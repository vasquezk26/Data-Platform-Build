# Instructions for Testing Terraform in your own Terraform Workspace

1. **Navigate to Cloud Build Triggers:**
    - Go to the [Google Cloud Console](https://console.cloud.google.com/cloud-build/triggers).
    - Select your project.

2. **Create a New Trigger:**
    - Click **"Create Trigger"**.
    - Choose your source repository and select the event (e.g., push to branch, pull request).

3. **Configure Build Settings:**
    - In the **"Build Configuration"** section, select **"Cloud Build configuration file (yaml or json)"**.
    - Specify the path to the `cloudbuild_-_databricks.yaml` file.

4. **Set the Terraform Workspace Environment Variable (Optional):**
    - In the **"Environment variables"** section, add a new variable:
      - Name: `_TERRAFORM_WORKSPACE`
      - Value: `your_name`
    - If this variable is set, the build will use the specified Terraform workspace.

5. **Save and Enable the Trigger:**
    - Review your settings and click **"Create"**.

**Note:**  
If `_TERRAFORM_WORKSPACE` is not defined, the build will use the default Terraform workspace.