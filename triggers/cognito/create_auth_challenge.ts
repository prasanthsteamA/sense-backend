import { APIGatewayEvent } from 'aws-lambda';

export const handler = async (event: APIGatewayEvent): APIGatewayEvent => {
    if (!event.request.session || event.request.session.length === 0) {
        const OTP: string = process.env.CREATE_AUTH_CHALLENGE_OTP;
        event.response.privateChallengeParameters = {
            answer: OTP,
        };
        event.response.challengeMetadata = "CUSTOM_CHALLENGE";
    }
    return event;
}