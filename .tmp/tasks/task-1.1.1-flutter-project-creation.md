# Task 1.1.1 - Flutter プロジェクト作成

## 概要

旅行ガイドブック作成・共有アプリ「Travue」の基盤となるFlutterプロジェクトを作成します。

## 作業内容

### 手順

1. **プロジェクト作成**
   ```bash
   flutter create app
   cd app
   ```

2. **Flutterバージョン確認**
   ```bash
   flutter --version
   ```
   - 要求バージョン: Flutter 3.16+ / Dart 3.2+

3. **初期動作確認**
   ```bash
   flutter run
   ```
   - iOS/Androidシミュレータでの動作確認
   - Hello Worldアプリが表示されることを確認

## 完了条件

- [ ] Flutterプロジェクトが正常に作成されている
- [ ] `flutter run`でデフォルトアプリが起動する
- [ ] iOS/Androidの両プラットフォームで動作する

## 注意事項

- プロジェクト名は `travue` を使用
- 作成場所は現在のディレクトリ
- デフォルトのサンプルコードはそのまま残しておく

## 関連ファイル

作成されるファイル構造:
```
travue/
├── lib/
│   └── main.dart
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```