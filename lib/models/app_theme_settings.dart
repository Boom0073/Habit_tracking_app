import 'package:hive/hive.dart';
import './front_or_back_side.dart';
import '../constants/app_colors.dart';
import '../ui/theming/app_theme.dart';

part 'app_theme_settings.g.dart';

@HiveType(typeId: 2)
class AppThemeSettings {
  AppThemeSettings({required this.colorIndex, required this.variantIndex});
  factory AppThemeSettings.defaults(FrontOrBackSide side) {
    return AppThemeSettings(
      colorIndex: 0,
      variantIndex: side == FrontOrBackSide.front ? 0 : 2,
    );
  }

  @HiveField(0)
  final int colorIndex;

  @HiveField(1)
  final int variantIndex;

  AppThemeSettings copyWith({int? colorIndex, int? variantIndex}) {
    return AppThemeSettings(
      colorIndex: colorIndex ?? this.colorIndex,
      variantIndex: variantIndex ?? this.variantIndex,
    );
  }

  AppThemeData get themeData {
    final variants = AppThemeVariants(AppColors.allSwatches[colorIndex]);
    return variants.themes[variantIndex];
  }
}
