import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/models/front_or_back_side.dart';
import 'package:habit_tracker/ui/task/tasks_grid.dart';
import 'package:page_flip_builder/page_flip_builder.dart';
import 'package:hive/hive.dart';

import 'package:habit_tracker/models/hive_task.dart';
import 'package:habit_tracker/persistence/hive_data_store.dart';
import '../ui/task/tasks_grid_page.dart';
import '../ui/sliding_panel/sliding_panel_animator.dart';
import '../ui/theming/app_theme_manager.dart';

// Note: Extending ConsumerStatefulWidget so that we can access the WidgetRef directly
//in the state class
class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

//Always declare GlobalKeys inside a State class rather than a StatelessWidget
//because everytime app rebuild StatelessWidget will always create a new instance
//and then new instance GlobalKey() will create along then widget that use that
//GlobalKey() cannot reference to previously GlobalKey() but refer to new GlobalKey()

class _HomePageState extends ConsumerState<HomePage> {
  final _pageFlipKey = GlobalKey<PageFlipBuilderState>();
  final _frontSlidingPanelLeftAnimatorKey =
      GlobalKey<SlidingPanelAnimatorState>();
  final _frontSlidingPanelRightAnimatorKey =
      GlobalKey<SlidingPanelAnimatorState>();
  final _frontGridKey = GlobalKey<TasksGridState>();
  final _backSlidingPanelLeftAnimatorKey =
      GlobalKey<SlidingPanelAnimatorState>();
  final _backSlidingPanelRightAnimatorKey =
      GlobalKey<SlidingPanelAnimatorState>();
  final _backGridKey = GlobalKey<TasksGridState>();
  @override
  Widget build(BuildContext context) {
    //By calling 'ref.watch()' then this widget will rebuild every time the
    //value that is returned by dataStoreProvider changes.
    final dataStore = ref.watch<HiveDataStore>(dataStoreProvider);
    return PageFlipBuilder(
      key: _pageFlipKey,
      frontBuilder: (context) => ProviderScope(
        overrides: [
          frontOrBackSideProvider.overrideWithValue(FrontOrBackSide.front)
        ],
        child: ValueListenableBuilder(
            valueListenable: dataStore.frontTasksListenable(),
            builder: (_, Box<Task> box, __) => TasksGridPage(
                  key: const ValueKey(1),
                  leftAnimatorKey: _frontSlidingPanelLeftAnimatorKey,
                  rightAnimatorKey: _frontSlidingPanelRightAnimatorKey,
                  gridKey: _frontGridKey,
                  tasks: box.values.toList(),
                  onFlip: () => _pageFlipKey.currentState?.flip(),
                  themeSettings: ref.watch(frontThemeManagerProvider),
                  onColorIndexSelected: (colorIndex) => ref
                      .read(frontThemeManagerProvider.notifier)
                      .updateColorIndex(colorIndex),
                  onVariantIndexSelected: (variantIndex) => ref
                      .read(frontThemeManagerProvider.notifier)
                      .updateVariantIndex(variantIndex),
                )),
      ),
      backBuilder: (context) => ProviderScope(
        overrides: [
          frontOrBackSideProvider.overrideWithValue(FrontOrBackSide.back)
        ],
        child: ValueListenableBuilder(
          valueListenable: dataStore.backTasksListenable(),
          builder: (_, Box<Task> box, __) => TasksGridPage(
            key: const ValueKey(2),
            leftAnimatorKey: _backSlidingPanelLeftAnimatorKey,
            rightAnimatorKey: _backSlidingPanelRightAnimatorKey,
            gridKey: _backGridKey,
            tasks: box.values.toList(),
            onFlip: () => _pageFlipKey.currentState?.flip(),
            themeSettings: ref.watch(backThemeManagerProvider),
            onColorIndexSelected: (colorIndex) => ref
                .read(backThemeManagerProvider.notifier)
                .updateColorIndex(colorIndex),
            onVariantIndexSelected: (variantIndex) => ref
                .read(backThemeManagerProvider.notifier)
                .updateVariantIndex(variantIndex),
          ),
        ),
      ),
    );
  }
}

//The way this code work is that the Consumer widget gives us a reference ('ref') that
//we can use to access all the providers that we have created.
//Use ref.watch() to get a provider's value or object that it contains.

//We can call a method inside a child widget's state class by using a GlobalKey that is defined inside
//the parent widget.

//We working with GlobalKey() so we can modify the state of a child widget from
//a parent widget.

//The really important point that you should remember ref.read() vs ref.watch()
//use ref.watch() from the build() method to rebuild your widgets when the provider
//state changes and you should use ref.read() when you're inside a callback and
//you want to call a method of the provider.