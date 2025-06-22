import 'package:flutter_riverpod/flutter_riverpod.dart';

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<Map<String, dynamic>>>((ref) {
  return OrdersNotifier();
});

class OrdersNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  OrdersNotifier() : super([]);

  void addOrder(Map<String, dynamic> order) {
    state = [...state, order];
  }

  void updateOrderStatus(String orderId, String status) {
    state = [
      for (final order in state)
        if (order['id'] == orderId)
          {...order, 'status': status}
        else
          order,
    ];
  }
} 