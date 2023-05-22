import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theming/app_theme.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_assets.dart';

class EditTaskButton extends StatelessWidget {
  const EditTaskButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  static const scaleFactor = 0.33;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.black20,
            spreadRadius: 1.5,
            blurRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        //When this button is pressed then VoidCallback is triggered so that the
        //parent widget can do something with it.
        onPressed: onPressed,
        icon: SvgPicture.asset(
          AppAssets.threeDots,
          color: AppTheme.of(context).accentNegative,
          width: 16,
          height: 16,
        ),
      ),
    );
  }
}
