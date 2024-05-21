CREATE EXTENSION IF NOT EXISTS plpgsql;

CREATE EXTENSION IF NOT EXISTS citext;

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE INDEX
    stations_geolocation_idx ON public.saev_charge_station USING gist (geolocation);

CREATE INDEX
    meter_value_index ON public.saev_ocpp_meter_value USING btree (measurand, transaction_id);

CREATE OR REPLACE FUNCTION FIND_STATION_LEVEL_TARIFF
(STATION_ID_INPUT INT) RETURNS TABLE(ID INT, NAME TEXT
, TYPE TEXT) AS 
	$$ $$ BEGIN
	RETURN QUERY
	SELECT
	    stp.id:: INT,
	    stp.name:: TEXT,
	    stp.type:: TEXT
	FROM saev_charge_station AS scs
	    LEFT JOIN saev_tariff_plan AS stp ON scs.tariff_id = stp.id
	WHERE
	    scs.id = station_id_input
	    AND scs.tariff_id IS NOT
NULL; 

END;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION FIND_STATE_LEVEL_TARIFF(
LEVEL_INPUT INT) RETURNS TABLE(ID INT, NAME TEXT, TYPE TEXT) AS 
	$$ $$ BEGIN
	RETURN QUERY
	SELECT
	    stp.id:: INT,
	    stp.name:: TEXT,
	    stp.type:: TEXT
	FROM saev_level_item AS sli
	    LEFT JOIN saev_tariff_plan AS stp ON sli.tariff_id = stp.id
	WHERE
	    sli.id = level_input
	    AND sli.tariff_id IS NOT
NULL; 

END;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION FIND_REGION_LEVEL_TARIFF
(LEVEL_INPUT INT) RETURNS TABLE(ID INT, NAME TEXT, TYPE 
TEXT) AS 
	$$ $$ BEGIN
	RETURN QUERY
	SELECT
	    stp.id:: INT,
	    stp.name:: TEXT,
	    stp.type:: TEXT
	FROM saev_level_item AS sli
	    LEFT JOIN saev_tariff_plan AS stp ON sli.tariff_id = stp.id
	WHERE
	    sli.id = level_input
	    AND sli.tariff_id IS NOT
NULL; 

END;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION FIND_COUNTRY_LEVEL_TARIFF
(LEVEL_INPUT INT) RETURNS TABLE(ID INT, NAME TEXT, TYPE 
TEXT) AS 
	$$ $$ BEGIN
	RETURN QUERY
	SELECT
	    stp.id:: INT,
	    stp.name:: TEXT,
	    stp.type:: TEXT
	FROM saev_level_item AS sli
	    LEFT JOIN saev_tariff_plan AS stp ON sli.tariff_id = stp.id
	WHERE
	    sli.id = level_input
	    AND sli.tariff_id IS NOT
NULL; 

END;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.update_session_log
() RETURNS trigger 
LANGUAGE plpgsql AS 
	$function$ BEGIN -- Check if the status has changed
	IF NEW.status <> OLD.status THEN -- Check if the new status is one of the specified statuses and is different from the existing status
	IF NEW.status IN (
	    'Faulted',
	    'Finishing',
	    'SuspendedEVSE',
	    'SuspendedEV',
	    'Charging'
	)
	AND NEW.status <> OLD.status THEN
	INSERT INTO
	    saev_charging_session_log (
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
	    UPPER (NEW.status),
	    scsl.charge_point_id,
	    scsl.connector_id,
	    'Session ' || NEW.status
	FROM
	    saev_charging_session_log scsl
	WHERE
	    scsl.charge_connector_id = NEW.charge_connector_id
	ORDER BY id DESC
	LIMIT 1;
	END IF;
	END IF;
	RETURN NEW;
	END;
	$function$
; 

CREATE TRIGGER 
	ON_CONNECTOR_STATUS_UPDATE on_connector_status_update after
	update
	    ON public.saev_charge_connector for each row
	execute
	    function update_session_log ()
; 