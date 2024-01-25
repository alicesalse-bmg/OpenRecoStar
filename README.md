# OpenRecoStar

## 🚀 Démarrer rapidement

### Installer QGIS

* Télécharger QGIS : https://qgis.org/fr/site/forusers/download.html


* Documentation QGIS : https://docs.qgis.org/3.28/fr/docs/user_manual/index.html

### Installer le plugin OpenRecoStar dans QGIS

* Ouvrir le gestionnaire d'extensions

![img](./img/gestion-extension.png)


* Ajouter le dépôt de l'extension OpenRecoStar à QGIS

![img](./img/depot-extension-1.png)

Entrer l'url du dépôt : https://raw.githubusercontent.com/alicesalse-bmg/OpenRecoStar/master/python/qgs_plugins/OpenRecoStarPlugin.xml

![img](./img/depot-extension-2.png)

* Installer l'extension

![img](./img/install-extension1.png)

* Une nouvelle barre d'outils est présente dans QGIS

![img](./img/barre-outils.png)


### Créer un nouveau projet

* Utiliser l'outil dédié pour la création d'un nouveau projet : <img src="https://github.com/alicesalse-bmg/OpenRecoStarPlugin/raw/master/icons/NewProjet.png"  width="25">

* Choisir le répertoire (dossier) dans lequel créer le projet.

* Donner un nom à votre projet :

![img](./img/nommer-new-projet.png)

> ⚠️  Éviter les accents et caractères spéciaux

* Le nouveau projet est automatiquement créé dans le répertoire choisi selon l'arborescence :

```
📁 mon_repertoire
└── 📁 mon_nouveau_projet
    ├── 🗺 Reco-Star-Elec_mon_nouveau_projet.qgs     <--  Fichier QGIS du projet (carte)
    └── 📁 gpkg
        ├── 🗃 Reco-Star-Elec-RPD.gpkg               <--  Géopackages contenant les données métiers
        ├── 🗃 Reco-Star-Elec-EP.gpkg
        └── 🗃 Reco-Star-xxx.gpkg
```

> ⚠️  Cette arborescence doit être préservée pour ne pas corrompre l'environnement de travail.

* Le projet créé peut être ouvert directement dans QGIS à la fin du processus :

![img](./img/ouvrir-new-projet.png)

## 📚 Documentation

🚧 En construction

## 📺 Vidéos

🚧 En construction
