class Category {
  int id;
  String name;
  String? description;

  Category({
    required this.id, 
    required this.name, 
    required this.description
  });
  
  @override
  String toString() {
    return "Category{id: $id, name: $name, description: $description}";
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}