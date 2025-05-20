import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:plantmate/models/plant.dart';
import 'package:plantmate/models/care_log.dart';
import 'package:plantmate/providers/plants_provider.dart';
import 'package:plantmate/providers/care_logs_provider.dart';
import 'package:plantmate/screens/edit_plant_screen.dart';
import 'package:plantmate/screens/add_care_log_screen.dart';
import 'package:plantmate/widgets/care_log_list.dart';

class PlantDetailScreen extends ConsumerWidget {
  final Plant plant;

  const PlantDetailScreen({
    Key? key,
    required this.plant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careLogs = ref.watch(plantCareLogsProvider(plant.id));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPlantScreen(plant: plant),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context, ref);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlantImage(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (plant.species.isNotEmpty)
                    Text(
                      plant.species,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildCareActions(context, ref),
                  const SizedBox(height: 24),
                  _buildPlantDetails(context),
                  const SizedBox(height: 24),
                  _buildCareSchedule(context),
                  const SizedBox(height: 24),
                  _buildCareHistory(context, careLogs),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCareLogScreen(plantId: plant.id),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlantImage() {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: plant.imagePath.startsWith('assets/')
          ? Image.asset(
              plant.imagePath,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(plant.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCareActions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCareButton(
          context,
          icon: Icons.water_drop,
          label: 'Water',
          isNeeded: plant.needsWatering(),
          onPressed: () {
            ref.read(plantsProvider.notifier).waterPlant(plant.id);
            
            // Add care log
            ref.read(careLogsProvider.notifier).addCareLog(
              CareLog(
                id: '',
                plantId: plant.id,
                date: DateTime.now(),
                careType: CareType.watering,
              ),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plant watered!')),
            );
          },
        ),
        _buildCareButton(
          context,
          icon: Icons.eco,
          label: 'Fertilize',
          isNeeded: plant.needsFertilizing(),
          onPressed: () {
            ref.read(plantsProvider.notifier).fertilizePlant(plant.id);
            
            // Add care log
            ref.read(careLogsProvider.notifier).addCareLog(
              CareLog(
                id: '',
                plantId: plant.id,
                date: DateTime.now(),
                careType: CareType.fertilizing,
              ),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plant fertilized!')),
            );
          },
        ),
        _buildCareButton(
          context,
          icon: Icons.swap_horiz,
          label: 'Repot',
          isNeeded: plant.needsRepotting(),
          onPressed: () {
            ref.read(plantsProvider.notifier).repotPlant(plant.id);
            
            // Add care log
            ref.read(careLogsProvider.notifier).addCareLog(
              CareLog(
                id: '',
                plantId: plant.id,
                date: DateTime.now(),
                careType: CareType.repotting,
              ),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plant repotted!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCareButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isNeeded,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: isNeeded
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            foregroundColor: isNeeded
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isNeeded
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isNeeded ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPlantDetails(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plant Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow(
              context,
              label: 'Sunlight',
              value: Plant.sunlightToString(plant.sunlightPreference),
              icon: Icons.wb_sunny,
            ),
            _buildDetailRow(
              context,
              label: 'Temperature',
              value: '${plant.minTemperature}°C - ${plant.maxTemperature}°C',
              icon: Icons.thermostat,
            ),
            _buildDetailRow(
              context,
              label: 'Categories',
              value: plant.categories
                  .map((c) => Plant.categoryToString(c))
                  .join(', '),
              icon: Icons.category,
            ),
            if (plant.tags.isNotEmpty)
              _buildDetailRow(
                context,
                label: 'Tags',
                value: plant.tags.join(', '),
                icon: Icons.tag,
              ),
            _buildDetailRow(
              context,
              label: 'Added on',
              value: DateFormat.yMMMd().format(plant.dateAdded),
              icon: Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareSchedule(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Schedule',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildScheduleRow(
              context,
              label: 'Watering',
              frequency: 'Every ${plant.wateringFrequencyDays} days',
              lastDate: plant.lastWatered,
              icon: Icons.water_drop,
            ),
            _buildScheduleRow(
              context,
              label: 'Fertilizing',
              frequency: 'Every ${plant.fertilizingFrequencyDays} days',
              lastDate: plant.lastFertilized,
              icon: Icons.eco,
            ),
            _buildScheduleRow(
              context,
              label: 'Repotting',
              frequency: 'Every ${plant.repottingFrequencyMonths} months',
              lastDate: plant.lastRepotted,
              icon: Icons.swap_horiz,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareHistory(BuildContext context, AsyncValue<List<CareLog>> careLogsAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Care History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            SizedBox(
              height: 300,
              child: CareLogList(careLogsAsync: careLogsAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(
    BuildContext context, {
    required String label,
    required String frequency,
    required DateTime? lastDate,
    required IconData icon,
  }) {
    final lastDateText = lastDate != null
        ? DateFormat.yMMMd().format(lastDate)
        : 'Never';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Frequency: $frequency'),
                Text('Last done: $lastDateText'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete ${plant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(plantsProvider.notifier).deletePlant(plant.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to plant list
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
