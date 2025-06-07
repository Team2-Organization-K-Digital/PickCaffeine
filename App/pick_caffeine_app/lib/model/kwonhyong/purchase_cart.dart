// 장바구니 메뉴드롭다운 페이지
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/kwonhyong/kwonhyoung_controller.dart';

// 장바구니 관련 모델
class CartItem {
  final int menuNum;
  final String menuName;
  final int menuPrice;
  final int selectedQuantity;
  final String selectedOptions;
  final int totalPrice;

  CartItem({
    required this.menuNum,
    required this.menuName,
    required this.menuPrice,
    required this.selectedQuantity,
    required this.selectedOptions,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'menuNum': menuNum,
      'menuName': menuName,
      'menuPrice': menuPrice,
      'selected_quantity': selectedQuantity,
      'selectedOptions': selectedOptions,
      'totalPrice': totalPrice,
    };
  }
}

//---------------------------------------------------------------------------------
// 구매 장바구니 페이지

// 구매 장바구니 페이지
class CustomerPurchasePage extends StatelessWidget {
  final RequestController controller = Get.put(RequestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
        centerTitle: true,
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              // Get.to(() => MenuListScreen());
            },
            icon: Icon(Icons.receipt_long),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메시지 표시 영역
            Obx(() => _buildMessageArea()),

            SizedBox(height: 16),

            // 샘플 메뉴 추가 섹션 (테스트용)
            _buildSampleMenuSection(),

            SizedBox(height: 24),

            // 옵션 선택 섹션
            Text(
              '요청사항 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // 드롭다운
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  key: Key('request_dropdown'),
                  decoration: InputDecoration(
                    labelText: '요청 사항 선택',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  value:
                      controller.requestOptions.contains(
                            controller.tempSelectedRequest.value,
                          )
                          ? controller.tempSelectedRequest.value
                          : null,
                  items:
                      controller.requestOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setTempSelected(value);
                      controller.clearMessages();
                    }
                  },
                ),
              ),
            ),

            // 직접 입력 필드
            Obx(
              () =>
                  controller.isDirectInput
                      ? Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextFormField(
                          key: Key('request_textfield'),
                          onChanged: (value) {
                            controller.setInputText(value);
                            controller.clearMessages();
                          },
                          maxLength: 80,
                          decoration: InputDecoration(
                            labelText: '요청사항을 입력하세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '예: 시럽 적게, 휘핑크림 추가 등',
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
            ),

            // 적용 버튼
            Obx(
              () =>
                  controller.tempSelectedRequest.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            key: Key('submit_request_button'),
                            onPressed: controller.applySelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown[400],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '요청사항 적용하기',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
            ),

            // 적용된 요청사항 표시
            Obx(
              () =>
                  controller.selectedRequest.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            border: Border.all(color: Colors.green[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '적용된 요청사항: ${controller.selectedRequest.value}',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
            ),

            SizedBox(height: 24),

            // 장바구니 아이템 목록
            Text(
              '장바구니 목록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            Obx(() => _buildCartItemsList()),

            SizedBox(height: 24),

            // 총 금액 및 주문 버튼
            Obx(() => _buildOrderSummary()),
          ],
        ),
      ),
    );
  }

  // 메시지 표시 위젯
  Widget _buildMessageArea() {
    if (controller.errorMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          controller.errorMessage.value,
          style: TextStyle(color: Colors.red[800]),
        ),
      );
    } else if (controller.successMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border.all(color: Colors.green[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          controller.successMessage.value,
          style: TextStyle(color: Colors.green[800]),
        ),
      );
    }
    return SizedBox.shrink();
  }

  // 샘플 메뉴 추가 섹션 (테스트용)
  Widget _buildSampleMenuSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '메뉴 추가 (테스트용)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      () => controller.addToCart(
                        menuNum: 1,
                        menuName: '아메리카노',
                        menuPrice: 4500,
                        quantity: 1,
                      ),
                  child: Text('아메리카노 추가'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      () => controller.addToCart(
                        menuNum: 2,
                        menuName: '카페라떼',
                        menuPrice: 5500,
                        quantity: 1,
                      ),
                  child: Text('카페라떼 추가'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 장바구니 아이템 목록 위젯
  Widget _buildCartItemsList() {
    if (controller.cartItems.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '장바구니가 비어있습니다.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children:
          controller.cartItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.menuName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '단가: ${item.menuPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}원',
                        ),
                        Text('수량: ${item.selectedQuantity}개'),
                        Text('요청사항: ${item.selectedOptions}'),
                        Text(
                          '소계: ${item.totalPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}원',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.removeFromCart(index),
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // 주문 요약 및 버튼 위젯
  Widget _buildOrderSummary() {
    if (controller.cartItems.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        border: Border.all(color: Colors.brown[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 금액:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${controller.totalAmount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}원',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value
                      ? null
                      : controller.saveOrderToDatabase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  controller.isLoading.value
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('주문 처리 중...'),
                        ],
                      )
                      : Text('주문하기', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
