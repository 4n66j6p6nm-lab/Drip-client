print("✅ Asesinos VS Sheriffs - Premium 5h Guardado")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer

local speedEnabled = false
local espEnabled = false
local hitboxEnabled = false
local hitboxSize = 8
local autoShootEnabled = false
local tpEnemyEnabled = false
local licenseAccepted = false
local isPremium = false

local LICENSE_KEY = "LIC-D16335"
local FREE_PREMIUM_5H = "PREMIUM-5H"
local LICENSE_FILE = "DuelsGod_License.txt"

local ICON_ID = "rbxassetid://18622390193"
local PARTICLE_ID = "rbxassetid://134384906566930"

local guiName = "DuelsGod"
if game:GetService("CoreGui"):FindFirstChild(guiName) then
    game:GetService("CoreGui")[guiName]:Destroy()
end

-- Guardar / cargar licencia
local function saveLicense(hours)
    if writefile then
        local expire
        if hours == -1 then
            expire = 9999999999 -- infinita
        else
            expire = os.time() + (hours * 3600)
        end
        pcall(function()
            writefile(LICENSE_FILE, tostring(expire))
        end)
    end
end

local function checkSavedLicense()
    if isfile and readfile and isfile(LICENSE_FILE) then
        local ok, data = pcall(function()
            return readfile(LICENSE_FILE)
        end)
        if ok and data then
            local expire = tonumber(data)
            if expire and os.time() < expire then
                return true
            end
        end
    end
    return false
end

local function showLoading()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DuelsLoading"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.Parent = game:GetService("CoreGui")

    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    bg.Image = ICON_ID
    bg.ScaleType = Enum.ScaleType.Crop
    bg.Parent = screenGui

    local dark = Instance.new("Frame")
    dark.Size = UDim2.new(1, 0, 1, 0)
    dark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dark.BackgroundTransparency = 0.4
    dark.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0.38, 0)
    title.BackgroundTransparency = 1
    title.Text = "Asesinos VS Sheriffs"
    title.TextColor3 = Color3.fromRGB(255, 60, 60)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.Parent = bg

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0.52, 0)
    status.BackgroundTransparency = 1
    status.Text = "Loading..."
    status.TextColor3 = Color3.fromRGB(220, 220, 220)
    status.TextSize = 20
    status.Font = Enum.Font.Gotham
    status.Parent = bg

    task.wait(2.5)
    status.Text = "Loaded!"
    task.wait(0.8)
    screenGui:Destroy()

    -- Si ya tiene licencia guardada y válida → entra directo
    if checkSavedLicense() then
        licenseAccepted = true
        isPremium = true
        loadMainMenu()
    else
        showLicense()
    end
end

function showLicense()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LicenseCheck"
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 320)
    frame.Position = UDim2.new(0.5, -170, 0.24, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "Asesinos VS Sheriffs"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.85, 0, 0, 42)
    box.Position = UDim2.new(0.075, 0, 0.2, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = ""
    box.PlaceholderText = "Ingresa tu licencia..."
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 16
    box.Font = Enum.Font.Gotham
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

    local activateBtn = Instance.new("TextButton")
    activateBtn.Size = UDim2.new(0.85, 0, 0, 42)
    activateBtn.Position = UDim2.new(0.075, 0, 0.4, 0)
    activateBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 80)
    activateBtn.Text = "Activar Licencia"
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.TextSize = 16
    activateBtn.Font = Enum.Font.GothamBold
    activateBtn.Parent = frame
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 10)

    local premium5hBtn = Instance.new("TextButton")
    premium5hBtn.Size = UDim2.new(0.85, 0, 0, 42)
    premium5hBtn.Position = UDim2.new(0.075, 0, 0.6, 0)
    premium5hBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    premium5hBtn.Text = "Premium Gratis (5h) - Discord"
    premium5hBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    premium5hBtn.TextSize = 14
    premium5hBtn.Font = Enum.Font.GothamBold
    premium5hBtn.Parent = frame
    Instance.new("UICorner", premium5hBtn).CornerRadius = UDim.new(0, 10)

    activateBtn.MouseButton1Click:Connect(function()
        if box.Text == LICENSE_KEY then
            licenseAccepted = true
            isPremium = true
            saveLicense(-1) -- infinita
            screenGui:Destroy()
            loadMainMenu()
        elseif box.Text == FREE_PREMIUM_5H then
            licenseAccepted = true
            isPremium = true
            saveLicense(5) -- 5 horas
            screenGui:Destroy()
            loadMainMenu()
        else
            box.Text = ""
            box.PlaceholderText = "Licencia incorrecta"
        end
    end)

    premium5hBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/wHc9aBmvh")
        box.Text = FREE_PREMIUM_5H
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Duels",
                Text = "Discord copiado! Usa PREMIUM-5H (5 horas)",
                Duration = 5
            })
        end)
    end)
end

local function createFallingParticles(parent)
    local folder = Instance.new("Folder")
    folder.Name = "FallingParticles"
    folder.Parent = parent

    local function spawnParticle()
        if not parent or not parent.Parent or not parent.Visible then return end
        local size = math.random(18, 32)
        local p = Instance.new("ImageLabel")
        p.Size = UDim2.new(0, size, 0, size)
        p.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, -0.15, 0)
        p.BackgroundTransparency = 1
        p.Image = PARTICLE_ID
        p.ImageTransparency = math.random(0, 25) / 100
        p.Rotation = math.random(0, 360)
        p.ZIndex = 10
        p.Parent = folder

        local duration = math.random(28, 50) / 10
        local endX = p.Position.X.Scale + (math.random(-30, 30) / 100)
        local tween = TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Position = UDim2.new(math.clamp(endX, -0.1, 1.1), 0, 1.2, 0),
            Rotation = p.Rotation + math.random(120, 360)
        })
        tween:Play()
        tween.Completed:Connect(function()
            p:Destroy()
        end)
    end

    task.spawn(function()
        while parent and parent.Parent do
            if parent.Visible then
                spawnParticle()
            end
            task.wait(0.2)
        end
    end)
end

function loadMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = guiName
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local logoBtn = Instance.new("ImageButton")
    logoBtn.Size = UDim2.new(0, 80, 0, 80)
    logoBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    logoBtn.BackgroundTransparency = 1
    logoBtn.Image = ICON_ID
    logoBtn.ScaleType = Enum.ScaleType.Crop
    logoBtn.Draggable = true
    logoBtn.Parent = screenGui
    Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)

    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "DUELS"
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.TextSize = 15
    logoText.Font = Enum.Font.GothamBold
    logoText.Parent = logoBtn

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 290, 0, isPremium and 450 or 260)
    menu.Position = UDim2.new(0.5, -145, 0.15, 0)
    menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    menu.Visible = false
    menu.Active = true
    menu.Draggable = true
    menu.ClipsDescendants = true
    menu.Parent = screenGui
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 14)

    local bgImage = Instance.new("ImageLabel")
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = ICON_ID
    bgImage.ImageTransparency = 0.55
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.Parent = menu
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 42)
    title.BackgroundTransparency = 1
    title.Text = "Asesinos VS Sheriffs"
    title.TextColor3 = Color3.fromRGB(255, 60, 60)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 12
    title.Parent = menu

    local function createToggle(name, y, default, callback)
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.9, 0, 0, 48)
        toggle.Position = UDim2.new(0.05, 0, 0, y)
        toggle.BackgroundColor3 = default and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(220, 40, 80)
        toggle.BackgroundTransparency = 0.12
        toggle.Text = name .. ": " .. (default and "ON" or "OFF")
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 15
        toggle.Font = Enum.Font.GothamBold
        toggle.ZIndex = 12
        toggle.Parent = menu
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

        toggle.MouseButton1Click:Connect(function()
            default = not default
            toggle.BackgroundColor3 = default and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(220, 40, 80)
            toggle.Text = name .. ": " .. (default and "ON" or "OFF")
            callback(default)
        end)
    end

    createToggle("Speed", 55, speedEnabled, function(s) speedEnabled = s end)
    createToggle("ESP", 110, espEnabled, function(s) espEnabled = s end)

    if isPremium then
        createToggle("Hitbox", 165, hitboxEnabled, function(s) hitboxEnabled = s end)

        local sizeLabel = Instance.new("TextLabel")
        sizeLabel.Size = UDim2.new(0.55, 0, 0, 40)
        sizeLabel.Position = UDim2.new(0.05, 0, 0, 225)
        sizeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sizeLabel.BackgroundTransparency = 0.15
        sizeLabel.Text = "Tamaño Hitbox"
        sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        sizeLabel.TextSize = 14
        sizeLabel.Font = Enum.Font.GothamBold
        sizeLabel.ZIndex = 12
        sizeLabel.Parent = menu
        Instance.new("UICorner", sizeLabel).CornerRadius = UDim.new(0, 8)

        local sizeBox = Instance.new("TextBox")
        sizeBox.Size = UDim2.new(0.3, 0, 0, 40)
        sizeBox.Position = UDim2.new(0.65, 0, 0, 225)
        sizeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sizeBox.Text = "8"
        sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        sizeBox.TextSize = 16
        sizeBox.Font = Enum.Font.GothamBold
        sizeBox.ZIndex = 12
        sizeBox.Parent = menu
        Instance.new("UICorner", sizeBox).CornerRadius = UDim.new(0, 8)

        sizeBox.FocusLost:Connect(function()
            local num = tonumber(sizeBox.Text)
            if num and num > 0 then
                hitboxSize = num
            end
        end)

        createToggle("Auto Shoot", 285, autoShootEnabled, function(s) autoShootEnabled = s end)
        createToggle("TP al Enemigo", 340, tpEnemyEnabled, function(s) tpEnemyEnabled = s end)
    end

    createFallingParticles(menu)

    logoBtn.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)
end

local lastTP = 0

RunService.Heartbeat:Connect(function()
    if not licenseAccepted then return end

    local char = localPlayer.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    local myHum = char:FindFirstChild("Humanoid")
    if not myRoot or not myHum or myHum.Health <= 0 then return end

    if speedEnabled then
        myHum.WalkSpeed = isPremium and 36 or 24
    end

    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                if plr.Character.Humanoid.Health > 0 then
                    if not plr.Character:FindFirstChildOfClass("Highlight") then
                        local hl = Instance.new("Highlight")
                        hl.Parent = plr.Character
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.3
                    end
                end
            end
        end
    end

    if isPremium and hitboxEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    for _, name in ipairs({"Head", "Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart"}) do
                        local part = plr.Character:FindFirstChild(name)
                        if part and part:IsA("BasePart") then
                            part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            part.Transparency = 0.35
                            part.Color = Color3.fromRGB(255, 0, 0)
                            part.Material = Enum.Material.Neon
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end

    if isPremium and autoShootEnabled then
        local gun = char:FindFirstChild("Gun") or localPlayer.Backpack:FindFirstChild("Gun")
        if gun then
            pcall(function()
                if gun.Parent == localPlayer.Backpack then
                    myHum:EquipTool(gun)
                end
                gun:Activate()
            end)
        end
    end

    if isPremium and tpEnemyEnabled then
        local closest = nil
        local closestDist = 100

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character then
                local hum = plr.Character:FindFirstChild("Humanoid")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = root
                    end
                end
            end
        end

        if closest and tick() - lastTP > 0.1 then
            myRoot.CFrame = closest.CFrame * CFrame.new(0, 1, 3)
            lastTP = tick()
        end
    end
end)

showLoading()
