## Overview
This repo maintains deployment code and configuration for the fmm projects.

The folder structure for this project is initially based on [a multi-account approach to Terraform](http://www.antonbabenko.com/2016/09/21/how-i-structure-terraform-configurations.html).

We are planning to use remote state storage in S3 for locking and accounting.

## Dependencies
To use this repo, you need to have following dependencies installed

- ssh-keygen
- cryptography lib for Python

Please run the `setup.sh` script to install your python dependencies


## Directory Structure
Since we're deploying into five AWS accounts and several shards within each account, a 3-tier directory structure as follows minimizes ctrl+c / ctrl-v.
```
└── terraform
    ├── aws
    │   └── <aws account>
    │       └── <stack_folder>
    │           ├── terraform.tfvars
    │           ├── <symbolic links to functional group .tf files>
    │           └── <other shard specific files>
    │       └── <global_folder>
    │           ├── terraform.tfvars
    │           ├── resources that is indepdent of any stack
    │           └── <other global specific files>
    ├── layers
    │   ├── main.tf
    │   └── <dev | prod>
    │       └── <application | analytics>
    │           └── <functional group>.tf
    └── modules
        └── awsc
            └── <module category>
                └── <module name>
                    ├── main.tf
                    ├── variables.tf
                    ├── output.tf
                    └── <other module specific files>
```

### Naming Convention
Please refer below
| Environment   | aws account suffix  | stack folder           |  resource name
| ------------------------------------| -------------------------------------------
| Development   |  <aws account>d     | <stack folder name>d   |  <resource name>d
| Staging       |  <aws account>s     | <stack folder name>s   |  <resource name>s
| Production    |  <aws account>      | <stack folder name>    |  <resource name>

### Tier 1: Modules
The module layer contains terraform modules. Generally if more than one resource will always be deployed as a unit, then they should be put into a module.

### Tier 2: Functional Groups

#### Reasoning
A functional group is an independent set of modules and resources that will be reused across different shards. The reasons that we don't use nested modules for this purpose include:
* Variables in modules are not automatically exposed when nested, so they need to be re-exposed at the parent module level.
* In order to share functional groups across shards, all the module variables have to be re-exposed at the shard level as well.

#### Structure
In order to avoid surprises, the top level directory of functional groups is environments, such as dev and prod. Duplication between those environments are considered necessary and allowed.

Within each environment, the functional groups are further divided into analytics and application. Application is for function groups that extract data from the application instances and databases, which are typically deployed into the application shards. Analytics is for functional groups that processes the data, which are deployed into analytics accounts.

#### Format
Each functional group should be one .tf file with the following sections:
1. Variables - list of all variables required
2. Resources - list of all modules and resources
3. Outputs (optional) - list of outputs
A single file instead of the main/variables/output trio allows easier symbolic linking into shard directories.

### Tier 3: Shards
A shard is a logical unit of deployment that is completely isolated from each other, so each shard should have its own tfstate file. The concept is largely borrowed from IoT Cloud's deployment architecture, in which each shard lives in its own VPC.

Likewise, in order to be consistent with existing naming conventions, the shard names should use the same frigga-naming convention, namely:
[stack name] [env abbrevation] _ [AWS region name]. Some examples:
* eu01deuwest1
* na01suseast1
* na02useast1

An exception is iam, of which there should be only one per account, and there's no env abbrevation or AWS region suffix.
