import 'package:chatapp/components/appbar.dart';
import 'package:chatapp/components/easy_button.dart';
import 'package:chatapp/components/password_field.dart';
import 'package:chatapp/components/pin.dart';
import 'package:chatapp/components/text_field.dart';
import 'package:chatapp/controller/controller.dart';
import 'package:chatapp/services/encryption/encryption_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String errorText = "";
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFB703),
      appBar: const CustomAppBar(
        text: "Register",
        icon: Icons.arrow_back_ios_new,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please repeat the pin:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Pin(
                onPinEntered: (pin) {
                  if (controller.pinController.pinController.text == pin) {
                    controller.pinController.pinController.text = hashData(pin);
                  } else {
                    errorText = "Pin do not match!";
                  }
                },
                errorText: errorText,
              ),
              const Spacer(),
              CustomEasyButton(
                  onPressed: () => controller.register(context),
                  text: "Finish"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildsFullnameScreen extends StatelessWidget {
  const ChildsFullnameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFB703),
      appBar: const CustomAppBar(
        text: "Register",
        icon: Icons.arrow_back_ios_new,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Text(
                  "Please enter the name of your child:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller:
                      controller.childController.childFullnameController,
                  hintText: "Full name",
                  obscureText: false,
                  asset: "assets/name-icon.svg",
                ),
                const Spacer(),
                CustomEasyButton(
                    onPressed: () {
                      Get.toNamed('/parent');
                    },
                    text: "Next"),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParentsFullnameScreen extends StatelessWidget {
  const ParentsFullnameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFB703),
      appBar: const CustomAppBar(
        text: "Register",
        icon: Icons.arrow_back_ios_new,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Text(
                  "Please enter the name of a parent:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller:
                      controller.parentController.parentFullnameController,
                  hintText: "Full name of a parent",
                  obscureText: false,
                  asset: "assets/name-icon.svg",
                ),
                const Spacer(),
                CustomEasyButton(
                    onPressed: () {
                      Get.toNamed('/email');
                    },
                    text: "Next"),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFB703),
      appBar: const CustomAppBar(
        text: "Register",
        icon: Icons.arrow_back_ios_new,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Text(
                  "Please enter the e-mail of a parent:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: controller.emailController.emailController,
                  hintText: "E-Mail of a parent",
                  obscureText: false,
                  asset: "assets/email-icon.svg",
                ),
                const Spacer(),
                CustomEasyButton(
                    onPressed: () {
                      Get.toNamed('/password');
                    },
                    text: "Next"),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  String passwordErrorText = "";

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFB703),
      appBar: const CustomAppBar(
        text: "Register",
        icon: Icons.arrow_back_ios_new,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please enter a password:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              PasswordField(
                controller: controller.passwordController.passwordController,
                hintText: "Password",
                prefixIcon: "assets/password-icon.svg",
                passwordErrorText: passwordErrorText,
                onErrorTextUpdated: (errorText) {
                  setState(() {
                    passwordErrorText = errorText;
                  });
                },
              ),
              const SizedBox(height: 20),
              PasswordField(
                controller: controller
                    .repeatedPasswordController.repeatedPasswordController,
                hintText: "Repeat password",
                prefixIcon: "assets/passwordRepeat-icon.svg",
                passwordErrorText: passwordErrorText,
                onErrorTextUpdated: (errorText) {
                  setState(() {
                    passwordErrorText = errorText;
                  });
                },
              ),
              const SizedBox(height: 25),
              const Spacer(),
              CustomEasyButton(
                  onPressed: () {
                    if (controller.passwordController.passwordController.text !=
                        controller.repeatedPasswordController
                            .repeatedPasswordController.text) {
                      setState(() {
                        passwordErrorText = "Passwords do not match!";
                      });
                    } else if (!controller
                        .passwordController.passwordController.text
                        .contains(RegExp(r'[A-Z]'))) {
                      setState(() {
                        passwordErrorText =
                            "Password must contain at least one capital letter!";
                      });
                    } else if (!controller
                        .passwordController.passwordController.text
                        .contains(RegExp(r'[a-z]'))) {
                      setState(() {
                        passwordErrorText =
                            "Password must contain at least one lower letter!";
                      });
                    } else if (!controller
                        .passwordController.passwordController.text
                        .contains(RegExp(r'[0-9]'))) {
                      setState(() {
                        passwordErrorText =
                            "Password must contain at least one digit!";
                      });
                    } else if (controller
                            .passwordController.passwordController.text.length <
                        8) {
                      setState(() {
                        passwordErrorText =
                            "Password must be at least 8 characters long!";
                      });
                    } else {
                      Get.toNamed('/pin');
                    }
                  },
                  text: "Next"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PinScreen extends StatelessWidget {
  const PinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFB703),
      appBar: const CustomAppBar(
        text: "Register",
        icon: Icons.arrow_back_ios_new,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please enter a pin (only parents):",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Pin(
                onPinEntered: (pin) {
                  controller.pinController.pinController.text = pin;
                },
              ),
              const Spacer(),
              CustomEasyButton(
                  onPressed: () {
                    Get.toNamed('/repeatPin');
                  },
                  text: "Next"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
