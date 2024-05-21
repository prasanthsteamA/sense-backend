--
-- PostgreSQL database dump
--

-- Dumped from database version 13.10
-- Dumped by pg_dump version 16.0

-- Started on 2023-11-15 15:13:57 IST

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
-- TOC entry 5141 (class 0 OID 24606)
-- Dependencies: 303
-- Data for Name: saev_permission_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (4, 'USER_MANAGEMENT:VIEW', 'user management', '2023-02-16 13:19:13.654', '2023-02-16 13:17:20.387', 'USER_MANAGEMENT', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (5, 'TARIFF:VIEW', 'tariff', '2023-02-16 13:19:13.654', '2023-02-16 13:19:13.654', 'TARIFF', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (6, 'CHARGING_SESSIONS:VIEW', 'charging sessions', '2023-02-16 13:20:48.441', '2023-02-16 13:17:20.387', 'CHARGING_SESSIONS', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (11, 'CUSTOMER_PROFILE:MODIFY', 'customer profile', '2023-02-16 13:18:52.571', '2023-02-16 13:18:52.571', 'CUSTOMER_PROFILE', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (13, 'USER_MANAGEMENT:MODIFY', 'user management', '2023-02-16 13:19:13.654', '2023-02-16 13:19:13.654', 'USER_MANAGEMENT', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (14, 'USER_MANAGEMENT:DELETE', 'user management', '2023-02-16 13:19:13.654', '2023-02-16 13:19:13.654', 'USER_MANAGEMENT', 'DELETE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (17, 'TARIFF:MODIFY', 'tariff', '2023-02-16 13:19:13.654', '2023-02-16 13:19:13.654', 'TARIFF', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (18, 'TARIFF:CREATE', 'tariff', '2023-02-16 13:19:13.654', '2023-02-16 13:19:13.654', 'TARIFF', 'CREATE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (19, 'USER_MANAGEMENT:CREATE', 'user management', '2023-02-16 13:19:13.654', '2023-02-16 13:19:13.654', 'USER_MANAGEMENT', 'CREATE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (43, 'ALERTS:VIEW', 'alerts', '2023-02-16 13:17:20.387', '2023-02-16 13:17:20.387', 'ALERTS', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (44, 'ALERTS:MODIFY', 'alerts', '2023-02-16 13:17:20.387', '2023-02-16 13:17:20.387', 'ALERTS', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (45, 'BUSINESS_UNIT:VIEW', 'business unit', '2023-05-30 12:45:07.537', '2023-05-30 12:45:07.537', 'BUSINESS_UNIT', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (46, 'BUSINESS_UNIT:CREATE', 'business unit', '2023-05-30 12:45:07.537', '2023-05-30 12:45:07.537', 'BUSINESS_UNIT', 'CREATE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (47, 'BUSINESS_UNIT:MODIFY', 'business unit', '2023-05-30 12:45:07.537', '2023-05-30 12:45:07.537', 'BUSINESS_UNIT', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (48, 'BUSINESS_UNIT:DELETE', 'business unit', '2023-05-30 12:45:07.537', '2023-05-30 12:45:07.537', 'BUSINESS_UNIT', 'DELETE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (53, 'AUTHENTICATION:VIEW', 'authentication', '2023-06-07 01:45:07.537', '2023-06-07 01:45:07.537', 'AUTHENTICATION', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (55, 'AUTHENTICATION:MODIFY', 'authentication', '2023-06-07 01:45:07.537', '2023-06-07 01:45:07.537', 'AUTHENTICATION', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (56, 'AUTHENTICATION:DELETE', 'authentication', '2023-06-07 01:45:07.537', '2023-06-07 01:45:07.537', 'AUTHENTICATION', 'DELETE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (57, 'TENANT:MODIFY', 'tenant', '2023-06-07 01:45:07.537', '2023-06-07 01:45:07.537', 'TENANT', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (54, 'AUTHENTICATION:CREATE', 'authentication', '2023-06-07 01:45:07.537', '2023-06-07 01:45:07.537', 'AUTHENTICATION', 'CREATE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (7, 'CHARGE_POINT:VIEW', 'charge point', '2023-08-04 01:45:07.537', NULL, 'CHARGE_POINT', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (8, 'REPORTS:VIEW', 'Reports', '2023-08-07 10:28:22.633946', '2023-08-07 10:28:22.633946', 'REPORTS', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (12, 'DISCOUNTS:VIEW', 'discounts', '2023-08-24 01:45:07.537', '2023-08-25 01:45:07.537', 'DISCOUNTS', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (15, 'DISCOUNTS:CREATE', 'discounts', '2023-08-24 01:45:07.537', '2023-08-25 01:45:07.537', 'DISCOUNTS', 'CREATE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (16, 'DISCOUNTS:MODIFY', 'discounts', '2023-08-24 01:45:07.537', '2023-08-25 01:45:07.537', 'DISCOUNTS', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (20, 'DISCOUNTS:DELETE', 'discounts', '2023-08-24 01:45:07.537', '2023-08-25 01:45:07.537', 'DISCOUNTS', 'DELETE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (21, 'NOTIFICATIONS:VIEW', 'Notifications', '2023-08-25 22:58:49.758457', '2023-08-25 22:58:49.758457', 'NOTIFICATIONS', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (22, 'NOTIFICATIONS:CREATE', 'Notifications', '2023-08-25 23:00:48.88285', '2023-08-25 23:00:48.88285', 'NOTIFICATIONS', 'CREATE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (23, 'NOTIFICATIONS:MODIFY', 'Notifications', '2023-08-25 23:00:53.593198', '2023-08-25 23:00:53.593198', 'NOTIFICATIONS', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (24, 'NOTIFICATIONS:DELETE', 'Notifications', '2023-08-25 23:00:56.915547', '2023-08-25 23:00:56.915547', 'NOTIFICATIONS', 'DELETE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (25, 'CHARGING_SESSIONS:MODIFY', 'charging sessions', '2023-08-30 09:53:36.422671', '2023-08-30 09:53:36.422671', 'CHARGING_SESSIONS', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (3, 'CHARGE_STATION:MODIFY', 'charge station', '2023-02-16 13:19:02.688', '2023-02-16 13:17:20.387', 'CHARGE_STATION', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (28, 'CHARGING_SESSIONS:ACTION_REMOTE_STOP', 'Remote Stop', NULL, NULL, 'CHARGING_SESSIONS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (50, 'TEAMS:CREATE', 'teams', '2023-06-07 01:45:07.537', '2023-06-07 01:45:07.537', 'TEAM_MANAGEMENT', 'CREATE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (51, 'TEAMS:MODIFY', 'teams', '2023-06-07 01:45:07.537', '2023-06-07 01:45:07.537', 'TEAM_MANAGEMENT', 'MODIFY');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (58, 'AUTHENTICATION:ACTION_APPROVE_AUTOCHARGE_REQUEST', 'Approve autocharge request', NULL, NULL, 'AUTHENTICATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (59, 'AUTHENTICATION:ACTION_MARK_RFID_AS_SHIPPED', 'Mark RFID as shipped', '2023-09-09 00:48:20.5172', NULL, 'AUTHENTICATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (9, 'CHARGE_STATION:VIEW', 'charge station', '2023-02-16 13:17:20.387', '2023-02-16 13:17:20.387', 'CHARGE_STATION', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (32, 'CUSTOMER_PROFILE:ACTION_TOPUP', 'Topup', '2023-09-09 00:26:48.630079', NULL, 'CUSTOMER_PROFILE', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (33, 'CUSTOMER_PROFILE:ACTION_REFUND', 'Refund', '2023-09-09 00:27:18.577315', NULL, 'CUSTOMER_PROFILE', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (34, 'CUSTOMER_PROFILE:ACTION_REMOTE_START', 'Remote start', '2023-09-09 00:27:54.629927', NULL, 'CUSTOMER_PROFILE', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (35, 'CUSTOMER_PROFILE:ACTION_REMOTE_STOP', 'Remote stop', '2023-09-09 00:28:10.259632', NULL, 'CUSTOMER_PROFILE', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (36, 'CUSTOMER_PROFILE:ACTION_DOWNLOAD_INVOICE', 'Download invoice', '2023-09-09 00:28:55.997976', NULL, 'CUSTOMER_PROFILE', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (37, 'CUSTOMER_PROFILE:ACTION_SEND_VERFICATION_LINK', 'Send verification link', '2023-09-09 00:29:39.747087', NULL, 'CUSTOMER_PROFILE', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (38, 'AUTHENTICATION:ACTION_ACTIVATE_RFID', 'Activate RFID', '2023-09-09 00:31:08.332955', NULL, 'AUTHENTICATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (39, 'AUTHENTICATION:ACTION_DEACTIVATE_RFID', 'Deactivate RFID', '2023-09-09 00:31:24.549908', NULL, 'AUTHENTICATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (40, 'AUTHENTICATION:ACTION_ASSIGN_RFID', 'Assign RFID', '2023-09-09 00:31:56.789295', NULL, 'AUTHENTICATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (41, 'AUTHENTICATION:ACTION_UNASSIGN_RFID', 'Unassign RFID', '2023-09-09 00:32:31.468225', NULL, 'AUTHENTICATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (42, 'AUTHENTICATION:ACTION_UNASSIGN_AUTOCHARGE', 'Unassign Autocharge', '2023-09-09 00:32:57.821965', NULL, 'AUTHENTICATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (62, 'AUTHENTICATION:ACTION_BULK_ASSIGN_RFID', 'Bulk assign RFID', '2023-09-09 00:50:21.279283', NULL, 'AUTHENTICATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (63, 'TARIFF:ACTION_SETUP_MINIMUM_BALANCE', 'Set up minimum balance', '2023-09-09 00:52:08.961639', NULL, 'TARIFF', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (64, 'TARIFF:ACTION_ASSIGN_TARIFF', 'Assign Tariff', '2023-09-09 00:52:48.737238', NULL, 'TARIFF', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (65, 'REPORTS:ACTION_CHARGING_TRANSACTION', 'Charging Transaction Report', '2023-09-09 00:53:51.913434', NULL, 'REPORTS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (66, 'REPORTS:ACTION_TEAM_TRANSACTION', 'Team Transaction Report', '2023-09-09 00:54:20.543669', NULL, 'REPORTS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (67, 'REPORTS:ACTION_WALLET_TRANSACTION', 'Wallet Transaction Report', '2023-09-09 00:54:54.215617', NULL, 'REPORTS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (68, 'REPORTS:ACTION_BILLING', 'Billing Report', '2023-09-09 00:55:44.686738', NULL, 'REPORTS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (69, 'REPORTS:ACTION_INDIVIDUAL_USER', 'Individual User Registration Report', '2023-09-09 00:56:24.72643', NULL, 'REPORTS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (27, 'REPORTS:ACTION_CHARGE_POINT', 'ChargePoint Report', NULL, NULL, 'REPORTS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (10, 'CHARGE_STATION:CREATE', 'charge station', '2023-02-16 13:17:20.387', '2023-02-16 13:17:20.387', 'CHARGE_STATION', 'CREATE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (26, 'CHARGE_STATION:DELETE', 'charge station', '2023-09-06 12:28:54.719685', '2023-09-06 12:28:54.719685', 'CHARGE_STATION', 'DELETE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (52, 'TEAMS:VIEW', 'teams', '2023-06-07 01:45:07.537', '2023-06-07 01:45:07.537', 'TEAM_MANAGEMENT', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (49, 'TEAMS:DELETE', 'teams', '2023-06-07 01:45:07.537', '2023-06-07 01:45:07.537', 'TEAM_MANAGEMENT', 'DELETE');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (2, 'CUSTOMER_PROFILE:VIEW', 'customer profile', '2023-02-16 13:18:52.571', '2023-02-16 13:17:20.387', 'CUSTOMER_PROFILE', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (1, 'FINANCE_AND_REVENUE:VIEW', 'Finance and revenue', '2023-02-16 13:17:20.387', '2023-02-16 13:17:20.387', 'FINANCE_AND_REVENUE', 'VIEW');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (70, 'REPORTS:ACTION_GROUP_USER_REG', 'Group User Registration Report', '2023-09-09 00:57:04.49646', NULL, 'REPORTS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (72, 'REPORTS:ACTION_CUST_WALLET_BAL', 'Customer Wallet Balance Report', '2023-09-09 01:00:08.936243', NULL, 'REPORTS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (71, 'REPORTS:ACTION_NEW_CUSTOMER_REG', 'New Customer Registration Report', '2023-09-09 00:58:47.772109', NULL, 'REPORTS', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (73, 'CHARGE_STATION:ACTION_REMOTE_START', 'Remote start', '2023-09-09 00:58:47.772', NULL, 'CHARGE_STATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (74, 'CHARGE_STATION:ACTION_REMOTE_STOP', 'Remote stop', '2023-09-09 00:58:47.772', NULL, 'CHARGE_STATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (75, 'CHARGE_STATION:ACTION_HARD_RESET', 'Hard reset', '2023-09-09 00:58:47.772', NULL, 'CHARGE_STATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (76, 'CHARGE_STATION:ACTION_SOFT_RESET', 'Soft reset', '2023-09-09 00:58:47.772', NULL, 'CHARGE_STATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (77, 'CHARGE_STATION:ACTION_CHARGER_CONFIG', 'Charger configuration', '2023-09-09 00:58:47.772', NULL, 'CHARGE_STATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (78, 'CHARGE_STATION:ACTION_CLEAR_CACHE', 'Clear Cache', '2023-09-09 00:58:47.772', NULL, 'CHARGE_STATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (79, 'CHARGE_STATION:SET_CHARGER_AVAIL', 'Set charger availability', '2023-09-09 00:58:47.772', NULL, 'CHARGE_STATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (80, 'CHARGE_STATION:SET_CONNECTOR_AVAIL', 'Set connector availability', '2023-09-09 00:58:47.772', NULL, 'CHARGE_STATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (84, 'CHARGE_STATION:VIEW_OCPP_LOGS', 'OCPP logs', '2023-09-09 00:58:47.772', NULL, 'CHARGE_STATION', 'ACTION');
INSERT INTO public.saev_permission_master (id, name, displayname, createdat, updatedat, module, actiontype) VALUES (85, 'AUTHENTICATION:ACTION_BULK_IMPORT_RFID', 'Bulk import RFID', '2023-09-22 16:56:41.700943', NULL, 'AUTHENTICATION', 'ACTION');


--
-- TOC entry 5143 (class 0 OID 28339)
-- Dependencies: 319
-- Data for Name: saev_sequence_number; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.saev_sequence_number (id, tenantid, prefix, finyear, suffix, is_active, created_at, updated_at, created_by, updated_by, reference) OVERRIDING SYSTEM VALUE VALUES (3, '58e54a38-33aa-4fca-a4df-05bd15825d39', 'ZSC', 23, '00000028', true, '2023-08-25 16:33:52.7399', '2023-11-07 09:58:03.444438', 'SYSTEM', 'SYSTEM', 'REFUND');
INSERT INTO public.saev_sequence_number (id, tenantid, prefix, finyear, suffix, is_active, created_at, updated_at, created_by, updated_by, reference) OVERRIDING SYSTEM VALUE VALUES (2, '58e54a38-33aa-4fca-a4df-05bd15825d39', 'ZSC', 23, '00000479', true, '2023-08-25 16:33:29.329316', '2023-11-15 06:43:21.331602', 'SYSTEM', 'SYSTEM', 'TOP_UP');
INSERT INTO public.saev_sequence_number (id, tenantid, prefix, finyear, suffix, is_active, created_at, updated_at, created_by, updated_by, reference) OVERRIDING SYSTEM VALUE VALUES (1, '58e54a38-33aa-4fca-a4df-05bd15825d39', 'ZSC', 23, '00001131', true, '2023-08-25 16:32:49.408914', '2023-11-15 09:09:04.538568', 'SYSTEM', 'SYSTEM', 'SESSION_INVOICE');


--
-- TOC entry 5139 (class 0 OID 17674)
-- Dependencies: 268
-- Data for Name: saev_super_admin; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.saev_super_admin (id, last_downtime_sync, heart_beat_time_interval) OVERRIDING SYSTEM VALUE VALUES (1, '2023-11-15 09:00:14.291', 5);


--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 318
-- Name: saev_sequence_number_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.saev_sequence_number_id_seq', 3, true);


--
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 269
-- Name: saev_super_admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.saev_super_admin_id_seq', 1, true);


-- Completed on 2023-11-15 15:14:01 IST

--
-- PostgreSQL database dump complete
--

