class StoreDuration {
  final int storeYear;
  final int storeMonth;

  StoreDuration(
    {
      required this.storeYear,
      required this.storeMonth,
    }
  );
  @override
  String toString() {
    return 'StoreDuration(storeYear: $storeYear, storeMonth: $storeMonth)';
  }
}