resource "aws_apigatewayv2_api" "websocket_api" {
  name          = "your-websocket-api"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_route" "connect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "disconnect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.websocket_lambda.invoke_arn
}

resource "aws_lambda_function" "websocket_lambda" {
  function_name = "your-websocket-lambda"
  handler       = "your_lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec.arn

  filename = "lambda_package.zip"
  
  environment {
    variables = {
      KAFKA_BOOTSTRAP_SERVERS = "your_kafka_bootstrap_servers"
      KAFKA_TOPIC             = "your_kafka_topic"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "your-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_permission" "apigw_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*/*"
}



