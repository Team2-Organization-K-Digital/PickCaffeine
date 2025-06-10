import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/model/changjun/chart_model/chart_data_list.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/chart_menu.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/chart_products_list.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/store_duration.dart';
import 'package:pick_caffeine_app/vm/changjun/account_handler.dart';

class ChartHandler extends AccountHandler{
  final RxList<ChartData> chartData = <ChartData>[].obs;
  final RxList<ChartProductsList> chartProductData = <ChartProductsList>[].obs;
  final RxList<ChartProductsList> chartQuantityData = <ChartProductsList>[].obs;

  final RxString chartState = 'month'.obs;

// 매장의 회원가입 날짜의 연도, 월 부터 오늘 날짜의 연도,월 까지 1달 씩 들어있는 List
  final RxList<StoreDuration> durationList= <StoreDuration>[].obs;

  final RxList<ChartMenu> menuList = <ChartMenu>[].obs;
  final RxString menuNum = " ".obs;

// ---------------------------------------------------------------------------------- //
  @override
  void onInit() async{
    super.onInit();
    final now = DateTime.now();
    await fetchDuration();
    fetchProductChart(now.year, now.month);
    fetchQuantityChart(now.year, now.month);
  }
// ---------------------------------------------------------------------------------- //
//1. 앱을 실행 할 때 작동되며 사용자가 data 를 입력하는 등의 변화가 있었을 때 데이터를 다시 불러와 list 에 담는 함수
  Future<void> fetchChart()async{
  
    try{
      chartData.clear();
      final res = await http.get(Uri.parse("$baseUrl/select/$chartState/doog2089"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      final List <ChartData> returnResult =
          results.map((data) {
            return ChartData(
              date: chartState.value == 'month' 
              ?data[0].toString().substring(5,7)
              : chartState.value == 'year'
              ?data[0].toString().substring(0,4)
              : chartState.value == 'day'
              ?data[0].toString().substring(8,10)
              :data[0].toString().substring(11),
              totalPrice: data[1]
            );
          }).toList();
          chartData.value = returnResult;

  }catch(e){
    // error = '불러오기 실패: $e';
  }
}
// ---------------------------------------------------------------------------------- //
// 2. database 에서 전체 제품의 선택 연, 월 에 해당하는 매출을 추출하는 함수
  Future<void> fetchProductChart(int year, int month)async{

      chartProductData.clear();
      final res = await http.get(Uri.parse("$baseUrl/selectProduct/doog2089/$year/$month/$menuNum"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      // print(results);
      final List <ChartProductsList> returnResult =
          results.map((data) {
            return ChartProductsList(
              productName: data['productName'],
              total:data['totalPrice'],
            );
          }).toList();
          // print(returnResult);
          // print(chartProductData);
          chartProductData.value = returnResult;
          
          // print(chartProductData);
}
// ---------------------------------------------------------------------------------- //
// 3. 제품 매출 선택에 필요한 년도, 월 을 선택하는 버튼 list 에 들어가는 data 를 추출하기 위한 함수
  Future<String> fetchDuration()async{
      final res = await http.get(Uri.parse("$baseUrl/selectDuration/doog2089"));
      final data = json.decode(utf8.decode(res.bodyBytes))['results'];
      // print(data);
      int storeYear = data[0]['year'];
      int storeMonth = data[0]['month'];
      await addDurationList(storeYear,storeMonth);
      return "Success";
  }
// ---------------------------------------------------------------------------------- //
// 3-1. 해당 매장의 가입 연도, 월 부터 오늘 날짜의 연도, 월 에 해당하는 list 를 추출하는 함수
addDurationList(int storeYear, int storeMonth){
  final int thisYear = DateTime.now().year;
  final int thisMonth = DateTime.now().month;

  for (int year = storeYear; year <= thisYear; year++) {
    if (year == thisYear) {
      for (var month = 1; month <= thisMonth; month++) {
        durationList.add(StoreDuration(storeYear: year, storeMonth: month));
      }
    } else if(year == storeYear){
      for (int month = storeMonth; month <= 12; month++) {
        durationList.add(StoreDuration(storeYear: year, storeMonth: month));
      }
    }else{
      for (int month = 1; month <= 12; month++) {
      durationList.add(StoreDuration(storeYear: year, storeMonth: month));
      }
    }
  }
}
// ---------------------------------------------------------------------------------- //
// 4. 해당 매장에 있는 메뉴의 id 와 이름을 list로 추출하는 함수
  Future<void> fetchMenu()async{
      final res = await http.get(Uri.parse("$baseUrl/selectMenu/doog2089"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      
      final List <ChartMenu> returnResult =
          results.map((data) {
            return ChartMenu(
              menuNum: data[0], 
              menuName: data[1]
            );
          }).toList();
          menuList.value = returnResult;
  }
// ---------------------------------------------------------------------------------- //
// 2. database 에서 전체 제품의 선택 연, 월 에 해당하는 매출을 추출하는 함수
  Future<void> fetchQuantityChart(int year, int month)async{

      chartProductData.clear();
      final res = await http.get(Uri.parse("$baseUrl/selectQuantity/doog2089/$year/$month/$menuNum"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      // print(results);
      final List <ChartProductsList> returnResult =
          results.map((data) {
            return ChartProductsList(
              productName: data['productName'],
              total:data['totalQuantity'],
            );
          }).toList();
          // print(returnResult);
          // print(chartProductData);
          chartQuantityData.value = returnResult;
          
          // print(chartQuantityData);
}
// ---------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------- //
}