-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Users table (extends Supabase Auth)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Landmarks table (tourist spots and facilities)
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

-- Posts table (reviews, photos, tips)
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  landmark_id UUID REFERENCES landmarks(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  images TEXT[], -- Array of image URLs
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Guides table (guidebooks)
CREATE TABLE guides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  cover_image TEXT,
  tags TEXT[], -- Target audience and theme tags
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Guide items table (guidebook composition)
CREATE TABLE guide_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guide_id UUID REFERENCES guides(id) ON DELETE CASCADE,
  landmark_id UUID REFERENCES landmarks(id) ON DELETE CASCADE,
  post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
  order_index INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Regions table (regional information)
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

-- Create indexes for better performance
CREATE INDEX idx_landmarks_location ON landmarks USING GIST (location);
CREATE INDEX idx_posts_landmark_id ON posts (landmark_id);
CREATE INDEX idx_posts_user_id ON posts (user_id);
CREATE INDEX idx_guide_items_guide_id ON guide_items (guide_id);
CREATE INDEX idx_guides_user_id ON guides (user_id);
CREATE INDEX idx_guides_is_public ON guides (is_public);

-- Spatial search function for nearby landmarks
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

-- Function to get posts with landmark and user information
CREATE OR REPLACE FUNCTION get_posts_for_landmark(landmark_uuid UUID)
RETURNS TABLE (
  id UUID,
  title VARCHAR,
  content TEXT,
  images TEXT[],
  rating INTEGER,
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE,
  user_id UUID,
  username VARCHAR,
  display_name VARCHAR,
  avatar_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.title,
    p.content,
    p.images,
    p.rating,
    p.tags,
    p.created_at,
    u.id as user_id,
    u.username,
    u.display_name,
    u.avatar_url
  FROM posts p
  JOIN users u ON p.user_id = u.id
  WHERE p.landmark_id = landmark_uuid
  ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;