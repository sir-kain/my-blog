---
title: De l'expérimentation à l'architecture - La genèse de vscode-mediaplayer
description: Retour technique sur la création d'une extension VS Code capable de lire des médias, du prototype monolithique à une architecture modulaire inspirée par Peacock.
date: 2025-11-22
tags: vscode, extension, typescript, architecture, open-source
---

En cette fin 2025, je prends enfin le temps de partager mon experience sur la création de mon extension VS Code, publiée en 2019. À l’époque, j’avais reçu un avis qui m’a marqué : celui d’un certain **Spencer Williams**.

![Le commentaire de Spencer Williams](spencer-comment.png)
<center><u>Ref</u>: https://marketplace.visualstudio.com/items?itemName=sirkane.vscode-mediaplayer&ssr=false#review-details</center>

Ce message m’a fait plaisir parce qu’au-delà des lenteurs et des mqnquement qu’il soulignait, j'ai senti qu'il a bien deviné le bricolage derierre, les galeres que j'ai dues surpasser pour finir à lancer un audio depuis VS Code. Je ne m’y attendais pas.

Alors, je sais qu'il y'a le debat sur les IDE qui en font too much. Perso, ecouter des podcasts ou de la musique en codant me deconcentre rapidement. Je prefere le calme quand je code.

Mais ici, c'est simplement un de mes 4899954 side projects pour experimenter des techno et parce que je fais beaucoup de veille technologique.

Apres, ca a servit a des gens vu le nombre de telechargmeent qui est aujourd'hui a 7483    

Alors oui, je sais qu’il y a le débat sur les IDE qui en font trop. Personnellement, écouter des podcasts ou de la musique en codant me déconcentre rapidement. Je préfère le calme.
Mais ici, c’était juste l’un de mes 4 899 954 side projects que je fais pour expérimenter des technos, tester des idées... parce que je fais beaucoup de veille technologique.

Et au final, ça a quand même servi à des gens, vu le nombre de téléchargements qui est aujourd’hui à **7 483**.

Voici un retour d'expérience sur ce projet, de la simple curiosité technique à la structuration d'une base de code maintenable.

## Comment j'ai eu l'idee

C’est venu de plusieurs choses:

- D’abord, je suis tombé sur cette [vidéo](https://www.youtube.com/watch?v=ilcWOQveNKY) sûrement une recommandation YouTube. C’est là que j’ai réalisé qu’il n’était pas si compliqué de créer une extension VS Code, et qu’en plus c’était faisable en Node.js, un environnement que je connais très bien.

- Plus tard, j’ai découvert [node-mpv](https://www.npmjs.com/package/node-mpv), un package permettant de contrôler le lecteur MPV en mode headless. [MPV](https://mpv.io/) c’est le lecteur ultra leger que j’utilise sur Ubuntu, un peu comme le VLC sur Windows.

C’est à ce moment-là que j’ai senti que j’avais tous les moyens pour tenter de faire un lecteur audio directement depuis VS Code.

## La conception

J'ai commencé par le plus simple : faire marcher un premier audio (**Make it works first**).

J'ai tout codé directement dans la fonction `activate` du fichier `extension.ts` (l'entrypoint de l'extension). Lecture de la doc VSCode, test de node-mpv, code brouillon. Et ça a marché. Quand le premier son est sorti depuis VSCode, j'ai eu ma 1ere victoire. 
Le commit https://github.com/sir-kain/vscode-mediaplayer/commit/a6227f6e6deac66236b443a4fc1d0e6ccd9e8ac4

Mais le code était un bordel. Tout dans un seul fichier, aucune structure. J'ai alors fait du benchmark. C'est là que je suis tombé sur [Peacock](https://github.com/johnpapa/vscode-peacock) de John Papa. Son code m'a vraiment séduit : patterns clairs, bonne organisation, architecture propre.


```typescript
// Pseudo-code de l'approche initiale
export function activate(context: vscode.ExtensionContext) {
	vscode.commands.registerCommand('vsmp.list', async () => {
		const mediaList = await ressources.searchTracks("eminem");
		vscode.window.showQuickPick(mediaList.map(media => media.title));
	});
	vscode.window.registerTreeDataProvider("vsmp.listmedia", {
		getChildren(elem) {
			return ressources.searchTracks("eminem");
		},
		getTreeItem(element: Track) {
			return {
				label: element.title,
				command: {
					command: "vsmp.play",
					title: 'play',
					arguments: [
						vscode.Uri.parse(element.preview)
					]
				}
			};
		}
	});
	vscode.commands.registerCommand('vsmp.play', async (track) => {
		return mpv.load('https://cdns-preview-5.dzcdn.net' + track.path);
	});
}
```

Cette approche "quick and dirty" a porté ses fruits : j'ai réussi à émettre le premier son. La faisabilité était validée. Mais le code était impossible à maintenir ou à faire évoluer.

## Phase 2 : Le Refactoring et l'Influence de Peacock

Une fois le "Hello World" audio réussi, je me suis retrouvé avec une dette technique immédiate. J'ai alors entamé une phase de recherche et de benchmarking pour trouver une architecture adaptée aux extensions VS Code.

C'est en explorant le code de l'extension **Peacock** de [John Papa](https://github.com/johnpapa) que j'ai eu le déclic.

J'ai été séduit par la clarté de son code et sa séparation des responsabilités. J'ai donc entrepris une refonte complète de `vscode-mediaplayer` en m'inspirant de ces principes :
*   **Séparation des services** : La logique de lecture, la gestion de l'interface utilisateur et les commandes VS Code ont été découplées.
*   **Typage fort** : Utilisation intensive de TypeScript pour sécuriser les échanges de données.
*   **Clean Code** : Adoption de conventions de nommage et de structures claires.

Ce passage d'un script monolithique à une architecture modulaire a été le véritable défi technique du projet, bien plus que la lecture audio elle-même.

---

Si vous souhaitez explorer le code ou tester l'extension :
*   [GitHub Repository](http://github.com/sir-kain/vscode-mediaplayer)
*   [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=sirkane.vscode-mediaplayer)
