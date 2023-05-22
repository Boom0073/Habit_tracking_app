import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/models/front_or_back_side.dart';
import 'package:habit_tracker/models/hive_task.dart';
import 'package:habit_tracker/ui/onboarding/onboarding_page.dart';
import 'package:habit_tracker/ui/theming/app_theme_manager.dart';
import './pages/home_page.dart';
import './constants/app_assets.dart';
import 'persistence/hive_data_store.dart';
import './ui/onboarding/home_or_onboarding.dart';

//In general, if you have any app startup logic that needs to run before anything
//else happens, the main method is a good place for this.Because you can use it
//to await for asynchronous initialization to complete.So that everything is ready by the time
//your code run up and load the widget tree.And you can do this as long as you
//mark the main method as async.

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppAssets.preloadSVGs();
  //Widgets should access this instance of the dataStore.We need a dependency override.
  final dataStore = HiveDataStore();
  await dataStore.init(); //This is initializing our data store.
  //This code will create default 6 tasks and store them with Hive.
  //The first time the application start
  /*
  await dataStore.createDemoTasks(
    frontTasks: [
      //Task.create(name: 'Take Vitamins', iconName: AppAssets.vitamins),
      //Task.create(name: 'Cycle to Work', iconName: AppAssets.bike),
      //Task.create(name: 'Wash Your Hands', iconName: AppAssets.washHands),
      //Task.create(name: 'Wear a Mask', iconName: AppAssets.mask),
      //Task.create(name: 'Brush Your Teeth', iconName: AppAssets.toothbrush),
    ],
    backTasks: [
      //Task.create(name: 'Eat a Healthy Meal', iconName: AppAssets.carrot),
      //Task.create(name: 'Walk the Dog', iconName: AppAssets.dog),
      //Task.create(name: 'Do Some Coding', iconName: AppAssets.html),
      //Task.create(name: 'Meditate', iconName: AppAssets.meditation),
      //Task.create(name: 'Do 10 Pushups', iconName: AppAssets.pushups),
    ],
    force: false,
  );
  */
  final frontThemeSettings =
      await dataStore.appThemeSettings(side: FrontOrBackSide.front);
  final backThemeSettings =
      await dataStore.appThemeSettings(side: FrontOrBackSide.back);
  runApp(
    ProviderScope(
      //dependency override.To ensure that dataStore in the homepage
      //is the same dataStore object in the main function.Once this code
      //is executed,then the value that is currently stored in the dataStoreProvider
      //will be replaced by the value that we pass as an argument
      //Once again, the purpose of these overrides is to make sure that by the time
      //the App is loaded.Then these providers are valid and they no longer throw
      //an unimplemented error.
      overrides: [
        dataStoreProvider.overrideWithValue(dataStore),
        //We can now use these to load the ThemeSettings object
        frontThemeManagerProvider.overrideWithValue(AppThemeManager(
          dataStore: dataStore,
          side: FrontOrBackSide.front,
          themeSettings: frontThemeSettings,
        )),
        backThemeManagerProvider.overrideWithValue(AppThemeManager(
          dataStore: dataStore,
          side: FrontOrBackSide.back,
          themeSettings: backThemeSettings,
        ))
      ],
      child: const MyApp(),
    ),
  );
}
//^
//You can think of 'ProviderScope' as a container for all the providers that
//we will use in our app.
//As a result of dependency override the value that is currently stored in the dataStoreProvier
//will be replaced by the value that we pass as an argument.Then any widget that are watching
//for this specific provider will rebuild.In this case, nothing really needs to rebuild
//because we are just starting the app,and ProviderScope is at the root of our widget tree.

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //You can customize the way theming works by passing a ThemeData object
      //when you create your MaterialApp.
      theme: ThemeData(
        fontFamily: 'Helvetica Neue',
        //The purpose of this is to disable the Material splash effect on all
        //buttons in the app.We are not using Material Design for this project.
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      home: const HomeOrOnboarding(),
    );
  }
}

//Note Hive local storage
//1. Create the HiveDataStore just once inside the main method and make it available
//to all the widgets by creating a dataStoreProvider.
//2. Since dataStore.init() and .createDemoTasks is configured asynchronously so the
//dataStoreProvider should throw an UnimplementedError by default.Once the dataStore has been
//created it never changed again.
//3. Override the value that is returned by the provider once the data store is created and
//initialized.inside the top ProviderScope.
