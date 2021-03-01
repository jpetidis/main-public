import boto3
import botocore

def describe_db_instances(db_instance=None):
    if db_instance:
        try:
            response = rds.describe_db_instances(
                DBInstanceIdentifier=db_instance
            )
            return response
        except botocore.exceptions.ClientError:
            return None
    else:
        response = rds.describe_db_instances()
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
session = boto3.session.Session(profile_name='saml')


# Initiate boto3 session
rds = session.client('rds', region_name="ap-southeast-2")
db_instances = []

# Get all RDS DBInstance names to avoid mulitple API calls
response = describe_db_instances()
for item in response['DBInstances']:
    db_instances.append(item['DBInstanceIdentifier'])
print(db_instances)


# Find free hostname - confirm against AWS API
hostname = "tawsdsql"
arbitrary_max_number = 999
for i in range(1, arbitrary_max_number):
    temp_name = f"{hostname}{'0'*(len(str(arbitrary_max_number))-len(str(i)))}{i}"

    if temp_name not in db_instances:
        # Confirm db_instance name is free (AWS API call)
        response = describe_db_instances(db_instance=temp_name)
        if response:
            print("DBInstance '" + temp_name + "' exists " + str(response))
        else:
            print("Free Hostname is " + temp_name)
            break
    else:
        continue

