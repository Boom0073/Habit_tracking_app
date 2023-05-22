import 'dart:math';

import 'package:flutter/material.dart';

//This widget can flip between the two pages when some button is pressed.
//front and back pages are instances of the TasksGridPage widgets but the data they
//contain is different. So if we want to make this PageFlipBuilderCustom widget reusable
//then the front and back widget should be given as arguments.

class PageFlipBuilderCustom extends StatefulWidget {
  const PageFlipBuilderCustom({
    Key? key,
    required this.frontBuilder,
    required this.backBuilder,
  }) : super(key: key);
  final WidgetBuilder frontBuilder;
  final WidgetBuilder backBuilder;
  @override
  PageFlipBuilderCustomState createState() => PageFlipBuilderCustomState();
}

class PageFlipBuilderCustomState extends State<PageFlipBuilderCustom>
    with SingleTickerProviderStateMixin {
  //Add logic to call frontBuilder() or backBuilder depending on some state.
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  bool _showFrontSide = true;

  @override
  void initState() {
    _controller.addStatusListener(_updateStatus);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_updateStatus);
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    if (_showFrontSide) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      setState(() {
        _showFrontSide = !_showFrontSide;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPageFlipBuilderCustom(
        animation: _controller,
        showFrontSide: _showFrontSide,
        frontBuilder: widget.frontBuilder,
        backBuilder: widget.backBuilder);
  }
}

//The main takeaway for this PageFlipBuilderCustom widget is that this is a good way
//to design a resuable widget API. Because the PageFlipBuilderCustom doesn't need to know
//what its' child widget looks like.
//All it cares about is that it can call frontBuilder() or backBuilder() function
//depending on its state.

//Page flip effect.To get this animation working.We need:
//An AnimationController to control the flip animation.
//Coding to rotate the page with a custom 3D transform based on the animation value.
//We can pass AnimationController value as an input to an AnimatedBuilder.
//- Setup an AnimationController to control the flip transition.
//- Write some custom code using AnimatedBuilder to get the rotation effect that
//we want.

class AnimatedPageFlipBuilderCustom extends AnimatedWidget {
  const AnimatedPageFlipBuilderCustom({
    Key? key,
    required Animation<double> animation,
    required this.showFrontSide,
    required this.frontBuilder,
    required this.backBuilder,
  }) : super(key: key, listenable: animation);
  final bool showFrontSide;
  final WidgetBuilder frontBuilder;
  final WidgetBuilder backBuilder;

  Animation<double> get animationValue => listenable as Animation<double>;
  @override
  Widget build(BuildContext context) {
    //animation values[0, 1] => rotation values[0, pi]
    //show the front side for animation values between 0.0 and 0.5
    //show the back side for animation values between 0.5 and 1.0
    final isAnimationFirstHalf = animationValue.value < 0.5;
    //decide which page we need to show
    final child =
        isAnimationFirstHalf ? frontBuilder(context) : backBuilder(context);
    //map values between [0, 1] to values between [0, pi]
    final rotationValue = animationValue.value * pi;
    final rotationAngle =
        animationValue.value > 0.5 ? pi - rotationValue : rotationValue;
    //tilt value should be 0 at the begining and at the end of the animation
    var tilt = (animationValue.value - 0.5).abs() - 0.5;
    tilt *= isAnimationFirstHalf ? -0.003 : 0.003;
    return Transform(
      transform: Matrix4.rotationY(rotationAngle)..setEntry(3, 0, tilt),
      alignment: Alignment.center,
      child: child,
    );
  }
}
