# Building Microservices with AWS and HashiCorp

# Laying the Foundations of a Microservices Architecture

These notes cover the [episodes of a series](https://www.youtube.com/playlist?list=PL81sUbsFNc5bXfbscI9dYj0p3cvagLqFn) on building a microservices architecture using AWS and HashiCorp’s Terraform. The focus is on establishing the groundwork, from setting up a Terraform project to provisioning a Virtual Private Cloud (VPC) and ECS for containerized services on AWS. We'll also have to configure the ALB and private subnets and connect services to the database among other things. Later on, we'll refactor what we have to include a service mesh with Consul. In the end, we ought to have a microservices like the one shown below:

![finalized_microservice_architecture](../images/aws-consul-ecs-finalized-architecture.png)

## Microservices and Service Mesh Architecture Overview

This section introduces the rationale for microservices architecture and the tools used to build it while also discussing the role of a service mesh.

### Purpose of Microservices

Microservices split an application into small, independent services, each handling a specific function. This enables teams to work on separate services without affecting the entire system, improving agility and scalability. The architecture in this series includes a client service, exposed via an Application Load Balancer (ALB), connecting to backend services (fruits and vegetables) and a database, all within a private network.

Each service (e.g., fruits, vegetables) handles a specific task, reducing dependencies compared to a monorepo. This supports large teams and multi-region deployments.

### Service Mesh Role

A service mesh, like Consul, standardizes service-to-service communication, authentication, and security. It eliminates the need for individual load balancers and firewall rules per service, simplifying scalability. The series will first build without a mesh, then refactor to demonstrate Consul’s benefits.

### Tools: Terraform and AWS

Terraform, a configuration language (HCL), defines and provisions infrastructure as code. AWS provides the cloud environment, with services like ECS (Elastic Container Service) for running containers. Together, they enable repeatable, version-controlled infrastructure setup. The demo uses a fake service to simulate backend services, focusing on infrastructure rather than application code.

### Architecture Design

The planned architecture consists of:

- **Client Service:** This is the entry point, exposed publicly via an application load balancer. It’s not just a front-end UI but a service that aggregates data from backend services (like fruits and vegetables) and presents it to users or APIs.
- **Backend Services:** Fruits and vegetables are example services running in private subnets, talking to a database. We’re using a tool called [fake service](https://github.com/nicholasjackson/fake-service) to mock these services, so we can focus on infrastructure rather than writing app code.

  ![fake-service-interface](../images/fake-service-interface.png)

- **Database:** The “grocery” database stores data for all services. It’s private and only accessible by the services.

The initial build avoids a service mesh, but a future refactor will incorporate HashiCorp’s Consul to simplify service communication.

![basic-microservice](../images/section-1-architecture.png)

## Terraform Fundamentals

This section covers the basics of setting up and using Terraform to manage AWS resources.

### Project Structure

A Terraform project is a directory containing `.tf` files that define resources. Terraform processes all files in the directory, regardless of naming or order, offering flexibility in organization. The project starts with a `main.tf` file, later splitting resources into separate files for clarity.

### Providers

Providers connect Terraform to external platforms like AWS. The AWS provider allows creation of AWS resources. Other providers, like TLS or random, can be used for tasks such as generating keys or UUIDs.

```py
# File: main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}
```

- `required_providers`: Specifies the AWS provider and version.
- `provider "aws"`: Configures the provider, setting the region via a variable.

### Workflow

Terraform’s workflow involves three steps:

1. **Write**: Define resources in `.tf` files.
2. **Plan**: Run `terraform plan` to preview changes.
3. **Apply**: Run `terraform apply` to create or update resources in AWS.

The `terraform init` command initializes the project, downloading providers. The AWS CLI, configured with credentials, enables Terraform to make API calls to AWS.

### Creating a VPC

The first resource is a VPC, a private network for hosting services. The initial setup defines a VPC with a hardcoded CIDR block:

```py
# File: main.tf
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}
```

Running `terraform init`, `plan`, and `apply` creates the VPC, visible in the AWS Console. The `/16` CIDR provides a large IP range, later adjusted for a smaller scope.

## Enhancing Reusability

To make the code flexible and maintainable, variables and file organization are introduced.

### Input Variables

Variables allow configuration without hardcoding values. A `variables.tf` file defines inputs for the region and VPC CIDR block:

```py
# File: variables.tf
variable "region" {
  type        = string
  description = "AWS region for the infrastructure"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.255.0.0/20"
}
```

The `main.tf` file references these variables:

```py
# File: main.tf
provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}
```

- `var.<variable_name>` references the variable.
- The `/20` CIDR reduces the IP range for a smaller VPC.
- Defaults prevent repetitive input during `terraform apply`.

### File Organization

The VPC resource is moved to a `vpc.tf` file for better organization:

```py
# File: vpc.tf
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}
```

Terraform automatically processes all `.tf` files, building a dependency graph to manage resource relationships. Terraform ignores subdirectories unless used for modules. Typically for larger project when the flat structure becomes unwieldy, modularization is preferable.

### Default Tags

Default tags ensure consistent metadata across resources. A map variable defines tags:

```py
# File: variables.tf
variable "default_tags" {
  type        = map(string)
  description = "Default tags for all resources"
  default     = {
    project = "learning-live-with-aws-hashicorp"
  }
}
```

The `main.tf` file applies these tags to all resources:

```py
# File: main.tf
provider "aws" {
  region = var.region
  default_tags {
    tags = var.default_tags
  }
}
```

Running `terraform apply` adds the `project` tag to the VPC, visible in the AWS Console.

## Virtual Private Cloud (VPC) Overview

A Virtual Private Cloud (VPC) is a private network within the AWS cloud, isolating resources from other networks and the internet.

### Key Components

- **IP Address Range (CIDR Block)**: Defines the range of IP addresses for resources within the VPC.
- **Subnets**: Segments of the VPC's IP range, divided into public and private subnets.
- **Internet Gateway**: Enables internet access for resources in public subnets.
- **Network Address Translation (NAT) Gateway**: Allows private subnet resources to access the internet for updates or package installations.
- **Route Tables**: Direct traffic between resources, subnets, and the internet.
- **Security Groups and Network Access Control Lists (ACLs)**: Provide security layers to control access to resources.

### City Analogy

The diagram below provides a visual representation of a VPC using a city analogy:

![vpc_analogy](../images/vpc_analogy.png)

- **VPC**: Represents a city, with the CIDR block as the range of postal codes.
- **Subnets**: Individual blocks within the city.
- **Route Tables**: Roads directing traffic within the city.
- **Internet Gateway**: An on-ramp to the internet.
- **NAT Gateway**: An on-ramp for private subnets to access the internet.
- **Services**: Buildings within the city.
- **Security Groups**: Security guards at buildings.
- **Network ACLs**: Gates controlling access to city blocks.

### Workflow for Building a VPC in Terraform

The process mirrors the AWS Management Console workflow, using Terraform documentation to map console inputs to Terraform arguments.

#### Steps

1. **Start with the AWS Console**: Identify required fields for creating a VPC (e.g., name tag, IPv4 CIDR block, tenancy).
2. **Map to Terraform Docs**: Locate the `aws_vpc` resource in the Terraform AWS provider documentation and use the argument reference to fill in required fields.
3. **Add Additional Fields**: Include settings like DNS support and hostnames, not always prompted in the console but critical for functionality.

#### Example: Creating a VPC

The following Terraform code sets up a VPC with a name tag, IPv4 and IPv6 CIDR blocks, default tenancy, and DNS settings.

```py
# File: main.tf

resource "aws_vpc" "main" {
  cidr_block           = "10.255.0.0/20"
  assign_generated_ipv6_cidr_block = true
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.default_tags.project}-vpc"
  }
}
```

### Creating Subnets

Subnets divide the VPC’s IP range into smaller segments, categorized as public or private.

#### Public Subnet Configuration

- **Purpose**: Hosts resources accessible from the internet.
- **Key Settings**:
  - Associate with the VPC using `vpc_id`.
  - Define a smaller CIDR block using the `cidrsubnet` function.
  - Enable public IP and IPv6 address assignment on resource launch.
  - Specify an availability zone for high availability.

**Using the `cidrsubnet` Function**

The `cidrsubnet` function carves out a smaller CIDR block from the VPC’s CIDR block:

- **Syntax**: `cidrsubnet(cidr_block, newbits, netnum)`
  - `cidr_block`: The VPC’s CIDR block (e.g., `10.255.0.0/20`).
  - `newbits`: Additional bits for the subnet mask (e.g., `4` to create a `/24` subnet).
  - `netnum`: Identifies the subnet (e.g., `0` for the first subnet).

#### Example: Public Subnet

```py
# File: main.tf

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, 0) 
  ipv6_cidr_block         = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 0)
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.default_tags.project}-public-${
              data.aws_availability_zones.available.names[0]}"
  }
}
```

### Using Data Sources

Data sources query AWS for information, such as available availability zones, to make configurations dynamic.

#### Example: Querying Availability Zones

```py
# File: data.tf

data "aws_availability_zones" "available" {
  state = "available"
}
```

This data source retrieves a list of available availability zones in the current region, used in the subnet configuration to assign an availability zone dynamically.

### Route Tables and Routes

Route tables direct traffic within the VPC and to external networks.

#### Route Table Configuration

- Associate with the VPC using `vpc_id`.
- Add a name tag for console visibility.

#### Route Configuration

- Associate with a route table using `route_table_id`.
- Specify a destination CIDR block (e.g., `0.0.0.0/0` for all traffic).
- Point to an internet gateway using `gateway_id`.

#### Route Table Association

- Links a subnet to a route table to apply routing rules.

#### Example: Route Table, Route, and Association

```py
# File: main.tf

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.default_tags.project}-public"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

### Internet Gateway

An internet gateway enables public subnets to access the internet.

#### Configuration

- Attach to the VPC using `vpc_id`.
- Add a name tag for identification.

#### Example: Internet Gateway

```py
# File: main.tf

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.default_tags.project}-igw"
  }
}
```

**Terraform Dependency Management**

Terraform automatically manages resource dependencies, creating resources in the correct order based on references (e.g., `aws_vpc.main.id`). Explicit dependency control is possible using the `depends_on` attribute, covered in later sections.
