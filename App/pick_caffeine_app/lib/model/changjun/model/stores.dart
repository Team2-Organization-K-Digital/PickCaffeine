class Stores {
  final String storeId;
  final String storeName;
  final int myStoreCount;
  final int reviewCount;
  final double distance;
  final String storeState;
  final String storeImage;

// ----------------------------------------------------------- //
  Stores(
    {
      required this.storeId,
      required this.storeName,
      required this.myStoreCount,
      required this.reviewCount,
      required this.distance,
      required this.storeState,
      required this.storeImage
    }
  );
// ----------------------------------------------------------- //
// // Map -> ChartData 로 변환 (DB 조회)
//   factory Stores.fromMap(Map<String, dynamic> map){
//     return Stores(
//       storeId: map['storeId'], 
//       storeName: map['storeName'], 
//       myStoreCount: map['myStoreCount'], 
//       reviewCount: map['reviewCount'], 
//       distance: map['distance'],
//       storeImage: map['storeImage']
//     );
//   }
// ----------------------------------------------------------- //

}