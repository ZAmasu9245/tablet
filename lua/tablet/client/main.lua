local ui = tablet.ui

local background = Material("ugc/tablet/background.png", "smooth") //ui.NullMaterial

if !file.Exists("materials/ugc/tablet/background.png", "GAME") then ui.DownloadMaterial("http://i.imgur.com/3dCFSLI.png", "smooth", function(m) background = m end) end

surface.CreateFont("ugctablet_appname", {font = "Roboto", size = 16, shadow = false})

local frame
tablet.open = function()
	if IsValid(frame) then return end

	local w, h = tablet.scaleSize()
	local scale = w / tablet.Width

	local animTime = 0.3
	local animEnd = CurTime() + animTime
	local animClose = false
	local animThink = true
	local startTime = CurTime()
	local isF4Down = input.IsKeyDown(KEY_F4)

	local frame_y = ScrH() / 2 - h / 2 + 5.5 * scale
	frame = vgui.Create("DFrame")
	frame:SetSize(w, h)
	frame:SetPos(ScrW() / 2 - w / 2, h)
	frame:MakePopup()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame.Paint = function(self, w, h)
		Derma_DrawBackgroundBlur(self, startTime)

		if animThink then
			local timeLeft = animEnd - CurTime()
			local delta = timeLeft / animTime
			if animClose then delta = 1 - delta end
			local x, y = self:GetPos()

			self:SetPos(x, frame_y + h * delta)
			self:SetAlpha(255 * (1 - delta))

			if delta <= 0 and !animClose or delta >= 1 then
				animThink = false
				if animClose then self:Remove() end
			end
		end

		ui.DrawTexturedRect(0, 0, w, h, tablet.Material)

		if input.IsKeyDown(KEY_F4) then
			if !isF4Down then frame:Close() end
		else
			isF4Down = false
		end
	end
	frame.Close = function(self) if animClose then return end self:SetKeyboardInputEnabled(false); self:SetMouseInputEnabled(false); animEnd = CurTime() + animTime; animClose = true; animThink = true end
	frame.scale = function(self, num) return math.Round(num * scale) end

	local screenX, screenY = frame:scale(176), frame:scale(150)
	local screenW, screenH = frame:scale(1467), frame:scale(1090)

	local barHeight = frame:scale(30)
	local barSpace = frame:scale(5)

	surface.CreateFont("ugctablet_time", {font = "Roboto", size = barHeight - barSpace * 2})

	local batteryHeight = frame:scale(20)
	local batteryWidth = frame:scale(43)

	local signalWidth = frame:scale(28)
	local signalHeight = frame:scale(20)

	local bar = vgui.Create("DPanel", frame)
	bar:SetPos(screenX, screenY)
	bar:SetSize(screenW, barHeight)
	bar.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 80, 80, 80)

		local tw, _ = ui.DrawText(os.date("%I:%M %p", os.time()), "ugctablet_time", w - barSpace * 2, h / 2, Color(255, 255, 255, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		ui.DrawTexturedRect(barSpace * 2, h / 2 - signalHeight / 2, signalWidth, signalHeight, tablet.Materials.Signal, 255, 255, 255, 100)
		ui.DrawTexturedRect(w - tw - barSpace * 4 - batteryWidth, h / 2 - batteryHeight / 2, batteryWidth, batteryHeight, tablet.Materials.Battery, 255, 255, 255, 100)
	end

	local rowSpace = 32
	local appIconSize = math.Min(frame:scale(150), 92) //92
	local perRow = math.floor(screenW / (appIconSize + rowSpace))
	rowSpace = (screenW - perRow * appIconSize) / (perRow + 1)

	local layout = vgui.Create("DPanel", frame)
	layout:SetPos(screenX, screenY + barHeight)
	layout:SetSize(screenW, screenH - barHeight)
	layout.Clear = function(self) for k, v in pairs(self:GetChildren()) do if IsValid(v) then v:Remove() end end end

	frame.openApp = function(self, id)
		local app = tablet.apps[id]
		if !app then ugc.error("invalid app id - " .. tostring(id)); return end
		layout:Clear()
		self.backFunction = self.openMainPage
		self.currentApp = id
		if app.onOpen then app:onOpen(layout, frame) end
	end

	frame.closeApp = function(self)
		local id = self.currentApp

		self.backFunction = function() self:openApp(id) end
		self.currentApp = nil
		self:openMainPage()
	end

	frame.openMainPage = function(self)
		layout:Clear()
		layout.Paint = function(self, w, h) ui.DrawTexturedRect(0, 0, w, h, background) end
		local i = 1
		local line = 1
		for _, app in SortedPairsByMemberValue(tablet.apps, "SortOrder") do
			if app.canUse and !app.canUse(LocalPlayer()) then continue end
			local btn = vgui.Create("DButton", layout)
			btn:SetSize(appIconSize, appIconSize)
			btn:SetPos(rowSpace + (i - 1) * (rowSpace + appIconSize), rowSpace + (line - 1) * (rowSpace + appIconSize))
			btn:SetText("")
			btn.hclr = Color(255, 255, 255, 0)
			btn.Paint = function(self, w, h)
			  	ui.DrawTexturedRect(0, 0, w, h, app.Icon)
				ui.DrawTexturedRect(0, 0, w, h, tablet.Materials.AppIcon, self.hclr)
				if self.Depressed then self.hclr = ui.LerpColor(FrameTime() * 3, self.hclr, Color(0, 0, 0, 40)) elseif self.Hovered then self.hclr = ui.LerpColor(FrameTime() * 3, self.hclr, Color(255, 255, 255, 15)) else self.hclr = ui.LerpColor(FrameTime() * 4, self.hclr, Color(255, 255, 255, 0)) end
				surface.DisableClipping(true)
					ui.DrawText(app.Name, "ugctablet_appname", w / 2 + 1, h + barSpace + 1, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					ui.DrawText(app.Name, "ugctablet_appname", w / 2, h + barSpace, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				surface.DisableClipping(false)
			end
			btn.DoClick = function() frame:openApp(app.ID) end
			i = i + 1

			if i >= perRow then
				line = line + 1
				i = 1
			end
		end
	end

	frame:openMainPage()

	local spaceDown = frame:scale(19)
	local frameDown = frame:scale(126)
	local btnSize = frame:scale(64)
	local btnDefaultColor = Color(150, 150, 150)
	local btnHoverColor = Color(255, 255, 255)

	local power = vgui.Create("DButton", frame)
	power:SetSize(btnSize, btnSize)
	power:SetPos(w / 2 - btnSize / 2, h - spaceDown - frameDown / 2 - btnSize / 2)
	power:SetText("")
	power.clr = btnDefaultColor
	power.Paint = function(self, w, h)  if self.Hovered then self.clr = ui.LerpColor(FrameTime() * 3, self.clr, btnHoverColor) else self.clr = ui.LerpColor(FrameTime() * 3, self.clr, btnDefaultColor) end ui.DrawTexturedRect(0, 0, w, h, tablet.Materials.Power, self.clr) end
	power.DoClick = function() frame:Close() end

	local menubtn = vgui.Create("DButton", frame)
	menubtn:SetSize(btnSize, btnSize)
	menubtn:SetPos(w / 2 - btnSize / 2 - btnSize * 2, h - spaceDown - frameDown / 2 - btnSize / 2)
	menubtn:SetText("")
	menubtn.clr = btnDefaultColor
	menubtn.Paint = function(self, w, h) if self.Hovered then self.clr = ui.LerpColor(FrameTime() * 3, self.clr, btnHoverColor) else self.clr = ui.LerpColor(FrameTime() * 3, self.clr, btnDefaultColor) end ui.DrawTexturedRect(0, 0, w, h, tablet.Materials.Menu, self.clr) end
	menubtn.DoClick = function() if frame.currentApp then frame:closeApp() else frame:openMainPage() end end

	local backbtn = vgui.Create("DButton", frame)
	backbtn:SetSize(btnSize, btnSize)
	backbtn:SetPos(w / 2 - btnSize / 2 + btnSize * 2, h - spaceDown - frameDown / 2 - btnSize / 2)
	backbtn:SetText("")
	backbtn.clr = btnDefaultColor
	backbtn.Paint = function(self, w, h) if self.Hovered then self.clr = ui.LerpColor(FrameTime() * 3, self.clr, btnHoverColor) else self.clr = ui.LerpColor(FrameTime() * 3, self.clr, btnDefaultColor) end ui.DrawTexturedRect(0, 0, w, h, tablet.Materials.Back, self.clr) end
	backbtn.DoClick = function()
		if frame.backFunction then 
			frame.backFunction()
		end
	end

	return frame
end

tablet.close = function()
	frame:Remove() 
end
tablet.get = function() return frame end
tablet.toggle = function() if IsValid(frame) then tablet.close() else tablet.open() end end

hook.Add("PostGamemodeLoaded", "tablet", function()
	(GAMEMODE or GM).ShowSpare2 = tablet.toggle
end)

concommand.Add("tablet_toggle", tablet.toggle)