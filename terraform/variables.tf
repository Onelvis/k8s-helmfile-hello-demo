## General

variable "location" {
	type = string
	description = "Azure region where the resources will be deployed"
	default = "eastus"
}

variable "resource_group_name" {
	type = string
	description = "Name for the resource group to be created in Azure"
}

## AKS

variable "aks_cluster_name" {
	type = string
	description = "Name of the AKS cluster"
}

variable "aks_dns_prefix" {
	type = string
	description = "DNS prefix for the AKS cluster"
}

variable "aks_node_count" {
	type = number
	description = "Number of nodes in the AKS cluster"
	default = 1
}

## ACR

variable "acr_name" {
	type = string
	description = "Name of the Azure Container Registry"
}

## Key Vault

variable "keyvault_name" {
	type = string
	description = "Name of the Azure Key Vault"
}
