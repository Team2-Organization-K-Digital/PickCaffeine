class Options {
  final int? option_num;
  final int menu_num;
  final String option_title;
  final String option_name;
  final int option_price;
  final int option_division;

  Options({
    this.option_num,
    required this.menu_num,
    required this.option_title,
    required this.option_name,
    required this.option_price,
    required this.option_division,
  });

  Map<String, dynamic> toMap() {
    return {
      "option_num": option_num,
      "menu_num": menu_num,
      "option_title": option_title,
      "option_name": option_name,
      "option_price": option_price,
      "option_division": option_division,
    };
  }
}

class OptionTitle {
  final String option_title;
  final int option_division;
  OptionTitle({required this.option_title, required this.option_division});
  factory OptionTitle.fromJson(List<dynamic> json) {
    return OptionTitle(option_title: json[0], option_division: json[1]);
  }
}
