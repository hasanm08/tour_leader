-- Drop all tables in reverse order (considering foreign key dependencies)

DROP TABLE IF EXISTS user_badges;
DROP TABLE IF EXISTS badges;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS chat_participants;
DROP TABLE IF EXISTS chat_rooms;
DROP TABLE IF EXISTS review_helpful;
DROP TABLE IF EXISTS hotel_reviews;
DROP TABLE IF EXISTS hotel_bookings;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS itinerary_items;
DROP TABLE IF EXISTS tour_participants;
DROP TABLE IF EXISTS tour_destinations;
DROP TABLE IF EXISTS tours;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS hotels;
DROP TABLE IF EXISTS destinations;
DROP TABLE IF EXISTS users;

-- Drop extensions (optional, might be used by other databases)
-- DROP EXTENSION IF EXISTS "earthdistance";
-- DROP EXTENSION IF EXISTS "cube";
-- DROP EXTENSION IF EXISTS "uuid-ossp";
