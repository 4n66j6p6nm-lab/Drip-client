print("✅ KAISENX DUELS | ESP fixed | Pred 0.19 | Root | created by KAISEN")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
print(isMobile and "📱 Mobile detected" or "💻 PC detected")

local DISCORD_LINK = "https://discord.gg/7Akknx2Gk"
local TIKTOK_USER = "@kaisen_x2"
local DISCORD_IMG = "rbxassetid://16584754883"
local TIKTOK_IMG = "rbxassetid://140658929749855"

-- AIM
local silentOn = true
local showFov = false
local aimPartName = "Root"
local silentFov = 305
local maxDist = 500
local MATCH_DIST = 280
local filterTeams = true
local PREDICT = 0.19

-- VISUALS
local lineOn, boxOn, skelOn, hpOn, nameOn = false, false, false, false, false
local espColor = Color3.fromRGB(255, 140, 40)

-- PLAYER
local speedOn, jumpOn, noclipOn = false, false, false
local walkSpeed = 28

-- ANIM
local animIdle, animWalk, animRun, animJump, animFall = 0, 0, 0, 0, 0
local selectedFullPack = "Ninja"
local animKeeperConn = nil
local animAppliedOnce = false

local PACKS = {
    Ninja = { idle = 656117400, walk = 656118341, run = 656118852, jump = 656117878, fall = 656115606 },
    Zombie = { idle = 616158929, walk = 616161140, run = 616163682, jump = 616161826, fall = 616157476 },
    OldSchool = { idle = 5319828216, walk = 5319839762, run = 5319844329, jump = 5319841935, fall = 5319841935 },
}
local IDLE_OPTS = { Default = 0, Ninja = 656117400, Zombie = 616158929, OldSchool = 5319828216 }
local WALK_OPTS = { Default = 0, Ninja = 656118341, Zombie = 616161140, OldSchool = 5319839762 }
local RUN_OPTS  = { Default = 0, Ninja = 656118852, Zombie = 616163682, OldSchool = 5319844329 }
local JUMP_OPTS = { Default = 0, Ninja = 656117878, Zombie = 616161826, OldSchool = 5319841935 }

local SKELETON_BONES = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local cachedPos, cachedPart, cachedRoot = nil, nil, nil
local espObjs, fovCircle = {}, nil
local originalWalkSpeed = nil
local originalCollision = {}

local function safeNotify(WindUI, title, content)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = title, Content = content, Duration = 3 })
        end
    end)
end

local function showError(msg)
    warn("[KAISENX]", msg)
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "KXError"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function() sg.Parent = CoreGui end)
        if not sg.Parent then sg.Parent = localPlayer:WaitForChild("PlayerGui") end
        local f = Instance.new("Frame")
        f.Size = UDim2.fromOffset(320, 90)
        f.Position = UDim2.new(0.5, -160, 0.15, 0)
        f.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
        f.Parent = sg
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.fromScale(1, 1)
        tl.BackgroundTransparency = 1
        tl.TextColor3 = Color3.fromRGB(255, 120, 120)
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 14
        tl.TextWrapped = true
        tl.Text = "KAISENX ERROR:\n" .. tostring(msg)
        tl.Parent = f
        task.delay(8, function() pcall(function() sg:Destroy() end) end)
    end)
end

local function getChar() return localPlayer.Character end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function setSpeed(enabled, speed)
    local hum = getHum()
    if not hum then return end
    if enabled then
        originalWalkSpeed = originalWalkSpeed or hum.WalkSpeed
        hum.WalkSpeed = speed
    elseif originalWalkSpeed then
        hum.WalkSpeed = originalWalkSpeed
        originalWalkSpeed = nil
    end
end

local function setNoclip(enabled)
    local char = getChar()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if enabled then
                if originalCollision[part] == nil then originalCollision[part] = part.CanCollide end
                part.CanCollide = false
            elseif originalCollision[part] ~= nil then
                part.CanCollide = originalCollision[part]
                originalCollision[part] = nil
            end
        end
    end
end

local function inMatch(plr)
    local my = getRoot()
    local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not my or not r then return false end
    return (r.Position - my.Position).Magnitude <= MATCH_DIST
end

local function isEnemy(plr)
    if not plr or plr == localPlayer or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not inMatch(plr) then return false end
    if filterTeams then
        if localPlayer.Team ~= nil and plr.Team ~= nil and localPlayer.Team == plr.Team then return false end
        local myRole = localPlayer:GetAttribute("Role") or localPlayer:GetAttribute("Team")
        local targetRole = plr:GetAttribute("Role") or plr:GetAttribute("Team")
        if myRole and targetRole and myRole == targetRole then return false end
    end
    return true
end

local function pickPart(char)
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local root = char:FindFirstChild("HumanoidRootPart")
    if aimPartName == "Head" then return head or torso or root
    elseif aimPartName == "Torso" then return torso or head or root
    else return root or torso or head end
end

local function predictPos(part, root)
    if not part then return nil end
    local pos = part.Position
    local vel = Vector3.zero
    if root and root:IsA("BasePart") then
        pcall(function() vel = root.AssemblyLinearVelocity end)
    else
        pcall(function() vel = part.AssemblyLinearVelocity end)
    end
    return pos + vel * PREDICT
end

local function updateTarget()
    if not silentOn then
        cachedPos, cachedPart, cachedRoot = nil, nil, nil
        return
    end
    if not camera then return end

    local center = camera.ViewportSize * 0.5
    local origin = camera.CFrame.Position
    local look = camera.CFrame.LookVector
    local maxAng = math.rad(silentFov) * 0.5
    local fovPx = math.tan(math.rad(silentFov) * 0.5) * (camera.ViewportSize.Y * 0.5)
    local best, bestScore = nil, -1e9

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local char = plr.Character
            local part = pickPart(char)
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if part then
                local pos = predictPos(part, root) or part.Position
                local dist = (pos - origin).Magnitude
                if dist <= maxDist then
                    local dir = pos - origin
                    if dir.Magnitude > 0.03 then
                        local ang = math.acos(math.clamp(look:Dot(dir.Unit), -1, 1))
                        local sp, on = camera:WorldToViewportPoint(pos)
                        local cross = 9999
                        if on and sp.Z > 0 then
                            cross = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        end
                        if (ang <= maxAng * 1.15) or (cross <= fovPx * 1.6) then
                            local score = 50000 - (cross * 22) - (dist * 0.03)
                            if on and sp.Z > 0 then score = score + 8000 end
                            if part.Name == "HumanoidRootPart" then score = score + 5500 end
                            if part.Name == "Head" then score = score + 4500 end
                            if dist < 60 then score = score + 4000 end
                            if dist < 30 then score = score + 3000 end
                            if score > bestScore then
                                bestScore = score
                                best = { pos = pos, part = part, root = root }
                            end
                        end
                    end
                end
            end
        end
    end

    if best then
        cachedPos, cachedPart, cachedRoot = best.pos, best.part, best.root
    else
        cachedPos, cachedPart, cachedRoot = nil, nil, nil
    end
end

local function setupSilentMouse()
    if type(getrawmetatable) ~= "function" then return false end
    local ok, mt = pcall(function() return getrawmetatable(mouse) end)
    if not ok or not mt then return false end
    return pcall(function()
        if setreadonly then setreadonly(mt, false) end
        local old = mt.__index
        local wrapper = function(self, key)
            if silentOn and cachedPos and cachedPart then
                if key == "Hit" then return CFrame.new(cachedPos) end
                if key == "Target" then return cachedPart end
                if key == "UnitRay" then
                    local o = camera.CFrame.Position
                    return Ray.new(o, (cachedPos - o).Unit * 5000)
                end
            end
            if type(old) == "function" then return old(self, key) end
            return old[key]
        end
        if newcclosure then mt.__index = newcclosure(wrapper) else mt.__index = wrapper end
        if setreadonly then setreadonly(mt, true) end
    end)
end

local function setupRemoteHook()
    if type(hookmetamethod) ~= "function" and type(getnamecallmethod) ~= "function" then
        return false
    end
    return pcall(function()
        local old
        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = { ... }
            if silentOn and cachedPos and method == "FireServer" then
                local name = ""
                pcall(function() name = self.Name end)
                if name == "showBeam" then
                    local a1, a2 = args[1], args[2]
                    if typeof(a1) == "Vector3" and typeof(a2) == "Vector3" then
                        args[2] = cachedPos
                        return old(self, unpack(args))
                    elseif typeof(a1) == "Vector3" and typeof(a2) ~= "Vector3" then
                        args[1] = cachedPos
                        return old(self, unpack(args))
                    end
                end
            end
            return old(self, ...)
        end))
    end)
end

local function assetUrl(id)
    return "http://www.roblox.com/asset/?id=" .. tostring(id)
end

local function softWriteFolder(folder, id)
    if not folder or not id or id <= 0 then return false end
    local want = tostring(id)
    for _, d in ipairs(folder:GetDescendants()) do
        if d:IsA("Animation") and not string.find(d.AnimationId, want, 1, true) then
            d.AnimationId = assetUrl(id)
        end
    end
    for _, ch in ipairs(folder:GetChildren()) do
        if ch:IsA("Animation") and not string.find(ch.AnimationId, want, 1, true) then
            ch.AnimationId = assetUrl(id)
        end
    end
    return true
end

local function softApplyAnims(char)
    if not char then return false end
    local animate = char:FindFirstChild("Animate")
    if not animate then return false end
    local map = {
        idle = animIdle, walk = animWalk, run = animRun,
        jump = animJump, fall = animFall, climb = animJump,
        sit = animIdle, swim = animWalk, swimidle = animIdle,
    }
    for name, id in pairs(map) do
        if id and id > 0 then
            local folder = animate:FindFirstChild(name)
            if folder then softWriteFolder(folder, id) end
        end
    end
    return true
end

local function firstApplyAnims(char)
    if not char then return false end
    softApplyAnims(char)
    local animate = char:FindFirstChild("Animate")
    if animate and not animAppliedOnce then
        pcall(function() animate.Disabled = true end)
        task.delay(0.1, function()
            pcall(function()
                if animate and animate.Parent then animate.Disabled = false end
            end)
        end)
        animAppliedOnce = true
    end
    return true
end

local function hasCustomAnims()
    return (animIdle > 0) or (animWalk > 0) or (animRun > 0) or (animJump > 0) or (animFall > 0)
end

local function startAnimKeeper()
    if animKeeperConn then animKeeperConn:Disconnect() animKeeperConn = nil end
    local acc = 0
    animKeeperConn = RunService.Heartbeat:Connect(function(dt)
        if not hasCustomAnims() then return end
        acc += dt
        if acc < 2 then return end
        acc = 0
        local char = getChar()
        if char then softApplyAnims(char) end
    end)
end

local function applyCatalogAnims()
    local char = getChar()
    if not char then return false end
    animAppliedOnce = false
    firstApplyAnims(char)
    startAnimKeeper()
    return true
end

local function applyFullPack(name)
    local pack = PACKS[name]
    if not pack then return false end
    animIdle = pack.idle or 0
    animWalk = pack.walk or 0
    animRun  = pack.run  or 0
    animJump = pack.jump or 0
    animFall = pack.fall or 0
    animAppliedOnce = false
    return applyCatalogAnims()
end

local function resetAnims()
    animIdle, animWalk, animRun, animJump, animFall = 0, 0, 0, 0, 0
    animAppliedOnce = false
    if animKeeperConn then animKeeperConn:Disconnect() animKeeperConn = nil end
    local hum = getHum()
    local char = getChar()
    if hum then
        pcall(function()
            hum:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId))
        end)
    end
    if char and char:FindFirstChild("Animate") then
        local a = char.Animate
        a.Disabled = true
        task.delay(0.08, function()
            if a and a.Parent then a.Disabled = false end
        end)
    end
    return true
end

local function updateFovCircle()
    if not showFov then if fovCircle then fovCircle.Visible = false end return end
    local parent = CoreGui
    pcall(function() if gethui then parent = gethui() end end)
    if not fovCircle or not fovCircle.Parent then
        local sg = parent:FindFirstChild("KXFov") or Instance.new("ScreenGui")
        sg.Name = "KXFov" sg.IgnoreGuiInset = true sg.Parent = parent
        fovCircle = Instance.new("Frame")
        fovCircle.BackgroundTransparency = 1
        fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        fovCircle.Parent = sg
        local s = Instance.new("UIStroke")
        s.Thickness = 1.5 s.Color = Color3.fromRGB(80, 220, 255) s.Parent = fovCircle
        Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
    end
    local px = math.tan(math.rad(silentFov) * 0.5) * (camera.ViewportSize.Y * 0.5) * 1.1
    fovCircle.Size = UDim2.fromOffset(px * 2, px * 2)
    fovCircle.Position = UDim2.fromScale(0.5, 0.5)
    fovCircle.Visible = true
end

local function clearEsp()
    for _, v in pairs(espObjs) do pcall(function() if v and v.Destroy then v:Destroy() end end) end
    table.clear(espObjs)
end

local function makeBoneLine(draw, key)
    local line = Instance.new("Frame")
    line.Name = key
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = espColor
    line.Parent = draw
    return line
end

local function placeLine(line, a, b)
    local mid = (a + b) * 0.5
    local dist = (a - b).Magnitude
    line.BackgroundColor3 = espColor
    line.Size = UDim2.fromOffset(math.max(dist, 1), 1.6)
    line.Position = UDim2.fromOffset(mid.X, mid.Y)
    line.Rotation = math.deg(math.atan2(b.Y - a.Y, b.X - a.X))
    line.Visible = true
end

local function updateEsp()
    if not (lineOn or boxOn or skelOn or hpOn or nameOn) then
        clearEsp()
        return
    end

    local parent = CoreGui
    pcall(function() if gethui then parent = gethui() end end)
    local draw = parent:FindFirstChild("KXDraw")
    if not draw then
        draw = Instance.new("ScreenGui")
        draw.Name = "KXDraw"
        draw.IgnoreGuiInset = true
        draw.ResetOnSpawn = false
        draw.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        draw.Parent = parent
    end

    local top = Vector2.new(camera.ViewportSize.X * 0.5, 6)
    local seen = {}
    local myRoot = getRoot()

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local uid = tostring(plr.UserId)
                local part = head or root
                local sp, onScreen = camera:WorldToViewportPoint(part.Position)

                if onScreen and sp.Z > 0 then
                    local screenPos = Vector2.new(sp.X, sp.Y)

                    -- LINES
                    if lineOn then
                        local lkey = "l" .. uid
                        seen[lkey] = true
                        local line = espObjs[lkey]
                        if not line or not line.Parent then
                            line = makeBoneLine(draw, lkey)
                            espObjs[lkey] = line
                        end
                        placeLine(line, top, screenPos)
                    end

                    -- BOXES
                    if boxOn then
                        local bkey = "b" .. uid
                        seen[bkey] = true
                        local box = espObjs[bkey]
                        if not box or not box.Parent then
                            box = Instance.new("Frame")
                            box.Name = bkey
                            box.BackgroundTransparency = 1
                            box.BorderSizePixel = 0
                            box.Parent = draw
                            local s = Instance.new("UIStroke")
                            s.Thickness = 1.5
                            s.Parent = box
                            espObjs[bkey] = box
                        end
                        local st = box:FindFirstChildOfClass("UIStroke")
                        if st then st.Color = espColor end
                        box.Size = UDim2.fromOffset(40, 64)
                        box.Position = UDim2.fromOffset(sp.X - 20, sp.Y - 12)
                        box.Visible = true
                    end

                    -- SKELETON
                    if skelOn then
                        local boneIdx = 0
                        for _, pair in ipairs(SKELETON_BONES) do
                            local p1 = plr.Character:FindFirstChild(pair[1])
                            local p2 = plr.Character:FindFirstChild(pair[2])
                            if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                                local s1, o1 = camera:WorldToViewportPoint(p1.Position)
                                local s2, o2 = camera:WorldToViewportPoint(p2.Position)
                                if o1 and o2 and s1.Z > 0 and s2.Z > 0 then
                                    boneIdx = boneIdx + 1
                                    local skkey = "sk" .. uid .. "_" .. boneIdx
                                    seen[skkey] = true
                                    local bline = espObjs[skkey]
                                    if not bline or not bline.Parent then
                                        bline = makeBoneLine(draw, skkey)
                                        espObjs[skkey] = bline
                                    end
                                    placeLine(bline, Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y))
                                end
                            end
                        end
                    end

                    -- NAMES / HEALTH
                    if nameOn or hpOn then
                        local nkey = "n" .. uid
                        seen[nkey] = true
                        local lbl = espObjs[nkey]
                        if not lbl or not lbl.Parent then
                            lbl = Instance.new("TextLabel")
                            lbl.Name = nkey
                            lbl.BackgroundTransparency = 1
                            lbl.Size = UDim2.fromOffset(160, 18)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 12
                            lbl.TextColor3 = Color3.fromRGB(240, 240, 245)
                            lbl.TextStrokeTransparency = 0.3
                            lbl.TextXAlignment = Enum.TextXAlignment.Center
                            lbl.Parent = draw
                            espObjs[nkey] = lbl
                        end
                        local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0
                        local txt = ""
                        if nameOn then txt = plr.Name end
                        if hpOn then txt = txt .. string.format(" %dhp", math.floor(hum.Health)) end
                        txt = txt .. string.format(" %dm", dist)
                        lbl.Text = txt
                        lbl.Position = UDim2.fromOffset(sp.X - 80, sp.Y - 30)
                        lbl.Visible = true
                    end
                end
            end
        end
    end

    -- cleanup solo lo que ya no se usa
    for key, obj in pairs(espObjs) do
        if not seen[key] then
            pcall(function() obj:Destroy() end)
            espObjs[key] = nil
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if jumpOn then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

localPlayer.CharacterAdded:Connect(function(char)
    task.wait(1.2)
    originalWalkSpeed = nil
    table.clear(originalCollision)
    animAppliedOnce = false
    if hasCustomAnims() then
        firstApplyAnims(char)
        startAnimKeeper()
    end
end)

local function loadWindUI()
    local urls = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
    }
    for _, url in ipairs(urls) do
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if ok and lib and type(lib) == "table" and lib.CreateWindow then
            return lib
        end
    end
    return nil
end

local function startHub()
    local WindUI = loadWindUI()
    if not WindUI then
        showError("Could not load WindUI.")
        return
    end

    pcall(setupSilentMouse)
    pcall(setupRemoteHook)

    local Window = WindUI:CreateWindow({
        Title = "KAISENX DUELS",
        Author = "created by KAISEN",
        Folder = "KaisenXDuels",
        Size = UDim2.fromOffset(520, 520),
        Transparent = true,
        Theme = "Crimson",
        Resizable = true,
        SideBarWidth = 140,
    })

    local function names(tbl)
        local list = {}
        for k in pairs(tbl) do table.insert(list, k) end
        table.sort(list)
        return list
    end

    local Home = Window:Tab({ Title = "Home", Icon = "star" })
    Home:Paragraph({
        Title = "Join our Discord",
        Desc = "Join our official community for support, updates and to talk with other members.\n" .. DISCORD_LINK,
        Image = DISCORD_IMG,
        ImageSize = 110,
    })
    Home:Button({
        Title = "Copy Discord",
        Icon = "message-circle",
        Callback = function()
            pcall(function() setclipboard(DISCORD_LINK) end)
            safeNotify(WindUI, "Discord", "Link copied!")
        end
    })
    Home:Paragraph({ Title = "By: KAISEN", Desc = "Creator of KAISENX" })
    Home:Paragraph({
        Title = "TikTok",
        Desc = TIKTOK_USER .. "\nClips, updates and more content.",
        Image = TIKTOK_IMG,
        ImageSize = 110,
    })
    Home:Button({
        Title = "Copy TikTok",
        Icon = "share",
        Callback = function()
            pcall(function() setclipboard("https://www.tiktok.com/" .. TIKTOK_USER) end)
            safeNotify(WindUI, "TikTok", "Link copied!")
        end
    })

    local Aim = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
    Aim:Paragraph({
        Title = "Silent Aim",
        Desc = "You shoot · showBeam redirects · prediction 0.19 locked"
    })
    Aim:Toggle({
        Title = "Silent Aim",
        Default = silentOn,
        Callback = function(v)
            silentOn = v
            if v then PREDICT = 0.19 end
        end
    })
    Aim:Dropdown({
        Title = "Body Part",
        Values = { "Head", "Torso", "Root" },
        Value = "Root",
        Callback = function(v) aimPartName = v end
    })
    Aim:Toggle({ Title = "Show FOV Circle", Default = false, Callback = function(v) showFov = v end })
    Aim:Toggle({ Title = "Filter Team", Default = filterTeams, Callback = function(v) filterTeams = v end })
    Aim:Slider({
        Title = "FOV",
        Step = 5,
        Value = { Min = 120, Max = 360, Default = 305 },
        Callback = function(v) silentFov = v end
    })
    Aim:Slider({
        Title = "Match Dist",
        Step = 10,
        Value = { Min = 80, Max = 500, Default = MATCH_DIST },
        Callback = function(v) MATCH_DIST = v end
    })

    local Vis = Window:Tab({ Title = "Visuals", Icon = "eye" })
    Vis:Toggle({ Title = "Lines", Default = false, Callback = function(v)
        lineOn = v
        if not v then
            for key, obj in pairs(espObjs) do
                if string.sub(key, 1, 1) == "l" then
                    pcall(function() obj:Destroy() end)
                    espObjs[key] = nil
                end
            end
        end
    end })
    Vis:Toggle({ Title = "Boxes", Default = false, Callback = function(v)
        boxOn = v
        if not v then
            for key, obj in pairs(espObjs) do
                if string.sub(key, 1, 1) == "b" then
                    pcall(function() obj:Destroy() end)
                    espObjs[key] = nil
                end
            end
        end
    end })
    Vis:Toggle({ Title = "Skeleton", Default = false, Callback = function(v)
        skelOn = v
        if not v then
            for key, obj in pairs(espObjs) do
                if string.sub(key, 1, 2) == "sk" then
                    pcall(function() obj:Destroy() end)
                    espObjs[key] = nil
                end
            end
        end
    end })
    Vis:Toggle({ Title = "Health", Default = false, Callback = function(v) hpOn = v end })
    Vis:Toggle({ Title = "Names", Default = false, Callback = function(v)
        nameOn = v
        if not v and not hpOn then
            for key, obj in pairs(espObjs) do
                if string.sub(key, 1, 1) == "n" then
                    pcall(function() obj:Destroy() end)
                    espObjs[key] = nil
                end
            end
        end
    end })
    Vis:Dropdown({
        Title = "ESP Color",
        Values = { "Orange", "Red", "Cyan", "Green", "Purple" },
        Value = "Orange",
        Callback = function(name)
            local map = {
                Orange = Color3.fromRGB(255, 140, 40),
                Red = Color3.fromRGB(255, 40, 50),
                Cyan = Color3.fromRGB(80, 220, 255),
                Green = Color3.fromRGB(60, 255, 100),
                Purple = Color3.fromRGB(180, 80, 255),
            }
            espColor = map[name] or espColor
        end
    })

    local Anim = Window:Tab({ Title = "Animations", Icon = "user" })
    Anim:Dropdown({
        Title = "Full Pack",
        Values = names(PACKS),
        Value = "Ninja",
        Callback = function(v) selectedFullPack = v end
    })
    Anim:Button({ Title = "Apply Full Pack", Callback = function() applyFullPack(selectedFullPack) end })
    Anim:Dropdown({ Title = "Idle", Values = names(IDLE_OPTS), Value = "Default", Callback = function(v) animIdle = IDLE_OPTS[v] or 0 end })
    Anim:Dropdown({ Title = "Walk", Values = names(WALK_OPTS), Value = "Default", Callback = function(v) animWalk = WALK_OPTS[v] or 0 end })
    Anim:Dropdown({ Title = "Run", Values = names(RUN_OPTS), Value = "Default", Callback = function(v) animRun = RUN_OPTS[v] or 0 end })
    Anim:Dropdown({ Title = "Jump", Values = names(JUMP_OPTS), Value = "Default", Callback = function(v) animJump = JUMP_OPTS[v] or 0 end })
    Anim:Button({ Title = "Apply Combination", Callback = function() applyCatalogAnims() end })
    Anim:Button({ Title = "Reset Original Animation", Callback = function() resetAnims() end })

    local Misc = Window:Tab({ Title = "Misc", Icon = "box" })
    Misc:Toggle({ Title = "Speed", Default = false, Callback = function(v) speedOn = v setSpeed(v, walkSpeed) end })
    Misc:Slider({
        Title = "WalkSpeed",
        Step = 2,
        Value = { Min = 16, Max = 50, Default = walkSpeed },
        Callback = function(v)
            walkSpeed = v
            if speedOn then setSpeed(true, walkSpeed) end
        end
    })
    Misc:Toggle({ Title = "Infinite Jump", Default = false, Callback = function(v) jumpOn = v end })
    Misc:Toggle({ Title = "Noclip", Default = false, Callback = function(v) noclipOn = v setNoclip(v) end })

    local Set = Window:Tab({ Title = "Settings", Icon = "settings" })
    Set:Dropdown({
        Title = "Menu Theme",
        Values = { "Dark", "Light", "Rose", "Indigo", "Sky", "Violet", "Amber", "Plant", "Nord", "Crimson" },
        Value = "Crimson",
        Callback = function(name)
            pcall(function()
                if WindUI.SetTheme then WindUI:SetTheme(name)
                elseif Window.SetTheme then Window:SetTheme(name) end
            end)
        end
    })

    RunService.RenderStepped:Connect(function()
        updateTarget()
        updateEsp()
        updateFovCircle()
        if noclipOn then setNoclip(true) end
    end)

    RunService.Heartbeat:Connect(function()
        if speedOn then setSpeed(true, walkSpeed) end
    end)

    print("[KAISENX] ESP fixed (lines/boxes/names/skel)")
    safeNotify(WindUI, "KAISENX", "Hub loaded")
end

local ok, err = pcall(startHub)
if not ok then
    showError(tostring(err))
end
