# Ex3 - Terraform modulaire + ACR + Web App conteneurisee

## Objectif
Ce dossier deploie, avec Terraform modulaire:
- un Azure Container Registry (ACR)
- une Azure Linux Web App qui consomme une image Docker stockee dans ACR

Une pipeline GitHub Actions est fournie pour:
- deployer/configurer les ressources Azure via Terraform
- builder l'image Docker depuis `app/app.js` avec le `docker/Dockerfile`
- scanner le code Terraform et/ou l'image Docker avec Trivy (selon le workflow choisi)
- pousser l'image dans ACR
- redemarrer la Web App pour prendre la derniere image
- detruire l'infrastructure Terraform pour nettoyer le lab

## Structure
- `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`
- `modules/acr` : module ACR
- `modules/webapp` : module App Service Plan + Linux Web App
- `.github/workflows/ex3-terraform-acr-webapp-no-scan.yml` : pipeline de deploiement simplifiee (sans scans)
- `.github/workflows/ex3-terraform-acr-webapp.yml` : pipeline de deploiement securisee (avec scans Trivy + gates)
- `.github/workflows/ex3-terraform-acr-webapp-destroy.yml` : pipeline de destruction (manuel)

## Workflows GitHub Actions
- `Ex3 Terraform and Docker Deploy without Scan`
  - declenchement manuel (`workflow_dispatch`)
  - parcours simple pour comprendre le flux technique de bout en bout
  - Terraform: `fmt -check`, `init`, `validate`, `plan`, puis `apply` (option `deploy=true`)
  - Docker: build, push ACR, restart Web App
  - aucun scan Trivy ni gate securite
- `Ex3 Terraform and Docker Deploy with Scan`
  - declenchement manuel (`workflow_dispatch`)
  - pipeline securisee avec scans Trivy IaC + image Docker
  - publication des rapports SARIF et artifacts
  - gates de securite optionnels (blocage sur `CRITICAL`)
  - options d'execution: `scan_type`, `severity_levels`, `enforce_gates`, `deploy`
- `Ex3 Terraform and Docker Destroy`
  - declenchement manuel (`workflow_dispatch`)
  - destruction Terraform avec confirmation obligatoire via l'input `confirm_destroy=destroy`

## Cheminement recommande pour bien comprendre
Pour progresser de facon pedagogique, utiliser les workflows dans cet ordre:

1. `Ex3 Terraform and Docker Deploy without Scan`
   - objectif: valider la mecanique Terraform + Docker + ACR + Web App, sans bruit de securite
2. `Ex3 Terraform and Docker Deploy with Scan`
   - objectif: ajouter la couche DevSecOps (rapports, gates, seuils de severite)
3. `Ex3 Terraform and Docker Destroy`
   - objectif: nettoyer l'environnement de lab

Ce cheminement permet de separer clairement:
- la comprehension du deploiement
- puis la comprehension des controles de securite

## Environnement GitHub `dev`
Nous utilisons un environnement GitHub nomme `dev` pour securiser les jobs de deploiement et de destruction.

Dans les workflows, chaque job principal declare:
- `environment: dev`

Cela permet:
- d'appliquer des regles d'environnement (approbation manuelle, restrictions de branche, etc.)
- d'emettre un token OIDC GitHub avec un `subject` lie a l'environnement
- d'aligner l'authentification Azure avec le Federated Credential configure sur la managed identity

## Comment l'environnement est utilise dans les workflows
Dans:
- `.github/workflows/ex3-terraform-acr-webapp-no-scan.yml`
- `.github/workflows/ex3-terraform-acr-webapp.yml`
- `.github/workflows/ex3-terraform-acr-webapp-destroy.yml`

Les jobs utilisent `environment: dev`, puis s'authentifient avec:
- `azure/login@v2`
- `client-id: ${{ secrets.AZURE_CLIENT_ID }}`
- `tenant-id: ${{ secrets.AZURE_TENANT_ID }}`
- `subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}`

Pour Terraform, les variables ARM OIDC sont aussi positionnees dans les jobs:
- `ARM_USE_OIDC=true`
- `ARM_CLIENT_ID`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`

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

## Configuration des secrets GitHub
Dans le repository GitHub, ajouter ces secrets (Settings > Secrets and variables > Actions):
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

Valeurs attendues:
- `AZURE_CLIENT_ID`: Client ID de la managed identity `mi-ynov-labo-epe`
- `AZURE_TENANT_ID`: ID du tenant Microsoft Entra
- `AZURE_SUBSCRIPTION_ID`: ID de la souscription Azure cible

## Configuration de la managed identity (OIDC)
Sur l'identite user-assigned `mi-ynov-labo-epe`:
- ajouter un Federated Credential avec:
	- Issuer: `https://token.actions.githubusercontent.com`
	- Audience: `api://AzureADTokenExchange`
	- Subject identifier: `repo:texofr/YnovCloudSecurityModule2026:environment:dev`
- attribuer les roles RBAC necessaires sur le scope cible:
	- `Contributor` (creation/mise a jour/suppression des ressources)
	- `User Access Administrator` (si Terraform cree des role assignments)

Sans cette configuration, `azure/login` et les commandes Terraform/Azure CLI ne pourront pas s'authentifier en OIDC.

## Backend Terraform Ex3

Ex3 utilise un backend distant AzureRM pour conserver un state persistant entre les runs GitHub Actions.

Configuration backend actuelle (dans `main.tf`):
- `resource_group_name`: `RG-B3-Eric`
- `storage_account_name`: `sttfstatelabynovepe`
- `container_name`: `tfstate`
- `key`: `security-course.terraform.tfstate`

Pourquoi c'est important:
- les workflows de deploiement et de destruction partagent le meme state;
- evite les recreations involontaires de ressources;
- permet une destruction fiable depuis GitHub Actions.

Note migration locale -> backend distant:
- si un state local existait avant, Terraform peut demander une migration lors du `terraform init`;
- en CI, ce point n'est pas bloquant si le backend est deja initialise.

## Schema CI/CD de l'exercice
Le deploiement et le nettoyage sont executes uniquement via GitHub Actions (manuels).
Deux chemins de deploiement existent: un sans scan (apprentissage du flux) et un avec scan (DevSecOps complet).

```mermaid
flowchart TD
    A[Developer lance un workflow manuel] --> B{Workflow choisi}

  B -->|Deploy without Scan| C0[Job terraform\nenvironment: dev]
  C0 --> D0[OIDC + azure/login]
  D0 --> E0[Terraform fmt/check init validate plan apply]
  E0 --> F0[Job docker\nenvironment: dev]
  F0 --> G0[Build image]
  G0 --> H0[Push ACR]
  H0 --> I0[Restart Web App]
  I0 --> J0[Application disponible]

  B -->|Deploy with Scan| C[Job terraform\nenvironment: dev]
    C --> D[OIDC token GitHub]
    D --> E[azure/login\nAZURE_CLIENT_ID / TENANT_ID / SUBSCRIPTION_ID]
    E --> F[Terraform init / fmt-check / validate]
    F --> G[Trivy IaC scan code Terraform\nrapport SARIF uploade dans GitHub Security]
    G --> H{Misconfiguration CRITICAL ?}
    H -->|Oui| X1[Pipeline stoppe]
    H -->|Non| I[Terraform plan / apply]
    I --> J[Creation infra Azure\nACR + App Service Plan + Web App]
    J --> K[Export outputs Terraform]
    K --> L[Job docker\nenvironment: dev]
    L --> M[Login ACR via az acr login]
    M --> N[Build image Docker\napp + Dockerfile]
    N --> O[Trivy scan image Docker\nrapport SARIF uploade dans GitHub Security]
    O --> P{CVE CRITICAL ?}
    P -->|Oui| X2[CD stoppee\nrapport artifact disponible]
    P -->|Non| Q[Push image ACR\ntags latest + SHA]
    Q --> R[Restart Web App]
    R --> S[Application disponible]

    B -->|Ex3 Terraform and Docker Destroy| D1[Validation\nconfirm_destroy=destroy]
    D1 --> D2[Job destroy\nenvironment: dev]
    D2 --> D3[OIDC + azure/login]
    D3 --> D4[Terraform init + destroy -auto-approve]
    D4 --> D5[Infra Ex3 supprimee]
```

## Scans Trivy et gates de securite
Cette section concerne le workflow `Ex3 Terraform and Docker Deploy with Scan`.
Deux scans Trivy distincts y sont executes:

### 1. Scan IaC (code Terraform)
- se declenche apres `terraform validate`, avant `terraform plan`
- scan de type `config` sur `Exercices/Terraform/Ex3`
- detecte les mauvaises configurations de securite (ex: ressources non chiffrees, acces publics, etc.)
- gate bloquant si misconfiguration de severite `CRITICAL`

### 2. Scan image Docker
- se declenche apres le build de l'image, avant le push ACR
- detecte les CVE dans les paquets OS et librairies de l'image
- gate bloquant si CVE de severite `CRITICAL` avec correctif disponible

Dans les deux cas:
- un rapport SARIF est publie dans l'onglet **Security > Code scanning** du repository GitHub
- un rapport est archive comme artifact du run GitHub Actions (retention 30 jours)

Artifacts produits:
- `trivy-iac-sarif-report`
- `trivy-iac-critical-gate`
- `trivy-sarif-report`
- `trivy-critical-gate`

## Quand utiliser quel workflow
- utiliser `Ex3 Terraform and Docker Deploy without Scan` pour les premiers runs, le debug Terraform ou la validation du pipeline de base
- utiliser `Ex3 Terraform and Docker Deploy with Scan` pour les runs de validation securite, de demonstration DevSecOps et de controle qualite avant mise en production
- utiliser `Ex3 Terraform and Docker Destroy` pour supprimer les ressources en fin de TP/lab
