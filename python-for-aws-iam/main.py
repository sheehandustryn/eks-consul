#! /usr/bin/env python3

import argparse
import boto3
import configparser
import json
import logging
import sys
import textwrap
import time


def attach_managed_policy(role_name: str, managed_policy_arn: str) -> None:
    """Attach the specified AWS Managed Policy to the specified AWS IAM Role

    Args:
        role_name (string): The name of the role to which the managed policy
            should be attached.
        managed_policy_arn (string): The ARN of the AWS IAM Managed Policy
            that should be attached.
    """
    try:
        IAM.attach_role_policy(
            PolicyArn=managed_policy_arn,
            RoleName=role_name
        )
    except Exception as e:
        logging.error(
            f"Unable to attach managed role policy. Exception: {e}"
        )
        raise


def create_and_attach_terraform_required_perms_policy(role_name: str) -> None:
    """Create an IAM policy with the permissions required for
       terragrunt/terraform operations and attach them to the specified role.

    Args:
        role_name (string): Name of the IAM Role to which the created policy
        should be attached.
    """
    terraform_policy = {
        'Version': '2012-10-17',
        'Statement': [
            {
                'Resource': '*',
                'Effect': 'Allow',
                'Action': [
                    'dynamodb:*',
                    'ec2:*',
                    'ecr:*',
                    'eks:*',
                    'iam:*',
                    'logs:*',
                    'kms:*',
                    's3:*'
                ]
            }
        ]
    }

    try:
        response = IAM.create_policy(
            PolicyName='terraform_policy',
            PolicyDocument=json.dumps(terraform_policy),
            Description='Permissions required for terraform operations'
        )
    except Exception as e:
        logging.error(f"Could not create terraform policy. Exception: {e}")
    else:
        attach_managed_policy(
            role_name=role_name,
            managed_policy_arn=response['Policy']['Arn']
        )


def create_key(user_name: str) -> dict:
    try:
        key = IAM.create_access_key(UserName=user_name)
        logging.info(
            f"""
            Created access key pair for {user_name}.
            Key ID is {key['AccessKey']['AccessKeyId']}
            """
        )
    except Exception as e:
        logging.error(
            f"Couldn't create key pair for user {user_name}. Exception: {e}"
        )
        raise
    else:
        return key


def create_role(role_name: str, user_name: str) -> dict:
    try:
        role = IAM.get_role(RoleName=role_name)
    except Exception:
        user_arn = IAM.get_user(UserName=user_name)
        logging.info(f"User Arn: {user_arn['User']['Arn']}")
        trust_policy = {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Effect': 'Allow',
                    'Principal': {'AWS': user_arn['User']['Arn']},
                    'Action': 'sts:AssumeRole'
                }
            ]
        }
        try:
            role = IAM.create_role(
                RoleName=role_name,
                AssumeRolePolicyDocument=json.dumps(trust_policy)
            )
        except Exception as e:
            logging.error(f"Unable to create role. Exception: {e}")
            raise
        else:
            logging.info(f"Role Arn: {role['Role']['Arn']}")
            return role
    else:
        logging.info(f"Role Arn: {role['Role']['Arn']}")
        return role


def create_user(user_name: str) -> dict:
    try:
        user = IAM.get_user(UserName=user_name)
    except Exception:
        try:
            user = IAM.create_user(UserName=user_name)
        except Exception as e:
            logging.error(f"Couldn't create user. Exception: {e}")
            raise
        else:
            return user
    else:
        return user


def update_aws_cli_config(
    config_file_path: str,
    user_name: str
) -> None:
    parser = configparser.ConfigParser()

    try:
        parser.read(config_file_path)
    except Exception as e:
        logging.error(
            f"Couldn't read file {config_file_path}. Exception: {e}"
        )
        raise
    else:
        parser.add_section(f"profile {user_name}")
        parser.set(
            section=f"profile {user_name}",
            option="region",
            value="us-east-1"
        )
        parser.set(
            section=f"profile {user_name}",
            option="output",
            value="json"
        )

        try:
            with open(config_file_path, "w") as configFile:
                parser.write(configFile)
        except Exception as e:
            logging.error(
                f"Couldn't write to file {config_file_path}. Exception: {e}"
            )
            raise


def update_aws_cli_credentials(
    access_key: dict,
    credentials_file_path: str,
    user_name: str
) -> None:
    parser = configparser.ConfigParser()

    try:
        parser.read(credentials_file_path)
    except Exception as e:
        logging.error(
            f"Couldn't read file {credentials_file_path}." +
            f"Exception: {e}"
        )
        raise
    else:
        parser.add_section(user_name)
        parser.set(
            section=user_name,
            option="aws_access_key_id",
            value=access_key['AccessKey']['AccessKeyId']
        )
        parser.set(
            section=user_name,
            option="aws_secret_access_key",
            value=access_key['AccessKey']['SecretAccessKey']
        )

        try:
            with open(credentials_file_path, "w") as credentialsFile:
                parser.write(credentialsFile)
        except Exception as e:
            logging.error(
                f"Couldn't write to file {credentials_file_path}." +
                f"Exception: {e}"
            )
            raise


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Create initial AWS IAM Resources",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent('Examples: Examples to follow...')
    )

    parser.add_argument(
        "-e",
        "--environment",
        help="""
        The name of the environment in which resources are being created. e.g. dev, staging, or prod.
        """
    )


    parser.add_argument(
        "-r",
        "--role-name",
        help="""
        The name to use for the IAM role to be created.
        """
    )

    parser.add_argument(
        "-u",
        "--user-name",
        help="""
        The name to use for the IAM User to be created.
        """
    )

    parser.add_argument(
        "--aws-config-file",
        help="""
        Path to your AWS CLI config file
        """
    )

    parser.add_argument(
        "--aws-credentials-file",
        help="""
        Path to your AWS CLI credentials file
        """
    )

    args = parser.parse_args()

    format = "%(asctime)s: %(message)s"
    logging.basicConfig(format=format, level=logging.INFO, datefmt="%H:%M:%S")

    try:
        IAM = boto3.client('iam')
    except Exception as e:
        logging.error(
            f"Unable to instantiate boto3 client for iam. Exception: {e}")
        sys.exit(1)

    logging.info("Create IAM User")
    try:
        iam_user = create_user(user_name=f"{args.user_name}-{args.environment}")
    except Exception:
        sys.exit(1)

    logging.info("Creating Access Key Pair for IAM User")
    try:
        access_key = create_key(user_name=f"{args.user_name}-{args.environment}")
    except Exception:
        sys.exit(1)

    logging.info("Updating AWS CLI Config file")
    try:
        update_aws_cli_config(
            config_file_path=args.aws_config_file,
            user_name=f"{args.user_name}-{args.environment}"
        )
    except Exception:
        sys.exit(1)

    logging.info("Updating AWS CLI Credentials file")
    try:
        update_aws_cli_credentials(
            access_key=access_key,
            credentials_file_path=args.aws_credentials_file,
            user_name=f"{args.user_name}-{args.environment}"
        )
    except Exception:
        sys.exit(1)

    time.sleep(180)
    logging.info('Creating eks_user_role')
    try:
        eks_role = create_role(
            role_name=args.role_name,
            user_name=f"{args.user_name}-{args.environment}"
        )
    except Exception:
        sys.exit(1)

    logging.info("Attaching IAM Policy for EKS to eks_user_role")
    try:
        attach_managed_policy(
            eks_role['Role']['RoleName'],
            "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
        )
    except Exception:
        sys.exit(1)

    logging.info("Creating terraform policy")
    try:
        create_and_attach_terraform_required_perms_policy(
            role_name=eks_role['Role']['RoleName']
        )
    except Exception:
        sys.exit(1)

    logging.info("Execution successful")
    sys.exit(0)
