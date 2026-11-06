# NovaSphere — Architecture technique AWS

## 1. Présentation

NovaSphere est une infrastructure web déployée avec
Terraform dans AWS Academy, région us-east-1.

L'architecture comprend deux environnements
indépendants : DEV et PROD.

Les ressources sont gérées par des modules Terraform
versionnés et déployées via GitHub Actions.

## 2. Schéma général

                       UTILISATEUR
                            |
                            | HTTP : 80
                            |
                  Application Load Balancer
                            |
                      Target Group
                            |
                  Auto Scaling Group
                       /         \
                      /           \
                 EC2 Web 1     EC2 Web 2
                  Apache         Apache
                      \           /
                       \         /
                    AWS Parameter Store
                       SecureString

Chaque environnement dispose de son propre VPC,
de son ALB et de son Auto Scaling Group.

## 3. Infrastructure réseau

Chaque VPC comprend :

- Deux sous-réseaux publics.
- Un Internet Gateway.
- Des tables de routage.
- Un Security Group pour l'ALB.
- Un Security Group pour les instances web.

L'ALB accepte les connexions HTTP publiques.

Les instances web acceptent les connexions HTTP
provenant du Security Group de l'ALB.

Les flux sortants web configurés utilisent
HTTP et HTTPS.

Les VPC DEV et PROD sont distincts.

## 4. Couche applicative

Les serveurs utilisent Amazon Linux 2023.

Apache HTTP Server est installé automatiquement
au premier démarrage grâce au user_data.

La page web affiche :

- L'environnement DEV ou PROD.
- Le nom de l'instance EC2.
- Le résultat de lecture du paramètre SSM.

L'ALB distribue les requêtes entre les instances
enregistrées dans son Target Group.

## 5. Haute disponibilité

Chaque environnement utilise un Auto Scaling Group.

Configuration :

- Capacité minimale : 2 instances.
- Capacité souhaitée : 2 instances.
- Capacité maximale : 4 instances.
- Vérification de santé : ELB.
- Période de grâce : 300 secondes.

Deux instances ont été observées en état Healthy
dans chaque environnement.

Le Launch Template définit la configuration
des futures instances EC2.

## 6. Gestion des secrets

Les secrets applicatifs sont stockés dans
AWS Systems Manager Parameter Store.

DEV :
/novasphere/dev/db_password

PROD :
/novasphere/prod/db_password

Le type SecureString protège les paramètres
au repos par chiffrement KMS.

Les instances utilisent LabInstanceProfile
pour accéder à Parameter Store.

Les valeurs des secrets ne sont pas affichées
dans les pages web.

## 7. Backend Terraform

Les états Terraform sont enregistrés dans
un bucket Amazon S3 distant.

Chaque environnement utilise une clé distincte :

DEV :
novasphere/dev/terraform.tfstate

PROD :
novasphere/prod/terraform.tfstate

Le bucket utilise le versionnement, le chiffrement
et le blocage des accès publics.

Le verrouillage du state utilise les mécanismes
de lockfile du backend S3.

## 8. Organisation des modules

Le dépôt principal est :

Shibal-seki/novasphere-infra

Le module web réutilisable est :

Shibal-seki/terraform-aws-web-stack

Version utilisée : v1.1.0.

Le module web gère notamment :

- Application Load Balancer.
- Target Group.
- Security Groups.
- Launch Template.
- Auto Scaling Group.

Le réseau est également défini avec un
module Terraform externe versionné.

## 9. Automatisation GitHub Actions

Le projet comprend trois workflows.

terraform-pr.yml :
validation du code et plan DEV lors des PR.

terraform-apply.yml :
déploiement automatique DEV après fusion
des changements d'infrastructure sur main.

Le déploiement PROD nécessite une approbation.

terraform-drift.yml :
détection de différences entre le code
Terraform et les ressources AWS existantes.

## 10. Mise à jour du bootstrap SSM

Le bootstrap initial réalisait une seule
tentative de récupération du secret.

Une correction a introduit jusqu'à
12 tentatives espacées de 10 secondes.

Les Launch Templates DEV et PROD ont été
mis à jour vers la version 2.

Cependant, les instances existantes vérifiées
utilisaient encore la version 1.

AWS Academy bloque StartInstanceRefresh
par une Service Control Policy.

La nouvelle logique sera utilisée par les
futures instances lancées avec la version 2.

## 11. Limites de l'architecture

Cette infrastructure est pédagogique.

Les limitations identifiées comprennent :

- Utilisation du protocole HTTP.
- Absence de WAF.
- Absence de journalisation ALB configurée.
- Instances web placées en sous-réseaux publics.
- Restrictions des permissions AWS Academy.
- Renouvellement automatique des instances interdit.

Les risques et recommandations sont
détaillés dans SECURITE.md.

## 12. Conclusion

L'architecture NovaSphere démontre la création
de deux environnements AWS indépendants et
automatisés avec Terraform.

Elle combine réseau, répartition de charge,
Auto Scaling, gestion des secrets, CI/CD
et contrôles de sécurité.
