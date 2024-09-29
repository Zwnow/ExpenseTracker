class Account {
  int id;
  String name;
  double total;

  Account({
    required this.id,
    required this.name,
    required this.total,
  });

  @override
  String toString() {
    return "Account{id: $id, name: $name, total: $total}";
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'total': total,
    };
  }

  Map<String, Object?> toMapWithoutId() {
    return {
      'name': name,
      'total': total,
    };
  }
}