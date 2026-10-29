--[[
  MM2 HUB v5.1 - LinoriaLib (mstudio45)
  Pestañas: Ronda · Evento · ESP · Rol · Jugador · Visual · Ajustes
  Idiomas: Español · English · Português · Français · Русский
  (el selector de idioma está en la pestaña Ronda)
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players           = game:GetService("Players")
local Lighting          = game:GetService("Lighting")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local UIS               = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local HttpService       = game:GetService("HttpService")
local TeleportSvc       = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP                = Players.LocalPlayer
local H                 = Color3.fromHex

-- =============================================================================
-- IDIOMAS
-- =============================================================================
local LANGS = { { "es", "Español" }, { "en", "English" }, { "pt", "Português" }, { "fr", "Français" }, { "ru", "Русский" } }
local LIDX  = { es = 1, en = 2, pt = 3, fr = 4, ru = 5 }

-- orden: es, en, pt, fr, ru
local TR = {
    tab_round   = { "Ronda", "Round", "Rodada", "Manche", "Раунд" },
    tab_event   = { "Evento", "Event", "Evento", "Événement", "Событие" },
    tab_esp     = { "ESP", "ESP", "ESP", "ESP", "ESP" },
    tab_role    = { "Rol", "Role", "Função", "Rôle", "Роль" },
    tab_player  = { "Jugador", "Player", "Jogador", "Joueur", "Игрок" },
    tab_visual  = { "Visual", "Visual", "Visual", "Visuel", "Графика" },
    tab_settings= { "Ajustes", "Settings", "Configurações", "Paramètres", "Настройки" },

    gb_state    = { "Estado de la partida", "Match status", "Estado da partida", "État de la partie", "Состояние игры" },
    gb_hud      = { "Avisos y HUD", "Alerts & HUD", "Avisos e HUD", "Alertes et HUD", "Уведомления и HUD" },
    gb_lang     = { "Idioma", "Language", "Idioma", "Langue", "Язык" },
    l_round     = { "Ronda", "Round", "Rodada", "Manche", "Раунд" },
    st_wait     = { "esperando...", "waiting...", "aguardando...", "en attente...", "ожидание..." },
    st_live     = { "en curso", "in progress", "em andamento", "en cours", "идёт" },
    st_end      = { "terminada", "ended", "encerrada", "terminée", "окончен" },
    l_time      = { "Tiempo", "Time", "Tempo", "Temps", "Время" },
    t_remaining = { "Restante", "Remaining", "Restante", "Restant", "Осталось" },
    t_elapsed   = { "Transcurrido", "Elapsed", "Decorrido", "Écoulé", "Прошло" },
    l_alive     = { "Vivos", "Alive", "Vivos", "Vivants", "Живы" },
    l_myrole    = { "Mi rol", "My role", "Minha função", "Mon rôle", "Моя роль" },
    l_murd      = { "Asesino", "Murderer", "Assassino", "Meurtrier", "Убийца" },
    l_sher      = { "Sheriff", "Sheriff", "Xerife", "Shérif", "Шериф" },
    l_inno      = { "Inocente", "Innocent", "Inocente", "Innocent", "Невиновный" },
    dead        = { "muerto", "dead", "morto", "mort", "мёртв" },
    waiting_hud = { "Esperando ronda", "Waiting for round", "Aguardando rodada", "En attente de manche", "Ожидание раунда" },
    tg_hud      = { "Contador en pantalla", "On-screen timer", "Contador na tela", "Compteur à l'écran", "Таймер на экране" },
    tg_nround   = { "Avisar inicio y fin de ronda", "Notify round start & end", "Avisar início e fim da rodada", "Prévenir début et fin de manche", "Уведомлять о начале и конце раунда" },
    tg_ntimer   = { "Avisar a los 30s y 10s", "Alert at 30s and 10s", "Avisar aos 30s e 10s", "Alerter à 30s et 10s", "Уведомлять за 30с и 10с" },
    tg_ndeath   = { "Avisar si muere asesino o sheriff", "Alert if murderer or sheriff dies", "Avisar se assassino ou xerife morrer", "Alerter si meurtrier ou shérif meurt", "Уведомлять о смерти убийцы или шерифа" },
    timer_info  = { "El contador usa el reloj del juego si lo encuentra; si no, cuenta desde que empieza la ronda.", "The timer uses the game's clock if found; otherwise it counts from round start.", "O contador usa o relógio do jogo se achar; senão conta desde o início da rodada.", "Le compteur utilise l'horloge du jeu s'il la trouve ; sinon il compte depuis le début de la manche.", "Таймер использует часы игры, если найдёт; иначе считает с начала раунда." },
    n_round_start = { "Ronda iniciada", "Round started", "Rodada iniciada", "Manche commencée", "Раунд начался" },
    n_round_end = { "Ronda terminada", "Round ended", "Rodada encerrada", "Manche terminée", "Раунд закончен" },
    n_30        = { "Quedan 30 segundos", "30 seconds left", "Faltam 30 segundos", "Il reste 30 secondes", "Осталось 30 секунд" },
    n_10        = { "Quedan 10 segundos", "10 seconds left", "Faltam 10 segundos", "Il reste 10 secondes", "Осталось 10 секунд" },
    n_died      = { "ha muerto", "has died", "morreu", "est mort", "погиб" },
    n_langchange= { "Cambiando idioma...", "Changing language...", "Mudando idioma...", "Changement de langue...", "Смена языка..." },

    gb_farm     = { "Auto farm Candy", "Candy auto farm", "Auto farm de Candy", "Auto farm Candy", "Автофарм конфет" },
    gb_opt      = { "Opciones", "Options", "Opções", "Options", "Опции" },
    gb_info     = { "Info del evento", "Event info", "Info do evento", "Infos de l'événement", "Инфо о событии" },
    tg_farm     = { "Auto-recoger Candy", "Auto-collect Candy", "Auto-coletar Candy", "Auto-ramasser Candy", "Автосбор конфет" },
    sl_speed    = { "Velocidad", "Speed", "Velocidade", "Vitesse", "Скорость" },
    tg_avoid    = { "Evitar al asesino", "Avoid the murderer", "Evitar o assassino", "Éviter le meurtrier", "Избегать убийцу" },
    sl_avoid    = { "Distancia segura", "Safe distance", "Distância segura", "Distance de sécurité", "Безопасная дистанция" },
    l_count     = { "Recorridos (aprox.)", "Visited (approx.)", "Percorridos (aprox.)", "Parcourus (approx.)", "Посещено (прибл.)" },
    l_left      = { "Candy en mapa", "Candy on map", "Candy no mapa", "Candy sur la carte", "Конфет на карте" },
    l_fstate    = { "Farm", "Farm", "Farm", "Farm", "Фарм" },
    fs_off      = { "apagado", "off", "desligado", "désactivé", "выкл" },
    fs_wait     = { "esperando ronda", "waiting for round", "aguardando rodada", "attente de manche", "ждёт раунд" },
    fs_run      = { "farmeando", "farming", "farmando", "en cours", "фармит" },
    tg_wide     = { "Búsqueda ampliada", "Extended search", "Busca ampliada", "Recherche étendue", "Расширенный поиск" },
    tip_wide    = { "Busca también objetos con 'candy' en el nombre dentro del mapa", "Also searches map objects with 'candy' in the name", "Busca também objetos com 'candy' no nome dentro do mapa", "Cherche aussi les objets contenant 'candy' dans la carte", "Ищет также объекты с 'candy' в названии на карте" },
    tg_autoreset= { "Reiniciar al acabar candies", "Reset when candies run out", "Reiniciar ao acabar candies", "Réinitialiser sans candies", "Сброс, когда конфеты кончились" },
    tip_autoreset={ "Mata tu personaje cuando no queden candies, para pasar a la siguiente ronda", "Kills your character when no candies are left, to skip to the next round", "Mata seu personagem quando não houver candies, para ir à próxima rodada", "Tue ton personnage quand il n'y a plus de candies, pour passer à la manche suivante", "Убивает персонажа, когда конфет нет, чтобы перейти к следующему раунду" },
    tg_candyesp = { "Marcar candies (ESP)", "Mark candies (ESP)", "Marcar candies (ESP)", "Marquer les candies (ESP)", "Метки конфет (ESP)" },
    tg_nocfarm  = { "Atravesar paredes al farmear", "Walk through walls while farming", "Atravessar paredes ao farmar", "Traverser les murs en farmant", "Проходить сквозь стены при фарме" },
    btn_resetlist={ "Reiniciar lista", "Reset list", "Reiniciar lista", "Réinitialiser la liste", "Сбросить список" },
    n_listreset = { "Lista reiniciada", "List reset", "Lista reiniciada", "Liste réinitialisée", "Список сброшен" },
    info1       = { "Evento hasta el 16 nov 2026.", "Event until Nov 16, 2026.", "Evento até 16 nov 2026.", "Événement jusqu'au 16 nov. 2026.", "Событие до 16 ноября 2026." },
    info2       = { "No caen monedas, solo Candy.", "No coins drop, only Candy.", "Não caem moedas, só Candy.", "Pas de pièces, seulement des Candy.", "Монеты не падают, только конфеты." },
    info3       = { "Misiones diarias: 60 / 120 / 200 candies.", "Daily quests: 60 / 120 / 200 candies.", "Missões diárias: 60 / 120 / 200 candies.", "Quêtes quotidiennes : 60 / 120 / 200 candies.", "Ежедневные задания: 60 / 120 / 200 конфет." },
    info4       = { "El Candy expira al terminar el evento: gástalo antes.", "Candy expires when the event ends: spend it first.", "O Candy expira quando o evento acaba: gaste antes.", "Les Candy expirent à la fin de l'événement : dépense-les avant.", "Конфеты сгорают после события: потрать их заранее." },

    gb_espp     = { "ESP jugadores", "Player ESP", "ESP de jogadores", "ESP joueurs", "ESP игроков" },
    gb_gun      = { "Pistola", "Gun", "Arma", "Arme", "Пистолет" },
    tg_esp      = { "Activar ESP", "Enable ESP", "Ativar ESP", "Activer ESP", "Включить ESP" },
    tg_espnames = { "Nombre y rol", "Name & role", "Nome e função", "Nom et rôle", "Имя и роль" },
    tg_espgun   = { "Resaltar pistola caída", "Highlight dropped gun", "Destacar arma caída", "Surligner l'arme au sol", "Подсвечивать упавший пистолет" },
    btn_grabgun = { "Agarrar pistola caída", "Grab dropped gun", "Pegar arma caída", "Ramasser l'arme", "Подобрать пистолет" },
    n_gunok     = { "Pistola recogida", "Gun grabbed", "Arma coletada", "Arme ramassée", "Пистолет подобран" },
    n_nogun     = { "No hay pistola en el suelo", "No gun on the ground", "Sem arma no chão", "Pas d'arme au sol", "Пистолета на земле нет" },
    tg_autogun  = { "Auto-agarrar pistola", "Auto-grab gun", "Auto-pegar arma", "Auto-ramasser l'arme", "Автоподбор пистолета" },
    tg_rolenotify={ "Avisar de mi rol", "Notify my role", "Avisar minha função", "Prévenir de mon rôle", "Уведомлять о моей роли" },
    n_yourrole  = { "Tu rol:", "Your role:", "Sua função:", "Ton rôle :", "Твоя роль:" },

    gb_sheriff  = { "Sheriff", "Sheriff", "Xerife", "Shérif", "Шериф" },
    gb_safe     = { "Inocente / seguridad", "Innocent / safety", "Inocente / segurança", "Innocent / sécurité", "Невиновный / безопасность" },
    btn_shoot   = { "Disparar al asesino", "Shoot the murderer", "Atirar no assassino", "Tirer sur le meurtrier", "Выстрелить в убийцу" },
    tg_autoshoot= { "Auto-disparar al asesino", "Auto-shoot murderer", "Auto-atirar no assassino", "Auto-tir sur le meurtrier", "Автовыстрел в убийцу" },
    sl_range    = { "Alcance auto", "Auto range", "Alcance auto", "Portée auto", "Дальность авто" },
    sl_cooldown = { "Espera entre disparos", "Delay between shots", "Intervalo entre tiros", "Délai entre les tirs", "Пауза между выстрелами" },
    tg_predict  = { "Predecir movimiento", "Predict movement", "Prever movimento", "Prédire le mouvement", "Предсказывать движение" },
    tg_los      = { "Solo con línea de visión", "Only with line of sight", "Só com linha de visão", "Seulement en ligne de vue", "Только при прямой видимости" },
    btn_equipgun= { "Equipar pistola", "Equip gun", "Equipar arma", "Équiper l'arme", "Взять пистолет" },
    err_notsher = { "No eres sheriff", "You are not the sheriff", "Você não é o xerife", "Tu n'es pas le shérif", "Ты не шериф" },
    err_nomurd  = { "No hay asesino vivo", "No living murderer", "Nenhum assassino vivo", "Aucun meurtrier en vie", "Убийца не найден" },
    err_nogun   = { "No tienes la pistola", "You don't have the gun", "Você não tem a arma", "Tu n'as pas l'arme", "У тебя нет пистолета" },
    err_noremote= { "La pistola no tiene el remote Shoot", "The gun has no Shoot remote", "A arma não tem o remote Shoot", "L'arme n'a pas le remote Shoot", "У пистолета нет remote Shoot" },
    err_shoot   = { "No se pudo disparar", "Could not shoot", "Não foi possível atirar", "Tir impossible", "Не удалось выстрелить" },
    tg_aura     = { "Aura de cuchillo", "Knife aura", "Aura da faca", "Aura du couteau", "Аура ножа" },
    sl_aurarange= { "Alcance del aura", "Aura range", "Alcance da aura", "Portée de l'aura", "Радиус ауры" },
    tg_reach    = { "Reach del cuchillo", "Knife reach", "Alcance da faca", "Allonge du couteau", "Увеличенный нож" },
    sl_reachsize= { "Tamaño del reach", "Reach size", "Tamanho do alcance", "Taille de l'allonge", "Размер" },
    btn_killall = { "Matar a todos", "Kill all", "Matar todos", "Tuer tout le monde", "Убить всех" },
    n_notmurd   = { "No eres el asesino", "You are not the murderer", "Você não é o assassino", "Tu n'es pas le meurtrier", "Ты не убийца" },
    n_killdone  = { "Ronda de ataques terminada", "Attack run finished", "Rodada de ataques concluída", "Série d'attaques terminée", "Атака завершена" },
    btn_equipknife={ "Equipar cuchillo", "Equip knife", "Equipar faca", "Équiper le couteau", "Взять нож" },
    tg_safe     = { "Modo seguro (cielo)", "Safe mode (sky)", "Modo seguro (céu)", "Mode sûr (ciel)", "Безопасный режим (небо)" },
    tip_safe    = { "Te lleva a una plataforma en el cielo; al desactivarlo vuelves", "Takes you to a sky platform; turning it off brings you back", "Leva você a uma plataforma no céu; ao desativar você volta", "Te téléporte sur une plateforme dans le ciel ; tu reviens en le désactivant", "Переносит на платформу в небе; при выключении возвращает" },
    tg_autosafe = { "Auto-cielo si el asesino está cerca", "Auto-sky if murderer is near", "Auto-céu se o assassino estiver perto", "Auto-ciel si le meurtrier est proche", "Авто-небо, если убийца рядом" },
    sl_danger   = { "Distancia de peligro", "Danger distance", "Distância de perigo", "Distance de danger", "Опасная дистанция" },

    gb_move     = { "Movimiento", "Movement", "Movimento", "Mouvement", "Движение" },
    gb_extras   = { "Extras", "Extras", "Extras", "Extras", "Дополнительно" },
    tg_jump     = { "Salto", "Jump", "Pulo", "Saut", "Прыжок" },
    tg_infjump  = { "Salto infinito", "Infinite jump", "Pulo infinito", "Saut infini", "Бесконечный прыжок" },
    tg_fly      = { "Volar", "Fly", "Voar", "Voler", "Полёт" },
    sl_flyspeed = { "Velocidad de vuelo", "Fly speed", "Velocidade de voo", "Vitesse de vol", "Скорость полёта" },
    btn_goplayer= { "Ir al jugador", "Go to player", "Ir ao jogador", "Aller au joueur", "К игроку" },
    btn_refresh = { "Actualizar lista", "Refresh list", "Atualizar lista", "Actualiser la liste", "Обновить список" },
    tg_spectate = { "Espectar jugador", "Spectate player", "Espectar jogador", "Observer le joueur", "Наблюдать за игроком" },
    sl_fov      = { "Campo de visión", "Field of view", "Campo de visão", "Champ de vision", "Поле зрения" },
    n_fps       = { "FPS boost aplicado", "FPS boost applied", "FPS boost aplicado", "Boost FPS appliqué", "Буст FPS применён" },
    btn_rejoin  = { "Reentrar al servidor", "Rejoin server", "Reentrar no servidor", "Rejoindre le serveur", "Перезайти на сервер" },
    btn_hop     = { "Cambiar de servidor", "Server hop", "Trocar de servidor", "Changer de serveur", "Сменить сервер" },
    n_noserver  = { "No encontré otro servidor", "No other server found", "Não achei outro servidor", "Aucun autre serveur trouvé", "Другой сервер не найден" },
    n_fail      = { "No se pudo", "Failed", "Não foi possível", "Échec", "Не удалось" },
    nobody      = { "(nadie)", "(nobody)", "(ninguém)", "(personne)", "(никого)" },

    gb_shaders  = { "Shaders", "Shaders", "Shaders", "Shaders", "Шейдеры" },
    gb_live     = { "Ajustes en vivo", "Live adjustments", "Ajustes ao vivo", "Réglages en direct", "Настройки онлайн" },
    dd_shader   = { "Shader", "Shader", "Shader", "Shader", "Шейдер" },
    tg_shader   = { "Activar shader", "Enable shader", "Ativar shader", "Activer le shader", "Включить шейдер" },
    btn_random  = { "Shader aleatorio", "Random shader", "Shader aleatório", "Shader aléatoire", "Случайный шейдер" },
    fx_time     = { "Hora", "Time of day", "Hora", "Heure", "Время суток" },
    fx_bright   = { "Brillo", "Brightness", "Brilho", "Luminosité", "Яркость" },
    fx_fog      = { "Niebla", "Fog", "Névoa", "Brouillard", "Туман" },
    fx_sat      = { "Saturación", "Saturation", "Saturação", "Saturation", "Насыщенность" },
    fx_con      = { "Contraste", "Contrast", "Contraste", "Contraste", "Контраст" },

    sh_real     = { "Realista", "Realistic", "Realista", "Réaliste", "Реалистичный" },
    sh_noon     = { "Mediodía claro", "Clear noon", "Meio-dia claro", "Plein midi", "Ясный полдень" },
    sh_gold     = { "Atardecer dorado", "Golden sunset", "Pôr do sol dourado", "Coucher de soleil doré", "Золотой закат" },
    sh_blue     = { "Hora azul", "Blue hour", "Hora azul", "Heure bleue", "Синий час" },
    sh_moon     = { "Noche lunar", "Moonlit night", "Noite lunar", "Nuit lunaire", "Лунная ночь" },
    sh_hallo    = { "Halloween naranja", "Orange Halloween", "Halloween laranja", "Halloween orange", "Оранжевый Хэллоуин" },
    sh_cine     = { "Cinematográfico", "Cinematic", "Cinematográfico", "Cinématographique", "Кинематографичный" },
    sh_teal     = { "Teal & Orange", "Teal & Orange", "Teal & Orange", "Teal & Orange", "Teal & Orange" },
    sh_cyber    = { "Cyberpunk neón", "Neon cyberpunk", "Cyberpunk neon", "Cyberpunk néon", "Неоновый киберпанк" },
    sh_synth    = { "Synthwave", "Synthwave", "Synthwave", "Synthwave", "Synthwave" },
    sh_fantasy  = { "Fantasía mágica", "Magic fantasy", "Fantasia mágica", "Fantaisie magique", "Волшебное фэнтези" },
    sh_horror   = { "Terror", "Horror", "Terror", "Horreur", "Ужас" },
    sh_noir     = { "Noir", "Noir", "Noir", "Noir", "Нуар" },
    sh_bright   = { "Ultra brillante", "Ultra bright", "Ultra brilhante", "Ultra lumineux", "Ультраяркий" },

    gb_menu     = { "Menú", "Menu", "Menu", "Menu", "Меню" },
    btn_unload  = { "Descargar script", "Unload script", "Descarregar script", "Décharger le script", "Выгрузить скрипт" },
    l_menukey   = { "Tecla del menú (PC)", "Menu key (PC)", "Tecla do menu (PC)", "Touche du menu (PC)", "Клавиша меню (ПК)" },
    n_loaded    = { "MM2 Hub v5.1 cargado", "MM2 Hub v5.1 loaded", "MM2 Hub v5.1 carregado", "MM2 Hub v5.1 chargé", "MM2 Hub v5.1 загружен" },
}

local LANG_FILE = "MM2Hub/lang.txt"
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
        if makefolder then pcall(makefolder, "MM2Hub") end
        writefile(LANG_FILE, code)
    end)
end

-- =============================================================================
-- CONSTRUCCIÓN DEL HUB (se vuelve a ejecutar al cambiar de idioma)
-- =============================================================================
local function Build(LANG, snap)
    local function T(k)
        local e = TR[k]
        if not e then return k end
        return e[LIDX[LANG]] or e[2]
    end

    -- Librería ----------------------------------------------------------------
    local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
    local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    local Toggles = getgenv().Toggles or Library.Toggles
    local Options = getgenv().Options or Library.Options

    getgenv().__MM2HubUnload = function() pcall(function() Library:Unload() end) end

    -- Utilidades --------------------------------------------------------------
    local alive = true
    local conns = {}
    local function track(c) table.insert(conns, c); return c end

    local function getChar()
        local ch = LP.Character
        return ch, ch and ch:FindFirstChild("HumanoidRootPart"), ch and ch:FindFirstChildOfClass("Humanoid")
    end

    local guiParent = (pcall(function() return gethui() end) and gethui()) or game:GetService("CoreGui")
    for _, n in ipairs({ "MM2HubESP", "MM2HubHUD" }) do
        local old = guiParent:FindFirstChild(n); if old then old:Destroy() end
    end
    local espFolder = Instance.new("Folder")
    espFolder.Name = "MM2HubESP"
    espFolder.Parent = guiParent

    local function fmtTime(s)
        s = math.max(0, math.floor(s))
        return string.format("%02d:%02d", s // 60, s % 60)
    end

    local function toPart(o)
        if o:IsA("BasePart") then return o end
        if o:IsA("Model") then return o:FindFirstChildWhichIsA("BasePart", true) end
    end

    local function getMap()
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChild("CoinContainer") then return m end
        end
    end

    -- Roles: "murd" / "sheriff" / "inno" --------------------------------------
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
                -- en hilo aparte: si el servidor no responde, no bloquea nada
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
        if hasTool(plr, "Knife") then return "murd" end
        if hasTool(plr, "Gun") then return "sheriff" end
        return roleCache[plr.Name] or "inno"
    end

    local function roleName(r)
        return r == "murd" and T("l_murd") or r == "sheriff" and T("l_sher") or T("l_inno")
    end

    local function isAlive(plr)
        local ch = plr.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        return hum ~= nil and hum.Health > 0
    end

    local function findByRole(role)
        for _, plr in ipairs(Players:GetPlayers()) do
            if getRole(plr) == role then return plr end
        end
    end

    local function strictMurd()
        for _, plr in ipairs(Players:GetPlayers()) do
            if hasTool(plr, "Knife") then return plr end
        end
    end

    local function murdererHRP()
        local m = findByRole("murd")
        if m and m ~= LP and m.Character then return m.Character:FindFirstChild("HumanoidRootPart") end
    end

    -- Estado de ronda compartido ------------------------------------------------
    local Round = { active = false, ended = false, hadMurd = false, id = 0, startedAt = 0 }

    -- Ventana -------------------------------------------------------------------
    local Window = Library:CreateWindow({
        Title = "MM2 Hub v5.1",
        Center = true,
        AutoShow = true,
        TabPadding = 4,
        MenuFadeTime = 0.15,
        Size = UDim2.fromOffset(470, 320),
        MobileButtonsSide = "Left",
        ShowCustomCursor = false,
    })
    local Tabs = {
        Round    = Window:AddTab(T("tab_round")),
        Event    = Window:AddTab(T("tab_event")),
        ESP      = Window:AddTab(T("tab_esp")),
        Role     = Window:AddTab(T("tab_role")),
        Player   = Window:AddTab(T("tab_player")),
        Visual   = Window:AddTab(T("tab_visual")),
        Settings = Window:AddTab(T("tab_settings")),
    }

    local hud, hudTop, hudBot

    -- =========================================================================
    -- RONDA
    -- =========================================================================
    do
        local RdBox = Tabs.Round:AddLeftGroupbox(T("gb_state"))
        local RdOpt = Tabs.Round:AddRightGroupbox(T("gb_hud"))

        local lblState = RdBox:AddLabel(T("l_round") .. ": " .. T("st_wait"))
        local lblTimer = RdBox:AddLabel(T("l_time") .. ": --:--")
        local lblAlive = RdBox:AddLabel(T("l_alive") .. ": 0")
        local lblMe    = RdBox:AddLabel(T("l_myrole") .. ": " .. T("l_inno"))
        local lblMurd  = RdBox:AddLabel(T("l_murd") .. ": ?")
        local lblSher  = RdBox:AddLabel(T("l_sher") .. ": ?")

        -- Idioma
        local langNames, curName = {}, "Español"
        for _, l in ipairs(LANGS) do
            table.insert(langNames, l[2])
            if l[1] == LANG then curName = l[2] end
        end
        RdOpt:AddDropdown("LangPick", { Values = langNames, Default = curName, Multi = false, Text = T("gb_lang") })

        RdOpt:AddToggle("HUDOn", { Text = T("tg_hud"), Default = true })
        RdOpt:AddToggle("NotifyRound", { Text = T("tg_nround"), Default = true })
        RdOpt:AddToggle("NotifyTimer", { Text = T("tg_ntimer"), Default = true })
        RdOpt:AddToggle("NotifyDeaths", { Text = T("tg_ndeath"), Default = true })
        RdOpt:AddLabel(T("timer_info"), true)

        -- HUD en pantalla
        hud = Instance.new("ScreenGui")
        hud.Name = "MM2HubHUD"
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
        hudTop = hudLabel(2, 17, true)
        hudBot = hudLabel(23, 12, false)

        -- Reloj del juego (si existe)
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

        -- Eventos del juego que indican el fin de ronda (si existen)
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
                if not (gameTimer and gameTimer.Parent) and tick % 6 == 1 then
                    gameTimer = findGameTimer()
                end
                local gs = gameTimer and gameTimer.Parent and readTimer(gameTimer) or nil
                local remaining
                if gs then
                    if lastSec then
                        if gs < lastSec then direction = "down" elseif gs > lastSec then direction = "up" end
                    end
                    lastSec = gs
                    if direction == "down" then remaining = gs end
                end

                -- ¿ronda activa? (mapa + asesino con cuchillo vivo, sin marca de fin)
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
                    Round.ended = true
                    newActive = false
                end

                if newActive and not prevActive then
                    Round.id += 1
                    Round.startedAt = os.clock()
                    warned30, warned10 = false, false
                    prevAlive = {}
                    if Toggles.NotifyRound.Value then Library:Notify(T("n_round_start"), 3) end
                elseif not newActive and prevActive then
                    if Toggles.NotifyRound.Value then Library:Notify(T("n_round_end"), 3) end
                end
                prevActive = newActive
                Round.active = newActive

                -- texto de tiempo
                local timeText = "--:--"
                if newActive then
                    if gs and direction == "down" then timeText = T("t_remaining") .. " " .. fmtTime(gs)
                    elseif gs and direction == "up" then timeText = T("t_elapsed") .. " " .. fmtTime(gs)
                    else timeText = T("t_elapsed") .. " " .. fmtTime(os.clock() - Round.startedAt) end
                end

                if remaining and newActive and Toggles.NotifyTimer.Value then
                    if remaining <= 30 and not warned30 then warned30 = true; Library:Notify(T("n_30"), 3) end
                    if remaining <= 10 and not warned10 then warned10 = true; Library:Notify(T("n_10"), 3) end
                end

                local nAlive = 0
                for _, plr in ipairs(Players:GetPlayers()) do if isAlive(plr) then nAlive += 1 end end
                local murd, sher = findByRole("murd"), findByRole("sheriff")
                local myRole = getRole(LP)

                if newActive and Toggles.NotifyDeaths.Value then
                    for tag, plr in pairs({ murd = murd, sheriff = sher }) do
                        if plr then
                            local a = isAlive(plr)
                            if prevAlive[tag] == true and not a then
                                Library:Notify(roleName(tag) .. " (" .. plr.Name .. ") " .. T("n_died"), 4)
                            end
                            prevAlive[tag] = a
                        end
                    end
                end

                local stText = newActive and T("st_live") or (map and Round.ended and T("st_end") or T("st_wait"))
                lblState:SetText(T("l_round") .. ": " .. stText)
                lblTimer:SetText(T("l_time") .. ": " .. timeText)
                lblAlive:SetText(T("l_alive") .. ": " .. nAlive)
                lblMe:SetText(T("l_myrole") .. ": " .. roleName(myRole))
                lblMurd:SetText(T("l_murd") .. ": " .. (murd and (murd.Name .. (isAlive(murd) and "" or " (" .. T("dead") .. ")")) or "?"))
                lblSher:SetText(T("l_sher") .. ": " .. (sher and (sher.Name .. (isAlive(sher) and "" or " (" .. T("dead") .. ")")) or "?"))

                hud.Enabled = Toggles.HUDOn.Value
                hudTop.Text = newActive and timeText or T("waiting_hud")
                hudBot.Text = T("l_myrole") .. ": " .. roleName(myRole) .. "  ·  " .. T("l_alive") .. ": " .. nAlive

                task.wait(0.4)
            end
        end)
    end

    -- =========================================================================
    -- EVENTO: Auto farm de Candy (solo durante la ronda)
    -- =========================================================================
    do
        local EvBox  = Tabs.Event:AddLeftGroupbox(T("gb_farm"))
        local EvOpt  = Tabs.Event:AddRightGroupbox(T("gb_opt"))
        local EvInfo = Tabs.Event:AddRightGroupbox(T("gb_info"))

        EvBox:AddToggle("AutoFarm", { Text = T("tg_farm"), Default = false })
        EvBox:AddSlider("FarmSpeed", { Text = T("sl_speed"), Default = 28, Min = 10, Max = 70, Rounding = 0, Suffix = " st/s" })
        EvBox:AddToggle("AvoidMurd", { Text = T("tg_avoid"), Default = true })
        EvBox:AddSlider("AvoidDist", { Text = T("sl_avoid"), Default = 30, Min = 10, Max = 80, Rounding = 0, Suffix = " st" })
        local lblFarm  = EvBox:AddLabel(T("l_fstate") .. ": " .. T("fs_off"))
        local lblCount = EvBox:AddLabel(T("l_count") .. ": 0")
        local lblLeft  = EvBox:AddLabel(T("l_left") .. ": 0")

        EvOpt:AddToggle("WideSearch", { Text = T("tg_wide"), Default = true, Tooltip = T("tip_wide") })
        EvOpt:AddToggle("AutoReset", { Text = T("tg_autoreset"), Default = false, Tooltip = T("tip_autoreset") })
        EvOpt:AddToggle("CandyESP", { Text = T("tg_candyesp"), Default = false })
        EvOpt:AddToggle("NoClipFarm", { Text = T("tg_nocfarm"), Default = true })

        EvInfo:AddLabel(T("info1"), true)
        EvInfo:AddLabel(T("info2"), true)
        EvInfo:AddLabel(T("info3"), true)
        EvInfo:AddLabel(T("info4"), true)

        local Farm = { visited = setmetatable({}, { __mode = "k" }), skip = setmetatable({}, { __mode = "k" }),
                       count = 0, resetDone = false, seenRound = -1, tween = nil }

        local function resetFarm()
            Farm.visited = setmetatable({}, { __mode = "k" })
            Farm.skip = setmetatable({}, { __mode = "k" })
            Farm.count = 0
            Farm.resetDone = false
            lblCount:SetText(T("l_count") .. ": 0")
        end

        local function getCandies()
            local list, seen = {}, {}
            local map = getMap()
            if not map then return list, nil end
            for _, c in ipairs(map.CoinContainer:GetChildren()) do
                local p = toPart(c)
                if p and not seen[p] then seen[p] = true; table.insert(list, p) end
            end
            if Toggles.WideSearch and Toggles.WideSearch.Value then
                for _, d in ipairs(map:GetDescendants()) do
                    if d:IsA("BasePart") and not seen[d] and d.Name:lower():find("candy") then
                        seen[d] = true; table.insert(list, d)
                    end
                end
            end
            return list, map
        end

        EvOpt:AddButton({ Text = T("btn_resetlist"), Func = function()
            resetFarm()
            Library:Notify(T("n_listreset"), 2)
        end })

        task.spawn(function()
            while alive do
                -- nueva ronda => lista limpia
                if Farm.seenRound ~= Round.id then
                    Farm.seenRound = Round.id
                    resetFarm()
                end

                local list = Round.active and getCandies() or {}
                local pending = 0
                for _, p in ipairs(list) do if p.Parent and not Farm.visited[p] then pending += 1 end end
                lblLeft:SetText(T("l_left") .. ": " .. pending)

                local farmOn = Toggles.AutoFarm.Value
                lblFarm:SetText(T("l_fstate") .. ": " ..
                    (not farmOn and T("fs_off") or (Round.active and T("fs_run") or T("fs_wait"))))

                if farmOn and Round.active then
                    local _, hrp, hum = getChar()
                    if hrp and hum and hum.Health > 0 then
                        local mhrp = (Toggles.AvoidMurd.Value and getRole(LP) ~= "murd") and murdererHRP() or nil
                        local best, bestD
                        for _, p in ipairs(list) do
                            if p.Parent and not Farm.visited[p] and (not Farm.skip[p] or Farm.skip[p] < os.clock()) then
                                if mhrp and (p.Position - mhrp.Position).Magnitude < Options.AvoidDist.Value then
                                    Farm.skip[p] = os.clock() + 3
                                else
                                    local d = (p.Position - hrp.Position).Magnitude
                                    if not bestD or d < bestD then best, bestD = p, d end
                                end
                            end
                        end

                        if best then
                            local t = math.max(bestD / Options.FarmSpeed.Value, 0.05)
                            local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear),
                                { CFrame = CFrame.new(best.Position + Vector3.new(0, 1.5, 0)) })
                            local done = false
                            tw.Completed:Connect(function() done = true end)
                            Farm.tween = tw
                            tw:Play()
                            -- se corta al instante si termina la ronda o apagas el farm
                            while not done and alive and Round.active and Toggles.AutoFarm.Value do
                                task.wait(0.05)
                            end
                            if not done then tw:Cancel() end
                            Farm.tween = nil

                            if done and Round.active and Toggles.AutoFarm.Value then
                                if firetouchinterest and best.Parent then
                                    pcall(function()
                                        firetouchinterest(hrp, best, 0)
                                        firetouchinterest(hrp, best, 1)
                                    end)
                                end
                                task.wait(0.1)
                                Farm.visited[best] = true
                                Farm.count += 1
                                lblCount:SetText(T("l_count") .. ": " .. Farm.count)
                            end
                        elseif pending == 0 and Toggles.AutoReset.Value and not Farm.resetDone then
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
                    -- ronda terminada o farm apagado: asegurar que no queda ningún movimiento
                    if Farm.tween then pcall(function() Farm.tween:Cancel() end); Farm.tween = nil end
                    task.wait(0.5)
                end
                task.wait()
            end
        end)

        -- ESP de candies
        local candyTags = {}
        task.spawn(function()
            while alive do
                if Toggles.CandyESP.Value and Round.active then
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

        -- Noclip (farm activo o manual)
        track(RunService.Stepped:Connect(function()
            local farmNoclip = Toggles.AutoFarm.Value and Round.active and Toggles.NoClipFarm.Value
            local manual = Toggles.Noclip and Toggles.Noclip.Value
            if farmNoclip or manual then
                local ch = LP.Character
                if ch then
                    for _, p in ipairs(ch:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end
        end))
    end

    -- =========================================================================
    -- ESP
    -- =========================================================================
    local grabGun
    do
        local ESPBox = Tabs.ESP:AddLeftGroupbox(T("gb_espp"))
        local GunBox = Tabs.ESP:AddRightGroupbox(T("gb_gun"))

        ESPBox:AddToggle("ESPOn",    { Text = T("tg_esp"), Default = false })
        ESPBox:AddToggle("ESPNames", { Text = T("tg_espnames"), Default = true })
        ESPBox:AddToggle("ESPGun",   { Text = T("tg_espgun"), Default = true })
        ESPBox:AddLabel(T("l_murd")):AddColorPicker("ColMurd",  { Default = Color3.fromRGB(255, 50, 50),  Title = T("l_murd") })
        ESPBox:AddLabel(T("l_sher")):AddColorPicker("ColSher",  { Default = Color3.fromRGB(60, 140, 255), Title = T("l_sher") })
        ESPBox:AddLabel(T("l_inno")):AddColorPicker("ColInno",  { Default = Color3.fromRGB(80, 230, 120), Title = T("l_inno") })
        ESPBox:AddLabel(T("gb_gun")):AddColorPicker("ColGun",   { Default = Color3.fromRGB(255, 220, 60), Title = T("gb_gun") })

        local function ensureHighlight(key, adornee, color)
            local hl = espFolder:FindFirstChild("HL_" .. key)
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "HL_" .. key
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.55
                hl.Parent = espFolder
            end
            hl.Adornee = adornee
            hl.FillColor = color
            hl.OutlineColor = color
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
                tl.Name = "T"
                tl.Size = UDim2.fromScale(1, 1)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 13
                tl.TextStrokeTransparency = 0.4
                tl.Parent = bb
                bb.Parent = espFolder
            end
            bb.Adornee = head
            bb.T.Text = text
            bb.T.TextColor3 = color
        end

        task.spawn(function()
            while alive do
                if Toggles.ESPOn.Value then
                    local keep = {}
                    for _, plr in ipairs(Players:GetPlayers()) do
                        local ch = plr ~= LP and plr.Character
                        local head = ch and ch:FindFirstChild("Head")
                        if head and isAlive(plr) then
                            local role = getRole(plr)
                            local col = role == "murd" and Options.ColMurd.Value
                                or role == "sheriff" and Options.ColSher.Value or Options.ColInno.Value
                            ensureHighlight(plr.Name, ch, col)
                            keep["HL_" .. plr.Name] = true
                            if Toggles.ESPNames.Value then
                                ensureTag(plr.Name, head, plr.Name .. " [" .. roleName(role) .. "]", col)
                                keep["BB_" .. plr.Name] = true
                            end
                        end
                    end
                    local gun = workspace:FindFirstChild("GunDrop")
                    if gun and Toggles.ESPGun.Value then
                        ensureHighlight("GunDrop", gun, Options.ColGun.Value)
                        keep["HL_GunDrop"] = true
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
            local g = workspace:FindFirstChild("GunDrop")
            local part = g and toPart(g)
            local _, hrp = getChar()
            if not part or not hrp then return false end
            local old = hrp.CFrame
            if firetouchinterest then
                pcall(function() firetouchinterest(hrp, part, 0); firetouchinterest(hrp, part, 1) end)
            end
            task.wait(0.15)
            if part.Parent then
                hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.35)
            end
            hrp.CFrame = old
            return true
        end

        GunBox:AddButton({ Text = T("btn_grabgun"), Func = function()
            task.spawn(function()
                if grabGun() then Library:Notify(T("n_gunok"), 3)
                else Library:Notify(T("n_nogun"), 3) end
            end)
        end })
        GunBox:AddToggle("AutoGun", { Text = T("tg_autogun"), Default = false })
        GunBox:AddToggle("RoleNotify", { Text = T("tg_rolenotify"), Default = true })

        task.spawn(function()
            while alive do
                if Toggles.AutoGun.Value and workspace:FindFirstChild("GunDrop") then
                    pcall(grabGun); task.wait(1)
                end
                task.wait(0.5)
            end
        end)

        local lastRole
        task.spawn(function()
            while alive do
                local r = getRole(LP)
                if r ~= lastRole then
                    lastRole = r
                    if Toggles.RoleNotify.Value and r ~= "inno" then
                        Library:Notify(T("n_yourrole") .. " " .. roleName(r), 4)
                    end
                end
                task.wait(1)
            end
        end)
    end

    -- =========================================================================
    -- ROL
    -- =========================================================================
    local safePlat, savedCF
    do
        local ShBox = Tabs.Role:AddLeftGroupbox(T("gb_sheriff"))
        local MdBox = Tabs.Role:AddRightGroupbox(T("l_murd"))
        local InBox = Tabs.Role:AddLeftGroupbox(T("gb_safe"))

        local function equip(name)
            local tool = hasTool(LP, name)
            local _, _, hum = getChar()
            if tool and hum and tool.Parent ~= LP.Character then
                pcall(function() hum:EquipTool(tool) end)
                task.wait(0.1)
            end
            return LP.Character and LP.Character:FindFirstChild(name)
        end

        -- ---------------------------------------------------------------------
        -- SHERIFF: usa el remote  Character.Gun.Shoot:FireServer(origen, destino)
        -- (FireServer no espera respuesta, así que no puede congelar el script)
        -- ---------------------------------------------------------------------
        local shooting = false
        local lastShot = 0

        local function heldGun()
            local ch = LP.Character
            return ch and ch:FindFirstChild("Gun")
        end

        local function ensureGun()
            local g = heldGun()
            if g then return g end
            local bp = LP:FindFirstChildOfClass("Backpack")
            local tool = bp and bp:FindFirstChild("Gun")
            local _, _, hum = getChar()
            if tool and hum then
                pcall(function() hum:EquipTool(tool) end)
                local t0 = os.clock()
                while os.clock() - t0 < 1 do
                    g = heldGun()
                    if g then return g end
                    task.wait(0.05)
                end
            end
            return heldGun()
        end

        local function shootAt(targetHRP)
            local gun = ensureGun()
            if not gun then return false, T("err_nogun") end
            local remote = gun:FindFirstChild("Shoot")
            if not (remote and remote:IsA("RemoteEvent")) then return false, T("err_noremote") end

            local ch, hrp = getChar()
            if not hrp then return false, T("err_shoot") end
            local hand = ch:FindFirstChild("RightHand") or ch:FindFirstChild("Right Arm")
            local originCF = (hand and hand.CFrame) or hrp.CFrame

            local pos = targetHRP.Position
            if Toggles.ShootPredict.Value then
                pos = pos + targetHRP.AssemblyLinearVelocity * 0.12
            end

            local ok = pcall(function() remote:FireServer(originCF, CFrame.new(pos)) end)
            lastShot = os.clock()
            return ok
        end

        ShBox:AddButton({ Text = T("btn_shoot"), Func = function()
            if getRole(LP) ~= "sheriff" then Library:Notify(T("err_notsher"), 3) return end
            local m = findByRole("murd")
            local mh = m and m ~= LP and m.Character and m.Character:FindFirstChild("HumanoidRootPart")
            if not mh or not isAlive(m) then Library:Notify(T("err_nomurd"), 3) return end
            if shooting then return end
            task.spawn(function()
                shooting = true
                local ok, res, err = pcall(shootAt, mh)
                shooting = false
                if ok and res == false then Library:Notify(err or T("err_shoot"), 3) end
            end)
        end })
        ShBox:AddToggle("AutoShoot", { Text = T("tg_autoshoot"), Default = false })
        ShBox:AddSlider("ShootRange", { Text = T("sl_range"), Default = 70, Min = 20, Max = 200, Rounding = 0, Suffix = " st" })
        ShBox:AddSlider("ShootCooldown", { Text = T("sl_cooldown"), Default = 2.5, Min = 1, Max = 6, Rounding = 1, Suffix = " s" })
        ShBox:AddToggle("ShootPredict", { Text = T("tg_predict"), Default = true })
        ShBox:AddToggle("ShootLOS", { Text = T("tg_los"), Default = true })
        ShBox:AddButton({ Text = T("btn_equipgun"), Func = function() task.spawn(ensureGun) end })

        task.spawn(function()
            while alive do
                task.wait(0.25)
                if Toggles.AutoShoot.Value and Round.active and not shooting
                    and os.clock() - lastShot > Options.ShootCooldown.Value
                    and getRole(LP) == "sheriff" then

                    local m = findByRole("murd")
                    local mh = m and m ~= LP and m.Character and m.Character:FindFirstChild("HumanoidRootPart")
                    local _, hrp = getChar()
                    if mh and hrp and isAlive(m)
                        and (mh.Position - hrp.Position).Magnitude <= Options.ShootRange.Value then

                        local clear = true
                        if Toggles.ShootLOS.Value then
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Exclude
                            params.FilterDescendantsInstances = { LP.Character, m.Character }
                            clear = workspace:Raycast(hrp.Position, mh.Position - hrp.Position, params) == nil
                        end

                        if clear then
                            shooting = true
                            pcall(shootAt, mh)   -- cualquier error queda contenido aquí
                            shooting = false
                        end
                    end
                end
            end
        end)

        -- Asesino
        local function stab(knife, target)
            local ch = target.Character
            if not ch then return end
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

        MdBox:AddToggle("KnifeAura", { Text = T("tg_aura"), Default = false })
        MdBox:AddSlider("AuraRange", { Text = T("sl_aurarange"), Default = 12, Min = 5, Max = 30, Rounding = 0, Suffix = " st" })
        MdBox:AddToggle("KnifeReach", { Text = T("tg_reach"), Default = false })
        MdBox:AddSlider("ReachSize", { Text = T("sl_reachsize"), Default = 8, Min = 2, Max = 25, Rounding = 0 })
        MdBox:AddButton({ Text = T("btn_killall"), Func = function()
            if getRole(LP) ~= "murd" then Library:Notify(T("n_notmurd"), 3) return end
            task.spawn(function()
                local knife = equip("Knife")
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
                Library:Notify(T("n_killdone"), 3)
            end)
        end })
        MdBox:AddButton({ Text = T("btn_equipknife"), Func = function() task.spawn(equip, "Knife") end })

        task.spawn(function()
            while alive do
                if Toggles.KnifeAura.Value and getRole(LP) == "murd" then
                    pcall(function()
                        local knife = equip("Knife")
                        local _, hrp = getChar()
                        if knife and hrp then
                            for _, plr in ipairs(Players:GetPlayers()) do
                                if plr ~= LP and isAlive(plr) then
                                    local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                    if thrp and (thrp.Position - hrp.Position).Magnitude <= Options.AuraRange.Value then
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
            local knife = LP.Character and LP.Character:FindFirstChild("Knife")
            local handle = knife and knife:FindFirstChild("Handle")
            if handle then
                if not origHandle[handle] then origHandle[handle] = handle.Size end
                if Toggles.KnifeReach.Value then
                    local s = Options.ReachSize.Value
                    handle.Size = Vector3.new(s, s, s)
                    handle.Massless = true
                else
                    handle.Size = origHandle[handle]
                end
            end
        end))

        -- Inocente / seguridad
        InBox:AddToggle("SafeMode", { Text = T("tg_safe"), Default = false, Tooltip = T("tip_safe") })
        InBox:AddToggle("AutoSafe", { Text = T("tg_autosafe"), Default = false })
        InBox:AddSlider("SafeDist", { Text = T("sl_danger"), Default = 25, Min = 10, Max = 80, Rounding = 0, Suffix = " st" })

        local function goSafe()
            local _, hrp = getChar()
            if not hrp then return end
            if not safePlat then
                safePlat = Instance.new("Part")
                safePlat.Name = "MM2HubSafe"
                safePlat.Size = Vector3.new(40, 2, 40)
                safePlat.Anchored = true
                safePlat.Transparency = 0.6
                safePlat.Position = Vector3.new(0, 1500, 0)
                safePlat.Parent = workspace
            end
            if not savedCF then savedCF = hrp.CFrame end
            hrp.CFrame = CFrame.new(0, 1504, 0)
        end
        local function leaveSafe()
            local _, hrp = getChar()
            if hrp and savedCF then hrp.CFrame = savedCF end
            savedCF = nil
        end
        Toggles.SafeMode:OnChanged(function()
            if Toggles.SafeMode.Value then goSafe() else leaveSafe() end
        end)

        task.spawn(function()
            while alive do
                if Toggles.AutoSafe.Value and Round.active and getRole(LP) ~= "murd" then
                    local mh = murdererHRP()
                    local _, hrp = getChar()
                    if mh and hrp and not savedCF and (mh.Position - hrp.Position).Magnitude < Options.SafeDist.Value then
                        Toggles.SafeMode:SetValue(true)
                    end
                end
                if savedCF and not Round.active and Toggles.SafeMode.Value then
                    Toggles.SafeMode:SetValue(false)
                end
                task.wait(0.4)
            end
        end)
    end

    -- =========================================================================
    -- JUGADOR
    -- =========================================================================
    local flyBV
    do
        local MoveBox = Tabs.Player:AddLeftGroupbox(T("gb_move"))
        local MiscBox = Tabs.Player:AddRightGroupbox(T("gb_extras"))

        MoveBox:AddToggle("WSOn", { Text = T("sl_speed"), Default = false })
        MoveBox:AddSlider("WS", { Text = "WalkSpeed", Default = 24, Min = 16, Max = 100, Rounding = 0 })
        MoveBox:AddToggle("JPOn", { Text = T("tg_jump"), Default = false })
        MoveBox:AddSlider("JP", { Text = "JumpPower", Default = 60, Min = 50, Max = 200, Rounding = 0 })
        MoveBox:AddToggle("InfJump", { Text = T("tg_infjump"), Default = false })
        MoveBox:AddToggle("Noclip", { Text = "Noclip", Default = false })
        MoveBox:AddToggle("Fly", { Text = T("tg_fly"), Default = false })
        MoveBox:AddSlider("FlySpeed", { Text = T("sl_flyspeed"), Default = 40, Min = 10, Max = 120, Rounding = 0 })

        track(RunService.Heartbeat:Connect(function()
            local _, hrp, hum = getChar()
            if hum then
                if Toggles.WSOn.Value then hum.WalkSpeed = Options.WS.Value end
                if Toggles.JPOn.Value then hum.UseJumpPower = true; hum.JumpPower = Options.JP.Value end
            end
            if hrp and hum and Toggles.Fly.Value then
                if not flyBV or flyBV.Parent ~= hrp then
                    if flyBV then flyBV:Destroy() end
                    flyBV = Instance.new("BodyVelocity")
                    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    flyBV.Parent = hrp
                end
                local cam = workspace.CurrentCamera
                flyBV.Velocity = hum.MoveDirection.Magnitude > 0
                    and cam.CFrame.LookVector * Options.FlySpeed.Value or Vector3.zero
            elseif flyBV then
                flyBV:Destroy(); flyBV = nil
            end
        end))
        track(UIS.JumpRequest:Connect(function()
            if Toggles.InfJump.Value then
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
        MiscBox:AddDropdown("TPPlayer", { Values = playerNames(), Default = 1, Multi = false, Text = T("tab_player") })
        MiscBox:AddButton({ Text = T("btn_goplayer"), Func = function()
            local target = Players:FindFirstChild(Options.TPPlayer.Value or "")
            local _, hrp = getChar()
            local thrp = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if hrp and thrp then hrp.CFrame = thrp.CFrame + Vector3.new(0, 3, 0)
            else Library:Notify(T("n_fail"), 2) end
        end })
        MiscBox:AddButton({ Text = T("btn_refresh"), Func = function() Options.TPPlayer:SetValues(playerNames()) end })
        MiscBox:AddToggle("Spectate", { Text = T("tg_spectate"), Default = false, Callback = function(v)
            local cam = workspace.CurrentCamera
            if v then
                local target = Players:FindFirstChild(Options.TPPlayer.Value or "")
                local hum = target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
                if hum then cam.CameraSubject = hum end
            else
                local _, _, hum = getChar()
                if hum then cam.CameraSubject = hum end
            end
        end })
        MiscBox:AddToggle("AntiAFK", { Text = "Anti-AFK", Default = true })
        track(LP.Idled:Connect(function()
            if Toggles.AntiAFK.Value then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end))
        MiscBox:AddSlider("FOV", { Text = T("sl_fov"), Default = 70, Min = 50, Max = 120, Rounding = 0,
            Callback = function(v) workspace.CurrentCamera.FieldOfView = v end })
        MiscBox:AddButton({ Text = "Boost FPS", Func = function()
            task.spawn(function()
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                Lighting.GlobalShadows = false
                local n = 0
                for _, d in ipairs(workspace:GetDescendants()) do
                    if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") then
                        d.Enabled = false
                    elseif d:IsA("BasePart") then
                        d.CastShadow = false
                    end
                    n += 1
                    if n % 400 == 0 then task.wait() end
                end
                Library:Notify(T("n_fps"), 3)
            end)
        end })
        MiscBox:AddButton({ Text = T("btn_rejoin"), Func = function()
            TeleportSvc:Teleport(game.PlaceId, LP)
        end })
        MiscBox:AddButton({ Text = T("btn_hop"), Func = function()
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
                Library:Notify(T("n_noserver"), 3)
            end)
        end })
    end

    -- =========================================================================
    -- VISUAL: shaders
    -- =========================================================================
    local atm, bloom, cc, rays, dof
    local original, origShadows = {}, Lighting.GlobalShadows
    local currentShaderId = "real"
    do
        local ShdBox = Tabs.Visual:AddLeftGroupbox(T("gb_shaders"))
        local FxBox  = Tabs.Visual:AddRightGroupbox(T("gb_live"))

        local ORIG = { "Brightness", "ClockTime", "Ambient", "OutdoorAmbient", "ColorShift_Top",
            "ColorShift_Bottom", "ExposureCompensation", "FogColor", "FogStart", "FogEnd" }
        for _, k in ipairs(ORIG) do pcall(function() original[k] = Lighting[k] end) end

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
            cc    = { Brightness = 0, Contrast = 0, Saturation = 0, TintColor = H("ffffff") },
            rays  = { Intensity = 0 },
            dof   = { FarIntensity = 0, NearIntensity = 0 },
        }
        local DEF = { t = 14, b = 2.5, ex = 0.1, am = "505a6a", oa = "78808c", top = "ffffff", bot = "000000",
            fog = "bec8d7", fs = 100, fe = 2000, ad = 0.3, ac = "bec8dc", adc = "78829a", hz = 1.2, gl = 0.3,
            bi = 0.4, bs = 30, bt = 1.4, con = 0.1, sat = 0.1, tint = "ffffff", ry = 0.1, df = 0.1 }

        local function S(o)
            local d = {}
            for k, v in pairs(DEF) do d[k] = o[k] ~= nil and o[k] or v end
            return {
                L = { Brightness = d.b, ClockTime = d.t, Ambient = H(d.am), OutdoorAmbient = H(d.oa),
                      ColorShift_Top = H(d.top), ColorShift_Bottom = H(d.bot), ExposureCompensation = d.ex,
                      FogColor = H(d.fog), FogStart = d.fs, FogEnd = d.fe },
                atm   = { Density = d.ad, Offset = 0.25, Color = H(d.ac), Decay = H(d.adc), Glare = d.gl, Haze = d.hz },
                bloom = { Intensity = d.bi, Size = d.bs, Threshold = d.bt },
                cc    = { Brightness = 0, Contrast = d.con, Saturation = d.sat, TintColor = H(d.tint) },
                rays  = { Intensity = d.ry },
                dof   = { FarIntensity = d.df, FocusDistance = 60, InFocusRadius = 50, NearIntensity = 0 },
            }
        end

        local SHADERS = {
            real    = S({}),
            noon    = S({ t = 12, b = 3.4, ex = 0.15, sat = 0.2, ad = 0.2, hz = 0.8, ry = 0.15 }),
            gold    = S({ t = 18, b = 2.8, am = "5a3c32", oa = "966450", top = "ffaa5a", bot = "50285a", fog = "ffaa78", ac = "ffaf78", adc = "d26446", hz = 2, gl = 1, bi = 0.6, bs = 40, sat = 0.25, tint = "ffe1be", ry = 0.35 }),
            blue    = S({ t = 18.7, b = 1.4, am = "3c4670", oa = "5a6ea0", top = "96aaff", bot = "281e50", fog = "6478b4", fe = 1600, ac = "6e82c8", adc = "3c3c82", hz = 2, bi = 0.7, tint = "dce6ff", ry = 0.05 }),
            moon    = S({ t = 0, b = 0.8, ex = 0.3, am = "1e2846", oa = "283764", top = "7896ff", bot = "0a0f28", fog = "141e3c", fs = 50, fe = 1200, ac = "3c5096", adc = "141e46", hz = 1.5, gl = 0.2, bi = 0.8, bs = 40, bt = 0.9, tint = "d2e1ff", ry = 0 }),
            hallo   = S({ t = 19, b = 1.6, ex = 0.1, am = "4a2a1a", oa = "7a4528", top = "ff8a2a", bot = "2a0f3a", fog = "7a3a1a", fs = 30, fe = 1100, ad = 0.5, ac = "d2782e", adc = "6e2d14", hz = 3, gl = 0.6, bi = 0.9, bs = 44, bt = 1, con = 0.3, sat = 0.3, tint = "ffd2a0", ry = 0.2, df = 0.2 }),
            cine    = S({ t = 16.5, b = 2.4, ex = -0.05, am = "3c373c", oa = "5a555f", top = "ffd2a0", bot = "1e2846", fog = "a09696", fe = 1800, ac = "c8b4aa", adc = "966e5a", hz = 1.6, gl = 0.6, bi = 0.55, bs = 36, bt = 1.3, con = 0.25, sat = -0.05, tint = "ffeedc", ry = 0.2, df = 0.25 }),
            teal    = S({ t = 17, b = 2.6, am = "34505a", oa = "58828c", top = "ffaa64", bot = "0a465a", fog = "78aab4", ac = "8cc8d2", adc = "dc7846", hz = 1.6, bi = 0.6, con = 0.3, sat = 0.2, tint = "ffe6d2", ry = 0.3, df = 0.2 }),
            cyber   = S({ t = 22, b = 1.2, ex = 0.2, am = "3c145a", oa = "280a50", top = "ff3cc8", bot = "00c8ff", fog = "3c0a5a", fs = 30, fe = 900, ad = 0.45, ac = "b43cdc", adc = "280a64", hz = 2.5, gl = 0.5, bi = 1.2, bs = 50, bt = 0.7, con = 0.3, sat = 0.5, tint = "ffd2ff", ry = 0.1, df = 0.2 }),
            synth   = S({ t = 19.2, b = 1.8, ex = 0.2, am = "50206e", oa = "78329b", top = "ff64b4", bot = "3264ff", fog = "aa3c8c", fe = 1600, ad = 0.4, ac = "ff78b4", adc = "5a28a0", hz = 2.5, gl = 1, bi = 1.1, bs = 50, bt = 0.8, con = 0.25, sat = 0.5, tint = "ffd2f0", ry = 0.35 }),
            fantasy = S({ t = 17.2, b = 2.6, ex = 0.2, am = "64508c", oa = "8c6eb4", top = "e6b4ff", bot = "50a0ff", fog = "c8aaff", fs = 80, ad = 0.38, ac = "d7afff", adc = "965adc", hz = 2, gl = 0.8, bi = 0.9, bs = 48, bt = 1, sat = 0.35, tint = "f5e1ff", ry = 0.3, df = 0.15 }),
            horror  = S({ t = 3, b = 1, ex = -0.1, am = "23282d", oa = "2d3737", top = "96b4aa", bot = "0a0f0f", fog = "3c4b46", fs = 0, fe = 220, ad = 0.62, ac = "5f6e69", adc = "282d32", hz = 4, gl = 0, bi = 0.3, bs = 24, bt = 1.2, con = 0.3, sat = -0.35, tint = "d2ebe1", ry = 0, df = 0.3 }),
            noir    = S({ t = 21, b = 1.2, am = "282828", oa = "3c3c3c", top = "e6e6e6", bot = "000000", fog = "28282d", fs = 20, fe = 800, ad = 0.4, ac = "46464b", adc = "1e1e23", hz = 2, bi = 0.6, bs = 36, bt = 1.1, con = 0.5, sat = -1, ry = 0.1, df = 0.3 }),
            bright  = S({ t = 12, b = 5, ex = 0.5, am = "8c8c8c", oa = "b4b4b4", fog = "dce6f5", fs = 500, fe = 5000, ad = 0.15, ac = "c8d7f0", adc = "8296be", hz = 0.5, gl = 0.2, bi = 0.5, con = 0.1, sat = 0.3, ry = 0.2, df = 0 }),
        }
        local ORDER = { "real", "noon", "gold", "blue", "moon", "hallo", "cine", "teal", "cyber", "synth", "fantasy", "horror", "noir", "bright" }
        local shaderNames, nameToId = {}, {}
        for _, id in ipairs(ORDER) do
            local nm = T("sh_" .. id)
            table.insert(shaderNames, nm)
            nameToId[nm] = id
        end

        local TW = TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local function tween(i, p) TweenService:Create(i, TW, p):Play() end

        local sliderRefresh = {}
        local function syncSliders() for _, r in ipairs(sliderRefresh) do r() end end

        local function applyShader(id)
            local p = SHADERS[id]
            if not p then return end
            Lighting.GlobalShadows = true
            tween(Lighting, p.L)
            tween(atm, p.atm); tween(bloom, p.bloom); tween(cc, p.cc); tween(rays, p.rays); tween(dof, p.dof)
            task.delay(1.5, syncSliders)
        end
        local function restoreLighting()
            tween(Lighting, original)
            pcall(function() Lighting.GlobalShadows = origShadows end)
            tween(atm, OFF.atm); tween(bloom, OFF.bloom); tween(cc, OFF.cc); tween(rays, OFF.rays); tween(dof, OFF.dof)
            task.delay(1.5, syncSliders)
        end

        ShdBox:AddDropdown("ShaderPick", { Values = shaderNames, Default = 1, Multi = false, Text = T("dd_shader") })
        ShdBox:AddToggle("ShaderOn", { Text = T("tg_shader"), Default = false, Callback = function(v)
            if v then applyShader(currentShaderId) else restoreLighting() end
        end })
        Options.ShaderPick:OnChanged(function()
            currentShaderId = nameToId[Options.ShaderPick.Value] or currentShaderId
            if Toggles.ShaderOn.Value then applyShader(currentShaderId) end
        end)
        ShdBox:AddButton({ Text = T("btn_random"), Func = function()
            local id = ORDER[math.random(1, #ORDER)]
            Options.ShaderPick:SetValue(T("sh_" .. id))
            Toggles.ShaderOn:SetValue(true)
            currentShaderId = id
            applyShader(id)
        end })
        ShdBox:AddToggle("Fullbright", { Text = "Fullbright", Default = false, Callback = function(v)
            if v then
                Lighting.Brightness = 2; Lighting.ClockTime = 14
                Lighting.FogEnd = 1e5; Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(190, 190, 190)
            else
                for k, val in pairs(original) do pcall(function() Lighting[k] = val end) end
                Lighting.GlobalShadows = origShadows
            end
        end })

        local function fxSlider(id, text, min, max, get, set, rounding)
            FxBox:AddSlider(id, { Text = text, Default = min, Min = min, Max = max, Rounding = rounding or 1,
                Callback = function(v) set(v) end })
            table.insert(sliderRefresh, function()
                local ok, v = pcall(get)
                if ok and type(v) == "number" and Options[id] then Options[id]:SetValue(math.clamp(v, min, max)) end
            end)
        end
        fxSlider("FxTime",  T("fx_time"), 0, 24, function() return Lighting.ClockTime end, function(v) Lighting.ClockTime = v end)
        fxSlider("FxBright",T("fx_bright"), 0, 6, function() return Lighting.Brightness end, function(v) Lighting.Brightness = v end)
        fxSlider("FxFog",   T("fx_fog"), 100, 6000, function() return Lighting.FogEnd end, function(v) Lighting.FogEnd = v end, 0)
        fxSlider("FxBloom", "Bloom", 0, 2, function() return bloom.Intensity end, function(v) bloom.Intensity = v end, 2)
        fxSlider("FxSat",   T("fx_sat"), -1, 1, function() return cc.Saturation end, function(v) cc.Saturation = v end, 2)
        fxSlider("FxCon",   T("fx_con"), -0.5, 1, function() return cc.Contrast end, function(v) cc.Contrast = v end, 2)
    end

    -- =========================================================================
    -- AJUSTES + cambio de idioma
    -- =========================================================================
    local function takeSnapshot()
        local s = { toggles = {}, options = {}, shader = currentShaderId }
        for k, t in pairs(Toggles) do s.toggles[k] = t.Value end
        for k, o in pairs(Options) do
            if type(o) == "table" and o.Value ~= nil then s.options[k] = o.Value end
        end
        return s
    end

    local SKIP = { LangPick = true, ShaderPick = true, TPPlayer = true, MenuKeybind = true, SafeMode = true, Spectate = true }
    local function restoreSnapshot(s)
        if not s then return end
        if s.shader then pcall(function() Options.ShaderPick:SetValue(T("sh_" .. s.shader)) end) end
        for k, v in pairs(s.options) do
            if not SKIP[k] and k:sub(1, 2) ~= "Fx" and Options[k] then
                pcall(function()
                    if typeof(v) == "Color3" then Options[k]:SetValueRGB(v) else Options[k]:SetValue(v) end
                end)
            end
        end
        for k, v in pairs(s.toggles) do
            if not SKIP[k] and Toggles[k] then pcall(function() Toggles[k]:SetValue(v) end) end
        end
    end

    do
        local MenuBox = Tabs.Settings:AddLeftGroupbox(T("gb_menu"))
        MenuBox:AddButton({ Text = T("btn_unload"), Func = function() Library:Unload() end })
        MenuBox:AddLabel(T("l_menukey")):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = T("l_menukey") })
        Library.ToggleKeybind = Options.MenuKeybind

        -- cambio de idioma: reconstruye el menú conservando tus ajustes
        local nameToCode = {}
        for _, l in ipairs(LANGS) do nameToCode[l[2]] = l[1] end
        Options.LangPick:OnChanged(function()
            local code = nameToCode[Options.LangPick.Value]
            if code and code ~= LANG then
                saveLang(code)
                local s = takeSnapshot()
                Library:Notify(T("n_langchange"), 2)
                task.spawn(function()
                    task.wait(0.4)
                    pcall(function() Library:Unload() end)
                    task.wait(0.6)
                    Build(code, s)
                end)
            end
        end)
    end

    Library:OnUnload(function()
        alive = false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        pcall(function() espFolder:Destroy() end)
        pcall(function() hud:Destroy() end)
        if flyBV then pcall(function() flyBV:Destroy() end) end
        if safePlat then pcall(function() safePlat:Destroy() end) end
        for _, e in ipairs({ atm, bloom, cc, rays, dof }) do pcall(function() e:Destroy() end) end
        for k, v in pairs(original) do pcall(function() Lighting[k] = v end) end
        pcall(function() Lighting.GlobalShadows = origShadows end)
    end)

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "LangPick" })
    ThemeManager:SetFolder("MM2Hub")
    SaveManager:SetFolder("MM2Hub/mm2")
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)

    restoreSnapshot(snap)
    Library:Notify(T("n_loaded"), 4)
end

-- Evitar duplicados si ejecutas el script dos veces
if getgenv().__MM2HubUnload then pcall(getgenv().__MM2HubUnload) task.wait(0.4) end
Build(loadLang(), nil)
