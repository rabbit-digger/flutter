extension MapValue<K, V> on Map<K, V> {
  Map<K, U> mapValue<U>(U Function(V) mapper) {
    return Map.fromEntries(
        entries.map((e) => MapEntry(e.key, mapper(e.value))));
  }
}
