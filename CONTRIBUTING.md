# NovaSphere — Guide de contribution

## Organisation Git

La branche main contient la configuration
de référence du projet.

Les modifications sont préparées dans
des branches de travail distinctes.

Exemples :

- fix/nom-correction
- docs/nom-document
- feat/nom-fonctionnalite

## Contributions

1. Créer une branche depuis main.
2. Effectuer les modifications nécessaires.
3. Vérifier le format et la configuration Terraform.
4. Créer un commit descriptif.
5. Ouvrir une Pull Request.
6. Vérifier les contrôles GitHub Actions.
7. Fusionner après validation.

## Contrôles Terraform

Les configurations DEV et PROD doivent être validées
avant toute modification de l'infrastructure.

Une modification affectant les ressources AWS
nécessite l'analyse du plan Terraform.

Toute création, suppression ou recréation
inattendue doit être examinée avant application.

## Sécurité

Il est interdit de publier :

- Des clés AWS.
- Des tokens de session.
- Des mots de passe.
- Des fichiers Terraform state.
- Des clés privées.
- Des données sensibles dans les journaux CI/CD.

Utiliser GitHub Secrets et AWS Systems Manager
pour la gestion des informations sensibles.

## Déploiement

Le déploiement DEV est automatisé
par GitHub Actions.

Le déploiement PROD nécessite
une approbation manuelle.

Ne pas contourner les restrictions
imposées par AWS Academy.

## Documentation

Mettre à jour README.md, ARCHITECTURE.md
et SECURITE.md lorsque les modifications
affectent le fonctionnement ou la sécurité.

Documenter les problèmes non résolus
dans RESTE_A_FAIRE.md.
