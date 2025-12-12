-- Create districts table
CREATE TABLE IF NOT EXISTS districts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    state VARCHAR(50) NOT NULL DEFAULT 'Maharashtra',
    district_code VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create talukas table
CREATE TABLE IF NOT EXISTS talukas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    taluka_code VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(district_id, name)
);

-- Create blocks table (development blocks/panchayat samitis)
CREATE TABLE IF NOT EXISTS blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    taluka_id UUID NOT NULL REFERENCES talukas(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    block_code VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(taluka_id, name)
);

-- Create cities table (urban areas)
CREATE TABLE IF NOT EXISTS cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE CASCADE,
    taluka_id UUID NOT NULL REFERENCES talukas(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    city_type VARCHAR(20) CHECK (city_type IN ('municipal_corporation', 'municipal_council', 'nagar_panchayat', 'census_town')),
    population INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(taluka_id, name)
);

-- Create villages table
CREATE TABLE IF NOT EXISTS villages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    taluka_id UUID NOT NULL REFERENCES talukas(id) ON DELETE CASCADE,
    block_id UUID REFERENCES blocks(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    village_code VARCHAR(15),
    population INTEGER,
    is_coastal BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(taluka_id, name)
);

-- Create gram panchayats table
CREATE TABLE IF NOT EXISTS gram_panchayats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    block_id UUID NOT NULL REFERENCES blocks(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    gp_code VARCHAR(15),
    headquarters_village VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(block_id, name)
);

-- Create village_gram_panchayat mapping table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS village_gram_panchayat (
    village_id UUID NOT NULL REFERENCES villages(id) ON DELETE CASCADE,
    gram_panchayat_id UUID NOT NULL REFERENCES gram_panchayats(id) ON DELETE CASCADE,
    PRIMARY KEY (village_id, gram_panchayat_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_districts_name ON districts(name);
CREATE INDEX IF NOT EXISTS idx_districts_active ON districts(is_active);
CREATE INDEX IF NOT EXISTS idx_talukas_district_id ON talukas(district_id);
CREATE INDEX IF NOT EXISTS idx_talukas_name ON talukas(name);
CREATE INDEX IF NOT EXISTS idx_talukas_active ON talukas(is_active);
CREATE INDEX IF NOT EXISTS idx_blocks_taluka_id ON blocks(taluka_id);
CREATE INDEX IF NOT EXISTS idx_blocks_active ON blocks(is_active);
CREATE INDEX IF NOT EXISTS idx_cities_district_id ON cities(district_id);
CREATE INDEX IF NOT EXISTS idx_cities_taluka_id ON cities(taluka_id);
CREATE INDEX IF NOT EXISTS idx_cities_active ON cities(is_active);
CREATE INDEX IF NOT EXISTS idx_villages_taluka_id ON villages(taluka_id);
CREATE INDEX IF NOT EXISTS idx_villages_block_id ON villages(block_id);
CREATE INDEX IF NOT EXISTS idx_villages_active ON villages(is_active);
CREATE INDEX IF NOT EXISTS idx_villages_coastal ON villages(is_coastal);
CREATE INDEX IF NOT EXISTS idx_gram_panchayats_block_id ON gram_panchayats(block_id);
CREATE INDEX IF NOT EXISTS idx_gram_panchayats_active ON gram_panchayats(is_active);

-- Insert all Konkan districts
INSERT INTO districts (name, district_code) VALUES 
    ('Ratnagiri', 'RTG'),
    ('Sindhudurg', 'SND'),
    ('Thane', 'THN'),
    ('Mumbai City', 'MBC'),
    ('Mumbai Suburban', 'MBS'),
    ('Raigad', 'RGD')
ON CONFLICT (name) DO NOTHING;

-- Insert talukas for Ratnagiri district
INSERT INTO talukas (district_id, name, taluka_code) 
SELECT d.id, t.name, t.code
FROM districts d
CROSS JOIN (VALUES 
    ('Ratnagiri', 'RTG1'),
    ('Dapoli', 'RTG2'),
    ('Guhagar', 'RTG3'),
    ('Chiplun', 'RTG4'),
    ('Mandangad', 'RTG5'),
    ('Lanja', 'RTG6'),
    ('Sangameshwar', 'RTG7'),
    ('Ganpatipule', 'RTG8')
) t(name, code)
WHERE d.name = 'Ratnagiri'
ON CONFLICT (district_id, name) DO NOTHING;

-- Insert talukas for Sindhudurg district
INSERT INTO talukas (district_id, name, taluka_code)
SELECT d.id, t.name, t.code
FROM districts d
CROSS JOIN (VALUES
    ('Kudal', 'SND1'),
    ('Sawantwadi', 'SND2'),
    ('Dodamarg', 'SND3'),
    ('Kankavli', 'SND4'),
    ('Malvan', 'SND5'),
    ('Devgad', 'SND6'),
    ('Vengurla', 'SND7')
) t(name, code)
WHERE d.name = 'Sindhudurg'
ON CONFLICT (district_id, name) DO NOTHING;

-- Insert talukas for Thane district (coastal parts)
INSERT INTO talukas (district_id, name, taluka_code)
SELECT d.id, t.name, t.code
FROM districts d
CROSS JOIN (VALUES
    ('Thane', 'THN1'),
    ('Kalyan', 'THN2'),
    ('Ulhasnagar', 'THN3'),
    ('Ambarnath', 'THN4'),
    ('Badlapur', 'THN5'),
    ('Murbad', 'THN6'),
    ('Bhiwandi', 'THN7'),
    ('Shahapur', 'THN8'),
    ('Dahanu', 'THN9'),
    ('Talasari', 'THN10'),
    ('Palghar', 'THN11'),
    ('Vasai', 'THN12'),
    ('Nalasopara', 'THN13')
) t(name, code)
WHERE d.name = 'Thane'
ON CONFLICT (district_id, name) DO NOTHING;

-- Insert talukas for Mumbai City
INSERT INTO talukas (district_id, name, taluka_code)
SELECT d.id, t.name, t.code
FROM districts d
CROSS JOIN (VALUES
    ('Mumbai City', 'MBC1')
) t(name, code)
WHERE d.name = 'Mumbai City'
ON CONFLICT (district_id, name) DO NOTHING;

-- Insert talukas for Mumbai Suburban
INSERT INTO talukas (district_id, name, taluka_code)
SELECT d.id, t.name, t.code
FROM districts d
CROSS JOIN (VALUES
    ('Andheri', 'MBS1'),
    ('Borivali', 'MBS2'),
    ('Kurla', 'MBS3')
) t(name, code)
WHERE d.name = 'Mumbai Suburban'
ON CONFLICT (district_id, name) DO NOTHING;

-- Insert talukas for Raigad district
INSERT INTO talukas (district_id, name, taluka_code)
SELECT d.id, t.name, t.code
FROM districts d
CROSS JOIN (VALUES
    ('Alibag', 'RGD1'),
    ('Murud', 'RGD2'),
    ('Shrivardhan', 'RGD3'),
    ('Mahad', 'RGD4'),
    ('Poladpur', 'RGD5'),
    ('Sudhagad', 'RGD6'),
    ('Mhasla', 'RGD7'),
    ('Mangaon', 'RGD8'),
    ('Tala', 'RGD9'),
    ('Roha', 'RGD10'),
    ('Nagothane', 'RGD11'),
    ('Pen', 'RGD12'),
    ('Khalapur', 'RGD13'),
    ('Karjat', 'RGD14'),
    ('Panvel', 'RGD15'),
    ('Uran', 'RGD16')
) t(name, code)
WHERE d.name = 'Raigad'
ON CONFLICT (district_id, name) DO NOTHING;

-- Insert blocks for key talukas in Ratnagiri
INSERT INTO blocks (taluka_id, name, block_code)
SELECT t.id, b.name, b.code
FROM talukas t
INNER JOIN districts d ON t.district_id = d.id
CROSS JOIN (VALUES
    ('Ratnagiri', 'RTGB1'),
    ('Dapoli', 'RTGB2'),
    ('Guhagar', 'RTGB3'),
    ('Chiplun', 'RTGB4')
) b(name, code)
WHERE d.name = 'Ratnagiri' AND t.name = b.name
ON CONFLICT (taluka_id, name) DO NOTHING;

-- Insert blocks for key talukas in Sindhudurg
INSERT INTO blocks (taluka_id, name, block_code)
SELECT t.id, b.name, b.code
FROM talukas t
INNER JOIN districts d ON t.district_id = d.id
CROSS JOIN (VALUES
    ('Kudal', 'SNDB1'),
    ('Sawantwadi', 'SNDB2'),
    ('Kankavli', 'SNDB3'),
    ('Malvan', 'SNDB4')
) b(name, code)
WHERE d.name = 'Sindhudurg' AND t.name = b.name
ON CONFLICT (taluka_id, name) DO NOTHING;

-- Insert major coastal cities in Ratnagiri
INSERT INTO cities (district_id, taluka_id, name, city_type, population)
SELECT d.id, t.id, c.name, c.type, c.population
FROM districts d
INNER JOIN talukas t ON d.id = t.district_id
CROSS JOIN (VALUES
    ('Ratnagiri', 'Ratnagiri', 'municipal_council', 76062),
    ('Chiplun', 'Chiplun', 'municipal_council', 70655),
    ('Dapoli', 'Dapoli', 'nagar_panchayat', 8298),
    ('Guhagar', 'Guhagar', 'nagar_panchayat', 6747)
) c(taluka_name, name, type, population)
WHERE d.name = 'Ratnagiri' AND t.name = c.taluka_name
ON CONFLICT (taluka_id, name) DO NOTHING;

-- Insert major coastal cities in Sindhudurg
INSERT INTO cities (district_id, taluka_id, name, city_type, population)
SELECT d.id, t.id, c.name, c.type, c.population
FROM districts d
INNER JOIN talukas t ON d.id = t.district_id
CROSS JOIN (VALUES
    ('Kudal', 'Kudal', 'municipal_council', 42746),
    ('Sawantwadi', 'Sawantwadi', 'municipal_council', 28690),
    ('Malvan', 'Malvan', 'nagar_panchayat', 15881),
    ('Vengurla', 'Vengurla', 'nagar_panchayat', 12236)
) c(taluka_name, name, type, population)
WHERE d.name = 'Sindhudurg' AND t.name = c.taluka_name
ON CONFLICT (taluka_id, name) DO NOTHING;

-- Insert sample coastal villages in Ratnagiri
INSERT INTO villages (taluka_id, name, village_code, is_coastal, population)
SELECT t.id, v.name, v.code, v.is_coastal, v.population
FROM talukas t
INNER JOIN districts d ON t.district_id = d.id
CROSS JOIN (VALUES
    ('Dapoli', 'Murud', 'DPL001', true, 3245),
    ('Dapoli', 'Harnai', 'DPL002', true, 4156),
    ('Dapoli', 'Anjarle', 'DPL003', true, 2187),
    ('Dapoli', 'Kelshi', 'DPL004', true, 1456),
    ('Dapoli', 'Ladghar', 'DPL005', true, 998),
    ('Guhagar', 'Guhagar', 'GUH001', true, 6747),
    ('Guhagar', 'Velas', 'GUH002', true, 1876),
    ('Guhagar', 'Hedvi', 'GUH003', true, 2134),
    ('Ratnagiri', 'Ganpatipule', 'RTN001', true, 1456),
    ('Ratnagiri', 'Pawas', 'RTN002', true, 2876),
    ('Ratnagiri', 'Rajapur', 'RTN003', true, 3245),
    ('Ratnagiri', 'Bhatye', 'RTN004', true, 2187),
    ('Mandangad', 'Aravali', 'MND001', true, 1823),
    ('Mandangad', 'Kondivli', 'MND002', true, 2456),
    ('Lanja', 'Lanja', 'LNJ001', false, 4567),
    ('Sangameshwar', 'Marleshwar', 'SGM001', false, 3456)
) v(taluka_name, name, code, is_coastal, population)
WHERE d.name = 'Ratnagiri' AND t.name = v.taluka_name
ON CONFLICT (taluka_id, name) DO NOTHING;

-- Insert sample coastal villages in Sindhudurg
INSERT INTO villages (taluka_id, name, village_code, is_coastal, population)
SELECT t.id, v.name, v.code, v.is_coastal, v.population
FROM talukas t
INNER JOIN districts d ON t.district_id = d.id
CROSS JOIN (VALUES
    ('Malvan', 'Malvan', 'MLV001', true, 15881),
    ('Malvan', 'Tarkarli', 'MLV002', true, 4567),
    ('Malvan', 'Devbag', 'MLV003', true, 2134),
    ('Malvan', 'Sindhudurg', 'MLV004', true, 1876),
    ('Malvan', 'Achara', 'MLV005', true, 3245),
    ('Vengurla', 'Vengurla', 'VNG001', true, 12236),
    ('Vengurla', 'Mochemad', 'VNG002', true, 2876),
    ('Vengurla', 'Shiroda', 'VNG003', true, 1456),
    ('Devgad', 'Devgad', 'DVG001', true, 8934),
    ('Devgad', 'Vijaydurg', 'DVG002', true, 2187),
    ('Devgad', 'Bharane', 'DVG003', true, 1823),
    ('Kudal', 'Masure', 'KDL001', true, 2456),
    ('Kudal', 'Banda', 'KDL002', true, 1876),
    ('Kankavli', 'Banda', 'KNK001', true, 2134),
    ('Sawantwadi', 'Sawantwadi', 'SWT001', false, 28690),
    ('Dodamarg', 'Dodamarg', 'DDM001', false, 4567)
) v(taluka_name, name, code, is_coastal, population)
WHERE d.name = 'Sindhudurg' AND t.name = v.taluka_name
ON CONFLICT (taluka_id, name) DO NOTHING;

-- Insert sample gram panchayats for Ratnagiri
INSERT INTO gram_panchayats (block_id, name, gp_code, headquarters_village)
SELECT b.id, gp.name, gp.code, gp.hq_village
FROM blocks b
INNER JOIN talukas t ON b.taluka_id = t.id
INNER JOIN districts d ON t.district_id = d.id
CROSS JOIN (VALUES
    ('Dapoli', 'Murud Gram Panchayat', 'DPL_GP001', 'Murud'),
    ('Dapoli', 'Harnai Gram Panchayat', 'DPL_GP002', 'Harnai'),
    ('Dapoli', 'Anjarle Gram Panchayat', 'DPL_GP003', 'Anjarle'),
    ('Guhagar', 'Guhagar Gram Panchayat', 'GUH_GP001', 'Guhagar'),
    ('Guhagar', 'Velas Gram Panchayat', 'GUH_GP002', 'Velas'),
    ('Ratnagiri', 'Ganpatipule Gram Panchayat', 'RTN_GP001', 'Ganpatipule'),
    ('Ratnagiri', 'Pawas Gram Panchayat', 'RTN_GP002', 'Pawas'),
    ('Chiplun', 'Chiplun Gram Panchayat', 'CHP_GP001', 'Chiplun')
) gp(block_name, name, code, hq_village)
WHERE d.name = 'Ratnagiri' AND t.name = gp.block_name AND b.name = gp.block_name
ON CONFLICT (block_id, name) DO NOTHING;

-- Insert sample gram panchayats for Sindhudurg
INSERT INTO gram_panchayats (block_id, name, gp_code, headquarters_village)
SELECT b.id, gp.name, gp.code, gp.hq_village
FROM blocks b
INNER JOIN talukas t ON b.taluka_id = t.id
INNER JOIN districts d ON t.district_id = d.id
CROSS JOIN (VALUES
    ('Malvan', 'Malvan Gram Panchayat', 'MLV_GP001', 'Malvan'),
    ('Malvan', 'Tarkarli Gram Panchayat', 'MLV_GP002', 'Tarkarli'),
    ('Malvan', 'Devbag Gram Panchayat', 'MLV_GP003', 'Devbag'),
    ('Kudal', 'Masure Gram Panchayat', 'KDL_GP001', 'Masure'),
    ('Kankavli', 'Banda Gram Panchayat', 'KNK_GP001', 'Banda'),
    ('Sawantwadi', 'Sawantwadi Gram Panchayat', 'SWT_GP001', 'Sawantwadi')
) gp(block_name, name, code, hq_village)
WHERE d.name = 'Sindhudurg' AND t.name = gp.block_name AND b.name = gp.block_name
ON CONFLICT (block_id, name) DO NOTHING;

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_districts_updated_at 
    BEFORE UPDATE ON districts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_talukas_updated_at 
    BEFORE UPDATE ON talukas 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_blocks_updated_at 
    BEFORE UPDATE ON blocks 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cities_updated_at 
    BEFORE UPDATE ON cities 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_villages_updated_at 
    BEFORE UPDATE ON villages 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gram_panchayats_updated_at 
    BEFORE UPDATE ON gram_panchayats 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();