import AuthRoute from "./auth/router";
import UsersRoute from "./users/router";


export default function setupRoute(app: any) {
  app.use("/api/v1/auth", AuthRoute);
  app.use("/api/v1/users", UsersRoute);
}