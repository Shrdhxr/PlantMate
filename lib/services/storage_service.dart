import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantmate/models/plant.dart';
import 'package:plantmate/models/care_log.dart';

class StorageService {
  static const String _plantsFileName = 'plants.json';
  static const String _careLogsFileName = 'care_logs.json';
  static const String _initialPlantsAsset = 'assets/data/initial_plants.json';
  
  static const String _plantsKey = 'plants_data';
  static const String _careLogsKey = 'care_logs_data';

  Future<void> initializeStorage() async {
    if (kIsWeb) {
      await _initializeWebStorage();
    } else {
      await _initializeNativeStorage();
    }
  }

  // Web platform initialization
  Future<void> _initializeWebStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey(_plantsKey)) {
      final initialPlantsJson = await rootBundle.loadString(_initialPlantsAsset);
      await prefs.setString(_plantsKey, initialPlantsJson);
    }

    if (!prefs.containsKey(_careLogsKey)) {
      await prefs.setString(_careLogsKey, jsonEncode([]));
    }
  }

  Future<void> _initializeNativeStorage() async {
    try {
      final plantsFile = await _getPlantsFile();
      final careLogsFile = await _getCareLogsFile();

      if (!await plantsFile.exists()) {
        final initialPlantsJson = await rootBundle.loadString(_initialPlantsAsset);
        await plantsFile.writeAsString(initialPlantsJson);
      }

      if (!await careLogsFile.exists()) {
        await careLogsFile.writeAsString(jsonEncode([]));
      }
    } catch (e) {
      print('Error initializing native storage: $e');
      await _initializeWebStorage();
    }
  }

  Future<String> get _localPath async {
    if (kIsWeb) return '';
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      print('Error getting local path: $e');
      return '';
    }
  }

  Future<File> _getPlantsFile() async {
    final path = await _localPath;
    return File('$path/$_plantsFileName');
  }

  Future<File> _getCareLogsFile() async {
    final path = await _localPath;
    return File('$path/$_careLogsFileName');
  }

  Future<List<Plant>> getPlants() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final contents = prefs.getString(_plantsKey) ?? '[]';
        final List<dynamic> plantsJson = jsonDecode(contents);
        return plantsJson.map((json) => Plant.fromJson(json)).toList();
      } else {
        final file = await _getPlantsFile();
        final contents = await file.readAsString();
        final List<dynamic> plantsJson = jsonDecode(contents);
        return plantsJson.map((json) => Plant.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting plants: $e');
      return [];
    }
  }

  Future<void> savePlants(List<Plant> plants) async {
    final plantsJson = plants.map((plant) => plant.toJson()).toList();
    final jsonString = jsonEncode(plantsJson);
    
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_plantsKey, jsonString);
      } else {
        final file = await _getPlantsFile();
        await file.writeAsString(jsonString);
      }
    } catch (e) {
      print('Error saving plants: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_plantsKey, jsonString);
    }
  }

  Future<void> addPlant(Plant plant) async {
    final plants = await getPlants();
    plants.add(plant);
    await savePlants(plants);
  }

  Future<void> updatePlant(Plant updatedPlant) async {
    final plants = await getPlants();
    final index = plants.indexWhere((plant) => plant.id == updatedPlant.id);
    if (index != -1) {
      plants[index] = updatedPlant;
      await savePlants(plants);
    }
  }

  Future<void> deletePlant(String plantId) async {
    final plants = await getPlants();
    plants.removeWhere((plant) => plant.id == plantId);
    await savePlants(plants);
    
    final careLogs = await getCareLogs();
    careLogs.removeWhere((log) => log.plantId == plantId);
    await saveCareLogs(careLogs);
  }

  Future<List<CareLog>> getCareLogs() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final contents = prefs.getString(_careLogsKey) ?? '[]';
        final List<dynamic> logsJson = jsonDecode(contents);
        return logsJson.map((json) => CareLog.fromJson(json)).toList();
      } else {
        final file = await _getCareLogsFile();
        final contents = await file.readAsString();
        final List<dynamic> logsJson = jsonDecode(contents);
        return logsJson.map((json) => CareLog.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting care logs: $e');
      return [];
    }
  }

  Future<List<CareLog>> getCareLogsForPlant(String plantId) async {
    final allLogs = await getCareLogs();
    return allLogs.where((log) => log.plantId == plantId).toList();
  }

  Future<void> saveCareLogs(List<CareLog> logs) async {
    final logsJson = logs.map((log) => log.toJson()).toList();
    final jsonString = jsonEncode(logsJson);
    
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_careLogsKey, jsonString);
      } else {
        final file = await _getCareLogsFile();
        await file.writeAsString(jsonString);
      }
    } catch (e) {
      print('Error saving care logs: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_careLogsKey, jsonString);
    }
  }

  Future<void> addCareLog(CareLog log) async {
    final logs = await getCareLogs();
    logs.add(log);
    await saveCareLogs(logs);
    
    final plants = await getPlants();
    final plantIndex = plants.indexWhere((plant) => plant.id == log.plantId);
    
    if (plantIndex != -1) {
      final plant = plants[plantIndex];
      Plant updatedPlant;
      
      switch (log.careType) {
        case CareType.watering:
          updatedPlant = plant.copyWith(lastWatered: log.date);
          break;
        case CareType.fertilizing:
          updatedPlant = plant.copyWith(lastFertilized: log.date);
          break;
        case CareType.repotting:
          updatedPlant = plant.copyWith(lastRepotted: log.date);
          break;
        default:
          updatedPlant = plant;
      }
      
      plants[plantIndex] = updatedPlant;
      await savePlants(plants);
    }
  }

  Future<void> deleteCareLog(String logId) async {
    final logs = await getCareLogs();
    logs.removeWhere((log) => log.id == logId);
    await saveCareLogs(logs);
  }
}
