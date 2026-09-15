const express = require('express');
const axios = require('axios');
const app = express();

app.use(express.json());

// Tu Webhook de Discord configurado
const DISCORD_WEBHOOK_URL = 'https://discord.com/api/webhooks/1549532747075420172/MEX-ygtRDtvT7dOANziKBDoFZZelAVGIaQPcCvb_1tsKl_M_W5ahJepoMfTtpuu21ICE';

// Sistema de Heartbeat para contador de usuarios activos
const onlineUsers = new Map();

setInterval(() => {
    const now = Date.now();
    for (const [userId, lastSeen] of onlineUsers.entries()) {
        if (now - lastSeen > 30000) {
            onlineUsers.delete(userId);
        }
    }
}, 10000);

app.post('/api/heartbeat', (req, res) => {
    const { userId } = req.body;
    if (userId) {
        onlineUsers.set(userId, Date.now());
    }
    res.json({ success: true, onlineCount: onlineUsers.size });
});

// Endpoint de Logs (Registro en consola + Webhook a Discord)
app.post("/api/log", async (req, res) => {
    const { username, userId, executor } = req.body || {};
    
    // Imprime en la consola de Render
    console.log("[EXEC]", username, userId, executor);

    // Mensaje formateado para Discord
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
        res.json({ status: "ok" });
    } catch (error) {
        console.error("Error al enviar a Discord:", error.message);
        res.status(500).json({ status: "error", message: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor iniciado en el puerto ${PORT}`);
});
