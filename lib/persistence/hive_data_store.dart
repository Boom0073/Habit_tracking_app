import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/models/hive_task.dart';
import '../models/task_state.dart';
import '../models/app_theme_settings.dart';
import '../models/front_or_back_side.dart';

class HiveDataStore {
  //We will need to reference this box name again when we read and write tasks.
  //then we can use this identifier whenever we need to access this box.
  static const frontTasksBoxName = 'frontTasks';
  static const backTasksBoxName = 'backTasks';
  static const tasksStateBoxName = 'tasksState';
  static const flagsBoxName = 'flags';
  static String taskStateKey(String key) => 'tasksState/$key';
  static const frontAppThemeBoxName = 'frontAppTheme';
  static const backAppThemeBoxName = 'backAppTheme';

  static const alwaysShowAddTaskKey = 'alwaysShowAddTask';
  static const didAddFirstTaskKey = 'didAddFirstTask';
  //Initialize Hive
  //Register an adapter for our task model class
  Future<void> init() async {
    await Hive.initFlutter();
    //Always specify the Type and the corresponding adapter
    Hive.registerAdapter<Task>(TaskAdapter());
    Hive.registerAdapter<TaskState>(TaskStateAdapter());
    Hive.registerAdapter<AppThemeSettings>(AppThemeSettingsAdapter());
    //finally, open a new box that will hold all the tasks that we need to start.
    await Hive.openBox<Task>(frontTasksBoxName);
    await Hive.openBox<Task>(backTasksBoxName);
    await Hive.openBox<TaskState>(tasksStateBoxName);
    await Hive.openBox<AppThemeSettings>(frontAppThemeBoxName);
    await Hive.openBox<AppThemeSettings>(backAppThemeBoxName);
    await Hive.openBox<bool>(flagsBoxName);
  }

  Future<void> createDemoTasks({
    required List<Task> frontTasks,
    required List<Task> backTasks,
    bool force = false,
  }) async {
    final frontBox = Hive.box<Task>(frontTasksBoxName);
    if (frontBox.isEmpty || force == true) {
      await frontBox.clear();
      await frontBox.addAll(frontTasks);
    } else {
      log('Box already has ${frontBox.length} items');
    }
    final backBox = Hive.box<Task>(backTasksBoxName);
    if (backBox.isEmpty || force == true) {
      await backBox.clear();
      await backBox.addAll(backTasks);
    } else {
      log('Box already has ${backBox.length} items');
    }
  }

  //The main point here is that we want to avoid calling any mathods on this hive
  //class directly inside our widgets.
  ValueListenable<Box<Task>> frontTasksListenable() {
    return Hive.box<Task>(frontTasksBoxName).listenable();
  }

  ValueListenable<Box<Task>> backTasksListenable() {
    return Hive.box<Task>(backTasksBoxName).listenable();
  }

  //This method for saving tasksState object with Hive.
  Future<void> setTaskState(
      {required Task task, required bool completed}) async {
    final box = Hive.box<TaskState>(tasksStateBoxName);
    final taskState = TaskState(taskId: task.id, completed: completed);
    await box.put(taskStateKey(task.id), taskState);
  }

  ValueListenable<Box<TaskState>> taskStateListenable({required Task task}) {
    final box = Hive.box<TaskState>(tasksStateBoxName);
    final key = taskStateKey(task.id);
    return box.listenable(keys: <String>[
      key
    ]); //We want to only notify listeners for a specific task (not all of them).
  }

  TaskState taskState(Box<TaskState> box, {required Task task}) {
    final key = taskStateKey(task.id);
    return box.get(key) ?? TaskState(taskId: task.id, completed: false);
  }

  //App Theme Settings
  Future<void> setAppThemeSettings({
    required AppThemeSettings settings,
    required FrontOrBackSide side,
  }) async {
    final themeKey = side == FrontOrBackSide.front
        ? frontAppThemeBoxName
        : backAppThemeBoxName;
    final box = Hive.box<AppThemeSettings>(themeKey);
    await box.put(themeKey, settings);
  }

  Future<AppThemeSettings> appThemeSettings(
      {required FrontOrBackSide side}) async {
    final themeKey = side == FrontOrBackSide.front
        ? frontAppThemeBoxName
        : backAppThemeBoxName;
    final box = Hive.box<AppThemeSettings>(themeKey);
    final setting = box.get(themeKey);
    return setting ?? AppThemeSettings.defaults(side);
  }

  //Save and delete tasks
  Future<void> saveTask(Task task, FrontOrBackSide frontOrBackSide) async {
    final boxName = frontOrBackSide == FrontOrBackSide.front
        ? frontTasksBoxName
        : backTasksBoxName;
    final box = Hive.box<Task>(boxName);
    if (box.values.isEmpty) {
      await box.add(task);
    } else {
      final index =
          box.values.toList().indexWhere((element) => element.id == task.id);
      if (index >= 0) {
        await box.putAt(index, task);
      } else {
        await box.add(task);
      }
    }
  }

  Future<void> deleteTask(Task task, FrontOrBackSide frontOrBackSide) async {
    final boxName = frontOrBackSide == FrontOrBackSide.front
        ? frontTasksBoxName
        : backTasksBoxName;
    final box = Hive.box<Task>(boxName);
    if (box.isNotEmpty) {
      final index =
          box.values.toList().indexWhere((element) => element.id == task.id);
      if (index >= 0) {
        await box.deleteAt(index);
      }
    }
  }

  //Did Add First Task
  Future<void> setDidAddFirstTask(bool value) async {
    final box = Hive.box<bool>(flagsBoxName);
    await box.put(didAddFirstTaskKey, value);
  }

  ValueListenable<Box<bool>> didAddFirstTaskListenable() {
    return Hive.box<bool>(flagsBoxName)
        .listenable(keys: <String>[didAddFirstTaskKey]);
  }

  bool didAddFirstTask(Box<bool> box) {
    final value = box.get(didAddFirstTaskKey);
    return value ?? false;
  }

  //Always Show Add Task
  Future<void> setAlwaysShowAddTask(bool value) async {
    final box = Hive.box<bool>(flagsBoxName);
    await box.put(alwaysShowAddTaskKey, value);
  }

  ValueListenable<Box<bool>> alwaysShowAddTaskListenable() {
    return Hive.box<bool>(flagsBoxName)
        .listenable(keys: <String>[alwaysShowAddTaskKey]);
  }

  bool alwaysShowAddTask(Box<bool> box) {
    final value = box.get(alwaysShowAddTaskKey);
    return value ?? true;
  }
}

//In summary, Hive initialization code contains these three steps.
//We created the HiveDataStore class, now we need to create an instance of it and
//use it to call init() method

//Create first provider
//This identifier is global, which means that we can access it by reference from
//any other file in our project as long as we import the file where it is defined.
final dataStoreProvider = Provider<HiveDataStore>((ref) {
  throw UnimplementedError();
});
//replace return HiveDataStore(); with throw UnimplementedError(); because
//Since dataStoreProvider should not return a HiveDataStore object until asynchronous work
//dataStore.init() and .createDemoTasks has finished.
//And this will guarantee that we get a runtime exception if we try to watch the 
//dataStoreProvider before we have overriden its value inside the ProviderScope.