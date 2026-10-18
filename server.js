const express = require('express');
const { Client, GatewayIntentBits } = require('discord.js');

const app = express();
const PORT = process.env.PORT || 3000;

// Tu token de Discord integrado
const TOKEN = 'MTU2MTQ4MjAxNjkyOTc0Mjk1MQ.Gq_CVb.yVwtpkmdSCcsjQpT7LSJWQlZD5iftFNO2JvOAM';

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

client.once('ready', () => {
    console.log(`¡Bot conectado como ${client.user.tag}!`);
});

client.on('messageCreate', (message) => {
    if (message.content === '!ping') {
        message.reply('¡Pong!');
    }
});

app.get('/', (req, res) => {
    res.send('¡El servidor y el bot de Discord están funcionando correctamente!');
});

app.listen(PORT, () => {
    console.log(`Servidor escuchando en el puerto ${PORT}`);
});

client.login(TOKEN);
