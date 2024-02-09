import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class Pin extends StatefulWidget {
  final void Function(String)? onPinEntered;
  final String? errorText;

  const Pin({super.key, this.onPinEntered, this.errorText});

  @override
  State<Pin> createState() => _PinPageState();
}

class _PinPageState extends State<Pin> {
  String enteredPin = '';

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.white,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 6,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10.0),
      ),
      errorText: widget.errorText,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: (pin) {
        setState(() {
          enteredPin = pin;
        });
        if (widget.onPinEntered != null) {
          widget.onPinEntered!(enteredPin);
        }
      },
    );
  }
}
