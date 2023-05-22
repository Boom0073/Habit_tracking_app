import 'dart:math';

import 'package:flutter/material.dart';

import '../theming/app_theme.dart';

class TaskCompletionRing extends StatelessWidget {
  const TaskCompletionRing({Key? key, required this.progress})
      : super(key: key);
  final double progress;
  @override
  Widget build(BuildContext context) {
    final themeData = AppTheme.of(context);
    return AspectRatio(
      aspectRatio:
          1.0, //The result of this will be the height will match the width, which is set to 240 points.
      child: CustomPaint(
        //for painter: We cannot just type CustomPainter() because it is an abstract class.
        //Our job to implement a subclass of CustomPainter() that will contain
        //all drawing logic.
        painter: RingPainter(
          progress: progress,
          taskNotCompletedColor: themeData.taskRing,
          taskCompletedColor: themeData.accent,
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  RingPainter({
    required this.progress,
    required this.taskNotCompletedColor,
    required this.taskCompletedColor,
  });
  final double progress;
  final Color taskNotCompletedColor;
  final Color taskCompletedColor;

  //When we create a CustomPainter, we need to implement two methods called paint and should repaint.
  //We need to implement the paint() method so that we can draw our completion ring.
  //Canvas objects that we can use to draw things, Size object that tells us
  //how big is the drawing area that we have available.
  @override
  void paint(Canvas canvas, Size size) {
    final notCompleted = progress <
        1.0; //This variable will indicate whether the task is completed.
    final strokeWidth = size.width /
        15.0; //The thickness of the circle is relative to the size of our painter. SO that it scales proportionally if we make the widget bigger or smaller.
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        notCompleted ? (size.width - strokeWidth) / 2 : size.width / 2;
    if (notCompleted) {
      final backgroundPaint = Paint()
        ..strokeWidth = strokeWidth
        ..color = taskNotCompletedColor
        ..style = PaintingStyle.stroke
        ..isAntiAlias =
            true; //is used to make our shape look smoother.Whenever we draw shapes that are not horizontal or vertical lines.
      canvas.drawCircle(center, radius, backgroundPaint);
      //The general idea here is that we can use the canvas to draw different shapes,
      //and we can use a paint object to set attributes such as stroke width, color etc.
      //If we want our shapes to resize proportionally to the size of the parent widget.
      //we can make certain properties functions of the size itself like we have done here
      //for the stroke width, center and radius properties.
    }

    final foregroundPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth
      ..color = taskCompletedColor
      ..style = notCompleted ? PaintingStyle.stroke : PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      foregroundPaint,
    );
  }

  //On shouldRepaint() method, by default, when we overwrite this we will get code
  //that throw UnimplementedError().
  //But what we actually want is to return true or false, depending on whether the
  //painter should re-paint when Flutter rebuilds the parent widget.
  //As a rule of thumb, we should return true if something has changed.
  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
  //The covariant keyword lets us replace a method argument type with
  //any of its subclasses. This is not something that would be possible
  //if the type of this argument was CustomPainter() because progress is only
  //defined as a property in the 'RingPainter()' class.
  //So the result of all of this is that our Painter() will only redraw when the
  //progress value changes.This is a performance optimization that will come handy
  //when we implement the animation code.
}
