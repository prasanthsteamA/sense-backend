import { logger } from "../lib/logger";
import { addData, getSingle } from "../lib/postgresDB";
import settings from "../settings";

interface updatedUserParams {
  id?: string;
  roles?: any;
  tenantId?: string;
}

export const updateRoles = async (
  { id, roles, tenantId }: updatedUserParams,
  pgClientInstance: any
) => {
  const childLogger = logger.child({
    route: "users/helper",
  });
  const deleteRoleQuery = `DELETE FROM ${settings.USER_ROLES} 
    WHERE user_id IN ($1)`;

  await pgClientInstance.query(deleteRoleQuery, [id]);

  const queryToAddRole = `user_id, role_id, tenant_id, created_by, created_at`;

  let addRoles = roles.map((role) => {
    return addData(
      settings.USER_ROLES,
      queryToAddRole,
      [id, role.id, tenantId, tenantId, new Date()],
      pgClientInstance
    )
      .then((item) => {
        childLogger.info(`${item}`);
      })
      .catch((err) => {
        childLogger.error(`${err}, ${err.stack}`);
      });
  });

  await Promise.all(addRoles).then(() => {
    childLogger.info(`All promise resolved`);
  });

  return addRoles;
};

interface authorityCheckParams {
  id?: string;
  userId?: string;
  tenantId?: string;
  userType?: string;
}

export const updateUserAuthorityCheck = async ({
  id, // id is from params
  userId, // this can be tenantId or userId taken from claims
  tenantId, // this is taken from claims
  userType, // this is also taken from claims
}: authorityCheckParams) => {
  const userData = await getSingle(settings.USERS_TABLE, id);
  const childLogger = logger.child({
    USER_ACTIVITY: userId,
    route: "users/helper",
  });
  if (!userData) {
    childLogger.error(`User not found with the id ${id}`);
    return {
      success: false,
      message: `User not found with the id ${id}`,
    };
  }

  if (userType === "TENANT") {
    if (userId === userData.tenantid) {
      return {
        success: true,
        message: "Can be updated",
      };
    }
  }
  if (id && userType === 'USER' && userData.username === id) {
    return {
      success: true,
      message: "Can be updated",
    };
  }

  if(id && userType === "CUSTOMER" && userData.username === id){
    return {
      success: true,
      message: "Can be updated",
    };
  }
  childLogger.error(`User cannot be updated`);
  return {
    success: false,
    message: "User cannot be updated",
  };
};
