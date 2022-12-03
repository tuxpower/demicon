import json
import subprocess
import boto3

s3 = boto3.resource('s3')

def lambda_handler(event, context):
    
    s3.meta.client.download_file(event['bucket'], event['tfstate'], '/tmp/terraform.tfstate')
    sp = subprocess.Popen(['./terraform', 'output', '-state', '/tmp/terraform.tfstate', event['resource']], stdout=subprocess.PIPE)
    
    return {
        'message': sp.stdout.readlines() 
    }
