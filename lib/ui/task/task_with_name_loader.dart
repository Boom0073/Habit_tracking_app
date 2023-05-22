import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/ui/task/task_with_name.dart';
import 'package:hive/hive.dart';

import 'package:habit_tracker/models/task_state.dart';
import 'package:habit_tracker/persistence/hive_data_store.dart';

import '../../models/hive_task.dart';

//This widget will sit between TasksGrid and TaskWithName widgets and the sole
//purpose of it will be to load the task state from Hive and update this state
//when the onComplted callback from AnimatedTask widget fires.
//One important thing about this widget is that it should be reactive.What means
//whenever the task completion state changes then the widget should rebuild itself.

class TaskWithNameLoader extends ConsumerWidget {
  const TaskWithNameLoader({
    Key? key,
    required this.task,
    this.isEditing = false,
    this.editTaskButtonBuilder,
  }) : super(key: key);
  final Task task;
  final bool isEditing;
  final WidgetBuilder? editTaskButtonBuilder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Inside a build method, you should always call ref.watch() so that the widget
    //will rebuild if the provider's value changes.
    final dataStore = ref.watch(dataStoreProvider);
    return ValueListenableBuilder(
        valueListenable: dataStore.taskStateListenable(task: task),
        builder: (context, Box<TaskState> box, _) {
          final taskState = dataStore.taskState(box, task: task);
          return TaskWithName(
            task: task,
            completed: taskState.completed,
            isEditing: isEditing,
            onCompleted: (completed) {
              //However, inside the callback, you should ref.read instead because
              //call back are normally used to trigger some business logic.And
              //you shouldn't use ref.watch() inside the callback.
              ref
                  .read(dataStoreProvider)
                  .setTaskState(task: task, completed: completed);
            },
            editTaskButtonBuilder: editTaskButtonBuilder,
          );
        });
  }
}
