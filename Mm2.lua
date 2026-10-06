--[[
	KAISEN X | MM2 | Rayfield
	created by KAISEN
]]

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local DISCORD_LINK = "https://discord.gg/cs6eGYEGE"
local TIKTOK_USER = "@kaisen_x2"

-- ===== IDIOMA =====
local Lang = "ES"
if getgenv and (getgenv().KAISEN_LANG == "ES" or getgenv().KAISEN_LANG == "EN") then
	Lang = getgenv().KAISEN_LANG
end

local T = {
	ES = {
		home = "Inicio", combat = "Combate", farm = "Farmeo", visuals = "Visuales",
		shaders = "Shaders", player = "Jugador", extras = "Extras",
		title = "KAISEN X — MM2",
		copyDiscord = "Copiar Discord", copyTikTok = "Copiar TikTok",
		killAll = "Matar a todos", silent = "Silent Aim (Sheriff)",
		grabGun = "Agarrar pistola", autoGrab = "Auto agarrar pistola",
		flingM = "Fling asesino", flingS = "Fling sheriff", flingAll = "Fling a todos",
		flingTarget = "Objetivo fling", flingSel = "Fling seleccionado",
		reveal = "Revelar asesino",
		autoFarm = "Auto farmear monedas", farmSpeed = "Velocidad farm", farmRange = "Rango",
		roleEsp = "ESP roles", gunEsp = "ESP pistola", fullbright = "Fullbright", xray = "Rayos X",
		antiFling = "Anti fling", ghost = "Fantasma", godmode = "Godmode",
		walkSpeed = "Velocidad", jumpPower = "Salto", fly = "Volar",
		infJump = "Salto infinito", noclip = "Noclip",
		autoDodge = "Auto esquivar", fakeLag = "Fake lag", antiAfk = "Anti-AFK",
		fov = "FOV", rejoin = "Reentrar", lang = "Idioma",
		langSaved = "Idioma guardado. Vuelve a ejecutar el script.",
	},
	EN = {
		home = "Home", combat = "Combat", farm = "Farming", visuals = "Visuals",
		shaders = "Shaders", player = "Player", extras = "Extras",
		title = "KAISEN X — MM2",
		copyDiscord = "Copy Discord", copyTikTok = "Copy TikTok",
		killAll = "Kill All", silent = "Sheriff Silent Aim",
		grabGun = "Grab Gun", autoGrab = "Auto-Grab Gun",
		flingM = "Fling Murderer", flingS = "Fling Sheriff", flingAll = "Fling All",
		flingTarget = "Fling Target", flingSel = "Fling Selected",
		reveal = "Reveal Murderer",
		autoFarm = "Auto-Farm Coins", farmSpeed = "Farm Speed", farmRange = "Range",
		roleEsp = "Role ESP", gunEsp = "Gun ESP", fullbright = "Fullbright", xray = "X-Ray",
		antiFling = "Anti-Fling", ghost = "Ghost", godmode = "Godmode",
		walkSpeed = "WalkSpeed", jumpPower = "JumpPower", fly = "Fly",
		infJump = "Infinite Jump", noclip = "Noclip",
		autoDodge = "Auto Dodge", fakeLag = "Fake Lag", antiAfk = "Anti-AFK",
		fov = "FOV", rejoin = "Rejoin", lang = "Language",
		langSaved = "Language saved. Re-execute the script.",
	},
}
local function L(k)
	return (T[Lang] and T[Lang][k]) or k
end

local Window = Rayfield:CreateWindow({
	Name = "KAISEN X — MM2",
	LoadingTitle = "KAISEN X",
	LoadingSubtitle = "created by KAISEN",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false,
})

local KillAllActive, AutoFarmCoins = false, false
local FarmRange, FarmSpeed = 50, 28
local GodmodeEnabled, InvisibleEnabled = false, false
local ESP_Enabled, GunESP_Enabled, AutoGrabGunEnabled = false, false, false
local Noclip_Enabled, SilentAimEnabled, FullbrightEnabled = false, false, false
local InfJumpEnabled, AntiAFKEnabled = true, true
local Flying, FlySpeed = false, 50
local AutoDodgeEnabled, FakeLagEnabled = false, false
local AntiFlingEnabled = true
local SavedPositions, Highlights, GunHighlight = {}, {}, nil
local isGrabbingGun = false
local ghostConn = nil
local normalWalkSpeed = 16
local flingBusy = false
local FlingTargetName = nil
local farmIndex, farmList, farmRefresh = 1, {}, 0

local function wipeFX()
	for _, v in ipairs(Lighting:GetChildren()) do
		if tostring(v.Name):find("Kaisen") then pcall(function() v:Destroy() end) end
	end
end
local function fx(class, name)
	local e = Lighting:FindFirstChild(name)
	if not e then e = Instance.new(class) e.Name = name e.Parent = Lighting end
	return e
end
local function Shader_Noir()
	wipeFX()
	Lighting.Brightness, Lighting.ClockTime = 1.4, 20
	local cc = fx("ColorCorrectionEffect", "KaisenCC")
	cc.Saturation, cc.Contrast = -0.85, 0.35
	fx("BloomEffect", "KaisenBloom").Intensity = 0.6
end
local function Shader_WarmFilm()
	wipeFX()
	Lighting.Brightness, Lighting.ClockTime = 2.6, 16.5
	local cc = fx("ColorCorrectionEffect", "KaisenCC")
	cc.Saturation, cc.TintColor = 0.15, Color3.fromRGB(255, 230, 190)
end
local function Shader_NeonRain()
	wipeFX()
	Lighting.Brightness, Lighting.ClockTime = 1.8, 0
	local cc = fx("ColorCorrectionEffect", "KaisenCC")
	cc.Saturation, cc.TintColor = 0.45, Color3.fromRGB(180, 200, 255)
	fx("BloomEffect", "KaisenBloom").Intensity = 1.1
end
local function Shader_CleanHQ()
	wipeFX()
	Lighting.Brightness, Lighting.ClockTime = 2.5, 14
	local cc = fx("ColorCorrectionEffect", "KaisenCC")
	cc.Saturation, cc.Contrast = 0.12, 0.15
end
local function Shader_Reset()
	wipeFX()
	Lighting.Brightness, Lighting.ClockTime = 2, 14
	Lighting.Ambient = Color3.fromRGB(128, 128, 128)
end

LocalPlayer.Idled:Connect(function()
	if AntiAFKEnabled then
		pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
	end
end)

local function GetMurderer()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local b = p:FindFirstChild("Backpack")
			if p.Character:FindFirstChild("Knife") or (b and b:FindFirstChild("Knife")) then return p end
		end
	end
end

local function GetSheriff()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local b = p:FindFirstChild("Backpack")
			if p.Character:FindFirstChild("Gun") or (b and b:FindFirstChild("Gun")) then return p end
		end
	end
end

local function GetRoleColor(p)
	if not p or not p.Character then return Color3.fromRGB(50, 255, 100) end
	local b = p:FindFirstChild("Backpack")
	if p.Character:FindFirstChild("Knife") or (b and b:FindFirstChild("Knife")) then return Color3.fromRGB(255, 50, 50) end
	if p.Character:FindFirstChild("Gun") or (b and b:FindFirstChild("Gun")) then return Color3.fromRGB(50, 150, 255) end
	return Color3.fromRGB(50, 255, 100)
end

local function playerNames()
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then table.insert(t, p.Name) end
	end
	table.sort(t)
	if #t == 0 then table.insert(t, "—") end
	return t
end

local function findPlayer(name)
	if not name or name == "—" then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name == name or p.DisplayName == name then return p end
	end
	return Players:FindFirstChild(name)
end

local function GetDroppedGun()
	for _, i in ipairs(Workspace:GetChildren()) do
		if i.Name == "GunDrop" then return i end
		if i:IsA("Tool") and i.Name == "Gun" and i.Parent == Workspace then return i end
	end
	for _, folder in ipairs(Workspace:GetChildren()) do
		local g = folder:FindFirstChild("GunDrop", true)
		if g then return g end
	end
	return nil
end

local function hasGunAlready()
	local char, bp = LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack")
	return (char and char:FindFirstChild("Gun")) or (bp and bp:FindFirstChild("Gun"))
end

local function SafeGrabGun()
	if isGrabbingGun or hasGunAlready() then return end
	local gun, char = GetDroppedGun(), LocalPlayer.Character
	if not (gun and char) then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local handle = gun:FindFirstChild("Handle") or gun:FindFirstChildWhichIsA("BasePart") or (gun:IsA("BasePart") and gun)
	if not handle then return end
	isGrabbingGun = true
	local returnCF = hrp.CFrame
	hrp.CFrame = CFrame.new(handle.Position + Vector3.new(0, 2.5, 0))
	hrp.AssemblyLinearVelocity = Vector3.zero
	task.wait(0.08)
	if firetouchinterest then
		for _ = 1, 8 do
			pcall(function()
				firetouchinterest(hrp, handle, 0)
				task.wait(0.025)
				firetouchinterest(hrp, handle, 1)
			end)
			task.wait(0.03)
			if hasGunAlready() then break end
		end
	end
	task.wait(0.05)
	if hrp.Parent then
		hrp.CFrame = returnCF
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
	isGrabbingGun = false
end

local function FlingPlayer(targetPlayer)
	if flingBusy or not targetPlayer then return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local targetHrp = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetHrp then return end
	flingBusy = true
	local oldPos = hrp.CFrame
	local oldCollide = {}
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			oldCollide[p] = p.CanCollide
			p.CanCollide = false
		end
	end
	local bv = Instance.new("BodyAngularVelocity")
	bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bv.AngularVelocity = Vector3.new(0, 9e4, 0)
	bv.Parent = hrp
	local start = tick()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not hrp.Parent or not targetHrp.Parent or tick() - start > 1.4 then
			if conn then conn:Disconnect() end
			pcall(function() bv:Destroy() end)
			for p, col in pairs(oldCollide) do
				if p and p.Parent then p.CanCollide = col end
			end
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			hrp.CFrame = oldPos
			flingBusy = false
			return
		end
		hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0.5, 0)
		hrp.AssemblyLinearVelocity = Vector3.new(1, 1, 1) * 12000
	end)
end

local function FlingAll()
	task.spawn(function()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				FlingPlayer(p)
				task.wait(1.6)
			end
		end
	end)
end

local function SetGhostState(on)
	InvisibleEnabled = on
	if ghostConn then ghostConn:Disconnect() ghostConn = nil end
	local char = LocalPlayer.Character
	if not char then return end
	if on then
		ghostConn = RunService.RenderStepped:Connect(function()
			local c = LocalPlayer.Character
			if not c or not InvisibleEnabled then return end
			for _, o in ipairs(c:GetDescendants()) do
				if o:IsA("BasePart") or o:IsA("MeshPart") then
					o.LocalTransparencyModifier = 1
					pcall(function() o.CastShadow = false end)
				elseif o:IsA("Decal") or o:IsA("Texture") then
					o.Transparency = 1
				elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Fire") or o:IsA("Smoke") then
					o.Enabled = false
				elseif o:IsA("BillboardGui") or o:IsA("SurfaceGui") then
					o.Enabled = false
				end
			end
		end)
	else
		for _, o in ipairs(char:GetDescendants()) do
			if o:IsA("BasePart") or o:IsA("MeshPart") then
				o.LocalTransparencyModifier = 0
				if o.Name ~= "HumanoidRootPart" then o.Transparency = 0 end
			elseif o:IsA("Decal") or o:IsA("Texture") then
				o.Transparency = 0
			elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then
				o.Enabled = true
			end
		end
	end
end

local function isCoin(obj)
	if not obj or not obj:IsA("BasePart") or not obj.Parent then return false end
	local n = string.lower(obj.Name)
	if not (n == "coin" or n == "coin_sub" or n == "coinserver" or (string.find(n, "coin") and not string.find(n, "gui") and not string.find(n, "spawn"))) then
		return false
	end
	if obj.Transparency >= 0.95 or obj.Size.Magnitude > 12 or obj.Size.Magnitude < 0.15 then return false end
	return true
end

local function rebuildFarmList(hrp)
	farmList = {}
	for _, o in ipairs(Workspace:GetDescendants()) do
		if isCoin(o) then
			local d = (o.Position - hrp.Position).Magnitude
			if d <= FarmRange and math.abs(o.Position.Y - hrp.Position.Y) < 20 then
				table.insert(farmList, o)
			end
		end
	end
	table.sort(farmList, function(a, b)
		if math.abs(a.Position.X - b.Position.X) > 2 then return a.Position.X < b.Position.X end
		return a.Position.Z < b.Position.Z
	end)
	farmIndex = 1
	farmRefresh = tick()
end

local function touch(hrp, coin)
	if not firetouchinterest or not coin or not coin.Parent then return end
	pcall(function()
		firetouchinterest(hrp, coin, 0)
		task.wait(0.02)
		firetouchinterest(hrp, coin, 1)
	end)
end

task.spawn(function()
	while true do
		task.wait(0.1)
		if not AutoFarmCoins or isGrabbingGun then task.wait(0.15) continue end
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then task.wait(0.2) continue end
		hum.WalkSpeed = FarmSpeed
		if #farmList == 0 or tick() - farmRefresh > 4 then rebuildFarmList(hrp) end
		if #farmList == 0 then task.wait(0.3) continue end
		if farmIndex > #farmList then farmIndex = 1 end
		local coin = farmList[farmIndex]
		farmIndex += 1
		if not coin or not coin.Parent then continue end
		hum:MoveTo(coin.Position)
		local t0 = tick()
		while tick() - t0 < 1.6 and AutoFarmCoins and coin.Parent do
			if (hrp.Position - coin.Position).Magnitude < 8 then
				touch(hrp, coin)
				for _, c2 in ipairs(farmList) do
					if c2 ~= coin and c2.Parent and (c2.Position - hrp.Position).Magnitude < 9 then
						touch(hrp, c2)
					end
				end
				break
			end
			task.wait(0.07)
		end
		if not AutoFarmCoins then hum.WalkSpeed = normalWalkSpeed end
	end
end)

local function predictPos(part, lead)
	local vel = Vector3.zero
	pcall(function() vel = part.AssemblyLinearVelocity end)
	return part.Position + vel * lead
end

local function ShootAtMurderer()
	local murd, char = GetMurderer(), LocalPlayer.Character
	if not (murd and murd.Character and char) then return end
	local head = murd.Character:FindFirstChild("Head")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not head or not hrp then return end
	local gun = char:FindFirstChild("Gun") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun"))
	if not gun then return end
	if gun.Parent == LocalPlayer.Backpack then char.Humanoid:EquipTool(gun) task.wait(0.03) end
	if not gun:FindFirstChild("Shoot") then return end
	local dist = (head.Position - hrp.Position).Magnitude
	local pred = predictPos(head, math.clamp(dist / 90, 0.08, 0.35)) + Vector3.new(0, 0.3, 0)
	gun.Shoot:FireServer(CFrame.new(hrp.Position, pred), CFrame.new(pred))
end

local function SetupSilentAim(character)
	if not character then return end
	character.ChildAdded:Connect(function(c)
		if c:IsA("Tool") and c.Name == "Gun" then
			c.Activated:Connect(function() if SilentAimEnabled then ShootAtMurderer() end end)
		end
	end)
	local g = character:FindFirstChild("Gun")
	if g then g.Activated:Connect(function() if SilentAimEnabled then ShootAtMurderer() end end) end
end
if LocalPlayer.Character then SetupSilentAim(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(c)
	SetupSilentAim(c)
	task.wait(0.4)
	if InvisibleEnabled then SetGhostState(true) end
end)

task.spawn(function()
	while true do
		RunService.RenderStepped:Wait()
		if Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local hrp, d = LocalPlayer.Character.HumanoidRootPart, Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then d += camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then d -= camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then d -= camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then d += camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d -= Vector3.new(0, 1, 0) end
			hrp.AssemblyLinearVelocity = d * FlySpeed
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		if AutoDodgeEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local murd = GetMurderer()
			if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart") then
				local my = LocalPlayer.Character.HumanoidRootPart
				if (my.Position - murd.Character.HumanoidRootPart.Position).Magnitude < 12 then
					my.CFrame = my.CFrame * CFrame.new(0, 15, -20)
				end
			end
		end
	end
end)

RunService.Stepped:Connect(function()
	if Noclip_Enabled and LocalPlayer.Character then
		for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
	if GodmodeEnabled and LocalPlayer.Character then
		local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if h then h.Health = h.MaxHealth end
	end
	if AntiFlingEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = LocalPlayer.Character.HumanoidRootPart
		if hrp.AssemblyLinearVelocity.Magnitude > 350 or hrp.AssemblyAngularVelocity.Magnitude > 350 then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end
	end
	if FakeLagEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character.HumanoidRootPart.Anchored = true
		task.wait(0.05)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.Anchored = false
		end
	end
end)

RunService.RenderStepped:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if ESP_Enabled then
				local hl = Highlights[player]
				if not hl or hl.Parent ~= player.Character then
					if hl then hl:Destroy() end
					hl = Instance.new("Highlight")
					hl.Parent = player.Character
					Highlights[player] = hl
				end
				local col = GetRoleColor(player)
				hl.FillColor, hl.OutlineColor, hl.FillTransparency = col, col, 0.5
			elseif Highlights[player] then
				Highlights[player]:Destroy()
				Highlights[player] = nil
			end
		end
	end
	local dg = GetDroppedGun()
	if dg then
		if GunESP_Enabled then
			if not GunHighlight or GunHighlight.Parent ~= dg then
				if GunHighlight then GunHighlight:Destroy() end
				GunHighlight = Instance.new("Highlight")
				GunHighlight.Parent = dg
				GunHighlight.FillColor = Color3.fromRGB(255, 255, 0)
				GunHighlight.OutlineColor = Color3.fromRGB(255, 215, 0)
				GunHighlight.FillTransparency = 0.2
			end
		elseif GunHighlight then
			GunHighlight:Destroy()
			GunHighlight = nil
		end
		if AutoGrabGunEnabled and not isGrabbingGun and not hasGunAlready() then
			task.defer(SafeGrabGun)
		end
	elseif GunHighlight then
		GunHighlight:Destroy()
		GunHighlight = nil
	end
	if FullbrightEnabled then
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.Brightness = 2
	end
end)

task.spawn(function()
	while true do
		task.wait(0.05)
		if KillAllActive then
			local myChar = LocalPlayer.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") then
				local myHrp = myChar.HumanoidRootPart
				local knife = myChar:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
				if knife then
					if knife.Parent == LocalPlayer.Backpack then myChar.Humanoid:EquipTool(knife) end
					knife:Activate()
				end
				for _, t in pairs(Players:GetPlayers()) do
					if t ~= LocalPlayer and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
						local th = t.Character.HumanoidRootPart
						if not SavedPositions[t] then SavedPositions[t] = th.CFrame end
						th.CFrame = myHrp.CFrame * CFrame.new(0, 0, -2.5)
					end
				end
			end
		elseif next(SavedPositions) then
			for t, cf in pairs(SavedPositions) do
				if t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
					t.Character.HumanoidRootPart.CFrame = cf
				end
			end
			SavedPositions = {}
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if InfJumpEnabled and LocalPlayer.Character then
		local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- ===== UI (con idioma) =====
local TabHome = Window:CreateTab(L("home"), 4483362458)
TabHome:CreateParagraph({ Title = L("title"), Content = "created by KAISEN" })
TabHome:CreateDropdown({
	Name = L("lang"),
	Options = { "ES", "EN" },
	CurrentOption = { Lang },
	Flag = "Lang",
	Callback = function(o)
		local v = type(o) == "table" and o[1] or o
		Lang = v
		if getgenv then getgenv().KAISEN_LANG = v end
		pcall(function()
			Rayfield:Notify({ Title = "KAISEN X", Content = L("langSaved"), Duration = 4 })
		end)
	end,
})
TabHome:CreateButton({ Name = L("copyDiscord"), Callback = function() pcall(function() if setclipboard then setclipboard(DISCORD_LINK) end end) end })
TabHome:CreateButton({ Name = L("copyTikTok"), Callback = function() pcall(function() if setclipboard then setclipboard(TIKTOK_USER) end end) end })

local TabCombat = Window:CreateTab(L("combat"), 4483362458)
TabCombat:CreateToggle({ Name = L("killAll"), CurrentValue = false, Flag = "KillAll", Callback = function(v) KillAllActive = v end })
TabCombat:CreateToggle({ Name = L("silent"), CurrentValue = false, Flag = "Silent", Callback = function(v) SilentAimEnabled = v end })
TabCombat:CreateButton({ Name = L("grabGun"), Callback = function() SafeGrabGun() end })
TabCombat:CreateToggle({ Name = L("autoGrab"), CurrentValue = false, Flag = "AutoGun", Callback = function(v) AutoGrabGunEnabled = v end })
TabCombat:CreateButton({ Name = L("flingM"), Callback = function() local m = GetMurderer() if m then FlingPlayer(m) end end })
TabCombat:CreateButton({ Name = L("flingS"), Callback = function() local s = GetSheriff() if s then FlingPlayer(s) end end })
TabCombat:CreateButton({ Name = L("flingAll"), Callback = function() FlingAll() end })
TabCombat:CreateDropdown({
	Name = L("flingTarget"),
	Options = playerNames(),
	CurrentOption = { playerNames()[1] },
	Flag = "FlingTarget",
	Callback = function(o) FlingTargetName = type(o) == "table" and o[1] or o end,
})
TabCombat:CreateButton({
	Name = L("flingSel"),
	Callback = function()
		local p = findPlayer(FlingTargetName)
		if p then FlingPlayer(p) end
	end,
})
TabCombat:CreateButton({
	Name = L("reveal"),
	Callback = function()
		local m = GetMurderer()
		if m then
			local msg = "The Murderer is: " .. m.DisplayName .. " (@" .. m.Name .. ")"
			pcall(function()
				local ce = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
				if ce and ce:FindFirstChild("SayMessageRequest") then
					ce.SayMessageRequest:FireServer(msg, "All")
				elseif TextChatService:FindFirstChild("TextChannels") then
					local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
					if ch then ch:SendAsync(msg) end
				end
			end)
		end
	end,
})

local TabFarm = Window:CreateTab(L("farm"), 4483362458)
TabFarm:CreateToggle({
	Name = L("autoFarm"),
	CurrentValue = false,
	Flag = "Farm",
	Callback = function(v)
		AutoFarmCoins = v
		farmList = {}
		if not v then
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = normalWalkSpeed end
		end
	end,
})
TabFarm:CreateSlider({ Name = L("farmSpeed"), Range = { 20, 40 }, Increment = 1, CurrentValue = 28, Flag = "FarmSpeed", Callback = function(v) FarmSpeed = v end })
TabFarm:CreateSlider({ Name = L("farmRange"), Range = { 20, 70 }, Increment = 1, CurrentValue = 50, Flag = "FarmRange", Callback = function(v) FarmRange = v end })

local TabVisual = Window:CreateTab(L("visuals"), 4483362458)
TabVisual:CreateToggle({ Name = L("roleEsp"), CurrentValue = false, Flag = "ESP", Callback = function(v) ESP_Enabled = v end })
TabVisual:CreateToggle({ Name = L("gunEsp"), CurrentValue = false, Flag = "GunESP", Callback = function(v) GunESP_Enabled = v end })
TabVisual:CreateToggle({
	Name = L("fullbright"),
	CurrentValue = false,
	Flag = "FB",
	Callback = function(v)
		FullbrightEnabled = v
		if not v then Lighting.Brightness = 1 Lighting.Ambient = Color3.fromRGB(128, 128, 128) end
	end,
})
TabVisual:CreateToggle({
	Name = L("xray"),
	CurrentValue = false,
	Flag = "Xray",
	Callback = function(state)
		for _, part in pairs(Workspace:GetDescendants()) do
			if part:IsA("BasePart") and not part.Parent:FindFirstChildOfClass("Humanoid") then
				part.LocalTransparencyModifier = state and 0.6 or 0
			end
		end
	end,
})

local TabShaders = Window:CreateTab(L("shaders"), 4483362458)
TabShaders:CreateButton({ Name = "Noir", Callback = Shader_Noir })
TabShaders:CreateButton({ Name = "Warm Film", Callback = Shader_WarmFilm })
TabShaders:CreateButton({ Name = "Neon Rain", Callback = Shader_NeonRain })
TabShaders:CreateButton({ Name = "Clean HQ", Callback = Shader_CleanHQ })
TabShaders:CreateButton({ Name = "Reset", Callback = Shader_Reset })

local TabPlayer = Window:CreateTab(L("player"), 4483362458)
TabPlayer:CreateToggle({ Name = L("antiFling"), CurrentValue = true, Flag = "AntiFling", Callback = function(v) AntiFlingEnabled = v end })
TabPlayer:CreateToggle({ Name = L("ghost"), CurrentValue = false, Flag = "Ghost", Callback = function(v) SetGhostState(v) end })
TabPlayer:CreateToggle({ Name = L("godmode"), CurrentValue = false, Flag = "God", Callback = function(v) GodmodeEnabled = v end })
TabPlayer:CreateSlider({
	Name = L("walkSpeed"), Range = { 16, 120 }, Increment = 1, CurrentValue = 16, Flag = "WS",
	Callback = function(v)
		normalWalkSpeed = v
		if not AutoFarmCoins then
			local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if h then h.WalkSpeed = v end
		end
	end,
})
TabPlayer:CreateSlider({
	Name = L("jumpPower"), Range = { 50, 200 }, Increment = 1, CurrentValue = 50, Flag = "JP",
	Callback = function(v)
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if h then h.JumpPower = v end
	end,
})
TabPlayer:CreateToggle({ Name = L("fly"), CurrentValue = false, Flag = "Fly", Callback = function(v) Flying = v end })
TabPlayer:CreateToggle({ Name = L("infJump"), CurrentValue = true, Flag = "InfJ", Callback = function(v) InfJumpEnabled = v end })
TabPlayer:CreateToggle({ Name = L("noclip"), CurrentValue = false, Flag = "Noclip", Callback = function(v) Noclip_Enabled = v end })

local TabExtras = Window:CreateTab(L("extras"), 4483362458)
TabExtras:CreateToggle({ Name = L("autoDodge"), CurrentValue = false, Flag = "Dodge", Callback = function(v) AutoDodgeEnabled = v end })
TabExtras:CreateToggle({ Name = L("fakeLag"), CurrentValue = false, Flag = "Lag", Callback = function(v) FakeLagEnabled = v end })
TabExtras:CreateToggle({ Name = L("antiAfk"), CurrentValue = true, Flag = "AFK", Callback = function(v) AntiAFKEnabled = v end })
TabExtras:CreateSlider({ Name = L("fov"), Range = { 70, 120 }, Increment = 1, CurrentValue = 70, Flag = "FOV", Callback = function(v) camera.FieldOfView = v end })
TabExtras:CreateButton({ Name = L("rejoin"), Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })
