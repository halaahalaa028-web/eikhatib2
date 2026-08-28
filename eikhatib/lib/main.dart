import 'dart:io';
import 'package:easy_localization/easy_localization.dart'
    show BuildContextEasyLocalizationExtension, EasyLocalization;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upgrader/upgrader.dart';

import 'core/routes/app_router.dart';
import 'core/routes/routes.dart';
import 'core/theme/app_theme.dart';

import 'core/localization/localization_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'features/cart/logic/cart_cubit.dart';
import 'features/cart/logic/address_cubit.dart';
import 'features/auth/logic/user_cubit.dart';
import 'features/home/logic/home_cubit.dart';
import 'features/categories/logic/categories_cubit.dart';
import 'features/categories/logic/category_products_cubit.dart';
import 'features/notifications/logic/notifications_cubit.dart';
import 'features/home/logic/loyalty_cubit.dart';
import 'features/home/logic/coupons_cubit.dart';
import 'features/orders/logic/orders_cubit.dart';
import 'features/profile/logic/security_cubit.dart';
import 'core/widgets/app_cart_summary_bar.dart';
import 'features/orders/views/widgets/order_rating_dialog.dart';
import 'features/orders/data/models/order_status.dart';
import 'core/widgets/biometric_gate.dart';
import 'core/widgets/app_update_gate.dart';
import 'core/services/fcm_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await FcmHelper.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: LocalizationManager.supportedLocales,
      path: LocalizationManager.translationsPath,
      fallbackLocale: LocalizationManager.fallbackLocale,
      startLocale: LocalizationManager.fallbackLocale,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => CartCubit()),
          BlocProvider(create: (context) => AddressCubit()),
          BlocProvider(create: (context) => OrdersCubit()),
          BlocProvider(create: (context) => UserCubit()),
          BlocProvider(create: (context) => HomeCubit()..fetchHomeData()),
          BlocProvider(
            create: (context) => CategoriesCubit()..fetchCategories(),
          ),
          BlocProvider(create: (context) => CategoryProductsCubit()),
          BlocProvider(create: (context) => NotificationsCubit()),
          BlocProvider(create: (context) => LoyaltyCubit()),
          BlocProvider(create: (context) => CouponsCubit()),
          BlocProvider(create: (context) => SecurityCubit()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocListener(
          listeners: [
            BlocListener<OrdersCubit, OrdersState>(
              listenWhen: (previous, current) {
                return current.orders.any(
                  (o) =>
                      o.status == OrderStatus.delivered &&
                      !o.hasSeenRatingPrompt,
                );
              },
              listener: (ctx, state) {
                final orderToRate = state.orders.firstWhere(
                  (o) =>
                      o.status == OrderStatus.delivered &&
                      !o.hasSeenRatingPrompt,
                );
                ctx.read<OrdersCubit>().markRatingPromptAsSeen(orderToRate.id);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final navContext = AppRouter.navigatorKey.currentContext;
                  if (navContext != null) {
                    OrderRatingDialog.show(navContext, orderToRate);
                  }
                });
              },
            ),
            BlocListener<UserCubit, UserState>(
              listenWhen: (previous, current) =>
                  previous.user == null && current.user != null,
              listener: (context, state) {
                context.read<CartCubit>().fetchCart();
                context.read<OrdersCubit>().fetchOrders();
                context.read<AddressCubit>().fetchAddresses();
                FcmHelper.init(); // Resync/register token after successful login
              },
            ),
          ],
          child: MaterialApp(
            title: 'ElKhatib',
            navigatorKey: AppRouter.navigatorKey,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final biometricGateWidget = BiometricGate(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Stack(
                    children: [
                      child!,
                      const Positioned(
                        bottom: 90,
                        right: 5,
                        left: 5,
                        child: AppCartSummaryBar(),
                      ),
                    ],
                  ),
                ),
              );

              Widget mainWidget = biometricGateWidget;

              if (Platform.isIOS) {
                mainWidget = UpgradeAlert(
                  upgrader: Upgrader(
                    languageCode: 'ar',
                    messages: UpgraderMessages(code: 'ar'),
                    durationUntilAlertAgain: const Duration(hours: 1),
                  ),
                  showIgnore: false,
                  showLater: false,
                  dialogStyle: UpgradeDialogStyle.cupertino,
                  child: biometricGateWidget,
                );
              }

              if (Platform.isAndroid) {
                return AppUpdateGate(child: mainWidget);
              }

              return mainWidget;
            },
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: Routes.splash,
            onGenerateRoute: AppRouter.generateRoute,
            navigatorObservers: [
              AppRouter.routeObserver,
              AppNavigatorObserver(),
            ],
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          ),
        );
      },
    );
  }
}
