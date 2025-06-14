// 관리자 통계 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Statistics Page
  - Description   : 관리자가 로그인 이후 전체 매장의 매출과 거래량을 chart 로 기간 별 확인 할 수 있고
  -                 회원들의 가입 수를 기간 별로 chart 로 확인 할 수 있는 페이지
  - Author        : Lee ChangJun
  - Created Date  : 2025.06.13
  - Last Modified : 2025.06.13
  - package       : GetX, Syncfusion

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  : 전반적인 화면 디자인 및 chart 구현 back_end 와 연결 및 vm 과 연결
// ----------------------------------------------------------------- //
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/changjun/chart_model/admin_total_price.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/widget_class/utility/Ipod_button_brown.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';
import 'package:pick_caffeine_app/widget_class/utility/ipod_button_light_brown.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ----------------------------------------------------------------- //
class AdminStatistics extends StatelessWidget {
  AdminStatistics({super.key});
  final chartHandler = Get.find<JunTemp>();
  final tooltipBehavior = TooltipBehavior(enable: true);
// ----------------------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
// ----------------------------------------------------------------- //
chartHandler.fetchAdminDurationList();
chartHandler.fetchAdminDurationYearList();
// ----------------------------------------------------------------- //
    return Obx(
      () =>  Scaffold(
        backgroundColor: AppColors.lightpick,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
// ----------------- //
                Divider(height: 30,thickness: 3,color: Colors.black,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
// Button : 연도 별 매출
                    IpodButtonBrown(
                      text: '전체 기간',
                      onPressed: () {
                        chartHandler.adminChartType.value = 'all';
                        chartHandler.fetchAdminTotalPrice();
                      },
                    ),
// Button : 연간 매출
                    SizedBox(width: 20),
                    IpodButtonBrown(
                      text: '연간 차트',
                      onPressed: () {
                        chartHandler.adminChartType.value = 'yearly';
                        chartHandler.fetchAdminYearTotalPrice();
                      } 
                    ),
// Button : 월간 매출
                    SizedBox(width: 20),
                    IpodButtonBrown(
                      text: '월간 차트',
                      onPressed: () {
                        chartHandler.adminChartType.value = 'monthly';
                        chartHandler.fetchAdminMonthlyTotalPrice();
                      }
                    ),
// Button : 일간 매출
                    SizedBox(width: 20),
                    IpodButtonBrown(
                      text: '일간 차트',
                      onPressed: () {
                        chartHandler.adminChartType.value = 'daily';
                        chartHandler.fetchAdminDayilyTotalPrice();
                      } 
                    ),
                  ],
                ),
                Divider(height: 30,thickness: 3,color: Colors.black,),
// ---------------------------------------------------------------------- //
// Button : Chart Type Change (Line Chart :duration / Bar Chart : products)
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IpodButtonLightBrown(text: '매출액', onPressed: () {
                        chartHandler.adminTypeOfChart.value = 'duration';
                      },),
                      // SizedBox(width: 10,),
                      // IpodButtonLightBrown(text: '제품 별 매출', onPressed: () {
                      //   chartHandler.typeOfChart.value = 'products';
                      // },),
                      SizedBox(width: 30,),
                      IpodButtonLightBrown(text: '거래량', onPressed: () {
                        chartHandler.adminTypeOfChart.value = 'quantity';
                      },),
                    ],
                  ),
                Divider(height: 30,thickness: 3,),
// ---------------------------------------------------------------------- //
// ----------------- Price Chart -------------------- //
                chartHandler.adminTypeOfChart.value == 'duration'
                ?chartHandler.adminTotalChartList.isNotEmpty
                ?SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 600,
                  child: SfCartesianChart(
// Price Chart : Title
                    title: ChartTitle(
                      text: chartHandler.adminChartType.value == 'yearly'
                      ?'연간 총 매출'
                      :chartHandler.adminChartType.value == 'monthly'
                      ?'월간 총 매출'
                      :chartHandler.adminChartType.value == 'daily'
                      ?'일간 총 매출'
                      :'전체기간 총 매출',
                      textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                    ),
                    tooltipBehavior: tooltipBehavior,
                    palette: <Color>[AppColors.brown],
// Price Chart : Series
                    series: [
                      ColumnSeries<AdminTotalPrice, String>(
                        dataSource: chartHandler.adminTotalChartList,
// Price Chart : X value
                        xValueMapper:
                            (AdminTotalPrice date, _) => date.date,
// Price Chart : Y value
                        yValueMapper:
                            (AdminTotalPrice totalPrice, _) =>totalPrice.total,
                            width: chartHandler.adminChartType.value == 'all'
                            ? 0.3
                            :0.2,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          )
                        ),
                      ),
                    ],
// Price Chart : X Axis
                    primaryXAxis: CategoryAxis(
                      axisLine: AxisLine(
                        width: 4,
                        color: AppColors.black
                      ),
                      title: AxisTitle(
                        text: chartHandler.adminChartType.value == 'yearly'
                        ?'기간 (월)'
                        :chartHandler.adminChartType.value == 'monthly'
                        ?'기간 (일)' 
                        :chartHandler.adminChartType.value == 'daily'
                        ?'기간 (시)'
                        :'기간 (전체)',
                        textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25),
                      ),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                    ),
// Price Chart : Y Axis
                    primaryYAxis: NumericAxis(
                      axisLine: AxisLine(
                        width: 4,
                        color: AppColors.black
                      ),
                      title: AxisTitle(text: '매출 (원)',textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                      ),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                      numberFormat: NumberFormat('#,##0', 'ko_KR'),
                      interval: chartHandler.chartType.value == 'yearly'
                      ? 100000000
                      :chartHandler.chartType.value == 'monthly'
                      ? 10000000
                      :chartHandler.chartType.value == 'daily'
                      ? 1000000
                      : 100000000
                    ),
                  ),
                )
// ------------------ //
// Price Chart : list is empty
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
// ----------------- Quantity Chart -------------------- //
                : chartHandler.adminTypeOfChart.value == 'quantity'
                ? chartHandler.adminTotalChartList.isNotEmpty
                ?SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 600,
                  child: SfCartesianChart(
// Quantity Chart : Title
                    title: ChartTitle(
                      text: chartHandler.adminChartType.value == 'yearly'
                      ?'연간 총 거래량'
                      :chartHandler.adminChartType.value == 'monthly'
                      ?'월간 총 거래량'
                      :chartHandler.adminChartType.value == 'daily'
                      ?'일간 총 거래량'
                      :'전체기간 총 거래량',
                      textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                    ),
                    tooltipBehavior: tooltipBehavior,
                    palette: <Color>[AppColors.brown],
// Quantity Chart : Series
                    series: [
                      ColumnSeries<AdminTotalPrice, String>(
                        dataSource: chartHandler.adminTotalChartList,
// Quantity Chart : X value
                        xValueMapper:
                            (AdminTotalPrice date, _) => date.date,
// Quantity Chart : Y value
                        yValueMapper:
                            (AdminTotalPrice totalPrice, _) =>totalPrice.quantity,
                            width: chartHandler.adminChartType.value == 'all'
                            ? 0.3
                            : 0.1,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                        ),
                      ),
                    ],
// Quantity Chart : X Axis
                    primaryXAxis: CategoryAxis(
                      axisLine: AxisLine(
                        width: 4,
                        color: AppColors.black
                      ),
                      title: AxisTitle(
                        text: chartHandler.adminChartType.value == 'yearly'
                        ?'기간 (월)'
                        :chartHandler.adminChartType.value == 'monthly'
                        ?'기간 (일)' 
                        :chartHandler.adminChartType.value == 'daily'
                        ?'기간 (시)'
                        :'기간 (전체)',
                        textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25),
                      ),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                    ),
// Quantity Chart : Y Axis
                    primaryYAxis: NumericAxis(
                      axisLine: AxisLine(
                        width: 4,
                        color: AppColors.black
                      ),
                      title: AxisTitle(text: '거래량 (회)',textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 25)
                      ),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                      numberFormat: NumberFormat('#,##0', 'ko_KR'),
                      interval: chartHandler.adminChartType.value == 'yearly'
                      ? 10000
                      :chartHandler.adminChartType.value == 'monthly'
                      ? 1000
                      :chartHandler.adminChartType.value == 'daily'
                      ? 100
                      : 100000
                    ),
                  ),
                ) 
// ------------------ //
// Quantity Chart : list is empty
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
// ------------------------------------------------- //
                : Center(child: Text('유저 차트 부분'),),
                Divider(height: 30,thickness: 3,),
// ---------- //
// Button : 선택한 유형의 기간 별 기간 선택 버튼
                  chartHandler.adminChartType.value == 'daily'
                  ?IpodButtonBrown(
                    onPressed: () => dispDatePicker(context),
                    text: chartHandler.adminSelectedDateDay.value,
                  )
                  :chartHandler.adminChartType.value == 'monthly'
                  ?IpodButtonBrown(
                    text: chartHandler.adminSelectedDateMonth.value,
                    onPressed: () => _showMonthDialogue(),
                  )
                  :chartHandler.adminChartType.value == 'yearly'
                  ?IpodButtonBrown(
                    text: chartHandler.adminSelectedDateYear.value,
                    onPressed: () => _showYearDialugoe(),
                  )
                  :Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IpodButtonBrown(text: '전체', 
                      onPressed:() {
                        chartHandler.fetchAdminTotalPrice();
                        }, 
                      ),
                      IpodButtonBrown(text: '연도 별', 
                      onPressed: () {
                        chartHandler.fetchAdminYearlyTotalPrice();
                      },
                      ),
                    ],
                  )
                  

              ],
            ),
          ),
        )
      )
    );
  }// build
// ---------------------------------------------------------------------- //
// 1. 원하는 일 을 선택하기 위한 캘린더 함수
  dispDatePicker(BuildContext context) async {
    int firtYear = DateTime.now().year;
    int lastYear = firtYear + 5;
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(firtYear),
      lastDate: DateTime(lastYear),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: Locale('ko', 'KR'),
    );
    if (selectedDate != null) {
      chartHandler.adminSelectedChartDayYear.value = selectedDate.year.toString();
      chartHandler.adminSelectedChartDayMonth.value = selectedDate.month.toString();
      chartHandler.adminSelectedChartDay.value = selectedDate.day.toString();
      chartHandler.adminSelectedDateDay.value ="선택 일자 : ${chartHandler.adminSelectedChartDayYear.value}-${chartHandler.adminSelectedChartDayMonth.value}-${chartHandler.adminSelectedChartDay.value}";
      chartHandler.fetchAdminDayilyTotalPrice();
    }
  }
// -------------------------------------------------------------- //
// ---------------------------------------------------------------------- //
// 2. 연도 별 chart 에 들어갈 year 를 select 하는 button list 를 보여주는 dialogue
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
      itemCount: chartHandler.adminDurationYearList.length,
      itemBuilder: (context, index) {
        final date = chartHandler.adminDurationYearList[index];
        return ButtonLightBrown(
          text: '$date 년',
          onPressed: () async {
            chartHandler.adminSelectedChartYear.value = date.toString();
            chartHandler.adminSelectedDateYear.value = '선택 연도 : ${chartHandler.adminSelectedChartYear.value}';
            await chartHandler.fetchAdminYearTotalPrice();
            Get.back();
          },
        );
      },
    );
  }
// ---------------------------------------------------------------------- //
  //1. 월간 차트를 보는 경우 원하는 월을 선택하기 위해 button list 를 띄워주는 dialogue 함수
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
// 1-1. 2024년 1월을 기준으로 오늘 날짜의 연도와 월 까지의 list data 를 각각 button list 로 return 하는 함수
  Widget monthButtonList() {
    return ListView.builder(
      itemCount: chartHandler.adminDurationList.length,
      itemBuilder: (context, index) {
        final store = chartHandler.adminDurationList[index];
        return ButtonLightBrown(
          text: "${store.storeYear}년 - ${store.storeMonth}월",
          onPressed: () async {
            chartHandler.adminSelectedChartMonthYear.value = store.storeYear.toString();
            chartHandler.adminSelectedChartMonth.value = store.storeMonth.toString();
            chartHandler.adminSelectedDateMonth.value = '선택 월 : ${chartHandler.adminSelectedChartMonthYear.value}년 ${chartHandler.adminSelectedChartMonth.value}월';
            await chartHandler.fetchAdminMonthlyTotalPrice();
            Get.back();
          },
        );
      },
    );
  }
// ---------------------------------------------------------------------- //
}// class