# Karpenter Interruption Queue
resource "aws_sqs_queue" "karpenter" {
  name = "${var.name}-karpenter"

  message_retention_seconds = 300
  sqs_managed_sse_enabled  = true
}

resource "aws_sqs_queue_policy" "karpenter" {
  queue_url = aws_sqs_queue.karpenter.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2InterruptionPolicy"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
          AWS     = "*"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter.arn
      }
    ]
  })
}
