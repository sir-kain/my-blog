# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projet

Blog personnel d'**Ahmadou Waly NDIAYE** (alias Sir Kane), développeur web.

**Objectif** : publier des articles techniques en français sur ses expériences de développeur — projets perso, side-projects, talks donnés en communauté.

**Deux types de contenus** :
- **Articles techniques** : retour d'expérience sur la création d'un projet (ex: vscode-mediaplayer). Ton direct, première personne, narratif — on raconte comment ça s'est construit, pas juste ce que ça fait.
- **Comptes rendus de talks** : résumé d'une présentation donnée en communauté. On sent l'événement (date, lieu, public), les slides sont embarquées en iframe, et une section "Pour aller plus loin" regroupe les ressources.

**Ton général** : personnel, direct, sans jargon inutile. Pas d'article encyclopédique — on partage une expérience vécue.

**Déployé sur** : [ahmadouwalyndiaye.dev](https://ahmadouwalyndiaye.dev)

---

## Commands

```bash
npm start        # Dev server with live reload (http://localhost:8080)
npm run build    # Production build → output in _site/
npm run debug    # Build with Eleventy debug logs
```

Deployment is handled by Cloudflare Workers via `wrangler.toml`. The build output `_site/` is served as static assets.

## Architecture

Static site built with **Eleventy 3** (ESM, Node ≥ 18). No frontend framework.

### Key files

| Fichier | Rôle |
|---------|------|
| `eleventy.config.js` | Config principale : plugins, passthrough copy, bundles CSS/JS |
| `_data/metadata.js` | Titre du site, URL, auteur, langue — utilisés dans tous les templates |
| `_config/filters.js` | Filtres Eleventy : `readableDate`, `head`, `filterTagList`, etc. |
| `wrangler.toml` | Config Cloudflare Workers, pointe vers `_site/` |

### Templates (`_includes/layouts/`)

- `base.njk` — layout racine : `<head>`, nav, footer. La nav est générée automatiquement via `eleventy-navigation` depuis les frontmatters des pages.
- `home.njk` — extend base, utilisé pour les pages hors blog (`content.11tydata.js`)
- `post.njk` — extend base, utilisé pour tous les articles (`blog.11tydata.js`), inclut syntax highlighting (Prism/Okaidia) et navigation précédent/suivant

### Contenu (`content/`)

- Pages de navigation (`index.njk`, `blog.njk`, `about.md`) : ont un `eleventyNavigation` dans leur frontmatter pour apparaître dans le menu
- Articles : dans `content/blog/<slug>/<slug>.md`, avec les assets (images, PDF) dans le même dossier
- `blog.11tydata.js` injecte automatiquement `tags: ["posts"]` et `layout: "layouts/post.njk"` à tous les articles
- Les drafts (`draft: true`) sont exclus du build de production

### Assets statiques

`public/` est copié tel quel à la racine du site (ex: `public/cv.pdf` → `/cv.pdf`).

### Création d'un nouvel article

Créer `content/blog/<slug>/<slug>.md` avec le frontmatter :

```yaml
---
title: "Titre de l'article"
description: Courte description.
date: YYYY-MM-DD
tags: Tag1, Tag2
---
```

Le layout, la collection `posts` et la navigation précédent/suivant sont automatiquement appliqués via `blog.11tydata.js`.
