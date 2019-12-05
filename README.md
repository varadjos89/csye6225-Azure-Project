## Instructions to run azure ami
1) Add ami-var.json to set your azure credential details.
2) Validate your files using "packer valide -var-file=./ami-vars.json ami-template.json" command.
3) Then build custom ami using "packer build -var-file=./ami-vars.json ami-template.json" command.


## Instructions to run terraform script
1) Navigate into terraform folder.
2) Run terrafom init command to download required code for terraform.
3) To validate your terraform run terraform validate command.
4) In order to create a plan run terraform plan command which will create a plan.
5) Add terraform.tfvars file to set values.
6) To create terraform network stack run below command

    `terraform apply`
    
7) To delete terraform network stack run below command
 
    `terraform destroy`

