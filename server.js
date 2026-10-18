const express = require('express');
const fetch = require('node-fetch');
const app = express();

app.use(express.json());

// Puedes configurar tu Webhook como una variable de entorno en Render o ponerla aquí
const WEBHOOK_URL = process.env.WEBHOOK_URL || "https://discord.com/api/webhooks/1561259901077159946/F9NXMM2apV_YPqG27Z9NVWf2OgkUS0bvundFuD-quDFajJH6eqaeUVpPX7cEyfK5g7SD";

app.post('/api/log', async (req, res) => {
    try {
        const playerData = req.body;

        // Estructura del mensaje que llegará a Discord
        const discordPayload = {
            embeds: [
                {
                    title: "🚀 ¡Nuevo uso detectado!",
                    color: 65280,
                    fields: [
                        { name: "👤 Usuario", value: `\`${playerData.username}\` (ID: ${playerData.userId})`, inline: true },
                        { name: "⚙️ Ejecutor", value: `\`${playerData.executor}\``, inline: true },
                        { name: "🎮 Place ID", value: `\`${playerData.placeId}\``, inline: false }
                    ],
                    footer: { text: "Kaisen X Hub Logger" }
                }
            ]
        };

        // Enviar los datos a Discord
        const response = await fetch(WEBHOOK_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(discordPayload)
        });

        if (response.ok) {
            res.status(200).json({ success: true, message: "Notificación enviada con éxito" });
        } else {
            res.status(500).json({ success: false, message: "Error al comunicar con Discord" });
        }
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor de logs corriendo en el puerto ${PORT}`);
});
