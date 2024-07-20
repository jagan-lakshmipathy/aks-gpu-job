<center> <h1> AKS GPU JOB </h1> </center>
<center> <h4> Jagan Lakshmipathy <h4> <h4> 07-14-2024 <c/enter> </h4> </center>


### 1. Introduction
This repo contains a well known working example of a simple machine learning job that will run in both CPU and GPU. We will demonstrate a step-by-step process on how to run the above mentioned simple machine learning workload in a GPU enhanced vCPU in Azure Kubernetes (AKS). Let's start with a caveat, the steps provided here are not cloud provider agnostic, particularly the Azure CLI commands. So, you will have to make necessary changes to suit the CLI of your preferred cloud vendor. Similarly, the bash scripts shown here have to be modified to suit your shell of choice.


### 2. Prerequesites
We assume that the kubernetes cluster is up and running for us to be able to run the GPU workloads. We also assume that you have a good understanding of Azure. If you would like to read about Azure please go [here](https://azure.microsoft.com/en-us/get-started). If you haven't done already installed Azure CLI, do install it as instructed in this [link](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli). 

We refer you to learn about Azure Kubernetes Service (AKS) from [here](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli). Also we refer to [here](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli) on how to request vCPU quotas from azure portal. If you would like to learn about different compute options in Azure please review this [link](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview?tabs=breakdownseries%2Cgeneralsizelist%2Ccomputesizelist%2Cmemorysizelist%2Cstoragesizelist%2Cgpusizelist%2Cfpgasizelist%2Chpcsizelist). In this example we will use two types of vCPUs Standard_D4ds_v5 and Standard_NC40ads_H100_v5. We will use the D4ds_v5 CPUs to run the kubernetes system workloads and NC40ads_H100_v5 CPUs to run the GPU workloads. Steps involved in requesting any other vCPUs with GPU will be very similar. In our example we run a simple Machine Learning example on the GPU.  We assume you have a reasonable understanding of Azure Cloud Platform. We are also assume you have a fairly good understanding of Kubernetes. Please do find the Kubernetes reading material from [here](https://kubernetes.io/docs/setup/). We assume that you also have a fairly good working knowledge of github. Please clone this [repo](www.github.com) to your local. Install kubectl, kubernetes cli tool, from [here](https://kubernetes.io/docs/tasks/tools/).

We will be using MacOS to run the kubernetes commands and Azure CLI commands using bash shell. You can follow along with your prefered host, operating system and shell.


### 3. Lets Get Started
We assume that the kubernetes cluster is up and running for us to be able to run the GPU workloads.The following are the steps:

1. Login to your Azure Portal and make sure the kubernetes cluster is up and running.You can also check the cluster from your bash console. For that to work we need to have the *kubectl* working. So go to Step 2, before you try out any *kubectl* commands. 

2. In order to issue kubectl commands to control AKS cluster from your local console we need to merge the credentials with the local kube config. Kubernetes config file is typically located under /Users/\<username\>/.kube/config in MacOS. The following azure cli command would merge the config. The second command lets you see the running pods in the cluster:

```
    bash> az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
    bash> kubectl get pods --watch

```

3. Following commands will add the aks-preview extension and register microsoft container service:

```
    bash> 	az extension add --name aks-preview
	bash> 	az extension update --name aks-preview
	
	bash> 	az feature register --namespace "Microsoft.ContainerService" --name "GPUDedicatedVHDPreview"
	bash> 	az feature show --namespace "Microsoft.ContainerService" --name "GPUDedicatedVHDPreview"
	bash> 	az provider register --namespace Microsoft.ContainerService

```
4. Now that your kubernetes cluster is up and running, lets add a nodepool with just one node with H100 GPU (check Azure documentation to see the Azure's latest offering). You can choose any GPU loaded vCPU from Azure offering that you are eligible to request as per your quota requirements. I tried these GPU loaded nodes Standard_NC24s_v3, and Standard_NC40ads_H100_v5 from the NCv3-series and NCads H100 v5-series familes respectively.

```
    bash> az aks nodepool add --resource-group <name-of-resource-group> --cluster-name <cluster-name> --name <nodepool-name> --node-count 2 --node-vm-size Standard_NC40ads_H100_v5 --node-taints sku=gpu:NoSchedule --aks-custom-headers UseGPUDedicatedVHD=true --enable-cluster-autoscaler --min-count 1 --max-count 3
    
```
5. We need an image to run as a job in AKS. We need a Azure Container Registry (ACR) to push your image. So, lets create a ACR, if you don't have it already. Here is the command:

```
    bash> az acr create --name <name-of-acr> --resource-group <resource-group-associated> --sku basic
```

6. We need to login to ACR before you can upload any images to ACR.

```
    bash> az acr login --name <name-of-acr>
```
7. Let's create a docker image that you would like to run as a GPU workload. Before you run the following commands that create the image. Browse the repo code and familarize yourself with the dockerfile and the python workload provided. Note the --platform directive below that enables to generate a AMD64 based image as I was running the following command in Apple Silicon host.

```
    bash> docker build  --platform="linux/amd64"  -t <your-tag-name:latest> .
```

8. Now that we already logged into the ACR, lets tag and push the image to the ACR.

```
    bash> docker tag <your-tag-name:latest> <acr-name>.azurecr.io/<your-tag-name>
    bash> docker push <acr-name>.azurecr.io/<your-tag-name>
```

9. Now that we have pushed the image to the ACR, we have to now attach that ACR to the cluster so that our job can access the ACR to pull the image from. We use the following command.

```
    bash> az aks update --name <aks-cluster-name> --resource-group <aks-rg-name>  --attach-acr <name-of-acr-to-attach>
```

10. Create a job manifest that refers to the pushed image. A template job manifest is provided "pytorch-demo.yaml" in the repository. Feel free to browse the content. Pay particular attention to the image, imagePullPolicy, and resources fields under job.spec. You have to customize it to your needs. Also, pay attention to the Job.spec.tolerations. It basically refers to the node pool created in step 4.


11. Run the job as follows:

```
    kubectl apply -f pytorch-demo.yaml
```

12. Now the job is running you can monitor/troubleshoot the job with the following commands:

```
    kubectl get pods --watch
    kubectl logs <pod-id>
    kkubectl describe pod <pod-id>
```
