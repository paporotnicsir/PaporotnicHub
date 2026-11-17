-- PAPOROTNIC HUB | universal launcher prototype v0.2.13
-- Bigger launcher, releases, search, and smoothly drifting fern-sticker background.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
if not localPlayer then return end
local playerGui = localPlayer:WaitForChild("PlayerGui")
local global = ((type(getgenv) == "function") and getgenv()) or _G

if type(global.__PaporotnicLauncherStop) == "function" then
    pcall(global.__PaporotnicLauncherStop)
end

local BASE = "https://raw.githubusercontent.com/paporotnicsir/PaporotnicHub/refs/heads/main/"
local CATALOG_URL = BASE .. "catalog.json"
local SPLASH_FERN_URL = BASE .. "assets/fern_sticker.png"
local LOCAL_SPLASH_FERN_PATH = "PaporotnicHub/assets/fern_sticker.png"
local HUB_FERN_URL = BASE .. "assets/hub_fern_leaf.png"
local LOCAL_HUB_FERN_PATH = "PaporotnicHub/assets/hub_fern_leaf.png"
local FALLBACK = {
    version = "0.2.13 (offline catalog)",
    latestVersion = "Paporotnic Hub Core v0.2.8",
    lifetimePrice = "$ ?? / TBA",
    announcement = "Welcome, LIL Paporotnics! The universal hub is online.",
    releases = {
        {title = "v0.2.0", body = "Bigger launcher UI, fern background, Releases tab, and top activation block."},
        {title = "v0.1.0", body = "Initial universal launcher prototype with Games and Settings."},
    },
    -- Each major release owns its smaller patches. This preview entry can be
    -- removed from catalog.json when the official changelog is published.
    releaseGroups = {
        {
            id = "release-020", version = "v0.2.0", name = "Launcher redesign",
            summary = "Larger interface, fern background and a dedicated Releases page.",
            updates = {
                {version = "v0.2.13", title = "New hub fern icon",
                 body = "The in-hub background now uses a new minimal green leaf, while the splash keeps the outlined fern.",
                 bodyRu = "Фон внутри хаба теперь использует новый минималистичный зелёный лист, а заставка сохраняет старый папоротник с белой обводкой."},
                {version = "v0.2.12", title = "Splash border visibility fix",
                 body = "The launcher outline now stays hidden until the startup animation is fully complete.",
                 bodyRu = "Рамка окна скрыта во время заставки и появляется только после завершения перехода."},
                {version = "v0.2.11", title = "Smooth diagonal fern movement",
                 body = "The whole fern grid glides slowly down-right with seamless wraparound and no random motion.",
                 bodyRu = "Вся сетка папоротников плавно движется вниз-вправо, без рандома и рывков на краях."},
                {version = "v0.2.10", title = "Visible game behind splash",
                 body = "Splash now uses a truly translucent backdrop and lightly blurs the game behind it.",
                 bodyRu = "Теперь за полупрозрачной заставкой видно игру, немного размытую на время запуска."},
                {version = "v0.2.9", title = "Intro transparency and faster typing",
                 body = "Semi-transparent startup overlay and faster title typing.",
                 bodyRu = "Полупрозрачный фон заставки и ускоренная печать названия."},
                {version = "v0.2.8", title = "Themes and animated launch intro",
                 body = "Added four color themes in Settings and an animated fern splash with typewriter title.",
                 bodyRu = "Добавлены четыре темы оформления и плавная заставка с папоротником и печатающимся названием."},
                {version = "v0.2.7", title = "TEST: expandable release notes",
                 body = "If this test entry is visible, you have loaded the updated launcher. Tap the release header to collapse or expand these notes.",
                 bodyRu = "Если видишь это тестовое обновление, загрузился новый launcher.lua. Нажми заголовок релиза, чтобы свернуть или раскрыть список."},
                {version = "v0.2.6", title = "Fern background adjustments",
                 body = "Static fern layout: the background no longer uses falling animations.",
                 bodyRu = "Статичный фон из папоротников без анимации падения."},
                {version = "v0.2.1", title = "Game search",
                 body = "Added a search field to the Games tab.",
                 bodyRu = "Добавлен поиск по списку игр."},
            }
        },
        {
            id = "release-010", version = "v0.1.0", name = "First launcher",
            summary = "Universal launcher with Home, Games and Settings.",
            updates = {}
        }
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
        -- New format is optional: keep the built-in grouped history until
        -- catalog.json provides its own releaseGroups array.
        if type(data.releaseGroups) ~= "table" then data.releaseGroups = FALLBACK.releaseGroups end
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
        accessPublic="PUBLIC / TEST", accessGranted="Ключ активирован", accessNeed="Ожидает ключ",
        patches="ПОДОБНОВЛЕНИЙ", expandedHint="Нажми на релиз, чтобы увидеть изменения",
        releaseBuild="СБОРКА ЛАУНЧЕРА: v0.2.13 (TEST)",
        themeHeading="ТЕМА ОФОРМЛЕНИЯ", themeHint="Изменения применяются сразу. Сохранение работает, если исполнитель поддерживает запись файлов.",
        themeForest="ЛЕСНАЯ", themeOcean="НОЧНОЙ ОКЕАН", themeEmber="ЗАКАТ", themeViolet="ФИОЛЕТОВАЯ", themeActive="ВЫБРАНО"
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
        accessPublic="PUBLIC / TEST", accessGranted="Key activated", accessNeed="Awaiting key",
        patches="PATCHES", expandedHint="Click a release to view its updates",
        releaseBuild="LAUNCHER BUILD: v0.2.13 (TEST)",
        themeHeading="COLOR THEME", themeHint="Themes apply instantly. Saving needs executor file access.",
        themeForest="FOREST", themeOcean="NIGHT OCEAN", themeEmber="SUNSET", themeViolet="VIOLET", themeActive="ACTIVE"
    }
}
local lang = "en"
local function T(k) return (strings[lang] or strings.en)[k] or k end

-- Themes recolor existing GUI elements instantly; the original fern PNG stays green.
local themes = {
    forest = {
        background=Color3.fromRGB(12,18,24), panel=Color3.fromRGB(24,33,42),
        card=Color3.fromRGB(30,42,52), highlight=Color3.fromRGB(86,228,170),
        text=Color3.fromRGB(240,248,255), muted=Color3.fromRGB(157,181,196),
        border=Color3.fromRGB(55,82,91), alert=Color3.fromRGB(252,158,118),
        fern=Color3.fromRGB(103,153,84), fern2=Color3.fromRGB(131,186,108),
        fernShadow=Color3.fromRGB(41,60,39)
    },
    ocean = {
        background=Color3.fromRGB(10,17,29), panel=Color3.fromRGB(20,32,49),
        card=Color3.fromRGB(28,46,66), highlight=Color3.fromRGB(88,199,255),
        text=Color3.fromRGB(236,247,255), muted=Color3.fromRGB(150,180,205),
        border=Color3.fromRGB(60,91,125), alert=Color3.fromRGB(255,162,132),
        fern=Color3.fromRGB(103,153,84), fern2=Color3.fromRGB(131,186,108),
        fernShadow=Color3.fromRGB(41,60,39)
    },
    ember = {
        background=Color3.fromRGB(24,15,20), panel=Color3.fromRGB(42,25,31),
        card=Color3.fromRGB(57,36,43), highlight=Color3.fromRGB(255,155,112),
        text=Color3.fromRGB(255,243,237), muted=Color3.fromRGB(199,169,169),
        border=Color3.fromRGB(117,70,73), alert=Color3.fromRGB(255,206,108),
        fern=Color3.fromRGB(103,153,84), fern2=Color3.fromRGB(131,186,108),
        fernShadow=Color3.fromRGB(41,60,39)
    },
    violet = {
        background=Color3.fromRGB(18,15,29), panel=Color3.fromRGB(31,26,49),
        card=Color3.fromRGB(44,36,65), highlight=Color3.fromRGB(197,158,255),
        text=Color3.fromRGB(247,242,255), muted=Color3.fromRGB(186,169,212),
        border=Color3.fromRGB(90,74,128), alert=Color3.fromRGB(255,155,175),
        fern=Color3.fromRGB(103,153,84), fern2=Color3.fromRGB(131,186,108),
        fernShadow=Color3.fromRGB(41,60,39)
    }
}
local themeOrder = {"forest", "ocean", "ember", "violet"}
local settingsPath = "PaporotnicHub/preferences.json"
local themeName = "forest"
do
    if type(readfile)=="function" then
        local success, body = pcall(readfile, settingsPath)
        if success and type(body)=="string" then
            local parsed, saved = pcall(function() return HttpService:JSONDecode(body) end)
            if parsed and type(saved)=="table" then
                if type(saved.theme)=="string" and themes[saved.theme] then themeName=saved.theme end
                if saved.language=="ru" or saved.language=="en" then lang=saved.language end
            end
        end
    end
end
local palette = {}
for key,color in pairs(themes[themeName]) do palette[key]=color end
local themeBindings = setmetatable({}, {__mode="k"})
local function savePreferences()
    if type(writefile)~="function" then return end
    if type(makefolder)=="function" then pcall(makefolder,"PaporotnicHub") end
    pcall(writefile, settingsPath, HttpService:JSONEncode({theme=themeName,language=lang}))
end

local uiConnections = {}
local alive = true
local authenticated = catalog.auth.mode == "public"
local authMode = catalog.auth.mode or "public"
local selectedTab = "home"
local statusText = ""
local screen, root, content, statusLabel, titleLabel, footerLabel

local function connect(signal, cb)
    local c = signal:Connect(cb)
    table.insert(uiConnections, c)
    return c
end
local function create(class, props, parent)
    local x = Instance.new(class)
    local tracked = nil
    for k,v in pairs(props or {}) do
        x[k] = v
        -- Remember which colors belong to the active theme so we can recolor
        -- the whole GUI without destroying it or restarting the intro.
        if typeof(v)=="Color3" then
            for paletteKey,currentColor in pairs(palette) do
                if v==currentColor then
                    tracked = tracked or {}
                    tracked[k] = paletteKey
                    break
                end
            end
        end
    end
    x.Parent = parent
    if tracked then themeBindings[x]=tracked end
    return x
end
local function setTheme(name)
    if not themes[name] or name==themeName then return end
    themeName=name
    for key,color in pairs(themes[name]) do palette[key]=color end
    for object, properties in pairs(themeBindings) do
        if object.Parent then
            for property, paletteKey in pairs(properties) do
                pcall(function() object[property]=palette[paletteKey] end)
            end
        end
    end
    savePreferences()
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

local function getCustomAsset(path)
    local fn = getsynasset or getcustomasset or ((syn and syn.asset) and syn.asset)
    if type(fn) == "function" then
        local ok, asset = pcall(fn, path)
        if ok then return asset end
    end
    return nil
end

local function ensureAsset(url, localPath)
    local existing = nil
    if type(isfile) == "function" and isfile(localPath) then
        existing = getCustomAsset(localPath)
        if existing then return existing end
    end
    if type(makefolder) == "function" then
        pcall(makefolder, "PaporotnicHub")
        pcall(makefolder, "PaporotnicHub/assets")
    end
    if type(writefile) == "function" then
        local okData, data = pcall(function() return game:HttpGet(url) end)
        if okData and type(data) == "string" and #data > 100 then
            pcall(writefile, localPath, data)
            if type(isfile) == "function" and isfile(localPath) then
                return getCustomAsset(localPath)
            end
        end
    end
    return nil
end

local function ensureSplashFernAsset()
    return ensureAsset(SPLASH_FERN_URL, LOCAL_SPLASH_FERN_PATH)
end

local function ensureHubFernAsset()
    return ensureAsset(HUB_FERN_URL, LOCAL_HUB_FERN_PATH)
end

local function verifyKey(key)
    local auth = catalog.auth or {}
    if authMode == "public" then info(T("later"),true); return end
    if authMode ~= "server" or type(auth.verifyUrl) ~= "string" or not auth.verifyUrl:match("^https://") then info(T("authNeedServer"),true); return end
    local requester = (syn and syn.request) or http_request or request
    if type(requester) ~= "function" then info(T("verifyFail"),true) return end
    if #key < 4 or #key > 128 then info(T("invalid"),true) return end
    info("Verifying...")
    task.spawn(function()
        local success, result = pcall(function()
            return requester({Url = auth.verifyUrl, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body = HttpService:JSONEncode({key=key})})
        end)
        if not alive then return end
        if not success or type(result) ~= "table" then info(T("verifyFail"),true) return end
        local code = tonumber(result.StatusCode or result.Status)
        if code ~= 200 then info(T("verifyFail"),true) return end
        local parseOK, data = pcall(function() return HttpService:JSONDecode(result.Body or "") end)
        if parseOK and type(data)=="table" and data.valid == true then
            authenticated=true
            info(T("activated"))
            task.defer(function() if alive then render() end end)
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

local function createMagnifier(parent, pos)
    local holder = create("Frame", {BackgroundTransparency=1, Size=UDim2.fromOffset(18,18), Position=pos}, parent)
    local ring = create("Frame", {
        Size=UDim2.fromOffset(11,11), Position=UDim2.fromOffset(0,0), AnchorPoint=Vector2.new(0,0),
        BackgroundTransparency=1, BorderSizePixel=0
    }, holder)
    corner(ring, 99)
    create("UIStroke", {Thickness=2, Color=palette.muted, Transparency=0.08}, ring)
    local handle = create("Frame", {
        Size=UDim2.fromOffset(7,2), Position=UDim2.fromOffset(9,11),
        Rotation=45, BackgroundColor3=palette.muted, BorderSizePixel=0
    }, holder)
    corner(handle, 99)
    return holder
end

local function createFernSticker(parent, z, fernAsset)
    if fernAsset then
        local img = create("ImageLabel", {
            Size = UDim2.fromOffset(210, 255),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = fernAsset,
            ScaleType = Enum.ScaleType.Fit,
            ImageTransparency = 0.40,
            Visible = false, -- positioned before showing the continuous drift
            ZIndex = z or 0,
            Rotation = -22
        }, parent)
        return img
    end

    local holder = create("Frame", {
        Size = UDim2.fromOffset(210, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = z or 0,
        Rotation = math.random(-25,25)
    }, parent)

    local shadow = create("Frame", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(2,3), ZIndex = (z or 0)
    }, holder)
    local sticker = create("Frame", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
        ZIndex = (z or 0)+1
    }, holder)

    local function leaflet(container, size, pos, rot, color, zIndex)
        local leaf = create("Frame", {
            AnchorPoint = Vector2.new(0.5,0.5), Size = size, Position = pos,
            Rotation = rot, BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = zIndex
        }, container)
        corner(leaf, 99)
        create("UIStroke", {Thickness=2, Color=Color3.fromRGB(255,255,255), Transparency=0.03}, leaf)
        return leaf
    end
    local function stem(container, color, zIndex)
        local line = create("Frame", {
            AnchorPoint = Vector2.new(0.5,0), Position = UDim2.new(0.5,0,0.12,0), Size = UDim2.new(0,5,0.72,0),
            BackgroundColor3 = color, BorderSizePixel = 0, Rotation = -8, ZIndex = zIndex
        }, container)
        corner(line, 99)
        create("UIStroke", {Thickness=2, Color=Color3.fromRGB(255,255,255), Transparency=0.04}, line)
    end

    stem(shadow, palette.fernShadow, (z or 0))
    stem(sticker, (math.random() > 0.5) and palette.fern or palette.fern2, (z or 0)+1)

    for i = 1, 8 do
        local y = 0.16 + (i-1) * 0.082
        local w = 0.16 + (8-i) * 0.010
        local h = 0.08 + (8-i) * 0.004
        leaflet(shadow, UDim2.new(w,0,h,0), UDim2.new(0.36,0,y,0), -38, palette.fernShadow, (z or 0))
        leaflet(shadow, UDim2.new(w,0,h,0), UDim2.new(0.66,0,y+0.01,0), 36, palette.fernShadow, (z or 0))
        leaflet(sticker, UDim2.new(w,0,h,0), UDim2.new(0.38,0,y,0), -38, (i%2==0) and palette.fern or palette.fern2, (z or 0)+1)
        leaflet(sticker, UDim2.new(w,0,h,0), UDim2.new(0.64,0,y+0.01,0), 36, (i%2==1) and palette.fern or palette.fern2, (z or 0)+1)
    end
    local tip = create("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.52,0,0.08,0), Size = UDim2.new(0.16,0,0.10,0),
        Rotation = -8, BackgroundColor3 = palette.fern2, BorderSizePixel = 0, ZIndex = (z or 0)+1
    }, sticker)
    corner(tip, 99)
    create("UIStroke", {Thickness=2, Color=Color3.fromRGB(255,255,255), Transparency=0.04}, tip)

    return holder
end

-- Continuously drifting diagonal lattice. Its exact starting grid is the
-- previous 5x4 layout; all ferns share the same down-right translation.
-- Edge copies make the pattern seamless when a leaf crosses any side.
-- No random positions, staggered spawns, or independent tweens.
local function startDiagonalFernField(parent, asset)
    if not asset then
        warn("[Paporotnic] Missing hub fern asset. Upload assets/hub_fern_leaf.png to GitHub.")
        return
    end

    local RunService = game:GetService("RunService")
    local columns, rows = 5, 4
    local speedX, speedY = 16, 24 -- pixels/second: gentle downward-right drift
    local marginX, marginY = 155, 170 -- larger than rotated sprite half-bounds
    local offsetX, offsetY = 0, 0
    local ferns = {}

    for row = 0, rows - 1 do
        for column = 0, columns - 1 do
            local copies = {}
            for i = 1, 4 do
                local fern = createFernSticker(parent, 0, asset)
                fern.AnchorPoint = Vector2.new(0.5, 0.5)
                fern.Rotation = -22
                fern.ImageTransparency = 0.48
                fern.Visible = false
                copies[i] = fern
            end
            ferns[#ferns + 1] = {row = row, column = column, copies = copies}
        end
    end

    local function place(fern, x, y, visible)
        if visible then
            fern.Position = UDim2.fromOffset(x, y)
        end
        fern.Visible = visible
    end

    local function positionAll()
        local width, height = parent.AbsoluteSize.X, parent.AbsoluteSize.Y
        if width < 1 or height < 1 then return end
        for _, entry in ipairs(ferns) do
            -- Preserve the original alternating-row diagonal grid precisely.
            local x = ((((entry.column + 0.5 + (entry.row % 2) * 0.5) / columns) * width) + offsetX) % width
            local y = ((((entry.row + 0.5) / rows) * height) + offsetY) % height

            -- Show mirror copies only near an edge, so passing the opposite
            -- edge never creates a visible jump or an empty border.
            local ghostX, ghostY = nil, nil
            if x < marginX then ghostX = x + width
            elseif x > width - marginX then ghostX = x - width end
            if y < marginY then ghostY = y + height
            elseif y > height - marginY then ghostY = y - height end

            local copies = entry.copies
            place(copies[1], x, y, true)
            place(copies[2], ghostX or 0, y, ghostX ~= nil)
            place(copies[3], x, ghostY or 0, ghostY ~= nil)
            place(copies[4], ghostX or 0, ghostY or 0, ghostX ~= nil and ghostY ~= nil)
        end
    end

    positionAll() -- fill the whole canvas before the intro reveals the hub
    connect(RunService.RenderStepped, function(dt)
        if not alive or not parent.Parent then return end
        local width, height = parent.AbsoluteSize.X, parent.AbsoluteSize.Y
        if width < 1 or height < 1 then return end
        dt = math.min(dt, 0.1)
        offsetX = (offsetX + speedX * dt) % width
        offsetY = (offsetY + speedY * dt) % height
        positionAll()
    end)
end

function render() end

local function renderHome()
    clearPage()
    local sc=create("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
        AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0), ScrollingDirection=Enum.ScrollingDirection.Y
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
        Size=UDim2.new(1,-170,0,38),Position=UDim2.fromOffset(0,0), ClearTextOnFocus=false,Text="",
        PlaceholderText=T("key"), Font=Enum.Font.Gotham,TextSize=14,TextColor3=palette.text,
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

    local searchWrap=create("Frame",{
        Position=UDim2.new(1,-330,0,1), Size=UDim2.fromOffset(330,38),
        BackgroundColor3=palette.card, BorderSizePixel=0
    },content)
    corner(searchWrap,9)
    create("UIStroke",{Thickness=1,Color=palette.border,Transparency=0.2},searchWrap)
    createMagnifier(searchWrap, UDim2.fromOffset(11,10))
    local searchBox=create("TextBox",{
        Position=UDim2.fromOffset(34,0), Size=UDim2.new(1,-42,1,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ClearTextOnFocus=false, Text="", PlaceholderText=T("searchHint"),
        Font=Enum.Font.Gotham, TextSize=14,
        TextColor3=palette.text, PlaceholderColor3=palette.muted,
        TextXAlignment=Enum.TextXAlignment.Left
    },searchWrap)

    local scroll=create("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-48),Position=UDim2.fromOffset(0,45),
        BackgroundTransparency=1,ScrollBarThickness=4,BorderSizePixel=0,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y
    },content)
    stack(scroll,12)
    if not catalog.games or #catalog.games == 0 then txt(scroll,T("noGames"),14,palette.muted,28); return end

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
            table.insert(rows, {frame=row, searchText=string.lower(table.concat({tostring(item.title or ""), tostring(item.description or ""), tostring(item.id or "")}, " "))})
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
    local sub=txt(content,T("expandedHint"),13,palette.muted,24)
    sub.Position=UDim2.fromOffset(0,34)
    local scroll=create("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-95),Position=UDim2.fromOffset(0,60),
        BackgroundTransparency=1,ScrollBarThickness=4,BorderSizePixel=0,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y
    },content)
    stack(scroll,12)

    -- Catalog format: releaseGroups = [{id, version, name, summary,
    -- updates = [{version, title, body, bodyRu?}, ...]}, ...]
    local groups = catalog.releaseGroups or FALLBACK.releaseGroups
    for _, group in ipairs(groups) do
        if type(group) == "table" then
            local changes = type(group.updates) == "table" and group.updates or {}
            local groupId = tostring(group.id or group.version or group.name or "release")
            local opened = (global.__PaporotnicReleaseExpanded or {})[groupId] == true
            local row = card(scroll,74)
            row.ClipsDescendants = true
            local head = create("TextButton",{
                Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,56),
                BorderSizePixel=0,BackgroundTransparency=1,Text="",
                AutoButtonColor=false
            },row)
            local releaseTitle = txt(head,
                tostring(group.version or "—").."  |  "..tostring(group.name or ""),
                18,palette.highlight,27)
            releaseTitle.Font=Enum.Font.GothamBold
            releaseTitle.Position=UDim2.fromOffset(4,0)
            releaseTitle.Size=UDim2.new(1,-56,0,27)
            local summary=txt(head,tostring(group.summary or ""),12,palette.muted,23)
            summary.Position=UDim2.fromOffset(4,28)
            summary.Size=UDim2.new(1,-68,0,23)
            -- Draw the arrow using GUI shapes so Roblox fonts cannot replace it
            -- with a missing-character square.
            local arrow = create("Frame", {
                Position=UDim2.new(1,-40,0,13),Size=UDim2.fromOffset(25,25),
                BackgroundTransparency=1,Rotation=opened and 90 or 0
            },head)
            for _,v in ipairs({{x=7,y=7,angle=45},{x=7,y=15,angle=-45}}) do
                local stroke=create("Frame",{
                    Position=UDim2.fromOffset(v.x,v.y),Size=UDim2.fromOffset(13,2),
                    Rotation=v.angle,BackgroundColor3=palette.highlight,BorderSizePixel=0
                },arrow)
                corner(stroke,3)
            end

            local changeList=create("Frame",{
                Position=UDim2.fromOffset(0,64),Size=UDim2.new(1,-2,0,0),
                BackgroundTransparency=1,Visible=opened
            },row)
            local function updateLayout()
                local changeHeight = #changes * 85
                row.Size = UDim2.new(1,-10,0,opened and (76 + changeHeight) or 74)
                arrow.Rotation = opened and 90 or 0
                changeList.Visible=opened
                changeList.Size=UDim2.new(1,-2,0,changeHeight)
            end
            for n, patch in ipairs(changes) do
                local item=create("Frame",{
                    Position=UDim2.fromOffset(3,(n-1)*85),Size=UDim2.new(1,-8,0,79),
                    BackgroundColor3=palette.card,BorderSizePixel=0
                },changeList)
                corner(item,8)
                local label=txt(item,tostring(patch.version or "").."   "..tostring(patch.title or ""),
                    13,palette.highlight,22)
                label.Font=Enum.Font.GothamBold
                label.Position=UDim2.fromOffset(12,7)
                label.Size=UDim2.new(1,-24,0,22)
                local bodyText=(lang=="ru" and patch.bodyRu) or patch.body or ""
                local description=txt(item,tostring(bodyText),12,palette.text,45)
                description.Position=UDim2.fromOffset(12,29)
                description.Size=UDim2.new(1,-24,0,45)
                description.TextYAlignment=Enum.TextYAlignment.Top
            end
            updateLayout()
            connect(head.MouseButton1Click,function()
                opened = not opened
                global.__PaporotnicReleaseExpanded = global.__PaporotnicReleaseExpanded or {}
                global.__PaporotnicReleaseExpanded[groupId] = opened
                updateLayout()
            end)
        end
    end
    local buildLabel=txt(content,T("releaseBuild"),12,palette.highlight,25,
        Enum.TextXAlignment.Right)
    buildLabel.Position=UDim2.new(0,0,1,-27)
    buildLabel.Size=UDim2.new(1,-6,0,25)
end

local function renderSettings()
    clearPage()
    local heading=txt(content,T("settings"),22,palette.text,38)
    heading.Font=Enum.Font.GothamBold
    local b=button(content,T("lang"),260,42,function()
        lang=lang=="ru" and "en" or "ru"
        savePreferences()
        if titleLabel then titleLabel.Text=T("title") end
        if footerLabel then footerLabel.Text=T("footer") end
        task.defer(function() if alive then render() end end)
    end,false)
    b.Position=UDim2.fromOffset(0,53)

    local themeHeading=txt(content,T("themeHeading"),16,palette.text,27)
    themeHeading.Font=Enum.Font.GothamBold
    themeHeading.Position=UDim2.fromOffset(0,118)
    for index,name in ipairs(themeOrder) do
        local theme = themes[name]
        local isSelected = (name==themeName)
        local label = T("theme"..name:sub(1,1):upper()..name:sub(2))
        local tile=create("TextButton",{
            Position=UDim2.fromOffset((index-1)*228,153), Size=UDim2.fromOffset(214,74),
            Text="",BorderSizePixel=0,AutoButtonColor=true,
            BackgroundColor3=palette.panel
        },content)
        corner(tile,11)
        create("UIStroke",{
            Thickness=isSelected and 2 or 1,
            Color=isSelected and palette.highlight or palette.border,
            Transparency=isSelected and 0 or 0.35
        },tile)
        local swatch=create("Frame",{
            Position=UDim2.fromOffset(13,14),Size=UDim2.fromOffset(18,18),
            BackgroundColor3=theme.highlight,BorderSizePixel=0
        },tile)
        corner(swatch,5)
        local nameLabel=txt(tile,label,13,palette.text,24)
        nameLabel.Font=Enum.Font.GothamBold
        nameLabel.Position=UDim2.fromOffset(40,11)
        nameLabel.Size=UDim2.new(1,-49,0,26)
        local selection=txt(tile,isSelected and T("themeActive") or "",11,palette.highlight,20)
        selection.Position=UDim2.fromOffset(13,44)
        selection.Size=UDim2.new(1,-25,0,20)
        connect(tile.MouseButton1Click,function()
            setTheme(name)
            if alive then render() end
        end)
    end
    local themeHint=txt(content,T("themeHint"),12,palette.muted,44)
    themeHint.Position=UDim2.fromOffset(0,235)
    themeHint.TextYAlignment=Enum.TextYAlignment.Top
    local hint=txt(content,T("hide"),13,palette.muted,30)
    hint.Position=UDim2.fromOffset(0,285)
    local exit=button(content,T("exit"),260,42,function()
        if global.__PaporotnicLauncherStop then global.__PaporotnicLauncherStop() end
    end,false)
    exit.Position=UDim2.fromOffset(0,327)
    local note=txt(content,T("note"),13,palette.muted,60)
    note.Position=UDim2.fromOffset(0,380)
    note.TextYAlignment=Enum.TextYAlignment.Top
end

function render()
    if not alive or not content then return end
    if selectedTab=="games" then renderGames()
    elseif selectedTab=="releases" then renderReleases()
    elseif selectedTab=="settings" then renderSettings()
    else renderHome() end
end

screen=create("ScreenGui",{Name="PaporotnicUniversalLauncher",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1000},playerGui)
root=create("CanvasGroup",{Position=UDim2.new(.5,-490,.5,-360),Size=UDim2.fromOffset(980,720),Active=true,BackgroundColor3=palette.background,BorderSizePixel=0,ClipsDescendants=true,GroupTransparency=1},screen)
corner(root,16)
-- CanvasGroup.GroupTransparency does not reliably hide a UIStroke attached to
-- the group itself. Keep the window border fully hidden during the splash.
local rootStroke=create("UIStroke",{Thickness=1,Color=palette.border,Transparency=1,Enabled=false},root)

local bg=create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true},root)
local splashFernAsset = ensureSplashFernAsset()
local hubFernAsset = ensureHubFernAsset()
startDiagonalFernField(bg, hubFernAsset or splashFernAsset)

local top=create("Frame",{Size=UDim2.new(1,0,0,60),Active=true,BackgroundColor3=palette.panel,BorderSizePixel=0,BackgroundTransparency=0.08},root)
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

content=create("Frame",{Position=UDim2.fromOffset(24,126),Size=UDim2.new(1,-48,1,-184),BackgroundTransparency=1},root)
statusLabel=txt(root,"",12,palette.highlight,34)
statusLabel.Position=UDim2.new(0,24,1,-52)
statusLabel.Size=UDim2.new(1,-48,0,34)
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

footerLabel=txt(root,T("footer"),12,palette.muted,18,Enum.TextXAlignment.Center)
footerLabel.Position = UDim2.new(0,24,1,-24)
footerLabel.Size = UDim2.new(1,-48,0,18)

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

local introBlur = nil
local function stop()
    if not alive then return end
    alive=false
    if introBlur then
        pcall(function() introBlur:Destroy() end)
        introBlur = nil
    end
    for _,c in ipairs(uiConnections) do pcall(function() c:Disconnect() end) end
    if screen then screen:Destroy() end
    if global.__PaporotnicLauncherStop==stop then global.__PaporotnicLauncherStop=nil end
end
global.__PaporotnicLauncherStop=stop
render()
if not catalogOk then info(T("offline"),true) end

-- Intro: a plain Frame for the backdrop. A CanvasGroup could composite the
-- whole splash into an opaque-looking dark rectangle in some Roblox clients.
-- BlurEffect softens only the game world; the fern and title stay sharp.
local function playLaunchIntro()
    local overlay=create("Frame",{
        Size=UDim2.fromScale(1,1), Position=UDim2.fromScale(0,0),
        BackgroundColor3=palette.background, BackgroundTransparency=0.62,
        BorderSizePixel=0, Active=true, ZIndex=100
    },screen)

    local Lighting=game:GetService("Lighting")
    local blur=Instance.new("BlurEffect")
    blur.Name="PaporotnicLauncherIntroBlur"
    blur.Size=0
    blur.Enabled=true
    blur.Parent=Lighting
    introBlur=blur
    TweenService:Create(blur,TweenInfo.new(0.55,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
        Size=9
    }):Play()

    local fern=create("ImageLabel",{
        Size=UDim2.fromOffset(175,224),Position=UDim2.new(0.5,0,0.47,-45),
        AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
        Image=splashFernAsset or "",ScaleType=Enum.ScaleType.Fit,
        ImageTransparency=1,Rotation=-14,ZIndex=102
    },overlay)
    local title=txt(overlay,"PAPOROTNIC HUB",30,palette.highlight,48,Enum.TextXAlignment.Center)
    title.AnchorPoint=Vector2.new(0.5,0.5)
    title.Position=UDim2.new(0.5,0,0.47,150)
    title.Size=UDim2.fromOffset(520,48)
    title.Font=Enum.Font.GothamBold
    title.MaxVisibleGraphemes=0
    title.TextTransparency=0
    title.ZIndex=102

    local bloom=TweenService:Create(fern,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
        Size=UDim2.fromOffset(250,320),ImageTransparency=0.07,Rotation=-22
    })
    bloom:Play()
    bloom.Completed:Wait()
    if not alive or not overlay.Parent then return end
    for letter=1,#"PAPOROTNIC HUB" do
        title.MaxVisibleGraphemes=letter
        task.wait(0.025)
        if not alive or not overlay.Parent then return end
    end
    task.wait(0.36)
    if not alive or not overlay.Parent then return end

    local duration=TweenInfo.new(0.85,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)
    local backdropFade=TweenService:Create(overlay,duration,{BackgroundTransparency=1})
    local fernFade=TweenService:Create(fern,duration,{ImageTransparency=1})
    local titleFade=TweenService:Create(title,duration,{TextTransparency=1})
    local blurFade=TweenService:Create(blur,duration,{Size=0})
    local hubFade=TweenService:Create(root,TweenInfo.new(0.90,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{
        GroupTransparency=0
    })
    backdropFade:Play()
    fernFade:Play()
    titleFade:Play()
    blurFade:Play()
    hubFade:Play()
    hubFade.Completed:Wait()
    if alive and root.Parent then
        root.GroupTransparency=0
        -- Only show the outline after the entire splash/reveal has finished.
        -- This prevents the thin theme-colored rectangle appearing early.
        rootStroke.Enabled=true
        TweenService:Create(rootStroke,TweenInfo.new(0.24,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
            Transparency=0
        }):Play()
    end
    if overlay.Parent then overlay:Destroy() end
    if introBlur == blur then
        blur:Destroy()
        introBlur = nil
    end
end
task.spawn(playLaunchIntro)
print("[Paporotnic Universal Launcher] v0.2.12 | PlaceId="..tostring(game.PlaceId))
