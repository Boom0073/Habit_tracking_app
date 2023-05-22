import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/constants/app_colors.dart';
import 'package:habit_tracker/models/front_or_back_side.dart';

import 'package:habit_tracker/models/hive_task.dart';
import 'package:habit_tracker/ui/add_task/add_task_navigator.dart';
import 'package:habit_tracker/ui/add_task/task_details_page.dart';
import 'package:habit_tracker/ui/animations/opacity_animated_widget.dart';
import 'package:habit_tracker/ui/task/task_with_name_loader.dart';
import 'package:habit_tracker/ui/theming/app_theme.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../common_widgets/edit_task_button.dart';
import '../animations/staggered_scale_animated_widget.dart';
import './add_task_item.dart';

//TasksGrid widget need to take List of tasks  and then show
//them inside the GridView.
class TasksGrid extends StatefulWidget {
  const TasksGrid({
    Key? key,
    required this.tasks,
    this.onAddorEditTask,
  }) : super(key: key);
  final List<Task> tasks;
  final VoidCallback? onAddorEditTask;

  @override
  TasksGridState createState() => TasksGridState();
}

class TasksGridState extends State<TasksGrid> with TickerProviderStateMixin {
  //By declaring the AnimationController explicitly here, we ensure it does not
  //get disposed when the TasksGrid is disposed (as it would be the casae if we
  //we used the AnimationControllerState helper.).
  //This is necessary when the page flip effect takes place, as the parent widget still
  //holds onto a GlobalKey, meaning that the animationController will be needed again later
  //(hence it should not be disposed).
  late AnimationController animationController;
  late bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void enterEditMode() {
    animationController.forward();
    setState(() => _isEditing = true);
  }

  void exitEditMode() {
    animationController.reverse();
    setState(() => _isEditing = false);
  }

  Future<void> _addNewTask(WidgetRef ref) async {
    //Notify the parent widget that we need to exit the edit mode.
    //As a result, the parent widget will call exitEditMode() and
    //the edit UI will be dismissed.
    widget.onAddorEditTask?.call();
    //Short delay to wait for the animations to complete.
    await Future.delayed(const Duration(milliseconds: 200));
    final appThemeData = AppTheme.of(context);
    final frontOrBackSide = ref.read<FrontOrBackSide>(frontOrBackSideProvider);
    //Then, show the AddTask page
    await showCupertinoModalBottomSheet<void>(
      context: context,
      barrierColor: AppColors.black50,
      builder: (_) => AppTheme(
        data: appThemeData,
        child: AddTaskNavigator(frontOrBackSide: frontOrBackSide),
      ),
    );
  }

  Future<void> _editTask(WidgetRef ref, Task task) async {
    //Notify the parent widget that we need to exit the edit mode.
    //As a result, the parent widget will call exitEditMode() and
    //the edit UI will be dismissed.
    widget.onAddorEditTask?.call();
    //Short delay to wait for the animations to complete
    await Future.delayed(const Duration(milliseconds: 200));
    final appThemeData = AppTheme.of(context);
    final frontOrBackSide = ref.read<FrontOrBackSide>(frontOrBackSideProvider);
    //Then, show the TaskDetailsPage
    await showCupertinoModalBottomSheet<void>(
      context: context,
      barrierColor: AppColors.black50,
      builder: (_) => AppTheme(
        data: appThemeData,
        child: TaskDetailPage(
          task: task,
          isNewTask: false,
          frontOrBackSide: frontOrBackSide,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisSpacing = constraints.maxWidth * 0.05;
        final taskWidth = (constraints.maxWidth - crossAxisSpacing) / 2.0;
        const aspectRatio = 0.82;
        final taskHeight = taskWidth / aspectRatio;
        final mainAxisSpacing =
            max<double>((constraints.maxHeight - taskHeight * 3) / 2.0, 0.1);
        final taskLength = min(6, widget.tasks.length + 1);
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          //gridDelegate: specify how the items are laid out.
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //represents the number of columns in the grid.
              crossAxisSpacing:
                  crossAxisSpacing, //the spacing of items between columns.
              mainAxisSpacing:
                  mainAxisSpacing, //the spacing between items in rows.
              childAspectRatio:
                  aspectRatio //fixed proportion between width and height for each child widget.
              ),
          itemBuilder: (context, index) {
            return Consumer(
              builder: (context, ref, _) {
                if (index == widget.tasks.length) {
                  return OpacityAnimatedWideget(
                    animation: animationController,
                    child: AddTaskItem(
                      onCompleted: _isEditing ? () => _addNewTask(ref) : null,
                    ),
                  );
                }
                final task = widget.tasks[index];
                return TaskWithNameLoader(
                  task: task,
                  isEditing: _isEditing,
                  editTaskButtonBuilder: (_) => StaggeredScaleAnimatedWidget(
                    animation: animationController,
                    index: index,
                    child: EditTaskButton(
                      onPressed: () => _editTask(ref, task),
                    ),
                  ),
                );
              },
            );
          },
          itemCount: taskLength,
        );
      },
    );
  }
}

//We are using a WidgetBuilder to delegate the creation on EditTaskButton inside
//the TasksGrid widget.Due to TasksGrid widget will contain all the code neede to
//drive the animation
//We use a single AnimationController to drive the animation on multiple widgets.
//We use widget composition to apply the scale animation to each one of these button.
