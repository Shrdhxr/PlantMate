import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmate/models/plant.dart';
import 'package:plantmate/services/storage_service.dart';
import 'package:uuid/uuid.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final plantsProvider = StateNotifierProvider<PlantsNotifier, AsyncValue<List<Plant>>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return PlantsNotifier(storageService);
});

final filteredPlantsProvider = Provider<AsyncValue<List<Plant>>>((ref) {
  final plants = ref.watch(plantsProvider);
  final filter = ref.watch(plantFilterProvider);
  
  return plants.whenData((plantsList) {
    if (filter.isEmpty) return plantsList;
    
    return plantsList.where((plant) {
      // Filter by name or species
      if (plant.name.toLowerCase().contains(filter.toLowerCase()) ||
          plant.species.toLowerCase().contains(filter.toLowerCase())) {
        return true;
      }
      
      // Filter by tags
      for (final tag in plant.tags) {
        if (tag.toLowerCase().contains(filter.toLowerCase())) {
          return true;
        }
      }
      
      return false;
    }).toList();
  });
});

final plantFilterProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<PlantCategory?>((ref) => null);

final categoryFilteredPlantsProvider = Provider<AsyncValue<List<Plant>>>((ref) {
  final plants = ref.watch(filteredPlantsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  if (selectedCategory == null) {
    return plants;
  }
  
  return plants.whenData((plantsList) {
    return plantsList.where((plant) => 
      plant.categories.contains(selectedCategory)
    ).toList();
  });
});

class PlantsNotifier extends StateNotifier<AsyncValue<List<Plant>>> {
  final StorageService _storageService;
  final _uuid = const Uuid();
  
  PlantsNotifier(this._storageService) : super(const AsyncValue.loading()) {
    _loadPlants();
  }
  
  Future<void> _loadPlants() async {
    try {
      await _storageService.initializeStorage();
      final plants = await _storageService.getPlants();
      state = AsyncValue.data(plants);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> addPlant(Plant plant) async {
    try {
      final newPlant = plant.copyWith(id: _uuid.v4());
      await _storageService.addPlant(newPlant);
      _loadPlants();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> updatePlant(Plant plant) async {
    try {
      await _storageService.updatePlant(plant);
      _loadPlants();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> deletePlant(String plantId) async {
    try {
      await _storageService.deletePlant(plantId);
      _loadPlants();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> waterPlant(String plantId) async {
    state.whenData((plants) async {
      final index = plants.indexWhere((p) => p.id == plantId);
      if (index != -1) {
        final plant = plants[index];
        final updatedPlant = plant.copyWith(lastWatered: DateTime.now());
        await _storageService.updatePlant(updatedPlant);
        _loadPlants();
      }
    });
  }
  
  Future<void> fertilizePlant(String plantId) async {
    state.whenData((plants) async {
      final index = plants.indexWhere((p) => p.id == plantId);
      if (index != -1) {
        final plant = plants[index];
        final updatedPlant = plant.copyWith(lastFertilized: DateTime.now());
        await _storageService.updatePlant(updatedPlant);
        _loadPlants();
      }
    });
  }
  
  Future<void> repotPlant(String plantId) async {
    state.whenData((plants) async {
      final index = plants.indexWhere((p) => p.id == plantId);
      if (index != -1) {
        final plant = plants[index];
        final updatedPlant = plant.copyWith(lastRepotted: DateTime.now());
        await _storageService.updatePlant(updatedPlant);
        _loadPlants();
      }
    });
  }
}
