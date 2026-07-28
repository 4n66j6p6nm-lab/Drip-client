print("✅ Asesinos VS Sheriffs - Fixed Hitbox")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local speedEnabled = false
local espEnabled = false
local hitboxEnabled = false
local hitboxSize = 6
local autoShootEnabled = false
local licenseAccepted = false
local isPremium = false

local LICENSE_KEY = "LIC-D16335"
local FREE_LICENSE = "FREE-12H"

local guiName = "DuelsGod"
if game:GetService("CoreGui"):FindFirstChild(guiName) then
    game:GetService("CoreGui")[guiName]:Destroy()
end

-- ==================== LICENSE ====================
local function showLicense()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LicenseCheck"
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 250)
    frame.Position = UDim2.new(0.5, -170, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Asesinos VS Sheriffs"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.85, 0, 0, 40)
    box.Position = UDim2.new(0.075, 0, 0.28, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = ""
    box.PlaceholderText = "Ingresa tu licencia..."
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 16
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local activateBtn = Instance.new("TextButton")
    activateBtn.Size = UDim2.new(0.85, 0, 0, 40)
    activateBtn.Position = UDim2.new(0.075, 0, 0.5, 0)
    activateBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 80)
    activateBtn.Text = "Activar Licencia"
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.TextSize = 16
    activateBtn.Font = Enum.Font.SourceSansBold
    activateBtn.Parent = frame
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)

    local freeBtn = Instance.new("TextButton")
    freeBtn.Size = UDim2.new(0.85, 0, 0, 40)
    freeBtn.Position = UDim2.new(0.075, 0, 0.72, 0)
    freeBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 220)
    freeBtn.Text = "Licencia Gratis (12h)"
    freeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    freeBtn.TextSize = 15
    freeBtn.Font = Enum.Font.SourceSansBold
    freeBtn.Parent = frame
    Instance.new("UICorner", freeBtn).CornerRadius = UDim.new(0, 8)

    activateBtn.MouseButton1Click:Connect(function()
        if box.Text == LICENSE_KEY then
            licenseAccepted = true
            isPremium = true
            screenGui:Destroy()
            loadMainMenu()
        elseif box.Text == FREE_LICENSE then
            licenseAccepted = true
            isPremium = false
            screenGui:Destroy()
            loadMainMenu()
        else
            box.Text = ""
            box.PlaceholderText = "Licencia incorrecta"
        end
    end)

    freeBtn.MouseButton1Click:Connect(function()
        box.Text = FREE_LICENSE
    end)
end

-- ==================== MAIN MENU ====================
function loadMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = guiName
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local logoBtn = Instance.new("TextButton")
    logoBtn.Size = UDim2.new(0, 80, 0, 80)
    logoBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    logoBtn.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
    logoBtn.Text = "DUELS"
    logoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoBtn.TextSize = 18
    logoBtn.Font = Enum.Font.SourceSansBold
    logoBtn.Draggable = true
    logoBtn.Parent = screenGui
    Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 290, 0, isPremium and 420 or 260)
    menu.Position = UDim2.new(0.5, -145, 0.18, 0)
    menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    menu.Visible = false
    menu.Active = true
    menu.Draggable = true
    menu.Parent = screenGui
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Asesinos VS Sheriffs"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.Parent = menu

    local function createToggle(name, y, default, callback)
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.9, 0, 0, 48)
        toggle.Position = UDim2.new(0.05, 0, 0, y)
        toggle.BackgroundColor3 = default and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(220, 40, 80)
        toggle.Text = name .. ": " .. (default and "ON" or "OFF")
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 15
        toggle.Font = Enum.Font.SourceSansBold
        toggle.Parent = menu
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

        toggle.MouseButton1Click:Connect(function()
            default = not default
            toggle.BackgroundColor3 = default and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(220, 40, 80)
            toggle.Text = name .. ": " .. (default and "ON" or "OFF")
            callback(default)
        end)
    end

    createToggle("Speed", 50, speedEnabled, function(s) speedEnabled = s end)
    createToggle("ESP", 105, espEnabled, function(s) espEnabled = s end)

    if isPremium then
        createToggle("Hitbox (Cuerpo)", 160, hitboxEnabled, function(s) hitboxEnabled = s end)

        -- Ajustar tamaño de Hitbox
        local sizeLabel = Instance.new("TextLabel")
        sizeLabel.Size = UDim2.new(0.55, 0, 0, 40)
        sizeLabel.Position = UDim2.new(0.05, 0, 0, 220)
        sizeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sizeLabel.Text = "Tamaño Hitbox"
        sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        sizeLabel.TextSize = 14
        sizeLabel.Font = Enum.Font.SourceSansBold
        sizeLabel.Parent = menu
        Instance.new("UICorner", sizeLabel).CornerRadius = UDim.new(0, 8)

        local sizeBox = Instance.new("TextBox")
        sizeBox.Size = UDim2.new(0.3, 0, 0, 40)
        sizeBox.Position = UDim2.new(0.65, 0, 0, 220)
        sizeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sizeBox.Text = "6"
        sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        sizeBox.TextSize = 16
        sizeBox.Font = Enum.Font.SourceSansBold
        sizeBox.Parent = menu
        Instance.new("UICorner", sizeBox).CornerRadius = UDim.new(0, 8)

        sizeBox.FocusLost:Connect(function()
            local num = tonumber(sizeBox.Text)
            if num and num > 0 then
                hitboxSize = num
            end
        end)

        createToggle("Auto Shoot", 280, autoShootEnabled, function(s) autoShootEnabled = s end)
    end

    logoBtn.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)
end

-- Features
RunService.RenderStepped:Connect(function()
    if not licenseAccepted then return end

    -- Speed
    if speedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = isPremium and 36 or 24
    end

    -- ESP
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local hl = plr.Character:FindFirstChildOfClass("Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Parent = plr.Character
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                end
            end
        end
    end

    -- Hitbox en el CUERPO (Torso) - ajustable
    if isPremium and hitboxEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character then
                local torso = plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("HumanoidRootPart")
                if torso then
                    torso.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    torso.Transparency = 0.6
                    torso.CanCollide = false
                    torso.Massless = true
                end
            end
        end
    end

    -- Auto Shoot
    if isPremium and autoShootEnabled then
        local gun = localPlayer.Character and localPlayer.Character:FindFirstChild("Gun")
        if gun then
            pcall(function()
                gun:Activate()
            end)
        end
    end
end)

showLicense()
