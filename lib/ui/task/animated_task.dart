import 'package:flutter/material.dart';

import './task_completion_ring.dart';
import '../common_widgets/centered_svg_icon.dart';
import '../theming/app_theme.dart';
import '../../constants/app_assets.dart';

//This class will contain all the animation logic that we will use to rebuild
//this widget when the progress value changes.

class AnimatedTask extends StatefulWidget {
  const AnimatedTask({
    Key? key,
    required this.iconName,
    required this.completed,
    this.isEditing = false,
    this.hasCompletedState = true,
    this.onCompleted,
  }) : super(key: key);
  final String iconName;
  final bool isEditing;
  final bool hasCompletedState;
  final bool
      completed; //This widget will now get the task completion state from the outside
  final ValueChanged<bool>?
      onCompleted; //it will use this callback to inform the parent widget when the completion state change.
  @override
  State<AnimatedTask> createState() => _AnimatedTaskState();
}

class _AnimatedTaskState extends State<AnimatedTask>
    with SingleTickerProviderStateMixin {
  //By default, AnimationController produces values that range from 0 to 1 over a given duration.
  //The animation controller generates a new value whenever the device running your app is ready to display a new frame (typically, this rate is around 60 values per second).
  late final AnimationController _animationController;
  late final Animation<double> _curveAnimation;
  bool _showCheckIcon = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, //this represents the current instance of _AnimatedTaskState
      duration: const Duration(
          milliseconds:
              750), // This is the time that it takes for the animation to complete.
    );
    _animationController.addStatusListener(_checkStatusUpdates);
    _curveAnimation =
        _animationController.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.removeStatusListener(_checkStatusUpdates);
    _animationController.dispose();
  }

  //Every time the animation status changes, then this method will be called.
  void _checkStatusUpdates(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted?.call(true);
      if (widget.hasCompletedState) {
        if (mounted) {
          setState(() => _showCheckIcon = true);
        }
        Future.delayed(const Duration(seconds: 1), () {
          //if(mounted) just make the safer code.
          if (mounted) {
            setState(() {
              _showCheckIcon = false;
            });
          }
        });
      } else {
        _animationController.value = 0.0;
      }
    }
  }
  //^ We should onal call setState() if the widget is currently mounted.
  //Whatever reason our AnimatedTask widget is removed from the widget tree before
  //the future has completed then calling  setState() will be invalid and will generate
  //an error.Don't call setState() in the Future callback if the widget was removed from
  //the widget tree.

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEditing &&
        !widget.completed &&
        _animationController.status != AnimationStatus.completed) {
      _animationController.forward();
    } else if (!widget.isEditing && !_showCheckIcon) {
      widget.onCompleted?.call(false);
      _animationController.value = 0.0;
    }
  }

  void _handleTabCancel() {
    if (!widget.isEditing &&
        _animationController.status != AnimationStatus.completed) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    //The AnimatedBuilder is rebuild every time value assign in animation property
    //changed

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: (_) => _handleTabCancel(),
      onTapCancel: _handleTabCancel,
      child: AnimatedBuilder(
          animation: _curveAnimation,
          builder: ((context, child) {
            final themeData = AppTheme.of(context);
            final progress = widget.completed ? 1.0 : _curveAnimation.value;
            final hasCompleted = progress == 1.0;
            final iconColor =
                hasCompleted ? themeData.accentNegative : themeData.taskIcon;
            return Stack(
              children: [
                TaskCompletionRing(progress: progress),
                Positioned.fill(
                  child: CenteredSvgIcon(
                    iconName: hasCompleted && _showCheckIcon
                        ? AppAssets.check
                        : widget.iconName,
                    color: iconColor,
                  ),
                )
              ],
            );
          })),
    );
  }
}

//Minimum boilerplate code that you will need when you want to create
//an AnimationController.
//So when you need an AnimationController. You need to perform these 5 steps.
//1.First of all, you need to create a StatefulWidget.
//2.Then you need to add a SingleTickerProviderStateMixin as a mixin to the state class.
//3.Then you need to create a late final AnimationController
//4.Initialize AnimationController inside initState().
//5.Finally, you need to dispose it in the dispose method. 

//We can only see this animation when we hot-restart but not when we hot-reload
//because what start this animation is _animationController.forward() and this
//happen inside the initState method which is only called once when the widget is mounted
//and initState is not called again when we hot-reload