-- Initialize PostgreSQL database for TourLeader API

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "earthdistance";
CREATE EXTENSION IF NOT EXISTS "cube";

-- Create some sample data for development

-- Sample users
INSERT INTO users (id, email, password, first_name, last_name, name, role, is_verified) VALUES
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin@tourleader.app', '$2a$10$N9qo8uLOickgx2ZMRZoMye1w.roBtP4P0Y3lNgE1.U9r1OJ.BqKa6', 'Admin', 'User', 'Admin User', 'admin', true),
    ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'john@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1w.roBtP4P0Y3lNgE1.U9r1OJ.BqKa6', 'John', 'Doe', 'John Doe', 'user', true),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'jane@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1w.roBtP4P0Y3lNgE1.U9r1OJ.BqKa6', 'Jane', 'Smith', 'Jane Smith', 'user', true);

-- Sample destinations
INSERT INTO destinations (id, name, description, long_description, country, city, latitude, longitude, image_urls, rating, review_count, price, currency, is_popular, is_featured, best_time_to_visit, activities, attractions, categories) VALUES
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Santorini', 'Beautiful Greek island with stunning sunsets', 'Santorini is a Greek island in the southern Aegean Sea, about 200 km southeast of the Greek mainland. It is the largest island of a small, circular archipelago, which bears the same name and is the remnant of a caldera.', 'Greece', 'Santorini', 36.3932, 25.4615, ARRAY['assets/images/santorini.jpg'], 4.8, 1245, 1299.99, 'USD', true, true, 'May to October', ARRAY['Sunset Viewing', 'Wine Tasting', 'Beach Activities'], ARRAY['Oia Sunset', 'Red Beach', 'Akrotiri Archaeological Site'], ARRAY['Beach', 'Culture', 'Romance']),
    
    ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Kyoto', 'Ancient capital of Japan with temples and tradition', 'Kyoto, once the capital of Japan, is a city on the island of Honshu. It is famous for its numerous classical Buddhist temples, gardens, imperial palaces, Shinto shrines and traditional wooden houses.', 'Japan', 'Kyoto', 35.0116, 135.7681, ARRAY['assets/images/kyoto.jpg'], 4.7, 987, 1899.99, 'USD', true, true, 'March to May, September to November', ARRAY['Temple Visits', 'Cherry Blossom Viewing', 'Tea Ceremony'], ARRAY['Fushimi Inari Shrine', 'Kinkaku-ji Temple', 'Arashiyama Bamboo Grove'], ARRAY['Culture', 'History', 'Temples']),
    
    ('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Bali', 'Tropical paradise with rich culture', 'Bali is an Indonesian island known for its forested volcanic mountains, iconic rice paddies, beaches and coral reefs. The island is home to religious sites such as cliffside Uluwatu Temple.', 'Indonesia', 'Bali', -8.3405, 115.0920, ARRAY['assets/images/bali.jpg'], 4.6, 2156, 899.99, 'USD', true, false, 'April to October', ARRAY['Beach Activities', 'Temple Visits', 'Cultural Tours'], ARRAY['Tanah Lot Temple', 'Ubud Rice Terraces', 'Mount Batur'], ARRAY['Beach', 'Culture', 'Adventure']),
    
    ('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Cappadocia', 'Magical landscape with hot air balloons', 'Cappadocia is a historical region in Central Anatolia, Turkey. It is famous for its unique rock formations, underground cities, and hot air balloon rides.', 'Turkey', 'Cappadocia', 38.6431, 34.8283, ARRAY['assets/images/cappadocia.jpg'], 4.9, 1876, 1199.99, 'USD', true, true, 'April to June, September to November', ARRAY['Hot Air Balloon Rides', 'Cave Exploration', 'Hiking'], ARRAY['Göreme Open Air Museum', 'Derinkuyu Underground City', 'Pasabag Valley'], ARRAY['Adventure', 'History', 'Unique']);

-- Sample hotels
INSERT INTO hotels (id, name, description, address, destination_id, latitude, longitude, rating, price_per_night, currency, amenities, star_rating, category) VALUES
    ('h0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Santorini Palace Hotel', 'Luxury hotel with caldera views', 'Oia, Santorini 84702, Greece', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 36.4618, 25.3753, 4.7, 450.00, 'USD', ARRAY['Pool', 'Spa', 'Restaurant', 'WiFi', 'Balcony'], 5, 'luxury'),
    
    ('h1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Kyoto Traditional Ryokan', 'Traditional Japanese inn experience', '123 Temple District, Kyoto, Japan', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 35.0116, 135.7681, 4.8, 280.00, 'USD', ARRAY['Traditional Baths', 'Garden View', 'Tea Service', 'WiFi'], 4, 'boutique'),
    
    ('h2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Bali Beach Resort', 'Beachfront resort with tropical gardens', 'Seminyak Beach, Bali, Indonesia', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', -8.3405, 115.0920, 4.5, 180.00, 'USD', ARRAY['Beach Access', 'Pool', 'Spa', 'Restaurant', 'WiFi'], 4, 'resort');

-- Sample tours
INSERT INTO tours (id, name, description, creator_id, total_price, currency, duration, start_date, end_date, min_participants, max_participants, share_code, status, is_public) VALUES
    ('t0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Mediterranean Adventure', 'Explore the beautiful Mediterranean coastline with stunning islands and rich history', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2599.99, 'USD', 14, '2024-06-01 00:00:00+00', '2024-06-15 00:00:00+00', 20, 50, 'MED2024A', 'active', true),
    
    ('t1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Asian Cultural Journey', 'Discover ancient temples and modern cities across Asia', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 3299.99, 'USD', 21, '2024-07-01 00:00:00+00', '2024-07-22 00:00:00+00', 15, 40, 'ASIA2024', 'active', true);

-- Sample tour destinations
INSERT INTO tour_destinations (tour_id, destination_id, order_index, days_spent) VALUES
    ('t0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 1, 7),
    ('t0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2, 7),
    ('t1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 1, 10),
    ('t1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2, 11);

-- Sample tour participants
INSERT INTO tour_participants (tour_id, user_id, status, role) VALUES
    ('t0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'joined', 'admin'),
    ('t0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'joined', 'participant'),
    ('t1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'joined', 'admin'),
    ('t1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'joined', 'participant');

-- Sample reviews
INSERT INTO reviews (id, user_id, destination_id, title, comment, rating, status, travel_type) VALUES
    ('r0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Absolutely Amazing!', 'Santorini exceeded all my expectations. The sunsets are truly magical and the hospitality is outstanding.', 5.0, 'approved', 'couple'),
    
    ('r1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Cultural Paradise', 'Kyoto is a perfect blend of ancient traditions and modern conveniences. The temples are breathtaking.', 4.8, 'approved', 'solo'),
    
    ('r2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Tropical Heaven', 'Bali offers the perfect mix of relaxation and adventure. The beaches are pristine and the culture is fascinating.', 4.6, 'approved', 'family');

-- Update destination ratings based on reviews
UPDATE destinations SET 
    rating = (SELECT AVG(rating) FROM reviews WHERE destination_id = destinations.id AND status = 'approved'),
    review_count = (SELECT COUNT(*) FROM reviews WHERE destination_id = destinations.id AND status = 'approved')
WHERE id IN ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
