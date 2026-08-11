# Next

Next est une application de tracking et de recommandation personnalisée pour films et séries (musique et livres à venir). Elle permet de suivre ce que l'on regarde, de gérer sa watchlist et son avancement épisode par épisode, avec des données synchronisées depuis [TMDB](https://www.themoviedb.org/).

Projet personnel développé en solo.

## Fonctionnalités

- **Authentification** — inscription / connexion via Devise
- **Recherche TMDB** — recherche de films et séries, import à la demande
- **Watchlist** — ajout/retrait d'un titre, statut (`à voir` / `en cours` / `vu`)
- **Suivi des épisodes** — synchronisation des saisons/épisodes depuis TMDB, marquage vu/non vu, description au clic, progression globale et par saison
- **Statut automatique** — le statut de la watchlist d'une série se met à jour automatiquement selon la progression du visionnage
- **Page d'accueil** — recherche + watchlist en un coup d'œil
- **Profil utilisateur** — email, date d'inscription, statistiques de base

## Stack technique

- **Backend** : Ruby on Rails 8, Ruby 3.3.5
- **Frontend** : Hotwire (Turbo + Stimulus), Bootstrap 5
- **Base de données** : PostgreSQL
- **Authentification** : Devise
- **API externe** : [TMDB](https://www.themoviedb.org/documentation/api) (recherche, détails, saisons/épisodes)
- **Déploiement** : Kamal

## Installation

```bash
git clone <repo>
cd Next_app
bundle install
rails db:create db:migrate
```

### Clé API TMDB

L'application a besoin d'un token d'accès en lecture TMDB (API v4, Bearer token). Créer un compte sur [TMDB](https://www.themoviedb.org/settings/api), puis :

```bash
EDITOR="code --wait" rails credentials:edit
```

Ajouter :

```yaml
tmdb:
  api_key: ton_token_tmdb
```

### Lancer le serveur

```bash
rails server
```

## Roadmap

- **V1 — MVP** : auth, recherche TMDB, watchlist, suivi épisodes ✅
- **V2 — IA & différenciation** : recommandations personnalisées (ruby_llm), dashboard stats, liens d'affiliation
- **V3 — Polish & rétention** : notifications, partage entre amis, export, PWA
- **V4 — Vision long terme** : cross-média (musique, livres, jeux vidéo), mode social, jeu type Cemantix
