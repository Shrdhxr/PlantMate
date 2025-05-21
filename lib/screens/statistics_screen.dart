import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:plantmate/models/plant.dart';
import 'package:plantmate/models/care_log.dart';
import 'package:plantmate/providers/plants_provider.dart';
import 'package:plantmate/providers/care_logs_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsProvider);
    final careLogsAsync = ref.watch(careLogsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plant Statistics',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          _buildPlantCountCard(context, plantsAsync),
          const SizedBox(height: 16),
          _buildCareActivityCard(context, careLogsAsync),
          const SizedBox(height: 16),
          _buildPlantCategoriesCard(context, plantsAsync),
          const SizedBox(height: 16),
          _buildCareTypeDistributionCard(context, careLogsAsync),
        ],
      ),
    );
  }

  Widget _buildPlantCountCard(BuildContext context, AsyncValue<List<Plant>> plantsAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plant Collection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            plantsAsync.when(
              data: (plants) {
                final needsWatering = plants.where((p) => p.needsWatering()).length;
                final needsFertilizing = plants.where((p) => p.needsFertilizing()).length;
                final needsRepotting = plants.where((p) => p.needsRepotting()).length;
                
                return Column(
                  children: [
                    _buildStatRow(
                      context,
                      label: 'Total Plants',
                      value: plants.length.toString(),
                      icon: Icons.spa,
                    ),
                    _buildStatRow(
                      context,
                      label: 'Needs Watering',
                      value: needsWatering.toString(),
                      icon: Icons.water_drop,
                      color: needsWatering > 0 ? Colors.blue : null,
                    ),
                    _buildStatRow(
                      context,
                      label: 'Needs Fertilizing',
                      value: needsFertilizing.toString(),
                      icon: Icons.eco,
                      color: needsFertilizing > 0 ? Colors.green : null,
                    ),
                    _buildStatRow(
                      context,
                      label: 'Needs Repotting',
                      value: needsRepotting.toString(),
                      icon: Icons.swap_horiz,
                      color: needsRepotting > 0 ? Colors.orange : null,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareActivityCard(BuildContext context, AsyncValue<List<CareLog>> careLogsAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: careLogsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const Center(
                      child: Text('No care logs recorded yet'),
                    );
                  }
                  
                  final now = DateTime.now();
                  final sevenDaysAgo = now.subtract(const Duration(days: 7));
                  
                  final Map<DateTime, int> activityByDate = {};
                  
                  for (int i = 0; i < 7; i++) {
                    final date = now.subtract(Duration(days: i));
                    final dateWithoutTime = DateTime(date.year, date.month, date.day);
                    activityByDate[dateWithoutTime] = 0;
                  }
                  
                  for (final log in logs) {
                    if (log.date.isAfter(sevenDaysAgo)) {
                      final dateWithoutTime = DateTime(log.date.year, log.date.month, log.date.day);
                      activityByDate[dateWithoutTime] = (activityByDate[dateWithoutTime] ?? 0) + 1;
                    }
                  }
                  
                  final sortedDates = activityByDate.keys.toList()
                    ..sort((a, b) => a.compareTo(b));
                  
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: activityByDate.values.isEmpty
                          ? 1
                          : (activityByDate.values.reduce((a, b) => a > b ? a : b) * 1.2),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final date = sortedDates[groupIndex];
                            return BarTooltipItem(
                              '${date.day}/${date.month}: ${rod.toY.toInt()} activities',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                                final date = sortedDates[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('${date.day}/${date.month}'),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) {
                                return const Text('0');
                              }
                              if (value % 1 == 0) {
                                return Text(value.toInt().toString());
                              }
                              return const Text('');
                            },
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        sortedDates.length,
                        (index) {
                          final date = sortedDates[index];
                          final count = activityByDate[date] ?? 0;
                          
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                color: Theme.of(context).colorScheme.primary,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCategoriesCard(BuildContext context, AsyncValue<List<Plant>> plantsAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plant Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: plantsAsync.when(
                data: (plants) {
                  if (plants.isEmpty) {
                    return const Center(
                      child: Text('No plants added yet'),
                    );
                  }
                  
                  final Map<PlantCategory, int> plantsByCategory = {};
                  
                  for (final category in PlantCategory.values) {
                    plantsByCategory[category] = 0;
                  }
                  
                  for (final plant in plants) {
                    for (final category in plant.categories) {
                      plantsByCategory[category] = (plantsByCategory[category] ?? 0) + 1;
                    }
                  }
                  
                  final nonEmptyCategories = plantsByCategory.entries
                      .where((entry) => entry.value > 0)
                      .toList();
                  
                  if (nonEmptyCategories.isEmpty) {
                    return const Center(
                      child: Text('No categories assigned yet'),
                    );
                  }
                  
                  return PieChart(
                    PieChartData(
                      sections: nonEmptyCategories.map((entry) {
                        final category = entry.key;
                        final count = entry.value;
                        
                        Color color;
                        switch (category) {
                          case PlantCategory.indoor:
                            color = Colors.green;
                            break;
                          case PlantCategory.outdoor:
                            color = Colors.blue;
                            break;
                          case PlantCategory.succulent:
                            color = Colors.amber;
                            break;
                          case PlantCategory.herb:
                            color = Colors.purple;
                            break;
                          case PlantCategory.ornamental:
                            color = Colors.red;
                            break;
                        }
                        
                        return PieChartSectionData(
                          color: color,
                          value: count.toDouble(),
                          title: '${Plant.categoryToString(category)}\n$count',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 0,
                      sectionsSpace: 2,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareTypeDistributionCard(BuildContext context, AsyncValue<List<CareLog>> careLogsAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Type Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: careLogsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const Center(
                      child: Text('No care logs recorded yet'),
                    );
                  }
                  
                  final Map<CareType, int> logsByCareType = {};
                  
                  for (final type in CareType.values) {
                    logsByCareType[type] = 0;
                  }
                  
                  for (final log in logs) {
                    logsByCareType[log.careType] = (logsByCareType[log.careType] ?? 0) + 1;
                  }
                  
                  final nonEmptyCareTypes = logsByCareType.entries
                      .where((entry) => entry.value > 0)
                      .toList();
                  
                  if (nonEmptyCareTypes.isEmpty) {
                    return const Center(
                      child: Text('No care logs recorded yet'),
                    );
                  }
                  
                  return PieChart(
                    PieChartData(
                      sections: nonEmptyCareTypes.map((entry) {
                        final careType = entry.key;
                        final count = entry.value;
                        
                        Color color;
                        switch (careType) {
                          case CareType.watering:
                            color = Colors.blue;
                            break;
                          case CareType.fertilizing:
                            color = Colors.green;
                            break;
                          case CareType.repotting:
                            color = Colors.brown;
                            break;
                          case CareType.pruning:
                            color = Colors.orange;
                            break;
                          case CareType.observation:
                            color = Colors.purple;
                            break;
                        }
                        
                        return PieChartSectionData(
                          color: color,
                          value: count.toDouble(),
                          title: '${careType.name}\n$count',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 0,
                      sectionsSpace: 2,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
