abstract class TestCache<T> {
  Future<T?> getCache(int id);

  Future<void> setCache(T data);

  Future<List<T>> getAllCache();

  Future<void> deleteCache(int id);
}