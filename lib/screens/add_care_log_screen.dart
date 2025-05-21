import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmate/models/care_log.dart';
import 'package:plantmate/providers/care_logs_provider.dart';
import 'package:plantmate/providers/plants_provider.dart';

class AddCareLogScreen extends ConsumerStatefulWidget {
  final String plantId;
  
  const AddCareLogScreen({
    Key? key,
    required this.plantId,
  }) : super(key: key);

  @override
  ConsumerState<AddCareLogScreen> createState() => _AddCareLogScreenState();
}

class _AddCareLogScreenState extends ConsumerState<AddCareLogScreen> {
  final _formKey = GlobalKey<FormState>();
  CareType _careType = CareType.watering;
  DateTime _date = DateTime.now();
  final _notesController = TextEditingController();
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(plantsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Care Log'),
      ),
      body: plantsAsync.when(
        data: (plants) {
          final plant = plants.firstWhere((p) => p.id == widget.plantId);
          
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add care log for ${plant.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildCareTypeSelector(),
                  const SizedBox(height: 16),
                  _buildDatePicker(context),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Add any observations or notes',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveCareLog,
                      child: const Text('Save Care Log'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildCareTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Care Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<CareType>(
          segments: CareType.values.map((type) {
            IconData icon;
            switch (type) {
              case CareType.watering:
                icon = Icons.water_drop;
                break;
              case CareType.fertilizing:
                icon = Icons.eco;
                break;
              case CareType.repotting:
                icon = Icons.swap_horiz;
                break;
              case CareType.pruning:
                icon = Icons.content_cut;
                break;
              case CareType.observation:
                icon = Icons.visibility;
                break;
            }
            
            return ButtonSegment<CareType>(
              value: type,
              label: Text(type.name),
              icon: Icon(icon),
            );
          }).toList(),
          selected: {_careType},
          onSelectionChanged: (Set<CareType> selection) {
            setState(() {
              _careType = selection.first;
            });
          },
          multiSelectionEnabled: false,
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _saveCareLog() {
    if (_formKey.currentState!.validate()) {
      final careLog = CareLog(
        id: '',
        plantId: widget.plantId,
        date: _date,
        careType: _careType,
        notes: _notesController.text,
      );
      
      ref.read(careLogsProvider.notifier).addCareLog(careLog);
      
      if (_careType == CareType.watering) {
        ref.read(plantsProvider.notifier).waterPlant(widget.plantId);
      } else if (_careType == CareType.fertilizing) {
        ref.read(plantsProvider.notifier).fertilizePlant(widget.plantId);
      } else if (_careType == CareType.repotting) {
        ref.read(plantsProvider.notifier).repotPlant(widget.plantId);
      }
      
      Navigator.pop(context);
    }
  }
}
