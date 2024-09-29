class Expense {
  int id;
  int accountId;
  int categoryId;
  double amount;
  String title;
  DateTime createdOn;

  Expense._internal(
    this.createdOn,
    this.amount,
    this.title,
    this.id,
    this.accountId,
    this.categoryId,
  );

  factory Expense(DateTime createdOn, String title, double amount, int accountId, int categoryId, int id) {
    return Expense._internal(createdOn, amount, title, id, accountId, categoryId);
  }

  @override
  String toString() {
    return "Expense{amount: $amount, title: $title, created_on: $createdOn}";
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'category_id': categoryId,
      'title': title,
      'amount': amount,
      'created_on': createdOn,
    };
  }
}