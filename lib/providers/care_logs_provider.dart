import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmate/models/care_log.dart';
import 'package:plantmate/providers/plants_provider.dart';
import 'package:uuid/uuid.dart';

final careLogsProvider = StateNotifierProvider<CareLogsNotifier, AsyncValue<List<CareLog>>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return CareLogsNotifier(storageService);
});

final plantCareLogsProvider = Provider.family<AsyncValue<List<CareLog>>, String>((ref, plantId) {
  final careLogsAsync = ref.watch(careLogsProvider);
  
  return careLogsAsync.whenData((logs) {
    return logs.where((log) => log.plantId == plantId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); 
  });
});

class CareLogsNotifier extends StateNotifier<AsyncValue<List<CareLog>>> {
  final _storageService;
  final _uuid = const Uuid();
  
  CareLogsNotifier(this._storageService) : super(const AsyncValue.loading()) {
    _loadCareLogs();
  }
  
  Future<void> _loadCareLogs() async {
    try {
      final logs = await _storageService.getCareLogs();
      state = AsyncValue.data(logs);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> addCareLog(CareLog log) async {
    try {
      final newLog = CareLog(
        id: _uuid.v4(),
        plantId: log.plantId,
        date: log.date,
        careType: log.careType,
        notes: log.notes,
      );
      
      await _storageService.addCareLog(newLog);
      _loadCareLogs();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> deleteCareLog(String logId) async {
    try {
      await _storageService.deleteCareLog(logId);
      _loadCareLogs();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
