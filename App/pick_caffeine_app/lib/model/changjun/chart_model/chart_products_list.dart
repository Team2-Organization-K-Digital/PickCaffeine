class ChartProductsList {
  final String productName;
  final int  total;

  ChartProductsList(
    {
      required this.productName,
      required this.total,
    }
  );
// ----------------------------------------------------------- //
  @override
  String toString() {
    return 'ChartProductsDate(productName: $productName, totalPrice: $total)';
  }
}
