//This file we're going to create a new model class that we can use to store
//tasks with Hive local storage

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'hive_task.g.dart';

//This is all we have to do to create a Hive type.
//Since this is the first one that we create, we can use 0 as a value.
@HiveType(typeId: 0)
class Task {
  const Task({required this.id, required this.name, required this.iconName});

  factory Task.create({required String name, required String iconName}) {
    final id = const Uuid().v1();
    return Task(id: id, name: name, iconName: iconName);
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String iconName;

//In order to serialize types so that they can be written in local storage, we
//need to create a type adapter.
}

//All variables are final.In general it's a good idea to make model classes
//immutable so that there are less chances that we modify this data when we
//are not supposed to.