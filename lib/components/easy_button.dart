import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';

class CustomEasyButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  const CustomEasyButton(
      {super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return EasyButton(
      type: EasyButtonType.elevated,
      idleStateWidget: Text(
        text,
        style: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      loadingStateWidget: const CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          Color(0xFFFFB703),
        ),
      ),
      useWidthAnimation: true,
      useEqualLoadingStateWidgetDimension: true,
      height: 60.0,
      borderRadius: 10.0,
      elevation: 0.0,
      contentGap: 6.0,
      buttonColor: Colors.white,
      onPressed: onPressed,
    );
  }
}
