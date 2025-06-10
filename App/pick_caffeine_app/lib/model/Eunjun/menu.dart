class Menu {
  final int? menu_num;
  final int category_num;
  final String menu_name;
  final String menu_content;
  final int menu_price;
  final String menu_image;
  final int menu_state;

  Menu({
    this.menu_num,
    required this.category_num,
    required this.menu_name,
    required this.menu_content,
    required this.menu_price,
    required this.menu_image,
    required this.menu_state,
  });

  Map<String, dynamic> toMap() {
    return {
      'menu_num': menu_num,
      'category_num': category_num,
      'menu_name': menu_name,
      'menu_content': menu_content,
      'menu_price': menu_price,
      'menu_image': menu_image,
      'menu_state': menu_state,
    };
  }
}
