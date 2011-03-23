------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
local function Logging(id,handler,encoded,decoded)
	 
	local LoggingMenu = vgui.Create( "DFrame" )
	LoggingMenu:SetSize( 534, 468 )
	LoggingMenu:Center( )
	LoggingMenu:SetTitle( "Environments Logs" ) 
	LoggingMenu:ShowCloseButton( true )
	LoggingMenu:SetVisible( true )
	LoggingMenu:SetDraggable( false )
	LoggingMenu:MakePopup( )
	
	local MenuTabs = vgui.Create("DPropertySheet")
	MenuTabs:SetParent(LoggingMenu)
	MenuTabs:SetPos(4, 30)
	MenuTabs:SetSize(526, 432)

	local EventList = vgui.Create("DPanelList")
	EventList:SetSize(475, 357)
	EventList:SetPos(5, 15)
	EventList:SetSpacing(5)
	EventList:EnableHorizontal(false)
	EventList:EnableVerticalScrollbar(true)

	/*ChatList = vgui.Create("DPanelList")
	ChatList:SetSize(475, 357)
	ChatList:SetPos(5, 15)
	ChatList:SetSpacing(5)
	ChatList:EnableHorizontal(false)
	ChatList:EnableVerticalScrollbar(true)*/

	local LoggingListView = vgui.Create("DListView")
	LoggingListView:SetParent(LoggingMenu)
	LoggingListView:SetPos(3, 50)
	LoggingListView:SetSize(534, 375)
	LoggingListView:SetMultiSelect(false)
	local timecol = LoggingListView:AddColumn("Time")
	LoggingListView:AddColumn("Entry")
	timecol:SetMaxWidth(130)

	for k,v in pairs(decoded[1]) do
		logrecs = string.Explode(";", v)
		LoggingListView:AddLine(  logrecs[1], logrecs[2] ) end 
		LoggingListView.OnRowSelected = function(self, row)
		local confirmation = DermaMenu()
		confirmation:AddOption("Copy to Clipboard", function() SetClipboardText(self:GetLine(row):GetValue(1).. " - "..(self:GetLine(row):GetValue(2))) end) 
		confirmation:Open()
	end
	EventList:AddItem(LoggingListView)

	--[[
	CHAT LOGGING
	--]]

	/*LoggingListView1 = vgui.Create("DListView")
	LoggingListView1:SetParent(LoggingMenu)
	LoggingListView1:SetPos(3, 50)
	LoggingListView1:SetSize(534, 375)
	LoggingListView1:SetMultiSelect(false)
	timecol = LoggingListView1:AddColumn("Time")
	LoggingListView1:AddColumn("Entry")
	timecol:SetMaxWidth(130)
	for k,v in pairs(decoded[2]) do
		logrecs1 = string.Explode(";", v)
		LoggingListView1:AddLine(  logrecs1[1], logrecs1[2] ) end 
		LoggingListView1.OnRowSelected = function(self, row)
			confirmation1 = DermaMenu()
			confirmation1:AddOption("Copy to Clipboard", function() SetClipboardText(self:GetLine(row):GetValue(1).. " - "..(self:GetLine(row):GetValue(2))) end) 
			confirmation1:Open()
		end
		ChatList:AddItem(LoggingListView1)

		if AbleToRemoveLogsAutomaticly then
			ClearChatButton = vgui.Create("DButton")
			ClearChatButton:SetPos(ChatList:GetWide()/2 - 42, 0 )
			ClearChatButton:SetSize( 84, 20 )
			ClearChatButton:SetText( "Clear Chat Log" )
			ClearChatButton.DoClick = function()
				RunConsoleCommand("ClearChatLog")
				LoggingMenu:Close()
				RunConsoleCommand("Logging")
			end
			ChatList:AddItem(ClearChatButton)
		else
			ClearChatButton = vgui.Create("DButton")
			ClearChatButton:SetPos(ChatList:GetWide()/2 - 42, 0 )
			ClearChatButton:SetSize( 84, 20 )
			ClearChatButton:SetText( "Clear Chat Log" )
			ClearChatButton:SetDisabled( true )
			ChatList:AddItem(ClearChatButton)
		end
	end*/

	MenuTabs:AddSheet("Event Log", EventList, "gui/silkicons/shield", false, false, nil)
	--MenuTabs:AddSheet("Error log", ChatList, "gui/silkicons/shield", false, false, nil)
end
datastream.Hook("sendEnvLogs",Logging)