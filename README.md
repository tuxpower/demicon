## Requirements

- existing S3 bucket and DynamoDB table for storing terraform state and enable terraform locking

## Testing

Assuming you have already setup all required AWS credentials, you can test the lambda function with the following command and payload:

```
aws lambda invoke --cli-binary-format raw-in-base64-out --function-name demicon --payload '{ "resource": "" }' response.jon
```

In this case `response.json` will contain all the outputs from terraform since no resource name was provided in the payload:

```
{"message": ["alb_id = \"arn:aws:elasticloadbalancing:eu-west-1:510200864357:loadbalancer/app/my-alb/538c9c639803a5c3\"\n", "alb_name = \"my-alb-55784350.eu-west-1.elb.amazonaws.com\"\n", "lambda_function_arn = \"arn:aws:lambda:eu-west-1:510200864357:function:demicon\"\n"]}
```

The lambda function also accepts the name of a given terraform output to be printed out. In this example we want the name of a ALB:

```
aws lambda invoke --cli-binary-format raw-in-base64-out --function-name demicon --payload '{ "resource": "alb_name" }' response.jon
```

Response:

```
{"message": ["\"my-alb-55784350.eu-west-1.elb.amazonaws.com\"\n"]}
```
