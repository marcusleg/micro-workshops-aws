import { LambdaFunctionURLEvent } from 'aws-lambda';

export const handler = async (event: LambdaFunctionURLEvent) => {
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      message: 'Hello from Lambda',
      request: {
        headers: event.headers,
        path: event.rawPath,
        queryStringParameters: event.queryStringParameters
      }
    }),
  };
};
