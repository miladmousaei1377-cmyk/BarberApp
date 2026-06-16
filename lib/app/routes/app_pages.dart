import 'package:get/get.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/phone_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/profile_setup_screen.dart';
import '../../presentation/screens/auth/role_selection_screen.dart';
import '../../presentation/screens/auth/customer_login_screen.dart';
import '../../presentation/screens/auth/customer_register_screen.dart';
import '../../presentation/screens/auth/stylist_login_screen.dart';
import '../../presentation/screens/auth/stylist_register_screen.dart';
import '../../presentation/screens/auth/phone_otp_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/pending_approval_screen.dart';
import '../../presentation/screens/home/main_screen.dart';
import '../../presentation/screens/salon/salon_list_screen.dart';
import '../../presentation/screens/salon/salon_detail_screen.dart';
import '../../presentation/screens/booking/booking_flow_screen.dart';
import '../../presentation/screens/booking/booking_success_screen.dart';
import '../../presentation/screens/appointments/appointments_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/owner/owner_panel_screen.dart';
import '../../presentation/screens/owner/barber_register_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.phone, page: () => const PhoneScreen()),
    GetPage(name: Routes.otp, page: () => const OtpScreen()),
    GetPage(name: Routes.profileSetup, page: () => const ProfileSetupScreen()),
    GetPage(name: Routes.roleSelection, page: () => const RoleSelectionScreen()),
    GetPage(name: Routes.customerLogin, page: () => const CustomerLoginScreen()),
    GetPage(name: Routes.customerRegister, page: () => const CustomerRegisterScreen()),
    GetPage(name: Routes.stylistLogin, page: () => const StylistLoginScreen()),
    GetPage(name: Routes.stylistRegister, page: () => const StylistRegisterScreen()),
    GetPage(name: Routes.phoneOtp, page: () => const PhoneOtpScreen()),
    GetPage(name: Routes.forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: Routes.pendingApproval, page: () => const PendingApprovalScreen()),
    GetPage(name: Routes.main, page: () => const MainScreen()),
    GetPage(name: Routes.salonList, page: () => const SalonListScreen()),
    GetPage(name: Routes.salonDetail, page: () => const SalonDetailScreen()),
    GetPage(name: Routes.bookingFlow, page: () => const BookingFlowScreen()),
    GetPage(name: Routes.bookingSuccess, page: () => const BookingSuccessScreen()),
    GetPage(name: Routes.appointments, page: () => const AppointmentsScreen()),
    GetPage(name: Routes.map, page: () => const MapScreen()),
    GetPage(name: Routes.profile, page: () => const ProfileScreen()),
    GetPage(name: Routes.ownerPanel, page: () => const OwnerPanelScreen()),
    GetPage(name: Routes.barberRegister, page: () => const BarberRegisterScreen()),
  ];
}
