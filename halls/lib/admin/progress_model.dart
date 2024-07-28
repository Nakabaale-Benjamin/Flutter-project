class Progress {
  final String name;
  final String registrationNumber;
  final String? hall;
  final int? bedspace;
  final int weight;

  Progress({
    required this.name,
    required this.registrationNumber,
    this.hall,
    this.bedspace,
    required this.weight,
  });

  // Convert a Progress object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'registrationNumber': registrationNumber,
      'hall': hall,
      'bedspace': bedspace,
      'weight': weight,
    };
  }

  // Create a Progress object from a Map
  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      name: map['name'],
      registrationNumber: map['registrationNumber'],
      hall: map['hall'],
      bedspace: map['bedspace'],
      weight: map['weight'],
    );
  }
}
