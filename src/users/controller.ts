import { getAllData, getSingle, addData, updateData } from "../lib/postgresDB";
import {
  get_presigned_url_for_uploading,
  send_notification_using_sns,
  sms_sender,
} from "../lib/common_modules";
import { getValidDocument, getValidUpdateDocument } from "./validation";
import { pool } from "../lib/connection_db";

import { randomUUID } from "crypto";
import { Request, Response, NextFunction } from "express";
import settings from "../settings";
import * as AWS from "aws-sdk";
import {
  getSingleUserRoleQuery,
  getUserLevelListQuery,
  getUserRoleQuery,
  searchUserQuery,
  getVehicleDetailsQuery,
  getTeamDetailsQuery,
  getTeamAdminDetailsQuery,
  getuserActiveSessionCount,
  selectUserQuery,
} from "./queries";
import { updateRoles, updateUserAuthorityCheck } from "./helper";
import { levelHeaderNameQuery } from "../lib/levelHeader.utils";
import { getClaims } from "../lib/common_modules";
import { logger } from "../lib/logger";
import { isEmailVerified, getUser_tenant_details } from "../lib/utils";
import {
  User_Activate_SMS_template,
  Customer_Activate_SMS_template,
  User_Deactivate_SMS_template,
  Customer_Deactivate_SMS_template,
} from "../lib/templates/sms_templates";
import {
  User_Activate_Email_template,
  Customer_Activate_Email_template,
  User_Deactivate_Email_template,
  Customer_Deactivate_Email_template,
} from "../lib/templates/auto_generated_email";
import { MESSAGES } from "../lib/messages";
import constants from "../lib/constants";
const USERS_TABLE = settings.USERS_TABLE;
const RFID_TABLE = settings.RFID_TABLE;
const USER_ROLES = settings.USER_ROLES;

export const update_cognito = async (data: any) => {
  const childLogger = logger.child({
    USER_ACTIVITY: "ADMIN",
    route: "users/controller",
  });
  const UserAttributes = [];
  if (data.name) {
    UserAttributes.push({
      Name: "name",
      Value: data.name,
    });
  }
  if (data.email) {
    UserAttributes.push({
      Name: "email",
      Value: data.email,
    });
  }
  if (data.phone) {
    UserAttributes.push({
      Name: "phone_number",
      Value: data.phone,
    });
  }
  var params = {
    UserAttributes: UserAttributes,
    UserPoolId: process.env.USER_POOL_ID,
    Username: data.username,
  };
  const cognito = new AWS.CognitoIdentityServiceProvider();
  try {
    const update_response = await cognito
      .adminUpdateUserAttributes(params)
      .promise();
  } catch (error) {
    childLogger.error(`${error.message}, ${error.stack}`);
  }
};

export const createMediaPath = async (req: Request) => {
  const { userId: user_id, data: event_body } = await getClaims(req);
  const childLogger = logger.child({
    USER_ACTIVITY: user_id,
    route: req.route.path,
  });

  if (Object.keys(event_body).length === 0) {
    childLogger.error(`Required fields are missing, ${req}`);
    throw { error: true, message: "Required fields are missing.", code: 400 };
  }
  const ext = [".jpg", ".jpeg", ".png", ".ico"];
  if (
    !event_body.filename ||
    ![".jpg", ".jpeg", ".png", ".ico"].some(
      (el) => event_body.filename || "".toLowerCase().endsWith(el)
    )
  ) {
    childLogger.error(
      `filename is rerquired and supported media type should be one of this ${ext}, ${req}`
    );
    return {
      error: true,
      message: `filename is rerquired and supported media type should be one of this ${ext}`,
      code: 400,
    };
  }
  if (
    !event_body.imageType ||
    !["cover", "logo"].includes(event_body.imageType || "".toLowerCase())
  ) {
    childLogger.error(`imageType is rerquired, ${req}`);
    return { error: true, message: "imageType is rerquired.", code: 400 };
  }

  const path = `user_images/${process.env.STAGE}/${event_body.imageType}/${user_id}/${event_body.filename}`;
  const presigned_url = await get_presigned_url_for_uploading(AWS, path);
  const s3_path = `https://steam-a-evbackend-public-${settings.STAGE}.s3.ap-south-1.amazonaws.com/${path}`;
  return { url: presigned_url, path: s3_path, code: 200 };
};

export const getAllLists = async (req: Request, params: Object = {}) => {
  const { claims, queryData, userId } = await getClaims(req);
  const childLogger = logger.child({
    USER_ACTIVITY: userId,
    route: req.route.path,
  });
  try {
    let tenantId = claims.tenantId;
    const rolesQuery = getUserRoleQuery;
    let usersResponse = [];
    let responseObject = {};

    params = {
      level: claims["effective_role_level"],
      levelId: claims["effective_role_id"],
      userId: claims["cognito:username"],
      queryData,
    };
    const query = getUserLevelListQuery(params);

    const tenantUsers = await pool.query(query, [tenantId]);
    let getRoles = tenantUsers.rows.map(async (user) => {
      const roles = await pool
        .query(rolesQuery, [user.username])
        .then((item) => item);
      if (roles.rowCount < 1) {
        responseObject = {
          name: user.name,
          email: user.email,
          phone: user.phone,
          user_id: user.username,
          user_role: null,
          assigned_levels: null,
        };
      } else {
        let role = roles.rows[0];
        if (
          role.effective_role_level &&
          role.effective_level_id &&
          levelHeaderNameQuery[role.effective_role_level]
        ) {
          const fetchQuery = levelHeaderNameQuery[role.effective_role_level](
            role.effective_level_id
          );
          const resp = await pool.query(fetchQuery);

          const levelHeaderInfo = resp.rows[0];
          responseObject = {
            name: user.name,
            email: user.email,
            phone: user.phone,
            user_id: user.username,
            user_role: roles.rows[0].name,
            assigned_levels:
              `${levelHeaderInfo.header_name}-`.trim() +
              resp.rows
                .map((row) => `${row.name}`)
                .join(", ")
                .trim(),
          };
        }
      }
      usersResponse.push(responseObject);
    });

    await Promise.all(getRoles).then(() => {
      childLogger.info(`promise has been resolved...`);
    });

    return {
      error: false,
      data: usersResponse,
      data_count: tenantUsers.rows[0]?.data_count || 0,
    };
  } catch (err) {
    childLogger.error(`internal error is ${err}, ${err.stack}`);
    return {
      error: true,
      message: `internal error is ${err}`,
      code: 500,
    };
  }
};

export const getSingleList = async (id: string) => {
  const childLogger = logger.child({
    route: "users/controller",
  });
  try {
    const getUser = await getSingle(USERS_TABLE, id);
    getUser.roles = [];
    if (getUser.usertype === "USER") {
      const rolesQuery = getSingleUserRoleQuery;
      const getRole = await pool
        .query(rolesQuery, [id])
        .then((item) => item.rows);
      getUser.roles = getRole;
    }

    return getUser;
  } catch (err) {
    childLogger.error(`${err}, ${err.stack}`);
    return {
      error: true,
      message: err,
    };
  }
};

export const addList = async (req: Request) => {
  const { claims, data, tenantId: userId } = await getClaims(req);
  const childLogger = logger.child({
    USER_ACTIVITY: userId,
    route: req.route.path,
  });
  const pg_client = await pool.connect();

  try {
    const groups = claims["cognito:groups"] ? claims["cognito:groups"] : [];

    let validatedData = await getValidDocument(data);
    let tenantId = randomUUID();
    let username: any = tenantId;
    let userType = validatedData.userType;
    let isTenant = false;
    let createdBy = claims.tenantId;
    let checkUser: any;

    if (userType == "TENANT") {
      isTenant = true;
    } else if (userType == "USER") {
      username = `${createdBy}${validatedData.phone}+${userType}`;
      tenantId = createdBy;
    }

    if (isTenant && !groups.includes("SuperAdmins")) {
      childLogger.error(`You do not have permission to add a tenant`);
      return {
        error: true,
        message: "You don't have permission to add a tenant.",
        code: 400,
      };
    } else if (!isTenant && groups.includes("SuperAdmins")) {
      childLogger.error(
        `You don't have permission to add an user or a customer, Only tenant can add an user or a costumer, ${req}`
      );
      return {
        error: true,
        message:
          "You don't have permission to add an user or a customer, Only tenant can add an user or a costumer",
        code: 400,
      };
    }
    // Check If User Exists with same phone number or email for a tenant
    if (isTenant === false) {
      checkUser = await pool
        .query(
          `select * from ${USERS_TABLE} WHERE tenantid = '${createdBy}' and userType = 'USER' and (email = '${validatedData.email}' OR phone = '${validatedData.phone}' OR id = '${username}')`
        )
        .then((items: any) => {
          return { dataCount: items.rowCount, data: items.rows };
        });

      if (checkUser.dataCount > 0) {
        if (checkUser.data[0]["isactive"] === true) {
          return {
            error: true,
            message: "A user already exists",
            code: 400,
          };
        } else {
          childLogger.error(
            `A deactivated user already exists, update it if you want to reactivate, ${req}`
          );
          return {
            error: true,
            message:
              "A deactivated user already exists, update it if you want to reactivate",
            code: 400,
          };
        }
      }
    }
    await pg_client.query(constants.TRANSACTIONS.BEGIN); // Transaction initiated

    let lastAtIndex = validatedData.email.lastIndexOf('@');
    let modifiedEmail;
    if (lastAtIndex !== -1) {
        // Split the email into local part and domain part
        let localPart = validatedData.email.substring(0, lastAtIndex);
        let domainPart = validatedData.email.substring(lastAtIndex);

        // Add '+customer' to the local part
        modifiedEmail = `${localPart}+${userType.toLowerCase()}${domainPart}`;
    } else {
        modifiedEmail = validatedData.email
        console.log("Invalid email format");
    }
    
    const cognitoPayload = {
      UserPoolId: process.env.USER_POOL_ID,
      Username: username,
      DesiredDeliveryMediums: ["EMAIL"],
      UserAttributes: [
        {
          Name: "name",
          Value: validatedData.name,
        },
        {
          Name: "email",
          Value: modifiedEmail,
        },
        {
          Name: "phone_number",
          Value: validatedData.phone,
        },
        {
          Name: "email_verified",
          Value: "true",
        },
        {
          Name: "phone_number_verified",
          Value: "true",
        },
        {
          Name: "custom:tenantId",
          Value: tenantId,
        },
        {
          Name: "custom:userType",
          Value: userType,
        },
      ],
    };
    // const cognitoPayload = {
    //   UserPoolId: process.env.USER_POOL_ID,
    //   Username: username,
    //   DesiredDeliveryMediums: ["EMAIL"],
    //   UserAttributes: [
    //     {
    //       Name: "name",
    //       Value: validatedData.name,
    //     },
    //     {
    //       Name: "email",
    //       Value: validatedData.email,
    //     },
    //     {
    //       Name: "phone_number",
    //       Value: validatedData.phone,
    //     },
    //     {
    //       Name: "email_verified",
    //       Value: "true",
    //     },
    //     {
    //       Name: "phone_number_verified",
    //       Value: "true",
    //     },
    //     {
    //       Name: "custom:tenantId",
    //       Value: tenantId,
    //     },
    //     {
    //       Name: "custom:userType",
    //       Value: userType,
    //     },
    //   ],
    // };
    const cognito = new AWS.CognitoIdentityServiceProvider();
    await cognito.adminCreateUser(cognitoPayload).promise();

    let params = [
      username,
      validatedData.name,
      validatedData.email,
      validatedData.phone,
      tenantId,
      userType,
      username,
      `now()`,
      createdBy,
    ];
    const query = `id, name, email, phone, tenantid, usertype, username, createdat, createdby`;
    let addUserDataToDb = await addData(USERS_TABLE, query, params, pg_client);

    const queryToAddRole = `user_id, role_id, tenant_id, created_by, created_at`;
    if (userType === "USER") {
      let addRoles = validatedData.roles.map((role) => {
        return addData(
          USER_ROLES,
          queryToAddRole,
          [username, role.id, tenantId, tenantId, new Date()],
          pg_client
        )
          .then(async (item) => {
            childLogger.info(`${item}`);
          })
          .catch((err) => {
            Promise.reject();
            childLogger.error(
              `Error found while adding roles to the user ${err.stack}`
            );
          });
      });

      await Promise.all(addRoles).then(() => {
        childLogger.info(`Promise has been resolved`);
      });
    }
    if (userType == "TENANT") {
      const query_params = `tenantid, createdat, createdby `;
      const query_params_data = [tenantId, `now()`, tenantId];
      await addData(
        settings.SETTINGS_TABLE,
        query_params,
        query_params_data,
        pg_client
      );
    }
    childLogger.info(`User created successfully`);
    await pg_client.query(constants.TRANSACTIONS.COMMIT);
    return addUserDataToDb;
  } catch (err) {
    await pg_client.query(constants.TRANSACTIONS.ROLLBACK);
    return {
      message: `internal error is ${err}`,
      error: true,
      code: 500,
    };
  } finally {
    childLogger.info(constants.POOL_RELEASED);
    await pg_client.release();
  }
};

export const updateList = async (req: Request, res: Response, id: any) => {
  const { claims, data, userId } = await getClaims(req);
  const childLogger = logger.child({
    USER_ACTIVITY: userId,
    route: req.route.path,
  });
  const pg_client = await pool.connect();

  try {
    let userId = claims["cognito:username"];
    let userType = claims["custom:userType"];
    let tenantId = claims.tenantId;
    let phone_number = claims.phone_number;
    const { success: updateAvailable, message: checkMessage } =
      await updateUserAuthorityCheck({ id, userId, tenantId, userType });
    if (!updateAvailable) {
      childLogger.error(checkMessage);
      return {
        error: true,
        message: checkMessage,
      };
    }

    let updatedby = userId;

    let validatedData = await getValidUpdateDocument(data, claims);
    let params: any = {};

    // ignoring phone in payload
    params = {
      name: validatedData.name,
      email: validatedData.email,
    };
    Object.keys(params).forEach(
      (key) => !Boolean(params[key]) && delete params[key]
    );
    await pg_client.query(constants.TRANSACTIONS.BEGIN); // Transaction initiated
    if (params.email) {
      let checkUserWithEmail;
      if (userType === "CUSTOMER") {
        checkUserWithEmail = await getAllData(USERS_TABLE, {
          email: params.email,
          tenantId: tenantId,
          userType: userType,
        });
      } else {
        let resp = await pool.query(
          `SELECT * FROM saev_user
           WHERE email = $1
             AND tenantid = $2
             AND usertype IN ('USER', 'TENANT');`,
          [params.email, tenantId]
        );

        checkUserWithEmail = {
          dataCount: resp.rowCount,
          data: resp.rows,
        };
      }
      if (checkUserWithEmail?.dataCount > 1) {
        childLogger.error(
          `Email address is already in use, please choose a different email address to update`
        );
        // Already existing email should be one and That one also requested Email Allow them to edit appropriate else throw error
        return {
          error: true,
          message:
            "Email address is already in use, please choose a different email address to update",
          code: 405,
        };
      }

      if (checkUserWithEmail?.dataCount == 1) {
        if (!(checkUserWithEmail?.data[0].id === id)) {
          childLogger.error(
            `Email address is already in use, please choose a different email address to update`
          );
          return {
            error: true,
            message:
              "Email address is already in use, please choose a different email address to update",
            code: 405,
          };
        }
      }
      const cognito = new AWS.CognitoIdentityServiceProvider();
      const cognitoParams = {
        UserPoolId: process.env.USER_POOL_ID,
        Username: id,
        UserAttributes: [
          {
            Name: "email",
            Value: params.email,
          },
        ],
      };

      if (userType === "CUSTOMER") {
        cognitoParams.UserAttributes.push({
          Name: "email_verified",
          Value: "false",
        },{
          Name: "name",
          Value: params.name
        });
        params["is_email_verified"] = false; // If the customer updates their email that should be in unverified state by default
      }
      cognito.adminUpdateUserAttributes(cognitoParams, function (err, data) {
        if (err) {
          childLogger.error(`${err}, ${err.stack}`);
        } else {
          childLogger.error(`inside cognito function, ${data}`);
        }
      });
    }
    params.updatedat = `now()`;
    params.updatedby = updatedby;
    const updateUser = await updateData(USERS_TABLE, params, id, pg_client);

    if (claims["userType"] !== "CUSTOMER") {
      if (validatedData.roles) {
        params = {
          id,
          roles: validatedData["roles"],
          tenantId,
        };
        await updateRoles(params, pg_client);
      }
    }

    childLogger.info(`user is updated successfully`);
    await pg_client.query(constants.TRANSACTIONS.COMMIT);

    return updateUser;
  } catch (error) {
    childLogger.error(`Error found while updating user ${error.stack}`);
    await pg_client.query(constants.TRANSACTIONS.ROLLBACK);
    return {
      error: true,
      message: `Internal error while updating user`,
      code: 500,
    };
  } finally {
    childLogger.info(constants.POOL_RELEASED);
    await pg_client.release();
  }
};

export const getProfile = async (req: Request) => {
  const { userId: id, tenantId } = await getClaims(req);
  const childLogger = logger.child({
    USER_ACTIVITY: id,
    route: req.route.path,
  });
  try {
    let data = {} as any;
    const record = await getSingle(USERS_TABLE, id).then((items: any) => items);
    const rfidData = await pool
      .query(`SELECT rfidnumber FROM ${RFID_TABLE} WHERE user_id = '${id}'`)
      .then((items: any) => items);
    data = { ...record };
    data["rfidnumber"] = rfidData?.rows[0]?.rfidnumber;
    const cognito = new AWS.CognitoIdentityServiceProvider();
    var params = {
      UserPoolId: process.env.USER_POOL_ID,
      Username: id,
    };
    // Provide the user pool data to check Email, Mobile are verified or not
    const user = await cognito.adminGetUser(params).promise();
    const result = user.UserAttributes.find(
      (ele) => ele.Name == "email_verified"
    );
    result === undefined
      ? user.UserAttributes.push({
          Name: "email_verified",
          Value: null, // If no Email is not yet configured , Should pass as null based on this flag only they will update verified or unverified or
        })
      : "";
    data.pooldata = user ? user : {};
    const vehicle_details = await pool
      .query(getVehicleDetailsQuery, [id])
      .then((res: any) => {
        return res && res.rows ? res.rows : [];
      });
    data.vehicle_details = vehicle_details ? vehicle_details : [];

    const team_details = await pool
      .query(getTeamDetailsQuery, [id])
      .then((res: any) => {
        return res && res.rows ? res.rows : [];
      });

    data.team_details = team_details ? team_details : [];
    const team_hdr_id =
      data?.team_details?.length > 0 ? data.team_details[0].team_hdr_id : 0; //If the customer is an individual then team_hdr_id will be 0
    data.team_admin_result = [];
    const team_admin_result = await pool
      .query(getTeamAdminDetailsQuery, [team_hdr_id])
      .then((res: any) => {
        return res && res.rows ? res.rows : [];
      });
    data.team_admin_result = team_admin_result ? team_admin_result : [];

    // Get the user_active_sessions data from sesstion table
    const user_active_sessionsQuery = await getuserActiveSessionCount();
    const sessionResponse = await pool.query(user_active_sessionsQuery, [
      id,
      tenantId,
    ]);
    data.active_sessions = sessionResponse?.rows[0]?.record_count
      ? sessionResponse?.rows[0]?.record_count
      : 0;
    return data;
  } catch (err) {
    childLogger.error(`${err}, ${err.stack}`);
    return {
      error: true,
      code: 500,
      message: `${err.message}`,
    };
  }
};

export const searchUserData = async (req: Request) => {
  const { tenantId } = await getClaims(req);
  let getDataCall = await pool
    .query(searchUserQuery, [tenantId, `%${req.query.search}%`])
    .then((items: any) => {
      return { dataCount: items.rowCount, data: items.rows };
    });
  const id = getDataCall?.data[0]?.id;

  const team_details = await pool
    .query(getTeamDetailsQuery, [id])
    .then((res: any) => {
      return res && res.rows ? res.rows : [];
    });
  getDataCall.team_details = team_details ? team_details : [];
  const team_hdr_id =
    team_details?.length > 0 ? team_details[0]?.team_hdr_id : 0; //If the customer is an individual then team_hdr_id will be 0
  const team_admin_result = await pool
    .query(getTeamAdminDetailsQuery, [team_hdr_id])
    .then((res: any) => {
      return res && res.rows ? res.rows : [];
    });
  getDataCall.team_admin_result = team_admin_result ? team_admin_result : [];
  return getDataCall;
};

export const selectUserData = async (req: Request) => {
  const id = req.params.id;
  const { tenantId } = await getClaims(req);
  let getDataCall = await pool
    .query(selectUserQuery, [tenantId, id])
    .then((items: any) => {
      return { dataCount: items.rowCount, data: items.rows };
    });
  const team_details = await pool
    .query(getTeamDetailsQuery, [id])
    .then((res: any) => {
      return res && res.rows ? res.rows : [];
    });
  getDataCall.team_details = team_details ? team_details : [];
  const team_hdr_id =
    team_details?.length > 0 ? team_details[0]?.team_hdr_id : 0; //If the customer is an individual then team_hdr_id will be 0
  const team_admin_result = await pool
    .query(getTeamAdminDetailsQuery, [team_hdr_id])
    .then((res: any) => {
      return res && res.rows ? res.rows : [];
    });
  getDataCall.team_admin_result = team_admin_result ? team_admin_result : [];
  return getDataCall;
};

export const deactivateUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const { tenantId, userId } = await getClaims(req);
  const childLogger = logger.child({
    USER_ACTIVITY: userId,
    route: req.route.path,
  });
  const username = req.params.id;
  var params = {
    UserPoolId: process.env.USER_POOL_ID,
    Username: username,
  };
  const pg_client = await pool.connect();
  const cognito = new AWS.CognitoIdentityServiceProvider();
  try {
    await pg_client.query(constants.TRANSACTIONS.BEGIN); // Transaction initiated
    // disable an user first
    const disable_user_resp = cognito.adminDisableUser(params).promise();
    disable_user_resp
      .then(async () => {
        // global signout to invalidate all refresh token except access token and id token
        await cognito.adminUserGlobalSignOut(params).promise();
        // mark as inactive in user table using username
        var user_params = {
          isactive: false,
          updatedat: `now()`,
          updatedby: tenantId,
        };
        await updateData(USERS_TABLE, user_params, username, pg_client);
        childLogger.info(`Requested user has been deactivated`);
        const user_type_query = `select id,email,phone,name,is_email_verified,usertype from saev_user where id='${username}'`;
        const user_type_query_result = await pg_client.query(user_type_query);
        const user_type = user_type_query_result.rows[0]?.usertype;
        if (username != null) {
          const customerTenantData = await getUser_tenant_details(username);
          const { isEmailisVerified, email } = await isEmailVerified(username);
          // Customer Email  is verfied then only allow to send mail else not required
          if (isEmailisVerified === true) {
            const user_activateRequest = {
              customerName: customerTenantData?.data?.customer_name,
            };
            let emailTemplate;
            let emailSubject;
            if (user_type === "USER") {
              emailTemplate = User_Deactivate_Email_template(
                user_activateRequest,
                customerTenantData?.data.company_logo,
                customerTenantData?.data.primary_color
              );
              emailSubject = MESSAGES.EMAIL_SUBJECTS.USER_DEACTIVATION;
            } else if (user_type === "CUSTOMER") {
              emailTemplate = Customer_Deactivate_Email_template(
                user_activateRequest,
                customerTenantData?.data.company_logo,
                customerTenantData?.data.primary_color
              );
              emailSubject = MESSAGES.EMAIL_SUBJECTS.CUSTOMER_DEACTIVATION;
            }
            const { success, message } = await send_notification_using_sns(
              AWS,
              "Email",
              [email], // To Email Address
              emailTemplate,
              emailSubject
            );
            if (!success) {
              childLogger.error(
                "Email Trigger failed due to this reason ..." + message
              );
            }
          }
          const user_activate_SMS_request = {
            customerName: customerTenantData?.data?.customer_name,
          };
          let smsTemplate;
          if (user_type === "USER") {
            smsTemplate = User_Deactivate_SMS_template(
              user_activate_SMS_request
            );
          } else if (user_type === "CUSTOMER") {
            smsTemplate = Customer_Deactivate_SMS_template(
              user_activate_SMS_request
            );
          }

          const messageBodyforMobile = smsTemplate;
          const phone = customerTenantData?.data.phone;
          // Dont wait for sms sending result. It should be non blocking
          sms_sender(messageBodyforMobile, phone);
        }
        await pg_client.query(constants.TRANSACTIONS.COMMIT);
        return res
          .status(200)
          .send({ message: "Requested user has been deactivated" });
      })
      .catch(async (err) => {
        childLogger.error(`${err}, ${err.stack}`);
        childLogger.error(
          `Error found while deactivating the requested user ${err.stack}`
        );
        await pg_client.query(constants.TRANSACTIONS.ROLLBACK);
        return res
          .status(400)
          .send({ error: true, message: err.message, code: 400 });
      });
  } catch (error) {
    childLogger.error(`Error found while updating user ${error.stack}`);
    await pg_client.query(constants.TRANSACTIONS.ROLLBACK);
    return {
      error: true,
      message: `Internal error while updating user`,
      code: 500,
    };
  } finally {
    childLogger.info(constants.POOL_RELEASED);
    await pg_client.release();
  }
};

export const activateUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const { tenantId, userId } = await getClaims(req);
  const pg_client = await pool.connect();
  const childLogger = logger.child({
    USER_ACTIVITY: userId,
    route: req.route.path,
  });
  try {
    const username = req.params.id;

    let checkUser = await getAllData(USERS_TABLE, {
      id: username,
    });
    await pg_client.query(constants.TRANSACTIONS.BEGIN); // Transaction initiated
    if (checkUser.dataCount <= 0) {
      childLogger.error(`user ${username} doesn't exists to activate`);
      return res.status(400).send({
        error: true,
        message: "user doesn't exists to activate",
        code: 400,
      });
    } else if (
      checkUser.dataCount > 0 &&
      checkUser.data[0].is_deleted == true
    ) {
      childLogger.error(
        `the user ${username} you are trying to activate is already deleted`
      );
      return res.status(400).send({
        error: true,
        message: "This account has been deleted.",
        code: 400,
      });
    }

    var params = {
      UserPoolId: process.env.USER_POOL_ID,
      Username: username,
    };
    const cognito = new AWS.CognitoIdentityServiceProvider();
    // enable an user first
    const disable_user_resp = cognito.adminEnableUser(params).promise();
    disable_user_resp
      .then(async (data) => {
        // mark as active in user table using username
        var user_params = {
          isactive: true,
          updatedat: `now()`,
          updatedby: tenantId,
        };
        await updateData(USERS_TABLE, user_params, username, pg_client);
        childLogger.info(`Requested user ${username} has been activated`);
        const user_type_query = `select id,email,phone,name,is_email_verified,usertype from saev_user where id='${username}'`;
        const user_type_query_result = await pool.query(user_type_query);
        const user_type = user_type_query_result.rows[0]?.usertype;
        if (username != null) {
          const customerTenantData = await getUser_tenant_details(username);
          const { isEmailisVerified, email } = await isEmailVerified(username);
          // Customer Email  is verfied then only allow to send mail else not required
          if (isEmailisVerified === true) {
            const user_activateRequest = {
              customerName: customerTenantData?.data?.customer_name,
            };
            let emailTemplate;
            let emailSubject;
            if (user_type === "USER") {
              // Use USER_ACTIVATION template
              emailTemplate = User_Activate_Email_template(
                user_activateRequest,
                customerTenantData?.data.company_logo,
                customerTenantData?.data.primary_color
              );
              emailSubject = MESSAGES.EMAIL_SUBJECTS.USER_ACTIVATION;
            } else if (user_type === "CUSTOMER") {
              // Use CUSTOMER_ACTIVATION template
              emailTemplate = Customer_Activate_Email_template(
                user_activateRequest,
                customerTenantData?.data.company_logo,
                customerTenantData?.data.primary_color
              );
              emailSubject = MESSAGES.EMAIL_SUBJECTS.CUSTOMER_ACTIVATION;
            }
            const { success, message } = await send_notification_using_sns(
              AWS,
              "Email",
              [email], // To Email Address
              emailTemplate,
              emailSubject
            );
            if (!success) {
              childLogger.error(
                "Email Trigger failed due to this reason ..." + message
              );
            }
          }
          const user_activate_SMS_request = {
            customerName: customerTenantData?.data?.customer_name,
          };
          let smsTemplate;
          if (user_type === "USER") {
            smsTemplate = User_Activate_SMS_template(user_activate_SMS_request);
          } else if (user_type === "CUSTOMER") {
            smsTemplate = Customer_Activate_SMS_template(
              user_activate_SMS_request
            );
          }

          const messageBodyforMobile = smsTemplate;
          const phone = customerTenantData?.data.phone;
          // Dont wait for sms sending result. It should be non blocking
          sms_sender(messageBodyforMobile, phone);
        }
        await pg_client.query(constants.TRANSACTIONS.COMMIT);
        return res
          .status(200)
          .send({ message: "Requested user has been activated" });
      })
      .catch(async (err) => {
        childLogger.error(`Error found while activating user ${err.stack}`);
        await pg_client.query(constants.TRANSACTIONS.ROLLBACK);
        return res
          .status(400)
          .send({ error: true, message: err.message, code: 400 });
      });
  } catch (error) {
    childLogger.error(`Error found while updating user ${error.stack}`);
    await pg_client.query(constants.TRANSACTIONS.ROLLBACK);
    return {
      error: true,
      message: `Internal error while updating user`,
      code: 500,
    };
  } finally {
    childLogger.info(constants.POOL_RELEASED);
    await pg_client.release();
  }
};

export const deleteUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const { tenantId, userId } = await getClaims(req);
  const childLogger = logger.child({
    USER_ACTIVITY: userId,
    route: req.route.path,
  });
  const pg_client = await pool.connect();
  try {
    const username = req.params.id;
    var params = {
      UserPoolId: process.env.USER_POOL_ID,
      Username: username,
    };
    await pg_client.query(constants.TRANSACTIONS.BEGIN); // Transaction initiated
    const cognito = new AWS.CognitoIdentityServiceProvider();
    // delete(disable user) an user first
    const disable_user_resp = cognito.adminDisableUser(params).promise();
    disable_user_resp
      .then(async (data) => {
        // global signout to invalidate all refresh token except access token and id token
        await cognito.adminUserGlobalSignOut(params).promise();
        // mark as inactive and is_deleted true in user table using username
        var user_params = {
          isactive: false,
          is_deleted: true,
          updatedat: `now()`,
          updatedby: tenantId,
        };
        await updateData(USERS_TABLE, user_params, username, pg_client);
        childLogger.info(`user ${username} is deleted`);
        await pg_client.query(constants.TRANSACTIONS.COMMIT);

        return res
          .status(200)
          .send({ message: "Requested user has been deleted" });
      })
      .catch(async (err) => {
        childLogger.error(`Error found while deleting the user ${err.stack}`);
        await pg_client.query(constants.TRANSACTIONS.ROLLBACK);

        return res
          .status(400)
          .send({ error: true, message: err.message, code: 400 });
      });
  } catch (error) {
    childLogger.error(`Error found while updating user ${error.stack}`);
    await pg_client.query(constants.TRANSACTIONS.ROLLBACK);
    return {
      error: true,
      message: `Internal error while updating user`,
      code: 500,
    };
  } finally {
    childLogger.info(constants.POOL_RELEASED);
    await pg_client.release();
  }
};

export const getUserPermissions = async (req: Request) => {
  const { claims, userId } = await getClaims(req);

  const childLogger = logger.child({
    USER_ACTIVITY: userId,
    route: req.route.path,
  });

  try {
    const childLogger = logger.child({
      USER_ACTIVITY: userId,
      route: req.route.path,
    });
    let role_id = claims["role_id"];
    let user_type = claims["custom:userType"];

    let permissions = {};
    const permission_master_data = await pool.query(
      `SELECT name FROM ${settings.PERMISSIONS_TABLE}`
    );
    permission_master_data.rows.forEach(function (row) {
      permissions[row.name] = false;
    });
    if (user_type === "TENANT") {
      for (let key in permissions) {
        permissions[key] = true;
      }
    } else if (user_type === "USER") {
      const role_data = await pool.query(
        `SELECT permissions FROM ${settings.ROLES_TABLE} WHERE id = '${role_id}'`
      );
      if (!role_data.rows[0]) {
        childLogger.error(`User doen't have any role info, ${req}`);
        return {
          code: 200,
          message: "User doen't have any role info.",
          data: {},
        };
      }

      for (let item = 0; item < role_data.rows[0].permissions.length; item++) {
        let key = role_data.rows[0].permissions[item]["name"];
        if (key in permissions) {
          permissions[key] = true;
        }
      }
    } else {
      // CUSTOMER
      return {
        code: 406,
        data: {},
      };
    }
    return {
      code: 200,
      data: permissions,
    };
  } catch (error) {
    childLogger.error(`Error found while deleting the user ${error.stack}`);
    return {
      error: true,
      code: 500,
      message: "Error while fetching user permissions.",
    };
  }
};
