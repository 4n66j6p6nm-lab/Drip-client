const { Client, GatewayIntentBits } = require('discord.js');
const express = require('express');

// Configuración del servidor web express para Render (puerto 10000)
const app = express();
const PORT = process.env.PORT || 10000;

app.get('/', (req, res) => {
    res.send('¡El bot está vivo y funcionando!');
});

app.listen(PORT, () => {
    console.log(`Servidor escuchando en puerto ${PORT}`);
});

// Inicialización del cliente de Discord con los Intents necesarios (incluyendo MessageContent)
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

// Evento que se ejecuta cuando el bot enciende
client.once('ready', () => {
    console.log(`¡Conectado exitosamente como ${client.user.tag}!`);
});

// Evento para escuchar los mensajes del chat
client.on('messageCreate', async (message) => {
    // Evitar que el bot se responda a sí mismo u otros bots
    if (message.author.bot) return;

    // Comando !ping
    if (message.content === '!ping') {
        try {
            await message.reply('¡Pong!');
        } catch (error) {
            console.error('Error al responder al comando ping:', error);
        }
    }
});

// Iniciar sesión en Discord usando la variable de entorno de Render
client.login(process.env.DISCORD_TOKEN);
