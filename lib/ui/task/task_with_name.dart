import 'package:flutter/material.dart';

import 'package:habit_tracker/models/hive_task.dart';
import './animated_task.dart';
import '../../constants/text_styles.dart';
import '../theming/app_theme.dart';
import '../common_widgets/edit_task_button.dart';

class TaskWithName extends StatelessWidget {
  const TaskWithName({
    Key? key,
    required this.task,
    this.completed = false,
    this.isEditing = false,
    this.hasCompletedState = true,
    this.onCompleted,
    this.editTaskButtonBuilder,
  }) : super(key: key);
  final Task task;
  final bool completed;
  final bool isEditing;
  final bool hasCompletedState;
  final ValueChanged<bool>? onCompleted;
  final WidgetBuilder?
      editTaskButtonBuilder; //We use this property to show edit task button
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Stack(
            children: [
              AnimatedTask(
                iconName: task.iconName,
                completed: completed,
                isEditing: isEditing,
                hasCompletedState: hasCompletedState,
                onCompleted: onCompleted,
              ),
              if (editTaskButtonBuilder != null)
                Positioned.fill(
                    child: FractionallySizedBox(
                  widthFactor: EditTaskButton.scaleFactor,
                  heightFactor: EditTaskButton.scaleFactor,
                  alignment: Alignment.bottomRight,
                  child: editTaskButtonBuilder!(context),
                ))
            ],
          ),
        ),
        const SizedBox(
          height: 8.0,
        ),
        Text(
          task.name.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyles.taskName.copyWith(
            color: AppTheme.of(context).accent,
          ),
          //Using this copyWith() method is a very common pattern that is used in Flutter
          //when we want to take an object and return a copy of it by changing some specific properties.
        )
      ],
    );
  }
}

//We have created separate widget classes for different concerns.
//for example, the TaskWithName widget is only responsible for
//arranging widgets(AnimatedTask, SizedBox, Text()) inside column.
//And AnimatedTask widget contains all the interesting animation code
//that we need to enable the interaction.
//And the TaskCompletionRing hold all the custom painting codes.
//This is always a good idea to create composable widgets that each one
//do one specific thing.So that they are easier to use and reason about.