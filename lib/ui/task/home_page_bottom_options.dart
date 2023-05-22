import 'package:flutter/material.dart';

import '../theming/app_theme.dart';

class HomePageBottomOptions extends StatelessWidget {
  const HomePageBottomOptions({Key? key, this.onFlip, this.onEnterEditMode})
      : super(key: key);
  final VoidCallback? onEnterEditMode;
  final VoidCallback? onFlip;
  //This widget uses onFlip callback to tell the parent widget when the button is
  //pressed.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onEnterEditMode,
          icon: Icon(
            Icons.settings,
            color: AppTheme.of(context).settingsLabel,
          ),
        ),
        IconButton(
          onPressed: onFlip,
          icon: Icon(
            Icons.flip,
            color: AppTheme.of(context).settingsLabel,
          ),
        ),
        Opacity(
          opacity: 0.0,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        )
      ],
    );
  }
}
