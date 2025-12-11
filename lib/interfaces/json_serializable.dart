/// Base interface for all models with JSON serialization
abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}

/// Base interface for models that can be created from JSON
abstract class JsonDeserializable<T> {
  // Factory constructors can't be declared in interfaces,
  // but this serves as documentation for implementing classes
}
