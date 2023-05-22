import 'package:flutter/material.dart';

import './task_with_name.dart';
import '../../models/hive_task.dart';
import '../../constants/app_assets.dart';

class AddTaskItem extends StatelessWidget {
  const AddTaskItem({
    super.key,
    this.onCompleted,
  });
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    return TaskWithName(
      task: Task(id: '', name: 'Add a task', iconName: AppAssets.plus),
      hasCompletedState: false,
      onCompleted: (completed) => onCompleted?.call(),
    );
  }
}
