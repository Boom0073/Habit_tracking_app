import 'package:flutter/material.dart';

class OpacityAnimatedWideget extends StatelessWidget {
  OpacityAnimatedWideget(
      {super.key, required Animation<double> animation, required this.child})
      : opacityAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
        );
  final Animation<double> opacityAnimation;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacityAnimation,
      child: child,
    );
  }
}


//Avoid using the opacity widget directly when working with animations.The reason
//is that by using this with animations, we are forcing the child widget tree to
//rebuild every frame.So using opacity widget with animations can have a negative 
//impact on performance.So Lets use FadeTransition instead.
//FadeTransition can use it to any kind of explicit animation to fade your widgets
//in and out.