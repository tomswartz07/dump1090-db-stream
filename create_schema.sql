--
-- PostgreSQL database dump
--

-- Started on 2022-02-08 14:19:43 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 9 (class 2615 OID 32578)
-- Name: adsb; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS adsb;


--
-- TOC entry 2 (class 3079 OID 171000)
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- TOC entry 2929 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 198 (class 1259 OID 32579)
-- Name: adsb_messages; Type: TABLE; Schema: adsb; Owner: -
--

CREATE TABLE IF NOT EXISTS adsb.adsb_messages (
    message_type text,
    transmission_type integer NOT NULL,
    session_id text,
    aircraft_id text,
    hex_ident text NOT NULL,
    flight_id text,
    generated_date date NOT NULL,
    generated_time text NOT NULL,
    logged_date date,
    logged_time text,
    callsign text,
    altitude integer,
    ground_speed integer,
    track integer,
    lat real,
    lon real,
    vertical_rate real,
    squawk text,
    alert integer,
    emergency integer,
    spi integer,
    is_on_ground integer,
    parsed_time timestamp with time zone NOT NULL
)
WITH (autovacuum_vacuum_scale_factor='0.0', autovacuum_analyze_scale_factor='0.0', autovacuum_analyze_threshold='5000', autovacuum_vacuum_threshold='5000');


--
-- TOC entry 199 (class 1259 OID 32620)
-- Name: callsigns; Type: VIEW; Schema: adsb; Owner: -
--

CREATE OR REPLACE VIEW adsb.callsigns AS
 SELECT adsb_messages.callsign,
    adsb_messages.hex_ident,
    (adsb_messages.parsed_time)::date AS date_seen,
    max(adsb_messages.parsed_time) AS last_seen,
    min(adsb_messages.parsed_time) AS first_seen
   FROM adsb.adsb_messages
  WHERE (adsb_messages.callsign <> ''::text)
  GROUP BY adsb_messages.callsign, adsb_messages.hex_ident, ((adsb_messages.parsed_time)::date);


--
-- TOC entry 200 (class 1259 OID 32624)
-- Name: locations; Type: VIEW; Schema: adsb; Owner: -
--

CREATE OR REPLACE VIEW adsb.locations AS
 SELECT adsb_messages.hex_ident,
    adsb_messages.parsed_time,
    adsb_messages.lon,
    adsb_messages.lat,
    adsb_messages.altitude
   FROM adsb.adsb_messages
  WHERE (adsb_messages.lat IS NOT NULL);


--
-- TOC entry 201 (class 1259 OID 32629)
-- Name: flights; Type: VIEW; Schema: adsb; Owner: -
--

CREATE OR REPLACE VIEW adsb.flights AS
 SELECT DISTINCT l.hex_ident,
    l.parsed_time,
    l.lon,
    l.lat,
    l.altitude,
    cs.callsign
   FROM (adsb.locations l
     JOIN adsb.callsigns cs ON (((l.hex_ident = cs.hex_ident) AND ((l.parsed_time)::timestamp with time zone <= ((cs.last_seen)::timestamp with time zone + '00:10:00'::interval)) AND ((l.parsed_time)::timestamp with time zone >= ((cs.first_seen)::timestamp with time zone - '00:10:00'::interval)))));


--
-- TOC entry 2798 (class 2606 OID 35451)
-- Name: adsb_messages idx_adsb_unique; Type: CONSTRAINT; Schema: adsb; Owner: -
--

ALTER TABLE ONLY adsb.adsb_messages
    ADD CONSTRAINT idx_adsb_unique PRIMARY KEY (transmission_type, parsed_time, hex_ident);


--
-- TOC entry 2796 (class 1259 OID 32612)
-- Name: idx_adsb_time; Type: INDEX; Schema: adsb; Owner: -
--

CREATE INDEX idx_adsb_time ON adsb.adsb_messages USING brin (parsed_time);


-- Completed on 2022-02-08 14:19:44 UTC

--
-- PostgreSQL database dump complete
--

