class SelectedMenu {
  final int? selected_num;
  final int menu_num;
  final Map<String, String>? selected_options;
  final int total_price;

  SelectedMenu({
    this.selected_num,
    required this.menu_num,
    this.selected_options,
    required this.total_price,
  });

  factory SelectedMenu.fromJson(List<dynamic> json) {
    return SelectedMenu(
      selected_num: json[0],
      menu_num: json[1],
      selected_options: json[2],
      total_price: json[3],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_num': menu_num,
      'selected_options': selected_options,
      'total_price': total_price,
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
