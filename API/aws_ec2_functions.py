import boto3


def describe_subnets(vpc_id):
    response = ec2.describe_subnets(
        Filters=[
            {
                'Name': "vpc-id",
                "Values": [vpc_id]
            }
        ]
    )
    return response


# Enter AWS credentials if not using saml
aws_access_key_id = ""
aws_secret_access_key = ""
aws_session_token = ""

session = boto3.Session(
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    aws_session_token=aws_session_token
)

# OR if using saml:
#session = boto3.session.Session(profile_name='saml')


# Initiate boto3 session
ec2 = session.client('ec2', region_name="ap-southeast-2")
vpc_info = []


# Enter VPC ID to show all subnets
vpc_id = "vpc-32bed556"
response = describe_subnets(vpc_id)

for item in response['Subnets']:
    subnetId = item['SubnetId']
    for tag in item['Tags']:
        if tag['Key'] == 'Name':
            name = tag['Value']
            dict_layout = {'name': name, 'subnetId': subnetId}
            vpc_info.append(dict_layout)

print(vpc_info)
