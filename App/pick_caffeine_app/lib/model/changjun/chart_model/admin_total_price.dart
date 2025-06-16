class AdminTotalPrice {
  final String date;
  final int total;
  int? quantity;

  AdminTotalPrice(
    {
      required this.date,
      required this.total,
      this.quantity
    }
  );
}