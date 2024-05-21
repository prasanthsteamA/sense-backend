import {
  RequestHandler,
  Router,
  Request,
  Response,
  NextFunction,
} from "express";
import {
  getAllLists,
  getSingleList,
  addList,
  updateList,
  deleteUser,
  createMediaPath,
  searchUserData,
  selectUserData,
  getProfile,
  deactivateUser,
  activateUser,
  getUserPermissions,
} from "./controller";
import constants from "../lib/constants";
import { checkPermissions } from "../permissionAuthMiddleware/utils";
const { USER_MANAGEMENT, CUSTOMER_PROFILE } = constants.permissions;
const {
  userGroupsForPermissionAuth: { ALL, STAFF },
} = constants;

const mediaService: RequestHandler = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  createMediaPath(req)
    .then((data) => {
      res.send(data);
    })
    .catch(next);
};

const listService: RequestHandler = (req: any, res: any, next: any) => {
  getAllLists(req, req.query)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};

const singleService: RequestHandler = (req: any, res: any, next: any) => {
  getSingleList(req.params.id)
    .then((data: any) => {
      if (data) {
        res.send(data);
      } else {
        res.status(404).end();
      }
    })
    .catch(next);
};

const addService: RequestHandler = (req: any, res: any, next: any) => {
  addList(req)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};

const searchUser: RequestHandler = (req: any, res: any, next: any) => {
  searchUserData(req)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};

const selectUser: RequestHandler = (req: any, res: any, next: any) => {
  selectUserData(req)
    .then((data: any) => {
      res.send(data);
    })
    .catch(next);
};

const updateService: RequestHandler = (req: any, res: any, next: any) => {
  updateList(req, res, req.params.id)
    .then((data: any) => {
      if (data) {
        res.send(data);
      } else {
        res.status(404).end();
      }
    })
    .catch(next);
};

const profileService: RequestHandler = (req: any, res: any, next: any) => {
  getProfile(req)
    .then((data: any) => {
      if (data) {
        res.send(data);
      } else {
        res.status(404).end();
      }
    })
    .catch(next);
};

const permissionService: RequestHandler = (req: any, res: any, next: any) => {
  getUserPermissions(req)
    .then((data: any) => {
      if (data) {
        res.send(data);
      } else {
        res.status(404).end();
      }
    })
    .catch(next);
};

const UsersRoute = Router();

UsersRoute.get("/search", searchUser);
UsersRoute.get("/search/select/:id", selectUser);
UsersRoute.patch(
  "/deactivate/:id",
  checkPermissions([CUSTOMER_PROFILE.MODIFY], STAFF),
  deactivateUser
);
UsersRoute.patch(
  "/activate/:id",
  checkPermissions([CUSTOMER_PROFILE.MODIFY], STAFF),
  activateUser
);
UsersRoute.post("/media", mediaService);
UsersRoute.get(
  "/",
  checkPermissions([USER_MANAGEMENT.VIEW], STAFF),
  listService
);
UsersRoute.get("/profile", profileService);
UsersRoute.get("/permissions", permissionService);
UsersRoute.get("/:id", singleService);
UsersRoute.post("/", addService);
UsersRoute.patch(
  "/:id",
  checkPermissions([USER_MANAGEMENT.MODIFY], ALL),
  updateService
);
UsersRoute.delete(
  "/:id",
  checkPermissions([USER_MANAGEMENT.DELETE], STAFF),
  deleteUser
);

export default UsersRoute;
