import { FastifyPluginAsync } from "fastify";
import employeeSkillsTable from "../../library/dynamodb_client.js";

const employee: FastifyPluginAsync = async (fastify, opts): Promise<void> => {
  fastify.get("/", async function (request, reply) {
    return await employeeSkillsTable.listEmployees();
  });

  fastify.get<{
    Querystring: {
      availableFrom?: string;
      skill?: string;
    };
  }>("/search", async function (request, reply) {
    const { availableFrom, skill } = request.query;

    if (!availableFrom && !skill) {
      throw new Error(
        "Either 'availableFrom' or 'skill' query parameter is required",
      );
    }

    if (availableFrom && skill) {
      return await employeeSkillsTable.listEmployeesBySkillAndAvailableFrom(
        skill,
        availableFrom,
      );
    }

    if (availableFrom) {
      return await employeeSkillsTable.listEmployeesByAvailableFrom(
        availableFrom,
      );
    }

    return await employeeSkillsTable.listEmployeesBySkill(skill);
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
