-- PAPOROTNIC HUB | universal launcher prototype v0.2.1
-- UI enlarged, fern background, Releases tab, top auth card.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
if not localPlayer then return end
local playerGui = localPlayer:WaitForChild("PlayerGui")
local global = ((type(getgenv) == "function") and getgenv()) or _G

if type(global.__PaporotnicLauncherStop) == "function" then
    pcall(global.__PaporotnicLauncherStop)
end

local BASE = "https://raw.githubusercontent.com/paporotnicsir/PaporotnicHub/refs/heads/main/"
local CATALOG_URL = BASE .. "catalog.json"
local FALLBACK = {
    version = "0.2.1 (offline catalog)",
    latestVersion = "Paporotnic Hub Core v0.2.1",
    lifetimePrice = "$ ?? / TBA",
    announcement = "Welcome, LIL Paporotnics! The universal hub is online.",
    releases = {
        {title = "v0.2.0", body = "Bigger launcher UI, fern background, Releases tab, and top activation block."},
        {title = "v0.1.0", body = "Initial universal launcher prototype with Games and Settings."},
    },
    auth = { mode = "public", verifyUrl = "" },
    games = {
        {
            id = "disassemble_car_tycoon", title = "Disassemble Car Tycoon",
            description = "Containers ESP, TP, Movement, Auction, Configs",
            version = "v9.0", placeIds = {89472775643845},
            universeId = 10537055421, enabled = true,
            script = BASE .. "hub.lua"
        }
    }
}

local catalog = FALLBACK
local catalogOk = false
local ok, response = pcall(function() return game:HttpGet(CATALOG_URL) end)
if ok and type(response) == "string" then
    local parsedOk, data = pcall(function() return HttpService:JSONDecode(response) end)
    if parsedOk and type(data) == "table" and type(data.games) == "table" and type(data.auth) == "table" then
        if type(data.releases) ~= "table" then data.releases = FALLBACK.releases end
        catalog = data
        catalogOk = true
    end
end

local strings = {
    ru = {
        searchHint="Поиск игры...", noSearchResults="Игры по запросу не найдены",
        home="ГЛАВНАЯ", games="ИГРЫ", releases="РЕЛИЗЫ", settings="НАСТРОЙКИ", title="PAPOROTNIC HUB",
        welcome="Welcome, LIL Paporotnics!", heroSub="One hub for your scripts, updates, and supported games.",
        status="АКТУАЛЬНАЯ ВЕРСИЯ", price="LIFETIME-КЛЮЧ", news="НОВОСТИ", login="АКТИВАЦИЯ",
        key="Введите ключ доступа", enter="АКТИВИРОВАТЬ", noBackend="Тестовый режим: ключи пока не включены.",
        secure="Доступ по ключу обязателен.", unauth="Сначала активируй ключ.",
        activated="Ключ подтверждён!", invalid="Ключ не принят.", verifyFail="Проверка недоступна.",
        authNeedServer="Сервер проверки ключей ещё не настроен.", current="ТЕКУЩАЯ ИГРА",
        other="ДРУГАЯ ИГРА", start="ЗАПУСТИТЬ", unsupported="Игра не опознана. Открой нужный плейс Roblox.",
        unavailable="Модуль временно отключён.", badUrl="Небезопасная ссылка на модуль.",
        loading="Загрузка игрового модуля...", loaded="Модуль запущен.", loadFail="Не удалось запустить модуль: ",
        lang="Язык: Русский / English", hide="Показать / скрыть окно: F7", footer="Paporotnic Hub • Universal Launcher",
        note="Новые игры добавляются через catalog.json на GitHub.", exit="ЗАКРЫТЬ LAUNCHER",
        offline="Показан встроенный каталог (сеть недоступна).", later="Ключи появятся после подключения сервера проверки.",
        noGames="Пока нет доступных игр", supported="ПОДДЕРЖИВАЕМЫЕ ИГРЫ", releaseTitle="ПОСЛЕДНИЕ РЕЛИЗЫ",
        releaseSub="Новости и изменения Paporotnic Hub", totalGames="Игр в каталоге", authState="Статус доступа",
        accessPublic="PUBLIC / TEST", accessGranted="Ключ активирован", accessNeed="Ожидает ключ"
    },
    en = {
        searchHint="Search games...", noSearchResults="No matching games",
        home="HOME", games="GAMES", releases="RELEASES", settings="SETTINGS", title="PAPOROTNIC HUB",
        welcome="Welcome, LIL Paporotnics!", heroSub="One hub for your scripts, updates, and supported games.",
        status="LATEST VERSION", price="LIFETIME KEY", news="ANNOUNCEMENTS", login="ACTIVATION",
        key="Enter access key", enter="ACTIVATE", noBackend="Preview access: keys are not enabled yet.",
        secure="A valid key is required.", unauth="Activate your key first.",
        activated="Key accepted!", invalid="Key was rejected.", verifyFail="Verification is unavailable.",
        authNeedServer="Key verification server is not configured.", current="CURRENT GAME",
        other="OTHER GAME", start="LOAD SCRIPT", unsupported="Wrong game. Open the supported Roblox place.",
        unavailable="Module currently disabled.", badUrl="Untrusted module URL.",
        loading="Loading game module...", loaded="Module loaded.", loadFail="Module failed: ",
        lang="Language: Русский / English", hide="Toggle window: F7", footer="Paporotnic Hub • Universal Launcher",
        note="Add new games via GitHub catalog.json.", exit="UNLOAD LAUNCHER",
        offline="Using built-in catalog (remote catalog unavailable).", later="Keys can be enabled when a verification backend is deployed.",
        noGames="No games yet", supported="SUPPORTED GAMES", releaseTitle="LATEST RELEASES",
        releaseSub="News and changes for Paporotnic Hub", totalGames="Games in catalog", authState="Access status",
        accessPublic="PUBLIC / TEST", accessGranted="Key activated", accessNeed="Awaiting key"
    }
}
local lang = "en"
local function T(k) return (strings[lang] or strings.en)[k] or k end

local palette = {
    background=Color3.fromRGB(12,18,24), panel=Color3.fromRGB(24,33,42),
    card=Color3.fromRGB(30,42,52), highlight=Color3.fromRGB(86,228,170),
    text=Color3.fromRGB(240,248,255), muted=Color3.fromRGB(157,181,196),
    border=Color3.fromRGB(55,82,91), alert=Color3.fromRGB(252,158,118),
    fern=Color3.fromRGB(72,130,94), fern2=Color3.fromRGB(101,161,118)
}

local uiConnections = {}
local alive = true
local authenticated = catalog.auth.mode == "public"
local authMode = catalog.auth.mode or "public"
local selectedTab = "home"
local statusText = ""
local screen, root, content, statusLabel, titleLabel
local tabs = {}

local function connect(signal, cb)
    local c = signal:Connect(cb)
    table.insert(uiConnections, c)
    return c
end
local function create(class, props, parent)
    local x = Instance.new(class)
    for k,v in pairs(props or {}) do x[k] = v end
    x.Parent = parent
    return x
end
local function corner(target, radius)
    return create("UICorner", {CornerRadius=UDim.new(0,radius or 10)}, target)
end
local function pad(parent, x, y)
    return create("UIPadding", {PaddingLeft=UDim.new(0,x), PaddingRight=UDim.new(0,x), PaddingTop=UDim.new(0,y), PaddingBottom=UDim.new(0,y)}, parent)
end
local function txt(parent, value, size, color, height, align)
    return create("TextLabel", {
        Size=UDim2.new(1,0,0,height or 28), BackgroundTransparency=1,
        Font=Enum.Font.Gotham, TextColor3=color or palette.text,
        Text= tostring(value or ""), TextSize=size or 14,
        TextXAlignment=align or Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center, TextWrapped=true
    }, parent)
end
local function button(parent, label, width, height, click, accent)
    local b = create("TextButton", {
        Size=UDim2.fromOffset(width or 145,height or 35), BackgroundColor3=accent and palette.highlight or palette.card,
        BorderSizePixel=0, Font=Enum.Font.GothamBold,
        TextColor3=accent and palette.background or palette.text,
        TextSize=13, Text=label, AutoButtonColor=true
    }, parent)
    corner(b,8)
    if click then connect(b.MouseButton1Click,click) end
    return b
end
local function stack(parent, spacing)
    return create("UIListLayout", {Padding=UDim.new(0,spacing or 8), SortOrder=Enum.SortOrder.LayoutOrder}, parent)
end
local function card(parent, height)
    local x=create("Frame", {Size=UDim2.new(1,-10,0,height), BorderSizePixel=0, BackgroundColor3=palette.panel, BackgroundTransparency=0.05},parent)
    corner(x,12)
    pad(x,16,14)
    create("UIStroke", {Thickness=1, Color=palette.border, Transparency=0.25}, x)
    return x
end
local function clearPage()
    for _,child in ipairs(content:GetChildren()) do child:Destroy() end
end
local function info(text, warning)
    statusText=tostring(text or "")
    if statusLabel then
        statusLabel.Text=statusText
        statusLabel.TextColor3 = warning and palette.alert or palette.highlight
    end
end
local function isSupported(gameRow)
    if type(gameRow) ~= "table" or type(gameRow.placeIds) ~= "table" then return false end
    for _,id in ipairs(gameRow.placeIds) do
        if tonumber(id) == game.PlaceId then return true end
    end
    return false
end
local function trustedUrl(url)
    return type(url)=="string" and url:sub(1,#BASE)==BASE and not url:find("%.%./")
end
local function verifyKey(key)
    local auth = catalog.auth or {}
    if authMode == "public" then
        info(T("later"),true)
        return
    end
    if authMode ~= "server" or type(auth.verifyUrl) ~= "string" or not auth.verifyUrl:match("^https://") then
        info(T("authNeedServer"),true)
        return
    end
    local requester = (syn and syn.request) or http_request or request
    if type(requester) ~= "function" then info(T("verifyFail"),true) return end
    if #key < 4 or #key > 128 then info(T("invalid"),true) return end
    info("Verifying...")
    task.spawn(function()
        local success, result = pcall(function()
            return requester({
                Url = auth.verifyUrl, Method = "POST",
                Headers = {["Content-Type"]="application/json"},
                Body = HttpService:JSONEncode({key=key})
            })
        end)
        if not alive then return end
        if not success or type(result) ~= "table" then info(T("verifyFail"),true) return end
        local code = tonumber(result.StatusCode or result.Status)
        if code ~= 200 then info(T("verifyFail"),true) return end
        local parseOK, data = pcall(function() return HttpService:JSONDecode(result.Body or "") end)
        if parseOK and type(data)=="table" and data.valid == true then
            authenticated=true
            info(T("activated"))
            if selectedTab == "home" then task.defer(function() if alive then selectedTab = "home"; render() end end) end
        else
            authenticated=false
            info(T("invalid"),true)
        end
    end)
end
local function launch(row)
    if not authenticated then info(T("unauth"),true); return end
    if not isSupported(row) then info(T("unsupported"),true); return end
    if row.enabled == false then info(T("unavailable"),true); return end
    if not trustedUrl(row.script) then info(T("badUrl"),true); return end
    info(T("loading"))
    task.spawn(function()
        local fetched, code = pcall(function() return game:HttpGet(row.script) end)
        if not alive then return end
        if not fetched or type(code)~="string" then info(T("loadFail")..tostring(code),true); return end
        if type(loadstring)~="function" then info(T("loadFail").."loadstring unavailable",true); return end
        local buildOK, fn = pcall(function() return loadstring(code) end)
        if not buildOK or type(fn)~="function" then info(T("loadFail")..tostring(fn),true); return end
        local launched,err=pcall(fn)
        if not alive then return end
        if launched then info(T("loaded")); screen.Enabled=false else info(T("loadFail")..tostring(err),true) end
    end)
end

function render() end

local function renderHome()
    clearPage()
    local sc=create("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=4,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.new(0,0,0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y
    },content)
    stack(sc,12)

    local hero=card(sc,130)
    local welcome=txt(hero,T("welcome"),28,palette.text,38)
    welcome.Font=Enum.Font.GothamBold
    welcome.Position=UDim2.fromOffset(0,0)
    local sub=txt(hero,T("heroSub"),14,palette.muted,36)
    sub.Position=UDim2.fromOffset(0,42)
    local stats=create("Frame",{Position=UDim2.fromOffset(0,82), Size=UDim2.new(1,0,0,30), BackgroundTransparency=1}, hero)
    txt(stats, T("totalGames")..": "..tostring(#(catalog.games or {})), 13, palette.highlight, 24).Position = UDim2.fromOffset(0,0)
    local access = authMode == "public" and T("accessPublic") or (authenticated and T("accessGranted") or T("accessNeed"))
    local accessLbl = txt(stats, T("authState")..": "..access, 13, authenticated and palette.highlight or palette.muted, 24)
    accessLbl.Position = UDim2.new(0.48,0,0,0)

    local keyCard=card(sc,112)
    txt(keyCard,T("login"),12,palette.muted,20).Position=UDim2.fromOffset(0,0)
    local actions=create("Frame",{Position=UDim2.fromOffset(0,28),Size=UDim2.new(1,0,0,38),BackgroundTransparency=1},keyCard)
    local keyBox=create("TextBox",{
        Size=UDim2.new(1,-170,0,38),Position=UDim2.fromOffset(0,0),
        ClearTextOnFocus=false,Text="",PlaceholderText=T("key"),
        Font=Enum.Font.Gotham,TextSize=14,TextColor3=palette.text,
        PlaceholderColor3=palette.muted,BackgroundColor3=palette.card,BorderSizePixel=0
    },actions)
    corner(keyBox,8)
    local submit=button(actions,T("enter"),160,38,function() verifyKey(keyBox.Text) end,true)
    submit.Position=UDim2.new(1,-160,0,0)
    local message=authMode=="public" and T("noBackend") or T("secure")
    local m=txt(keyCard,message,12,palette.muted,28)
    m.Position=UDim2.fromOffset(0,72)

    local infoRow=create("Frame",{Size=UDim2.new(1,-10,0,150), BackgroundTransparency=1}, sc)
    local versionCard=card(infoRow,150)
    versionCard.Size = UDim2.new(0.5,-6,1,0)
    local priceCard=card(infoRow,150)
    priceCard.Position = UDim2.new(0.5,6,0,0)
    priceCard.Size = UDim2.new(0.5,-6,1,0)

    txt(versionCard,T("status"),11,palette.muted,18).Position=UDim2.fromOffset(0,0)
    local l=txt(versionCard,catalog.latestVersion or catalog.version or "—",20,palette.highlight,45)
    l.Position=UDim2.fromOffset(0,18)
    l.Font=Enum.Font.GothamBold
    local ann=txt(versionCard,T("news")..": "..(catalog.announcement or "—"),12,palette.text,50)
    ann.Position=UDim2.fromOffset(0,78)
    ann.TextYAlignment=Enum.TextYAlignment.Top

    txt(priceCard,T("price"),11,palette.muted,18).Position=UDim2.fromOffset(0,0)
    local price=txt(priceCard,catalog.lifetimePrice or "TBA",24,palette.text,45)
    price.Position=UDim2.fromOffset(0,18)
    price.Font=Enum.Font.GothamBold
    local note=txt(priceCard,T("note"),12,palette.muted,52)
    note.Position=UDim2.fromOffset(0,82)
    note.TextYAlignment=Enum.TextYAlignment.Top

    local rel=card(sc,120)
    txt(rel,T("releaseTitle"),12,palette.muted,20).Position=UDim2.fromOffset(0,0)
    local latest = (catalog.releases and catalog.releases[1]) or {title = catalog.version or "v0.2.0", body = catalog.announcement or "—"}
    local rt = txt(rel, tostring(latest.title or "—"), 20, palette.highlight, 28)
    rt.Font = Enum.Font.GothamBold
    rt.Position = UDim2.fromOffset(0,24)
    local rb = txt(rel, tostring(latest.body or "—"), 13, palette.text, 56)
    rb.Position = UDim2.fromOffset(0,58)
    rb.TextYAlignment = Enum.TextYAlignment.Top

    if not catalogOk then txt(sc,T("offline"),11,palette.alert,22) end
end

local function renderGames()
    clearPage()
    local heading=txt(content,T("supported"),22,palette.text,38)
    heading.Font=Enum.Font.GothamBold
    heading.Size=UDim2.new(1,-348,0,38)

    -- Filter the currently loaded catalog without re-downloading it.
    local searchBox=create("TextBox",{
        Position=UDim2.new(1,-330,0,1), Size=UDim2.fromOffset(330,38),
        BackgroundColor3=palette.card, BorderSizePixel=0,
        ClearTextOnFocus=false, Text="", PlaceholderText="⌕  "..T("searchHint"),
        Font=Enum.Font.Gotham, TextSize=14,
        TextColor3=palette.text, PlaceholderColor3=palette.muted,
        TextXAlignment=Enum.TextXAlignment.Left
    },content)
    corner(searchBox,9)
    create("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},searchBox)
    create("UIStroke",{Thickness=1,Color=palette.border,Transparency=0.2},searchBox)

    local scroll=create("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-48),Position=UDim2.fromOffset(0,45),
        BackgroundTransparency=1,ScrollBarThickness=4,BorderSizePixel=0,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y
    },content)
    stack(scroll,12)
    if not catalog.games or #catalog.games == 0 then
        txt(scroll,T("noGames"),14,palette.muted,28)
        return
    end
    local rows={}
    for _,item in ipairs(catalog.games or {}) do
        if type(item)=="table" then
            local row=card(scroll,130)
            local thumb=create("ImageLabel",{
                Position=UDim2.fromOffset(4,10),Size=UDim2.fromOffset(92,92),
                BackgroundColor3=palette.card,BorderSizePixel=0,
                Image=(type(item.universeId)=="number") and ("rbxthumb://type=GameIcon&id="..item.universeId.."&w=150&h=150") or ""
            },row)
            corner(thumb,12)
            local x=110
            local title=txt(row,item.title or "Unknown",18,palette.text,28)
            title.Font=Enum.Font.GothamBold
            title.Position=UDim2.fromOffset(x,0)
            title.Size=UDim2.new(1,-116,0,28)
            local desc=txt(row,item.description or "",12,palette.muted,34)
            desc.Position=UDim2.fromOffset(x,30)
            desc.Size=UDim2.new(1,-116,0,34)
            local gameState = isSupported(item) and T("current") or T("other")
            local marker=txt(row,gameState.." • "..tostring(item.version or ""),12, isSupported(item) and palette.highlight or palette.muted,19)
            marker.Position=UDim2.fromOffset(x,68)
            marker.Size=UDim2.new(1,-134,0,19)
            local startBtn=button(row,T("start"),140,34,function() launch(item) end,isSupported(item))
            startBtn.Position=UDim2.new(1,-140,1,-34)
            table.insert(rows, {frame=row, searchText=string.lower(table.concat({
                tostring(item.title or ""), tostring(item.description or ""),
                tostring(item.id or "")
            }, " "))})
        end
    end
    local noResults=txt(scroll,T("noSearchResults"),14,palette.muted,36)
    noResults.Visible=false
    local function applySearch()
        local query=string.lower(searchBox.Text):gsub("^%s+", ""):gsub("%s+$", "")
        local count=0
        for _,entry in ipairs(rows) do
            local matches=(query=="") or (string.find(entry.searchText, query, 1, true) ~= nil)
            entry.frame.Visible=matches
            if matches then count=count+1 end
        end
        noResults.Visible=(count==0)
    end
    connect(searchBox:GetPropertyChangedSignal("Text"),applySearch)
    applySearch()
end

local function renderReleases()
    clearPage()
    local heading=txt(content,T("releaseTitle"),22,palette.text,36)
    heading.Font=Enum.Font.GothamBold
    local sub=txt(content,T("releaseSub"),13,palette.muted,24)
    sub.Position=UDim2.fromOffset(0,32)
    local scroll=create("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-64),Position=UDim2.fromOffset(0,60),
        BackgroundTransparency=1,ScrollBarThickness=4,BorderSizePixel=0,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y
    },content)
    stack(scroll,12)
    for _,rel in ipairs(catalog.releases or FALLBACK.releases) do
        local row=card(scroll,110)
        local t=txt(row,tostring(rel.title or "—"),20,palette.highlight,28)
        t.Font=Enum.Font.GothamBold
        t.Position=UDim2.fromOffset(0,0)
        local b=txt(row,tostring(rel.body or rel.description or "—"),13,palette.text,58)
        b.Position=UDim2.fromOffset(0,34)
        b.TextYAlignment=Enum.TextYAlignment.Top
    end
end

local function renderSettings()
    clearPage()
    local heading=txt(content,T("settings"),22,palette.text,38)
    heading.Font=Enum.Font.GothamBold
    local b=button(content,T("lang"),260,42,function()
        lang=lang=="ru" and "en" or "ru"
        if titleLabel then titleLabel.Text=T("title") end
        task.defer(function() if alive then render() end end)
    end,false)
    b.Position=UDim2.fromOffset(0,55)
    local hint=txt(content,T("hide"),13,palette.muted,30)
    hint.Position=UDim2.fromOffset(0,110)
    local exit=button(content,T("exit"),260,42,function()
        if global.__PaporotnicLauncherStop then global.__PaporotnicLauncherStop() end
    end,false)
    exit.Position=UDim2.fromOffset(0,150)
    local note=txt(content,T("note"),13,palette.muted,60)
    note.Position=UDim2.fromOffset(0,210)
    note.TextYAlignment=Enum.TextYAlignment.Top
end

function render()
    if not alive or not content then return end
    if selectedTab=="games" then renderGames()
    elseif selectedTab=="releases" then renderReleases()
    elseif selectedTab=="settings" then renderSettings()
    else renderHome() end
end

screen=create("ScreenGui",{
    Name="PaporotnicUniversalLauncher",ResetOnSpawn=false,IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1000
},playerGui)
root=create("Frame",{
    Position=UDim2.new(.5,-490,.5,-360),Size=UDim2.fromOffset(980,720),
    Active=true,BackgroundColor3=palette.background,BorderSizePixel=0, ClipsDescendants=true
},screen)
corner(root,16)
create("UIStroke",{Thickness=1,Color=palette.border},root)

local bg=create("Frame",{Size=UDim2.new(1,0,1,0), BackgroundTransparency=1}, root)
for i = 1, 22 do
    local fern=create("TextLabel", {
        Size=UDim2.fromOffset(80,80),
        Position=UDim2.new(math.random(), math.random(-30, 0), math.random(), math.random(-30, 0)),
        BackgroundTransparency=1,
        Text=(i % 2 == 0) and "🌿" or "🍃",
        Font=Enum.Font.GothamBlack,
        TextScaled=true,
        Rotation=math.random(-35,35),
        TextTransparency=0.72,
        TextColor3=(i % 2 == 0) and palette.fern or palette.fern2,
        ZIndex=0
    }, bg)
end

local top=create("Frame",{
    Size=UDim2.new(1,0,0,60),Active=true,BackgroundColor3=palette.panel,
    BorderSizePixel=0, BackgroundTransparency=0.08
},root)
corner(top,16)
titleLabel=txt(top,T("title"),22,palette.highlight,56)
titleLabel.Font=Enum.Font.GothamBold
titleLabel.Position=UDim2.fromOffset(18,2)
titleLabel.Size=UDim2.new(1,-120,0,56)
local collapse=button(top,"—",36,36,function() screen.Enabled=not screen.Enabled end)
collapse.Position=UDim2.new(1,-84,0,12)
local settings=button(top,"⚙",36,36,function() selectedTab="settings"; render() end)
settings.TextSize=20
settings.Position=UDim2.new(1,-42,0,12)

local tabWrap=create("Frame",{Position=UDim2.fromOffset(18,74),Size=UDim2.new(1,-36,0,42),BackgroundTransparency=1},root)
local homeButton=button(tabWrap,T("home"),150,38,function() selectedTab="home"; render() end)
local gamesButton=button(tabWrap,T("games"),150,38,function() selectedTab="games"; render() end)
gamesButton.Position=UDim2.fromOffset(160,0)
local releasesButton=button(tabWrap,T("releases"),150,38,function() selectedTab="releases"; render() end)
releasesButton.Position=UDim2.fromOffset(320,0)

tabs.home, tabs.games, tabs.releases = homeButton, gamesButton, releasesButton

content=create("Frame",{Position=UDim2.fromOffset(24,126),Size=UDim2.new(1,-48,1,-184),BackgroundTransparency=1},root)
statusLabel=txt(root,"",12,palette.highlight,34)
statusLabel.Position=UDim2.new(0,24,1,-52)
statusLabel.Size=UDim2.new(1,-48,0,34)
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

local footer=txt(root,T("footer"),12,palette.muted,18,Enum.TextXAlignment.Center)
footer.Position = UDim2.new(0,24,1,-24)
footer.Size = UDim2.new(1,-48,0,18)

local dragging,dragStart,startPos=false,nil,nil
connect(top.InputBegan,function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true;dragStart=input.Position;startPos=root.Position
    end
end)
connect(UIS.InputChanged,function(input)
    if not dragging or not dragStart or not startPos then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta=input.Position-dragStart
        root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)
connect(UIS.InputEnded,function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging=false end
end)
connect(UIS.InputBegan,function(input,processed)
    if processed or UIS:GetFocusedTextBox() then return end
    if input.KeyCode==Enum.KeyCode.F7 then screen.Enabled=not screen.Enabled end
end)

local function stop()
    if not alive then return end
    alive=false
    for _,c in ipairs(uiConnections) do pcall(function() c:Disconnect() end) end
    if screen then screen:Destroy() end
    if global.__PaporotnicLauncherStop==stop then global.__PaporotnicLauncherStop=nil end
end
global.__PaporotnicLauncherStop=stop
render()
if not catalogOk then info(T("offline"),true) end
print("[Paporotnic Universal Launcher] v0.2.1 | PlaceId="..tostring(game.PlaceId))
