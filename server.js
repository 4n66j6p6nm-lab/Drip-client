const express = require('express');
const fetch = require('node-fetch');

const app = express();
app.use(express.json());

const WEBHOOK_URL = process.env.WEBHOOK_URL || process.env.DISCORD_WEBHOOK_URL || "https://discord.com/api/webhooks/1561259901077159946/F9NXMM2apV_YPqG27Z9NVWf2OgkUS0bvundFuD-quDFajJH6eqaeUVpPX7cEyfK5g7SD";

const activeUsers = new Map();

// Función auxiliar para obtener el nombre del juego desde la API de Roblox
async function getGameName(placeId) {
    if (!placeId) return "Juego Desconocido";
    try {
        const res = await fetch(`https://apis.roblox.com/universes/v1/places/${placeId}/universe`);
        const data = await res.json();
        if (data && data.universeId) {
            const gameRes = await fetch(`https://games.roblox.com/v1/games?universeIds=${data.universeId}`);
            const gameData = await gameRes.json();
            if (gameData && gameData.data && gameData.data[0]) {
                return gameData.data[0].name;
            }
        }
    } catch (e) {
        console.error("No se pudo obtener el nombre del juego:", e.message);
    }
    return `Place ID: ${placeId}`;
}

app.post('/online', async (req, res) => {
    try {
        const {
            username,
            displayName,
            userId,
            placeId,
            jobId,
            executor,
            scriptVersion,
            isPing
        } = req.body;

        if (!userId) return res.status(400).json({ error: "Falta userId" });

        // Obtener el nombre real del juego
        const gameName = await getGameName(placeId);

        activeUsers.set(userId, {
            username: username || "Desconocido",
            displayName: displayName || username || "Desconocido",
            executor: executor || "Desconocido",
            placeId: placeId || "N/A",
            gameName: gameName,
            jobId: jobId || "",
            lastSeen: Date.now()
        });

        if (isPing) {
            return res.status(200).json({ status: "pinged", onlineCount: activeUsers.size });
        }

        const joinLink = (placeId && jobId) 
            ? `roblox://experiences/start?placeId=${placeId}&gameInstanceId=${jobId}`
            : `https://www.roblox.com/games/${placeId || ''}`;
            
        const profileLink = `https://www.roblox.com/users/${userId}/profile`;

        const embedPayload = {
            embeds: [
                {
                    title: "🚀 ¡Ejecución de Script Detectada!",
                    color: 0x5865F2,
                    thumbnail: {
                        url: `https://www.roblox.com/headshot-thumbnail/image?userId=${userId}&width=420&height=420&format=png`
                    },
                    fields: [
                        {
                            name: "👤 Usuario",
                            value: `**${displayName \vert{}\vert{} username}**\n(@${username})`,
                            inline: true
                        },
                        {
                            name: "🆔 User ID",
                            value: `\`${userId}\``,
                            inline: true
                        },
                        {
                            name: "💉 Ejecutor",
                            value: `\`${executor || "Desconocido"}\``,
                            inline: true
                        },
                        {
                            name: "🎮 Juego",
                            value: `**${gameName}**\n(\`${placeId || "N/A"}\`)`,
                            inline: false
                        },
                        {
                            name: "📌 Versión",
                            value: `\`${scriptVersion || "1.3 - FREE"}\``,
                            inline: true
                        },
                        {
                            name: "🟢 Conectados en Tiempo Real",
                            value: `Actualmente hay **${activeUsers.size}** usuario(s) en línea`,
                            inline: false
                        },
                        {
                            name: "🔗 Acciones Rápidas",
                            value: `👉 [**🎮 Unirse al Servidor del Jugador**](${joinLink})\n👉 [**👤 Ver Perfil de Roblox**](${profileLink})`,
                            inline: false
                        }
                    ],
                    footer: { text: "Kaisen X Hub | Logger Proxy" },
                    timestamp: new Date().toISOString()
                }
            ]
        };

        await fetch(WEBHOOK_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(embedPayload)
        });

        return res.status(200).json({ status: "success", onlineCount: activeUsers.size });
    } catch (error) {
        console.error("Error procesando webhook:", error);
        return res.status(500).json({ status: "error", message: error.message });
    }
});

app.get('/online', (req, res) => {
    const now = Date.now();
    for (const [id, user] of activeUsers.entries()) {
        if (now - user.lastSeen > 2 * 60 * 1000) {
            activeUsers.delete(id);
        }
    }

    let userListHtml = '';
    activeUsers.forEach((user) => {
        userListHtml += `
            <li style="margin-bottom: 12px; background: #222; padding: 12px; border-radius: 6px; list-style: none;">
                <strong>${user.displayName}</strong> (@${user.username}) - <em>${user.executor}</em><br>
                🎮 Juega: <span style="color: #5865F2; font-weight: bold;">${user.gameName}</span><br>
                <small style="color: #888;">Place ID: ${user.placeId}</small>
            </li>
        `;
    });

    res.send(`
        <html>
            <head>
                <title>Usuarios en Tiempo Real</title>
                <meta http-equiv="refresh" content="10">
            </head>
            <body style="font-family: Arial, sans-serif; background: #121212; color: #fff; text-align: center; padding: 20px;">
                <h1>🟢 Personas usando tu script ahora mismo</h1>
                <h2>Total en línea: <span style="color: #00ff66;">${activeUsers.size}</span></h2>
                <ul style="max-width: 450px; margin: 0 auto; padding: 0; text-align: left;">
                    ${userListHtml || '<p style="text-align:center;">No hay nadie usando el script en este momento.</p>'}
                </ul>
            </body>
        </html>
    `);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor escuchando en puerto ${PORT}`));
