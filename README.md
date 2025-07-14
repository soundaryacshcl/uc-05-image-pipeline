# Automated Image Resizing & Transfer on AWS

## 1&nbsp;· Target Architecture

```text
┌────────────┐          PUT event          ┌──────────────┐
│  S3 Bucket │ ───────────────────────────▶│   AWS Lambda │
│   uploads/ │ (ObjectCreated:* trigger)   │ image-resize │
└────────────┘                              └─────┬────────┘
                                                  │
                                    write resized │ image
                                                  ▼
                                         ┌────────────┐
                                         │  S3 Bucket │
                                         │  resized/  │
                                         └─────┬──────┘
                                               │ publish
                                               ▼
                                        ┌────────────┐
                                        │    SNS     │
                                        │   Topic    │
                                        └─────┬──────┘
                            email/SMS/HTTP │ notifications
                                           ▼
                                       Stakeholders

Why this architecture?
Event driven & serverless – scales automatically with the object-upload rate.

Zero servers to manage – you pay only for Lambda invocations, S3 storage/requests, and SNS messages.

Least-privilege IAM – a single role for Lambda with the minimum s3:GetObject, s3:PutObject, and sns:Publish actions.

Observability – CloudWatch Logs for the function plus CloudWatch metrics/alarms for failures or throttling.

2 · Target Technology Stack
Layer	Choice	Notes
Storage	Amazon S3 (Standard or Intelligent-Tiering)	Source & destination buckets; versioning on for rollback
Compute	AWS Lambda (Python 3.12 runtime)	Uses Pillow to resize; concurrency = “On-Demand” (scale to zero)
Messaging	Amazon SNS	Email, SMS, or webhook subscribers
IaC	Terraform ≥ 1.6 + AWS provider ≥ 5.0	Remote backend in S3 with DynamoDB state locking
CI	GitHub Actions	Lints, validates, and plans before manual approval to apply
Security & Quality	TFLint + tfsec (optional)	Static analysis in the workflow
