import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart'; // <-- Add this
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/main_screen.dart';
import 'routes.dart';
import 'theme.dart';
import '../providers/navigation_provider.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          create: (context) =>
              TransactionProvider(authProvider: context.read<AuthProvider>()),
          update: (context, auth, previous) {
            previous?.authProvider = auth;
            if (previous != null &&
                previous.authProvider?.user?.uid != auth.user?.uid) {
              previous.updateUser(auth.user?.uid);
            }
            return previous ?? TransactionProvider(authProvider: auth);
          },
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'SpendWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          AppRoutes.home: (context) => const MainScreen(),
        },
      ),
    );
  }
}
