import * as express from "express";
import * as cors from "cors";
import * as winston from "winston";
import * as expressWinston from "express-winston";
import { sendResponse } from "./src/lib/security";
import { } from "./src/lib/common_modules";
import setupRoute from "./src/setupRoute";
import configs from "./src/settings";
const serverless = require("serverless-http");
const app = express();

// Configure Winston logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
  ],
});

app.use(
  cors({
    origin: "*",
  })
);
app.use(express.json({limit: '10mb'}));
app.use(express.urlencoded({ limit: '10mb', extended: false }));
// Logging middleware using express-winston
app.use(expressWinston.logger({
  winstonInstance: logger,
  meta: true, // Log metadata (default true)
  msg: "HTTP {{req.method}} {{req.url}}",
  expressFormat: true,
  colorize: false, // Disable colorization of logs (default false)
}));

// Custom middleware for additional logging
app.use((req, res, next) => {
  const { body, url, params, query } = req;
  logger.info("Request Log:", { body, url, params, query });
  next();
});

// Override res.send to log the response before sending
app.use((req, res, next) => {
  const originalSend: express.Response['send'] = res.send.bind(res);
  res.send = function (body): express.Response {
    logger.info("Response Log:", body);
    return originalSend(body);
  };
  next();
});


app.get("/", async (req, res, next) => {
  res.status(200).send("Hello World!");
  logger.info("hello world.....");
});

// Setup routes
setupRoute(app);
app.use(sendResponse);

if (process.env.NODE_ENV === "dev" || process.env.NODE_ENV === "staging") {
  app.listen(configs.apiListenPort, () => {
    logger.info(`Application Running on PORT ${configs.apiListenPort}`);
  });
}
module.exports.server = serverless(app);
