--[[
  KAISEN X - MM2 - WindUI
  Pistola y cuchillo con remotes reales, noclip por grupo de colisión,
  wallbang, HUD de ronda, idiomas (ES/EN/PT/FR/RU)
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players             = game:GetService("Players")
local Lighting            = game:GetService("Lighting")
local TweenService        = game:GetService("TweenService")
local RunService          = game:GetService("RunService")
local UIS                  = game:GetService("UserInputService")
local VirtualUser         = game:GetService("VirtualUser")
local HttpService         = game:GetService("HttpService")
local TeleportSvc         = game:GetService("TeleportService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local TextChatService     = game:GetService("TextChatService")
local SoundService        = game:GetService("SoundService")
local PhysicsService      = game:GetService("PhysicsService")
local CoreGui             = game:GetService("CoreGui")
local LP                  = Players.LocalPlayer

local BG_ASSET   = "rbxassetid://127386766933743"
local DISCORD_URL = "https://discord.gg/tjevxNrAt"

local GUN_NAME   = "Gun"
local KNIFE_NAME = "Knife"
local NOCLIP_GROUP = "KaisenXNoclip"

-- =============================================================================
-- IDIOMAS
-- =============================================================================
local LANGS = { { "es", "Español" }, { "en", "English" }, { "pt", "Português" }, { "fr", "Français" }, { "ru", "Русский" } }
local LIDX  = { es = 1, en = 2, pt = 3, fr = 4, ru = 5 }

local TR = {
    tab_round="Ronda,Round,Rodada,Manche,Раунд",
    tab_event="Evento,Event,Evento,Événement,Событие",
    tab_esp="ESP,ESP,ESP,ESP,ESP",
    tab_role="Rol,Role,Função,Rôle,Роль",
    tab_player="Jugador,Player,Jogador,Joueur,Игрок",
    tab_visual="Visual,Visual,Visual,Visuel,Графика",
    tab_settings="Ajustes,Settings,Configurações,Paramètres,Настройки",

    st_round="Ronda: esperando...,Round: waiting...,Rodada: aguardando...,Manche : en attente...,Раунд: ожидание...",
    st_timer="Tiempo: --:--,Time: --:--,Tempo: --:--,Temps : --:--,Время: --:--",
    st_alive="Vivos: 0,Alive: 0,Vivos: 0,Vivants : 0,Живы: 0",
    st_me="Mi rol: Inocente,My role: Innocent,Minha função: Inocente,Mon rôle : Innocent,Моя роль: Невиновный",
    st_murd="Asesino: ?,Murderer: ?,Assassino: ?,Meurtrier : ?,Убийца: ?",
    st_sher="Sheriff: ?,Sheriff: ?,Xerife: ?,Shérif : ?,Шериф: ?",
    l_round="Ronda,Round,Rodada,Manche,Раунд", l_time="Tiempo,Time,Tempo,Temps,Время",
    l_alive="Vivos,Alive,Vivos,Vivants,Живы", l_myrole="Mi rol,My role,Minha função,Mon rôle,Моя роль",
    l_murd="Asesino,Murderer,Assassino,Meurtrier,Убийца", l_sher="Sheriff,Sheriff,Xerife,Shérif,Шериф",
    l_inno="Inocente,Innocent,Inocente,Innocent,Невиновный", dead="muerto,dead,morto,mort,мёртв",
    st_live="en curso,in progress,em andamento,en cours,идёт", st_end="terminada,ended,encerrada,terminée,окончен",
    st_wait="esperando...,waiting...,aguardando...,en attente...,ожидание...",
    waiting_hud="Esperando ronda,Waiting for round,Aguardando rodada,En attente de manche,Ожидание раунда",

    tg_hud="Contador en pantalla,On-screen timer,Contador na tela,Compteur à l'écran,Таймер на экране",
    tg_nround="Avisar inicio y fin de ronda,Notify round start/end,Avisar início e fim,Prévenir début/fin,Уведомлять о раунде",
    tg_ntimer="Avisar a los 30s y 10s,Alert at 30s/10s,Avisar aos 30s/10s,Alerter à 30s/10s,Уведомлять за 30с/10с",
    tg_ndeath="Avisar si muere asesino o sheriff,Alert on murderer/sheriff death,Avisar morte do assassino/xerife,Alerter mort du meurtrier/shérif,Уведомлять о смерти",
    tg_reveal="Revelar automáticamente cada ronda,Auto-reveal every round,Revelar automaticamente,Révéler automatiquement,Авторазоблачение",
    btn_reveal="Revelar ahora,Reveal now,Revelar agora,Révéler maintenant,Разоблачить сейчас",
    n_norevl="No hay asesino para revelar,No murderer to reveal,Sem assassino,Pas de meurtrier,Нет убийцы",
    n_revlok="Mensaje enviado,Message sent,Mensagem enviada,Message envoyé,Сообщение отправлено",
    n_revlfail="No se pudo enviar,Could not send,Não foi possível enviar,Échec de l'envoi,Не удалось отправить",
    n_rstart="Ronda iniciada,Round started,Rodada iniciada,Manche commencée,Раунд начался",
    n_rend="Ronda terminada,Round ended,Rodada encerrada,Manche terminée,Раунд закончен",
    n_30="Quedan 30 segundos,30 seconds left,Faltam 30 segundos,Il reste 30 secondes,Осталось 30 секунд",
    n_10="Quedan 10 segundos,10 seconds left,Faltam 10 segundos,Il reste 10 secondes,Осталось 10 секунд",
    n_died="ha muerto,has died,morreu,est mort,погиб",

    gb_farm="Auto farm Candy,Candy auto farm,Auto farm Candy,Auto farm Candy,Автофарм конфет",
    tg_farm="Auto-recoger Candy,Auto-collect Candy,Auto-coletar Candy,Auto-ramasser Candy,Автосбор конфет",
    sl_speed="Velocidad,Speed,Velocidade,Vitesse,Скорость",
    tg_avoid="Evitar al asesino,Avoid murderer,Evitar assassino,Éviter le meurtrier,Избегать убийцу",
    sl_avoid="Distancia segura,Safe distance,Distância segura,Distance de sécurité,Безопасная дистанция",
    l_fstate="Farm,Farm,Farm,Farm,Фарм", fs_off="apagado,off,desligado,désactivé,выкл",
    fs_wait="esperando ronda,waiting for round,aguardando rodada,attente de manche,ждёт раунд",
    fs_run="farmeando,farming,farmando,en cours,фармит",
    l_count="Recorridos,Visited,Percorridos,Parcourus,Посещено",
    l_left="Candy en mapa,Candy on map,Candy no mapa,Candy sur la carte,Конфет на карте",
    tg_wide="Búsqueda ampliada,Extended search,Busca ampliada,Recherche étendue,Расширенный поиск",
    tg_autoreset="Reiniciar al acabar candies,Reset when empty,Reiniciar ao acabar,Réinitialiser,Сброс по окончании",
    tg_candyesp="Marcar candies (ESP),Mark candies (ESP),Marcar candies (ESP),Marquer les candies,Метки конфет",
    tg_nocfarm="Atravesar paredes al farmear,Walk through walls farming,Atravessar paredes,Traverser les murs,Проходить сквозь стены",
    tg_candysound="Sonido al recoger Candy,Sound on pickup,Som ao coletar,Son à la collecte,Звук при сборе",

    gb_espp="ESP jugadores,Player ESP,ESP de jogadores,ESP joueurs,ESP игроков",
    tg_esp="Activar ESP,Enable ESP,Ativar ESP,Activer ESP,Включить ESP",
    tg_espnames="Nombre y rol,Name & role,Nome e função,Nom et rôle,Имя и роль",
    tg_espgun="Resaltar pistola caída,Highlight dropped gun,Destacar arma caída,Surligner l'arme,Подсвечивать пистолет",
    col_murd="Color asesino,Murderer color,Cor assassino,Couleur meurtrier,Цвет убийцы",
    col_sher="Color sheriff,Sheriff color,Cor xerife,Couleur shérif,Цвет шерифа",
    col_inno="Color inocente,Innocent color,Cor inocente,Couleur innocent,Цвет невиновного",
    col_gun="Color pistola,Gun color,Cor da arma,Couleur de l'arme,Цвет пистолета",
    btn_grabgun="Agarrar pistola caída,Grab dropped gun,Pegar arma caída,Ramasser l'arme,Подобрать пистолет",
    n_gunok="Pistola recogida,Gun grabbed,Arma coletada,Arme ramassée,Пистолет подобран",
    n_gunmurd="El asesino no puede recoger la pistola,Murderer can't grab gun,Assassino não pode pegar,Le meurtrier ne peut pas,Убийца не может подобрать",
    n_gunhas="Ya tienes la pistola,Already have gun,Já tem a arma,Déjà l'arme,Уже есть пистолет",
    n_gunnone="No encuentro la pistola,Can't find gun,Arma não encontrada,Arme introuvable,Пистолет не найден",
    n_gunfail="No se pudo recoger,Could not grab,Não foi possível,Échec,Не удалось",
    tg_autogun="Auto-agarrar pistola,Auto-grab gun,Auto-pegar arma,Auto-ramasser l'arme,Автоподбор",
    tg_rolenotify="Avisar de mi rol,Notify my role,Avisar função,Prévenir du rôle,Уведомлять о роли",
    n_yourrole="Tu rol:,Your role:,Sua função:,Ton rôle :,Твоя роль:",

    sec_sheriff="Sheriff,Sheriff,Xerife,Shérif,Шериф",
    btn_shoot="Disparar al asesino,Shoot the murderer,Atirar no assassino,Tirer sur le meurtrier,Выстрелить в убийцу",
    tg_autoshoot="Auto-disparar al asesino,Auto-shoot murderer,Auto-atirar,Auto-tir,Автовыстрел",
    sl_range="Alcance auto,Auto range,Alcance auto,Portée auto,Дальность",
    sl_cooldown="Espera entre disparos,Shot cooldown,Intervalo entre tiros,Délai entre tirs,Пауза между выстрелами",
    sl_close="Distancia disparo instantáneo,Instant-shot distance,Distância instantânea,Distance tir instantané,Дистанция мгн. выстрела",
    tg_predict="Predecir movimiento,Predict movement,Prever movimento,Prédire le mouvement,Предсказывать движение",
    tg_los="Solo con línea de visión,Line of sight only,Só com linha de visão,Ligne de vue seulement,Только при видимости",
    tg_wallbang="Wallbang (disparar a través de paredes),Wallbang (shoot through walls),Wallbang (atirar através de paredes),Wallbang (tirer à travers les murs),Воллбанг (сквозь стены)",
    tip_wallbang="Ignora la línea de visión al disparar. Solo funciona si el juego no valida la visión en el servidor.,Ignores line of sight when shooting. Only works if the server doesn't validate sight itself.,Ignora a linha de visão. Só funciona se o servidor não validar.,Ignore la ligne de vue. Fonctionne seulement si le serveur ne la valide pas.,Игнорирует видимость. Работает, только если сервер её не проверяет.",
    btn_equipgun="Equipar pistola,Equip gun,Equipar arma,Équiper l'arme,Взять пистолет",
    err_notsher="No eres sheriff,You are not sheriff,Você não é o xerife,Tu n'es pas le shérif,Ты не шериф",
    err_nomurd="No hay asesino vivo,No living murderer,Nenhum assassino vivo,Aucun meurtrier en vie,Убийца не найден",
    err_nogun="No tienes la pistola,You don't have gun,Você não tem a arma,Tu n'as pas l'arme,Нет пистолета",
    err_noremote="La pistola no tiene Shoot,Gun has no Shoot,Arma sem Shoot,Arme sans Shoot,У пистолета нет Shoot",
    err_shoot="No se pudo disparar,Could not shoot,Não foi possível atirar,Tir impossible,Не удалось выстрелить",

    sec_murdthrow="Asesino — lanzar cuchillo,Murderer — throw knife,Assassino — lançar faca,Meurtrier — lancer couteau,Убийца — метание ножа",
    btn_throw="Lanzar cuchillo al más cercano,Throw knife at nearest,Lançar faca no mais próximo,Lancer le couteau au plus proche,Метнуть нож в ближайшего",
    tg_autoknife="Auto-lanzar cuchillo,Auto-throw knife,Auto-lançar faca,Auto-lancer couteau,Автометание ножа",
    sl_knifespeed="Velocidad estimada del cuchillo,Estimated knife speed,Velocidade estimada,Vitesse estimée,Расчётная скорость ножа",
    btn_equipknife="Equipar cuchillo,Equip knife,Equipar faca,Équiper le couteau,Взять нож",
    n_notmurd="No eres el asesino,You are not the murderer,Você não é o assassino,Tu n'es pas le meurtrier,Ты не убийца",
    n_noenemy="No hay enemigos cerca,No enemies nearby,Sem inimigos perto,Aucun ennemi proche,Нет врагов рядом",
    n_throwfail="No se pudo lanzar,Could not throw,Não foi possível lançar,Lancer impossible,Не удалось метнуть",
    n_throwok="Cuchillo lanzado,Knife thrown,Faca lançada,Couteau lancé,Нож брошен",

    sec_murdmelee="Asesino — cuerpo a cuerpo,Murderer — melee,Assassino — corpo a corpo,Meurtrier — corps à corps,Убийца — ближний бой",
    tg_aura="Aura de cuchillo,Knife aura,Aura da faca,Aura du couteau,Аура ножа",
    sl_aurarange="Alcance del aura,Aura range,Alcance da aura,Portée de l'aura,Радиус ауры",
    tg_reach="Reach del cuchillo,Knife reach,Alcance da faca,Allonge du couteau,Увеличенный нож",
    sl_reachsize="Tamaño del reach,Reach size,Tamanho do alcance,Taille de l'allonge,Размер",
    btn_killall="Matar a todos,Kill all,Matar todos,Tuer tout le monde,Убить всех",
    n_killdone="Ronda de ataques terminada,Attack run finished,Ataque concluído,Attaque terminée,Атака завершена",

    sec_safe="Inocente / seguridad,Innocent / safety,Inocente / segurança,Innocent / sécurité,Невиновный / безопасность",
    tg_safe="Modo seguro (cielo),Safe mode (sky),Modo seguro (céu),Mode sûr (ciel),Безопасный режим",
    tg_autosafe="Auto-cielo si el asesino está cerca,Auto-sky if murderer near,Auto-céu se perto,Auto-ciel si proche,Авто-небо при опасности",
    sl_safedist="Distancia de peligro,Danger distance,Distância de perigo,Distance de danger,Опасная дистанция",

    gb_move="Movimiento,Movement,Movimento,Mouvement,Движение",
    tg_ws="Velocidad,Speed,Velocidade,Vitesse,Скорость",
    tg_jp="Salto,Jump,Pulo,Saut,Прыжок",
    tg_infjump="Salto infinito,Infinite jump,Pulo infinito,Saut infini,Бесконечный прыжок",
    tg_noclip="Noclip (por grupo de colisión),Noclip (collision group),Noclip (grupo de colisão),Noclip (groupe de collision),Ноуклип (группа коллизии)",
    tg_fly="Volar,Fly,Voar,Voler,Полёт",
    sl_flyspeed="Velocidad de vuelo,Fly speed,Velocidade de voo,Vitesse de vol,Скорость полёта",
    dd_player="Jugador,Player,Jogador,Joueur,Игрок",
    btn_goplayer="Ir al jugador,Go to player,Ir ao jogador,Aller au joueur,К игроку",
    tg_antiafk="Anti-AFK,Anti-AFK,Anti-AFK,Anti-AFK,Анти-АФК",
    sl_fov="Campo de visión,Field of view,Campo de visão,Champ de vision,Поле зрения",
    btn_fps="Boost FPS,FPS boost,Boost FPS,Boost FPS,Буст FPS",
    n_fps="FPS boost aplicado,FPS boost applied,FPS boost aplicado,Boost FPS appliqué,Буст FPS применён",
    btn_rejoin="Reentrar al servidor,Rejoin server,Reentrar no servidor,Rejoindre le serveur,Перезайти",
    btn_hop="Cambiar de servidor,Server hop,Trocar de servidor,Changer de serveur,Сменить сервер",
    n_noserver="No encontré otro servidor,No other server found,Nenhum outro servidor,Aucun autre serveur,Другой сервер не найден",
    n_fail="No se pudo,Failed,Não foi possível,Échec,Не удалось", nobody="(nadie),(nobody),(ninguém),(personne),(никого)",

    gb_shaders="Shaders,Shaders,Shaders,Shaders,Шейдеры",
    dd_shader="Shader,Shader,Shader,Shader,Шейдер",
    tg_shader="Activar shader,Enable shader,Ativar shader,Activer le shader,Включить шейдер",
    btn_random="Shader aleatorio,Random shader,Shader aleatório,Shader aléatoire,Случайный шейдер",
    fx_time="Hora,Time of day,Hora,Heure,Время суток", fx_bright="Brillo,Brightness,Brilho,Luminosité,Яркость",
    fx_fog="Niebla,Fog,Névoa,Brouillard,Туман", fx_bloom="Bloom,Bloom,Bloom,Bloom,Блум",
    fx_sat="Saturación,Saturation,Saturação,Saturation,Насыщенность",
    sh_real="Realista,Realistic,Realista,Réaliste,Реалистичный", sh_noon="Mediodía claro,Clear noon,Meio-dia claro,Plein midi,Ясный полдень",
    sh_gold="Atardecer dorado,Golden sunset,Pôr do sol dourado,Coucher de soleil doré,Золотой закат",
    sh_moon="Noche lunar,Moonlit night,Noite lunar,Nuit lunaire,Лунная ночь",
    sh_cine="Cinematográfico,Cinematic,Cinematográfico,Cinématographique,Кинематографичный",
    sh_cyber="Cyberpunk neón,Neon cyberpunk,Cyberpunk neon,Cyberpunk néon,Неоновый киберпанк",
    sh_horror="Terror,Horror,Terror,Horreur,Ужас", sh_bright="Ultra brillante,Ultra bright,Ultra brilhante,Ultra lumineux,Ультраяркий",

    gb_menu="Menú,Menu,Menu,Menu,Меню",
    btn_unload="Descargar script,Unload script,Descarregar script,Décharger le script,Выгрузить скрипт",
    gb_lang="Idioma,Language,Idioma,Langue,Язык",
    n_langchange="Cambiando idioma...,Changing language...,Mudando idioma...,Changement de langue...,Смена языка...",
    btn_discord="Copiar invitación de Discord,Copy Discord invite,Copiar convite do Discord,Copier l'invitation Discord,Копировать приглашение Discord",
    n_disccopy="Invitación copiada,Invite copied,Convite copiado,Invitation copiée,Приглашение скопировано",
    n_discnosup="Tu executor no soporta copiar,Executor doesn't support copy,Executor sem suporte,Executor non pris en charge,Executor не поддерживает копирование",
    n_loaded="Kaisen X cargado,Kaisen X loaded,Kaisen X carregado,Kaisen X chargé,Kaisen X загружен",
    btn_retrybg="Reintentar imagen de fondo,Retry background image,Tentar imagem de fundo novamente,Réessayer l'image de fond,Повторить попытку фона",
    n_bgok="Imagen de fondo aplicada,Background image applied,Imagem de fundo aplicada,Image de fond appliquée,Фоновое изображение применено",
    n_bgfail="No encontré dónde poner la imagen todavía,Still couldn't find where to place the image,Ainda não encontrei onde colocar a imagem,Toujours pas trouvé où placer l'image,Пока не нашёл, куда поместить изображение",
}
local function TRS(key) local s = TR[key]; if not s then return key end; return s end

local LANG_FILE = "KaisenX/lang.txt"
local function loadLang()
    local ok, v = pcall(function() return readfile(LANG_FILE) end)
    if ok and type(v) == "string" then
        v = v:gsub("%s", "")
        if LIDX[v] then return v end
    end
    return "es"
end
local function saveLang(code)
    pcall(function()
        if makefolder then pcall(makefolder, "KaisenX") end
        writefile(LANG_FILE, code)
    end)
end

if getgenv().__KaisenXUnload then pcall(getgenv().__KaisenXUnload) task.wait(0.4) end

local okLib, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not okLib or not WindUI then
    warn("Kaisen X: no se pudo cargar WindUI. Revisa tu conexión o que el executor soporte loadstring/HttpGet.")
    return
end

local function Build(LANG)
    local function T(key)
        local raw = TRS(key)
        local parts = {}
        for part in raw:gmatch("[^,]+") do table.insert(parts, part) end
        return parts[LIDX[LANG]] or parts[2] or raw
    end

    local alive = true
    local conns = {}
    local function track(c) table.insert(conns, c); return c end

    local function getChar()
        local ch = LP.Character
        return ch, ch and ch:FindFirstChild("HumanoidRootPart"), ch and ch:FindFirstChildOfClass("Humanoid")
    end
    local function isAlive(plr)
        local ch = plr.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        return hum ~= nil and hum.Health > 0
    end
    local function toPart(o)
        if not o then return nil end
        if o:IsA("BasePart") then return o end
        local handle = o:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then return handle end
        return o:FindFirstChildWhichIsA("BasePart", true)
    end
    local function getMap()
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChild("CoinContainer") then return m end
        end
    end
    local function sendChat(text)
        local okNew = pcall(function()
            local channel = TextChatService.TextChannels and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                local r = channel:SendAsync(text)
                if r and r.TextChannel then return true end
            end
            error("no channel")
        end)
        if okNew then return true end
        return pcall(function()
            local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            local remote = ev and ev:FindFirstChild("SayMessageRequest")
            if remote then remote:FireServer(text, "All"); return true end
            error("no legacy")
        end)
    end

    local roleCache = {}
    local pdRemote
    local function normRole(r)
        if type(r) ~= "string" then return nil end
        r = r:lower()
        if r:find("murder") then return "murd" end
        if r:find("sheriff") or r:find("hero") then return "sheriff" end
        if r:find("innocent") then return "inno" end
    end
    task.spawn(function()
        while alive do
            if not (pdRemote and pdRemote.Parent) then
                for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
                    if d:IsA("RemoteFunction") and d.Name == "GetPlayerData" then pdRemote = d break end
                end
            end
            if pdRemote then
                task.spawn(function()
                    local ok, data = pcall(function() return pdRemote:InvokeServer() end)
                    if ok and type(data) == "table" then
                        for name, info in pairs(data) do
                            if type(info) == "table" then
                                roleCache[name] = normRole(info.Role) or normRole(info.role)
                            end
                        end
                    end
                end)
            end
            task.wait(2)
        end
    end)
    local function hasTool(plr, name)
        local ch, bp = plr.Character, plr:FindFirstChildOfClass("Backpack")
        return (ch and ch:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
    end
    local function getRole(plr)
        if hasTool(plr, KNIFE_NAME) then return "murd" end
        if hasTool(plr, GUN_NAME) then return "sheriff" end
        return roleCache[plr.Name] or "inno"
    end
    local function roleName(r)
        return r == "murd" and T("l_murd") or r == "sheriff" and T("l_sher") or T("l_inno")
    end
    local function findByRole(role)
        for _, plr in ipairs(Players:GetPlayers()) do
            if getRole(plr) == role then return plr end
        end
    end
    local function strictMurd()
        for _, plr in ipairs(Players:GetPlayers()) do
            if hasTool(plr, KNIFE_NAME) then return plr end
        end
    end
    local function murdererHRP()
        local m = findByRole("murd")
        if m and m ~= LP and m.Character then return m.Character:FindFirstChild("HumanoidRootPart") end
    end

    local Round = { active = false, ended = false, hadMurd = false, id = 0, startedAt = 0 }

    local gunDrop
    local function isGunName(n) return n:lower():find("gundrop", 1, true) ~= nil end
    local function isGunClass(d) return d:IsA("BasePart") or d:IsA("Model") or d:IsA("Tool") end
    local function findGunDrop()
        if gunDrop and gunDrop.Parent then return gunDrop end
        gunDrop = workspace:FindFirstChild("GunDrop")
        if not gunDrop then
            local map = getMap()
            if map then gunDrop = map:FindFirstChild("GunDrop", true) end
        end
        return gunDrop
    end
    track(workspace.DescendantAdded:Connect(function(d)
        if isGunName(d.Name) and isGunClass(d) then gunDrop = d end
    end))
    task.spawn(function()
        while alive do
            if not (gunDrop and gunDrop.Parent) and getMap() then
                pcall(function()
                    for _, d in ipairs(workspace:GetDescendants()) do
                        if isGunName(d.Name) and isGunClass(d) then gunDrop = d break end
                    end
                end)
            end
            task.wait(2.5)
        end
    end)

    local function equipTool(tool)
        local _, _, hum = getChar()
        if tool and hum and tool.Parent ~= LP.Character then
            pcall(function() hum:EquipTool(tool) end)
            local t0 = os.clock()
            while os.clock() - t0 < 0.8 do
                if LP.Character and LP.Character:FindFirstChild(tool.Name) then return LP.Character[tool.Name] end
                task.wait(0.05)
            end
        end
        return LP.Character and tool and LP.Character:FindFirstChild(tool.Name)
    end
    local function ensureGun()
        local held = LP.Character and LP.Character:FindFirstChild(GUN_NAME)
        if held then return held end
        return equipTool(hasTool(LP, GUN_NAME))
    end
    local function ensureKnife()
        local held = LP.Character and LP.Character:FindFirstChild(KNIFE_NAME)
        if held then return held end
        return equipTool(hasTool(LP, KNIFE_NAME))
    end
    local function losClear(origin, dest, excludeChar)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LP.Character, excludeChar }
        return workspace:Raycast(origin, dest - origin, params) == nil
    end
    local function nearestEnemyHRP(maxRange)
        local _, hrp = getChar()
        if not hrp then return nil end
        local best, bestD
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and isAlive(plr) then
                local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local d = (thrp.Position - hrp.Position).Magnitude
                    if (not maxRange or d <= maxRange) and (not bestD or d < bestD) then best, bestD = thrp, d end
                end
            end
        end
        return best
    end

    local function shootAt(targetHRP, useLOS, predict)
        local gun = ensureGun()
        if not gun then return false, T("err_nogun") end
        local remote = gun:FindFirstChild("Shoot")
        if not remote then return false, T("err_noremote") end
        local ch, hrp = getChar()
        if not hrp then return false, "no char" end
        local att = hrp:FindFirstChild("GunRaycastAttachment")
        local originCF = att and att.WorldCFrame or hrp.CFrame
        local pos = targetHRP.Position
        if predict then pos = pos + targetHRP.AssemblyLinearVelocity * 0.12 end
        if useLOS and not losClear(originCF.Position, pos) then return false, "no LOS" end
        local ok, err = pcall(function() remote:FireServer(originCF, CFrame.new(pos)) end)
        return ok, err
    end

    local function throwKnifeAt(targetHRP, useLOS, knifeSpeed)
        local knife = ensureKnife()
        if not knife then return false, T("err_nogun") end
        local events = knife:FindFirstChild("Events")
        local handle = knife:FindFirstChild("Handle")
        local remote = events and events:FindFirstChild("KnifeThrown")
        if not remote or not handle then return false, "missing Events/Handle" end
        local dist = (targetHRP.Position - handle.Position).Magnitude
        local leadTime = knifeSpeed > 0 and (dist / knifeSpeed) or 0
        local predictedPos = targetHRP.Position + targetHRP.AssemblyLinearVelocity * leadTime
        local dist2 = (predictedPos - handle.Position).Magnitude
        leadTime = knifeSpeed > 0 and (dist2 / knifeSpeed) or 0
        predictedPos = targetHRP.Position + targetHRP.AssemblyLinearVelocity * leadTime
        if useLOS and not losClear(handle.Position, predictedPos) then return false, "no LOS" end
        local ok, err = pcall(function() remote:FireServer(handle.CFrame, CFrame.new(predictedPos)) end)
        return ok, err
    end

    local function stab(knife, target)
        local ch = target.Character
        if not ch or not knife then return end
        pcall(function() knife:Activate() end)
        local handle = knife:FindFirstChild("Handle")
        if handle and firetouchinterest then
            for _, n in ipairs({ "HumanoidRootPart", "Head", "Torso", "UpperTorso" }) do
                local part = ch:FindFirstChild(n)
                if part then
                    pcall(function()
                        firetouchinterest(handle, part, 0)
                        firetouchinterest(handle, part, 1)
                    end)
                end
            end
        end
    end

    pcall(function() PhysicsService:RegisterCollisionGroup(NOCLIP_GROUP) end)
    pcall(function() PhysicsService:CollisionGroupSetCollidable(NOCLIP_GROUP, "Default", false) end)
    pcall(function()
        local cg = PhysicsService:GetCollisionGroups()
        for _, g in ipairs(cg) do
            pcall(function() PhysicsService:CollisionGroupSetCollidable(NOCLIP_GROUP, g.name, false) end)
        end
    end)
    local function setCollisionGroup(part, groupName)
        local ok = pcall(function() part.CollisionGroup = groupName end)
        if not ok then pcall(function() PhysicsService:SetPartCollisionGroup(part, groupName) end) end
    end
    local noclipParts = {}
    local function applyNoclip(on)
        local ch = LP.Character
        if not ch then return end
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then
                if on then
                    if not noclipParts[p] then
                        local okGet, cur = pcall(function() return p.CollisionGroup end)
                        noclipParts[p] = okGet and cur or "Default"
                    end
                    setCollisionGroup(p, NOCLIP_GROUP)
                    p.CanCollide = false
                else
                    setCollisionGroup(p, noclipParts[p] or "Default")
                end
            end
        end
        if not on then noclipParts = {} end
    end

    -- =============================================================================
    -- VENTANA + imagen de fondo: ya NO se recorre CoreGui completo (podía estar
    -- protegido y lanzar un error que detenía todo el script). Solo se busca
    -- dentro del propio contenedor nuevo que crea WindUI.
    -- =============================================================================
    local guiParent = (pcall(function() return gethui() end) and gethui()) or CoreGui

    for _, n in ipairs({ "KaisenXESP", "KaisenXHUD" }) do
        local old = guiParent:FindFirstChild(n); if old then old:Destroy() end
    end
    local espFolder = Instance.new("Folder"); espFolder.Name = "KaisenXESP"; espFolder.Parent = guiParent

    local function listScreenGuis()
        local set = {}
        local ok = pcall(function()
            for _, sg in ipairs(guiParent:GetChildren()) do
                if sg:IsA("ScreenGui") or sg:IsA("Folder") then set[sg] = true end
            end
        end)
        return set
    end
    local before = listScreenGuis()

    local okWin, Window = pcall(function()
        return WindUI:CreateWindow({
            Title = "Kaisen X",
            Icon = "swords",
            Author = "Kaisen X",
            Folder = "KaisenX",
            Theme = "Dark",
            Size = UDim2.fromOffset(560, 420),
        })
    end)
    if not okWin or not Window then
        warn("Kaisen X: no se pudo crear la ventana de WindUI: " .. tostring(Window))
        return
    end

    local newGui
    for i = 1, 40 do
        local after = listScreenGuis()
        for sg in pairs(after) do
            if not before[sg] then newGui = sg break end
        end
        if newGui then break end
        task.wait(0.1)
    end

    -- Solo busca dentro de newGui (y guiParent como respaldo), nunca en CoreGui completo
    local bgImage
    local function tryAttachBg()
        local biggest, biggestArea
        pcall(function()
            local roots = { newGui, guiParent }
            for _, root in ipairs(roots) do
                if root then
                    for _, f in ipairs(root:GetDescendants()) do
                        if (f:IsA("Frame") or f:IsA("CanvasGroup") or f:IsA("ScrollingFrame")) and f.Name ~= "KaisenXBg" then
                            local sz = f.AbsoluteSize
                            local area = sz.X * sz.Y
                            if area > 300 * 200 and (not biggestArea or area > biggestArea) then
                                biggest, biggestArea = f, area
                            end
                        end
                    end
                end
            end
        end)
        if not biggest then return false end
        if bgImage then pcall(function() bgImage:Destroy() end) end
        local ok = pcall(function()
            local img = Instance.new("ImageLabel")
            img.Name = "KaisenXBg"
            img.Size = UDim2.fromScale(1, 1)
            img.BackgroundTransparency = 1
            img.Image = BG_ASSET
            img.ImageTransparency = 0.8
            img.ScaleType = Enum.ScaleType.Crop
            img.ZIndex = math.max(biggest.ZIndex - 1, -100)
            img.Active = false
            img.Parent = biggest
            bgImage = img
        end)
        return ok
    end
    task.spawn(function()
        for i = 1, 20 do
            task.wait(0.25)
            if tryAttachBg() then break end
        end
    end)

    local hud = Instance.new("ScreenGui")
    hud.Name = "KaisenXHUD"
    hud.ResetOnSpawn = false
    hud.IgnoreGuiInset = true
    hud.Parent = guiParent
    local hudFrame = Instance.new("Frame")
    hudFrame.Size = UDim2.fromOffset(200, 44)
    hudFrame.Position = UDim2.new(0.5, -100, 0, 4)
    hudFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    hudFrame.BackgroundTransparency = 0.35
    hudFrame.BorderSizePixel = 0
    hudFrame.Active = false
    hudFrame.Parent = hud
    Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 8)
    local function hudLabel(y, size, bold)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -8, 0, 20)
        l.Position = UDim2.fromOffset(4, y)
        l.BackgroundTransparency = 1
        l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize = size
        l.TextColor3 = Color3.fromRGB(240, 240, 250)
        l.Active = false
        l.Parent = hudFrame
        return l
    end
    local hudTop = hudLabel(2, 17, true)
    local hudBot = hudLabel(23, 12, false)

    getgenv().__KaisenXUnload = function()
        pcall(function()
            alive = false
            for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
            applyNoclip(false)
            pcall(function() espFolder:Destroy() end)
            pcall(function() hud:Destroy() end)
            if Window.Destroy then Window:Destroy() end
        end)
    end

    local RoundTab = Window:Tab({ Title = T("tab_round"), Icon = "clock" })
    local EventTab = Window:Tab({ Title = T("tab_event"), Icon = "candy" })
    local ESPTab   = Window:Tab({ Title = T("tab_esp"), Icon = "eye" })
    local RoleTab  = Window:Tab({ Title = T("tab_role"), Icon = "swords" })
    local PlayerTab= Window:Tab({ Title = T("tab_player"), Icon = "user" })
    local VisualTab= Window:Tab({ Title = T("tab_visual"), Icon = "palette" })
    local SettingsTab = Window:Tab({ Title = T("tab_settings"), Icon = "settings" })

    local S = {
        HUDOn = true, NotifyRound = true, NotifyTimer = true, NotifyDeaths = true, AutoReveal = false,
        AutoFarm = false, FarmSpeed = 27, AvoidMurd = true, AvoidDist = 30, WideSearch = true,
        AutoReset = false, CandyESP = false, NoClipFarm = true, CandySound = false,
        ESPOn = false, ESPNames = true, ESPGun = true,
        ColMurd = Color3.fromRGB(255, 50, 50), ColSher = Color3.fromRGB(60, 140, 255),
        ColInno = Color3.fromRGB(80, 230, 120), ColGun = Color3.fromRGB(255, 220, 60),
        AutoGun = false, RoleNotify = true,
        AutoShoot = false, ShootRange = 70, ShootCooldown = 2, ShootPredict = true, ShootLOS = true,
        ShootCloseRange = 15, Wallbang = false,
        AutoKnife = false, KnifeRange = 60, KnifeCooldown = 1.5, KnifeLOS = true, KnifeSpeed = 80,
        KnifeAura = false, AuraRange = 12, KnifeReach = false, ReachSize = 8,
        SafeMode = false, AutoSafe = false, SafeDist = 25,
        WSOn = false, WS = 24, JPOn = false, JP = 60, InfJump = false,
        Noclip = false, Fly = false, FlySpeed = 40,
        ShaderOn = false, ShaderId = "real", AntiAFK = true,
    }

    do
        local lblState = RoundTab:Paragraph({ Title = T("st_round") })
        local lblTimer = RoundTab:Paragraph({ Title = T("st_timer") })
        local lblAlive = RoundTab:Paragraph({ Title = T("st_alive") })
        local lblMe    = RoundTab:Paragraph({ Title = T("st_me") })
        local lblMurd  = RoundTab:Paragraph({ Title = T("st_murd") })
        local lblSher  = RoundTab:Paragraph({ Title = T("st_sher") })

        RoundTab:Toggle({ Title = T("tg_hud"), Value = true, Callback = function(v) S.HUDOn = v; hud.Enabled = v end })
        RoundTab:Toggle({ Title = T("tg_nround"), Value = true, Callback = function(v) S.NotifyRound = v end })
        RoundTab:Toggle({ Title = T("tg_ntimer"), Value = true, Callback = function(v) S.NotifyTimer = v end })
        RoundTab:Toggle({ Title = T("tg_ndeath"), Value = true, Callback = function(v) S.NotifyDeaths = v end })

        local function findGameTimer()
            local pg = LP:FindFirstChild("PlayerGui")
            if not pg then return end
            for _, d in ipairs(pg:GetDescendants()) do
                if d:IsA("TextLabel") and d.Name:lower():find("timer") and d.Text:match("^%s*%d+:%d%d%s*$") then
                    return d
                end
            end
        end
        local function readTimer(lbl)
            local m, s = lbl.Text:match("(%d+):(%d%d)")
            if m then return tonumber(m) * 60 + tonumber(s) end
        end
        pcall(function()
            for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
                if d:IsA("RemoteEvent") then
                    local n = d.Name:lower()
                    if n:find("roundend") or n:find("endround") or n == "gameover" then
                        track(d.OnClientEvent:Connect(function() Round.ended = true end))
                    end
                end
            end
        end)

        local revealedRound = -1
        local function doReveal(manual)
            local m = findByRole("murd")
            if not m then
                if manual then WindUI:Notify({ Title = "Kaisen X", Content = T("n_norevl"), Duration = 3 }) end
                return
            end
            local ok = sendChat("The murder is " .. m.Name .. " kaisen x")
            if manual then WindUI:Notify({ Title = "Kaisen X", Content = ok and T("n_revlok") or T("n_revlfail"), Duration = 3 }) end
        end
        RoundTab:Toggle({ Title = T("tg_reveal"), Value = false, Callback = function(v) S.AutoReveal = v end })
        RoundTab:Button({ Title = T("btn_reveal"), Callback = function() task.spawn(doReveal, true) end })

        local prevActive, wasMap = false, nil
        local gameTimer, lastSec, direction
        local warned30, warned10 = false, false
        local prevAlive = {}

        task.spawn(function()
            local tick = 0
            while alive do
                local map = getMap()
                if map ~= wasMap then
                    wasMap = map
                    Round.ended, Round.hadMurd = false, false
                    lastSec, direction = nil, nil
                end
                tick += 1
                if not (gameTimer and gameTimer.Parent) and tick % 6 == 1 then gameTimer = findGameTimer() end
                local gs = gameTimer and gameTimer.Parent and readTimer(gameTimer) or nil
                local remaining
                if gs then
                    if lastSec then
                        if gs < lastSec then direction = "down" elseif gs > lastSec then direction = "up" end
                    end
                    lastSec = gs
                    if direction == "down" then remaining = gs end
                end

                local newActive = false
                local m = strictMurd()
                if map and not Round.ended then
                    if m then
                        Round.hadMurd = true
                        if isAlive(m) then newActive = true else Round.ended = true end
                    elseif Round.hadMurd then
                        Round.ended = true
                    end
                end
                if newActive and remaining == 0 and os.clock() - Round.startedAt > 10 then
                    Round.ended = true; newActive = false
                end

                if newActive and not prevActive then
                    Round.id += 1
                    Round.startedAt = os.clock()
                    warned30, warned10 = false, false
                    prevAlive = {}
                    if S.NotifyRound then WindUI:Notify({ Title = "Kaisen X", Content = T("n_rstart"), Duration = 3 }) end
                elseif not newActive and prevActive then
                    if S.NotifyRound then WindUI:Notify({ Title = "Kaisen X", Content = T("n_rend"), Duration = 3 }) end
                end
                prevActive = newActive
                Round.active = newActive

                if newActive and S.AutoReveal and revealedRound ~= Round.id then
                    revealedRound = Round.id
                    task.spawn(doReveal, false)
                end

                local timeText = "--:--"
                if newActive then
                    if gs and direction == "down" then timeText = string.format("%02d:%02d", gs // 60, gs % 60)
                    elseif gs and direction == "up" then timeText = string.format("%02d:%02d", gs // 60, gs % 60)
                    else
                        local e = os.clock() - Round.startedAt
                        timeText = string.format("%02d:%02d", e // 60, e % 60)
                    end
                end
                if remaining and newActive and S.NotifyTimer then
                    if remaining <= 30 and not warned30 then warned30 = true; WindUI:Notify({ Title = "Kaisen X", Content = T("n_30"), Duration = 3 }) end
                    if remaining <= 10 and not warned10 then warned10 = true; WindUI:Notify({ Title = "Kaisen X", Content = T("n_10"), Duration = 3 }) end
                end

                local nAlive = 0
                for _, plr in ipairs(Players:GetPlayers()) do if isAlive(plr) then nAlive += 1 end end
                local murd, sher = findByRole("murd"), findByRole("sheriff")
                local myRole = getRole(LP)

                if newActive and S.NotifyDeaths then
                    for tag, plr in pairs({ murd = murd, sheriff = sher }) do
                        if plr then
                            local a = isAlive(plr)
                            if prevAlive[tag] == true and not a then
                                WindUI:Notify({ Title = "Kaisen X", Content = roleName(tag) .. " (" .. plr.Name .. ") " .. T("n_died"), Duration = 4 })
                            end
                            prevAlive[tag] = a
                        end
                    end
                end

                local stText = newActive and T("st_live") or (map and Round.ended and T("st_end") or T("st_wait"))
                pcall(function() lblState:SetTitle(T("l_round") .. ": " .. stText) end)
                pcall(function() lblTimer:SetTitle(T("l_time") .. ": " .. timeText) end)
                pcall(function() lblAlive:SetTitle(T("l_alive") .. ": " .. nAlive) end)
                pcall(function() lblMe:SetTitle(T("l_myrole") .. ": " .. roleName(myRole)) end)
                pcall(function() lblMurd:SetTitle(T("l_murd") .. ": " .. (murd and (murd.Name .. (isAlive(murd) and "" or " (" .. T("dead") .. ")")) or "?")) end)
                pcall(function() lblSher:SetTitle(T("l_sher") .. ": " .. (sher and (sher.Name .. (isAlive(sher) and "" or " (" .. T("dead") .. ")")) or "?")) end)

                hud.Enabled = S.HUDOn
                hudTop.Text = newActive and timeText or T("waiting_hud")
                hudBot.Text = T("l_myrole") .. ": " .. roleName(myRole) .. "  ·  " .. T("l_alive") .. ": " .. nAlive

                task.wait(0.4)
            end
        end)
    end

    do
        EventTab:Toggle({ Title = T("tg_farm"), Value = false, Callback = function(v) S.AutoFarm = v end })
        EventTab:Slider({ Title = T("sl_speed"), Value = { Min = 10, Max = 70, Default = 27 }, Callback = function(v) S.FarmSpeed = v end })
        EventTab:Toggle({ Title = T("tg_avoid"), Value = true, Callback = function(v) S.AvoidMurd = v end })
        EventTab:Slider({ Title = T("sl_avoid"), Value = { Min = 10, Max = 80, Default = 30 }, Callback = function(v) S.AvoidDist = v end })
        local lblFarm  = EventTab:Paragraph({ Title = T("l_fstate") .. ": " .. T("fs_off") })
        local lblCount = EventTab:Paragraph({ Title = T("l_count") .. ": 0" })
        local lblLeft  = EventTab:Paragraph({ Title = T("l_left") .. ": 0" })

        EventTab:Toggle({ Title = T("tg_wide"), Value = true, Callback = function(v) S.WideSearch = v end })
        EventTab:Toggle({ Title = T("tg_autoreset"), Value = false, Callback = function(v) S.AutoReset = v end })
        EventTab:Toggle({ Title = T("tg_candyesp"), Value = false, Callback = function(v) S.CandyESP = v end })
        EventTab:Toggle({ Title = T("tg_nocfarm"), Value = true, Callback = function(v) S.NoClipFarm = v end })
        EventTab:Toggle({ Title = T("tg_candysound"), Value = false, Callback = function(v) S.CandySound = v end })

        local function onCandyPicked()
            if S.CandySound then
                pcall(function()
                    local s = Instance.new("Sound")
                    s.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                    s.Volume = 0.6
                    s.Parent = SoundService
                    s:Play()
                    game:GetService("Debris"):AddItem(s, 2)
                end)
            end
        end

        local Farm = { visited = setmetatable({}, { __mode = "k" }), skip = setmetatable({}, { __mode = "k" }),
                       count = 0, resetDone = false, seenRound = -1, tween = nil }
        local function resetFarm()
            Farm.visited = setmetatable({}, { __mode = "k" })
            Farm.skip = setmetatable({}, { __mode = "k" })
            Farm.count = 0
            Farm.resetDone = false
            pcall(function() lblCount:SetTitle(T("l_count") .. ": 0") end)
        end
        local function getCandies()
            local list, seen = {}, {}
            local map = getMap()
            if not map then return list, nil end
            for _, c in ipairs(map.CoinContainer:GetChildren()) do
                local p = toPart(c)
                if p and not seen[p] then seen[p] = true; table.insert(list, p) end
            end
            if S.WideSearch then
                for _, d in ipairs(map:GetDescendants()) do
                    if d:IsA("BasePart") and not seen[d] and d.Name:lower():find("candy") then
                        seen[d] = true; table.insert(list, d)
                    end
                end
            end
            return list, map
        end

        task.spawn(function()
            while alive do
                if Farm.seenRound ~= Round.id then Farm.seenRound = Round.id; resetFarm() end
                local list = Round.active and getCandies() or {}
                local pending = 0
                for _, p in ipairs(list) do if p.Parent and not Farm.visited[p] then pending += 1 end end
                pcall(function() lblLeft:SetTitle(T("l_left") .. ": " .. pending) end)

                pcall(function()
                    lblFarm:SetTitle(T("l_fstate") .. ": " .. (not S.AutoFarm and T("fs_off") or (Round.active and T("fs_run") or T("fs_wait"))))
                end)

                if S.AutoFarm and Round.active then
                    local _, hrp, hum = getChar()
                    if hrp and hum and hum.Health > 0 then
                        local mhrp = (S.AvoidMurd and getRole(LP) ~= "murd") and murdererHRP() or nil
                        local best, bestD
                        for _, p in ipairs(list) do
                            if p.Parent and not Farm.visited[p] and (not Farm.skip[p] or Farm.skip[p] < os.clock()) then
                                if mhrp and (p.Position - mhrp.Position).Magnitude < S.AvoidDist then
                                    Farm.skip[p] = os.clock() + 3
                                else
                                    local d = (p.Position - hrp.Position).Magnitude
                                    if not bestD or d < bestD then best, bestD = p, d end
                                end
                            end
                        end
                        if best then
                            local t = math.max(bestD / S.FarmSpeed, 0.05)
                            local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear),
                                { CFrame = CFrame.new(best.Position + Vector3.new(0, 1.5, 0)) })
                            local done = false
                            tw.Completed:Connect(function() done = true end)
                            Farm.tween = tw
                            tw:Play()
                            while not done and alive and Round.active and S.AutoFarm do task.wait(0.05) end
                            if not done then tw:Cancel() end
                            Farm.tween = nil
                            if done and Round.active and S.AutoFarm then
                                if firetouchinterest and best.Parent then
                                    pcall(function() firetouchinterest(hrp, best, 0); firetouchinterest(hrp, best, 1) end)
                                end
                                task.wait(0.1)
                                Farm.visited[best] = true
                                Farm.count += 1
                                pcall(function() lblCount:SetTitle(T("l_count") .. ": " .. Farm.count) end)
                                onCandyPicked()
                            end
                        elseif pending == 0 and S.AutoReset and not Farm.resetDone then
                            Farm.resetDone = true
                            task.wait(1)
                            local _, _, h2 = getChar()
                            if h2 and Round.active then h2.Health = 0 end
                        else
                            task.wait(0.5)
                        end
                    else
                        task.wait(0.8)
                    end
                else
                    if Farm.tween then pcall(function() Farm.tween:Cancel() end); Farm.tween = nil end
                    task.wait(0.5)
                end
                task.wait()
            end
        end)

        local candyTags = {}
        task.spawn(function()
            while alive do
                if S.CandyESP and Round.active then
                    local list = getCandies()
                    local set = {}
                    for _, p in ipairs(list) do
                        set[p] = true
                        if not candyTags[p] then
                            local bb = Instance.new("BillboardGui")
                            bb.Size = UDim2.fromOffset(10, 10)
                            bb.AlwaysOnTop = true
                            bb.Adornee = p
                            local f = Instance.new("Frame")
                            f.Size = UDim2.fromScale(1, 1)
                            f.BackgroundColor3 = Color3.fromRGB(255, 140, 20)
                            f.BorderSizePixel = 0
                            f.Parent = bb
                            Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
                            bb.Parent = espFolder
                            candyTags[p] = bb
                        end
                    end
                    for p, bb in pairs(candyTags) do
                        if not set[p] or not p.Parent then bb:Destroy(); candyTags[p] = nil end
                    end
                else
                    for p, bb in pairs(candyTags) do bb:Destroy(); candyTags[p] = nil end
                end
                task.wait(0.5)
            end
        end)

        track(RunService.Stepped:Connect(function()
            if S.AutoFarm and Round.active and S.NoClipFarm then
                local ch = LP.Character
                if ch then
                    for _, p in ipairs(ch:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end
        end))
    end

    local grabGun
    do
        ESPTab:Toggle({ Title = T("tg_esp"), Value = false, Callback = function(v) S.ESPOn = v end })
        ESPTab:Toggle({ Title = T("tg_espnames"), Value = true, Callback = function(v) S.ESPNames = v end })
        ESPTab:Toggle({ Title = T("tg_espgun"), Value = true, Callback = function(v) S.ESPGun = v end })
        ESPTab:Colorpicker({ Title = T("col_murd"), Default = S.ColMurd, Callback = function(c) S.ColMurd = c end })
        ESPTab:Colorpicker({ Title = T("col_sher"), Default = S.ColSher, Callback = function(c) S.ColSher = c end })
        ESPTab:Colorpicker({ Title = T("col_inno"), Default = S.ColInno, Callback = function(c) S.ColInno = c end })
        ESPTab:Colorpicker({ Title = T("col_gun"), Default = S.ColGun, Callback = function(c) S.ColGun = c end })

        local function ensureHighlight(key, adornee, color)
            local hl = espFolder:FindFirstChild("HL_" .. key)
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "HL_" .. key
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.55
                hl.Parent = espFolder
            end
            hl.Adornee = adornee; hl.FillColor = color; hl.OutlineColor = color
        end
        local function ensureTag(key, head, text, color)
            local bb = espFolder:FindFirstChild("BB_" .. key)
            if not bb then
                bb = Instance.new("BillboardGui")
                bb.Name = "BB_" .. key
                bb.AlwaysOnTop = true
                bb.Size = UDim2.fromOffset(150, 20)
                bb.StudsOffset = Vector3.new(0, 2.6, 0)
                local tl = Instance.new("TextLabel")
                tl.Name = "T"; tl.Size = UDim2.fromScale(1, 1); tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamBold; tl.TextSize = 13; tl.TextStrokeTransparency = 0.4
                tl.Parent = bb
                bb.Parent = espFolder
            end
            bb.Adornee = head; bb.T.Text = text; bb.T.TextColor3 = color
        end

        task.spawn(function()
            while alive do
                if S.ESPOn or S.ESPGun then
                    local keep = {}
                    if S.ESPOn then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            local ch = plr ~= LP and plr.Character
                            local head = ch and ch:FindFirstChild("Head")
                            if head and isAlive(plr) then
                                local role = getRole(plr)
                                local col = role == "murd" and S.ColMurd or role == "sheriff" and S.ColSher or S.ColInno
                                ensureHighlight(plr.Name, ch, col)
                                keep["HL_" .. plr.Name] = true
                                if S.ESPNames then
                                    ensureTag(plr.Name, head, plr.Name .. " [" .. roleName(role) .. "]", col)
                                    keep["BB_" .. plr.Name] = true
                                end
                            end
                        end
                    end
                    if S.ESPGun then
                        local g = findGunDrop()
                        if g then ensureHighlight("GunDrop", g, S.ColGun); keep["HL_GunDrop"] = true end
                    end
                    for _, o in ipairs(espFolder:GetChildren()) do
                        if (o.Name:sub(1, 3) == "HL_" or o.Name:sub(1, 3) == "BB_") and not keep[o.Name] then o:Destroy() end
                    end
                else
                    for _, o in ipairs(espFolder:GetChildren()) do
                        if o.Name:sub(1, 3) == "HL_" or o.Name:sub(1, 3) == "BB_" then o:Destroy() end
                    end
                end
                task.wait(0.4)
            end
        end)

        grabGun = function()
            local g = findGunDrop()
            local part = toPart(g)
            if not part then return false, "none" end
            if getRole(LP) == "murd" then return false, "murd" end
            if hasTool(LP, GUN_NAME) then return false, "has" end
            local _, hrp = getChar()
            if not hrp then return false, "fail" end
            local function touch()
                if firetouchinterest then
                    pcall(function() firetouchinterest(hrp, part, 0); firetouchinterest(hrp, part, 1) end)
                end
            end
            local function waitGun(sec)
                local t0 = os.clock()
                while os.clock() - t0 < sec do
                    if hasTool(LP, GUN_NAME) then return true end
                    task.wait(0.05)
                end
                return hasTool(LP, GUN_NAME) ~= nil
            end
            touch()
            if waitGun(0.4) then return true, "ok" end
            if part.Parent then
                local old = hrp.CFrame
                hrp.CFrame = part.CFrame + Vector3.new(0, 2.5, 0)
                task.wait(0.2)
                touch()
                local got = waitGun(1)
                hrp.CFrame = old
                if got then return true, "ok" end
            end
            return false, "fail"
        end

        ESPTab:Button({ Title = T("btn_grabgun"), Callback = function()
            task.spawn(function()
                local ok, a, b = pcall(grabGun)
                local success = ok and a
                local why = ok and b
                if success then WindUI:Notify({ Title = "Kaisen X", Content = T("n_gunok"), Duration = 3 })
                elseif why == "murd" then WindUI:Notify({ Title = "Kaisen X", Content = T("n_gunmurd"), Duration = 3 })
                elseif why == "has" then WindUI:Notify({ Title = "Kaisen X", Content = T("n_gunhas"), Duration = 3 })
                elseif why == "none" then WindUI:Notify({ Title = "Kaisen X", Content = T("n_gunnone"), Duration = 3 })
                else WindUI:Notify({ Title = "Kaisen X", Content = T("n_gunfail"), Duration = 3 }) end
            end)
        end })
        ESPTab:Toggle({ Title = T("tg_autogun"), Value = false, Callback = function(v) S.AutoGun = v end })
        ESPTab:Toggle({ Title = T("tg_rolenotify"), Value = true, Callback = function(v) S.RoleNotify = v end })

        task.spawn(function()
            while alive do
                local wait = 0.5
                if S.AutoGun and getRole(LP) ~= "murd" and not hasTool(LP, GUN_NAME) and findGunDrop() then
                    local ok, got = pcall(grabGun)
                    wait = (ok and got) and 1 or 3
                end
                task.wait(wait)
            end
        end)

        local lastRole
        task.spawn(function()
            while alive do
                local r = getRole(LP)
                if r ~= lastRole then
                    lastRole = r
                    if S.RoleNotify and r ~= "inno" then
                        WindUI:Notify({ Title = "Kaisen X", Content = T("n_yourrole") .. " " .. roleName(r), Duration = 4 })
                    end
                end
                task.wait(1)
            end
        end)
    end

    local safePlat, savedCF
    do
        local shooting, lastShot = false, 0
        RoleTab:Section({ Title = T("sec_sheriff") })
        RoleTab:Button({ Title = T("btn_shoot"), Callback = function()
            if getRole(LP) ~= "sheriff" then WindUI:Notify({ Title = "Kaisen X", Content = T("err_notsher"), Duration = 3 }) return end
            local m = findByRole("murd")
            local mh = m and m ~= LP and m.Character and m.Character:FindFirstChild("HumanoidRootPart")
            if not mh or not isAlive(m) then WindUI:Notify({ Title = "Kaisen X", Content = T("err_nomurd"), Duration = 3 }) return end
            if shooting then return end
            task.spawn(function()
                shooting = true
                local useLOS = S.ShootLOS and not S.Wallbang
                local ok, err = shootAt(mh, useLOS, S.ShootPredict)
                shooting = false
                if ok then lastShot = os.clock() else WindUI:Notify({ Title = "Kaisen X", Content = T("err_shoot"), Duration = 3 }) end
            end)
        end })
        RoleTab:Toggle({ Title = T("tg_autoshoot"), Value = false, Callback = function(v) S.AutoShoot = v end })
        RoleTab:Slider({ Title = T("sl_range"), Value = { Min = 20, Max = 200, Default = 70 }, Callback = function(v) S.ShootRange = v end })
        RoleTab:Slider({ Title = T("sl_cooldown"), Value = { Min = 0.3, Max = 6, Default = 2 }, Callback = function(v) S.ShootCooldown = v end })
        RoleTab:Slider({ Title = T("sl_close"), Value = { Min = 3, Max = 40, Default = 15 }, Callback = function(v) S.ShootCloseRange = v end })
        RoleTab:Toggle({ Title = T("tg_predict"), Value = true, Callback = function(v) S.ShootPredict = v end })
        RoleTab:Toggle({ Title = T("tg_los"), Value = true, Callback = function(v) S.ShootLOS = v end })
        RoleTab:Toggle({ Title = T("tg_wallbang"), Value = false, Callback = function(v) S.Wallbang = v end })
        RoleTab:Paragraph({ Title = T("tip_wallbang") })
        RoleTab:Button({ Title = T("btn_equipgun"), Callback = function() task.spawn(ensureGun) end })

        task.spawn(function()
            while alive do
                task.wait(0.1)
                if S.AutoShoot and Round.active and not shooting and getRole(LP) == "sheriff" then
                    local m = findByRole("murd")
                    local mh = m and m ~= LP and m.Character and m.Character:FindFirstChild("HumanoidRootPart")
                    local _, hrp = getChar()
                    if mh and hrp and isAlive(m) then
                        local dist = (mh.Position - hrp.Position).Magnitude
                        local closeRange = dist <= S.ShootCloseRange
                        local canFire = closeRange or (os.clock() - lastShot > S.ShootCooldown)
                        if dist <= S.ShootRange and canFire then
                            shooting = true
                            local useLOS = S.ShootLOS and not S.Wallbang
                            local ok = shootAt(mh, useLOS, S.ShootPredict)
                            if ok then lastShot = closeRange and (os.clock() - S.ShootCooldown + 0.15) or os.clock() end
                            shooting = false
                        end
                    end
                end
            end
        end)

        local throwing, lastThrow = false, 0
        RoleTab:Section({ Title = T("sec_murdthrow") })
        RoleTab:Button({ Title = T("btn_throw"), Callback = function()
            if getRole(LP) ~= "murd" then WindUI:Notify({ Title = "Kaisen X", Content = T("n_notmurd"), Duration = 3 }) return end
            local best = nearestEnemyHRP()
            if not best then WindUI:Notify({ Title = "Kaisen X", Content = T("n_noenemy"), Duration = 3 }) return end
            local ok, err = throwKnifeAt(best, S.KnifeLOS, S.KnifeSpeed)
            if not ok then WindUI:Notify({ Title = "Kaisen X", Content = T("n_throwfail"), Duration = 3 })
            else WindUI:Notify({ Title = "Kaisen X", Content = T("n_throwok"), Duration = 2 }) end
        end })
        RoleTab:Toggle({ Title = T("tg_autoknife"), Value = false, Callback = function(v) S.AutoKnife = v end })
        RoleTab:Slider({ Title = T("sl_range"), Value = { Min = 10, Max = 150, Default = 60 }, Callback = function(v) S.KnifeRange = v end })
        RoleTab:Slider({ Title = T("sl_cooldown"), Value = { Min = 0.5, Max = 4, Default = 1.5 }, Callback = function(v) S.KnifeCooldown = v end })
        RoleTab:Slider({ Title = T("sl_knifespeed"), Value = { Min = 30, Max = 150, Default = 80 }, Callback = function(v) S.KnifeSpeed = v end })
        RoleTab:Toggle({ Title = T("tg_los"), Value = true, Callback = function(v) S.KnifeLOS = v end })
        RoleTab:Button({ Title = T("btn_equipknife"), Callback = function() task.spawn(ensureKnife) end })

        task.spawn(function()
            while alive do
                task.wait(0.2)
                if S.AutoKnife and Round.active and not throwing
                    and os.clock() - lastThrow > S.KnifeCooldown
                    and getRole(LP) == "murd" then
                    local best = nearestEnemyHRP(S.KnifeRange)
                    if best then
                        throwing = true
                        local ok = throwKnifeAt(best, S.KnifeLOS, S.KnifeSpeed)
                        if ok then lastThrow = os.clock() end
                        throwing = false
                    end
                end
            end
        end)

        RoleTab:Section({ Title = T("sec_murdmelee") })
        RoleTab:Toggle({ Title = T("tg_aura"), Value = false, Callback = function(v) S.KnifeAura = v end })
        RoleTab:Slider({ Title = T("sl_aurarange"), Value = { Min = 5, Max = 30, Default = 12 }, Callback = function(v) S.AuraRange = v end })
        RoleTab:Toggle({ Title = T("tg_reach"), Value = false, Callback = function(v) S.KnifeReach = v end })
        RoleTab:Slider({ Title = T("sl_reachsize"), Value = { Min = 2, Max = 25, Default = 8 }, Callback = function(v) S.ReachSize = v end })
        RoleTab:Button({ Title = T("btn_killall"), Callback = function()
            if getRole(LP) ~= "murd" then WindUI:Notify({ Title = "Kaisen X", Content = T("n_notmurd"), Duration = 3 }) return end
            task.spawn(function()
                local knife = ensureKnife()
                local _, hrp = getChar()
                if not knife or not hrp then return end
                local old = hrp.CFrame
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and isAlive(plr) then
                        local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if thrp then
                            hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 2.5)
                            task.wait(0.12)
                            stab(knife, plr)
                            task.wait(0.28)
                        end
                    end
                end
                hrp.CFrame = old
                WindUI:Notify({ Title = "Kaisen X", Content = T("n_killdone"), Duration = 3 })
            end)
        end })

        task.spawn(function()
            while alive do
                if S.KnifeAura and getRole(LP) == "murd" then
                    pcall(function()
                        local knife = ensureKnife()
                        local _, hrp = getChar()
                        if knife and hrp then
                            for _, plr in ipairs(Players:GetPlayers()) do
                                if plr ~= LP and isAlive(plr) then
                                    local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                    if thrp and (thrp.Position - hrp.Position).Magnitude <= S.AuraRange then
                                        stab(knife, plr)
                                    end
                                end
                            end
                        end
                    end)
                end
                task.wait(0.3)
            end
        end)

        local origHandle = {}
        track(RunService.Heartbeat:Connect(function()
            local knife = LP.Character and LP.Character:FindFirstChild(KNIFE_NAME)
            local handle = knife and knife:FindFirstChild("Handle")
            if handle then
                if not origHandle[handle] then origHandle[handle] = handle.Size end
                if S.KnifeReach then
                    local s = S.ReachSize
                    handle.Size = Vector3.new(s, s, s)
                    handle.Massless = true
                else
                    handle.Size = origHandle[handle]
                end
            end
        end))

        RoleTab:Section({ Title = T("sec_safe") })
        RoleTab:Toggle({ Title = T("tg_safe"), Value = false, Callback = function(v)
            S.SafeMode = v
            local _, hrp = getChar()
            if v then
                if not hrp then return end
                if not safePlat then
                    safePlat = Instance.new("Part")
                    safePlat.Name = "KaisenXSafe"
                    safePlat.Size = Vector3.new(40, 2, 40)
                    safePlat.Anchored = true
                    safePlat.Transparency = 0.6
                    safePlat.Position = Vector3.new(0, 1500, 0)
                    safePlat.Parent = workspace
                end
                if not savedCF then savedCF = hrp.CFrame end
                hrp.CFrame = CFrame.new(0, 1504, 0)
            else
                if hrp and savedCF then hrp.CFrame = savedCF end
                savedCF = nil
            end
        end })
        RoleTab:Toggle({ Title = T("tg_autosafe"), Value = false, Callback = function(v) S.AutoSafe = v end })
        RoleTab:Slider({ Title = T("sl_safedist"), Value = { Min = 10, Max = 80, Default = 25 }, Callback = function(v) S.SafeDist = v end })

        task.spawn(function()
            while alive do
                if S.AutoSafe and Round.active and getRole(LP) ~= "murd" then
                    local mh = murdererHRP()
                    local _, hrp = getChar()
                    if mh and hrp and not savedCF and (mh.Position - hrp.Position).Magnitude < S.SafeDist then
                        S.SafeMode = true
                        if not safePlat then
                            safePlat = Instance.new("Part")
                            safePlat.Name = "KaisenXSafe"; safePlat.Size = Vector3.new(40, 2, 40)
                            safePlat.Anchored = true; safePlat.Transparency = 0.6
                            safePlat.Position = Vector3.new(0, 1500, 0); safePlat.Parent = workspace
                        end
                        if not savedCF then savedCF = hrp.CFrame end
                        hrp.CFrame = CFrame.new(0, 1504, 0)
                    end
                end
                if savedCF and not Round.active then
                    local _, hrp = getChar()
                    if hrp then hrp.CFrame = savedCF end
                    savedCF = nil
                    S.SafeMode = false
                end
                task.wait(0.4)
            end
        end)
    end

    local flyBV
    do
        PlayerTab:Toggle({ Title = T("tg_ws"), Value = false, Callback = function(v) S.WSOn = v end })
        PlayerTab:Slider({ Title = "WalkSpeed", Value = { Min = 16, Max = 100, Default = 24 }, Callback = function(v) S.WS = v end })
        PlayerTab:Toggle({ Title = T("tg_jp"), Value = false, Callback = function(v) S.JPOn = v end })
        PlayerTab:Slider({ Title = "JumpPower", Value = { Min = 50, Max = 200, Default = 60 }, Callback = function(v) S.JP = v end })
        PlayerTab:Toggle({ Title = T("tg_infjump"), Value = false, Callback = function(v) S.InfJump = v end })
        PlayerTab:Toggle({ Title = T("tg_noclip"), Value = false, Callback = function(v) S.Noclip = v; applyNoclip(v) end })
        PlayerTab:Toggle({ Title = T("tg_fly"), Value = false, Callback = function(v) S.Fly = v end })
        PlayerTab:Slider({ Title = T("sl_flyspeed"), Value = { Min = 10, Max = 120, Default = 40 }, Callback = function(v) S.FlySpeed = v end })

        track(RunService.Heartbeat:Connect(function()
            local _, hrp, hum = getChar()
            if hum then
                if S.WSOn then hum.WalkSpeed = S.WS end
                if S.JPOn then hum.UseJumpPower = true; hum.JumpPower = S.JP end
            end
            if hrp and hum and S.Fly then
                if not flyBV or flyBV.Parent ~= hrp then
                    if flyBV then flyBV:Destroy() end
                    flyBV = Instance.new("BodyVelocity")
                    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    flyBV.Parent = hrp
                end
                local cam = workspace.CurrentCamera
                flyBV.Velocity = hum.MoveDirection.Magnitude > 0
                    and cam.CFrame.LookVector * S.FlySpeed or Vector3.zero
            elseif flyBV then
                flyBV:Destroy(); flyBV = nil
            end
            if S.Noclip and LP.Character then applyNoclip(true) end
        end))
        track(UIS.JumpRequest:Connect(function()
            if S.InfJump then
                local _, _, hum = getChar()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end))

        local function playerNames()
            local t = {}
            for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then table.insert(t, p.Name) end end
            if #t == 0 then t = { T("nobody") } end
            return t
        end
        local tpTargetName = playerNames()[1]
        PlayerTab:Dropdown({ Title = T("dd_player"), Values = playerNames(), Value = tpTargetName, Callback = function(v) tpTargetName = v end })
        PlayerTab:Button({ Title = T("btn_goplayer"), Callback = function()
            local target = Players:FindFirstChild(tpTargetName or "")
            local _, hrp = getChar()
            local thrp = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if hrp and thrp then hrp.CFrame = thrp.CFrame + Vector3.new(0, 3, 0)
            else WindUI:Notify({ Title = "Kaisen X", Content = T("n_fail"), Duration = 2 }) end
        end })
        PlayerTab:Toggle({ Title = T("tg_antiafk"), Value = true, Callback = function(v) S.AntiAFK = v end })
        track(LP.Idled:Connect(function()
            if S.AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end))
        PlayerTab:Slider({ Title = T("sl_fov"), Value = { Min = 50, Max = 120, Default = 70 }, Callback = function(v)
            workspace.CurrentCamera.FieldOfView = v
        end })
        PlayerTab:Button({ Title = T("btn_fps"), Callback = function()
            task.spawn(function()
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                Lighting.GlobalShadows = false
                local n = 0
                for _, d in ipairs(workspace:GetDescendants()) do
                    if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") then d.Enabled = false
                    elseif d:IsA("BasePart") then d.CastShadow = false end
                    n += 1
                    if n % 400 == 0 then task.wait() end
                end
                WindUI:Notify({ Title = "Kaisen X", Content = T("n_fps"), Duration = 3 })
            end)
        end })
        PlayerTab:Button({ Title = T("btn_rejoin"), Callback = function() TeleportSvc:Teleport(game.PlaceId, LP) end })
        PlayerTab:Button({ Title = T("btn_hop"), Callback = function()
            task.spawn(function()
                local ok, res = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet(
                        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                end)
                if ok and res and res.data then
                    for _, s in ipairs(res.data) do
                        if s.id ~= game.JobId and s.playing < s.maxPlayers then
                            TeleportSvc:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                            return
                        end
                    end
                end
                WindUI:Notify({ Title = "Kaisen X", Content = T("n_noserver"), Duration = 3 })
            end)
        end })
    end

    local atm, bloom, cc, rays, dof
    local original, origShadows = {}, Lighting.GlobalShadows
    do
        for _, k in ipairs({ "Brightness", "ClockTime", "Ambient", "OutdoorAmbient", "ColorShift_Top",
            "ColorShift_Bottom", "ExposureCompensation", "FogColor", "FogStart", "FogEnd" }) do
            pcall(function() original[k] = Lighting[k] end)
        end
        for _, n in ipairs({ "MM_Atmosphere", "MM_Bloom", "MM_CC", "MM_Rays", "MM_DOF" }) do
            local e = Lighting:FindFirstChild(n); if e then e:Destroy() end
        end
        local function make(class, name) local o = Instance.new(class); o.Name = name; o.Parent = Lighting; return o end
        atm   = make("Atmosphere", "MM_Atmosphere")
        bloom = make("BloomEffect", "MM_Bloom")
        cc    = make("ColorCorrectionEffect", "MM_CC")
        rays  = make("SunRaysEffect", "MM_Rays")
        dof   = make("DepthOfFieldEffect", "MM_DOF")

        local OFF = {
            atm   = { Density = 0, Offset = 0, Glare = 0, Haze = 0 },
            bloom = { Intensity = 0, Size = 24, Threshold = 2 },
            cc    = { Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.fromHex("ffffff") },
            rays  = { Intensity = 0 },
            dof   = { FarIntensity = 0, NearIntensity = 0 },
        }
        local DEF = { t = 14, b = 2.5, ex = 0.1, am = "505a6a", oa = "78808c", top = "ffffff", bot = "000000",
            fog = "bec8d7", fs = 100, fe = 2000, ad = 0.3, ac = "bec8dc", adc = "78829a", hz = 1.2, gl = 0.3,
            bi = 0.4, bs = 30, bt = 1.4, con = 0.1, sat = 0.1, tint = "ffffff", ry = 0.1, df = 0.1 }
        local function S2(o)
            local d = {}
            for k, v in pairs(DEF) do d[k] = o[k] ~= nil and o[k] or v end
            return {
                L = { Brightness = d.b, ClockTime = d.t, Ambient = Color3.fromHex(d.am), OutdoorAmbient = Color3.fromHex(d.oa),
                      ColorShift_Top = Color3.fromHex(d.top), ColorShift_Bottom = Color3.fromHex(d.bot), ExposureCompensation = d.ex,
                      FogColor = Color3.fromHex(d.fog), FogStart = d.fs, FogEnd = d.fe },
                atm   = { Density = d.ad, Offset = 0.25, Color = Color3.fromHex(d.ac), Decay = Color3.fromHex(d.adc), Glare = d.gl, Haze = d.hz },
                bloom = { Intensity = d.bi, Size = d.bs, Threshold = d.bt },
                cc    = { Brightness = 0, Contrast = d.con, Saturation = d.sat, TintColor = Color3.fromHex(d.tint) },
                rays  = { Intensity = d.ry },
                dof   = { FarIntensity = d.df, FocusDistance = 60, InFocusRadius = 50, NearIntensity = 0 },
            }
        end
        local SHADERS = {
            real = S2({}), noon = S2({ t = 12, b = 3.4, ex = 0.15, sat = 0.2, ad = 0.2, hz = 0.8, ry = 0.15 }),
            gold = S2({ t = 18, b = 2.8, am = "5a3c32", oa = "966450", top = "ffaa5a", bot = "50285a", fog = "ffaa78", ac = "ffaf78", adc = "d26446", hz = 2, gl = 1, bi = 0.6, bs = 40, sat = 0.25, tint = "ffe1be", ry = 0.35 }),
            moon = S2({ t = 0, b = 0.8, ex = 0.3, am = "1e2846", oa = "283764", top = "7896ff", bot = "0a0f28", fog = "141e3c", fs = 50, fe = 1200, ac = "3c5096", adc = "141e46", hz = 1.5, gl = 0.2, bi = 0.8, bs = 40, bt = 0.9, tint = "d2e1ff", ry = 0 }),
            cine = S2({ t = 16.5, b = 2.4, ex = -0.05, am = "3c373c", oa = "5a555f", top = "ffd2a0", bot = "1e2846", fog = "a09696", fe = 1800, ac = "c8b4aa", adc = "966e5a", hz = 1.6, gl = 0.6, bi = 0.55, bs = 36, bt = 1.3, con = 0.25, sat = -0.05, tint = "ffeedc", ry = 0.2, df = 0.25 }),
            cyber= S2({ t = 22, b = 1.2, ex = 0.2, am = "3c145a", oa = "280a50", top = "ff3cc8", bot = "00c8ff", fog = "3c0a5a", fs = 30, fe = 900, ad = 0.45, ac = "b43cdc", adc = "280a64", hz = 2.5, gl = 0.5, bi = 1.2, bs = 50, bt = 0.7, con = 0.3, sat = 0.5, tint = "ffd2ff", ry = 0.1, df = 0.2 }),
            horror=S2({ t = 3, b = 1, ex = -0.1, am = "23282d", oa = "2d3737", top = "96b4aa", bot = "0a0f0f", fog = "3c4b46", fs = 0, fe = 220, ad = 0.62, ac = "5f6e69", adc = "282d32", hz = 4, gl = 0, bi = 0.3, bs = 24, bt = 1.2, con = 0.3, sat = -0.35, tint = "d2ebe1", ry = 0, df = 0.3 }),
            bright=S2({ t = 12, b = 5, ex = 0.5, am = "8c8c8c", oa = "b4b4b4", fog = "dce6f5", fs = 500, fe = 5000, ad = 0.15, ac = "c8d7f0", adc = "8296be", hz = 0.5, gl = 0.2, bi = 0.5, con = 0.1, sat = 0.3, ry = 0.2, df = 0 }),
        }
        local ORDER = { "real", "noon", "gold", "moon", "cine", "cyber", "horror", "bright" }
        local names, nameToId = {}, {}
        for _, id in ipairs(ORDER) do local label = T("sh_" .. id); table.insert(names, label); nameToId[label] = id end

        local TW = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local function tween(i, p) TweenService:Create(i, TW, p):Play() end
        local function applyShader(id)
            local p = SHADERS[id]; if not p then return end
            Lighting.GlobalShadows = true
            tween(Lighting, p.L); tween(atm, p.atm); tween(bloom, p.bloom); tween(cc, p.cc); tween(rays, p.rays); tween(dof, p.dof)
        end
        local function restoreLighting()
            tween(Lighting, original); pcall(function() Lighting.GlobalShadows = origShadows end)
            tween(atm, OFF.atm); tween(bloom, OFF.bloom); tween(cc, OFF.cc); tween(rays, OFF.rays); tween(dof, OFF.dof)
        end

        VisualTab:Dropdown({ Title = T("dd_shader"), Values = names, Value = names[1], Callback = function(v)
            S.ShaderId = nameToId[v] or "real"
            if S.ShaderOn then applyShader(S.ShaderId) end
        end })
        VisualTab:Toggle({ Title = T("tg_shader"), Value = false, Callback = function(v)
            S.ShaderOn = v
            if v then applyShader(S.ShaderId) else restoreLighting() end
        end })
        VisualTab:Button({ Title = T("btn_random"), Callback = function()
            local id = ORDER[math.random(1, #ORDER)]
            S.ShaderId = id
            S.ShaderOn = true
            applyShader(id)
        end })
        VisualTab:Slider({ Title = T("fx_time"), Value = { Min = 0, Max = 24, Default = 14 }, Callback = function(v) Lighting.ClockTime = v end })
        VisualTab:Slider({ Title = T("fx_bright"), Value = { Min = 0, Max = 6, Default = 2.5 }, Callback = function(v) Lighting.Brightness = v end })
        VisualTab:Slider({ Title = T("fx_fog"), Value = { Min = 100, Max = 6000, Default = 2000 }, Callback = function(v) Lighting.FogEnd = v end })
        VisualTab:Slider({ Title = T("fx_bloom"), Value = { Min = 0, Max = 2, Default = 0.4 }, Callback = function(v) bloom.Intensity = v end })
        VisualTab:Slider({ Title = T("fx_sat"), Value = { Min = -1, Max = 1, Default = 0.1 }, Callback = function(v) cc.Saturation = v end })
    end

    do
        SettingsTab:Button({ Title = T("btn_unload"), Callback = function() if getgenv().__KaisenXUnload then getgenv().__KaisenXUnload() end end })

        local langNames, curName, nameToCode = {}, "Español", {}
        for _, l in ipairs(LANGS) do
            table.insert(langNames, l[2]); nameToCode[l[2]] = l[1]
            if l[1] == LANG then curName = l[2] end
        end
        SettingsTab:Dropdown({ Title = T("gb_lang"), Values = langNames, Value = curName, Callback = function(v)
            local code = nameToCode[v]
            if code and code ~= LANG then
                saveLang(code)
                WindUI:Notify({ Title = "Kaisen X", Content = T("n_langchange"), Duration = 2 })
                task.spawn(function()
                    task.wait(0.3)
                    if getgenv().__KaisenXUnload then getgenv().__KaisenXUnload() end
                    task.wait(0.4)
                    Build(code)
                end)
            end
        end })

        SettingsTab:Button({ Title = T("btn_retrybg"), Callback = function()
            local ok = tryAttachBg()
            WindUI:Notify({ Title = "Kaisen X", Content = ok and T("n_bgok") or T("n_bgfail"), Duration = 3 })
        end })

        SettingsTab:Paragraph({ Title = DISCORD_URL })
        SettingsTab:Button({ Title = T("btn_discord"), Callback = function()
            local msg = "¡Únete al Discord de Kaisen X! " .. DISCORD_URL .. " — novedades del script, soporte y sorteos."
            if setclipboard then pcall(setclipboard, msg); WindUI:Notify({ Title = "Kaisen X", Content = T("n_disccopy"), Duration = 3 })
            else WindUI:Notify({ Title = "Kaisen X", Content = T("n_discnosup"), Duration = 3 }) end
        end })
    end

    WindUI:Notify({ Title = "Kaisen X", Content = T("n_loaded"), Duration = 4 })
end

local okBuild, buildErr = pcall(Build, loadLang())
if not okBuild then
    warn("Kaisen X: error al construir el menú: " .. tostring(buildErr))
end
