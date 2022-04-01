![This is an image](provisioning_infrastructure_with_terraform.png)

# Description

in this template we are building an Elastic High Availability
virtual network on azure with terraform code.
on that infrastructure we are going to deploy a Node.js Weight Trackerr App.

**an explanation on the way the app is deploied and it's dependacies can be found in this link** [Node.js Weight Tracker](https://github.com/odedrafi/bootcamp-app).

---

## Notes

In this project we will demostrate an elastic high avalibility network on azure cloud provisined with terraform.

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

Inorder to tun the template you will need to create a terraform.tfvar file to update your secret data.

the parametrs can be seen in the example below:
![This is an image](2.png)

Using git, clone the repository to your local machine.

_and run the foolowing commmand:_

- Initialize Terraform working directory

  terraform init

- To deploy the enviroment:

  > terraform plan

  > terraform apply

- To destroy the enviroment:

  > terraform destroy
