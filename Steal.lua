print("✅ STEAL A BRAINROT - Platforms + Invisible | Created by Drip_Dev")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer

local LICENSE_KEY = "LIC-D16335"
local FREE_PREMIUM_5H = "PREMIUM-5H"
local LICENSE_FILE = "BrainrotDrip_License.txt"
local licenseAccepted = false

local speedEnabled = false
local speedValue = 42
local infJumpEnabled = false
local platformJumpEnabled = false
local invisibleEnabled = false
local savedCFrame = nil
local lastPlatform = 0

local guiName = "BrainrotDrip"
pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild(guiName)
    if old then old:Destroy() end
end)

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

local function getChar()
    return localPlayer.Character
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function savePos()
    local root = getRoot()
    if root then
        savedCFrame = root.CFrame
        print("[Brainrot] Position saved")
    end
end

local function loadPos()
    local root = getRoot()
    if root and savedCFrame then
        root.CFrame = savedCFrame
        print("[Brainrot] Returned")
    end
end

-- Plataforma pequeña al saltar
local function spawnJumpPlatform()
    if tick() - lastPlatform < 0.15 then return end
    lastPlatform = tick()
    local root = getRoot()
    if not root then return end

    local pad = Instance.new("Part")
    pad.Name = "DripJumpPad"
    pad.Size = Vector3.new(5, 0.4, 5)
    pad.Anchored = true
    pad.CanCollide = true
    pad.Material = Enum.Material.Neon
    pad.Color = Color3.fromRGB(60, 255, 120)
    pad.Transparency = 0.35
    pad.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.2, root.Position.Z)
    pad.Parent = workspace
    Debris:AddItem(pad, 2.2) -- se borra sola
end

-- Invisible (local + intenta ocultar partes)
local function setInvisible(on)
    local char = getChar()
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            if on then
                obj.LocalTransparencyModifier = 1
                pcall(function() obj.Transparency = 1 end)
            else
                obj.LocalTransparencyModifier = 0
                pcall(function()
                    if obj.Name == "Head" or obj.Name:find("Torso") or obj.Name:find("Arm") or obj.Name:find("Leg") or obj.Name:find("Hand") or obj.Name:find("Foot") then
                        obj.Transparency = 0
                    end
                end)
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = on and 1 or 0
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = not on
        end
    end
    -- ocultar accesorios
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then
                h.LocalTransparencyModifier = on and 1 or 0
                pcall(function() h.Transparency = on and 1 or 0 end)
            end
        end
    end
end

local function getNearbyPrompts(maxDist)
    local root = getRoot()
    if not root then return {} end
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                local d = (part.Position - root.Position).Magnitude
                if d <= (maxDist or 22) then
                    table.insert(list, {prompt = obj, dist = d})
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

local function tryGrab()
    for _, item in ipairs(getNearbyPrompts(22)) do
        pcall(function()
            fireproximityprompt(item.prompt)
        end)
    end
end

local function createToggle(parent, text, y, get, set)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local function refresh()
        local on = get()
        btn.BackgroundColor3 = on and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 55)
        btn.Text = "  " .. text .. "  [" .. (on and "ON" or "OFF") .. "]"
    end
    refresh()
    btn.MouseButton1Click:Connect(function()
        set(not get())
        refresh()
    end)
end

local function loadMenu()
    local sg = Instance.new("ScreenGui")
    sg.Name = guiName
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = game:GetService("CoreGui")

    local logo = Instance.new("TextButton")
    logo.Size = UDim2.new(0, 70, 0, 70)
    logo.Position = UDim2.new(0.04, 0, 0.25, 0)
    logo.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    logo.Text = "🧠"
    logo.TextSize = 28
    logo.Draggable = true
    logo.Parent = sg
    Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 14)
    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(80, 255, 120)
    st.Thickness = 2
    st.Parent = logo

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 460)
    frame.Position = UDim2.new(0.5, -150, 0.5, -230)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    frame.Visible = false
    frame.Active = true
    frame.Draggable = true
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundTransparency = 1
    title.Text = "STEAL A BRAINROT"
    title.TextColor3 = Color3.fromRGB(80, 255, 140)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local credit = Instance.new("TextLabel")
    credit.Size = UDim2.new(1, 0, 0, 16)
    credit.Position = UDim2.new(0, 0, 0, 28)
    credit.BackgroundTransparency = 1
    credit.Text = "Created by Drip_Dev"
    credit.TextColor3 = Color3.fromRGB(120, 180, 255)
    credit.TextSize = 11
    credit.Font = Enum.Font.Gotham
    credit.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -50)
    scroll.Position = UDim2.new(0, 5, 0, 48)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    scroll.Parent = frame

    createToggle(scroll, "Jump Platforms", 5, function() return platformJumpEnabled end, function(v) platformJumpEnabled = v end)
    createToggle(scroll, "Invisible", 45, function() return invisibleEnabled end, function(v)
        invisibleEnabled = v
        setInvisible(v)
    end)
    createToggle(scroll, "Speed", 85, function() return speedEnabled end, function(v) speedEnabled = v end)
    createToggle(scroll, "Infinite Jump", 125, function() return infJumpEnabled end, function(v) infJumpEnabled = v end)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.9, 0, 0, 40)
    saveBtn.Position = UDim2.new(0.05, 0, 0, 175)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
    saveBtn.Text = "📍 SAVE MY BASE"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.TextSize = 14
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.Parent = scroll
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    saveBtn.MouseButton1Click:Connect(savePos)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.9, 0, 0, 40)
    loadBtn.Position = UDim2.new(0.05, 0, 0, 225)
    loadBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 40)
    loadBtn.Text = "🏠 RETURN TO BASE"
    loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadBtn.TextSize = 14
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.Parent = scroll
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 8)
    loadBtn.MouseButton1Click:Connect(loadPos)

    local grabBtn = Instance.new("TextButton")
    grabBtn.Size = UDim2.new(0.9, 0, 0, 40)
    grabBtn.Position = UDim2.new(0.05, 0, 0, 275)
    grabBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 200)
    grabBtn.Text = "🧠 GRAB NEARBY"
    grabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    grabBtn.TextSize = 14
    grabBtn.Font = Enum.Font.GothamBold
    grabBtn.Parent = scroll
    Instance.new("UICorner", grabBtn).CornerRadius = UDim.new(0, 8)
    grabBtn.MouseButton1Click:Connect(tryGrab)

    local tip = Instance.new("TextLabel")
    tip.Size = UDim2.new(0.9, 0, 0, 90)
    tip.Position = UDim2.new(0.05, 0, 0, 330)
    tip.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    tip.Text = "1) Invisible ON\n2) Jump Platforms ON + salta\n3) Entra, GRAB NEARBY\n4) RETURN TO BASE\nPlataformas se borran solas"
    tip.TextColor3 = Color3.fromRGB(200, 200, 200)
    tip.TextSize = 11
    tip.Font = Enum.Font.Gotham
    tip.Parent = scroll
    Instance.new("UICorner", tip).CornerRadius = UDim.new(0, 8)

    logo.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
end

local function showLicense()
    local sg = Instance.new("ScreenGui")
    sg.Name = "LicenseCheck"
    sg.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 250)
    frame.Position = UDim2.new(0.5, -160, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Steal a Brainrot"
    title.TextColor3 = Color3.fromRGB(80, 255, 140)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.85, 0, 0, 40)
    box.Position = UDim2.new(0.075, 0, 0.25, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.PlaceholderText = "Licencia..."
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local act = Instance.new("TextButton")
    act.Size = UDim2.new(0.85, 0, 0, 40)
    act.Position = UDim2.new(0.075, 0, 0.5, 0)
    act.BackgroundColor3 = Color3.fromRGB(220, 40, 80)
    act.Text = "Activar"
    act.TextColor3 = Color3.fromRGB(255, 255, 255)
    act.TextSize = 15
    act.Font = Enum.Font.GothamBold
    act.Parent = frame
    Instance.new("UICorner", act).CornerRadius = UDim.new(0, 8)

    local prem = Instance.new("TextButton")
    prem.Size = UDim2.new(0.85, 0, 0, 40)
    prem.Position = UDim2.new(0.075, 0, 0.72, 0)
    prem.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    prem.Text = "Premium 5h"
    prem.TextColor3 = Color3.fromRGB(255, 255, 255)
    prem.Parent = frame
    Instance.new("UICorner", prem).CornerRadius = UDim.new(0, 8)

    act.MouseButton1Click:Connect(function()
        if box.Text == LICENSE_KEY or box.Text == FREE_PREMIUM_5H then
            licenseAccepted = true
            saveLicense(box.Text == LICENSE_KEY and -1 or 5)
            sg:Destroy()
            loadMenu()
        else
            box.PlaceholderText = "Incorrecta"
            box.Text = ""
        end
    end)
    prem.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/wHc9aBmvh") end)
        box.Text = FREE_PREMIUM_5H
    end)
end

UserInputService.JumpRequest:Connect(function()
    if not licenseAccepted then return end
    if platformJumpEnabled then
        spawnJumpPlatform()
    end
    if infJumpEnabled then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Reaplicar invisible si respawneas / cambia character
localPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if invisibleEnabled then
        setInvisible(true)
    end
end)

RunService.Heartbeat:Connect(function()
    if not licenseAccepted then return end
    local hum = getHum()
    local char = getChar()
    if not hum or not char then return end

    if speedEnabled then
        hum.WalkSpeed = speedValue
    end

    -- mantener invisible
    if invisibleEnabled then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                if obj.LocalTransparencyModifier < 1 then
                    obj.LocalTransparencyModifier = 1
                end
            end
        end
    end
end)

if checkSavedLicense() then
    licenseAccepted = true
    loadMenu()
else
    showLicense()
end
