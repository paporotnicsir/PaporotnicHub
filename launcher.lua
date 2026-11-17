-- PAPOROTNIC HUB | universal launcher prototype v0.1.0
-- Initial catalog auth mode is PUBLIC (testing only). It is NOT a key system.
-- To enable key verification later: deploy an HTTPS /verify backend and set
-- catalog.auth.mode = "server" and catalog.auth.verifyUrl = its HTTPS URL.
-- Never sell access based on public client-side checks.

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
    version = "0.1.0 (offline catalog)",
    latestVersion = "Paporotnic Hub Core v0.1.0",
    lifetimePrice = "Уточняется / TBA",
    announcement = "Каталог на GitHub ещё не опубликован или временно недоступен.",
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
        catalog = data
        catalogOk = true
    end
end

local strings = {
    ru = {
        home="ГЛАВНАЯ", games="ИГРЫ", settings="НАСТРОЙКИ", title="PAPOROTNIC HUB",
        welcome="Добро пожаловать в Paporotnic Hub", status="АКТУАЛЬНАЯ ВЕРСИЯ",
        price="LIFETIME-КЛЮЧ", news="НОВОСТИ", login="АКТИВАЦИЯ", key="Введите ключ доступа",
        enter="АКТИВИРОВАТЬ", noBackend="Тестовый режим: ключи пока не включены.",
        secure="Доступ по ключу обязателен.", unauth="Сначала активируй ключ.",
        activated="Ключ подтверждён!", invalid="Ключ не принят.", verifyFail="Проверка недоступна.",
        authNeedServer="Сервер проверки ключей ещё не настроен.", current="ТЕКУЩАЯ ИГРА",
        other="ДРУГАЯ ИГРА", start="ЗАПУСТИТЬ", unsupported="Игра не опознана. Открой нужный плейс Roblox.",
        unavailable="Модуль временно отключён.", badUrl="Небезопасная ссылка на модуль.",
        loading="Загрузка игрового модуля...", loaded="Модуль запущен.", loadFail="Не удалось запустить модуль: ",
        lang="Язык: Русский / English", hide="Скрыть окно: F7", footer="Paporotnic Hub • Universal Launcher",
        note="Новые игры добавляются через catalog.json на GitHub.",
        exit="ЗАКРЫТЬ LAUNCHER", offline="Показан встроенный каталог (сеть недоступна).",
        later="Ключи появятся после подключения сервера проверки.",
        noGames="Пока нет доступных игр"
    },
    en = {
        home="HOME", games="GAMES", settings="SETTINGS", title="PAPOROTNIC HUB",
        welcome="Welcome to Paporotnic Hub", status="LATEST VERSION",
        price="LIFETIME KEY", news="ANNOUNCEMENTS", login="ACTIVATE", key="Enter access key",
        enter="ACTIVATE", noBackend="Preview access: keys are not enabled yet.",
        secure="A valid key is required.", unauth="Activate your key first.",
        activated="Key accepted!", invalid="Key was rejected.", verifyFail="Verification is unavailable.",
        authNeedServer="Key verification server is not configured.", current="CURRENT GAME",
        other="OTHER GAME", start="LOAD SCRIPT", unsupported="Wrong game. Open the supported Roblox place.",
        unavailable="Module currently disabled.", badUrl="Untrusted module URL.",
        loading="Loading game module...", loaded="Module loaded.", loadFail="Module failed: ",
        lang="Language: Русский / English", hide="Toggle window: F7", footer="Paporotnic Hub • Universal Launcher",
        note="Add new games via GitHub catalog.json.",
        exit="UNLOAD LAUNCHER", offline="Using built-in catalog (remote catalog unavailable).",
        later="Keys can be enabled when a verification backend is deployed.",
        noGames="No games yet"
    }
}
local lang = "ru"
local function T(k) return (strings[lang] or strings.ru)[k] or k end
local uiConnections = {}
local alive = true
local authenticated = catalog.auth.mode == "public"
local authMode = catalog.auth.mode or "public"
local selectedTab = "home"
local statusText = ""
local screen, root, content, statusLabel, titleLabel

local palette = {
    background=Color3.fromRGB(14,20,28), panel=Color3.fromRGB(26,36,46),
    card=Color3.fromRGB(31,43,55), highlight=Color3.fromRGB(60,225,174),
    text=Color3.fromRGB(237,248,255), muted=Color3.fromRGB(156,180,196),
    border=Color3.fromRGB(57,78,92), alert=Color3.fromRGB(252,158,118)
}
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
    return create("UIPadding", {PaddingLeft=UDim.new(0,x), PaddingRight=UDim.new(0,x),
        PaddingTop=UDim.new(0,y), PaddingBottom=UDim.new(0,y)}, parent)
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
    return create("UIListLayout", {Padding=UDim.new(0,spacing or 8), SortOrder=Enum.SortOrder.LayoutOrder},parent)
end
local function card(parent, height)
    local x=create("Frame", {Size=UDim2.new(1,-10,0,height), BorderSizePixel=0,
        BackgroundColor3=palette.panel},parent)
    corner(x,10)
    pad(x,14,12)
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
    info("Проверка... / Verifying...")
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
        if launched then info(T("loaded")); screen.Enabled=false
        else info(T("loadFail")..tostring(err),true) end
    end)
end
local function renderHome()
    clearPage()
    local sc=create("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=4,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.new(0,0,0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y
    },content)
    stack(sc,11)
    local heading=txt(sc,T("welcome"),20,palette.text,39)
    heading.Font=Enum.Font.GothamBold
    local versionCard=card(sc,76)
    txt(versionCard,T("status"),11,palette.muted,20).Position=UDim2.fromOffset(0,0)
    local l=txt(versionCard,catalog.latestVersion or catalog.version or "—",17,palette.highlight,30)
    l.Position=UDim2.fromOffset(0,22)
    l.Font=Enum.Font.GothamBold
    local priceCard=card(sc,65)
    txt(priceCard,T("price"),11,palette.muted,20).Position=UDim2.fromOffset(0,0)
    local price=txt(priceCard,catalog.lifetimePrice or "TBA",19,palette.text,30)
    price.Position=UDim2.fromOffset(0,20)
    price.Font=Enum.Font.GothamBold
    local announcement=card(sc,75)
    txt(announcement,T("news"),11,palette.muted,19).Position=UDim2.fromOffset(0,0)
    local news=txt(announcement,catalog.announcement or "—",13,palette.text,40)
    news.Position=UDim2.fromOffset(0,20)
    local keyCard=card(sc,114)
    txt(keyCard,T("login"),12,palette.muted,20).Position=UDim2.fromOffset(0,0)
    local actions=create("Frame",{
        Position=UDim2.fromOffset(0,26),Size=UDim2.new(1,0,0,38),BackgroundTransparency=1
    },keyCard)
    local keyBox=create("TextBox",{
        Size=UDim2.new(1,-144,0,35),Position=UDim2.fromOffset(0,0),
        ClearTextOnFocus=false,Text="",PlaceholderText=T("key"),
        Font=Enum.Font.Gotham,TextSize=13,TextColor3=palette.text,
        PlaceholderColor3=palette.muted,BackgroundColor3=palette.card,BorderSizePixel=0
    },actions)
    corner(keyBox,8)
    local submit=button(actions,T("enter"),135,35,function() verifyKey(keyBox.Text) end,true)
    submit.Position=UDim2.new(1,-135,0,0)
    local message=authMode=="public" and T("noBackend") or T("secure")
    txt(keyCard,message,11,palette.muted,26).Position=UDim2.fromOffset(0,69)
    if not catalogOk then txt(sc,T("offline"),11,palette.alert,22) end
end
local function renderGames()
    clearPage()
    local heading=txt(content,T("games"),20,palette.text,36)
    heading.Font=Enum.Font.GothamBold
    local scroll=create("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-48),Position=UDim2.fromOffset(0,45),
        BackgroundTransparency=1,ScrollBarThickness=4,BorderSizePixel=0,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y
    },content)
    stack(scroll,12)
    for _,item in ipairs(catalog.games or {}) do
        if type(item)=="table" then
            local row=card(scroll,118)
            local thumb=create("ImageLabel",{
                Position=UDim2.fromOffset(1,9),Size=UDim2.fromOffset(82,82),
                BackgroundColor3=palette.card,BorderSizePixel=0,
                Image=(type(item.universeId)=="number") and
                    ("rbxthumb://type=GameIcon&id="..item.universeId.."&w=150&h=150") or ""
            },row)
            corner(thumb,9)
            local x=98
            local title=txt(row,item.title or "Unknown",16,palette.text,27)
            title.Position=UDim2.fromOffset(x,0)
            title.Size=UDim2.new(1,-101,0,27)
            local desc=txt(row,item.description or "",11,palette.muted,33)
            desc.Position=UDim2.fromOffset(x,29)
            desc.Size=UDim2.new(1,-101,0,33)
            local gameState = isSupported(item) and T("current") or T("other")
            local marker=txt(row,gameState.." • "..tostring(item.version or ""),11,
                isSupported(item) and palette.highlight or palette.muted,19)
            marker.Position=UDim2.fromOffset(x,60)
            marker.Size=UDim2.new(1,-122,0,19)
            local startBtn=button(row,T("start"),116,29,function() launch(item) end,isSupported(item))
            startBtn.Position=UDim2.new(1,-116,1,-29)
        end
    end
end
local function renderSettings()
    clearPage()
    txt(content,T("settings"),20,palette.text,38).Font=Enum.Font.GothamBold
    local b=button(content,T("lang"),220,40,function()
        lang=lang=="ru" and "en" or "ru"
        if titleLabel then titleLabel.Text=T("title") end
        info("")
        -- redraw page and navigation
        selectedTab="settings"
        task.defer(function() if alive then renderSettings() end end)
    end,false)
    b.Position=UDim2.fromOffset(0,55)
    local hint=txt(content,T("hide"),13,palette.muted,35)
    hint.Position=UDim2.fromOffset(0,107)
    local exit=button(content,T("exit"),220,39,function()
        if global.__PaporotnicLauncherStop then global.__PaporotnicLauncherStop() end
    end,false)
    exit.Position=UDim2.fromOffset(0,157)
    local note=txt(content,T("note"),13,palette.muted,60)
    note.Position=UDim2.fromOffset(0,217)
end
local function render()
    if not alive or not content then return end
    if selectedTab=="games" then renderGames()
    elseif selectedTab=="settings" then renderSettings()
    else renderHome() end
end

screen=create("ScreenGui",{
    Name="PaporotnicUniversalLauncher",ResetOnSpawn=false,IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1000
},playerGui)
root=create("Frame",{
    Position=UDim2.new(.5,-300,.5,-245),Size=UDim2.fromOffset(600,490),
    Active=true,BackgroundColor3=palette.background,BorderSizePixel=0
},screen)
corner(root,12)
create("UIStroke",{Thickness=1,Color=palette.border},root)
local top=create("Frame",{
    Size=UDim2.new(1,0,0,54),Active=true,BackgroundColor3=palette.panel,
    BorderSizePixel=0
},root)
corner(top,12)
titleLabel=txt(top,T("title"),19,palette.highlight,50)
titleLabel.Font=Enum.Font.GothamBold
titleLabel.Position=UDim2.fromOffset(16,2)
titleLabel.Size=UDim2.new(1,-106,0,50)
local collapse=button(top,"—",33,33,function() screen.Enabled=not screen.Enabled end)
collapse.Position=UDim2.new(1,-79,0,10)
local settings=button(top,"⚙",33,33,function() selectedTab="settings"; render() end)
settings.TextSize=20
settings.Position=UDim2.new(1,-42,0,10)
local tabs=create("Frame",{Position=UDim2.fromOffset(16,66),Size=UDim2.new(1,-32,0,39),BackgroundTransparency=1},root)
local homeButton=button(tabs,"HOME / ГЛАВНАЯ",170,35,function() selectedTab="home";render() end)
local gamesButton=button(tabs,"GAMES / ИГРЫ",170,35,function() selectedTab="games";render() end)
gamesButton.Position=UDim2.fromOffset(181,0)
content=create("Frame",{Position=UDim2.fromOffset(18,110),Size=UDim2.new(1,-36,1,-167),BackgroundTransparency=1},root)
statusLabel=txt(root,"",12,palette.highlight,39)
statusLabel.Position=UDim2.new(0,18,1,-50)
statusLabel.Size=UDim2.new(1,-36,0,40)

-- Draggable header
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging=false
    end
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
print("[Paporotnic Universal Launcher] v0.1.0 | PlaceId="..tostring(game.PlaceId))
