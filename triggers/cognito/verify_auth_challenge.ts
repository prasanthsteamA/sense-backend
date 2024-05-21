import { Context, APIGatewayEvent } from 'aws-lambda';

export const handler = (event: APIGatewayEvent, context: Context): void => {
    if (event.request.privateChallengeParameters.answer === event.request.challengeAnswer) {
        event.response.answerCorrect = true;
    } else {
        event.response.answerCorrect = false;
    }
    context.done(null, event);
}