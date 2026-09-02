print("✅ KAISENX DUELS | created by KAISEN | loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()

local DISCORD_LINK = "https://discord.gg/xWPp9kxTs"
local TIKTOK_USER = "@kaisen_x2"
local DISCORD_IMG = "rbxassetid://16584754883"
local TIKTOK_IMG = "rbxassetid://140658929749855"

-- Language
local LANG = "en"
local function loadLang()
	pcall(function()
		if isfile and isfile("kaisenx_lang.txt") then
			local v = readfile("kaisenx_lang.txt")
			if v == "es" or v == "en" then LANG = v end
		end
	end)
end
local function saveLang(v)
	pcall(function() if writefile then writefile("kaisenx_lang.txt", v) end end)
end
loadLang()

local STR = {
	en = {
		home = "Home", aimbot = "Aimbot", visuals = "Visuals", misc = "Misc", settings = "Settings", shaders = "Shaders",
		join_discord = "Join our Discord", join_discord_desc = "Join our official community.\n",
		copy_discord = "Copy Discord", by_kaisen = "By: KAISEN", creator = "Creator of KAISENX",
		tiktok = "TikTok", tiktok_desc = "\nClips & updates", copy_tiktok = "Copy TikTok",
		silent_aim = "Silent Aim", body_part = "Body Part",
		show_fov = "Show FOV Circle", filter_team = "Filter Team", fov = "FOV (max 200)", match_dist = "Match Dist",
		esp = "ESP Marker", names = "Names", distance = "Distance",
		speed = "Speed", walkspeed = "WalkSpeed", inf_jump = "Infinite Jump", noclip = "Noclip",
		theme = "Menu Theme", language = "Language", lang_hint = "Re-execute to apply language",
		link_copied = "Link copied!", hitbox = "Hitbox", hitbox_size = "Hitbox Size",
		knife_tp = "Knife TP (Under Enemy)",
		knife_tp_warn = "⚠️ HIGH RISK OF KICK / BAN. Use at your own risk.",
	},
	es = {
		home = "Inicio", aimbot = "Aimbot", visuals = "Visuales", misc = "Misc", settings = "Ajustes", shaders = "Shaders",
		join_discord = "Únete a nuestro Discord", join_discord_desc = "Únete a nuestra comunidad.\n",
		copy_discord = "Copiar Discord", by_kaisen = "Por: KAISEN", creator = "Creador de KAISENX",
		tiktok = "TikTok", tiktok_desc = "\nClips y updates", copy_tiktok = "Copiar TikTok",
		silent_aim = "Silent Aim", body_part = "Parte del cuerpo",
		show_fov = "Mostrar círculo FOV", filter_team = "Filtrar equipo", fov = "FOV (máx 200)", match_dist = "Distancia",
		esp = "ESP Marker", names = "Nombres", distance = "Distancia",
		speed = "Velocidad", walkspeed = "WalkSpeed", inf_jump = "Salto infinito", noclip = "Noclip",
		theme = "Tema", language = "Idioma", lang_hint = "Vuelve a ejecutar para aplicar",
		link_copied = "¡Link copiado!", hitbox = "Hitbox", hitbox_size = "Tamaño Hitbox",
		knife_tp = "Knife TP (Debajo del enemigo)",
		knife_tp_warn = "⚠️ ALTO RIESGO DE KICK / BAN. Úsalo bajo tu responsabilidad.",
	},
}

local function t(key)
	local pack = STR[LANG] or STR.en
	return pack[key] or STR.en[key] or key
end

-- AIM
local silentOn = false
local showFov = false
local aimPartName = "Head"
local silentFov = 160
local maxDist = 450
local MATCH_DIST = 250
local filterTeams = true
local aimOffset = Vector3.new(0, -0.2, 0)
local knifeTP = false
local lastKnifeTP = 0

-- GUN
local GUN_GUID = "501fb32e-88ee-4941-b677-ab1cd9e0b2eb"
local lastGunFire = 0
local gunFireDelay = 0.09

local function fireGunRemote(pos)
	if not pos or not silentOn then return end
	pcall(function()
		local gunRemotes = ReplicatedStorage:FindFirstChild("GunRemotes")
		if gunRemotes then
			local fireGun = gunRemotes:FindFirstChild("FireGun")
			if fireGun then
				fireGun:InvokeServer("Fire", GUN_GUID, pos)
			end
		end
	end)
end

-- HITBOX
local hitboxEnabled = false
local hitboxSize = 6
local maxHitboxSize = 35
local hitboxParts = {}
local rgbSpeed = 1.8

local function getRGBColor()
	local tt = tick() * rgbSpeed
	return Color3.new(
		math.sin(tt) * 0.5 + 0.5,
		math.sin(tt + 2) * 0.5 + 0.5,
		math.sin(tt + 4) * 0.5 + 0.5
	)
end

local function clearHitboxes()
	for _, v in pairs(hitboxParts) do
		pcall(function() v:Destroy() end)
	end
	table.clear(hitboxParts)
end

local function isTeammate(plr)
	if not plr or plr == localPlayer then return true end
	if localPlayer.Team ~= nil and plr.Team ~= nil then
		return localPlayer.Team == plr.Team
	end
	return false
end

local function createHitboxFor(player)
	if not hitboxEnabled then return end
	if player == localPlayer then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health <= 0 then return end
	if filterTeams and isTeammate(player) then return end

	if hitboxParts[player] then
		pcall(function() hitboxParts[player]:Destroy() end)
		hitboxParts[player] = nil
	end

	local size = math.clamp(hitboxSize, 2, maxHitboxSize)
	local part = Instance.new("Part")
	part.Name = "KX_Hitbox"
	part.Anchored = false
	part.CanCollide = false
	part.CanQuery = true
	part.CanTouch = false
	part.Massless = true
	part.Transparency = 0.38
	part.Material = Enum.Material.Neon
	part.Color = getRGBColor()
	part.Size = Vector3.new(size, size, size)
	part.Parent = char

	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = part
	hitboxParts[player] = part
end

local function updateHitboxes()
	if not hitboxEnabled then
		clearHitboxes()
		return
	end
	local currentColor = getRGBColor()
	local size = math.clamp(hitboxSize, 2, maxHitboxSize)
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			if filterTeams and isTeammate(player) then
				if hitboxParts[player] then
					pcall(function() hitboxParts[player]:Destroy() end)
					hitboxParts[player] = nil
				end
			else
				local hb = hitboxParts[player]
				if not hb or not hb.Parent then
					createHitboxFor(player)
					hb = hitboxParts[player]
				end
				if hb and hb.Parent then
					hb.Size = Vector3.new(size, size, size)
					hb.Color = currentColor
				end
			end
		end
	end
	for plr, part in pairs(hitboxParts) do
		if not plr.Parent or not plr.Character or not part.Parent then
			pcall(function() part:Destroy() end)
			hitboxParts[plr] = nil
		end
	end
end

local function hookCharacter(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.7)
		if hitboxEnabled then createHitboxFor(player) end
	end)
end
for _, plr in ipairs(Players:GetPlayers()) do hookCharacter(plr) end
Players.PlayerAdded:Connect(hookCharacter)

-- VISUALS (ESP Marker + Nombre + Distancia)
local espOn, nameOn, distOn = false, false, false
local espObjects = {} -- [key] = {billboard, marker, label}
local speedOn, jumpOn, noclipOn = false, false, false
local walkSpeed = 28
local cachedPos, cachedPart = nil, nil
local fovCircle = nil
local originalWalkSpeed = nil
local originalCollision = {}
local espColor = Color3.fromRGB(255, 50, 70)

-- SHADERS
local originalLighting = {}
local colorEffect, bloomEffect, blurEffect = nil, nil, nil

local function saveLighting()
	if next(originalLighting) then return end
	originalLighting = {
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime,
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ColorShift_Top = Lighting.ColorShift_Top,
		ColorShift_Bottom = Lighting.ColorShift_Bottom,
		ExposureCompensation = Lighting.ExposureCompensation,
	}
end

local function clearEffects()
	if colorEffect then pcall(function() colorEffect:Destroy() end) colorEffect = nil end
	if bloomEffect then pcall(function() bloomEffect:Destroy() end) bloomEffect = nil end
	if blurEffect then pcall(function() blurEffect:Destroy() end) blurEffect = nil end
end

local function applyShader(name)
	saveLighting()
	clearEffects()
	if name == "None" then
		for k, v in pairs(originalLighting) do pcall(function() Lighting[k] = v end) end
		return
	end
	if name == "Fullbright" then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.Ambient = Color3.fromRGB(200, 200, 200)
		Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
	elseif name == "Night Vision" then
		Lighting.Brightness = 1.5
		Lighting.ClockTime = 4
		Lighting.FogEnd = 100000
		Lighting.Ambient = Color3.fromRGB(0, 255, 100)
		Lighting.OutdoorAmbient = Color3.fromRGB(0, 180, 80)
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.TintColor = Color3.fromRGB(100, 255, 140)
		colorEffect.Contrast = 0.3
		colorEffect.Parent = Lighting
	elseif name == "No Fog" then
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
	elseif name == "Soft Light" then
		Lighting.Brightness = 1.3
		Lighting.Ambient = Color3.fromRGB(180, 170, 160)
		Lighting.OutdoorAmbient = Color3.fromRGB(160, 150, 140)
		bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Intensity = 0.6
		bloomEffect.Size = 30
		bloomEffect.Threshold = 1.2
		bloomEffect.Parent = Lighting
	elseif name == "High Contrast" then
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.Contrast = 0.55
		colorEffect.Saturation = 0.2
		colorEffect.Parent = Lighting
	elseif name == "Cold" then
		Lighting.Ambient = Color3.fromRGB(120, 150, 200)
		Lighting.OutdoorAmbient = Color3.fromRGB(100, 130, 180)
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.TintColor = Color3.fromRGB(160, 200, 255)
		colorEffect.Parent = Lighting
	elseif name == "Warm" then
		Lighting.Ambient = Color3.fromRGB(200, 160, 120)
		Lighting.OutdoorAmbient = Color3.fromRGB(180, 140, 100)
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.TintColor = Color3.fromRGB(255, 210, 160)
		colorEffect.Parent = Lighting
	elseif name == "Cyber" then
		Lighting.Brightness = 1.4
		Lighting.ClockTime = 20
		Lighting.Ambient = Color3.fromRGB(40, 20, 80)
		Lighting.OutdoorAmbient = Color3.fromRGB(30, 10, 60)
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.TintColor = Color3.fromRGB(180, 80, 255)
		colorEffect.Contrast = 0.4
		colorEffect.Parent = Lighting
		bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Intensity = 0.9
		bloomEffect.Size = 40
		bloomEffect.Threshold = 0.9
		bloomEffect.Parent = Lighting
	elseif name == "Cartoon" or name == "Carton" then
		Lighting.Brightness = 1.6
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.Ambient = Color3.fromRGB(210, 200, 190)
		Lighting.OutdoorAmbient = Color3.fromRGB(190, 180, 170)
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.Saturation = 0.85
		colorEffect.Contrast = 0.45
		colorEffect.Brightness = 0.05
		colorEffect.Parent = Lighting
		bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Intensity = 0.35
		bloomEffect.Size = 18
		bloomEffect.Threshold = 1.6
		bloomEffect.Parent = Lighting
	elseif name == "Paper" then
		Lighting.Brightness = 1.4
		Lighting.Ambient = Color3.fromRGB(230, 220, 200)
		Lighting.OutdoorAmbient = Color3.fromRGB(210, 200, 180)
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.Saturation = 0.3
		colorEffect.Contrast = 0.5
		colorEffect.TintColor = Color3.fromRGB(255, 245, 230)
		colorEffect.Parent = Lighting
	elseif name == "Retro" then
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.Saturation = -0.2
		colorEffect.Contrast = 0.3
		colorEffect.TintColor = Color3.fromRGB(255, 230, 180)
		colorEffect.Parent = Lighting
		bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Intensity = 0.3
		bloomEffect.Size = 25
		bloomEffect.Parent = Lighting
	elseif name == "Toxic" then
		Lighting.Ambient = Color3.fromRGB(80, 200, 60)
		Lighting.OutdoorAmbient = Color3.fromRGB(60, 160, 40)
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.TintColor = Color3.fromRGB(120, 255, 80)
		colorEffect.Contrast = 0.35
		colorEffect.Parent = Lighting
	elseif name == "Black & White" then
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.Saturation = -1
		colorEffect.Contrast = 0.25
		colorEffect.Parent = Lighting
	elseif name == "Cinematic" then
		Lighting.Brightness = 1.1
		colorEffect = Instance.new("ColorCorrectionEffect")
		colorEffect.Contrast = 0.3
		colorEffect.Saturation = -0.1
		colorEffect.Parent = Lighting
		bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Intensity = 0.5
		bloomEffect.Size = 35
		bloomEffect.Threshold = 1.1
		bloomEffect.Parent = Lighting
		blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 2
		blurEffect.Parent = Lighting
	end
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
	if filterTeams and isTeammate(plr) then return false end
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

local function updateTarget()
	if not silentOn then
		cachedPos, cachedPart = nil, nil
		return
	end
	local center = camera.ViewportSize * 0.5
	local origin = camera.CFrame.Position
	local best, bestScore = nil, -1e9
	for _, plr in ipairs(Players:GetPlayers()) do
		if isEnemy(plr) then
			local part = pickPart(plr.Character)
			local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if part and root then
				local velocity = root.AssemblyLinearVelocity
				local dist = (part.Position - origin).Magnitude
				local predictionTime = math.clamp(dist / 720, 0.09, 0.24)
				local predictedPos = part.Position + (velocity * predictionTime) + aimOffset
				if dist <= maxDist then
					local sp, on = camera:WorldToViewportPoint(predictedPos)
					local cross = on and (Vector2.new(sp.X, sp.Y) - center).Magnitude or 9999
					local score = 50000 - cross * 22 - dist * 0.03
					if part.Name == "Head" then score = score + 10000 end
					if score > bestScore then
						bestScore = score
						best = { pos = predictedPos, part = part }
					end
				end
			end
		end
	end
	if best then
		cachedPos, cachedPart = best.pos, best.part
	else
		cachedPos, cachedPart = nil, nil
	end
end

local function doKnifeTP()
	if not knifeTP then return end
	if tick() - lastKnifeTP < 0.35 then return end
	local myRoot = getRoot()
	local myHum = getHum()
	if not myRoot or not myHum or myHum.Health <= 0 then return end
	local preferred, preferredDist = nil, 9999
	local fallback, fallbackDist = nil, 9999
	for _, plr in ipairs(Players:GetPlayers()) do
		if isEnemy(plr) then
			local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				local dist = (root.Position - myRoot.Position).Magnitude
				if dist >= 18 and dist <= 45 and dist < preferredDist then
					preferredDist = dist
					preferred = root
				end
				if dist < fallbackDist and dist > 6 then
					fallbackDist = dist
					fallback = root
				end
			end
		end
	end
	local target = preferred or fallback
	if not target then return end
	local targetCF = target.CFrame * CFrame.new(0, -3.1, 0)
	for i = 1, 4 do
		myRoot.CFrame = targetCF
		myRoot.AssemblyLinearVelocity = Vector3.zero
		myRoot.AssemblyAngularVelocity = Vector3.zero
	end
	lastKnifeTP = tick()
end

local function setupSilent()
	if type(getrawmetatable) ~= "function" then return end
	local ok, mt = pcall(function() return getrawmetatable(mouse) end)
	if not ok or not mt then return end
	pcall(function()
		if setreadonly then setreadonly(mt, false) end
		local old = mt.__index
		mt.__index = newcclosure(function(self, key)
			if silentOn and cachedPos and cachedPart then
				if key == "Hit" then return CFrame.new(cachedPos) end
				if key == "Target" then return cachedPart end
				if key == "UnitRay" then
					return Ray.new(camera.CFrame.Position, (cachedPos - camera.CFrame.Position).Unit * 4000)
				end
			end
			return old(self, key)
		end)
		if setreadonly then setreadonly(mt, true) end
	end)
end

-- ESP MARKER (reemplazo seguro de Highlight)
local function clearVisuals()
	for _, data in pairs(espObjects) do
		pcall(function()
			if data.billboard then data.billboard:Destroy() end
		end)
	end
	table.clear(espObjects)
end

local function updateVisuals()
	if not (espOn or nameOn or distOn) then
		clearVisuals()
		return
	end

	local myRoot = getRoot()
	local seen = {}

	for _, plr in ipairs(Players:GetPlayers()) do
		if isEnemy(plr) and plr.Character then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			local head = plr.Character:FindFirstChild("Head")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if root and head and hum then
				local key = tostring(plr.UserId)
				seen[key] = true

				local data = espObjects[key]
				if not data or not data.billboard or not data.billboard.Parent then
					local bb = Instance.new("BillboardGui")
					bb.Name = "KX_ESP"
					bb.AlwaysOnTop = true
					bb.Size = UDim2.fromOffset(120, 40)
					bb.StudsOffset = Vector3.new(0, 3.2, 0)
					bb.Adornee = head
					bb.Parent = head

					local marker = Instance.new("Frame")
					marker.Name = "Marker"
					marker.Size = UDim2.fromOffset(12, 12)
					marker.Position = UDim2.new(0.5, -6, 0, 0)
					marker.BackgroundColor3 = espColor
					marker.BorderSizePixel = 0
					marker.Parent = bb
					Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)
					local stroke = Instance.new("UIStroke")
					stroke.Thickness = 1.5
					stroke.Color = Color3.fromRGB(255, 255, 255)
					stroke.Parent = marker

					local label = Instance.new("TextLabel")
					label.Name = "Info"
					label.BackgroundTransparency = 1
					label.Size = UDim2.new(1, 0, 0, 18)
					label.Position = UDim2.fromOffset(0, 14)
					label.Font = Enum.Font.GothamBold
					label.TextSize = 12
					label.TextColor3 = Color3.fromRGB(255, 255, 255)
					label.TextStrokeTransparency = 0.2
					label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					label.Text = ""
					label.Parent = bb

					data = { billboard = bb, marker = marker, label = label }
					espObjects[key] = data
				end

				-- actualizar color y texto
				if data.marker then
					data.marker.BackgroundColor3 = espColor
					data.marker.Visible = espOn
				end

				if data.label then
					local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0
					local txt = ""
					if nameOn then txt = plr.Name end
					if distOn then txt = txt .. (txt ~= "" and "  " or "") .. dist .. "m" end
					data.label.Text = txt
					data.label.Visible = (nameOn or distOn) and txt ~= ""
				end
			end
		end
	end

	for key, data in pairs(espObjects) do
		if not seen[key] then
			pcall(function() if data.billboard then data.billboard:Destroy() end end)
			espObjects[key] = nil
		end
	end
end

local function updateFovCircle()
	if not showFov then if fovCircle then fovCircle.Visible = false end return end
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

UserInputService.JumpRequest:Connect(function()
	if jumpOn then
		local h = getHum()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

localPlayer.CharacterAdded:Connect(function()
	task.wait(1.2)
	originalWalkSpeed = nil
	table.clear(originalCollision)
end)

local function loadWindUI()
	local urls = {
		"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
		"https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
	}
	for _, url in ipairs(urls) do
		local ok, lib = pcall(function() return loadstring(game:HttpGet(url))() end)
		if ok and lib then return lib end
	end
	return nil
end

local function startHub()
	local WindUI = loadWindUI()
	if not WindUI then return end
	pcall(setupSilent)

	local Window = WindUI:CreateWindow({
		Title = "KAISENX DUELS",
		Author = "created by KAISEN",
		Folder = "KaisenXDuels",
		Size = UDim2.fromOffset(520, 580),
		Transparent = true,
		Theme = "Crimson",
		Resizable = true,
		SideBarWidth = 140,
	})

	local function notify(title, content)
		pcall(function() WindUI:Notify({Title = title, Content = content, Duration = 3}) end)
	end

	local Home = Window:Tab({ Title = t("home"), Icon = "star" })
	Home:Paragraph({ Title = t("join_discord"), Desc = t("join_discord_desc") .. DISCORD_LINK, Image = DISCORD_IMG, ImageSize = 110 })
	Home:Button({ Title = t("copy_discord"), Callback = function()
		pcall(function() setclipboard(DISCORD_LINK) end)
		notify("Discord", t("link_copied"))
	end })
	Home:Paragraph({ Title = t("by_kaisen"), Desc = t("creator") })
	Home:Paragraph({ Title = t("tiktok"), Desc = TIKTOK_USER .. t("tiktok_desc"), Image = TIKTOK_IMG, ImageSize = 110 })
	Home:Button({ Title = t("copy_tiktok"), Callback = function()
		pcall(function() setclipboard("https://www.tiktok.com/" .. TIKTOK_USER) end)
		notify("TikTok", t("link_copied"))
	end })

	local Aim = Window:Tab({ Title = t("aimbot"), Icon = "crosshair" })
	Aim:Toggle({ Title = t("silent_aim"), Default = false, Callback = function(v) 
		silentOn = v 
		if not v then cachedPos, cachedPart = nil, nil end
	end })
	Aim:Dropdown({ Title = t("body_part"), Values = {"Head", "Torso", "Root"}, Value = "Head", Callback = function(v) aimPartName = v end })
	Aim:Toggle({ Title = t("show_fov"), Default = false, Callback = function(v) showFov = v end })
	Aim:Toggle({ Title = t("filter_team"), Default = true, Callback = function(v) filterTeams = v end })
	Aim:Slider({ Title = t("fov"), Value = {Min=80, Max=200, Default=160}, Callback = function(v) silentFov = v end })
	Aim:Slider({ Title = t("match_dist"), Value = {Min=80, Max=500, Default=250}, Callback = function(v) MATCH_DIST = v end })

	Aim:Paragraph({ Title = t("knife_tp"), Desc = t("knife_tp_warn") })
	Aim:Toggle({
		Title = t("knife_tp") .. " (20-40m)",
		Default = false,
		Callback = function(v)
			knifeTP = v
			if v then notify("⚠️ WARNING", t("knife_tp_warn")) end
		end
	})

	local Hitbox = Window:Tab({ Title = t("hitbox"), Icon = "box" })
	Hitbox:Toggle({
		Title = t("hitbox") .. " (RGB)",
		Default = false,
		Callback = function(v)
			hitboxEnabled = v
			if not v then clearHitboxes()
			else
				for _, plr in ipairs(Players:GetPlayers()) do createHitboxFor(plr) end
			end
		end
	})
	Hitbox:Slider({
		Title = t("hitbox_size") .. " (máx 35)",
		Value = {Min = 2, Max = 35, Default = 6},
		Step = 0.5,
		Callback = function(v) hitboxSize = v end
	})

	local Vis = Window:Tab({ Title = t("visuals"), Icon = "eye" })
	Vis:Toggle({ Title = t("esp"), Default = false, Callback = function(v) espOn = v if not v and not nameOn and not distOn then clearVisuals() end end })
	Vis:Toggle({ Title = t("names"), Default = false, Callback = function(v) nameOn = v end })
	Vis:Toggle({ Title = t("distance"), Default = false, Callback = function(v) distOn = v end })

	local Shaders = Window:Tab({ Title = t("shaders"), Icon = "sun" })
	Shaders:Dropdown({
		Title = "Shader",
		Values = {
			"None", "Fullbright", "Night Vision", "No Fog", "Soft Light",
			"High Contrast", "Cold", "Warm", "Cyber", "Cartoon", "Carton",
			"Paper", "Retro", "Toxic", "Black & White", "Cinematic"
		},
		Value = "None",
		Callback = function(name) applyShader(name) end
	})

	local Misc = Window:Tab({ Title = t("misc"), Icon = "settings" })
	Misc:Toggle({ Title = t("speed"), Default = false, Callback = function(v) speedOn = v setSpeed(v, walkSpeed) end })
	Misc:Slider({ Title = t("walkspeed"), Value = {Min=16, Max=50, Default=28}, Callback = function(v)
		walkSpeed = v
		if speedOn then setSpeed(true, walkSpeed) end
	end })
	Misc:Toggle({ Title = t("inf_jump"), Default = false, Callback = function(v) jumpOn = v end })
	Misc:Toggle({ Title = t("noclip"), Default = false, Callback = function(v) noclipOn = v setNoclip(v) end })

	local Set = Window:Tab({ Title = t("settings"), Icon = "settings" })
	Set:Dropdown({
		Title = t("theme"),
		Values = {"Dark", "Light", "Rose", "Indigo", "Crimson"},
		Value = "Crimson",
		Callback = function(name)
			pcall(function() if WindUI.SetTheme then WindUI:SetTheme(name) end end)
		end
	})
	Set:Dropdown({
		Title = t("language"),
		Values = {"English", "Español"},
		Value = (LANG == "es") and "Español" or "English",
		Callback = function(name)
			LANG = (name == "Español") and "es" or "en"
			saveLang(LANG)
			notify(t("language"), t("lang_hint"))
		end
	})

	RunService.RenderStepped:Connect(function()
		updateTarget()
		updateVisuals()
		updateFovCircle()
		updateHitboxes()
		if noclipOn then setNoclip(true) end
		if silentOn and cachedPos then
			if tick() - lastGunFire >= gunFireDelay then
				fireGunRemote(cachedPos)
				lastGunFire = tick()
			end
		end
		if knifeTP then doKnifeTP() end
	end)

	RunService.Heartbeat:Connect(function()
		if speedOn then setSpeed(true, walkSpeed) end
	end)
end

task.spawn(startHub)
