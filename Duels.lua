print("✅ Asesinos VS Sheriffs - Tracers Top + Skeleton + Spin")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local speedEnabled = false
local espEnabled = false
local hitboxEnabled = false
local hitboxSize = 8
local tpEnemyEnabled = false
local infiniteJumpEnabled = false
local noClipEnabled = false
local fovEnabled = false
local brightnessEnabled = false
local aimbotEnabled = false
local forceLookEnabled = false
local showFovCircle = false
local espLineEnabled = false
local espBoxEnabled = false
local espDistanceEnabled = false
local nearbyCountEnabled = false
local skeletonEnabled = false
local spinEnabled = false
local spinSpeed = 15
local lineColor = Color3.fromRGB(255, 40, 40)
local boxColor = Color3.fromRGB(0, 200, 255)
local skeletonColor = Color3.fromRGB(255, 255, 255)
local aimFov = 150
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

local mainScreenGui, logoBtn, mainFrame, fovCircle, nearbyLabel, drawingFolder
local lighting = game:GetService("Lighting")
local originalBrightness = lighting.Brightness
local originalFOV = camera and camera.FieldOfView or 70
local espObjects = {}

local SKELETON_BONES = {
    {"Head", "UpperTorso"},
    {"Head", "Torso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"RightLowerLeg", "RightFoot"},
    -- R6 fallback
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

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
    task.spawn(function()
        while parent and parent.Parent do
            if parent.Visible and not streamMode then
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
                tween.Completed:Connect(function() p:Destroy() end)
            end
            task.wait(0.22)
        end
    end)
end

local function createToggle(parent, name, y, default, callback)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.9, 0, 0, 34)
    toggle.Position = UDim2.new(0.05, 0, 0, y)
    toggle.BackgroundColor3 = default and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 55)
    toggle.BackgroundTransparency = 0.15
    toggle.Text = "  " .. name .. "  [" .. (default and "ON" or "OFF") .. "]"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 12
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
end

local function createColorBox(parent, label, y, current, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.45, 0, 0, 30)
    lbl.Position = UDim2.new(0.05, 0, 0, y)
    lbl.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    lbl.BackgroundTransparency = 0.15
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.ZIndex = 12
    lbl.Parent = parent
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.4, 0, 0, 30)
    box.Position = UDim2.new(0.52, 0, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    box.Text = string.format("%d,%d,%d", current.R * 255, current.G * 255, current.B * 255)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 11
    box.Font = Enum.Font.Gotham
    box.ZIndex = 12
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    box.FocusLost:Connect(function()
        local r, g, b = box.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
        if r and g and b then
            local c = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
            callback(c)
        end
    end)
end

function loadMainMenu()
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = guiName
    mainScreenGui.ResetOnSpawn = false
    mainScreenGui.IgnoreGuiInset = true
    mainScreenGui.Parent = game:GetService("CoreGui")

    fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, 180, 0, 180)
    fovCircle.Position = UDim2.new(0.5, -90, 0.5, -90)
    fovCircle.BackgroundTransparency = 1
    fovCircle.Visible = false
    fovCircle.Parent = mainScreenGui
    local circleStroke = Instance.new("UIStroke")
    circleStroke.Color = Color3.fromRGB(0, 255, 120)
    circleStroke.Thickness = 2
    circleStroke.Parent = fovCircle
    Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

    nearbyLabel = Instance.new("TextLabel")
    nearbyLabel.Size = UDim2.new(0, 160, 0, 28)
    nearbyLabel.Position = UDim2.new(0.5, -80, 0.08, 0)
    nearbyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    nearbyLabel.BackgroundTransparency = 0.4
    nearbyLabel.Text = "Enemies: 0"
    nearbyLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    nearbyLabel.TextSize = 16
    nearbyLabel.Font = Enum.Font.GothamBold
    nearbyLabel.Visible = false
    nearbyLabel.Parent = mainScreenGui
    Instance.new("UICorner", nearbyLabel).CornerRadius = UDim.new(0, 8)

    drawingFolder = Instance.new("Folder")
    drawingFolder.Name = "ESPDrawings"
    drawingFolder.Parent = mainScreenGui

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
    mainFrame.Size = UDim2.new(0, 410, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -205, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    mainFrame.Visible = false
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainScreenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local bgImage = Instance.new("ImageLabel")
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = ICON_ID
    bgImage.ImageTransparency = 0.55
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 1
    bgImage.Parent = mainFrame
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 12)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 115, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
    sidebar.BackgroundTransparency = 0.12
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 5
    sidebar.Parent = mainFrame
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

    local sideFix = Instance.new("Frame")
    sideFix.Size = UDim2.new(0, 18, 1, 0)
    sideFix.Position = UDim2.new(1, -18, 0, 0)
    sideFix.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
    sideFix.BackgroundTransparency = 0.12
    sideFix.BorderSizePixel = 0
    sideFix.ZIndex = 5
    sideFix.Parent = sidebar

    local sideTitle = Instance.new("TextLabel")
    sideTitle.Size = UDim2.new(1, -6, 0, 22)
    sideTitle.Position = UDim2.new(0, 4, 0, 8)
    sideTitle.BackgroundTransparency = 1
    sideTitle.Text = "DUELS"
    sideTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    sideTitle.TextSize = 15
    sideTitle.Font = Enum.Font.GothamBold
    sideTitle.ZIndex = 6
    sideTitle.Parent = sidebar

    local creator = Instance.new("TextLabel")
    creator.Size = UDim2.new(1, -6, 0, 16)
    creator.Position = UDim2.new(0, 4, 0, 28)
    creator.BackgroundTransparency = 1
    creator.Text = "Created by Drip_Dev"
    creator.TextColor3 = Color3.fromRGB(120, 200, 255)
    creator.TextSize = 10
    creator.Font = Enum.Font.Gotham
    creator.ZIndex = 6
    creator.Parent = sidebar

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -125, 1, -16)
    content.Position = UDim2.new(0, 120, 0, 8)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 560)
    content.ZIndex = 10
    content.Parent = mainFrame

    local function clearContent()
        for _, c in ipairs(content:GetChildren()) do c:Destroy() end
    end

    local function showTab(tabName)
        clearContent()
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 24)
        header.BackgroundTransparency = 1
        header.Text = tabName
        header.TextColor3 = Color3.fromRGB(255, 255, 255)
        header.TextSize = 16
        header.Font = Enum.Font.GothamBold
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.ZIndex = 12
        header.Parent = content

        if tabName == "Aimbot" then
            if isPremium then
                createToggle(content, "Aimbot", 30, aimbotEnabled, function(s) aimbotEnabled = s end)
                createToggle(content, "Force Look", 68, forceLookEnabled, function(s) forceLookEnabled = s end)
                createToggle(content, "Show FOV Circle", 106, showFovCircle, function(s)
                    showFovCircle = s
                    if fovCircle then fovCircle.Visible = s and not streamMode end
                end)
                createToggle(content, "Hitbox", 144, hitboxEnabled, function(s) hitboxEnabled = s end)
                createToggle(content, "TP al Enemigo", 182, tpEnemyEnabled, function(s) tpEnemyEnabled = s end)

                local sizeLabel = Instance.new("TextLabel")
                sizeLabel.Size = UDim2.new(0.55, 0, 0, 30)
                sizeLabel.Position = UDim2.new(0.05, 0, 0, 225)
                sizeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                sizeLabel.BackgroundTransparency = 0.15
                sizeLabel.Text = "Hitbox Size"
                sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                sizeLabel.TextSize = 11
                sizeLabel.Font = Enum.Font.Gotham
                sizeLabel.ZIndex = 12
                sizeLabel.Parent = content
                Instance.new("UICorner", sizeLabel).CornerRadius = UDim.new(0, 6)

                local sizeBox = Instance.new("TextBox")
                sizeBox.Size = UDim2.new(0.3, 0, 0, 30)
                sizeBox.Position = UDim2.new(0.62, 0, 0, 225)
                sizeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                sizeBox.Text = tostring(hitboxSize)
                sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                sizeBox.TextSize = 13
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
                msg.Position = UDim2.new(0, 0, 0, 40)
                msg.BackgroundTransparency = 1
                msg.Text = "Premium requerido"
                msg.TextColor3 = Color3.fromRGB(255, 100, 100)
                msg.TextSize = 15
                msg.Font = Enum.Font.Gotham
                msg.ZIndex = 12
                msg.Parent = content
            end

        elseif tabName == "Visuals" then
            createToggle(content, "Enemy ESP", 30, espEnabled, function(s) espEnabled = s end)
            createToggle(content, "Line (Top)", 68, espLineEnabled, function(s) espLineEnabled = s end)
            createToggle(content, "Box", 106, espBoxEnabled, function(s) espBoxEnabled = s end)
            createToggle(content, "Skeleton", 144, skeletonEnabled, function(s) skeletonEnabled = s end)
            createToggle(content, "Distance", 182, espDistanceEnabled, function(s) espDistanceEnabled = s end)
            createToggle(content, "Nearby Count", 220, nearbyCountEnabled, function(s)
                nearbyCountEnabled = s
                if nearbyLabel then nearbyLabel.Visible = s and not streamMode end
            end)
            createToggle(content, "FOV Alto", 258, fovEnabled, function(s)
                fovEnabled = s
                if camera then camera.FieldOfView = s and 100 or originalFOV end
            end)
            createToggle(content, "Brillo", 296, brightnessEnabled, function(s)
                brightnessEnabled = s
                lighting.Brightness = s and 4 or originalBrightness
            end)

            createColorBox(content, "Color Lineas", 340, lineColor, function(c) lineColor = c end)
            createColorBox(content, "Color Box", 378, boxColor, function(c) boxColor = c end)
            createColorBox(content, "Color Skeleton", 416, skeletonColor, function(c) skeletonColor = c end)

        elseif tabName == "Player" then
            createToggle(content, "Speed", 30, speedEnabled, function(s) speedEnabled = s end)
            if isPremium then
                createToggle(content, "Infinite Jump", 68, infiniteJumpEnabled, function(s) infiniteJumpEnabled = s end)
                createToggle(content, "NoClip", 106, noClipEnabled, function(s) noClipEnabled = s end)
                createToggle(content, "Spin", 144, spinEnabled, function(s) spinEnabled = s end)

                local spinLabel = Instance.new("TextLabel")
                spinLabel.Size = UDim2.new(0.55, 0, 0, 30)
                spinLabel.Position = UDim2.new(0.05, 0, 0, 190)
                spinLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                spinLabel.BackgroundTransparency = 0.15
                spinLabel.Text = "Spin Speed"
                spinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                spinLabel.TextSize = 11
                spinLabel.Font = Enum.Font.Gotham
                spinLabel.ZIndex = 12
                spinLabel.Parent = content
                Instance.new("UICorner", spinLabel).CornerRadius = UDim.new(0, 6)

                local spinBox = Instance.new("TextBox")
                spinBox.Size = UDim2.new(0.3, 0, 0, 30)
                spinBox.Position = UDim2.new(0.62, 0, 0, 190)
                spinBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                spinBox.Text = tostring(spinSpeed)
                spinBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                spinBox.TextSize = 13
                spinBox.Font = Enum.Font.GothamBold
                spinBox.ZIndex = 12
                spinBox.Parent = content
                Instance.new("UICorner", spinBox).CornerRadius = UDim.new(0, 6)
                spinBox.FocusLost:Connect(function()
                    local n = tonumber(spinBox.Text)
                    if n and n > 0 then spinSpeed = n end
                end)
            end

        elseif tabName == "Settings" then
            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(0.95, 0, 0, 140)
            info.Position = UDim2.new(0.025, 0, 0, 35)
            info.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            info.BackgroundTransparency = 0.15
            info.Text = "Stream Mode:\n4 dedos = ocultar/mostrar\n\nColores: R,G,B (ej: 255,0,0)\n\nCreated by Drip_Dev"
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
        {name = "Aimbot", y = 55},
        {name = "Visuals", y = 100},
        {name = "Player", y = 145},
        {name = "Settings", y = 190},
    }

    local tabButtons = {}
    for _, t in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 34)
        btn.Position = UDim2.new(0.05, 0, 0, t.y)
        btn.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
        btn.Text = "  " .. t.name
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.TextSize = 13
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

    tabButtons["Aimbot"].BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    tabButtons["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)
    showTab("Aimbot")
    createFallingParticles(mainFrame)

    logoBtn.MouseButton1Click:Connect(function()
        if not streamMode then mainFrame.Visible = not mainFrame.Visible end
    end)
end

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
            if fovCircle then fovCircle.Visible = false end
            if nearbyLabel then nearbyLabel.Visible = false end
            if drawingFolder then drawingFolder:ClearAllChildren() end
            espObjects = {}
        else
            if logoBtn then logoBtn.Visible = true end
            if fovCircle then fovCircle.Visible = showFovCircle end
            if nearbyLabel then nearbyLabel.Visible = nearbyCountEnabled end
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

UserInputService.JumpRequest:Connect(function()
    if isPremium and infiniteJumpEnabled and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local function getClosestEnemy()
    local closest, closestDist = nil, aimFov
    if not camera then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local dist = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

local function makeLine(name)
    local line = Instance.new("Frame")
    line.Name = name
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.ZIndex = 50
    line.Parent = drawingFolder
    return line
end

local lastTP = 0

RunService.RenderStepped:Connect(function()
    if not licenseAccepted then return end
    camera = workspace.CurrentCamera
    local char = localPlayer.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    local myHum = char:FindFirstChild("Humanoid")
    if not myRoot or not myHum or myHum.Health <= 0 then return end

    if speedEnabled then
        myHum.WalkSpeed = isPremium and 36 or 24
    end

    if isPremium and noClipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Spin
    if isPremium and spinEnabled and myRoot then
        myRoot.CFrame = myRoot.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
    end

    if isPremium and (aimbotEnabled or forceLookEnabled) and camera then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    if fovCircle then fovCircle.Visible = showFovCircle and not streamMode end

    local nearCount = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                if (myRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 80 then
                    nearCount = nearCount + 1
                end
            end
        end
    end
    if nearbyLabel then
        nearbyLabel.Visible = nearbyCountEnabled and not streamMode
        nearbyLabel.Text = "Enemies: " .. nearCount
    end

    if streamMode then
        if drawingFolder then drawingFolder:ClearAllChildren() end
        espObjects = {}
    else
        local topPoint = Vector2.new(camera.ViewportSize.X / 2, 8)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character then
                local hum = plr.Character:FindFirstChild("Humanoid")
                local head = plr.Character:FindFirstChild("Head")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and head and root and hum.Health > 0 and camera then
                    if espEnabled and not plr.Character:FindFirstChildOfClass("Highlight") then
                        local hl = Instance.new("Highlight")
                        hl.Parent = plr.Character
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.4
                    end

                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                    local key = tostring(plr.UserId)

                    -- Line from TOP
                    if espLineEnabled and onScreen then
                        local line = espObjects["line_" .. key]
                        if not line or not line.Parent then
                            line = makeLine("line_" .. key)
                            espObjects["line_" .. key] = line
                        end
                        local target = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (topPoint - target).Magnitude
                        local mid = (topPoint + target) / 2
                        line.BackgroundColor3 = lineColor
                        line.Size = UDim2.new(0, dist, 0, 2)
                        line.Position = UDim2.new(0, mid.X, 0, mid.Y)
                        line.Rotation = math.deg(math.atan2(target.Y - topPoint.Y, target.X - topPoint.X))
                        line.Visible = true
                    elseif espObjects["line_" .. key] then
                        espObjects["line_" .. key].Visible = false
                    end

                    -- Box
                    if espBoxEnabled and onScreen then
                        local box = espObjects["box_" .. key]
                        if not box or not box.Parent then
                            box = Instance.new("Frame")
                            box.BackgroundTransparency = 1
                            box.ZIndex = 50
                            box.Parent = drawingFolder
                            local st = Instance.new("UIStroke")
                            st.Name = "Stroke"
                            st.Thickness = 2
                            st.Parent = box
                            espObjects["box_" .. key] = box
                        end
                        local st = box:FindFirstChild("Stroke")
                        if st then st.Color = boxColor end
                        local size = 40
                        box.Size = UDim2.new(0, size, 0, size * 1.6)
                        box.Position = UDim2.new(0, screenPos.X - size / 2, 0, screenPos.Y - size * 0.3)
                        box.Visible = true
                    elseif espObjects["box_" .. key] then
                        espObjects["box_" .. key].Visible = false
                    end

                    -- Skeleton
                    if skeletonEnabled then
                        for bi, bone in ipairs(SKELETON_BONES) do
                            local p0 = plr.Character:FindFirstChild(bone[1])
                            local p1 = plr.Character:FindFirstChild(bone[2])
                            local skKey = "sk_" .. key .. "_" .. bi
                            if p0 and p1 then
                                local s0, o0 = camera:WorldToViewportPoint(p0.Position)
                                local s1, o1 = camera:WorldToViewportPoint(p1.Position)
                                if o0 or o1 then
                                    local line = espObjects[skKey]
                                    if not line or not line.Parent then
                                        line = makeLine(skKey)
                                        espObjects[skKey] = line
                                    end
                                    local a = Vector2.new(s0.X, s0.Y)
                                    local b = Vector2.new(s1.X, s1.Y)
                                    local dist = (a - b).Magnitude
                                    local mid = (a + b) / 2
                                    line.BackgroundColor3 = skeletonColor
                                    line.Size = UDim2.new(0, dist, 0, 1.5)
                                    line.Position = UDim2.new(0, mid.X, 0, mid.Y)
                                    line.Rotation = math.deg(math.atan2(b.Y - a.Y, b.X - a.X))
                                    line.Visible = true
                                elseif espObjects[skKey] then
                                    espObjects[skKey].Visible = false
                                end
                            end
                        end
                    end

                    -- Distance
                    if espDistanceEnabled and onScreen then
                        local distLabel = espObjects["dist_" .. key]
                        if not distLabel or not distLabel.Parent then
                            distLabel = Instance.new("TextLabel")
                            distLabel.Size = UDim2.new(0, 60, 0, 18)
                            distLabel.BackgroundTransparency = 1
                            distLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                            distLabel.TextSize = 12
                            distLabel.Font = Enum.Font.GothamBold
                            distLabel.ZIndex = 51
                            distLabel.Parent = drawingFolder
                            espObjects["dist_" .. key] = distLabel
                        end
                        local d = math.floor((myRoot.Position - root.Position).Magnitude)
                        distLabel.Text = d .. "m"
                        distLabel.Position = UDim2.new(0, screenPos.X - 30, 0, screenPos.Y + 25)
                        distLabel.Visible = true
                    elseif espObjects["dist_" .. key] then
                        espObjects["dist_" .. key].Visible = false
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
