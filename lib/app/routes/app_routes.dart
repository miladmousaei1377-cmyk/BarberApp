part of 'app_pages.dart';

abstract class Routes {
  static const splash = '/splash';
  static const phone = '/auth/phone';
  static const otp = '/auth/otp';
  static const profileSetup = '/auth/profile-setup';
  static const main = '/main';
  static const salonList = '/salons';
  static const salonDetail = '/salons/detail';
  static const bookingFlow = '/booking/flow';
  static const bookingSuccess = '/booking/success';
  static const appointments = '/appointments';
  static const map = '/map';
  static const profile = '/profile';
  static const ownerPanel = '/owner/panel';
  static const roleSelection = '/auth/role-selection';
  static const barberRegister = '/owner/register';
  static const customerLogin = '/auth/customer-login';
  static const customerRegister = '/auth/customer-register';
  static const stylistLogin = '/auth/stylist-login';
  static const stylistRegister = '/auth/stylist-register';
  static const phoneOtp = '/auth/phone-otp';
  static const forgotPassword = '/auth/forgot-password';
  static const pendingApproval = '/auth/pending-approval';
  static const locationPicker = '/map/location-picker';
}
