import 'package:flutter/material.dart';

//This widget will take an animation object as an input and call this build
//method every time the animation value changes.

//All of these is scale effect controlled by an explicit animation

//Index property is an input value from our scale calculation

class StaggeredScaleAnimatedWidget extends StatelessWidget {
  StaggeredScaleAnimatedWidget({
    super.key,
    required Animation<double> animation,
    required int index,
    required this.child,
  }) : scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Interval(
              0.1 * index,
              0.5 + 0.1 * index,
              curve: Curves.easeInOutCubic,
            ),
          ),
        );
  final Widget child;
  final Animation<double> scaleAnimation;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      alignment: Alignment.center,
      child: child,
    );
  }
}

//Key to understand how staggered animation work.When we create a CurvedAnimation
//,we always need to pass a parent animation.This time we have passed an Interval object
//to the curve argument, and this allows us to specify the begin and end value as functions of the
//index value.