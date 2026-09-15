const express = require('express');
const axios = require('axios');
const app = express();

app.use(express.json());

// Tu Webhook de Discord
const DISCORD_WEBHOOK_URL = 'https://discord.com/api/webhooks/1549532747075420172/MEX-ygtRDtvT7dOANziKBDoFZZelAVGIaQPcCvb_1tsKl_M_W5ahJepoMfTtpuu21ICE';

// Sistema de Heartbeat en Memoria
const onlineUsers = new Map();

// Limpiar usuarios inactivosa los 30 segundos
setInterval(() => {
    const now = Date.now();
    for (const [userId, lastSeen] of onlineUsers.entries()) {
        if (now - lastSeen > 30000) {
            onlineUsers.delete(userId);
        }
    }
}, 10000);

// Endpoint Heartbeat (para contar usuarios activos)
app.post('/api/heartbeat', (req, res) => {
    const { userId } = req.body;
    if (userId) {
        onlineUsers.set(userId, Date.now());
    }
    res.json({ success: true, onlineCount: onlineUsers.size });
});

// Endpoint de Logs (envía notificación a Discord)
app.post('/api/log', async (req, res) => {
    const { username, userId, executor } = req.body;

    const embed = {
        title: "🚀 Nueva Ejecución Registrada",
        color: 0x3498db,
        fields: [
            { name: "Usuario", value: username || "Desconocido", inline: true },
            { name: "User ID", value: String(userId || "0"), inline: true },
            { name: "Executor", value: executor || "Desconocido", inline: true }
        ],
        timestamp: new Date().toISOString()
    };

    try {
        await axios.post(DISCORD_WEBHOOK_URL, { embeds: [embed] });
        res.json({ success: true });
    } catch (error) {
        console.error("Error al enviar el webhook:", error.message);
        res.status(500).json({ error: "No se pudo enviar el registro" });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor iniciado en el puerto ${PORT}`);
});
