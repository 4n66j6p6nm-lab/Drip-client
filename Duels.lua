print("✅ Asesinos VS Sheriffs - Sidebar + Fondo + Particles")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local speedEnabled = false
local espEnabled = false
local hitboxEnabled = false
local hitboxSize = 8
local tpEnemyEnabled = false
local licenseAccepted = false
local isPremium = false
local streamMode = false

local LICENSE_KEY = "LIC-D16335"
local FREE_PREMIUM_5H = "PREMIUM-5H"
local LICENSE_FILE = "DuelsGod_License.txt"
local ICON_ID = "rbxassetid://18622390193"
local PARTICLE_ID = "rbxassetid://134384906566930"

local guiName = "DuelsGod"
if game:GetService("CoreGui"):FindFirstChild(guiName) then
    game:GetService("CoreGui")[guiName]:Destroy()
end

local mainScreenGui, logoBtn, mainFrame

local function saveLicense(hours)
    if writefile then
        local expire = hours == -1 and 9999999999 or (os.time() + hours * 3600)
        pcall(function() writefile(LICENSE_FILE, tostring(expire)) end)
    end
end

local function checkSavedLicense()
    if isfile and readfile and isfile(LICENSE_FILE) then
        local ok, data = pcall(function() return readfile(LICENSE_FILE) end)
        if ok and data then
            local expire = tonumber(data)
            if expire and os.time() < expire then return true end
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

    task.wait(2.2)
    status.Text = "Loaded!"
    task.wait(0.7)
    screenGui:Destroy()

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
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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
            saveLicense(-1)
            screenGui:Destroy()
            loadMainMenu()
        elseif box.Text == FREE_PREMIUM_5H then
            licenseAccepted = true
            isPremium = true
            saveLicense(5)
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
                Text = "Discord copiado! Usa PREMIUM-5H",
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
        if not parent or not parent.Parent or not parent.Visible or streamMode then return end
        local size = math.random(16, 28)
        local p = Instance.new("ImageLabel")
        p.Size = UDim2.new(0, size, 0, size)
        p.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, -0.12, 0)
        p.BackgroundTransparency = 1
        p.Image = PARTICLE_ID
        p.ImageTransparency = math.random(0, 30) / 100
        p.Rotation = math.random(0, 360)
        p.ZIndex = 20
        p.Parent = folder

        local duration = math.random(28, 50) / 10
        local endX = p.Position.X.Scale + (math.random(-25, 25) / 100)
        local tween = TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Position = UDim2.new(math.clamp(endX, -0.1, 1.1), 0, 1.15, 0),
            Rotation = p.Rotation + math.random(100, 300)
        })
        tween:Play()
        tween.Completed:Connect(function()
            p:Destroy()
        end)
    end

    task.spawn(function()
        while parent and parent.Parent do
            if parent.Visible and not streamMode then
                spawnParticle()
            end
            task.wait(0.22)
        end
    end)
end

local function createToggle(parent, name, y, default, callback)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.9, 0, 0, 42)
    toggle.Position = UDim2.new(0.05, 0, 0, y)
    toggle.BackgroundColor3 = default and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 55)
    toggle.BackgroundTransparency = 0.15
    toggle.Text = "  " .. name .. "  [" .. (default and "ON" or "OFF") .. "]"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 14
    toggle.Font = Enum.Font.Gotham
    toggle.TextXAlignment = Enum.TextXAlignment.Left
    toggle.ZIndex = 15
    toggle.Parent = parent
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

    toggle.MouseButton1Click:Connect(function()
        default = not default
        toggle.BackgroundColor3 = default and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 55)
        toggle.Text = "  " .. name .. "  [" .. (default and "ON" or "OFF") .. "]"
        callback(default)
    end)
    return toggle
end

function loadMainMenu()
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = guiName
    mainScreenGui.ResetOnSpawn = false
    mainScreenGui.Parent = game:GetService("CoreGui")

    logoBtn = Instance.new("ImageButton")
    logoBtn.Size = UDim2.new(0, 70, 0, 70)
    logoBtn.Position = UDim2.new(0.04, 0, 0.2, 0)
    logoBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    logoBtn.Image = ICON_ID
    logoBtn.ScaleType = Enum.ScaleType.Crop
    logoBtn.Draggable = true
    logoBtn.Parent = mainScreenGui
    Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 255, 120)
    stroke.Thickness = 2
    stroke.Parent = logoBtn

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    mainFrame.Visible = false
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainScreenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    -- Fondo del menú
    local bgImage = Instance.new("ImageLabel")
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = ICON_ID
    bgImage.ImageTransparency = 0.55
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 1
    bgImage.Parent = mainFrame
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 12)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 120, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
    sidebar.BackgroundTransparency = 0.15
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 5
    sidebar.Parent = mainFrame
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

    local sideFix = Instance.new("Frame")
    sideFix.Size = UDim2.new(0, 20, 1, 0)
    sideFix.Position = UDim2.new(1, -20, 0, 0)
    sideFix.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
    sideFix.BackgroundTransparency = 0.15
    sideFix.BorderSizePixel = 0
    sideFix.ZIndex = 5
    sideFix.Parent = sidebar

    local sideTitle = Instance.new("TextLabel")
    sideTitle.Size = UDim2.new(1, -8, 0, 40)
    sideTitle.Position = UDim2.new(0, 4, 0, 6)
    sideTitle.BackgroundTransparency = 1
    sideTitle.Text = "DUELS\nScript"
    sideTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    sideTitle.TextSize = 13
    sideTitle.Font = Enum.Font.GothamBold
    sideTitle.ZIndex = 6
    sideTitle.Parent = sidebar

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -130, 1, -20)
    content.Position = UDim2.new(0, 125, 0, 10)
    content.BackgroundTransparency = 1
    content.ZIndex = 10
    content.Parent = mainFrame

    local function clearContent()
        for _, c in ipairs(content:GetChildren()) do
            c:Destroy()
        end
    end

    local function showTab(tabName)
        clearContent()

        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundTransparency = 1
        header.Text = tabName
        header.TextColor3 = Color3.fromRGB(255, 255, 255)
        header.TextSize = 18
        header.Font = Enum.Font.GothamBold
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.ZIndex = 12
        header.Parent = content

        if tabName == "Combat" then
            if isPremium then
                createToggle(content, "Hitbox", 40, hitboxEnabled, function(s) hitboxEnabled = s end)
                createToggle(content, "TP al Enemigo", 90, tpEnemyEnabled, function(s) tpEnemyEnabled = s end)

                local sizeLabel = Instance.new("TextLabel")
                sizeLabel.Size = UDim2.new(0.55, 0, 0, 36)
                sizeLabel.Position = UDim2.new(0.05, 0, 0, 145)
                sizeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                sizeLabel.BackgroundTransparency = 0.15
                sizeLabel.Text = "Tamaño Hitbox"
                sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                sizeLabel.TextSize = 13
                sizeLabel.Font = Enum.Font.Gotham
                sizeLabel.ZIndex = 12
                sizeLabel.Parent = content
                Instance.new("UICorner", sizeLabel).CornerRadius = UDim.new(0, 6)

                local sizeBox = Instance.new("TextBox")
                sizeBox.Size = UDim2.new(0.3, 0, 0, 36)
                sizeBox.Position = UDim2.new(0.62, 0, 0, 145)
                sizeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                sizeBox.Text = tostring(hitboxSize)
                sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                sizeBox.TextSize = 14
                sizeBox.Font = Enum.Font.GothamBold
                sizeBox.ZIndex = 12
                sizeBox.Parent = content
                Instance.new("UICorner", sizeBox).CornerRadius = UDim.new(0, 6)
                sizeBox.FocusLost:Connect(function()
                    local n = tonumber(sizeBox.Text)
                    if n and n > 0 then hitboxSize = n end
                end)
            else
                local msg = Instance.new("TextLabel")
                msg.Size = UDim2.new(1, 0, 0, 40)
                msg.Position = UDim2.new(0, 0, 0, 50)
                msg.BackgroundTransparency = 1
                msg.Text = "Premium requerido"
                msg.TextColor3 = Color3.fromRGB(255, 100, 100)
                msg.TextSize = 16
                msg.Font = Enum.Font.Gotham
                msg.ZIndex = 12
                msg.Parent = content
            end

        elseif tabName == "Visual" then
            createToggle(content, "ESP", 40, espEnabled, function(s) espEnabled = s end)

        elseif tabName == "Player" then
            createToggle(content, "Speed", 40, speedEnabled, function(s) speedEnabled = s end)

        elseif tabName == "Settings" then
            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(0.95, 0, 0, 120)
            info.Position = UDim2.new(0.025, 0, 0, 40)
            info.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            info.BackgroundTransparency = 0.15
            info.Text = "Stream Mode:\nPon 4 dedos en la pantalla\npara ocultar/mostrar el menú\n\nLicencia se guarda sola"
            info.TextColor3 = Color3.fromRGB(200, 200, 200)
            info.TextSize = 13
            info.Font = Enum.Font.Gotham
            info.TextWrapped = true
            info.ZIndex = 12
            info.Parent = content
            Instance.new("UICorner", info).CornerRadius = UDim.new(0, 8)
        end
    end

    local tabs = {
        {name = "Combat", y = 55},
        {name = "Visual", y = 100},
        {name = "Player", y = 145},
        {name = "Settings", y = 190},
    }

    local tabButtons = {}
    for _, t in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 36)
        btn.Position = UDim2.new(0.05, 0, 0, t.y)
        btn.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
        btn.Text = "  " .. t.name
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = 6
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        tabButtons[t.name] = btn

        btn.MouseButton1Click:Connect(function()
            for name, b in pairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
                b.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            showTab(t.name)
        end)
    end

    tabButtons["Combat"].BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    tabButtons["Combat"].TextColor3 = Color3.fromRGB(255, 255, 255)
    showTab("Combat")

    -- Partículas cayendo en el menú
    createFallingParticles(mainFrame)

    logoBtn.MouseButton1Click:Connect(function()
        if not streamMode then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
end

-- Stream Mode 4 dedos
local activeTouches = {}
local lastStreamToggle = 0

local function toggleStreamMode()
    if tick() - lastStreamToggle < 0.8 then return end
    lastStreamToggle = tick()
    streamMode = not streamMode

    if mainScreenGui then
        if streamMode then
            if logoBtn then logoBtn.Visible = false end
            if mainFrame then mainFrame.Visible = false end
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Stream Mode",
                    Text = "ON - Oculto",
                    Duration = 2
                })
            end)
        else
            if logoBtn then logoBtn.Visible = true end
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Stream Mode",
                    Text = "OFF - Visible",
                    Duration = 2
                })
            end)
        end
    end
end

UserInputService.InputBegan:Connect(function(input)
    if not licenseAccepted then return end
    if input.UserInputType ~= Enum.UserInputType.Touch then return end
    activeTouches[input] = true
    local count = 0
    for _ in pairs(activeTouches) do count = count + 1 end
    if count >= 4 then
        toggleStreamMode()
        activeTouches = {}
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        activeTouches[input] = nil
    end
end)

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

    if espEnabled and not streamMode then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                if plr.Character.Humanoid.Health > 0 and not plr.Character:FindFirstChildOfClass("Highlight") then
                    local hl = Instance.new("Highlight")
                    hl.Parent = plr.Character
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.3
                end
            end
        end
    elseif streamMode then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local hl = plr.Character:FindFirstChildOfClass("Highlight")
                if hl then hl:Destroy() end
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
                            part.CanCollide = false
                            part.Transparency = streamMode and 1 or 0.35
                            if not streamMode then
                                part.Color = Color3.fromRGB(255, 0, 0)
                                part.Material = Enum.Material.Neon
                            end
                        end
                    end
                end
            end
        end
    end

    if isPremium and tpEnemyEnabled then
        local closest, closestDist = nil, 100
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
