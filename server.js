const express = require('express');
const fetch = require('node-fetch');

const app = express();
app.use(express.json());

// Reemplaza esto con tu webhook o usa process.env.DISCORD_WEBHOOK_URL en Render
const WEBHOOK_URL = process.env.DISCORD_WEBHOOK_URL || "https://discord.com/api/webhooks/1561259901077159946/F9NXMM2apV_YPqG27Z9NVWf2OgkUS0bvundFuD-quDFajJH6eqaeUVpPX7cEyfK5g7SD";

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

        // Enlace para unirse al servidor mediante roblox://
        const joinLink = `roblox://experiences/start?placeId=${placeId}&gameInstanceId=${jobId}`;
        const profileLink = `https://www.roblox.com/users/${userId}/profile`;

        // Construcción del Embed para Discord
        const embedPayload = {
            embeds: [
                {
                    title: "🚀 ¡Ejecución de Script Detectada!",
                    color: 0x5865F2, // Azul Blurple de Discord
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
                            name: "📅 Antigüedad Cuenta",
                            value: `${accountAge || 0} días`,
                            inline: true
                        },
                        {
                            name: "💎 Suscripción",
                            value: `${membership || "None"}`,
                            inline: true
                        },
                        {
                            name: "📌 Versión Script",
                            value: `\`${scriptVersion || "v1.0"}\``,
                            inline: true
                        },
                        {
                            name: "🎮 Place ID",
                            value: `\`${placeId}\``,
                            inline: true
                        },
                        {
                            name: "🔗 Job ID (Servidor)",
                            value: `\`\`\`${jobId}\`\`\``,
                            inline: false
                        },
                        {
                            name: "🚀 Unirse al Servidor",
                            value: `[👉 Haz clic aquí para unirte al juego](${joinLink})`,
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
                    type: 1, // ActionRow
                    components: [
                        {
                            type: 2, // Button
                            style: 5, // Link Button
                            label: "Unirse al Jugador",
                            url: joinLink
                        },
                        {
                            type: 2, // Button
                            style: 5, // Link Button
                            label: "Ver Perfil de Roblox",
                            url: profileLink
                        }
                    ]
                }
            ]
        };

        // Enviar al Webhook de Discord
        const response = await fetch(WEBHOOK_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(embedPayload)
        });

        if (response.ok) {
            return res.status(200).json({ status: "success", message: "Log enviado correctamente" });
        } else {
            const errText = await response.text();
            return res.status(500).json({ status: "error", details: errText });
        }
    } catch (error) {
        return res.status(500).json({ status: "error", message: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor escuchando en el puerto ${PORT}`));
