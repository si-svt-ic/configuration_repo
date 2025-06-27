## bai 1


## bai 3

$ terraform apply -var-file="production.tfvars"

## bai 4

Bạn chạy lại câu lệnh apply, ta sẽ thấy giá trị IP của EC2 được in ra terminal.

$ terraform apply -auto-approve

 ...

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

ec2 = {
  "public_ip" = "52.36.124.230"
}

## bai 5

.
├── main.tf
└── vpc
    ├── main.tf
    ├── outputs.tf
    └── variables.tf