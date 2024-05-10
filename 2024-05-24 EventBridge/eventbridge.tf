resource "aws_cloudwatch_event_bus" "car_analytics" {
  name = "${local.workshop_prefix}-car-analytics"
}

resource "aws_schemas_registry" "car_analytics" {
  name = "${local.workshop_prefix}-car-analytics"
}

resource "aws_schemas_schema" "car_telemetry" {
  name          = "car-telemetry"
  registry_name = aws_schemas_registry.car_analytics.name
  type          = "OpenApi3"
  description   = "The schema definition for my event"

  content = jsonencode({
    "openapi" : "3.0.0",
    "info" : {
      "version" : "1.0.0",
      "title" : "Event"
    },
    "paths" : {},
    "components" : {
      "schemas" : {
        "Event" : {
          "type" : "object",
          "properties" : {
            "mileage" : {
              "type" : "number"
            },
            "lastService" : {
              "type" : "object",
              "properties" : {
                "date" : {
                  "type" : "string",
                  "format" : "date-time"
                },
                "mileage" : {
                  "type" : "number"
                }
              }
            },
          }
        }
      }
    }
  })
}