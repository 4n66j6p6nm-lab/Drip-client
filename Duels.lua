print("✅ KAISENX DUELS | created by KAISEN | loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()

local DISCORD_LINK = "https://discord.gg/xWPp9kxTs"
local TIKTOK_USER = "@kaisen_x2"
local DISCORD_IMG = "rbxassetid://16584754883"
local TIKTOK_IMG = "rbxassetid://140658929749855"

local LICENSE_FILE = "kaisenx_duels_license.txt"
local LICENSE_HOURS = 5

-- ===================== LICENCIA 5 HORAS =====================
local function hasValidLicense()
	local ok, data = pcall(function()
		if isfile and isfile(LICENSE_FILE) then
			return readfile(LICENSE_FILE)
		end
		return nil
	end)
	if not ok or not data then return false end
	local expire = tonumber(data)
	if not expire then return false end
	return os.time() < expire
end

local function saveLicense()
	local expire = os.time() + (LICENSE_HOURS * 3600)
	pcall(function()
		if writefile then
			writefile(LICENSE_FILE, tostring(expire))
		end
	end)
end

local function showLicense()
	if hasValidLicense() then
		return true
	end

	local sg = Instance.new("ScreenGui")
	sg.Name = "KaisenXLicense"
	sg.IgnoreGuiInset = true
	sg.ResetOnSpawn = false
	pcall(function() sg.Parent = CoreGui end)
	if not sg.Parent then sg.Parent = localPlayer:WaitForChild("PlayerGui") end

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	bg.BackgroundTransparency = 0.25
	bg.Parent = sg

	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(350, 250)
	card.Position = UDim2.new(0.5, -175, 0.5, -125)
	card.BackgroundColor3 = Color3.fromRGB(18, 16, 28)
	card.Parent = bg
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.fromOffset(0, 18)
	title.BackgroundTransparency = 1
	title.Text = "KAISENX DUELS"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 40)
	sub.Position = UDim2.fromOffset(0, 55)
	sub.BackgroundTransparency = 1
	sub.Text = "Elige una versión\n(PAID dura 5 horas)"
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 14
	sub.TextColor3 = Color3.fromRGB(170, 170, 190)
	sub.Parent = card

	local function makeBtn(text, y, color)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(270, 44)
		btn.Position = UDim2.new(0.5, -135, 0, y)
		btn.BackgroundColor3 = color
		btn.Text = text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 16
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Parent = card
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
		return btn
	end

	local paidBtn = makeBtn("PAID VERSION", 115, Color3.fromRGB(0, 170, 110))
	local freeBtn = makeBtn("FREE VERSION", 170, Color3.fromRGB(190, 40, 40))
	local chosen = false
	local success = false

	paidBtn.MouseButton1Click:Connect(function()
		if chosen then return end
		chosen = true
		saveLicense()
		success = true
		sg:Destroy()
	end)

	freeBtn.MouseButton1Click:Connect(function()
		if chosen then return end
		chosen = true
		sg:Destroy()
		task.wait(0.25)
		localPlayer:Kick("JAJAJAJA qué puto retrasado mental 😂 elegiste FREE sabiendo que es mentira. Eres un inútil completo, no tienes ni dos neuronas. Vuelve a ejecutar y dale a PAID, escoria.")
	end)

	while sg.Parent do
		task.wait(0.1)
	end

	return success
end

if not showLicense() and not hasValidLicense() then
	return
end

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
		home = "Home", aimbot = "Aimbot", visuals = "Visuals", misc = "Misc", settings = "Settings",
		join_discord = "Join our Discord", join_discord_desc = "Join our official community.\n",
		copy_discord = "Copy Discord", by_kaisen = "By: KAISEN", creator = "Creator of KAISENX",
		tiktok = "TikTok", tiktok_desc = "\nClips & updates", copy_tiktok = "Copy TikTok",
		silent_aim = "Silent Aim", silent_desc = "You equip the weapon", body_part = "Body Part",
		show_fov = "Show FOV Circle", filter_team = "Filter Team", fov = "FOV", match_dist = "Match Dist",
		lines = "Lines", boxes = "Boxes", health = "Health", names = "Names",
		speed = "Speed", walkspeed = "WalkSpeed", inf_jump = "Infinite Jump", noclip = "Noclip",
		theme = "Menu Theme", language = "Language", lang_hint = "Re-execute to apply language",
		loaded = "Hub loaded", link_copied = "Link copied!", hitbox = "Hitbox", hitbox_size = "Hitbox Size",
		knife_tp = "Knife TP (Under Enemy)",
		knife_tp_warn = "⚠️ HIGH RISK OF KICK / BAN. Use at your own risk.",
	},
	es = {
		home = "Inicio", aimbot = "Aimbot", visuals = "Visuales", misc = "Misc", settings = "Ajustes",
		join_discord = "Únete a nuestro Discord", join_discord_desc = "Únete a nuestra comunidad.\n",
		copy_discord = "Copiar Discord", by_kaisen = "Por: KAISEN", creator = "Creador de KAISENX",
		tiktok = "TikTok", tiktok_desc = "\nClips y updates", copy_tiktok = "Copiar TikTok",
		silent_aim = "Silent Aim", silent_desc = "Tú sacas el arma", body_part = "Parte del cuerpo",
		show_fov = "Mostrar círculo FOV", filter_team = "Filtrar equipo", fov = "FOV", match_dist = "Distancia",
		lines = "Líneas", boxes = "Cajas", health = "Vida", names = "Nombres",
		speed = "Velocidad", walkspeed = "WalkSpeed", inf_jump = "Salto infinito", noclip = "Noclip",
		theme = "Tema", language = "Idioma", lang_hint = "Vuelve a ejecutar para aplicar",
		loaded = "Hub cargado", link_copied = "¡Link copiado!", hitbox = "Hitbox", hitbox_size = "Tamaño Hitbox",
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
local silentFov = 280
local maxDist = 450
local MATCH_DIST = 250
local filterTeams = true
local aimOffset = Vector3.new(0, -0.35, 0)
local knifeTP = false
local lastKnifeTP = 0

-- GUN
local GUN_GUID = "501fb32e-88ee-4941-b677-ab1cd9e0b2eb"
local lastGunFire = 0
local gunFireDelay = 0.11

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

-- HITBOX (máx 35)
local hitboxEnabled = false
local hitboxSize = 6
local maxHitboxSize = 35
local hitboxParts = {}
local rgbSpeed = 1.8

local function getRGBColor()
	local t = tick() * rgbSpeed
	return Color3.new(
		math.sin(t) * 0.5 + 0.5,
		math.sin(t + 2) * 0.5 + 0.5,
		math.sin(t + 4) * 0.5 + 0.5
	)
end

local function clearHitboxes()
	for _, v in pairs(hitboxParts) do
		pcall(function() v:Destroy() end)
	end
	table.clear(hitboxParts)
end

-- ===================== FILTER TEAM SIMPLE =====================
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

	if filterTeams and isTeammate(player) then
		return
	end

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
		if hitboxEnabled then
			createHitboxFor(player)
		end
	end)
end

for _, plr in ipairs(Players:GetPlayers()) do
	hookCharacter(plr)
end
Players.PlayerAdded:Connect(hookCharacter)

-- VISUALS + RESTO
local lineOn, boxOn, hpOn, nameOn = false, false, false, false
local espColor = Color3.fromRGB(255, 140, 40)
local espObjs = {}
local speedOn, jumpOn, noclipOn = false, false, false
local walkSpeed = 28
local cachedPos, cachedPart = nil, nil
local fovCircle = nil
local originalWalkSpeed = nil
local originalCollision = {}

local function safeNotify(WindUI, title, content)
	pcall(function()
		if WindUI and WindUI.Notify then
			WindUI:Notify({ Title = title, Content = content, Duration = 3 })
		end
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
	if filterTeams and isTeammate(plr) then
		return false
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
			if part then
				local pos = part.Position + aimOffset
				local dist = (pos - origin).Magnitude
				if dist <= maxDist then
					local sp, on = camera:WorldToViewportPoint(pos)
					local cross = on and (Vector2.new(sp.X, sp.Y) - center).Magnitude or 9999
					local score = 40000 - cross * 28 - dist * 0.04
					if part.Name == "Head" then score = score + 4000 end
					if score > bestScore then
						bestScore = score
						best = { pos = pos, part = part }
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

-- ===================== KNIFE TP (20 - 40 metros) =====================
local function doKnifeTP()
	if not knifeTP then return end
	if tick() - lastKnifeTP < 0.40 then return end

	local myRoot = getRoot()
	if not myRoot then return end

	local bestTarget = nil
	local bestDist = 9999

	for _, plr in ipairs(Players:GetPlayers()) do
		if isEnemy(plr) then
			local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				local dist = (root.Position - myRoot.Position).Magnitude
				-- Solo enemigos entre 20 y 40 metros
				if dist >= 20 and dist <= 40 then
					if dist < bestDist then
						bestDist = dist
						bestTarget = root
					end
				end
			end
		end
	end

	if bestTarget then
		-- Teleport debajo de los pies
		myRoot.CFrame = bestTarget.CFrame * CFrame.new(0, -3.2, 0)
		lastKnifeTP = tick()
	end
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

local function clearEsp()
	for _, v in pairs(espObjs) do pcall(function() if v then v:Destroy() end end) end
	table.clear(espObjs)
end

local function updateEsp()
	if not (lineOn or boxOn or hpOn or nameOn) then clearEsp() return end
	local parent = CoreGui
	pcall(function() if gethui then parent = gethui() end end)
	local draw = parent:FindFirstChild("KXDraw") or Instance.new("ScreenGui")
	draw.Name = "KXDraw"
	draw.IgnoreGuiInset = true
	draw.Parent = parent

	local myRoot = getRoot()
	local seen = {}

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
					if lineOn then
						local line = espObjs["l"..key]
						if not line or not line.Parent then
							line = Instance.new("Frame")
							line.BorderSizePixel = 0
							line.AnchorPoint = Vector2.new(0.5, 0.5)
							line.BackgroundColor3 = espColor
							line.Parent = draw
							espObjs["l"..key] = line
						end
						local top = Vector2.new(camera.ViewportSize.X/2, 0)
						local mid = (top + Vector2.new(sp.X, sp.Y)) / 2
						local dist = (top - Vector2.new(sp.X, sp.Y)).Magnitude
						line.Size = UDim2.fromOffset(math.max(dist, 1), 1.5)
						line.Position = UDim2.fromOffset(mid.X, mid.Y)
						line.Rotation = math.deg(math.atan2(sp.Y - top.Y, sp.X - top.X))
						line.BackgroundColor3 = espColor
						line.Visible = true
					end
					if boxOn then
						local box = espObjs["b"..key]
						if not box or not box.Parent then
							box = Instance.new("Frame")
							box.BackgroundTransparency = 1
							box.Parent = draw
							local s = Instance.new("UIStroke")
							s.Thickness = 1.6
							s.Parent = box
							espObjs["b"..key] = box
						end
						local st = box:FindFirstChildOfClass("UIStroke")
						if st then st.Color = espColor end
						box.Size = UDim2.fromOffset(42, 66)
						box.Position = UDim2.fromOffset(sp.X - 21, sp.Y - 14)
						box.Visible = true
					end
					if nameOn or hpOn then
						local lbl = espObjs["n"..key]
						if not lbl or not lbl.Parent then
							lbl = Instance.new("TextLabel")
							lbl.BackgroundTransparency = 1
							lbl.Size = UDim2.fromOffset(160, 18)
							lbl.Font = Enum.Font.GothamBold
							lbl.TextSize = 13
							lbl.TextColor3 = Color3.fromRGB(240, 240, 245)
							lbl.TextStrokeTransparency = 0.3
							lbl.Parent = draw
							espObjs["n"..key] = lbl
						end
						local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0
						local txt = ""
						if nameOn then txt = plr.Name end
						if hpOn then txt = txt .. string.format(" [%dhp]", math.floor(hum.Health)) end
						txt = txt .. string.format(" %dm", dist)
						lbl.Text = txt
						lbl.Position = UDim2.fromOffset(sp.X - 80, sp.Y - 32)
						lbl.Visible = true
					end
				end
			end
		end
	end
	for key, obj in pairs(espObjs) do
		if not seen[key:gsub("%a","")] and not seen[key] then
			pcall(function() obj:Destroy() end)
			espObjs[key] = nil
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
		Size = UDim2.fromOffset(520, 560),
		Transparent = true,
		Theme = "Crimson",
		Resizable = true,
		SideBarWidth = 140,
	})

	local function notify(title, content)
		pcall(function() WindUI:Notify({Title = title, Content = content, Duration = 4}) end)
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
	Aim:Slider({ Title = t("fov"), Value = {Min=100, Max=450, Default=280}, Callback = function(v) silentFov = v end })
	Aim:Slider({ Title = t("match_dist"), Value = {Min=80, Max=500, Default=250}, Callback = function(v) MATCH_DIST = v end })

	-- KNIFE TP
	Aim:Paragraph({ Title = t("knife_tp"), Desc = t("knife_tp_warn") })
	Aim:Toggle({
		Title = t("knife_tp") .. " (20-40m)",
		Default = false,
		Callback = function(v)
			knifeTP = v
			if v then
				notify("⚠️ WARNING", t("knife_tp_warn"))
			end
		end
	})

	local Hitbox = Window:Tab({ Title = t("hitbox"), Icon = "box" })
	Hitbox:Toggle({
		Title = t("hitbox") .. " (RGB)",
		Default = false,
		Callback = function(v)
			hitboxEnabled = v
			if not v then
				clearHitboxes()
			else
				for _, plr in ipairs(Players:GetPlayers()) do
					createHitboxFor(plr)
				end
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
	Vis:Toggle({ Title = t("lines"), Default = false, Callback = function(v) lineOn = v end })
	Vis:Toggle({ Title = t("boxes"), Default = false, Callback = function(v) boxOn = v end })
	Vis:Toggle({ Title = t("names"), Default = false, Callback = function(v) nameOn = v end })
	Vis:Toggle({ Title = t("health"), Default = false, Callback = function(v) hpOn = v end })

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
		updateEsp()
		updateFovCircle()
		updateHitboxes()
		if noclipOn then setNoclip(true) end

		if silentOn and cachedPos then
			if tick() - lastGunFire >= gunFireDelay then
				fireGunRemote(cachedPos)
				lastGunFire = tick()
			end
		end

		if knifeTP then
			doKnifeTP()
		end
	end)

	RunService.Heartbeat:Connect(function()
		if speedOn then setSpeed(true, walkSpeed) end
	end)

	notify("KAISENX", t("loaded"))
end

task.spawn(startHub)
