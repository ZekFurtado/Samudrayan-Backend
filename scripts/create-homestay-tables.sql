-- Create homestays table
CREATE TABLE IF NOT EXISTS homestays (
    id UUID PRIMARY KEY,
    owner_id TEXT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    grade VARCHAR(20) NOT NULL CHECK (grade IN ('silver', 'gold', 'diamond')),
    district VARCHAR(100) NOT NULL,
    taluka VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    amenities JSONB DEFAULT '[]',
    media JSONB DEFAULT '[]',
    sustainability_score INTEGER DEFAULT 0 CHECK (sustainability_score >= 0 AND sustainability_score <= 100),
    status VARCHAR(30) DEFAULT 'pending-verification' CHECK (status IN ('pending-verification', 'active', 'inactive', 'suspended')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(owner_id, name)
);

-- Create homestay_rooms table
CREATE TABLE IF NOT EXISTS homestay_rooms (
    id UUID PRIMARY KEY,
    homestay_id UUID NOT NULL REFERENCES homestays(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    capacity INTEGER NOT NULL DEFAULT 2 CHECK (capacity > 0),
    price_per_night DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (price_per_night >= 0),
    amenities JSONB DEFAULT '[]',
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_homestays_owner_id ON homestays(owner_id);
CREATE INDEX IF NOT EXISTS idx_homestays_district ON homestays(district);
CREATE INDEX IF NOT EXISTS idx_homestays_taluka ON homestays(taluka);
CREATE INDEX IF NOT EXISTS idx_homestays_grade ON homestays(grade);
CREATE INDEX IF NOT EXISTS idx_homestays_status ON homestays(status);
CREATE INDEX IF NOT EXISTS idx_homestays_location ON homestays(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_homestay_rooms_homestay_id ON homestay_rooms(homestay_id);

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_homestays_updated_at 
    BEFORE UPDATE ON homestays 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_homestay_rooms_updated_at 
    BEFORE UPDATE ON homestay_rooms 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();