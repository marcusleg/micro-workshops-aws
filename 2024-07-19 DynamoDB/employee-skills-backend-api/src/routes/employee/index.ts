import { FastifyPluginAsync } from "fastify";
import employeeSkillsTable from "../../library/dynamodb_client.js";

interface EmployeeBody {
  name: string;
  availableFrom: string;
  skills: string[];
}

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

    if (skill) {
      return await employeeSkillsTable.listEmployeesBySkill(skill);
    }

    throw new Error("Invalid query parameters");
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
    Body: EmployeeBody;
  }>("/", async function (request, reply) {
    const { name, availableFrom, skills } = request.body;
    return await employeeSkillsTable.putEmployee(name, availableFrom, skills);
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
    Body: Partial<EmployeeBody>;
  }>("/:employeeId", async function (request, reply) {
    const { employeeId } = request.params;
    const { name, availableFrom, skills } = request.body;
    return await employeeSkillsTable.updateEmployee(
      employeeId,
      name,
      availableFrom,
      skills,
    );
  });
};

export default employee;
