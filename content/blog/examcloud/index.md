---
title: "Cloud Resource Manager : provisionner de l'AWS depuis une interface web"
description: Retour sur un projet d'examen — une app Laravel/Filament qui crée des ressources AWS (EC2, S3, RDS) en déclenchant un pipeline GitLab CI/CD avec Terraform.
date: 2026-04-25
tags: Cloud, Laravel, DevOps
---

Dans le cadre d'un examen de Cloud Computing, j'avais une semaine pour livrer un projet qui touche à AWS. L'énoncé était assez libre — l'essentiel était de démontrer qu'on sait provisionner des ressources cloud. J'aurais pu faire un script shell ou un simple README avec des captures. J'ai préféré construire une vraie interface.

Le projet : une application web qui permet de créer et supprimer des ressources AWS (EC2, S3, RDS) depuis un dashboard, sans jamais toucher à la console AWS. En coulisses, chaque action déclenche un pipeline GitLab CI/CD qui exécute Terraform.

Le repo : [gitlab.com/sir-kane/exam-cloud](https://gitlab.com/sir-kane/exam-cloud)

## La stack

Pour l'interface, j'ai choisi **Laravel 11 + Filament 3 + Livewire 3**. Filament génère un admin panel propre très vite, et Livewire permet de faire des composants réactifs sans écrire de JS. Pour l'infra : **Terraform** côté IaC, **GitLab CI/CD** comme moteur d'exécution, et **AWS** comme target.

Le flux est simple : l'utilisateur remplit un formulaire → Laravel appelle l'API GitLab → un runner CI exécute Terraform → la ressource apparaît dans AWS.

```
UI Filament → GitLabPipelineService → GitLab API → CI Runner (Terraform) → AWS
```

## Déclencher le pipeline à la demande

Le truc qui m'a plu dans cette architecture, c'est que le pipeline n'est **pas déclenché par un push**. Il est déclenché par l'application, via l'API GitLab, avec des variables qui décrivent la ressource à créer.

```php
// app/Services/GitLabPipelineService.php
Http::withHeaders(['PRIVATE-TOKEN' => $this->token])
    ->post("{$gitlabUrl}/api/v4/projects/{$projectId}/pipeline", [
        'ref'       => 'main',
        'variables' => [
            ['key' => 'TF_ACTION',       'value' => 'apply'],
            ['key' => 'RESOURCE_TYPE',   'value' => 'ec2'],
            ['key' => 'RESOURCE_NAME',   'value' => 'mon-serveur'],
            ['key' => 'RESOURCE_REGION', 'value' => 'us-east-1'],
            // ...
        ],
    ]);
```

Dans le `.gitlab-ci.yml`, le job `apply` ne s'exécute que si `$TF_ACTION == "apply"`. Pour chaque type de ressource, Terraform reçoit les variables et n'instancie que ce qui est demandé grâce à un `count` conditionnel :

```hcl
locals {
  is_ec2 = var.resource_type == "ec2"
  is_s3  = var.resource_type == "s3"
  is_rds = var.resource_type == "rds"
}

resource "aws_instance" "this" {
  count = local.is_ec2 ? 1 : 0
  # ...
}
```

Un seul `terraform apply`, trois types de ressources, zéro duplication.

## Le piège du state Terraform pour la suppression

C'est là où j'ai passé le plus de temps.

Pour créer une ressource, Terraform est parfait. Pour la **supprimer**, il y a un problème : le runner GitLab est éphémère. Chaque pipeline repart d'un état vide. Un job `terraform destroy` sur un state vide ne trouve rien à supprimer — et il ne fait rien.

La solution : pour le destroy, j'abandonne Terraform et j'utilise l'**AWS CLI** directement. Chaque ressource a été créée avec un tag `ResourceId` (l'ID en base de l'application). Le job de suppression retrouve la ressource par ce tag et la supprime.

```bash
# destroy-ec2
INSTANCE_ID=$(aws ec2 describe-instances \
  --region "$RESOURCE_REGION" \
  --filters "Name=tag:ResourceId,Values=${RESOURCE_ID}" \
            "Name=instance-state-name,Values=running,stopped,pending,stopping" \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)

aws ec2 terminate-instances --region "$RESOURCE_REGION" --instance-ids "$INSTANCE_ID"
```

C'est moins élégant que du Terraform pur, mais c'est robuste et ça marche indépendamment de l'état du runner.

## Deux autres problèmes rencontrés

**Les noms de buckets S3 sont globaux.** Un nom comme `mon-bucket-test` peut déjà appartenir à n'importe quel autre compte AWS dans le monde. Pour garantir l'unicité, j'inclus l'Account ID dans le nom :

```hcl
bucket = "${var.resource_slug}-${data.aws_caller_identity.current.account_id}-${var.resource_id}"
```

**Les identifiants RDS ont des contraintes strictes.** AWS refuse tout ce qui n'est pas minuscules + chiffres + tirets. Un nom avec des espaces ou des underscores lève une erreur de validation immédiate. Il faut normaliser le slug côté application avant de l'envoyer au pipeline.

## Trois formulaires et un chatbot

L'interface propose deux façons d'arriver au même résultat.

La première : trois formulaires Filament, un par type de ressource (EC2, S3, RDS). Chacun expose les paramètres propres à son type — région et instance type pour EC2, niveau d'accès ACL pour S3, moteur et classe d'instance pour RDS. Formulaire soumis → pipeline déclenché.

La deuxième : un assistant Livewire en mode conversationnel. Même logique, même résultat final, mais l'utilisateur avance étape par étape via des boutons. Il choisit d'abord le type de ressource, puis la région, puis les options spécifiques, et confirme à la fin. Ça ressemble à un chatbot mais il n'y a aucun LLM derrière — juste un composant Livewire avec une machine d'états.

L'idée c'était de proposer une UX plus accessible pour quelqu'un qui ne sait pas ce qu'est un `t3.micro`, sans dupliquer la logique métier.

## Ce que j'en retiens

Ce projet m'a confirmé que GitLab CI/CD peut très bien servir de moteur d'exécution de tâches, pas juste de pipeline de déploiement. Déclencher un pipeline à la demande avec des variables, c'est une approche propre pour orchestrer de l'IaC depuis une application métier.

Le vrai enseignement côté Terraform : **le state, c'est tout**. Sans state persistant (S3 backend, Terraform Cloud…), le destroy devient un cas à gérer à part. C'est quelque chose que je vais intégrer dès le début sur mes prochains projets.

## Pour aller plus loin

- Dépôt GitLab : [gitlab.com/sir-kane/exam-cloud](https://gitlab.com/sir-kane/exam-cloud)
- [Documentation Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [API GitLab – Trigger a pipeline](https://docs.gitlab.com/ee/api/pipelines.html#create-a-new-pipeline)
