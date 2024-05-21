import settings from "../settings";

export const getUserRoleQuery = `
SELECT sur.role_id, sr.name, sr.effective_level_id, sr.effective_role_level from ${settings.USER_ROLES} as sur 
left JOIN ${settings.ROLES_TABLE} as sr
ON sur.role_id = sr.id
WHERE user_id = $1
LIMIT 1 `;

export const getSingleUserRoleQuery = `
SELECT sur.role_id, sr.name, sr.effective_level_id, sr.effective_role_level from ${settings.USER_ROLES} as sur 
left JOIN ${settings.ROLES_TABLE} as sr
ON sur.role_id = sr.id
WHERE user_id = $1
`;

export const getUserLevelListQuery = (params) => {
  const { level, levelId, userId, queryData } = params;
  const { page, pagesize, search, sortby, orderby } = queryData;

  let sortConditions = {
    name: `ORDER BY name ${orderby ? orderby : "ASC"}`,
  };

  let condition = ``;
  let searchCondition = ``;
  let sortCondition = ``;

  if (search) {
    searchCondition = `AND usr.name ILIKE '%${search}%' OR  sr.name ILIKE '%${search}%'`;
  }

  if (sortby) {
    sortCondition = sortConditions[sortby];
  }

  let paginationCondition = `OFFSET(((${parseInt(
    page ? page : 1
  )})-1)*${parseInt(pagesize ? pagesize : 10)}) ROWS FETCH NEXT ${parseInt(
    pagesize ? pagesize : 10
  )} ROWS ONLY`;

  if (Boolean(level) && Boolean(levelId)) {
    condition = `AND sr.${level} IN (${levelId.join(
      ", "
    )}) AND usr.id != '${userId}'`;
  }

  let query = `SELECT
    COUNT(*) OVER() AS data_count,
     usr.*
    FROM ${settings.USERS_TABLE} as usr
    LEFT JOIN  ${settings.USER_ROLES} AS sur ON sur.user_id = usr.id
    LEFT JOIN  ${settings.ROLES_TABLE} as sr ON sr.id = sur.role_id 
    where usr.tenantid = $1 
    AND usr.is_deleted = false
    AND usr.usertype = 'USER' ${condition}
    ${searchCondition}
    GROUP BY
    usr.id,sur.user_id
    ${sortCondition}
    ${paginationCondition}

    `;

  return query;
};

export const searchUserQuery = `
    select usr.id, usr.phone, usr.name, usr.email, usr.wallet_balance, rf.rfidnumber
    FROM ${settings.USERS_TABLE} as usr
     LEFT JOIN ${settings.RFID_TABLE} as rf ON rf.user_id = usr.id
     WHERE usertype = 'CUSTOMER' AND usr.tenantid = $1 AND usr.is_deleted <> TRUE AND usr.isactive = TRUE
     AND (usr.name ILIKE $2 OR usr.phone ILIKE $2 OR usr.id ILIKE $2 OR usr.email ILIKE $2) 
     AND rf.id_type = 'remote_id';
  `;

export const selectUserQuery = `select
	usr.id,
	usr.phone,
	usr.name,
	usr.email,
	usr.wallet_balance,
	rf.rfidnumber
from
	saev_user as usr
left join saev_rfid as rf on
	rf.user_id = usr.id
where
	usertype = 'CUSTOMER'
	and usr.tenantid = $1
	and usr.id = $2
	and usr.is_deleted = false
	and usr.isactive = true
	and rf.id_type = 'remote_id'`;

export const getVehicleDetailsQuery = `
select sv.*, smv.is_autocharge_enabled, vid.vid_tag from ${settings.VEHICLES_TABLE} sv 
left join ${settings.MD_VEHICLE_TABLE} smv on smv.model = sv.model 
left join ${settings.VID_TABLE} vid on vid.vrn = sv.number
where sv.userid = $1
`;

export const getTeamDetailsQuery = `
select
th.team_name,
td.team_hdr_id,td.is_lead,th.payment_type
from ${settings.TEAM_DETAILS} as td
INNER join ${settings.TEAM_HEADER} as th on th.id=td.team_hdr_id
where customer_id = $1
`;

export const getTeamAdminDetailsQuery = `
select
td.team_hdr_id,
td.is_lead,
td.customer_id as id,
usr.wallet_balance ,usr."name" ,usr.email ,usr.phone 
from ${settings.TEAM_DETAILS} as td
inner join ${settings.USERS_TABLE} as usr on usr.id =td.customer_id 
where is_lead =true and td.team_hdr_id=$1
`;

export const getuserActiveSessionCount = () => {
  let query = `SELECT
  COUNT(*)::INTEGER AS record_count
FROM
  ${settings.CHARGING_SESSIONS_TABLE} scs
WHERE
  scs.user_id = $1 AND scs.tenantid=$2
  AND scs.status = 'STARTED'`;
  return query;
};
