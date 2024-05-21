import { getAllData, addData, updateData, deleteData } from "../lib/postgresDB";
import { getValidDocumentOtp, getValidDocumentVerify } from "./validation";
import { randomUUID } from "crypto";
import { pool } from "../lib/connection_db";

import settings from "../settings";
import {
  sms_sender,
  send_notification_using_sns,
  getClaims,
} from "../lib/common_modules";
import * as AWS from "aws-sdk";
import { Auth } from "aws-amplify";
import { NextFunction, Response, Request } from "express";
import { get_event } from "../lib/security";
import constants from "../lib/constants";
import { signin_Otp_EmailTemplate } from "../lib/templates/sign_in_otp";
import * as moment from "moment";
import fcm_service from "../lib/fcm_service";
import { getDeviceTokenForSigleCustomer, checkUserExist } from "./queries";
import { logger } from "../lib/logger";
const USERS_TABLE = settings.USERS_TABLE;
const USERS_OTP = settings.USERS_OTP_TABLE;
const RFID_TABLE = settings.RFID_TABLE;
const ID_TAG_TABLE = settings.ID_TAG_TABLE;
const SNS = new AWS.SNS({ apiVersion: "2010-03-31" });
const cognito = new AWS.CognitoIdentityServiceProvider();
const awsConfig = {
  aws_user_pools_id: process.env.USER_POOL_ID,
  aws_user_pools_web_client_id: process.env.USER_POOL_CLIENT_ID,
};

Auth.configure(awsConfig);

export const exchange_refresh_token = async (req: Request, res: Response) => {
  try {
    const _resp_event = get_event(req);
    const body = _resp_event.event_body;
    const refresh_token = body.refresh_token;
    let data: any = {};
    if (!refresh_token) {
      return res
        .status(400)
        .send({ error: true, message: "refresh_token is required", code: 400 });
    }
    var params = {
      AuthFlow: "REFRESH_TOKEN_AUTH",
      ClientId: process.env.USER_POOL_CLIENT_ID,
      UserPoolId: process.env.USER_POOL_ID,
      AnalyticsMetadata: {
        AnalyticsEndpointId: "STRING_VALUE",
      },
      AuthParameters: {
        REFRESH_TOKEN: refresh_token,
      },
    };
    const cognito = new AWS.CognitoIdentityServiceProvider();
    const resp_ = await cognito.adminInitiateAuth(params).promise();
    data.id_token = resp_.AuthenticationResult.IdToken;
    data.access_token = resp_.AuthenticationResult.AccessToken;
    data.refresh_token = refresh_token;

    return res.status(200).send(data);
  } catch (error) {
    return res.status(401).send(error);
  }
};

export const customer_signup = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const _resp_event = get_event(req);
  const event_body = _resp_event.event_body;
  const regex = /^\+\d{7,}$/;
  const childLogger = logger.child({
    route: req.route.path,
  });
  const pg_client = await pool.connect();

  try {
    if (Object.keys(event_body).length === 0) {
      return res.status(400).send({
        error: true,
        message: "Required fields are missing",
        code: 400,
      });
    }
    if (event_body.tenantId == undefined) {
      return res
        .status(400)
        .send({ error: true, message: "tenantId is required.", code: 400 });
    }
    if (event_body.phone == undefined) {
      return res
        .status(400)
        .send({ error: true, message: "phone is required.", code: 400 });
    }
    if (event_body.phone == undefined || !regex.test(event_body.phone)) {
      return res.status(400).send({
        error: true,
        message:
          "valid phone is required and it should be start with your country code. example: +91<phone-no>",
        code: 400,
      });
    }
    await pg_client.query(constants.TRANSACTIONS.BEGIN); // Transaction initiated

    let tenantId = event_body.tenantId;
    let userType = "CUSTOMER";
    // or we can create new customer by adding prefix with username cus_<tenantId>_<phone>
    const username = `${tenantId}${event_body.phone}+${userType}`;
    const createdBy = tenantId;
    const rfid_number = randomString(
      constants.rfidNumber.rfidLength,
      "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    );
    let id_tag_status = "Accepted";
    const randomNumber: number = parseInt(
      Math.floor(1000 + Math.random() * 8000).toString()
    ); // 4 digit random number
    // let checkUser: any;
    let checkUserWithId: any;

    // Check If User Exists
    checkUserWithId = await getAllData(USERS_TABLE, {
      id: username,
    });
    // checkUser = await getAllData(USERS_TABLE, {
    //   phone: event_body.phone,
    //   tenantId: tenantId,
    //   userType: userType
    // });

    if (checkUserWithId.dataCount > 0) {
      return res
        .status(400)
        .send({ error: true, message: "An user already exists", code: 400 });
    } else {
      const expiry_date = moment()
        .add(200, "years")
        .format("YYYY-MM-DD HH:mm:ss");
      let rfid_params = [
        username,
        tenantId,
        rfid_number,
        `now()`,
        createdBy,
        constants.idType.remote,
        expiry_date,
      ];
      let rfidQuery = `user_id, tenant_id, rfidnumber, created_at, created_by, id_type, expiry_date`;
      // await addData(RFID_TABLE, rfidQuery, rfid_params, pg_client).then(
      //   (items: Object) => items
      // );

      let id_tag_params = [rfid_number, expiry_date, id_tag_status];
      let idTagQuery = `id_tag, expiry_date, status`;
      // await addData(ID_TAG_TABLE, idTagQuery, id_tag_params, pg_client).then(
      //   (items: Object) => items
      // );
      let params = [
        username,
        event_body.phone,
        tenantId,
        userType,
        username,
        `now()`,
        createdBy,
      ];
      let userCreationQuery = `id, phone,tenantid, usertype, username, createdat, createdby`;
      // const resp_data = await addData(
      //   USERS_TABLE,
      //   query,
      //   params,
      //   pg_client
      // )

      const promiseResp = await Promise.all([
        addData(RFID_TABLE, rfidQuery, rfid_params, pg_client).then(
          (items: Object) => items
        ),
        addData(ID_TAG_TABLE, idTagQuery, id_tag_params, pg_client).then(
          (items: Object) => items
        ),
        addData(USERS_TABLE, userCreationQuery, params, pg_client),
      ]);

      const resp_data = promiseResp[2];

      await pg_client.query(constants.TRANSACTIONS.COMMIT);

      checkUserWithId = await getAllData(USERS_TABLE, {
        id: username,
      });
      if (checkUserWithId.dataCount > 0) {
        const user_id = checkUserWithId.data[0].id;
        const cognitoPayload = {
          UserPoolId: process.env.USER_POOL_ID,
          Username: username,
          // DesiredDeliveryMediums: ["SMS"], // SMS is not configured here and not passing email that's we can not use this.
          UserAttributes: [
            {
              Name: "phone_number",
              Value: event_body.phone,
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
        const cognito = new AWS.CognitoIdentityServiceProvider();
        return cognito.adminCreateUser(cognitoPayload, async (err, data) => {
          if (
            err.message !=
            "User pool does not have SMS configuration to send messages."
          ) {
            const delete_rfid_table = `DELETE from ${RFID_TABLE} where user_id='${user_id}'`;
            const delete_id_tag_table = `DELETE from ${ID_TAG_TABLE} where id_tag='${rfid_number}'`;
            await Promise.all([
              deleteData(USERS_TABLE, user_id).then((items: Object) => items),
              pool.query(delete_rfid_table),
              pool.query(delete_id_tag_table),
            ]);
            await new Promise((resolve) => {
              cognito.adminDeleteUser(
                {
                  UserPoolId: process.env.USER_POOL_ID,
                  Username: username,
                },

                (deleteErr) => {
                  if (deleteErr) {
                    childLogger.error(
                      `Failed to delete Cognito user: ${deleteErr.message}`
                    );
                  }

                  resolve(() => {});
                }
              );
            });
            childLogger.info(
              `Error in the cognito pool creation ${username}`,
              err?.message
            );
            return res.status(400).send({
              error: true,
              message: "Something went wrong please try agin later",
              code: 400,
            });
          } else {
            childLogger.info(
              `Successfully user created in the cognito pool creation ${username}`
            );
            return res.status(201).send(resp_data);
          }
        });
      } else {
        return res.status(400).send({
          error: true,
          message: "something went wrong please try agin later",
          code: 400,
        });
      }
      //   const expiry_date = moment()
      //     .add(200, "years")
      //     .format("YYYY-MM-DD HH:mm:ss");
      //   let rfid_params = [
      //     username,
      //     tenantId,
      //     rfid_number,
      //     `now()`,
      //     createdBy,
      //     constants.idType.remote,
      //     expiry_date,
      //   ];
      //   let query = `user_id, tenant_id, rfidnumber, created_at, created_by, id_type, expiry_date`;
      //   await addData(RFID_TABLE, query, rfid_params, pg_client).then(
      //     (items: Object) => items
      //   );

      //   let id_tag_params = [rfid_number, expiry_date, id_tag_status];
      //   query = `id_tag, expiry_date, status`;
      //   await addData(ID_TAG_TABLE, query, id_tag_params, pg_client).then(
      //     (items: Object) => items
      //   );

      //   let params = [
      //     username,
      //     event_body.phone,
      //     tenantId,
      //     userType,
      //     username,
      //     `now()`,
      //     createdBy,
      //   ];
      //   query = `id, phone,tenantid, usertype, username, createdat, createdby`;
      //   const resp_data = await addData(
      //     USERS_TABLE,
      //     query,
      //     params,
      //     pg_client
      //   ).then((items: Object) => items);
      //   await pg_client.query(constants.TRANSACTIONS.COMMIT);
      //   return res.status(201).send(resp_data);
      // });
    }
  } catch (err) {
    childLogger.error(`${err},${err.stack}`);
    await pg_client.query(constants.TRANSACTIONS.ROLLBACK);
    return {
      error: true,
      message: err,
      code: 500,
    };
  } finally {
    childLogger.info(constants.POOL_RELEASED);
    await pg_client.release();
  }
};

export const reset_password = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const _event_resp = get_event(req);
  const event_body = _event_resp.event_body;

  if (Object.keys(event_body).length === 0) {
    return res
      .status(400)
      .send({ error: true, message: "Required fields are missing." });
  }
  if (event_body.email == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "email is required.", code: 400 });
  }
  if (event_body.tenantId == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "tenantId is required.", code: 400 });
  }
  let email = event_body.email;

  // Find the index of '+' in the local part
  let plusIndex = email?.indexOf("+user");
  let modifiedEmail;
  if (plusIndex !== -1) {
    // Extract the local part and domain part
    let localPart = email.substring(0, plusIndex);
    let domainPart = email.substring(email?.indexOf("@"));

    // Reconstruct the modified email address
    modifiedEmail = localPart + domainPart;
    event_body.email = modifiedEmail;
  } else {
    console.log("No modifier found in the email");
  }
  // fetch username from users table
  const checkUser = await getAllData(USERS_TABLE, {
    email: event_body.email,
    tenantId: event_body.tenantId,
    userType: "USER",
  });
  const checkTenant = await getAllData(USERS_TABLE, {
    email: event_body.email,
    tenantId: event_body.tenantId,
    userType: "TENANT",
  });
  if (checkUser.dataCount == 0 && checkTenant.dataCount == 0) {
    return res
      .status(400)
      .send({ error: true, message: "Incorrect email or tenanId.", code: 400 });
  } else if (
    (checkUser.dataCount > 0 || checkTenant.dataCount > 0) &&
    (checkUser.data[0].isactive == false ||
      checkTenant.data[0].isactive == false ||
      checkUser.data[0].is_deleted == true ||
      checkTenant.data.is_deleted == true)
  ) {
    return res.status(400).send({
      error: true,
      message: "User is disabled or deleted.",
      code: 400,
    });
  }

  const username = checkUser.data[0].id
    ? checkUser.data[0].id
    : checkTenant.data[0].id;
  const cognito = new AWS.CognitoIdentityServiceProvider();
  const user_params = {
    Username: username,
    UserPoolId: process.env.USER_POOL_ID,
  };

  const user = await cognito.adminGetUser(user_params).promise();

  if (
    user.UserStatus == "FORCE_CHANGE_PASSWORD" ||
    user.UserStatus === "Confirmed"
  ) {
    const tmp_pass = randomUUID().replace(/-/g, "");

    var __reset_params = {
      Password: `$A@${tmp_pass}`,
      UserPoolId: process.env.USER_POOL_ID,
      Username: username,
      Permanent: true,
    };
    try {
      const change_temp_password = await cognito
        .adminSetUserPassword(__reset_params)
        .promise();
    } catch (err) {
      return res
        .status(400)
        .send({ error: true, message: err.message, code: 400 });
    }
  }
  const params = {
    ClientId: process.env.USER_POOL_CLIENT_ID,
    Username: username,
  };

  return cognito.forgotPassword(params, (err, data) => {
    if (err) {
      return res
        .status(400)
        .send({ error: true, message: err.message, code: 400 });
    }
    return res.status(200).send(data);
  });
};

export const confirm_reset_password = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const _event_resp = get_event(req);
  const event_body = _event_resp.event_body;

  if (Object.keys(event_body).length === 0) {
    return res
      .status(400)
      .send({ error: true, message: "Required fields are missing." });
  }
  if (event_body.email == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "email is required.", code: 400 });
  }
  if (event_body.otp == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "otp is required.", code: 400 });
  }
  if (event_body.tenantId == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "tenantId is required.", code: 400 });
  }
  if (event_body.password == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "password is required.", code: 400 });
  }
  // fetch username from users table
  const checkUser = await getAllData(USERS_TABLE, {
    email: event_body.email,
    tenantId: event_body.tenantId,
    isactive: true,
    is_deleted: false,
    userType: "USER",
  });
  const checkTenant = await getAllData(USERS_TABLE, {
    email: event_body.email,
    tenantId: event_body.tenantId,
    isactive: true,
    is_deleted: false,
    userType: "TENANT",
  });

  if (checkUser.dataCount == 0 && checkTenant.dataCount == 0) {
    return res
      .status(400)
      .send({ error: true, message: "Incorrect email or tenanId." });
  }

  const username = checkUser.data[0].id
    ? checkUser.data[0].id
    : checkTenant.data[0].id;
  const cognito = new AWS.CognitoIdentityServiceProvider();
  const params = {
    ClientId: process.env.USER_POOL_CLIENT_ID,
    Username: username,
    ConfirmationCode: event_body.otp,
    Password: event_body.password,
  };
  return cognito.confirmForgotPassword(params, (err, data) => {
    if (err) {
      return res
        .status(400)
        .send({ error: true, message: err.message, code: 400 });
    }

    return res.status(200).send({ message: "Your password has been changed." });
  });
};

export const check_password = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const _resp_event = get_event(req);
  const event_body = _resp_event.event_body;

  // validations
  if (Object.keys(event_body).length === 0) {
    return res
      .status(400)
      .send({ error: true, message: "Required fields are missing", code: 400 });
  }
  if (event_body.password == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "password is required.", code: 400 });
  }
  let email = req.body.claims.email;

  // Find the index of '+' in the local part
  let plusIndex = email?.indexOf("+user");
  let modifiedEmail;
  if (plusIndex !== -1) {
    // Extract the local part and domain part
    let localPart = email.substring(0, plusIndex);
    let domainPart = email.substring(email?.indexOf("@"));

    // Reconstruct the modified email address
    modifiedEmail = localPart + domainPart;
    req.body.claims.email = modifiedEmail;
  } else {
    console.log("No modifier found in the email");
  }
  const checkUser = await getAllData(USERS_TABLE, {
    email: req.body.claims.email,
    tenantId: req.body.claims.tenantId,
    userType: "USER",
  });
  const checkTenant = await getAllData(USERS_TABLE, {
    email: req.body.claims.email,
    tenantId: req.body.claims.tenantId,
    userType: "TENANT",
  });
  if (checkUser.dataCount == 0 && checkTenant.dataCount == 0) {
    return res
      .status(400)
      .send({ error: true, message: "User does not exists.", code: 400 });
  } else if (
    (checkUser.dataCount > 0 || checkTenant.dataCount > 0) &&
    (checkUser.data[0].isactive == false ||
      checkTenant.data[0].isactive == false ||
      checkUser.data[0].is_deleted == true ||
      checkTenant.data[0].is_deleted == true)
  ) {
    return res.status(400).send({
      error: true,
      message: "User is disabled or deleted.",
      code: 400,
    });
  }

  const params = {
    AuthFlow: "ADMIN_NO_SRP_AUTH",
    UserPoolId: process.env.USER_POOL_ID,
    ClientId: process.env.USER_POOL_CLIENT_ID,
    AuthParameters: {
      USERNAME: checkUser.data[0].id
        ? checkUser.data[0].id
        : checkTenant.data[0].id,
      PASSWORD: event_body.password,
    },
  };

  return cognito.adminInitiateAuth(params, (err, data) => {
    if (err) {
      return res
        .status(400)
        .send({ error: true, message: err.message, code: 400 });
    }
    res.status(200).send({
      code: 200,
      message: "Success",
    });
  });
};

export const change_password = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const _event_resp = get_event(req);
  const event_body = _event_resp.event_body;
  if (Object.keys(event_body).length === 0) {
    return res
      .status(400)
      .send({ error: true, message: "Required fields are missing." });
  }
  if (event_body.old_password == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "Old password is required.", code: 400 });
  }
  if (event_body.password == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "Password is required.", code: 400 });
  }
  let email = req.body.claims.email;

  // Find the index of '+' in the local part
  let plusIndex = email?.indexOf("+user");
  let modifiedEmail;
  if (plusIndex !== -1) {
    // Extract the local part and domain part
    let localPart = email.substring(0, plusIndex);
    let domainPart = email.substring(email?.indexOf("@"));

    // Reconstruct the modified email address
    modifiedEmail = localPart + domainPart;
    req.body.claims.email = modifiedEmail;
  } else {
    console.log("No modifier found in the email");
  }
  // fetch username from users table
  const checkUser = await getAllData(USERS_TABLE, {
    email: req.body.claims.email,
    tenantId: req.body.claims.tenantId,
    userType: "USER",
  });
  const checkTenant = await getAllData(USERS_TABLE, {
    email: req.body.claims.email,
    tenantId: req.body.claims.tenantId,
    userType: "TENANT",
  });
  if (checkUser.dataCount == 0 && checkTenant.dataCount == 0) {
    return res
      .status(400)
      .send({ error: true, message: "Incorrect email or tenanId." });
  } else if (
    (checkUser.dataCount > 0 || checkTenant.dataCount > 0) &&
    (checkUser.data[0].isactive == false ||
      checkTenant.data[0].isactive == false ||
      checkUser.data[0].is_deleted == true ||
      checkTenant.data.is_deleted == true)
  ) {
    return res.status(400).send({
      error: true,
      message: "User is disabled or deleted.",
      code: 400,
    });
  }

  const cognito = new AWS.CognitoIdentityServiceProvider();
  const params = {
    AccessToken: event_body.access_token,
    PreviousPassword: event_body.old_password,
    ProposedPassword: event_body.password,
  };
  return cognito.changePassword(params, (err, data) => {
    if (err) {
      return res
        .status(400)
        .send({ error: true, message: err.message, code: 400 });
    }
    return res.status(200).send({ message: "Your password has been changed." });
  });
};

export const usr_pass_login = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const _resp_event = get_event(req);
  const event = _resp_event.event;
  const event_body = _resp_event.event_body;
  // validations
  if (Object.keys(event_body).length === 0) {
    return res
      .status(400)
      .send({ error: true, message: "Required fields are missing", code: 400 });
  }
  if (event_body.email == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "email is required.", code: 400 });
  }
  if (event_body.password == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "password is required.", code: 400 });
  }
  if (event_body.tenantId == undefined) {
    return res
      .status(400)
      .send({ error: true, message: "tenantId is required.", code: 400 });
  }
  const checkUser = await getAllData(USERS_TABLE, {
    tenantId: event_body.tenantId,
    email: event_body.email,
    userType: "USER",
  });
  const checkTenant = await getAllData(USERS_TABLE, {
    tenantId: event_body.tenantId,
    email: event_body.email,
    userType: "TENANT",
  });
  if (checkUser.dataCount == 0 && checkTenant.dataCount == 0) {
    return res
      .status(400)
      .send({ error: true, message: "User does not exists.", code: 400 });
  } else if (
    (checkUser.dataCount > 0 || checkTenant.dataCount > 0) &&
    (checkUser.data[0].isactive == false ||
      checkTenant.data[0].isactive == false ||
      checkUser.data[0].is_deleted == true ||
      checkTenant.data[0].is_deleted == true)
  ) {
    return res.status(400).send({
      error: true,
      message: "User is disabled or deleted.",
      code: 400,
    });
  }
  const params = {
    AuthFlow: "ADMIN_NO_SRP_AUTH",
    UserPoolId: process.env.USER_POOL_ID,
    ClientId: process.env.USER_POOL_CLIENT_ID,
    AuthParameters: {
      USERNAME: checkUser.data[0].id
        ? checkUser.data[0].id
        : checkTenant.data[0].id,
      PASSWORD: event_body.password,
    },
  };
  return cognito.adminInitiateAuth(params, (err, data) => {
    if (err) {
      return res
        .status(400)
        .send({ error: true, message: err.message, code: 400 });
    }
    res.status(200).send({
      code: 200,
      message: "Success",
      userId: checkUser.data[0].id
        ? checkUser.data[0].id
        : checkTenant.data[0].id,
      ...data.AuthenticationResult,
    });
  });
};

export const sendSMS = async (phoneNumber: string, content: string) => {
  const AttributeParams = {
    attributes: { DefaultSMSType: "Transactional" },
  };
  const params = {
    Message: content,
    PhoneNumber: phoneNumber,
  };
  try {
    if (settings.sendSMS) {
      await SNS.setSMSAttributes(AttributeParams).promise();
      await SNS.publish(params).promise();
    }
    return { message: `message sent successfully, ${content}` };
  } catch (error) {
    return Promise.resolve({ error: true, message: JSON.stringify(error) });
  }
};

export const createOtp = async (value: any) => {
  let data = await getValidDocumentOtp(value);
  const childLogger = logger.child({
    route: "auth/createOtp",
  });
  // Check If User Exit
  const checkUser = await getAllData(USERS_TABLE, {
    tenantId: data.tenantId,
    phone: data.phone,
    userType: "CUSTOMER",
  });

  if (checkUser.dataCount == 0) {
    childLogger.error(`User does not exists.`);
    return Promise.resolve({
      error: true,
      message: "User does not exists.",
      code: 400,
    });
  } else if (
    checkUser.dataCount > 0 &&
    (checkUser.data[0].isactive == false ||
      checkUser.data[0].is_deleted == true)
  ) {
    childLogger.error(`User is disabled or deleted.`);
    return Promise.resolve({
      error: true,
      message: "User is disabled or deleted.",
      code: 400,
    });
  } else {
    // Create OTP
    const phone = data.phone;
    let signature = data.signature; // Used to trak the token for auto login purpose
    const OTP: string = Math.floor(1000 + Math.random() * 9000).toString();
    const query = `tenantid, username, phone, otp, createdat,signature`;
    const params = [
      data.tenantId,
      checkUser.data[0].id,
      phone,
      OTP,
      new Date(new Date().getTime() + 330 * 60 * 1000),
      signature,
    ];
    const createOtp = await addData(USERS_OTP, query, params);
    if (createOtp.id) {
      const Poolparams = {
        UserPoolId: process.env.USER_POOL_ID,
        Username: checkUser.data[0].id,
      };
      // Provide the user pool data to check Email, Mobile are verified or not
      const user = await cognito.adminGetUser(Poolparams).promise();
      let sendEmailFlag = false;
      const email_verified_flag = user.UserAttributes.find(
        (ele) => ele.Name === "email_verified"
      );
      signature = signature ? signature : constants.DEFAULT_SIGNATURE;
      const messageBodyforMobile = `${OTP} is your verification code for Zeon Charging. ${signature}`; // here Signature added for auto Fill OTP in mobile side
      const messageBodyforEmail = `Your verification code is ${OTP}`;
      sendEmailFlag =
        email_verified_flag === undefined
          ? false
          : email_verified_flag.Value == "true"
          ? true
          : false;

      if (sendEmailFlag == true) {
        // trigger the email for OTP during the sign in from APP
        const logoQuery = `select * from ${settings.SETTINGS_TABLE} where tenantid='${data.tenantId}'`;
        const settingData = await pool.query(logoQuery);
        await send_notification_using_sns(
          AWS,
          "Email",
          [checkUser.data[0].email],
          signin_Otp_EmailTemplate(
            checkUser.data[0].name,
            messageBodyforEmail,
            settingData?.rows[0]?.company_logo,
            settingData?.rows[0]?.primary_color
          ),
          `Sign in OTP`
        );
      }
      return await sms_sender(messageBodyforMobile, phone, true, true)
        .then((data) => {
          if (data) {
            const message = `Verification sent successfully on your mobile number ending with ${phone.substring(
              8
            )} and your verification code is ${OTP}.`;
            return { code: 200, message: message };
          } else {
            childLogger.error(`${data}`);
            return { code: 400, error: data };
          }
        })
        .catch((err) => {
          childLogger.error(`${err},${err.stack}`);
          return { code: 400, error: err };
        });
    } else {
      childLogger.error(`Create otp is failed.`);
      return { error: true, message: "Create otp is failed." };
    }
  }
};

export const loginUser = async (username: string) => {
  return await Auth.signIn(username)
    .then((user) => {
      return Auth.sendCustomChallengeAnswer(
        user,
        process.env.CREATE_AUTH_CHALLENGE_OTP
      )
        .then((user) => {
          return user;
        })
        .catch((err) => {
          return Promise.resolve({ error: true, message: err });
        });
    })
    .catch((err) => {
      return Promise.resolve({ error: true, message: err });
    });
};

export const verifyOtp = async (value: any) => {
  let data = await getValidDocumentVerify(value);

  let isMasterOtpFlow = false;
  if (settings.masterOtp === data.otp) {
    isMasterOtpFlow = true;
  }
  const { device_type, device_token, device_name, device_model } = value;

  const params = isMasterOtpFlow
    ? {
        tenantId: data.tenantId,
        phone: data.phone,
      }
    : {
        tenantId: data.tenantId,
        phone: data.phone,
        otp: data.otp,
      };
  let otpQuery: string;
  let otpParams: any[];
  otpQuery = `select * from ${USERS_OTP} where tenantid = $1 and phone = $2`;
  otpParams = [data.tenantId, data.phone];
  if (!isMasterOtpFlow) {
    otpQuery = otpQuery + "and otp = $3";
    otpParams.push(data.otp);
  }
  const getOtpResp = await pool.query(
    otpQuery + " order by createdat desc",
    otpParams
  );
  const checkOtp = {
    dataCount: getOtpResp.rowCount,
    data: getOtpResp?.rows ? getOtpResp?.rows : [],
  };
  // const checkOtp = await getAllData(USERS_OTP, params);
  const childLogger = logger.child({
    route: "auth/verifyOtp",
  });
  if (checkOtp.dataCount == 0) {
    childLogger.error(`OTP does not exists.`);
    return Promise.resolve({ error: true, message: "OTP does not exists." });
  } else {
    // Generate Token
    const username = `${checkOtp.data[0].username}`;
    const created_at = new Date(checkOtp.data[0].createdat);
    const local = new Date(new Date().getTime() + 330 * 60 * 1000);
    var time_diff = (local.getTime() - created_at.getTime()) / (1000 * 60);

    if (!isMasterOtpFlow && time_diff > checkOtp.data[0].expiryin) {
      childLogger.error(`This otp has been expired.`);
      return { error: true, message: "This otp has been expired.", code: 400 };
    }
    const tokenResponse = await loginUser(username);

    if (tokenResponse != null) {
      if (tokenResponse.error) {
        if (tokenResponse.message.name == "NotAuthorizedException") {
          childLogger.error(`User is disabled or deleted.`);
          tokenResponse.message.name = "User is disabled or deleted.";
        }
        childLogger.error(`${tokenResponse.message.name}`);
        return { error: true, message: tokenResponse.message.name, code: 400 };
      }
      let resp_data = {
        id_token: tokenResponse.signInUserSession.idToken.jwtToken,
        access_token: tokenResponse.signInUserSession.accessToken.jwtToken,
        refresh_token: tokenResponse.signInUserSession.refreshToken.token,
      };
      console.log(
        "tokenResponse username",
        username,
        device_token,
        resp_data.access_token
      );

      await insertOrUpdateSession(
        username,
        device_token,
        resp_data.access_token,
        data.tenantId,
        device_type
      );
      return resp_data;
    }
  }
};

// Function to retrieve all active sessions for a user
const getActiveSessions = async (userId: any) => {
  console.log("activeSessionsResult userId", userId);
  // Replace this with your actual query to retrieve active sessions from your database
  const activeSessionsQuery =
    "SELECT * FROM saev_user_devices WHERE user_id = $1";
  const activeSessionsResult = await pool.query(activeSessionsQuery, [userId]);
  console.log("activeSessionsResult", activeSessionsResult);

  return activeSessionsResult.rows;
};

const updateSessionAccessToken = async (
  userId: any,
  deviceId: any,
  accessToken: any
) => {
  const updateSessionQuery =
    "UPDATE saev_user_devices SET access_token = $1 WHERE user_id = $2 AND device_token = $3";
  console.log("updateSessionQuery", updateSessionQuery);
  await pool.query(updateSessionQuery, [accessToken, userId, deviceId]);
};
async function deleteSessionRecord(userId: any, deviceId: any) {
  try {
    await pool.query(
      "DELETE FROM saev_user_devices WHERE user_id = $1 AND device_token = $2",
      [userId, deviceId]
    );
    console.log(
      `Successfully deleted session record for userId: ${userId} and deviceId: ${deviceId}`
    );
  } catch (error) {
    console.error(`Failed to delete session record. Error: ${error.message}`);
    // Handle the error as needed
  }
}

// Function to insert or update session information into the database
const insertOrUpdateSession = async (
  userId: string,
  deviceId: any,
  accessToken: any,
  tenantId: string,
  device_type: string
) => {
  // Check if a session already exists for the user
  const existingSessionQuery =
    "SELECT * FROM saev_user_devices WHERE user_id = $1 AND device_token = $2";
  console.log("existingSessionQuery", existingSessionQuery);
  const existingSessionResult = await pool.query(existingSessionQuery, [
    userId,
    deviceId,
  ]);
  console.log("existingSessionResult", existingSessionResult);

  if (existingSessionResult.rows.length > 0) {
    // If a session exists, update the access_token
    await updateSessionAccessToken(userId, deviceId, accessToken);
  } else {
    // If no session exists, insert a new row
    const insertSessionQuery =
      "INSERT INTO saev_user_devices (user_id, device_token, access_token,tenant_id,device_type) VALUES ($1, $2, $3,$4,$5)";
    console.log("insertSessionQuery", insertSessionQuery);
    try {
      await pool.query(insertSessionQuery, [
        userId,
        deviceId,
        accessToken,
        tenantId,
        device_type,
      ]);
      console.log("Insert successful");
    } catch (error) {
      console.error("Error executing query:", error);
    }
  }
};

export const logoutAllDeviceWithOtp = async (req: Request) => {
  let value = req.body;
  let data = await getValidDocumentOtp(value);
  const { userId } = await getClaims(req);
  // Check If User Exist
  const childlogger = logger.child({
    USER_ACTIVITY: userId,
    route: req.route.path,
  });
  const checkUser = await getAllData(USERS_TABLE, {
    tenantId: data.tenantId,
    phone: data.phone,
    userType: "CUSTOMER",
  });

  if (checkUser.dataCount == 0) {
    childlogger.error(`User does not exists.`);
    return Promise.resolve({
      error: true,
      message: "User does not exists.",
      code: 400,
    });
  } else if (
    checkUser.dataCount > 0 &&
    (checkUser.data[0].isactive == false ||
      checkUser.data[0].is_deleted == true)
  ) {
    childlogger.error(`User is disabled or deleted.`);
    return Promise.resolve({
      error: true,
      message: "User is disabled or deleted.",
      code: 400,
    });
  } else {
    // Create OTP
    const phone = data.phone;
    const signature = data.signature; // Used to trak the token for auto login purpose
    const OTP: string = Math.floor(1000 + Math.random() * 9000).toString();
    const query = `tenantid, username, phone, otp, createdat,signature`;
    const params = [
      data.tenantId,
      checkUser.data[0].id,
      phone,
      OTP,
      new Date(new Date().getTime() + 330 * 60 * 1000),
      signature,
    ];
    const createOtp = await addData(USERS_OTP, query, params);
    if (createOtp.id) {
      const messageBody = `${OTP} is your verification code for Zeon Charging. ${signature}`; // here Signature added for auto Fill OTP in mobile side
      return await sms_sender(messageBody, phone, true, true)
        .then((data) => {
          if (data) {
            const message = `Verification sent successfully on your mobile number ending with ${phone.substring(
              8
            )} and your verification code is ${OTP}.`;
            return { code: 200, message: message };
          } else {
            childlogger.error(`${data}`);
            return { code: 400, error: data };
          }
        })
        .catch((err) => {
          childlogger.error(`${err},${err.stack}`);
          return { code: 400, error: err };
        });
    } else {
      childlogger.error(`Create otp is failed.`);
      return { error: true, message: "Create otp is failed." };
    }
  }
};

export const logoutAllDeviceWithOtpVerify = async (req: Request) => {
  let value = req.body;
  let data = await getValidDocumentVerify(value);

  let isMasterOtpFlow = false;
  if (settings.masterOtp === data.otp) {
    isMasterOtpFlow = true;
  }

  const params = isMasterOtpFlow
    ? {
        tenantId: data.tenantId,
        phone: data.phone,
      }
    : {
        tenantId: data.tenantId,
        phone: data.phone,
        otp: data.otp,
      };
  const checkOtp = await getAllData(USERS_OTP, params);
  const childlogger = logger.child({
    USER_ACTIVITY: checkOtp.data[0].createdat,
    route: req.route.path,
  });
  if (checkOtp.dataCount == 0) {
    childlogger.error(`OTP does not exists.`);
    return Promise.resolve({ error: true, message: "OTP does not exists." });
  } else {
    // Generate Token
    const username = `${checkOtp.data[0].username}`;
    const created_at = new Date(checkOtp.data[0].createdat);
    const local = new Date(new Date().getTime() + 330 * 60 * 1000);
    var time_diff = (local.getTime() - created_at.getTime()) / (1000 * 60);

    if (!isMasterOtpFlow && time_diff > checkOtp.data[0].expiryin) {
      childlogger.error(`This otp has been expired.`);
      return { error: true, message: "This otp has been expired.", code: 400 };
    }

    // Retrieve all active sessions for the user
    const activeSessions = await getActiveSessions(username);

    // Initiate the cognito service
    const cognito = new AWS.CognitoIdentityServiceProvider();

    const body = `Hi, you have been logged out of all devices by the account owner.`;
    const notifyBodyObjectRfidActivated = {
      alertTitle: "SIGNOUT",
      alertBody: "",
      alertMessageKey: `Hi, you have been logged out of all devices by the account owner.`,
    };
    const notificationBody = JSON.stringify(notifyBodyObjectRfidActivated);
    const alertRedirect = "/signOut";
    try {
      const alertsObject = {
        title: "Logged out",
        body: body,
        notificationType: "alert",
        notificationData: {
          alertType: "SIGNOUT",
          alertData: notificationBody,
          alertRedirect,
          username,
        },
        scheduledType: "immediate",
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      console.log("alertsObject", alertsObject);

      await fcm_service.sendAlerts(data.tenantId, username, alertsObject);
    } catch (err) {
      console.error(`Failed sending alert ${err}, ${err.stack}`);
    }
    const globalSignOutPromises = activeSessions.map(async (session: any) => {
      try {
        if (session.access_token) {
          // Perform global sign-out for each session
          await cognito
            .globalSignOut({ AccessToken: session.access_token })
            .promise();
          console.log(
            `Successfully signed out session with access token: ${session}`
          );
          await deleteSessionRecord(session?.user_id, session?.device_token);
        }
      } catch (error) {
        console.error(
          `Failed to sign out session with access token ${session.access_token}. Error: ${error.message}`
        );
        // Handle the error as needed
      }
    });

    // Wait for all promises to settle
    await Promise.all(globalSignOutPromises);

    console.log("activeSessions GlobalSignOutPromises 1", activeSessions);

    return {
      success: true,
    };
  }
};

function randomString(length: number, chars: string | any[]) {
  let result = "";
  for (let i = length; i > 0; --i)
    result += chars[Math.floor(Math.random() * chars.length)];
  return result;
}

export const verifyCustomerEmail = async (req: Request) => {
  const token = req.params.verify_token ? req.params.verify_token : null;
  const user_id = String(req.query.id) ? String(req.query.id) : null;
  const childlogger = logger.child({
    USER_ACTIVITY: user_id,
    route: req.route.path,
  });
  try {
    const params = {
      username: user_id,
      verify_token: token,
    };
    const checkToken = await getAllData(USERS_OTP, params);

    if (checkToken.dataCount == 0) {
      childlogger.error(`Token does not match or Invalid token`);
      return `
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Email Verification Successful</title>
          <style>
              body {
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  height: 100vh;
                  margin: 0;
              }
              div {
                  text-align: center;
                  max-width: 400px;
              }
              img {
                  max-width: 100%;
                  height: auto;
              }
          </style>
      </head>
      <body>
          <div>
              <h1>Invalid Token</h1>
               <p>The token does not match or is invalid. Please ensure you are using the correct verification link.</p>
          </div>
      </body>
      </html>      
          `;
    } else {
      // Validate that token for verifying the email
      const created_at = new Date(checkToken.data[0].createdat);
      const local = new Date(new Date().getTime() + 330 * 60 * 1000);
      const time_diff = (local.getTime() - created_at.getTime()) / (1000 * 60);
      if (time_diff > checkToken.data[0].expiryin) {
        childlogger.error(`This URL has been expired.`);
        return `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>URL Expired</title>
            <style>
                body {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    margin: 0;
                }
                div {
                    text-align: center;
                    max-width: 400px;
                }
            </style>
        </head>
        <body>
            <div>
            <h1>URL Expired</h1>
            <p>This URL has expired. Please request a new verification link.</p>
            </div>
        </body>
        </html>      
            `;
      }

      // update on userPool email_verified
      const cognito = new AWS.CognitoIdentityServiceProvider();
      const cognitoParams = {
        UserPoolId: process.env.USER_POOL_ID,
        Username: user_id,
        UserAttributes: [
          {
            Name: "email_verified",
            Value: "true",
          },
        ],
      };
      const updatePool = await cognito
        .adminUpdateUserAttributes(cognitoParams)
        .promise();
      if (updatePool.$response.error) {
        const err = updatePool.$response.error;
        childlogger.error(`${err.stack}`);
        return {
          error: true,
          message: updatePool.$response.error,
          code: 500,
        };
      } else {
        // Update the User table also since the new column to track the email is verified or not
        const email_update_params = {
          is_email_verified: true,
        };
        await updateData(USERS_TABLE, email_update_params, user_id);
        const getCustomerTokenQuery = getDeviceTokenForSigleCustomer();
        const userTokens = await pool.query(getCustomerTokenQuery, [
          checkToken.data[0].tenantid,
          user_id,
        ]);
        // If the device token available Ten trigger Push notification else skip
        if (userTokens?.rows?.length > 0) {
          const userTokensArray = userTokens.rows.map(
            (obj: { device_token: any }) => obj.device_token
          );
          // Here send the Push notification to the specific Customer Mobile device
          await fcm_service.sendNotificationToManyTokens(
            userTokensArray, // maximum 500 or 1000 tokens only allowed per instance
            "Email verified successfully!!" as string,
            "Your email has been verified. Enjoy seamless EV charging with us." as string,
            "" as string,
            {},
            user_id
          );
        }
        return `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Email Verification Successful</title>
            <style>
                body {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    margin: 0;
                }
                div {
                    text-align: center;
                    max-width: 400px;
                }
                img {
                    max-width: 100%;
                    height: auto;
                }
            </style>
        </head>
        <body>
            <div>
                <h1>Email Verification Successful</h1>
                <p>Your email has been verified successfully. Enjoy seamless EV charging with us.</p>
                <img src="https://gifdb.com/images/high/animated-green-verified-check-mark-k3et2jz52jyu2v22.webp" alt="Verified Icon">
            </div>
        </body>
        </html>      
            `;
      }
    }
  } catch (err) {
    childlogger.error(`${err.message}, ${err.stack}`);
    return {
      error: true,
      code: 500,
      message: err.message,
    };
  }
};

export const getUser = async (req: Request) => {
  const { tenantId, userId } = await getClaims(req);
  const childLogger = logger.child({
    USER_ACTIVITY: userId,
    route: req.route.path,
  });
  try {
    if (userId) {
      const getUserQuery = checkUserExist();
      const getUserResult = await pool.query(getUserQuery, [tenantId, userId]);
      if (getUserResult.rows.length > 0) {
        return {
          code: 200,
          message: "User found",
          success: true,
        };
      }
      return {
        code: 404,
        message: "User not found",
        error: true,
      };
    }
  } catch (error) {
    childLogger.error(`${error}, ${error.stack}`);
  }
};
