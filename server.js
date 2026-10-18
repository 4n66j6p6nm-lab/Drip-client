const express = require('express');
const fetch = require('node-fetch');

const app = express();
app.use(express.json());

const WEBHOOK_URL = process.env.DISCORD_WEBHOOK_URL || "https://discord.com/api/webhooks/1561259901077159946/F9NXMM2apV_YPqG27Z9NVWf2OgkUS0bvundFuD-quDFajJH6eqaeUVpPX7cEyfK5g7SD";

// Almacén de usuarios activos en tiempo real (UserId -> Datos)
const activeUsers = new Map();

// Endpoint para recibir la ejecución y pings de vida desde Roblox
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
            scriptVersion,
            isPing // Para distinguir entre la primera ejecución y un ping de mantenimiento
        } = req.body;

        if (!userId) return res.status(400).json({ error: "Falta userId" });

        // Guardar o actualizar la presencia del usuario
        activeUsers.set(userId, {
            username,
            displayName,
            executor: executor || "Desconocido",
            placeId,
            jobId,
            lastSeen: Date.now()
        });

        // Si es un ping constante, solo actualizamos la hora sin enviar otro mensaje a Discord
        if (isPing) {
            return res.status(200).json({ status: "pinged", onlineCount: activeUsers.size });
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
                            name: "🟢 Conectados en Tiempo Real",
                            value: `Actualmente hay **${activeUsers.size}** usuario(s) en línea`,
                            inline: false
                        },
                        {
                            name: "🚀 Unirse al Servidor",
                            value: `[Haz clic aquí para unirte](${joinLink})`,
                            inline: false
                        }
                    ],
                    footer: { text: "Kaisen X Hub | Logger Proxy" },
                    timestamp: new Date().toISOString()
                }
            ],
            components: [
                {
                    type: 1,
                    components: [
                        { type: 2, style: 5, label: "Unirse al Jugador", url: joinLink },
                        { type: 2, style: 5, label: "Ver Perfil", url: profileLink }
                    ]
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
        return res.status(500).json({ status: "error", message: error.message });
    }
});

// Ruta /online para ver quiénes están usando el script en tiempo real
app.get('/online', (req, res) => {
    // Limpiar usuarios inactivoc (que no han mandado señal en más de 2 minutos)
    const now = Date.now();
    for (const [id, user] of activeUsers.entries()) {
        if (now - user.lastSeen > 2 * 60 * 1000) {
            activeUsers.delete(id);
        }
    }

    let userListHtml = '';
    activeUsers.forEach((user, id) => {
        userListHtml += `
            <li style="margin-bottom: 10px; background: #222; padding: 10px; border-radius: 6px; list-style: none;">
                <strong>${user.displayName}</strong> (@${user.username}) - <em>${user.executor}</em><br>
                <small>Place ID: ${user.placeId}</small>
            </li>
        `;
    });

    res.send(`
        <html>
            <head>
                <title>Usuarios en Tiempo Real</title>
                <meta http-equiv="refresh" content="10"> <!-- Auto recarga cada 10s -->
            </head>
            <body style="font-family: Arial, sans-serif; background: #121212; color: #fff; text-align: center; padding: 20px;">
                <h1>🟢 Personas usando tu script ahora mismo</h1>
                <h2>Total en línea: <span style="color: #00ff66;">${activeUsers.size}</span></h2>
                <ul style="max-width: 400px; margin: 0 auto; padding: 0; text-align: left;">
                    ${userListHtml || '<p style="text-align:center;">No hay nadie usando el script en este momento.</p>'}
                </ul>
            </body>
        </html>
    `);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor escuchando en puerto ${PORT}`));
