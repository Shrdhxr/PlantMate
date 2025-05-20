class CareLog {
  final String id;
  final String plantId;
  final DateTime date;
  final CareType careType;
  final String notes;

  CareLog({
    required this.id,
    required this.plantId,
    required this.date,
    required this.careType,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'date': date.toIso8601String(),
      'careType': careType.index,
      'notes': notes,
    };
  }

  factory CareLog.fromJson(Map<String, dynamic> json) {
    return CareLog(
      id: json['id'],
      plantId: json['plantId'],
      date: DateTime.parse(json['date']),
      careType: CareType.values[json['careType']],
      notes: json['notes'],
    );
  }
}

enum CareType {
  watering,
  fertilizing,
  repotting,
  pruning,
  observation
}

extension CareTypeExtension on CareType {
  String get name {
    switch (this) {
      case CareType.watering:
        return 'Watering';
      case CareType.fertilizing:
        return 'Fertilizing';
      case CareType.repotting:
        return 'Repotting';
      case CareType.pruning:
        return 'Pruning';
      case CareType.observation:
        return 'Observation';
    }
  }
}
