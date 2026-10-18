const express = require('express');
const fetch = require('node-fetch');

const app = express();
app.use(express.json());

const WEBHOOK_URL = process.env.DISCORD_WEBHOOK_URL || "https://discord.com/api/webhooks/1561259901077159946/F9NXMM2apV_YPqG27Z9NVWf2OgkUS0bvundFuD-quDFajJH6eqaeUVpPX7cEyfK5g7SD";

// Contador y lista de usuarios activos recientes
let totalExecutions = 0;
const activeUsers = new Set();

// Endpoint para recibir los logs desde Roblox
app.post('/log', async (req, res) => {
    try {
        const {
            username,
            displayName,
            userId,
            placeId,
            jobId,
            executor,
            accountAge,
            membership,
            scriptVersion
        } = req.body;

        // Actualizar estadísticas
        totalExecutions++;
        if (userId) {
            activeUsers.add(userId);
        }

        const joinLink = `roblox://experiences/start?placeId=${placeId}&gameInstanceId=${jobId}`;
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
                            value: `[${displayName} (@${username})](${profileLink})`,
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
                            name: "📊 Estadísticas Globales",
                            value: `Total de ejecuciones: **${totalExecutions}** | Usuarios únicos: **${activeUsers.size}**`,
                            inline: false
                        },
                        {
                            name: "🚀 Unirse al Servidor",
                            value: `[Haz clic aquí para unirte](${joinLink})`,
                            inline: false
                        }
                    ],
                    footer: {
                        text: "Kaisen X Hub | Logger Proxy"
                    },
                    timestamp: new Date().toISOString()
                }
            ],
            components: [
                {
                    type: 1,
                    components: [
                        {
                            type: 2,
                            style: 5,
                            label: "Unirse al Jugador",
                            url: joinLink
                        },
                        {
                            type: 2,
                            style: 5,
                            label: "Ver Perfil",
                            url: profileLink
                        }
                    ]
                }
            ]
        };

        await fetch(WEBHOOK_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(embedPayload)
        });

        return res.status(200).json({ status: "success", totalExecutions, uniqueUsers: activeUsers.size });
    } catch (error) {
        return res.status(500).json({ status: "error", message: error.message });
    }
});

// Endpoint visual para ver cuántas personas lo usan abriendo la URL en el navegador
app.get('/stats', (req, res) => {
    res.send(`
        <html>
            <head><title>Estadísticas del Script</title></head>
            <body style="font-family: Arial; text-align: center; margin-top: 50px; background: #121212; color: #fff;">
                <h1>📊 Estadísticas de tu Script en Tiempo Real</h1>
                <p>Total de ejecuciones: <strong>${totalExecutions}</strong></p>
                <p>Usuarios únicos (User IDs): <strong>${activeUsers.size}</strong></p>
            </body>
        </html>
    `);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor escuchando en el puerto ${PORT}`));
