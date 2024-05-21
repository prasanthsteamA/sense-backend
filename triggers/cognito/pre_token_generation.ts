import { join } from "path";

const { Client, Pool } = require("pg");
const DB_TABLES = {
  ROLES_TABLE: "saev_role",
  USER_ROLES_TABLE: "saev_user_role",
};

const getRoleInfo = async (user_type, user_id) => {
  try {
    if (user_type !== "USER") {
      return {};
    }
    const client = new Pool({
      host: process.env.HOST,
      port: process.env.DB_PORT,
      database: process.env.DATABASE,
      user: process.env.DB_USER,
      password: process.env.PASSWORD,
      idleTimeoutMillis: 30000,
      reapIntervalMillis: 1000,
      // ssl: {
      //   rejectUnauthorized: false,
      // },
    });
    // await client.connect();
    const roleData = await client.query(
      `SELECT * FROM ${DB_TABLES.ROLES_TABLE} as r join ${DB_TABLES.USER_ROLES_TABLE} as ur on r.id = ur.role_id WHERE ur.user_id = '${user_id}'`
    );

    if (!roleData.rows[0]) {
      return {};
    }
    let permission_list = [];
    for (let i = 0; i < roleData.rows[0].permissions.length; i++) {
      permission_list.push(roleData.rows[0].permissions[i]["name"]);
    }

    const {
      level_1,
      level_2,
      level_3,
      charge_station_id,
      charge_point_id,
      charge_connector_id,
      effective_role_level,
      effective_level_id,
      role_id
    } = roleData.rows[0] || {};
    return {
      permission_list: JSON.stringify(permission_list),
      level_1:JSON.stringify(level_1),
      level_2:JSON.stringify(level_2),
      level_3:JSON.stringify(level_3),
      charge_station_id:JSON.stringify(charge_station_id),
      charge_point_id:JSON.stringify(charge_point_id),
      charge_connector_id:JSON.stringify(charge_connector_id),
      effective_role_level,
      effective_level_id:JSON.stringify(effective_level_id),
      role_id
    };
  } catch (err) {
    console.log("Role generation issue",err)
    return {};
  }
};

module.exports.handler = async (event, context, callback) => {
  console.log("event", event);
  console.log("context", context);
  console.log("event.response > ", event.response.userAttributes);
  let tenantId = event.request.userAttributes["sub"];
  let user_id = event.userName;
  let user_type = event.request.userAttributes["custom:userType"];
  if (event.request.userAttributes.hasOwnProperty("custom:tenantId")) {
    tenantId = event.request.userAttributes["custom:tenantId"];
  }
  const role_info = await getRoleInfo(user_type, user_id);
  event.response = {
    claimsOverrideDetails: {
      claimsToAddOrOverride: {
        tenantId: "" + tenantId,
        ...role_info,
      },
    },
  };
  console.log("event.response > ", event.response);
  // Return to Amazon Cognito
  //return event;
  return event;
};
