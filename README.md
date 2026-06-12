# Description

This repository manages the provisioning of AWS Organizational Units (OUs) and accounts using Terragrunt and Terraform.


# Prerequisites

> Manual stuffs needed to do before setting up AWS SSO.

* Go to `IAM Identity Center` service and `Enable` it.
* Enabled trusted access for AWS Account Management service: Via console: Organizations → Services → AWS Account Management → Enable trusted access.
* Create initial IAM user, with `AdministratorAccess` policy.
* Create policy `ForceMFA` and add it to the user also. JSON below:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowViewAccountInfo",
            "Effect": "Allow",
            "Action": [
                "iam:GetAccountPasswordPolicy",
                "iam:GetAccountSummary",
                "iam:ListVirtualMFADevices"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowManageOwnPasswordAndMFA",
            "Effect": "Allow",
            "Action": [
                "iam:ChangePassword",
                "iam:GetUser",
                "iam:CreateLoginProfile",
                "iam:UpdateLoginProfile",
                "iam:CreateVirtualMFADevice",
                "iam:EnableMFADevice",
                "iam:ResyncMFADevice",
                "iam:ListMFADevices",
                "iam:DeactivateMFADevice",
                "iam:DeleteVirtualMFADevice"
            ],
            "Resource": [
                "arn:aws:iam::*:user/${aws:username}",
                "arn:aws:iam::*:mfa/${aws:username}"
            ]
        },
        {
            "Sid": "DenyAllExceptListedIfNoMFA",
            "Effect": "Deny",
            "NotAction": [
                "iam:CreateVirtualMFADevice",
                "iam:EnableMFADevice",
                "iam:GetUser",
                "iam:ListMFADevices",
                "iam:ListVirtualMFADevices",
                "iam:ResyncMFADevice",
                "iam:ChangePassword",
                "iam:CreateLoginProfile",
                "iam:UpdateLoginProfile",
                "iam:GetAccountPasswordPolicy",
                "iam:GetAccountSummary",
                "sts:GetSessionToken"
            ],
            "Resource": "*",
            "Condition": {
                "BoolIfExists": {
                    "aws:MultiFactorAuthPresent": "false"
                }
            }
        }
    ]
}
```

* Generate keys on that `user` to use for applying `terragrunt` files.
* Login on the `user` and add `MFA`.

    - Click your account name / username in the top-right corner of the console
    - Select Security credentials
    - Scroll to Multi-factor authentication (MFA) and click Assign MFA device

* Should work as usual now, else do logout then relogin.