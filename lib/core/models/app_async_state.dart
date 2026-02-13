enum AppAsyncStatus { idle, loading, success, empty, error }

class AppAsyncState<T> {
  const AppAsyncState._({
    required this.status,
    this.data,
    this.message,
    this.retryAction,
  });

  final AppAsyncStatus status;
  final T? data;
  final String? message;
  final Future<void> Function()? retryAction;

  bool get isIdle => status == AppAsyncStatus.idle;
  bool get isLoading => status == AppAsyncStatus.loading;
  bool get isSuccess => status == AppAsyncStatus.success;
  bool get isEmpty => status == AppAsyncStatus.empty;
  bool get isError => status == AppAsyncStatus.error;

  factory AppAsyncState.idle() => const AppAsyncState._(
        status: AppAsyncStatus.idle,
      );

  factory AppAsyncState.loading() => const AppAsyncState._(
        status: AppAsyncStatus.loading,
      );

  factory AppAsyncState.success(T data) => AppAsyncState._(
        status: AppAsyncStatus.success,
        data: data,
      );

  factory AppAsyncState.empty() => const AppAsyncState._(
        status: AppAsyncStatus.empty,
      );

  factory AppAsyncState.error({
    required String message,
    Future<void> Function()? retryAction,
  }) =>
      AppAsyncState._(
        status: AppAsyncStatus.error,
        message: message,
        retryAction: retryAction,
      );
}
