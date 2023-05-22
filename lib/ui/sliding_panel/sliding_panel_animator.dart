import 'package:flutter/material.dart';

import 'package:habit_tracker/ui/sliding_panel/sliding_panel.dart';
import '../animations/animation_controller_state.dart';

//This is SlidingPanelAnimator widget that will be only concerned with animation and return a SlidingPanel as a child.
//This widget is used to slide SlidingPanel in and out.To get this working
//We will need to use an AnimationController + AnimatedBuilder + Transform widget
//that we can use to translate each panel according to some animation value.
//We will hook this up to our UI so that we can trigger the animation when we tap
//on the settings gear.

class SlidingPanelAnimator extends StatefulWidget {
  const SlidingPanelAnimator({
    super.key,
    required this.direction,
    required this.child,
  });
  final SlideDirection direction;
  final Widget child;

  @override
  SlidingPanelAnimatorState createState() =>
      // ignore: no_logic_in_create_state
      SlidingPanelAnimatorState(const Duration(milliseconds: 200));
}

class SlidingPanelAnimatorState
    extends AnimationControllerState<SlidingPanelAnimator> {
  SlidingPanelAnimatorState(Duration duration) : super(duration);

  late final _curveAnimation =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOutCubic,
  ));

  void slideIn() {
    animationController.forward();
  }

  void slideOut() {
    animationController.reverse();
  }

  double _getOffsetX(double screenWidth, double animationValue) {
    final startOffset = widget.direction == SlideDirection.rightToLeft
        ? screenWidth - SlidingPanel.leftPanelFixedWidth
        : -SlidingPanel.leftPanelFixedWidth;
    return startOffset * (1.0 - animationValue);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curveAnimation,
      child: SlidingPanel(
        direction: widget.direction,
        child: widget.child,
      ),
      builder: (context, child) {
        final animationValue = _curveAnimation.value;
        //if not on-screen, return empty container
        if (animationValue == 0.0) {
          return Container();
        }
        //else return the SlidingPanel
        final screenWidth = MediaQuery.of(context).size.width;
        final offsetX = _getOffsetX(screenWidth, animationValue);
        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: child,
        );
      },
    );
  }
}
