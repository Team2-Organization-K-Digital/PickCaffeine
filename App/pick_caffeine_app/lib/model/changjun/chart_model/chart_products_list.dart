class ChartProductsList {
  final String productName;
  final int  total;
  int? quantity;

  ChartProductsList(
    {
      required this.productName,
      required this.total,
      this.quantity,
    }
  );
// ----------------------------------------------------------- //
  @override
  String toString() {
    return 'ChartProductsDate(productName: $productName, totalPrice: $total)';
  }
}
