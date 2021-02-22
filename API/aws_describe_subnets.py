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


# Initiate boto3 session
session = boto3.session.Session(profile_name='saml')
ec2 = session.client('ec2', region_name="ap-southeast-2")
vpc_info = []

vpc_id = ""
response = describe_subnets(vpc_id)

for item in response['Subnets']:
    subnetId = item['SubnetId']
    for tag in item['Tags']:
        if tag['Key'] == 'Name':
            name = tag['Value']
            dict_layout = {'name': name, 'subnetId': subnetId}
            vpc_info.append(dict_layout)

print(vpc_info)
