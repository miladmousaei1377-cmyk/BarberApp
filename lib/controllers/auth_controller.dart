import 'package:get/get.dart';
import '../core/storage/storage_service.dart';
import '../data/mock/mock_data.dart';
import '../data/models/user_model.dart';

enum StylistLoginResult { success, pending, failed }

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final isLoading = false.obs;
  final errorMsg = ''.obs;

  Future<bool> loginCustomer({required String email, required String password}) async {
    isLoading.value = true;
    errorMsg.value = '';
    await Future.delayed(const Duration(milliseconds: 700));

    final matches = MockData.users.where(
      (u) => u.email?.toLowerCase() == email.trim().toLowerCase() && u.role == UserRole.customer,
    ).toList();

    if (matches.isEmpty || matches.first.password != password) {
      isLoading.value = false;
      errorMsg.value = 'ایمیل یا رمز عبور اشتباه است';
      return false;
    }

    final user = matches.first;
    await StorageService.saveToken('tok_${user.id}');
    await StorageService.saveUser(user);
    isLoading.value = false;
    return true;
  }

  Future<bool> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMsg.value = '';
    await Future.delayed(const Duration(milliseconds: 700));

    if (MockData.users.any((u) => u.email?.toLowerCase() == email.trim().toLowerCase())) {
      isLoading.value = false;
      errorMsg.value = 'این ایمیل قبلاً ثبت شده است';
      return false;
    }

    final user = UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      fullName: name.trim(),
      phone: phone.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );
    MockData.users.add(user);
    await StorageService.saveToken('tok_${user.id}');
    await StorageService.saveUser(user);
    isLoading.value = false;
    return true;
  }

  Future<StylistLoginResult> loginStylist({required String email, required String password}) async {
    isLoading.value = true;
    errorMsg.value = '';
    await Future.delayed(const Duration(milliseconds: 700));

    final matches = MockData.users.where(
      (u) => u.email?.toLowerCase() == email.trim().toLowerCase() && u.role == UserRole.barber,
    ).toList();

    if (matches.isEmpty || matches.first.password != password) {
      isLoading.value = false;
      errorMsg.value = 'ایمیل یا رمز عبور اشتباه است';
      return StylistLoginResult.failed;
    }

    final user = matches.first;
    await StorageService.saveToken('tok_${user.id}');
    await StorageService.saveUser(user);
    isLoading.value = false;

    return user.stylistStatus == 'pending' ? StylistLoginResult.pending : StylistLoginResult.success;
  }

  Future<bool> registerStylist({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String guildCode,
    required String salonName,
    required String salonAddress,
  }) async {
    isLoading.value = true;
    errorMsg.value = '';
    await Future.delayed(const Duration(milliseconds: 900));

    if (MockData.users.any((u) => u.email?.toLowerCase() == email.trim().toLowerCase())) {
      isLoading.value = false;
      errorMsg.value = 'این ایمیل قبلاً ثبت شده است';
      return false;
    }

    final user = UserModel(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      fullName: name.trim(),
      phone: phone.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      role: UserRole.barber,
      stylistStatus: 'pending',
      createdAt: DateTime.now(),
    );
    MockData.users.add(user);
    await StorageService.saveToken('tok_${user.id}');
    await StorageService.saveUser(user);
    isLoading.value = false;
    return true;
  }

  void clearError() => errorMsg.value = '';
}
