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
  - Last Modified : 2025.06.13
  - package       : GetX, Syncfusion, intl

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.06 v1.0.0  : 매장 기간 별 차트의 전반적인 화면 구성 추가

  - 2025.06.07 v1.0.1  : 전반적인 ui 디자인 재구성

  - 2025.06.13 v1.0.2  : 버튼을 통해 사용자가 원하는 유형의 기간 별 매출을 확인 할 수 있고
  -                      해당 유형에서 원하는 연, 월, 일 을 선택하여 매출을 확인 할 수 있도록 구현

  -                    : 총 매출을 보여주는 line chart 와 제품 별 총 매출을 보여주는 bar chart 구현

  - 2025.06.13 v1.0.3  : 제품 별 판매수량 차트 추가, 내림차순 정렬 적용 (큰 값이 위로 오게)
// ----------------------------------------------------------------- //
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/chart_data_list.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/chart_products_list.dart';
import 'package:pick_caffeine_app/vm/changjun/chart_handler.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/widget_class/utility/Ipod_button_brown.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';
import 'package:pick_caffeine_app/widget_class/utility/ipod_button_light_brown.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class StoreChartDuration extends StatelessWidget {
  StoreChartDuration({super.key});
  // ----------------------------------------------------------------- //
  final tooltipBehavior = TooltipBehavior(enable: true);
  final ChartHandler chartHandler = Get.find<JunTemp>();
  final now = DateTime.now();

  // ----------------------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------------- //

    // ----------------------------------------------------------------- //
    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.lightpick,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
// Button : 연도 별 매출
                        IpodButtonBrown(
                          text: '연도 별 매출',
                          onPressed: () {
                            chartHandler.chartType.value = 'all';
                            chartHandler.fetchYearChart();
                            chartHandler.fetchProductsYearlyChart();
                          },
                        ),
// Button : 연간 매출
                        SizedBox(width: 10),
                        IpodButtonBrown(
                          text: '연간 매출',
                          onPressed: () {
                            chartHandler.chartType.value = 'yearly';
                            chartHandler.fetchYearlyChart();
                            chartHandler.fetchProductsYearlyChart();
                          } 
                        ),
// Button : 월간 매출
                        SizedBox(width: 10),
                        IpodButtonBrown(
                          text: '월간 매출',
                          onPressed: () {
                            chartHandler.chartType.value = 'monthly';
                            chartHandler.fetchMonthlyChart();
                            chartHandler.fetchProductsMonthlyChart();
                          }
                        ),
// Button : 일간 매출
                        SizedBox(width: 10),
                        IpodButtonBrown(
                          text: '일간 매출',
                          onPressed: () {
                            chartHandler.chartType.value = 'daily';
                            chartHandler.fetchdailyChart();
                            chartHandler.fetchProductsDailyChart();
                          } 
                        ),
                      ],
                    ),
                  ),
// Button : Chart Type Change (Line Chart :duration / Bar Chart : products)
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IpodButtonLightBrown(text: '기간 별 매출', onPressed: () {
                        chartHandler.typeOfChart.value = 'duration';
                      },),
                      SizedBox(width: 10,),
                      IpodButtonLightBrown(text: '제품 별 매출', onPressed: () {
                        chartHandler.typeOfChart.value = 'products';
                      },),
                      SizedBox(width: 10,),
                      IpodButtonLightBrown(text: '제품 별 판매수량', onPressed: () {
                        chartHandler.typeOfChart.value = 'quantity';
                      },),
                    ],
                  ),
// ---------------------------------------------------------------------- //
// Chart 
                  chartHandler.typeOfChart.value == 'products'
                  ? chartHandler.chartProductData.isNotEmpty
                  ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                        height: 600,
// ------------------ //
// Chart : Bar Chart
                        child: SfCartesianChart(
                          title: ChartTitle(
                            text: chartHandler.chartType.value == 'yearly'
                            ?'연간 제품 별 판매액'
                            :chartHandler.chartType.value == 'monthly'
                            ?'월간 제품 별 매출'
                            :chartHandler.chartType.value == 'daily'
                            ?'일간 제품 별 매출'
                            :'연도 별 매출',
                            textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                          ),
                          tooltipBehavior: tooltipBehavior,
                          palette: <Color>[AppColors.brown],
// 가로형 수평 그래프로 변환 - 안해도 되는 상황이라 주석처리
                          // isTransposed: true,
                          series: [
                            BarSeries<ChartProductsList, String>(
                              dataSource: chartHandler.chartProductData,
// Bar Chart : X value
                              xValueMapper: (ChartProductsList data, _) => data.productName,
// Bar Chart : Y value
                              yValueMapper: (ChartProductsList data, _) => data.total,
                              dataLabelSettings: DataLabelSettings(isVisible: true),
                            )
                          ],
// Bar Chart : X Axis
                          primaryXAxis: CategoryAxis(
                            isInversed: true,
                            title: AxisTitle(
                              text: '제품 명',
                              textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
// Bar Chart : Y Axis
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: '매출 (원)',textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                            numberFormat: NumberFormat('#,##0', 'ko_KR'),
                            interval: chartHandler.chartType.value == 'yearly'
                            ? 5000000
                            :chartHandler.chartType.value == 'monthly'
                            ? 500000
                            :chartHandler.chartType.value == 'daily'
                            ? 50000
                            : 5000000
                          ),
                        ),
                  )
// Chart : Bar Chart has no Data
                  : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 600,
                        child: Center(
                          child: Text(
                            ' 다른 기간을 선택 해주세요.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      )
// ---------------------------------------------------------------------- //
// Chart : Line Chart
                  :chartHandler.typeOfChart.value == 'duration'
                      ? chartHandler.chartData.isNotEmpty
                      ?SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 600,
                        child: SfCartesianChart(
// Line Chart : Title
                          title: ChartTitle(
                            text: chartHandler.chartType.value == 'yearly'
                            ?'연간 매출'
                            :chartHandler.chartType.value == 'monthly'
                            ?'월간 매출'
                            :chartHandler.chartType.value == 'daily'
                            ?'일간 매출'
                            :'연도 별 매출',
                            textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                          ),
                          tooltipBehavior: tooltipBehavior,
                          palette: <Color>[AppColors.brown],
// Line Chart : Series
                          series: [
                            LineSeries<ChartData, int>(
                              dataSource: chartHandler.chartData,
// Line Chart : X value
                              xValueMapper:
                                  (ChartData date, _) => int.parse(date.date),
                                  
// Line Chart : Y value
                              yValueMapper:
                                  (ChartData totalPrice, _) =>totalPrice.totalPrice,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                              ),
                              width: 3,
                            ),
                          ],
// Line Chart : X Axis
                          primaryXAxis: CategoryAxis(
                            title: AxisTitle(
                              text: chartHandler.chartType.value == 'yearly'
                              ?'기간 (월)'
                              :chartHandler.chartType.value == 'monthly'
                              ?'기간 (일)' 
                              :chartHandler.chartType.value == 'daily'
                              ?'기간 (시)'
                              :'',
                              textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
// Line Chart : Y Axis
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: '매출 (원)',textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                            numberFormat: NumberFormat('#,##0', 'ko_KR'),
                            interval: chartHandler.chartType.value == 'yearly'
                            ? 10000000
                            :chartHandler.chartType.value == 'monthly'
                            ? 1000000
                            :chartHandler.chartType.value == 'daily'
                            ? 100000
                            : 10000000
                          ),
                        ),
                      )
// ------------------ //
// Chart : Line Chart has no Data
                      : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 600,
                        child: Center(
                          child: Text(
                            '해당 기간의 data 가 없습니다. 다른 기간을 선택 해주세요.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      )
// ---------------------------------------------------------------------- //
                      : chartHandler.chartProductData.isNotEmpty  
                      ?SizedBox(
                    width: MediaQuery.of(context).size.width,
                        height: 600,
// ------------------ //
// Chart : Bar Chart (quantity)
                        child: SfCartesianChart(
                          title: ChartTitle(
                            text: chartHandler.chartType.value == 'yearly'
                            ?'연간 제품 별 판매수량'
                            :chartHandler.chartType.value == 'monthly'
                            ?'월간 제품 별 판매수량'
                            :chartHandler.chartType.value == 'daily'
                            ?'일간 제품 별 판매수량'
                            :'연도 별 판매수량',
                            textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                          ),
                          tooltipBehavior: tooltipBehavior,
                          palette: <Color>[AppColors.brown],
// 가로형 수평 그래프로 변환 - 안해도 되는 상황이라 주석처리
                          // isTransposed: true,
                          series: [
                            BarSeries<ChartProductsList, String>(
                              dataSource: chartHandler.chartProductData,
// Bar Chart : X value
                              xValueMapper: (ChartProductsList data, _) => data.productName,
// Bar Chart : Y value
                              yValueMapper: (ChartProductsList data, _) => data.quantity,
                              dataLabelSettings: DataLabelSettings(isVisible: true),
                            )
                          ],
// Bar Chart : X Axis
                          primaryXAxis: CategoryAxis(
                            isInversed: true,
                            title: AxisTitle(
                              text: '제품 명',
                              textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
// Bar Chart : Y Axis
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: '판매수량 (잔)',textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                            numberFormat: NumberFormat('#,##0', 'ko_KR'),
                            interval: chartHandler.chartType.value == 'yearly'
                            ? 1000
                            :chartHandler.chartType.value == 'monthly'
                            ? 100
                            :chartHandler.chartType.value == 'daily'
                            ? 20
                            : 1000
                          ),
                        ),
                  )
// Chart : Bar Chart has no Data
                  : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 600,
                        child: Center(
                          child: Text(
                            ' 다른 기간을 선택 해주세요.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
// ------------------ //
// ------------------ //
// Button : 선택한 유형의 기간 별 기간 선택 버튼
                  chartHandler.chartType.value == 'daily'
                  ?IpodButtonLightBrown(
                    onPressed: () => dispDatePicker(context),
                    text: chartHandler.selectedDateDay.value,
                  )
                  :chartHandler.chartType.value == 'monthly'
                  ?IpodButtonLightBrown(
                    text: chartHandler.selectedDateMonth.value,
                    onPressed: () => _showMonthDialogue(),
                  )
                  :chartHandler.chartType.value == 'yearly'
                  ?IpodButtonLightBrown(
                    text: chartHandler.selectedDateYear.value,
                    onPressed: () => _showYearDialugoe(),
                  )
                  :IpodButtonLightBrown(text: '미정', 
                  onPressed:() {
                    //
                    }, 
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  } // build
// --------------------------------------------------------- //
  //1. 월간 매출 현황을 보는 경우 원하는 월을 선택하기 위해 button list 를 띄워주는 dialogue 함수
  _showMonthDialogue() async {
    Get.defaultDialog(
      backgroundColor: AppColors.brown,
      title: '월 선택',
      titleStyle: TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      content: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(width: 300, height: 200, child: monthButtonList()),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            '취소',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

// --------------------------------------------------------- //
// 1-1. vm 에서 data 를 받아 사용자의 회원가입 날짜의 연도와 월을 기준으로
//      오늘 날짜의 연도와 월 까지의 list data 를 각각 button list 로 return 하는 함수
  Widget monthButtonList() {
    return ListView.builder(
      itemCount: chartHandler.durationList.length,
      itemBuilder: (context, index) {
        final store = chartHandler.durationList[index];
        return ButtonLightBrown(
          text: "${store.storeYear}년 - ${store.storeMonth}월",
          onPressed: () async {
            chartHandler.selectedChartMonthYear.value =
            store.storeYear.toString();
            chartHandler.selectedChartMonth.value = store.storeMonth.toString();
            chartHandler.selectedDateMonth.value = '선택 월 : ${chartHandler.selectedChartMonthYear.value}년 ${chartHandler.selectedChartMonth.value}월';
            await chartHandler.fetchMonthlyChart();
            Get.back();
          },
        );
      },
    );
  }
// ---------------------------------------------------------------------- //
// 2. 일간 매출을 확인하기 위해 원하는 일 을 선택하기 위한 캘린더 함수
  dispDatePicker(BuildContext context) async {
    int firtYear = now.year;
    int lastYear = firtYear + 5;
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(firtYear),
      lastDate: DateTime(lastYear),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: Locale('ko', 'KR'),
    );
    if (selectedDate != null) {
      chartHandler.selectedChartDayYear.value = selectedDate.year.toString();
      chartHandler.selectedChartDayMonth.value = selectedDate.month.toString();
      chartHandler.selectedChartDay.value = selectedDate.day.toString();
      chartHandler.selectedDateDay.value ="선택 일자 : ${chartHandler.selectedChartDayYear.value}-${chartHandler.selectedChartDayMonth.value}-${chartHandler.selectedChartDay.value}";
      chartHandler.fetchdailyChart();
      chartHandler.fetchProductsDailyChart();
    }
  }
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
// 2. 연도 별 총 매출 chart 에 들어갈 year 를 select 하는 button list 를 보여주는 dialogue
  _showYearDialugoe() {
    Get.defaultDialog(
      backgroundColor: AppColors.brown,
      title: '연도 선택 리스트',
      titleStyle: TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      content: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(width: 300, height: 200, child: yearButtonList()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            '취소',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
// ---------------------------------------------------------------------- //
// 2-1. 연도 별 총 매출 chart 에 들어갈 year 를 select 하는 button list
  Widget yearButtonList() {
    return ListView.builder(
      itemCount: chartHandler.durationYearList.length,
      itemBuilder: (context, index) {
        final date = chartHandler.durationYearList[index];
        return ButtonLightBrown(
          text: '$date 년',
          onPressed: () async {
            chartHandler.selectedChartYear.value = date.toString();
            chartHandler.selectedDateYear.value = '선택 연도 : ${chartHandler.selectedChartYear.value}';
            await chartHandler.fetchYearlyChart();
            Get.back();
          },
        );
      },
    );
  }
// ---------------------------------------------------------------------- //
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
// --------------------------------------------------------- //
}// class