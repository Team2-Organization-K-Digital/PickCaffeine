class StoreHome {
  final String? store_id; //매장아이디
  final String store_password; //비밀번호
  final String store_name;//매장이름
  final String store_phone;  //매장전화번호
  final String store_address; //매장주소
  final String store_address_detail;  //매장주소디테일
  final double store_latitude; //위도
  final double store_longitude; //경도
  final String store_content; // 매장설명
  final int store_state; //매장상태
  final int store_business_num; //사업자번호
  final String store_regular_holiday; //정기휴무
  final String store_temporary_holiday; // 임시휴무
  final String store_business_hour; //영업시간



  StoreHome(
    {
      this.store_id,
      required this.store_password,
      required this.store_name,
      required this.store_phone,
      required this.store_address,
      required this.store_address_detail,
      required this.store_latitude,
      required this.store_longitude,
      required this.store_content,
      required this.store_state,
      required this.store_business_num,
      required this.store_regular_holiday,
      required this.store_temporary_holiday,
      required this.store_business_hour,
    }
  );

factory StoreHome.fromMap(Map<String, dynamic> map) {
  return StoreHome(
    store_id: map['store_id'] ?? '',
    store_password: map['store_password'] ?? '',
    store_name: map['store_name'] ?? '',
    store_phone: map['store_phone'] ?? '',
    store_address: map['store_address'] ?? '',
    store_address_detail: map['store_address_detail'] ?? '',
    store_latitude: map['store_latitude']?.toDouble() ?? 0.0,
    store_longitude: map['store_longitude']?.toDouble() ?? 0.0,
    store_content: map['store_content'] ?? '',
    store_state: map['store_state']  ?? '' ,
    store_business_num: map['store_business_num'] ?? '',
    store_regular_holiday: map['store_regular_holiday'] ?? '',
    store_temporary_holiday: map['store_temporary_holiday'] ?? '',
    store_business_hour: map['store_business_hour'] ?? '',
  );
}

Map<String, dynamic> toMap() {
  return {
    'store_id': store_id,
    'store_password': store_password,
    'store_name': store_name,
    'store_phone': store_phone,
    'store_address': store_address,
    'store_address_detail': store_address_detail,
    'store_latitude': store_latitude,
    'store_longitude': store_longitude,
    'store_content': store_content, 
    'store_state': store_state,
    'store_business_num': store_business_num,
    'store_regular_holiday': store_regular_holiday,
    'store_temporary_holiday': store_temporary_holiday,
    'store_business_hour': store_business_hour,
  };
}



}
