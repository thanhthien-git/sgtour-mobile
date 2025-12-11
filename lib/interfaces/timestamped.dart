/// Base interface for models with timestamp tracking
abstract class Timestamped {
  DateTime get createdAt;
  DateTime get updatedAt;
}
