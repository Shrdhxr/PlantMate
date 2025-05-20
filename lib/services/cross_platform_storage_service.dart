import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantmate/models/plant.dart';
import 'package:plantmate/models/care_log.dart';
import 'package:plantmate/services/storage_service.dart';

/// A storage service that works on both web and mobile platforms
class CrossPlatformStorageService extends StorageService {
  static const String _plantsKey = 'plants_data';
  static const String _careLogsKey = 'care_logs_data';
  static const String _initialPlantsAsset = 'assets/data/initial_plants.json';

  // Initialize storage with sample data if needed
  @override
  Future<void> initializeStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if plants data exists
    if (!prefs.containsKey(_plantsKey)) {
      // Load initial plants data from assets
      final initialPlantsJson = await rootBundle.loadString(_initialPlantsAsset);
      await prefs.setString(_plantsKey, initialPlantsJson);
    }
    
    // Check if care logs data exists
    if (!prefs.containsKey(_careLogsKey)) {
      // Create empty care logs
      await prefs.setString(_careLogsKey, jsonEncode([]));
    }
  }

  // Plants CRUD operations
  @override
  Future<List<Plant>> getPlants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plantsJson = prefs.getString(_plantsKey);
      
      if (plantsJson == null) {
        return [];
      }
      
      final List<dynamic> plantsData = jsonDecode(plantsJson);
      return plantsData.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      print('Error getting plants: $e');
      return [];
    }
  }

  @override
  Future<void> savePlants(List<Plant> plants) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plantsJson = plants.map((plant) => plant.toJson()).toList();
      await prefs.setString(_plantsKey, jsonEncode(plantsJson));
    } catch (e) {
      print('Error saving plants: $e');
    }
  }

  @override
  Future<void> addPlant(Plant plant) async {
    final plants = await getPlants();
    plants.add(plant);
    await savePlants(plants);
  }

  @override
  Future<void> updatePlant(Plant updatedPlant) async {
    final plants = await getPlants();
    final index = plants.indexWhere((plant) => plant.id == updatedPlant.id);
    if (index != -1) {
      plants[index] = updatedPlant;
      await savePlants(plants);
    }
  }

  @override
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
  @override
  Future<List<CareLog>> getCareLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_careLogsKey);
      
      if (logsJson == null) {
        return [];
      }
      
      final List<dynamic> logsData = jsonDecode(logsJson);
      return logsData.map((json) => CareLog.fromJson(json)).toList();
    } catch (e) {
      print('Error getting care logs: $e');
      return [];
    }
  }

  @override
  Future<List<CareLog>> getCareLogsForPlant(String plantId) async {
    final allLogs = await getCareLogs();
    return allLogs.where((log) => log.plantId == plantId).toList();
  }

  @override
  Future<void> saveCareLogs(List<CareLog> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = logs.map((log) => log.toJson()).toList();
      await prefs.setString(_careLogsKey, jsonEncode(logsJson));
    } catch (e) {
      print('Error saving care logs: $e');
    }
  }

  @override
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

  @override
  Future<void> deleteCareLog(String logId) async {
    final logs = await getCareLogs();
    logs.removeWhere((log) => log.id == logId);
    await saveCareLogs(logs);
  }
}
