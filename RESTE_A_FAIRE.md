# NovaSphere — Bilan et travaux restants

## Fonctionnalités réalisées

- Infrastructure Terraform DEV et PROD déployée.
- Modules Terraform versionnés.
- Backend S3 distant chiffré et versionné.
- Verrouillage des states Terraform.
- ALB et Auto Scaling Groups fonctionnels.
- Deux instances EC2 saines par environnement lors des tests.
- Validation Terraform DEV et PROD.
- Plans finaux sans changement.
- GitHub Actions : validation, déploiement et détection de dérive.
- Approbation manuelle PROD.
- Paramètres SSM SecureString.
- Lecture SSM vérifiée sur les quatre instances.
- Audit Checkov effectué.
- Documentation technique et de sécurité créée.

## Limitations identifiées

### Bootstrap SSM

Le script a été amélioré avec 12 tentatives de lecture SSM.

Les Launch Templates DEV et PROD utilisent la version 2,
mais les anciennes instances utilisent encore la version 1.

Le renouvellement automatique a été refusé par une
Service Control Policy AWS Academy.

La correction reste à tester sur de nouvelles instances.

### Sécurité

Le dernier audit Checkov disponible comporte
15 alertes restantes.

Elles sont analysées dans SECURITE.md.

L'utilisation de HTTP sans TLS reste une limitation
majeure pour une utilisation réelle.

### Identifiants AWS Academy

Les identifiants AWS sont temporaires.

Les workflows planifiés peuvent échouer après
expiration de la session du laboratoire.

## Vérifications finales restantes

- Contrôler les journaux du workflow Terraform Drift.
- Conserver les captures des résultats DEV et PROD.
- Vérifier les journaux CI/CD pour les secrets.
- Présenter ou réaliser une démonstration de dérive contrôlée
  si exigée par le jury et autorisée dans le laboratoire.
- Vérifier les derniers livrables demandés.
- Publier la documentation par Pull Request.
- Créer le tag Git rendu-final.
- Nettoyer les ressources AWS de façon contrôlée
  après le rendu, sans supprimer prématurément le backend.

## Conclusion

Le projet NovaSphere est fonctionnel dans son périmètre
pédagogique. Les limitations non résolues sont documentées.

Les fonctionnalités non validées ne sont pas présentées
comme entièrement terminées.
