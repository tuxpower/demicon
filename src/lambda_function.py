import json
import subprocess
import boto3

s3 = boto3.resource('s3')

def lambda_handler(event, context):
    
    s3.meta.client.download_file('josegaspar-terraform-state', 'terraform.tfstate', '/tmp/terraform.tfstate')
    #sp = subprocess.call(['./terraform', 'output', '-state', '/tmp/terraform.tfstate', event['resource']])
    sp = subprocess.Popen(['./terraform', 'output', '-state', '/tmp/terraform.tfstate', event['resource']], stdout=subprocess.PIPE)
    
    return {
        'message': sp.stdout.readlines() 
    }
