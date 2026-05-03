enum AppCategory {
  entertainment,
  education,
  productivity,
  social,
  game,
  system,
  other,
}

extension AppCategoryExtension on AppCategory {
  String get displayName {
    switch (this) {
      case AppCategory.entertainment:
        return 'Entertainment';
      case AppCategory.education:
        return 'Education';
      case AppCategory.productivity:
        return 'Productivity';
      case AppCategory.social:
        return 'Social';
      case AppCategory.game:
        return 'Gaming';
      case AppCategory.system:
        return 'System';
      case AppCategory.other:
        return 'Other';
    }
  }
}

AppCategory appCategoryConverter(int? categoryInt) {
  switch (categoryInt) {
    case 0:
      return AppCategory.game;
    case 1:
    case 2:
      return AppCategory.entertainment;
    case 3:
    case 7:
      return AppCategory.productivity;
    case 4:
      return AppCategory.social;
    case 5:
      return AppCategory.education;
    case 6:
      return AppCategory.other;
    case 8:
      return AppCategory.system;
    case -1:
      return AppCategory.other;
    default:
      return AppCategory.other;
  }
}
