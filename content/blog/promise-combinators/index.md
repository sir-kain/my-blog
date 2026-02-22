---
title: "Les combinateurs de promesses en JavaScript"
description: Un tour d'horizon de Promise.all, Promise.any, Promise.race et Promise.allSettled — quand les utiliser et ce qu'ils retournent vraiment.
date: 2024-08-18
tags: Web Standard & Performance
---

<video src="./promise-strategies.mp4" controls width="100%" style="border-radius:8px;"></video>

Dès qu'on a plusieurs tâches asynchrones à gérer en parallèle, la question se pose : comment les orchestrer ? C'est là qu'interviennent les **combinateurs de promesses**. JavaScript en fournit quatre nativement, et chacun a un comportement bien précis.

Pour illustrer ça, j'ai construit un petit [showcase](https://promise-combinator.netlify.app/) avec 3 promesses qui se résolvent ou échouent aléatoirement dans un intervalle de 3 secondes. On peut observer en direct ce que chaque combinateur retourne selon les résultats.

## Promise.all

**Échoue dès qu'une promesse est rejetée. Sinon, retourne un tableau de tous les résultats.**

C'est le combinateur "tout ou rien". Si les 3 promesses réussissent, tu récupères leurs 3 résultats dans l'ordre. Si une seule échoue, tu tombes directement dans le `catch` — peu importe ce qu'ont fait les autres.

```js
const results = await Promise.all([p1, p2, p3]);
// → [résultat1, résultat2, résultat3]
// ou rejet si l'une échoue
```

À utiliser quand toutes les tâches sont indispensables — par exemple charger les données d'un utilisateur et ses permissions en même temps. Si l'une échoue, il n'y a rien à afficher.

## Promise.any

**Se résout dès qu'une promesse réussit. Échoue seulement si toutes sont rejetées.**

L'inverse de `all` en quelque sorte. La première promesse qui réussit gagne, les autres sont ignorées. Si toutes échouent, tu reçois une `AggregateError` qui regroupe toutes les erreurs.

```js
const result = await Promise.any([p1, p2, p3]);
// → le résultat de la 1ère promesse résolue
// ou AggregateError si toutes échouent
```

Utile pour des stratégies de fallback — par exemple essayer plusieurs sources de données et prendre la première qui répond.

## Promise.race

**Se résout ou se rejette en fonction de la première promesse qui se termine, qu'elle réussisse ou échoue.**

Là où `any` attend une réussite, `race` réagit à n'importe quel résultat — succès ou échec. Le premier arrivé l'emporte.

```js
const result = await Promise.race([p1, p2, p3]);
// → résultat ou erreur de la 1ère promesse terminée
```

Cas d'usage classique : implémenter un timeout. On met en course la vraie requête contre une promesse qui rejette après N secondes — si la requête est trop lente, le timeout l'emporte.

```js
const timeout = new Promise((_, reject) =>
  setTimeout(() => reject(new Error("Timeout")), 5000)
);
const result = await Promise.race([fetchData(), timeout]);
```

## Promise.allSettled

**Se résout toujours. Retourne un tableau avec le statut de chaque promesse, succès ou échec.**

Contrairement aux autres, `allSettled` n'abandonne jamais. Il attend que toutes les promesses soient terminées et te donne un bilan complet — ce qui a réussi, ce qui a échoué, et pourquoi.

```js
const results = await Promise.allSettled([p1, p2, p3]);
// → [
//   { status: "fulfilled", value: ... },
//   { status: "rejected", reason: ... },
//   { status: "fulfilled", value: ... },
// ]
```

C'est le combinateur le plus "safe". Utile quand les tâches sont indépendantes et qu'on veut traiter chaque résultat même en cas d'échec partiel — envoyer plusieurs notifications, ou déclencher des actions en parallèle sans que l'une bloque les autres.

## En résumé

| Combinateur | Se résout si... | Échoue si... |
|:---|:---|:---|
| `Promise.all` | toutes réussissent | au moins une échoue |
| `Promise.any` | au moins une réussit | toutes échouent |
| `Promise.race` | la 1ère se termine (succès) | la 1ère se termine (échec) |
| `Promise.allSettled` | toujours | jamais |

Le code source et le showcase interactif sont dispo sur [github.com/sir-kain/promise-combinator](https://github.com/sir-kain/promise-combinator) — la démo permet de rejouer les scénarios pour voir les résultats en conditions réelles.

## Pour aller plus loin

- [MDN — Promise combinators](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
- [Démo interactive](https://promise-combinator.netlify.app/)
- [Code source](https://github.com/sir-kain/promise-combinator)
- Discussion sur [LinkedIn](https://www.linkedin.com/posts/ndiaye-ahmadou-waly-a61056ba_javascript-activity-7230581701834346496-ZfB2?utm_source=share&utm_medium=member_desktop&rcm=ACoAABlHo2kBLy8KE-CT5FHx-VPzPxL6RDQ_SQI) et [Twitter/X](https://x.com/_sir_kane/status/1824800762536382596)
