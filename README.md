<img src="https://user-images.githubusercontent.com/71599740/140194394-8d8b8fe8-a7d6-4b2b-938e-e5b00dea3bd4.png" width="130" height="100"/>

---

![This is an image](provisioning_infrastructure_with_terraform.png)

---

# Description

in this template we are building an Elastic High Availability
virtual network on azure with terraform code.
on that infrastructure we are going to deploy a Node.js Weight Trackerr App.

**an explanation on the way the app is deploied and it's dependacies can be found in this link** [Node.js Weight Tracker](https://github.com/odedrafi/bootcamp-app).

---

## Notes

In this project we will demostrate an elastic high avalibility network on azure cloud provisined with terraform. I also add a contoller machine in the web tier to configure the app.

As part of a DevOps bootcamp is sela accademy [Sela DevOps Bootcamp Page](https://rhinops.io/bootcamp).

It includes:

- a module that deploys a linux virtual machine scale set with auto scailing
- a load balancer to handle the traffic
- a use of a config script to load up the app on the web servers
- a fully automated code for a plug and play setup of infrastructure and app.
- An azure postgrers flexible data server

---

### Enviroment goals

![Enviroment goals](week-6-envs.png)

## Deployment

First you need to install terraform and connect to azure provider as explained in
[Install Terraform - HashiCorp Learn](https://learn.hashicorp.com/tutorials/terraform/install-cli).

Inorder to tun the template you will need to create an (Enviroment).tfvar file to update your secret data.

for the Staging enviroment:
![This is an image](StagingVarsImg.png)

for the Production enviroment:
![This is an image](ProductionVarsImg.png)

Using git, clone the repository to your local machine.

_and run the foolowing commmand:_

- Initialize Terraform working directory

  terraform init

- To deploy the enviroment :

  > terraform plan -var-file Staging.tfvars

  > terraform apply -var-file Production.tfvars

- To destroy the enviroment:

  > terraform destroy
