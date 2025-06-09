class Purchase {
  final int purchase_num;
  final String user_id;
  final String store_id;
  final String purchase_date;
  final String purchase_request;
  final String purchase_state;

  Purchase(
    {
      required this.purchase_num,
      required this.user_id,
      required this.store_id,
      required this.purchase_date,
      required this.purchase_request,
      required this.purchase_state
    }
  );
}