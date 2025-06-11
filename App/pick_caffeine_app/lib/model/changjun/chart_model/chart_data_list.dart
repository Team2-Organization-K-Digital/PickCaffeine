/* 
  1. purchase_list table 의 purchase_date 를 subString 하여 year, month, day 를 나누고
  2. purchase_list 의 forign key 인 selected_num 를 통해 
  selected_menu table 의 forign key 인 menu_num 을 찾아 menu table 에서 menu_name 을 찾는다.
  3. 위와 같은 방법으로 selected_menu table 의 total_price 를 찾아 purchase_list table 의 purchase_quantity 를 곱한 값이
  아래 모델의 totalPrice 가 된다.

  이러한 모델을 통해 화면에서 chart 를 띄우는 경우 :
  일 별 매출 - year 가 지금 년도인 data, month 가 지금 월 인 day 에 해당하는 data 를 추출하여 해당 월 전체의 일 별 매출을 보여준다.
  월 별 매출 - year 가 지금 년도인 month에 해당하는 data 를 추출하여 해당 년도의 월 별 매출을 보여준다.
  년도 별 매출 - 오늘 날짜의 연도가 처음 x축 으로 들어가 년도 별 매출을 보여주며 이전/이후 2년 간의 data 를 chart 로 보여준다.

  해당 가게의 제품 별 매출 (일 별) - 위 일 별 매출을 추출하는 과정에서 menu_num 이 같은 data 를 추출하며
  사용자의 선택에 따라 최대 3개 의 제품을 선택하여 볼 수 있다.
  
*/

class ChartData {
  final String date;
  final int totalPrice;

  ChartData(
    {
      required this.date,
      required this.totalPrice
    }
  );
// ----------------------------------------------------------- //
  @override
  String toString() {
    return 'ChartData(date: $date, totalPrice: $totalPrice)';
  }
}