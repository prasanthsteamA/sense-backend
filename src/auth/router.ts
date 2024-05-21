import { RequestHandler, Router } from "express";
import { verifyBodyToken } from "../lib/security";
import {
  createOtp,
  usr_pass_login,
  verifyOtp,
  customer_signup,
  reset_password,
  confirm_reset_password,
  check_password,
  change_password,
  exchange_refresh_token,
  logoutAllDeviceWithOtpVerify,
  logoutAllDeviceWithOtp,
  verifyCustomerEmail,
  getUser
} from "./controller";

const AuthRoute = Router();

const otpService: RequestHandler = (req: any, res: any, next: any) => {
  createOtp(req.body)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};
const verifyService: RequestHandler = (req: any, res: any, next: any) => {
  verifyOtp(req.body)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};
const logoutAllDeviceWithOtpService: RequestHandler = (
  req: any,
  res: any,
  next: any
) => {
  logoutAllDeviceWithOtp(req)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};
const logoutAllDeviceWithOtpVerifyService: RequestHandler = (
  req: any,
  res: any,
  next: any
) => {
  logoutAllDeviceWithOtpVerify(req)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};

const verifyCustomerEmailThroughMail: RequestHandler = (
  req: any,
  res: any,
  next: any
) => {
  verifyCustomerEmail(req)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};

const checkUserExist: RequestHandler = (req: any, res: any, next: any) => {
  getUser(req)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};

AuthRoute.post("/refresh-token", exchange_refresh_token);
AuthRoute.post("/login", usr_pass_login);
AuthRoute.post("/reset-password", reset_password);
AuthRoute.post("/confirm-reset-password", confirm_reset_password);
AuthRoute.post(
  "/check-password",
  verifyBodyToken.bind(this, true),
  check_password
);
AuthRoute.post(
  "/change-password",
  verifyBodyToken.bind(this, true),
  change_password
);
AuthRoute.post("/signup", customer_signup);
AuthRoute.post("/otp", otpService);
AuthRoute.post("/otp/verify", verifyService);
AuthRoute.post("/logout-all-device/otp", logoutAllDeviceWithOtpService);
AuthRoute.post(
  "/logout-all-device/otp/verify",
  logoutAllDeviceWithOtpVerifyService
);

// Below End point used to verify their email from their email box with proper token.
AuthRoute.get("/email/verify/:verify_token", verifyCustomerEmailThroughMail);
AuthRoute.get("/check-user", checkUserExist );


export default AuthRoute;
