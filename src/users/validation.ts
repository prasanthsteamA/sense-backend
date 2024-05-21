import { logger } from "../lib/logger";
import parse from "../lib/parse";

export const getValidDocument = (data: any) => {
  const childLogger = logger.child({
    route: "users/validations",
  });
  if (Object.keys(data).length === 0) {
    childLogger.error(`Required fields are missing`);
    throw new Error("Required fields are missing");
  }

  let items: any = {};

  if (data.name !== undefined) {
    items.name = parse.getString(data.name);
  } else {
    childLogger.error(`name is required, ${data}`);
    throw new Error("name is required.");
  }

  if (data.email !== undefined) {
    items.email = parse.getString(data.email);
  } else {
    childLogger.error(`email is required, ${data}`);
    throw new Error("email is required.");
  }

  if (data.usertype !== undefined) {
    items.userType = parse.getString(data.usertype).toUpperCase();
  } else {
    childLogger.error(`usertype is required, ${data}`);
    throw new Error("usertype is required.");
  }
  let parsedUserType = parse.getString(data.usertype).toUpperCase();
  if (
    parsedUserType === "TENANT" ||
    parsedUserType === "USER" ||
    parsedUserType === "CUSTOMER"
  ) {
    items.userType = parsedUserType;
  } else {
    childLogger.error(`enter the valid userType, ${data}`);
    throw new Error("enter the valid userType.");
  }
  if (
    data.phone !== undefined &&
    data.phone.startsWith("+91") &&
    data.phone.length == 13
  ) {
    items.phone = parse.getString(data.phone);
  } else {
    childLogger.error(
      `phone is required and it should be start with your country code. example: +91<10-digsit-phone-no>, ${data}`
    );
    throw new Error(
      "phone is required and it should be start with your country code. example: +91<10-digsit-phone-no>"
    );
  }

  if (items.userType === "USER") {
    if (
      data.roles !== undefined &&
      typeof data.roles === "object" &&
      data.roles.length === 1 &&
      validateRoleForUser(data.roles[0])
    ) {
      items.roles = data.roles;
    } else {
      childLogger.error(
        `role is required and one role should be assigned to one user, ${data}`
      );
      throw new Error(
        "role is required and one role should be assigned to one user"
      );
    }
  }

  return items;
};

const validateRoleForUser = (obj) => {
  if (Object.keys(obj).length === 0) return false;
  if (obj["id"] && obj["id"] != "") return true;
};

export const getValidUpdateDocument = (data: any, claims) => {
  const childLogger = logger.child({
    route: "users/validations",
  });
  if (Object.keys(data).length === 0) {
    childLogger.error(`No data is provided to update, ${data}`);
    throw new Error("No data is provided to update");
  }

  let items: any = {};

  if (data.user_id !== undefined) {
    childLogger.error(`Nuser_id cannot be updated, ${data}`);
    throw new Error("user_id cannot be updated.");
  } else if (data.tenantid !== undefined) {
    childLogger.error(`tenant_id cannot be updated, ${data}`);
    throw new Error("tenant_id cannot be updated.");
  } else if (data.username !== undefined) {
    childLogger.error(`Username cannot be updated, ${data}`);
    throw new Error("Username cannot be updated.");
  } else if (data.isActive !== undefined) {
    childLogger.error(`IsActive cannot be updated, ${data}`);
    throw new Error("IsActive cannot be updated.");
  } else if (data.walletbalance !== undefined) {
    childLogger.error(`walletBalance cannot be updated, ${data}`);
    throw new Error("walletBalance cannot be updated.");
  }

  if (data.name !== undefined) {
    items.name = parse.getString(data.name);
  }
  if (data.email !== undefined) {
    items.email = parse.getString(data.email);
  }
  if (data.logo !== undefined) {
    items.logo = parse.getString(data.logo);
  }
  if (data.cover !== undefined) {
    items.cover = parse.getString(data.cover);
  }

  if (claims["custom:userType"] !== "CUSTOMER") {
    if (
      data.roles !== undefined &&
      typeof data.roles === "object" &&
      data.roles.length === 1 &&
      validateRoleForUser(data.roles[0])
    ) {
      items.roles = data.roles;
    } else {
      childLogger.error(
        `role is required and one role should be assigned to one user, ${data}`
      );
      throw new Error(
        "role is required and one role should be assigned to one user"
      );
    }
  }

  return items;
};
