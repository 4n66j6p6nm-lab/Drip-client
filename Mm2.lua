print("✅ Murder Mystery 2 - Clean Version")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer

local speedEnabled = false
local espEnabled = true
local coinFarmEnabled = false
local licenseAccepted = false
local isPremium = false

local LICENSE_KEY = "LIC-D16335"
local FREE_PREMIUM_5H = "PREMIUM-5H"

local guiName = "MM2God"
if game:GetService("CoreGui"):FindFirstChild(guiName) then
    game:GetService("CoreGui")[guiName]:Destroy()
end

-- ==================== LOADING SCREEN ====================
local function showLoading()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2Loading"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.Parent = game:GetService("CoreGui")

    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    bg.Image = "rbxassetid://134384906566930"
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
    title.Text = "Murder Mystery 2"
    title.TextColor3 = Color3.fromRGB(255, 80, 120)
    title.TextSize = 36
    title.Font = Enum.Font.SourceSansBold
    title.Parent = bg

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0.52, 0)
    status.BackgroundTransparency = 1
    status.Text = "Loading..."
    status.TextColor3 = Color3.fromRGB(220, 220, 220)
    status.TextSize = 20
    status.Parent = bg

    task.wait(2.5)
    status.Text = "Loaded!"
    task.wait(0.8)
    screenGui:Destroy()
    showLicense()
end

-- ==================== LICENSE ====================
function showLicense()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LicenseCheck"
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 300)
    frame.Position = UDim2.new(0.5, -170, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "Murder Mystery 2"
    title.TextColor3 = Color3.fromRGB(255, 80, 120)
    title.TextSize = 20
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.85, 0, 0, 42)
    box.Position = UDim2.new(0.075, 0, 0.22, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = ""
    box.PlaceholderText = "Ingresa tu licencia..."
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 16
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local activateBtn = Instance.new("TextButton")
    activateBtn.Size = UDim2.new(0.85, 0, 0, 42)
    activateBtn.Position = UDim2.new(0.075, 0, 0.42, 0)
    activateBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 80)
    activateBtn.Text = "Activar Licencia"
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.TextSize = 16
    activateBtn.Font = Enum.Font.SourceSansBold
    activateBtn.Parent = frame
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)

    local premium5hBtn = Instance.new("TextButton")
    premium5hBtn.Size = UDim2.new(0.85, 0, 0, 42)
    premium5hBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
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
                Title = "MM2",
                Text = "Discord copiado! Usa PREMIUM-5H",
                Duration = 5
            })
        end)
    end)
end

-- ==================== MAIN MENU ====================
function loadMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = guiName
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    -- Icono circular con imagen
    local logoBtn = Instance.new("ImageButton")
    logoBtn.Size = UDim2.new(0, 80, 0, 80)
    logoBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    logoBtn.BackgroundTransparency = 1
    logoBtn.Image = "rbxassetid://134384906566930"
    logoBtn.ScaleType = Enum.ScaleType.Crop
    logoBtn.Draggable = true
    logoBtn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = logoBtn

    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "MM2"
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.TextSize = 18
    logoText.Font = Enum.Font.SourceSansBold
    logoText.Parent = logoBtn

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 290, 0, 280)
    menu.Position = UDim2.new(0.5, -145, 0.22, 0)
    menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    menu.Visible = false
    menu.Active = true
    menu.Draggable = true
    menu.Parent = screenGui
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 12)

    -- Fondo del menú
    local bgImage = Instance.new("ImageLabel")
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = "rbxassetid://134384906566930"
    bgImage.ImageTransparency = 0.55
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.Parent = menu
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Murder Mystery 2"
    title.TextColor3 = Color3.fromRGB(255, 80, 120)
    title.TextSize = 20
    title.Font = Enum.Font.SourceSansBold
    title.Parent = menu

    local function createToggle(name, y, default, callback)
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.9, 0, 0, 50)
        toggle.Position = UDim2.new(0.05, 0, 0, y)
        toggle.BackgroundColor3 = default and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(220, 40, 80)
        toggle.BackgroundTransparency = 0.1
        toggle.Text = name .. ": " .. (default and "ON" or "OFF")
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 16
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

    createToggle("ESP Roles", 55, espEnabled, function(s) espEnabled = s end)
    createToggle("Speed", 115, speedEnabled, function(s) speedEnabled = s end)
    createToggle("Coin Farm", 175, coinFarmEnabled, function(s) coinFarmEnabled = s end)

    logoBtn.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)
end

-- Features
local bodyVelocity = nil

RunService.RenderStepped:Connect(function()
    if not licenseAccepted then return end

    -- Speed
    if speedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = 26
    end

    -- ESP Roles
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local hl = plr.Character:FindFirstChildOfClass("Highlight")
                if hl then hl:Destroy() end

                local isMurderer = plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife")
                local isSheriff = plr.Character:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Gun")

                hl = Instance.new("Highlight")
                hl.Parent = plr.Character
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.4

                if isMurderer then
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                elseif isSheriff then
                    hl.FillColor = Color3.fromRGB(0, 120, 255)
                else
                    hl.FillColor = Color3.fromRGB(0, 255, 100)
                end
            end
        end
    end

    -- Coin Farm suave
    if coinFarmEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = localPlayer.Character.HumanoidRootPart

        for _, part in ipairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        local closestCoin = nil
        local closestDist = math.huge

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:find("coin") or name:find("cash") or name:find("money") then
                    local dist = (root.Position - obj.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestCoin = obj
                    end
                end
            end
        end

        if closestCoin then
            if not bodyVelocity then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                bodyVelocity.Parent = root
            end
            local direction = (closestCoin.Position - root.Position).Unit
            bodyVelocity.Velocity = direction * 75 + Vector3.new(0, 6, 0)
        end
    else
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end)

showLoading()
