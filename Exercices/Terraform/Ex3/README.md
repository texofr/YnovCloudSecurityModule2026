# Ex3 - Terraform modulaire + ACR + Web App conteneurisee

## Objectif
Ce dossier deploie, avec Terraform modulaire:
- un Azure Container Registry (ACR)
- une Azure Linux Web App qui consomme une image Docker stockee dans ACR

Une pipeline GitHub Actions est fournie pour:
- deployer/configurer les ressources Azure via Terraform
- builder l'image Docker depuis `app/app.js` avec le `docker/Dockerfile`
- pousser l'image dans ACR
- redemarrer la Web App pour prendre la derniere image

## Structure
- `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`
- `modules/acr` : module ACR
- `modules/webapp` : module App Service Plan + Linux Web App
- `.github/workflows/ex3-terraform-acr-webapp.yml` : pipeline CI/CD

## Prerequis OIDC (managed identity)
La pipeline utilise `azure/login` en OIDC avec:
- `AZURE_CLIENT_ID` = Client ID de l'identite user-assigned `mi-ynov-labo-epe`
- `AZURE_TENANT_ID` = Tenant ID
- `AZURE_SUBSCRIPTION_ID` = Subscription ID

Le workflow est configure avec l'environnement GitHub `dev`.
Le `Subject identifier` du Federated Credential doit donc etre:
- `repo:texofr/YnovCloudSecurityModule2026:environment:dev`

A configurer cote Azure avant execution:
1. Creer un Federated Credential sur l'identite `mi-ynov-labo-epe` pour le repo GitHub.
2. Donner a cette identite les roles suffisants sur le scope cible (au minimum Contributor, et User Access Administrator si creation de role assignments).
3. Creer l'environnement GitHub `dev` dans le repository (Settings > Environments).

## Deploiement local
```bash
terraform init
terraform validate
terraform plan
terraform apply
```

A executer depuis `Exercices/Terraform/Ex3`.
