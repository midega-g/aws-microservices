# AWS Microservices Architecture Learning Project

This repository contains my implementation of a microservices architecture on AWS using Terraform, based on the concepts from the [*"Learning Live with AWS & HashiCorp"*](https://www.youtube.com/playlist?list=PL81sUbsFNc5bYnjraNpivm1XxR3WNM_Kd) series by HashiCorp.

The project demonstrates building microservices foundations from scratch - setting up Terraform infrastructure, creating a Virtual Private Cloud (VPC), and implementing containerized services on Amazon ECS.

*Credit: This implementation is inspired by the excellent tutorial series by [Jenna Pederson](https://twitter.com/jennapederson) and [J. Cole Morrison](https://twitter.com/JColeMorrison) from HashiCorp.*

## The Architecture

This project builds towards the following microservices architecture:

![Microservices Architecture on AWS](images/section-1-architecture.png)

Future iterations will refactor this architecture to incorporate a Service Mesh using HashiCorp Consul.

## Getting Started

#### Prerequisites

1. [AWS Account](https://aws.amazon.com/)
2. [HashiCorp Terraform](https://www.terraform.io/downloads) installed
3. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed
4. [AWS IAM User](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html) with Admin or Power User permissions
5. [Configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with your IAM credentials

#### Using this Code

1. Clone this repository
2. Run `terraform init` to initialize the project
3. Run `terraform plan` to preview infrastructure changes
4. Run `terraform apply` to create the AWS infrastructure
5. Run `terraform destroy` to clean up resources when finished

## Additional Tools

This repository also includes:

- **YouTube Transcript Downloader** (`yttdownloader.py`) - A CLI tool for fetching YouTube video transcripts using the YouTube Transcript API

## Project Structure

- `vpc.tf` - Virtual Private Cloud configuration
- `variables.tf` - Input variables and configuration
- `main.tf` - Provider configuration and main setup
- `notes/` - Detailed learning notes and documentation
- `images/` - Architecture diagrams and visual references

## Learning Resources

Detailed notes and explanations covering the topics below can be found [here](notes/notes.md):

- Microservices architecture fundamentals
- Terraform basics and best practices
- AWS VPC concepts and implementation
- Service mesh introduction with Consul

---

*This is a learning project focused on understanding microservices architecture patterns and infrastructure as code with Terraform.*
