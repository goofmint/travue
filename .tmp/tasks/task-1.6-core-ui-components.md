# Task 1.6: Core UI Components Development

## 概要

アプリケーションの基本UIコンポーネントの実装を行います。共通ウィジェット、ナビゲーション、テーマシステムの構築により、一貫性のあるユーザー体験を提供する基盤を構築します。

## 目標

- [ ] アプリ全体で使用する共通ウィジェットの実装
- [ ] 統一されたナビゲーションシステムの構築  
- [ ] Material Design 3準拠のテーマシステムの実装
- [ ] レスポンシブデザインの基盤構築

## 実装内容

### 1. テーマシステム (theme_system.dart)

アプリ全体で使用するテーマ定義とカラーパレットの実装

```dart
// lib/presentation/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: TravueColors.primary),
    useMaterial3: true,
  );
  
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: TravueColors.primary,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
```

### 2. 共通ウィジェット (common_widgets.dart)

- **TravueButton**: 統一されたボタンデザイン
- **TravueCard**: 一貫性のあるカードコンポーネント  
- **TravueTextField**: フォーム入力用テキストフィールド
- **LoadingIndicator**: ローディング表示
- **ErrorWidget**: エラー表示コンポーネント

### 3. ナビゲーションシステム (navigation_system.dart)

```dart
// lib/presentation/navigation/app_router.dart
class AppRouter {
  static GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      // 追加ルート定義
    ],
  );
}
```

### 4. レイアウトコンポーネント (layout_components.dart)

- **AppScaffold**: 統一されたスキャフォールドラッパー
- **ResponsiveLayout**: レスポンシブレイアウト対応
- **BottomNavigationBarWidget**: ボトムナビゲーション

## 技術要件

### 使用パッケージ

```yaml
dependencies:
  go_router: ^14.0.0
  flutter_screenutil: ^5.9.0
```

### ファイル構成

```
lib/presentation/
├── theme/
│   ├── app_theme.dart
│   ├── colors.dart
│   └── text_styles.dart
├── widgets/
│   ├── common/
│   │   ├── travue_button.dart
│   │   ├── travue_card.dart
│   │   ├── travue_text_field.dart
│   │   ├── loading_indicator.dart
│   │   └── error_widget.dart
│   └── layout/
│       ├── app_scaffold.dart
│       ├── responsive_layout.dart
│       └── bottom_navigation_bar.dart
├── navigation/
│   └── app_router.dart
└── screens/
    └── home/
        └── home_screen.dart
```

## 完了条件

- [ ] 全ての共通ウィジェットが実装されている
- [ ] テーマシステムがライト・ダークモードに対応している
- [ ] ナビゲーションシステムが基本画面遷移をサポートしている
- [ ] レスポンシブデザインが各画面サイズで適切に動作する
- [ ] ウィジェットテストが作成されている

## テスト要件

各ウィジェットについて以下のテストを実装:

```dart
// test/presentation/widgets/common/travue_button_test.dart
void main() {
  testWidgets('TravueButton displays text correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TravueButton(
          text: 'Test Button',
          onPressed: () {},
        ),
      ),
    );
    
    expect(find.text('Test Button'), findsOneWidget);
  });
}
```

## 依存関係

- Task 1.1.1 (Clean Architecture Implementation) の完了が必要
- 既存のドメインエンティティとの連携を考慮

## 推定作業時間

- テーマシステム実装: 2時間
- 共通ウィジェット実装: 4時間  
- ナビゲーションシステム実装: 3時間
- レイアウトコンポーネント実装: 3時間
- テスト実装: 2時間

**合計: 14時間**

## 注意点

- Material Design 3のガイドラインに準拠する
- アクセシビリティを考慮した実装を行う
- パフォーマンスを意識した軽量な実装を心がける
- 将来的な機能拡張を考慮した拡張性のある設計にする