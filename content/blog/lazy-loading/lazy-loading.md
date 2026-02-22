---
title: "Talk: Le Lazy-Loading (amélioration des perfs)"
description: Retour sur ma présentation à TheCodingMachine sur les stratégies de lazy loading en restant sur les standards natifs du web.
date: 2025-12-05
tags: Web Standard & Performance, Talk
---


<iframe src="https://docs.google.com/presentation/d/1DmlfeT2aYsk5nQvcg_5m5r7Q0wvfdaQeyFzAewwuzNs/embed?start=false&loop=false" width="100%" height="420" style="border:none;border-radius:8px;" allowfullscreen></iframe>

| | |
|:---|:---|
| **Date** | 5 décembre 2025 |
| **Lieu** | <img src="/img/tcm.svg" alt="TheCodingMachine" width="32" height="32" style="width:64px" eleventy:ignore> [TheCodingMachine](https://www.thecodingmachine.com/) · en ligne |
| **Demo** | [sir-kain.github.io/lazy-loading](https://sir-kain.github.io/lazy-loading/) |

---

Le lazy loading, c'est une technique pour charger efficacement du contenu sur une page web. Ça répond à une seule question : **quand charger ?** Pas quoi, pas comment — juste quand.

L'idée : ne charger un élément que quand il est sur le point d'être visible. Pas la version "installe cette lib et ça marche", mais la version "voilà ce que le navigateur sait faire tout seul".

---

## Pourquoi s'en préoccuper ?

Une page web charge tout ce qu'elle trouve dans le HTML, même ce qui est à 3 scrolls de distance et que l'utilisateur ne verra peut-être jamais. C'est du réseau gaspillé, du temps de chargement rallongé, et des métriques Lighthouse qui souffrent (FCP, LCP, Speed Index...).

## Les images — le cas le plus simple

### `loading="lazy"`, c'est tout

La bonne nouvelle, c'est que pour les images, le navigateur fait le travail depuis des années. Un seul attribut suffit :

```html
<img src="mon-image.jpg" alt="a ne jamais oublier" loading="lazy">
```

Pas de JavaScript. Pas de bibliothèque. Juste un attribut HTML natif, supporté partout. L'image ne sera téléchargée que lorsqu'elle approche du viewport.

### La balise `<picture>` : afficher VS bien afficher

L'autre chose que j'ai montrée, c'est la différence entre "afficher une image" et "bien afficher une image". Une `<img>` basique envoie la même image JPEG à tout le monde — mobile, desktop, connexion lente, écran Retina. C'est rarement optimal.

La balise `<picture>` permet de laisser le navigateur choisir le meilleur format et la meilleure taille selon le contexte :

```html
<picture>
  <source
    type="image/avif"
    srcset="/image-400.avif 400w, /image-800.avif 800w, /image-1200.avif 1200w"
    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 800px"
  />
  <source
    type="image/webp"
    srcset="/image-400.webp 400w, /image-800.webp 800w, /image-1200.webp 1200w"
    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 800px"
  />
  <img
    src="/image-800.jpeg"
    srcset="/image-400.jpeg 400w, /image-800.jpeg 800w"
    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 800px"
    alt="Description de l'image"
    width="1600"
    height="900"
    loading="lazy"
    decoding="async"
  />
</picture>
```

Le navigateur descend la liste : si AVIF est supporté, il prend AVIF. Sinon WebP. Sinon JPEG. Il choisit aussi la bonne taille selon la largeur d'affichage. Et `loading="lazy"` + `decoding="async"` sur le `<img>` intérieur restent valides dans ce contexte.

## Les contenus lourds — l'IntersectionObserver

Pour tout ce qui n'est pas une image (iframes, composants lourds, vidéos, sections entières), il n'y a pas d'attribut magique. Mais il y a une API native : **IntersectionObserver**.

Son rôle : détecter quand un élément entre dans le viewport, sans polling, sans événement `scroll` chronophage.

```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      // charger ici
    }
  });
}, {
  threshold: 0.5,
  rootMargin: '0px'
});

document.querySelectorAll('.ma-class').forEach(el => {
  observer.observe(el);
});
```

`threshold: 0.5` signifie que le callback se déclenche quand 50% de l'élément est visible. `rootMargin` permet d'anticiper le chargement avant même que l'élément soit visible (par exemple `'200px'` pour charger 200px avant l'arrivée dans le viewport).

C'est cette API qui est derrière la plupart des implémentations modernes de lazy loading — y compris dans des frameworks comme Vue, React ou Angular.

## La démo

Pour illustrer tout ça, j'ai fait une petite page de démo : [sir-kain.github.io/lazy-loading](https://sir-kain.github.io/lazy-loading/)

Deux choses à observer :

- **Images adaptatives** : l'image mobile ne charge que sur mobile, l'image desktop seulement sur desktop — grâce à `<picture>` et ses `<source>` avec media queries.
- **IntersectionObserver en action** : chaque section affiche un message dans la console (`Partie 1 affichée`, `Partie 2 affichée`...) uniquement quand elle devient visible dans le viewport. Ouvre les DevTools et fais défiler — tu verras les logs apparaître au bon moment.

## Pour aller plus loin

- Les slides : [ouvrir en plein écran](https://docs.google.com/presentation/d/1DmlfeT2aYsk5nQvcg_5m5r7Q0wvfdaQeyFzAewwuzNs/present)
- La démo : [sir-kain.github.io/lazy-loading](https://sir-kain.github.io/lazy-loading/)
- Le code source : [github.com/sir-kain/lazy-loading](https://github.com/sir-kain/lazy-loading)
- [`loading` sur MDN](https://developer.mozilla.org/fr/docs/Web/HTML/Element/img#loading)
- [`<picture>` sur MDN](https://developer.mozilla.org/fr/docs/Web/HTML/Element/picture)
- [Intersection Observer API sur MDN](https://developer.mozilla.org/fr/docs/Web/API/Intersection_Observer_API)
- [Métriques Lighthouse (FCP, LCP, CLS...)](https://developer.chrome.com/docs/lighthouse/performance/first-contentful-paint?hl=fr)
