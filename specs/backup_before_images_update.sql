--
-- PostgreSQL database dump
--

-- Dumped from database version 17.7 (bdc8956)
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: neondb_owner
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO neondb_owner;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aadhar_verification_logs; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.aadhar_verification_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    verification_type character varying(20) NOT NULL,
    request_data jsonb,
    response_data jsonb,
    status character varying(20) NOT NULL,
    error_message text,
    ip_address inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT aadhar_verification_logs_status_check CHECK (((status)::text = ANY ((ARRAY['initiated'::character varying, 'success'::character varying, 'failed'::character varying, 'error'::character varying])::text[]))),
    CONSTRAINT aadhar_verification_logs_verification_type_check CHECK (((verification_type)::text = ANY ((ARRAY['uidai'::character varying, 'digilocker'::character varying, 'manual'::character varying])::text[])))
);


ALTER TABLE public.aadhar_verification_logs OWNER TO neondb_owner;

--
-- Name: TABLE aadhar_verification_logs; Type: COMMENT; Schema: public; Owner: neondb_owner
--

COMMENT ON TABLE public.aadhar_verification_logs IS 'Audit trail for all Aadhar verification attempts';


--
-- Name: amenities; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.amenities (
    id character varying(64) NOT NULL,
    title character varying(100) NOT NULL,
    category character varying(50)
);


ALTER TABLE public.amenities OWNER TO neondb_owner;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    action character varying(80) NOT NULL,
    entity_type character varying(40),
    entity_id uuid,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.audit_logs OWNER TO neondb_owner;

--
-- Name: availability; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.availability (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    room_id uuid NOT NULL,
    date date NOT NULL,
    price numeric(10,2) NOT NULL,
    is_available boolean DEFAULT true
);


ALTER TABLE public.availability OWNER TO neondb_owner;

--
-- Name: blocks; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.blocks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    taluka_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    block_code character varying(10),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.blocks OWNER TO neondb_owner;

--
-- Name: booking_items; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.booking_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    item_type character varying(40) NOT NULL,
    item_id character varying(64) NOT NULL,
    qty integer DEFAULT 1,
    amount numeric(10,2) NOT NULL
);


ALTER TABLE public.booking_items OWNER TO neondb_owner;

--
-- Name: bookings; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.bookings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    guest_id uuid NOT NULL,
    room_id uuid NOT NULL,
    check_in date NOT NULL,
    check_out date NOT NULL,
    guests integer NOT NULL,
    status character varying(20) NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    discount numeric(10,2) DEFAULT 0,
    tax numeric(10,2) DEFAULT 0,
    total numeric(10,2) NOT NULL,
    coupon_code character varying(40),
    guest_note text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT bookings_status_check CHECK (((status)::text = ANY ((ARRAY['pending_payment'::character varying, 'confirmed'::character varying, 'canceled'::character varying, 'completed'::character varying])::text[])))
);


ALTER TABLE public.bookings OWNER TO neondb_owner;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_name character varying(255) NOT NULL,
    subcategories jsonb,
    benefits character varying(1000),
    type character varying(50) DEFAULT 'tourism'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.categories OWNER TO neondb_owner;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.cities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    district_id uuid NOT NULL,
    taluka_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    city_type character varying(20),
    population integer,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT cities_city_type_check CHECK (((city_type)::text = ANY ((ARRAY['municipal_corporation'::character varying, 'municipal_council'::character varying, 'nagar_panchayat'::character varying, 'census_town'::character varying])::text[])))
);


ALTER TABLE public.cities OWNER TO neondb_owner;

--
-- Name: conversations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    guest_id uuid,
    host_id uuid,
    property_id uuid,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.conversations OWNER TO neondb_owner;

--
-- Name: coupons; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.coupons (
    code character varying(40) NOT NULL,
    description character varying(200),
    discount_type character varying(10),
    discount_value numeric(10,2) NOT NULL,
    active_from timestamp with time zone,
    active_to timestamp with time zone,
    max_uses integer,
    CONSTRAINT coupons_discount_type_check CHECK (((discount_type)::text = ANY ((ARRAY['flat'::character varying, 'percent'::character varying])::text[])))
);


ALTER TABLE public.coupons OWNER TO neondb_owner;

--
-- Name: devices; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.devices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    platform character varying(10),
    device_token text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT devices_platform_check CHECK (((platform)::text = ANY ((ARRAY['ios'::character varying, 'android'::character varying, 'web'::character varying])::text[])))
);


ALTER TABLE public.devices OWNER TO neondb_owner;

--
-- Name: districts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.districts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    state character varying(50) DEFAULT 'Maharashtra'::character varying NOT NULL,
    district_code character varying(10),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.districts OWNER TO neondb_owner;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_user_id uuid,
    type character varying(40) NOT NULL,
    file_id uuid,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.documents OWNER TO neondb_owner;

--
-- Name: experiences; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.experiences (
    id character varying(64) NOT NULL,
    title character varying(160) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL
);


ALTER TABLE public.experiences OWNER TO neondb_owner;

--
-- Name: food_packages; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.food_packages (
    id character varying(64) NOT NULL,
    title character varying(160) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL
);


ALTER TABLE public.food_packages OWNER TO neondb_owner;

--
-- Name: gram_panchayats; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.gram_panchayats (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    block_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    gp_code character varying(15),
    headquarters_village character varying(100),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.gram_panchayats OWNER TO neondb_owner;

--
-- Name: homestay_rooms; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.homestay_rooms (
    id uuid NOT NULL,
    homestay_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    capacity integer DEFAULT 2 NOT NULL,
    price_per_night numeric(10,2) DEFAULT 0 NOT NULL,
    amenities jsonb DEFAULT '[]'::jsonb,
    status character varying(20) DEFAULT 'active'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT homestay_rooms_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT homestay_rooms_price_per_night_check CHECK ((price_per_night >= (0)::numeric)),
    CONSTRAINT homestay_rooms_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying])::text[])))
);


ALTER TABLE public.homestay_rooms OWNER TO neondb_owner;

--
-- Name: homestays; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.homestays (
    id uuid NOT NULL,
    owner_id text NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    grade character varying(20) NOT NULL,
    district character varying(100) NOT NULL,
    taluka character varying(100) NOT NULL,
    latitude numeric(10,8) NOT NULL,
    longitude numeric(11,8) NOT NULL,
    amenities jsonb DEFAULT '[]'::jsonb,
    media jsonb DEFAULT '[]'::jsonb,
    sustainability_score integer DEFAULT 0,
    status character varying(30) DEFAULT 'pending-verification'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT homestays_grade_check CHECK (((grade)::text = ANY ((ARRAY['silver'::character varying, 'gold'::character varying, 'diamond'::character varying])::text[]))),
    CONSTRAINT homestays_status_check CHECK (((status)::text = ANY ((ARRAY['pending-verification'::character varying, 'active'::character varying, 'inactive'::character varying, 'suspended'::character varying])::text[]))),
    CONSTRAINT homestays_sustainability_score_check CHECK (((sustainability_score >= 0) AND (sustainability_score <= 100)))
);


ALTER TABLE public.homestays OWNER TO neondb_owner;

--
-- Name: hosts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.hosts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    status character varying(20) NOT NULL,
    aadhaar_hash text,
    pan_hash text,
    payout_bank_json jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hosts_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying])::text[])))
);


ALTER TABLE public.hosts OWNER TO neondb_owner;

--
-- Name: ledger; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.ledger (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying(20) NOT NULL,
    entity_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    currency character varying(10) DEFAULT 'INR'::character varying,
    note character varying(200),
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.ledger OWNER TO neondb_owner;

--
-- Name: locations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.locations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(160) NOT NULL,
    type character varying(20) NOT NULL,
    district character varying(80),
    taluka character varying(80),
    village character varying(80),
    lat numeric(9,6),
    lng numeric(9,6),
    CONSTRAINT locations_type_check CHECK (((type)::text = ANY ((ARRAY['district'::character varying, 'taluka'::character varying, 'village'::character varying, 'poi'::character varying])::text[])))
);


ALTER TABLE public.locations OWNER TO neondb_owner;

--
-- Name: media; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.media (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_user_id uuid,
    url text NOT NULL,
    type character varying(20),
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT media_type_check CHECK (((type)::text = ANY ((ARRAY['image'::character varying, 'video'::character varying, 'doc'::character varying])::text[])))
);


ALTER TABLE public.media OWNER TO neondb_owner;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    text text,
    sent_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.messages OWNER TO neondb_owner;

--
-- Name: payment_transactions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.payment_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    transaction_type character varying(20) NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_method character varying(20) NOT NULL,
    gateway_transaction_id character varying(255),
    gateway_response jsonb,
    status character varying(20) DEFAULT 'pending'::character varying,
    processed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT payment_transactions_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'success'::character varying, 'failed'::character varying, 'cancelled'::character varying])::text[]))),
    CONSTRAINT payment_transactions_transaction_type_check CHECK (((transaction_type)::text = ANY ((ARRAY['payment'::character varying, 'refund'::character varying])::text[])))
);


ALTER TABLE public.payment_transactions OWNER TO neondb_owner;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    provider character varying(20) NOT NULL,
    provider_payment_id character varying(100),
    amount numeric(10,2) NOT NULL,
    currency character varying(10) DEFAULT 'INR'::character varying,
    status character varying(20),
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY ((ARRAY['created'::character varying, 'authorized'::character varying, 'captured'::character varying, 'failed'::character varying, 'refunded'::character varying])::text[])))
);


ALTER TABLE public.payments OWNER TO neondb_owner;

--
-- Name: payouts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.payouts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    host_id uuid,
    amount numeric(10,2) NOT NULL,
    status character varying(20),
    scheduled_for timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT payouts_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'paid'::character varying, 'failed'::character varying])::text[])))
);


ALTER TABLE public.payouts OWNER TO neondb_owner;

--
-- Name: properties; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    host_id uuid NOT NULL,
    name character varying(160) NOT NULL,
    description text,
    location_id uuid,
    address_line1 character varying(200),
    address_line2 character varying(200),
    pin_code character varying(10),
    policies jsonb,
    status character varying(20) DEFAULT 'draft'::character varying,
    verified boolean DEFAULT false,
    average_rating numeric(2,1) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT properties_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'active'::character varying, 'inactive'::character varying])::text[])))
);


ALTER TABLE public.properties OWNER TO neondb_owner;

--
-- Name: property_amenities; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.property_amenities (
    property_id uuid NOT NULL,
    amenity_id character varying(64) NOT NULL
);


ALTER TABLE public.property_amenities OWNER TO neondb_owner;

--
-- Name: property_experiences; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.property_experiences (
    property_id uuid NOT NULL,
    experience_id character varying(64) NOT NULL
);


ALTER TABLE public.property_experiences OWNER TO neondb_owner;

--
-- Name: property_food_packages; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.property_food_packages (
    property_id uuid NOT NULL,
    food_package_id character varying(64) NOT NULL
);


ALTER TABLE public.property_food_packages OWNER TO neondb_owner;

--
-- Name: refunds; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.refunds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    status character varying(20),
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT refunds_status_check CHECK (((status)::text = ANY ((ARRAY['initiated'::character varying, 'processed'::character varying, 'failed'::character varying])::text[])))
);


ALTER TABLE public.refunds OWNER TO neondb_owner;

--
-- Name: reviews; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    property_id uuid NOT NULL,
    guest_id uuid NOT NULL,
    rating integer,
    title character varying(120),
    comment text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO neondb_owner;

--
-- Name: room_photos; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.room_photos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    room_id uuid NOT NULL,
    url text NOT NULL,
    "position" integer DEFAULT 0
);


ALTER TABLE public.room_photos OWNER TO neondb_owner;

--
-- Name: rooms; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.rooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    property_id uuid NOT NULL,
    name character varying(120) NOT NULL,
    capacity integer NOT NULL,
    bed_count integer DEFAULT 1,
    base_price numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying,
    CONSTRAINT rooms_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying])::text[])))
);


ALTER TABLE public.rooms OWNER TO neondb_owner;

--
-- Name: seasonal_pricing; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.seasonal_pricing (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    room_id uuid NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    price numeric(10,2) NOT NULL,
    min_nights integer DEFAULT 1
);


ALTER TABLE public.seasonal_pricing OWNER TO neondb_owner;

--
-- Name: support_tickets; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.support_tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    subject character varying(200) NOT NULL,
    status character varying(20),
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT support_tickets_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'in_progress'::character varying, 'resolved'::character varying, 'closed'::character varying])::text[])))
);


ALTER TABLE public.support_tickets OWNER TO neondb_owner;

--
-- Name: talukas; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.talukas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    district_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    taluka_code character varying(10),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.talukas OWNER TO neondb_owner;

--
-- Name: ticket_messages; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.ticket_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ticket_id uuid,
    sender_id uuid,
    message text NOT NULL,
    sent_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.ticket_messages OWNER TO neondb_owner;

--
-- Name: tourist_locations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.tourist_locations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sr_no integer NOT NULL,
    place_name character varying(255) NOT NULL,
    taluka character varying(100),
    location text,
    latitude_longitude character varying(255),
    video_link text,
    description text,
    famous_for text,
    best_time_to_visit character varying(100),
    ideal_duration character varying(100),
    images_drive_link text,
    firebase_storage_images text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.tourist_locations OWNER TO neondb_owner;

--
-- Name: users; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name character varying(120) NOT NULL,
    email character varying(255),
    phone character varying(20),
    role character varying(20) NOT NULL,
    language character varying(5) DEFAULT 'en'::character varying,
    avatar_url text,
    is_verified boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    firebase_uid character varying NOT NULL,
    taluka character varying,
    district character varying,
    aadhar_number_encrypted text,
    aadhar_verification_status character varying(20) DEFAULT 'pending'::character varying,
    aadhar_verified_at timestamp with time zone,
    verification_method character varying(20),
    verification_reference_id character varying(255),
    verification_attempts integer DEFAULT 0,
    verification_failure_reason text,
    aadhar_document_url text,
    last_verification_attempt timestamp with time zone,
    CONSTRAINT users_aadhar_verification_status_check CHECK (((aadhar_verification_status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying, 'verified'::character varying, 'failed'::character varying, 'rejected'::character varying])::text[]))),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'district-admin'::character varying, 'taluka-admin'::character varying, 'homestay-owner'::character varying, 'fisherfolk'::character varying, 'artisan'::character varying, 'ngo'::character varying, 'investor'::character varying, 'tourist'::character varying, 'trainer'::character varying])::text[]))),
    CONSTRAINT users_verification_method_check CHECK (((verification_method)::text = ANY ((ARRAY['uidai'::character varying, 'digilocker'::character varying, 'manual'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO neondb_owner;

--
-- Name: COLUMN users.aadhar_number_encrypted; Type: COMMENT; Schema: public; Owner: neondb_owner
--

COMMENT ON COLUMN public.users.aadhar_number_encrypted IS 'Encrypted Aadhar number for security';


--
-- Name: COLUMN users.aadhar_verification_status; Type: COMMENT; Schema: public; Owner: neondb_owner
--

COMMENT ON COLUMN public.users.aadhar_verification_status IS 'Current status of Aadhar verification process';


--
-- Name: COLUMN users.verification_method; Type: COMMENT; Schema: public; Owner: neondb_owner
--

COMMENT ON COLUMN public.users.verification_method IS 'Method used for verification (UIDAI/DigiLocker/Manual)';


--
-- Name: COLUMN users.verification_reference_id; Type: COMMENT; Schema: public; Owner: neondb_owner
--

COMMENT ON COLUMN public.users.verification_reference_id IS 'External reference ID from verification service';


--
-- Name: verifications; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying(20) NOT NULL,
    entity_id uuid NOT NULL,
    status character varying(20),
    notes text,
    reviewed_by uuid,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT verifications_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying])::text[])))
);


ALTER TABLE public.verifications OWNER TO neondb_owner;

--
-- Name: village_gram_panchayat; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.village_gram_panchayat (
    village_id uuid NOT NULL,
    gram_panchayat_id uuid NOT NULL
);


ALTER TABLE public.village_gram_panchayat OWNER TO neondb_owner;

--
-- Name: villages; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.villages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    taluka_id uuid NOT NULL,
    block_id uuid,
    name character varying(100) NOT NULL,
    village_code character varying(15),
    population integer,
    is_coastal boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.villages OWNER TO neondb_owner;

--
-- Name: wishlists; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.wishlists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    property_id uuid NOT NULL
);


ALTER TABLE public.wishlists OWNER TO neondb_owner;

--
-- Data for Name: aadhar_verification_logs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.aadhar_verification_logs (id, user_id, verification_type, request_data, response_data, status, error_message, ip_address, user_agent, created_at) FROM stdin;
5b72523b-96e4-4aeb-9cc0-37c047c6308e	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	initiated	\N	::1	PostmanRuntime/7.49.1	2025-12-01 09:42:20.769074+00
c4fbd996-290d-40b8-8fd3-827102cbc800	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	failed	UIDAI license key not configured	::1	PostmanRuntime/7.49.1	2025-12-01 09:42:21.014594+00
a85c5f4a-5c04-449a-98e9-ead1850ecdfa	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	initiated	\N	::1	PostmanRuntime/7.49.1	2025-12-01 09:42:21.266901+00
b4adcfe3-c835-4d3f-975d-486163422eb4	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	failed	DigiLocker authentication failed: Unexpected token '<', "<html>\r\n<h"... is not valid JSON	::1	PostmanRuntime/7.49.1	2025-12-01 09:42:21.802407+00
92476b77-defe-4825-9a84-8f60fc5e9fad	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	initiated	\N	::1	PostmanRuntime/7.49.1	2025-12-01 12:09:51.255473+00
a7584a63-a321-4a35-803f-6c8c20c4d592	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	failed	UIDAI license key not configured	::1	PostmanRuntime/7.49.1	2025-12-01 12:09:51.620571+00
8f878ae6-8dc1-4832-a7bf-d85de53c7cbb	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	initiated	\N	::1	PostmanRuntime/7.49.1	2025-12-01 12:09:51.755498+00
118cef24-00e6-4533-a449-33d58014f36f	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	failed	DigiLocker authentication failed: Unexpected token '<', "<html>\r\n<h"... is not valid JSON	::1	PostmanRuntime/7.49.1	2025-12-01 12:09:52.295382+00
2cf53187-8dc4-4032-ae5c-e25f4435417b	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	initiated	\N	::1	PostmanRuntime/7.49.1	2025-12-01 12:50:49.973036+00
45abf0fd-ebb9-446e-9a3c-1e3a39a831f7	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	failed	UIDAI license key not configured	::1	PostmanRuntime/7.49.1	2025-12-01 12:50:53.586119+00
e0d7cb61-d6ed-4b22-baf0-73aed49054b9	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	initiated	\N	::1	PostmanRuntime/7.49.1	2025-12-01 12:50:56.02799+00
cbb4a77a-669e-4fd9-a82e-99edeab89122	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	failed	DigiLocker authentication failed: Unexpected token '<', "<html>\r\n<h"... is not valid JSON	::1	PostmanRuntime/7.49.1	2025-12-01 12:51:04.293115+00
54147f2d-e509-4189-bac6-81dae0d2a076	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	initiated	\N	::ffff:172.225.137.232	PostmanRuntime/7.49.1	2025-12-11 06:31:00.977989+00
38014b19-01f4-4766-9a92-5f4fad7addb6	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	failed	UIDAI license key not configured	::ffff:172.225.137.232	PostmanRuntime/7.49.1	2025-12-11 06:31:01.395522+00
0866b03e-527c-4b49-b173-d7e3e3ca9300	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	initiated	\N	::ffff:172.225.137.232	PostmanRuntime/7.49.1	2025-12-11 06:31:01.593793+00
9e639c71-ee03-435f-b359-74119373fca6	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	failed	DigiLocker authentication failed: Unexpected token < in JSON at position 0	::ffff:172.225.137.232	PostmanRuntime/7.49.1	2025-12-11 06:31:02.683607+00
27f1909f-3815-4d76-9dcb-15d1c4a94bd3	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	initiated	\N	::ffff:172.225.137.232	PostmanRuntime/7.49.1	2025-12-11 06:32:15.731812+00
3b1f6ad2-b07a-4a13-82ef-4b057864a296	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	uidai	{"aadharNumber": "****1772"}	{}	failed	UIDAI license key not configured	::ffff:172.225.137.232	PostmanRuntime/7.49.1	2025-12-11 06:32:16.12662+00
0ba29807-e866-4cb5-a6a4-c1c675751c25	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	initiated	\N	::ffff:172.225.137.232	PostmanRuntime/7.49.1	2025-12-11 06:32:16.32248+00
83682099-f6c0-4e0a-a594-73124ecf8e25	0cb42175-4e38-4ee3-b7f8-777cec39c6bd	digilocker	{"aadharNumber": "****1772"}	{}	failed	DigiLocker authentication failed: Unexpected token < in JSON at position 0	::ffff:172.225.137.232	PostmanRuntime/7.49.1	2025-12-11 06:32:17.375669+00
d7a91dd1-0df1-4d3d-a458-a2acbbf320b2	39bf573c-852b-4379-9025-fd1d61ed4320	manual	{"comments": "string (optional, max 500 chars)", "approvedBy": "J5TROvXYTahgnB0hywjDOOsTYYi2"}	{"approvedAt": "2025-12-11T09:07:53.738Z", "referenceId": "MANUAL_1765444073373_J5TROvXYTahgnB0hywjDOOsTYYi2"}	success	\N	::1	PostmanRuntime/7.49.1	2025-12-11 09:07:53.810877+00
24346984-80af-48fb-8d1c-d7bc8fe51f4b	39bf573c-852b-4379-9025-fd1d61ed4320	manual	{"comments": "Approved", "approvedBy": "J5TROvXYTahgnB0hywjDOOsTYYi2"}	{"approvedAt": "2025-12-11T09:16:44.638Z", "referenceId": "MANUAL_1765444604444_J5TROvXYTahgnB0hywjDOOsTYYi2"}	success	\N	::ffff:172.225.186.44	Dart/3.9 (dart:io)	2025-12-11 09:16:44.734348+00
\.


--
-- Data for Name: amenities; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.amenities (id, title, category) FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.audit_logs (id, user_id, action, entity_type, entity_id, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: availability; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.availability (id, room_id, date, price, is_available) FROM stdin;
\.


--
-- Data for Name: blocks; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.blocks (id, taluka_id, name, block_code, is_active, created_at, updated_at) FROM stdin;
d8a84a78-901f-4262-a0ed-beaff90040b0	7e396c87-09c4-430e-90c3-a3236b4e1bf6	Ratnagiri	RTGB1	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
084e95b4-3d07-4515-ba27-748907516875	374f5ff0-c733-4e1d-9e85-a098085cfd97	Dapoli	RTGB2	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
6db4c7c7-d478-4c8d-a63a-f60166513e94	c1f2e096-cfcc-4680-805e-b48ca5483ecf	Guhagar	RTGB3	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
1532d9df-cae5-43e9-a03b-7ab8f375ad97	44206c65-9149-4a1b-8283-b128483e3963	Chiplun	RTGB4	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
22c1682d-0df8-47c3-bac8-d639df984e24	1ace7e58-43bb-43dd-bea2-c53e2a331ff4	Kudal	SNDB1	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
44c56eac-8ce1-4e47-afbb-f11182636c5c	84b8902f-bc95-4c50-97b3-b8de62941a74	Sawantwadi	SNDB2	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
f7c6c00b-db2f-4f11-af53-8c15d78d8931	3c44b5c7-6bd1-4945-9cd8-c21622fe17c8	Kankavli	SNDB3	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
6fa19e04-d377-4053-b626-03af419a8cbb	01bc2bc9-77a8-403d-887c-8a0711248452	Malvan	SNDB4	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
\.


--
-- Data for Name: booking_items; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.booking_items (id, booking_id, item_type, item_id, qty, amount) FROM stdin;
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.bookings (id, guest_id, room_id, check_in, check_out, guests, status, subtotal, discount, tax, total, coupon_code, guest_note, created_at) FROM stdin;
007090c0-7c75-434d-a335-93b6702a0f3d	fe4b1684-d7f0-4309-9d27-f4764fd732dc	64b0b2df-262b-45b0-a889-0656b997b1f4	2025-12-21	2025-12-23	1	pending_payment	5600.00	0.00	0.00	5600.00	\N	\N	2025-12-20 04:08:41.323076+00
bef9065e-b58b-4aa9-9b4f-0c09d4e353ee	fe4b1684-d7f0-4309-9d27-f4764fd732dc	64b0b2df-262b-45b0-a889-0656b997b1f4	2025-12-30	2025-12-31	2	pending_payment	2800.00	0.00	0.00	2800.00	\N	\N	2025-12-20 06:19:35.277521+00
79a12612-da82-47fe-b8f3-e82e8ef4dc52	fe4b1684-d7f0-4309-9d27-f4764fd732dc	64b0b2df-262b-45b0-a889-0656b997b1f4	2026-01-01	2026-01-03	1	pending_payment	5600.00	0.00	0.00	5600.00	\N	\N	2025-12-20 06:32:36.948343+00
b949854b-861d-4427-b4fb-cee759977052	fe4b1684-d7f0-4309-9d27-f4764fd732dc	64b0b2df-262b-45b0-a889-0656b997b1f4	2025-12-24	2025-12-26	1	pending_payment	5600.00	0.00	0.00	5600.00	\N	\N	2025-12-22 10:32:45.782402+00
8d1f14f1-20b5-4a92-a80e-25e0598a36ef	39bf573c-852b-4379-9025-fd1d61ed4320	64b0b2df-262b-45b0-a889-0656b997b1f4	2025-12-27	2025-12-28	1	pending_payment	2800.00	0.00	0.00	2800.00	\N	\N	2025-12-22 11:00:03.166072+00
9c7b3970-d0ff-43eb-b1d2-549f460f7b15	39bf573c-852b-4379-9025-fd1d61ed4320	64b0b2df-262b-45b0-a889-0656b997b1f4	2026-01-27	2026-01-28	1	pending_payment	2800.00	0.00	0.00	2800.00	\N	\N	2025-12-22 11:03:37.929207+00
58f53086-b96b-47c0-ad48-8992ec209273	39bf573c-852b-4379-9025-fd1d61ed4320	64b0b2df-262b-45b0-a889-0656b997b1f4	2026-01-21	2026-01-22	1	pending_payment	2800.00	0.00	0.00	2800.00	\N	\N	2025-12-22 11:22:02.525396+00
f9290f25-ce5b-40bb-a7e2-c61c7766d9b0	fe4b1684-d7f0-4309-9d27-f4764fd732dc	64b0b2df-262b-45b0-a889-0656b997b1f4	2026-01-07	2026-01-10	1	pending_payment	8400.00	0.00	0.00	8400.00	\N	\N	2025-12-22 11:23:35.611445+00
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.categories (id, category_name, subcategories, benefits, type, is_active, created_at, updated_at) FROM stdin;
a6d7bf07-874e-4f64-9450-6236ee9b03e6	Accommodation	["Homestays", "Lodging", "Hotels", "Resorts", "Hostels (Solo-friendly hostels)", "Beach-Front Properties", "Spiritual and Wellness Stays", "Eco-lodges and Treehouses"]	Comfortable stays for all budgets; authentic Konkan hospitality; solo & family-friendly	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
ef3fcffc-ea5f-4880-ac87-711082159477	Food & Culinary	["Local seafood", "Konkani thalis", "Alphonso mango dishes", "beach shacks", "vegetarian options", "Village food experience", "Coastal Cafe"]	Authentic coastal flavours, fresh produce, unique Konkani cuisine	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
7c6bf1ef-088b-4bba-8771-66ae8bb5f5ce	Unique Experiences	["Bungy Jumping (proposed)", "Coastal Zipline", "FlyingFish Scuba", "Fish Cooking Workshops"]	High-thrill adventures, water exploration, rare adrenaline activities in Konkan	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
cd710298-1fc8-421d-9504-8c69ee5b8d09	Water Sports	["White Water Rafting (Kolad side – accessible)", "Jet Ski", "Banana Ride", "Parasailing (Ganpatipule/Malvan access)", "Snorkling", "Kayaking & Canoying"]	Fun beach activities, great for families & groups	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
e6de4655-61d8-492b-9981-9d430bef8aaa	Nautical Tours	["Konkan Explorers (Nautical Tours – Ratnagiri/Goa route)", "Dolphin Safari", "Island Tours", "Yacht and Boat Tours", "Lighthouse Eco-Tours", "Maritime Heritage Experience", "Coastal Biodiversity Trails"]	Scenic coastal cruising, dolphin spotting, photography experiences	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
6a44e35c-ce05-49af-9c28-089dc52fe4e0	Tours & Sightseeing	["Hop On Hop Off Ratnagiri (museum circuit + beaches)", "Guided city tours", "Heritage walks", "City Heritage Circuits", "Village Tourism Circuit", "Coastal Temple Circuit", "Mango Tourism Circuit"]	Easy, flexible sightseeing covering major attractions	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
f43bdbbf-f341-44bd-919a-790c7168fbb4	Trekking & Hiking	["Indiahikes Treks (Konkan + Sahyadri)", "Kasheli Ghats", "Kashedi Ghat", "Sada Trek"]	Beautiful mountain views, jungle trails, beginner to advanced options	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
60822d0d-a3e3-40d5-9cef-d0aa3c2858a7	Wildlife & Nature	["Velas Turtle Festival", "Jaigad Lighthouse eco-trail", "Karnala (nearby)", "birdwatching points", "Bioluminescence Tours"]	Turtle conservation, walking trails, wildlife photography	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
a7ad304e-cbe4-4a43-9793-2e5ae9d6921a	Heritage & Forts	["Ratnadurg Fort", "Jaigad Fort", "Kanakaditya Temple", "Thiba Palace"]	History, architecture, sea-facing forts, cultural heritage	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
4dcee398-f288-4120-a5d2-82d48c55dcff	Museums & Aquariums	["Tilak Ali Museum", "Marine Aquarium (proposed)", "Thiba Palace Museum"]	Cultural stories, marine knowledge, family-friendly	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
3d9cc118-528e-441c-9479-497d8dd5ca9f	Agro-tourism	["Alphonso Mango Farms", "Cashew farms", "Coconut plantations"]	Seasonal activities, farm stays, plantation tours	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
c7cafe1b-9647-40df-9de5-8b31163295d7	Beaches & Nature	["Ganpatipule Beach", "Aare-Ware Beach", "Guhagar", "Mandvi", "Bhatye", "Pawas coastline", "Creeks & Backwaters", "Mangrove Zones", "Viewpoints/Sunsets", "Picnic Spots", "Nature Trails"]	Pristine beaches, sunsets, clean shores, picnic spots	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
7572e546-8966-4451-8515-de9994ba039d	Local Markets	["Ratnagiri Market", "Pawas market", "Guhagar market"]	Fresh produce, Konkani spices, handicrafts, fish markets	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
1ef4f956-d3d7-451c-b36a-8cdb0887f182	Local Products (Fresh)	["Alphonso mango", "Kokum", "Cashew", "Fish", "Amla", "Rice varieties", "Handicrafts"]	Take-home authentic Konkan products, fresh & organic	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
8a33d212-9b3d-414f-9ab2-861c44540018	Solo Traveler Activities	["Hostels", "Fort treks", "Beach cafés", "Cycling routes"]	Safe, budget-friendly, scenic solo exploration	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
55f7e275-20e2-4db0-aadc-d3fc3a6a3715	Welness and holistic tourisam	["Ayurveda Wellness Centres", "Panchakarma retreats", "Beach yoga", "Forest meditation", "Nature therapy trails", "Naturopathy resorts (proposed under Samudrayan)"]	Holistic health and wellness experiences	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
85c8f92d-4fd1-4bb0-b2ee-e44ecff8763d	Other Events /Festivals	["Velas Turtle Festival", "Ganpatipule temple festival", "Mango festivals", "Beach festivals", "Youth coastal sports festival (proposed)", "Coastal cultural carnival (Samudrayan flagship event)"]	Cultural celebrations and community events	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
5b838c00-b202-4c81-8307-9edb1c5b0410	Blue Green economy and livlihoods	["Fisheries livelihood demonstrations", "Boat making experience", "Fish processing units visit", "Women SHG livelihood tours", "Coir & coconut craft industries", "Climate resilience projects", "Sustainable coastal village models"]	Sustainable livelihood and economic development experiences	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
39f61a9e-e8b3-4b2a-9c02-a16031f28898	Climate and sustainability tourisam	["Mangrove conservation", "Beach clean-up volunteering", "Carbon-neutral village experiences", "Renewable energy tourism sites", "Disaster management village model", "SDG Tourism Village (pilot under Samudrayan)"]	Environmental conservation and sustainable tourism experiences	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
bf33ed32-2a31-4d16-af33-4e97ab453ec5	Digital and smart tourisam	["AR-based fort history", "Virtual museum", "Digital tourism maps", "Smart QR-coded tourism circuits", "Tourist mobile app", "Interactive coastal dashboards", "Coastal drone views (licensed)"]	Technology-enhanced tourism experiences	tourism	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
3780707c-fc91-4b92-92f4-3030be6136d4	Homestay Grades	["silver", "gold", "diamond"]	Quality classification system for homestays	homestay	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
a2dff433-10fa-4724-b91b-ce9f95fbc179	Marketplace Products	["seafood", "spices", "handicrafts", "coastal-cuisine"]	Local products and crafts from coastal communities	marketplace	t	2025-11-29 11:11:21.150014+00	2025-11-29 11:11:21.150014+00
\.


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.cities (id, district_id, taluka_id, name, city_type, population, is_active, created_at, updated_at) FROM stdin;
de2b5fd3-5fef-4b99-a3a5-c94105d32766	67974df7-1acb-4782-9047-1081af5f1056	7e396c87-09c4-430e-90c3-a3236b4e1bf6	Ratnagiri	municipal_council	76062	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
9d99a766-2417-410e-bd8f-f4bfbdc6d0aa	67974df7-1acb-4782-9047-1081af5f1056	374f5ff0-c733-4e1d-9e85-a098085cfd97	Dapoli	nagar_panchayat	8298	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
7b0a6b80-1409-462e-a063-512f9a150f42	67974df7-1acb-4782-9047-1081af5f1056	c1f2e096-cfcc-4680-805e-b48ca5483ecf	Guhagar	nagar_panchayat	6747	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
a5d994c6-5600-4a8a-894a-ecfb4587dabe	67974df7-1acb-4782-9047-1081af5f1056	44206c65-9149-4a1b-8283-b128483e3963	Chiplun	municipal_council	70655	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
c08b72cf-1c5b-4cf2-9baa-687809b24338	8459f93c-49b3-4aee-a30a-037f14350f2c	1ace7e58-43bb-43dd-bea2-c53e2a331ff4	Kudal	municipal_council	42746	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
f9f80c20-116f-40b0-90f9-7ec3de4b1ee4	8459f93c-49b3-4aee-a30a-037f14350f2c	84b8902f-bc95-4c50-97b3-b8de62941a74	Sawantwadi	municipal_council	28690	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
43ef5d30-469a-40b2-af59-11d237227882	8459f93c-49b3-4aee-a30a-037f14350f2c	01bc2bc9-77a8-403d-887c-8a0711248452	Malvan	nagar_panchayat	15881	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
f976fdfe-7291-4731-bb2a-69962b7e6c7c	8459f93c-49b3-4aee-a30a-037f14350f2c	e725b046-67de-4fa1-ad5e-93479d5ac123	Vengurla	nagar_panchayat	12236	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.conversations (id, guest_id, host_id, property_id, created_at) FROM stdin;
\.


--
-- Data for Name: coupons; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.coupons (code, description, discount_type, discount_value, active_from, active_to, max_uses) FROM stdin;
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.devices (id, user_id, platform, device_token, created_at) FROM stdin;
\.


--
-- Data for Name: districts; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.districts (id, name, state, district_code, is_active, created_at, updated_at) FROM stdin;
67974df7-1acb-4782-9047-1081af5f1056	Ratnagiri	Maharashtra	RTG	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
8459f93c-49b3-4aee-a30a-037f14350f2c	Sindhudurg	Maharashtra	SND	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
6af8522c-283d-4669-8bb1-d00b704146aa	Thane	Maharashtra	THN	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
90274349-c377-49ec-901a-d20b4ca5061f	Mumbai City	Maharashtra	MBC	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
d6c66472-1a72-429e-8e8c-a2cd6afffc54	Mumbai Suburban	Maharashtra	MBS	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Raigad	Maharashtra	RGD	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.documents (id, owner_user_id, type, file_id, created_at) FROM stdin;
\.


--
-- Data for Name: experiences; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.experiences (id, title, description, price) FROM stdin;
\.


--
-- Data for Name: food_packages; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.food_packages (id, title, description, price) FROM stdin;
\.


--
-- Data for Name: gram_panchayats; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.gram_panchayats (id, block_id, name, gp_code, headquarters_village, is_active, created_at, updated_at) FROM stdin;
481396ca-0eec-4b9e-8be1-0b617a026cf2	d8a84a78-901f-4262-a0ed-beaff90040b0	Ganpatipule Gram Panchayat	RTN_GP001	Ganpatipule	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
b140a3b6-c8f4-48ff-b374-62cc07e287c9	d8a84a78-901f-4262-a0ed-beaff90040b0	Pawas Gram Panchayat	RTN_GP002	Pawas	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
d025471d-ace4-47da-b5ca-bee2f7972e91	084e95b4-3d07-4515-ba27-748907516875	Murud Gram Panchayat	DPL_GP001	Murud	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
617812e5-caf0-406c-bffa-f5aeba9b1191	084e95b4-3d07-4515-ba27-748907516875	Harnai Gram Panchayat	DPL_GP002	Harnai	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
b87fc60a-a2b3-4a6e-8ce9-e108e70cffab	084e95b4-3d07-4515-ba27-748907516875	Anjarle Gram Panchayat	DPL_GP003	Anjarle	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
f016d1ea-cf48-4654-b3b7-8651cd74c8c8	6db4c7c7-d478-4c8d-a63a-f60166513e94	Guhagar Gram Panchayat	GUH_GP001	Guhagar	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
5f4c903f-63a5-4122-b9cc-55e60b3f55ae	6db4c7c7-d478-4c8d-a63a-f60166513e94	Velas Gram Panchayat	GUH_GP002	Velas	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
27758da6-cc5d-4ab8-bb87-293d46742e63	1532d9df-cae5-43e9-a03b-7ab8f375ad97	Chiplun Gram Panchayat	CHP_GP001	Chiplun	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
1cff1392-d21c-4c98-b6b4-28317c0dadde	22c1682d-0df8-47c3-bac8-d639df984e24	Masure Gram Panchayat	KDL_GP001	Masure	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
f0db5676-2568-486d-9a28-a65dd7177cb6	44c56eac-8ce1-4e47-afbb-f11182636c5c	Sawantwadi Gram Panchayat	SWT_GP001	Sawantwadi	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
86545c13-c9e0-4aa4-9739-165111647da6	f7c6c00b-db2f-4f11-af53-8c15d78d8931	Banda Gram Panchayat	KNK_GP001	Banda	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
32caa7b8-96c3-454f-bad8-2ac8f16f8574	6fa19e04-d377-4053-b626-03af419a8cbb	Devbag Gram Panchayat	MLV_GP003	Devbag	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
2a6fd310-cdc8-435b-82a9-9342d665d347	6fa19e04-d377-4053-b626-03af419a8cbb	Tarkarli Gram Panchayat	MLV_GP002	Tarkarli	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
eb3a00b9-b1de-4769-a2e5-03432223eef8	6fa19e04-d377-4053-b626-03af419a8cbb	Malvan Gram Panchayat	MLV_GP001	Malvan	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
\.


--
-- Data for Name: homestay_rooms; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.homestay_rooms (id, homestay_id, name, capacity, price_per_night, amenities, status, created_at, updated_at) FROM stdin;
4cf9a185-5aa1-4c2c-adf1-92a4e7bf955e	9f4636ca-6b02-4f2c-9c3c-f17e260d8d5b	Sea View Deluxe	3	2500.00	[]	active	2025-11-09 20:21:18.6+00	2025-11-09 20:21:18.720691+00
ea382a14-a779-447b-b10c-6117f9ba7e92	9f4636ca-6b02-4f2c-9c3c-f17e260d8d5b	Garden View Standard	2	2000.00	[]	active	2025-11-09 20:21:18.727+00	2025-11-09 20:21:18.84732+00
56428aea-8265-4a66-ba25-6d22f0183468	62d34970-44fd-4e82-a8f1-e63687e4dd12	Traditional Konkan Room	4	1800.00	[]	active	2025-11-09 20:21:19.352+00	2025-11-09 20:21:19.471357+00
a14da547-702c-4956-8aa2-d725820299a3	82b62439-5533-4d66-8d4c-811473a4a2e4	Premium Sea View Suite	2	3200.00	[]	active	2025-11-09 20:21:19.504+00	2025-11-09 20:21:19.623863+00
64b0b2df-262b-45b0-a889-0656b997b1f4	82b62439-5533-4d66-8d4c-811473a4a2e4	Deluxe Hill View	3	2800.00	[]	active	2025-11-09 20:21:19.586+00	2025-11-09 20:21:19.711599+00
9faaf7c4-7269-43cc-8dc2-ad18b7825d60	19810925-f7c1-4e95-92d9-eb5a715df5af	Cozy Cottage Room	2	1500.00	[]	active	2025-11-09 20:21:19.864+00	2025-11-09 20:21:19.985149+00
27d2b538-2971-4282-a316-f8cf6355b240	19810925-f7c1-4e95-92d9-eb5a715df5af	Family Cottage Room	4	1800.00	[]	active	2025-11-09 20:21:19.946+00	2025-11-09 20:21:20.067979+00
5eabb916-2f3e-43ae-b0fa-a05639c4af02	51889dc1-283b-4b4d-80a3-5a92435376ce	Test Deluxe Room	3	2500.00	[]	active	2025-11-30 08:42:48.551+00	2025-11-30 08:42:48.701251+00
63e69bdb-3526-4859-aaf9-5b8654cf57d8	51889dc1-283b-4b4d-80a3-5a92435376ce	Test Standard Room	2	1800.00	[]	active	2025-11-30 08:42:48.679+00	2025-11-30 08:42:48.835153+00
d3b4ce10-e508-457a-ac81-6bdc69075f03	aa39f119-010b-462d-9210-78a91eb0e371	Room 1	2	4000.00	["WiFi", "Air Conditioning"]	active	2025-12-11 09:19:29.395+00	2025-12-11 09:19:29.395+00
\.


--
-- Data for Name: homestays; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.homestays (id, owner_id, name, description, grade, district, taluka, latitude, longitude, amenities, media, sustainability_score, status, created_at, updated_at) FROM stdin;
51889dc1-283b-4b4d-80a3-5a92435376ce	mJtI6AoIEkTnTujvgRUpZqHjWWH2	Test Beach Resort With Rooms Fixed	Testing room insertion functionality	gold	Ratnagiri	Ganpatipule	17.13290000	73.26410000	["wifi", "power-backup", "24h-water"]	["https://example.com/img1.jpg"]	75	pending-verification	2025-11-30 08:42:48.423+00	2025-12-10 04:50:31.087554+00
62d34970-44fd-4e82-a8f1-e63687e4dd12	mJtI6AoIEkTnTujvgRUpZqHjWWH2	Traditional Fishing Village Stay	Experience authentic coastal lifestyle in a traditional fishing village. Learn about local fishing techniques and enjoy fresh seafood daily.	silver	Sindhudurg	Malvan	16.05610000	73.46930000	["wifi", "fishing_tours", "local_cuisine", "cultural_activities"]	["https://images.unsplash.com/photo-1520637836862-4d197d17c0a4?w=800"]	92	active	2025-11-09 20:21:18.77+00	2025-12-10 13:52:00.966302+00
82b62439-5533-4d66-8d4c-811473a4a2e4	mJtI6AoIEkTnTujvgRUpZqHjWWH2	Hilltop Coastal Retreat	Luxury hilltop retreat offering panoramic views of the Arabian Sea. Premium amenities and personalized service for discerning travelers.	diamond	Ratnagiri	Ratnagiri	16.99440000	73.30000000	["wifi", "spa", "pool", "restaurant", "bar", "gym", "room_service"]	["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800", "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800"]	65	active	2025-11-09 20:21:19.424+00	2025-12-10 13:52:00.966302+00
9f4636ca-6b02-4f2c-9c3c-f17e260d8d5b	mJtI6AoIEkTnTujvgRUpZqHjWWH2	Konkan Beach Resort	Beautiful beachfront resort offering authentic Konkan coastal experience with modern amenities. Perfect for families and couples seeking a peaceful getaway.	gold	Sindhudurg	Malvan	16.00540000	73.46660000	["wifi", "parking", "restaurant", "beachfront", "garden"]	["https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800", "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800"]	85	active	2025-11-09 20:21:18.334+00	2025-12-10 13:52:00.966302+00
c4984426-5fbf-4361-8ff5-44350303ef9e	mJtI6AoIEkTnTujvgRUpZqHjWWH2	Hotel Sai Palace	Charming coastal cottage run by local fishing family. Authentic home-cooked meals and insights into traditional coastal life.	silver	Ratnagiri	Dapoli	17.76470000	73.19080000	["wifi", "home_cooked_meals", "fishing_experience", "bicycle"]	["https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800"]	88	active	2025-11-30 08:36:22.943+00	2025-12-10 13:52:00.966302+00
19810925-f7c1-4e95-92d9-eb5a715df5af	mJtI6AoIEkTnTujvgRUpZqHjWWH2	Fisherman's Cottage	Charming coastal cottage run by local fishing family. Authentic home-cooked meals and insights into traditional coastal life.	silver	Ratnagiri	Dapoli	17.76470000	73.19080000	["wifi", "home_cooked_meals", "fishing_experience", "bicycle"]	["https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800"]	88	active	2025-11-09 20:21:19.78+00	2025-12-11 09:17:04.037755+00
aa39f119-010b-462d-9210-78a91eb0e371	mJtI6AoIEkTnTujvgRUpZqHjWWH2	Test Homestay after Aadhar Verification	Test	silver	Test	Test	37.42199830	-122.08400000	["WiFi", "Air Conditioning", "Parking"]	["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/homestays%2F39bf573c-852b-4379-9025-fd1d61ed4320%2Ftest_homestay_after_aadhar_verification%2F1765444761521_1000000018.png?alt=media&token=c0fd11de-e950-4f1f-916d-deb93c7fb694"]	0	active	2025-12-11 09:19:29.199+00	2025-12-11 09:21:34.067236+00
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.hosts (id, user_id, status, aadhaar_hash, pan_hash, payout_bank_json, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ledger; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.ledger (id, entity_type, entity_id, amount, currency, note, created_at) FROM stdin;
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.locations (id, name, type, district, taluka, village, lat, lng) FROM stdin;
\.


--
-- Data for Name: media; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.media (id, owner_user_id, url, type, created_at) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.messages (id, conversation_id, sender_id, text, sent_at) FROM stdin;
\.


--
-- Data for Name: payment_transactions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.payment_transactions (id, booking_id, transaction_type, amount, payment_method, gateway_transaction_id, gateway_response, status, processed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.payments (id, booking_id, provider, provider_payment_id, amount, currency, status, created_at) FROM stdin;
\.


--
-- Data for Name: payouts; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.payouts (id, host_id, amount, status, scheduled_for, created_at) FROM stdin;
\.


--
-- Data for Name: properties; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.properties (id, host_id, name, description, location_id, address_line1, address_line2, pin_code, policies, status, verified, average_rating, created_at) FROM stdin;
\.


--
-- Data for Name: property_amenities; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.property_amenities (property_id, amenity_id) FROM stdin;
\.


--
-- Data for Name: property_experiences; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.property_experiences (property_id, experience_id) FROM stdin;
\.


--
-- Data for Name: property_food_packages; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.property_food_packages (property_id, food_package_id) FROM stdin;
\.


--
-- Data for Name: refunds; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.refunds (id, payment_id, amount, status, created_at) FROM stdin;
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.reviews (id, property_id, guest_id, rating, title, comment, created_at) FROM stdin;
\.


--
-- Data for Name: room_photos; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.room_photos (id, room_id, url, "position") FROM stdin;
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.rooms (id, property_id, name, capacity, bed_count, base_price, status) FROM stdin;
\.


--
-- Data for Name: seasonal_pricing; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.seasonal_pricing (id, room_id, start_date, end_date, price, min_nights) FROM stdin;
\.


--
-- Data for Name: support_tickets; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.support_tickets (id, user_id, subject, status, created_at) FROM stdin;
\.


--
-- Data for Name: talukas; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.talukas (id, district_id, name, taluka_code, is_active, created_at, updated_at) FROM stdin;
7e396c87-09c4-430e-90c3-a3236b4e1bf6	67974df7-1acb-4782-9047-1081af5f1056	Ratnagiri	RTG1	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
374f5ff0-c733-4e1d-9e85-a098085cfd97	67974df7-1acb-4782-9047-1081af5f1056	Dapoli	RTG2	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
c1f2e096-cfcc-4680-805e-b48ca5483ecf	67974df7-1acb-4782-9047-1081af5f1056	Guhagar	RTG3	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
44206c65-9149-4a1b-8283-b128483e3963	67974df7-1acb-4782-9047-1081af5f1056	Chiplun	RTG4	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
b66e24bc-8cf7-4255-81fa-9013ce550f24	67974df7-1acb-4782-9047-1081af5f1056	Mandangad	RTG5	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
69a8e70e-13e0-41b7-bda3-bab400777726	67974df7-1acb-4782-9047-1081af5f1056	Lanja	RTG6	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
8052b0aa-cb60-4c46-ac4c-2e747e0dbbfe	67974df7-1acb-4782-9047-1081af5f1056	Sangameshwar	RTG7	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
1ace7e58-43bb-43dd-bea2-c53e2a331ff4	8459f93c-49b3-4aee-a30a-037f14350f2c	Kudal	SND1	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
84b8902f-bc95-4c50-97b3-b8de62941a74	8459f93c-49b3-4aee-a30a-037f14350f2c	Sawantwadi	SND2	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
7229eaa3-33c5-4ce1-a545-9db4263ae324	8459f93c-49b3-4aee-a30a-037f14350f2c	Dodamarg	SND3	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
3c44b5c7-6bd1-4945-9cd8-c21622fe17c8	8459f93c-49b3-4aee-a30a-037f14350f2c	Kankavli	SND4	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
01bc2bc9-77a8-403d-887c-8a0711248452	8459f93c-49b3-4aee-a30a-037f14350f2c	Malvan	SND5	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
fa25dd6c-35f3-4fdf-9cd7-e549a9f56ad9	8459f93c-49b3-4aee-a30a-037f14350f2c	Devgad	SND6	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
e725b046-67de-4fa1-ad5e-93479d5ac123	8459f93c-49b3-4aee-a30a-037f14350f2c	Vengurla	SND7	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
1ea89426-3d58-47b9-9c38-74f01dbe42a5	6af8522c-283d-4669-8bb1-d00b704146aa	Thane	THN1	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
7067f303-586b-4e7f-a357-0adedfaef67e	6af8522c-283d-4669-8bb1-d00b704146aa	Kalyan	THN2	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
7f5ddda8-556c-45a5-a7ca-c24f1b853304	6af8522c-283d-4669-8bb1-d00b704146aa	Ulhasnagar	THN3	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
c9435961-e93a-44b0-81ce-b2cbc896218f	6af8522c-283d-4669-8bb1-d00b704146aa	Ambarnath	THN4	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
99a2fb27-ca50-4727-863d-2141c2a9e2ac	6af8522c-283d-4669-8bb1-d00b704146aa	Badlapur	THN5	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
ea06a2a4-8f76-441a-9dee-3919ec3cce86	6af8522c-283d-4669-8bb1-d00b704146aa	Murbad	THN6	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
9b39bb94-fd53-428c-b9a6-d0b78e76b81a	6af8522c-283d-4669-8bb1-d00b704146aa	Bhiwandi	THN7	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
e166eb9f-d159-4bca-9efe-28f88ab15732	6af8522c-283d-4669-8bb1-d00b704146aa	Shahapur	THN8	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
8f9b238d-3dac-41a2-bbf1-9c122ace3101	6af8522c-283d-4669-8bb1-d00b704146aa	Dahanu	THN9	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
dc6d6de6-b326-4eea-ae0a-184b880bf717	6af8522c-283d-4669-8bb1-d00b704146aa	Talasari	THN10	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
18adedd9-1d49-4e48-887a-f9dede087330	6af8522c-283d-4669-8bb1-d00b704146aa	Palghar	THN11	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
3873a4f2-ad2a-4043-b763-f2312b8b2079	6af8522c-283d-4669-8bb1-d00b704146aa	Vasai	THN12	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
735425da-4ac1-4ea0-ac6a-bd8fd282022e	6af8522c-283d-4669-8bb1-d00b704146aa	Nalasopara	THN13	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
da57aaae-97f7-416c-8d0e-546bbbb9112f	90274349-c377-49ec-901a-d20b4ca5061f	Mumbai City	MBC1	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
fd97d99c-da0a-4d21-b780-c4a6aa6bf115	d6c66472-1a72-429e-8e8c-a2cd6afffc54	Andheri	MBS1	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
eaf4bfc7-009d-4de8-becb-b6fd8875ce2c	d6c66472-1a72-429e-8e8c-a2cd6afffc54	Borivali	MBS2	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
dd8cc77f-74e3-469f-b164-0d8aca419a21	d6c66472-1a72-429e-8e8c-a2cd6afffc54	Kurla	MBS3	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
4da79b3e-40c0-4518-a4c2-1f7a8e88fc31	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Alibag	RGD1	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
85dc2785-185c-47d4-845a-7e365fa673e3	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Murud	RGD2	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
c58da31b-b384-4db8-8ff6-b010d658efdd	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Shrivardhan	RGD3	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
ed836d0a-9156-43bd-964f-3854cc66aecc	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Mahad	RGD4	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
1504a3a2-393f-408b-95cc-7cf88a7e7042	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Poladpur	RGD5	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
65ad5484-c116-4b7d-94d6-c400e299ea41	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Sudhagad	RGD6	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
20e2214e-1309-4615-82c0-affaf8a35843	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Mhasla	RGD7	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
31046848-e729-4605-bcea-521577e4396e	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Mangaon	RGD8	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
832c1815-a8f7-4f66-86ad-99902e2d460e	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Tala	RGD9	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
4d49eeab-047c-4b1a-8155-59321f91e55b	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Roha	RGD10	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
637b83c6-9771-4a3a-9405-18e2360c886d	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Nagothane	RGD11	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
0bac0a75-b0fc-4e26-88ed-20dd34bc4be2	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Pen	RGD12	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
fdd1a37a-765f-43e3-becb-ea5903edf337	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Khalapur	RGD13	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
f8ac7be2-68d4-4157-8d16-9aa428b498cc	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Karjat	RGD14	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
fa5babdc-ebb6-4a30-be70-012a9df76340	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Panvel	RGD15	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
0d9a9ff2-d16e-4d83-bada-45df93f54d7e	5b6a55de-9bde-42e3-b4ce-06666f6af9e9	Uran	RGD16	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
969edf1e-b13f-41fa-8da1-d0821146cc53	67974df7-1acb-4782-9047-1081af5f1056	Khed	RTG8	t	2025-11-29 11:03:48.635754+00	2025-12-16 05:44:10.605479+00
\.


--
-- Data for Name: ticket_messages; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.ticket_messages (id, ticket_id, sender_id, message, sent_at) FROM stdin;
\.


--
-- Data for Name: tourist_locations; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.tourist_locations (id, sr_no, place_name, taluka, location, latitude_longitude, video_link, description, famous_for, best_time_to_visit, ideal_duration, images_drive_link, firebase_storage_images, is_active, created_at, updated_at) FROM stdin;
ffdf6843-795f-40d2-8c86-4ba7e72254a4	1	Ganpatipule Beach & Ganpati Mandir	Ratnagiri	Ganpatipule, Tal. Ratnagiri, Maharashtra 415615	\N	https://www.youtube.com/shorts/jHyHmWgkijw	A beautiful clean beach with a naturally formed Swayambhu Ganpati idol. Perfect for sunrise/sunset, spiritual atmosphere, and long beach walks.	Temple, beach, photography, coastal route.	Oct–Feb	2–3 hours	https://drive.google.com/drive/folders/1HO6nwAxOkIDRxTEGSYsYkkIkL8hoQ9b8?usp=sharing	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105022.png?alt=media&token=d43b0073-4f02-4677-b9d4-f0473a58ea9b, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105031.png?alt=media&token=8c532feb-a409-432d-9a5f-1f0df70c2325, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105120.png?alt=media&token=fd201e18-4b4c-4de9-9d27-6b013ce3ac73, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105201.png?alt=media&token=6cc3b989-e30c-4bab-a8c7-3b3f1ff006b7, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105352.png?alt=media&token=44291c9c-b2bc-4c7d-b284-e26d743b532c 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
4a04c4ab-6be7-4bbc-9731-03dcbb7bd69c	2	Ratnadurg Fort (Bhagwati Fort)	Ratnagiri	Fort Rd, Mirya, Ratnagiri, Maharashtra 415639	\N	https://www.instagram.com/reel/DQmEPxgjCjW/?utm_	A massive sea-cliff fort offering panoramic Arabian Sea views. Sunset point is excellent. 700+ year history.	Sea views, lighthouse, photography, fort’s history.	Nov–Feb	1.5–2 hours	https://drive.google.com/drive/folders/1HDDZ87N19ZkNuPKVGpedjgc_h-6WE5Gm?usp=drive_link	 https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105502.png?alt=media&token=bcbd1294-976b-4fae-ae45-e9ef7ca8d29c, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105518.png?alt=media&token=378e5ad2-945b-4ea5-b8c5-a7563cba12da, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105543.png?alt=media&token=779eabf7-9a96-4a4b-a515-3b64520681ed, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105617.png?alt=media&token=65eb9979-0b66-46b8-a344-f5f83d3ef016, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105856.png?alt=media&token=5272ee21-addf-48bc-adab-6868a5bdfbab	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
f96b2891-f550-4041-af83-b2df8de0ca56	3	Thiba Palace	Ratnagiri	Thiba Palace Rd, Ratnagiri city, Maharashtra 415612	\N	https://www.youtube.com/shorts/17kB7lu7Xkk	Historical palace where the King of Burma (Myanmar) was kept in exile. Architecture + gardens worth seeing.	Burmese king’s story, heritage building.	Throughout the year	1 hour	https://drive.google.com/drive/folders/1hP8BPpQiXpK4MvOpvmvhW7DSrF2lkJwN?usp=drive_link	 https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20105731.png?alt=media&token=5bc2b43f-4bf3-45d3-bf1b-6a5f477ddb04, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110100.png?alt=media&token=d6ec672d-3bcc-4638-afb4-c4af9fc6db2d, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110116.png?alt=media&token=24b376ce-d160-4de8-a510-9ae70829e30c, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110310.png?alt=media&token=8aa492c1-ead4-4057-ae9d-17c4bbf32c23, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110431.png?alt=media&token=9135fb0f-d23f-49be-bdd8-838d170fcf81 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
9516077e-58dd-423d-aba0-6325f82ab380	4	Mandavi Beach (Black Sand Beach)	Ratnagiri	Mandavi Beach, near Ratnagiri Jetty, Ratnagiri 415612	\N	https://www.instagram.com/reel/CyN6ov7Ptdu/?utm_	Popular sunset point inside city; black-sand beach; good for families. Clean promenade.	Black sand, sunset, fish market nearby.	Evening	1–1.5 hours	https://drive.google.com/drive/folders/1VrjtvuI04Am_JbnDAJawQlm0buibabbo?usp=drive_link	 https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F4-Mandavi%20Beach%20(Black%20Sand%20Beach)%2FScreenshot%202025-12-15%20110554.png?alt=media&token=9adc038f-5a6e-4e9e-8e22-af654f2cb08c, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F4-Mandavi%20Beach%20(Black%20Sand%20Beach)%2FScreenshot%202025-12-15%20110622.png?alt=media&token=72de0d75-70c1-43cf-892f-660ba28196d2, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F4-Mandavi%20Beach%20(Black%20Sand%20Beach)%2FScreenshot%202025-12-15%20110644.png?alt=media&token=5592f067-a73a-4b20-9afc-df47517fc837, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F4-Mandavi%20Beach%20(Black%20Sand%20Beach)%2FScreenshot%202025-12-15%20110711.png?alt=media&token=7994f284-09d5-47aa-9c0e-aa4bd3e60ab5 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
723a5477-878e-430e-b810-93719419b550	5	Jaigad Fort	Ratnagiri	Jaigad, Dist. Ratnagiri, Maharashtra 415614	\N	https://www.instagram.com/reel/DOV2ozljBfx/?utm_	A large 16th-century coastal fort with deep moats, thick walls, and fantastic sea views. Windy cliffs.	History, bastions, ocean ridge.	Oct–March	2 hours	https://drive.google.com/drive/folders/1q8WTExjQGSVSRz6Cv0JF6fl431t7Go1U?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20111915.png?alt=media&token=0df488f6-95b9-4247-8e87-7cff1c5456e9, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20111957.png?alt=media&token=49f0517e-5e62-433a-ad43-2ea62f48074d, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112018.png?alt=media&token=48d53788-ae60-482d-bc26-2ebafa9f649a, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112039.png?alt=media&token=51ebb506-cbd9-4cae-be05-9570e819a3cb, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112207.png?alt=media&token=8feb889a-a7e7-4557-a4c4-22523d0fce5f, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112246.png?alt=media&token=b6d89970-45b0-43da-8fb7-4878e4705742, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112323.png?alt=media&token=5aa8bc40-b641-4feb-909d-d364e7f986e7 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
96e59d11-2165-431d-b496-a862f21c17f5	6	Jaigad Lighthouse	Ratnagiri	Jaigad Lighthouse Rd, Jaigad, Maharashtra 415614	\N	https://www.instagram.com/reel/C-fZnZKtvWs/?utm_	Lighthouse on a cliff near Jaigad Fort. Offers a 360° Konkan coastline view.	Height, views, photography.	Morning	30 min	https://drive.google.com/drive/folders/131IUhA5hqx3o_jKj0xRNazFTlneHMKmK?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F6-Jaigad%20Lighthouse%2FScreenshot%202025-12-15%20112440.png?alt=media&token=81e0e41e-5687-44ef-9b86-921a6b5f78c6, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F6-Jaigad%20Lighthouse%2FScreenshot%202025-12-15%20112501.png?alt=media&token=ccf17c56-9904-4505-a2bd-f7595b92cc52, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F6-Jaigad%20Lighthouse%2FScreenshot%202025-12-15%20112526.png?alt=media&token=92e7d09d-1728-4bf9-9da5-03e48af178da, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F6-Jaigad%20Lighthouse%2FScreenshot%202025-12-15%20112540.png?alt=media&token=ce10e66e-5928-44ab-93a2-c47bc104ebd4 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
9f96d63b-fe61-4a42-b95e-0f50ab57f534	7	Aare Ware Beach (Twin Beaches)	Ratnagiri	Aare–Ware Rd, Ganpatipule – Ratnagiri coastal route	\N	https://www.instagram.com/reel/DPgejhaiFik/?utm_	Two untouched, natural beaches connected by a cliff road. Scenic drive.	Scenic drive, drone shots, blue sea.	Anytime	45 min – 1 hour	https://drive.google.com/drive/folders/17y1hZKZt3vQK8q2DXTZz5EXyCON36fKB?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F7-Aare%20Ware%20Beach%20(Twin%20Beaches)%2FScreenshot%202025-12-15%20112709.png?alt=media&token=38ab4893-0d7e-4456-8a9d-cc8b29026078, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F7-Aare%20Ware%20Beach%20(Twin%20Beaches)%2FScreenshot%202025-12-15%20112737.png?alt=media&token=72fe726e-54f5-444a-bef5-0c1b6f3e8d92, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F7-Aare%20Ware%20Beach%20(Twin%20Beaches)%2FScreenshot%202025-12-15%20112800.png?alt=media&token=f4aeaa7c-391a-4ead-98b1-ac3a4aac47a9, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F7-Aare%20Ware%20Beach%20(Twin%20Beaches)%2FScreenshot%202025-12-15%20112857.png?alt=media&token=a635639d-eb9b-49d4-97fe-26bcfc03bd50 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
1df2a32c-c6df-4f9b-8f5f-f8f173481d14	8	Kasheli Beach	Ratnagiri	Kasheli Village, Near Purnagad Fort, Ratnagiri	\N	https://youtu.be/KCive5LXExw?si=sDeWYDC4AJMkynVr	A scenic beach known for its peaceful environment and fishing village culture. Wide sandy patches & stunning sunsets.	Excellent for cultural vlogs	\N	\N	https://drive.google.com/drive/folders/1qF6oqaxkwuXcxaAS_or7OuxGgu71jASt?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F8-Kasheli%20Beach%2FScreenshot%202025-12-15%20113157.png?alt=media&token=ad7561d2-52f7-4663-84d3-930c793cd892, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F8-Kasheli%20Beach%2FScreenshot%202025-12-15%20113217.png?alt=media&token=bdb45abe-1ccc-434a-bf49-1debbc37774c, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F8-Kasheli%20Beach%2FScreenshot%202025-12-15%20113246.png?alt=media&token=541becfe-f19c-4c15-9ead-7eda7cbd8666, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F8-Kasheli%20Beach%2FScreenshot%202025-12-15%20113301.png?alt=media&token=da453ace-486e-4397-b44a-9fd11ba3dec1 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
8614e1ff-af31-4394-bec0-e4bfdb46f44f	9	Marine Museum (Aquarium)	Ratnagiri	Near Mandavi Beach, Ratnagiri City	\N	https://youtu.be/KWBzl8hb6qI?si=8khb7Da6KllCklCL	Small marine museum displaying fish species, shells, preserved sea life — great for kids.	Fish species, marine education.	Any	20–30 min	https://drive.google.com/drive/folders/1Ld2Apzm6gFhbwZHWKnhELjh7liiv_Yhc?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F9-Marine%20Museum%20(Aquarium)%2FScreenshot%202025-12-15%20113425.png?alt=media&token=cbb2a249-00a2-4303-bd82-8599670ddcea, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F9-Marine%20Museum%20(Aquarium)%2FScreenshot%202025-12-15%20114046.png?alt=media&token=5ece0a21-956b-4632-9cdc-2de82e2ba9c2 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
9ca58d44-e978-41fc-8243-a019c4245cf2	10	Bhatye Beach	Ratnagiri	Bhatye Village, Ratnagiri 415612	\N	https://www.instagram.com/reel/DM7W0ypBnnI/?utm_	Long straight beach with shallow waters, perfect for walking, chilling, and photography. Less crowd, windy and peaceful.	Calm beach, seafood near by, bridge view.	Sunset	1–1.5 hrs	https://drive.google.com/drive/folders/14x1GozESTjpVotwWiGF9N20kdrCT0pY7?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F10-Bhatye%20Beach%2FScreenshot%202025-12-15%20114136.png?alt=media&token=80857a3c-27e0-48ba-b08a-26686fa15c1c, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F10-Bhatye%20Beach%2FScreenshot%202025-12-15%20114150.png?alt=media&token=3aa8a89e-b233-4779-802b-38b1c0d1d4c8, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F10-Bhatye%20Beach%2FScreenshot%202025-12-15%20114204.png?alt=media&token=6961501d-cb32-4653-85fb-f2b3b53fe377 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
7f2144af-1e05-49f6-8ad5-9cb636cbdede	11	Arey-Ware Ghat Scenic Road	Ratnagiri	Ratnagiri–Ganpatipule Coastal Highway	\N	https://youtube.com/shorts/SrFVysEBWpE?si=dTtwr-5uZt6er0qI	One of Maharashtra’s best coastal roads — turquoise ocean, cliffs, hills, greenery.	Road trip, cinematic drone shots.	Evening	30 min (drive)	https://drive.google.com/drive/folders/1ELxlUZbZYcP5AlzvQsJN4NkolNAU6Jtu?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F11-Arey-Ware%20Ghat%20Scenic%20Road%2FScreenshot%202025-12-15%20114429.png?alt=media&token=53a2cbdd-91aa-4285-ae0e-6c7150ff677e, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F11-Arey-Ware%20Ghat%20Scenic%20Road%2FScreenshot%202025-12-15%20114445.png?alt=media&token=8c6240ed-e95e-4654-b620-da0feb52499f, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F11-Arey-Ware%20Ghat%20Scenic%20Road%2FScreenshot%202025-12-15%20114514.png?alt=media&token=e099c566-ef7f-4071-82d4-12187d489ec1	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
38e5432b-69e1-43e0-8fa2-484c33235adf	12	Purnagad Fort	Ratnagiri	Purnagad Village, Ratnagiri	\N	https://www.instagram.com/reel/DRE9xSODJQw/?utm_	Stunning sea-facing fort associated with Kanhoji Angre. Peaceful, untouched fort.	Sea fort view + history.	Winter	1–1.5 hrs	https://drive.google.com/drive/folders/1eIy4FdT9vBzSikrsHvllG66vZgi5VdmX?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F12-Purnagad%20Fort%2FScreenshot%202025-12-15%20115857.png?alt=media&token=576179b0-b379-4f7a-9eba-8e79a0eb3aa8, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F12-Purnagad%20Fort%2FScreenshot%202025-12-15%20115918.png?alt=media&token=06db8bf8-360f-45ed-8cfc-00d806c138f1, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F12-Purnagad%20Fort%2FScreenshot%202025-12-15%20115940.png?alt=media&token=ebfbf549-f912-4e0d-acd7-82483a71e7e4	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
24a4d9f9-90f9-408d-9ca7-79ffbdc85281	13	Malgund Village – Birthplace of Keshavsut	Ratnagiri	Malgund Village, Near Ganpatipule, Ratnagiri	\N	https://www.youtube.com/shorts/ux40ZeXpGPU	A cultural and literary village with a museum dedicated to Marathi poet Kavi Keshavsut.	Good for literature lovers. Peaceful village ambiance.	Anytime	\N	https://drive.google.com/drive/folders/1j_Fq7mm4bVDXdJ4aAuL-FUtrVjdSzZF5?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F13-Malgund%20Village%20–%20Birthplace%20of%20Keshavsut%2FScreenshot%202025-12-15%20120139.png?alt=media&token=8ce46fa4-6786-4f87-8d37-9cf535c7613e,\nhttps://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F13-Malgund%20Village%20–%20Birthplace%20of%20Keshavsut%2FScreenshot%202025-12-15%20120158.png?alt=media&token=0bac628d-11a3-4e50-baf2-624f31a1c675,\nhttps://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F13-Malgund%20Village%20–%20Birthplace%20of%20Keshavsut%2FScreenshot%202025-12-15%20120224.png?alt=media&token=f7d09ebe-0500-4e66-b13a-1ddc5fb5d092	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
422d4fdb-4de1-47c7-add7-819bca32cd54	14	Kalbadevi Temple & Beach	Ratnagiri	Kalbadevi, Ratnagiri District,	\N	https://www.instagram.com/reel/DJBvasZRzNL/?utm_	An old temple dedicated to Goddess Kalbadevi, located beside a serene beach. The combination of spirituality and scenic beauty makes it a must-visit.	Peaceful atmosphere.\n Perfect for family visits.\n Good for religious functions.	\N	\N	https://drive.google.com/drive/folders/1j9TWBjXKh3cCn6vke4fzyvWiuYAhtjyT?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F14-Kalbadevi%20Temple%20%26%20Beach%2FScreenshot%202025-12-15%20120449.png?alt=media&token=cafa8d58-ddef-4896-a94e-930a633b5745, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F14-Kalbadevi%20Temple%20%26%20Beach%2FScreenshot%202025-12-15%20120514.png?alt=media&token=1ad2b95f-eef4-4e46-a17a-b1d6f8c048c9	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
8b991dde-e728-434d-af46-42d5906ecf6f	15	Pokharbav Ganpati Mandir	Ratnagiri	Pokharbav, Ratnagiri District, Maharashtra	\N	https://www.instagram.com/reel/DEhmhBdtOuj/?utm_	A sacred ancient Ganpati temple built in traditional Konkani style. Surrounded by greenery and village landscape.	Peaceful religious spot.\n Local festivals celebrated grandly.	\N	\N	https://drive.google.com/drive/folders/13_ANM68EMaGlqkyxrUG1_-NUisnbh6u2?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F15-Pokharbav%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20202756.png?alt=media&token=db3b2a7a-1bf8-4f43-9fc8-c17d903d8007, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F15-Pokharbav%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20202924.png?alt=media&token=77de1856-9d48-4612-9dcf-558cbdcf26d9 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
b9ff477f-a481-4234-b02a-bfe834d071ab	16	Karhateshwar Temple	Ratnagiri	Near Jaigad Fort, Karhateshwar, Ratnagiri 415614	\N	https://www.instagram.com/reel/DOn4OVsjM0T/?utm_	A historical Shiva temple located on a cliff overlooking the Arabian Sea. One of the most stunning and peaceful coastal temples in the Konkan region.	Sea view is extraordinary.\n Great photography spot.	\N	\N	https://drive.google.com/drive/folders/1fzRd4V_VSFxrr97kmkKiT6J0nNm9Fzo5?usp=drive_link	 https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F16-Karhateshwar%20Temple%2FScreenshot%202025-12-16%20001630.png?alt=media&token=294f620f-b4a9-4e35-9226-6055b9a55beb, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F16-Karhateshwar%20Temple%2FScreenshot%202025-12-16%20001646.png?alt=media&token=f966605e-06f2-4535-b38f-35e6166890da, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F16-Karhateshwar%20Temple%2FScreenshot%202025-12-16%20001750.png?alt=media&token=a86b733a-243f-4e0b-8c04-c987dc2673e8 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
a82505ac-8eb2-4abf-ad1c-9e3c7e9da45b	17	Panval Waterfall	Ratnagiri	Panval Village, Ratnagiri District, Maharashtra	\N	https://www.instagram.com/reel/DMffB9IvxOx/?utm_	A picturesque waterfall hidden deep in the forest. Best enjoyed after heavy monsoon rains. Great spot for nature lovers.	Some trekking required.\n Safe during early monsoon	\N	\N	https://drive.google.com/drive/folders/1uhu5Yo8oaPFkjJaNiCE3B96f0ULnPdDI?usp=drive_link	https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F18-Mirya%20Beach%2FScreenshot%202025-12-16%20014714.png?alt=media&token=5274af6b-33e2-43c4-8d1d-4eed1d68e642, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F18-Mirya%20Beach%2FScreenshot%202025-12-16%20014724.png?alt=media&token=bfa7b506-fb33-4a6c-867c-2a75d0021cf2, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F18-Mirya%20Beach%2FScreenshot%202025-12-16%20014734.png?alt=media&token=d40f3a74-4e82-4be1-ae16-fe59ce1e5614, https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F18-Mirya%20Beach%2FScreenshot%202025-12-16%20014744.png?alt=media&token=4555e3a4-89a5-4f63-bf5a-0746edbccf0b 	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
eda8b796-8e92-4206-8eb1-61467e3e5ce3	18	Mirya Beach	Ratnagiri	Mirya Village, Ratnagiri City, Maharashtra 415612	\N	https://www.instagram.com/reel/DQRd6MAjJLQ/?utm_	Mirya Beach is close to Ratnagiri city and known for its calm backwaters, picturesque fishing boats, and long stretch of walkable shoreline. The beach is less commercial, ideal for families and peaceful evening walks.	Walking, photography, fishing boat watching, sunrise & sunset views.	November – February	\N	https://drive.google.com/drive/folders/1Y0aJ6H8jk528g02H6ltvDSWHJRSx5qwV?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
8b42d402-a0db-4dbd-a87e-2778c7a69764	19	Avachitwadi village, Malgund	Ratnagiri	\N	\N	https://www.instagram.com/reel/DQ4AHRLjHRR/?utm_	This peaceful pond surrounded by lush greenery and absolute silence. The water is crystal clear — it almost looks unreal under sunlight.	This is one of those rare places where you can just sit, breathe, and forget time.	Anytime	\N	https://drive.google.com/drive/folders/1uNjq3YfDxPcvFFuComlmuh1uIn3qMwO3?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
b124a991-0782-443b-b34d-602d9005e29f	20	Hanuman Kundi (Waterfall Point)	Ratnagiri	Near Pawas Village, Ratnagiri – Pawas Road, Maharashtra 415616	\N	https://www.youtube.com/watch?v=xRqY5F5jckE&t=52s	Small natural waterfall + rock formation surrounded by dense greenery. Calm hidden spot; good for monsoon nature lovers. Not commercial, peaceful and less crowded.	\N	Monsoon & post-monsoon (July–Oct)	\N	https://drive.google.com/drive/folders/13uBYruKsMnqK3klXq61MIxpZmu85NBAz?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
b7420a86-fe91-427f-bbdc-6187d650f127	21	Jay Vinayak Temple	Ratnagiri	JSW Township, Kachare Village, Taluka Jaigad, Dist. Ratnagiri, Maharashtra 415614	\N	https://www.instagram.com/reel/DPoaueqDzB6/?utm_	Beautiful, well-maintained modern temple of Lord Ganesha. Temple has pagoda-style roof, attractive gardens & pond, calm ambiance. Good for spiritual visit + peaceful time amidst greenery.	Lovely brass idol of Ganesha, clean gardens, peaceful atmosphere, good stop if you visit nearby coastal forts/beaches.	Morning or evening (sunrise or aarti time) — 6 AM–10 AM, 5 PM–6 PM recommended	30–45 minutes (or more if you include stroll in gardens / photography)	https://drive.google.com/drive/folders/1piPOGy1EkuY-_Gpijzqu9Wvh8fnF_EJe?usp=sharing	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
6032bf6c-a7fa-4f7a-90a7-f6c96718fdc0	125	Rajapur Fort	Ratnagiri	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1tSG_Jbq1fkFbfOwWAzCRJ1r0yqPVQUCc?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
da03a158-11aa-4274-95b6-e92b51094e71	22	Phansavle Bridge	Ratnagiri	Phansavle, Ratnagiri – near river crossing	\N	https://www.instagram.com/reel/DRWDdnwiGLZ/?utm_	Scenic old bridge with beautiful river views, greenery, and photogenic surroundings — popular among locals.	River views, scenic photography spot	Oct–Feb	15–30 min	https://drive.google.com/drive/folders/1sKMbyfhnUQkVJqui6dE-QDx6o0AfkuBL?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
be8605e4-8d9e-4f78-b56b-d459ad911ff8	23	Kanakaditya Temple (Sun Temple)	Lanja	Kasheli village, Tal. Lanja, Dist. Ratnagiri	\N	https://www.youtube.com/shorts/EX_T7Mg8oX0	One of the few Sun Temples in India. Very clean, surprisingly peaceful, unique architecture.	Sun God temple, rare structure.	Morning hours	30 min	https://drive.google.com/drive/folders/1wu1YF-zuIknEZV8QAcDbEVIn-JD1lSnG?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
79254d32-7216-4946-8327-45e9fef11469	24	Devgad Beach + Fort	\N	Devgad, Sindhudurg district border (1.5 hours from Ratnagiri)	\N	https://www.youtube.com/watch?v=o4v0XIjUvGU	Clear blue-water beach + hilltop fort + lighthouse. Famous for Alphonso mangoes.	Clean beach, mango farms.	Winter	Half-day	https://drive.google.com/drive/folders/1khJB8okdRmGpqpgHnpXNsDhozb9UEHH1?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
39b39a80-255c-4767-be72-1db55bddf5ef	25	Kunkeshwar Temple & Beach	\N	Kunkeshwar, Devgad Road, near Ratnagiri border	\N	https://youtu.be/Y1mbBxaJRYg?si=UkyQa0wcjo25FTvB	A beautiful Shiva temple right at the edge of the Arabian Sea. The beach is clean and less commercial.	Sea-facing temple, clean beach.	Early morning	1 hour	https://drive.google.com/drive/folders/1Ab1M_aQlgU3XxJJ7cv01_QTrZtHX-R6k?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
3523d141-674e-4e0a-9ee5-e2c57448c5df	26	Velas Beach (Turtle Festival)	\N	Velas Village, Ratnagiri 415208	\N	https://www.youtube.com/shorts/qUCZM22IpIw	Conservation site for Olive Ridley turtles. Every year hatchlings are released into the sea.	Turtle hatching festival.	Feb–April	Half day	https://drive.google.com/drive/folders/1NuUm2rjVXuKJpYyiQXK_aqc_LH22pv2T?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
2d4687ef-bf83-4084-86db-89a1a904c39e	27	Anjarle Beach & Kadyavarcha Ganpati	Dapoli	Anjarle, Dapoli (Ratnagiri district)	\N	https://www.instagram.com/reel/DHgG77fglWD/?utm_	Stunning beach + hilltop Ganpati temple with a panoramic view. Less commercial, very scenic.	Clear beach, hilltop temple, photography.	Winter	2 hrs	https://drive.google.com/drive/folders/1UabUrUPj__DFmGOZ_1uBezp9lMiVEtli?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
04d54955-ddb1-451d-b2b1-06439c076fd5	28	Murud Beach	Dapoli	Murud, Dapoli, Ratnagiri	\N	https://www.instagram.com/reel/DFWxlJQNkKl/?utm_source=ig_web_button_share_sheet	One of Dapoli’s most visited beaches; water sports, horse rides, and long stretches.	Watersports, dolphin-spotting nearby.	Nov–Feb	2–3 hrs	https://drive.google.com/drive/folders/1xof6LIK-hjHq2bsF3fQyiPXWGagCPuCc?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
b1a2eb6c-33fd-438d-8791-a6591f472451	29	Harnai Port & Fish Auction Market	Dapoli	Harnai, Dapoli, Ratnagiri	\N	https://www.instagram.com/reel/DPbPRf-ka9_/?utm_	Live fish auction market — huge boats, fresh catch, real Konkan culture.	Fish auction, local seafood culture.	\N	1 hr	https://drive.google.com/drive/folders/12iLRLCaOBWm-GGFZDz-EfAA9teB8uuO4?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
67b4f3d5-cf0e-4653-a2fd-b216ee514e1f	30	Suvarnadurg Fort (Sea Fort)	Dapoli	Off Harnai coast, Dapoli, accessible by boat	\N	https://www.instagram.com/reel/DIoNHZAA41X/?utm_	Historic sea fort of Shivaji Maharaj, accessible via boat ride; adventurous and scenic.	Sea fort adventure, history.	Winter	2 hrs	https://drive.google.com/drive/folders/1NTZnCI1RcIPUMGfh_1nePyCWraymLxFq?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
ce2dceb4-1412-4105-990d-a36ccb3a65e6	31	Panhalekaji Caves	Dapoli	Near Dapoli, Ratnagiri district	\N	https://www.instagram.com/reel/CpFoH_kjfYG/?utm_	Ancient Buddhist–Hindu caves with carvings; located near a river. Hidden, underrated place.	Cave carvings, archaeology.	Winter	1–1.5 hrs	https://drive.google.com/drive/folders/19ziZV0adlaUYZzwxrTMbXrpXoda8TepF?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
c7d94524-69d1-4f35-b887-8b8d243d4458	32	Ladghar Beach	Dapoli	Ladghar, Dapoli, Ratnagiri	\N	https://www.instagram.com/reel/DIWLp0FNsZ-/?utm_	Known as “Red Sea” due to reddish sand tint. Water sports, boat rides, dolphin sighting.	Red sand shade, watersports, dolphins.	Winter	1.5–2 hrs	https://drive.google.com/drive/folders/19Z1yAoQvSJXGm7a2rfz2JFrG7Bdrw8dd?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
5bb4e62f-c941-4600-9805-90ec12cff2b5	33	Kolthare Beach	Dapoli	Kolthare Village, Dapoli, Ratnagiri	\N	https://www.youtube.com/watch?v=FCzr7grXM4Y	Extremely clean, untouched beach. No crowd. Perfect for peaceful travellers.	Virgin beach, clean coastline.	Oct–Feb	1–1.5 hrs	https://drive.google.com/drive/folders/1cxu9AsI9mxBGrdiX_WbdTj_UPmmpXH48?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
fa340623-86ea-4d15-bd77-84b7e3434024	34	Karde Beach	Dapoli	Karde Village, Dapoli, Ratnagiri	\N	https://www.youtube.com/watch?v=pbA0QGlW4Lw	Long clean beach, popular for dolphin rides. Several homestays nearby.	Dolphin safari.	Morning	1–2 hrs	https://drive.google.com/drive/folders/1-Ib4-mh4CzzdY16o99hUoVshjO9-mv2W?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
7edbfed7-160a-407e-b822-f2ce7996252e	35	Dabhol Port & Chandika Devi Cave Temple	Dapoli	Dabhol, Dapoli, Ratnagiri	\N	https://www.instagram.com/reel/DO3lyHwDLVx/?igsh=	Port area + Goddess Chandika Devi’s underground cave temple. Ancient & mystical ambience.	Natural cave temple, ancient idol.	Morning	45 min	https://drive.google.com/drive/folders/16DSTxhxphyn9YL_np71oRPnimKQlF6Rb?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
1c03fad8-bb9f-4fff-bc96-76f5842162e1	36	Keshavraj Temple	Dapoli	Asud, Dapoli, Ratnagiri, Maharashtra 415713	\N	https://www.instagram.com/reel/DH8bm1Pttbz/?utm_	A peaceful temple situated inside a dense forest with a freshwater stream flowing alongside the stone steps. The path to the temple is scenic with lush greenery, making it one of the most serene spiritual spots in Ratnagiri.	Ideal for nature lovers and a calm getaway.	Early morning or winter season	\N	https://drive.google.com/drive/folders/1Qj343zATN7efTSNtqzk9TtwqDebNTg12?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
11bfa60b-4d34-482f-b1fd-42b03995da3f	37	Kanakdurg Fort	Dapoli	Harne Port, Dapoli, Ratnagiri	\N	https://www.youtube.com/watch?v=qsZq0azfr9I&t=124s	Sea-side fort built on rocks; offers stunning sea waves, port views & peaceful historic ambiance.	Adjacent to Suvarnadurg; sea-wave photography	\N	45 mins – 1 hour	https://drive.google.com/drive/folders/1z8aKa7U2mycUBmJAnMIwYPDMZI0bgSGc?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
c3721729-043c-428e-8dbe-7e0027ab12c6	38	Fattegad Fort	Dapoli	Harne, Near Murud–Dapoli Road, Ratnagiri	\N	https://www.youtube.com/watch?v=qsZq0azfr9I&t=124s	Small fort near fishing harbor with old gateways & bastions; good for quick visit & marine views.	Historic defense fort, fishermen activities	Nov–Feb	30–45 mins	https://drive.google.com/drive/folders/1emeq85hQFXviTmmx0cmLWzUzsMwTk_ap?usp=sharing	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
9a94c24b-6819-4163-afd2-5f1e0514061b	39	Goa Fort (Gabriel Fort)	Dapoli	Anjarle – Harnai Coastline, Dapoli	\N	https://www.youtube.com/watch?v=DCoEyVk4M5k	Calm old coastal fort with cliffs, sea breeze & scenic ocean landscapes; peaceful & less crowd	Quiet fort with panoramic coastline	Oct–Feb	1 hour	https://drive.google.com/drive/folders/18sV_kxPjwzDX6GWxBtdwX2hErivXoQkk?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
3f36fd00-af3f-4c0c-b32f-571583b3af3c	126	Gangatirth & Hot Water Spring	Rajapur	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1b7rF4GXA4ljFsHF7tvjlUgfyFz62EIdK?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
910b9348-1dcf-439f-9466-794335f3220c	127	Rock Carvings (Rajapur Taluka)	Rajapur	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1V_2XSBiCM8Sgq07youGMcYXz75D4PspI?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
52eabfda-fb63-47b7-aa12-18844064dc47	40	Kelshi	Dapoli	Kelshi Village, Dapoli Taluka, Ratnagiri District, Maharashtra	\N	https://www.instagram.com/reel/DJwfJoLM3Rd/?utm_	Quiet, clean, long beach with soft sand, surrounded by dunes and coconut trees. Known for Yakub Baba Dargah, Mahalaxmi Temple, and beautiful sunsets. One of the most peaceful beaches in Dapoli region.	Clean beaches, dunes, temples, village walks, peaceful offbeat location	Oct–March	2–3 hours (half day if exploring village)	https://drive.google.com/drive/folders/1UgPeF4WYfnljRM9hugmouaGF4CVVPAQA?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
c20d3b7f-6fd8-448d-b53f-8252072ea198	41	Guhagar Beach	Guhagar	Guhagar town, Ratnagiri District	\N	https://www.youtube.com/shorts/Q1p4NxiJpAI	Clean, broad, untouched beach with coconut trees & quiet vibes. Popular with families.	Clean sandy beach.	Oct–Feb	2 hrs	https://drive.google.com/drive/folders/1q4TqkqSk20vfeW6SIyVTM8H85NZYOHpj?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
6cc90cf7-94f1-4dd9-b23e-a7d1f84fd35c	42	Hedvi Dashabhuja Ganpati & Hedvi Beach	Guhagar	Hedvi, Guhagar, Ratnagiri	\N	https://www.instagram.com/reel/DDuO4_2vz2u/?utm_	Unique 10-handed Ganpati idol + serene beach + natural rock gorge (Baman Ghal).	10-hand idol, natural gorge.	Morning	1 hr	https://drive.google.com/drive/folders/18oczlfhWqOgE2fFxieIrlbKnU50dkOB5?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
8529a019-49ff-40e5-b6fd-17870656ff6f	43	Marleshwar Waterfall & Cave Temple	\N	Chiplun – Marleshwar Road, Ratnagiri	\N	https://www.instagram.com/reel/DM7uyZoN8ZP/?utm_	Cave temple in Sahyadri + huge waterfall (especially powerful in monsoon).	Waterfall, Shiva cave, trekking trail.	Half-day	Half-day	https://drive.google.com/drive/folders/151l5ahBWqgPnWJ3IRFq3ShRSc4yTc-gh?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
6872c8f1-98e2-4957-9898-5820ab173470	44	Tilak Gram (Birthplace of Lokmanya Tilak – near Ratnagiri)	\N	Chikhali village, Ratnagiri	\N	https://www.youtube.com/shorts/mRPutYvJ1Yk	Area dedicated to Lokmanya Bal Gangadhar Tilak’s legacy; simple, peaceful, historical.	Historical importance.	Any	30 min	https://drive.google.com/drive/folders/1PFAVfVGNGcgxOjTndUnuFKNQSVCzwFAa?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
8e92317b-bb2f-4ed6-afb2-0253ad80db8a	45	Gopalgad Fort (Anjanvel Fort)	Guhagar	Anjanwel Village, Guhagar–Dabhol Road, Ratnagiri	\N	https://www.instagram.com/reel/DIS2xFgicEI/?utm_	Sea-facing fort with huge walls, cliff edges, and greenery. Great panoramic views.	Sea-view fort, scenic cliff top.	Nov–Feb	1 hr	https://drive.google.com/drive/folders/1rdNWzgvRAihaNiJWQUTTmdYU2uEMv_nC?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
5fc6e252-3728-4b24-8cc8-3f16645d2c6a	46	Baman Ghal (Natural Gorge at Hedvi)	Guhagar	Hedvi, near Dashabhuja Temple, Guhagar	\N	https://www.youtube.com/shorts/i9pb-6tzuxY	Narrow rock gorge where waves shoot up like a fountain during high tide.	Natural gorge + water jet.	High tide	20–30 min	https://drive.google.com/drive/folders/1ZtH7gm-wc-sy3HFnp0-Xq9Wxqq3h2lYV?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
2cd674cd-5c38-4c1b-8698-f2cace66e4d5	47	Palshet Beach (Unexplored)	Guhagar	Palshet Village, Guhagar Taluka, Ratnagiri 415703	\N	https://youtu.be/jUhqfYMu3a8?si=ceTTJS6LZJ_u8VfI	A quiet beach with natural rock formations, minimal crowd, and clean water—ideal for peaceful visits.	Great sunset spot	Anytime	\N	https://drive.google.com/drive/folders/1GZoWb9JD2iiFv8rT9BT3zxjY7qvbPUu-?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
5308cd06-c509-48ea-a595-18b02886b4d3	48	Velneshwar Beach	Guhagar	Velneshwar village, Guhagar taluka, Ratnagiri district, Maharashtra 41572	\N	https://www.youtube.com/watch?v=wn58QnwtuAw	A calm, rock-free sandy beach with clean water, lined with coconut trees — ideal for relaxing, swimming, and long walks. Close to old Shiva temple which gives it spiritual & cultural charm.	Peaceful beach-vibe, safe for swimming, temple + coastal village feel, less crowded compared to main tourist beaches	Oct – Feb (or dry season) for pleasant weather; also good for calm sea & swimming.	\N	https://drive.google.com/drive/folders/18WP7FrQc-1_PfvRmz54fGhxqmkYankmN?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
2412911d-fb9b-48c7-a67e-e6a080d02ff8	49	Sapteshwar temple	Sangameshwar	Sangameshwar Taluka, Ratnagiri	\N	https://www.instagram.com/reel/DRjHrElCDQz/?utm_	Ancient Shiva temple where two rivers meet. Surrounded by greenery.	River confluence, old temple.	Monsoon	30–45 min	https://drive.google.com/drive/folders/1bsFf-ZAznDF0nkTzN6yRip5xGQ5V-vSa?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
e6c0827e-65eb-4211-9d80-0f420ad09811	50	Sangameshwar Kasba Area	Sangameshwar	Sangameshwar (Kasba), Sangameshwar Taluka, Ratnagiri District, Maharashtra — at the confluence of Sonavi & Shastri rivers; PIN ~415611	\N	https://www.instagram.com/reel/DC8XWJwITCa/?utm_	Historic kasba built around several old Hemadpanti temples; sit-down market/townfeel at the river confluence — good for a short cultural stop, local temples (Karneshwar), and seeing inland Konkan life.	River-confluence temples, Hemadpanti architecture, local markets, good en-route stop when driving interior Konkan	Oct–Feb (pleasant weather)	30–90 minutes (walk & temple visits)	https://drive.google.com/drive/folders/1umv_Fxo5CEqc6gOxUDwCdNapB9K8cPrW?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
bc203d92-ced8-4bff-9299-5e6288569e9a	51	Tikaleshwar Temple	Sangameshwar	Talavade village (near Devrukh), Sangameshwar Taluka, Ratnagiri District — hilltop temple reached by ~200 steps; nearest town Devrukh	\N	https://www.instagram.com/reel/DLsJP0Hvrda/?utm_	Small hill-top Shiva temple (Tikaleshwar) above Talavade; short trek / stair-climb to a compact shrine with local devotees — popular during Maha Shivratri and for a quick hilltop view.	Hilltop Shiva temple, short trek (200 steps), local pilgrimage spot; good detour if exploring Marleshwar / Sangameshwar route.	30–45 minutes (including climb)	\N	https://drive.google.com/drive/folders/1s76HraORAQ7Yu7PBDkXv1dsFkNNOz7j2?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
659fecf2-1638-4836-befa-048cb26d1f85	52	Konkan Railway Scenic Viewpoints (Ratnagiri Belt)	Ratnagiri	Ratnagiri–Nivsar–Aadavali region	\N	https://www.youtube.com/shorts/0UuyKtl_mR4	Iconic rail route with tunnels, bridges, Western Ghats valleys — perfect for drone/videos.	Most scenic railway route.	Monsoon	Travel time	https://drive.google.com/drive/folders/17HFfTSMnMheQ_GD5eMFn7B-gXauP86-P?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
73b935c3-f899-4940-8a3a-18f1c6bcc9bf	53	Ambolgad Fort	Rajapur	Ambolgad, Rajapur, Ratnagiri, Maharashtra 416702	\N	https://www.youtube.com/watch?v=iMYhCpSjips	A lesser-known coastal fort with stunning cliffs facing the Arabian Sea. The fort gives panoramic views of the coastline, fishing villages, and untouched nature. Perfect spot for trekking and photography.	Less crowded, raw natural beauty.\n Good for drone photography	Anytime	\N	https://drive.google.com/drive/folders/1m1NqFDMXcVBFHVB9gWJLrhbJXoMMQUck?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
08d4dfa2-da72-4b7b-9696-191aea0cb470	54	Gavkhadi Beach	Rajapur	Gavkhadi, Rajapur Taluka, Ratnagiri	\N	https://www.instagram.com/reel/C7QZnKzoE3Q/?utm_	A peaceful, untouched beach surrounded by greenery and small village settlements. Clear water, soft sand, and zero commercial activity make it an ideal calm escape from city noise. Perfect for quiet sunsets.	Photography, calm walks, local seafood	Oct–Feb	\N	https://drive.google.com/drive/folders/1JI7Zy6z2TrGhl2bG_oPfduy0XgJs2hm_?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
3eb560c7-3b3a-400b-b38c-3620c74eba14	128	Mouje Soundal	Rajapur	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1AvjEhXCoWYXHig7C1Hli88TGaxKoU8tw?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
9dac4d68-5a05-4d20-a6d3-fdb91f40c519	129	Ozar Waterfall (Ghagwadi)	Rajapur	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1SdeKR5cffx6nntUyfoXBWaaVTzQYqbfD?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
c171b369-392e-4897-a897-a1e0406a8ec8	55	Khorninko Dam	Rajapur	Near Tulsani Village, Rajapur Taluka, Ratnagiri District	\N	https://www.youtube.com/shorts/7cyvybL7IbI	Khorninko Dam is a peaceful offbeat reservoir surrounded by lush greenery and hills. Ideal for nature lovers, it offers serene views, calm water, and the perfect ambience for a quiet outing or photography. The area is less crowded, giving a raw village-side experience.	Good for drone shots & landscape photography	Best for morning/evening visits	\N	https://drive.google.com/drive/folders/1-1Xg4cD7Ob4sSMnrIee_hGJd2XGwnCWP?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
75a1173d-9aab-4b01-8305-627d86df6a08	56	Wayangani Beach	\N	Wayangani, Near Devgad–Ratnagiri Road – 416612	\N	https://www.youtube.com/watch?v=NxlW0heF9No	A pristine beach located between Ratnagiri and Devgad. Known for turquoise water, clean sand, very low crowd, and natural rock formations.	Good for peaceful stays & homestays	Winter	\N	https://drive.google.com/drive/folders/1a1zMzVhDTLRPd0EgmJ4LStXVbPu2e4yq?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
e8dccde7-b8f2-4363-b8ae-3b5d07fbadf1	57	Talashi Beach	Rajapur	Talashi Village, Near Rajapur, Ratnagiri District, Maharashtra – 416702	\N	https://www.youtube.com/shorts/aUgUvzHsL-o	A small, silent beach ideal for family visits and peaceful solo trips.	Clean waters and lush surroundings make it perfect for aesthetic reels and shorts.	\N	\N	https://drive.google.com/drive/folders/14QO8Nv01hUDG0Dp7I4NO9IVbQIX6iD3S?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
8125eb2d-b480-41c4-9d75-1f8efdae7236	58	Ambolgad Beach	Rajapur	Ambolgad, Rajapur, Ratnagiri, Maharashtra 416702	\N	https://www.instagram.com/reel/DRZsY6ijAAs/?utm_	A lesser-known coastal fort with stunning cliffs facing the Arabian Sea.	Less crowded, raw natural beauty.	Anytime	\N	https://drive.google.com/drive/folders/1cj2jhuYf8jLGBEgpR1yx9jD3p8Zk4k52?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
484e515a-4f2d-4338-8c9a-61d9aca960b4	59	Loteshwar temple	Khed	Near Lote MIDC area, Khed Taluka, Ratnagiri District, Maharashtra 415722	\N	https://www.instagram.com/reel/DRKHdV9jLfC/?utm_	Ancient Shiva temple known for its peaceful surroundings, simple stone architecture, and serene natural setting. A calm spiritual spot away from the crowds.	Small temple, quiet atmosphere, good for devotees & short visits.	\N	\N	https://drive.google.com/drive/folders/1JVtRKky4cTlL4v2UcByqK6ZtLiC2Hobe?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
935228ff-4fb3-466f-8830-7c1dbd4ef05d	60	Devacha Dongar	Mandangad	Near Mandangad – Dapoli region, Ratnagiri district, Maharashtra	\N	https://www.youtube.com/shorts/n2N_6XFHLks	Devacha Dongar is a stunning hill point in Dapoli, rising about 3,500 meters above sea level. It connects four talukas — Dapoli, Khed, Mahad, and Mandangad — and lies on the border of two districts. The mountain has four settlements mostly inhabited by the Dhangar community. At the centre stands a naturally formed Shankar (Shiva) shrine, which gives the place its name.	The temple is simple, but the surrounding panoramic views are breathtaking. During winter, the cold climate and misty scenery make the experience even more special.	Winter	\N	https://drive.google.com/drive/folders/1eR70l7L0fmadzR73vRgRe3K7i50p7JXT?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
793b110f-c029-4fa6-a65e-e992c12d79d6	61	Mandangad Fort	Mandangad	Mandangad Taluka, Ratnagiri District, Maharashtra 415203	\N	https://www.youtube.com/watch?v=Hui7Alj2EnM	Hill-fort known for its large cannon, ancient bastions, and wide hilltop views. A short trek to reach, surrounded by greenery. Great for beginners.	Ancient fort, trekking point, panoramic views, historic ruins	Nov–Feb	1.5–2 hours	https://drive.google.com/drive/folders/1sw27W_quSAmuWuPu4Q-ieJiWMh2hIIuD?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
95a79209-460f-4eee-bd09-ba47f803dfe3	62	Bankot Fort (Himmatgad)	Mandangad	Bankot village, near Velas – Harihareshwar coastal belt, Ratnagiri district, Maharashtra	\N	https://www.instagram.com/reel/Ce6WZoyIVmv/?utm_	A coastal fort offering sea views, peaceful surroundings, and an old gateway structure. Historically important as a Maratha & Portuguese post.	Sea-fort, photography spot, quiet coastal nature	Oct–Feb	1–1.5 hours	https://drive.google.com/drive/folders/1GcGC6HxJz1p4bxBK3zE4r6rThwKgVPKd?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
8596693b-2901-4315-85dd-6ae3db3cb880	63	Parshuram Temple (Chiplun)	Chiplun	Parshuram, near Chiplun, Ratnagiri	\N	https://www.youtube.com/shorts/ZImCW5GErSw	Traditional wooden temple dedicated to Bhagwan Parshuram; serene and scenic backdrop.	Wooden architecture, religious importance.	Morning	45 min	https://drive.google.com/drive/folders/1bSU4qJyqNP9MJI-sQERUINsqt6UZPHX4?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
07d5a7ad-2cd3-4b9e-b922-6652a24e8402	64	Ambadwe (Ambedkar’s ancestral village & Memorial)	Mandangad	Ambadwe village, approx 13 km from Mandangad, Ratnagiri-Konkan region, Maharashtra	\N	https://www.youtube.com/watch?v=_f-XlI38izY	Village heritage site — birthplace/village of Dr. Babasaheb Ambedkar’s ancestors. The original house is now a memorial / national-monument under development. Good for history, social-heritage, quiet village-atmosphere.	Historical / Heritage / Social importance; off-beat spot away from beaches/forts	\N	\N	https://drive.google.com/drive/folders/1F0BdULSaLlOcvokuLljMDBhEJLfbvog3?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
2058623b-085a-45ec-9b64-7357cdc90547	65	Shri Ram Mandir Pajpandhari	Dapoli	\N	https://www.instagram.com/reel/DQolcBdgZMz/?utm_	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/13azBidWYiNTDHR57hwkSgDJ-uRv3xZ47?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
e51d1339-f051-4e04-a2b5-6ba8d0c1edbc	66	Panhale Durg Fort	Dapoli	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/189j68DYhSmvDicXpAq7TzJI8AY27JKHf?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
e6be857d-3d0e-4824-be35-0ad04f9d7a60	67	Palgad	Dapoli	Near Dapoli, Ratnagiri district, Konkan region, Maharashtra	\N	https://www.youtube.com/watch?v=958a8lF-MVg	Old fort ruins/hill-fort site offering countryside / forest / hill-fort experience. Good for trekking, exploring lesser-visited heritage locations away from crowds.	Offbeat heritage/fort, trekking, natural surroundings, less commercial — good for travellers seeking quiet, less-touristed forts	\N	\N	https://drive.google.com/drive/folders/1X_x-nHZymW1EE7Dq6Qv9fQTAfZ8Vaeb1?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
026713fd-5618-4a15-8321-9378efb07f55	68	Unhavare Hot Water Springs	Dapoli	Unhavare Village, Near Dapoli, Ratnagiri District, Maharashtra 415712	\N	https://www.youtube.com/shorts/oxPQo61LuBc	Natural sulphur hot springs located in a peaceful valley surrounded by greenery. Water remains warm throughout the year. Believed to have skin-healing and medicinal properties. Calm, rural atmosphere — perfect for relaxing and nature experience.	Natural hot water springs, sulphur-rich medicinal water, village/rural Konkan experience	\N	\N	https://drive.google.com/drive/folders/1hluAhc0MA2EIY9qhnvYNZDEZu9aUU9t7?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
e2885811-a894-4346-8d8b-c1a547ba7fb3	69	Murud	Dapoli	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1u6QIzHwEqgZl9cpSbWW_gPE54ffWiPaq?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
7d26da43-58f4-4c27-9a5a-c9f9bce8cd72	70	Vanand Village	Dapoli	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/13u-zveHOu3McbwHD9xmgUUU1jjpV3VrK?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
af85867b-d13c-4bfb-b981-3be81f3fabf0	71	Nageshwar temple, Chorvane	Khed	Nageshwar ,Choravane,Tal.Khed Maharashtra 415718, India	\N	https://www.instagram.com/reel/CuPRONzgynE/?utm_	Ancient Shiva temple surrounded by greenery; peaceful riverside atmosphere. Popular among locals for darshan, meditation, and Shivratri visits.	Old heritage temple, calm surroundings, spiritual ambience	09:00 AM to 05:00 PM	\N	https://drive.google.com/drive/folders/1jS-0NQ4nRLMTMgXGSwhpKPNPMK6ewPuX?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
300d8e11-b211-4e61-bf1d-130084e2f3a7	72	Shree ramvardayani mandir, chorvane	Khed	Chorvane village, Tal.Khed, Ratnagiri district, Maharashtra (Konkan region)	\N	https://www.youtube.com/shorts/-HX_O_n7cxM	Local temple — likely of regional importance; potential for rural-temple ambience and insight into local religious/cultural life.	Village temple, rural Konkan culture, authentic local experience	\N	\N	https://drive.google.com/drive/folders/1n4hJABGsWXJ7YRJR4V4tu70E87-7zUyt?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
a51df09c-9aae-45b4-bbba-2bbabbc94b94	73	Kartel	Khed	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1qRxIRnca1YLa6a6Cy15e3NIDy3uMZfBV?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
6db91aca-85e2-414e-b288-9a9ff65d13de	74	Wadibeldar	Khed	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1UGa_aQ1_leYUAyIhIwmbgVk_H4KyOIgv?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
f0c955ab-e507-459e-b5f0-a714cef64045	75	Songaon Mangrove Ecotourism & Crocodile Safari	Khed	Songav, Tal, Khed, Maharashtra 415722, India	\N	https://www.instagram.com/reel/DDFCXlTzt_L/?utm_	Good for rural tourism, nature walks, small temples, local culture & village life experiences. Offers peaceful, non-touristy environment.	Peaceful environment, village lifestyle, and access to nearby Khed attractions.	\N	\N	https://drive.google.com/drive/folders/1XDB1vfUYhUprFzwJZkWoppWQ1OG4-9HV?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
7eb6930b-8c4b-46da-9f94-13503de84d20	76	Bhuleshwar Shiva Temple, Furus Khed	Khed	Furus Village, Khed Taluka, Ratnagiri District, Maharashtra	\N	https://www.instagram.com/reel/ChbXvQaov4Z/?utm_	A small old Shiva temple located in a calm forested area of Furus. Known for its peaceful atmosphere, local devotion, and typical Konkan stone-temple style. Good for a quiet spiritual stop.	Local Shiva temple; calm ambience; village-side spiritual point	\N	\N	https://drive.google.com/drive/folders/1BjzQXUlDc-NiTC9Gx48LpOipEHWGllR3?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
6f243765-d608-4b5c-a1a7-275637fb788e	77	Mahipatgad	Khed	East of Khed Taluka, near the Rasalgad–Sumargad mountain range in Maharashtra.	\N	https://www.instagram.com/p/C14OZBkJRv3/?utm_	One of the tallest and largest forts in the region, spread across 120 acres. It has natural cliff protection, remains of six ancient gates, a large Pareshwar Temple, and a freshwater well. Built and repaired during Shivaji Maharaj’s era.	Hill fort trek, historical significance, Pareshwar Temple, scenic views, and connection to Shivaji Maharaj & Ramdas Swami.	\N	\N	https://drive.google.com/drive/folders/1Sb_ORRm5yUuVawHy8fJz9Kvdd5cMUGbT?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
249c141e-0c8b-424c-b718-1f6502cab1b4	78	Sumargad	Khed	Wadi – Jaitapur region, Khed Taluka, Ratnagiri District, Maharashtra	\N	https://www.instagram.com/reel/CxmlHgBo1Xy/?utm_	One of the least explored treks in Ratnagiri. Offers rocky patches, lush greenery, cliff views, forest trails & raw Konkan wilderness. Suitable for trekkers who enjoy offbeat, non-commercial trails.	Offbeat trek, views of surrounding Sahyadri ranges, dense forest route, peaceful summit, no commercialization	\N	\N	https://drive.google.com/drive/folders/1kWvIVvWHaDeZ5keuaHVxxLodRSzo81D2?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
4f6a9b79-63ac-4404-a23e-2cd8812e8f75	79	Rasalgad	Khed	Khed Taluka, Ratnagiri District, Maharashtra	\N	https://www.instagram.com/reel/DJtuquvobAT/?utm_	Historic Maratha-era fort once captured by Chhatrapati Shivaji Maharaj (from the More clan of Javli).Scenic views: you can see neighbouring forts Suamargad and Mahipatgad from Rasalgad — forming a triangular-spur of forts.	Easy trek + historic ambiance + temple + old fort architecture — good for beginners, families, and heritage-lovers.	\N	\N	https://drive.google.com/drive/folders/1cBNhdFK9kvAmvUsIZJu4AhjMcPoHoVpF?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
c60d08f2-d434-4c21-99ce-09ae3d91fe96	80	Paldurg Fort	Khed	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1kUFO7uPV_Fap45qvWK-p3P9mG79AjUT8?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
0ffbce4d-9b59-4d04-973f-f39a0f756422	81	Raghuveer Ghat	Khed	Khed Taluka, Ratnagiri District, Maharashtra	\N	https://www.youtube.com/shorts/Hz43FluXgj8	The ghat lies roughly 1,400 m above sea level, in the lap of the Sahyadri Range — surrounded by lush green hills, forests and seasonal waterfalls.The area also forms part of a biologically rich zone — home to rare species such as the freshwater crab Gubernatoriana thackerayi, first recorded here.	Scenic natural beauty — hills, forests, waterfalls and misty landscapes.	\N	\N	https://drive.google.com/drive/folders/1Q0OyvP7atGJKdqT6W6wC2LHGF3vQkcGV?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
f30631dd-920e-48d7-a99e-9762e7beec1c	82	Caves at Khed	Khed	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1ifnj4c0yhBkkxc49Vs65SUQ7My8Skq4F?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
51675df7-f69e-49d8-bdbd-cf8f52ec57fd	83	Shri Kalkai Temple (Bharane)	Khed	Bharane village, Taluka Khed, Ratnagiri district, Maharashtra	\N	https://www.instagram.com/reel/DO6L-TcjEOC/?utm_	Local village-temple of Kalkai Devi. Temple premises, village ambience — good for spiritual visit and village-level Konkan culture.	Local/folk temple — possibly visited by locals; may offer rural Konkan-temple experience	\N	\N	https://drive.google.com/drive/folders/13KQbCnZOpopl3I4EncQ2JaC-bUKBhEL7?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
2abd775c-de0a-4c14-8278-05657f08a248	84	Niribaji Waterfall (Khandoshi Village)	Khed	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/16vYYpaoystMxiI-lVNEjh381-LyohASz?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
10a953c1-ede9-40b5-819f-30d2f4340558	85	Anari	Chiplun	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/10UUSngeR7ptKlqCUiK_MsIQBzcKdsnh3?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
3e5658e4-00f6-45a4-a316-4070d82d51fe	86	Dalwatne	Chiplun	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1zNsCVaOIgrc4TaNbhH9KvFbPtgS8EgkW?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
84ba048d-251e-4094-a438-a6d25e6d6851	87	Gandhareshwar	Chiplun	Muradpur, Chiplun, Maharashtra 415605, India.	\N	https://www.instagram.com/reel/DQIywmWEx1x/?igsh=	Good for religious/cultural visit; may also reflect local village/town heritage and architecture.	Local-temple heritage, community worship, potential traditional festivals / rituals	\N	\N	https://drive.google.com/drive/folders/1bqf_E7FR5mcLlEHZgPthu4y4I9LDmVZ_?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
ef11425f-42d5-4e10-947a-46a33de616fa	88	Adare	Chiplun	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1Xx00jh1w3SAl0u7M-oMVlbOaAoDumQUp?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
599781de-88f4-436e-aff5-431bdc758b1f	89	Goval Kot Fort	Chiplun	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1O_qL4rReqVx7VwAWUoAvjF2ho0RZNdKM?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
13bfd3d3-7206-49d2-9b22-0909a9d2f125	90	Kolkewadi Durg	Chiplun	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1i14cngMpEao6jGl8MX9reelqIL8LLGQ-?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
0dc4d47a-cea4-45ec-807b-0b29bf6d41d8	91	Bhairavgad	Chiplun	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1aspsQW4LYEjuB_MZWzBFUJRu01iW-0rn?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
3dc61452-7b30-498b-9705-62c9259440e7	92	Derwan	Chiplun	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1H3vOyysLQgGEuSrJM3qrIYxPmQ9_QLNM?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
0a67dc80-2964-474a-98c8-3c817d588d46	93	Sawatsada Waterfall	Chiplun	Near Parshuram Ghat, NH-66 Highway, Chiplun, Ratnagiri District, Maharashtra	\N	https://www.instagram.com/reel/DNk3hWCypDp/?utm_source=ig_web_button_share_sheet	A popular seasonal waterfall visible right from the highway near Parshuram Ghat. Becomes huge & powerful in monsoon. Easy to access, perfect for photography, a quick stopover, and enjoying misty valley views.	Highway waterfall, monsoon hotspot, roadside viewpoint, safe & easy access	Sapteshwar temple	\N	https://drive.google.com/drive/folders/1HozG8llRsDsC8aTGY0-QfKKi_ZfL7d4z?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
2b1b8241-e776-44c0-aba0-c57b201842cf	94	Sharada Devi Temple (Turambav)	Chiplun	Turambav, Chiplun, Ratnagiri 415641, Maharashtra.	\N	https://www.youtube.com/shorts/ytZfMMroTlw	The temple architecture is notable built in a Rajasthani style, with carved marble stones, a dome-shaped chautara (central pavilion), and multiple deities: besides the main idol of Sharada Devi, there are idols of village-goddesses like Vardayini, Manai, and Chandika. A popular seasonal waterfall visible right from the highway near Parshuram Ghat. Becomes huge & powerful in monsoon. Easy to access, perfect for photography, a quick stopover, and enjoying misty valley views.	Spiritual ambiance, Sharda Devi idol, festivals, and scenic temple surroundings.	6:00 AM – 6:00 PM	\N	https://drive.google.com/drive/folders/1-JUTzDgLuQSs0ja6fdvkfRcvQ0xNCAvY?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
b7173293-a743-4cc2-bdb4-edfd135d7fe2	95	Kulswamini Bhavani Waghjai Temple (Terev)	Chiplun	Terav village, Taluka Chiplun, District Ratnagiri, Maharashtra — PIN 415605	\N	https://www.instagram.com/reel/DPLHvUCkc_T/?utm_	The main idol of Goddess Bhawani is a black-stone statue about 9 ft tall, holding weapons and symbolising the defeat of the demon. It’s the only temple in Maharashtra where all nine forms of Goddess Navadurga are installed. Strong cultural and local significance: devotees come especially during festivals.	For peace, greenery and good weather — post-monsoon and winter months are ideal, when the surrounding hills and village look very scenic.	\N	\N	https://drive.google.com/drive/folders/1Xihh96rB10EdMcbamLBF4svK25n1OZ5S?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
be0b5fa0-442f-4843-a7a0-9115f08dff9c	96	Devi Karanjeshwari Temple (Goval Kot)	Chiplun	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1BU4Q1iadsSJuc1mgbAiIatxsw_gSQtqB?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
604ef05b-e019-40c2-846b-54fb36681828	97	Pandav-era Caves, Peer Baba Dargah	Chiplun	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1pmAx4caiBAisjq6yGoi7ZR4R8Ak1P5Xp?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
6b4a1975-c47b-463e-b90f-b1044a3b63b2	98	Vijaygad	Guhagar	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1DG5m1wmPBcNpxBx4p-DG12j1kI05yQzd?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
3c19d46c-ad7b-4096-96df-0ed8f1252aca	99	Modka Depot	Guhagar	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1iUVrKrTC0nQA9CEh2hBITl4MZrWHk1N_?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
a6a2f75d-5b39-4ec3-aa6e-e16cbaa1853f	100	Durga Devi Temple (Budhal)	Guhagar	\N	\N	https://www.youtube.com/shorts/XSe8dL5l4xY	\N	\N	\N	\N	https://drive.google.com/drive/folders/1IMX-apoaKUFCtwGaAsPGXg8fHa3nfV99?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
390ff753-8621-4b85-8587-b893f45ed3a9	101	Kotaluk	Guhagar	\N	\N	https://www.instagram.com/reel/DQokr_kjGSR/?utm_	\N	\N	\N	\N	https://drive.google.com/drive/folders/1b7LlGK4Pd20EELBbPJtO3O0svjQAruHk?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
5e01ff68-b55c-4e00-8631-cc1796666b43	102	Varaveli- Vervali	Guhagar	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/159z_PtojkIcOxWlEUF79mf9HkfVy171W?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
bb2a1915-81ae-4a8e-bb98-3878bd2895a6	103	Sakhari Depot	Guhagar	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1Oi2nmYVvNl1LyFS5-nDgTB9KSpLaSS0B?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
f6f430be-0bc0-44be-99d8-ac0a6a988b29	104	Shirgaon	Guhagar	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1rAbAeybNwBOQFXBLU88xHxJJqknw5ivb?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
a65cd4f9-20c0-4f7b-a7f6-2149a0fba600	105	Bhavanigad	Sangameshwar	\N	\N	https://www.youtube.com/watch?v=uBi8O-OApIQ	\N	\N	\N	\N	https://drive.google.com/drive/folders/1VTylcXPnvJrjaGS0COQzbodqNhBZscjp?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
ad911fef-02bf-4455-914a-622114bea312	106	Prachitgad	Sangameshwar	\N	\N	https://www.instagram.com/reel/DQst8B6jF7L/?igsh=	\N	\N	\N	\N	https://drive.google.com/drive/folders/1cAnFbd6lPQtwxUisHL9D6ZXn4ce6Kj3q?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
bd1b1829-6268-4df5-9759-a002d2391a0c	107	Mahipatgad	Sangameshwar	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1y4J53_OoDTZHMvgLURWRGvYH111DaTsA?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
dedd6484-8617-489d-8218-b65bc80f912b	108	Shri Karneshwar Temple	Sangameshwar	Kasaba - Kalambaste Rd, \nKasaba, Wada Thikanat, \nSangameshwar,\nRatnagiri,\nMaharashtra	\N	https://www.instagram.com/reel/DNGB_uhsCX-/?igsh=	\N	\N	\N	\N	https://drive.google.com/drive/folders/1ejiIGtU-r4ZfC-3h9qhrC2Q70SaeDoGX?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
1e4a8fe6-0cf6-4232-9cff-3e5383db59cc	109	Machal	Lanja	Machal Village, Tal.Lanja, Ratnagiri	\N	https://www.instagram.com/reel/DKJGKVUzaBF/?utm_	\N	\N	\N	\N	https://drive.google.com/drive/folders/1cUzvzBM3tycSTD3gg1XURoFuqL4vHQPL?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
175c433f-0194-40b9-84ae-a4c45b6a35e8	110	Math	Lanja	\N	\N	https://www.youtube.com/shorts/R7soNPuu_wI	\N	\N	\N	\N	https://drive.google.com/drive/folders/1EPoD_wN9eitEamLko6zk7tPKQnEEbNgp?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
be593e46-1043-427e-aa32-3a862e947c47	111	Satavali Fort	Lanja	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1Cu537w54qRbs0y4zFh6y2KsPBdlc-NwY?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
0f0b9355-23ce-4af1-b578-a2fc9fb2be60	112	Rani Laxmibai Memorial (Mouje Kot)	Lanja	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/173B1BBGm1jaDQsE5TEcm68iAXKcuMTKf?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
99b56988-bf76-4faf-8046-49ab8bf351c8	113	Gangu’s Bowl (Bapere Zorewadi)	Lanja	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1ZfhHUx_uB7bOM91Jmc2DwbtpQoXsAKP6?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
7b0cd3e0-0552-4ab3-aba4-292260be9b80	114	Pawas	Ratnagiri	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1F4NeFU5hxU-1KJB0V0v3pK_MEaFugdfR?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
ef0d074a-74cc-407b-8298-065ebc44f9bc	115	Hatis	Ratnagiri	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1MuyowmOXSDXEy4kQtXVQ6hruxh7CWvnP?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
8fdab277-33d5-4245-9f57-e12db3a66010	116	Ratnagiri City	Ratnagiri	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1v14YyDnBbLVtcKi2HtS6mLXQLJj4ToJb?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
fb3cd14f-0a6d-4abf-ac59-95658d86afad	117	Nirul	Ratnagiri	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1Ek_KWbac-w0eSYjJdZvoKpzdxyViyk6X?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
d9dc8563-b098-4866-a50b-eb695bd93ae9	118	Nivali Waterfall	Ratnagiri	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1Ftqj9yyz1IaPfqQtEYNtxypQc7_KTANQ?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
87d96e6f-5e0c-440e-a272-bd7b43fa1ce9	119	Kalbadevi Temple and Beach	Ratnagiri	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1z_zeN7BFlYuk5uX4ZSK1Jjkk6sYyDOjq?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
3e6c3d73-5644-4e71-8375-96fc4d721083	120	Shil Dam	Ratnagiri	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1L_lWqicjfs4PjXMyUnf-6tn91Zt5svLl?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
71ad5e78-fd5f-479b-bd7a-1c742278ce7e	121	Rantal	Rajapur	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1FBa-n4NoRVMXeASggCL6RPb9PRFC9D8_?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
e5b58d71-5e9a-4b59-a401-6c6d7d1ebe2e	122	Dhopeshwar Temple	Rajapur	Dhopeshwar village, Tal. Rajapur, Dist. Ratnagiri	\N	https://www.instagram.com/reel/DK6Api5oUwx/?igsh=	The sacred energy here truly makes you feel the presence of Lord Shambhu Mahadev. The temple premises also include shrines of Lord Dattatreya and Kalbhairav. The temple was recently renovated, using stone, wood, colours and lighting that recreate an atmosphere from 200–300 years ago. The sabhamandap (assembly hall) was added during the Peshwa era.	During the monsoon, the scenery around the temple becomes extremely beautiful.	July to November	\N	https://drive.google.com/drive/folders/1Yh-q3XV5LLafZ5k66jnOSYJvQUe20oIS?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
3a9d2f40-2c67-441d-ac2c-3032ebc88104	123	Chunakolwan	Rajapur	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1MfOPUweBAgZ1Sjz-uZdbSnFXTxhdyj2I?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
fad44e7c-a1b2-4279-975a-425479fcb5dc	124	Yashwantgad	Rajapur	\N	\N	\N	\N	\N	\N	\N	https://drive.google.com/drive/folders/1xTSQBOnZt_RCLnLJUYaB98JyRpc_EnzR?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
42eb5661-e44d-42f1-927f-29f20d1daca6	130	Savatkada waterfall	Rajapur	\N	\N	https://www.instagram.com/reel/DK4kt12oXtF/?utm_	\N	\N	\N	\N	https://drive.google.com/drive/folders/1Y5uOA-JdnWyaiUyxLK-8M8bvduW9h55s?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
f212df40-bc00-41d4-b5ad-2a0566ccbabf	131	Phansavle Bridge	Ratnagiri	Phansavle Village, Ratnagiri- 415612	\N	https://www.instagram.com/reel/DRWDdnwiGLZ/?utm_	\N	\N	\N	\N	https://drive.google.com/drive/folders/1re4bNbYG7TAxgIBVt1nRTmhG8V5OaFH5?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
b6467f3d-03ee-4c5d-9253-08d017ef3282	132	Patit Pavan Temple	Ratnagiri	\N	\N	https://www.instagram.com/reel/C70bLCdIYJY/?utm_	Swatantryaveer Savarkar stayed in Ratnagiri for 16 years wherein he built Patit Pavan Temple. This temple was built for people who were considered untouchable or inferior. A man of any caste had an access to the innermost part (gabhara) of the temple. On the request of Savarkar, Mr. Bhagoji Sheth Keer built this temple by spending about ₹ 1.5 lakhs. This temple was completed in 1931.	This temple of Laxmi and Vishnu is in the heart of the town of Ratnagiri in coastal Maharashtra. It was inaugurated in 1931 and is the first temple in India open to Hindus of all castes.	\N	\N	https://drive.google.com/drive/folders/1lPb_ElJOdhSUsHeEyruo1hJq5lJF6Bmb?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
5da8a3e2-3245-4381-8176-64c2d9593160	133	Mallika arjun temple	Chiplun	\N	\N	https://www.instagram.com/reel/DNOGRHUoG1f/?utm_	\N	\N	\N	\N	https://drive.google.com/drive/folders/12h49Jby7mD_xDluYc7x6rrno-j4N2iT1?usp=drive_link	\N	t	2025-12-24 04:37:31.431024+00	2025-12-24 04:37:31.431024+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.users (id, full_name, email, phone, role, language, avatar_url, is_verified, created_at, updated_at, firebase_uid, taluka, district, aadhar_number_encrypted, aadhar_verification_status, aadhar_verified_at, verification_method, verification_reference_id, verification_attempts, verification_failure_reason, aadhar_document_url, last_verification_attempt) FROM stdin;
80c23ebd-8730-475d-bf71-15064462afa6	newhomestay	newhomestay@homestay.com	\N	tourist	en	\N	f	2025-12-15 04:34:18.449724+00	2025-12-15 04:34:18.449724+00	GmXtHm82C6XzEMG72QRLCH6Ph1Y2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
7a0ff23c-4354-4409-8ac2-a63040ed7aa2	New Test User	newuser@example.com	8765432109	homestay-owner	en	\N	f	2025-11-29 19:43:52.972762+00	2025-11-29 19:43:52.972762+00	test-firebase-uid-new-456	Chiplun	Ratnagiri	\N	pending	\N	\N	\N	0	\N	\N	\N
e2d01f94-0d05-4054-908e-1176b7feb79a	Test User	test@example.com	7234567890	tourist	en	\N	f	2025-11-29 19:50:08.355008+00	2025-11-29 19:50:08.355008+00	jTRDNOAjPISVnoeE6bZeqPHGtZG3	Malvan	Sindhudurg	\N	pending	\N	\N	\N	0	\N	\N	\N
123a290c-4856-4f06-8667-ded7e0d83f56	tourist	tourist@tourist.com	\N	tourist	en	\N	f	2025-12-15 05:06:18.772211+00	2025-12-15 05:06:18.772211+00	XvDBUwQveBYnNN30fT3Wrz116Z33	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
2d6fb4b4-472e-42ab-9416-ccffd44cef18	testtourist	testtourist@gmail.com	\N	tourist	en	\N	f	2025-12-15 20:31:19.93455+00	2025-12-15 20:31:19.93455+00	ni89hQRHFggFkEzLhkla7CCuORV2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
fe4b1684-d7f0-4309-9d27-f4764fd732dc	Test User	tourist@gmail.com	9876543210	tourist	en	\N	f	2025-11-29 19:43:30.935592+00	2025-12-10 04:23:51.486253+00	Kz0pmeeY2JOOkE9B5AWHu3vxLIM2	Malvan	Sindhudurg	\N	pending	\N	\N	\N	0	\N	\N	\N
0cb42175-4e38-4ee3-b7f8-777cec39c6bd	Zek Furtado	zekfurtado2303@gmail.com	9434532345	admin	en	\N	t	2025-11-09 19:55:52.944281+00	2025-12-11 06:32:17.571688+00	J5TROvXYTahgnB0hywjDOOsTYYi2	Unknown	Unknown	\N	failed	\N	manual	\N	18	Verification failed through all available methods	\N	2025-12-11 06:32:17.571688+00
39bf573c-852b-4379-9025-fd1d61ed4320	test-homestay	test-homestay@gmail.com	\N	homestay-owner	en	\N	f	2025-12-04 11:46:26.206603+00	2025-12-11 09:16:44.540333+00	mJtI6AoIEkTnTujvgRUpZqHjWWH2	Unknown	Unknown	\N	verified	2025-12-11 09:16:44.540333+00	manual	MANUAL_1765444604444_J5TROvXYTahgnB0hywjDOOsTYYi2	0	\N	\N	\N
aff37f34-bb31-40c3-8594-8ceb43cfb147	apurv	apurv@gmail.com	\N	tourist	en	\N	f	2025-12-11 09:33:55.085339+00	2025-12-11 09:33:55.085339+00	AteRiyLpw0OH31QDZ9LmgebVCbH2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
822e6bb1-3ef9-47e1-86a0-5232d8c3fadc	newtourist	newtourist@gmail.com	\N	tourist	en	\N	f	2025-12-12 13:00:46.880842+00	2025-12-12 13:00:46.880842+00	jdbYVNkNTzeoFY62UYEUWWsKJPH3	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
5b66e2b1-8d2c-437c-aad4-c9834cddb523	Test Register	testregister@gmail.com	9323526532	tourist	en	\N	f	2025-12-12 13:06:29.467893+00	2025-12-12 13:06:29.467893+00	osqlSJonGQbwUXp9BCSXBNTr1082	Malvan	Sindhudurg	\N	pending	\N	\N	\N	0	\N	\N	\N
be6294ef-8a15-4f3a-a658-892cff593ef1	Test Tourist	johndoe@tourists.com	9847563271	tourist	en	\N	f	2025-12-15 21:57:47.626086+00	2025-12-15 21:57:47.626086+00	HVd0uDdlIAaRPakkGASr2ysonX63	Sangameshwar	Ratnagiri	\N	pending	\N	\N	\N	0	\N	\N	\N
1c773a03-fad9-4e63-9814-1a5d8ef17aba	Jane	janetourist@gmail.com	9458673281	tourist	en	\N	f	2025-12-16 04:50:13.879546+00	2025-12-16 04:50:13.879546+00	Rql3zcWz6SVhDx9hbufZ1TnwhDH3	Chiplun	Ratnagiri	\N	pending	\N	\N	\N	0	\N	\N	\N
8e1fbd34-5fce-43cf-b067-37b62537545f	Jane	janet@gmail.com	\N	tourist	en	\N	f	2025-12-16 05:48:36.906367+00	2025-12-16 05:48:36.906367+00	VJT0kvSE9OQKTpzj9NxrrpXcTvm2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
d9f7b438-a020-45b3-89f4-e70236bd80bf	Scott Lang	scott@gmail.com	\N	tourist	en	\N	f	2025-12-16 06:52:36.514089+00	2025-12-16 06:52:36.514089+00	7EZCPN8qpFQFPuDwcDU5OxYvqNH2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
046efd1b-60d0-4021-b4c3-df8e896c601a	tourist	touriest@gmaoikc.com	\N	tourist	en	\N	f	2025-12-20 09:37:25.900313+00	2025-12-20 09:37:25.900313+00	usWijRQ4WOOgQ8fElfJwPjXyWBB2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
499b4ebd-7cae-48d1-b56b-ef2c5a71735c	touriststs	toriststs@gmail.com	\N	tourist	en	\N	f	2025-12-20 09:38:12.931215+00	2025-12-20 09:38:12.931215+00	PKM0Y4KvdRWCAb23Lm5nqEV4BzC2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
20ab9f55-964a-450d-9d34-01d9986047f6	tourists	toursts@gmail.com	\N	tourist	en	\N	f	2025-12-20 09:44:28.904911+00	2025-12-20 09:44:28.904911+00	AX9CZykaM4h50kpK8yjU6cnvISu2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
222e1d78-0206-4ba0-a981-0991898642e2	qwetyqew	qewqwer@portal.com	\N	tourist	en	\N	f	2025-12-20 09:55:35.941651+00	2025-12-20 09:55:35.941651+00	c2FlDBl7tTSY1xGXBhSMYaSpUig2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
a2b1f09a-c835-4c88-a4ce-0ca8a2a32fe5	artisan	artisan@portal.com	\N	tourist	en	\N	f	2025-12-20 09:59:49.945817+00	2025-12-20 09:59:49.945817+00	8j46wQSKd8fqBKySkei3FB0T2Ty1	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
ca328604-56e2-4993-b3b8-de3402ee4ebd	testt	tetststs@gagta.com	\N	tourist	en	\N	f	2025-12-20 10:08:28.810724+00	2025-12-20 10:08:28.810724+00	XPV8FUmjYlaLZoUWXQrWAKEmawi1	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
a26d4e5b-47f3-40a0-937c-17d4202a1366	test	tetsstst@gmail.com	\N	tourist	en	\N	f	2025-12-20 10:12:29.906183+00	2025-12-20 10:12:29.906183+00	EEJTtsc8BeXMSsDVTlspbSEmJgX2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
1c85d777-fde9-4f0e-bc39-25081053a018	testsets	testesest@gmailc.om	\N	tourist	en	\N	f	2025-12-20 10:17:26.132771+00	2025-12-20 10:17:26.132771+00	FgYN180KwPPVYahaxtf8l6DtGle2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
a48d6122-61c8-4365-9fb6-6c6ad1a032aa	atest	qwertrewq@portal.com	\N	tourist	en	\N	f	2025-12-20 10:20:26.090988+00	2025-12-20 10:20:26.090988+00	Z5NETVcVn7WGaSPHTITBEIZibvb2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
627dec2c-599d-441a-8f28-f81d53f7ec74	Test Tourist	johdowe@tourists.com	9323522332	tourist	en	\N	f	2025-12-20 10:23:35.243176+00	2025-12-20 10:23:35.243176+00	Bx5HvPfSsoWliJzWLmfEsb4iLqC2	Malvan	Sindhudurg	\N	pending	\N	\N	\N	0	\N	\N	\N
2cb60061-5756-4082-8623-f54710fa9bf8	testtesttesttest	qazswx@qazxsw.com	\N	tourist	en	\N	f	2025-12-20 10:27:58.697712+00	2025-12-20 10:27:58.697712+00	8f6PvnOfBCWTgqHFx9bP2p4eHRs2	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
62f21762-3ab1-4ceb-a9e3-e6590c22a5a3	tsaetea	qweqweqe@qw.com	\N	tourist	en	\N	f	2025-12-20 10:30:54.422819+00	2025-12-20 10:30:54.422819+00	L0QCeXqM7edXnkVvDcxcHVoKLFA3	Unknown	Unknown	\N	pending	\N	\N	\N	0	\N	\N	\N
\.


--
-- Data for Name: verifications; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.verifications (id, entity_type, entity_id, status, notes, reviewed_by, updated_at) FROM stdin;
\.


--
-- Data for Name: village_gram_panchayat; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.village_gram_panchayat (village_id, gram_panchayat_id) FROM stdin;
\.


--
-- Data for Name: villages; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.villages (id, taluka_id, block_id, name, village_code, population, is_coastal, is_active, created_at, updated_at) FROM stdin;
34da8199-fc9f-4aaf-b9de-a1e2d44f20d2	7e396c87-09c4-430e-90c3-a3236b4e1bf6	\N	Ganpatipule	RTN001	1456	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
6e8063f8-f19c-42da-813b-a5d7bde6b530	7e396c87-09c4-430e-90c3-a3236b4e1bf6	\N	Pawas	RTN002	2876	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
8f309425-5296-4edf-844c-d7dbec4d01e2	7e396c87-09c4-430e-90c3-a3236b4e1bf6	\N	Rajapur	RTN003	3245	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
29f741fa-d55d-4611-baa3-157063c70085	7e396c87-09c4-430e-90c3-a3236b4e1bf6	\N	Bhatye	RTN004	2187	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
8433559d-08f5-4742-bf91-4403c1a29e68	374f5ff0-c733-4e1d-9e85-a098085cfd97	\N	Murud	DPL001	3245	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
7735c62b-1565-4969-866e-ae990c98443e	374f5ff0-c733-4e1d-9e85-a098085cfd97	\N	Harnai	DPL002	4156	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
1caeaf1d-a76e-4b8f-b600-17ff88521c07	374f5ff0-c733-4e1d-9e85-a098085cfd97	\N	Anjarle	DPL003	2187	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
f0c35014-a040-4ec3-82e5-fdc0f3ef1b4b	374f5ff0-c733-4e1d-9e85-a098085cfd97	\N	Kelshi	DPL004	1456	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
700031b0-5d23-492c-9062-d1547bbb90e5	374f5ff0-c733-4e1d-9e85-a098085cfd97	\N	Ladghar	DPL005	998	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
a0ff1e8e-766d-42f5-81f1-7e654c3cb841	c1f2e096-cfcc-4680-805e-b48ca5483ecf	\N	Guhagar	GUH001	6747	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
4ba90252-a08b-47c9-8ae8-ea17d021f653	c1f2e096-cfcc-4680-805e-b48ca5483ecf	\N	Velas	GUH002	1876	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
f8666bec-6d5c-4105-8b52-6474177e45f1	c1f2e096-cfcc-4680-805e-b48ca5483ecf	\N	Hedvi	GUH003	2134	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
378ad2b3-8928-47c1-8c81-589db5cc766b	b66e24bc-8cf7-4255-81fa-9013ce550f24	\N	Aravali	MND001	1823	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
0eda13cc-4528-4ce0-b6c0-242c365aba22	b66e24bc-8cf7-4255-81fa-9013ce550f24	\N	Kondivli	MND002	2456	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
2db29390-f0a6-43aa-8ccd-6c4319a6632f	69a8e70e-13e0-41b7-bda3-bab400777726	\N	Lanja	LNJ001	4567	f	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
b39a644d-24b8-49ac-9fc1-fc87af1bb3a9	8052b0aa-cb60-4c46-ac4c-2e747e0dbbfe	\N	Marleshwar	SGM001	3456	f	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
d1176963-f56a-4899-9a8c-79a7e6cceabe	1ace7e58-43bb-43dd-bea2-c53e2a331ff4	\N	Masure	KDL001	2456	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
acf750fc-95f5-4472-a7df-6662d5da9ac8	1ace7e58-43bb-43dd-bea2-c53e2a331ff4	\N	Banda	KDL002	1876	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
f61d941c-ff5f-44b4-a3d6-79ed883e1baf	84b8902f-bc95-4c50-97b3-b8de62941a74	\N	Sawantwadi	SWT001	28690	f	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
43f5b61e-10be-48a0-9ee8-4624ca904ce9	7229eaa3-33c5-4ce1-a545-9db4263ae324	\N	Dodamarg	DDM001	4567	f	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
80e5813a-0445-4a41-870f-aa11cfdf8551	3c44b5c7-6bd1-4945-9cd8-c21622fe17c8	\N	Banda	KNK001	2134	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
65421e63-54eb-4908-b931-9ba418533486	01bc2bc9-77a8-403d-887c-8a0711248452	\N	Malvan	MLV001	15881	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
c54a506d-8ca3-4d22-b115-bd91b45aaf57	01bc2bc9-77a8-403d-887c-8a0711248452	\N	Tarkarli	MLV002	4567	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
bf11ea27-b18f-4198-9d41-248f086eb2cf	01bc2bc9-77a8-403d-887c-8a0711248452	\N	Devbag	MLV003	2134	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
67dcf458-d9fa-40f8-a56c-4d2498185819	01bc2bc9-77a8-403d-887c-8a0711248452	\N	Sindhudurg	MLV004	1876	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
a9eb1a7c-7dae-43fa-bcb9-8fc02c77957b	01bc2bc9-77a8-403d-887c-8a0711248452	\N	Achara	MLV005	3245	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
6f10a09d-b045-449a-9962-81cc7b2d0348	fa25dd6c-35f3-4fdf-9cd7-e549a9f56ad9	\N	Devgad	DVG001	8934	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
29b47df3-3044-48f3-9645-5f816a22c1b6	fa25dd6c-35f3-4fdf-9cd7-e549a9f56ad9	\N	Vijaydurg	DVG002	2187	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
66f65628-2dc2-41b1-928b-aa5281fc8c1d	fa25dd6c-35f3-4fdf-9cd7-e549a9f56ad9	\N	Bharane	DVG003	1823	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
4bc3db43-e72e-495c-9c3c-ca0b103bccc7	e725b046-67de-4fa1-ad5e-93479d5ac123	\N	Vengurla	VNG001	12236	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
161fad63-66e6-4135-8446-1ae6013db462	e725b046-67de-4fa1-ad5e-93479d5ac123	\N	Mochemad	VNG002	2876	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
bd7cf5af-ea03-4ef8-a6a6-bbfb5eec49ce	e725b046-67de-4fa1-ad5e-93479d5ac123	\N	Shiroda	VNG003	1456	t	t	2025-11-29 11:03:48.635754+00	2025-11-29 11:03:48.635754+00
\.


--
-- Data for Name: wishlists; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.wishlists (id, user_id, property_id) FROM stdin;
\.


--
-- Name: aadhar_verification_logs aadhar_verification_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.aadhar_verification_logs
    ADD CONSTRAINT aadhar_verification_logs_pkey PRIMARY KEY (id);


--
-- Name: amenities amenities_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.amenities
    ADD CONSTRAINT amenities_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: availability availability_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.availability
    ADD CONSTRAINT availability_pkey PRIMARY KEY (id);


--
-- Name: availability availability_room_id_date_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.availability
    ADD CONSTRAINT availability_room_id_date_key UNIQUE (room_id, date);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);


--
-- Name: blocks blocks_taluka_id_name_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_taluka_id_name_key UNIQUE (taluka_id, name);


--
-- Name: booking_items booking_items_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.booking_items
    ADD CONSTRAINT booking_items_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: cities cities_taluka_id_name_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_taluka_id_name_key UNIQUE (taluka_id, name);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: coupons coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.coupons
    ADD CONSTRAINT coupons_pkey PRIMARY KEY (code);


--
-- Name: devices devices_device_token_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_device_token_key UNIQUE (device_token);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: districts districts_name_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_name_key UNIQUE (name);


--
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: experiences experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.experiences
    ADD CONSTRAINT experiences_pkey PRIMARY KEY (id);


--
-- Name: food_packages food_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.food_packages
    ADD CONSTRAINT food_packages_pkey PRIMARY KEY (id);


--
-- Name: gram_panchayats gram_panchayats_block_id_name_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.gram_panchayats
    ADD CONSTRAINT gram_panchayats_block_id_name_key UNIQUE (block_id, name);


--
-- Name: gram_panchayats gram_panchayats_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.gram_panchayats
    ADD CONSTRAINT gram_panchayats_pkey PRIMARY KEY (id);


--
-- Name: homestay_rooms homestay_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.homestay_rooms
    ADD CONSTRAINT homestay_rooms_pkey PRIMARY KEY (id);


--
-- Name: homestays homestays_owner_id_name_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.homestays
    ADD CONSTRAINT homestays_owner_id_name_key UNIQUE (owner_id, name);


--
-- Name: homestays homestays_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.homestays
    ADD CONSTRAINT homestays_pkey PRIMARY KEY (id);


--
-- Name: hosts hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: ledger ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: payment_transactions payment_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT payment_transactions_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: payments payments_provider_payment_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_provider_payment_id_key UNIQUE (provider_payment_id);


--
-- Name: payouts payouts_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT payouts_pkey PRIMARY KEY (id);


--
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: property_amenities property_amenities_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.property_amenities
    ADD CONSTRAINT property_amenities_pkey PRIMARY KEY (property_id, amenity_id);


--
-- Name: property_experiences property_experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.property_experiences
    ADD CONSTRAINT property_experiences_pkey PRIMARY KEY (property_id, experience_id);


--
-- Name: property_food_packages property_food_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.property_food_packages
    ADD CONSTRAINT property_food_packages_pkey PRIMARY KEY (property_id, food_package_id);


--
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: room_photos room_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.room_photos
    ADD CONSTRAINT room_photos_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: seasonal_pricing seasonal_pricing_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.seasonal_pricing
    ADD CONSTRAINT seasonal_pricing_pkey PRIMARY KEY (id);


--
-- Name: support_tickets support_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_pkey PRIMARY KEY (id);


--
-- Name: talukas talukas_district_id_name_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.talukas
    ADD CONSTRAINT talukas_district_id_name_key UNIQUE (district_id, name);


--
-- Name: talukas talukas_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.talukas
    ADD CONSTRAINT talukas_pkey PRIMARY KEY (id);


--
-- Name: ticket_messages ticket_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.ticket_messages
    ADD CONSTRAINT ticket_messages_pkey PRIMARY KEY (id);


--
-- Name: tourist_locations tourist_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.tourist_locations
    ADD CONSTRAINT tourist_locations_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: verifications verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (id);


--
-- Name: village_gram_panchayat village_gram_panchayat_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.village_gram_panchayat
    ADD CONSTRAINT village_gram_panchayat_pkey PRIMARY KEY (village_id, gram_panchayat_id);


--
-- Name: villages villages_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.villages
    ADD CONSTRAINT villages_pkey PRIMARY KEY (id);


--
-- Name: villages villages_taluka_id_name_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.villages
    ADD CONSTRAINT villages_taluka_id_name_key UNIQUE (taluka_id, name);


--
-- Name: wishlists wishlists_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_pkey PRIMARY KEY (id);


--
-- Name: wishlists wishlists_user_id_property_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_property_id_key UNIQUE (user_id, property_id);


--
-- Name: idx_aadhar_logs_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_aadhar_logs_created_at ON public.aadhar_verification_logs USING btree (created_at);


--
-- Name: idx_aadhar_logs_status; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_aadhar_logs_status ON public.aadhar_verification_logs USING btree (status);


--
-- Name: idx_aadhar_logs_user_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_aadhar_logs_user_id ON public.aadhar_verification_logs USING btree (user_id);


--
-- Name: idx_blocks_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_blocks_active ON public.blocks USING btree (is_active);


--
-- Name: idx_blocks_taluka_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_blocks_taluka_id ON public.blocks USING btree (taluka_id);


--
-- Name: idx_bookings_room_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_bookings_room_id ON public.bookings USING btree (room_id);


--
-- Name: idx_categories_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_categories_active ON public.categories USING btree (is_active);


--
-- Name: idx_categories_type; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_categories_type ON public.categories USING btree (type);


--
-- Name: idx_cities_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_cities_active ON public.cities USING btree (is_active);


--
-- Name: idx_cities_district_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_cities_district_id ON public.cities USING btree (district_id);


--
-- Name: idx_cities_taluka_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_cities_taluka_id ON public.cities USING btree (taluka_id);


--
-- Name: idx_districts_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_districts_active ON public.districts USING btree (is_active);


--
-- Name: idx_districts_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_districts_name ON public.districts USING btree (name);


--
-- Name: idx_gram_panchayats_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_gram_panchayats_active ON public.gram_panchayats USING btree (is_active);


--
-- Name: idx_gram_panchayats_block_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_gram_panchayats_block_id ON public.gram_panchayats USING btree (block_id);


--
-- Name: idx_homestay_rooms_homestay_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_homestay_rooms_homestay_id ON public.homestay_rooms USING btree (homestay_id);


--
-- Name: idx_homestays_district; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_homestays_district ON public.homestays USING btree (district);


--
-- Name: idx_homestays_grade; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_homestays_grade ON public.homestays USING btree (grade);


--
-- Name: idx_homestays_location; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_homestays_location ON public.homestays USING btree (latitude, longitude);


--
-- Name: idx_homestays_owner_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_homestays_owner_id ON public.homestays USING btree (owner_id);


--
-- Name: idx_homestays_status; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_homestays_status ON public.homestays USING btree (status);


--
-- Name: idx_homestays_taluka; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_homestays_taluka ON public.homestays USING btree (taluka);


--
-- Name: idx_talukas_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_talukas_active ON public.talukas USING btree (is_active);


--
-- Name: idx_talukas_district_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_talukas_district_id ON public.talukas USING btree (district_id);


--
-- Name: idx_talukas_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_talukas_name ON public.talukas USING btree (name);


--
-- Name: idx_tourist_locations_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_tourist_locations_active ON public.tourist_locations USING btree (is_active);


--
-- Name: idx_tourist_locations_place_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_tourist_locations_place_name ON public.tourist_locations USING btree (place_name);


--
-- Name: idx_tourist_locations_sr_no; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_tourist_locations_sr_no ON public.tourist_locations USING btree (sr_no);


--
-- Name: idx_tourist_locations_taluka; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_tourist_locations_taluka ON public.tourist_locations USING btree (taluka);


--
-- Name: idx_users_aadhar_verification_status; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_users_aadhar_verification_status ON public.users USING btree (aadhar_verification_status);


--
-- Name: idx_users_verification_method; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_users_verification_method ON public.users USING btree (verification_method);


--
-- Name: idx_users_verification_reference_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_users_verification_reference_id ON public.users USING btree (verification_reference_id);


--
-- Name: idx_villages_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_villages_active ON public.villages USING btree (is_active);


--
-- Name: idx_villages_block_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_villages_block_id ON public.villages USING btree (block_id);


--
-- Name: idx_villages_coastal; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_villages_coastal ON public.villages USING btree (is_coastal);


--
-- Name: idx_villages_taluka_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_villages_taluka_id ON public.villages USING btree (taluka_id);


--
-- Name: blocks update_blocks_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_blocks_updated_at BEFORE UPDATE ON public.blocks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: cities update_cities_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_cities_updated_at BEFORE UPDATE ON public.cities FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: districts update_districts_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_districts_updated_at BEFORE UPDATE ON public.districts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: gram_panchayats update_gram_panchayats_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_gram_panchayats_updated_at BEFORE UPDATE ON public.gram_panchayats FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: homestay_rooms update_homestay_rooms_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_homestay_rooms_updated_at BEFORE UPDATE ON public.homestay_rooms FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: homestays update_homestays_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_homestays_updated_at BEFORE UPDATE ON public.homestays FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: talukas update_talukas_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_talukas_updated_at BEFORE UPDATE ON public.talukas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: tourist_locations update_tourist_locations_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_tourist_locations_updated_at BEFORE UPDATE ON public.tourist_locations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: villages update_villages_updated_at; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER update_villages_updated_at BEFORE UPDATE ON public.villages FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: aadhar_verification_logs aadhar_verification_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.aadhar_verification_logs
    ADD CONSTRAINT aadhar_verification_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: availability availability_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.availability
    ADD CONSTRAINT availability_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- Name: blocks blocks_taluka_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_taluka_id_fkey FOREIGN KEY (taluka_id) REFERENCES public.talukas(id) ON DELETE CASCADE;


--
-- Name: booking_items booking_items_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.booking_items
    ADD CONSTRAINT booking_items_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_guest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.homestay_rooms(id) ON DELETE CASCADE;


--
-- Name: cities cities_district_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(id) ON DELETE CASCADE;


--
-- Name: cities cities_taluka_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_taluka_id_fkey FOREIGN KEY (taluka_id) REFERENCES public.talukas(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_guest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: devices devices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: documents documents_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.media(id) ON DELETE CASCADE;


--
-- Name: documents documents_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: gram_panchayats gram_panchayats_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.gram_panchayats
    ADD CONSTRAINT gram_panchayats_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id) ON DELETE CASCADE;


--
-- Name: homestay_rooms homestay_rooms_homestay_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.homestay_rooms
    ADD CONSTRAINT homestay_rooms_homestay_id_fkey FOREIGN KEY (homestay_id) REFERENCES public.homestays(id) ON DELETE CASCADE;


--
-- Name: hosts hosts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: media media_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payment_transactions payment_transactions_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT payment_transactions_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: payouts payouts_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT payouts_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: properties properties_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: properties properties_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE CASCADE;


--
-- Name: property_amenities property_amenities_amenity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.property_amenities
    ADD CONSTRAINT property_amenities_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES public.amenities(id) ON DELETE CASCADE;


--
-- Name: property_amenities property_amenities_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.property_amenities
    ADD CONSTRAINT property_amenities_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: property_experiences property_experiences_experience_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.property_experiences
    ADD CONSTRAINT property_experiences_experience_id_fkey FOREIGN KEY (experience_id) REFERENCES public.experiences(id) ON DELETE CASCADE;


--
-- Name: property_experiences property_experiences_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.property_experiences
    ADD CONSTRAINT property_experiences_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: property_food_packages property_food_packages_food_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.property_food_packages
    ADD CONSTRAINT property_food_packages_food_package_id_fkey FOREIGN KEY (food_package_id) REFERENCES public.food_packages(id) ON DELETE CASCADE;


--
-- Name: property_food_packages property_food_packages_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.property_food_packages
    ADD CONSTRAINT property_food_packages_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: refunds refunds_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_guest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: room_photos room_photos_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.room_photos
    ADD CONSTRAINT room_photos_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- Name: rooms rooms_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: seasonal_pricing seasonal_pricing_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.seasonal_pricing
    ADD CONSTRAINT seasonal_pricing_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- Name: support_tickets support_tickets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: talukas talukas_district_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.talukas
    ADD CONSTRAINT talukas_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(id) ON DELETE CASCADE;


--
-- Name: ticket_messages ticket_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.ticket_messages
    ADD CONSTRAINT ticket_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ticket_messages ticket_messages_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.ticket_messages
    ADD CONSTRAINT ticket_messages_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id) ON DELETE CASCADE;


--
-- Name: verifications verifications_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.verifications
    ADD CONSTRAINT verifications_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: village_gram_panchayat village_gram_panchayat_gram_panchayat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.village_gram_panchayat
    ADD CONSTRAINT village_gram_panchayat_gram_panchayat_id_fkey FOREIGN KEY (gram_panchayat_id) REFERENCES public.gram_panchayats(id) ON DELETE CASCADE;


--
-- Name: village_gram_panchayat village_gram_panchayat_village_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.village_gram_panchayat
    ADD CONSTRAINT village_gram_panchayat_village_id_fkey FOREIGN KEY (village_id) REFERENCES public.villages(id) ON DELETE CASCADE;


--
-- Name: villages villages_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.villages
    ADD CONSTRAINT villages_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id) ON DELETE SET NULL;


--
-- Name: villages villages_taluka_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.villages
    ADD CONSTRAINT villages_taluka_id_fkey FOREIGN KEY (taluka_id) REFERENCES public.talukas(id) ON DELETE CASCADE;


--
-- Name: wishlists wishlists_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: wishlists wishlists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--

