-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/

local betting_pos_x = 150
local betting_pos_y = ScrH() / 2 - (ScrH() / 5)
local t_betcount = 0
local i_betcount = 0
-- Languages:
-- 1 = english
-- 2 = german
local lang = 1
local KARMABET_LANG = {}

-- Manual language strings
-- If you want to add another language, proceed by incrementing the number in the []-brackets
KARMABET_LANG[1] = {}
KARMABET_LANG[1].runningbets = "Running Bets"
KARMABET_LANG[1].for_t = " for Traitors"
KARMABET_LANG[1].for_i = " for Innocents"
KARMABET_LANG[1].derma_title = "Place your bet! - KARMABET"
KARMABET_LANG[1].derma_chooseteam = "Choose Team"
KARMABET_LANG[1].derma_teaminno = "Innocent"
KARMABET_LANG[1].derma_teamtraitor = "Traitor"
KARMABET_LANG[1].derma_karmaamount = "Karma Amount"
KARMABET_LANG[1].derma_allin = "All-In"
KARMABET_LANG[1].derma_button = "BET"

KARMABET_LANG[2] = {}
KARMABET_LANG[2].runningbets = "Laufende Wetten"
KARMABET_LANG[2].for_t = " für Traitor"
KARMABET_LANG[2].for_i = " für Innocent"
KARMABET_LANG[2].derma_title = "Platziere deine Wette! - KARMAWETTEN"
KARMABET_LANG[2].derma_chooseteam = "Wähle Team"
KARMABET_LANG[2].derma_teaminno = "Innocent"
KARMABET_LANG[2].derma_teamtraitor = "Traitor"
KARMABET_LANG[2].derma_karmaamount = "Menge an Karma"
KARMABET_LANG[2].derma_allin = "All-In"
KARMABET_LANG[2].derma_button = "WETTE"


hook.Add( "HUDPaint", "BettingHUD", function()
	-- Only show bets when there are bets placed
	if t_betcount ~= 0 or i_betcount ~= 0 then
		-- Top title
		draw.DrawText( KARMABET_LANG[lang].runningbets, "TargetID", ScrW() - betting_pos_x, betting_pos_y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		
		-- Traitor amount
		draw.DrawText( t_betcount .. KARMABET_LANG[lang].for_t, "TargetIDSmall", ScrW() - betting_pos_x, betting_pos_y + 20, Color( 255, 0, 0, 255 ), TEXT_ALIGN_LEFT )
		
		-- Innocent amount
		draw.DrawText( i_betcount .. KARMABET_LANG[lang].for_i, "TargetIDSmall", ScrW() - betting_pos_x, betting_pos_y + 35, Color( 0, 255, 0, 255 ), TEXT_ALIGN_LEFT )
	end
end)

-- Here we get the server's feedback of how high the bets currently are
net.Receive( "karmabet_updatehud", function( net_response )
	t_betcount = net.ReadInt( 32 )
	i_betcount = net.ReadInt( 32 )
	lang = net.ReadInt( 8 )
end)

-- Shows a GUI to place a bet
local function showBetGUI( minimum, maximum, allinvalue, language, team )

	-- prevents the window from being opened multiple times
	if bettingFrame then 
		local temp = bettingFrame
		bettingFrame = nil
		temp:Remove() 
	end
	
	local allin = false
	
	-- Alternating button/panel color
	local panelColor = Color(54, 63, 71, 255)
	local buttonColor = Color(44, 120, 178, 255)
	
	-- MAIN FRAME
	bettingFrame = vgui.Create( "DFrame" )
	bettingFrame:SetSize( 400, 200 )
	bettingFrame:SetPos( ScrW() / 2 - 200 , ScrH() / 2 - 100 )
	bettingFrame:SetTitle( KARMABET_LANG[language].derma_title )
	bettingFrame:SetVisible( true )
	bettingFrame:SetDraggable( true )
	bettingFrame:ShowCloseButton( true )
	bettingFrame.Paint = function( self, w, h )
		draw.RoundedBox( 8, 0, 0, 400, 200, panelColor )
	end
	bettingFrame:MakePopup()
	
	-- TEAM SELECTION DROP DOWN MENU
	local teamselect = vgui.Create( "DComboBox", bettingFrame )
	teamselect:SetPos( 125, 50 )
	teamselect:SetSize( 150, 20 )
	-- Depending on our previous selection, force a player to keep betting for a certain team
	if team == "" or not team then
		teamselect:SetValue( KARMABET_LANG[language].derma_chooseteam )
		teamselect:AddChoice( KARMABET_LANG[language].derma_teaminno )
		teamselect:AddChoice( KARMABET_LANG[language].derma_teamtraitor )
	elseif team == "i" then
		teamselect:SetValue( KARMABET_LANG[language].derma_teaminno )
		panelColor = Color( 54, 71, 54, 255 )
	else
		teamselect:SetValue( KARMABET_LANG[language].derma_teamtraitor )
		panelColor = Color( 71, 54, 54, 255 )
	end
	
	-- SLIDER TO DEFINE KARMA BETTING AMOUNT
	local slider = vgui.Create( "DNumSlider", bettingFrame )
	slider:SetSize( 225, 25 )
	slider:Center()
	slider:SetPos( slider:GetPos( 1 ), 75 )
	slider:SetText( KARMABET_LANG[language].derma_karmaamount )
	slider:SetMin( minimum )
	slider:SetMax( maximum )
	slider:SetValue( minimum )
	slider:SetDecimals( 0 )	
	
	-- CHECKBOX FOR ALL-IN
	local allinCheck = vgui.Create( "DCheckBoxLabel", bettingFrame )
	allinCheck:Center()
	allinCheck:SetSize( 250, 80 )
	allinCheck:SetPos( slider:GetPos(1) + slider:GetSize(1), 80 )
	allinCheck:SetText( KARMABET_LANG[language].derma_allin )
	allinCheck:SetValue( 0 )
	allinCheck:SizeToContents()
	
	-- SENDING BUTTON
	local sendbet = vgui.Create( "DButton", bettingFrame )
	sendbet:SetSize( 125, 30 )
	sendbet:Center()
	sendbet:SetPos( sendbet:GetPos( 1 ), teamselect:GetSize( 2 ) )
	sendbet:SetText( KARMABET_LANG[language].derma_button )
	sendbet:SetTextColor( Color(255, 255, 255, 255) )
	if teamselect:GetValue() == KARMABET_LANG[language].derma_chooseteam then
		sendbet:SetDisabled( true )
		sendbet:SetTextColor( Color(0, 0, 0, 255) )
		buttonColor = Color( 100, 100, 100, 255 )
	end
	sendbet.Paint = function( self, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, buttonColor ) -- Draw a blue button
	end
	
	-- Enable betting once a team has been selected
	-- Adjust color of the box depending on the chosen team
	teamselect.OnSelect = function( panel, index, value )
		sendbet:SetTextColor( Color(255, 255, 255, 255) )
		sendbet:SetDisabled( false )
		buttonColor = Color(44, 120, 178, 255)
		if allin then
			buttonColor = Color(255, 255, 0, 255)
			sendbet:SetTextColor( Color(0, 0, 0, 255) )
		end
		if value == KARMABET_LANG[language].derma_teaminno then
			panelColor = Color( 54, 71, 54, 255 )
		else
			panelColor = Color( 71, 54, 54, 255 )
		end
	end
	
	-- For some odd reason the slider can be brought to 0 or NaN
	-- Force to be within range
	slider.OnValueChanged = function()
		if allinCheck:GetChecked() then
			slider:SetMin( allinvalue )
			slider:SetMax( allinvalue )
			slider:SetValue( allinvalue )
		elseif not isnumber( slider:GetValue() ) or slider:GetValue() < slider:GetMin() then
			slider:SetValue( slider:GetMin() )
		end
		sendbet:SetText( KARMABET_LANG[language].derma_button .. " " .. math.floor(slider:GetValue()) .. " Karma" )
	end
	
	allinCheck.OnChange = function()
		if allinCheck:GetChecked() then
			allin = true
			slider:SetMin( allinvalue )
			slider:SetMax( allinvalue )
			slider:SetValue( allinvalue )
			if teamselect:GetValue() ~= KARMABET_LANG[language].derma_chooseteam then
				buttonColor = Color( 255, 255, 0, 255 )
				sendbet:SetTextColor( Color(0, 0, 0, 255) )
			end
		else
			allin = false
			slider:SetMin( minimum )
			slider:SetMax( maximum )
			slider:SetValue( slider:GetMin() )
			if teamselect:GetValue() ~= KARMABET_LANG[language].derma_chooseteam then
				buttonColor = Color(44, 120, 178, 255)
				sendbet:SetTextColor( Color(255, 255, 255, 255) )
			end
		end
	end

	sendbet:SetText( KARMABET_LANG[language].derma_button .. " " .. math.floor(slider:GetValue()) .. " Karma" )
	sendbet.DoClick = function()
		net.Start( "karmabet_betgui_response" )
		
		net.WriteInt( slider:GetValue(), 32 ) -- Amount?
		net.WriteString( string.sub( string.lower(teamselect:GetValue()), 1, 1) ) -- Team?
		net.WriteBool( allinCheck:GetChecked() ) -- Allin?
		
		net.SendToServer()
		
		bettingFrame:Remove()
	end
end

-- Upon receival of karmabet_betgui we open the GUI for placing a bet
net.Receive( "karmabet_betgui", function( net_response )
	showBetGUI( net.ReadInt( 32 ), net.ReadInt( 32 ), net.ReadInt( 32 ), net.ReadInt( 8 ), net.ReadString() )
end)

-- In case the GUI is still open after a round has ended or the time has run out, we force close it
net.Receive( "karmabet_closegui", function( net_response )
	if bettingFrame then bettingFrame:Remove() end
end)