// // 매장 제품 별 매출 차트 페이지
// /*
// // ----------------------------------------------------------------- //
//   - title         : Store Products Chart Page
//   - Description   : 매장 의 점주가 제품들의 판매 매출을 pie chart 로 확인하는 페이지
//   -               : 월 별로 button 을 통해 선택하여 매출을 확인 할 수 있다.
//   - Author        : Lee ChangJun
//   - Created Date  : 2025.06.05
//   - Last Modified : 2025.06.09
//   - package       : GetX, Syncfusion

// // ----------------------------------------------------------------- //
//   [Changelog]
//   - 2025.06.06 v1.0.0  : 전반적인 화면 디자인 및 vm 과 model 을 연결하여 데이터 확인
// // ----------------------------------------------------------------- //
// */

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pick_caffeine_app/model/changjun/chart_model/chart_products_list.dart';
// import 'package:pick_caffeine_app/vm/changjun/chart_handler.dart';
// import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
// import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class StoreChartProducts extends StatelessWidget {
//   StoreChartProducts({super.key});
// // ----------------------------------------------------------------- //
//     final priceTooltip = TooltipBehavior(enable: true);
//     final quantityTooltip = TooltipBehavior(enable: true);
//     final ChartHandler chartHandler = Get.find<JunTemp>();
    
    
// // ----------------------------------------------------------------- //
//   @override
//   Widget build(BuildContext context) {
// // ----------------------------------------------------------------- //
// chartHandler.fetchProductChart(DateTime.now().year,DateTime.now().month);
// chartHandler.fetchDuration();
// // ----------------------------------------------------------------- //
//     return Obx(
//       () {
//   if (chartHandler.chartProductData.isEmpty) {
//     return Scaffold(
//       body: Center(child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               _showDialogue();
//             }, 
//             child: Text('월별 제품 매출')
//           ),
//           Text('해당 월의 데이터가 없습니다'),
//         ],
//       )),
//     );
//   }
//       return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Column(
//             children: [
//               SizedBox(
//                 width: 400,
//                 height: 600,
//                 child: SfCircularChart(
//                   title: ChartTitle(
//                     text: '제품별 매출'),
//                     tooltipBehavior: priceTooltip,
//                     series: [
//                       PieSeries<ChartProductsList, String>(
//                         dataSource: chartHandler.chartProductData,
//                         xValueMapper: (ChartProductsList date, _) => date.productName, 
//                         yValueMapper: (ChartProductsList totalPrice, _) => totalPrice.total,
//                         dataLabelMapper: (ChartProductsList data, _) => '${data.productName}\n₩${data.total.toString()}',
//                         dataLabelSettings: DataLabelSettings(
//                           isVisible: true,
//                           labelPosition: ChartDataLabelPosition.outside,
//                         ),
//                       ),
//                     ],
//                 ),
//               ),
//             SizedBox(
//               width: 400,
//               height: 70,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: chartHandler.chartQuantityData.length,
//                 itemBuilder: (context, index) {
//                   final data = chartHandler.chartQuantityData[index];
//                   return Card(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("제품 명: ${data.productName}"),
//                         Text('수량 (잔):${data.total.toString()}')
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//               ButtonLightBrown(text: '월 별 제품 매출', 
//               onPressed: () => _showDialogue(),
//               ),
//             ],
//           ),
//         ),
//       ),
//           );
//       },
//     );
//   }// build
// // --------------------------------------------------------- //
// _showDialogue()async{
//   Get.defaultDialog(
//     title: '선택',
//     content:Obx(() => SingleChildScrollView(scrollDirection: Axis.vertical, child: SizedBox(width: 300, height: 200, child: buttonList()))) ,
//     actions: [
//       TextButton(
//         onPressed: () => Get.back(), 
//         child: Text('취소')
//       )
//     ]
//   );
// }
// // --------------------------------------------------------- //
// Widget buttonList(){
// return ListView.builder(
//   itemCount: chartHandler.durationList.length,
//   itemBuilder: (context, index) {
//     final store = chartHandler.durationList[index];
//     return ElevatedButton(
//       onPressed: () {
//         chartHandler.fetchProductChart(store.storeYear,store.storeMonth);
//         Get.back();
//       }, 
//       child: Text("${store.storeYear}년 - ${store.storeMonth}월")
//     );
//   },
//   );
// }
// // --------------------------------------------------------- //
// }// class