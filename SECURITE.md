# NovaSphere — Rapport de sécurité

Date de référence : 6 novembre 2026

## 1. Objectif

Ce document présente les mesures de sécurité mises en place dans
l'infrastructure Terraform NovaSphere, les résultats de l'analyse
statique Checkov et les risques résiduels.

L'infrastructure est un projet pédagogique déployé dans AWS Academy.
Certaines fonctions AWS sont limitées par les permissions du laboratoire.

Les exceptions documentées ne constituent pas une validation
de sécurité pour un environnement de production réel.

## 2. Architecture et périmètre

Deux environnements distincts sont déployés :

- DEV : VPC, sous-réseaux, ALB, Auto Scaling Group et instances EC2.
- PROD : infrastructure distincte avec les mêmes composants.
- Région AWS : us-east-1.
- Modules Terraform versionnés.
- State Terraform distant dans Amazon S3 avec verrouillage.
- Secrets applicatifs dans AWS Systems Manager Parameter Store.
- Déploiements automatisés par GitHub Actions.
- Approbation manuelle nécessaire pour déployer PROD.

Les Security Groups séparent les flux vers l'ALB et les instances web.

## 3. Mesures de sécurité implémentées

### 3.1 Réseau

- ALB exposé pour les requêtes HTTP.
- Instances web accessibles en HTTP depuis le Security Group de l'ALB.
- Flux sortants web limités aux usages HTTP et HTTPS configurés.
- Environnements DEV et PROD isolés dans des VPC distincts.
- Activation de drop_invalid_header_fields sur les ALB.
- Descriptions ajoutées aux cinq règles de Security Groups du module.

Le protocole HTTP reste une limitation importante :
le trafic applicatif n'est pas chiffré en transit.

### 3.2 Instances EC2

- Amazon Linux 2023.
- Auto Scaling Group avec deux instances souhaitées par environnement.
- Instance Metadata Service configuré avec IMDSv2 obligatoire.
- Bootstrap automatique d'Apache.
- Utilisation du profil IAM LabInstanceProfile fourni par AWS Academy.

### 3.3 Gestion des secrets

- Paramètres SSM distincts pour DEV et PROD.
- Paramètres de type SecureString.
- Déchiffrement via AWS KMS.
- Variables Terraform sensibles et éphémères.
- Utilisation de value_wo pour éviter d'enregistrer la valeur
  du secret dans le state Terraform lors de sa gestion.
- Secrets GitHub Actions utilisés pour les déploiements.
- Secret PROD associé à l'environnement GitHub protégé.

Les scripts de démarrage ne publient jamais le mot de passe
dans la page HTML. Ils affichent uniquement un statut.

L'absence de secrets en clair dans l'historique Git, les logs
et les anciennes versions des states doit être vérifiée séparément.

### 3.4 CI/CD et state distant

- Validation Terraform des environnements.
- Plan Terraform automatique lors des Pull Requests.
- Application automatisée sur la branche main.
- Approbation de l'environnement PROD avant son déploiement.
- Détection de dérive via un workflow dédié.
- Backend S3 avec chiffrement, versionnement et verrouillage.

Les identifiants AWS Academy sont temporaires.
Leur expiration peut empêcher l'exécution planifiée des workflows.

## 4. Résultats Checkov

Dernier audit disponible après passage du module web à v1.1.0 :

- Contrôles réussis : 120.
- Contrôles en échec : 15.
- Contrôles ignorés : 0.

L'analyse a été réalisée sur la configuration DEV avec
téléchargement des modules Terraform externes.

Ces résultats décrivent un audit statique.
Ils ne remplacent pas les contrôles AWS en fonctionnement.

### 4.1 Corrections réalisées dans le module v1.1.0

- CKV_AWS_23 : descriptions des cinq règles réseau ajoutées.
- CKV_AWS_131 : suppression des en-têtes HTTP invalides activée.

L'activation de la protection des en-têtes a été vérifiée
directement sur les ALB DEV et PROD.

### 4.2 Les 15 alertes restantes

| ID Checkov | Risque ou non-conformité | Décision / action |
|---|---|---|
| CKV_AWS_150 | Protection contre la suppression de l'ALB désactivée | Non corrigé. À activer hors laboratoire ; facilite ici le nettoyage des ressources. |
| CKV_AWS_91 | Journalisation des accès ALB absente | Non corrigé. Prévoir un bucket S3 dédié et une politique de conservation des logs. |
| CKV_AWS_2 | Listener ALB utilisant HTTP | Non corrigé. Mettre en place HTTPS avec certificat ACM. |
| CKV_AWS_88 | Attribution d'adresses IP publiques aux instances | Non corrigé. Préférer des instances privées et une sortie réseau contrôlée. |
| CKV_AWS_260 | Port 80 public sur la règle d'entrée de l'ALB | Exposition volontaire pour la démonstration HTTP ; à remplacer par HTTPS. |
| CKV_AWS_260 | Alerte port 80 sur la règle web | À examiner : la configuration vise une source Security Group ALB, pas un CIDR public direct. |
| CKV_AWS_130 | Attribution automatique d'IP publiques aux sous-réseaux | Non corrigé. Revoir la séparation des sous-réseaux publics et privés. |
| CKV_TF_1 | Module réseau non fixé à un commit SHA | Module versionné ; fixer un SHA pour une immutabilité renforcée. |
| CKV_AWS_337 | SSM utilisant une clé KMS gérée par AWS | SecureString chiffré ; envisager une clé KMS dédiée pour limiter les accès au déchiffrement. |
| CKV_TF_1 | Module web non fixé à un commit SHA | Module web référencé par tag v1.1.0 ; SHA recommandé pour renforcer l'intégrité. |
| CKV_AWS_378 | Target Group en HTTP | Non corrigé. Étudier le chiffrement TLS entre ALB et instances. |
| CKV_AWS_103 | Politique TLS 1.2+ non vérifiable sur le listener HTTP | À traiter lors de l'activation d'un listener HTTPS. |
| CKV2_AWS_20 | Absence de redirection HTTP vers HTTPS | Non corrigé. Ajouter un listener HTTPS et une redirection HTTP. |
| CKV2_AWS_28 | Absence de WAF devant l'ALB public | Non corrigé. Évaluer AWS WAF selon les droits et coûts disponibles. |
| CKV2_AWS_12 | Configuration du Security Group par défaut du VPC | À contrôler sur AWS ; ne pas considérer ce point comme corrigé sans vérification. |

La règle web signalée par CKV_AWS_260 doit faire l'objet
d'une vérification spécifique des sources réseau.
Une alerte potentiellement imprécise ne doit pas être ignorée
sans justification technique.

## 5. Incident SSM au démarrage

### 5.1 Symptôme initial

Certaines instances affichaient :

Secret SSM : INDISPONIBLE

Le script original ne tentait de récupérer le paramètre SSM
qu'une seule fois, pendant le démarrage EC2.

Le résultat était ensuite écrit dans une page HTML statique.

### 5.2 Diagnostic

Les quatre instances DEV et PROD ont été vérifiées via
AWS Systems Manager Run Command.

Résultat : SSM_READ_OK sur les quatre instances.

Les paramètres DEV et PROD existent dans Parameter Store.

Les rôles et accès SSM fonctionnaient donc lors de ces tests.
La cause exacte de l'échec initial reste non déterminée.

### 5.3 Correction apportée

Le bootstrap a été modifié pour effectuer jusqu'à
12 tentatives de lecture SSM avec un intervalle de 10 secondes.

Le script vérifie uniquement la réussite de la récupération
du paramètre sans publier sa valeur.

La nouvelle configuration a été déployée via GitHub Actions
sur DEV et PROD.

### 5.4 Limitation AWS Academy

Les Auto Scaling Groups utilisent le Launch Template version 2,
mais les instances présentes au moment de la vérification
utilisaient encore la version 1.

L'appel autoscaling:StartInstanceRefresh a été refusé
par une Service Control Policy AWS Academy (explicit deny).

Il n'a pas été tenté de contourner cette restriction.

La nouvelle version du bootstrap est donc disponible pour
les futures instances, mais son exécution sur une nouvelle
instance n'a pas encore été démontrée.

### 5.5 Risque résiduel

Les anciennes pages HTML peuvent continuer à afficher
INDISPONIBLE alors que la lecture SSM fonctionne désormais.

Il reste à valider le comportement au démarrage d'une nouvelle
instance lorsque l'environnement AWS le permettra.

## 6. Contrôles complémentaires à effectuer

- Vérifier les Security Groups effectifs dans AWS.
- Auditer les permissions IAM appliquées au profil EC2.
- Vérifier l'absence de secrets dans le code et l'historique Git.
- Vérifier les anciennes versions des states Terraform.
- Vérifier les logs GitHub Actions.
- Confirmer que les plans DEV et PROD sont sans changement
  après les déploiements.
- Tester et documenter une dérive Terraform contrôlée.
- Contrôler l'absence de remplacement ou de destruction inattendue.
- Préparer la suppression contrôlée des ressources AWS du laboratoire.

## 7. Recommandations pour une production réelle

1. Activer HTTPS et les redirections appropriées.
2. Utiliser des sous-réseaux privés pour les instances.
3. Activer la journalisation ALB et les VPC Flow Logs.
4. Ajouter AWS WAF selon l'analyse de risque.
5. Utiliser une clé KMS dédiée avec des droits minimaux.
6. Renforcer la gestion des identités avec des rôles CI/CD temporaires.
7. Ajouter des tests automatiques du bootstrap.
8. Tester les mises à jour progressives des Auto Scaling Groups.
9. Fixer les dépendances Terraform par commit immuable.
10. Mettre en place une stratégie de sauvegarde et de reprise.

## 8. Conclusion

NovaSphere démontre une infrastructure AWS déployée et
administrée avec Terraform, GitHub Actions et Parameter Store.

La séparation DEV/PROD, les protections de métadonnées EC2,
la gestion des secrets et les contrôles automatisés constituent
des éléments positifs.

Cependant, les 15 alertes Checkov restantes et les restrictions
AWS Academy doivent rester explicitement identifiées.

L'architecture est une démonstration pédagogique et ne doit
pas être présentée comme entièrement sécurisée pour une
production réelle.
