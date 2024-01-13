# apply terraform

## Bài 2 - Life cycle của một resource trong Terraform 

Khởi tạo workspace

  $ terraform init

Kiểm tra resrource nào sẽ được tạo ra

  $ terraform plan
  $ terraform plan -out plan.out
  $ terraform show -json plan.out > plan.json

Tạo resource

  $ terraform apply
  $ terraform plan -out plan.out
  $ terraform apply "plan.out"
  
bai1_instance  .
  ├── .terraform
  │   └── providers
  │       └── registry.terraform.io
  │           └── hashicorp
  │               └── aws
  │                   └── 3.68.0
  │                       └── linux_amd64
  │                           └── terraform-provider-aws_v3.68.0_x5
  ├── .terraform.lock.hcl
  ├── main.tf
  └── terraform.tfstate

Resource drift

  Note: Objects have changed outside of Terraform để báo ta biết việc đó. 
  Và tùy thuộc vào thuộc tính mà ta thay đổi bên ngoài terraform là force new hay normal update thì terraform sẽ thực hiện re-create hay update bình thường cho ta.

## Bài 4 - Terraform functional programming

Định nghĩa biến

  variable.tf

Danh sách biến

  production.tfvars
  terraform.tfvars (default)

Apply sử dụng biến

  $ terraform apply -var-file="production.tfvars"
  $ terraform apply -auto-approve

Hàm for

    output "ec2" {
    value = {
      public_ip = [ for v in aws_instance.hello : v.public_ip ]
    }
  }

Hàm format

    output "ec2" {
    value = { for i, v in aws_instance.hello : format("public_ip%d", i + 1) => v.public_ip }
  }

File function
  .
  ├── main.tf
  ├── s3_static_policy.json
  ├── static-web
  │   ├── README.md
  │   ├── article-details.html
  ...
  ├── terraform.tfstate

## Bài 5 - Terraform Module: Create Virtual Private Cloud on AWS

Tạo folder với cấu trúc như sau.

  .
  ├── main.tf
  └── vpc
      ├── main.tf
      ├── outputs.tf
      └── variables.tf