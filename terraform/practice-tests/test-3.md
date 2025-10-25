2. There are multiple ways to provide sensitive values when using Terraform. However, sensitive information provided in your configuration can be written to the state file, which is not desirable. Which method below will not result in sensitive information being written to the state file?
- Correct: none of the above
- Why:
    - When using sensitive values in your Terraform configuration, all of the configurations mentioned above will result in the sensitive value being written to the state file. Terraform stores the state as plain text, including variable values, even if you have flagged them as sensitive. Terraform needs to store these values in your state so that it can tell if you have changed them since the last time you applied your configuration.

    - Terraform runs will receive the full text of sensitive variables and might print the value in logs and state files if the configuration pipes the value through to an output or a resource parameter. Additionally, Sentinel mocks downloaded from runs will contain the sensitive values of Terraform (but not environment) variables. Take care when writing your configurations to avoid unnecessary credential disclosure. (Environment variables can end up in log files if TF_LOG is set to TRACE.)

4. When using HCP Terraform, what is the easiest way to ensure the security and integrity of modules when used by multiple teams across different projects?
- Correct: Use the HCP Terraform Private Registry to ensure only approved modules are consumed by your organization
- Why: Using the HCP Terraform Private Registry allows organizations to control and manage the modules that are available for consumption by their teams. This ensures that only approved and verified modules are used in different projects, enhancing security and integrity across the organization.

9. What feature of Terraform provides an abstraction above the upstream API and is responsible for understanding API interactions and exposing resources?
- Correct: Terraform provider
- Why: Terraform provider is the correct choice because it is a key component of Terraform that acts as an interface between Terraform and the upstream API of a specific service or platform. It abstracts the API interactions, understands how to create, read, update, and delete resources, and exposes those resources to be managed within Terraform configurations.

10. Ralphie has executed a terraform apply using a complex Terraform configuration file. However, a few resources failed to deploy due to incorrect variables. After the error is discovered, what happens to the resources that were successfully provisioned?
- Correct: the resources that were successfully provisioned will remain as deployed
- Why: This choice is correct because Terraform follows a declarative approach, where it only manages the resources specified in the configuration file. Once a resource is successfully provisioned, it will remain deployed unless explicitly destroyed or modified in the configuration.

14. You are working with a cloud provider to deploy resources using Terraform. You've added the following data block to your configuration. When the data block is used, what data will be returned?
- Correct: all possible data of a specific Amazon Machine Image(AMI) from AWS
- Why: The data block "aws_ami" with the specified filters will return all possible data of a specific Amazon Machine Image (AMI) from AWS that matches the criteria set in the configuration. This includes information such as the AMI ID, description, architecture, root device type, and more.

23. Your organization requires that no security group in your public cloud environment includes "0.0.0.0/0" as a source of network traffic. How can you proactively enforce this control and prevent Terraform configurations from being executed if they contain this specific string?
- Correct: Create a Sentinel or OPA policy that checks for the string and denies the Terraform apply if the string exists
- Why: To prevent a Terraform configuration from being executed if it contains a specific string, you can use Sentinel or Open Policy Agent (OPA) to enforce policy checks. Both tools allow you to define custom policies to evaluate and control Terraform configurations before they are applied. Both offer powerful capabilities to enforce custom policies on your Terraform configurations, providing an additional layer of security and governance. By leveraging these tools, you can prevent sensitive information or undesired strings from being present in your infrastructure code, reducing the risk of accidental misconfigurations and potential security vulnerabilities.

24. Both Terraform Community/CLI and HCP Terraform offer a feature called "workspaces." Which of the following statements are true regarding workspaces? (select three)
- Correct: 
    - CLI workspaces are alternative state files in the same working directory
    - HCP Terraform maintains the state version and run history for each workspace
    - HCP Terraform manages infrastructure collections with a workspace whereas CLI manages collections of infrastructure resources with a persistent working directory

38. A startup needs a way to ensure only its engineers and architects can create and publish approved Terraform modules. Which feature can provide this capability?
- Correct: private registry

42. Margaret is calling a child module to deploy infrastructure for her organization. Just as a good architect does (and suggested by HashiCorp), she specifies the module version she wants to use even though there are newer versions available. During a terrafom init, Terraform downloads v0.0.5 just as expected.

- What would happen if Margaret removed the version parameter in the module block and ran a terraform init again?

```
module "consul" {
  source  = "hashicorp/consul/aws"
  version = "0.0.5"
 
  servers = 3
}
```

- Correct: Terraform would use the existing module already downloaded
- Why: Terraform would use the existing module already downloaded because once a specific version is downloaded, Terraform caches it locally. If the version parameter is removed, Terraform will continue to use the cached version unless explicitly updated.

46. Please fill the blank field(s) in the statement with the right words.

- What CLI command and flag can you use to delete a resource named azurerm_resource_group.production that is managed by Terraform?
- Correct: `terraform destroy -target=azure...`
