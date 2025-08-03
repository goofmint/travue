# Task 1.4: Row Level Security (RLS) 設定

## 概要

Supabaseデータベースの各テーブルに対してRow Level Security (RLS) ポリシーを設定し、ユーザーが適切な権限でのみデータにアクセスできるようにセキュリティ基盤を構築します。

## 目標

- [ ] 各テーブルのRLSポリシー作成

## 実装内容

### 1. RLSポリシーの設計

各テーブルに対してセキュリティポリシーを設計し、実装します。

### 1.1 users テーブル

```sql
-- ユーザー自身のプロフィールのみ参照・更新可能
CREATE POLICY "Users can view own profile" ON users 
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users 
  FOR UPDATE USING (auth.uid() = id);
```

### 1.2 landmarks テーブル

```sql
-- 全ての認証済みユーザーが参照可能
CREATE POLICY "Authenticated users can view landmarks" ON landmarks 
  FOR SELECT TO authenticated USING (true);

-- 管理者のみ作成・更新・削除可能（将来的な拡張）
CREATE POLICY "Admins can manage landmarks" ON landmarks 
  FOR ALL TO authenticated USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );
```

### 1.3 posts テーブル

```sql
-- 公開投稿は全ユーザーが参照可能
CREATE POLICY "Anyone can view public posts" ON posts 
  FOR SELECT USING (is_public = true);

-- 投稿者は自分の投稿を全て参照可能
CREATE POLICY "Users can view own posts" ON posts 
  FOR SELECT USING (auth.uid() = user_id);

-- 認証済みユーザーのみ投稿作成可能
CREATE POLICY "Authenticated users can create posts" ON posts 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- 投稿者のみ自分の投稿を更新・削除可能
CREATE POLICY "Users can update own posts" ON posts 
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts" ON posts 
  FOR DELETE USING (auth.uid() = user_id);
```

### 1.4 guides テーブル

```sql
-- 公開ガイドは全ユーザーが参照可能
CREATE POLICY "Anyone can view public guides" ON guides 
  FOR SELECT USING (is_public = true);

-- 作成者は自分のガイドを全て参照可能
CREATE POLICY "Users can view own guides" ON guides 
  FOR SELECT USING (auth.uid() = user_id);

-- 認証済みユーザーのみガイド作成可能
CREATE POLICY "Authenticated users can create guides" ON guides 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- 作成者のみ自分のガイドを更新・削除可能
CREATE POLICY "Users can update own guides" ON guides 
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own guides" ON guides 
  FOR DELETE USING (auth.uid() = user_id);
```

### 1.5 guide_items テーブル

```sql
-- ガイド作成者のみガイドアイテムを管理可能
CREATE POLICY "Guide owners can manage guide items" ON guide_items 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM guides 
      WHERE guides.id = guide_items.guide_id 
      AND guides.user_id = auth.uid()
    )
  );

-- 公開ガイドのアイテムは全ユーザーが参照可能
CREATE POLICY "Anyone can view public guide items" ON guide_items 
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM guides 
      WHERE guides.id = guide_items.guide_id 
      AND guides.is_public = true
    )
  );
```

### 1.6 comments テーブル

```sql
-- 対象投稿/ガイドが公開されている場合、コメントも参照可能
CREATE POLICY "Anyone can view public comments" ON comments 
  FOR SELECT USING (
    (target_type = 'post' AND EXISTS (
      SELECT 1 FROM posts 
      WHERE posts.id = target_id 
      AND posts.is_public = true
    )) OR
    (target_type = 'guide' AND EXISTS (
      SELECT 1 FROM guides 
      WHERE guides.id = target_id 
      AND guides.is_public = true
    ))
  );

-- 認証済みユーザーのみコメント作成可能
CREATE POLICY "Authenticated users can create comments" ON comments 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- コメント作成者のみ自分のコメントを更新・削除可能
CREATE POLICY "Users can update own comments" ON comments 
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments" ON comments 
  FOR DELETE USING (auth.uid() = user_id);
```

### 1.7 likes テーブル

```sql
-- 自分のいいねのみ参照・管理可能
CREATE POLICY "Users can manage own likes" ON likes 
  FOR ALL USING (auth.uid() = user_id);

-- 公開投稿/ガイドのいいね数は集計可能（Supabaseの集計関数経由）
```

### 2. RLS有効化

各テーブルでRLSを有効化します：

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE landmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
```

### 3. セキュリティテスト実装

#### 3.1 テスト用データ作成

```dart
// test/security/rls_test_helper.dart
class RLSTestHelper {
  static Future<void> createTestUsers() async {
    // テスト用ユーザーの作成
  }
  
  static Future<void> createTestData() async {
    // テスト用投稿、ガイドの作成
  }
  
  static Future<void> cleanupTestData() async {
    // テストデータのクリーンアップ
  }
}
```

#### 3.2 権限テスト

```dart
// test/security/rls_security_test.dart
void main() {
  group('RLS Security Tests', () {
    testWidgets('users can only access their own profile', (tester) async {
      // ユーザーが自分のプロフィールのみアクセス可能か確認
    });
    
    testWidgets('posts visibility follows privacy settings', (tester) async {
      // 投稿の公開/非公開設定が正しく機能するか確認
    });
    
    testWidgets('guide ownership is properly enforced', (tester) async {
      // ガイドの所有権が適切に管理されているか確認
    });
  });
}
```

## 技術要件

### セキュリティ原則

1. **最小権限の原則**: ユーザーは必要最小限のデータにのみアクセス可能
2. **明示的な権限**: 全ての操作に明示的な権限チェックを実装
3. **認証の必須化**: 機密データへのアクセスには認証を必須とする
4. **データ分離**: ユーザー間のデータは適切に分離する

### 実装アプローチ

1. Supabase Dashboard でのポリシー作成
2. SQLファイルでのポリシー管理
3. Flutter側での権限チェック（フェイルセーフ）
4. 自動テストでの権限検証

## 完了条件

- [ ] 各テーブルのRLSポリシー作成

## 依存関係

- Task 1.3 (データベーススキーマ実装) の完了が必要
- Supabaseプロジェクトの認証設定

## 推定作業時間

- RLSポリシー設計・実装: 2時間
- セキュリティテスト実装: 1時間

**合計: 3時間**

## 注意点

- RLSポリシーは慎重に設計し、段階的にテストする
- 性能に影響を与える可能性があるため、クエリ最適化も考慮する
- セキュリティホールを避けるため、全てのアクセスパターンをテストする
- 将来的な機能拡張を考慮した柔軟なポリシー設計を行う