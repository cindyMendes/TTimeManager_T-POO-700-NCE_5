# TTimeManager_T-POO-700-NCE_5

# Time Manager Mobile Application

Ce projet est une application mobile développée avec Vue.js et Capacitor, utilisant une API Phoenix (Elixir) comme backend.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les logiciels suivants :

- [Node.js](https://nodejs.org/) (version 14.x ou supérieure)
- [npm](https://www.npmjs.com/) (généralement installé avec Node.js)
- [Git](https://git-scm.com/)
- [Android Studio](https://developer.android.com/studio) (pour le développement Android)
- [Xcode](https://developer.apple.com/xcode/) (pour le développement iOS, Mac uniquement)
- [Elixir](https://elixir-lang.org/install.html) (pour le backend Phoenix)
- [Phoenix Framework](https://hexdocs.pm/phoenix/installation.html)

## Configuration de l'environnement de développement

### 1. Installation d'Android Studio

1. Téléchargez et installez Android Studio depuis [le site officiel](https://developer.android.com/studio).
2. Pendant l'installation, assurez-vous de sélectionner les composants suivants :
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device
3. Une fois installé, ouvrez Android Studio et allez dans "Tools" > "SDK Manager".
4. Dans l'onglet "SDK Platforms", cochez la case pour Android 13 (API Level 33) ou la version la plus récente.
5. Dans l'onglet "SDK Tools", assurez-vous que "Android SDK Build-Tools" et "Android SDK Platform-Tools" sont installés.

### 2. Configuration des variables d'environnement

Ajoutez les chemins suivants à votre variable d'environnement PATH :

- Windows :
  ```
  C:\Users\[YourUsername]\AppData\Local\Android\Sdk\platform-tools
  C:\Users\[YourUsername]\AppData\Local\Android\Sdk\tools
  ```

- macOS/Linux :
  ```
  $HOME/Library/Android/sdk/platform-tools
  $HOME/Library/Android/sdk/tools
  ```

### 3. Installation des dépendances du projet

Dans le répertoire du projet, exécutez :

```bash
npm install
```

## Configuration du projet

### 1. Configuration de l'API (Backend)

1. Naviguez vers le dossier du backend :
   ```bash
   cd path/to/backend
   ```

2. Installez les dépendances Phoenix :
   ```bash
   mix deps.get
   ```

3. Configurez la base de données dans `config/dev.exs`.

4. Créez et migrez la base de données :
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

5. Modifiez `config/dev.exs` pour permettre l'accès depuis le réseau local :

   ```elixir
   config :time_manager, TimeManagerWeb.Endpoint,
     http: [ip: {0, 0, 0, 0}, port: 4000],
     check_origin: false,
     # ... autres configurations
   ```

6. Lancez le serveur Phoenix :
   ```bash
   mix phx.server
   ```

### 2. Configuration du Frontend (Vue.js/Capacitor)

1. Dans le dossier du frontend, créez ou modifiez `src/config.js` :

   ```javascript
   const isDevelopment = process.env.NODE_ENV === 'development';

   export const API_URL = isDevelopment
     ? 'http://10.73.187.153:4000/api'  // Remplacez par votre adresse IP locale
     : 'https://api.timemanager.com/api';

   export { isDevelopment };
   ```

2. Configurez la sécurité réseau pour Android. Créez ou modifiez `android/app/src/main/res/xml/network_security_config.xml` :

   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <network-security-config>
       <domain-config cleartextTrafficPermitted="true">
           <domain includeSubdomains="true">10.73.187.153</domain>
       </domain-config>
   </network-security-config>
   ```

3. Référencez ce fichier dans `android/app/src/main/AndroidManifest.xml` :

   ```xml
   <application
       ...
       android:networkSecurityConfig="@xml/network_security_config">
       ...
   </application>
   ```

## Lancement de l'application

1. Construisez l'application Vue.js :
   ```bash
   npm run build
   ```

2. Synchronisez les fichiers avec Capacitor :
   ```bash
   npx cap sync
   ```

3. Exécutez l'application sur un émulateur Android :
   ```bash
   npx cap run android
   ```

   Ou sur un simulateur iOS (Mac uniquement) :
   ```bash
   npx cap run ios
   ```

## Dépannage

- Si l'émulateur est hors ligne, essayez de redémarrer ADB :
  ```bash
  adb kill-server
  adb start-server
  ```

- Assurez-vous que votre pare-feu autorise les connexions sur le port 4000.

- Pour les problèmes de connexion à l'API, vérifiez que l'adresse IP dans `config.js` correspond à celle de votre machine sur le réseau local.

## Ressources additionnelles

- [Documentation Vue.js](https://vuejs.org/guide/introduction.html)
- [Documentation Capacitor](https://capacitorjs.com/docs)
- [Documentation Phoenix](https://hexdocs.pm/phoenix/overview.html)