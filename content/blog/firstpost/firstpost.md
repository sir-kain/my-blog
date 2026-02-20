---
title: "Les APIs IA intégrées dans Chrome : l'IA qui tourne sans internet"
description: Gemini Nano est désormais embarqué directement dans Chrome. Fini les appels serveurs, l'IA tourne en local, même hors ligne. Voici ce que ça change pour nous développeurs.
date: 2025-11-01
tags: Web, AI, Talk
---

Diapo: [Power point](https://docs.google.com/presentation/d/1AOr12gD7B9Y_7yTUVKyG6FTmrHMPdacD/edit?usp=sharing&ouid=104352643540620210482&rtpof=true&sd=true)

Live demo: [chrome-ia.netlify.app](https://chrome-ia.netlify.app/)

Au Hacktoberfest 2025 organisé par [Galsen Dev](https://galsen.dev/), j'ai eu l'occasion de présenter quelque chose qui m'avait pas mal excité lors de ma veille technologique : les **APIs IA intégrées nativement dans Chrome**.

Ce n'est pas encore un standard. C'est en preview. Mais c'est une direction qui change vraiment la façon dont on peut intégrer de l'IA dans nos applications web.

## Le contexte : comment on fait de l'IA aujourd'hui

Jusqu'ici, pour utiliser de l'IA dans une app web, le flow est toujours le même :

1. L'utilisateur envoie une requête depuis son navigateur
2. Ça part sur **un serveur** qui héberge ou appelle un modèle IA
3. Le serveur renvoie la réponse

Ce modèle fonctionne, mais il a des limites évidentes : latence, coût d'infrastructure, besoin de connexion internet, et surtout — les données de l'utilisateur quittent son appareil.

## La nouveauté : Gemini Nano directement dans Chrome

Google a intégré **Gemini Nano**, un LLM compact, directement dans Chrome. Le modèle tourne **côté client**, dans le navigateur, sans passer par un serveur externe et sans nécessiter de connexion internet.

Concrètement, ça veut dire que depuis du JavaScript, on peut appeler des fonctionnalités IA directement, comme on appelle n'importe quelle API web.

Les avantages sont immédiats :

- **Privé** — les données ne quittent jamais le navigateur de l'utilisateur
- **Offline** — ça fonctionne sans connexion internet
- **Performant** — accélération matérielle, réponses en temps réel

## Les APIs disponibles

Chrome expose plusieurs APIs spécialisées :

| API | Utilité |
|-----|---------|
| **Prompt API** | Interagir avec le modèle en langage naturel (texte ou image) |
| **Translator API** | Traduire du texte entre langues |
| **Summarizer API** | Générer des résumés de textes |
| **Writer API** | Rédiger du contenu |
| **Rewriter API** | Reformuler du texte existant |
| **Proofreader API** | Corriger et améliorer un texte |
| **Language Detector API** | Détecter la langue d'un texte |

## Dans le code, ça ressemble à quoi ?

### Prompt API — poser une question au modèle

```javascript
const session = await LanguageModel.create({
  expectedInputs: [{ type: "text", languages: ["en"] }],
  expectedOutputs: [{ type: "text", languages: ["en"] }]
});

const response = await session.prompt(
  "Explain quantum computing like I'm five."
);
// "Imagine you have a special box that can be both a coin and a
// door at the same time, like magic! That's kind of like a
// quantum bit. [...]"
```

La Prompt API supporte aussi les **images** :

```javascript
const session = await LanguageModel.create({
  expectedInputs: [{ type: "image" }, { type: "text" }],
});

const result = await session.prompt([
  {
    role: "user",
    content: [
      { type: "text", value: input.value },
      { type: "image", value: document.querySelector("img") },
    ],
  },
]);
```

### Translator API — traduire sans API externe

```javascript
const translator = await Translator.create({
  sourceLanguage: "en",
  targetLanguage: "fr",
});

await translator.translate("the text in english");
```

### Summarizer API — résumer un texte long

```javascript
const summarizer = await Summarizer.create();
await summarizer.summarize("Text to summarize...");
```

## Un cas concret : Bluesky l'utilise déjà

Ce qui m'a convaincu que cette direction est sérieuse, c'est de voir que **Bluesky utilise la Translation API** pour traduire les posts directement dans l'app. Thomas Steiner (@tomayac) en a parlé sur [son post Bluesky](https://bsky.app/profile/tomayac.com/post/3lzlaf5kpq22x).

C'est du monde réel, pas juste un proof of concept.

## Ma démo

Pour le Hacktoberfest, j'ai construit une petite démo qui explore ces différentes APIs :

- **Repo GitHub** : [github.com/sir-kain/chrome-ia](https://github.com/sir-kain/chrome-ia)
- **Demo live** : [chrome-ia.netlify.app](https://chrome-ia.netlify.app/)

Attention : pour que ça fonctionne, il faut être sur **Chrome** et avoir rejoint le programme early preview (voir ci-dessous), car les APIs ne sont pas encore activées par défaut.

## Comment tester dès maintenant

Google a ouvert un programme early preview pour que les développeurs puissent accéder aux APIs dès qu'elles atterrissent dans Chrome :

- Rejoindre le programme : [goo.gle/chrome-ai-dev-preview-join](https://goo.gle/chrome-ai-dev-preview-join)
- Pour les curieux, Google avait aussi lancé le **Built-in AI Challenge 2025** avec 70 000$ à la clé : [goo.gle/ChromeAIChallenge2025](https://goo.gle/ChromeAIChallenge2025)

---

Ce qui me plaît dans cette approche, c'est qu'elle démocratise l'accès à l'IA. Plus besoin de gérer une infrastructure serveur, de payer des tokens ou d'avoir une connexion stable. Le modèle est là, dans le navigateur, disponible pour tout le monde.

C'est encore en preview et pas standardisé — donc pas à mettre en prod sans plan de fallback — mais c'est clairement une brique sur laquelle il vaut le coup de garder un oeil.
