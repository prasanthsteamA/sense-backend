import parse from "../lib/parse";

export const getValidDocumentOtp = (data: any) => {
  if (Object.keys(data).length === 0) {
    throw new Error("Required fields are missing");
  }

  let items: any = {};

  if (data.phone !== undefined) {
    items.phone = parse.getString(data.phone);
  } else {
    throw new Error("Phone field is required");
  }

  if (data.tenantid !== undefined) {
    items.tenantId = parse.getString(data.tenantid);
  } else {
    throw new Error("tenantId field is required");
  }
  // Below signature used to check auto fill in Client side(Mobile)
  if (data.signature !== undefined) {
    items.signature = parse.getString(data.signature);
  } else {
    items.signature = null;
  }

  return items;
};

export const getValidDocumentVerify = (data: any) => {
  if (Object.keys(data).length === 0) {
    throw new Error("Required fields are missing");
  }

  let items: any = {};

  if (data.phone !== undefined) {
    items.phone = parse.getString(data.phone);
  } else {
    throw new Error("phone is required");
  }

  if (data.tenantid !== undefined) {
    items.tenantId = parse.getString(data.tenantid);
  } else {
    throw new Error("tenantId is required");
  }

  if (data.otp !== undefined) {
    items.otp = parse.getString(data.otp);
  } else {
    throw new Error("OTP is required");
  }

  return items;
};
