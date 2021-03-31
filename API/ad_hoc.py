import boto3

rds = boto3.client('rds', region_name="ap-southeast-2")


def get_engine_versions(engine):
    engine_versions = []
    response = rds.describe_db_engine_versions(
        Engine=engine)
    for item in response['DBEngineVersions']:
        dict_layout = {'Description': item['DBEngineVersionDescription'],
                       'Version': item['EngineVersion']}
        engine_versions.append(dict_layout)
    return engine_versions


def get_instance_options(engine):
    engine_instance_options = []
    paginator = rds.get_paginator('describe_orderable_db_instance_options')
    page_iterator = paginator.paginate(Engine=engine)
    for page in page_iterator:
        dict_layout = {'Description': page['OrderableDBInstanceOptions'][0]['EngineVersion'],
                       'DBInstanceClass': page['OrderableDBInstanceOptions'][0]['DBInstanceClass']}
        engine_instance_options.append(dict_layout)
    return engine_instance_options


def lambda_handler(event, context):
    if event['query'] == "engine_versions":
        engine_version = get_engine_versions(event['server_edition'])
        return engine_version

    if event['query'] == "instance_options":
        instance_options = get_instance_options(event['server_edition'])
        return instance_options

    return "Invalid RDS Query"