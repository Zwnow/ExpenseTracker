enum PaymentInterval {
  single,       // One-time payment
  weekly,       // Payment every week
  biWeekly,     // Payment every two weeks
  monthly,      // Payment every month
  quarterly,    // Payment every three months
  semiAnnual,   // Payment every six months
  annual,       // Payment once a year
}

class Expense {
  int id;
  int accountId;
  int categoryId;
  PaymentInterval interval;
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
    this.interval,
  );

  factory Expense(DateTime createdOn, String title, double amount, int accountId, int categoryId, int id, PaymentInterval interval) {
    return Expense._internal(createdOn, amount, title, id, accountId, categoryId, interval);
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