import 'package:get/get.dart';
import '../../../data/models/payment_history_model.dart';
import '../../../data/services/data_service.dart';

class PaymentHistoryController extends GetxController {
  final DataService _dataService = DataService();

  final payments = <PaymentHistoryModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentHistory();
  }

  Future<void> loadPaymentHistory() async {
    try {
      isLoading.value = true;
      error.value = '';

      final fetchedPayments = await _dataService.fetchPaymentHistory();
      payments.value = fetchedPayments;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      print('Error loading payment history: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
