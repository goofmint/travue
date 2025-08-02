-- Insert sample landmarks for Tokyo
INSERT INTO landmarks (id, name, description, location, address, category) VALUES
  (
    gen_random_uuid(),
    'Tokyo Station',
    'Major railway station and transportation hub in central Tokyo',
    ST_Point(139.7673068, 35.6809591)::geography,
    '1 Chome Marunouchi, Chiyoda City, Tokyo 100-0005, Japan',
    'transportation'
  ),
  (
    gen_random_uuid(),
    'Senso-ji Temple',
    'Ancient Buddhist temple in Asakusa, Tokyo''s oldest temple',
    ST_Point(139.7966553, 35.7148066)::geography,
    '2 Chome-3-1 Asakusa, Taito City, Tokyo 111-0032, Japan',
    'temple'
  ),
  (
    gen_random_uuid(),
    'Tokyo Skytree',
    'Broadcasting and observation tower, the tallest structure in Japan',
    ST_Point(139.8107004, 35.7100627)::geography,
    '1 Chome-1-2 Oshiage, Sumida City, Tokyo 131-0045, Japan',
    'observation'
  ),
  (
    gen_random_uuid(),
    'Shibuya Crossing',
    'Famous pedestrian crossing and one of the busiest intersections in the world',
    ST_Point(139.7005713, 35.6595211)::geography,
    'Shibuya City, Tokyo 150-0043, Japan',
    'landmark'
  ),
  (
    gen_random_uuid(),
    'Meiji Shrine',
    'Shinto shrine dedicated to Emperor Meiji and Empress Shoken',
    ST_Point(139.6993259, 35.6763976)::geography,
    '1-1 Kamizono-cho, Shibuya City, Tokyo 151-8557, Japan',
    'shrine'
  );

-- Insert sample regions
INSERT INTO regions (id, name, country_code, currency, language, timezone, safety_level) VALUES
  (
    gen_random_uuid(),
    'Japan',
    'JP',
    'JPY',
    'ja',
    'Asia/Tokyo',
    5
  ),
  (
    gen_random_uuid(),
    'United States',
    'US',
    'USD',
    'en',
    'America/New_York',
    4
  ),
  (
    gen_random_uuid(),
    'France',
    'FR',
    'EUR',
    'fr',
    'Europe/Paris',
    4
  );