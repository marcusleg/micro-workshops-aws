interface ApiGatewayEvent {
  resource: string;
  path: string;
  httpMethod: string;
  requestContent: unknown;
  headers: Record<string, string>;
  multiValueHeaders: Record<string, string[]>;
  body?: string;
  isBase64Encoded: boolean;
}

export const handler = async (event: ApiGatewayEvent) => {
  console.log(event);
  return {
    statusCode: 200,
    body: "Hello World",
  };
};
