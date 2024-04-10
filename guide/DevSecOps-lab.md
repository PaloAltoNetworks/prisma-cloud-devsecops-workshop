# Welcome

This workshop will demonstrate how to leverage infrastructure as code (IaC) and DevSecOps patterns to automate, scale, and improve the security posture of cloud infrastructure and applications. We will create a pipeline that ensures our configurations are secure and compliant from code to cloud.

This guide provides step-by-step instructions to integrate **Prisma Cloud** (and **checkov**) with **Terraform Cloud, GitHub, VScode** and **AWS**. 

![](images/workshop-flow.png)

![](images/devsecops-workflow.png)



## Table of Contents

- [Welcome](#welcome)
  - [Table of Contents ](#table-of-contents)
  - [Learning Objectives](#learning-objectives)
  - [DevSecOps](#devsecops)
  - [Infrastructure as Code Using Terraform](#infrastructure-as-code-using-terraform)

- [Section 0: Setup AWS Environment](#section-0-setup)
  - [Prerequisites](#prerequisities)
  - [Log into AWS Event Engine](#log-into-aws-event-engine)
  - [Configure IAM User and API Key](#configure-iam-user-and-api-key)
  - [Configure Cloud9](#configure-cloud9)

- [Section 1: Code Scanning with checkov](#section-1-code-scanning-with-checkov)
  - [Install checkov](#install-checkov)
  - [Fork and clone target repository](#fork-and-clone-target-repository)
  - [Scan with checkov](#scan-with-checkov)
  - [Custom Policies](#custom-policies)
  - [IDE plugin](#ide-plugin)
  - [Integrate with GitHub Actions](#integrate-with-GitHub-actions)
  - [View results in GitHub Security](#view-results-in-GitHub-secuirty)
  - [Tag and Trace with yor](#tag-and-trace-with-yor)
  - [Branch Protection Rules](#branch-protection-rules)
  - [BONUS: Pre-commit hooks](#bonus-pre-commit-hooks)
  - [Integrate workflow with Terraform Cloud](#integrate-workflow-with-terraform-cloud)
  - [Block a Pull Request, Prevent a Deployment](#block-a-pull-request-prevent-a-deployment)
  - [Deploy to AWS](#deploy-to-aws)

- [Section 2: Application Security with Prisma Cloud](#section-2-application-security-with-prisma-cloud)
  - [Welcome to Prisma Cloud](#welcome-to-prisma-cloud)
  - [Onboard AWS account](#onboard-aws-account)
  - [Integrations and Providers](#integrations-and-providers)
  - [Checkov with API Key](#checkov-with-api-key)
  - [Terraform Cloud Run Tasks](#terraform-cloud-run-tasks)
  - [GitHub Application](#GitHub-application)
  - [Submit a Pull Request 2.0](#submit-a-pull-request-20)
  - [View scan results in Prisma Cloud](#view-scan-results-in-prisma-cloud)
  - [Issue a PR Fix](#issue-a-pr-fix)
  - [Drift Detection](#drift-detection)

- [Wrapping Up](#wrapping-up)


## Learning Objectives
- Gain an understanding of DevSecOps and infrastructure as code (IaC) using Terraform
- Scan IaC files for misconfigurations locally
- Set up CI/CD pipelines to automate security scanning and policy enforcement
- Fix security findings and AWS resource misconfigurations with Prisma Cloud

**Let’s start with a few core concepts...**

## DevSecOps
The foundation of DevSecOps lies in the DevOps movement, wherein development and operations functions have merged to make deployments faster, safer, and more repeatable. Common DevOps practices include automated infrastructure build pipelines (CI/CD) and version-controlled manifests (GitOps) to make it easier to control cloud deployments. By baking software and infrastructure quality requirements into the release lifecycle, teams save time manually reviewing code, letting teams focus on shipping features.

As deployments to production speed up, however, many traditional cloud security concepts break down. With the rise of containerized technologies, serverless functions, and IaC frameworks, it is increasingly harder to maintain visibility of cloud security posture. 

By leveraging DevOps foundations, security and development teams can build security scanning and policy enforcement into automated pipelines. The ultimate goal with DevSecOps is to “shift cloud security left.” That means automating it and embedding it earlier into the development lifecycle so that actions can be taken earlier. Preventing risky deployments is a more proactive approach to traditional cloud security that often slows down development teams with deployment rollbacks and disruptive fixes.

For DevSecOps to be successful for teams working to build and secure infrastructure, embracing existing tools and workflows is critical. At Palo Alto Networks, we’re committed to making it as simple, effective, and painless as possible to automate security controls and integrate them seamlessly into standard workflows.




## Infrastructure as Code Using Terraform
Infrastructure as code (IaC) frameworks, such as  HashiCorp Terraform, make cloud provisioning scalable and straightforward by leveraging automation and code. Defining our cloud infrastructure in code simplifies repetitive DevOps tasks and gives us a versioned, auditable source of truth for the state of an environment.

Terraform is useful for defining resource configurations and interacting with APIs in a codified, stateful manor. Any updates we want to make, such as adding more instances, or changes to a configuration, can be handled by Terraform. 

For example, the following Terraform resource block defines a simple AWS S3 bucket:

```hcl
resource "aws_s3_bucket" "data" {
  bucket     = "my_bucket_name"
  acl        = "public-read-write"
}
```

After performing `terraform init`, we can provision an S3 bucket with the following command:

```bash
terraform apply
```

Any changes made to the resource definition within a .tf file, such as adding tags or changing the acl, can be pushed with the  `terraform apply` command. 

Another benefit of using Terraform to define infrastructure is that code can be scanned for  misconfigurations before the resource is created. This allows for security controls to be integrated into the development process, preventing issues from ever being introduced, deployed and exploited.

# Section 0: Setup AWS Environment

## Prerequisities
- GitHub account
- Terraform Cloud account
- AWS account (provided during workshop)
- Prisma Cloud account (OPTIONAL)

## Log into AWS Event Engine
> [!NOTE]
> *This section is for live workshop events only.*

Follow the link provided to you for Event Engine. Enter the event hash (if it is not already populated), and click `Accept Terms & Login`.

![ee-login](images/ee-login.png)

Choose your perferred sign-in method (OTP is recommended for workshop attendees).

![ee-sign-in](images/ee-sign-in.png)

Once logged in, copy the provided credentials into a local text file and then click `Open Console` to navigate to AWS.

![ee-creds](images/ee-creds.png)

## Configure IAM User and API Key

From the AWS console, select `IAM` or search for 'IAM' in the Search bar if not displayed.

![iam-console-home](images/iam-console-home.png)

In the IAM Dashboard, click `Users` on the left sidebar.

![iam-dashboard](images/iam-dashboard.png)

Click the `Create User` button on the top right.

![create-user](images/iam-create-user.png)

Specify a `User name` that will be unique then click `Next`.

![user-details](images/iam-user-details.png)

Next, set the permissions for the user by selecting `Attach policies directly` and attaching the `AdministratorAccess` policy.

![iam-set-perms](images/iam-set-perms.png)

Review the user details and click `Create user`.

![iam-review-create](images/iam-review-create.png)

Now we need to assign an API key to the user we just created. Click on the user you just created from the IAM Dashboard and then click `Create access key` on the right.

![iam-create-key](images/iam-create-key.png)

Select `Other` from the Access Key options.

![iam-key-options](images/iam-key-options.png)

Optionally, supply a tag to associate with the Access Key, then click `Create access key`.

![iam-key-tag-and-create](images/iam-key-tag-and-create.png)

Finally, save the Access Key data provided (copy to a local file). This credential will be used to deploy resources to AWS in a later section. When ready, click `Done`.

![iam-retrieve-key-data](images/iam-retrieve-key-data.png)

An access key will now appear on the User details page.

![iam-key-created](images/iam-key-created.png)


## Configure Cloud9
To ensure we all have the same environent configuration, we will use Cloud9, a cloud-delivered IDE from AWS, to carry out many of the steps in this workshop. To set this up, navigate back to the AWS Console home and select Cloud9 (or enter it into the Search bar).


![c9-console-home](images/c9-console-home.png)

On the Cloud9 Environments page, click `Create Environment`.

![c9-create-env](images/c9-create-env.png)

Enter a `Name` for the Environemnt and select `New EC2 instance` for Environment Type.

![c9-env-options1](images/c9-env-options1.png)

Select `Additional instance types` then choose `t3.medium` from the drop-down.

![c9-env-options2](images/c9-env-options2.png)

Leave all other options on default setting and click `Create`. 

![c9-env-options3](images/c9-env-options3.png)


Once the environment is created, navigate to it and click `Open in Cloud9` to launch the IDE.

![c9-open-ide](images/c9-open-ide.png)

Close all of the default windows, then create a New Terminal window.

![c9-close-welcome](images/c9-close-welcome.png)

![c9-open-term](images/c9-open-term.png)

![c9-blank-term](images/c9-blank-shell.png)

Congrats! Cloud9 is now ready to use. Before installing checkov or pulling code to scan, create and activate a python virtual environment to better organize python packages.

``` 
python3 -m venv env
source ./env/bin/activate 
```

![c9-py-venv](images/c9-py-venv.png)

##
# Section 1: Code Scanning with checkov

[Checkov](https://checkov.io) is an open source 'policy-as-code' tool that scans cloud infrastructure defintions to find misconfigurations before they are deployed. Some of the key benefits of checkov:
1. Runs as a command line interface (CLI) tool 
2. Supports many common plaftorms and frameworks 
3. Ships with thousands of default policies
4. Works on windows/mac/linux (any system with python installed)

## Install checkov

To get started, install checkov using pip:

```
pip3 install checkov
```

![](images/c9-install-checkov.png)




Use the `--version` and `--help` flags to verify the install and view usage / optional arguements.

```
checkov --version
checkov --help
```
![](images/c9-checkov-options.png)

To see a list of every policy that checkov can enforce, use the `-l` or ` --list` options.

```
checkov --list
```

Now that you see what checkov can do, let's get some code to scan...



## Fork and clone target repository
This workshop involves code that is vulnerable-by-design. All of the necessary code is contained within [this repository](https://GitHub.com/paloAltoNetworks/prisma-cloud-devsecops-workshop) or workshop guide itself.

To begin, log into GitHub and navigate to the [Prisma Cloud DevSecOps Workshop](https://GitHub.com/paloAltoNetworks/prisma-cloud-devsecops-workshop) repository. Create a `Fork` of this repository to create a copy of the code in your own account.

![](images/gh-fork.png)

Ensure the selected `Owner` matches your username, then proceed to fork the repository by clicking `Create fork`.

![](images/gh-create-fork.png)

Grab the repo URL from GitHub, then clone the **forked** repository to Cloud9.

![](images/gh-clone.png)

```
git clone https://github.com/<your-organization>/prisma-cloud-devsecops-workshop.git
cd prisma-cloud-devsecops-workshop/
git status

```

![](images/c9-git-clone.png)


Great! Now we have some code to scan. Let's jump in...



## Scan with checkov

Checkov can be configured to scan files and enforce policies in many different ways. To highlight a few: 
1. Scans can run on individual files or entire directories. 
2. Policies can be selected through selection or omission. 
3. Enforcement can be determined by flags that control checkov's exit code.


Let's start by scanning the entire `./code` directory and viewing the results.

```
cd code/
checkov -d .
```
![](images/c9-checkov-d.png)

Failed checks are returned containing the offending file and resource, the lines of code that triggered the policy, and a guide to fix the issue.

![](images/checkov-result.png)

Now try running checkov on an individual file with `checkov -f <filename>`. 

```
checkov -f deployment_ec2.tf
```
```
checkov -f simple_ec2.tf
```

> **⍰  Question** 
>
> Why are there more security findings for `deployment_ec2.tf` than there are for `simple_ec2.tf`? What about `simple_s3.tf` vs `simple_ec2.tf`?


Policies can be optionally enforced or skipped with the `--check` and `--skip-check` flags. 

```
checkov -f deployment_s3.tf --check CKV_AWS_18,CKV_AWS_52
```
```
checkov -f deployment_s3.tf --skip-check CKV_AWS_18,CKV_AWS_52
```

Frameworks can also be selected or omitted for a particular scan.


```
checkov -d . --framework secrets --enable-secret-scan-all-files
```
```
checkov -d . --skip-framework dockerfile
```

![](images/checkov-secrets.png)


Lastly, enforcement can be more granularly controlled by using the `--soft-fail` option. Applying `--soft-fail` results in the scan always returning a 0 exit code. Using `--hard-fail-on` overrides this option. 

Check the exit code when running `checkov -d . ` with and without the `--soft-fail` option.

```
checkov -d . ; echo $?
```
```
checkov -d . --soft-fail ; echo $?
```

An example of using `--soft-fail` and exit codes in a pipeline context will be demosntrated in a later section.


## Custom Policies

Checkov supports the creation of [Custom Policies](https://www.checkov.io/3.Custom%20Policies/YAML%20Custom%20Policies.html) for users to customize their own policy and configuration checks. Custom policies can be written in YAML (recommended) or python and applied with the `--external-checks-dir` or `--external-checks-git` flags. 

Let's create a custom policy to check for [local-exec and remote-exec Provisioners](https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec) being used in Terraform resource definitons. (Follow link to learn more about provisioners and why it is a good idea to check for them).

```yaml
metadata:
 name: "Terraform contains local-exec and/or remote-exec provisioner"
 id: "CKV2_TF_1"
 category: "GENERAL_SECURITY"
definition:
 and:
  - cond_type: "attribute"
    resource_types: all 
    attribute: "provisioner/local-exec"
    operator: "not_exists"
  - cond_type: "attribute"
    resource_types: all
    attribute: "provisioner/remote-exec"
    operator: "not_exists"
```
Add the above code to a new file within a new direcotry.

```
mkdir custom-checks/
vim custom-checks/check.yaml
```
>[!TIP]
> use `echo '$(file_contents)' > custom-checks/check.yaml` if formatting is an issue with vim.


Save the file. Then run checkov with the `--external-checks-dir` to test the custom policy.

```
checkov -f simple_ec2.tf --external-checks-dir custom-checks
```
![](images/checkov-custom-checks.png)

**Challenge:** write a custom policy to check all resources for the presence of tags. Specifically, ensure that a tag named "Environment" exists.


## IDE plugin
> [!NOTE]
> *Demo Only. Requires API key for Prisma Cloud.*
>
> Link to docs: [Prisma Cloud IDE plugins](https://docs.prismacloud.io/en/classic/appsec-admin-guide/get-started/connect-your-repositories/integrate-ide/integrate-ide)
>
> Link to docs: [VScode extension](https://marketplace.visualstudio.com/items?itemName=Bridgecrew.checkov)

Enabling checkov in an IDE provides real-time scan results and inline fix suggestions to developers as they create cloud infrastructure and applications.

![](images/vscode-extension.png)

![](images/vscode-ide1.png)

![](images/vscode-ide2.png)


## Integrate with GitHub Actions
Now that we are more familiar with some of checkov's basic functionality, let's see what it can do when integrated with other tools like GitHub Actions.

You can leverage GitHub Actions to run automated scans for every build or specific builds, such as the ones that merge into the master branch. This action can alert on misconfigurations, or block code from being merged if certain policies are violated. Results can also be sent to Prisma Cloud and other sources for further review and remediation steps.

Let's begin by setting an action from the repository page, under the `Actions` tab. Then click on `set up a workflow yourself ->` to create a new action from scratch.


<img src="images/gh-actions-new-workflow.png" width="800" height="300" /> 

Name the file `checkov.yaml` and add the following code snippet into the editor.

```yaml
name: checkov
on:
  pull_request:
  push:
    branches:
      - main    
jobs:
  scan:
    runs-on: ubuntu-latest 
    permissions:
      contents: read # for actions/checkout to fetch code
      security-events: write # for GitHub/codeql-action/upload-sarif to upload SARIF results
     
    steps:
    - uses: actions/checkout@v2
    
    - name: Run checkov 
      id: checkov
      uses: bridgecrewio/checkov-action@master
      with:
        directory: code/
        #soft_fail: true
        #api-key: ${{ secrets.BC_API_KEY }}
      #env:
        #PRISMA_API_URL: https://api4.prismacloud.io
        
    - name: Upload SARIF file
      uses: GitHub/codeql-action/upload-sarif@v3
      
      # Results are generated only on a success or failure
      # this is required since GitHub by default won't run the next step
      # when the previous one has failed. Alternatively, enable soft_fail in checkov action.
      if: success() || failure()
      with:
        sarif_file: results.sarif
```

Once complete, click `Commit changes...` at the top right, then select `commit directly to the main branch` and click `Commit changes`.

![](images/gh-action-edit.png)


Verify that the action is running (or has run) by navigating back to the `Actions` tab.

![](images/gh-actions-workflows.png)


> **⍰  Question** 
>
> The action will result in a "Failure" (❌) on the first run, why does this happen?


View the results of the run by clicking on the `Create checkov.yaml` link.

![](images/gh-actions-results.png)

Notice the policy violations that were seen earlier in CLI/Cloud9 are now displayed here. However, this is not the only place they are sent...

## View results in GitHub Secuirty 
Checkov natively supports SARIF format and generates this output by default. GitHub Security accepts SARIF for uploading security issues. The GitHub Action created earlier handles the plumbing between the two.


Navigate to the `Security` tab in GitHub, the click `Code scanning` from the left sidebar or `View alerts` in the **Security overview > Code scanning alerts** section.

![](images/ghas-overview.png)

The security issues found by checkov are surfaced here for developers to get actionable feedback on the codebase they are working in without having to leave the platform. 

![](images/ghas-code-scanning-results.png)


> [!TIP]
> Code scanning alerts can be integrated into many other tools and workflows.



## Tag and Trace with yor
[Yor](yor.io) is another open source tool that can be used for tagging and tracing IaC resources from code to cloud. For example, yor can be used to add git metadata and a unique hash to a terraform resource; this can be used to better manage resource lifecycles, improve change management, and ultimately to help tie code defintions to runtime configurations.

Create new file in the GitHub UI under the path `.github/workflows/yor.yaml`. 

![](images/gh-new-file.png)

Add the following code snippet:

```yaml
name: IaC tag and trace

on:
  push:
  pull_request:

jobs:
  yor:
    runs-on: ubuntu-latest
    permissions:
      contents: write
  
    steps:
      - uses: actions/checkout@v2
        name: Checkout repo
        with:
          fetch-depth: 0
      - name: Run yor action
        uses: bridgecrewio/yor-action@main

```

This time, click `Commit changes...` at the top right, then select `Create a new branch` and click `Propose changes`. Click `Create pull request` on the next screen.


Check that the action is running, queued, or finished under the `Actions` tab.

More importanly, look at what yor updated by following the commit history and viewing any `.tf` file in the `code/` directory.

<img src="images/yor-tags.png" width="600" height="500" /> 


Notice the `yor_trace` tag? This can be used track "drift" between IaC definitons and runtime configurations.

## Branch Protection Rules
Using Branch Protection Rules allows for criteria to be set in order for pushes and pull requests to be merged to a given branch. This can be set up to run checkov and block merges if there are any misconfigurations or vulnerabilities. 

Within GitHub, go to the `Settings` tab and navigate to `Branches` on the left sidebar, then click `Add branch protection rule`.

![](images/gh-branch-protection.png)

Enter `main` as the `Branch name pattern`. Then select `Require status checks to pass before merging`, search for `checkov` in the provided search bar and select it as a required check. Leave the rest as default (unchecked), then click `Create`.

![](images/gh-bp-rule.png)



## BONUS: Pre-commit Hooks
Checkov can also be configured as a pre-commit hook. Read how to set up [here!](https://www.checkov.io/4.Integrations/pre-commit.html)


## Integrate workflow with Terraform Cloud
Let's continue by integrating our GitHub repository with Terraform Cloud. We will then use Terraform Cloud to deploy IaC resource to AWS.

Navigate to [Terraform Cloud](app.terraform.io) and sign in / sign up. The community edition is all that is needed for this workshop.

Once logged in, follow the prompt to set up a new organization.

![](images/tfc-welcome.png)

Enter an `Organization name` and provide your email address.


<img src="images/tfc-org-details.png" width="700" height="500" /> 

Create a workspace using the `Version Control Workflow` option.

![](images/tfc-vcs-workflow.png)

Select `GitHub`, then `GitHub.com` from the dropdown. Authenticate and authorize the GitHub.


<img src="images/tfc-add-github.png" width="600" height="450" /> 

Choose the `prisma-cloud-devsecops-workshop` from the list of repositories.

![](images/tfc-add-repo.png)

Add a `Workspace Name` and click `Advanced options`.


<img src="images/tfc-workspace1.png" width="500" height="600" /> 

In the `Terraform Working Directory` field, enter `/code/build/`. Select `Only trigger runs when files in specified paths change`.


<img src="images/tfc-workspace2.png" width="500" height="600" />

Leave the rest of the options as default and click `Create`.

<img src="images/tfc-workspace3.png" width="500" height="400" />

Almost done. In order to deploy resources to AWS, we need to provide Terraform Cloud with AWS credentials. We need to add our credentials as workspace variables. Click `Continue to workspace overview` to do continue. 

![](images/tfc-workspace-created.png)

Click `Configure variables`

<img src="images/tfc-configure-variables.png" width="700" height="450" />

Add variables for `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. Ensure you select `Environment variables` for both and that `AWS_SECRET_ACCESS_KEY` is marked as `Sensitive`.

![](images/tfc-vars1.png)

Review the variables then return the your workspace overview when finished.

![](images/tfc-vars2.png)

Terraform Cloud is now configured and our pipeline is ready to go. Let's test this out by submitting a pull request.


## Block a Pull Request, Prevent a Deployment
We have now configured a GitHub repository to be scanned with checkov and to trigger Terraform Cloud to deploy infrastructure. Let's see how this works in action.

Create a new file in the GitHub UI under the path `code/build/s3.tf`. Enter the following code snippet into the new file. 


```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "dev_s3" {
  bucket_prefix = "dev-"

  tags = {
    Environment      = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "dev_s3" {
  bucket = aws_s3_bucket.dev_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

```

Once complete, click `Commit changes...` at the top right, then select `Create a new branch and start a pull request` and click `Propose changes`.

![](images/gh-pr.png)

At the next screen, review the diff then click `Create pull request`.

![](images/gh-create-pr.png)

One more time... click  `Create pull request` to open the PR.

![](images/gh-open-pr.png)

Wait for the checks to run. Then take note of the result: a blocked pull request!

![](images/gh-blocked-pr.png)

Either bypass branch protections and `Merge pull request` or go back to the GitHub Action for checkov and uncomment the line with `--soft-fail=true`. This will require closing and reopening the pull request.

> **⍰  Question** 
>
> What other command options could be used to get the pipeline to pass?


## Deploy to AWS
Navigate to Terraform Cloud and view the running plan.

![](images/tfc-run-queued.png)

Once finished, click `Confirm & apply` to deploy the s3 bucket to AWS.

![](images/tfc-apply.png)

Go to the S3 menu within AWS to view the bucket that has been deployed.

![](images/aws-s3.png)


> **⍰  Question** 
>
> Given that we only supplied the s3 bucket with a prefix and not a specific bucket name, how can you tell which s3 bucket is the one *you* deployed?

> [!TIP]
> We used a tool to tag IaC resources...


Now let's see how we can leverage Prisma Cloud to make this all easier, gain more featues and scale security at ease.

##
# Section 2: Application Security with Prisma Cloud
> [!NOTE]
> *This portion of the workshop is intended to be view-only. Those with existing access to Prisma Cloud can follow along but is not recommended to onboard any of the workshop content into a production deployment of Prisma Cloud. Use this guide as an example and the content within for demonstration purposes only.*

## Welcome to Prisma Cloud
![](images/prisma-welcome.png)

Prisma Cloud is a Cloud Native Application Protection Platform (CNAPP) comprised of three main pillars:
- Cloud Security
- Runtime Security
- Application Security

Across these three "modules", Prisma Cloud provides comprehensive security capabilities spanning code to cloud. This workshop will mainly focus on the Application Security module within the Prisma Cloud platform.

## Onboard AWS Account
> [!NOTE]
> Link to docs: [Onboard AWS Account](https://docs.prismacloud.io/en/enterprise-edition/content-collections/connect/connect-cloud-accounts/onboard-aws/onboard-aws-account)

To begin securing resources running in the cloud, we need to configure Prisma Cloud to communitcate with a CSP. Let's do this by onboarding an AWS Account.

Navigate to **Settings > Providers > Connect Provider** and follow the instructions prompted by the conifguration wizard.

![](images/prisma-cloud-account.png)

Select **Amazon Web Services**.

![](images/prisma-csp-onboarding.png)

Choose **Account** for the scope, deselect **Agentless Workload Scanning**, leave the rest as default and click **Done**.

![](images/prisma-aws1.png)

Provide your **Account ID** and enter an **Account Name**. Then click **Create IAM Role** to have Prisma Cloud auto-configure itself.

![](images/prisma-aws2.png)

Scroll to the bottom of the AWS page that opens, click to **acknowledge** the disclaimer and then click **Create stack**.

![](images/aws-create-stack.png)

Wait a moment while the stack is created, we need an output from the final result of the stack being deployed.

![](images/prisma-cfn.png)

Once created, go to the **Outputs** tab and copy the value of ARN displayed.

![](images/prisma-cfn-output.png)

Head back to Prisma Cloud and paste this value into the **IAM Role ARN** field, then click **Next**.

![](images/prisma-aws3.png)

Wait for the connectivity test to run, review the status and click **Save and Close**.

![](images/prisma-aws4.png)

View the onboarded cloud account under **Settings > Providers**.

![](images/prisma-aws-added.png)

Prisma Cloud will now begin to scan the configured AWS Account for misconfigurations associated with deployed resources. Let the initial scan run in the background and we will come back to this in a later section.

## Integrations and Providers
Prisma Cloud has a wide variety of built-in integrations to help operationalize within a cloud ecosystem.

Navigate to `Settings` at the top, then select `Providers` from the left sidebar. Click the `Connect Provider` button on the top right.

![](images/prisma-code-build-providers.png)

Notice all of the different tools that can be integrated natively.

![](images/prisma-connect-providers.png)

Let's start by integrating with checkov.


## Checkov with API Key
> [!NOTE] 
> Link to docs: [Creating Access Keys for Prisma Cloud](https://docs.prismacloud.io/en/enterprise-edition/content-collections/administration/create-access-keys)
>
> Link to docs: [Add Checkov to Prisma Cloud](https://docs.prismacloud.io/en/classic/appsec-admin-guide/get-started/connect-your-repositories/ci-cd-runs/add-checkov)

To generate an API key, navigate to **Settings > Access Control**. Click the `Add` button and select `Access Key`.

![](images/prisma-access-control.png)

Download the csv file containing the credentials then click `Done`.

<img src="images/prisma-create-access-key.png" width="400" height="300" />



![](images/prisma-access-key-created.png) 

In a terminal window run checkov against the entire `code` directory, now with an API key. Use the following command:

> [!WARNING]
> Replace the `access_key_id`, `secret_key` and `prisma-api-url` with your values.

```
checkov -d . --bc-api-key <access_key_id::<secret_key> --repo-id prisma/devsecops-workshop --prisma-api-url https://api4.prismacloud.io
```

![](images/c9-checkov-api-key.png)

Notice how the results now contain a severity. There are some other features that come with Prisma Cloud (using an API key) as well... 

Return back to Prisma Cloud to view the results that checkov surfaced in the platform. Navigate to **Application Security > Projects**.

![](images/prisma-checkov-results.png)

Let's add this same API key to the GitHub Action created earlier. Within your GitHub repository, go to **Settings > Secrets and variables** then select **Actions**. 

![](images/GitHub-secrets.png)

Click `New repository secret` then input the secret value of `<access_key_id>::<secret_key>` pair.

![](images/github-repo-secret.png)

![](images/github-create-secret.png)

Edit `checkov.yaml`, remove comments for `api-key` and `PRISMA_API_URL`.

![](images/gh-edit-checkov.png)

Commit directly to main branch.

<img src="images/gh-commit-directly.png" width="375" height="400" />

Now check the results under **Security > Code scanning**. The same findings that displayed here earlier now with a **Severity** to sort and prioritze with.

![](images/gh-security-results.png)

Return again to Prisma Cloud to view the results that were sent to the the platform.

![](images/prisma-gha-results.png)

> [!TIP]
> You can use Prisma Cloud (checkov w/ an API key) to scan docker images for vulnerabilities! Use the `--docker-image` flag and point to an image name or ID.

## Terraform Cloud Run Tasks
> [!NOTE] 
> Link to docs: [Connect Terraform Cloud - Run Tasks](https://docs.prismacloud.io/en/enterprise-edition/content-collections/application-security/get-started/connect-code-and-build-providers/ci-cd-runs/add-terraform-run-tasks)

Let's now connect Prisma Cloud with Terraform Cloud using the Run Tasks integration. This allows for developers and platform teams to get immediate security feedback for every pipeline run. The Run Task integration will also surface results of every pipeline run to Prisma Cloud and the Security team.

First we need to create an API key in Terraform Cloud. Go to the Terraform Cloud console and navigate to **User Settings > Tokens** then click **Create an API Token**.

![](images/tfc-create-token.png)

Name the token something meaningful, then click **Generate token**.

![](images/tfc-token-created.png)

Copy the token and save the value somewhere safe. This will be provided to Prisma Cloud in the next step.

Go to the Prisma Cloud console and navigate to **Settings > Connect Provider > Code & Build Providers** to set up the integration.

![](images/prisma-code-build-providers.png)

Under **CI/CD Runs**, choose **Terraform Cloud (Run Tasks)**.

<img src="images/prisma-tfc-rt.png" width="600" height="500" />

Enter the API token generated in Terraform Cloud and click **Next**.

<img src="images/prisma-tfc-token.png" width="600" height="500" />

Select your **Organization**.

<img src="images/prisma-tfc-org.png" width="600" height="500" />

Select your **Workspace** and choose the **Run Stage** in which you want Prisma Cloud to execute a scan. `Pre-plan` will scan HCL code, `Post-plan` will scan the Terraform plan.out file.

<img src="images/prisma-tfc-workspace.png" width="600" height="500" />

> **⍰  Question** 
>
> What are some advantages and/or limitations between scanning HCL files and scanning plan.out files?

Once completed, click **Done**.

<img src="images/prisma-tfc-done.png" width="600" height="500" />

Return back to Terraform Cloud to view the integration. Go to your **Workspace** and click **Settings > Run Tasks**. 

![](images/tfc-run-task-created.png)



## GitHub Application
> [!NOTE] 
> Link to docs: [Connect GitHub](https://docs.prismacloud.io/en/enterprise-edition/content-collections/application-security/get-started/connect-code-and-build-providers/code-repositories/add-GitHub)


Next we will set up the Prisma Cloud GitHub Application which will perform easy-to-configure code scanning for GitHub repos.

Go to Prisma Cloud and create a new integration under **Settings > Connect Provider > Code & Build Providers**.

![](images/prisma-code-build-providers.png)

Under **Code Repositories**, select **GitHub**. 

<img src="images/prisma-gh-app.png" width="600" height="500" />

Follow the install wizard and **Authorize** your GitHub account.

<img src="images/prisma-gh-auth.png" width="600" height="500" />

Select the repositories you would like to provide access to and click **Install & Authorize**.

<img src="images/gh-select-repos.png" width="400" height="700" />

Select the target repositories to scan now accessible from the Prisma Cloud wizard, then click **Next**.

<img src="images/prisma-select-repos.png" width="600" height="500" />

Click **Done** once completed. Navigate to **Settings > Providers > Repositories** to view the onboarded repo(s). 

![](images/prisma-gh-done.png)

Also navigate to **Application Security > Projects** to view the results coming from the integration.

![](images/prisma-gh-app-results.png)

## Submit a Pull Request 2.0

Lets push a change to test the integration. Navigate to GitHub and make a change to the s3 resource deployed earlier under `code/build/s3.tf`.




Add the following line of code to the s3 resource definition. Then click **Commit changes...** once complete.

```
acl = "public-read-write"
```

![](images/gh-edit-s3.png)


Create a new branch and click **Propose changes**.

<img src="images/gh-propose-changes.png" width="450" height="525" />

On the next page, review the diff then click **Create pull request**. Once gain, click **Create pull request** to open the pull request.

Let the checks run against the pull request. Prisma Cloud can review pull requests and will add comments with proposed changes to give developers actionable feedback within their VCS platform.

![](images/gh-prisma-comments.png)


 When ready, click **Merge pull request** bypassing branch protection rules if still enabled.


Now that the change has been merged, navigate back to Terraform Cloud to view the pipeline running.

![](images/tfc-plan-running.png)


Check the **Post-plan** stage and view the results of the Prisma Cloud scan.

![](images/tfc-post-plan.png)

Leave this as is for now. We will soon fix the error and retrigger the pipeline.


## View scan results in Prisma Cloud
Return to Prisma Cloud to view the results of all the scans that were just performed.

Navigate to **Application Security > Projects > Overview** to view findings for all scans. Filter the results with the **Repository** drop-down menu.

![](images/prisma-appsec-projects.png)

View relevant CI/CD Risks **Application Security > CI/CD Risks**:

![](images/prisma-cicd-risks.png)

Get a full SBOM analysis under **Application Security > SBOM**:

![](images/prisma-sbom.png)


Take a look at **Dashboards > Code Security** to get top-level reports.

![](images/prisma-dashboard-code.png)

Another useful view can be found under **Inventory > IaC Resources**

![](images/prisma-inventory.png)

## Enforcement Rules

The level of enforcement applied to each code scan can be controlled under **Settings > Configure > Application Security > Enforcement Rules**

![](images/prisma-enforcement-rules.png)

These can be adjusted as a top-down policy or exceptions can be created for specific repositories / integrations.

![](images/prisma-enforcement-rules1.png)

![](images/prisma-enforcement-rules2.png)

![](images/prisma-enforcement-rules3.png)



## Issue a PR-Fix
Lets create a pull request from the Prisma Cloud console to apply a code fix. Navigate to **Application Security > Projects > Overview IaC Misconfiguration** then find the `dev_s3` bucket with the public access violations.

![](images/prisma-pr-fix1.png)

Then click the **Submit** button in the top right to open a pull request.

![](images/prisma-pr-fix2.png)

Navigate back to GitHub and check the **Pull request** tab to see the fix Prisma Cloud submitted.

![](images/gh-pr-fix1.png)

Drill into the pull request and inspect the file changes under the **Files changes** tab. Notice the changes made to remediate the original policy violation.

![](images/gh-pr-fix2.png)

Go back to the **Coversation** tab and click **Merge the pull request** at the bottom to check this code into the main branch.

![](images/gh-merge-pr-fix.png)

Check Terraform Cloud to view the plan succesfully run. No need to apply this run as we will use the earlier deployment for our next example.

![](images/tfc-pr-fix.png)


## Drift Detection
> [!NOTE]
> Link to docs: [Setup Drift Detection](https://docs.prismacloud.io/en/classic/appsec-admin-guide/get-started/drift-detection)

In this final section, we will use the pipeline we built to detect drift. Drift occurs when infrastructure running in the cloud becomes configured differntly from what was originally defined in code.

This usually happens during a major incident, where DevOps and SRE teams make manual changes to quickly solve a problem, such as opening up ports to larger CIDR blocks or turning off HTTPS to find the problem. Sometimes lack of access and/or familiarity with IaC/CICD makes fixing an issue directly in the cloud easier than fixing in code and redeploying. If these aren’t reverted, they present security issues and it weakens the benefits of using IaC.

We will use the S3 bucket deployed earlier to simulate drift in a resource configuration.

> [!NOTE]
> By default Prisma Cloud performs full resource scans on an hourly interval. 


Let's first examine the policies associated with drift. Go to **Governance > Overview** and serach for `Traced resources are manually modified`. Notice the policies for each CSP. Ensure the policy for AWS is enabled.

![](images/prisma-traced-resource-policies.png)

Next, go to the AWS Console under S3 buckets and add a new tag to the bucket created earlier.

![](images/aws-s3-properties.png)

For example, add a tag with the key/value pair `drift` = `true` and click **Save changes**.

![](images/aws-tag-drift.png)

On the next scan Prisma Cloud will detect this change and notify users that a resource configuration has changed from how it is defined in code. To view this, navigate to **Projects > IaC Misconfiguration** and filter for **Drift** under the **IaC Categories** dropdown menu.

![](images/prisma-drift-result.png)

Prisma Cloud provides the option to revert the change via the same pull request mechanism we just performed which would trigger a pipeline run and patch the resource.



# Wrapping Up
Congrats! In this workshop, we didn’t just learn how to identify and automate fixing misconfigurations — we learned how to bridge the gaps between Development, DevOps, and Cloud Security. We are now equipped with full visibility, guardrails, and remediation capabilities across the development lifecycle. We also learned how important and easy it is to make security accessible to our engineering teams.

Try more of the integrations with other popular developer and DevOps tools. Share what you’ve found with other members of your team and show how easy it is to incorporate this into their development processes. 

You can also check out the [Prisma Cloud DevDay](https://register.paloaltonetworks.com/securitydevdays) to experience more of the platform in action.
