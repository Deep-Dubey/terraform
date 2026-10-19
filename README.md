# Terraform Project Notes

## Multiple Providers

This configuration declares AzureRM and AWS providers:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = "ap-south-1"
}
```

Running `terraform init` alone is not sufficient to validate the configuration. For example, adding content inside `provider "azurerm" { features {} }` can still allow initialization to succeed; use `terraform plan` to check the planned configuration and changes.

## Terraform Commands

| Command | Purpose |
| --- | --- |
| `terraform fmt` | Formats Terraform configuration files. |
| `terraform init` | Initializes the working directory and its providers. |
| `terraform plan` | Previews what Terraform will create, modify, or delete before applying changes. |
| `terraform apply -auto-approve` | Creates, updates, or deletes infrastructure without asking for confirmation. |
| `terraform state list` | Lists resources in the Terraform state. |
| `terraform state show resource_group_name` | Shows details for a resource. Example: `terraform state show azurerm_resource_group.mtc-rg`. |
| `terraform plan -destroy` | Previews the resources Terraform would destroy. |
| `terraform apply -destroy` | Destroys the infrastructure managed by the configuration. |
| `terraform apply -refresh-only` | Refreshes the state to reflect current infrastructure changes without changing infrastructure. |

## SSH and Linux Commands

- `ssh-keygen -t rsa` generates an SSH key pair for securely connecting to a remote machine.
- `ssh -i ~/.ssh/azurerm-ssh-key azureuser@XXXX` connects to an Azure Linux virtual machine over SSH. Replace `XXXX` with the VM's current address.
- `lsb_release -a` displays the operating system version on the VM.
- `ssh-keygen -R XXXX` removes the old host key for the address. Replace `XXXX` with the VM's address.
- `ssh -i "$HOME\.ssh\azurerm-ssh-key" azureuser@XXXX` verifies the new host key while connecting. Replace `XXXX` with the VM's current address.

## Templates and Provisioners

Terraform `.tpl` files keep scripts or configuration outside the main Terraform code so they can be reused when creating infrastructure.

Provisioners run commands on a local or remote machine after a resource is created or during its lifecycle:

1. `local-exec` runs a command on the machine where Terraform is executed, such as a local shell script or a message-printing command.
2. `remote-exec` runs commands on a remote machine, such as an Azure Linux VM, usually through SSH.

## Data Sources and Resources

Use a Terraform `data` block to read information about an existing Azure resource. Use a `resource` block when Terraform should create or manage the resource's lifecycle.

## Dummy Files

`dummy_main.tf` is a placeholder configuration. Set `admin_source_cidr` to a trusted source CIDR before using it. The `dummy_terraform.tfstate.example` and `dummy_terraform.tfstate.backup.example` files are empty examples, not project state; Terraform will not load them as state files.