--[[
	KAISEN X | MM2 | Rayfield
	created by KAISEN
	Farm rápido + sin paredes + monedas reales
]]

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "KAISEN X — MM2",
	LoadingTitle = "KAISEN X",
	LoadingSubtitle = "created by KAISEN",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local DISCORD_LINK = "https://discord.gg/cs6eGYEGE"
local TIKTOK_USER = "@kaisen_x2"

local KillAllActive, AutoFarmCoins = false, false
local FarmRange = 35
local FarmSpeed = 28 -- walkspeed solo mientras farmea
local GodmodeEnabled, InvisibleEnabled = false, false
local ESP_Enabled, GunESP_Enabled, AutoGrabGunEnabled = false, false, false
local Noclip_Enabled, SilentAimEnabled, FullbrightEnabled = false, false, false
local InfJumpEnabled, AntiAFKEnabled = true, true
local Flying, FlySpeed = false, 50
local AutoDodgeEnabled, FakeLagEnabled = false, false
local AntiFlingEnabled = true
local SavedPositions, Highlights, GunHighlight = {}, {}, nil
local isGrabbingGun, isFarming = false, false
local ghostConn = nil
local normalWalkSpeed = 16

-- SHADERS
local function wipeFX()
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("Atmosphere") then
			if tostring(v.Name):find("Kaisen") then v:Destroy() end
		end
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
	if not (gun and char and char:FindFirstChild("HumanoidRootPart")) then return end
	local hrp = char.HumanoidRootPart
	local handle = gun:FindFirstChild("Handle") or gun:FindFirstChildOfClass("BasePart") or gun
	if not (handle and handle:IsA("BasePart")) then return end
	if (hrp.Position - handle.Position).Magnitude > 20 then return end
	isGrabbingGun = true
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = FarmSpeed
		hum:MoveTo(handle.Position)
		local t0 = tick()
		while tick() - t0 < 2 and (hrp.Position - handle.Position).Magnitude > 4 do task.wait(0.08) end
	end
	if firetouchinterest then
		pcall(function()
			firetouchinterest(hrp, handle, 0) task.wait(0.04) firetouchinterest(hrp, handle, 1)
		end)
	end
	if hum then hum.WalkSpeed = normalWalkSpeed end
	isGrabbingGun = false
end

local function FlingPlayer(targetPlayer)
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetHrp = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetHrp then return end
	local oldPos = hrp.CFrame
	local start = tick()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not hrp.Parent or not targetHrp.Parent or tick() - start > 1.2 then
			if conn then conn:Disconnect() end
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

-- GHOST
local function hideObject(obj)
	if obj:IsA("BasePart") or obj:IsA("MeshPart") then
		obj.Transparency = 1
		obj.LocalTransparencyModifier = 1
		pcall(function() obj.CastShadow = false end)
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		obj.Transparency = 1
	elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") then
		obj.Enabled = false
	elseif obj:IsA("Accessory") then
		for _, h in ipairs(obj:GetDescendants()) do
			if h:IsA("BasePart") or h:IsA("MeshPart") then
				h.Transparency = 1
				h.LocalTransparencyModifier = 1
			elseif h:IsA("Decal") then h.Transparency = 1 end
		end
	elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
		obj.Enabled = false
	end
end

local function applyGhost(char)
	if not char then return end
	for _, obj in ipairs(char:GetDescendants()) do hideObject(obj) end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			for _, o in ipairs(tool:GetDescendants()) do hideObject(o) end
		end
	end
end

local function restoreGhost(char)
	if not char then return end
	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("MeshPart") then
			if obj.Name ~= "HumanoidRootPart" then obj.Transparency = 0 end
			obj.LocalTransparencyModifier = 0
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Transparency = 0
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
			obj.Enabled = true
		elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
			obj.Enabled = true
		end
	end
end

local function SetGhostState(state)
	InvisibleEnabled = state
	if ghostConn then ghostConn:Disconnect() ghostConn = nil end
	local char = LocalPlayer.Character
	if state then
		applyGhost(char)
		ghostConn = RunService.RenderStepped:Connect(function()
			if InvisibleEnabled and LocalPlayer.Character then applyGhost(LocalPlayer.Character) end
		end)
	else
		restoreGhost(char)
	end
end

-- ===================== FARM RÁPIDO SIN PAREDES =====================
local function isRealCoin(obj)
	if not obj or not obj:IsA("BasePart") or not obj.Parent then return false end
	local n = string.lower(obj.Name)
	-- nombres típicos MM2
	if n ~= "coin" and n ~= "coin_sub" and n ~= "coinserver" and not (n == "handle" and obj.Parent and string.find(string.lower(obj.Parent.Name), "coin")) then
		if not (string.find(n, "coin") and not string.find(n, "container") and not string.find(n, "gui") and not string.find(n, "spawn")) then
			return false
		end
	end
	if obj.Transparency >= 0.9 then return false end
	if obj.Size.Magnitude < 0.2 or obj.Size.Magnitude > 15 then return false end
	return true
end

-- ¿hay pared entre yo y la moneda?
local function hasClearPath(fromPos, toPos)
	local dir = toPos - fromPos
	local dist = dir.Magnitude
	if dist < 1 then return true end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local filter = { LocalPlayer.Character }
	-- excluir monedas del raycast
	for _, o in ipairs(Workspace:GetDescendants()) do
		if isRealCoin(o) then table.insert(filter, o) end
	end
	params.FilterDescendantsInstances = filter
	params.IgnoreWater = true
	local result = Workspace:Raycast(fromPos + Vector3.new(0, 2, 0), dir.Unit * dist, params)
	if not result then return true end
	-- si pegó muy cerca de la moneda, ok
	if (result.Position - toPos).Magnitude < 4 then return true end
	return false
end

local function getCoinsSorted(hrp)
	local list = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isRealCoin(obj) then
			local d = (obj.Position - hrp.Position).Magnitude
			if d <= FarmRange and d > 1.5 then
				-- altura similar (no monedas en otro piso absurdo)
				if math.abs(obj.Position.Y - hrp.Position.Y) < 18 then
					if hasClearPath(hrp.Position, obj.Position) then
						table.insert(list, { part = obj, dist = d })
					end
				end
			end
		end
	end
	table.sort(list, function(a, b) return a.dist < b.dist end)
	return list
end

local function walkTo(hum, hrp, targetPos, timeout)
	timeout = timeout or 2.5
	-- pathfinding corto
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		WaypointSpacing = 4,
	})
	local ok = pcall(function() path:ComputeAsync(hrp.Position, targetPos) end)
	if ok and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		local t0 = tick()
		for _, wp in ipairs(waypoints) do
			if not AutoFarmCoins or not hrp.Parent then return false end
			if tick() - t0 > timeout then return false end
			hum:MoveTo(wp.Position)
			local arrived = false
			local conn
			conn = hum.MoveToFinished:Connect(function(reached)
				arrived = true
				if conn then conn:Disconnect() end
			end)
			local w0 = tick()
			while not arrived and tick() - w0 < 1.2 and AutoFarmCoins do
				task.wait(0.05)
				if (hrp.Position - wp.Position).Magnitude < 3.5 then break end
			end
			if conn then conn:Disconnect() end
		end
		return true
	else
		-- fallback: MoveTo directo solo si hay vista clara
		if hasClearPath(hrp.Position, targetPos) then
			hum:MoveTo(targetPos)
			local t0 = tick()
			while tick() - t0 < timeout and AutoFarmCoins do
				if (hrp.Position - targetPos).Magnitude < 4 then return true end
				task.wait(0.05)
			end
		end
	end
	return false
end

task.spawn(function()
	while true do
		task.wait(0.05)
		if AutoFarmCoins and not isGrabbingGun and not isFarming then
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				isFarming = true
				normalWalkSpeed = hum.WalkSpeed > 0 and math.clamp(hum.WalkSpeed, 16, 30) or 16
				hum.WalkSpeed = FarmSpeed

				local coins = getCoinsSorted(hrp)
				if #coins > 0 then
					local coin = coins[1].part
					if coin and coin.Parent then
						local reached = walkTo(hum, hrp, coin.Position, 2.2)
						if reached or (hrp.Position - coin.Position).Magnitude < 6 then
							if firetouchinterest then
								pcall(function()
									firetouchinterest(hrp, coin, 0)
									task.wait(0.02)
									firetouchinterest(hrp, coin, 1)
								end)
							end
							-- segundo toque rápido
							task.wait(0.05)
							if firetouchinterest and coin.Parent then
								pcall(function()
									firetouchinterest(hrp, coin, 0)
									firetouchinterest(hrp, coin, 1)
								end)
							end
						end
					end
				end

				if not AutoFarmCoins and hum.Parent then
					hum.WalkSpeed = normalWalkSpeed
				end
				isFarming = false
				task.wait(0.04)
			end
		elseif not AutoFarmCoins then
			-- restaurar speed si se apagó el farm
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum and isFarming == false then
				-- no forzar si el user cambió el slider
			end
			task.wait(0.15)
		end
	end
end)

-- SILENT
local function predictPos(part, lead)
	local vel = Vector3.zero
	pcall(function() vel = part.AssemblyLinearVelocity end)
	if vel.Magnitude < 0.5 then
		local r = part.Parent and part.Parent:FindFirstChild("HumanoidRootPart")
		if r then pcall(function() vel = r.AssemblyLinearVelocity end) end
	end
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
	if gun.Parent == LocalPlayer.Backpack and char:FindFirstChildOfClass("Humanoid") then
		char.Humanoid:EquipTool(gun)
		task.wait(0.03)
	end
	if not gun:FindFirstChild("Shoot") then return end
	local dist = (head.Position - hrp.Position).Magnitude
	local lead = math.clamp(dist / 90, 0.08, 0.35)
	local pred = predictPos(head, lead) + Vector3.new(0, 0.3, 0)
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
	task.wait(0.5)
	if InvisibleEnabled then SetGhostState(true) end
end)

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
		if AutoGrabGunEnabled and not isGrabbingGun then SafeGrabGun() end
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

-- UI
local TabHome = Window:CreateTab("Home", 4483362458)
TabHome:CreateParagraph({ Title = "KAISEN X — MM2", Content = "created by KAISEN" })
TabHome:CreateButton({ Name = "Copy Discord", Callback = function() pcall(function() if setclipboard then setclipboard(DISCORD_LINK) end end) end })
TabHome:CreateButton({ Name = "Copy TikTok", Callback = function() pcall(function() if setclipboard then setclipboard(TIKTOK_USER) end end) end })

local TabCombat = Window:CreateTab("Combat", 4483362458)
TabCombat:CreateToggle({ Name = "Kill All", CurrentValue = false, Flag = "KillAll", Callback = function(v) KillAllActive = v end })
TabCombat:CreateToggle({ Name = "Sheriff Silent Aim", CurrentValue = false, Flag = "Silent", Callback = function(v) SilentAimEnabled = v end })
TabCombat:CreateButton({ Name = "Grab Gun", Callback = function() SafeGrabGun() end })
TabCombat:CreateToggle({ Name = "Auto-Grab Gun", CurrentValue = false, Flag = "AutoGun", Callback = function(v) AutoGrabGunEnabled = v end })
TabCombat:CreateButton({ Name = "Fling Murderer", Callback = function() local m = GetMurderer() if m then FlingPlayer(m) end end })
TabCombat:CreateButton({ Name = "Fling Sheriff", Callback = function() local s = GetSheriff() if s then FlingPlayer(s) end end })
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

local TabFarm = Window:CreateTab("Farming", 4483362458)
TabFarm:CreateParagraph({
	Title = "Farm rápido",
	Content = "Pathfinding + raycast (no atraviesa paredes). Solo monedas reales. Speed solo al farmear.",
})
TabFarm:CreateToggle({
	Name = "Auto-Farm Coins",
	CurrentValue = false,
	Flag = "Farm",
	Callback = function(v)
		AutoFarmCoins = v
		if not v then
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = normalWalkSpeed end
		end
	end,
})
TabFarm:CreateSlider({
	Name = "Farm Speed",
	Range = { 20, 40 },
	Increment = 1,
	CurrentValue = 28,
	Flag = "FarmSpeed",
	Callback = function(v) FarmSpeed = v end,
})
TabFarm:CreateSlider({
	Name = "Rango",
	Range = { 15, 50 },
	Increment = 1,
	CurrentValue = 35,
	Flag = "FarmRange",
	Callback = function(v) FarmRange = v end,
})

local TabVisual = Window:CreateTab("Visuals", 4483362458)
TabVisual:CreateToggle({ Name = "Role ESP", CurrentValue = false, Flag = "ESP", Callback = function(v) ESP_Enabled = v end })
TabVisual:CreateToggle({ Name = "Gun ESP", CurrentValue = false, Flag = "GunESP", Callback = function(v) GunESP_Enabled = v end })
TabVisual:CreateToggle({
	Name = "Fullbright",
	CurrentValue = false,
	Flag = "FB",
	Callback = function(v)
		FullbrightEnabled = v
		if not v then Lighting.Brightness = 1 Lighting.Ambient = Color3.fromRGB(128, 128, 128) end
	end,
})
TabVisual:CreateToggle({
	Name = "X-Ray",
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

local TabShaders = Window:CreateTab("Shaders", 4483362458)
TabShaders:CreateButton({ Name = "Noir", Callback = Shader_Noir })
TabShaders:CreateButton({ Name = "Warm Film", Callback = Shader_WarmFilm })
TabShaders:CreateButton({ Name = "Neon Rain", Callback = Shader_NeonRain })
TabShaders:CreateButton({ Name = "Clean HQ", Callback = Shader_CleanHQ })
TabShaders:CreateButton({ Name = "Reset", Callback = Shader_Reset })

local TabPlayer = Window:CreateTab("Player", 4483362458)
TabPlayer:CreateToggle({ Name = "Anti-Fling", CurrentValue = true, Flag = "AntiFling", Callback = function(v) AntiFlingEnabled = v end })
TabPlayer:CreateToggle({ Name = "Ghost Mode", CurrentValue = false, Flag = "Ghost", Callback = function(v) SetGhostState(v) end })
TabPlayer:CreateToggle({ Name = "Godmode", CurrentValue = false, Flag = "God", Callback = function(v) GodmodeEnabled = v end })
TabPlayer:CreateSlider({
	Name = "WalkSpeed", Range = { 16, 120 }, Increment = 1, CurrentValue = 16, Flag = "WS",
	Callback = function(v)
		normalWalkSpeed = v
		if not AutoFarmCoins then
			local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if h then h.WalkSpeed = v end
		end
	end,
})
TabPlayer:CreateSlider({
	Name = "JumpPower", Range = { 50, 200 }, Increment = 1, CurrentValue = 50, Flag = "JP",
	Callback = function(v)
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if h then h.JumpPower = v end
	end,
})
TabPlayer:CreateToggle({ Name = "Fly", CurrentValue = false, Flag = "Fly", Callback = function(v) Flying = v end })
TabPlayer:CreateToggle({ Name = "Infinite Jump", CurrentValue = true, Flag = "InfJ", Callback = function(v) InfJumpEnabled = v end })
TabPlayer:CreateToggle({ Name = "Noclip", CurrentValue = false, Flag = "Noclip", Callback = function(v) Noclip_Enabled = v end })

local TabExtras = Window:CreateTab("Extras", 4483362458)
TabExtras:CreateToggle({ Name = "Auto Dodge", CurrentValue = false, Flag = "Dodge", Callback = function(v) AutoDodgeEnabled = v end })
TabExtras:CreateToggle({ Name = "Fake Lag", CurrentValue = false, Flag = "Lag", Callback = function(v) FakeLagEnabled = v end })
TabExtras:CreateToggle({ Name = "Anti-AFK", CurrentValue = true, Flag = "AFK", Callback = function(v) AntiAFKEnabled = v end })
TabExtras:CreateSlider({ Name = "FOV", Range = { 70, 120 }, Increment = 1, CurrentValue = 70, Flag = "FOV", Callback = function(v) camera.FieldOfView = v end })
TabExtras:CreateButton({ Name = "Rejoin", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })
