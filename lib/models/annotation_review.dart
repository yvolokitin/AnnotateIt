class AnnotationSchema {
  static const int currentVersion = 1;

  const AnnotationSchema._();
}

class AnnotationReviewStatus {
  static const String draft = 'draft';
  static const String proposed = 'proposed';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';

  static const Set<String> values = <String>{
    draft,
    proposed,
    accepted,
    rejected,
  };

  const AnnotationReviewStatus._();

  static String normalize(String? raw) {
    final value = raw?.trim().toLowerCase();
    if (value != null && values.contains(value)) {
      return value;
    }
    return draft;
  }

  static bool isValid(String value) => values.contains(value);

  static bool canTransition(String from, String to) {
    if (from == to) return true;

    switch (from) {
      case draft:
        return to == proposed;
      case proposed:
        return to == draft || to == accepted || to == rejected;
      case rejected:
        return to == draft || to == proposed;
      case accepted:
        return to == draft;
      default:
        return false;
    }
  }
}
