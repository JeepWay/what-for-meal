import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = _lightTheme;
  // static final ThemeData darkTheme = _darkTheme;
}

final _lightColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.amber.shade600,
  brightness: Brightness.light,
  primary: Colors.amber.shade600, // 主題色：橙色 (0xFFFF9800)
  onPrimary: Colors.white, // 主題色上的文字/圖標：白色
  secondary: Colors.grey.shade200, // 次要色：番茄紅
  onSecondary: Colors.white, // 次要色上的文字/圖標：白色
  error: Colors.red.shade800, // 錯誤色：柔和紅色
  onError: Colors.white, // 錯誤色上的文字/圖標：白色
  surface: Colors.grey.shade50, // 表面色（如卡片）：淺橙米色
  onSurface: Colors.black87, // 表面上的文字/圖標：深灰色
);


ThemeData _lightTheme = ThemeData(
  primarySwatch: Colors.orange,
  colorScheme: _lightColorScheme,
  useMaterial3: true,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.orange, width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.orange,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide(color: Colors.orange.shade300),
    ),
  ),
  textTheme: Typography.material2021().black.copyWith(
    displayLarge: const TextStyle(
      color: Colors.black87,
    ),
    displayMedium: const TextStyle(
      color: Colors.black87,
    ),
    displaySmall: const TextStyle(
      color: Colors.black87,
    ),
    headlineMedium: const TextStyle(
      color: Colors.black87,
    ),
    titleLarge: const TextStyle( 
      color: Colors.black87,
    ),
    titleMedium: const TextStyle( 
      color: Colors.black87,
    ),
    bodyLarge: const TextStyle(
      color: Colors.black87,
    ),
    bodyMedium: const TextStyle(
      color: Colors.black54,
    ),
    bodySmall: const TextStyle(
      color: Colors.black54,
    ),
    labelLarge: const TextStyle(  // 用於按鈕文字
      color: Colors.black54, 
    ),
    labelMedium: const TextStyle(
      color: Colors.black54,
    ),
    labelSmall: const TextStyle(
      color: Colors.black54,
    ),
  ),
);


// ThemeData _darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     primarySwatch: Colors.orange,
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: Colors.orange,
//       brightness: Brightness.dark,
//       primary: Colors.orange,
//       secondary: Colors.amber,
//     ),
//     useMaterial3: true,
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.grey[800],
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 20,
//         vertical: 16,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey[700]!),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Colors.orange, width: 2),
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.black,
//         backgroundColor: Colors.amber,
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         side: const BorderSide(color: Colors.grey),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         iconSize: 25,
//       ),
//     ),
//     textTheme: const TextTheme(
//       displayLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//       displayMedium: TextStyle(
//         fontSize: 28,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//       headlineMedium: TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//       titleLarge: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.w500,
//         color: Colors.white,
//       ),
//       bodyLarge: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.normal,
//         color: Colors.white,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.normal,
//         color: Colors.white,
//       ),
//       labelLarge: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w500,
//         color: Colors.white, // 用於按鈕文字
//       ),
//     ),
//   );


  // class AppColors {
//   static const Color seedColor = Colors.orange;

//   static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
//     seedColor: seedColor,
//     brightness: Brightness.light,
//     // 主要顏色 - 由種子顏色生成，但可以自訂
//     primary: seedColor,
//     onPrimary: Colors.white,
//     // primaryContainer - 用於按鈕背景、強調區域等
//     primaryContainer: Colors.orange.shade100,
//     onPrimaryContainer: Colors.deepOrange.shade900,
//     // 次要顏色 - 選擇較深的橙色作為對比
//     secondary: Colors.deepOrange.shade300,
//     onSecondary: Colors.white,
//     // secondaryContainer - 適用於次要按鈕、標籤等
//     secondaryContainer: Colors.deepOrange.shade50,
//     onSecondaryContainer: Colors.deepOrange.shade900,
//     // 第三色 - 選擇較淺的橙色提供視覺層次
//     tertiary: Colors.orange.shade200,
//     onTertiary: Colors.black87,
//     // tertiaryContainer - 用於強調不那麼重要的UI元素
//     tertiaryContainer: Colors.amber.shade50,
//     onTertiaryContainer: Colors.brown.shade800,
//     // 錯誤狀態顏色
//     error: Colors.red.shade700,
//     onError: Colors.white,
//     // errorContainer - 用於錯誤提示背景
//     errorContainer: Colors.red.shade50,
//     onErrorContainer: Colors.red.shade900,
//     // 背景色 - 選擇淺橙色調的背景，但保持較淺以確保可讀性
//     // background: Color(0xFFFFF8F0), // 非常淺的橙色調背景
//     // onBackground: Colors.black87,
//     // 表面顏色 - 比背景更白，用於卡片等元素
//     surface: Colors.white,
//     onSurface: Colors.black87,
//     // 表面變體，用於不同層次的表面
//     // surfaceVariant: Colors.orange.shade50,
//     onSurfaceVariant: Colors.black54,
//     // 輪廓顏色，用於分隔線等
//     outline: Colors.orange.shade300,
//     outlineVariant: const Color.fromARGB(255, 17, 15, 13),
//     // 陰影色彩
//     shadow: Colors.black.withOpacity(0.1),
//     scrim: Colors.black.withOpacity(0.2),
//     // 容器顏色系列 - 用於不同層次的容器
//     surfaceContainerHighest: Colors.orange.shade100,
//     surfaceContainer: Colors.orange.shade50,
//     surfaceContainerLow: Color(0xFFFFFAF0),
//     surfaceContainerLowest: Colors.white,
//     surfaceContainerHigh: Colors.orange.shade100,
//     // 反轉的顏色
//     inverseSurface: Colors.brown.shade900,
//     onInverseSurface: Colors.white,
//     inversePrimary: Colors.orange.shade200,
//   );
// }