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

const deleteEmployeeById = async (employeeId: string) => {
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

const getEmployeeById = async (employeeId: string) => {
  // TODO
  return { name: "TODO", availableFrom: "1970-01-01", skills: [] };
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

const listEmployeesByAvailableFrom = async (availableFrom: string) => {
  // TODO
  return [];
};

const listEmployeesBySkill = async (skill: string) => {
  // TODO
  return [];
};

const listEmployeesBySkillAndAvailableFrom = async (
  skill: string,
  availableFrom: string,
) => {
  // TODO
  return [];
};

const putEmployee = async (
  name: string,
  availableFrom: string,
  skills: string[],
) => {
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

  // TODO implement putCommands for 'skills' and 'available from' data

  return getEmployeeById(employeeId);
};

const updateEmployee = async (
  employeeId: string,
  name?: string,
  availableFrom?: string,
  skills?: string[],
) => {
  // TODO
  return;
};

const employeeSkillsTable = {
  deleteEmployee: deleteEmployeeById,
  getEmployeeById,
  listEmployees,
  listEmployeesByAvailableFrom,
  listEmployeesBySkill,
  listEmployeesBySkillAndAvailableFrom,
  putEmployee,
  updateEmployee,
};

export default employeeSkillsTable;
