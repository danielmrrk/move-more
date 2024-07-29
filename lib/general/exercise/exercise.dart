class Exercise {
  int id;
  String name;
  String pluralizedName;
  String imageUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.pluralizedName,
    required this.imageUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      pluralizedName: json['pluralizedName'],
      imageUrl: json['imageUrl'],
    );
  }
}
