class SelectedMenu {
  final int? selected_num;
  final int menu_num;
  final Map<String, String>? selected_options;
  final int total_price;
  final int purchase_num;
  final int selected_quantity;

  SelectedMenu({
    this.selected_num,
    required this.menu_num,
    this.selected_options,
    required this.total_price,
    required this.purchase_num,
    required this.selected_quantity,
  });

  factory SelectedMenu.fromJson(List<dynamic> json) {
    return SelectedMenu(
      selected_num: json[0],
      menu_num: json[1],
      selected_options: json[2],
      total_price: json[3],
      purchase_num: json[4],
      selected_quantity: json[5],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_num': menu_num,
      'selected_options': selected_options,
      'total_price': total_price,
      'purchase_num': purchase_num,
      'selected_quantity': selected_quantity,
    };
  }
}

class SelectedOptions {
  final List<Map<String, String>> selectOptions;
  SelectedOptions({required this.selectOptions});
  factory SelectedOptions.fromJson(List<dynamic> json) {
    return SelectedOptions(selectOptions: json[0]);
  }
}
