# NovaSphere — Cadrage du projet

## Contexte

NovaSphere est un projet pédagogique d'infrastructure
cloud réalisé sur AWS Academy avec Terraform.

## Objectif principal

Déployer et administrer deux environnements
AWS indépendants : DEV et PROD.

## Objectifs techniques

- Automatiser les ressources avec Terraform.
- Réutiliser des modules versionnés.
- Centraliser les states dans Amazon S3.
- Sécuriser les secrets avec Parameter Store.
- Mettre en place ALB et Auto Scaling.
- Automatiser les déploiements avec GitHub Actions.
- Protéger le déploiement PROD par approbation.
- Contrôler les configurations avec Checkov.
- Détecter les dérives Terraform.

## Périmètre

Le projet comprend :

- Deux VPC indépendants.
- Deux environnements web.
- Des instances EC2 Amazon Linux.
- Des Application Load Balancers.
- Des Auto Scaling Groups.
- Un backend Terraform distant.
- Une chaîne CI/CD GitHub Actions.
- Une documentation technique et de sécurité.

## Contraintes

- Permissions AWS Academy limitées.
- Identifiants temporaires.
- Certaines opérations AWS interdites par SCP.
- Ressources à nettoyer après démonstration.

## Critères de validation

- Déploiements DEV et PROD réussis.
- Applications accessibles via les ALB.
- Instances et Target Groups en bonne santé.
- States distants accessibles et chiffrés.
- Plans Terraform sans modification inattendue.
- Vérifications CI/CD exécutées.
- Secrets non publiés en clair.
- Risques et limitations documentés.

## Limites du résultat

Le projet est une démonstration pédagogique.

Les alertes de sécurité non résolues et les
limitations AWS Academy sont détaillées
dans SECURITE.md et RESTE_A_FAIRE.md.
