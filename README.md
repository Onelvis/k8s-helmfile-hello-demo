# k8s-helmfile-hello-demo

This repository shows a demo of a AKS cluster with a modified version of the [nginxdemos/hello](https://hub.docker.com/r/nginxdemos/hello/) docker image, which includes both an environment variable and the value of a secret stored in Azure's Key Vault.

## Prerequisites
1. An Azure account and create a Service Principal with a Client Secret, you can follow the instructions in [Terraform provider's auth methods](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
2. An Azure storage account and a container for the Terraform state storage.

## How to run (Github Actions)

1. Clone/Fork this repository
2. Create a `dev.tfvars` file, you can do so by using this demo's `dev.tfvars.example` file: 
```bash
cp ./terraform/tfvars/dev.tfvars.example cp ./terraform/tfvars/dev.tfvars`
```
3. Create a `backend.config`, this is necesary for the terraform init, since the backend is configured to use Azure Storage Account for state management.
```bash
# Make sure to populate the resource_group_name and storage_account_name with your own values!

cp ./terraform/backend.config.example cp ./terraform/backend.config`
```
4. Create a GitHub Actions secret named `AZURE_CREDENTIALS`, the definition format is shown in the [action's documentation](https://github.com/Azure/login?tab=readme-ov-file#login-with-a-service-principal-secret)
5. Create the following Github Action secrets:
```text
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
AZURE_STORAGE_ACCOUNT_ACCESS_KEY
```
6. Push your changes, the Actions will fire on the `main` branch, they will plan and apply your changes (Beware, this will create an AKS cluster based on the configurations you provided on your `dev.tfvars` file)

## How to run (Locally)

1. Follow the steps 1-3 of the [How to run (Github Actions)](#How-to-run-(Github-Actions))

2. cd into the `terraform` directory

3. Initiate the providers: 

`terraform init -backend-config="./backend.config" -input=false`

4. Run the plan: 

`terraform plan -var-file="./tfvars/dev.tfvars"`

5. If you are ok with the changes, apply: 

`terraform apply -var-file="./tfvars/dev.tfvars" -auto-approve`

6. This will create all the resources, specially the ACR that we'll need for the docker image steps

7. Once created, `az login` into the same account that the ACR lives

8. Now login into acr: 

`az acr login --name <name of the acr>`

9. Build, tag and push the image

```bash
docker build -t hellochallenge:latest .
docker tag hellochallenge:latest <acr login server url>/challenge/hellochallenge:latest
docker push <acr login server url>/challenge/hellochallenge
```

## Helmfile

Once you obtain the `kubeconfig` from the AKS, go ahead and cd into the helm directory. There are two value files, you can modify them at will.

Have in mind that the secret ref you provide must come from an existing secret in Azure, and the AKS needs permission to read from that secret. I've configure the secret with the ones created by terraform in the above steps (Assuming you used the same values that are on the `dev.tfvars.example` file).


Once you configured your `.kube/config` file, you are ready to run:

```bash
# On the helm directory

helmfile -e dev apply
helmfile -e stg apply
```

Get the k8s service's IP, and see the result:

```bash
kubectl get svc

NAME         TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
hello        LoadBalancer   10.0.103.28  copy this-> 134.33.154.147   80:31829/TCP   21h
kubernetes   ClusterIP      10.0.0.1      <none>           443/TCP        36h
```

## Questions

> How to change the stage that Github Actions deploys?

Change the environment variable defined in line `162` of `provision-infra.yaml`, or implement a branch or path filtering approach.