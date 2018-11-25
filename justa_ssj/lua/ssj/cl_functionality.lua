-- justa's ssj

-- Trigger Interface Response
local function UpdateData(setting_id)
	net.Start("SSJ_InterfaceResponse")
		net.WriteInt(setting_id, 6)
	net.SendToServer()
end

-- Toggle gui 
-- Btw, take my credit out of the gui and you're an asshole xo
surface.CreateFont( "SSJ_Label", { size = 12, weight = 200, font = "Trebuchet24" } )
local function ToggleGUI(data, update)
	if (update) then
		ssj.data = table.Copy(data)
		return
	end

	if (ssj) then
		ssj:Remove()
		ssj = nil 
		gui.EnableScreenClicker(false)
		return
	end

	gui.EnableScreenClicker(true)

	ssj = vgui.Create("EditablePanel")
	ssj:SetSize(300, 228)
	ssj:SetPos(10, ScrH() / 2 - ssj:GetTall()/2)
	ssj.Paint = function(self, width, height)
		surface.SetDrawColor(Color(35, 35, 35, 255))
		surface.DrawRect(0, 0, width, height)
		surface.SetDrawColor(Color(42, 42, 42, 255))
		surface.DrawRect(5, 5, width - 10, height - 10)

		surface.SetDrawColor(color_white)
		surface.DrawLine(80, 29, 220, 29)

		draw.SimpleText("Justa's SSJ Menu", "HUDTimer", width / 2, 18, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	ssj.data = table.Copy(data)

	local settings = {
		{"Toggle", "On", "Off"},
		{"Mode", "All", "6th"},
		{"Show Speed Difference", "On", "Off"},
		{"Show Height Difference", "On", "Off"},
		{"Show Observers Stats", "On", "Off"},
		{"Show Current Time", "On", "Off"},
		{"Close", "Yes", "No"}
	}

	local setting_pans = {}
	function draw_setting(setting, setting_id)
		local pan = ssj:Add("EditablePanel")

		pan:SetSize(ssj:GetWide() - 20, 20)
		pan:SetPos(10, (#setting_pans * 26) + 38)
		pan.Paint = function(self, width, height)
			draw.SimpleText(setting[1], "HUDTimer", 0, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local but = pan:Add("DButton")
		but:SetSize(80, 20)
		but:SetPos(pan:GetWide() - 80, 0)
		but:SetText("")
		but.Paint = function(self, width, height)
			local x = ssj.data[setting_id] and width / 2 or 0
			--PrintTable(ssj.data)

			surface.SetDrawColor(200, 50, 50)
			surface.DrawRect(x, 0, width / 2, height)
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, width, height)

			-- States
			draw.SimpleText(setting[3], "SSJ_Label", 14, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(setting[2], "SSJ_Label", width - 14, 10, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
		but.OnMousePressed = function(self)
			if (setting_id == 7) then
				ToggleGUI()
				return
			end

			UpdateData(setting_id)
		end

		table.insert(setting_pans, pan)
	end

	for k, v in pairs(settings) do
		draw_setting(v, k)
	end
end

-- Print
net.Receive("SSJ_Print", function()
	local str = net.ReadTable()

	chat.AddText(color_white, "[", SSJ_Col, "SSJ", color_white, "] ", unpack(str))
end)

-- Open
net.Receive("SSJ_Open", function()
	ssj_data = net.ReadTable()
	is_update = net.ReadBool()
	ToggleGUI(ssj_data, is_update)
end)
