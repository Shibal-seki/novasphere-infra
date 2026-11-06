# NovaSphere — Infrastructure AWS avec Terraform

## 1. Présentation du projet

NovaSphere est un projet d'Infrastructure as Code (IaC) permettant de déployer automatiquement une infrastructure web sur Amazon Web Services (AWS) à l'aide de Terraform.

Le projet est réalisé dans un environnement AWS Academy et comprend deux environnements indépendants :

- **DEV** : développement et validation
- **PROD** : production pédagogique avec approbation manuelle

### Objectifs

- Automatiser le déploiement des ressources AWS
- Utiliser des modules Terraform réutilisables
- Séparer DEV et PROD
- Assurer la haute disponibilité avec un Load Balancer
- Automatiser les déploiements avec GitHub Actions
- Protéger les secrets applicatifs avec AWS SSM
- Détecter les dérives d'infrastructure
- Analyser la sécurité avec Checkov

## 2. Technologies utilisées

| Technologie | Utilisation |
|---|---|
| Terraform | Infrastructure as Code |
| AWS EC2 | Hébergement des serveurs web |
| Amazon VPC | Isolation des environnements |
| Application Load Balancer | Répartition du trafic |
| Auto Scaling Group | Gestion des instances EC2 |
| Amazon S3 | Stockage distant des states |
| AWS Systems Manager | Gestion des secrets |
| AWS IAM | Permissions des ressources |
| GitHub Actions | CI/CD |
| Checkov | Analyse de sécurité |
| Apache HTTP Server | Serveur web |
| Amazon Linux 2023 | Système d'exploitation EC2 |

## 3. Architecture AWS

Chaque environnement possède :

- Un VPC indépendant
- Deux sous-réseaux publics
- Un Internet Gateway
- Un Application Load Balancer
- Un Target Group
- Un Launch Template EC2
- Un Auto Scaling Group
- Deux instances EC2 souhaitées
- Des Security Groups
- Un paramètre SSM SecureString

### Fonctionnement

Le trafic HTTP arrive sur l'Application Load Balancer.

L'ALB distribue ensuite les requêtes vers les instances EC2 du Target Group.

Les serveurs Apache affichent :

- Le nom de l'environnement
- Le nom de l'instance EC2
- Le statut de récupération du secret SSM au démarrage

## 4. Dépôts GitHub

**Infrastructure principale :**

https://github.com/Shibal-seki/novasphere-infra

**Module Terraform réutilisable :**

https://github.com/Shibal-seki/terraform-aws-web-stack

Le module web utilise la version **v1.1.0**.

## 5. Organisation du projet

```text
novasphere-infra/
├── .github/
│   └── workflows/
│       ├── terraform-pr.yml
│       ├── terraform-apply.yml
│       └── terraform-drift.yml
├── infra/
│   └── envs/
│       ├── dev/
│       │   ├── web.tf
│       │   └── bootstrap.sh.tftpl
│       └── prod/
│           ├── web.tf
│           └── bootstrap.sh.tftpl
├── README.md
├── SECURITE.md
└── ARCHITECTURE.md
```

Les répertoires DEV et PROD contiennent également leurs fichiers Terraform de réseau, de backend, de variables et de sorties.

## 6. Prérequis

Pour reproduire le projet :

- Installer Terraform
- Installer et configurer AWS CLI
- Disposer d'identifiants AWS valides
- Préparer le bucket S3 de backend
- Disposer des autorisations AWS nécessaires
- Configurer les secrets des workflows GitHub Actions

Dans AWS Academy, les identifiants sont temporaires et peuvent expirer.

## 7. Initialisation Terraform

Depuis la racine du dépôt :

```bash
terraform -chdir=infra/envs/dev init -reconfigure
terraform -chdir=infra/envs/prod init -reconfigure
```

Les deux environnements possèdent des chemins de state S3 distincts.

Le backend utilise le chiffrement, le versionnement et le verrouillage.

## 8. Validation Terraform

```bash
terraform fmt -check -recursive infra/envs
terraform -chdir=infra/envs/dev validate
terraform -chdir=infra/envs/prod validate
```

## 9. Plan Terraform DEV

Le secret DEV doit être fourni sans l'enregistrer dans un fichier :

```bash
read -rsp "Mot de passe DEV : " TF_VAR_db_password
echo
export TF_VAR_db_password

terraform -chdir=infra/envs/dev plan -input=false

unset TF_VAR_db_password
```

Pour PROD, utiliser le mot de passe spécifique à cet environnement.

Les déploiements habituels sont réalisés via GitHub Actions.

## 10. Pipeline CI/CD

### terraform-pr.yml

À chaque Pull Request :

- Vérification du format
- Validation Terraform DEV et PROD
- Génération d'un plan DEV

### terraform-apply.yml

Après fusion des changements d'infrastructure sur main :

- Déploiement automatique DEV
- Approbation manuelle PROD
- Déploiement PROD après approbation

### terraform-drift.yml

Vérification manuelle ou planifiée de dérive Terraform.

Le workflow compare le code Terraform et les ressources AWS existantes.

Les identifiants temporaires AWS Academy peuvent empêcher les exécutions planifiées.

## 11. Gestion des secrets

Les secrets applicatifs sont stockés dans AWS Systems Manager Parameter Store :

- /novasphere/dev/db_password
- /novasphere/prod/db_password

Les paramètres utilisent le type SecureString.

Terraform utilise des variables sensibles et éphémères ainsi que value_wo pour éviter de conserver la valeur du secret dans le state lors de sa gestion.

Les instances EC2 utilisent un profil IAM pour interroger Parameter Store.

## 12. Tests réalisés

- Déploiement DEV réussi
- Déploiement PROD réussi
- Réponses HTTP 200 sur les deux ALB
- Deux instances EC2 vérifiées par environnement
- Contrôle de santé des Target Groups
- Accès SSM testé avec succès sur les quatre instances
- Validation Terraform DEV et PROD
- Correction des descriptions des Security Groups
- Activation de drop_invalid_header_fields sur les ALB
- Analyse Checkov

## 13. Sécurité et limites

Le dernier audit Checkov disponible après la version v1.1.0 indique :

- 120 contrôles réussis
- 15 contrôles en échec
- 0 contrôle ignoré

Les alertes et recommandations sont documentées dans SECURITE.md.

### Limitation AWS Academy

La commande autoscaling:StartInstanceRefresh a été refusée par une Service Control Policy AWS Academy.

Les Auto Scaling Groups utilisent désormais la version 2 des Launch Templates, comprenant plusieurs tentatives de lecture SSM.

Les instances existantes vérifiées utilisaient encore la version 1. Le nouveau bootstrap n'a donc pas encore été validé sur de nouvelles instances.

### Limitation HTTP

Le trafic applicatif utilise HTTP sans chiffrement TLS.

Cette architecture est destinée à une démonstration pédagogique et ne doit pas être considérée comme une production entièrement sécurisée.

## 14. Documentation

- **SECURITE.md** : analyse Checkov, mesures de sécurité et risques résiduels
- **ARCHITECTURE.md** : description technique de l'architecture AWS

## 15. Nettoyage du laboratoire

À la fin du projet, les ressources AWS doivent être supprimées de façon contrôlée.

Conserver le bucket S3 du backend tant que les destructions et les vérifications ne sont pas terminées.

Ne pas supprimer les states Terraform avant de détruire les ressources qu'ils gèrent.

## 16. Conclusion

NovaSphere démontre le déploiement automatisé de deux environnements AWS avec Terraform.

Le projet associe la modularité, la haute disponibilité, la gestion des secrets, le CI/CD, la séparation DEV/PROD et les contrôles de sécurité.

Les restrictions AWS Academy et les améliorations de sécurité restantes sont documentées.
