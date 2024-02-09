import 'package:chatapp/controller/controller.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/pages/chats.dart';
import 'package:chatapp/pages/login.dart';
import 'package:chatapp/pages/start.dart';
import 'package:chatapp/pages/register.dart';
import 'package:chatapp/services/auth/auth_gate.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFFFFB703),
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthService());
  Get.put(ChildController());
  Get.put(ParentController());
  Get.put(EmailController());
  Get.put(PasswordController());
  Get.put(PinController());
  Get.put(RegistrationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(fontFamily: "Poppins"),
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/start', page: () => const StartPage()),
        GetPage(name: '/child', page: () => const ChildsFullnameScreen()),
        GetPage(name: '/parent', page: () => const ParentsFullnameScreen()),
        GetPage(name: '/email', page: () => const EmailScreen()),
        GetPage(name: '/password', page: () => const PasswordScreen()),
        GetPage(name: '/pin', page: () => const PinScreen()),
        GetPage(name: '/repeatPin', page: () => const Register()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/login', page: () => const Login()),
      ],
      home: const AuthGate(),
    );
  }
}
