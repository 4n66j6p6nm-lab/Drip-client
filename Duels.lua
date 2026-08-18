print("✅ KAISENX DUELS | Silent · Catalog Anims")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()

-- AIM
local silentOn = true
local showFov = true
local aimPartName = "Head"
local silentFov = 160
local maxDist = 350
local MATCH_DIST = 200
local filterTeams = true

-- VISUALS (empiezan apagados)
local lineOn, boxOn, skelOn, hpOn, nameOn = false, false, false, false, false
local espColor = Color3.fromRGB(255, 140, 40)

-- PLAYER
local speedOn, jumpOn, noclipOn, fastSwap = false, false, false, false
local walkSpeed = 28

-- ANIM
local animIdle, animWalk, animRun, animJump, animFall = 0, 0, 0, 0, 0
local selectedFullPack = "Ninja"

local PACKS = {
    Default = { idle = 0, walk = 0, run = 0, jump = 0, fall = 0 },
    Ninja = {
        idle = 656117400, walk = 656118341, run = 656118852,
        jump = 656117878, fall = 656115606,
    },
    Robot = {
        idle = 616006778, walk = 616010702, run = 616010702,
        jump = 616008936, fall = 616008936,
    },
    Stylish = {
        idle = 2510196951, walk = 2510198475, run = 2510198475,
        jump = 2510197830, fall = 2510195892,
    },
    Zombie = {
        idle = 10921295139, walk = 10921301576, run = 10921306285,
        jump = 10921327484, fall = 10921321317,
    },
    Levitation = {
        idle = 2510192778, walk = 2510194744, run = 2510194744,
        jump = 2510195892, fall = 2510195892,
    },
    Superhero = {
        idle = 1018553897, walk = 1018593140, run = 1018595538,
        jump = 1018564512, fall = 1018564512,
    },
    Cartoony = {
        idle = 742637544, walk = 742638485, run = 742638842,
        jump = 742637942, fall = 742637942,
    },
    Elder = {
        idle = 5319828216, walk = 5319839762, run = 5319844329,
        jump = 5319841935, fall = 5319841935,
    },
}

local IDLE_OPTS = { Default=0, Ninja=656117400, Robot=616006778, Stylish=2510196951, Zombie=10921295139, Levitation=2510192778, Superhero=1018553897, Cartoony=742637544, Elder=5319828216 }
local WALK_OPTS = { Default=0, Ninja=656118341, Robot=616010702, Stylish=2510198475, Zombie=10921301576, Levitation=2510194744, Superhero=1018593140, Cartoony=742638485, Elder=5319839762 }
local RUN_OPTS  = { Default=0, Ninja=656118852, Robot=616010702, Stylish=2510198475, Zombie=10921306285, Levitation=2510194744, Superhero=1018595538, Cartoony=742638842, Elder=5319844329 }
local JUMP_OPTS = { Default=0, Ninja=656117878, Robot=616008936, Stylish=2510197830, Zombie=10921327484, Levitation=2510195892, Superhero=1018564512, Cartoony=742637942, Elder=5319841935 }

local cachedPos, cachedPart = nil, nil
local targetVisible = false
local espObjs, fovCircle = {}, nil
local lastSwap = 0

local function getChar() return localPlayer.Character end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function inMatch(plr)
    local my = getRoot()
    local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not my or not r then return false end
    return (r.Position - my.Position).Magnitude <= MATCH_DIST
end

local function isEnemy(plr)
    if not plr or plr == localPlayer or not plr.Character then return false end
    if not inMatch(plr) then return false end
    local h = plr.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if filterTeams and localPlayer.Team and plr.Team and localPlayer.Team == plr.Team then return false end
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

local function hasLineOfSight(fromPos, toPos, targetChar)
    local dir = toPos - fromPos
    local dist = dir.Magnitude
    if dist < 1 then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = { localPlayer.Character }
    if targetChar then table.insert(ignore, targetChar) end
    params.FilterDescendantsInstances = ignore
    params.IgnoreWater = true
    local result = workspace:Raycast(fromPos, dir.Unit * dist, params)
    if not result then return true end
    if targetChar and result.Instance and result.Instance:IsDescendantOf(targetChar) then return true end
    return false
end

-- AIM SIN PREDICCIÓN
local function updateTarget()
    if not silentOn then
        cachedPos, cachedPart, targetVisible = nil, nil, false
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
            local part = pickPart(plr.Character)
            if part then
                local pos = part.Position
                local dist = (pos - origin).Magnitude
                if dist <= maxDist then
                    local dir = pos - origin
                    if dir.Magnitude > 0.1 then
                        local ang = math.acos(math.clamp(look:Dot(dir.Unit), -1, 1))
                        local sp, on = camera:WorldToViewportPoint(pos)
                        local cross = 9999
                        if on and sp.Z > 0 then
                            cross = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        end

                        local inFov = (ang <= maxAng) or (cross <= fovPx)

                        if inFov then
                            local visible = hasLineOfSight(origin, pos, plr.Character)
                            local score = 15000 - cross * 8 - dist * 0.15
                            score = score + (visible and 7000 or -3500)
                            if on and sp.Z > 0 then score = score + 1000 end

                            if score > bestScore then
                                bestScore = score
                                best = { pos = pos, part = part, visible = visible }
                            end
                        end
                    end
                end
            end
        end
    end

    if best then
        cachedPos, cachedPart = best.pos, best.part
        targetVisible = best.visible
    else
        cachedPos, cachedPart, targetVisible = nil, nil, false
    end
end

local function setupSilent()
    local ok, mt = pcall(function() return getrawmetatable(mouse) end)
    if not ok or not mt then return false end
    return pcall(function()
        setreadonly(mt, false)
        local old = mt.__index
        mt.__index = newcclosure(function(self, key)
            if silentOn and cachedPos and cachedPart then
                if key == "Hit" then return CFrame.new(cachedPos) end
                if key == "Target" then return cachedPart end
                if key == "UnitRay" then
                    local o = camera.CFrame.Position
                    return Ray.new(o, (cachedPos - o).Unit * 2500)
                end
            end
            return old(self, key)
        end)
        setreadonly(mt, true)
    end)
end

local function doFastSwap()
    if not fastSwap then return end
    if tick() - lastSwap < 0.35 then return end
    local char, bp = getChar(), localPlayer:FindFirstChild("Backpack")
    if not char or not bp then return end
    local held = char:FindFirstChildOfClass("Tool")
    local tools = {}
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then table.insert(tools, t) end
    end
    if held then table.insert(tools, 1, held) end
    if #tools < 2 then return end
    lastSwap = tick()
    if held then held.Parent = bp end
    tools[2].Parent = char
end

local function applyCatalogAnims()
    local char = getChar()
    local hum = getHum()
    if not char or not hum then return false, "sin personaje" end

    local ok = pcall(function()
        local desc = hum:GetAppliedDescription()
        if animIdle > 0 then desc.IdleAnimation = animIdle end
        if animWalk > 0 then desc.WalkAnimation = animWalk end
        if animRun  > 0 then desc.RunAnimation  = animRun  end
        if animJump > 0 then desc.JumpAnimation = animJump end
        if animFall > 0 then desc.FallAnimation = animFall end
        if animIdle == 0 and animWalk == 0 and animRun == 0 and animJump == 0 and animFall == 0 then
            local own = Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
            hum:ApplyDescription(own)
        else
            hum:ApplyDescription(desc)
        end
    end)
    if ok then return true, "description" end

    local animate = char:FindFirstChild("Animate")
    if not animate then return false, "sin Animate" end

    local function setAnim(folderName, id)
        if id <= 0 then return end
        local folder = animate:FindFirstChild(folderName)
        if not folder then return end
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Animation") then
                child.AnimationId = "http://www.roblox.com/asset/?id=" .. tostring(id)
            end
        end
    end

    setAnim("idle", animIdle)
    setAnim("walk", animWalk)
    setAnim("run",  animRun)
    setAnim("jump", animJump)
    setAnim("fall", animFall)

    animate.Disabled = true
    task.wait(0.05)
    animate.Disabled = false
    return true, "animate"
end

local function applyFullPack(name)
    local pack = PACKS[name]
    if not pack then return false, "pack no existe" end
    animIdle = pack.idle or 0
    animWalk = pack.walk or 0
    animRun  = pack.run  or 0
    animJump = pack.jump or 0
    animFall = pack.fall or 0
    return applyCatalogAnims()
end

local function resetAnims()
    animIdle, animWalk, animRun, animJump, animFall = 0, 0, 0, 0, 0
    local hum = getHum()
    if not hum then return false end
    local ok = pcall(function()
        local own = Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
        hum:ApplyDescription(own)
    end)
    if not ok then
        local char = getChar()
        local animate = char and char:FindFirstChild("Animate")
        if animate then
            animate.Disabled = true
            task.wait(0.05)
            animate.Disabled = false
        end
    end
    return true
end

local function updateFovCircle()
    if not showFov then
        if fovCircle then fovCircle.Visible = false end
        return
    end
    local parent = CoreGui
    pcall(function() if gethui then parent = gethui() end end)
    if not fovCircle or not fovCircle.Parent then
        local sg = parent:FindFirstChild("KXFov") or Instance.new("ScreenGui")
        sg.Name = "KXFov"
        sg.IgnoreGuiInset = true
        sg.Parent = parent
        fovCircle = Instance.new("Frame")
        fovCircle.BackgroundTransparency = 1
        fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        fovCircle.Parent = sg
        local s = Instance.new("UIStroke")
        s.Thickness = 1.5
        s.Color = Color3.fromRGB(80, 220, 255)
        s.Parent = fovCircle
        Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
    end
    local px = math.tan(math.rad(silentFov) * 0.5) * (camera.ViewportSize.Y * 0.5) * 1.1
    fovCircle.Size = UDim2.fromOffset(px * 2, px * 2)
    fovCircle.Position = UDim2.fromScale(0.5, 0.5)
    fovCircle.Visible = true
end

local function clearEsp()
    for _, v in pairs(espObjs) do
        pcall(function() if v and v.Destroy then v:Destroy() end end)
    end
    table.clear(espObjs)
end

local function updateEsp()
    if not (lineOn or boxOn or skelOn or hpOn or nameOn) then
        clearEsp()
        return
    end

    local parent = CoreGui
    pcall(function() if gethui then parent = gethui() end end)
    local draw = parent:FindFirstChild("KXDraw") or Instance.new("ScreenGui")
    draw.Name = "KXDraw"
    draw.IgnoreGuiInset = true
    draw.Parent = parent

    local top = Vector2.new(camera.ViewportSize.X * 0.5, 6)
    local seen = {}
    local myRoot = getRoot()

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local key = tostring(plr.UserId)
                seen[key] = true
                local part = head or root
                local sp, on = camera:WorldToViewportPoint(part.Position)
                if on and sp.Z > 0 then
                    -- LINEAS
                    if lineOn then
                        local line = espObjs["l" .. key]
                        if not line or not line.Parent then
                            line = Instance.new("Frame")
                            line.BorderSizePixel = 0
                            line.AnchorPoint = Vector2.new(0.5, 0.5)
                            line.Parent = draw
                            espObjs["l" .. key] = line
                        end
                        local tgt = Vector2.new(sp.X, sp.Y)
                        local mid = (top + tgt) * 0.5
                        line.BackgroundColor3 = espColor
                        line.Size = UDim2.fromOffset(math.max((top - tgt).Magnitude, 1), 1.5)
                        line.Position = UDim2.fromOffset(mid.X, mid.Y)
                        line.Rotation = math.deg(math.atan2(tgt.Y - top.Y, tgt.X - top.X))
                        line.Visible = true
                    elseif espObjs["l" .. key] then
                        espObjs["l" .. key].Visible = false
                    end

                    -- CAJAS / SKELETON
                    if boxOn or skelOn then
                        local box = espObjs["b" .. key]
                        if not box or not box.Parent then
                            box = Instance.new("Frame")
                            box.BackgroundTransparency = 1
                            box.Parent = draw
                            local s = Instance.new("UIStroke")
                            s.Thickness = 1.5
                            s.Parent = box
                            espObjs["b" .. key] = box
                        end
                        local st = box:FindFirstChildOfClass("UIStroke")
                        if st then st.Color = espColor end
                        local w = skelOn and 26 or 40
                        local h = skelOn and 48 or 64
                        box.Size = UDim2.fromOffset(w, h)
                        box.Position = UDim2.fromOffset(sp.X - w * 0.5, sp.Y - 12)
                        box.Visible = true
                    elseif espObjs["b" .. key] then
                        espObjs["b" .. key].Visible = false
                    end

                    -- NOMBRE + HP
                    if nameOn or hpOn then
                        local lbl = espObjs["n" .. key]
                        if not lbl or not lbl.Parent then
                            lbl = Instance.new("TextLabel")
                            lbl.BackgroundTransparency = 1
                            lbl.Size = UDim2.fromOffset(150, 16)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 12
                            lbl.TextColor3 = Color3.fromRGB(240, 240, 245)
                            lbl.TextStrokeTransparency = 0.35
                            lbl.Parent = draw
                            espObjs["n" .. key] = lbl
                        end
                        local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0
                        local t = ""
                        if nameOn then t = plr.Name end
                        if hpOn then t = t .. string.format(" %dhp", math.floor(hum.Health)) end
                        t = t .. string.format(" %dm", dist)
                        lbl.Text = t
                        lbl.Position = UDim2.fromOffset(sp.X - 75, sp.Y - 28)
                        lbl.Visible = true
                    elseif espObjs["n" .. key] then
                        espObjs["n" .. key].Visible = false
                    end
                end
            end
        end
    end

    for key, obj in pairs(espObjs) do
        local id = key:gsub("l", ""):gsub("b", ""):gsub("n", "")
        if not seen[id] then
            pcall(function() obj:Destroy() end)
            espObjs[key] = nil
        end
    end
end

local function applyNoclip(char)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end

UserInputService.JumpRequest:Connect(function()
    if jumpOn then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if animIdle > 0 or animWalk > 0 or animRun > 0 or animJump > 0 then
        applyCatalogAnims()
    end
end)

local function loadWindUI()
    for _, url in ipairs({
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    }) do
        local ok, lib = pcall(function() return loadstring(game:HttpGet(url))() end)
        if ok and lib then return lib end
    end
    return nil
end

local function startHub()
    local WindUI = loadWindUI()
    if not WindUI then warn("[KAISENX] WindUI fail") return end
    setupSilent()

    local Window = WindUI:CreateWindow({
        Title = "KAISENX DUELS",
        Author = "Silent · Anims",
        Icon = "crosshair",
        Folder = "KaisenXDuels",
        Size = UDim2.fromOffset(520, 520),
        Transparent = true,
        Theme = "Crimson",
        Resizable = true,
        SideBarWidth = 140,
    })

    local function notify(title, content)
        pcall(function()
            WindUI:Notify({ Title = title, Content = content, Duration = 2.2 })
        end)
    end

    local function names(tbl)
        local t = {}
        for k in pairs(tbl) do table.insert(t, k) end
        table.sort(t)
        return t
    end

    -- AIMBOT
    local Aim = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
    Aim:Paragraph({ Title = "Silent Aim", Desc = "Cámara fija. Solo disparas tú." })
    Aim:Toggle({ Title = "Silent Aim", Default = silentOn, Callback = function(v)
        silentOn = v
        notify("Silent", v and "ON" or "OFF")
    end })
    Aim:Dropdown({
        Title = "Parte del cuerpo",
        Values = { "Head", "Torso", "Root" },
        Value = aimPartName,
        Callback = function(v) aimPartName = v end
    })
    Aim:Toggle({ Title = "Mostrar Circulo FOV", Default = showFov, Callback = function(v) showFov = v end })
    Aim:Toggle({ Title = "Filter Team", Default = filterTeams, Callback = function(v) filterTeams = v end })
    Aim:Slider({ Title = "FOV", Step = 5, Value = { Min = 60, Max = 360, Default = silentFov }, Callback = function(v) silentFov = v end })
    Aim:Slider({ Title = "Match Dist", Step = 10, Value = { Min = 80, Max = 450, Default = MATCH_DIST }, Callback = function(v) MATCH_DIST = v end })

    -- VISUALS (empiezan apagados)
    local Vis = Window:Tab({ Title = "Visuals", Icon = "eye" })
    Vis:Toggle({ Title = "Lineas", Default = false, Callback = function(v) lineOn = v end })
    Vis:Toggle({ Title = "Cajas", Default = false, Callback = function(v) boxOn = v end })
    Vis:Toggle({ Title = "Skeleton", Default = false, Callback = function(v) skelOn = v end })
    Vis:Toggle({ Title = "Vida", Default = false, Callback = function(v) hpOn = v end })
    Vis:Toggle({ Title = "Nombres", Default = false, Callback = function(v) nameOn = v end })
    Vis:Dropdown({
        Title = "Color ESP",
        Values = { "Naranja", "Rojo", "Cyan", "Verde", "Morado" },
        Value = "Naranja",
        Callback = function(name)
            local map = {
                Naranja = Color3.fromRGB(255, 140, 40),
                Rojo = Color3.fromRGB(255, 40, 50),
                Cyan = Color3.fromRGB(80, 220, 255),
                Verde = Color3.fromRGB(60, 255, 100),
                Morado = Color3.fromRGB(180, 80, 255),
            }
            espColor = map[name] or espColor
        end
    })

    -- ANIMACIONES
    local Anim = Window:Tab({ Title = "Animaciones", Icon = "user" })
    Anim:Paragraph({
        Title = "Pack entero",
        Desc = "Aplica idle + walk + run + jump del mismo pack de una vez."
    })
    Anim:Dropdown({
        Title = "Pack completo",
        Values = names(PACKS),
        Value = "Ninja",
        Callback = function(v) selectedFullPack = v end
    })
    Anim:Button({ Title = "Aplicar pack entero", Callback = function()
        local ok, how = applyFullPack(selectedFullPack)
        if ok then
            notify("Anim", "Pack " .. selectedFullPack .. " (" .. tostring(how) .. ")")
        else
            notify("Anim", "Error: " .. tostring(how))
        end
    end })
    Anim:Paragraph({
        Title = "Combinar (personalizar)",
        Desc = "Elige cada animación por separado y aplica."
    })
    Anim:Dropdown({
        Title = "Idle (parado)",
        Values = names(IDLE_OPTS),
        Value = "Default",
        Callback = function(v) animIdle = IDLE_OPTS[v] or 0 end
    })
    Anim:Dropdown({
        Title = "Walk (caminar)",
        Values = names(WALK_OPTS),
        Value = "Default",
        Callback = function(v) animWalk = WALK_OPTS[v] or 0 end
    })
    Anim:Dropdown({
        Title = "Run (correr)",
        Values = names(RUN_OPTS),
        Value = "Default",
        Callback = function(v) animRun = RUN_OPTS[v] or 0 end
    })
    Anim:Dropdown({
        Title = "Jump (saltar)",
        Values = names(JUMP_OPTS),
        Value = "Default",
        Callback = function(v) animJump = JUMP_OPTS[v] or 0 end
    })
    Anim:Button({ Title = "Aplicar combinación", Callback = function()
        local ok, how = applyCatalogAnims()
        if ok then
            notify("Anim", "Combinación (" .. tostring(how) .. ")")
        else
            notify("Anim", "Error: " .. tostring(how))
        end
    end })
    Anim:Button({ Title = "Reset animación original", Callback = function()
        resetAnims()
        notify("Anim", "Default restaurado")
    end })

    -- MISC
    local Misc = Window:Tab({ Title = "Misc", Icon = "box" })
    Misc:Toggle({ Title = "Fast Swap", Default = false, Callback = function(v) fastSwap = v end })
    Misc:Toggle({ Title = "Speed", Default = false, Callback = function(v)
        speedOn = v
        if not v then
            local h = getHum()
            if h then h.WalkSpeed = 16 end
        end
    end })
    Misc:Slider({ Title = "WalkSpeed", Step = 2, Value = { Min = 16, Max = 50, Default = walkSpeed }, Callback = function(v) walkSpeed = v end })
    Misc:Toggle({ Title = "Infinite Jump", Default = false, Callback = function(v) jumpOn = v end })
    Misc:Toggle({ Title = "Noclip", Default = false, Callback = function(v) noclipOn = v end })

    -- SETTINGS (solo tema)
    local Set = Window:Tab({ Title = "Settings", Icon = "settings" })
    Set:Dropdown({
        Title = "Tema del menú",
        Values = { "Dark", "Light", "Rose", "Indigo", "Sky", "Violet", "Amber", "Plant", "Nord", "Crimson" },
        Value = "Crimson",
        Callback = function(name)
            pcall(function()
                if WindUI.SetTheme then
                    WindUI:SetTheme(name)
                elseif Window.SetTheme then
                    Window:SetTheme(name)
                end
            end)
        end
    })

    notify("KAISENX", "Listo")

    RunService.RenderStepped:Connect(function()
        updateTarget()
        updateEsp()
        updateFovCircle()
        if fastSwap then doFastSwap() end
    end)

    RunService.Heartbeat:Connect(function()
        local hum, char = getHum(), getChar()
        if hum and hum.Health > 0 then
            if speedOn then hum.WalkSpeed = walkSpeed end
            if noclipOn and char then applyNoclip(char) end
        end
    end)
end

local ok, err = pcall(startHub)
if not ok then warn("[KAISENX]", err) end
