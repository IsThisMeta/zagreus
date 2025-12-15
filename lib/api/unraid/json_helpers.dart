/// Helper functions for Unraid JSON parsing.
///
/// The Unraid GraphQL API frequently returns large numeric values as strings.
/// These helpers normalize incoming values so the models can consume both
/// numeric and string representations without throwing cast exceptions.

int? parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return null;

    final intValue = int.tryParse(cleaned);
    if (intValue != null) return intValue;

    final doubleValue = double.tryParse(cleaned);
    if (doubleValue != null) return doubleValue.toInt();
  }
  return null;
}

int parseRequiredInt(dynamic value) {
  final parsed = parseNullableInt(value);
  if (parsed == null) {
    throw FormatException('Expected numeric value, received: $value');
  }
  return parsed;
}

double? parseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return null;

    final parsed = double.tryParse(cleaned);
    if (parsed != null) return parsed;
  }
  return null;
}

double parseRequiredDouble(dynamic value) {
  final parsed = parseNullableDouble(value);
  if (parsed == null) {
    throw FormatException('Expected decimal value, received: $value');
  }
  return parsed;
}
