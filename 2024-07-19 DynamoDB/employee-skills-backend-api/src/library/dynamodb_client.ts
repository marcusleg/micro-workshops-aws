import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DeleteCommand,
  DynamoDBDocumentClient,
  PutCommand,
  QueryCommand,
} from "@aws-sdk/lib-dynamodb";
import { DYNAMODB_SK_PK_INDEX_NAME, DYNAMODB_TABLE_NAME } from "../config.js";
import { ulid } from "ulid";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const addSkillToEmployee = async (employeeId: string, skill: string) => {
  // TODO
  return;
};

const deleteEmployee = async (employeeId: string) => {
  const command = new DeleteCommand({
    TableName: DYNAMODB_TABLE_NAME,
    Key: {
      PK: `EMPLOYEE#${employeeId}`,
      SK: "METADATA",
    },
  });
  await docClient.send(command);

  // TODO delete 'skills' and 'available from' data
};

const deleteSkillFromEmployee = async (employeeId: string, skill: string) => {
  // TODO
  return;
};

const getEmployeeById = async (employeeId: string) => {
  // TODO
  return { metadata: {}, skills: [] };
};

const listEmployees = async () => {
  const command = new QueryCommand({
    TableName: DYNAMODB_TABLE_NAME,
    IndexName: DYNAMODB_SK_PK_INDEX_NAME,
    KeyConditions: {
      SK: {
        ComparisonOperator: "EQ",
        AttributeValueList: ["METADATA"],
      },
      PK: {
        ComparisonOperator: "BEGINS_WITH",
        AttributeValueList: ["EMPLOYEE#"],
      },
    },
    AttributesToGet: ["PK", "Name"],
  });

  const response = await docClient.send(command);
  return response.Items;
};

const putEmployee = async (name: string) => {
  const employeeId = ulid();
  const command = new PutCommand({
    TableName: DYNAMODB_TABLE_NAME,
    Item: {
      PK: `EMPLOYEE#${employeeId}`,
      SK: "METADATA",
      Name: name,
    },
  });
  await docClient.send(command);

  return getEmployeeById(employeeId);
};

const employeeSkillsTable = {
  addSkillToEmployee,
  deleteEmployee,
  deleteSkillFromEmployee,
  getEmployeeById,
  listEmployees,
  putEmployee,
};

export default employeeSkillsTable;
