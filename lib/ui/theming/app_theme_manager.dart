import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_theme_settings.dart';
import '../../persistence/hive_data_store.dart';
import '../../models/front_or_back_side.dart';

//Type annotation represents the type of the state class that we want to use.
class AppThemeManager extends StateNotifier<AppThemeSettings> {
  AppThemeManager(
      {required this.dataStore,
      required this.side,
      required AppThemeSettings themeSettings})
      : super(themeSettings);
//super(themeSettings) represent 'initial value' of StateNotifier.
  final HiveDataStore dataStore;
  final FrontOrBackSide side;

  void updateColorIndex(int colorIndex) {
    //The main idea of this method is that when the colorIndex changes, we should
    //update the current state (themeSettings).
    //This is a common pattern that you seen in other places in Flutter, whenever
    //you need to update only one property of a certain object and keep all the
    //remaining ones with their previous values.
    state = state.copyWith(colorIndex: colorIndex);
    //By updating the state, all widgets that are 'watching' the StateNotifier
    //will rebuild
    dataStore.setAppThemeSettings(settings: state, side: side);
    //This is how we update both the state and the data store when the colorIndex changes.
  }

  void updateVariantIndex(int variantIndex) {
    state = state.copyWith(variantIndex: variantIndex);
    dataStore.setAppThemeSettings(settings: state, side: side);
  }
}

//StateNotifierProvider is a type of Provider that takes two types annotations
//the first one is the type of the 'StateNotifier' subclass that we have difined
//the second one is the type of the 'StateNotifier' itself.
final frontThemeManagerProvider =
    StateNotifierProvider<AppThemeManager, AppThemeSettings>((ref) {
  throw UnimplementedError();
});

final backThemeManagerProvider =
    StateNotifierProvider<AppThemeManager, AppThemeSettings>((ref) {
  throw UnimplementedError();
});
