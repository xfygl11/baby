import 'package:drift/drift.dart';

@DataClassName('ExpenseRecord')
class ExpenseRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get category => text().withLength(max: 50)();
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get expenseDate => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}

enum ExpenseCategory {
  formula,
  diaper,
  medical,
  education,
  toy,
  clothing,
  food,
  transportation,
  entertainment,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.formula:
        return '奶粉';
      case ExpenseCategory.diaper:
        return '尿布';
      case ExpenseCategory.medical:
        return '医疗';
      case ExpenseCategory.education:
        return '教育';
      case ExpenseCategory.toy:
        return '玩具';
      case ExpenseCategory.clothing:
        return '服装';
      case ExpenseCategory.food:
        return '食品';
      case ExpenseCategory.transportation:
        return '交通';
      case ExpenseCategory.entertainment:
        return '娱乐';
      case ExpenseCategory.other:
        return '其他';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.formula:
        return '🍼';
      case ExpenseCategory.diaper:
        return '👶';
      case ExpenseCategory.medical:
        return '🏥';
      case ExpenseCategory.education:
        return '📚';
      case ExpenseCategory.toy:
        return '🧸';
      case ExpenseCategory.clothing:
        return '👕';
      case ExpenseCategory.food:
        return '🍎';
      case ExpenseCategory.transportation:
        return '🚗';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.other:
        return '💰';
    }
  }
}