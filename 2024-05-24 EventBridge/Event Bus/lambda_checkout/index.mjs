import {EventBridgeClient, PutEventsCommand} from '@aws-sdk/client-eventbridge';

const client = new EventBridgeClient();

export const handler = async (event) => {
    const params = {
        Entries: [
            {
                EventBusName: process.env.EVENT_BUS_NAME,
                Source: 'com.example.shop',
                DetailType: 'CustomEvent',
                Detail: event.body
            }
        ]
    };

    try {
        const command = new PutEventsCommand(params);
        const result = await client.send(command);
        console.log('Event sent successfully:', result);
        return {
            statusCode: 200,
            body: JSON.stringify('Checkout successful.')
        };
    } catch (error) {
        console.error('Error sending event:', error);
        return {
            statusCode: 500,
            body: JSON.stringify('Error checkout failed.')
        };
    }
};
