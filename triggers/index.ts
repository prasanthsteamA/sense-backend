import { APIGatewayEvent } from 'aws-lambda';
import axios, * as others from 'axios';
exports.handler = async  (event: APIGatewayEvent): APIGatewayEvent => {
    const resp = await axios({
        method: 'post',
        url: `${process.env.ANALYTICS_URL}`,
        data: {}
      });
    console.log("resp",resp);
    return 'success';
};