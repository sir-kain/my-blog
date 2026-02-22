---
title: "Talk: L'outillage JavaScript au DevFest Yamoussoukro"
description: Retour sur ma présentation au DevFest Yamoussoukro 2025 — même sujet que Dakar, mais une autre expérience, un autre public, et un déplacement qui valait vraiment le coup.
date: 2025-12-13
tags: Web Standard & Performance, JavaScript, Talk
---

<iframe src="https://docs.google.com/presentation/d/1pxSYyPwBO1oXnx7nU0klt_atwqYBsA3SgAU1M7DkJ2g/embed?start=false&loop=false" width="100%" height="420" style="border:none;border-radius:8px;" allowfullscreen></iframe>

| | |
|:---|:---|
| **Date** | 13 décembre 2025 |
| **Lieu** | Stade Charles Konan Banny, Yamoussoukro — [DevFest Yamoussoukro 2025](https://gdg.community.dev/) |

---

J'avais déjà présenté ce talk sur l'outillage JavaScript au [DevFest Dakar](/blog/frontend-bundler/) en janvier. Quand l'opportunité s'est présentée de le faire à Yamoussoukro, j'ai pas hésité.

Faire le déplacement jusqu'en Côte d'Ivoire, c'était l'occasion de rencontrer des communautés de développeurs qu'on ne croise pas habituellement. On parle souvent de la scène tech en Afrique de l'Ouest comme d'un tout, mais chaque ville a sa dynamique propre, ses centres d'intérêt, ses questions. Les échanges qu'on a eus surtout autour du développement Front m'ont autant apporté que le talk lui-même.

J'ai beaucoup aimé cette journée.

---

Le contenu du talk couvre 4 mécanismes fondamentaux derrière les bundlers modernes (Webpack, Vite, Rollup...) :

**Minification** — réduire le poids des fichiers en supprimant les commentaires, espaces et en renommant les variables. Un fichier passe de 228 à 98 caractères, le comportement reste identique.

**Bundling** — concaténer plusieurs modules en un seul fichier pour limiter les requêtes HTTP.

**Tree Shaking** — supprimer le code non utilisé. Ça ne fonctionne qu'avec des ES modules (exports nommés). L'exemple qui illustre bien : moment.js (~250 Ko) vs day.js (~7 Ko) pour le même usage de dates.

**Code Splitting** — charger les fichiers à la demande plutôt que tout d'un coup. La primitive native, c'est l'import dynamique :

```js
document.querySelector('button').addEventListener("click", async () => {
  const { hello } = await import("./utils/hello.js");
  console.log(hello("Sir Kane"));
});
```

Le détail complet de chaque concept est dans le [compte rendu du DevFest Dakar](/blog/frontend-bundler/).

## Pour aller plus loin

- Les slides : [ouvrir en plein écran](https://docs.google.com/presentation/d/1pxSYyPwBO1oXnx7nU0klt_atwqYBsA3SgAU1M7DkJ2g/present)
- Le code source des démos : [github.com/sir-kain/js-tools](https://github.com/sir-kain/js-tools)
- [Code splitting avec les directives Astro](https://docs.astro.build/fr/reference/directives-reference/#directives-client)
- [Bundlephobia — voir la taille d'un package npm](https://bundlephobia.com/)
