-- Paporotnic Hub v8.0 | Disassemble Car Tycoon
-- Container ESP / TP, Movement, Auction timing (BETA), Settings.
-- No server XP modification. The auction detector uses client GUI geometry.
-- This script runs locally; server validation may undo character movement.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local env = (type(getgenv) == "function" and getgenv()) or _G

if type(env.__PaporotnikHub_Stop) == "function" then pcall(env.__PaporotnikHub_Stop) end
if type(env.__PaporotnicHub_Stop) == "function" then pcall(env.__PaporotnicHub_Stop) end
if type(env.__AuctionESP_Stop) == "function" then pcall(env.__AuctionESP_Stop) end

local oldPrefs = env.__PaporotnicHubV7_Prefs or env.__PaporotnicHubV6_Prefs or env.__PaporotnicHubV5_Prefs or env.__PaporotnikHubV4_Prefs or env.__PaporotnikHub_Prefs or {}
local prefs = env.__PaporotnicHubV8_Prefs or {
    lang = oldPrefs.lang or "ru", theme = oldPrefs.theme or "dark",
    menuKey = oldPrefs.menuKey or oldPrefs.hotkey or "F6", flyKey = oldPrefs.flyKey or "X",
    noclipKey = oldPrefs.noclipKey or "N", auctionMode="off",
    esp = oldPrefs.esp ~= false, labels = oldPrefs.labels ~= false,
    speed = oldPrefs.speed or 16, flySpeed = oldPrefs.flySpeed or 65, noclip = false, autoAuction = false,
}
env.__PaporotnicHubV8_Prefs = prefs
prefs.noclipKey=prefs.noclipKey or "N"
prefs.speed=math.clamp(tonumber(prefs.speed) or 16,16,250)
prefs.flySpeed=math.clamp(tonumber(prefs.flySpeed) or 65,10,1000)
prefs.auctionMode = ({off=true,yellow=true,green=true,win=true})[prefs.auctionMode] and prefs.auctionMode or "off"
prefs.autoAuction=nil -- deprecated v5 boolean
if prefs.lang ~= "ru" and prefs.lang ~= "en" then prefs.lang = "ru" end
if not ({dark=true,light=true,neon=true})[prefs.theme] then prefs.theme = "dark" end

local folderRoot = Workspace:FindFirstChild("StorageAuction") or Workspace:WaitForChild("StorageAuction", 8)
local containerFolder = folderRoot and (folderRoot:FindFirstChild("Containers") or folderRoot:WaitForChild("Containers", 8))

local rarities = {
    Bronze={ru="БРОНЗОВЫЙ", en="BRONZE",rank=1,color=Color3.fromRGB(205,130,66)},
    Silver={ru="СЕРЕБРЯНЫЙ",en="SILVER",rank=2,color=Color3.fromRGB(207,219,234)},
    Gold={ru="ЗОЛОТОЙ",en="GOLD",rank=3,color=Color3.fromRGB(255,204,55)},
    Diamond={ru="АЛМАЗНЫЙ",en="DIAMOND",rank=4,color=Color3.fromRGB(82,226,255)},
    Prismatic={ru="ПРИЗМАТИЧЕСКИЙ",en="PRISMATIC",rank=5,color=Color3.fromRGB(216,104,255)},
}
local themes = {
    dark={bg=Color3.fromRGB(18,23,33),panel=Color3.fromRGB(36,44,60),row=Color3.fromRGB(29,36,49),text=Color3.fromRGB(236,245,255),muted=Color3.fromRGB(158,179,202),accent=Color3.fromRGB(94,231,186),border=Color3.fromRGB(71,86,109)},
    light={bg=Color3.fromRGB(235,242,250),panel=Color3.fromRGB(214,226,239),row=Color3.fromRGB(248,250,255),text=Color3.fromRGB(27,42,61),muted=Color3.fromRGB(79,102,128),accent=Color3.fromRGB(12,132,110),border=Color3.fromRGB(156,181,206)},
    neon={bg=Color3.fromRGB(16,13,31),panel=Color3.fromRGB(36,23,63),row=Color3.fromRGB(27,22,51),text=Color3.fromRGB(250,235,255),muted=Color3.fromRGB(194,163,220),accent=Color3.fromRGB(222,114,255),border=Color3.fromRGB(125,69,165)},
}
local T={
    ru={containers="Контейнеры",movement="Движение",auction="Аукцион",settings="НАСТРОЙКИ",
        esp="ESP",labels="ПОДПИСИ",found="Контейнеров: %d (в зоне: %d, кэш: %d)",none="Контейнеры не найдены",clear="УБРАТЬ МАЯК",
        track="МАЯК",tp="ТП",distance="студ.",noChar="Персонаж не готов",gone="Контейнер исчез",
        speed="СКОРОСТЬ ХОДЬБЫ",fly="ПОЛЁТ",flySpeed="СКОРОСТЬ ПОЛЁТА",noclip="NOCLIP",
        flyKey="БИНД ПОЛЁТА",noclipKey="БИНД NOCLIP",saveHome="ЗАПОМНИТЬ БАЗУ",tpHome="ТП НА БАЗУ",
        homeMissing="Точка базы неизвестна. Сохрани её на базе или сделай Reset.",homeSaved="Точка базы сохранена",
        homeAuto="База запомнена после возрождения",tpDone="Телепорт выполнен",
        auctionYellow="AUTO YELLOW",auctionGreen="AUTO GREEN",auctionWin="AUTO WIN",auctionModeOff="Аукцион: выключен",
        auctionLeading="Ты уже лидируешь — не ставлю",auctionOverBudget="Недостаточно денег для следующей ставки",
        auctionGreenMissing="Зелёная зона не найдена",auctionTracking="Слежу за полосой",scan="СКАНИРОВАТЬ GUI",auctionIdle="Ожидаю мини-игру",
        auctionFound="Шкала найдена: слежу за стрелкой",auctionNoBar="Мини-игра видна, но зона/стрелка не найдены",
        auctionFired="Отправлено нажатие Space",auctionNoInput="Нет доступной отправки Space",
        auctionTip="WIN: не ставит, если ты уже лидируешь. В остальных случаях выбирает минимальную доступную надбавку. Данные ставок могут быть недоступны в GUI.",
        language="ЯЗЫК",theme="ТЕМА",menuKey="БИНД МЕНЮ",press="НАЖМИ КЛАВИШУ...",
        dark="ТЁМНАЯ",light="СВЕТЛАЯ",neon="НЕОН",on="ВКЛ",off="ВЫКЛ",
        guide="Настройки сеанса сохраняются при повторном запуске скрипта",
        unload="ВЫГРУЗИТЬ HUB",unloadConfirm="ПОДТВЕРДИТЬ ВЫГРУЗКУ",
        notif="Скрипт не меняет серверный опыт",notFound="Нет папки StorageAuction/Containers",
        copy="Результат диагностики скопирован в буфер обмена",copyFail="Диагностика выведена в консоль",
        restricted="КЭШ пропадает при подтверждённом удалении, рядом с пустым местом или через 15 мин",
        purge="ОЧИСТИТЬ КЭШ",minimap="МИНИКАРТА",mapNotFound="Метки миникарты не найдены",mapCopied="Данные миникарты скопированы",
        lastSeen="КЭШ",cached="ПОСЛ.",cacheTp="ТП К МЕСТУ"},
    en={containers="Containers",movement="Movement",auction="Auction",settings="SETTINGS",
        esp="ESP",labels="LABELS",found="Containers: %d (live: %d, cached: %d)",none="No containers found",clear="CLEAR TRACKING",
        track="TRACK",tp="TP",distance="studs",noChar="Character not ready",gone="Container disappeared",
        speed="WALK SPEED",fly="FLY",flySpeed="FLY SPEED",noclip="NOCLIP",
        flyKey="FLY HOTKEY",noclipKey="NOCLIP HOTKEY",saveHome="SAVE HOME",tpHome="TP HOME",
        homeMissing="Home unknown. Save it at base or respawn first.",homeSaved="Home position saved",
        homeAuto="Home learned after respawn",tpDone="Teleport complete",
        auctionYellow="AUTO YELLOW",auctionGreen="AUTO GREEN",auctionWin="AUTO WIN",auctionModeOff="Auction automation off",
        auctionLeading="Already leading — holding bid",auctionOverBudget="Not enough funds for next bid",
        auctionGreenMissing="Green zone not found",auctionTracking="Tracking timing bar",scan="SCAN GUI",auctionIdle="Waiting for auction minigame",
        auctionFound="Bar found: tracking pointer",auctionNoBar="Minigame visible, but bar/pointer not found",
        auctionFired="Space triggered",auctionNoInput="No supported Space input method",
        auctionTip="WIN: holds when already leading; otherwise chooses lowest available raise. Bid values may be unavailable to client UI.",
        language="LANGUAGE",theme="THEME",menuKey="MENU HOTKEY",press="PRESS A KEY...",
        dark="DARK",light="LIGHT",neon="NEON",on="ON",off="OFF",
        guide="Session settings are retained when rerunning the script",
        unload="UNLOAD HUB",unloadConfirm="CONFIRM UNLOAD",
        notif="This script does not change server XP",notFound="StorageAuction/Containers folder not found",
        copy="Diagnostic report copied to clipboard",copyFail="Diagnostic report printed to console",
        restricted="CACHE clears on verified removal, nearby absence, or after 15 minutes",
        purge="CLEAR CACHE",minimap="MINIMAP",mapNotFound="No minimap markers found",mapCopied="Minimap diagnostics copied",
        lastSeen="CACHE",cached="LAST",cacheTp="TP TO SPOT"}
}
local function L(k) return T[prefs.lang][k] or k end
local function P() return themes[prefs.theme] end
local function new(class, props, parent)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    o.Parent=parent
    return o
end
local function round(obj,amount) new("UICorner",{CornerRadius=UDim.new(0,amount or 8)},obj) end
local function label(parent,txt,pos,size,fontSize,bold)
    return new("TextLabel",{Position=pos,Size=size,BackgroundTransparency=1,Text=txt,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize=fontSize or 13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=P().text},parent)
end
local function btn(parent,txt,pos,size)
    local b=new("TextButton",{Position=pos,Size=size,BackgroundColor3=P().panel,TextColor3=P().text,
        BorderSizePixel=0,Text=txt,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=true},parent)
    round(b,7)
    return b
end
local connections, records, originalCollisions = {},{},{}
-- A stream-out produces DescendantRemoving, but ordinarily not Destroying.
-- Keep old locations temporarily; forget on confirmed destruction, on a sustained
-- close-range absence, or after a conservative TTL. This cannot confirm a sold
-- container that was already out of the client's streaming area.
local CACHE_VERIFY_RADIUS = 115
local CACHE_VERIFY_SECONDS = 8
local CACHE_TTL_SECONDS = 900
local knownLocations = {}
local knownRoot = Instance.new("Folder")
knownRoot.Name = "PaporotnicHub_LastSeen"
knownRoot.Parent = Workspace
local running,selected,flyOn=false,nil,false
local bindingFor, currentPage, inSettings=nil,"containers",false
local collapsed=false  -- Minimize keeps a draggable header; X only hides the window.
local unloadArmed=false
local homeCF=nil
local notice,noticeUntil=nil,0
local function listen(signal,cb)
    local c=signal:Connect(cb); table.insert(connections,c); return c
end
local function tell(s)
    notice=tostring(s); noticeUntil=os.clock()+3.2
end
local ui=new("ScreenGui",{Name="PaporotnicHub_v8",ResetOnSpawn=false,IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=900},playerGui)
local root=new("Frame",{Position=UDim2.new(0.035,0,0.14,0),Size=UDim2.fromOffset(500,560),BackgroundColor3=P().bg,
    BorderSizePixel=0,Active=true,ClipsDescendants=true},ui)
round(root,12)
local outline=new("UIStroke",{Color=P().border,Thickness=1},root)
local top=new("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=P().panel,BorderSizePixel=0,Active=true},root)
round(top,12)
local head=label(top,"PAPOROTNIC HUB  |  v8.0",UDim2.fromOffset(14,5),UDim2.new(1,-140,0,39),17,true)
local settingBtn=btn(top,"⚙",UDim2.new(1,-121,0,9),UDim2.fromOffset(34,34))
settingBtn.TextSize=22
local minBtn=btn(top,"—",UDim2.new(1,-82,0,9),UDim2.fromOffset(34,34))
minBtn.TextSize=19
local closeBtn=btn(top,"×",UDim2.new(1,-43,0,9),UDim2.fromOffset(34,34))
closeBtn.TextSize=20
local tabs=new("Frame",{Position=UDim2.fromOffset(11,63),Size=UDim2.fromOffset(478,40),BackgroundTransparency=1},root)
local tabB={}
for i,v in ipairs({"containers","movement","auction"}) do
    tabB[v]=btn(tabs,v,UDim2.fromOffset((i-1)*160,0),UDim2.fromOffset(152,36))
end
local status=label(root,"",UDim2.fromOffset(13,109),UDim2.fromOffset(471,23),12,false)

local pages={}
for _,name in ipairs({"containers","movement","auction"}) do
    pages[name]=new("Frame",{Position=UDim2.fromOffset(10,141),Size=UDim2.fromOffset(480,410),
        BackgroundTransparency=1,Visible=name=="containers"},root)
end
local conPage, movPage, aucPage=pages.containers,pages.movement,pages.auction

local espBtn=btn(conPage,"",UDim2.fromOffset(3,3),UDim2.fromOffset(230,35))
local tagsBtn=btn(conPage,"",UDim2.fromOffset(244,3),UDim2.fromOffset(230,35))
local conHeader=label(conPage,"",UDim2.fromOffset(5,47),UDim2.fromOffset(465,20),12,true)
local conList=new("ScrollingFrame",{Position=UDim2.fromOffset(3,72),Size=UDim2.fromOffset(474,277),BackgroundColor3=P().panel,
    BorderSizePixel=0,ScrollBarThickness=5,ScrollingDirection=Enum.ScrollingDirection.Y,CanvasSize=UDim2.fromOffset(0,0)},conPage)
round(conList,8)
new("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},conList)
local emptyLabel=label(conList,L("none"),UDim2.fromOffset(7,2),UDim2.fromOffset(440,30),12)
emptyLabel.Size=UDim2.new(1,-12,0,30)
emptyLabel.LayoutOrder=-1
local clearBtn=btn(conPage,"",UDim2.fromOffset(3,355),UDim2.fromOffset(150,29))
local purgeBtn=btn(conPage,"",UDim2.fromOffset(163,355),UDim2.fromOffset(150,29))
local mapScanBtn=btn(conPage,"",UDim2.fromOffset(323,355),UDim2.fromOffset(151,29))
local conFoot=label(conPage,"",UDim2.fromOffset(5,388),UDim2.fromOffset(470,17),10)

local walkLabel=label(movPage,"",UDim2.fromOffset(12,15),UDim2.fromOffset(298,25),14,true)
local walkMinus=btn(movPage,"−",UDim2.fromOffset(320,10),UDim2.fromOffset(44,34))
local walkValue=new("TextBox",{Position=UDim2.fromOffset(370,10),Size=UDim2.fromOffset(58,34),
    BackgroundColor3=P().row,BorderSizePixel=0,Text="",ClearTextOnFocus=false,
    TextColor3=P().text,TextSize=15,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Center},movPage)
round(walkValue,7)
local walkPlus=btn(movPage,"+",UDim2.fromOffset(428,10),UDim2.fromOffset(44,34))
local flyBtn=btn(movPage,"",UDim2.fromOffset(12,60),UDim2.fromOffset(210,38))
local noclipBtn=btn(movPage,"",UDim2.fromOffset(241,60),UDim2.fromOffset(232,38))
local flySpeedLabel=label(movPage,"",UDim2.fromOffset(12,118),UDim2.fromOffset(298,26),14,true)
local flyMinus=btn(movPage,"−",UDim2.fromOffset(320,114),UDim2.fromOffset(44,34))
local flyValue=new("TextBox",{Position=UDim2.fromOffset(370,114),Size=UDim2.fromOffset(58,34),
    BackgroundColor3=P().row,BorderSizePixel=0,Text="",ClearTextOnFocus=false,
    TextColor3=P().text,TextSize=15,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Center},movPage)
round(flyValue,7)
local flyPlus=btn(movPage,"+",UDim2.fromOffset(428,114),UDim2.fromOffset(44,34))
local flyBindBtn=btn(movPage,"",UDim2.fromOffset(12,163),UDim2.fromOffset(461,36))
local noclipBindBtn=btn(movPage,"",UDim2.fromOffset(12,205),UDim2.fromOffset(461,34))
local saveHomeBtn=btn(movPage,"",UDim2.fromOffset(12,264),UDim2.fromOffset(218,42))
local tpHomeBtn=btn(movPage,"",UDim2.fromOffset(242,264),UDim2.fromOffset(231,42))
local homeText=label(movPage,"",UDim2.fromOffset(15,321),UDim2.fromOffset(454,53),12)
homeText.TextWrapped=true

local yellowAucBtn=btn(aucPage,"",UDim2.fromOffset(10,12),UDim2.fromOffset(149,42))
local greenAucBtn=btn(aucPage,"",UDim2.fromOffset(165,12),UDim2.fromOffset(149,42))
local winAucBtn=btn(aucPage,"",UDim2.fromOffset(320,12),UDim2.fromOffset(149,42))
local scanBtn=btn(aucPage,"",UDim2.fromOffset(10,65),UDim2.fromOffset(460,37))
local aucState=label(aucPage,"",UDim2.fromOffset(12,115),UDim2.fromOffset(454,65),13,true)
aucState.TextWrapped=true
local aucHelp=label(aucPage,"",UDim2.fromOffset(12,197),UDim2.fromOffset(454,75),12,false)
aucHelp.TextWrapped=true
aucHelp.TextYAlignment=Enum.TextYAlignment.Top
local aucTelemetry=label(aucPage,"",UDim2.fromOffset(12,286),UDim2.fromOffset(454,98),11,false)
aucTelemetry.TextWrapped=true
aucTelemetry.TextYAlignment=Enum.TextYAlignment.Top

local settings=new("Frame",{Position=UDim2.fromOffset(10,58),Size=UDim2.fromOffset(480,493),
    Visible=false,BackgroundColor3=P().bg,BorderSizePixel=0,ZIndex=12},root)
round(settings,9)
local settingsTitle=label(settings,"",UDim2.fromOffset(15,12),UDim2.fromOffset(430,31),16,true)
settingsTitle.ZIndex=13
local langBtn=btn(settings,"",UDim2.fromOffset(17,66),UDim2.fromOffset(445,44));langBtn.ZIndex=13
local themeBtn=btn(settings,"",UDim2.fromOffset(17,126),UDim2.fromOffset(445,44));themeBtn.ZIndex=13
local menuBindBtn=btn(settings,"",UDim2.fromOffset(17,186),UDim2.fromOffset(445,44));menuBindBtn.ZIndex=13
local settingsNote=label(settings,"",UDim2.fromOffset(17,265),UDim2.fromOffset(445,54),12)
settingsNote.TextWrapped=true;settingsNote.ZIndex=13
local unloadBtn=btn(settings,"",UDim2.fromOffset(17,347),UDim2.fromOffset(445,52));unloadBtn.ZIndex=13
local settingsClose=btn(settings,"OK",UDim2.fromOffset(17,429),UDim2.fromOffset(445,40));settingsClose.ZIndex=13
local nav=label(ui,"",UDim2.new(.5,-240,0,65),UDim2.fromOffset(480,46),15,true)
nav.TextXAlignment=Enum.TextXAlignment.Center
nav.BackgroundTransparency=.1;nav.BackgroundColor3=P().bg;nav.Visible=false
round(nav,8)

local function getHRP()
    local char=player.Character
    return char and char:FindFirstChild("HumanoidRootPart"), char
end
local function getHum()
    local char=player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function distanceTo(pos)
    local hrp=getHRP()
    return hrp and (pos-hrp.Position).Magnitude or math.huge
end
local function rarityFor(name)
    local suffix=name:match("^[Ss]torage[Cc]ontainer_(.+)$")
    if not suffix then return nil end
    for k,r in pairs(rarities) do
        if suffix:lower()==k:lower() then return r end
    end
end
local function center(rec)
    local ok,cf=pcall(function()return rec.model:GetPivot()end)
    return ok and cf.Position or rec.part.Position
end
-- A streaming-safe map of positions seen while roaming. Does not pretend to discover
-- objects that the game never replicated to the client.
local function cacheKey(rarity, pos)
    local function q(n) return math.floor(n / 4 + .5) end
    return rarity.en .. ":" .. q(pos.X) .. ":" .. q(pos.Y) .. ":" .. q(pos.Z)
end
local function cacheTag(entry, enabled)
    if entry.board then entry.board.Enabled = enabled and prefs.esp and prefs.labels end
end
local tpTo
local function forgetKnown(entry)
    if not entry then return end
    if selected==entry then selected=nil end
    -- Detach live records before removing a shared cache entry.
    for _,rec in pairs(records) do
        if rec.known==entry then rec.known=nil end
    end
    for _,c in ipairs(entry.conns or {}) do pcall(function() c:Disconnect() end) end
    if entry.row then entry.row:Destroy() end
    if entry.board then entry.board:Destroy() end
    if entry.anchor then entry.anchor:Destroy() end
    if knownLocations[entry.key]==entry then knownLocations[entry.key]=nil end
end
local function makeKnown(rarity, pos)
    local key = cacheKey(rarity, pos)
    local entry = knownLocations[key]
    if entry then
        entry.lastSeen=os.clock()
        return entry
    end
    entry={key=key, rarity=rarity, pos=pos, lastSeen=os.clock(), isCache=true, active=nil, dist=math.huge, conns={}}
    knownLocations[key]=entry
    local anchor=new("Part",{Name="Known_"..rarity.en,Size=Vector3.new(.5,.5,.5),Position=pos,
        Transparency=1,Anchored=true,CanCollide=false,CanTouch=false,CastShadow=false},knownRoot)
    anchor.CanQuery=false
    entry.anchor=anchor
    local board=new("BillboardGui",{Name="LastSeenTag",Adornee=anchor,Size=UDim2.fromOffset(225,55),
        StudsOffsetWorldSpace=Vector3.new(0,9,0),MaxDistance=1000000,AlwaysOnTop=true,
        LightInfluence=0,Enabled=false},ui)
    entry.board=board
    local bg=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=P().bg,
        BackgroundTransparency=.23,BorderSizePixel=0},board)
    round(bg,7)
    new("UIStroke",{Color=rarity.color,Thickness=1},bg)
    entry.tagName=label(bg,rarity[prefs.lang].." • "..L("lastSeen"),UDim2.fromOffset(4,2),UDim2.new(1,-8,0,24),12,true)
    entry.tagName.TextColor3=rarity.color
    entry.tagName.TextXAlignment=Enum.TextXAlignment.Center
    entry.tagDist=label(bg,"",UDim2.fromOffset(4,27),UDim2.new(1,-8,0,21),12,true)
    entry.tagDist.TextXAlignment=Enum.TextXAlignment.Center
    local row=new("Frame",{Size=UDim2.new(1,-9,0,47),BackgroundColor3=P().row,
        BorderSizePixel=0,Visible=false},conList)
    round(row,7)
    entry.row=row
    entry.rn=label(row,rarity[prefs.lang].." • "..L("lastSeen"),UDim2.fromOffset(7,4),UDim2.fromOffset(201,36),11,true)
    entry.rn.TextColor3=rarity.color
    entry.rd=label(row,"—",UDim2.fromOffset(212,5),UDim2.fromOffset(67,33),11)
    entry.rd.TextXAlignment=Enum.TextXAlignment.Center
    entry.track=btn(row,L("track"),UDim2.fromOffset(285,6),UDim2.fromOffset(86,34))
    entry.tp=btn(row,L("tp"),UDim2.fromOffset(378,6),UDim2.fromOffset(65,34))
    table.insert(entry.conns,entry.track.MouseButton1Click:Connect(function()
        selected=(selected==entry) and nil or entry
    end))
    table.insert(entry.conns,entry.tp.MouseButton1Click:Connect(function()
        -- This is only the last known location; container may no longer exist.
        local p=entry.pos
        local dir=Vector3.new(0,0,8)
        tpTo(p + dir + Vector3.new(0,4,0),p)
    end))
    return entry
end

tpTo = function(pos,lookPos)
    local hrp,char=getHRP()
    if not hrp or not char then tell(L("noChar"));return end
    local target=lookPos and CFrame.lookAt(pos,Vector3.new(lookPos.X,pos.Y,lookPos.Z)) or CFrame.new(pos)
    local ok=pcall(function()
        char:PivotTo(target)
        hrp.AssemblyLinearVelocity=Vector3.zero
        hrp.AssemblyAngularVelocity=Vector3.zero
    end)
    if ok then tell(L("tpDone")) else tell(L("noChar")) end
end
local function teleportContainer(rec)
    if not rec or not rec.model.Parent then tell(L("gone")); return end
    local hrp=getHRP();if not hrp then tell(L("noChar"));return end
    local ok,cf,size=pcall(function()return rec.model:GetBoundingBox()end)
    if not ok then tell(L("gone"));return end
    local pos=cf.Position
    local dir=Vector3.new(hrp.Position.X-pos.X,0,hrp.Position.Z-pos.Z)
    if dir.Magnitude<.01 then dir=Vector3.new(0,0,-1) end
    local side=pos+dir.Unit*(math.max(size.X,size.Z)*.75+7)
    local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude
    local exclusions={}
    if player.Character then table.insert(exclusions,player.Character) end
    if containerFolder then table.insert(exclusions,containerFolder) end
    ray.FilterDescendantsInstances=exclusions
    local hit=Workspace:Raycast(Vector3.new(side.X,pos.Y+120,side.Z),Vector3.new(0,-400,0),ray)
    local y=hit and hit.Position.Y+4 or pos.Y+size.Y/2+4
    tpTo(Vector3.new(side.X,y,side.Z),pos)
    -- Teleport must NOT silently activate tracking; TRACK is a separate action.
end

local removeRecord -- forward declaration: destruction callbacks call this
local function addRecord(model)
    if not running or not containerFolder or not model:IsA("Model") or records[model] then return end
    local r=rarityFor(model.Name);if not r then return end
    local part=model:FindFirstChildWhichIsA("BasePart",true)
    if not part then return end
    local cachePos = center({model=model,part=part})
    local known = makeKnown(r, cachePos)
    known.active=model
    known.nearSince=nil
    known.missingSince=nil
    known.pos=cachePos
    known.anchor.Position=cachePos
    cacheTag(known,false)
    known.row.Visible=false
    for _,old in ipairs({"AuctionESP","AuctionESP_v2","PaporotnicHub_Highlight"}) do
        local o=model:FindFirstChild(old)
        if o and o:IsA("Highlight") then o:Destroy() end
    end
    local h=new("Highlight",{Name="PaporotnicHub_Highlight",Adornee=model,
        DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,FillColor=r.color,FillTransparency=.73,
        OutlineColor=r.color,OutlineTransparency=0,Enabled=prefs.esp},model)
    local offset=Vector3.new(0,7,0)
    local ok,cf,size=pcall(function()return model:GetBoundingBox()end)
    if ok then offset=cf.Position-part.Position+Vector3.new(0,size.Y/2+3,0) end
    local board=new("BillboardGui",{Name="PaporotnicHub_Tag",Adornee=part,Size=UDim2.fromOffset(222,52),
        StudsOffsetWorldSpace=offset,MaxDistance=1000000,AlwaysOnTop=true,LightInfluence=0,
        Enabled=prefs.esp and prefs.labels},ui)
    local tagBg=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=P().bg,BackgroundTransparency=.1,BorderSizePixel=0},board)
    round(tagBg,7)
    new("UIStroke",{Color=r.color,Thickness=1.5},tagBg)
    local tagName=label(tagBg,r[prefs.lang],UDim2.fromOffset(4,1),UDim2.new(1,-8,0,26),14,true)
    tagName.TextXAlignment=Enum.TextXAlignment.Center;tagName.TextColor3=r.color
    local tagDist=label(tagBg,"",UDim2.fromOffset(4,26),UDim2.new(1,-8,0,21),13,true)
    tagDist.TextXAlignment=Enum.TextXAlignment.Center
    local row=new("Frame",{Size=UDim2.new(1,-9,0,47),BackgroundColor3=P().row,BorderSizePixel=0},conList)
    round(row,7)
    local rn=label(row,r[prefs.lang],UDim2.fromOffset(7,4),UDim2.fromOffset(205,36),12,true)
    rn.TextColor3=r.color
    local rd=label(row,"—",UDim2.fromOffset(212,5),UDim2.fromOffset(67,33),11)
    rd.TextXAlignment=Enum.TextXAlignment.Center
    local track=btn(row,L("track"),UDim2.fromOffset(285,6),UDim2.fromOffset(86,34))
    local tp=btn(row,L("tp"),UDim2.fromOffset(378,6),UDim2.fromOffset(65,34))
    local rec={model=model,part=part,rarity=r,highlight=h,board=board,tagBg=tagBg,tagName=tagName,
        tagDist=tagDist,row=row,rn=rn,rd=rd,track=track,tp=tp,conns={},dist=math.huge,known=known}
    records[model]=rec
    -- Unlike streaming out, an explicit Instance:Destroy() triggers Destroying.
    table.insert(rec.conns,model.Destroying:Connect(function()
        if running then removeRecord(model,"destroyed") end
    end))
    table.insert(rec.conns,track.MouseButton1Click:Connect(function()
        selected=(selected==rec) and nil or rec
    end))
    table.insert(rec.conns,tp.MouseButton1Click:Connect(function()teleportContainer(rec)end))
end
removeRecord = function(model,why)
    local rec=records[model];if not rec then return end
    if selected==rec then selected=nil end
    local known=rec.known
    if known and known.active==model then
        known.active=nil
        known.lastSeen=os.clock()
        known.missingSince=os.clock()
    end
    for _,c in ipairs(rec.conns) do pcall(function()c:Disconnect()end) end
    if rec.row then rec.row:Destroy() end
    if rec.board then rec.board:Destroy() end
    if rec.highlight then rec.highlight:Destroy() end
    records[model]=nil
    if why=="destroyed" and known then
        -- Confirmed server/client destruction; never leave an ESP ghost.
        forgetKnown(known)
    end
end

-- Movement controls. The local character may be corrected by the game server.
local vel,gyro=nil,nil
local function stopFly()
    flyOn=false
    if vel then vel:Destroy();vel=nil end
    if gyro then gyro:Destroy();gyro=nil end
    local hum=getHum()
    if hum then hum.PlatformStand=false end
end
local function toggleFly()
    if flyOn then stopFly();return end
    local hrp=getHRP();local hum=getHum()
    if not hrp or not hum then tell(L("noChar"));return end
    flyOn=true
    vel=new("BodyVelocity",{MaxForce=Vector3.new(1e8,1e8,1e8),Velocity=Vector3.zero,P=12000},hrp)
    gyro=new("BodyGyro",{MaxTorque=Vector3.new(1e8,1e8,1e8),P=12000,D=500,CFrame=Workspace.CurrentCamera.CFrame},hrp)
    hum.PlatformStand=true
end
local function stopNoclip()
    for part,old in pairs(originalCollisions) do
        if part and part.Parent then pcall(function()part.CanCollide=old end) end
    end
    originalCollisions={}
end
local originalWalkSpeeds=setmetatable({}, {__mode="k"})
local function applyWalk()
    local hum=getHum()
    if hum then
        if originalWalkSpeeds[hum]==nil then originalWalkSpeeds[hum]=hum.WalkSpeed end
        hum.WalkSpeed=prefs.speed
    end
end
local function keyDown(key)
    return UserInputService:IsKeyDown(key)
end
listen(RunService.Heartbeat,function()
    if not running or not flyOn then return end
    local hrp=getHRP();local hum=getHum();local cam=Workspace.CurrentCamera
    if not hrp or not hum or not cam or not vel or not gyro then stopFly();return end
    hum.PlatformStand=true
    local cf=cam.CFrame
    local forward=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)
    local right=Vector3.new(cf.RightVector.X,0,cf.RightVector.Z)
    if forward.Magnitude>.01 then forward=forward.Unit end
    if right.Magnitude>.01 then right=right.Unit end
    local d=Vector3.zero
    if keyDown(Enum.KeyCode.W) then d=d+forward end
    if keyDown(Enum.KeyCode.S) then d=d-forward end
    if keyDown(Enum.KeyCode.D) then d=d+right end
    if keyDown(Enum.KeyCode.A) then d=d-right end
    if keyDown(Enum.KeyCode.Space) then d=d+Vector3.yAxis end
    if keyDown(Enum.KeyCode.LeftControl) or keyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.yAxis end
    vel.Velocity=d.Magnitude>.01 and d.Unit*prefs.flySpeed or Vector3.zero
    gyro.CFrame=cf
end)
listen(RunService.Stepped,function()
    if not running or not prefs.noclip then return end
    local char=player.Character
    if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if originalCollisions[p]==nil then originalCollisions[p]=p.CanCollide end
            if p.CanCollide then p.CanCollide=false end
        end
    end
end)
listen(player.CharacterAdded,function(char)
    stopFly();stopNoclip()
    task.delay(1.25,function()
        if not running or player.Character~=char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart",4)
        if hrp then
            homeCF=hrp.CFrame
            tell(L("homeAuto"))
            applyWalk()
        end
    end)
end)
-- IMPORTANT: on first launch away from the user's base, home is deliberately unknown.
-- It is learned after the next actual respawn, or explicitly by the SAVE HOME button.

-- Auction v6: client GUI timing; no server guarantees. Never moves the target zone.
-- Detect the zone/pointer independently of their position along the bar.
local auctionStatus="auctionIdle"
local auctionTelemetry=""
local auctionCache=nil
local lastAuctionScan=0
local lastFire=0
local lastPointerX=nil
local lastPointerTime=nil
local lastSpeed=0
local lastGoalX=nil
local lastAuctionElements=nil
local armed=true
local farSince=nil
local lastPromptVisible=false
local function lower(s)return tostring(s or ""):lower() end
local function isVisibleGui(o)
    if not o or not o:IsA("GuiObject") or not o.Visible then return false end
    local ancestor=o.Parent
    while ancestor and ancestor~=playerGui do
        if ancestor:IsA("GuiObject") and not ancestor.Visible then return false end
        if ancestor:IsA("ScreenGui") and not ancestor.Enabled then return false end
        ancestor=ancestor.Parent
    end
    return o.AbsoluteSize.X>0 and o.AbsoluteSize.Y>0
end
local function visibleText(o)
    if not (o:IsA("TextLabel") or o:IsA("TextButton")) or not isVisibleGui(o) then return nil end
    return tostring(o.Text or ""):gsub("<.->",""):gsub("%s+"," ")
end
local cachedPrompt=nil
local lastPromptScan=0
local function findPrompt()
    if cachedPrompt and cachedPrompt.Parent and isVisibleGui(cachedPrompt) then
        local t=lower(visibleText(cachedPrompt))
        if t:find("stop in the green",1,true) or t:find("space or click",1,true) then
            return cachedPrompt
        end
    end
    cachedPrompt=nil
    if os.clock()-lastPromptScan<.08 then return nil end
    lastPromptScan=os.clock()
    for _,o in ipairs(playerGui:GetDescendants()) do
        local t=visibleText(o)
        if t then
            t=lower(t)
            if t:find("stop in the green",1,true) or t:find("space or click",1,true) then
                cachedPrompt=o;return o
            end
        end
    end
end
local function sharedAncestor(a,b)
    local seen={};local n=a
    while n do seen[n]=true;n=n.Parent end
    n=b
    while n do if seen[n] then return n end;n=n.Parent end
end
local function getAuctionGeometry()
    local prompt=findPrompt()
    if not prompt then return nil,"idle" end
    local cy=prompt.AbsolutePosition.Y+prompt.AbsoluteSize.Y*.5
    local left=prompt.AbsolutePosition.X-130
    local right=prompt.AbsolutePosition.X+prompt.AbsoluteSize.X+130
    local yellows,greens,whites={},{},{}
    for _,o in ipairs(playerGui:GetDescendants()) do
        if o:IsA("GuiObject") and isVisibleGui(o) and o~=prompt then
            local p,s=o.AbsolutePosition,o.AbsoluteSize
            local midx,midy=p.X+s.X*.5,p.Y+s.Y*.5
            if midx>=left and midx<=right and math.abs(midy-cy)<125 and s.X>2 and s.Y>5 and s.Y<95 then
                local color=nil;local opacity=0
                if o:IsA("Frame") or o:IsA("TextLabel") or o:IsA("TextButton") then
                    color=o.BackgroundColor3;opacity=1-o.BackgroundTransparency
                elseif o:IsA("ImageLabel") or o:IsA("ImageButton") then
                    color=o.ImageColor3;opacity=1-o.ImageTransparency
                end
                if color and opacity>.2 then
                    local h,sat,val=color:ToHSV()
                    local candidate={o=o,x=midx,y=midy,w=s.X,h=s.Y,
                        score=math.abs(midy-(cy-34))*2 + math.max(0,s.Y-45)}
                    if sat>.27 and h>.09 and h<.175 and val>.35 and s.X>=7 and s.X<=380 then
                        table.insert(yellows,candidate)
                    elseif sat>.20 and h>.28 and h<.50 and val>.27 and s.X>=8 and s.X<=380 then
                        table.insert(greens,candidate)
                    elseif sat<.18 and val>.73 and s.X<=25 and s.Y>=13 and s.Y<=85 then
                        candidate.score=candidate.score+math.abs(s.X-5)*.5
                        table.insert(whites,candidate)
                    end
                end
            end
        end
    end
    table.sort(yellows,function(a,b)return a.score<b.score end)
    local yellow=yellows[1]
    if not yellow then return nil,"noBar" end
    local elig={}
    for _,w in ipairs(whites) do
        if math.abs(w.y-yellow.y)<42 and math.abs(w.x-yellow.x)<950 then
            local ancestor=sharedAncestor(w.o,yellow.o)
            local sc=math.abs(w.y-yellow.y)*3+math.abs(w.h-yellow.h)*.4+math.abs(w.w-5)*.7
            if ancestor==playerGui then sc=sc+18 end
            table.insert(elig,{o=w.o,x=w.x,y=w.y,score=sc})
        end
    end
    table.sort(elig,function(a,b)return a.score<b.score end)
    local pointer=elig[1]
    if not pointer then return nil,"noBar" end
    -- Green segments: same row as yellow, never an unrelated green button.
    local closeGreens={}
    for _,g in ipairs(greens) do
        local dy=math.abs(g.y-yellow.y)
        local dx=math.abs(g.x-yellow.x)
        if dy<20 and dx<math.max(95, yellow.w*5) then
            table.insert(closeGreens,{o=g.o,x=g.x,y=g.y,w=g.w,score=dy*3+dx*.05})
        end
    end
    table.sort(closeGreens,function(a,b)return a.score<b.score end)
    -- Choose nearest valid green segment; it may be left or right of yellow.
    return {prompt=prompt,yellow=yellow,green=closeGreens[1],pointer=pointer},"found"
end
local function sendSpace()
    local keypressFn=env.keypress or keypress
    local keyreleaseFn=env.keyrelease or keyrelease
    if type(keypressFn)=="function" and type(keyreleaseFn)=="function" then
        local ok=pcall(function()
            keypressFn(0x20)
            task.wait(.025)
            keyreleaseFn(0x20)
        end)
        if ok then return true end
    end
    local ok,vim=pcall(function()return game:GetService("VirtualInputManager")end)
    if ok and vim then
        return pcall(function()
            vim:SendKeyEvent(true,Enum.KeyCode.Space,false,game)
            task.wait(.025)
            vim:SendKeyEvent(false,Enum.KeyCode.Space,false,game)
        end)
    end
    return false
end
local function parseMoney(text)
    if not text then return nil end
    local str=tostring(text):match("%$%s*([%d,]+)")
    if not str then return nil end
    return tonumber(str:gsub(",",""))
end
local lastBidStatsTime=0
local lastBidStats={}
local function getBidStats()
    local now=os.clock()
    if now-lastBidStatsTime<.12 then return lastBidStats end
    lastBidStatsTime=now
    local stats={}
    local all={}
    for _,o in ipairs(playerGui:GetDescendants()) do
        local t=visibleText(o)
        if t then table.insert(all,{o=o,t=t,up=t:upper()}) end
    end
    for _,v in ipairs(all) do
        local t=v.up
        if t:find("PERFECT",1,true) then stats.perfect=stats.perfect or parseMoney(v.t) end
        if t:find("GOOD",1,true) then stats.good=stats.good or parseMoney(v.t) end
        if t:find("MISS",1,true) then stats.miss=stats.miss or parseMoney(v.t) end
        if t:find("CURRENT BID",1,true) then stats.bid=stats.bid or parseMoney(v.t) end
        if t:find("SPENDABLE",1,true) then stats.cash=stats.cash or parseMoney(v.t) end
        -- Bidders screen has a row labelled YOU, with LEADING inside the same row.
        if t=="YOU" or t:match("^YOU%s") then
            local parent=v.o.Parent
            if parent then
                local found=false
                for _,obj in ipairs(parent:GetDescendants()) do
                    local sub=visibleText(obj)
                    if sub and sub:upper():find("LEADING",1,true) then found=true;break end
                end
                if found then stats.leading=true end
            end
        end
    end
    lastBidStats=stats
    return stats
end
local function resetAuctionMotion()
    auctionCache=nil
    lastPointerX=nil
    lastPointerTime=nil
    lastSpeed=0
    lastGoalX=nil
    lastAuctionElements=nil
    armed=true
    farSince=nil
end
local function chooseAuctionTarget(geom,mode,stats)
    if mode=="yellow" then return geom.yellow,"yellow" end
    if mode=="green" then return geom.green,"green" end
    if mode~="win" then return nil,"off" end
    if stats.leading then return nil,"leading" end
    local opts={}
    if geom.yellow then table.insert(opts,{zone=geom.yellow,kind="yellow",raise=stats.perfect or 1}) end
    if geom.green then table.insert(opts,{zone=geom.green,kind="green",raise=stats.good or 2}) end
    table.sort(opts,function(a,b)return a.raise<b.raise end)
    for _,cand in ipairs(opts) do
        if not (stats.cash and stats.bid and cand.raise and stats.bid+cand.raise>stats.cash) then
            return cand.zone,cand.kind
        end
    end
    return nil,"budget"
end
local function auctionTick()
    local mode=prefs.auctionMode
    if mode=="off" then return end
    local now=os.clock()
    local prompt=findPrompt()
    if not prompt then
        if lastPromptVisible then resetAuctionMotion() end
        lastPromptVisible=false
        auctionStatus="auctionIdle"
        return
    end
    if not lastPromptVisible then resetAuctionMotion() end
    lastPromptVisible=true
    if not auctionCache or now-lastAuctionScan>.18 or not auctionCache.pointer.o.Parent
        or not auctionCache.yellow.o.Parent or not isVisibleGui(auctionCache.prompt) then
        local geom,state=getAuctionGeometry()
        lastAuctionScan=now
        if geom then auctionCache=geom end
        if state~="found" and not auctionCache then
            auctionStatus="auctionNoBar"
            return
        end
    end
    local geom=auctionCache
    if not geom or not geom.pointer.o.Parent or not geom.yellow.o.Parent then
        auctionStatus="auctionNoBar";return
    end
    local stats=getBidStats()
    local goalObj,kind=chooseAuctionTarget(geom,mode,stats)
    if not goalObj then
        if kind=="leading" then auctionStatus="auctionLeading"
        elseif kind=="budget" then auctionStatus="auctionOverBudget"
        elseif kind=="green" then auctionStatus="auctionGreenMissing"
        else auctionStatus="auctionNoBar" end
        auctionTelemetry="Current bid: "..tostring(stats.bid or "?").." | Cash: "..tostring(stats.cash or "?")
        return
    end
    local ptr=geom.pointer.o
    local x=ptr.AbsolutePosition.X+ptr.AbsoluteSize.X*.5
    local goal=goalObj.o.AbsolutePosition.X+goalObj.o.AbsoluteSize.X*.5
    local w=goalObj.o.AbsoluteSize.X
    local token=tostring(ptr).."|"..tostring(goalObj.o)
    -- If UI is recreated / zone jumps between rounds, immediately rearm.
    if lastAuctionElements and token~=lastAuctionElements then
        resetAuctionMotion();auctionCache=geom
    end
    if lastGoalX and math.abs(goal-lastGoalX)>math.max(16,w*.9) and now-lastFire>.15 then
        armed=true;lastPointerX=nil;lastPointerTime=nil;lastSpeed=0
    end
    lastAuctionElements=token;lastGoalX=goal
    local speed=lastSpeed
    if lastPointerX and lastPointerTime then
        local dt=now-lastPointerTime
        if dt>.003 and dt<.20 then
            local v=(x-lastPointerX)/dt
            if math.abs(v)<15000 then
                -- Motion can reverse at edges; do not smooth away a reversal.
                if speed*v<=0 then speed=v else speed=speed*.35+v*.65 end
            end
        end
    end
    -- Position can reset from right to left when a new sweep/turn begins.
    if not armed and now-lastFire>.20 and lastPointerX and x<lastPointerX-math.max(25,w) then
        armed=true
    end
    -- The prompt can persist across turns. Rearm if pointer has clearly left zone.
    if not armed then
        if math.abs(x-goal)>math.max(42,w*1.6) then
            farSince=farSince or now
            if now-farSince>.45 and now-lastFire>.55 then armed=true end
        else
            farSince=nil
        end
    end
    local left=goal-w*.5
    local right=goal+w*.5
    -- Predict forward across keypress latency; works for zones on either side.
    local lead=math.clamp(math.abs(speed)*.030,0,math.max(8,w*.45))
    local predicted=x+(speed>0 and lead or (speed<0 and -lead or 0))
    local inside=x>=left+1 and x<=right-1
    local incoming=(speed>1 and x<=right and predicted>=left+w*.26)
        or (speed< -1 and x>=left and predicted<=right-w*.26)
    local nearCenter=math.abs(predicted-goal)<=math.max(3,w*.23)
    auctionStatus="auctionFound"
    auctionTelemetry=string.format("Mode: %s (%s) | X: %.0f / target: %.0f | speed %.0f px/s | width: %.0f | armed: %s\nBid: %s | Cash: %s | Perfect +%s | Good +%s",
        mode,kind,x,goal,speed,w,tostring(armed),tostring(stats.bid or "?"),tostring(stats.cash or "?"),
        tostring(stats.perfect or "?"),tostring(stats.good or "?"))
    if armed and now-lastFire>.28 and (inside or (incoming and nearCenter)) then
        armed=false;lastFire=now;farSince=nil
        task.spawn(function()
            local ok=sendSpace()
            if ok then auctionStatus="auctionFired" else auctionStatus="auctionNoInput" end
        end)
    end
    lastPointerX=x
    lastPointerTime=now
    lastSpeed=speed
end
local function auditGui()
    local geom,state=getAuctionGeometry()
    local out={"PAPOROTNIC HUB v6 AUCTION DIAGNOSTICS", "Detection: "..state,
        "Mode: "..tostring(prefs.auctionMode),"Telemetry: "..auctionTelemetry}
    local prompt=findPrompt()
    if prompt then
        table.insert(out,"Prompt: "..prompt:GetFullName())
        table.insert(out,"Prompt position: "..tostring(prompt.AbsolutePosition))
    end
    if geom then
        for _,key in ipairs({"yellow","green","pointer"}) do
            local a=geom[key]
            if a then
                table.insert(out,key:upper()..": "..a.o:GetFullName().." pos="..tostring(a.o.AbsolutePosition).." size="..tostring(a.o.AbsoluteSize))
            end
        end
    end
    local stats=getBidStats()
    for k,v in pairs(stats) do table.insert(out,"Bid data "..tostring(k).."="..tostring(v)) end
    table.insert(out,"Nearby visible GUI candidates:")
    if prompt then
        local cx=prompt.AbsolutePosition.X+prompt.AbsoluteSize.X*.5
        local cy=prompt.AbsolutePosition.Y+prompt.AbsoluteSize.Y*.5
        local count=0
        for _,obj in ipairs(playerGui:GetDescendants()) do
            if obj:IsA("GuiObject") and isVisibleGui(obj) then
                local p,s=obj.AbsolutePosition,obj.AbsoluteSize
                if math.abs(p.X+s.X*.5-cx)<750 and math.abs(p.Y+s.Y*.5-cy)<145 then
                    count=count+1
                    if count<=90 then
                        local t=visibleText(obj) or ""
                        table.insert(out,obj.ClassName.." "..obj:GetFullName().." position="..tostring(p).." size="..tostring(s).." text="..t:sub(1,90))
                    end
                end
            end
        end
    end
    local msg=table.concat(out,"\n")
    print(msg)
    local cb=env.setclipboard or setclipboard
    if type(cb)=="function" then
        if pcall(cb,msg) then tell(L("copy")) else tell(L("copyFail")) end
    else tell(L("copyFail")) end
end

-- Minimap overlay icons can exist even for streamed-out world models.
-- We export positions/attributes, not fake world coordinates. Coordinate
-- calibration needs at least two matching live markers before full-map ESP.
local function scanMinimap()
    local out={"Paporotnic Hub v7 | MINIMAP DIAGNOSTICS",
        "Workspace.StreamingEnabled = "..tostring(Workspace.StreamingEnabled)}
    local count=0
    for _,obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Name:lower():find("container",1,true) then
            count=count+1
            if count<=180 then
                local parent=obj.Parent
                local pos=obj.AbsolutePosition
                local size=obj.AbsoluteSize
                local attrs={}
                for k,v in pairs(obj:GetAttributes()) do
                    table.insert(attrs,tostring(k).."="..tostring(v))
                end
                table.sort(attrs)
                local ancestor=parent
                local depth=0
                while ancestor and depth<4 do
                    if ancestor.Name:lower():find("overlay",1,true) then break end
                    ancestor=ancestor.Parent
                    depth=depth+1
                end
                local norm="n/a"
                if ancestor and ancestor:IsA("GuiObject") then
                    local ap,as=ancestor.AbsolutePosition,ancestor.AbsoluteSize
                    if as.X>0 and as.Y>0 then
                        norm=string.format("%.4f,%.4f",(pos.X+size.X/2-ap.X)/as.X,
                            (pos.Y+size.Y/2-ap.Y)/as.Y)
                    end
                end
                table.insert(out,string.format("%s | px=%.0f,%.0f | norm=%s | attrs=%s | visible=%s",
                    obj:GetFullName(),pos.X,pos.Y,norm,table.concat(attrs,";"),tostring(obj.Visible)))
            end
        end
    end
    table.insert(out,2,"Marker count: "..count)
    if count==0 then tell(L("mapNotFound")) else tell(L("mapCopied")) end
    local msg=table.concat(out,"\n")
    print(msg)
    local clip=env.setclipboard or setclipboard
    if type(clip)=="function" then pcall(clip,msg) end
end

-- Collapse only the content; the titlebar remains at full width and stays draggable.
local function setCollapsed(value)
    collapsed=value
    root.Size=UDim2.fromOffset(500,collapsed and 52 or 560)
    -- A header dragged near the screen bottom should re-open within the viewport.
    if not collapsed then
        local camera=Workspace.CurrentCamera
        local vp=camera and camera.ViewportSize
        if vp then
            local at=root.AbsolutePosition
            local x=math.clamp(at.X,0,math.max(0,vp.X-500))
            local y=math.clamp(at.Y,0,math.max(0,vp.Y-560))
            root.Position=UDim2.fromOffset(x,y)
        end
    end
end

local function refresh()
    local p=P()
    root.BackgroundColor3=p.bg;top.BackgroundColor3=p.panel;outline.Color=p.border
    settings.BackgroundColor3=p.bg;head.TextColor3=p.text
    for _,b in ipairs({settingBtn,minBtn,closeBtn,espBtn,tagsBtn,clearBtn,walkMinus,walkPlus,flyMinus,flyPlus,
        flyBtn,noclipBtn,flyBindBtn,noclipBindBtn,saveHomeBtn,tpHomeBtn,yellowAucBtn,greenAucBtn,winAucBtn,scanBtn,langBtn,themeBtn,
        menuBindBtn,settingsClose,unloadBtn,mapScanBtn,purgeBtn,tabB.containers,tabB.movement,tabB.auction}) do
        b.BackgroundColor3=p.panel;b.TextColor3=p.text
    end
    for _,l in ipairs({status,conHeader,conFoot,walkLabel,walkValue,flySpeedLabel,flyValue,homeText,
        aucState,aucHelp,aucTelemetry,settingsTitle,settingsNote,emptyLabel}) do l.TextColor3=p.muted end
    for _,name in ipairs({"containers","movement","auction"}) do
        pages[name].Visible=(not collapsed and not inSettings and currentPage==name)
        tabB[name].Text=L(name)
        tabB[name].BackgroundColor3=(currentPage==name) and p.accent or p.panel
        tabB[name].TextColor3=(currentPage==name) and p.bg or p.text
    end
    settings.Visible=(not collapsed and inSettings);tabs.Visible=(not collapsed and not inSettings)
    status.Visible=(not collapsed and not inSettings)
    minBtn.Text=collapsed and "□" or "—"
    espBtn.Text=L("esp")..": "..L(prefs.esp and "on" or "off")
    tagsBtn.Text=L("labels")..": "..L(prefs.labels and "on" or "off")
    espBtn.TextColor3=prefs.esp and p.accent or Color3.fromRGB(220,110,110)
    tagsBtn.TextColor3=prefs.labels and p.accent or Color3.fromRGB(220,110,110)
    conHeader.Text=string.format(L("found"),0,0,0)
    clearBtn.Text=L("clear")
    purgeBtn.Text=L("purge")
    mapScanBtn.Text=L("minimap")
    conFoot.Text=L("restricted")
    conList.BackgroundColor3=p.panel;conList.ScrollBarImageColor3=p.accent
    emptyLabel.Text=L("none")
    walkLabel.Text=L("speed");if not walkValue:IsFocused() then walkValue.Text=tostring(prefs.speed) end
    flySpeedLabel.Text=L("flySpeed");if not flyValue:IsFocused() then flyValue.Text=tostring(prefs.flySpeed) end
    walkValue.TextColor3=p.text;flyValue.TextColor3=p.text
    walkValue.BackgroundColor3=p.row;flyValue.BackgroundColor3=p.row
    flyBtn.Text=L("fly")..": "..L(flyOn and "on" or "off")
    noclipBtn.Text=L("noclip")..": "..L(prefs.noclip and "on" or "off")
    flyBindBtn.Text=(bindingFor=="fly") and L("press") or (L("flyKey")..": "..prefs.flyKey)
    noclipBindBtn.Text=(bindingFor=="noclip") and L("press") or (L("noclipKey")..": "..prefs.noclipKey)
    saveHomeBtn.Text=L("saveHome");tpHomeBtn.Text=L("tpHome")
    homeText.Text=homeCF and ("HOME: "..tostring(homeCF.Position)) or L("homeMissing")
    for _,tuple in ipairs({{yellowAucBtn,"yellow","auctionYellow"},{greenAucBtn,"green","auctionGreen"},
        {winAucBtn,"win","auctionWin"}}) do
        local b,mode,key=tuple[1],tuple[2],tuple[3]
        b.Text=L(key)
        b.BackgroundColor3=prefs.auctionMode==mode and p.accent or p.panel
        b.TextColor3=prefs.auctionMode==mode and p.bg or p.text
    end
    scanBtn.Text=L("scan")
    aucState.Text=prefs.auctionMode=="off" and L("auctionModeOff") or L(auctionStatus)
    aucHelp.Text=L("auctionTip")
    aucTelemetry.Text=auctionTelemetry
    settingsTitle.Text=L("settings")
    langBtn.Text=L("language")..": "..prefs.lang:upper()
    themeBtn.Text=L("theme")..": "..L(prefs.theme)
    menuBindBtn.Text=(bindingFor=="menu") and L("press") or (L("menuKey")..": "..prefs.menuKey)
    settingsNote.Text=L("guide").."\n"..L("notif")
    unloadBtn.Text=L(unloadArmed and "unloadConfirm" or "unload")
    unloadBtn.BackgroundColor3=unloadArmed and Color3.fromRGB(151,48,49) or p.row
    unloadBtn.TextColor3=unloadArmed and Color3.fromRGB(255,255,255) or Color3.fromRGB(240,105,105)
    nav.BackgroundColor3=p.bg
    for _,rec in pairs(knownLocations) do
        rec.tagName.Text=rec.rarity[prefs.lang].." • "..L("lastSeen")
        rec.rn.Text=rec.rarity[prefs.lang].." • "..L("lastSeen")
        rec.tagDist.TextColor3=p.text
        rec.row.BackgroundColor3=p.row
        rec.track.Text=L("track");rec.track.BackgroundColor3=p.panel;rec.track.TextColor3=p.text
        rec.tp.Text=L("tp");rec.tp.BackgroundColor3=p.panel;rec.tp.TextColor3=p.accent
    end
    for _,rec in pairs(records) do
        rec.highlight.Enabled=prefs.esp
        rec.board.Enabled=prefs.esp and prefs.labels
        rec.tagBg.BackgroundColor3=p.bg
        rec.tagName.Text=rec.rarity[prefs.lang]
        rec.tagDist.TextColor3=p.text
        rec.row.BackgroundColor3=p.row
        rec.rn.Text=rec.rarity[prefs.lang]
        rec.rd.TextColor3=p.muted
        rec.track.Text=L("track");rec.track.BackgroundColor3=p.panel;rec.track.TextColor3=p.text
        rec.tp.Text=L("tp");rec.tp.BackgroundColor3=p.panel;rec.tp.TextColor3=p.accent
    end
end

for name,b in pairs(tabB) do
    listen(b.MouseButton1Click,function()
        inSettings=false;currentPage=name;refresh()
    end)
end
listen(settingBtn.MouseButton1Click,function()
    if collapsed then
        setCollapsed(false)
        inSettings=true
    else
        inSettings=not inSettings
    end
    unloadArmed=false
    refresh()
end)
listen(settingsClose.MouseButton1Click,function()inSettings=false;unloadArmed=false;refresh()end)
listen(minBtn.MouseButton1Click,function()
    setCollapsed(not collapsed)
    refresh()
end)
-- X does not unload: it hides the menu until the configured hotkey opens it again.
listen(closeBtn.MouseButton1Click,function()
    root.Visible=false
    nav.Visible=false
    unloadArmed=false
end)
-- Explicit unload lives in Settings only. Require confirmation to avoid accidents.
listen(unloadBtn.MouseButton1Click,function()
    if not unloadArmed then
        unloadArmed=true
        refresh()
    else
        if type(env.__PaporotnicHub_Stop)=="function" then env.__PaporotnicHub_Stop() end
    end
end)
listen(espBtn.MouseButton1Click,function()prefs.esp=not prefs.esp;refresh()end)
listen(tagsBtn.MouseButton1Click,function()prefs.labels=not prefs.labels;refresh()end)
listen(clearBtn.MouseButton1Click,function()selected=nil;nav.Visible=false;refresh()end)
listen(purgeBtn.MouseButton1Click,function()
    local stale={}
    for _,entry in pairs(knownLocations) do
        if not (entry.active and records[entry.active]) then
            table.insert(stale,entry)
        end
    end
    for _,entry in ipairs(stale) do forgetKnown(entry) end
    tell(prefs.lang=="ru" and ("Кэш очищен: "..#stale) or ("Cache cleared: "..#stale))
end)
listen(mapScanBtn.MouseButton1Click,scanMinimap)
listen(walkMinus.MouseButton1Click,function()prefs.speed=math.max(16,prefs.speed-10);applyWalk();refresh()end)
listen(walkPlus.MouseButton1Click,function()prefs.speed=math.min(250,prefs.speed+10);applyWalk();refresh()end)
listen(flyMinus.MouseButton1Click,function()prefs.flySpeed=math.max(10,prefs.flySpeed-25);refresh()end)
listen(flyPlus.MouseButton1Click,function()prefs.flySpeed=math.min(1000,prefs.flySpeed+25);refresh()end)
listen(walkValue.FocusLost,function()
    local n=tonumber(walkValue.Text)
    if n then prefs.speed=math.clamp(math.floor(n+.5),16,250);applyWalk() end
    refresh()
end)
listen(flyValue.FocusLost,function()
    local n=tonumber(flyValue.Text)
    if n then prefs.flySpeed=math.clamp(math.floor(n+.5),10,1000) end
    refresh()
end)
listen(flyBtn.MouseButton1Click,function()toggleFly();refresh()end)
listen(noclipBtn.MouseButton1Click,function()
    prefs.noclip=not prefs.noclip
    if not prefs.noclip then stopNoclip() end
    refresh()
end)
listen(flyBindBtn.MouseButton1Click,function()bindingFor="fly";refresh()end)
listen(noclipBindBtn.MouseButton1Click,function()bindingFor="noclip";refresh()end)
listen(saveHomeBtn.MouseButton1Click,function()
    local hrp=getHRP()
    if hrp then homeCF=hrp.CFrame;tell(L("homeSaved")) else tell(L("noChar")) end
    refresh()
end)
listen(tpHomeBtn.MouseButton1Click,function()
    if homeCF then tpTo(homeCF.Position+Vector3.new(0,3,0)) else tell(L("homeMissing")) end
end)
local function switchAuctionMode(mode)
    prefs.auctionMode=(prefs.auctionMode==mode) and "off" or mode
    resetAuctionMotion()
    auctionStatus="auctionIdle"
    auctionTelemetry=""
    lastPromptVisible=false
    refresh()
end
listen(yellowAucBtn.MouseButton1Click,function()switchAuctionMode("yellow")end)
listen(greenAucBtn.MouseButton1Click,function()switchAuctionMode("green")end)
listen(winAucBtn.MouseButton1Click,function()switchAuctionMode("win")end)
listen(scanBtn.MouseButton1Click,auditGui)
listen(langBtn.MouseButton1Click,function()unloadArmed=false;prefs.lang=(prefs.lang=="ru") and "en" or "ru";refresh()end)
listen(themeBtn.MouseButton1Click,function()
    unloadArmed=false
    prefs.theme=({dark="light",light="neon",neon="dark"})[prefs.theme]
    refresh()
end)
listen(menuBindBtn.MouseButton1Click,function()unloadArmed=false;bindingFor="menu";refresh()end)
listen(UserInputService.InputBegan,function(input,gpe)
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    if bindingFor then
        if input.KeyCode==Enum.KeyCode.Escape then bindingFor=nil
        elseif input.KeyCode~=Enum.KeyCode.Unknown then
            if bindingFor=="menu" then prefs.menuKey=input.KeyCode.Name
            elseif bindingFor=="fly" then prefs.flyKey=input.KeyCode.Name
            elseif bindingFor=="noclip" then prefs.noclipKey=input.KeyCode.Name end
            bindingFor=nil
        end
        refresh()
        return
    end
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode.Name==prefs.menuKey then
        root.Visible=not root.Visible
        if not root.Visible then nav.Visible=false;unloadArmed=false end
        refresh()
    elseif input.KeyCode.Name==prefs.flyKey and not gpe then
        toggleFly();refresh()
    elseif input.KeyCode.Name==prefs.noclipKey and not gpe then
        prefs.noclip=not prefs.noclip
        if not prefs.noclip then stopNoclip() end
        refresh()
    end
end)
-- Dragging by the title bar.
local dragging,startDrag,startPos=false,nil,nil
listen(top.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true;startDrag=input.Position;startPos=root.Position
    end
end)
listen(UserInputService.InputEnded,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
listen(UserInputService.InputChanged,function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local d=input.Position-startDrag
        local wanted=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        local camera=Workspace.CurrentCamera
        local vp=camera and camera.ViewportSize
        if vp then
            local base=Vector2.new(startPos.X.Scale*vp.X+startPos.X.Offset,startPos.Y.Scale*vp.Y+startPos.Y.Offset)
            local x=math.clamp(base.X+d.X,0,math.max(0,vp.X-500))
            local y=math.clamp(base.Y+d.Y,0,math.max(0,vp.Y-(collapsed and 52 or 560)))
            root.Position=UDim2.fromOffset(x,y)
        else
            root.Position=wanted
        end
    end
end)

local dirs={"↑","↗","→","↘","↓","↙","←","↖"}
local function arrowTo(p)
    local cam=Workspace.CurrentCamera;if not cam then return "•" end
    local d=p-cam.CFrame.Position
    local flat=Vector3.new(d.X,0,d.Z)
    if flat.Magnitude<.01 then return "•" end
    flat=flat.Unit
    local f=cam.CFrame.LookVector;local r=cam.CFrame.RightVector
    f=Vector3.new(f.X,0,f.Z);r=Vector3.new(r.X,0,r.Z)
    if f.Magnitude<.01 or r.Magnitude<.01 then return "•" end
    local a=math.atan2(flat:Dot(r.Unit),flat:Dot(f.Unit))
    return dirs[(math.floor((a+math.pi/8)/(math.pi/4))%8)+1]
end
if containerFolder then
    for _,o in ipairs(containerFolder:GetDescendants()) do addRecord(o) end
    listen(containerFolder.DescendantAdded,function(o)
        if o:IsA("Model") then
            task.defer(function()if running and o:IsDescendantOf(containerFolder) then addRecord(o) end end)
        elseif o:IsA("BasePart") then
            local n=o.Parent
            while n and n~=containerFolder do
                if n:IsA("Model") and rarityFor(n.Name) then addRecord(n);break end
                n=n.Parent
            end
        end
    end)
    listen(containerFolder.DescendantRemoving,function(o)if records[o] then removeRecord(o) end end)
end
local function tickContainers()
    local found={}
    local liveCount,cacheCount=0,0
    for model,rec in pairs(records) do
        if model.Parent and rec.part.Parent then
            rec.dist=distanceTo(center(rec))
            rec.tagDist.Text=string.format("%.0f %s",rec.dist,L("distance"))
            rec.rd.Text=string.format("%.0f",rec.dist)
            table.insert(found,rec)
            liveCount=liveCount+1
        else
            removeRecord(model)
        end
    end
    local now=os.clock()
    local forgetList={}
    for _,known in pairs(knownLocations) do
        local live=known.active and records[known.active] ~= nil
        known.dist=distanceTo(known.pos)
        if live then
            known.nearSince=nil
            known.missingSince=nil
            known.lastSeen=now
        else
            -- Only check actual absence once the player has remained nearby
            -- long enough for local streaming to catch up.
            if known.dist<CACHE_VERIFY_RADIUS then
                known.nearSince=known.nearSince or now
            else
                known.nearSince=nil
            end
            local old=(now-known.lastSeen)>CACHE_TTL_SECONDS
            local confirmedAbsent=known.nearSince and
                (now-known.nearSince)>CACHE_VERIFY_SECONDS
            if old or confirmedAbsent then
                table.insert(forgetList,known)
            end
        end
        if not live and not (known.nearSince and (now-known.nearSince)>CACHE_VERIFY_SECONDS)
            and (now-known.lastSeen)<=CACHE_TTL_SECONDS then
            known.row.Visible=true
            cacheTag(known,true)
            known.tagDist.Text=string.format("%.0f %s • %s",known.dist,L("distance"),L("lastSeen"))
            known.rd.Text=string.format("%.0f",known.dist)
            table.insert(found,known)
            cacheCount=cacheCount+1
        else
            known.row.Visible=false
            cacheTag(known,false)
        end
    end
    for _,known in ipairs(forgetList) do forgetKnown(known) end
    table.sort(found,function(a,b)
        if a.rarity.rank~=b.rarity.rank then return a.rarity.rank>b.rarity.rank end
        if a.isCache~=b.isCache then return not a.isCache end
        return a.dist<b.dist
    end)
    conHeader.Text=string.format(L("found"),#found,liveCount,cacheCount)
    emptyLabel.Visible=#found==0
    for i,rec in ipairs(found) do
        rec.row.LayoutOrder=i
        rec.row.BackgroundColor3=(rec==selected) and P().panel or P().row
        rec.track.TextColor3=(rec==selected) and P().accent or P().text
    end
    conList.CanvasSize=UDim2.fromOffset(0,#found*51+12)
    if selected and (selected.isCache or (selected.model and selected.model.Parent)) then
        local pos=selected.isCache and selected.pos or center(selected)
        nav.Text=string.format("%s  %s%s  |  %.0f %s",arrowTo(pos),selected.rarity[prefs.lang],
            selected.isCache and (" ["..L("lastSeen").."]") or "",distanceTo(pos),L("distance"))
        nav.TextColor3=selected.rarity.color
        nav.Visible=root.Visible
    else
        selected=nil;nav.Visible=false
    end
end

local function tickStatus()
    if notice and os.clock()<noticeUntil then
        status.Text=notice
    else
        notice=nil
        status.Text=(not containerFolder) and L("notFound") or L("notif")
    end
    aucState.Text=prefs.auctionMode=="off" and L("auctionModeOff") or L(auctionStatus)
    aucTelemetry.Text=auctionTelemetry
end
local function stop()
    if not running then return end
    running=false
    prefs.auctionMode="off"
    prefs.noclip=false
    stopFly();stopNoclip()
    for hum,speed in pairs(originalWalkSpeeds) do
        if hum and hum.Parent then pcall(function() hum.WalkSpeed=speed end) end
    end
    for _,c in ipairs(connections) do pcall(function()c:Disconnect()end) end
    local keys={}
    for model in pairs(records) do table.insert(keys,model) end
    for _,model in ipairs(keys) do removeRecord(model) end
    for _,entry in pairs(knownLocations) do
        for _,c in ipairs(entry.conns) do pcall(function()c:Disconnect()end) end
        if entry.row then entry.row:Destroy() end
        if entry.board then entry.board:Destroy() end
    end
    if knownRoot then knownRoot:Destroy() end
    if ui then ui:Destroy() end
    if env.__PaporotnicHub_Stop==stop then env.__PaporotnicHub_Stop=nil end
end
env.__PaporotnicHub_Stop=stop
running=true
refresh()
applyWalk()
task.spawn(function()
    while running and ui.Parent do
        local ok,err=pcall(function()
            tickContainers()
            tickStatus()
        end)
        if not ok then warn("[Paporotnic Hub v8] "..tostring(err)) end
        task.wait(.35)
    end
end)
listen(RunService.RenderStepped,function()
    if running and ui.Parent and prefs.auctionMode~="off" then
        local ok,err=pcall(auctionTick)
        if not ok then
            warn("[Paporotnic Hub v8] Auction: "..tostring(err))
            auctionStatus="auctionNoBar"
        end
    end
end)
print("[Paporotnic Hub v8.0] Loaded. Menu key: "..prefs.menuKey)
