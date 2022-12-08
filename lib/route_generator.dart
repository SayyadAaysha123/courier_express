import 'package:courier_customer_app/src/views/screens/chat.dart';
import 'package:courier_customer_app/src/views/screens/order/recent_orders_screen.dart';
import 'package:flutter/material.dart';

import 'src/models/screen_argument.dart';
import 'src/views/screens/auth/forgot_password_screen.dart';
import 'src/views/screens/order/add_order.dart';
import 'src/views/screens/auth/login_screen.dart';
import 'src/views/screens/order/order.dart';
import 'src/views/screens/auth/sign_up_screen.dart';
import 'src/views/screens/auth/social_login.dart';
import 'src/views/screens/legal_terms.dart';
import 'src/views/screens/profile_screen.dart';
import 'src/views/screens/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    ScreenArgument? argument;
    if (settings.arguments != null) {
      argument = settings.arguments as ScreenArgument;
    }
    switch (settings.name) {
      case '/RecentOrders':
        return MaterialPageRoute(builder: (context) => RecentOrdersScreen());
      case '/Profile':
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case '/Splash':
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case '/Login':
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case '/Signup':
        return MaterialPageRoute(builder: (context) => const SignupScreen());
      case '/SocialLogin':
        return MaterialPageRoute(
          builder: (context) =>
              SocialLogin(argument!.arguments['socialNetwork']),
        );
      case '/Termos':
        return MaterialPageRoute(builder: (context) => LegalTermsWidget());
      case '/NewOrder':
      case '/Home':
        return MaterialPageRoute(builder: (context) => AddOrderScreen());
      case '/Order':
        return MaterialPageRoute(
          builder: (context) =>
              OrderScreen(orderId: argument!.arguments['orderId'] ?? ''),
        );
      case '/Chat':
        return MaterialPageRoute(
          builder: (context) =>
              ChatScreen(argument!.arguments['orderId'] ?? ''),
        );
      case '/ForgotPassword':
        return MaterialPageRoute(
            builder: (context) => const ForgotPasswordScreen());
      default:
        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: SafeArea(child: Text('Route Error'))),
        );
    }
  }
}
