class DatasetSample {
  DatasetSample({
    required this.id,
    required this.commodityId,
    required this.label,
    required this.imagePath,
    this.createdAt,
  });

  final String id;
  final String commodityId;
  final String label;
  final String imagePath;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commodity_id': commodityId,
      'label': label,
      'image_path': imagePath,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory DatasetSample.fromMap(Map<String, dynamic> map) {
    return DatasetSample(
      id: map['id'] as String? ?? '',
      commodityId: map['commodity_id'] as String? ?? '',
      label: map['label'] as String? ?? 'UNLABELED',
      imagePath: map['image_path'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
