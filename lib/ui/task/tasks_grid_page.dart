import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:habit_tracker/models/hive_task.dart';
import '../../models/app_theme_settings.dart';
import 'package:habit_tracker/ui/theming/app_theme.dart';
import 'tasks_grid.dart';
import 'home_page_bottom_options.dart';
import '../sliding_panel/sliding_panel.dart';
import '../sliding_panel/theme_selection_close.dart';
import '../sliding_panel/theme_selection_list.dart';
import '../sliding_panel/sliding_panel_animator.dart';
import '../theming/animated_app_theme.dart';

class TasksGridPage extends StatelessWidget {
  const TasksGridPage({
    Key? key,
    required this.tasks,
    this.onFlip,
    required this.leftAnimatorKey,
    required this.rightAnimatorKey,
    required this.gridKey,
    required this.themeSettings,
    this.onColorIndexSelected,
    this.onVariantIndexSelected,
  }) : super(key: key);
  final List<Task> tasks;
  final VoidCallback? onFlip;
  final GlobalKey<SlidingPanelAnimatorState> leftAnimatorKey;
  final GlobalKey<SlidingPanelAnimatorState> rightAnimatorKey;
  final GlobalKey<TasksGridState> gridKey;
  final AppThemeSettings themeSettings;
  final ValueChanged<int>? onColorIndexSelected;
  final ValueChanged<int>? onVariantIndexSelected;

  void _enterEditMode() {
    leftAnimatorKey.currentState?.slideIn();
    rightAnimatorKey.currentState?.slideIn();
    gridKey.currentState?.enterEditMode();
  }

  void _exitEditMode() {
    leftAnimatorKey.currentState?.slideOut();
    rightAnimatorKey.currentState?.slideOut();
    gridKey.currentState!.exitEditMode();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAppTheme(
      duration: const Duration(milliseconds: 300),
      data: themeSettings.themeData,
      child: Builder(
        builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.of(context).overlayStyle,
          child: Scaffold(
            backgroundColor: AppTheme.of(context).primary,
            body: SafeArea(
              child: Stack(
                children: [
                  TasksGridContents(
                    gridKey: gridKey,
                    tasks: tasks,
                    onFlip: onFlip,
                    onEnterEditMode: _enterEditMode,
                    onExitEditMode: _exitEditMode,
                  ),
//Many of the widgets that are available in Flutter have their own animated versions.
//For example, the position widget that we are using here can be animated by using
//AnimatedPosition().Whenever one of the properties of this widget changes then
//Flutter automatically animates from the previous value to the new value.This kind of API is really simple to use.
                  Positioned(
                    bottom: 6,
                    left: 0,
                    width: SlidingPanel.leftPanelFixedWidth,
                    child: SlidingPanelAnimator(
                      key: leftAnimatorKey,
                      direction: SlideDirection.leftToRight,
                      child: ThemeSelectionClose(
                        onClose: _exitEditMode,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 0,
                    width: MediaQuery.of(context).size.width -
                        SlidingPanel.leftPanelFixedWidth,
                    child: SlidingPanelAnimator(
                      key: rightAnimatorKey,
                      direction: SlideDirection.rightToLeft,
                      child: ThemeSelectionList(
                        currentThemeSetting: themeSettings,
                        availableWidth: MediaQuery.of(context).size.width -
                            SlidingPanel.leftPanelFixedWidth -
                            SlidingPanel.paddingWidth,
                        onColorIndexSelected: onColorIndexSelected,
                        onVariantIndexSelected: onVariantIndexSelected,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TasksGridContents extends StatelessWidget {
  const TasksGridContents({
    Key? key,
    this.gridKey,
    required this.tasks,
    this.onFlip,
    this.onEnterEditMode,
    this.onExitEditMode,
  }) : super(key: key);
  final Key? gridKey;
  final List<Task> tasks;
  final VoidCallback? onFlip;
  final VoidCallback? onEnterEditMode;
  final VoidCallback? onExitEditMode;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: TasksGrid(
              key: gridKey,
              tasks: tasks,
              onAddorEditTask: onExitEditMode,
            ),
          ),
        ),
        HomePageBottomOptions(
          onFlip: onFlip,
          onEnterEditMode: onEnterEditMode,
        ),
      ],
    );
  }
}


//The main idea is that the widgets at the bottom are mainly concerned with UI
//and layout and as such they can be configured with some properties that are passing
//by the widgets above them.They also define some calbacks and widget builders that
//they can use to inform the widget above when something changes.
//On the other hand, the widget above use some GlobalKeys to control the state of some
//of the descendant widgets.So these can be use to drive some animation
//So using Callbacks and GlobalKey is ok for this project because we don't have a deep widget
//tree.We only propagate callbacks and keys by 2 or 3 levels at the most, which is tolerable.
//But if you have a more complex app with a very deep widget tree.So using Riverpod.