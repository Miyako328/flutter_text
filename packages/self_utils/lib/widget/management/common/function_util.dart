typedef InFunc<T> = void Function(T arg);
typedef OutFunc<T> = T Function();
typedef InOutFunc<T,R> = R Function(T arg);


typedef InFutureFunc<T> = Future<void> Function(T arg);
typedef OutFutureFunc<T> = Future<T> Function();
typedef InOutFutureFunc<T,R> = Future<R> Function(T arg);


