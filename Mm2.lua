--[[
	KAISEN X | MM2
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
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local camera = Workspace.CurrentCamera

task.spawn(function()
	local req = (http_request or request or (syn and syn.request))
	if not req then return end
	local exec = "Delta"
	pcall(function() if identifyexecutor then exec = identifyexecutor() end end)
	pcall(function()
		req({
			Url = "https://drip-client-2.onrender.com/online",
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({
				username = LP.Name,
				displayName = LP.DisplayName,
				userId = tostring(LP.UserId),
				placeId = tostring(game.PlaceId),
				jobId = tostring(game.JobId),
				executor = exec,
				scriptVersion = "KAISEN X - MM2"
			})
		})
	end)
end)

local KillAll, SilentAim, AutoGrabGun = false, false, false
local AutoFarm, FarmSpeed, FarmRange = false, 40, 90
local ESP, GunESP, NameESP, DistESP = false, false, true, true
local Fullbright = false
local AntiFling, Ghost, Godmode = true, false, false
local Noclip, InfJump, Flying, FlySpeed = false, true, false, 55
local AutoDodge, FakeLag, AntiAFK = false, false, true
local WalkSpeed = 16
local FlingTarget, flingBusy, isGrabbing = nil, false, false
local SavedPos, Highlights, GunHL, ESPBill = {}, {}, nil, {}
local ghostConn, farmBP, farmBG = nil, nil, nil

local function getChar() return LP.Character end
local function getHRP(c) c = c or getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum(c) c = c or getChar() return c and c:FindFirstChildOfClass("Humanoid") end

local function GetMurderer()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then
			local bp = p:FindFirstChild("Backpack")
			if p.Character:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then return p end
		end
	end
end

local function GetSheriff()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then
			local bp = p:FindFirstChild("Backpack")
			if p.Character:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then return p end
		end
	end
end

local function RoleColor(p)
	if not p or not p.Character then return Color3.fromRGB(50, 255, 100) end
	local bp = p:FindFirstChild("Backpack")
	if p.Character:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then return Color3.fromRGB(255, 50, 50) end
	if p.Character:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then return Color3.fromRGB(50, 150, 255) end
	return Color3.fromRGB(50, 255, 100)
end

local function playerNames()
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then table.insert(t, p.Name) end
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

local function hasGun()
	local c, bp = getChar(), LP:FindFirstChild("Backpack")
	return (c and c:FindFirstChild("Gun")) or (bp and bp:FindFirstChild("Gun"))
end

local function GetDroppedGun()
	for _, i in ipairs(Workspace:GetChildren()) do
		if i.Name == "GunDrop" then return i end
		if i:IsA("Tool") and i.Name == "Gun" and i.Parent == Workspace then return i end
	end
	for _, f in ipairs(Workspace:GetChildren()) do
		local g = f:FindFirstChild("GunDrop", true)
		if g then return g end
	end
end

local function isCandy(obj)
	if not obj or not obj:IsA("BasePart") or not obj.Parent then return false end
	local n = string.lower(obj.Name)
	if n:find("gui") or n:find("spawn") or n:find("label") then return false end
	if not (n:find("candy") or n:find("candie") or n == "coin" or n == "coin_sub" or (n:find("coin") and not n:find("icon"))) then
		return false
	end
	if obj.Transparency >= 0.95 or obj.Size.Magnitude > 14 or obj.Size.Magnitude < 0.1 then return false end
	return true
end

local function getClosestCandy(hrp)
	local best, bestD = nil, FarmRange
	for _, o in ipairs(Workspace:GetDescendants()) do
		if isCandy(o) then
			local d = (o.Position - hrp.Position).Magnitude
			if d < bestD and d > 0.5 then
				bestD = d
				best = o
			end
		end
	end
	return best, bestD
end

local function touch(hrp, part)
	if not hrp or not part or not part.Parent then return end
	if firetouchinterest then
		pcall(function()
			firetouchinterest(hrp, part, 0)
			firetouchinterest(hrp, part, 1)
		end)
	end
end

local function clearFarmBody()
	if farmBP then pcall(function() farmBP:Destroy() end) farmBP = nil end
	if farmBG then pcall(function() farmBG:Destroy() end) farmBG = nil end
end

local function setupFarmBody(hrp)
	clearFarmBody()
	farmBP = Instance.new("BodyPosition")
	farmBP.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	farmBP.P = 9000
	farmBP.D = 800
	farmBP.Position = hrp.Position
	farmBP.Parent = hrp
	farmBG = Instance.new("BodyGyro")
	farmBG.MaxTorque = Vector3.new(4e4, 4e4, 4e4)
	farmBG.P = 3500
	farmBG.CFrame = hrp.CFrame
	farmBG.Parent = hrp
end

local function FlingPlayer(target)
	if flingBusy or not target then return end
	local char = getChar()
	local hrp = getHRP(char)
	local hum = getHum(char)
	local th = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not th or not char then return end
	flingBusy = true
	local old = hrp.CFrame
	if hum then hum.Health = hum.MaxHealth end
	local cols = {}
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then cols[p] = p.CanCollide p.CanCollide = false end
	end
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bv.Velocity = Vector3.zero
	bv.Parent = hrp
	local bav = Instance.new("BodyAngularVelocity")
	bav.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bav.AngularVelocity = Vector3.new(0, 9999, 0)
	bav.Parent = hrp
	local t0 = tick()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if hum then hum.Health = hum.MaxHealth end
		if not hrp.Parent or not th.Parent or tick() - t0 > 1.8 then
			if conn then conn:Disconnect() end
			pcall(function() bv:Destroy() end)
			pcall(function() bav:Destroy() end)
			for p, c in pairs(cols) do if p and p.Parent then p.CanCollide = c end end
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			task.wait(0.05)
			if hrp.Parent then hrp.CFrame = old end
			flingBusy = false
			return
		end
		hrp.CFrame = th.CFrame
		local away = th.Position - old.Position
		if away.Magnitude < 1 then away = Vector3.new(1, 0, 0) end
		away = away.Unit
		bv.Velocity = Vector3.new(away.X * 20000, 15000, away.Z * 20000)
		bav.AngularVelocity = Vector3.new(9999, 9999, 9999)
	end)
end

local function FlingAll()
	task.spawn(function()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				FlingPlayer(p)
				task.wait(2.1)
			end
		end
	end)
end

local function SafeGrabGun()
	if isGrabbing or hasGun() then return end
	local gun, hrp = GetDroppedGun(), getHRP()
	if not gun or not hrp then return end
	local handle = gun:FindFirstChild("Handle") or gun:FindFirstChildWhichIsA("BasePart") or (gun:IsA("BasePart") and gun)
	if not handle then return end
	isGrabbing = true
	local back = hrp.CFrame
	if (hrp.Position - handle.Position).Magnitude < 100 then
		hrp.CFrame = CFrame.new(handle.Position + Vector3.new(0, 2.5, 0))
		task.wait(0.1)
		for _ = 1, 8 do
			touch(hrp, handle)
			task.wait(0.03)
			if hasGun() then break end
		end
	end
	if hrp.Parent then hrp.CFrame = back end
	isGrabbing = false
end

local function ShootMurderer()
	local murd, char = GetMurderer(), getChar()
	if not (murd and murd.Character and char) then return end
	local head = murd.Character:FindFirstChild("Head")
	local hrp = getHRP(char)
	if not head or not hrp then return end
	local gun = char:FindFirstChild("Gun") or (LP.Backpack and LP.Backpack:FindFirstChild("Gun"))
	if not gun then return end
	if gun.Parent == LP.Backpack then getHum(char):EquipTool(gun) task.wait(0.03) end
	if not gun:FindFirstChild("Shoot") then return end
	local dist = (head.Position - hrp.Position).Magnitude
	local vel = Vector3.zero
	pcall(function() vel = head.AssemblyLinearVelocity end)
	local pred = head.Position + vel * math.clamp(dist / 90, 0.08, 0.35) + Vector3.new(0, 0.3, 0)
	gun.Shoot:FireServer(CFrame.new(hrp.Position, pred), CFrame.new(pred))
end

local function SetupSilent(character)
	if not character then return end
	character.ChildAdded:Connect(function(c)
		if c:IsA("Tool") and c.Name == "Gun" then
			c.Activated:Connect(function() if SilentAim then ShootMurderer() end end)
		end
	end)
	local g = character:FindFirstChild("Gun")
	if g then g.Activated:Connect(function() if SilentAim then ShootMurderer() end end) end
end
if LP.Character then SetupSilent(LP.Character) end

local function SetGhost(on)
	Ghost = on
	if ghostConn then ghostConn:Disconnect() ghostConn = nil end
	local char = getChar()
	if not char then return end
	if on then
		ghostConn = RunService.RenderStepped:Connect(function()
			local c = getChar()
			if not c or not Ghost then return end
			for _, o in ipairs(c:GetDescendants()) do
				if o:IsA("BasePart") or o:IsA("MeshPart") then
					o.LocalTransparencyModifier = 1
				elseif o:IsA("Decal") or o:IsA("Texture") then
					o.Transparency = 1
				end
			end
		end)
	else
		for _, o in ipairs(char:GetDescendants()) do
			if o:IsA("BasePart") or o:IsA("MeshPart") then
				o.LocalTransparencyModifier = 0
				if o.Name ~= "HumanoidRootPart" then o.Transparency = 0 end
			end
		end
	end
end

LP.CharacterAdded:Connect(function(c)
	SetupSilent(c)
	clearFarmBody()
	task.wait(0.4)
	if Ghost then SetGhost(true) end
end)

task.spawn(function()
	while true do
		task.wait(0.03)
		if not AutoFarm or isGrabbing or flingBusy then
			if farmBP then clearFarmBody() end
			task.wait(0.08)
		else
			local hrp = getHRP()
			local hum = getHum()
			if hrp and hum and hum.Health > 0 then
				if not farmBP or not farmBP.Parent then setupFarmBody(hrp) end
				for _, p in ipairs(getChar():GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
				local candy, dist = getClosestCandy(hrp)
				if candy and candy.Parent then
					local target = candy.Position + Vector3.new(0, 2.2, 0)
					local cur = hrp.Position
					local delta = target - cur
					local mag = delta.Magnitude
					if mag > 3.5 then
						local step = math.min(FarmSpeed * 0.055, mag)
						farmBP.Position = cur + delta.Unit * step
						farmBP.P = 4000 + FarmSpeed * 90
						farmBP.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					else
						farmBP.Position = target
						touch(hrp, candy)
						for _, o in ipairs(Workspace:GetDescendants()) do
							if o ~= candy and isCandy(o) and (o.Position - hrp.Position).Magnitude < 12 then
								touch(hrp, o)
							end
						end
						task.wait(0.1)
					end
				else
					if farmBP then farmBP.Position = hrp.Position end
					task.wait(0.2)
				end
			end
		end
	end
end)

task.spawn(function()
	local was = false
	while true do
		task.wait(0.25)
		if was and not AutoFarm then
			clearFarmBody()
			if not Noclip and getChar() then
				for _, p in ipairs(getChar():GetDescendants()) do
					if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
						p.CanCollide = true
					end
				end
			end
			local h = getHum()
			if h then h.WalkSpeed = WalkSpeed end
		end
		was = AutoFarm
	end
end)

LP.Idled:Connect(function()
	if AntiAFK then
		pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
	end
end)

task.spawn(function()
	while true do
		RunService.RenderStepped:Wait()
		if Flying and not AutoFarm then
			local hrp = getHRP()
			if hrp then
				local d = Vector3.zero
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then d = d + camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then d = d - camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then d = d - camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then d = d + camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d = d - Vector3.new(0, 1, 0) end
				hrp.AssemblyLinearVelocity = d * FlySpeed
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		if AutoDodge then
			local murd = GetMurderer()
			local my = getHRP()
			if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart") and my then
				if (my.Position - murd.Character.HumanoidRootPart.Position).Magnitude < 12 then
					my.CFrame = my.CFrame * CFrame.new(0, 12, -18)
				end
			end
		end
	end
end)

RunService.Stepped:Connect(function()
	if Noclip and not AutoFarm and getChar() then
		for _, p in pairs(getChar():GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
	if Godmode or flingBusy then
		local h = getHum()
		if h then h.Health = h.MaxHealth end
	end
	if AntiFling and not flingBusy then
		local hrp = getHRP()
		if hrp and (hrp.AssemblyLinearVelocity.Magnitude > 400 or hrp.AssemblyAngularVelocity.Magnitude > 400) then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end
	end
	if FakeLag then
		local hrp = getHRP()
		if hrp then
			hrp.Anchored = true
			task.wait(0.05)
			if hrp.Parent then hrp.Anchored = false end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if ESP then
				local hl = Highlights[player]
				if not hl or hl.Parent ~= player.Character then
					if hl then hl:Destroy() end
					hl = Instance.new("Highlight")
					hl.Parent = player.Character
					Highlights[player] = hl
				end
				local col = RoleColor(player)
				hl.FillColor, hl.OutlineColor, hl.FillTransparency = col, col, 0.5
			elseif Highlights[player] then
				Highlights[player]:Destroy()
				Highlights[player] = nil
			end
			if NameESP or DistESP then
				local head = player.Character:FindFirstChild("Head")
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				if head and root then
					local key = tostring(player.UserId)
					if not ESPBill[key] or not ESPBill[key].Parent then
						local bill = Instance.new("BillboardGui")
						bill.AlwaysOnTop = true
						bill.Size = UDim2.fromOffset(120, 28)
						bill.StudsOffset = Vector3.new(0, 3, 0)
						bill.Adornee = head
						bill.Parent = head
						local lb = Instance.new("TextLabel")
						lb.Name = "L"
						lb.Size = UDim2.fromScale(1, 1)
						lb.BackgroundTransparency = 1
						lb.Font = Enum.Font.GothamBold
						lb.TextSize = 12
						lb.TextColor3 = Color3.new(1, 1, 1)
						lb.TextStrokeTransparency = 0.3
						lb.Parent = bill
						ESPBill[key] = bill
					end
					local txt = NameESP and player.Name or ""
					local my = getHRP()
					if DistESP and my then
						txt = txt .. (txt ~= "" and " " or "") .. math.floor((root.Position - my.Position).Magnitude) .. "m"
					end
					local lb = ESPBill[key]:FindFirstChild("L")
					if lb then lb.Text = txt lb.Visible = txt ~= "" end
				end
			end
		end
	end
	if not (NameESP or DistESP) then
		for k, v in pairs(ESPBill) do
			pcall(function() v:Destroy() end)
			ESPBill[k] = nil
		end
	end
	local dg = GetDroppedGun()
	if dg then
		if GunESP then
			if not GunHL or GunHL.Parent ~= dg then
				if GunHL then GunHL:Destroy() end
				GunHL = Instance.new("Highlight")
				GunHL.Parent = dg
				GunHL.FillColor = Color3.fromRGB(255, 255, 0)
				GunHL.FillTransparency = 0.2
			end
		elseif GunHL then
			GunHL:Destroy()
			GunHL = nil
		end
		if AutoGrabGun and not isGrabbing and not hasGun() then
			task.defer(SafeGrabGun)
		end
	elseif GunHL then
		GunHL:Destroy()
		GunHL = nil
	end
	if Fullbright then
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.Brightness = 2
	end
end)

task.spawn(function()
	while true do
		task.wait(0.05)
		if KillAll then
			local my = getHRP()
			if my then
				local knife = getChar() and getChar():FindFirstChild("Knife") or (LP.Backpack and LP.Backpack:FindFirstChild("Knife"))
				if knife then
					if knife.Parent == LP.Backpack then getHum():EquipTool(knife) end
					knife:Activate()
				end
				for _, t in ipairs(Players:GetPlayers()) do
					if t ~= LP and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
						local th = t.Character.HumanoidRootPart
						if not SavedPos[t] then SavedPos[t] = th.CFrame end
						th.CFrame = my.CFrame * CFrame.new(0, 0, -2.5)
					end
				end
			end
		elseif next(SavedPos) then
			for t, cf in pairs(SavedPos) do
				if t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
					t.Character.HumanoidRootPart.CFrame = cf
				end
			end
			SavedPos = {}
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if InfJump then
		local h = getHum()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- ===================== SHADERS (27) =====================
local function wipeFX()
	for _, v in ipairs(Lighting:GetChildren()) do
		if tostring(v.Name):find("Kaisen") then pcall(function() v:Destroy() end) end
	end
end

local function fx(class, name)
	local e = Lighting:FindFirstChild(name)
	if not e then
		e = Instance.new(class)
		e.Name = name
		e.Parent = Lighting
	end
	return e
end

local function applyCC(sat, tint, contrast, brightness)
	local cc = fx("ColorCorrectionEffect", "KaisenCC")
	cc.Saturation = sat or 0
	cc.Contrast = contrast or 0
	cc.Brightness = brightness or 0
	if tint then cc.TintColor = tint end
	return cc
end

local Shaders = {
	{ "Halloween", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.1, 0
		applyCC(0.3, Color3.fromRGB(255, 120, 40), 0.2)
		fx("BloomEffect", "KaisenBloom").Intensity = 1
	end },
	{ "Noir", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.3, 18
		applyCC(-1, Color3.fromRGB(200, 200, 200), 0.4)
	end },
	{ "Cyber", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.6, 2
		applyCC(0.5, Color3.fromRGB(80, 180, 255), 0.25)
		fx("BloomEffect", "KaisenBloom").Intensity = 1.4
	end },
	{ "Warm Film", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2.4, 16
		applyCC(0.2, Color3.fromRGB(255, 220, 170), 0.1)
	end },
	{ "Toxic", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.5, 10
		applyCC(0.6, Color3.fromRGB(120, 255, 80), 0.15)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.9
	end },
	{ "Dream", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2, 12
		applyCC(0.35, Color3.fromRGB(255, 180, 220), 0.1)
		fx("BloomEffect", "KaisenBloom").Intensity = 1.2
		fx("BlurEffect", "KaisenBlur").Size = 2
	end },
	{ "Ice", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2.2, 8
		applyCC(-0.1, Color3.fromRGB(180, 220, 255), 0.2)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.6
	end },
	{ "Sunset", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2, 17.5
		applyCC(0.25, Color3.fromRGB(255, 140, 90), 0.15)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.8
	end },
	{ "Midnight", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 0.6, 0
		applyCC(-0.2, Color3.fromRGB(60, 70, 120), 0.3)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.5
	end },
	{ "Blood Moon", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1, 0
		applyCC(0.15, Color3.fromRGB(200, 40, 40), 0.35)
		fx("BloomEffect", "KaisenBloom").Intensity = 1.1
	end },
	{ "Matrix", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.4, 14
		applyCC(0.4, Color3.fromRGB(40, 255, 80), 0.2)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.7
	end },
	{ "Vaporwave", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.8, 20
		applyCC(0.55, Color3.fromRGB(255, 100, 200), 0.2)
		fx("BloomEffect", "KaisenBloom").Intensity = 1.3
	end },
	{ "Sepia", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2, 15
		applyCC(-0.3, Color3.fromRGB(220, 180, 120), 0.25)
	end },
	{ "Arctic", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2.8, 12
		applyCC(-0.25, Color3.fromRGB(200, 230, 255), 0.15)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.9
	end },
	{ "Neon Pink", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.5, 3
		applyCC(0.7, Color3.fromRGB(255, 50, 180), 0.2)
		fx("BloomEffect", "KaisenBloom").Intensity = 1.6
	end },
	{ "Forest", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2.1, 14
		applyCC(0.2, Color3.fromRGB(120, 200, 100), 0.1)
	end },
	{ "Desert", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2.6, 15
		applyCC(0.15, Color3.fromRGB(255, 200, 120), 0.2)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.5
	end },
	{ "Purple Haze", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.4, 21
		applyCC(0.3, Color3.fromRGB(160, 80, 255), 0.2)
		fx("BloomEffect", "KaisenBloom").Intensity = 1
	end },
	{ "Cinematic", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.7, 16
		applyCC(-0.15, Color3.fromRGB(220, 210, 200), 0.35)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.4
		fx("BlurEffect", "KaisenBlur").Size = 1
	end },
	{ "Retro TV", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.8, 14
		applyCC(0.1, Color3.fromRGB(180, 255, 180), 0.45)
		fx("BlurEffect", "KaisenBlur").Size = 1.5
	end },
	{ "Gold Hour", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2.3, 17
		applyCC(0.3, Color3.fromRGB(255, 190, 80), 0.15)
		fx("BloomEffect", "KaisenBloom").Intensity = 1.1
	end },
	{ "Ocean", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2, 13
		applyCC(0.1, Color3.fromRGB(80, 160, 220), 0.15)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.7
	end },
	{ "Inferno", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.2, 1
		applyCC(0.4, Color3.fromRGB(255, 80, 20), 0.3)
		fx("BloomEffect", "KaisenBloom").Intensity = 1.5
	end },
	{ "Soft Pastel", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2.5, 14
		applyCC(0.4, Color3.fromRGB(255, 210, 230), 0.05)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.8
	end },
	{ "Storm", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 0.9, 6
		applyCC(-0.35, Color3.fromRGB(100, 110, 130), 0.4)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.3
	end },
	{ "Chrome", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 2.2, 14
		applyCC(-0.5, Color3.fromRGB(220, 220, 230), 0.5)
		fx("BloomEffect", "KaisenBloom").Intensity = 1.2
	end },
	{ "Lofi", function()
		wipeFX()
		Lighting.Brightness, Lighting.ClockTime = 1.9, 19
		applyCC(0.15, Color3.fromRGB(255, 160, 140), 0.2)
		fx("BloomEffect", "KaisenBloom").Intensity = 0.6
		fx("BlurEffect", "KaisenBlur").Size = 1
	end },
}

local function shReset()
	wipeFX()
	Lighting.Brightness, Lighting.ClockTime = 2, 14
	Lighting.Ambient = Color3.fromRGB(128, 128, 128)
	Lighting.FogEnd = 100000
end

-- ===================== UI =====================
local Window = Rayfield:CreateWindow({
	Name = "KAISEN X — MM2",
	LoadingTitle = "KAISEN X",
	LoadingSubtitle = "created by KAISEN",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false,
})

local TabHome = Window:CreateTab("Home", 4483362458)
TabHome:CreateButton({Name = "Copy Discord", Callback = function() pcall(function() if setclipboard then setclipboard("https://discord.gg/cs6eGYEGE") end end) end})
TabHome:CreateButton({Name = "Copy TikTok", Callback = function() pcall(function() if setclipboard then setclipboard("@kaisen_x2") end end) end})
TabHome:CreateButton({Name = "Rejoin", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})

local TabCombat = Window:CreateTab("Combat", 4483362458)
TabCombat:CreateSection("Kill")
TabCombat:CreateToggle({Name = "Kill All", CurrentValue = false, Callback = function(v) KillAll = v end})
TabCombat:CreateSection("Gun")
TabCombat:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) SilentAim = v end})
TabCombat:CreateButton({Name = "Grab Gun", Callback = function() SafeGrabGun() end})
TabCombat:CreateToggle({Name = "Auto Grab Gun", CurrentValue = false, Callback = function(v) AutoGrabGun = v end})
TabCombat:CreateSection("Fling")
TabCombat:CreateButton({Name = "Fling Murderer", Callback = function() local m = GetMurderer() if m then FlingPlayer(m) end end})
TabCombat:CreateButton({Name = "Fling Sheriff", Callback = function() local s = GetSheriff() if s then FlingPlayer(s) end end})
TabCombat:CreateButton({Name = "Fling All", Callback = function() FlingAll() end})
TabCombat:CreateDropdown({
	Name = "Fling Target",
	Options = playerNames(),
	CurrentOption = {playerNames()[1]},
	Callback = function(o) FlingTarget = type(o) == "table" and o[1] or o end,
})
TabCombat:CreateButton({Name = "Fling Selected", Callback = function() local p = findPlayer(FlingTarget) if p then FlingPlayer(p) end end})
TabCombat:CreateButton({
	Name = "Reveal Murderer",
	Callback = function()
		local m = GetMurderer()
		if not m then return end
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
	end,
})

local TabFarm = Window:CreateTab("Farm", 4483362458)
TabFarm:CreateSection("Candies")
TabFarm:CreateToggle({
	Name = "Auto Farm (float 3D)",
	CurrentValue = false,
	Callback = function(v)
		AutoFarm = v
		if v then
			local hrp = getHRP()
			if hrp then setupFarmBody(hrp) end
		else
			clearFarmBody()
		end
	end,
})
TabFarm:CreateSlider({Name = "Farm Speed", Range = {15, 90}, Increment = 1, CurrentValue = 40, Callback = function(v) FarmSpeed = v end})
TabFarm:CreateSlider({Name = "Farm Range", Range = {25, 150}, Increment = 5, CurrentValue = 90, Callback = function(v) FarmRange = v end})

local TabVis = Window:CreateTab("Visual", 4483362458)
TabVis:CreateSection("ESP")
TabVis:CreateToggle({Name = "Role ESP", CurrentValue = false, Callback = function(v) ESP = v end})
TabVis:CreateToggle({Name = "Names", CurrentValue = true, Callback = function(v) NameESP = v end})
TabVis:CreateToggle({Name = "Distance", CurrentValue = true, Callback = function(v) DistESP = v end})
TabVis:CreateToggle({Name = "Gun ESP", CurrentValue = false, Callback = function(v) GunESP = v end})
TabVis:CreateSection("World")
TabVis:CreateToggle({
	Name = "Fullbright",
	CurrentValue = false,
	Callback = function(v)
		Fullbright = v
		if not v then Lighting.Brightness = 1 Lighting.Ambient = Color3.fromRGB(128, 128, 128) end
	end,
})

local TabSh = Window:CreateTab("Shaders", 4483362458)
for _, sh in ipairs(Shaders) do
	TabSh:CreateButton({
		Name = sh[1],
		Callback = sh[2],
	})
end
TabSh:CreateButton({Name = "Reset", Callback = shReset})

local TabPl = Window:CreateTab("Player", 4483362458)
TabPl:CreateSection("Movement")
TabPl:CreateSlider({
	Name = "WalkSpeed", Range = {16, 120}, Increment = 1, CurrentValue = 16,
	Callback = function(v)
		WalkSpeed = v
		if not AutoFarm then local h = getHum() if h then h.WalkSpeed = v end end
	end,
})
TabPl:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) Flying = v end})
TabPl:CreateSlider({Name = "Fly Speed", Range = {30, 150}, Increment = 5, CurrentValue = 55, Callback = function(v) FlySpeed = v end})
TabPl:CreateToggle({Name = "Infinite Jump", CurrentValue = true, Callback = function(v) InfJump = v end})
TabPl:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Noclip = v end})
TabPl:CreateSection("Defense")
TabPl:CreateToggle({Name = "Anti Fling", CurrentValue = true, Callback = function(v) AntiFling = v end})
TabPl:CreateToggle({Name = "Ghost", CurrentValue = false, Callback = function(v) SetGhost(v) end})
TabPl:CreateToggle({Name = "Godmode", CurrentValue = false, Callback = function(v) Godmode = v end})
TabPl:CreateToggle({Name = "Auto Dodge", CurrentValue = false, Callback = function(v) AutoDodge = v end})

local TabEx = Window:CreateTab("Extras", 4483362458)
TabEx:CreateToggle({Name = "Fake Lag", CurrentValue = false, Callback = function(v) FakeLag = v end})
TabEx:CreateToggle({Name = "Anti-AFK", CurrentValue = true, Callback = function(v) AntiAFK = v end})
TabEx:CreateSlider({Name = "FOV", Range = {70, 120}, Increment = 1, CurrentValue = 70, Callback = function(v) camera.FieldOfView = v end})
