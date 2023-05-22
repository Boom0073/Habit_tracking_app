import 'package:flutter/material.dart';

import './app_theme.dart';

class AppThemeDataTween extends Tween<AppThemeData> {
  AppThemeDataTween({AppThemeData? begin, AppThemeData? end})
      : super(begin: begin, end: end);

  //The main idea is that our Tween subclass needs to know how to interpolate
  //between two values of type AppThemeData (begin and end values).And lerp stands
  //for Linear intERPolation which is a mathematical operation that we can use to
  //get a value between two points.What does it mean to interpolate between values
  //of type AppThemeData? The main idea is that we can interpolate between two objects
  //of type AppThemeData by interpolating between all their individual properties.and
  //because AppThemeData is a type that we have created then it is our job to define
  //its own lerp method if we want to use it with Tweens.
  @override
  AppThemeData lerp(double t) => AppThemeData.lerp(begin!, end!, t);
}

//We create this widget to animate our AppTheme

class AnimatedAppTheme extends ImplicitlyAnimatedWidget {
  const AnimatedAppTheme({
    Key? key,
    required Duration duration,
    required this.data,
    required this.child,
  }) : super(key: key, duration: duration);
  final AppThemeData data;
  //This will rebuild when the theme animation is in progress.
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedAppTheme> createState() =>
      _AnimatedAppThemeState();
}

class _AnimatedAppThemeState extends AnimatedWidgetBaseState<AnimatedAppTheme> {
  AppThemeDataTween? _themeDataTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _themeDataTween = visitor(
      _themeDataTween,
      widget.data,
      (dynamic value) => AppThemeDataTween(begin: value as AppThemeData),
    ) as AppThemeDataTween?;
  }
  //visitor takes 3 positional arguments
  //1. current tween value, 2. target value to animate to, 3. function argumant,
  //used tp return a Tween configuredt with the begin value.

  //The way this code work us that this build method is called every time this
  //animation object changes and what it does is to evaluate the AppThemeData
  //from this _themeDataTween object using the animation as an argument.
  @override
  Widget build(BuildContext context) {
    return AppTheme(
      data: _themeDataTween!.evaluate(animation),
      child: widget.child,
    );
  }
}

//When we use any of the exiting implicitly animated widgets, we need to provide
//a value to animate to such as Offset, Color that our widget should animate to.
//In this case the value to animate is an AppThemeData object..
//In order for our custom implementation to work, we need to have some kind of
//AppThemeDataTween object that Flutter can use to interpolate from the previous
//value to the new value when the theme changes.
//Because AppThemeData is a custom class that we have created, we also have to create
//an AppThemeDataTween class so that we can interpolate between two AppThemeData objects.
