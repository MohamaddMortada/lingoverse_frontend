class Challenge {
  final int id;
  final String description;

  Challenge({required this.id, required this.description});

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      description: json['description'],
    );
  }
}