class Trail {
  final String id;
  final String name;
  final String location;
  final String difficulty;
  final double length;
  final String estimatedTime;
  final String description;
  final String imageUrl;

  Trail({
    required this.id,
    required this.name,
    required this.location,
    required this.difficulty,
    required this.length,
    required this.estimatedTime,
    required this.description,
    required this.imageUrl,
  });

  factory Trail.fromMap(Map<String, dynamic> data, String id) {
    return Trail(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      difficulty: data['difficulty'] ?? '',
      length: (data['length'] ?? 0.0).toDouble(),
      estimatedTime: data['estimatedTime'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'difficulty': difficulty,
      'length': length,
      'estimatedTime': estimatedTime,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}