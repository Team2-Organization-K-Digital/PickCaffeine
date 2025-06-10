// 매장 기간 별 매출 차트 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Store Duration Chart Page
  - Description   : 매장의 점주가 기간 별 매출 data 를 chart 로 확인 할 수 있는 page
  -               : 기간은 Year  : 현재 날짜의 연도 이전 및 이후 2년 간의 data
  -               :      Month : 현재 날짜의 연도를 기준으로 1월 ~ 12월 간의 data
  -               :      Day   : 현재 날짜의 월 간 매출이 있는 날의 data
  -               :      Hour  : 현재 날짜를 기준으로 해당 일의 00시 ~ 24 시 까지의 data
  - Author        : Lee ChangJun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.09
  - package       : GetX, Syncfusion

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.06 v1.0.0  : 매장 기간 별 차트의 전반적인 화면 구성 추가

  - 2025.06.07 v1.0.1  : 전반적인 ui 디자인 재구성
// ----------------------------------------------------------------- //
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/chart_data_list.dart';
import 'package:pick_caffeine_app/vm/changjun/chart_handler.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StoreChartDuration extends StatelessWidget {
  StoreChartDuration({super.key});
  // ----------------------------------------------------------------- //
  final tooltipBehavior = TooltipBehavior(enable: true);
  final ChartHandler chartHandler = Get.find<JunTemp>();
  // ----------------------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------------- //
    chartHandler.fetchChart();
    // chartHandler.fetchMenu();
    // ----------------------------------------------------------------- //
    return Obx(() {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ButtonLightBrown(
                        text: '연 별 매출',
                        onPressed: () {
                          chartHandler.chartState.value = "year";
                          chartHandler.fetchChart();
                        },
                      ),
                      SizedBox(width: 10),
                      ButtonLightBrown(
                        text: '월 별 매출',
                        onPressed: () {
                          chartHandler.chartState.value = "month";
                          chartHandler.fetchChart();
                        },
                      ),
                      SizedBox(width: 10),
                      ButtonLightBrown(
                        text: '일 별 매출',
                        onPressed: () {
                          chartHandler.chartState.value = "day";
                          chartHandler.fetchChart();
                        },
                      ),
                      SizedBox(width: 10),
                      ButtonLightBrown(
                        text: '시간대 별 매출',
                        onPressed: () {
                          chartHandler.chartState.value = "hour";
                          chartHandler.fetchChart();
                        },
                      ),
                    ],
                  ),
                ),
                // ------------------ //
                // Chart
                chartHandler.chartData.isNotEmpty
                    ? SizedBox(
                      width: 400,
                      height: 600,
                      child: SfCartesianChart(
                        title: ChartTitle(
                          text: '${chartHandler.chartState.value} 별 매출',
                        ),
                        tooltipBehavior: tooltipBehavior,
                        palette: <Color>[AppColors.brown],
                        series: [
                          LineSeries<ChartData, int>(
                            dataSource: chartHandler.chartData,
                            xValueMapper:
                                (ChartData date, _) => int.parse(date.date),
                            yValueMapper:
                                (ChartData totalPrice, _) =>
                                    totalPrice.totalPrice,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                            ),
                          ),
                        ],
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(text: chartHandler.chartState.value),
                        ),
                        primaryYAxis: CategoryAxis(
                          title: AxisTitle(text: '매출 (원)'),
                        ),
                      ),
                    )
                    // ------------------ //
                    : SizedBox(
                      width: 400,
                      height: 600,
                      child: Center(
                        child: Text('해당 기간의 data 가 없습니다 다른 기간을 선택 해주세요.'),
                      ),
                    ),
                // ------------------ //
              ],
            ),
          ),
        ),
      );
    });
  } // build

  // --------------------------------------------------------- //
  // Column(
  //   children: [
  //     // ElevatedButton(
  //     //   onPressed: () => Get.to(()=>ProductsChart()),
  //     //   child: Text('제품별 매출')
  //     // ),
  //     ElevatedButton(
  //       onPressed: () => _showDialogue(),
  //       child: Text('메뉴 선택')
  //     )
  //   ],
  // ),
  // --------------------------------------------------------- //
  // _showDialogue()async{
  //   await Get.defaultDialog(
  //     title: '선택',
  //     content: Column(
  //       children: [
  //         ElevatedButton(
  //           onPressed: () {
  //             chartHandler.menuNum.value = " ";
  //             chartHandler.fetchChart();
  //           },
  //           child: Text('전체 매출')
  //         ),
  //         SingleChildScrollView(scrollDirection: Axis.vertical, child: SizedBox(width: 300, height: 200, child: buttonList())),
  //       ],
  //     ),
  //     actions: [
  //       TextButton(
  //         onPressed: () => Get.back(),
  //         child: Text('취소')
  //       )
  //     ]
  //   );
  // }
  // ---------------------------------------------------------------------- //
  // Widget buttonList(){
  // return ListView.builder(
  //   itemCount: chartHandler.menuList.length,
  //   itemBuilder: (context, index) {
  //     final store = chartHandler.menuList[index];
  //     return ElevatedButton(
  //       onPressed: () async{
  //         chartHandler.menuNum.value = store.menuNum.toString();
  //         await chartHandler.fetchChart();
  //         Get.back();
  //       },
  //       child: Text(store.menuName)
  //     );
  //   },
  //   );
  // }
  // ---------------------------------------------------------------------- //
}// class