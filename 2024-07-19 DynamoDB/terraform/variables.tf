variable "aws_region" {
    default = "eu-central-1"
}

# variable "employees" {
#     type = map(object({
#         ulid = string
#         name = string
#         available_from = string
#         skills = list(string)
#     }))
#     default = {
#             mj = {
#                 ulid           = "01J33CZCCQGP9A1WDFTV0100ER"
#                 name           = "Michael Jackson"
#                 available_from = "2024-07-01"
#                 skills = ["Singing", "Dancing", "Moonwalking"]
#             }
#             al = {
#                 ulid           = "01J33PY153XDMT9YNXNZ5SMF71"
#                 name           = "Alexi Laiho",
#                 available_from = "2024-10-01",
#                 skills = ["Guitar", "Singing", "Composing"]
#             }
#         }
# }