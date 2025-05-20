import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:plantmate/utils/image_helper.dart';

enum SunlightPreference { low, medium, high }
enum PlantCategory { indoor, outdoor, succulent, herb, ornamental }

class Plant {
  final String id;
  final String name;
  final String species;
  final String imagePath;
  final SunlightPreference sunlightPreference;
  final double minTemperature;
  final double maxTemperature;
  final int wateringFrequencyDays;
  final int fertilizingFrequencyDays;
  final int repottingFrequencyMonths;
  final List<PlantCategory> categories;
  final List<String> tags;
  final DateTime dateAdded;
  final DateTime? lastWatered;
  final DateTime? lastFertilized;
  final DateTime? lastRepotted;

  Plant({
    required this.id,
    required this.name,
    this.species = '',
    required this.imagePath,
    required this.sunlightPreference,
    required this.minTemperature,
    required this.maxTemperature,
    required this.wateringFrequencyDays,
    required this.fertilizingFrequencyDays,
    required this.repottingFrequencyMonths,
    required this.categories,
    this.tags = const [],
    required this.dateAdded,
    this.lastWatered,
    this.lastFertilized,
    this.lastRepotted,
  });

  Plant copyWith({
    String? id,
    String? name,
    String? species,
    String? imagePath,
    SunlightPreference? sunlightPreference,
    double? minTemperature,
    double? maxTemperature,
    int? wateringFrequencyDays,
    int? fertilizingFrequencyDays,
    int? repottingFrequencyMonths,
    List<PlantCategory>? categories,
    List<String>? tags,
    DateTime? dateAdded,
    DateTime? lastWatered,
    DateTime? lastFertilized,
    DateTime? lastRepotted,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      imagePath: imagePath ?? this.imagePath,
      sunlightPreference: sunlightPreference ?? this.sunlightPreference,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      wateringFrequencyDays: wateringFrequencyDays ?? this.wateringFrequencyDays,
      fertilizingFrequencyDays: fertilizingFrequencyDays ?? this.fertilizingFrequencyDays,
      repottingFrequencyMonths: repottingFrequencyMonths ?? this.repottingFrequencyMonths,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      dateAdded: dateAdded ?? this.dateAdded,
      lastWatered: lastWatered ?? this.lastWatered,
      lastFertilized: lastFertilized ?? this.lastFertilized,
      lastRepotted: lastRepotted ?? this.lastRepotted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'imagePath': imagePath,
      'sunlightPreference': sunlightPreference.index,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'wateringFrequencyDays': wateringFrequencyDays,
      'fertilizingFrequencyDays': fertilizingFrequencyDays,
      'repottingFrequencyMonths': repottingFrequencyMonths,
      'categories': categories.map((c) => c.index).toList(),
      'tags': tags,
      'dateAdded': dateAdded.toIso8601String(),
      'lastWatered': lastWatered?.toIso8601String(),
      'lastFertilized': lastFertilized?.toIso8601String(),
      'lastRepotted': lastRepotted?.toIso8601String(),
    };
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      imagePath: json['imagePath'],
      sunlightPreference: SunlightPreference.values[json['sunlightPreference']],
      minTemperature: json['minTemperature'],
      maxTemperature: json['maxTemperature'],
      wateringFrequencyDays: json['wateringFrequencyDays'],
      fertilizingFrequencyDays: json['fertilizingFrequencyDays'],
      repottingFrequencyMonths: json['repottingFrequencyMonths'],
      categories: (json['categories'] as List).map((i) => PlantCategory.values[i]).toList(),
      tags: List<String>.from(json['tags']),
      dateAdded: DateTime.parse(json['dateAdded']),
      lastWatered: json['lastWatered'] != null ? DateTime.parse(json['lastWatered']) : null,
      lastFertilized: json['lastFertilized'] != null ? DateTime.parse(json['lastFertilized']) : null,
      lastRepotted: json['lastRepotted'] != null ? DateTime.parse(json['lastRepotted']) : null,
    );
  }

  static String sunlightToString(SunlightPreference pref) {
    switch (pref) {
      case SunlightPreference.low:
        return 'Low Light';
      case SunlightPreference.medium:
        return 'Medium Light';
      case SunlightPreference.high:
        return 'Bright Light';
    }
  }

  static String categoryToString(PlantCategory category) {
    switch (category) {
      case PlantCategory.indoor:
        return 'Indoor';
      case PlantCategory.outdoor:
        return 'Outdoor';
      case PlantCategory.succulent:
        return 'Succulent';
      case PlantCategory.herb:
        return 'Herb';
      case PlantCategory.ornamental:
        return 'Ornamental';
    }
  }

  bool needsWatering() {
    if (lastWatered == null) return true;
    final daysElapsed = DateTime.now().difference(lastWatered!).inDays;
    return daysElapsed >= wateringFrequencyDays;
  }

  bool needsFertilizing() {
    if (lastFertilized == null) return true;
    final daysElapsed = DateTime.now().difference(lastFertilized!).inDays;
    return daysElapsed >= fertilizingFrequencyDays;
  }

  bool needsRepotting() {
    if (lastRepotted == null) return true;
    final monthsElapsed = DateTime.now().difference(lastRepotted!).inDays ~/ 30;
    return monthsElapsed >= repottingFrequencyMonths;
  }
  
  // Helper method to get the appropriate image widget based on platform
  Widget getImage({BoxFit fit = BoxFit.cover}) {
    return ImageHelper.buildImage(imagePath, fit: fit);
  }
}
