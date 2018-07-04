## hiera-awssm: Hiera AWS Secrets Manager Backend

### Overview

Allows Puppet to read string secrets from [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/). Supports returning secrets wrapped with Sensitive() to force proper handling.

### Requirements

* Hiera 5 (Puppet 4.9+)
* AWS Instance Profile allowing secretsmanager:GetSecretValue. 

Environment variables likely also work, but are untested and not recommended.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:*:*:secret:puppet_secrets/*"
        }
    ]
}
```
* aws-sdk-secretsmanager gem installed in Puppet JRuby environment

```bash
puppetserver gem install aws-sdk-secretsmanager
```

or, with Puppet:

```
package { 'aws-sdk-secretsmanager':
  ensure   => 'installed',
  provider => 'puppet_gem'
}
```

### Installation

Install the module in your environment. The Hiera function will be created by Puppet.

### Configuration

```yaml
- name: "AWS Secrets Manager"
  lookup_key: "hiera_awssm"
  options:
    confine_to_keys:
      - "^puppet_secrets/.*"
    proxy_uri: "http://myproxy:8080"
    region: "us-east-1"
    sensitive: true
```

`name` Required: Anything you want. :)

`lookup_key` Required: Must be hiera_awssm.

`region` Required: AWS region for Secrets Manager.

`sensitive`: Required: Set to true to return secrets wrapped in Sensitive()

`confine_to_keys` Optional: Only lookup keys matching list of regexes for efficiency.

`proxy_uri` Optional: Proxy URI for accessing AWS API.

