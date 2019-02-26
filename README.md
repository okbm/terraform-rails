
# What is installed

## aws service

- ec2
- eip
- rds
- s3
- ses
- route53
- alb(+https)
- acm
- iam
- vpc

## other

https://github.com/okbm/terraform-rails/blob/master/tmp/script.sh

- nginx
- ruby

## setup

terraform version 0.11.8

```
$ cp terraform.tfvars.sample terraform.tfvars
$ terraform init

$ ssh-keygen -t rsa
$ vim terraform.tfvars
```

### use vim
https://github.com/hashivim/vim-terraform

## run

```
$ terraform validate
$ terraform plan
$ terraform apply
```
