-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE landmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- Users table policies
-- Users can only view and update their own profile
CREATE POLICY "Users can view own profile" ON users 
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users 
  FOR UPDATE USING (auth.uid() = id);

-- Landmarks table policies
-- All authenticated users can view landmarks
CREATE POLICY "Authenticated users can view landmarks" ON landmarks 
  FOR SELECT TO authenticated USING (true);

-- Only admins can manage landmarks (future feature)
CREATE POLICY "Admins can manage landmarks" ON landmarks 
  FOR ALL TO authenticated USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );

-- Posts table policies
-- Public posts are viewable by everyone
CREATE POLICY "Anyone can view public posts" ON posts 
  FOR SELECT USING (is_public = true);

-- Users can view their own posts
CREATE POLICY "Users can view own posts" ON posts 
  FOR SELECT USING (auth.uid() = user_id);

-- Authenticated users can create posts
CREATE POLICY "Authenticated users can create posts" ON posts 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Users can update their own posts only
CREATE POLICY "Users can update own posts" ON posts
  FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete own posts" ON posts 
  FOR DELETE USING (auth.uid() = user_id);

-- Guides table policies
-- Public guides are viewable by everyone
CREATE POLICY "Anyone can view public guides" ON guides 
  FOR SELECT USING (is_public = true);

-- Users can view their own guides
CREATE POLICY "Users can view own guides" ON guides 
  FOR SELECT USING (auth.uid() = user_id);

-- Authenticated users can create guides
CREATE POLICY "Authenticated users can create guides" ON guides 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Users can update their own guides only
CREATE POLICY "Users can update own guides" ON guides
  FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own guides
CREATE POLICY "Users can delete own guides" ON guides 
  FOR DELETE USING (auth.uid() = user_id);

-- Guide items table policies
-- Guide owners can manage guide items
CREATE POLICY "Guide owners can manage guide items" ON guide_items 
  FOR ALL 
    USING (
      EXISTS (
        SELECT 1 FROM guides 
        WHERE guides.id = guide_items.guide_id 
        AND guides.user_id = auth.uid()
      )
    )
    WITH CHECK (
      EXISTS (
        SELECT 1 FROM guides 
        WHERE guides.id = guide_items.guide_id 
        AND guides.user_id = auth.uid()
      )
    );

-- Public guide items are viewable by everyone
CREATE POLICY "Anyone can view public guide items" ON guide_items 
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM guides 
      WHERE guides.id = guide_items.guide_id 
      AND guides.is_public = true
    )
  );

-- Comments table policies
-- Comments on public posts/guides are viewable by everyone
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

-- Authenticated users can create comments
CREATE POLICY "Authenticated users can create comments" ON comments 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Users can update their own comments only
CREATE POLICY "Users can update own comments" ON comments
  FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own comments
CREATE POLICY "Users can delete own comments" ON comments 
  FOR DELETE USING (auth.uid() = user_id);

-- Likes table policies
-- Users can only manage their own likes
CREATE POLICY "Users can manage own likes" ON likes 
  FOR ALL USING (auth.uid() = user_id);