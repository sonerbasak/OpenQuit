/// Thrown by data sources when a local DB operation fails.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache operation failed.']);

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when an entity is not found in the data source.
class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Entity not found.']);

  @override
  String toString() => 'NotFoundException: $message';
}
