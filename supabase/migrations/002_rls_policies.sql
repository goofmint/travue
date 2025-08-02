-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE landmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE regions ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view all profiles" ON users
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Landmarks table policies (public read, admin write)
CREATE POLICY "Everyone can view landmarks" ON landmarks
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert landmarks" ON landmarks
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update landmarks they created" ON landmarks
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Posts table policies
CREATE POLICY "Everyone can view posts" ON posts
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own posts" ON posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON posts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts" ON posts
  FOR DELETE USING (auth.uid() = user_id);

-- Guides table policies
CREATE POLICY "Everyone can view public guides" ON guides
  FOR SELECT USING (is_public = true OR auth.uid() = user_id);

CREATE POLICY "Users can insert own guides" ON guides
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own guides" ON guides
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own guides" ON guides
  FOR DELETE USING (auth.uid() = user_id);

-- Guide items table policies
CREATE POLICY "Guide items visible based on guide visibility" ON guide_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM guides g 
      WHERE g.id = guide_items.guide_id 
      AND (g.is_public = true OR g.user_id = auth.uid())
    )
  );

CREATE POLICY "Users can manage items in own guides" ON guide_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM guides g 
      WHERE g.id = guide_items.guide_id 
      AND g.user_id = auth.uid()
    )
  );

-- Regions table policies (public read, admin write)
CREATE POLICY "Everyone can view regions" ON regions
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert regions" ON regions
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update regions" ON regions
  FOR UPDATE USING (auth.role() = 'authenticated');