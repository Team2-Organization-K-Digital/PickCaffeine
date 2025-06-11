class Store {
  final String store_id;
  final String store_password;
  final String store_name;
  final String store_phone;
  final String store_address;
  final String store_addressdetail;
  final double store_latitude;
  final double store_longitude;
  final String store_content;
  final int store_state;
  final int store_business_num;
  final String store_regular_hoilday;
  final String store_temporary_holiday;
  final String store_business_hour;
  final String store_created_date;

  Store({
    required this.store_id,
    required this.store_password,
    required this.store_name,
    required this.store_phone,
    required this.store_address,
    required this.store_addressdetail,
    required this.store_latitude,
    required this.store_longitude,
    required this.store_content,
    required this.store_state,
    required this.store_business_num,
    required this.store_regular_hoilday,
    required this.store_temporary_holiday,
    required this.store_business_hour,
    required this.store_created_date,
  });

  Map<String, dynamic> toJson() {
    return {
      'store_id': store_id,
      'store_password': store_password,
      'store_name': store_name,
      'store_phone': store_phone,
      'store_address': store_address,
      'store_addressdetail': store_addressdetail,
      'store_latitude': store_latitude,
      'store_longitude': store_longitude,
      'store_content': store_content,
      'store_state': store_state,
      'store_business_num': store_business_num,
      'store_regular_hoilday': store_regular_hoilday,
      'store_temporary_holiday': store_temporary_holiday,
      'store_business_hour': store_business_hour,
      'store_created_date': store_created_date,
    };
  }
}

class MyStores {
  final String user_id;
  final String store_id;
  final String selected_date;

  MyStores({
    required this.user_id,
    required this.store_id,
    required this.selected_date,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'store_id': store_id,
      'selected_date': selected_date,
    };
  }
}
