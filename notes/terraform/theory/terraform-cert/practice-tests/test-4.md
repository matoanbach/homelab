7. Which of the following Terraform editions provides the ability to create and use a private registry?
- Correct: HCP terraform

18. Which of the following statements are true about using the terraform import command? (select three)
- Incorrect: the terraform import command will automatically update the referenced Terraform resource block after the resource has been imported to ensure consistency
- Why: The terraform import command does not automatically update the referenced Terraform resource block after importing the resource. It is the responsibility of the user to ensure that the Terraform configuration is updated and aligned with the imported resource to maintain consistency and avoid conflicts.

22. Which of the following are advantages of using infrastructure as code (IaC) for your day-to-day operations? (select three)
- Incorrect: ensures the security of applications provisioned on managed infrastructure
- Why: Ensuring the security of applications provisioned on managed infrastructure is not a direct advantage of using infrastructure as code (IaC). While IaC can help enforce security best practices through automated configuration management, the primary focus is on automation, scalability, and consistency in managing infrastructure resources.

26. When using Terraform, where can you install providers from? (select four)
- Incorrect: provider's source code:
- Why: Providers can be installed using multiple methods, including downloading from a Terraform public or private registry, the official HashiCorp releases page, a local plugins directory, or even from a plugin cache. Terraform cannot, however, install directly from the source code.

27. True or False? When developing Terraform code, you must include a provider block for each unique provider so Terraform knows which ones you want to download and use.
- Correct: False
- Why: While it is a best practice to include a provider block for each unique provider in Terraform code, it is not a strict requirement. Terraform can automatically detect and use providers based on the resource configurations defined in the code. However, explicitly defining provider blocks enhances code readability and helps avoid potential conflicts or ambiguities in resource management.

30. What CLI commands will completely tear down and delete all resources that Terraform is currently managing? (select two)
- Correct: 
    - `terraform apply -destroy`
    - `terraform destroy`

42. What are some of the benefits that Terraform providers offer to users? (select three)
- Incorrect: enforces security compliance across multiple cloud providers
- Why: The choice is incorrect as Terraform providers do not enforce security compliance across multiple cloud providers. While Terraform allows users to define security configurations and policies within their infrastructure code, it is not a built-in feature of providers to enforce security compliance across different cloud platforms.

54. Your co-worker has decided to migrate Terraform state to a remote backend. They configure Terraform with the backend configuration, including the type, location, and credentials. However, you want to secure this configuration better.

- Rather than storing them in plaintext, where should you store the credentials for the remote backend? (select two)

- Correct: credential files, environment variables.

