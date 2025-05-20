import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:plantmate/models/plant.dart';
import 'package:plantmate/models/care_log.dart';

class StorageService {
  static const String _plantsFileName = 'plants.json';
  static const String _careLogsFileName = 'care_logs.json';
  static const String _initialPlantsAsset = 'assets/data/initial_plants.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _plantsFile async {
    final path = await _localPath;
    return File('$path/$_plantsFileName');
  }

  Future<File> get _careLogsFile async {
    final path = await _localPath;
    return File('$path/$_careLogsFileName');
  }

  // Initialize storage with sample data if needed
  Future<void> initializeStorage() async {
    final plantsFile = await _plantsFile;
    final careLogsFile = await _careLogsFile;

    if (!await plantsFile.exists()) {
      // Load initial plants data from assets
      final initialPlantsJson = await rootBundle.loadString(_initialPlantsAsset);
      await plantsFile.writeAsString(initialPlantsJson);
    }

    if (!await careLogsFile.exists()) {
      // Create empty care logs file
      await careLogsFile.writeAsString(jsonEncode([]));
    }
  }

  // Plants CRUD operations
  Future<List<Plant>> getPlants() async {
    try {
      final file = await _plantsFile;
      final contents = await file.readAsString();
      final List<dynamic> plantsJson = jsonDecode(contents);
      return plantsJson.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      // If there's an error, return an empty list
      return [];
    }
  }

  Future<void> savePlants(List<Plant> plants) async {
    final file = await _plantsFile;
    final plantsJson = plants.map((plant) => plant.toJson()).toList();
    await file.writeAsString(jsonEncode(plantsJson));
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
    
    // Also delete associated care logs
    final careLogs = await getCareLogs();
    careLogs.removeWhere((log) => log.plantId == plantId);
    await saveCareLogs(careLogs);
  }

  // Care Logs CRUD operations
  Future<List<CareLog>> getCareLogs() async {
    try {
      final file = await _careLogsFile;
      final contents = await file.readAsString();
      final List<dynamic> logsJson = jsonDecode(contents);
      return logsJson.map((json) => CareLog.fromJson(json)).toList();
    } catch (e) {
      // If there's an error, return an empty list
      return [];
    }
  }

  Future<List<CareLog>> getCareLogsForPlant(String plantId) async {
    final allLogs = await getCareLogs();
    return allLogs.where((log) => log.plantId == plantId).toList();
  }

  Future<void> saveCareLogs(List<CareLog> logs) async {
    final file = await _careLogsFile;
    final logsJson = logs.map((log) => log.toJson()).toList();
    await file.writeAsString(jsonEncode(logsJson));
  }

  Future<void> addCareLog(CareLog log) async {
    final logs = await getCareLogs();
    logs.add(log);
    await saveCareLogs(logs);
    
    // Update the plant's last care date
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
