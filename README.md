*Jagan Lakshmipathy*  
*07-14-2024*  

### 1. Introduction
We will outline steps involved in running a sample machine learning job in a GPU Enhanced nodepool in Azure Kubernetes (AKS). Let's start with a caveat, the steps provided here are not cloud provider agnostic, particularly the Azure CLI commands.


### 2. Prerequesites
We assume that the kubernetes cluster is up and running for us to be able to run the GPU workloads. We assume you have a good understanding of Azure. Please follow [here](https://azure.microsoft.com/en-us/get-started). 

We refer you to learn about Azure Kubernetes Service (AKS) from [here](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli). Also we refer to [here](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli) on how to request vCPU quotas from azure portal. If you would like to learn about different compute options in Azure please review this [link](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview?tabs=breakdownseries%2Cgeneralsizelist%2Ccomputesizelist%2Cmemorysizelist%2Cstoragesizelist%2Cgpusizelist%2Cfpgasizelist%2Chpcsizelist). In this example we will use two types of vCPUs Standard_D4ds_v5 and Standard_NC40ads_H100_v5. We will use the D4ds_v5 CPUs to run the kubernetes system workloads and NC40ads_H100_v5 CPUs to run the GPU workloads. In our example we run a simple Machine Learning example on the GPU.  We assume you have a reasonable understanding of Azure Cloud Platform. We are also assume you have a fairly good understanding of Kubernetes. We refer you [here](https://kubernetes.io/docs/setup/) if you like to learn about Kubernetes. We assume you also have a fair understanding of github. Please clone this [repo](www.github.com) to your local. 

We will be using MacOS to run the kubernetes commands and Azure CLI commands using bash shell. You can follow along with your prefered host, operating system and shell.


### 3. Lets Get Started
We assume that the kubernetes cluster is up and running for us to be able to run the GPU workloads.The following are the steps:

1. Login to your Azure Portal and make sure the kubernetes cluster is up and running.You can also check the cluster from your bash console. 
```
bash> kubectl get pods 

```
2. 

