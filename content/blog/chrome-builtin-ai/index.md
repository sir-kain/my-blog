---
title: "Talk: Chrome built-in AI APIs"
description: Retour sur ma présentation au Hacktoberfest 2025 organisé par Galsen Dev, où j'ai parlé des APIs IA intégrées nativement dans Chrome.
date: 2025-10-25
tags: Web Standard & Performance, AI, Talk
---

<iframe src="https://docs.google.com/presentation/d/1AOr12gD7B9Y_7yTUVKyG6FTmrHMPdacD/embed?start=false&loop=false" width="100%" height="420" style="border:none;border-radius:8px;" allowfullscreen></iframe>

| | |
|:---|:---|
| **Date** | 25 octobre 2025 |
| **Lieu** | FST de l'UCAD, Dakar — [Hacktoberfest Galsen Dev](https://galsen.dev/) |

Demo : [chrome-ia.netlify.app](https://chrome-ia.netlify.app/)

---

Le 25 octobre 2025, [Galsen Dev](https://galsen.dev/) organisait son Hacktoberfest à la FST de l'UCAD. J'ai eu un slot pour présenter quelque chose que je suivais depuis un moment dans ma veille : les **APIs IA intégrées directement dans Chrome**.

Le sujet a bien résonné dans la salle, alors j'en fais un résumé ici.

## L'idée centrale

Aujourd'hui, intégrer de l'IA dans une app web passe forcément par un serveur : on envoie la requête, le modèle tourne quelque part dans le cloud, la réponse revient. Ça marche, mais ça implique de la latence, des coûts, une connexion internet — et les données de l'utilisateur quittent son appareil.

Ce que Google est en train d'expérimenter, c'est de faire tourner **Gemini Nano** directement dans Chrome. Pas dans le cloud. Dans le navigateur, sur la machine de l'utilisateur. Avec trois bénéfices immédiats : **privé, offline, performant**.

## Ce que j'ai montré

La partie qui a le plus intrigué la salle, c'est la simplicité du code. Appeler un LLM depuis le navigateur, ça ressemble à ça :

```javascript
const session = await LanguageModel.create({
  expectedInputs: [{ type: "text", languages: ["en"] }],
  expectedOutputs: [{ type: "text", languages: ["en"] }]
});

const response = await session.prompt("Explain quantum computing like I'm five.");
```

Pas de clé API. Pas de requête HTTP. Le modèle répond directement.

Il y a aussi une **Translator API**, une **Summarizer API**, un **Language Detector**... Autant de fonctionnalités exposées nativement, sans dépendance externe.

Ce qui m'a convaincu que c'est une direction sérieuse : **Bluesky l'utilise déjà** pour traduire les posts. Thomas Steiner (@tomayac) en a parlé [ici](https://bsky.app/profile/tomayac.com/post/3lzlaf5kpq22x).

## Ce qu'il faut retenir

C'est encore en **early preview**, pas standardisé, pas activé par défaut. Donc pas question de l'utiliser en prod sans fallback. Mais c'est une direction qui mérite d'être suivie de près, surtout pour ceux qui construisent des apps où la confidentialité et le mode offline comptent.

## Pour aller plus loin

- Les slides : [ouvrir en plein écran](https://docs.google.com/presentation/d/1AOr12gD7B9Y_7yTUVKyG6FTmrHMPdacD/present)
- Ma démo interactive : [chrome-ia.netlify.app](https://chrome-ia.netlify.app/) *(Chrome requis + early preview)*
- Le code source : [github.com/sir-kain/chrome-ia](https://github.com/sir-kain/chrome-ia)
- Rejoindre le programme early preview : [goo.gle/chrome-ai-dev-preview-join](https://goo.gle/chrome-ai-dev-preview-join)
