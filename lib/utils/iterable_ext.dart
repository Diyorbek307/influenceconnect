/// Общие расширения для коллекций (вместо зависимости от package:collection).
extension IterableFirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
