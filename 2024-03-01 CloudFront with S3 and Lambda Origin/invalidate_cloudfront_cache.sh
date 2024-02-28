#!/usr/bin/env bash
aws cloudfront create-invalidation --distribution-id $(terraform output -raw cloudfront_id) --paths "/*"