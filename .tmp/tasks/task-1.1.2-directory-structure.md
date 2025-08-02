# Task 1.1.2 - 基本的なディレクトリ構造の設定

## 概要

Clean Architectureに基づいた基本的なディレクトリ構造を設定します。

## 作業内容

### 手順

1. **lib配下のディレクトリ作成**
   ```bash
   cd travue
   mkdir -p lib/domain
   mkdir -p lib/application
   mkdir -p lib/infrastructure
   mkdir -p lib/presentation
   ```

2. **各レイヤーのサブディレクトリ作成**
   ```bash
   # Domain Layer
   mkdir -p lib/domain/entities
   mkdir -p lib/domain/repositories
   mkdir -p lib/domain/services
   
   # Application Layer
   mkdir -p lib/application/controllers
   mkdir -p lib/application/providers
   mkdir -p lib/application/states
   
   # Infrastructure Layer
   mkdir -p lib/infrastructure/datasources
   mkdir -p lib/infrastructure/repositories
   mkdir -p lib/infrastructure/services
   
   # Presentation Layer
   mkdir -p lib/presentation/screens
   mkdir -p lib/presentation/widgets
   mkdir -p lib/presentation/routes
   ```

3. **共通ディレクトリ作成**
   ```bash
   mkdir -p lib/core/constants
   mkdir -p lib/core/errors
   mkdir -p lib/core/utils
   ```

## 完了条件

- [ ] Clean Architectureに基づいたディレクトリ構造が作成されている
- [ ] 各レイヤーのサブディレクトリが正しく配置されている
- [ ] ディレクトリ構造がプロジェクト要件に合致している

## ディレクトリ構造

作成される構造:
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   └── utils/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── services/
├── application/
│   ├── controllers/
│   ├── providers/
│   └── states/
├── infrastructure/
│   ├── datasources/
│   ├── repositories/
│   └── services/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── routes/
└── main.dart
```

## 注意事項

- Clean Architectureの原則に従った層分け
- 依存関係の方向性: Presentation → Application → Domain ← Infrastructure
- 各レイヤーの責務を明確に分離