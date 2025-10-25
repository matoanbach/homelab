21. When configuring a remote backend in Terraform, it might be a good idea to purposely omit some of the required arguments to ensure secrets and other relevant data are not inadvertently shared with others. What alternatives are available to provide the remaining values to Terraform to initialize and communicate with the remote backend? (select three)

- Correct: interactively on the command line, use the -backend-config=PATH flag to specify a separate config file, directly querying HashiCorp Vault for the secrets
- Overall explanation:
    - When configuring a remote backend in Terraform, it's important to avoid hardcoding sensitive data like secrets in your configuration files to prevent inadvertent sharing through version control. Instead, you can provide these values securely through alternative methods. One option is to provide the missing values interactively on the command line during terraform init, ensuring they aren't stored in code. Another approach is to use the -backend-config=PATH flag to specify a separate configuration file that can be excluded from Git repositories. Additionally, you can directly query HashiCorp Vault for secrets, allowing dynamic retrieval of credentials at runtime.

    - However, using a TFVARS file committed to a Git repository is not recommended, as it risks exposing secrets to a code repository.

34. In the terraform block, which configuration would be used to identify the specific version of a provider required?
- Correct: `required_providers`

40. What are some of the features of Terraform state? (select three)
- Incorrect: inspection of cloud resources
- Why: Inspection of cloud resources is not a feature of Terraform state. Terraform state is used for tracking the state of managed infrastructure resources and managing their configuration, but it does not provide direct inspection capabilities for cloud resources.

47. In regards to Terraform state file, select all the statements below which are correct: (select four)
- Incorrect: using the sensitive = true feature, you can instruct Terraform to mask sensitive data in the state file
- Why: Terraform will still record sensitive values in the state when using the sensitive=true feature, and so anyone who can access the state data will have access to the sensitive values in cleartext.

49. In order to make a Terraform configuration file dynamic and/or reusable, static values should be converted to use what?
- Correct: input variables
- Why: Modules in Terraform are used to encapsulate and organize reusable components of infrastructure configurations. While modules promote reusability, they are not used specifically to convert static values to dynamic ones in a Terraform configuration file. Input variables are the appropriate choice for achieving this goal

54. What Terraform command can be used to inspect the current state file?
- Incorrect: `terraform state`
- Why: 
    - The 'terraform state' command is used to perform operations on the Terraform state, such as listing resources, showing resource attributes, and more. However, it is not specifically used to inspect the current state file like the 'terraform show' command.
    - The 'terraform show' command is used to inspect the current state file in Terraform. It displays the current state as Terraform sees it, including resource attributes and dependencies.

56. True or False? Similar to Terraform Community, you must use the CLI to switch between workspaces when using HCP Terraform workspaces.
- Correct: False
- Why: In HCP Terraform, you can switch between workspaces directly within the HCP Terraform web interface without the need to use the CLI. HCP Terraform provides a user-friendly interface that allows users to manage and switch between workspaces efficiently without relying solely on the CLI for workspace management.

