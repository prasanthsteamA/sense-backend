--
-- PostgreSQL database dump
--

-- Dumped from database version 14.7
-- Dumped by pg_dump version 14.0

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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: id_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.id_type_enum AS ENUM (
    'remote_id',
    'rfid',
    'vid'
);


ALTER TYPE public.id_type_enum OWNER TO postgres;

--
-- Name: find_country_level_tariff(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.find_country_level_tariff(level_input integer) RETURNS TABLE(id integer, name text, type text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT stp.id::INT, stp.name::TEXT, stp.type::TEXT
    FROM saev_level_item AS sli
    LEFT JOIN saev_tariff_plan AS stp ON sli.tariff_id = stp.id
    WHERE sli.id = level_input AND sli.tariff_id IS NOT NULL;
END;
$$;


ALTER FUNCTION public.find_country_level_tariff(level_input integer) OWNER TO postgres;

--
-- Name: find_region_level_tariff(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.find_region_level_tariff(level_input integer) RETURNS TABLE(id integer, name text, type text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT stp.id::INT, stp.name::TEXT, stp.type::TEXT
    FROM saev_level_item AS sli
    LEFT JOIN saev_tariff_plan AS stp ON sli.tariff_id = stp.id
    WHERE sli.id = level_input AND sli.tariff_id IS NOT NULL;
END;
$$;


ALTER FUNCTION public.find_region_level_tariff(level_input integer) OWNER TO postgres;

--
-- Name: find_state_level_tariff(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.find_state_level_tariff(level_input integer) RETURNS TABLE(id integer, name text, type text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT stp.id::INT, stp.name::TEXT, stp.type::TEXT
    FROM saev_level_item AS sli
    LEFT JOIN saev_tariff_plan AS stp ON sli.tariff_id = stp.id
    WHERE sli.id = level_input AND sli.tariff_id IS NOT NULL;
END;
$$;


ALTER FUNCTION public.find_state_level_tariff(level_input integer) OWNER TO postgres;

--
-- Name: find_station_level_tariff(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.find_station_level_tariff(station_id_input integer) RETURNS TABLE(id integer, name text, type text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT stp.id::INT, stp.name::TEXT, stp.type::TEXT
    FROM saev_charge_station AS scs
    LEFT JOIN saev_tariff_plan AS stp ON scs.tariff_id = stp.id
    WHERE scs.id = station_id_input AND scs.tariff_id IS NOT NULL;
END;
$$;


ALTER FUNCTION public.find_station_level_tariff(station_id_input integer) OWNER TO postgres;

--
-- Name: update_session_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_session_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if the status has changed
    IF NEW.status <> OLD.status THEN
        -- Check if the new status is one of the specified statuses and is different from the existing status
        IF NEW.status IN ('Faulted', 'Finishing', 'SuspendedEVSE', 'SuspendedEV', 'Charging') AND NEW.status <> OLD.status THEN
            INSERT INTO saev_charging_session_log (
                session_id,
                charge_connector_id,
                created_at,
                created_by,
                type,
                charge_point_id,
                connector_id,
                text
            )
            SELECT
                scsl.session_id,
                scsl.charge_connector_id,
                CURRENT_TIMESTAMP,
                scsl.created_by,
                UPPER(NEW.status),
                scsl.charge_point_id,
                scsl.connector_id,
                'Session ' || NEW.status
            FROM
                saev_charging_session_log scsl
            WHERE
                scsl.charge_connector_id = NEW.charge_connector_id
            ORDER BY
                id DESC
            LIMIT 1;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_session_log() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: chargebot_load_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chargebot_load_session (
    id integer NOT NULL,
    cpid character varying(100),
    message character varying(100),
    operation character varying(500),
    status character varying(50),
    logged_time timestamp without time zone
);


ALTER TABLE public.chargebot_load_session OWNER TO postgres;

--
-- Name: chargebot_load_session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.chargebot_load_session ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.chargebot_load_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: max_transaction_id; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.max_transaction_id (
    max bigint
);


ALTER TABLE public.max_transaction_id OWNER TO postgres;

--
-- Name: saev_alert; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_alert (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    alert character varying(255),
    charge_station_id integer,
    charge_point_id integer,
    connector_id integer,
    status character varying(255),
    created_by character varying(255),
    updated_by character varying(255),
    tenant_id character varying(255),
    level_1 integer,
    level_2 integer,
    level_3 integer,
    charge_connector_id integer,
    ocpp_log_id bigint,
    call character varying(4096),
    call_result character varying(4096),
    call_error character varying(4096)
);


ALTER TABLE public.saev_alert OWNER TO postgres;

--
-- Name: saev_alert_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_alert ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_alert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_analytics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_analytics (
    id integer NOT NULL,
    tenant_id character varying(255),
    level_type character varying(255),
    level_id character varying(255),
    energy_consumed double precision DEFAULT '0'::double precision,
    total_revenue double precision DEFAULT '0'::double precision,
    total_session integer DEFAULT 0,
    type character varying(255),
    year integer,
    month integer,
    day integer,
    created_at timestamp without time zone,
    day_start_time character varying(255),
    day_end_time character varying(255)
);


ALTER TABLE public.saev_analytics OWNER TO postgres;

--
-- Name: saev_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_analytics ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_analytics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_business_unit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_business_unit (
    id integer NOT NULL,
    tenant_id character varying(255) NOT NULL,
    business_unit_name character varying(255) NOT NULL,
    address json,
    gst_no character varying(20),
    cgst numeric(10,2),
    sgst numeric(10,2),
    igst numeric(10,2),
    is_deleted boolean DEFAULT false,
    created_at timestamp without time zone,
    created_by character varying(255),
    updated_at timestamp without time zone,
    updated_by character varying(255),
    alias_name character varying(255)
);


ALTER TABLE public.saev_business_unit OWNER TO postgres;

--
-- Name: saev_business_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_business_unit ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_business_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_charge_connector; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_charge_connector (
    id integer NOT NULL,
    isactive boolean DEFAULT true,
    createdat timestamp(6) without time zone,
    createdby character varying(200),
    updatedat timestamp(6) without time zone,
    updatedby character varying(200),
    status character varying(255),
    level_1 integer,
    level_2 integer,
    level_3 integer,
    charge_station_id integer,
    charge_point_id integer,
    connector_id integer,
    connector_type character varying,
    tenant_id character varying,
    peak_power character varying(100),
    current_type character varying(100),
    tariff_id integer,
    charge_connector_id integer,
    ocpp_charge_point_id character varying(255),
    peak_power_rank double precision DEFAULT '0'::double precision,
    level1 integer,
    level2 integer,
    level3 integer,
    discount_id integer,
    reason text,
    last_received_message_time timestamp without time zone,
    isdeleted boolean DEFAULT false
);


ALTER TABLE public.saev_charge_connector OWNER TO postgres;

--
-- Name: saev_charge_connector_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_charge_connector ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_charge_connector_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_charge_connector_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saev_charge_connector_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saev_charge_connector_seq OWNER TO postgres;

--
-- Name: saev_charge_point; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_charge_point (
    id integer NOT NULL,
    station_id integer NOT NULL,
    serial_number character varying(200),
    model character varying(100),
    no_of_connectors integer,
    manufacturer_name character varying(200),
    createdat timestamp(6) without time zone,
    createdby character varying(200),
    updatedat timestamp(6) without time zone,
    updatedby character varying(200),
    charge_point_id integer,
    level_1 integer,
    level_2 integer,
    level_3 integer,
    peak_power character varying(255),
    ac_input_voltage character varying(255),
    ac_max_current character varying(255),
    fm_number character varying(255),
    iccid_number character varying(255),
    imsi_number character varying(255),
    is_active boolean DEFAULT false,
    custom_name character varying(200),
    heart_beat timestamp without time zone,
    charge_station_id integer,
    tariff_id integer,
    ocpp_charge_point_id character varying(255) NOT NULL,
    total_energy_consumed integer DEFAULT 0,
    charger_type character varying(255) DEFAULT 'AC'::character varying,
    created_at timestamp(6) without time zone,
    created_by character varying(200),
    mac_address character varying(100),
    updated_at timestamp(6) without time zone,
    updated_by character varying(200),
    landmark character varying(255),
    discount_id integer,
    reason text,
    ispublished boolean DEFAULT false,
    isdeleted boolean DEFAULT false,
    tenantid character varying(200) NOT NULL,
    station_owned boolean DEFAULT false,
    total_sessions integer,
    commissioned_date timestamp without time zone,
    meter_value_interval integer DEFAULT 30,
    heart_beat_interval integer DEFAULT 30
);


ALTER TABLE public.saev_charge_point OWNER TO postgres;

--
-- Name: saev_charge_point_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_charge_point ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_charge_point_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_charge_point_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saev_charge_point_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saev_charge_point_seq OWNER TO postgres;

--
-- Name: saev_charge_point_unavailability; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_charge_point_unavailability (
    id integer NOT NULL,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    duration double precision,
    created_at timestamp without time zone,
    charge_point_id character varying(255)
);


ALTER TABLE public.saev_charge_point_unavailability OWNER TO postgres;

--
-- Name: saev_charge_point_unavailability_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_charge_point_unavailability ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_charge_point_unavailability_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_charge_station; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_charge_station (
    id integer NOT NULL,
    tenantid character varying(200),
    name character varying(100),
    always_open boolean DEFAULT true,
    latitude double precision,
    longitude double precision,
    geolocation public.geometry(Point,4326),
    createdat timestamp(6) without time zone,
    createdby character varying(200),
    updatedat timestamp(6) without time zone,
    updatedby character varying(200),
    opening_hours json,
    address json,
    total_sessions integer DEFAULT 0,
    level_1 integer,
    level_2 integer,
    level_3 integer,
    tariff_id integer,
    energy_consumed integer DEFAULT 0,
    charge_station_id integer,
    business_unit_id integer,
    amenities json,
    discount_id integer,
    station_charger_type character varying(255) DEFAULT 'AC'::character varying,
    contact_person character varying(255),
    contact_number character varying(255),
    commissioned_date timestamp without time zone,
    isdeleted boolean DEFAULT false
);


ALTER TABLE public.saev_charge_station OWNER TO postgres;

--
-- Name: saev_charge_station_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_charge_station ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_charge_station_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_charging_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_charging_session (
    id integer NOT NULL,
    charge_point_id integer NOT NULL,
    connector_id integer NOT NULL,
    user_id character varying(500) NOT NULL,
    status character varying(200),
    started_time timestamp without time zone,
    end_time timestamp without time zone,
    power_consumed double precision DEFAULT '0'::double precision,
    total_cost double precision DEFAULT '0'::double precision,
    total_duration double precision DEFAULT '0'::double precision,
    created_at timestamp without time zone,
    created_by character varying(200),
    updated_at timestamp without time zone,
    updated_by character varying(200),
    charge_station_id integer,
    invoice character varying(500),
    ocpp_transaction_id integer,
    tenantid character varying(255),
    break_down jsonb,
    tariff_info jsonb,
    charge_connector_id integer,
    level_1 integer,
    level_2 integer,
    level_3 integer,
    amount_before_tax double precision,
    vehicle_details jsonb,
    team_id integer,
    team_inv_generated boolean DEFAULT false,
    source character varying,
    user_rfid character varying,
    inv_no character varying(256),
    start_meter_value bigint,
    last_meter_value bigint,
    deducted_cost double precision,
    closed_by character varying,
    start_soc character varying,
    end_soc character varying,
    is_interrupted boolean DEFAULT false,
    last_meter_value_time timestamp without time zone,
    discount_info jsonb,
    amount_with_discount double precision,
    discount_amount double precision,
    reason character varying,
    is_suspicious boolean DEFAULT false,
    stop_reason character varying,
    stopped_while_interrupted boolean DEFAULT false
);


ALTER TABLE public.saev_charging_session OWNER TO postgres;

--
-- Name: saev_charging_session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_charging_session ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_charging_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_charging_session_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_charging_session_log (
    id integer NOT NULL,
    session_id integer NOT NULL,
    charge_connector_id integer,
    created_at timestamp without time zone,
    created_by character varying(200),
    type character varying(255),
    charge_point_id integer,
    connector_id integer,
    text character varying(255),
    source character varying,
    user_rfid character varying,
    reason character varying(255)
);


ALTER TABLE public.saev_charging_session_log OWNER TO postgres;

--
-- Name: saev_charging_session_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_charging_session_log ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_charging_session_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_db_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_db_version (
    id integer NOT NULL,
    version character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updated_by character varying NOT NULL
);


ALTER TABLE public.saev_db_version OWNER TO postgres;

--
-- Name: saev_db_version_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saev_db_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saev_db_version_id_seq OWNER TO postgres;

--
-- Name: saev_db_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.saev_db_version_id_seq OWNED BY public.saev_db_version.id;


--
-- Name: saev_discount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_discount (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(20) NOT NULL,
    discount_value numeric NOT NULL,
    is_active boolean NOT NULL,
    is_fixed_time_period boolean,
    tenant_id character varying NOT NULL,
    createdat timestamp without time zone,
    createdby character varying,
    updatedat timestamp without time zone,
    updatedby character varying,
    start_datetime timestamp without time zone,
    end_datetime timestamp without time zone,
    config jsonb,
    available_to jsonb,
    is_deleted boolean,
    config_parent_level jsonb
);


ALTER TABLE public.saev_discount OWNER TO postgres;

--
-- Name: saev_discount_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_discount ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_discount_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_discount_team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_discount_team (
    id integer NOT NULL,
    team_id integer NOT NULL,
    level character varying NOT NULL,
    level_id integer NOT NULL,
    discount_id integer NOT NULL,
    created_by character varying,
    updated_by character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_active boolean,
    tenant_id character varying
);


ALTER TABLE public.saev_discount_team OWNER TO postgres;

--
-- Name: saev_discount_team_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_discount_team ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_discount_team_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_favourite_station; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_favourite_station (
    id integer NOT NULL,
    userid character varying(500) NOT NULL,
    stationid integer NOT NULL,
    isactive boolean DEFAULT true,
    createdat timestamp(6) without time zone,
    createdby character varying(200)
);


ALTER TABLE public.saev_favourite_station OWNER TO postgres;

--
-- Name: saev_favourite_station_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_favourite_station ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_favourite_station_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_level_header; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_level_header (
    id integer NOT NULL,
    tenant_id character varying(200) NOT NULL,
    level character varying(200) NOT NULL,
    name character varying(255) NOT NULL,
    created_at date
);


ALTER TABLE public.saev_level_header OWNER TO postgres;

--
-- Name: saev_level_header_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_level_header ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_level_header_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_level_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_level_item (
    id integer NOT NULL,
    created_at date,
    name character varying(255),
    tenant_id character varying(255),
    created_by character varying(255),
    updated_at date,
    updated_by character varying(255),
    level_header_id integer,
    parent_id integer DEFAULT 0,
    level integer,
    tariff_id integer,
    discount_id integer
);


ALTER TABLE public.saev_level_item OWNER TO postgres;

--
-- Name: saev_level_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_level_item ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_level_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_md_charger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_md_charger (
    id integer NOT NULL,
    tenantid character varying(200),
    oem character varying(200),
    model_name public.citext,
    charger_type character varying(200),
    peak_power double precision,
    dc_output_current double precision,
    dc_output_voltage double precision,
    ac_input_current double precision,
    ac_input_voltage double precision,
    no_of_connectors integer,
    createdat timestamp without time zone,
    createdby character varying(200),
    updatedat timestamp without time zone,
    updatedby character varying(200),
    isdeleted boolean DEFAULT false
);


ALTER TABLE public.saev_md_charger OWNER TO postgres;

--
-- Name: saev_md_charger_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_md_charger ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_md_charger_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_md_connector; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_md_connector (
    id integer NOT NULL,
    charger_id integer,
    current_type character varying(100),
    connector_type character varying(200),
    peak_power double precision,
    createdat timestamp without time zone,
    createdby character varying(200),
    updatedat timestamp without time zone,
    updatedby character varying(200),
    isdeleted boolean DEFAULT false,
    connector_id integer
);


ALTER TABLE public.saev_md_connector OWNER TO postgres;

--
-- Name: saev_md_connector_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_md_connector ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_md_connector_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_md_vehicle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_md_vehicle (
    id integer NOT NULL,
    tenantid character varying(200),
    manufacturer character varying(200),
    model public.citext,
    battery_capacity double precision,
    createdat timestamp without time zone,
    createdby character varying(200),
    updatedat timestamp without time zone,
    updatedby character varying(200),
    isdeleted boolean DEFAULT false,
    ccs_charging_speed double precision,
    type2_charging_speed double precision,
    battery_voltage double precision
);


ALTER TABLE public.saev_md_vehicle OWNER TO postgres;

--
-- Name: saev_md_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_md_vehicle ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_md_vehicle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_notification_hdr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_notification_hdr (
    id integer NOT NULL,
    tenantid character varying(200),
    notify_type character varying(50),
    notify_send_to character varying(100),
    is_rule_based boolean DEFAULT false,
    rule_config jsonb,
    mail_id jsonb,
    team_id jsonb,
    notify_schedule_type character varying(100),
    notify_schedule timestamp without time zone,
    notify_content jsonb,
    notify_action jsonb,
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    notify_status character varying(256),
    created_at timestamp without time zone,
    created_by character varying(100),
    updated_at timestamp without time zone,
    updated_by character varying(100),
    media_url character varying(1000)
);


ALTER TABLE public.saev_notification_hdr OWNER TO postgres;

--
-- Name: saev_notification_hdr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_notification_hdr ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_notification_hdr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_notifications (
    id integer NOT NULL,
    tenant_id character varying(100) NOT NULL,
    user_id character varying(100) NOT NULL,
    notification_title text NOT NULL,
    notification_body text NOT NULL,
    notification_type character varying(20) NOT NULL,
    scheduled_type character varying(20) NOT NULL,
    scheduled_time timestamp without time zone,
    sent_at timestamp without time zone,
    attachment_url character varying(255),
    other_metadata jsonb,
    created_by character varying(100),
    updated_by character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notification_data json
);


ALTER TABLE public.saev_notifications OWNER TO postgres;

--
-- Name: saev_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_notifications ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_ocpp_charge_point; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_ocpp_charge_point (
    id bigint NOT NULL,
    charge_point_id character varying(255),
    charge_station_id character varying(255),
    connectors integer NOT NULL,
    is_boot_notif_received boolean NOT NULL,
    status character varying(255),
    tenant_id character varying(255),
    updated_at timestamp(6) without time zone
);


ALTER TABLE public.saev_ocpp_charge_point OWNER TO postgres;

--
-- Name: saev_ocpp_charge_point_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_ocpp_charge_point ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.saev_ocpp_charge_point_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_ocpp_charge_point_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saev_ocpp_charge_point_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saev_ocpp_charge_point_seq OWNER TO postgres;

--
-- Name: saev_ocpp_connector_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_ocpp_connector_status (
    id bigint NOT NULL,
    charge_point_id character varying(255),
    connector_id integer NOT NULL,
    error_code character varying(255),
    info character varying(255),
    status character varying(255),
    updated_at timestamp(6) without time zone,
    vendor_error_code character varying(255),
    vendor_id character varying(255)
);


ALTER TABLE public.saev_ocpp_connector_status OWNER TO postgres;

--
-- Name: saev_ocpp_connector_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_ocpp_connector_status ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.saev_ocpp_connector_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_ocpp_connector_status_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saev_ocpp_connector_status_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saev_ocpp_connector_status_seq OWNER TO postgres;

--
-- Name: saev_ocpp_id_tag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_ocpp_id_tag (
    id bigint NOT NULL,
    expiry_date timestamp(6) without time zone,
    id_tag character varying(255),
    status character varying(255)
);


ALTER TABLE public.saev_ocpp_id_tag OWNER TO postgres;

--
-- Name: saev_ocpp_id_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_ocpp_id_tag ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.saev_ocpp_id_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_ocpp_id_tag_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saev_ocpp_id_tag_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saev_ocpp_id_tag_seq OWNER TO postgres;

--
-- Name: saev_ocpp_message_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_ocpp_message_log (
    id bigint NOT NULL,
    call character varying(100000),
    call_action character varying(256),
    call_error character varying(100000),
    call_result character varying(100000),
    charge_point_id character varying(255),
    created_at timestamp(6) without time zone,
    is_error boolean NOT NULL,
    type character varying(255),
    connector_id integer,
    id_tag character varying(255),
    status character varying(255),
    transaction_id integer
);


ALTER TABLE public.saev_ocpp_message_log OWNER TO postgres;

--
-- Name: saev_ocpp_message_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_ocpp_message_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.saev_ocpp_message_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_ocpp_message_log_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saev_ocpp_message_log_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saev_ocpp_message_log_seq OWNER TO postgres;

--
-- Name: saev_ocpp_meter_value; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_ocpp_meter_value (
    id bigint NOT NULL,
    charge_point_id character varying(255),
    connector_id integer NOT NULL,
    context character varying(255),
    format character varying(255),
    location character varying(255),
    measurand character varying(255),
    meter_value character varying(255),
    phase character varying(255),
    "timestamp" timestamp(6) without time zone,
    transaction_id integer NOT NULL,
    unit character varying(255)
);


ALTER TABLE public.saev_ocpp_meter_value OWNER TO postgres;

--
-- Name: saev_ocpp_meter_value_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_ocpp_meter_value ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.saev_ocpp_meter_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_ocpp_meter_value_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saev_ocpp_meter_value_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saev_ocpp_meter_value_seq OWNER TO postgres;

--
-- Name: saev_ocpp_transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_ocpp_transaction (
    transaction_id bigint NOT NULL,
    charge_point_id character varying(255),
    connector_id integer NOT NULL,
    id_tag character varying(255),
    meter_start integer,
    meter_stop integer,
    reason character varying(255),
    started_at timestamp(6) without time zone,
    stopped_at timestamp(6) without time zone,
    transaction_status character varying(255)
);


ALTER TABLE public.saev_ocpp_transaction OWNER TO postgres;

--
-- Name: saev_ocpp_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saev_ocpp_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saev_ocpp_transaction_id_seq OWNER TO postgres;

--
-- Name: saev_ocpp_transaction_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_ocpp_transaction ALTER COLUMN transaction_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.saev_ocpp_transaction_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_ocpp_vid_tag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_ocpp_vid_tag (
    id bigint NOT NULL,
    charge_point_id character varying(255),
    connector_id integer,
    expires_at timestamp(6) without time zone,
    request_status character varying(255),
    vid_tag character varying(255)
);


ALTER TABLE public.saev_ocpp_vid_tag OWNER TO postgres;

--
-- Name: saev_ocpp_vid_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_ocpp_vid_tag ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.saev_ocpp_vid_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_payment (
    id bigint NOT NULL,
    result_status character varying(255),
    result_code character varying(255),
    result_msg character varying(255),
    txn_id character varying(255),
    bank_txn_id character varying(255),
    order_id character varying(255) NOT NULL,
    txn_amount character varying(255),
    txn_type character varying(255),
    gateway_name character varying(255),
    bank_name character varying(255),
    mid character varying(255),
    payment_mode character varying(255),
    refund_amt character varying(255),
    txn_date character varying(255),
    txn_token character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone,
    wallet_transaction_id integer,
    user_id character varying(255),
    tenant_id character varying(255),
    invoice_id character varying,
    payment_vendor character varying
);


ALTER TABLE public.saev_payment OWNER TO postgres;

--
-- Name: saev_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_payment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.saev_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_permission_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_permission_master (
    id integer NOT NULL,
    name character varying(100),
    displayname character varying(100),
    createdat timestamp without time zone,
    updatedat timestamp without time zone,
    module character varying(255),
    actiontype character varying(255)
);


ALTER TABLE public.saev_permission_master OWNER TO postgres;

--
-- Name: saev_permission_master_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_permission_master ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_permission_master_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_rfid; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_rfid (
    id integer NOT NULL,
    created_at timestamp without time zone,
    user_id character varying(255),
    rfidnumber character varying(255),
    tenant_id character varying(255),
    created_by character varying(255),
    updated_by character varying(255),
    updated_at timestamp without time zone,
    isactive boolean DEFAULT true,
    id_type public.id_type_enum DEFAULT 'remote_id'::public.id_type_enum,
    serial_number character varying(255),
    batch_number character varying(100),
    expiry_date timestamp without time zone,
    assigned_on timestamp without time zone
);


ALTER TABLE public.saev_rfid OWNER TO postgres;

--
-- Name: saev_rfid_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_rfid ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_rfid_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_role (
    id integer NOT NULL,
    created_at date,
    name character varying(255),
    tenant_id character varying(255),
    created_by character varying(255),
    updated_at date,
    updated_by character varying(255),
    permissions jsonb,
    is_deleted boolean DEFAULT false,
    effective_role_level character varying(255),
    effective_level_id jsonb,
    level_1 jsonb,
    level_2 jsonb,
    level_3 jsonb,
    charge_station_id jsonb,
    charge_point_id jsonb,
    charge_connector_id jsonb
);


ALTER TABLE public.saev_role OWNER TO postgres;

--
-- Name: saev_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_role ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_sequence_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_sequence_number (
    id integer NOT NULL,
    tenantid character varying(255),
    prefix character varying(255),
    finyear integer,
    suffix character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by character varying(255),
    updated_by character varying(255),
    reference character varying(256)
);


ALTER TABLE public.saev_sequence_number OWNER TO postgres;

--
-- Name: saev_sequence_number_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_sequence_number ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_sequence_number_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_session_attempt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_session_attempt (
    id integer NOT NULL,
    charge_point_id integer,
    action character varying,
    status character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    session_id integer
);


ALTER TABLE public.saev_session_attempt OWNER TO postgres;

--
-- Name: saev_session_attempt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_session_attempt ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_session_attempt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_setting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_setting (
    id integer NOT NULL,
    tenantid character varying(200) NOT NULL,
    primary_color character varying(100),
    secondary_color character varying(100),
    distance_unit character varying(100),
    use_gradient boolean DEFAULT false,
    company_logo character varying(500),
    currency character varying(100),
    createdat timestamp(6) without time zone,
    createdby character varying(200),
    updatedat timestamp(6) without time zone,
    updatedby character varying(200),
    isactive boolean DEFAULT true,
    minimum_wallet_balance double precision,
    gradient_left character varying(255),
    gradient_right character varying(255),
    currency_symbol character varying(255),
    ocpp_sokcet_endpoint character varying(255),
    time_zone character varying(10),
    connector_types jsonb,
    tenant_name character varying,
    display_name character varying,
    tenant_support_email character varying(255),
    time_zone_name character varying(255),
    is_paytm boolean DEFAULT false,
    is_razor_pay boolean DEFAULT true
);


ALTER TABLE public.saev_setting OWNER TO postgres;

--
-- Name: saev_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_setting ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_setting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_station_media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_station_media (
    id integer NOT NULL,
    stationid integer,
    name character varying(100),
    status character varying(100) DEFAULT 'Draft'::character varying,
    type character varying(100),
    url character varying(1000),
    ispublic boolean DEFAULT true,
    isactive boolean DEFAULT true,
    createdat timestamp(6) without time zone,
    createdby character varying(200),
    updatedat timestamp(6) without time zone,
    updatedby character varying(200)
);


ALTER TABLE public.saev_station_media OWNER TO postgres;

--
-- Name: saev_station_media_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_station_media ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_station_media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_super_admin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_super_admin (
    id integer NOT NULL,
    last_downtime_sync timestamp without time zone,
    heart_beat_time_interval double precision
);


ALTER TABLE public.saev_super_admin OWNER TO postgres;

--
-- Name: saev_super_admin_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_super_admin ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_super_admin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_tariff_plan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_tariff_plan (
    id integer NOT NULL,
    name character varying(200),
    type character varying(100),
    isactive boolean DEFAULT true,
    connection_fee double precision DEFAULT '0'::double precision,
    createdat timestamp(6) without time zone,
    createdby character varying(200),
    updatedat timestamp(6) without time zone,
    updatedby character varying(200),
    tenantid character varying(255)
);


ALTER TABLE public.saev_tariff_plan OWNER TO postgres;

--
-- Name: saev_tariff_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_tariff_plan ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_tariff_plan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_tariff_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_tariff_rule (
    id integer NOT NULL,
    tariffplan integer NOT NULL,
    type character varying(100),
    isactive boolean DEFAULT true,
    costperkwh double precision DEFAULT 0.0,
    costperhour double precision DEFAULT 0.0,
    from_time time without time zone,
    to_time time without time zone,
    dayname character varying(100),
    createdat timestamp(6) without time zone,
    createdby character varying(200),
    updatedat timestamp(6) without time zone,
    updatedby character varying(200),
    groupid character varying(255),
    costperkwh_ac double precision DEFAULT 0.0,
    costperkwh_dc double precision DEFAULT 0.0,
    costperhour_ac double precision DEFAULT 0.0,
    costperhour_dc double precision DEFAULT 0.0
);


ALTER TABLE public.saev_tariff_rule OWNER TO postgres;

--
-- Name: saev_tariff_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_tariff_rule ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_tariff_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_team_dtl; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_team_dtl (
    id integer NOT NULL,
    team_hdr_id integer,
    customer_id character varying(100),
    is_lead boolean DEFAULT false,
    is_deleted boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by character varying(255),
    updated_by character varying(255)
);


ALTER TABLE public.saev_team_dtl OWNER TO postgres;

--
-- Name: saev_team_dtl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_team_dtl ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_team_dtl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_team_hdr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_team_hdr (
    id integer NOT NULL,
    tenant_id character varying(255),
    team_name character varying(4096),
    is_deleted boolean DEFAULT false,
    team_gst character varying(255),
    payment_type character varying(255),
    invoice_address character varying(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by character varying(255),
    updated_by character varying(255),
    billing_cycle integer,
    discount_id jsonb
);


ALTER TABLE public.saev_team_hdr OWNER TO postgres;

--
-- Name: saev_team_hdr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_team_hdr ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_team_hdr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_team_invoice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_team_invoice (
    id integer NOT NULL,
    tenant_id character varying(255),
    team_id integer,
    billing_month character varying(255),
    billing_amount double precision,
    paid_on timestamp without time zone,
    invoice character varying(500),
    payment_status character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by character varying(255),
    updated_by character varying(255),
    sessions_count integer,
    energy_consumed integer,
    breakdown json
);


ALTER TABLE public.saev_team_invoice OWNER TO postgres;

--
-- Name: saev_team_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_team_invoice ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_team_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_trip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_trip (
    id integer NOT NULL,
    userid character varying(500) NOT NULL,
    vehicleid integer NOT NULL,
    originname character varying(500),
    destinationname character varying(500),
    originlat double precision,
    originlong double precision,
    destinationlat double precision,
    destinationlong double precision,
    initialcharging double precision DEFAULT 0.0,
    lastcharging double precision DEFAULT 0.0,
    powerconsumed double precision DEFAULT 0.0,
    distance double precision DEFAULT 0.0,
    duration double precision DEFAULT 0.0,
    isactive boolean DEFAULT true,
    updatedat timestamp(6) without time zone,
    updatedby character varying(200),
    createdat timestamp(6) without time zone,
    createdby character varying(200)
);


ALTER TABLE public.saev_trip OWNER TO postgres;

--
-- Name: saev_trip_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_trip ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_trip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_user (
    id character varying(100) NOT NULL,
    tenantid character varying(100),
    usertype character varying(100),
    email character varying(100),
    phone character varying(100),
    name character varying(100),
    username character varying(100),
    cover_image character varying(500),
    logo character varying(500),
    isactive boolean DEFAULT true,
    createdat timestamp(6) without time zone,
    createdby character varying(100),
    updatedat timestamp(6) without time zone,
    updatedby character varying(100),
    wallet_balance double precision DEFAULT '0'::double precision,
    is_deleted boolean DEFAULT false,
    business_unit_details jsonb,
    is_email_verified boolean DEFAULT false
);


ALTER TABLE public.saev_user OWNER TO postgres;

--
-- Name: saev_user_devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_user_devices (
    id integer NOT NULL,
    user_id character varying(100),
    tenant_id character varying(100) NOT NULL,
    device_type character varying(50) NOT NULL,
    device_token character varying(255) NOT NULL,
    device_name character varying(100),
    device_model character varying(100),
    os_version character varying(50),
    app_version character varying(50),
    last_active_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    other_metadata jsonb,
    access_token character varying(255)
);


ALTER TABLE public.saev_user_devices OWNER TO postgres;

--
-- Name: saev_user_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_user_devices ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_user_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_user_otp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_user_otp (
    id integer NOT NULL,
    tenantid character varying(100),
    email character varying(100),
    username character varying(100),
    phone character varying(100),
    otp character varying(100),
    expiryin integer DEFAULT 15,
    isactive boolean DEFAULT true,
    createdat timestamp(6) without time zone,
    verify_token character varying(100),
    signature character varying(256)
);


ALTER TABLE public.saev_user_otp OWNER TO postgres;

--
-- Name: saev_user_otp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_user_otp ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_user_otp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_user_role (
    id integer NOT NULL,
    user_id character varying(255),
    tenant_id character varying(255),
    created_by character varying(255),
    created_at date,
    updated_by character varying(255),
    updated_at date,
    role_id integer NOT NULL
);


ALTER TABLE public.saev_user_role OWNER TO postgres;

--
-- Name: saev_user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_user_role ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_user_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_vehicle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_vehicle (
    id integer NOT NULL,
    userid character varying(500) NOT NULL,
    nickname character varying(200) NOT NULL,
    manufacturer character varying(200),
    model character varying(200),
    number character varying(200),
    type character varying(100),
    connectortype character varying(100),
    power double precision DEFAULT 0.0,
    isactive boolean DEFAULT true,
    updatedat timestamp(6) without time zone,
    updatedby character varying(200),
    createdat timestamp(6) without time zone,
    createdby character varying(200),
    image character varying(500),
    is_default boolean,
    is_temporary boolean,
    temp_created_at timestamp without time zone,
    tenantid character varying(255)
);


ALTER TABLE public.saev_vehicle OWNER TO postgres;

--
-- Name: saev_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_vehicle ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_vehicle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_vid; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_vid (
    id integer NOT NULL,
    user_id character varying,
    created_at timestamp without time zone,
    ocpp_charge_point_id character varying,
    vrn character varying,
    status character varying,
    vid_tag character varying NOT NULL,
    created_by character varying,
    updated_at timestamp without time zone,
    updated_by character varying,
    tenant_id character varying,
    connector_id integer
);


ALTER TABLE public.saev_vid OWNER TO postgres;

--
-- Name: saev_vid_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_vid ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_vid_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: saev_wallet_transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saev_wallet_transaction (
    id integer NOT NULL,
    tenant_id character varying(255),
    user_id character varying(255),
    amount double precision,
    currency character varying(255),
    balance double precision,
    type character varying(255),
    message character varying(255),
    meta_info jsonb,
    created_at timestamp without time zone,
    status character varying(255),
    reference_type character varying(255),
    remarks text,
    invoice_id character varying,
    CONSTRAINT saev_wallet_transaction_status_check CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('success'::character varying)::text, ('failed'::character varying)::text])))
);


ALTER TABLE public.saev_wallet_transaction OWNER TO postgres;

--
-- Name: saev_wallet_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.saev_wallet_transaction ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.saev_wallet_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transaction_id_seq OWNER TO postgres;

--
-- Name: saev_db_version id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_db_version ALTER COLUMN id SET DEFAULT nextval('public.saev_db_version_id_seq'::regclass);


--
-- Name: saev_charge_point Unique Charge Point Id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_charge_point
    ADD CONSTRAINT "Unique Charge Point Id" PRIMARY KEY (tenantid, ocpp_charge_point_id);


--
-- Name: saev_alert alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_alert
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: saev_charge_connector chargingconnectors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_charge_connector
    ADD CONSTRAINT chargingconnectors_pkey PRIMARY KEY (id);


--
-- Name: saev_charging_session_log chargingsessionlogs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_charging_session_log
    ADD CONSTRAINT chargingsessionlogs_pkey PRIMARY KEY (id);


--
-- Name: saev_charging_session chargingsessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_charging_session
    ADD CONSTRAINT chargingsessions_pkey PRIMARY KEY (id);


--
-- Name: saev_favourite_station favouritestations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_favourite_station
    ADD CONSTRAINT favouritestations_pkey PRIMARY KEY (id);


--
-- Name: saev_level_header label_header_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_level_header
    ADD CONSTRAINT label_header_pkey PRIMARY KEY (id);


--
-- Name: saev_level_item levelhierarchy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_level_item
    ADD CONSTRAINT levelhierarchy_pkey PRIMARY KEY (id);


--
-- Name: chargebot_load_session load_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chargebot_load_session
    ADD CONSTRAINT load_session_pkey PRIMARY KEY (id);


--
-- Name: saev_payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: saev_permission_master permission_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_permission_master
    ADD CONSTRAINT permission_master_pkey PRIMARY KEY (id);


--
-- Name: saev_rfid rfid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_rfid
    ADD CONSTRAINT rfid_pkey PRIMARY KEY (id);


--
-- Name: saev_role roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_role
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: saev_analytics saev_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_analytics
    ADD CONSTRAINT saev_analytics_pkey PRIMARY KEY (id);


--
-- Name: saev_business_unit saev_business_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_business_unit
    ADD CONSTRAINT saev_business_unit_pkey PRIMARY KEY (id);


--
-- Name: saev_charge_point_unavailability saev_charge_point_unavailability_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_charge_point_unavailability
    ADD CONSTRAINT saev_charge_point_unavailability_pkey PRIMARY KEY (id);


--
-- Name: saev_db_version saev_db_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_db_version
    ADD CONSTRAINT saev_db_version_pkey PRIMARY KEY (id);


--
-- Name: saev_discount saev_discount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_discount
    ADD CONSTRAINT saev_discount_pkey PRIMARY KEY (id);


--
-- Name: saev_discount_team saev_discount_team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_discount_team
    ADD CONSTRAINT saev_discount_team_pkey PRIMARY KEY (id);


--
-- Name: saev_md_charger saev_md_charger_model_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_md_charger
    ADD CONSTRAINT saev_md_charger_model_name_key UNIQUE (model_name);


--
-- Name: saev_md_charger saev_md_charger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_md_charger
    ADD CONSTRAINT saev_md_charger_pkey PRIMARY KEY (id);


--
-- Name: saev_md_connector saev_md_connector_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_md_connector
    ADD CONSTRAINT saev_md_connector_pkey PRIMARY KEY (id);


--
-- Name: saev_md_vehicle saev_md_vehicle_model_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_md_vehicle
    ADD CONSTRAINT saev_md_vehicle_model_key UNIQUE (model);


--
-- Name: saev_md_vehicle saev_md_vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_md_vehicle
    ADD CONSTRAINT saev_md_vehicle_pkey PRIMARY KEY (id);


--
-- Name: saev_notification_hdr saev_notification_hdr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_notification_hdr
    ADD CONSTRAINT saev_notification_hdr_pkey PRIMARY KEY (id);


--
-- Name: saev_notifications saev_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_notifications
    ADD CONSTRAINT saev_notifications_pkey PRIMARY KEY (id);


--
-- Name: saev_ocpp_charge_point saev_ocpp_charge_point_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_ocpp_charge_point
    ADD CONSTRAINT saev_ocpp_charge_point_pkey PRIMARY KEY (id);


--
-- Name: saev_ocpp_connector_status saev_ocpp_connector_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_ocpp_connector_status
    ADD CONSTRAINT saev_ocpp_connector_status_pkey PRIMARY KEY (id);


--
-- Name: saev_ocpp_id_tag saev_ocpp_id_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_ocpp_id_tag
    ADD CONSTRAINT saev_ocpp_id_tag_pkey PRIMARY KEY (id);


--
-- Name: saev_ocpp_message_log saev_ocpp_message_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_ocpp_message_log
    ADD CONSTRAINT saev_ocpp_message_log_pkey PRIMARY KEY (id);


--
-- Name: saev_ocpp_meter_value saev_ocpp_meter_value_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_ocpp_meter_value
    ADD CONSTRAINT saev_ocpp_meter_value_pkey PRIMARY KEY (id);


--
-- Name: saev_ocpp_transaction saev_ocpp_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_ocpp_transaction
    ADD CONSTRAINT saev_ocpp_transaction_pkey PRIMARY KEY (transaction_id);


--
-- Name: saev_ocpp_vid_tag saev_ocpp_vid_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_ocpp_vid_tag
    ADD CONSTRAINT saev_ocpp_vid_tag_pkey PRIMARY KEY (id);


--
-- Name: saev_super_admin saev_super_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_super_admin
    ADD CONSTRAINT saev_super_admin_pkey PRIMARY KEY (id);


--
-- Name: saev_user_devices saev_user_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_user_devices
    ADD CONSTRAINT saev_user_devices_pkey PRIMARY KEY (id);


--
-- Name: saev_vid saev_vid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_vid
    ADD CONSTRAINT saev_vid_pkey PRIMARY KEY (id);


--
-- Name: saev_wallet_transaction saev_wallet_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_wallet_transaction
    ADD CONSTRAINT saev_wallet_transaction_pkey PRIMARY KEY (id);


--
-- Name: saev_sequence_number seq_no_pky; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_sequence_number
    ADD CONSTRAINT seq_no_pky PRIMARY KEY (id);


--
-- Name: saev_setting settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_setting
    ADD CONSTRAINT settings_pkey PRIMARY KEY (tenantid);


--
-- Name: saev_station_media stationmedias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_station_media
    ADD CONSTRAINT stationmedias_pkey PRIMARY KEY (id);


--
-- Name: saev_charge_station stations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_charge_station
    ADD CONSTRAINT stations_pkey PRIMARY KEY (id);


--
-- Name: saev_tariff_plan tariffplans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_tariff_plan
    ADD CONSTRAINT tariffplans_pkey PRIMARY KEY (id);


--
-- Name: saev_tariff_rule tariffrules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_tariff_rule
    ADD CONSTRAINT tariffrules_pkey PRIMARY KEY (id);


--
-- Name: saev_team_dtl team_dtl_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_team_dtl
    ADD CONSTRAINT team_dtl_pkey PRIMARY KEY (id);


--
-- Name: saev_team_hdr team_hdr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_team_hdr
    ADD CONSTRAINT team_hdr_pkey PRIMARY KEY (id);


--
-- Name: saev_team_invoice team_invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_team_invoice
    ADD CONSTRAINT team_invoice_pkey PRIMARY KEY (id);


--
-- Name: saev_trip trips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_trip
    ADD CONSTRAINT trips_pkey PRIMARY KEY (id);


--
-- Name: saev_user_role user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_user_role
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: saev_user_otp userotps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_user_otp
    ADD CONSTRAINT userotps_pkey PRIMARY KEY (id);


--
-- Name: saev_user users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_user
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: saev_vehicle vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_vehicle
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: charge_session_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX charge_session_index ON public.saev_charging_session USING btree (status, ocpp_transaction_id, source);


--
-- Name: charging_session_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX charging_session_index ON public.saev_charging_session USING btree (source);


--
-- Name: id_charge_point_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX id_charge_point_id ON public.saev_charge_point USING btree (ocpp_charge_point_id);


--
-- Name: idx_business_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_business_unit_id ON public.saev_business_unit USING btree (id);


--
-- Name: idx_charge_connector; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_charge_connector ON public.saev_charge_connector USING btree (charge_station_id, charge_point_id, connector_id);


--
-- Name: idx_charge_connector_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_charge_connector_id ON public.saev_charge_connector USING btree (id);


--
-- Name: idx_charge_connector_ids; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_charge_connector_ids ON public.saev_charge_connector USING btree (charge_station_id, charge_point_id, connector_id, ocpp_charge_point_id);


--
-- Name: idx_charge_point_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_charge_point_id ON public.saev_charge_connector USING btree (charge_point_id);


--
-- Name: idx_charge_session_created_at_desc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_charge_session_created_at_desc ON public.saev_charging_session USING btree (created_at DESC);


--
-- Name: idx_charge_station_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_charge_station_id ON public.saev_charging_session USING btree (charge_station_id);


--
-- Name: idx_charge_station_id_business_unit; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_charge_station_id_business_unit ON public.saev_charge_station USING btree (id, business_unit_id);


--
-- Name: idx_charging_session_tenant_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_charging_session_tenant_created_at ON public.saev_charging_session USING btree (tenantid, created_at);


--
-- Name: idx_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_created_at ON public.saev_wallet_transaction USING btree (created_at);


--
-- Name: idx_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customer_id ON public.saev_team_dtl USING btree (customer_id);


--
-- Name: idx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_id ON public.saev_charge_station USING btree (id);


--
-- Name: idx_ocpp_transaction_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ocpp_transaction_id ON public.saev_ocpp_transaction USING btree (transaction_id);


--
-- Name: idx_saev_setting_tenantid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_saev_setting_tenantid ON public.saev_setting USING btree (tenantid);


--
-- Name: idx_station_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_station_id ON public.saev_charge_point USING btree (station_id);


--
-- Name: idx_team_dtl_customer_team_hdr; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_team_dtl_customer_team_hdr ON public.saev_team_dtl USING btree (customer_id, team_hdr_id);


--
-- Name: idx_team_hdr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_team_hdr_id ON public.saev_team_hdr USING btree (id);


--
-- Name: idx_tenantid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenantid ON public.saev_charge_station USING btree (tenantid);


--
-- Name: idx_tenantid_status_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenantid_status_created_at ON public.saev_charging_session USING btree (tenantid, status, created_at);


--
-- Name: idx_transaction_id_measurand; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_id_measurand ON public.saev_ocpp_meter_value USING btree (transaction_id, measurand);


--
-- Name: idx_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_id ON public.saev_user USING btree (id);


--
-- Name: idx_wallet_transaction_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wallet_transaction_id ON public.saev_payment USING btree (wallet_transaction_id);


--
-- Name: meter_value_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX meter_value_index ON public.saev_ocpp_meter_value USING btree (measurand, transaction_id);


--
-- Name: session_charge_point_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_charge_point_id ON public.saev_charging_session USING btree (charge_point_id);


--
-- Name: station_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX station_name_index ON public.saev_charge_station USING btree (name);


--
-- Name: stations_geolocation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stations_geolocation_idx ON public.saev_charge_station USING gist (geolocation);


--
-- Name: saev_charge_connector on_connector_status_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_connector_status_update AFTER UPDATE ON public.saev_charge_connector FOR EACH ROW EXECUTE FUNCTION public.update_session_log();


--
-- Name: saev_md_connector saev_md_connector_charger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saev_md_connector
    ADD CONSTRAINT saev_md_connector_charger_id_fkey FOREIGN KEY (charger_id) REFERENCES public.saev_md_charger(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM rdsadmin;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

