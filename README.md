1 Target Architecture
arduino
Copy
Edit
┌────────────┐          PUT event          ┌──────────────┐
│  S3 Bucket │ ───────────────────────────▶│   AWS Lambda │
│   uploads/ │ (ObjectCreated:* trigger)   │  image-resize │
└────────────┘                              └─────┬────────┘
                                                  │
                                    write resized │ image
                                                  ▼
                                         ┌────────────┐
                                         │  S3 Bucket │
                                         │ resized/   │
                                         └─────┬──────┘
                                               │publish
                                               ▼
                                        ┌────────────┐
                                        │   SNS      │
                                        │  Topic     │
                                        └─────┬──────┘
                            email/SMS/HTTP │ notifications
                                           ▼
                                   Stakeholders
Event driven & serverless – scales automatically with object upload rate.

No instances to manage – pay only for Lambda invocations, S3 storage/requests, and SNS messages.

Least-privilege IAM – one role for Lambda with the minimum S3 GetObject/PutObject and SNS:Publish actions.

Observability – CloudWatch Logs for the function, CloudWatch metrics/alarms for failures or throttling.

2 Target Technology Stack
Layer	Choice	Notes
Storage	Amazon S3 (Standard or Intelligent-Tiering)	Source & destination buckets with versioning turned on for rollback.
Compute	AWS Lambda (Python 3.12 runtime)	Uses Pillow to resize, concurrency = “On-Demand” (scale to zero).
Messaging	Amazon SNS	Email, SMS or webhook subscribers.
IaC	Terraform ≥ 1.6 + AWS provider ≥ 5.0	Remote backend in S3 with DynamoDB state locking.
CI	GitHub Actions	Lints, validates, plans before manual approval to apply.
Security & Quality	TFLint + tfsec (optional)	Static analysis in the workflow.

