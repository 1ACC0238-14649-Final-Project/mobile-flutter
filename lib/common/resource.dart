sealed class Resource<T> {
  const Resource();
}
class Success<T> extends Resource<T> {
  final T data;
  const Success(this.data);
}
class ErrorRes<T> extends Resource<T> {
  final Object error;
  final StackTrace? stackTrace;
  const ErrorRes(this.error, [this.stackTrace]);
}
class Loading<T> extends Resource<T> {
  const Loading();
}
