--[[
	KAISEN X | MM2 | Luna UI
	created by KAISEN
]]

local Luna
local success, err = pcall(function()
	local urls = {
		"https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua",
		"https://raw.githubusercontent.com/Snxdfer/back-ups-for-libs/refs/heads/main/Luna_Source.lua",
		"https://pastebin.com/raw/10291932"
	}
	for _, url in ipairs(urls) do
		local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
		if ok and res then
			Luna = res
			break
		end
	end
end)

if not Luna then
	warn("[KAISEN X] Failed to load Luna UI Library: ", err)
	return
end

-- HIDE / REMOVE NOTIFICATIONS
local CoreGui = game:GetService("CoreGui")
local function RemoveNotify()
	pcall(function()
		for _, v in pairs(CoreGui:GetDescendants()) do
			if v:IsA("TextLabel") and (string.find(v.Text, "Interface Hidden") or string.find(v.Text, "reopen the interface")) then
				local parentFrame = v:FindFirstAncestorOfClass("Frame") or v.Parent
				if parentFrame then parentFrame:Destroy() else v:Destroy() end
			end
		end
	end)
end

CoreGui.DescendantAdded:Connect(function(descendant)
	task.wait(0.05)
	if descendant:IsA("TextLabel") and (string.find(descendant.Text, "Interface Hidden") or string.find(descendant.Text, "reopen the interface")) then
		local parentFrame = descendant:FindFirstAncestorOfClass("Frame") or descendant.Parent
		if parentFrame then parentFrame:Destroy() else descendant:Destroy() end
	end
end)
RemoveNotify()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local DISCORD_LINK = "https://discord.gg/cs6eGYEGE"
local TIKTOK_USER = "@kaisen_x2"

-- SCRIPT STATES
local KillAllActive, AutoFarmCoins, FarmDelay = false, false, 0.35
local GodmodeEnabled, InvisibleEnabled = false, false
local ESP_Enabled, GunESP_Enabled, AutoGrabGunEnabled = false, false, false
local Noclip_Enabled, SilentAimEnabled, FullbrightEnabled = false, false, false
local InfJumpEnabled, AntiAFKEnabled = true, true
local Flying, FlySpeed = false, 50
local AutoDodgeEnabled, FakeLagEnabled = false, false
local AntiFlingEnabled = true
local SavedPositions, Highlights, GunHighlight = {}, {}, nil
local isGrabbingGun, isFarming = false, false

-- ADVANCED SHADERS SYSTEM
local ShadersFolder = Lighting:FindFirstChild("KaisenX_Shaders")
if not ShadersFolder then
	ShadersFolder = Instance.new("Folder")
	ShadersFolder.Name = "KaisenX_Shaders"
	ShadersFolder.Parent = Lighting
end

local function ClearShaders()
	for _, child in ipairs(ShadersFolder:GetChildren()) do
		child:Destroy()
	end
	Lighting.GlobalShadows = true
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	Lighting.Ambient = Color3.fromRGB(128, 128, 128)
	Lighting.ExposureCompensation = 0
end

local function GetOrCreateEffect(className, name)
	local effect = ShadersFolder:FindFirstChild(name)
	if not effect then
		effect = Instance.new(className)
		effect.Name = name
		effect.Parent = ShadersFolder
	end
	return effect
end

-- HIGH QUALITY PRESETS
local function ApplyRTXOverhaul()
	ClearShaders()
	Lighting.GlobalShadows = true
	Lighting.Brightness = 2.8
	Lighting.OutdoorAmbient = Color3.fromRGB(135, 140, 150)
	Lighting.Ambient = Color3.fromRGB(90, 95, 105)
	Lighting.ExposureCompensation = 0.15
	Lighting.ClockTime = 15

	local bloom = GetOrCreateEffect("BloomEffect", "Bloom")
	bloom.Intensity = 0.45
	bloom.Size = 18
	bloom.Threshold = 0.85

	local cc = GetOrCreateEffect("ColorCorrectionEffect", "ColorCorrection")
	cc.Brightness = 0.02
	cc.Contrast = 0.22
	cc.Saturation = 0.25
	cc.TintColor = Color3.fromRGB(255, 252, 245)

	local sunRays = GetOrCreateEffect("SunRaysEffect", "SunRays")
	sunRays.Intensity = 0.3
	sunRays.Spread = 0.85

	local atmosphere = GetOrCreateEffect("Atmosphere", "Atmosphere")
	atmosphere.Density = 0.28
	atmosphere.Offset = 0.25
	atmosphere.Color = Color3.fromRGB(220, 200, 170)
	atmosphere.Decay = Color3.fromRGB(120, 130, 150)
	atmosphere.Haze = 1.2
	atmosphere.Glares = 0.4

	local dof = GetOrCreateEffect("DepthOfFieldEffect", "DepthOfField")
	dof.FarIntensity = 0.15
	dof.FocusDistance = 25
	dof.InFocusRadius = 20
	dof.NearIntensity = 0.1
end

local function ApplyCinematicNight()
	ClearShaders()
	Lighting.GlobalShadows = true
	Lighting.Brightness = 1.2
	Lighting.ClockTime = 0
	Lighting.OutdoorAmbient = Color3.fromRGB(20, 25, 45)
	Lighting.Ambient = Color3.fromRGB(15, 20, 35)
	Lighting.ExposureCompensation = 0.1

	local bloom = GetOrCreateEffect("BloomEffect", "Bloom")
	bloom.Intensity = 1.2
	bloom.Size = 32
	bloom.Threshold = 0.5

	local cc = GetOrCreateEffect("ColorCorrectionEffect", "ColorCorrection")
	cc.Brightness = 0.03
	cc.Contrast = 0.35
	cc.Saturation = 0.3
	cc.TintColor = Color3.fromRGB(180, 200, 255)

	local atmosphere = GetOrCreateEffect("Atmosphere", "Atmosphere")
	atmosphere.Density = 0.45
	atmosphere.Offset = 0.15
	atmosphere.Color = Color3.fromRGB(30, 45, 80)
	atmosphere.Decay = Color3.fromRGB(10, 15, 30)
	atmosphere.Haze = 1.8

	local dof = GetOrCreateEffect("DepthOfFieldEffect", "DepthOfField")
	dof.FarIntensity = 0.2
	dof.FocusDistance = 30
	dof.InFocusRadius = 15
	dof.NearIntensity = 0.05
end

local function ApplyGoldenHour()
	ClearShaders()
	Lighting.GlobalShadows = true
	Lighting.Brightness = 3.2
	Lighting.ClockTime = 17.5
	Lighting.OutdoorAmbient = Color3.fromRGB(160, 120, 80)
	Lighting.Ambient = Color3.fromRGB(100, 70, 50)
	Lighting.ExposureCompensation = 0.2

	local bloom = GetOrCreateEffect("BloomEffect", "Bloom")
	bloom.Intensity = 0.7
	bloom.Size = 24
	bloom.Threshold = 0.7

	local cc = GetOrCreateEffect("ColorCorrectionEffect", "ColorCorrection")
	cc.Brightness = 0.04
	cc.Contrast = 0.28
	cc.Saturation = 0.4
	cc.TintColor = Color3.fromRGB(255, 220, 180)

	local sunRays = GetOrCreateEffect("SunRaysEffect", "SunRays")
	sunRays.Intensity = 0.55
	sunRays.Spread = 0.95

	local atmosphere = GetOrCreateEffect("Atmosphere", "Atmosphere")
	atmosphere.Density = 0.38
	atmosphere.Offset = 0.3
	atmosphere.Color = Color3.fromRGB(245, 170, 100)
	atmosphere.Decay = Color3.fromRGB(180, 90, 50)
	atmosphere.Haze = 2
	atmosphere.Glares = 0.8
end

local function ApplySoftShading()
	ClearShaders()
	Lighting.GlobalShadows = true
	Lighting.Brightness = 2.4
	Lighting.ClockTime = 14
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 160)
	Lighting.Ambient = Color3.fromRGB(110, 110, 120)

	local bloom = GetOrCreateEffect("BloomEffect", "Bloom")
	bloom.Intensity = 0.3
	bloom.Size = 12
	bloom.Threshold = 0.9

	local cc = GetOrCreateEffect("ColorCorrectionEffect", "ColorCorrection")
	cc.Brightness = 0.01
	cc.Contrast = 0.12
	cc.Saturation = 0.15
	cc.TintColor = Color3.fromRGB(245, 248, 255)

	local dof = GetOrCreateEffect("DepthOfFieldEffect", "DepthOfField")
	dof.FarIntensity = 0.08
	dof.FocusDistance = 35
	dof.InFocusRadius = 25
	dof.NearIntensity = 0.02
end

-- ANTI-AFK
LocalPlayer.Idled:Connect(function()
	if AntiAFKEnabled then VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end
end)

-- GAME LOGIC: ROLES
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

local function GetDroppedGun()
	for _, i in pairs(Workspace:GetChildren()) do
		if i.Name == "GunDrop" or (i:IsA("Tool") and i.Name == "Gun") then return i end
	end
	for _, i in pairs(Workspace:GetDescendants()) do
		if i.Name == "GunDrop" then return i end
	end
end

local function SafeGrabGun()
	if isGrabbingGun then return end
	local gun, char = GetDroppedGun(), LocalPlayer.Character
	if gun and char and char:FindFirstChild("HumanoidRootPart") then
		local hrp = char.HumanoidRootPart
		local handle = gun:FindFirstChild("Handle") or gun:FindFirstChildOfClass("BasePart") or gun
		if handle and handle:IsA("BasePart") then
			isGrabbingGun = true
			local spot = hrp.CFrame
			
			local dist = (hrp.Position - handle.Position).Magnitude
			local travelTime = math.clamp(dist / 35, 0.2, 1.2)
			local tween = TweenService:Create(hrp, TweenInfo.new(travelTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = handle.CFrame * CFrame.new(0, 1, 0)})
			tween:Play()
			tween.Completed:Wait()

			if firetouchinterest then
				pcall(function() firetouchinterest(hrp, handle, 0) task.wait(0.05) firetouchinterest(hrp, handle, 1) end)
			end
			task.wait(0.08)
			
			local returnTween = TweenService:Create(hrp, TweenInfo.new(travelTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = spot})
			returnTween:Play()
			returnTween.Completed:Wait()
			
			task.wait(0.1)
			isGrabbingGun = false
		end
	end
end

-- FLING FUNCTION
local function FlingPlayer(targetPlayer)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local targetChar = targetPlayer and targetPlayer.Character
	local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	
	if not hrp or not targetHrp then return end
	
	local oldPos = hrp.CFrame
	local duration = 1.2
	local startTime = tick()
	
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not hrp or not targetHrp or tick() - startTime > duration then
			if connection then connection:Disconnect() end
			hrp.CFrame = oldPos
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			return
		end
		
		hrp.CFrame = targetHrp.CFrame
		hrp.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
		hrp.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
	end)
end

-- GHOST MODE
RunService.RenderStepped:Connect(function()
	if not InvisibleEnabled or not LocalPlayer.Character then return end
	for _, item in pairs(LocalPlayer.Character:GetDescendants()) do
		if item:IsA("BasePart") or item:IsA("MeshPart") then
			item.Transparency = 1
			item.LocalTransparencyModifier = 1
		elseif item:IsA("Decal") or item:IsA("Texture") then
			item.Transparency = 1
		elseif item:IsA("ParticleEmitter") or item:IsA("Trail") then
			item.Enabled = false
		end
	end
end)

local function SetGhostState(state)
	InvisibleEnabled = state
	local char = LocalPlayer.Character
	if not char or state then return end
	for _, obj in pairs(char:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("MeshPart") then
			obj.Transparency = (obj.Name == "HumanoidRootPart") and 1 or 0
			obj.LocalTransparencyModifier = 0
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Transparency = 0
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = true
		end
	end
end

-- AUTO FARM COINS (ROBUST SCANNER)
local function isValidCoin(obj, hrp)
	if not obj or not obj:IsA("BasePart") or not obj.Parent then return false end
	local n = string.lower(obj.Name)
	local isCoinName = (n == "coin" or n == "coin_sub" or n == "coinserver")
	if not isCoinName then return false end
	if obj.Transparency > 0.8 then return false end
	return true
end

local function collectCoinsList(hrp)
	local list, seen = {}, {}
	local function add(part)
		if isValidCoin(part, hrp) and not seen[part] then
			seen[part] = true
			table.insert(list, part)
		end
	end
	
	local mapFolder = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("Map") or Workspace
	for _, obj in ipairs(mapFolder:GetDescendants()) do
		add(obj)
	end
	return list
end

local function touchCoin(hrp, coin)
	if not coin or not coin.Parent then return end
	local targetCFrame = CFrame.new(coin.Position + Vector3.new(0, 0.2, 0))
	local distance = (hrp.Position - coin.Position).Magnitude

	local travelTime = math.clamp(distance / 28, 0.15, 0.8)
	local tween = TweenService:Create(hrp, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
	
	tween:Play()
	tween.Completed:Wait()

	if firetouchinterest and coin and coin.Parent then
		pcall(function() 
			firetouchinterest(hrp, coin, 0) 
			task.wait(0.02) 
			firetouchinterest(hrp, coin, 1) 
		end)
	end
end

task.spawn(function()
	while true do
		task.wait(0.08)
		if AutoFarmCoins and not isGrabbingGun and not isFarming then
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				isFarming = true
				local coins = collectCoinsList(hrp)
				table.sort(coins, function(a, b) return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude end)
				for _, coin in ipairs(coins) do
					if not AutoFarmCoins then break end
					if coin and coin.Parent and isValidCoin(coin, hrp) then 
						pcall(touchCoin, hrp, coin) 
						task.wait(math.clamp(FarmDelay, 0.25, 0.6)) 
					end
				end
				isFarming = false
			end
		end
	end
end)

-- FLY
task.spawn(function()
	while true do
		RunService.RenderStepped:Wait()
		if Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local hrp, d = LocalPlayer.Character.HumanoidRootPart, Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then d = d + camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then d = d - camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then d = d - camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then d = d + camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d = d - Vector3.new(0, 1, 0) end
			hrp.AssemblyLinearVelocity = d * FlySpeed
		end
	end
end)

-- AUTO DODGE
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

-- SILENT AIM
local function ShootAtMurderer()
	local murd, char = GetMurderer(), LocalPlayer.Character
	if murd and murd.Character and murd.Character:FindFirstChild("Head") and char then
		local gun = char:FindFirstChild("Gun")
		if gun and gun:FindFirstChild("Shoot") then
			local a, b = char.HumanoidRootPart.Position, murd.Character.Head.Position
			gun.Shoot:FireServer(CFrame.new(a, b), CFrame.new(b))
		end
	end
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
LocalPlayer.CharacterAdded:Connect(function(c) SetupSilentAim(c) task.wait(0.4) if InvisibleEnabled then SetGhostState(true) end end)

-- NOCLIP / GODMODE / FAKELAG / ANTI-FLING
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

-- VISUALS RENDER
RunService.RenderStepped:Connect(function()
	RemoveNotify()
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
		elseif GunHighlight then GunHighlight:Destroy() GunHighlight = nil end
		if AutoGrabGunEnabled and not isGrabbingGun then SafeGrabGun() end
	elseif GunHighlight then GunHighlight:Destroy() GunHighlight = nil end
	if FullbrightEnabled then
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.Brightness = 2
	end
end)

-- KILL ALL LOOP
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

-- UI CONSTRUCTION (ENGLISH ONLY)
local Window = Luna:CreateWindow({
	Name = "KAISEN X — MM2",
	Subtitle = "created by KAISEN",
	LogoID = "82795327169782",
	LoadingEnabled = false,
	ConfigSettings = { ConfigFolder = "KaisenXMM2" },
	NotificationSettings = { EnableNotifications = false },
	KeySystem = false,
})

pcall(function()
	Window:CreateHomeTab({
		SupportedExecutors = { "Delta", "Wave", "Fluxus", "Codex", "Solara", "Xeno" },
		DiscordInvite = "cs6eGYEGE",
		Icon = 1,
	})
end)

-- COMBAT TAB
local TabCombat = Window:CreateTab({ Name = "Combat", Icon = "sports_mma", ImageSource = "Material", ShowTitle = true })
TabCombat:CreateToggle({ Name = "Kill All", CurrentValue = KillAllActive, Callback = function(v) KillAllActive = v end })
TabCombat:CreateToggle({ Name = "Sheriff Silent Aim", CurrentValue = SilentAimEnabled, Callback = function(v) SilentAimEnabled = v end })
TabCombat:CreateButton({ Name = "Grab Gun", Callback = function() SafeGrabGun() end })
TabCombat:CreateToggle({ Name = "Auto-Grab Gun", CurrentValue = AutoGrabGunEnabled, Callback = function(v) AutoGrabGunEnabled = v end })
TabCombat:CreateButton({
	Name = "Fling Murderer",
	Callback = function()
		local m = GetMurderer()
		if m then FlingPlayer(m) end
	end,
})
TabCombat:CreateButton({
	Name = "Fling Sheriff",
	Callback = function()
		local s = GetSheriff()
		if s then FlingPlayer(s) end
	end,
})
TabCombat:CreateButton({
	Name = "Reveal Murderer",
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

-- FARMING TAB
local TabFarm = Window:CreateTab({ Name = "Farming", Icon = "monetization_on", ImageSource = "Material", ShowTitle = true })
TabFarm:CreateToggle({ Name = "Auto-Farm Coins", CurrentValue = AutoFarmCoins, Callback = function(v) AutoFarmCoins = v end })
TabFarm:CreateSlider({
	Name = "Farm Speed Delay",
	Range = { 0.25, 0.7 },
	Increment = 0.05,
	CurrentValue = FarmDelay,
	Callback = function(v) FarmDelay = v end,
})

-- VISUALS TAB
local TabVisual = Window:CreateTab({ Name = "Visuals", Icon = "visibility", ImageSource = "Material", ShowTitle = true })
TabVisual:CreateToggle({ Name = "Role ESP", CurrentValue = ESP_Enabled, Callback = function(v) ESP_Enabled = v end })
TabVisual:CreateToggle({ Name = "Gun ESP", CurrentValue = GunESP_Enabled, Callback = function(v) GunESP_Enabled = v end })
TabVisual:CreateToggle({
	Name = "Fullbright",
	CurrentValue = FullbrightEnabled,
	Callback = function(v)
		FullbrightEnabled = v
		if not v then Lighting.Brightness = 1 Lighting.Ambient = Color3.fromRGB(128, 128, 128) end
	end,
})
TabVisual:CreateToggle({
	Name = "X-Ray",
	CurrentValue = false,
	Callback = function(state)
		for _, part in pairs(Workspace:GetDescendants()) do
			if part:IsA("BasePart") and not part.Parent:FindFirstChildOfClass("Humanoid") then
				part.LocalTransparencyModifier = state and 0.6 or 0
			end
		end
	end,
})

-- SHADERS TAB
local TabShaders = Window:CreateTab({ Name = "Shaders / Effects", Icon = "wb_sunny", ImageSource = "Material", ShowTitle = true })

TabShaders:CreateButton({ Name = "Preset: RTX Overhaul", Callback = function() ApplyRTXOverhaul() end })
TabShaders:CreateButton({ Name = "Preset: Cinematic Night", Callback = function() ApplyCinematicNight() end })
TabShaders:CreateButton({ Name = "Preset: Golden Hour", Callback = function() ApplyGoldenHour() end })
TabShaders:CreateButton({ Name = "Preset: Soft Shading", Callback = function() ApplySoftShading() end })
TabShaders:CreateButton({ Name = "Disable Shaders / Reset", Callback = function() ClearShaders() end })

TabShaders:CreateSlider({
	Name = "Lighting Brightness",
	Range = { 0.5, 5 },
	Increment = 0.1,
	CurrentValue = Lighting.Brightness,
	Callback = function(v) Lighting.Brightness = v end,
})

TabShaders:CreateSlider({
	Name = "Exposure Compensation",
	Range = { -1, 1 },
	Increment = 0.05,
	CurrentValue = Lighting.ExposureCompensation,
	Callback = function(v) Lighting.ExposureCompensation = v end,
})

TabShaders:CreateSlider({
	Name = "Contrast",
	Range = { -0.5, 0.8 },
	Increment = 0.02,
	CurrentValue = 0.2,
	Callback = function(v)
		local cc = GetOrCreateEffect("ColorCorrectionEffect", "ColorCorrection")
		cc.Contrast = v
	end,
})

TabShaders:CreateSlider({
	Name = "Saturation",
	Range = { -0.5, 1 },
	Increment = 0.05,
	CurrentValue = 0.2,
	Callback = function(v)
		local cc = GetOrCreateEffect("ColorCorrectionEffect", "ColorCorrection")
		cc.Saturation = v
	end,
})

TabShaders:CreateSlider({
	Name = "Bloom Intensity",
	Range = { 0, 2 },
	Increment = 0.05,
	CurrentValue = 0.45,
	Callback = function(v)
		local bloom = GetOrCreateEffect("BloomEffect", "Bloom")
		bloom.Intensity = v
	end,
})

TabShaders:CreateSlider({
	Name = "SunRays Intensity",
	Range = { 0, 1 },
	Increment = 0.05,
	CurrentValue = 0.3,
	Callback = function(v)
		local sunRays = GetOrCreateEffect("SunRaysEffect", "SunRays")
		sunRays.Intensity = v
	end,
})

TabShaders:CreateSlider({
	Name = "Atmosphere Density",
	Range = { 0, 0.8 },
	Increment = 0.02,
	CurrentValue = 0.28,
	Callback = function(v)
		local atmosphere = GetOrCreateEffect("Atmosphere", "Atmosphere")
		atmosphere.Density = v
	end,
})

-- PLAYER TAB
local TabPlayer = Window:CreateTab({ Name = "Player", Icon = "person", ImageSource = "Material", ShowTitle = true })
TabPlayer:CreateToggle({ Name = "Anti-Fling Protection", CurrentValue = AntiFlingEnabled, Callback = function(v) AntiFlingEnabled = v end })
TabPlayer:CreateToggle({ Name = "Ghost Mode", CurrentValue = InvisibleEnabled, Callback = function(v) SetGhostState(v) end })
TabPlayer:CreateToggle({ Name = "Godmode", CurrentValue = GodmodeEnabled, Callback = function(v) GodmodeEnabled = v end })
TabPlayer:CreateSlider({
	Name = "WalkSpeed",
	Range = { 16, 120 },
	Increment = 1,
	CurrentValue = 16,
	Callback = function(v)
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if h then h.WalkSpeed = v end
	end,
})
TabPlayer:CreateSlider({
	Name = "JumpPower",
	Range = { 50, 200 },
	Increment = 1,
	CurrentValue = 50,
	Callback = function(v)
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if h then h.JumpPower = v end
	end,
})
TabPlayer:CreateToggle({ Name = "Fly", CurrentValue = Flying, Callback = function(v) Flying = v end })
TabPlayer:CreateToggle({ Name = "Infinite Jump", CurrentValue = InfJumpEnabled, Callback = function(v) InfJumpEnabled = v end })
TabPlayer:CreateToggle({ Name = "Noclip", CurrentValue = Noclip_Enabled, Callback = function(v) Noclip_Enabled = v end })

-- EXTRAS / SETTINGS TAB
local TabExtras = Window:CreateTab({ Name = "Extras / Settings", Icon = "settings", ImageSource = "Material", ShowTitle = true })
TabExtras:CreateToggle({ Name = "Auto Dodge", CurrentValue = AutoDodgeEnabled, Callback = function(v) AutoDodgeEnabled = v end })
TabExtras:CreateToggle({ Name = "Fake Lag", CurrentValue = FakeLagEnabled, Callback = function(v) FakeLagEnabled = v end })
TabExtras:CreateToggle({ Name = "Anti-AFK", CurrentValue = AntiAFKEnabled, Callback = function(v) AntiAFKEnabled = v end })
TabExtras:CreateSlider({
	Name = "Field of View (FOV)",
	Range = { 70, 120 },
	Increment = 1,
	CurrentValue = camera.FieldOfView,
	Callback = function(v) camera.FieldOfView = v end,
})
TabExtras:CreateButton({
	Name = "Copy Discord Link",
	Callback = function()
		pcall(function() if setclipboard then setclipboard(DISCORD_LINK) end end)
	end,
})
TabExtras:CreateButton({
	Name = "Copy TikTok User",
	Callback = function()
		pcall(function() if setclipboard then setclipboard(TIKTOK_USER) end end)
	end,
})
TabExtras:CreateButton({
	Name = "Rejoin Server",
	Callback = function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end,
})
