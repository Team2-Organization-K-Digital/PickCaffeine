import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/model/changjun/chart_model/admin_total_price.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/chart_data_list.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/chart_menu.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/chart_products_list.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/store_duration.dart';
import 'package:pick_caffeine_app/vm/changjun/account_handler.dart';

class ChartHandler extends AccountHandler{
// ------- Store ------ //
  final RxList<ChartData> chartData = <ChartData>[].obs;
  final RxList<ChartProductsList> chartProductData = <ChartProductsList>[].obs;

  final RxString chartState = 'month'.obs;

// 매장의 회원가입 날짜의 연도, 월 부터 오늘 날짜의 연도,월 까지 1달 씩 들어있는 List
  final RxList<StoreDuration> durationList= <StoreDuration>[].obs;
  final RxList<int> durationYearList= <int>[].obs;

  final RxList<ChartMenu> menuList = <ChartMenu>[].obs;
  final RxString menuNum = " ".obs;

// 사용자가 선택한 chart 의 유형 (기간 별 매출 : duration / 해당 기간의 제품 별 매출 : products)
  final RxString typeOfChart = 'duration'.obs;
// 연도 별 매출 : 선택 년도
  final RxString selectedChartYear = DateTime.now().year.toString().obs;
  final RxString selectedDateYear = '연도 선택'.obs;
// 월 별 매출 : 선택 연도-월
  final RxString selectedChartMonthYear = DateTime.now().year.toString().obs;
  final RxString selectedChartMonth = DateTime.now().month.toString().obs;
  final RxString selectedDateMonth = '월 선택'.obs;
  // 일 별 매출 : 선택 연도-월-일
  final RxString selectedChartDayYear = DateTime.now().year.toString().obs;
  final RxString selectedChartDayMonth = DateTime.now().month.toString().obs;
  final RxString selectedChartDay = DateTime.now().day.toString().obs;
  final RxString selectedDateDay = "일 선택".obs;
// 선택된 chart 의 state 를 반영할 변수
  final RxString chartType = 'daily'.obs;
// ------- Admin ------ //
  final RxList<AdminTotalPrice> adminTotalChartList = <AdminTotalPrice>[].obs;
// ---------------------------------------------------------------------------------- //
// 1. 매장의 전체 매출을 연도 별로 보여주는 chart 에 삽입할 연도 별 매출 data 를 불러오는 함수
  Future<void> fetchYearChart()async{
  String storeId =box.read('loginId');
    try{
      chartData.clear();
      final res = await http.get(Uri.parse("$baseUrl/select/year/$storeId"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      final List <ChartData> returnResult =
          results.map((data) {
            return ChartData(
              date: data[0],
              totalPrice: data[1]
            );
          }).toList();
          chartData.value = returnResult;
  }catch(e){
    print("Error : $e");
    // error = '불러오기 실패: $e';
  }
}
// ---------------------------------------------------------------------------------- //
// 1-1. 매장의 전체 매출을 월 별로 보여주는 chart 에 삽입할 월 별 매출 data 를 불러오는 함수
  Future<void> fetchYearlyChart()async{
  String storeId =box.read('loginId');
    try{
      chartData.clear();
      final res = await http.get(Uri.parse("$baseUrl/select/month/$storeId/$selectedChartYear"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      final List <ChartData> returnResult =
          results.map((data) {
            return ChartData(
              date: data[0],
              totalPrice: data[1]
            );
          }).toList();
          chartData.value = returnResult;
  }catch(e){
    print("Error : $e");
    // error = '불러오기 실패: $e';
  }
}
// ---------------------------------------------------------------------------------- //
// 1-2. 매장의 전체 매출을 일 별로 보여주는 chart 에 삽입할 일 별 매출 data 를 불러오는 함수
  Future<void> fetchMonthlyChart()async{
  String storeId =box.read('loginId');
    try{
      chartData.clear();
      final res = await http.get(Uri.parse("$baseUrl/select/day/$storeId/$selectedChartDayYear/$selectedChartMonth"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      final List <ChartData> returnResult =
          results.map((data) {
            return ChartData(
              date: data[0],
              totalPrice: data[1]
            );
          }).toList();
          chartData.value = returnResult;
  }catch(e){
    print("Error : $e");
    // error = '불러오기 실패: $e';
  }
}
// ---------------------------------------------------------------------------------- //
// 1-3. 매장의 전체 매출을 시간 별로 보여주는 chart 에 삽입할 시간 별 매출 data 를 불러오는 함수
  Future<void> fetchdailyChart()async{
  String storeId =box.read('loginId');
    try{
      chartData.clear();
      final res = await http.get(Uri.parse("$baseUrl/select/day/$storeId/$selectedChartMonthYear/$selectedChartDayMonth/$selectedChartDay"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      final List <ChartData> returnResult =
          results.map((data) {
            return ChartData(
              date: data[0],
              totalPrice: data[1]
            );
          }).toList();
          chartData.value = returnResult;
  }catch(e){
    print("Error : $e");
    // error = '불러오기 실패: $e';
  }
}
// ---------------------------------------------------------------------------------- //
// 2. 선택한 연도와 월 값을 통해 해당 일자의 제품 별 매출의 총 합 data 를 추출하는 함수
  Future<void> fetchProductsMonthlyChart()async{
  String storeId =box.read('loginId');
    try{
      chartProductData.clear();
      final res = await http.get(Uri.parse("$baseUrl/selectProduct/month/$storeId/$selectedChartMonthYear/$selectedChartMonth"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      final List <ChartProductsList> returnResult =
          results.map((data) {
            // print(data[0].runtimeType);
            // print(data[1].runtimeType);
            return ChartProductsList(
              productName: data[0], 
              total: data[1], 
              quantity: data[2]
            );
          }).toList();
          chartProductData.value = returnResult;
// 제품 별 매출 : total 순으로 정렬 / 제품 별 판매수량 : quantity 순으로 정렬
          typeOfChart.value == 'products'
          ? chartProductData.sort((a, b) => b.total.compareTo(a.total))
          : chartProductData.sort((a, b) => b.quantity!.compareTo(a.quantity!));
  }catch(e){
    print("Error : $e");
    // error = '불러오기 실패: $e';
  }
}
// ---------------------------------------------------------------------------------- //
// 2-2. 선택한 연도 값을 통해 해당 일자의 제품 별 매출의 총 합 data 를 추출하는 함수
  Future<void> fetchProductsYearlyChart()async{
  String storeId =box.read('loginId');
    try{
      chartProductData.clear();
      final res = await http.get(Uri.parse("$baseUrl/selectProduct/year/$storeId/$selectedChartYear"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      final List <ChartProductsList> returnResult =
          results.map((data) {
            // print(data[0].runtimeType);
            // print(data[1].runtimeType);
            return ChartProductsList(
              productName: data[0], 
              total: data[1], 
              quantity: data[2]
            );
          }).toList();
          chartProductData.value = returnResult;
// 제품 별 매출 : total 순으로 정렬 / 제품 별 판매수량 : quantity 순으로 정렬
          typeOfChart.value == 'products'
          ? chartProductData.sort((a, b) => b.total.compareTo(a.total))
          : chartProductData.sort((a, b) => b.quantity!.compareTo(a.quantity!));
  }catch(e){
    print("Error : $e");
    // error = '불러오기 실패: $e';
  }
}
// ---------------------------------------------------------------------------------- //
// 2-3. 선택한 연도, 월, 일 값을 통해 해당 일자의 제품 별 매출의 총 합 data 를 추출하는 함수
  Future<void> fetchProductsDailyChart()async{
  String storeId =box.read('loginId');
    try{
      chartProductData.clear();
      final res = await http.get(Uri.parse("$baseUrl/selectProduct/day/$storeId/$selectedChartDayYear/$selectedChartDayMonth/$selectedChartDay"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      final List <ChartProductsList> returnResult =
          results.map((data) {
            // print(data[0].runtimeType);
            // print(data[1].runtimeType);
            return ChartProductsList(
              productName: data[0], 
              total: data[1], 
              quantity: data[2]
            );
          }).toList();
          chartProductData.value = returnResult;
// 제품 별 매출 : total 순으로 정렬 / 제품 별 판매수량 : quantity 순으로 정렬
          typeOfChart.value == 'products'
          ? chartProductData.sort((a, b) => b.total.compareTo(a.total))
          : chartProductData.sort((a, b) => b.quantity!.compareTo(a.quantity!));
  }catch(e){
    print("Error : $e");
    // error = '불러오기 실패: $e';
  }
}
// ---------------------------------------------------------------------------------- //
// 3. 제품 매출 선택에 필요한 년도, 월 을 선택하는 버튼 list 에 들어가는 data 를 추출하기 위한 함수
  Future<String> fetchDuration()async{
    String storeId = box.read('loginId');
      final res = await http.get(Uri.parse("$baseUrl/selectDuration/$storeId"));
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
// 4. 년도 를 선택하는 버튼 list 에 들어가는 data 를 추출하기 위한 함수
  Future<String> fetchYearDuration()async{
    String storeId = box.read('loginId');
      final res = await http.get(Uri.parse("$baseUrl/selectDuration/year/$storeId"));
      final data = json.decode(utf8.decode(res.bodyBytes))['results'];
      // print(data);
      int storeYear = data[0]['year'];
      await addDurationYearList(storeYear);
      return "Success";
  }
// ---------------------------------------------------------------------------------- //
// 4-1. 매장의 생성 연도 부터 오늘 날짜의 연도 까지를 list 에 추가하는 함수
addDurationYearList(int storeYear){
  durationYearList.clear();
  final int thisYear = DateTime.now().year;
  for (int year = storeYear; year <= thisYear; year++) {
    durationYearList.add(year);
  }
}
// ---------------------------------------------------------------------------------- //
// 5. 해당 매장에 있는 메뉴의 id 와 이름을 list로 추출하는 함수
  Future<void> fetchMenu()async{
    String storeid = box.read('loginId');
      final res = await http.get(Uri.parse("$baseUrl/selectMenu/$storeid"));
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
// 6. 관리자 페이징 에서 앱을 이용하는 매장의 전체 기간에서 매출과 거래 량을 추출하는 함수
  Future<void> fetchAdminTotalPrice()async{
    try{
      chartData.clear();
      final res = await http.get(Uri.parse("$baseUrl/select/admins/totalPrice"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      final List <AdminTotalPrice> returnResult =
          results.map((data) {
            return AdminTotalPrice(
              date: '전체', 
              total: data[0],
            );
          }).toList();
          adminTotalChartList.value = returnResult;
  }catch(e){
    print("Error : $e");
    // error = '불러오기 실패: $e';
  }
}
// ---------------------------------------------------------------------------------- //
// // 6. database 에서 전체 제품의 선택 연, 월 에 해당하는 매출을 추출하는 함수
//   Future<void> fetchQuantityChart(int year, int month)async{
//     String storeId = box.read('loginId');
//       chartProductData.clear();
//       final res = await http.get(Uri.parse("$baseUrl/selectQuantity/$storeId/$year/$month/$menuNum"));
//       final data = json.decode(utf8.decode(res.bodyBytes));
//       final List results = data['results'];
//       // print(results);
//       final List <ChartProductsList> returnResult =
//           results.map((data) {
//             return ChartProductsList(
//               productName: data['productName'],
//               total:data['totalQuantity'],
//             );
//           }).toList();
//           // print(returnResult);
//           // print(chartProductData);
//           chartQuantityData.value = returnResult;
          
//           // print(chartQuantityData);
// }
// ---------------------------------------------------------------------------------- /
}