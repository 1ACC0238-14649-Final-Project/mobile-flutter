class UIState<T> {
  final bool loading;
  final T? data;
  final String? message;

  const UIState({this.loading = false, this.data, this.message});

  UIState<T> copyWith({bool? loading, T? data, String? message}) {
    return UIState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      message: message,
    );
  }

  static UIState<T> idle<T>() => UIState<T>(loading: false, data: null);
  static UIState<T> loadingState<T>() => UIState<T>(loading: true);
  static UIState<T> dataState<T>(T data) => UIState<T>(data: data);
  static UIState<T> errorState<T>(String msg) => UIState<T>(message: msg);
}
