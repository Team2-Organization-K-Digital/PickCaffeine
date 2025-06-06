// 은준님 필요한 메뉴 슬라이더블 기능 관련 코드
import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/kwonhyong/kwonhyoung_controller.dart';

// 메뉴 모델
class MenuItem {
  final int menuNum;
  final int categoryNum;
  final String menuName;
  final String menuContent;
  final int menuPrice;
  final String menuImage;
  String menuState; // 판매중/품절 상태

  MenuItem({
    required this.menuNum,
    required this.categoryNum,
    required this.menuName,
    required this.menuContent,
    required this.menuPrice,
    required this.menuImage,
    this.menuState = '판매중',
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuNum: json['menu_num'],
      categoryNum: json['category_num'],
      menuName: json['menu_name'],
      menuContent: json['menu_content'],
      menuPrice: json['menu_price'],
      menuImage: json['menu_image'],
      menuState: json['menu_state'] ?? '판매중',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_num': menuNum,
      'category_num': categoryNum,
      'menu_name': menuName,
      'menu_content': menuContent,
      'menu_price': menuPrice,
      'menu_image': menuImage,
      'menu_state': menuState,
    };
  }

  // 편의 메소드
  bool get isAvailable => menuState == '판매중';
}

//--------------------------------------------------------------------------------
// 메뉴 슬라이더블 기능 페이지

// 메뉴 리스트에서 슬라이더블 화면
class MenuListScreen extends StatelessWidget {
  final MenuController controller = Get.put(MenuController());

  MenuListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('커피 메뉴'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.loadMenuItems(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.menuItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.coffee, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('메뉴가 없습니다.', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadMenuItems(),
                  child: Text('다시 로드'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => await controller.loadMenuItems(),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: controller.menuItems.length,
            itemBuilder: (context, index) {
              final item = controller.menuItems[index];
              return;
              // Padding(
              //   padding: EdgeInsets.only(bottom: 8),
              //   child: MenuItemCard(item: item, controller: controller),
              // );
            },
          ),
        );
      }),
    );
  }
}

// 메뉴 아이템 카드
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final MenuController controller;

  const MenuItemCard({Key? key, required this.item, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(item.menuNum),
      endActionPane: ActionPane(
        motion: DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: Text('삭제 확인'),
                      content: Text('정말로 이 메뉴를 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: Text('삭제'),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                controller.deleteMenu(item.menuNum); // 실제 삭제 실행
              }
            },
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '삭제',
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => controller.toggleAvailability(item.menuNum),
            backgroundColor: item.isAvailable ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
            icon: item.isAvailable ? Icons.block : Icons.check_circle,
            label: item.isAvailable ? '품절' : '판매재개',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: item.isAvailable ? Colors.white : Colors.grey[100],
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                // 이미지
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.brown[100],
                  ),
                  child: Icon(
                    Icons.coffee,
                    size: 40,
                    color: item.isAvailable ? Colors.brown[700] : Colors.grey,
                  ),
                ),
                SizedBox(width: 12),
                // 메뉴 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.menuName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    item.isAvailable
                                        ? Colors.black
                                        : Colors.grey,
                                decoration:
                                    item.isAvailable
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          if (!item.isAvailable)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '품절',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        item.menuContent,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              item.isAvailable
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${_formatPrice(item.menuPrice)}원',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              item.isAvailable
                                  ? Colors.brown[700]
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // 화살표 힌트
                Icon(Icons.arrow_back_ios, color: Colors.grey[400], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 가격 포맷팅 함수
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
