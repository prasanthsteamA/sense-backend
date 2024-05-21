
const getOnboardingEmailBody = ({
  tenantLogo,
  userName,
  tenantName,
  userEmail,
  tempPassword,
  userId
}) => {
  let email = userEmail;

// Find the index of '+' in the local part
let plusIndex = email?.indexOf('+user');
let modifiedEmail;
if (plusIndex !== -1) {
    // Extract the local part and domain part
    let localPart = email.substring(0, plusIndex);
    let domainPart = email.substring(email?.indexOf('@'));

    // Reconstruct the modified email address
    modifiedEmail = localPart + domainPart;
} else {
    modifiedEmail = userEmail
    console.log("No modifier found in the email");
}

  return `
<html>
<body style="font-family: Arial, sans-serif;font-size: 14px;color: #444444;margin: 0px;">
<div>
<div class="header" style="background-color: #4caf50;width: &quot;100%&quot;;height: 47px;display: flex;align-items: center;justify-content: space-between;">
  <div>
    <img style="margin-left: 20px" src="${tenantLogo}" width="60" height="50">
  </div>
</div>
<div style="margin-left: 81px; margin-right: 81px; margin-top: 24px">
  <div class="primaryTextStyle" style="font-weight: 400;font-size: 14px;line-height: 25px;color: #000000;">Dear ${userName},</div>
  <p class="primaryTextStyle" style="font-weight: 400;font-size: 14px;line-height: 25px;color: #000000;">
    We are delighted to welcome you to ${tenantName}'s Charge Station
    Management System! As part of our onboarding process, we have created
    an account for you on the platform. Your temporary login details are
    provided below:
  </p>
  <div style="margin-top: 32px; margin-bottom: 32px">
    <p class="secondaryTextStyle" style="font-weight: 700;font-size: 14px;line-height: 25px;color: #000000;">
      Name:
      <span class="primaryTextStyle" style="font-weight: 400;font-size: 14px;line-height: 25px;color: #000000;">${userName}</span>
    </p>
    <p class="secondaryTextStyle" style="font-weight: 700;font-size: 14px;line-height: 25px;color: #000000;">
      User ID:
      <span class="primaryTextStyle" style="font-weight: 400;font-size: 14px;line-height: 25px;color: #000000;">${userId}</span>
    </p>
    <p class="secondaryTextStyle" style="font-weight: 700;font-size: 14px;line-height: 25px;color: #000000;">
      Username:
      <span class="primaryTextStyle" style="font-weight: 400;font-size: 14px;line-height: 25px;color: #000000;">${modifiedEmail}</span>
    </p>
    <p class="secondaryTextStyle" style="font-weight: 700;font-size: 14px;line-height: 25px;color: #000000;">
      Temporary Password:
      <span class="primaryTextStyle" style="font-weight: 400;font-size: 14px;line-height: 25px;color: #000000;">${tempPassword}</span>
    </p>
  </div>
  <div>
    <p class="primaryTextStyle" style="font-weight: 400;font-size: 14px;line-height: 25px;color: #000000;">
      Please log in using these details and
      <span class="secondaryTextStyle" style="font-weight: 700;font-size: 14px;line-height: 25px;color: #000000;">reset your password</span>
      for security purposes.
    </p>
    <p class="primaryTextStyle" style="font-weight: 400;font-size: 14px;line-height: 25px;color: #000000;">
      If you encounter any issues while using the platform, please don't
      hesitate to contact your admin.
    </p>
  </div>
</div>
</div>
</body>
</html>
  `
}

const getresetPasswordEmailBody = ({
  tenantLogo,
  userName,
  tenantName,
  tempPassword,
  userEmail
}) => {
  let email = userEmail;
  let modifiedEmail;
// Find the index of '+' in the local part
  if(email){
  let plusIndex = email?.indexOf('+');
  if (plusIndex !== -1) {
      // Extract the local part and domain part
      let localPart = email.substring(0, plusIndex);
      let domainPart = email.substring(email?.indexOf('@'));

      // Reconstruct the modified email address
      modifiedEmail = localPart + domainPart;
  } else {
    modifiedEmail = userEmail;
  }
}

  return `
  <html>
  <head>
    <meta charset="UTF-8">
  </head>
  <body style="font-family: Arial, sans-serif; font-size: 14px; color: #444444; margin: 0px;">
    <div>
      <div style="background-color: #4caf50; width: 100%; height: 47px; display: flex; align-items: center; justify-content: space-between;" >
        <div>
          <img style="margin-left: 20px;" src="${tenantLogo}" width="126.55px" height="27px" />
        </div>
      </div>
      <div style="margin-left: 81px; margin-right: 81px; margin-top: 24px;">
        <div style="font-weight: 400; font-size: 14px; line-height: 25px; color: #000000;" >Dear ${userName},</div>
        <p style="font-weight: 400; font-size: 14px; line-height: 25px; color: #000000;">
          We received a request to reset the password for your account on ${tenantName} Charge Station Management System. Please use the following code to reset your password:
        </p>
        <div style="display: flex; flex-direction: column; margin-top: 24px; margin-bottom: 24px;">
          <div style="font-weight: 400; align-self: center; font-size: 14px; line-height: 25px; color: #000000;">Password Reset Code</div>
          <div style="direction: rtl; width: 260px; height: 67px; margin-top: 1px; background-color: #0000000d; border-radius: 7px; align-self: center; font-size: 37px; font-weight: 700; line-height: 67px; color: #4caf50; letter-spacing: 16px; text-align: center; text-indent: -16px;">${tempPassword}</div>
        </div>
        <div>
          <p style="font-weight: 400; font-size: 14px; line-height: 25px; color: #000000;">Enter this code on the password reset page to complete the process. This code will expire in 10 mins.</p>
          <p style="font-weight: 400; font-size: 14px; line-height: 25px; color: #000000;"><a href="${process.env.RESET_PASSWORD_PAGE_URL}?email=${modifiedEmail}" style="text-decoration: underline;">Click here to go to the password reset page.</a></p>
          <p style="font-weight: 400; font-size: 14px; line-height: 25px; color: #000000;">If you didn't make this request, you can ignore this email. Please contact your admin if you encounter any issues.</p>
        </div>
      </div>
    </div>
  </body>
</html>
  `
}

const onboardingEmail = (event, params) => {
  if (Object.keys(params).length === 0 ) {
    return {}
  }
  if(event.request.userAttributes['custom:userType'] !== 'USER'){
    return {};
  }
  const body = getOnboardingEmailBody(params);
  return {
    subject: `${params.tenantName} | Temporary login credentials for the CMS`,
    body: body,
  }
}

const resetPasswordEmail = (event, params) => {
  if (Object.keys(params).length === 0 ) {
    return {}
  }
  if(event.request.userAttributes['custom:userType'] !== 'USER'){
    return {};
  }
  const body = getresetPasswordEmailBody(params);
  return {
    subject: `${params.tenantName} | Request for password reset`,
    body: body,
  }
}

const getOnboardingEmailParams = async (event) => {
  try {
    const userName = event.request.userAttributes.name;
    const userId = event.request.usernameParameter;
    const userEmail = event.request.userAttributes.email;
    const tempPassword = event.request.codeParameter;
    const { Client, Pool } = require("pg");
    const DB_TABLES = {
      USERS_TABLE: "saev_user"
    };
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
    const tenantData: any = await client.query(
      `SELECT name, logo FROM ${DB_TABLES.USERS_TABLE} WHERE tenantid = '${event.request.userAttributes['custom:tenantId']}' AND usertype='TENANT'`
    );

    if (!tenantData.rows[0]) {
      return {};
    }
    const tenantLogo = tenantData.rows[0].logo;
    const tenantName = tenantData.rows[0].name;
    return {
        tenantLogo,
        userName,
        tenantName,
        userEmail,
        tempPassword,
        userId
    };
  } catch (err) {
    return {};
  }
}

const getresetPasswordEmailParams = async (event) => {
  try {
    let email = event.request.userAttributes.email;

// Find the index of '+' in the local part
    let plusIndex = email?.indexOf('+user');
    let modifiedEmail;
    if (plusIndex !== -1) {
        // Extract the local part and domain part
        let localPart = email.substring(0, plusIndex);
        let domainPart = email.substring(email?.indexOf('@'));

        // Reconstruct the modified email address
        modifiedEmail = localPart + domainPart;
    } else {
        modifiedEmail = event.request.userAttributes.email;
        console.log("No modifier found in the email");
    }
    const userName = event.request.userAttributes.name;
    const tempPassword = event.request.codeParameter;
    const userEmail = modifiedEmail;
    let { Client, Pool } = require("pg");
    let DB_TABLES = {
      USERS_TABLE: "saev_user"
    };
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
    const tenantData: any = await client.query(
      `SELECT name, logo FROM ${DB_TABLES.USERS_TABLE} WHERE tenantid = '${event.request.userAttributes['custom:tenantId']}' AND usertype = 'TENANT'`
    );

    if (!tenantData.rows[0]) {
      return {};
    }
    const tenantLogo = tenantData.rows[0].logo;
    const tenantName = tenantData.rows[0].name;
    return {
        tenantLogo,
        userName,
        tenantName,
        tempPassword,
        userEmail
    };
  } catch (err) {
    return {};
  }
}

const emailTemplates = {
  CustomMessage_AdminCreateUser: onboardingEmail,
  CustomMessage_ForgotPassword: resetPasswordEmail,
}

const getEmailParams = {
    CustomMessage_AdminCreateUser: getOnboardingEmailParams,
    CustomMessage_ForgotPassword: getresetPasswordEmailParams,
}



exports.handler = async (event, context, callback) => {
  console.log("event", event)

  if (Object.keys(getEmailParams).includes(event.triggerSource)) {
      const params =  await getEmailParams[event.triggerSource](event);
      const { subject, body  } = emailTemplates[event.triggerSource](event, params);
      if(Boolean(subject) && Boolean(body)){
        event.response = {
          emailSubject: subject,
          emailMessage: body
      };
      }
  }
  
  return event;
};

