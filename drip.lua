print("KAISENX | Speed Draw! | loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local DISCORD_LINK = "https://discord.gg/xWPp9kxTs"
local TIKTOK_USER = "@kaisen_x2"
local MENU_BG = "rbxassetid://133435869312714"

local revealTheme = false
local autoVote = false
local voteStars = 5
local speedOn = false
local walkSpeed = 28
local antiAfk = true
local fullbright = false
local showFps = false
local drawSpeed = 0.008
local drawBusy = false

local themeLabel, fpsLabel = nil, nil
local originalWalkSpeed = nil
local originalLighting = {}
local lastVote = 0
local recordedBuffers = {}

local function getHum()
	local c = localPlayer.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function setSpeed(on, spd)
	local h = getHum()
	if not h then return end
	if on then
		originalWalkSpeed = originalWalkSpeed or h.WalkSpeed
		h.WalkSpeed = spd
	elseif originalWalkSpeed then
		h.WalkSpeed = originalWalkSpeed
		originalWalkSpeed = nil
	end
end

local function saveLighting()
	if next(originalLighting) then return end
	originalLighting = {
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime,
		FogEnd = Lighting.FogEnd,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
	}
end

local function applyFullbright(on)
	saveLighting()
	if on then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.Ambient = Color3.fromRGB(200, 200, 200)
		Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
	else
		for k, v in pairs(originalLighting) do
			pcall(function() Lighting[k] = v end)
		end
	end
end

local function findThemeText()
	local found = nil
	local function scan(obj)
		if found then return end
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			local t = (obj.Text or ""):gsub("%s+", " ")
			if #t > 2 and #t < 55 then
				local lower = t:lower()
				if not lower:find("vote") and not lower:find("star") and not lower:find("coin")
					and not lower:find("shop") and not lower:find("like") and not lower:find("report")
					and not lower:find("time") and not lower:find("round") and not lower:find("player")
					and not lower:find("vip") and not lower:find("undo") and not lower:find("redo") then
					if obj.TextSize >= 16 or (obj.AbsoluteSize and obj.AbsoluteSize.Y >= 26) then
						found = t
					end
				end
			end
		end
		for _, c in ipairs(obj:GetChildren()) do scan(c) end
	end
	pcall(function()
		if localPlayer:FindFirstChild("PlayerGui") then scan(localPlayer.PlayerGui) end
	end)
	return found
end

local function updateThemeHud()
	if not revealTheme then
		if themeLabel then themeLabel.Visible = false end
		return
	end
	local parent = CoreGui
	pcall(function() if gethui then parent = gethui() end end)
	if not themeLabel or not themeLabel.Parent then
		local sg = parent:FindFirstChild("KX_ThemeHud") or Instance.new("ScreenGui")
		sg.Name = "KX_ThemeHud"
		sg.IgnoreGuiInset = true
		sg.ResetOnSpawn = false
		sg.Parent = parent
		themeLabel = Instance.new("TextLabel")
		themeLabel.Size = UDim2.new(0, 420, 0, 36)
		themeLabel.Position = UDim2.new(0.5, -210, 0, 12)
		themeLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		themeLabel.BackgroundTransparency = 0.25
		themeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		themeLabel.Font = Enum.Font.GothamBold
		themeLabel.TextSize = 18
		themeLabel.Text = "Theme: ..."
		themeLabel.Parent = sg
		Instance.new("UICorner", themeLabel).CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(120, 80, 255)
		stroke.Thickness = 1.5
		stroke.Parent = themeLabel
	end
	local txt = findThemeText()
	themeLabel.Visible = true
	themeLabel.Text = txt and ("Theme: " .. txt) or "Theme: (waiting...)"
end

local function tryAutoVote()
	if not autoVote then return end
	if tick() - lastVote < 1.2 then return end
	lastVote = tick()
	pcall(function()
		local pg = localPlayer:FindFirstChild("PlayerGui")
		if not pg then return end
		for _, obj in ipairs(pg:GetDescendants()) do
			if obj:IsA("ImageButton") or obj:IsA("TextButton") then
				local n = (obj.Name .. " " .. (obj.Text or "")):lower()
				if n:find("star") or n:find("vote") or n:find(tostring(voteStars)) then
					pcall(function()
						if firesignal then firesignal(obj.MouseButton1Click) end
					end)
				end
			end
		end
	end)
end

local function updateFpsHud()
	if not showFps then
		if fpsLabel then fpsLabel.Visible = false end
		return
	end
	local parent = CoreGui
	pcall(function() if gethui then parent = gethui() end end)
	if not fpsLabel or not fpsLabel.Parent then
		local sg = parent:FindFirstChild("KX_FpsHud") or Instance.new("ScreenGui")
		sg.Name = "KX_FpsHud"
		sg.IgnoreGuiInset = true
		sg.ResetOnSpawn = false
		sg.Parent = parent
		fpsLabel = Instance.new("TextLabel")
		fpsLabel.Size = UDim2.new(0, 90, 0, 28)
		fpsLabel.Position = UDim2.new(1, -100, 0, 10)
		fpsLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
		fpsLabel.BackgroundTransparency = 0.3
		fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 140)
		fpsLabel.Font = Enum.Font.GothamBold
		fpsLabel.TextSize = 14
		fpsLabel.Text = "FPS: --"
		fpsLabel.Parent = sg
		Instance.new("UICorner", fpsLabel).CornerRadius = UDim.new(0, 6)
	end
	fpsLabel.Visible = true
end

local function findCanvas()
	local pg = localPlayer:FindFirstChild("PlayerGui")
	if not pg then return nil end
	for _, gui in ipairs(pg:GetChildren()) do
		local drawing = gui:FindFirstChild("Drawing")
		if drawing then
			local canvas = drawing:FindFirstChild("Canvas")
			if canvas and canvas:IsA("GuiObject") then
				return canvas
			end
		end
	end
	for _, obj in ipairs(pg:GetDescendants()) do
		if obj.Name == "Canvas" and obj:IsA("GuiObject") then
			local p = obj.Parent
			if p and p.Name == "Drawing" then return obj end
		end
	end
	for _, obj in ipairs(pg:GetDescendants()) do
		if obj.Name == "Canvas" and obj:IsA("GuiObject") then
			local s = obj.AbsoluteSize
			if s.X > 150 and s.Y > 100 then return obj end
		end
	end
	return nil
end

-- Mouse CORRECTO (con coordenadas)
local function mouseMove(x, y)
	pcall(function()
		VirtualInputManager:SendMouseMoveEvent(x, y, game)
	end)
end

local function mouseDown(x, y)
	pcall(function()
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	end)
end

local function mouseUp(x, y)
	pcall(function()
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
	end)
end

local function stroke(x1, y1, x2, y2, steps)
	steps = math.max(3, steps or 10)
	mouseMove(x1, y1)
	task.wait(0.01)
	mouseDown(x1, y1)
	for i = 1, steps do
		local t = i / steps
		local x = x1 + (x2 - x1) * t
		local y = y1 + (y2 - y1) * t
		mouseMove(x, y)
		task.wait(drawSpeed)
	end
	mouseUp(x2, y2)
	task.wait(0.01)
end

local function doAutoDraw()
	if drawBusy then return end
	drawBusy = true
	task.spawn(function()
		local canvas = findCanvas()
		if not canvas then
			warn("[KAISENX] Canvas not found")
			drawBusy = false
			return
		end
		task.wait(0.08)
		local pos = canvas.AbsolutePosition
		local size = canvas.AbsoluteSize
		if size.X < 40 or size.Y < 40 then
			warn("[KAISENX] Canvas too small")
			drawBusy = false
			return
		end

		local pad = 20
		local x0, y0 = pos.X + pad, pos.Y + pad
		local x1, y1 = pos.X + size.X - pad, pos.Y + size.Y - pad
		local w, h = x1 - x0, y1 - y0
		print("[KAISENX] Draw", math.floor(w), "x", math.floor(h), "at", math.floor(x0), math.floor(y0))

		-- borde
		stroke(x0, y0, x1, y0, 16)
		stroke(x1, y0, x1, y1, 16)
		stroke(x1, y1, x0, y1, 16)
		stroke(x0, y1, x0, y0, 16)

		-- rejilla
		for i = 1, 5 do
			local x = x0 + w * (i / 6)
			stroke(x, y0 + 4, x, y1 - 4, 12)
		end
		for j = 1, 4 do
			local y = y0 + h * (j / 5)
			stroke(x0 + 4, y, x1 - 4, y, 12)
		end

		-- diagonales
		stroke(x0 + 6, y0 + 6, x1 - 6, y1 - 6, 18)
		stroke(x1 - 6, y0 + 6, x0 + 6, y1 - 6, 18)

		-- circulos
		local function circle(cx, cy, r)
			local pts = {}
			for a = 0, 12 do
				local ang = (a / 12) * math.pi * 2
				table.insert(pts, { cx + math.cos(ang) * r, cy + math.sin(ang) * r })
			end
			for i = 1, #pts - 1 do
				stroke(pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], 4)
			end
		end
		circle(x0 + w * 0.5, y0 + h * 0.5, math.min(w, h) * 0.18)
		circle(x0 + w * 0.3, y0 + h * 0.35, math.min(w, h) * 0.08)
		circle(x0 + w * 0.7, y0 + h * 0.35, math.min(w, h) * 0.08)

		for i = 1, 12 do
			stroke(
				x0 + w * math.random(),
				y0 + h * math.random(),
				x0 + w * math.random(),
				y0 + h * math.random(),
				6
			)
		end

		drawBusy = false
		print("[KAISENX] Auto Draw done")
	end)
end

-- Remote DrawingToolReplication
local function getDrawRemote()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then return nil end
	return remotes:FindFirstChild("DrawingToolReplication")
end

local function fireDrawBuffer(buf)
	local rem = getDrawRemote()
	if not rem or not buf then return false end
	local ok = pcall(function()
		rem:FireServer(buf)
	end)
	return ok
end

-- Hook: graba buffers cuando dibujas UNA vez a mano
local hookOn = false
local function startRecordHook()
	if hookOn then return end
	local rem = getDrawRemote()
	if not rem then
		warn("[KAISENX] Remote not found")
		return
	end
	hookOn = true
	local old = rem.FireServer
	rem.FireServer = newcclosure(function(self, ...)
		local args = {...}
		for _, v in ipairs(args) do
			if typeof(v) == "buffer" then
				table.insert(recordedBuffers, v)
				print("[KAISENX] Recorded stroke #", #recordedBuffers, "len", buffer.len(v))
			end
		end
		return old(self, ...)
	end)
	print("[KAISENX] Record ON - draw 1-2 lines with pencil")
end

local function replayRecorded()
	if #recordedBuffers == 0 then
		warn("[KAISENX] No recorded strokes - use Record first")
		return
	end
	task.spawn(function()
		for i, buf in ipairs(recordedBuffers) do
			fireDrawBuffer(buf)
			task.wait(0.05)
		end
		-- repetir varias veces para llenar
		for r = 1, 8 do
			for _, buf in ipairs(recordedBuffers) do
				fireDrawBuffer(buf)
				task.wait(0.03)
			end
		end
		print("[KAISENX] Replay done")
	end)
end

-- buffer que capturaste antes (prueba)
local sampleBuf = nil
pcall(function()
	sampleBuf = buffer.fromstring("S<\227o%\136\147#\253\227\164\133\194M\244\174z\234P2\181\151\238\149\222\240")
end)

task.spawn(function()
	while true do
		task.wait(40)
		if antiAfk then
			pcall(function()
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
				task.wait(0.05)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
			end)
		end
	end
end)

localPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	originalWalkSpeed = nil
	if speedOn then setSpeed(true, walkSpeed) end
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

local function applyMenuBackground()
	task.spawn(function()
		for i = 1, 25 do
			local parent = CoreGui
			pcall(function() if gethui then parent = gethui() end end)
			for _, gui in ipairs(parent:GetDescendants()) do
				if gui:IsA("Frame") and (gui.Name:lower():find("window") or (gui.Size.X.Offset >= 380 and gui.Size.Y.Offset >= 380)) then
					if not gui:FindFirstChild("KX_MenuBG") then
						local img = Instance.new("ImageLabel")
						img.Name = "KX_MenuBG"
						img.BackgroundTransparency = 1
						img.Image = MENU_BG
						img.ScaleType = Enum.ScaleType.Crop
						img.Size = UDim2.fromScale(1, 1)
						img.ZIndex = 0
						img.Parent = gui
						return
					end
				end
			end
			task.wait(0.15)
		end
	end)
end

local function startHub()
	local WindUI = loadWindUI()
	if not WindUI then
		warn("[KAISENX] WindUI failed")
		return
	end

	local Window = WindUI:CreateWindow({
		Title = "KAISENX | Speed Draw!",
		Author = "created by KAISEN",
		Folder = "KaisenXSpeedDraw",
		Size = UDim2.fromOffset(500, 560),
		Transparent = true,
		Theme = "Crimson",
		Resizable = true,
		SideBarWidth = 140,
	})

	applyMenuBackground()

	local Home = Window:Tab({ Title = "Home", Icon = "star" })
	Home:Paragraph({
		Title = "KAISENX Speed Draw",
		Desc = "Auto Draw (mouse fixed) · Record/Replay remote · Theme · Vote"
	})
	Home:Button({
		Title = "Copy Discord",
		Callback = function()
			pcall(function() setclipboard(DISCORD_LINK) end)
		end
	})
	Home:Button({
		Title = "Copy TikTok",
		Callback = function()
			pcall(function() setclipboard("https://www.tiktok.com/" .. TIKTOK_USER) end)
		end
	})

	local Draw = Window:Tab({ Title = "Draw", Icon = "pencil" })
	Draw:Button({
		Title = "1) AUTO DRAW Mouse",
		Callback = function() doAutoDraw() end
	})
	Draw:Button({
		Title = "2) RECORD strokes (draw 1 line)",
		Callback = function() startRecordHook() end
	})
	Draw:Button({
		Title = "3) REPLAY recorded (spam)",
		Callback = function() replayRecorded() end
	})
	Draw:Button({
		Title = "Test sample buffer",
		Callback = function()
			if sampleBuf then
				fireDrawBuffer(sampleBuf)
				print("[KAISENX] sample buffer fired")
			end
		end
	})
	Draw:Button({
		Title = "Find Canvas (test)",
		Callback = function()
			local c = findCanvas()
			if c then
				print("[KAISENX] Found:", c:GetFullName(), c.AbsoluteSize, c.AbsolutePosition)
			else
				print("[KAISENX] Canvas NOT found")
			end
		end
	})
	Draw:Slider({
		Title = "Draw Speed (lower = faster)",
		Value = { Min = 0.002, Max = 0.03, Default = 0.008 },
		Step = 0.001,
		Callback = function(v) drawSpeed = v end
	})
	Draw:Toggle({
		Title = "Reveal Theme (HUD)",
		Default = false,
		Callback = function(v)
			revealTheme = v
			if not v and themeLabel then themeLabel.Visible = false end
		end
	})
	Draw:Toggle({
		Title = "Auto Vote Stars",
		Default = false,
		Callback = function(v) autoVote = v end
	})
	Draw:Slider({
		Title = "Stars to give",
		Value = { Min = 1, Max = 5, Default = 5 },
		Callback = function(v) voteStars = v end
	})
	Draw:Paragraph({
		Title = "How to use",
		Desc = "Try button 1 first.\nIf nothing: press 2, draw ONE line yourself, then press 3."
	})

	local Misc = Window:Tab({ Title = "Misc", Icon = "settings" })
	Misc:Toggle({
		Title = "Lobby Speed",
		Default = false,
		Callback = function(v)
			speedOn = v
			setSpeed(v, walkSpeed)
		end
	})
	Misc:Slider({
		Title = "WalkSpeed",
		Value = { Min = 16, Max = 50, Default = 28 },
		Callback = function(v)
			walkSpeed = v
			if speedOn then setSpeed(true, walkSpeed) end
		end
	})
	Misc:Toggle({
		Title = "Anti AFK",
		Default = true,
		Callback = function(v) antiAfk = v end
	})
	Misc:Toggle({
		Title = "Fullbright",
		Default = false,
		Callback = function(v)
			fullbright = v
			applyFullbright(v)
		end
	})
	Misc:Toggle({
		Title = "Show FPS",
		Default = false,
		Callback = function(v)
			showFps = v
			if not v and fpsLabel then fpsLabel.Visible = false end
		end
	})

	local Set = Window:Tab({ Title = "Settings", Icon = "sliders" })
	Set:Dropdown({
		Title = "Theme",
		Values = { "Dark", "Light", "Rose", "Indigo", "Crimson" },
		Value = "Crimson",
		Callback = function(name)
			pcall(function()
				if WindUI.SetTheme then WindUI:SetTheme(name) end
			end)
		end
	})

	local fpsCounter, fpsLast = 0, tick()
	RunService.RenderStepped:Connect(function()
		updateThemeHud()
		updateFpsHud()
		tryAutoVote()
		if speedOn then setSpeed(true, walkSpeed) end
		if showFps and fpsLabel then
			fpsCounter = fpsCounter + 1
			if tick() - fpsLast >= 1 then
				fpsLabel.Text = "FPS: " .. tostring(fpsCounter)
				fpsCounter = 0
				fpsLast = tick()
			end
		end
	end)
end

task.spawn(startHub)
