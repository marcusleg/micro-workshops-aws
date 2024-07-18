import { FastifyPluginAsync } from "fastify";
import employeeSkillsTable from "../../library/dynamodb_client.js";

const employee: FastifyPluginAsync = async (fastify, opts): Promise<void> => {
  fastify.get("/", async function (request, reply) {
    return await employeeSkillsTable.listEmployees();
  });

  fastify.get<{
    Params: {
      employeeId: string;
    };
  }>("/:employeeId", async function (request, reply) {
    const { employeeId } = request.params;
    return await employeeSkillsTable.getEmployeeById(employeeId);
  });

  fastify.post<{
    Body: {
      name: string;
    };
  }>("/", async function (request, reply) {
    const { name } = request.body;
    return await employeeSkillsTable.putEmployee(name);
  });

  fastify.delete<{
    Params: {
      employeeId: string;
    };
  }>("/:employeeId", async function (request, reply) {
    const { employeeId } = request.params;
    return await employeeSkillsTable.deleteEmployee(employeeId);
  });

  fastify.put<{
    Params: {
      employeeId: string;
    };
    Body: {
      skill: string;
    };
  }>("/:employeeId/skill", async function (request, reply) {
    const { employeeId } = request.params;
    const { skill } = request.body;
    return await employeeSkillsTable.addSkillToEmployee(employeeId, skill);
  });

  fastify.delete<{
    Params: {
      employeeId: string;
      skill: string;
    };
  }>("/:employeeId/skill/:skill", async function (request, reply) {
    const { employeeId, skill } = request.params;
    return await employeeSkillsTable.deleteSkillFromEmployee(employeeId, skill);
  });
};

export default employee;
