Azure Terraform Example
=======================

 

This is an example of a Azure terraform config that creates two web farms, sql
database and a redis instance.

`all` is the main terraform config that can be used (with some variable
manipulation) to create the dev, test, uat, prod, whatever environment.

 

Local setup
-----------

`cd /path/to/repo/envs/all`

`terraform init`

`terraform apply`


