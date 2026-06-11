const http = require('http');
const os = require('os');

// Azure Web App utilise souvent la variable d'environnement PORT, on s'y adapte.
const port = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
    res.writeHead(200, {"Content-Type": "text/html; charset=utf-8"});
    res.end(`
        <div style="font-family: sans-serif; text-align: center; margin-top: 50px;">
            <h1>🚀 Bienvenue sur mon Azure Web App en Conteneur !</h1>
            <p style="font-size: 1.2em; color: #555;">Ceci est une démonstration en direct pour la classe.</p>
            <hr style="width: 50%; margin: 20px auto;">
            <p><strong>Nom de l'hôte (ID du Conteneur) :</strong> <span style="color: #0078D4;">${os.hostname()}</span></p>
            <p><strong>Système d'exploitation :</strong> ${os.type()} ${os.release()}</p>
        </div>
    `);
});

server.listen(port, () => {
    console.log(`Serveur démarré sur le port ${port}`);
});