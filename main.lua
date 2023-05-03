-- QuestLookup
-- Uses the QuestID from places like WowHead to see if you have completed it.

local QuestLookup, QuestData = ...

QuestLookup = LibStub("AceAddon-3.0"):NewAddon("QuestLookup", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local _QLDB = {}
local QID_Width = 45
local QName_Width = 300
local QRegion_Width = 125
local QFaction_Width = 35
local Label_Height = 200
local  mFrame = {}
local  mLabel = {}
local FIRE, EARTH, AIR, WATER, SIGIL = "|cFFFF0000Not Complete|r", "|cFFFF0000Not Complete|r", "|cFFFF0000Not Complete|r", "|cFFFF0000Not Complete|r", "|cFFFF0000Not Complete|r"

local questName, questId, description, QuestLookupMainFrame, dsc
local FrameIsOpen = false
local CnfgIsOpen = false
local AddonHasLoaded = false
local nuLabel = {}
local TTipFrame = {}
local HdrToolTip = {}

function QuestLookup:DragonFlightUpdate()
  --print("Running DragonFlightUpdate()")
  if C_QuestLog.IsQuestFlaggedCompleted(70723) then
    EARTH = "|cFF00FF00 Completed   |r"
  end
  if C_QuestLog.IsQuestFlaggedCompleted(70752) then
    WATER = "|cFF00FF00 Completed   |r"
  end
    if C_QuestLog.IsQuestFlaggedCompleted(70753) then
      AIR = "|cFF00FF00 Completed   |r"
  end
  if C_QuestLog.IsQuestFlaggedCompleted(70754) then
      FIRE = "|cFF00FF00 Completed   |r"
  end
  if C_QuestLog.IsQuestFlaggedCompleted(72686) then
    SIGIL = "|cFF00FF00 Completed   |r"
  end
  LibStub("AceConfig-3.0"):RegisterOptionsTable("QuestLookup", QuestLookup:GetOptions())
end

function QuestLookup:SetDBOption( info, input)
  _QLDB.profile.minimap.qlShowIcon = input
  QuestLookup:UpdateMinimap()
end

function QuestLookup:GetDBOption( info)
  return _QLDB.profile.minimap.qlShowIcon            
end

local function DisplayConfig(widget, event, text)
  QuestLookup:DragonFlightUpdate()
  LibStub("AceConfigDialog-3.0"):Open("QuestLookup")
  CnfgIsOpen = true
end

function QuestLookup:GetOptions()
  local options = {
    name = "QuestLookup",
    handler = QuestLookup,
    type = 'group',
    args = {
      intro = {
        order = 1,
        type = "description",
        name = "\nQuestLookup will determine if you have completed a quest.\n"
        .. "Enter some part of the quest name and the results will be displayed in the chat window.\n\n",
      },
      cl = {
        order = 2,
        type = "execute",
        name = "Begin Lookup",
        desc = "Find out what quests you have or have not completed by Id or name.",
        func = "DisplayFrame",
      },
      c2 = {
        order = 6,
        type = "execute",
        name = "Update",
        desc = "Update the Dragonflight Primalist quest status.",
        func = "DragonFlightUpdate",
      },
      mm = {    
        order = 3,
        type = "toggle",
        name = "Show Minimap Icon",
        desc = "Show the minimap icon.",
        get = 'GetDBOption',
        set = 'SetDBOption',
      },
      vsn = {    
        order = 4,
        type = "description",
        name = "\n                         Version: " .. QuestData.Version                                                                                           ,
        fontSize = "medium",
      },
      p1 = {    
        order = 5,
        type = "description",
        name = "\n    Earth: " .. EARTH .. "    Water: " .. WATER ..
               "\n    Fire:  " .. FIRE .. "      Air:     " .. AIR ..
               "\n                           Sigil: " .. SIGIL, 
        fontSize = "medium",
      },
    },
  }
  return options
end

local function ClearAll(dItems, str, val)
  if dItems ==  nil then
    -- print("dItems is nil")
  else      
    dItems:ReleaseChildren()
  end
  if val == 0 then
    --questName:SetText("")
    questId:SetText("")
    QuestLookupMainFrame:SetStatusText("All items have been cleared.")
  elseif val == 1 then
    questName:SetText("")
    questId:SetText("")
    QuestLookupMainFrame:SetStatusText("All items have been cleared.")
  elseif val ==2 then
    questName:SetText("")
    --questId:SetText("")
    QuestLookupMainFrame:SetStatusText("")
  elseif val == 3 then
    --questName:SetText("")
    questId:SetText("")
    QuestLookupMainFrame:SetStatusText("")
  end     
  description:SetText("")
  dsc:SetText("")
end   

local function SetDesc(k, name, v3)
  local cnt = math.ceil(string.len(v3) / 65)
  local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(k)
  dsc:SetNumLines(cnt)
  dsc:SetText(v3)
  if isCompleted then
    QuestLookupMainFrame:SetStatusText("|cFF00FF00 You have completed quest " .. k .. ":  " .. name .. "|r")
  else
    QuestLookupMainFrame:SetStatusText("You have not done quest " ..  k .. ":  " .. name)
  end
end

local function newLabel(h, w, k, txt, name, desc, pos)
  local nuLabel = AceGUI:Create("InteractiveLabel")
  local ntxt = txt

  if pos == 3 then
    if string.len(txt) > 20 then
      local nstr = string.sub(txt, 1, 19) .. ".."
      ntxt = nstr
      txt = ntxt
    end
  elseif pos == 4 then
    if string.len(txt) > 52 then
      local nstr = string.sub(txt, 1, 49) .. ".."
      ntxt = nstr
      txt = ntxt
    end
  end

  nuLabel:SetHeight(h)
  nuLabel:SetWidth(w)
  local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(k)

  if isCompleted then 
    ntxt = "|cFF00FF00" .. txt .. "|r"
    QuestLookupMainFrame:SetStatusText("|cFF00FF00 You have completed quest " .. k .. ":  " .. name .. "|r")
  else
    QuestLookupMainFrame:SetStatusText("You have not done quest " ..  k .. ":  " .. name)
  end

  nuLabel:SetText(ntxt)
  nuLabel:SetCallback("OnEnter", function(self, event, ...) 
      questName:SetText(name) 
      questId:SetText(k) 
      SetDesc(k, name, desc)
    end )
  return nuLabel
end

local function createLabels(container,k, v1, v2, v3, v4)
  nuLabel["labelId" .. k] = newLabel(Label_Height, QID_Width, k, k, v1, v4, 1)   -- ID
  nuLabel["labelFaction" .. k] = newLabel(Label_Height, QFaction_Width, k, v3, v1, v4, 2)   -- Faction
  nuLabel["labelRegion" .. k] = newLabel(Label_Height, QRegion_Width, k, v2, v1, v4, 3)   -- Region
  nuLabel["labelName" .. k] = newLabel(Label_Height, QName_Width, k,v1, v1, v4, 4)  --Quest Name

  container:AddChild(nuLabel["labelId" .. k])
  container:AddChild(nuLabel["labelFaction" .. k])
  container:AddChild(nuLabel["labelRegion" .. k])
  container:AddChild(nuLabel["labelName" .. k])
end

local function readTableForKey (container, entry)
  ClearAll(container,"",2)
  QuestLookupMainFrame:SetStatusText("No Quests Found.")

  if QuestData.quest_table1 then
    for k,v in pairs(QuestData.quest_table1) do  
      if k == entry then
        createLabels(container, k, v[1],v[2],v[3],v[4])
        return nil
      end
    end
  end

  if QuestData.quest_table2 then
    for k,v in pairs(QuestData.quest_table2) do  
      if k == entry then
        createLabels(container, k, v[1],v[2],v[3],v[4])
        return nil
      end
    end
  end

  if QuestData.quest_table3 then
    for k,v in pairs(QuestData.quest_table3) do  
      if k == entry then
        createLabels(container, k, v[1],v[2],v[3],v[4])
        return nil
      end
    end
  end

  if QuestData.quest_table4 then
    for k,v in pairs(QuestData.quest_table4) do  
      if k == entry then
        createLabels(container, k, v[1],v[2],v[3],v[4])
        return nil
      end
    end
  end

  if QuestData.quest_table5 then
    for k,v in pairs(QuestData.quest_table5) do  
      if k == entry then
        createLabels(container, k, v[1],v[2],v[3],v[4])
        return nil
      end
    end
  end

  if QuestData.quest_table6 then
    for k,v in pairs(QuestData.quest_table6) do  
      if k == entry then
        createLabels(container, k, v[1],v[2],v[3],v[4])
        return nil
      end
    end
  end

  if QuestData.quest_table7 then
    for k,v in pairs(QuestData.quest_table7) do  
      if k == entry then
        createLabels(container, k, v[1],v[2],v[3],v[4])
        return nil
      end
    end
  end

  if QuestData.quest_table8 then
    for k,v in pairs(QuestData.quest_table8) do  
      if k == entry then
        createLabels(container, k, v[1],v[2],v[3],v[4])
        return nil
      end
    end
  end
end

local function readTableForName (container, entry)
  ClearAll(container,"",3)
  QuestLookupMainFrame:SetStatusText("No Quests Found.")
  local cntr = 0

  if QuestData.quest_table1 then
    for k,v in pairs(QuestData.quest_table1) do  
      if cntr > 100 then
        ClearAll(container,"",0)
        QuestLookupMainFrame:SetStatusText("Too many quests found.  Change search criteria.") 
        return nil
      end

      if string.find(string.lower(v[1]),string.lower(entry)) then
        createLabels(container, k, v[1], v[2], v[3], v[4])
        cntr = cntr + 1
      end
    end
  end

  if QuestData.quest_table2 then
    for k,v in pairs(QuestData.quest_table2) do  
      if cntr > 100 then
        ClearAll(container,"",0)
        QuestLookupMainFrame:SetStatusText("Too many quests found.  Change search criteria.") 
        return nil
      end
      if string.find(string.lower(v[1]),string.lower(entry)) then
        createLabels(container, k,v[1],v[2],v[3],v[4])
        cntr = cntr + 1
      end
    end
  end

  if QuestData.quest_table3 then
    for k,v in pairs(QuestData.quest_table3) do  
      if cntr > 100 then
        ClearAll(container,"",0)
        QuestLookupMainFrame:SetStatusText("Too many quests found.  Change search criteria.") 
        return nil
      end
      if string.find(string.lower(v[1]),string.lower(entry)) then
        createLabels(container, k,v[1],v[2],v[3],v[4])
        cntr = cntr + 1
      end
    end
  end

  if QuestData.quest_table4 then
    for k,v in pairs(QuestData.quest_table4) do  
      if cntr > 100 then
        ClearAll(container,"",0)
        QuestLookupMainFrame:SetStatusText("Too many quests found.  Change search criteria.") 
        return nil
      end
      if string.find(string.lower(v[1]),string.lower(entry)) then
        createLabels(container, k,v[1],v[2],v[3],v[4])
        cntr = cntr + 1
      end
    end
  end

  if QuestData.quest_table5 then
    for k,v in pairs(QuestData.quest_table5) do  
      if cntr > 100 then
        ClearAll(container,"",0)
        QuestLookupMainFrame:SetStatusText("Too many quests found.  Change search criteria.") 
        return nil
      end
      if string.find(string.lower(v[1]),string.lower(entry)) then
        createLabels(container, k,v[1],v[2],v[3],v[4])
        cntr = cntr + 1
      end
    end
  end

  if QuestData.quest_table6 then
    for k,v in pairs(QuestData.quest_table6) do  
      if cntr > 100 then
        ClearAll(container,"",0)
        QuestLookupMainFrame:SetStatusText("Too many quests found.  Change search criteria.") 
        return nil
      end
      if string.find(string.lower(v[1]),string.lower(entry)) then
        createLabels(container, k,v[1],v[2],v[3],v[4])
        cntr = cntr + 1
      end
    end
  end

  if QuestData.quest_table7 then
    for k,v in pairs(QuestData.quest_table7) do  
      if cntr > 100 then
        ClearAll(container,"",0)
        QuestLookupMainFrame:SetStatusText("Too many quests found.  Change search criteria.")        
        return nil
      end
      if string.find(string.lower(v[1]),string.lower(entry)) then
        createLabels(container, k,v[1],v[2],v[3],v[4])
        cntr = cntr + 1
      end
    end
  end

  if QuestData.quest_table8 then
    for k,v in pairs(QuestData.quest_table8) do  
      if cntr > 100 then
        ClearAll(container,"",0)
        QuestLookupMainFrame:SetStatusText("Too many quests found.  Change search criteria.")        
        return nil
      end
      if string.find(string.lower(v[1]),string.lower(entry)) then
        createLabels(container, k,v[1],v[2],v[3],v[4])
        cntr = cntr + 1
      end
    end
  end
end

function ShowMyToolTip(txt)
  TTipFrame:SetFrameStrata("TOOLTIP")
  TTipFrame:SetWidth(300) 
  TTipFrame:SetHeight(64) 

  --local t = f:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  HdrToolTip:SetText("")
  HdrToolTip:SetJustifyH("CENTER")
  HdrToolTip:SetJustifyV("CENTER")
  if txt == "faction" then
    HdrToolTip:SetText("Horde, Alliance, or Both")
  elseif txt == "id" then
    HdrToolTip:SetText("Quest ID")
  elseif txt == "region" then
    HdrToolTip:SetText("Quest Region")
  else
    HdrToolTip:SetText("Quest Name")
  end

  HdrToolTip:SetAllPoints(f)
  TTipFrame.texture = HdrToolTip

  local scale,x,y=f:GetEffectiveScale(),GetCursorPosition();
  TTipFrame:SetPoint("CENTER",nil,"BOTTOMLEFT",(x+50)/scale,(y+20)/scale);

  HdrToolTip:Show()
  TTipFrame:Show()
end

-- No longer using this function.  It stopped working and it wasn't necessary.
function HideMyToolTip()
  HdrToolTip:SetText("")
  HdrToolTip:Hide()
  TTipFrame:Hide()
end

function ShowFrame()
  --QuestLookup:DragonFlightUpdate()
  FrameIsOpen = true;
  
  if QuestLookupMainFrame == nil then

  QuestLookupMainFrame = AceGUI:Create("Frame")
  QuestLookupMainFrame:SetWidth(560)
  QuestLookupMainFrame:SetHeight(480)
  QuestLookupMainFrame:SetTitle("QuestLookup")
  QuestLookupMainFrame:SetStatusText("")
  QuestLookupMainFrame:SetCallback("OnClose", function(widget) 
                                                FrameIsOpen = false; 
                                                --IDLabel:Hide(); 
                                                --QNameLabel:Hide(); 
                                                --QRegionLabel:Hide();
                                                --QFactionLabel:Hide(); 
                                                --AceGUI:Release(widget); 
                                                end)
  QuestLookupMainFrame:SetLayout("List")

  TTipFrame = CreateFrame("Frame",nil, UIParent)
  HdrToolTip = TTipFrame:CreateFontString(nil, "ARTWORK", "GameTooltipText")

  local InputGroup = AceGUI:Create("SimpleGroup")
  InputGroup:SetFullWidth(true)
  InputGroup:SetLayout("Flow")

  local QuestLookupDataItems = AceGUI:Create("SimpleGroup")
  QuestLookupDataItems:SetFullWidth(true)
  QuestLookupDataItems:SetLayout("Fill")   

  local QuestLookupDataScroll = AceGUI:Create("ScrollFrame")
  QuestLookupDataScroll:SetLayout("Flow") -- probably?

  local IDLabel = AceGUI:Create("InteractiveLabel")
  IDLabel:SetHeight(Label_Height)
  IDLabel:SetWidth(QID_Width)
  IDLabel:SetText("ID")
  --IDLabel:SetCallback("OnEnter", function(widget) ShowMyToolTip("id") end)
  --IDLabel:SetCallback("OnLeave", function(widget) HdrToolTip:Hide(); end)

  local QNameLabel = AceGUI:Create("InteractiveLabel")
  QNameLabel:SetHeight(Label_Height)
  QNameLabel:SetWidth(QName_Width)
  QNameLabel:SetText("Quest Name")
  --QNameLabel:SetCallback("OnEnter", function(widget) ShowMyToolTip("name") end)
  --QNameLabel:SetCallback("OnLeave", function(widget) HdrToolTip:Hide(); end)

  local QRegionLabel = AceGUI:Create("InteractiveLabel")
  QRegionLabel:SetHeight(Label_Height)
  QRegionLabel:SetWidth(QRegion_Width)
  QRegionLabel:SetText("Region")
  --QRegionLabel:SetCallback("OnEnter", function(widget) ShowMyToolTip("region") end)
  --QRegionLabel:SetCallback("OnLeave", function(widget) HdrToolTip:Hide(); end)

  local QFactionLabel = AceGUI:Create("InteractiveLabel")
  QFactionLabel:SetHeight(Label_Height)
  QFactionLabel:SetWidth(QFaction_Width)
  QFactionLabel:SetText("F")
  --QFactionLabel:SetCallback("OnEnter", function(widget) ShowMyToolTip("faction") end)
  --QFactionLabel:SetCallback("OnLeave", function(widget) HdrToolTip:Hide(); end)

  questId = AceGUI:Create("EditBox")
  questId:SetLabel("Quest Id")
  questId:SetWidth(100)
  questId:SetHeight(100)
  questId:SetCallback("OnEnterPressed", function(widget, event, text) readTableForKey(QuestLookupDataScroll, tonumber(text)) end)  

  InputGroup:AddChild(questId)

  questName = AceGUI:Create("EditBox")
  questName:SetLabel("Quest Name")
  questName:SetWidth(400)
  questName:SetHeight(100)
  questName:SetCallback("OnEnterPressed", function(widget, event, text) readTableForName(QuestLookupDataScroll, text) end)  

  InputGroup:AddChild(questName)

  description = AceGUI:Create("MultiLineEditBox")
  description:SetLabel("Description")
  description:SetWidth(300)
  description:SetHeight(100)
  description:DisableButton("TRUE")

  local buttonGroup = AceGUI:Create("SimpleGroup")
  buttonGroup:SetFullWidth(true)
  buttonGroup:SetLayout("Flow")

  local clrButton = AceGUI:Create("Button")
  clrButton:SetText("Clear")
  clrButton:SetWidth(90)
  clrButton:SetHeight(30)
  clrButton:SetCallback("OnClick", function(widget, event, text) ClearAll(QuestLookupDataScroll, "", 1) end )  --QuestLookupDataItems, "", 1) end )

  local cfgButton = AceGUI:Create("Button")
  cfgButton:SetText("Config")
  cfgButton:SetWidth(90)
  cfgButton:SetHeight(30)
  cfgButton:SetCallback("OnClick", function(widget, event, text) DisplayConfig(widget, event, text) end)

  buttonGroup:AddChild(clrButton)
  buttonGroup:AddChild(cfgButton)

  InputGroup:AddChild(IDLabel)
  InputGroup:AddChild(QFactionLabel)
  InputGroup:AddChild(QRegionLabel)
  InputGroup:AddChild(QNameLabel)

  QuestLookupMainFrame:AddChild(buttonGroup)
  QuestLookupMainFrame:AddChild(InputGroup)

  dsc = AceGUI:Create("MultiLineEditBox")
  dsc:SetLabel("Quest Description")
  dsc:SetWidth(500)
  dsc:SetHeight(100)
  dsc:DisableButton("TRUE")    

  QuestLookupDataItems:AddChild(QuestLookupDataScroll)

  QuestLookupMainFrame:AddChild(QuestLookupDataItems)

  QuestLookupMainFrame:AddChild(dsc)
  
  else
  
    QuestLookupMainFrame:Show()
  
  end
end

function QuestLookup:GetMessage(info)
  return self.message
end

function QuestLookup:SetMessage(info, newValue)
  self.message = newValue
end

function QuestLookup:DisplayFrame(info, newValue)
  --QuestLookup:DragonFlightUpdate()
  LibStub("AceConfigDialog-3.0"):Close("QuestLookup")

  if FrameIsOpen == false then
    ShowFrame()
  end
end

function QuestLookup:ChatCommand(input)
  LibStub("AceConfigDialog-3.0"):Open("QuestLookup") 
  CnfgIsOpen = true
end

local MyDataBroker = LibStub("LibDataBroker-1.1"):NewDataObject("QuestLookup!", {
    type = "launcher",
    text = "QuestLookup!",
    icon = "Interface\\Addons\\QuestLookup\\Icons\\Toby",
    OnClick = function( f, button )
      LibStub("AceConfigDialog-3.0"):Open("QuestLookup") 
      CnfgIsOpen = true
      GameTooltip:Hide()
    end,
    OnTooltipShow = function( mt )
      mt:AddDoubleLine( "QuestLookup", Minimap.text )
      mt:AddLine( "|cFFFFFFFFClick to open the the QuestLookup interface.|r" )
    end
  })

local defaults = {
  profile = {
    minimap = { 
      qlShowIcon = false,
    }
  }
}

function QuestLookup:OnInitialize()
  _QLDB = LibStub("AceDB-3.0"):New("QuestLookupDB", defaults)
  LibStub("AceConfig-3.0"):RegisterOptionsTable("QuestLookup", QuestLookup:GetOptions())
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("QuestLookup", "QuestLookup")
  LibStub("AceConfigDialog-3.0"):SetDefaultSize("QuestLookup", 400, 268)
  self:RegisterChatCommand("ql", "ChatCommand")
  LibStub("LibDBIcon-1.0"):Register("QuestLookup!", MyDataBroker, _QLDB.profile);
  CnfgIsOpen = true;

  QuestLookup:DragonFlightUpdate()
end 

function QuestLookup:UpdateMinimap()
  if _QLDB.profile.minimap.qlShowIcon == false then
    LibStub("LibDBIcon-1.0"):Hide( "QuestLookup!")
  else
    LibStub("LibDBIcon-1.0"):Show( "QuestLookup!")
  end
end

function QuestLookup:ADDON_LOADED()
  AddonHasLoaded = true
  QuestLookup:UpdateMinimap()
end

function QuestLookup:OnEnable()
  self:RegisterEvent("ADDON_LOADED")
  print("QuestLookup enabled.")
end

function QuestLookup:OnDisable()
end