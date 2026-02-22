---
title: "Talk: L'outillage JavaScript - Les bundler"
description: Retour sur ma présentation au DevFest Dakar où j'ai couvert les 4 piliers de l'outillage JS — minification, bundling, tree shaking et code splitting.
date: 2025-01-13
tags: Web Standard & Performance, Talk
---

<iframe src="https://docs.google.com/presentation/d/1pxSYyPwBO1oXnx7nU0klt_atwqYBsA3SgAU1M7DkJ2g/embed?start=false&loop=false" width="100%" height="420" style="border:none;border-radius:8px;" allowfullscreen></iframe>

| | |
|:---|:---|
| **Date** | 13 janvier 2025 |
| **Lieu** | Hôtel Sea Plaza, Dakar — <img src="/img/devfest.png" alt="DevFest" width="32" eleventy:ignore> [DevFest Dakar](https://gdg.community.dev/gdg-dakar/) |

---

Quand on parle d'outillage JavaScript, on parle souvent de Webpack, Vite, Rollup... sans vraiment savoir ce qu'ils font sous le capot. Au DevFest Dakar, j'ai pris le parti de décortiquer les 4 mécanismes fondamentaux derrière ces outils.

## Minification

**Objectif : réduire le poids des fichiers à charger par le navigateur.**

Le navigateur n'a pas besoin de code lisible. Il n'a besoin que de code fonctionnel. La minification exploite ça en appliquant plusieurs transformations successives :

1. Suppression des commentaires, espaces et sauts de ligne inutiles
2. Renommage des variables en noms courts (`firstNumber` → `f`)
3. Réécriture avec des opérateurs plus compacts (ternaires, etc.)

Résultat concret sur un fichier `math.js` : **228 caractères → 98 caractères**, sans changer le comportement.

```js
// Avant (math.js) — 228 chars
export function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}
// Recursivity
export function factorial(number) {
  if (number === 0) {
    return 1;
  }
  return number * factorial(number - 1);
}

// Après (math.min.js) — 98 chars
export function add(f,s){return f+s}export function factorial(n){return n===0?1:n*factorial(n-1)}
```

Les outils du marché, du plus lent au plus rapide : **Terser** (JS, 2018), **SWC** (Rust, 2019), **Esbuild** (Go, 2020).

> "Don't minify what you don't need. Minification without tree-shaking is like compressing a trash can without taking out the garbage." — *Philip Walton*

## Bundling

**Objectif : concaténer plusieurs fichiers en un seul.**

Un projet JS moderne est découpé en modules. Sans bundler, le navigateur doit faire une requête HTTP par fichier. Le bundling rassemble tout en un `bundle.js` unique.

```js
// math.js
export const add = (a, b) => a + b

// index.js
import { add } from './math'
console.log(add(2, 3))

// → bundle.js
const add = (a, b) => a + b
console.log(add(2, 3))
```

Les `import`/`export` disparaissent, le code est inliné. Une seule requête réseau au lieu de deux.

## Tree Shaking

**Objectif : supprimer le code non utilisé.**

Le tree shaking, c'est ce qui fait que si tu importes `add` depuis un fichier qui exporte aussi `subtract`, seul `add` se retrouve dans le bundle final. Mais ça ne fonctionne qu'avec des **ES modules** (exports nommés), pas avec CommonJS.

```js
// ❌ Non tree shakable — exporte un objet entier
// math.js
const math = { add: (a, b) => a + b, subtract: (a, b) => a - b }
export default math
// index.js — importe tout l'objet même si on n'utilise que add
import math from './math'

// ✅ Tree shakable — exports nommés
// math.js
export const add = (a, b) => a + b
export const subtract = (a, b) => a - b
// index.js — seul add est inclus dans le bundle
import { add } from './math'
```

Un exemple qui parle : **moment.js** (~250 Ko) vs **day.js** (~7 Ko) pour le même usage. La différence vient en grande partie du fait que moment.js n'est pas tree shakable.

## Code Splitting

**Objectif : charger les fichiers à la demande, pas tous d'un coup.**

Le bundling crée un seul fichier — mais si ce fichier fait 2 Mo, l'utilisateur le télécharge entier au premier chargement, même pour les parties qu'il ne verra jamais. Le code splitting inverse la logique : on découpe en plusieurs chunks, chargés uniquement quand on en a besoin.

La primitive native, c'est l'**import dynamique** :

```js
document.querySelector('button').addEventListener("click", async () => {
  const { hello } = await import("./utils/hello.js");
  console.log(hello("Sir Kane"));
});
```

Le fichier `hello.js` n'est téléchargé qu'au clic. Avant ça, zéro requête.

Les frameworks ont leurs propres abstractions par-dessus : `defineAsyncComponent` en Vue, les `client:` directives en Astro (`client:load`, `client:idle`, `client:visible`...).

## Pour aller plus loin

- Les slides : [ouvrir en plein écran](https://docs.google.com/presentation/d/1pxSYyPwBO1oXnx7nU0klt_atwqYBsA3SgAU1M7DkJ2g/present)
- Le code source des démos : [github.com/sir-kain/js-tools](https://github.com/sir-kain/js-tools)
- [Code splitting avec les directives Astro](https://docs.astro.build/fr/reference/directives-reference/#directives-client)
- [Conf de Hubert Sablonnière sur la compression](https://www.youtube.com/watch?v=zxiJXQpRa4E)
- [Bundlephobia — voir la taille d'un package npm](https://bundlephobia.com/)
- [Métriques LCP sur web.dev](https://web.dev/articles/lcp?hl=fr)
