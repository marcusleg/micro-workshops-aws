// Import the necessary AWS SDK clients for Rekognition and S3 using ES Modules syntax
import { RekognitionClient, DetectLabelsCommand } from "@aws-sdk/client-rekognition";
import { S3Client, CopyObjectCommand } from "@aws-sdk/client-s3";

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
        MaxLabels: 10, // Adjust the maximum number of labels to return
        MinConfidence: 70 // Adjust the confidence level as needed
    };

    try {
        // Call Rekognition to detect labels
        const detectCommand = new DetectLabelsCommand(detectParams);
        const detectResponse = await rekognitionClient.send(detectCommand);

        // Log the detected labels
        console.log("Detected labels: ", JSON.stringify(detectResponse.Labels, null, 2));

        // Convert detected labels to comma-separated values
        const labelsCsv = detectResponse.Labels.map(label => label.Name).join(",");

        // Prepare to update the S3 object metadata with Rekognition labels
        const copyParams = {
            Bucket: bucketName,
            CopySource: encodeURIComponent(bucketName + "/" + objectKey),
            Key: objectKey,
            Metadata: {
                "rekognition-labels": labelsCsv
            },
            MetadataDirective: 'REPLACE' // Instructs S3 to replace the metadata with the new set provided
        };

        // Update S3 object with the new metadata
        const copyCommand = new CopyObjectCommand(copyParams);
        await s3Client.send(copyCommand);

        console.log("S3 object metadata updated successfully with Rekognition labels:", objectKey);
    } catch (error) {
        console.error("Error processing the image: ", error);
        throw error;
    }
};
