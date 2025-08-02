# 詳細設計書 - 旅行ガイドブック作成・共有アプリ（Travue）

## 1. アーキテクチャ概要

### 1.1 システム構成図

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                      │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer                                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │   Screens   │ │   Widgets   │ │ Controllers │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
├─────────────────────────────────────────────────────────────┤
│  Application Layer                                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │  Use Cases  │ │   States    │ │ Providers   │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
├─────────────────────────────────────────────────────────────┤
│  Domain Layer                                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │  Entities   │ │ Repositories│ │   Services  │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
├─────────────────────────────────────────────────────────────┤
│  Infrastructure Layer                                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │ Data Sources│ │   Network   │ │Local Storage│           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Supabase Platform                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │PostgreSQL + │ │ Supabase    │ │ Supabase    │           │
│  │   PostGIS   │ │    Auth     │ │  Storage    │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 技術スタック

- **言語**: Dart 3.2+
- **フレームワーク**: Flutter 3.16+
- **状態管理**: Riverpod 2.4+
- **地図**: flutter_map 6.0+ + OpenStreetMap
- **ライブラリ一覧**:
  - `supabase_flutter`: Supabaseクライアント
  - `sqflite`: ローカルデータベース
  - `image_picker`: 写真撮影・選択
  - `cached_network_image`: 画像キャッシング
  - `geolocator`: 位置情報取得
  - `permission_handler`: 権限管理
- **ツール**: 
  - ビルド: `flutter build`
  - テスト: `flutter test`, `integration_test`
  - Linting: `flutter_lints`

## 2. コンポーネント設計

### 2.1 コンポーネント一覧

| コンポーネント名 | 責務 | 依存関係 |
|---|---|---|
| AuthenticationController | ユーザー認証管理 | Supabase Auth |
| MapController | 地図表示・操作 | flutter_map, Geolocator |
| LandmarkController | ランドマーク情報管理 | LandmarkRepository |
| PostController | 投稿管理 | PostRepository, StorageService |
| GuideController | ガイドブック管理 | GuideRepository |
| CacheManager | ローカルキャッシュ管理 | SQLite |

### 2.2 各コンポーネントの詳細

#### AuthenticationController

- **目的**: ユーザー認証フローの管理
- **公開インターフェース**:
  ```dart
  class AuthenticationController extends StateNotifier<AuthState> {
    Future<void> signInWithEmail(String email, String password);
    Future<void> signUpWithEmail(String email, String password);
    Future<void> signInWithGoogle();
    Future<void> signOut();
    User? get currentUser;
  }
  ```
- **内部実装方針**: Supabase Authとの統合、認証状態の永続化

#### MapController

- **目的**: 地図表示とランドマーク表示の制御
- **公開インターフェース**:
  ```dart
  class MapController extends StateNotifier<MapState> {
    Future<void> loadLandmarksInBounds(LatLngBounds bounds);
    void onMapReady(MapController controller);
    void onLandmarkTapped(Landmark landmark);
    void onMapTapped(LatLng position);
  }
  ```
- **内部実装方針**: flutter_map統合、PostGIS空間検索、マーカー最適化

#### LandmarkController

- **目的**: ランドマーク情報の取得・管理
- **公開インターフェース**:
  ```dart
  class LandmarkController extends StateNotifier<LandmarkState> {
    Future<List<Landmark>> searchLandmarks(String query);
    Future<Landmark?> getLandmarkById(String id);
    Future<List<Post>> getPostsForLandmark(String landmarkId);
  }
  ```
- **内部実装方針**: Wikipedia API統合、PostGIS検索、キャッシング

## 3. データフロー

### 3.1 データフロー図

```
User Action → Controller → Use Case → Repository → DataSource → Supabase
    ↓             ↓           ↓           ↓            ↓           ↓
  UI Event    State Update  Business    Data Access  Network    Database
                            Logic       Layer        Request    
```

### 3.2 主要フロー

#### 地図でランドマーク検索フロー
1. ユーザーが現在位置、または地図上の位置を選択。または検索キーワードを入力。
2. MapController が新しい範囲を検知。検索条件に利用。
3. LandmarkRepository が PostGIS で空間検索実行
4. 結果をキャッシュしつつ UI を更新

#### 投稿作成フロー
1. ユーザーが写真を撮影・選択
2. 位置情報とランドマークを関連付け
3. Supabase Storage に画像アップロード
4. PostgreSQL にメタデータ保存
5. ローカルキャッシュ更新

## 4. データベース設計

### 4.1 テーブル定義

```sql
-- ユーザー情報（Supabase Auth連携）
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ランドマーク（観光地・施設）
CREATE TABLE landmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  location GEOGRAPHY(POINT, 4326) NOT NULL,
  address TEXT,
  wikipedia_url TEXT,
  category VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 投稿（レビュー・写真・Tips）
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  landmark_id UUID REFERENCES landmarks(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  images TEXT[], -- 画像URL配列
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ガイドブック
CREATE TABLE guides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  cover_image TEXT,
  tags TEXT[], -- 対象層・テーマタグ
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ガイドブック構成要素
CREATE TABLE guide_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guide_id UUID REFERENCES guides(id) ON DELETE CASCADE,
  landmark_id UUID REFERENCES landmarks(id) ON DELETE CASCADE,
  post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
  order_index INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 地域情報
CREATE TABLE regions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(200) NOT NULL,
  country_code CHAR(2),
  currency VARCHAR(10),
  language VARCHAR(10),
  timezone VARCHAR(50),
  safety_level INTEGER CHECK (safety_level >= 1 AND safety_level <= 5),
  bounds GEOGRAPHY(POLYGON, 4326),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックス作成
CREATE INDEX idx_landmarks_location ON landmarks USING GIST (location);
CREATE INDEX idx_posts_landmark_id ON posts (landmark_id);
CREATE INDEX idx_posts_user_id ON posts (user_id);
CREATE INDEX idx_guide_items_guide_id ON guide_items (guide_id);
```

### 4.2 空間検索関数

```sql
-- 半径内ランドマーク検索
CREATE OR REPLACE FUNCTION search_landmarks_nearby(
  center_lat DOUBLE PRECISION,
  center_lng DOUBLE PRECISION,
  radius_meters INTEGER DEFAULT 1000
)
RETURNS TABLE (
  id UUID,
  name VARCHAR,
  location_lat DOUBLE PRECISION,
  location_lng DOUBLE PRECISION,
  distance_meters DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.name,
    ST_Y(l.location::geometry) as location_lat,
    ST_X(l.location::geometry) as location_lng,
    ST_Distance(l.location, ST_Point(center_lng, center_lat)::geography) as distance_meters
  FROM landmarks l
  WHERE ST_DWithin(
    l.location,
    ST_Point(center_lng, center_lat)::geography,
    radius_meters
  )
  ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;
```

## 5. API設計

### 5.1 Supabase RPC Functions

```dart
// ランドマーク検索
final response = await supabase.rpc('search_landmarks_nearby', params: {
  'center_lat': 35.6762,
  'center_lng': 139.6503,
  'radius_meters': 1000,
  'query': 'Japanese food',
  'limit': 20,
  'offset': 0,
  'sort_by': 'distance_meters',
  'sort_order': 'asc'
});

// 投稿データ取得
final posts = await supabase
  .from('posts')
  .select('*, users(username, avatar_url), landmarks(name)')
  .eq('landmark_id', landmarkId)
  .order('created_at', ascending: false);
```

### 5.2 内部API（Repository パターン）

```dart
abstract class LandmarkRepository {
  Future<List<Landmark>> searchNearby(LatLng center, double radiusKm);
  Future<Landmark?> findById(String id);
  Future<List<Landmark>> searchByName(String query);
}

abstract class PostRepository {
  Future<List<Post>> getPostsForLandmark(String landmarkId);
  Future<String> createPost(CreatePostRequest request);
  Future<void> uploadImages(String postId, List<File> images);
}

abstract class GuideRepository {
  Future<List<Guide>> getPublicGuides({String? tag});
  Future<Guide?> findById(String id);
  Future<String> createGuide(CreateGuideRequest request);
  Future<void> addItemToGuide(String guideId, GuideItem item);
}
```

## 6. UI/UX設計

### 6.1 画面構成

```dart
// ナビゲーション構造
class AppRouter {
  static final routes = [
    '/': () => const HomeScreen(),
    '/map': () => const MapScreen(),
    '/landmark/:id': (id) => LandmarkDetailScreen(landmarkId: id),
    '/post/create': () => const CreatePostScreen(),
    '/guide/create': () => const CreateGuideScreen(),
    '/guide/:id': (id) => GuideDetailScreen(guideId: id),
    '/profile': () => const ProfileScreen(),
  ];
}
```

### 6.2 主要Widget設計

```dart
// 地図画面のメインWidget
class MapScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapControllerProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: mapState.center,
              zoom: mapState.zoom,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  ref.read(mapControllerProvider.notifier)
                    .onMapMoved(position);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: mapState.landmarks.map((landmark) => 
                  LandmarkMarker(landmark: landmark)
                ).toList(),
              ),
            ],
          ),
          LandmarkListPanel(landmarks: mapState.landmarks),
          SearchOverlay(),
        ],
      ),
    );
  }
}
```

## 7. テスト戦略

### 7.1 単体テスト

- **カバレッジ目標**: 80%以上
- **禁止事項**: モック利用、テストのスキップ
- **テストフレームワーク**: Flutter Test
- **テスト対象**:
  ```dart
  // Controller のテスト例
  void main() {
    group('LandmarkController', () {
      test('should load landmarks when map bounds change', () async {
        // Arrange
        final mockRepository = MockLandmarkRepository();
        final controller = LandmarkController(mockRepository);
        
        // Act
        await controller.loadLandmarksInBounds(testBounds);
        
        // Assert
        verify(mockRepository.searchNearby(any, any)).called(1);
        expect(controller.state.landmarks, isNotEmpty);
      });
    });
  }
  ```

### 7.2 統合テスト

- **E2Eシナリオ**:
  1. ユーザー登録→ログイン
  2. 地図でランドマーク検索
  3. 投稿作成（写真付き）
  4. ガイドブック作成・公開
  5. 他ユーザーのガイドブック閲覧・コメント
  6. 他のユーザーをフォロー・フォロワー管理

## 8. パフォーマンス最適化

### 8.1 想定される負荷

- 地図上のマーカー: 最大200個まで表示
- 画像: 1枚あたり10MB以下
- キャッシュ: ローカルに最大500MB

### 8.2 最適化方針

```dart
// 画像の最適化
class ImageOptimizer {
  static Future<File> compressImage(File image) async {
    final bytes = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      quality: 85,
      minWidth: 1920,
      minHeight: 1080,
    );
    return File('${image.path}_compressed')..writeAsBytesSync(bytes!);
  }
}

// マーカーのクラスタリング
class MarkerClusterer {
  List<Marker> clusterMarkers(List<Landmark> landmarks, double zoom) {
    if (zoom > 15) return landmarks.map(createMarker).toList();
    
    // クラスタリングロジック
    return clusteredMarkers;
  }
}
```

## 9. セキュリティ設計

### 9.1 認証・認可

```sql
-- Row Level Security (RLS) ポリシー
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all posts" ON posts
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own posts" ON posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON posts
  FOR UPDATE USING (auth.uid() = user_id);
```

### 9.2 データ保護

- 画像アップロード時のファイルサイズ・形式チェック
- SQL インジェクション対策（Supabase の prepared statement）
- XSS 対策（入力値のサニタイズ）

## 10. エラーハンドリング

### 10.1 エラー分類

```dart
abstract class AppError {
  String get message;
}

class NetworkError extends AppError {
  final String message;
  NetworkError(this.message);
}

class AuthenticationError extends AppError {
  final String message;
  AuthenticationError(this.message);
}

class ValidationError extends AppError {
  final String field;
  final String message;
  ValidationError(this.field, this.message);
}
```

### 10.2 エラー通知

```dart
class ErrorHandler {
  static void handleError(AppError error, BuildContext context) {
    String message = error.message;
    
    switch (error.runtimeType) {
      case NetworkError:
        message = 'Network error occurred: ${error.message}';
        break;
      case AuthenticationError:
        message = 'Authentication failed: ${error.message}';
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

## 11. デプロイメント

### 11.1 ビルド設定

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/

# Android設定
android {
  compileSdkVersion 34
  defaultConfig {
    minSdkVersion 21
    targetSdkVersion 34
  }
}

# iOS設定
ios:
  deployment_target: '13.0'
```

### 11.2 環境設定

```dart
// 環境別設定
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
}
```

## 12. 実装上の注意事項

- **地理空間データ**: PostGIS のクエリは適切なインデックスを使用
- **画像処理**: メモリリークを避けるため適切な dispose
- **キャッシング**: ローカルストレージの容量制限を考慮
- **権限管理**: カメラ・位置情報、プッシュ通知の権限リクエスト処理
- **オフライン対応**: 重要なデータのローカルキャッシュ

## 13. 開発フェーズ

### Phase 1: 基盤実装（2週間）
- Flutter プロジェクト作成
- Supabase 接続設定
- 認証機能実装

### Phase 2: 地図・ランドマーク（3週間）
- flutter_map 統合
- ランドマーク表示・検索
- PostGIS 空間検索

### Phase 3: 投稿機能（3週間）
- 写真撮影・アップロード
- 投稿作成・表示
- ランドマーク詳細画面

### Phase 4: ガイドブック（4週間）
- ガイドブック作成・編集
- 公開・共有機能
- プロフィール画面
