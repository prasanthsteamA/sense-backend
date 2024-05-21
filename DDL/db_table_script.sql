CREATE TABLE
    public.saev_permission_master (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        "name" varchar(100) NULL,
        displayname varchar(100) NULL,
        createdat timestamp NULL,
        updatedat timestamp NULL,
        "module" varchar(255) NULL,
        actiontype varchar(255) NULL,
        CONSTRAINT permission_master_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_alert (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        created_at timestamp NULL,
        updated_at timestamp NULL,
        alert varchar(255) NULL,
        charge_station_id int4 NULL,
        charge_point_id int4 NULL,
        connector_id int4 NULL,
        status varchar(255) NULL,
        created_by varchar(255) NULL,
        updated_by varchar(255) NULL,
        tenant_id varchar(255) NULL,
        level_1 int4 NULL,
        level_2 int4 NULL,
        level_3 int4 NULL,
        charge_connector_id int4 NULL,
        ocpp_log_id int8 NULL,
        "call" varchar(4096) NULL,
        call_result varchar(4096) NULL,
        call_error varchar(4096) NULL,
        CONSTRAINT alerts_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_analytics (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenant_id varchar(255) NULL,
        level_type varchar(255) NULL,
        level_id varchar(255) NULL,
        energy_consumed float8 NULL DEFAULT '0':: double precision,
        total_revenue float8 NULL DEFAULT '0':: double precision,
        total_session int4 NULL DEFAULT 0,
        "type" varchar(255) NULL,
        "year" int4 NULL,
        "month" int4 NULL,
        "day" int4 NULL,
        created_at timestamp NULL,
        day_start_time varchar(255) NULL,
        day_end_time varchar(255) NULL,
        CONSTRAINT saev_analytics_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_business_unit (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenant_id varchar(255) NOT NULL,
        business_unit_name varchar(255) NOT NULL,
        address json NULL,
        gst_no varchar(20) NULL,
        cgst numeric(10, 2) NULL,
        sgst numeric(10, 2) NULL,
        igst numeric(10, 2) NULL,
        is_deleted bool NULL DEFAULT false,
        created_at timestamp NULL,
        created_by varchar(255) NULL,
        updated_at timestamp NULL,
        updated_by varchar(255) NULL,
        alias_name varchar(255) NULL,
        CONSTRAINT saev_business_unit_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_charge_connector (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        isactive bool NULL DEFAULT true,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        updatedat timestamp(6) NULL,
        updatedby varchar(200) NULL,
        status varchar(255) NULL,
        level_1 int4 NULL,
        level_2 int4 NULL,
        level_3 int4 NULL,
        charge_station_id int4 NULL,
        charge_point_id int4 NULL,
        connector_id int4 NULL,
        connector_type varchar NULL,
        tenant_id varchar NULL,
        peak_power varchar(100) NULL,
        current_type varchar(100) NULL,
        tariff_id int4 NULL,
        charge_connector_id int4 NULL,
        ocpp_charge_point_id varchar(255) NULL,
        peak_power_rank float8 NULL DEFAULT '0':: double precision,
        level1 int4 NULL,
        level2 int4 NULL,
        level3 int4 NULL,
        discount_id int4 NULL,
        reason text NULL,
        CONSTRAINT chargingconnectors_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_charge_point_unavailability (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        start_time timestamp NULL,
        end_time timestamp NULL,
        duration float8 NULL,
        created_at timestamp NULL,
        charge_point_id varchar(255) NULL,
        CONSTRAINT saev_charge_point_unavailability_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_charge_station (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenantid varchar(200) NULL,
        "name" varchar(100) NULL,
        always_open bool NULL DEFAULT true,
        latitude float8 NULL,
        longitude float8 NULL,
        geolocation public.geometry(point, 4326) NULL,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        updatedat timestamp(6) NULL,
        updatedby varchar(200) NULL,
        opening_hours json NULL,
        address json NULL,
        total_sessions int4 NULL DEFAULT 0,
        level_1 int4 NULL,
        level_2 int4 NULL,
        level_3 int4 NULL,
        tariff_id int4 NULL,
        energy_consumed int4 NULL DEFAULT 0,
        charge_station_id int4 NULL,
        business_unit_id int4 NULL,
        amenities json NULL,
        discount_id int4 NULL,
        station_charger_type varchar(255) NULL DEFAULT 'AC':: character varying,
        contact_person varchar(255) NULL,
        contact_number varchar(255) NULL,
        CONSTRAINT stations_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_charging_session (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        charge_point_id int4 NOT NULL,
        connector_id int4 NOT NULL,
        user_id varchar(500) NOT NULL,
        status varchar(200) NULL,
        started_time timestamp NULL,
        end_time timestamp NULL,
        power_consumed float8 NULL DEFAULT '0':: double precision,
        total_cost float8 NULL DEFAULT '0':: double precision,
        total_duration float8 NULL DEFAULT '0':: double precision,
        created_at timestamp NULL,
        created_by varchar(200) NULL,
        updated_at timestamp NULL,
        updated_by varchar(200) NULL,
        charge_station_id int4 NULL,
        invoice varchar(500) NULL,
        ocpp_transaction_id int4 NULL,
        tenantid varchar(255) NULL,
        break_down jsonb NULL,
        tariff_info jsonb NULL,
        charge_connector_id int4 NULL,
        level_1 int4 NULL,
        level_2 int4 NULL,
        level_3 int4 NULL,
        amount_before_tax float8 NULL,
        vehicle_details jsonb NULL,
        team_id int4 NULL,
        team_inv_generated bool NULL DEFAULT false,
        "source" varchar NULL,
        user_rfid varchar NULL,
        inv_no varchar(256) NULL,
        start_meter_value int8 NULL,
        last_meter_value int8 NULL,
        deducted_cost float8 NULL,
        closed_by varchar NULL,
        start_soc varchar NULL,
        end_soc varchar NULL,
        is_interrupted bool NULL DEFAULT false,
        last_meter_value_time timestamp NULL,
        discount_info jsonb NULL,
        amount_with_discount float8 NULL,
        discount_amount float8 NULL,
        reason varchar NULL,
        is_suspicious bool NULL DEFAULT false,
        stop_reason varchar NULL,
        CONSTRAINT chargingsessions_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_charging_session_log (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        session_id int4 NOT NULL,
        charge_connector_id int4 NULL,
        created_at timestamp NULL,
        created_by varchar(200) NULL,
        "type" varchar(255) NULL,
        charge_point_id int4 NULL,
        connector_id int4 NULL,
        "text" varchar(255) NULL,
        "source" varchar NULL,
        user_rfid varchar NULL,
        reason varchar(255) NULL,
        CONSTRAINT chargingsessionlogs_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_discount (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        "name" varchar(100) NOT NULL,
        "type" varchar(20) NOT NULL,
        discount_value numeric NOT NULL,
        is_active bool NOT NULL,
        is_fixed_time_period bool NULL,
        tenant_id varchar NOT NULL,
        createdat timestamp NULL,
        createdby varchar NULL,
        updatedat timestamp NULL,
        updatedby varchar NULL,
        start_datetime timestamp NULL,
        end_datetime timestamp NULL,
        config jsonb NULL,
        available_to jsonb NULL,
        is_deleted bool NULL,
        config_parent_level jsonb NULL,
        CONSTRAINT saev_discount_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_discount_team (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        team_id int4 NOT NULL,
        "level" varchar NOT NULL,
        level_id int4 NOT NULL,
        discount_id int4 NOT NULL,
        created_by varchar NULL,
        updated_by varchar NULL,
        created_at timestamp NULL,
        updated_at timestamp NULL,
        is_active bool NULL,
        tenant_id varchar NULL,
        CONSTRAINT saev_discount_team_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_favourite_station (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        userid varchar(500) NOT NULL,
        stationid int4 NOT NULL,
        isactive bool NULL DEFAULT true,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        CONSTRAINT favouritestations_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_level_header (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenant_id varchar(200) NOT NULL,
        "level" varchar(200) NOT NULL,
        "name" varchar(255) NOT NULL,
        created_at date NULL,
        CONSTRAINT label_header_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_level_item (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        created_at date NULL,
        "name" varchar(255) NULL,
        tenant_id varchar(255) NULL,
        created_by varchar(255) NULL,
        updated_at date NULL,
        updated_by varchar(255) NULL,
        level_header_id int4 NULL,
        parent_id int4 NULL DEFAULT 0,
        "level" int4 NULL,
        tariff_id int4 NULL,
        discount_id int4 NULL,
        CONSTRAINT levelhierarchy_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_md_charger (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenantid varchar(200) NULL,
        oem varchar(200) NULL,
        model_name public.citext NULL,
        charger_type varchar(200) NULL,
        peak_power float8 NULL,
        dc_output_current float8 NULL,
        dc_output_voltage float8 NULL,
        ac_input_current float8 NULL,
        ac_input_voltage float8 NULL,
        no_of_connectors int4 NULL,
        createdat timestamp NULL,
        createdby varchar(200) NULL,
        updatedat timestamp NULL,
        updatedby varchar(200) NULL,
        isdeleted bool NULL DEFAULT false,
        CONSTRAINT saev_md_charger_model_name_key UNIQUE (model_name),
        CONSTRAINT saev_md_charger_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_md_vehicle (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenantid varchar(200) NULL,
        manufacturer varchar(200) NULL,
        model public.citext NULL,
        battery_capacity float8 NULL,
        createdat timestamp NULL,
        createdby varchar(200) NULL,
        updatedat timestamp NULL,
        updatedby varchar(200) NULL,
        isdeleted bool NULL DEFAULT false,
        CONSTRAINT saev_md_vehicle_model_key UNIQUE (model),
        CONSTRAINT saev_md_vehicle_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_notification_hdr (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenantid varchar(200) NULL,
        notify_type varchar(50) NULL,
        notify_send_to varchar(100) NULL,
        is_rule_based bool NULL DEFAULT false,
        rule_config jsonb NULL,
        mail_id jsonb NULL,
        team_id jsonb NULL,
        notify_schedule_type varchar(100) NULL,
        notify_schedule timestamp NULL,
        notify_content jsonb NULL,
        notify_action jsonb NULL,
        is_active bool NULL DEFAULT true,
        is_deleted bool NULL DEFAULT false,
        notify_status varchar(256) NULL,
        created_at timestamp NULL,
        created_by varchar(100) NULL,
        updated_at timestamp NULL,
        updated_by varchar(100) NULL,
        media_url varchar(1000) NULL,
        CONSTRAINT saev_notification_hdr_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_notifications (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenant_id varchar(100) NOT NULL,
        user_id varchar(100) NOT NULL,
        notification_title text NOT NULL,
        notification_body text NOT NULL,
        notification_type varchar(20) NOT NULL,
        scheduled_type varchar(20) NOT NULL,
        scheduled_time timestamp NULL,
        sent_at timestamp NULL,
        attachment_url varchar(255) NULL,
        other_metadata jsonb NULL,
        created_by varchar(100) NULL,
        updated_by varchar(100) NULL,
        created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        notification_data json NULL,
        CONSTRAINT saev_notifications_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_ocpp_charge_point (
        id int8 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
        charge_point_id varchar(255) NULL,
        charge_station_id varchar(255) NULL,
        connectors int4 NOT NULL,
        is_boot_notif_received bool NOT NULL,
        status varchar(255) NULL,
        tenant_id varchar(255) NULL,
        updated_at timestamp(6) NULL,
        CONSTRAINT saev_ocpp_charge_point_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_ocpp_connector_status (
        id int8 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
        charge_point_id varchar(255) NULL,
        connector_id int4 NOT NULL,
        error_code varchar(255) NULL,
        info varchar(255) NULL,
        status varchar(255) NULL,
        updated_at timestamp(6) NULL,
        vendor_error_code varchar(255) NULL,
        vendor_id varchar(255) NULL,
        CONSTRAINT saev_ocpp_connector_status_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_ocpp_id_tag (
        id int8 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
        expiry_date timestamp(6) NULL,
        id_tag varchar(255) NULL,
        status varchar(255) NULL,
        CONSTRAINT saev_ocpp_id_tag_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_ocpp_message_log (
        id int8 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
        "call" varchar(100000) NULL,
        call_action varchar(256) NULL,
        call_error varchar(100000) NULL,
        call_result varchar(100000) NULL,
        charge_point_id varchar(255) NULL,
        created_at timestamp(6) NULL,
        is_error bool NOT NULL,
        "type" varchar(255) NULL,
        connector_id int4 NULL,
        id_tag varchar(255) NULL,
        status varchar(255) NULL,
        transaction_id int4 NULL,
        CONSTRAINT saev_ocpp_message_log_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_ocpp_meter_value (
        id int8 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
        charge_point_id varchar(255) NULL,
        connector_id int4 NOT NULL,
        context varchar(255) NULL,
        format varchar(255) NULL,
        "location" varchar(255) NULL,
        measurand varchar(255) NULL,
        meter_value varchar(255) NULL,
        phase varchar(255) NULL,
        "timestamp" timestamp(6) NULL,
        transaction_id int4 NOT NULL,
        unit varchar(255) NULL,
        CONSTRAINT saev_ocpp_meter_value_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_ocpp_transaction (
        transaction_id int8 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
        charge_point_id varchar(255) NULL,
        connector_id int4 NOT NULL,
        id_tag varchar(255) NULL,
        meter_start int4 NULL,
        meter_stop int4 NULL,
        reason varchar(255) NULL,
        started_at timestamp(6) NULL,
        stopped_at timestamp(6) NULL,
        transaction_status varchar(255) NULL,
        CONSTRAINT saev_ocpp_transaction_pkey PRIMARY KEY (transaction_id)
    );

CREATE TABLE
    public.saev_ocpp_vid_tag (
        id int8 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
        charge_point_id varchar(255) NULL,
        connector_id int4 NULL,
        expires_at timestamp(6) NULL,
        request_status varchar(255) NULL,
        vid_tag varchar(255) NULL,
        CONSTRAINT saev_ocpp_vid_tag_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_payment (
        id int8 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
        result_status varchar(255) NULL,
        result_code varchar(255) NULL,
        result_msg varchar(255) NULL,
        txn_id varchar(255) NULL,
        bank_txn_id varchar(255) NULL,
        order_id varchar(255) NOT NULL,
        txn_amount varchar(255) NULL,
        txn_type varchar(255) NULL,
        gateway_name varchar(255) NULL,
        bank_name varchar(255) NULL,
        mid varchar(255) NULL,
        payment_mode varchar(255) NULL,
        refund_amt varchar(255) NULL,
        txn_date varchar(255) NULL,
        txn_token varchar(255) NOT NULL,
        created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp NULL,
        wallet_transaction_id int4 NULL,
        user_id varchar(255) NULL,
        tenant_id varchar(255) NULL,
        invoice_id varchar NULL,
        CONSTRAINT payment_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_rfid (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        created_at timestamp NULL,
        user_id varchar(255) NULL,
        rfidnumber varchar(255) NULL,
        tenant_id varchar(255) NULL,
        created_by varchar(255) NULL,
        updated_by varchar(255) NULL,
        updated_at timestamp NULL,
        isactive bool NULL DEFAULT true,
        id_type public.id_type_enum NULL DEFAULT 'remote_id':: id_type_enum,
        serial_number varchar(255) NULL,
        batch_number varchar(100) NULL,
        expiry_date timestamp NULL,
        assigned_on timestamp NULL,
        CONSTRAINT rfid_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_role (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        created_at date NULL,
        "name" varchar(255) NULL,
        tenant_id varchar(255) NULL,
        created_by varchar(255) NULL,
        updated_at date NULL,
        updated_by varchar(255) NULL,
        permissions jsonb NULL,
        is_deleted bool NULL DEFAULT false,
        effective_role_level varchar(255) NULL,
        effective_level_id jsonb NULL,
        level_1 jsonb NULL,
        level_2 jsonb NULL,
        level_3 jsonb NULL,
        charge_station_id jsonb NULL,
        charge_point_id jsonb NULL,
        charge_connector_id jsonb NULL,
        CONSTRAINT roles_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_sequence_number (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenantid varchar(255) NULL,
        prefix varchar(255) NULL,
        finyear int4 NULL,
        suffix varchar(255) NULL,
        is_active bool NULL DEFAULT true,
        created_at timestamp NULL,
        updated_at timestamp NULL,
        created_by varchar(255) NULL,
        updated_by varchar(255) NULL,
        reference varchar(256) NULL,
        CONSTRAINT seq_no_pky PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_session_attempt (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        charge_point_id int4 NULL,
        "action" varchar NULL,
        status varchar NULL,
        created_at timestamp NULL,
        updated_at timestamp NULL,
        session_id int4 NULL
    );

CREATE TABLE
    public.saev_setting (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenantid varchar(200) NOT NULL,
        primary_color varchar(100) NULL,
        secondary_color varchar(100) NULL,
        distance_unit varchar(100) NULL,
        use_gradient bool NULL DEFAULT false,
        company_logo varchar(500) NULL,
        currency varchar(100) NULL,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        updatedat timestamp(6) NULL,
        updatedby varchar(200) NULL,
        isactive bool NULL DEFAULT true,
        minimum_wallet_balance float8 NULL,
        gradient_left varchar(255) NULL,
        gradient_right varchar(255) NULL,
        currency_symbol varchar(255) NULL,
        ocpp_sokcet_endpoint varchar(255) NULL,
        time_zone varchar(10) NULL,
        connector_types jsonb NULL,
        tenant_name varchar(255) NULL,
        display_name varchar(255) NULL,
        tenant_support_email varchar(255) NULL,
        CONSTRAINT settings_pkey PRIMARY KEY (tenantid)
    );

CREATE TABLE
    public.saev_station_media (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        stationid int4 NULL,
        "name" varchar(100) NULL,
        status varchar(100) NULL DEFAULT 'Draft':: character varying,
        "type" varchar(100) NULL,
        url varchar(1000) NULL,
        ispublic bool NULL DEFAULT true,
        isactive bool NULL DEFAULT true,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        updatedat timestamp(6) NULL,
        updatedby varchar(200) NULL,
        CONSTRAINT stationmedias_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_super_admin (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        last_downtime_sync timestamp NULL,
        heart_beat_time_interval float8 NULL,
        CONSTRAINT saev_super_admin_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_tariff_plan (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        "name" varchar(200) NULL,
        "type" varchar(100) NULL,
        isactive bool NULL DEFAULT true,
        connection_fee float8 NULL DEFAULT '0':: double precision,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        updatedat timestamp(6) NULL,
        updatedby varchar(200) NULL,
        tenantid varchar(255) NULL,
        CONSTRAINT tariffplans_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_tariff_rule (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tariffplan int4 NOT NULL,
        "type" varchar(100) NULL,
        isactive bool NULL DEFAULT true,
        costperkwh float8 NULL DEFAULT 0.0,
        costperhour float8 NULL DEFAULT 0.0,
        from_time time NULL,
        to_time time NULL,
        dayname varchar(100) NULL,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        updatedat timestamp(6) NULL,
        updatedby varchar(200) NULL,
        groupid varchar(255) NULL,
        costperkwh_ac float8 NULL DEFAULT 0.0,
        costperkwh_dc float8 NULL DEFAULT 0.0,
        costperhour_ac float8 NULL DEFAULT 0.0,
        costperhour_dc float8 NULL DEFAULT 0.0,
        CONSTRAINT tariffrules_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_team_dtl (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        team_hdr_id int4 NULL,
        customer_id varchar(100) NULL,
        is_lead bool NULL DEFAULT false,
        is_deleted bool NULL DEFAULT false,
        created_at timestamp NULL,
        updated_at timestamp NULL,
        created_by varchar(255) NULL,
        updated_by varchar(255) NULL,
        CONSTRAINT team_dtl_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_team_hdr (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenant_id varchar(255) NULL,
        team_name varchar(4096) NULL,
        is_deleted bool NULL DEFAULT false,
        team_gst varchar(255) NULL,
        payment_type varchar(255) NULL,
        invoice_address varchar(4096) NULL,
        created_at timestamp NULL,
        updated_at timestamp NULL,
        created_by varchar(255) NULL,
        updated_by varchar(255) NULL,
        billing_cycle int4 NULL,
        discount_id jsonb NULL,
        CONSTRAINT team_hdr_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_team_invoice (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenant_id varchar(255) NULL,
        team_id int4 NULL,
        billing_month varchar(255) NULL,
        billing_amount float8 NULL,
        paid_on timestamp NULL,
        invoice varchar(500) NULL,
        payment_status varchar(255) NULL,
        is_active bool NULL DEFAULT true,
        created_at timestamp NULL,
        updated_at timestamp NULL,
        created_by varchar(255) NULL,
        updated_by varchar(255) NULL,
        sessions_count int4 NULL,
        energy_consumed int4 NULL,
        breakdown json NULL,
        CONSTRAINT team_invoice_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_trip (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        userid varchar(500) NOT NULL,
        vehicleid int4 NOT NULL,
        originname varchar(500) NULL,
        destinationname varchar(500) NULL,
        originlat float8 NULL,
        originlong float8 NULL,
        destinationlat float8 NULL,
        destinationlong float8 NULL,
        initialcharging float8 NULL DEFAULT 0.0,
        lastcharging float8 NULL DEFAULT 0.0,
        powerconsumed float8 NULL DEFAULT 0.0,
        distance float8 NULL DEFAULT 0.0,
        duration float8 NULL DEFAULT 0.0,
        isactive bool NULL DEFAULT true,
        updatedat timestamp(6) NULL,
        updatedby varchar(200) NULL,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        CONSTRAINT trips_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_user (
        id varchar(100) NOT NULL,
        tenantid varchar(100) NULL,
        usertype varchar(100) NULL,
        email varchar(100) NULL,
        phone varchar(100) NULL,
        "name" varchar(100) NULL,
        username varchar(100) NULL,
        cover_image varchar(500) NULL,
        logo varchar(500) NULL,
        isactive bool NULL DEFAULT true,
        createdat timestamp(6) NULL,
        createdby varchar(100) NULL,
        updatedat timestamp(6) NULL,
        updatedby varchar(100) NULL,
        wallet_balance float8 NULL DEFAULT '0':: double precision,
        is_deleted bool NULL DEFAULT false,
        business_unit_details jsonb NULL,
        is_email_verified bool NULL DEFAULT false,
        CONSTRAINT users_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_user_devices (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        user_id varchar(100) NULL,
        tenant_id varchar(100) NOT NULL,
        device_type varchar(50) NOT NULL,
        device_token varchar(255) NOT NULL,
        device_name varchar(100) NULL,
        device_model varchar(100) NULL,
        os_version varchar(50) NULL,
        app_version varchar(50) NULL,
        last_active_at timestamp NULL,
        created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        other_metadata jsonb NULL,
        CONSTRAINT saev_user_devices_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_user_otp (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenantid varchar(100) NULL,
        email varchar(100) NULL,
        username varchar(100) NULL,
        phone varchar(100) NULL,
        otp varchar(100) NULL,
        expiryin int4 NULL DEFAULT 15,
        isactive bool NULL DEFAULT true,
        createdat timestamp(6) NULL,
        verify_token varchar(100) NULL,
        signature varchar(256) NULL,
        CONSTRAINT userotps_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_user_role (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        user_id varchar(255) NULL,
        tenant_id varchar(255) NULL,
        created_by varchar(255) NULL,
        created_at date NULL,
        updated_by varchar(255) NULL,
        updated_at date NULL,
        role_id int4 NOT NULL,
        CONSTRAINT user_roles_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_vehicle (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        userid varchar(500) NOT NULL,
        nickname varchar(200) NOT NULL,
        manufacturer varchar(200) NULL,
        model varchar(200) NULL,
        "number" varchar(200) NULL,
        "type" varchar(100) NULL,
        connectortype varchar(100) NULL,
        power float8 NULL DEFAULT 0.0,
        isactive bool NULL DEFAULT true,
        updatedat timestamp(6) NULL,
        updatedby varchar(200) NULL,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        image varchar(500) NULL,
        is_default bool NULL,
        is_temporary bool NULL,
        temp_created_at timestamp NULL,
        tenantid varchar(255) NULL,
        CONSTRAINT vehicles_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_vid (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        user_id varchar NULL,
        created_at timestamp NULL,
        ocpp_charge_point_id varchar NULL,
        vrn varchar NULL,
        status varchar NULL,
        vid_tag varchar NOT NULL,
        created_by varchar NULL,
        updated_at timestamp NULL,
        updated_by varchar NULL,
        tenant_id varchar NULL,
        connector_id int4 NULL,
        CONSTRAINT saev_vid_pkey PRIMARY KEY (id)
    );

CREATE TABLE
    public.saev_wallet_transaction (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        tenant_id varchar(255) NULL,
        user_id varchar(255) NULL,
        amount float8 NULL,
        currency varchar(255) NULL,
        balance float8 NULL,
        "type" varchar(255) NULL,
        message varchar(255) NULL,
        meta_info jsonb NULL,
        created_at timestamp NULL,
        status varchar(255) NULL,
        reference_type varchar(255) NULL,
        remarks text NULL,
        invoice_id varchar NULL,
        CONSTRAINT saev_wallet_transaction_pkey PRIMARY KEY (id),
        CONSTRAINT saev_wallet_transaction_status_check CHECK ( ( (status):: text = ANY ( (
                        ARRAY ['pending':: character varying,
                        'success':: character varying,
                        'failed':: character varying]
                    ):: text []
                )
            )
        )
    );

CREATE TABLE
    public.saev_md_connector (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        charger_id int4 NULL,
        current_type varchar(100) NULL,
        connector_type varchar(200) NULL,
        peak_power float8 NULL,
        createdat timestamp NULL,
        createdby varchar(200) NULL,
        updatedat timestamp NULL,
        updatedby varchar(200) NULL,
        isdeleted bool NULL DEFAULT false,
        connector_id int4 NULL,
        CONSTRAINT saev_md_connector_pkey PRIMARY KEY (id),
        CONSTRAINT saev_md_connector_charger_id_fkey FOREIGN KEY (charger_id) REFERENCES public.saev_md_charger(id)
    );

CREATE TABLE
    public.saev_charge_point (
        id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
        station_id int4 NOT NULL,
        serial_number varchar(200) NULL,
        model varchar(100) NULL,
        no_of_connectors int4 NULL,
        manufacturer_name varchar(200) NULL,
        createdat timestamp(6) NULL,
        createdby varchar(200) NULL,
        updatedat timestamp(6) NULL,
        updatedby varchar(200) NULL,
        charge_point_id int4 NULL,
        level_1 int4 NULL,
        level_2 int4 NULL,
        level_3 int4 NULL,
        peak_power varchar(255) NULL,
        ac_input_voltage varchar(255) NULL,
        ac_max_current varchar(255) NULL,
        fm_number varchar(255) NULL,
        iccid_number varchar(255) NULL,
        imsi_number varchar(255) NULL,
        is_active bool NULL,
        custom_name varchar(200) NULL,
        heart_beat timestamp NULL,
        charge_station_id int4 NULL,
        tariff_id int4 NULL,
        ocpp_charge_point_id varchar(255) NOT NULL,
        total_energy_consumed int4 NULL DEFAULT 0,
        charger_type varchar(255) NULL DEFAULT 'AC':: character varying,
        created_at timestamp(6) NULL,
        created_by varchar(200) NULL,
        mac_address varchar(100) NULL,
        updated_at timestamp(6) NULL,
        updated_by varchar(200) NULL,
        landmark varchar(255) NULL,
        discount_id int4 NULL,
        reason text NULL,
        ispublished bool NULL DEFAULT false,
        isdeleted bool NULL DEFAULT false,
        tenantid varchar(200) NOT NULL,
        station_owned bool NULL DEFAULT false,
        total_sessions int4 NULL,
        CONSTRAINT "Unique Charge Point Id" PRIMARY KEY (
            tenantid,
            ocpp_charge_point_id
        )
    );