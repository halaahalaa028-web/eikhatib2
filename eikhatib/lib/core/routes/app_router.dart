// ignore_for_file: unused_import

import 'package:eikhatib/features/orders/views/order_tracking_screen.dart';
import 'package:eikhatib/features/orders/views/orders_screen.dart';
import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';
import '../../features/notifications/views/notifications_screen.dart';
import '../../features/notifications/views/notification_details_screen.dart';
import '../../features/notifications/data/models/notification_model.dart';
import '../../features/home/views/loyalty_points_screen.dart';
import '../../features/home/views/coupons_screen.dart';
import 'routes.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/new_password_screen.dart';
import '../../features/product_details/views/product_details_screen.dart';
import '../../features/categories/views/category_products_screen.dart';
import '../../features/categories/views/all_categories_screen.dart';
import '../../features/categories/views/categories_view.dart';
import '../../features/home/views/offers_screen.dart';
import '../../features/search/views/search_view.dart';
import '../../features/cart/views/cart_screen.dart';
import '../../features/cart/views/add_address_screen.dart';
import '../../features/profile/views/profile_screen.dart';
import '../../features/profile/views/security_settings_screen.dart';
import '../../features/profile/views/change_password_screen.dart';
import '../../features/profile/views/edit_profile_screen.dart';
import '../../features/profile/views/addresses_screen.dart';
import '../../features/profile/views/help_center_screen.dart';
import '../../features/profile/views/terms_privacy_screen.dart';
import '../../features/orders/views/driver_home_screen.dart';
import '../../features/auth/driver_docs_upload_screen.dart';
import '../../features/auth/views/waiting_approval_screen.dart';
import '../../features/auth/reset_status_screen.dart';
import '../../features/orders/views/admin_simulation_screen.dart';

/// Application Router
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  static final ValueNotifier<String?> currentRouteName = ValueNotifier<String?>(
    Routes.splash,
  );

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _buildRoute(const SplashScreen(), settings);
      case Routes.onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case Routes.home:
        return _buildRoute(const HomeScreen(), settings);
      case Routes.login:
        return _buildRoute(const LoginScreen(), settings);
      case Routes.register:
        return _buildRoute(const SignupScreen(), settings);
      case Routes.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case Routes.otp:
        return _buildRoute(const OtpScreen(), settings);
      case Routes.newPassword:
        return _buildRoute(const NewPasswordScreen(), settings);
      case Routes.categories:
        return _buildRoute(const CategoriesView(), settings);
      case Routes.offers:
        return _buildRoute(const OffersScreen(), settings);
      case Routes.productDetails:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _buildRoute(
          ProductDetailsScreen(productArguments: args),
          settings,
        );
      case Routes.categoryProducts:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _buildRoute(CategoryProductsScreen(arguments: args), settings);
      case Routes.allCategories:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _buildRoute(
          AllCategoriesScreen(parentCategory: args['parentCategory']),
          settings,
        );
      case Routes.notifications:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationsScreen(),
        );
      case Routes.loyaltyPoints:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoyaltyPointsScreen(),
        );
      case Routes.coupons:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CouponsScreen(),
        );
      case Routes.notificationDetails:
        final notification = settings.arguments as NotificationModel;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NotificationDetailsScreen(notification: notification),
        );
      case Routes.search:
        return _buildRoute(const SearchView(), settings);
      case Routes.cart:
        return _buildRoute(const CartScreen(), settings);
      case Routes.addAddress:
        return _buildRoute(const AddAddressScreen(), settings);
      case Routes.orders:
        return _buildRoute(const OrdersScreen(), settings);
      case Routes.driverHome:
        return _buildRoute(const DriverHomeScreen(), settings);
      case Routes.driverDocs:
        return _buildRoute(const DriverDocsUploadScreen(), settings);
      case Routes.waitingApproval:
        return _buildRoute(const WaitingApprovalScreen(), settings);
      case Routes.resetStatus:
        return _buildRoute(const ResetStatusScreen(), settings);
      case Routes.adminSimulation:
        return _buildRoute(const AdminSimulationScreen(), settings);
      case Routes.orderTracking:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _buildRoute(OrderTrackingScreen(arguments: args), settings);
      case Routes.profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      case Routes.securitySettings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SecuritySettingsScreen(),
        );
      case Routes.changePassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChangePasswordScreen(),
        );
      case Routes.editProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EditProfileScreen(),
        );
      case Routes.addresses:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddressesScreen(),
        );
      case Routes.helpCenter:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HelpCenterScreen(),
        );
      case Routes.termsAndPrivacy:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TermsAndPrivacyScreen(),
        );
      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static void updateCurrentRoute(String? routeName) {
    currentRouteName.value = routeName;
  }

  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static void navigateAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    navigatorKey.currentState?.pop();
  }
}

class AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppRouter.updateCurrentRoute(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppRouter.updateCurrentRoute(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppRouter.updateCurrentRoute(newRoute?.settings.name);
  }
}
