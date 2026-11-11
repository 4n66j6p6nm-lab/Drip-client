--[[
  KAISEN X - UTILIDADES RP - WindUI
  Enganchado directamente a los módulos reales del juego (Sprint, VehicleSystem)
  Pestañas: Jugador · Vehículo · Ajustes
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UIS                = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP                = Players.LocalPlayer

local DISCORD_URL = "https://discord.gg/tjevxNrAt"

if getgenv().__KaisenXRPUnload then pcall(getgenv().__KaisenXRPUnload) task.wait(0.4) end

local okLib, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not okLib or not WindUI then
    warn("Kaisen X: no se pudo cargar WindUI.")
    return
end

local alive = true
local conns = {}
local function track(c) table.insert(conns, c); return c end

local function getChar()
    local ch = LP.Character
    return ch, ch and ch:FindFirstChild("HumanoidRootPart"), ch and ch:FindFirstChildOfClass("Humanoid")
end

-- =============================================================================
-- Enganche a los módulos reales del juego (reintenta hasta encontrarlos)
-- =============================================================================
local function safeRequire(path, maxTries)
    maxTries = maxTries or 40
    for i = 1, maxTries do
        local ok, mod = pcall(require, path)
        if ok and mod then return mod end
        task.wait(0.25)
    end
    return nil
end

local Sprint, Vehicle
local modulesStatus = "Buscando módulos del juego..."
task.spawn(function()
    local mods = ReplicatedStorage:FindFirstChild("Modules")
    local game_ = mods and mods:FindFirstChild("Game")
    local sprintPath = game_ and game_:FindFirstChild("Sprint")
    local vehiclePath = game_ and game_:FindFirstChild("VehicleSystem") and game_.VehicleSystem:FindFirstChild("Vehicle")

    if not sprintPath then
        for i = 1, 40 do
            mods = ReplicatedStorage:FindFirstChild("Modules")
            game_ = mods and mods:FindFirstChild("Game")
            sprintPath = game_ and game_:FindFirstChild("Sprint")
            vehiclePath = game_ and game_:FindFirstChild("VehicleSystem") and game_.VehicleSystem:FindFirstChild("Vehicle")
            if sprintPath and vehiclePath then break end
            task.wait(0.25)
        end
    end

    if sprintPath then Sprint = safeRequire(sprintPath) end
    if vehiclePath then Vehicle = safeRequire(vehiclePath) end

    modulesStatus = (Sprint and "Sprint ✓ " or "Sprint ✗ ") .. (Vehicle and "Vehículo ✓" or "Vehículo ✗")
end)

-- Stamina infinita: sobreescribe la función real que decide si puedes correr -----
local originalConsumeStamina
local infiniteStaminaOn = false
local function setInfiniteStamina(on)
    if not Sprint then return false end
    infiniteStaminaOn = on
    if on then
        if not originalConsumeStamina then originalConsumeStamina = Sprint.consume_stamina end
        Sprint.consume_stamina = function() return true end
    else
        if originalConsumeStamina then Sprint.consume_stamina = originalConsumeStamina end
    end
    return true
end
-- Mantiene la barra visualmente llena mientras está activo
task.spawn(function()
    while alive do
        if infiniteStaminaOn and Sprint and Sprint.sprint_bar then
            pcall(function() Sprint.sprint_bar.set(1) end)
        end
        task.wait(0.3)
    end
end)

-- Snap al suelo: raycast hacia abajo desde tu posición -----------------------
local function groundRaycast(fromPos, ignoreList)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList or {}
    return workspace:Raycast(fromPos, Vector3.new(0, -2000, 0), params)
end

local function snapCharacterToGround()
    local ch, hrp = getChar()
    if not hrp then return false, "sin personaje" end
    local result = groundRaycast(hrp.Position, { ch })
    if not result then return false, "no encontré suelo debajo" end
    hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
    return true
end

local function getCurrentVehicle()
    if not Vehicle then return nil end
    local ok, car = pcall(Vehicle.get_car_player_is_in)
    if ok then return car end
    return nil
end

local function snapVehicleToGround()
    local car = getCurrentVehicle()
    if not car then return false, "no estás en un vehículo" end
    local ch = LP.Character
    local _, size = pcall(car.GetBoundingBox, car) and car:GetBoundingBox() or nil, nil
    local okBB, cf, boundSize = pcall(function() return car:GetBoundingBox() end)
    if not okBB then return false, "no se pudo medir el vehículo" end
    local pos = cf.Position
    local result = groundRaycast(pos, { car, ch })
    if not result then return false, "no encontré suelo debajo del auto" end
    local currentCF = car:GetPivot()
    local newPos = Vector3.new(currentCF.Position.X, result.Position.Y + boundSize.Y / 2 + 0.5, currentCF.Position.Z)
    car:PivotTo(CFrame.new(newPos) * (currentCF - currentCF.Position))
    return true
end

-- Auto-recuperación: si caes muy por debajo de tu última posición válida, snap solo
local autoRecoverOn = false
local AUTO_RECOVER_Y_DROP = 150
task.spawn(function()
    local lastGoodY
    while alive do
        if autoRecoverOn then
            local _, hrp = getChar()
            if hrp then
                if not lastGoodY then lastGoodY = hrp.Position.Y end
                if hrp.Position.Y < lastGoodY - AUTO_RECOVER_Y_DROP then
                    local car = getCurrentVehicle()
                    if car then snapVehicleToGround() else snapCharacterToGround() end
                    lastGoodY = nil
                else
                    lastGoodY = math.max(lastGoodY, hrp.Position.Y)
                end
            end
        end
        task.wait(1)
    end
end)

-- =============================================================================
-- VENTANA
-- =============================================================================
local Window = WindUI:CreateWindow({
    Title = "Kaisen X",
    Icon = "swords",
    Author = "Kaisen X",
    Folder = "KaisenX",
    Theme = "Dark",
    Size = UDim2.fromOffset(500, 380),
})

getgenv().__KaisenXRPUnload = function()
    pcall(function()
        alive = false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        if infiniteStaminaOn then setInfiniteStamina(false) end
        if Window.Destroy then Window:Destroy() end
    end)
end

local PlayerTab  = Window:Tab({ Title = "Jugador", Icon = "user" })
local VehicleTab = Window:Tab({ Title = "Vehículo", Icon = "car" })
local SettingsTab= Window:Tab({ Title = "Ajustes", Icon = "settings" })

-- JUGADOR ---------------------------------------------------------------------
do
    local lblStatus = PlayerTab:Paragraph({ Title = modulesStatus })
    task.spawn(function()
        while alive do
            pcall(function() lblStatus:SetTitle(modulesStatus) end)
            task.wait(1)
        end
    end)

    PlayerTab:Toggle({
        Title = "Stamina infinita",
        Value = false,
        Callback = function(v)
            local ok = setInfiniteStamina(v)
            if not ok then
                WindUI:Notify({ Title = "Kaisen X", Content = "El módulo de stamina aún no cargó, espera un momento", Duration = 3 })
            end
        end
    })

    PlayerTab:Button({
        Title = "Bajar al suelo (snap)",
        Callback = function()
            local ok, err = snapCharacterToGround()
            WindUI:Notify({ Title = "Kaisen X", Content = ok and "Hecho" or err, Duration = 3 })
        end
    })

    PlayerTab:Toggle({
        Title = "Auto-recuperación (si caes mucho, se baja solo)",
        Value = false,
        Callback = function(v) autoRecoverOn = v end
    })

    PlayerTab:Toggle({ Title = "Anti-AFK", Value = true, Callback = function(v)
        getgenv().__KaisenXRP_AntiAFK = v
    end })
    getgenv().__KaisenXRP_AntiAFK = true
    track(LP.Idled:Connect(function()
        if getgenv().__KaisenXRP_AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end))
end

-- VEHÍCULO ----------------------------------------------------------------------
do
    local lblVehicle = VehicleTab:Paragraph({ Title = "Vehículo actual: ninguno" })
    task.spawn(function()
        while alive do
            local car = getCurrentVehicle()
            pcall(function() lblVehicle:SetTitle("Vehículo actual: " .. (car and car.Name or "ninguno")) end)
            task.wait(0.5)
        end
    end)

    VehicleTab:Button({
        Title = "Bajar vehículo al suelo (snap car)",
        Callback = function()
            local ok, err = snapVehicleToGround()
            WindUI:Notify({ Title = "Kaisen X", Content = ok and "Hecho" or err, Duration = 3 })
        end
    })

    VehicleTab:Paragraph({ Title = "Si no detecta tu vehículo, asegúrate de estar sentado en el asiento del conductor." })
end

-- AJUSTES -------------------------------------------------------------------------
do
    SettingsTab:Button({ Title = "Descargar script", Callback = function()
        if getgenv().__KaisenXRPUnload then getgenv().__KaisenXRPUnload() end
    end })
    SettingsTab:Paragraph({ Title = DISCORD_URL })
    SettingsTab:Button({ Title = "Copiar invitación de Discord", Callback = function()
        local msg = "¡Únete al Discord de Kaisen X! " .. DISCORD_URL .. " — novedades del script, soporte y sorteos."
        if setclipboard then pcall(setclipboard, msg); WindUI:Notify({ Title = "Kaisen X", Content = "Invitación copiada", Duration = 3 })
        else WindUI:Notify({ Title = "Kaisen X", Content = "Tu executor no soporta copiar", Duration = 3 }) end
    end })
end

WindUI:Notify({ Title = "Kaisen X", Content = "Cargado correctamente", Duration = 4 })
