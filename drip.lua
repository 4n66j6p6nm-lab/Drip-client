print("✅ Drip Client - Rivals + 5h Premium")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local aimbotEnabled = false
local speedEnabled = false
local espEnabled = false
local flyEnabled = false
local licenseAccepted = false
local isPremium = false

local LICENSE_KEY = "LIC-D16335"
local FREE_LICENSE = "FREE-12H"
local FREE_PREMIUM_5H = "PREMIUM-5H"

local guiName = "DripClient"
if game:GetService("CoreGui"):FindFirstChild(guiName) then
    game:GetService("CoreGui")[guiName]:Destroy()
end

local songs = {
    "rbxassetid://116888428582801",
    "rbxassetid://76463442516219",
    "rbxassetid://102605327652034",
    "rbxassetid://78074422495421"
}
local currentSong = 1

local function playNextSong()
    local sound = SoundService:FindFirstChild("DripMusic")
    if sound then sound:Destroy() end

    sound = Instance.new("Sound")
    sound.Name = "DripMusic"
    sound.SoundId = songs[currentSong]
    sound.Volume = 1
    sound.Looped = false
    sound.Parent = SoundService
    sound:Play()

    sound.Ended:Connect(function()
        currentSong = currentSong + 1
        if currentSong > #songs then currentSong = 1 end
        playNextSong()
    end)
end

local function showLoading()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DripLoading"
    screenGui.Parent = game:GetService("CoreGui")

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    bg.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0.35, 0)
    title.BackgroundTransparency = 1
    title.Text = "Drip Client"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.TextSize = 42
    title.Font = Enum.Font.SourceSansBold
    title.Parent = bg

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0.48, 0)
    status.BackgroundTransparency = 1
    status.Text = "Loading..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 20
    status.Parent = bg

    playNextSong()
    task.wait(2.5)
    status.Text = "Loaded!"
    task.wait(0.8)
    screenGui:Destroy()
    showLicense()
end

function showLicense()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LicenseCheck"
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 320)
    frame.Position = UDim2.new(0.5, -170, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Drip Client - Licencia"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.TextSize = 20
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.85, 0, 0, 40)
    box.Position = UDim2.new(0.075, 0, 0.18, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = ""
    box.PlaceholderText = "Ingresa tu licencia..."
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 16
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local activateBtn = Instance.new("TextButton")
    activateBtn.Size = UDim2.new(0.85, 0, 0, 40)
    activateBtn.Position = UDim2.new(0.075, 0, 0.35, 0)
    activateBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
    activateBtn.Text = "Activar Licencia"
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.TextSize = 16
    activateBtn.Font = Enum.Font.SourceSansBold
    activateBtn.Parent = frame
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)

    local freeBtn = Instance.new("TextButton")
    freeBtn.Size = UDim2.new(0.85, 0, 0, 40)
    freeBtn.Position = UDim2.new(0.075, 0, 0.52, 0)
    freeBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 180)
    freeBtn.Text = "Licencia Gratis (12h)"
    freeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    freeBtn.TextSize = 15
    freeBtn.Font = Enum.Font.SourceSansBold
    freeBtn.Parent = frame
    Instance.new("UICorner", freeBtn).CornerRadius = UDim.new(0, 8)

    -- Nuevo botón Premium 5 horas
    local premium5hBtn = Instance.new("TextButton")
    premium5hBtn.Size = UDim2.new(0.85, 0, 0, 40)
    premium5hBtn.Position = UDim2.new(0.075, 0, 0.69, 0)
    premium5hBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    premium5hBtn.Text = "Premium Gratis (5h) - Discord"
    premium5hBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    premium5hBtn.TextSize = 14
    premium5hBtn.Font = Enum.Font.SourceSansBold
    premium5hBtn.Parent = frame
    Instance.new("UICorner", premium5hBtn).CornerRadius = UDim.new(0, 8)

    activateBtn.MouseButton1Click:Connect(function()
        if box.Text == LICENSE_KEY or box.Text == FREE_PREMIUM_5H then
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

    premium5hBtn.MouseButton1Click:Connect(function()
        -- Copia el Discord
        setclipboard("https://discord.gg/wHc9aBmvh")
        box.Text = FREE_PREMIUM_5H
        StarterGui:SetCore("SendNotification", {
            Title = "Drip Client",
            Text = "Discord copiado! Usa la licencia PREMIUM-5H",
            Duration = 5
        })
    end)
end

function loadMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = guiName
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local logoBtn = Instance.new("TextButton")
    logoBtn.Size = UDim2.new(0, 140, 0, 50)
    logoBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    logoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
    logoBtn.Text = "Drip Client"
    logoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoBtn.TextSize = 18
    logoBtn.Font = Enum.Font.SourceSansBold
    logoBtn.Draggable = true
    logoBtn.Parent = screenGui
    Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(0, 10)

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 280, 0, isPremium and 340 or 280)
    menu.Position = UDim2.new(0.5, -140, 0.2, 0)
    menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    menu.Visible = false
    menu.Active = true
    menu.Draggable = true
    menu.Parent = screenGui
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Drip Client"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.TextSize = 22
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

    createToggle("Aimbot", 50, aimbotEnabled, function(s) aimbotEnabled = s end)
    createToggle("Speed", 105, speedEnabled, function(s) speedEnabled = s end)
    createToggle("ESP", 160, espEnabled, function(s) espEnabled = s end)

    if isPremium then
        createToggle("Fly (Joystick)", 215, flyEnabled, function(s) flyEnabled = s end)
    end

    logoBtn.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)
end

local bodyVelocity = nil

RunService.RenderStepped:Connect(function()
    if not licenseAccepted then return end

    if speedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = isPremium and 55 or 35
    end

    if aimbotEnabled then
        local closest = nil
        local dist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") then
                if plr.Character.Humanoid.Health > 0 then
                    if plr.Team ~= localPlayer.Team or not plr.Team then
                        local d = (camera.CFrame.Position - plr.Character.Head.Position).Magnitude
                        if d < dist then
                            dist = d
                            closest = plr.Character.Head
                        end
                    end
                end
            end
        end
        if closest then
            camera.CFrame = CFrame.new(camera.CFrame.Position, closest.Position)
        end
    end

    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local hl = plr.Character:FindFirstChildOfClass("Highlight")
                if hl then hl:Destroy() end
                if plr.Team ~= localPlayer.Team or not plr.Team then
                    hl = Instance.new("Highlight")
                    hl.Parent = plr.Character
                    hl.FillColor = Color3.fromRGB(0, 200, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                end
            end
        end
    end

    if isPremium and flyEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = localPlayer.Character.HumanoidRootPart
        local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
            bodyVelocity.Parent = root
        end
        if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
            bodyVelocity.Velocity = humanoid.MoveDirection * 90 + Vector3.new(0, 15, 0)
        else
            bodyVelocity.Velocity = Vector3.new(0, 5, 0)
        end
    else
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end)

showLoading()
