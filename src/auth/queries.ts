import settings from "../settings";

export const getDeviceTokenForSigleCustomer = () => {
  let query = `SELECT device_token FROM ${settings.USER_DEVICES} where tenant_id= $1 and user_id= $2 `;
  return query;
};

export const checkUserExist = () => {
  let query = `SELECT * FROM ${settings.USER_DEVICES} where tenant_id= $1 and user_id= $2 `;
  return query;
};
