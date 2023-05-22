import 'package:flutter/material.dart';
import 'package:habit_tracker/constants/text_styles.dart';
import 'package:habit_tracker/ui/theming/app_theme.dart';

class TextFieldHeader extends StatelessWidget {
  const TextFieldHeader({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        text,
        style: TextStyles.caption.copyWith(
          color: AppTheme.of(context).settingsLabel,
        ),
      ),
    );
  }
}
