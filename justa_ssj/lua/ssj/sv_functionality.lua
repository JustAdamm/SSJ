-- justa's ssj

-- Net strings
util.AddNetworkString("SSJ_Print")
util.AddNetworkString("SSJ_Open")
util.AddNetworkString("SSJ_InterfaceResponse")

-- Neat
local SSJ = {}

-- Load
local function LoadPlayer(pl)
	-- Just a timer
	timer.Simple(1, function()
		local ssj = pl:GetPData("SSJ_Settings", false)

		pl.SSJ = {}
		pl.SSJ["Jumps"] = {}
		pl.SSJ["Settings"] = ssj and util.JSONToTable(ssj) or {false, true, false, false, true}
	end)
end
hook.Add("PlayerInitialSpawn", "SSJ.LoadPlayer", LoadPlayer)

-- The "!ssj" command
local function AddCommand()
	Command:Register({"ssj", "s6j", "sj", "ssjmenu", "justascool"}, function(pl)
		-- Core:Send(pl, "GUI_Open", {"SSJ", {pl.SSJ}})
		SSJ:OpenMenuForPlayer(pl)
	end )
end
hook.Add("Initialize", "SSJ.AddCommand", AddCommand)

-- Adding ssj jumps
local function OnPlayerHitGround(pl)
	if LocalPlayer and pl != LocalPlayer() then return end
	if not pl.Style then pl.Style = Timer.Style or 1 end

	if pl.SSJ and pl.SSJ["InSpace"] then
		table.insert(pl.SSJ["Jumps"], SSJ:RetrieveData(pl))
		SSJ:Display(pl)
	end
end
hook.Add("OnPlayerHitGround", "SSJ.OnPlayerHitGround", OnPlayerHitGround)

-- Key Press 
-- Work out first jump data
local function KeyPress(pl, key)
	if (key == IN_JUMP) and pl:OnGround() and pl:Alive() then
		-- In Space
		pl.SSJ["InSpace"] = true 

		-- Add statistic
		pl.SSJ["Jumps"] = {}
		pl.SSJ["Jumps"][1] = SSJ:RetrieveData(pl)

		-- Display to players
		SSJ:Display(pl)
	end
end

-- Key Release
local function KeyRelease(pl, key)
	if (key == IN_JUMP) and pl.SSJ["InSpace"] then
		pl.SSJ["InSpace"] = false 
	end
end

-- Hooks
hook.Add("KeyPress", "SSJ.KeyPress", KeyPress)
hook.Add("KeyRelease", "SSJ.KeyRelease", KeyRelease)

-- Open menu for player
function SSJ:OpenMenuForPlayer(pl, isupdate)
	net.Start("SSJ_Open")
		net.WriteTable(pl.SSJ["Settings"])
		net.WriteBool(isupdate and isupdate or false)
	net.Send(pl)
end

-- Retrieve Data
function SSJ:RetrieveData(pl)
	local velocity = pl:GetVelocity():Length2D()
	local pos = pl:GetPos().z

	return {velocity, pos}
end

-- Interface Response
local function InterfaceResponse(len, pl)
	-- The key
	local k = net.ReadInt(6)
	print(k)

	-- The setting
	pl.SSJ["Settings"][k] = (not pl.SSJ["Settings"][k])
	pl:SetPData("SSJ_Settings", util.TableToJSON(pl.SSJ["Settings"]))

	-- Callback
	SSJ:OpenMenuForPlayer(pl, true)
end
net.Receive("SSJ_InterfaceResponse", InterfaceResponse)

-- Print
function SSJ:Print(pl, str)
	net.Start("SSJ_Print")
		net.WriteTable(str)
	net.Send(pl)
end

-- Display 
function SSJ:Display(pl)
	-- No SSJ Table? What.
	if (not pl.SSJ) then return end

	-- They're not holding space.
	if (not pl.SSJ["InSpace"]) then return end

	-- Prevent weird spamming in zone.
	if (#pl.SSJ["Jumps"] > 1) and pl.InZone then return end 

	-- Replay bot
	if pl:IsBot() then return end 

	-- Current Data
	local currentJump = pl.SSJ["Jumps"][#pl.SSJ["Jumps"]]
	local currentVel = currentJump[1]
	local currentHeight = currentJump[2]

	-- Build string table
	local dStr = {"Jumps: ", SSJ_Col, tostring(#pl.SSJ["Jumps"]), color_white, " | ", "Speed: ", SSJ_Col, tostring(math.Round(currentVel)), color_white}

	-- Values
	local difference, height

	-- Previous Jump
	if (#pl.SSJ["Jumps"] ~= 1) then
		local oldData = pl.SSJ["Jumps"][#pl.SSJ["Jumps"] - 1]

		-- Check
		if (not oldData) then return end

		local oldVelocity = oldData[1]
		local oldHeight = oldData[2]
		difference = math.Round(currentVel - oldVelocity)
		height = math.Round(currentHeight - oldHeight)
	end

	-- Clients to show
	local clients = {pl}
	for k, v in pairs(player.GetAll()) do
		if (not v.Spectating) or (not v.SSJ["Settings"][5]) then continue end 

		local target = v:GetObserverTarget()
		if target:IsValid() and target == pl then 
			table.insert(clients, v)
		end
	end

	-- Start to show
	for k, v in pairs(clients) do
		local str = table.Copy(dStr)

		-- SSJ Off
		if (not v.SSJ["Settings"][1]) then continue end
		
		-- Every jump disabled
		if (not v.SSJ["Settings"][2]) and (#pl.SSJ["Jumps"] ~= 6) then continue end

		-- Height
		if (#pl.SSJ["Jumps"] > 1) and (v.SSJ["Settings"][4]) then
			table.insert(str, " | Height ∆: ")
			table.insert(str, SSJ_Col)
			table.insert(str, tostring(height))
			table.insert(str, color_white)
		end

		-- Speed Difference
		if (#pl.SSJ["Jumps"] > 1) and (v.SSJ["Settings"][3]) then
			table.insert(str, " | Speed ∆: ")
			table.insert(str, SSJ_Col)
			table.insert(str, tostring(difference))
			table.insert(str, color_white)
		end

		-- Print
		--Core:Send(v, "Print", str)
		SSJ:Print(v, str)
	end
end

print("[SSJ] Loaded successfully yay, go bhop yay lets go woo!")