#!/usr/bin/env bash
aws sqs receive-message --queue-url `tofu output -raw queue_url`