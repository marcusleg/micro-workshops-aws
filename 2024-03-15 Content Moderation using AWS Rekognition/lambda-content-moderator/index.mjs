// Import the necessary AWS SDK clients for Rekognition and S3 using ES Modules syntax
import { RekognitionClient, DetectModerationLabelsCommand } from "@aws-sdk/client-rekognition";
import { S3Client, DeleteObjectCommand } from "@aws-sdk/client-s3";

const rekognitionClient = new RekognitionClient({});
const s3Client = new S3Client({});

export const handler = async (event) => {
    // Log the event
    console.log("Event: ", JSON.stringify(event, null, 2));

    // Get the S3 object details from the event
    const bucketName = event.Records[0].s3.bucket.name;
    const objectKey = event.Records[0].s3.object.key;

    // Parameters for detecting labels in an image
    const detectParams = {
        Image: {
            S3Object: {
                Bucket: bucketName,
                Name: objectKey
            }
        },
        MinConfidence: 70 // Adjust the confidence level as needed
    };

    try {
        // Call Rekognition to detect moderation labels
        const detectCommand = new DetectModerationLabelsCommand(detectParams);
        const detectResponse = await rekognitionClient.send(detectCommand);

        // Log the detected moderation labels
        console.log("Detected moderation labels: ", JSON.stringify(detectResponse.ModerationLabels, null, 2));

        // Check if inappropriate content was detected
        if (detectResponse.ModerationLabels && detectResponse.ModerationLabels.length > 0) {
            console.log("Inappropriate content detected, deleting image:", objectKey);

            // Prepare and send a delete object command to S3
            const deleteParams = { Bucket: bucketName, Key: objectKey };
            const deleteCommand = new DeleteObjectCommand(deleteParams);
            await s3Client.send(deleteCommand);

            console.log("Image deleted successfully:", objectKey);
        } else {
            console.log("No inappropriate content detected in image:", objectKey);
        }
    } catch (error) {
        console.error("Error processing the image: ", error);
        throw error;
    }
};
