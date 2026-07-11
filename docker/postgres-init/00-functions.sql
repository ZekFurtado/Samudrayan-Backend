-- Shared trigger function used by every table's "updated_at" trigger.
-- Several of the copied scripts below (locations, restaurants, aadhar fields,
-- tourist locations, homestays) each redefine this with CREATE OR REPLACE as
-- if it might not exist yet, but 00-users.sql uses it without defining it —
-- so it must exist before any of them run. Extracted here to run first
-- (alphabetically "00-functions.sql" < "00-users.sql").
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';
