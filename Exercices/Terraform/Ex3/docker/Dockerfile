# 1. On part d'une image Linux très légère avec Node.js préinstallé
FROM node:20-alpine

# 2. On définit le dossier de travail dans le conteneur
WORKDIR /usr/src/app

# 3. On copie le code de notre application dans le conteneur
COPY app.js .

# 4. On indique que notre application écoute sur le port 8080
EXPOSE 8080

# 5. La commande exécutée au démarrage du conteneur
CMD ["node", "app.js"]