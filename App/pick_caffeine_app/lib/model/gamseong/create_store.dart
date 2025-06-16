class CreateStore {
  final String? store_id;
  final String store_password;
  final String store_name;
  final String store_phone;
  final int store_business_num;
  final String store_address;
  final String store_address_detail;
  final String store_created_date;

  CreateStore({
    this.store_id,
    required this.store_password,
    required this.store_name,
    required this.store_phone,  
    required this.store_business_num,
    required this.store_address,
    required this.store_address_detail,
    required this.store_created_date,
    

  });

  factory CreateStore.fromMap(Map<String, dynamic> map) {
    return CreateStore(
      store_id: map['store_id'],
      store_password: map['store_password'],
      store_name: map['store_name'],
      store_phone: map['store_phone'],
      store_business_num: map['store_business_num'],
      store_address: map['store_address'],
      store_address_detail: map['store_address_detail'],
      store_created_date: map['store_created_date'],
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'store_id': store_id,
      'store_password': store_password,
      'store_name': store_name,
      'store_phone': store_phone,
      'store_business_num': store_business_num,
      'store_address': store_address,
      'store_address_detail': store_address_detail,
      'store_created_date': store_created_date,
    };

  }






}

