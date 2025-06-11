class Categories {
  final int? category_num;
  final String store_id;
  final String category_name;

  Categories({
    this.category_num,
    required this.store_id,
    required this.category_name,
  });

  Map<String, dynamic> toMap() {
    return {
      'category_num': category_name,
      'store_id': store_id,
      'category_name': category_name,
    };
  }
}
