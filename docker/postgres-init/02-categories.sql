-- Create categories table for tourism categories
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_name VARCHAR(255) NOT NULL,
  subcategories JSONB,
  benefits VARCHAR(1000),
  type VARCHAR(50) NOT NULL DEFAULT 'tourism', -- tourism, homestay, marketplace
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_categories_type ON categories(type);
CREATE INDEX IF NOT EXISTS idx_categories_active ON categories(is_active);

-- Insert tourism categories from the specifications
INSERT INTO categories (category_name, subcategories, benefits, type) VALUES
('Accommodation', '["Homestays", "Lodging", "Hotels", "Resorts", "Hostels (Solo-friendly hostels)", "Beach-Front Properties", "Spiritual and Wellness Stays", "Eco-lodges and Treehouses"]', 'Comfortable stays for all budgets; authentic Konkan hospitality; solo & family-friendly', 'tourism'),
('Food & Culinary', '["Local seafood", "Konkani thalis", "Alphonso mango dishes", "beach shacks", "vegetarian options", "Village food experience", "Coastal Cafe"]', 'Authentic coastal flavours, fresh produce, unique Konkani cuisine', 'tourism'),
('Unique Experiences', '["Bungy Jumping (proposed)", "Coastal Zipline", "FlyingFish Scuba", "Fish Cooking Workshops"]', 'High-thrill adventures, water exploration, rare adrenaline activities in Konkan', 'tourism'),
('Water Sports', '["White Water Rafting (Kolad side – accessible)", "Jet Ski", "Banana Ride", "Parasailing (Ganpatipule/Malvan access)", "Snorkling", "Kayaking & Canoying"]', 'Fun beach activities, great for families & groups', 'tourism'),
('Nautical Tours', '["Konkan Explorers (Nautical Tours – Ratnagiri/Goa route)", "Dolphin Safari", "Island Tours", "Yacht and Boat Tours", "Lighthouse Eco-Tours", "Maritime Heritage Experience", "Coastal Biodiversity Trails"]', 'Scenic coastal cruising, dolphin spotting, photography experiences', 'tourism'),
('Tours & Sightseeing', '["Hop On Hop Off Ratnagiri (museum circuit + beaches)", "Guided city tours", "Heritage walks", "City Heritage Circuits", "Village Tourism Circuit", "Coastal Temple Circuit", "Mango Tourism Circuit"]', 'Easy, flexible sightseeing covering major attractions', 'tourism'),
('Trekking & Hiking', '["Indiahikes Treks (Konkan + Sahyadri)", "Kasheli Ghats", "Kashedi Ghat", "Sada Trek"]', 'Beautiful mountain views, jungle trails, beginner to advanced options', 'tourism'),
('Wildlife & Nature', '["Velas Turtle Festival", "Jaigad Lighthouse eco-trail", "Karnala (nearby)", "birdwatching points", "Bioluminescence Tours"]', 'Turtle conservation, walking trails, wildlife photography', 'tourism'),
('Heritage & Forts', '["Ratnadurg Fort", "Jaigad Fort", "Kanakaditya Temple", "Thiba Palace"]', 'History, architecture, sea-facing forts, cultural heritage', 'tourism'),
('Museums & Aquariums', '["Tilak Ali Museum", "Marine Aquarium (proposed)", "Thiba Palace Museum"]', 'Cultural stories, marine knowledge, family-friendly', 'tourism'),
('Agro-tourism', '["Alphonso Mango Farms", "Cashew farms", "Coconut plantations"]', 'Seasonal activities, farm stays, plantation tours', 'tourism'),
('Beaches & Nature', '["Ganpatipule Beach", "Aare-Ware Beach", "Guhagar", "Mandvi", "Bhatye", "Pawas coastline", "Creeks & Backwaters", "Mangrove Zones", "Viewpoints/Sunsets", "Picnic Spots", "Nature Trails"]', 'Pristine beaches, sunsets, clean shores, picnic spots', 'tourism'),
('Local Markets', '["Ratnagiri Market", "Pawas market", "Guhagar market"]', 'Fresh produce, Konkani spices, handicrafts, fish markets', 'tourism'),
('Local Products (Fresh)', '["Alphonso mango", "Kokum", "Cashew", "Fish", "Amla", "Rice varieties", "Handicrafts"]', 'Take-home authentic Konkan products, fresh & organic', 'tourism'),
('Solo Traveler Activities', '["Hostels", "Fort treks", "Beach cafés", "Cycling routes"]', 'Safe, budget-friendly, scenic solo exploration', 'tourism'),
('Welness and holistic tourisam', '["Ayurveda Wellness Centres", "Panchakarma retreats", "Beach yoga", "Forest meditation", "Nature therapy trails", "Naturopathy resorts (proposed under Samudrayan)"]', 'Holistic health and wellness experiences', 'tourism'),
('Other Events /Festivals', '["Velas Turtle Festival", "Ganpatipule temple festival", "Mango festivals", "Beach festivals", "Youth coastal sports festival (proposed)", "Coastal cultural carnival (Samudrayan flagship event)"]', 'Cultural celebrations and community events', 'tourism'),
('Blue Green economy and livlihoods', '["Fisheries livelihood demonstrations", "Boat making experience", "Fish processing units visit", "Women SHG livelihood tours", "Coir & coconut craft industries", "Climate resilience projects", "Sustainable coastal village models"]', 'Sustainable livelihood and economic development experiences', 'tourism'),
('Climate and sustainability tourisam', '["Mangrove conservation", "Beach clean-up volunteering", "Carbon-neutral village experiences", "Renewable energy tourism sites", "Disaster management village model", "SDG Tourism Village (pilot under Samudrayan)"]', 'Environmental conservation and sustainable tourism experiences', 'tourism'),
('Digital and smart tourisam', '["AR-based fort history", "Virtual museum", "Digital tourism maps", "Smart QR-coded tourism circuits", "Tourist mobile app", "Interactive coastal dashboards", "Coastal drone views (licensed)"]', 'Technology-enhanced tourism experiences', 'tourism');

-- Insert homestay categories
INSERT INTO categories (category_name, subcategories, benefits, type) VALUES
('Homestay Grades', '["silver", "gold", "diamond"]', 'Quality classification system for homestays', 'homestay');

-- Insert marketplace categories  
INSERT INTO categories (category_name, subcategories, benefits, type) VALUES
('Marketplace Products', '["seafood", "spices", "handicrafts", "coastal-cuisine"]', 'Local products and crafts from coastal communities', 'marketplace');