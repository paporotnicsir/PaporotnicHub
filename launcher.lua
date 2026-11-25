-- PAPOROTNIC HUB | universal launcher v0.2.28
-- 3-second loading gate, key-only entry, and quiet accent-glow interface.
-- Based on the user's v0.2.14 launcher; auth API and game module flow preserved.

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
-- Layered artwork v0.2.27. Every PNG is an independent file in assets/.
-- To display artwork in Roblox, use a Roblox uploaded Image ID, OR an executor
-- with writefile + getcustomasset / getsynasset. Without either, safe GUI fallbacks remain.
-- These files must ALSO be uploaded to this repository's assets/ directory.
local PREMIUM_ASSETS = {
    heroBanner = "",         -- optional Roblox Image ID: rbxassetid://...
    infiniteYield = "",      -- the supplied Infinite Yield logo
    infiniteYieldCard = "",  -- horizontal crop of the very same user image
    fernLogo = "",           -- isolated fern from our original design mockup
    fernCorners = "",        -- transparent fern decorations
    wallpaper = "",          -- subtle atmospheric backdrop
}
local LAYERED_FILES = {
    heroBanner = "featured-banner.png",
    infiniteYield = "infinite-yield.png",
    infiniteYieldCard = "infinite-yield-card.png",
    fernLogo = "fern-logo.png",
    fernCorners = "fern-corners.png",
    wallpaper = "dashboard-wallpaper.png",
}
local function premiumImageId(value)
    if type(value)=="number" and value > 0 then return "rbxassetid://"..tostring(math.floor(value)) end
    return type(value)=="string" and value:match("^rbxassetid://%d+$") and value or nil
end

local FALLBACK = {
    version = "0.2.28 (offline catalog)",
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
                {version = "v0.2.28", title = "Theme Editor · custom accents",
                  body = "Added editable accent colors with six presets, hex entry, a reset button and an optional foliage toggle. Preferences save locally when supported.",
                  bodyRu = "Редактор цвета акцента: шесть готовых цветов, ввод HEX, сброс к стандартному и переключатель декоративной листвы. Настройки сохраняются локально при поддержке исполнителем."},
                {version = "v0.2.27", title = "Layered Visual Fix",
                  body = "Manually separated fern artwork, exact user-provided Infinite Yield image, one real Game Library entry, and properly spaced script buttons. Added optional executor-side image loading.",
                  bodyRu = "Отдельные слои папоротника, точная картинка Infinite Yield от пользователя, одна настоящая игра в библиотеке и нормальные отступы между кнопками. Добавлена загрузка графики в поддерживаемых исполнителях."},
                {version = "v0.2.26", title = "Clean Dashboard Rework",
                  body = "Replaced the faux fern icon with a clean monogram, redesigned empty image areas as built-in premium graphics, reduced border clutter and improved layout readability.",
                  bodyRu = "Вместо неудачного значка — чистая монограмма; вместо пустых картинок — оформленные встроенные баннеры, меньше лишних рамок и лучше читаемость."},
                {version = "v0.2.25", title = "Premium Dashboard · visual fidelity",
                  body = "Screenshot-inspired dashboard with a wide featured banner, lime navigation, game tiles, universal tools, access and update rails, plus responsive scaling.",
                  bodyRu = "Главная максимально приближена к макету: большой баннер, зелёное меню, карточки игр, универсальные инструменты, доступ и обновления; адаптивный масштаб."},
                {version = "v0.2.24", title = "Home Dashboard Foundation",
                  body = "A new dashboard, sidebar navigation, featured catalog module, access summary, recent game, quick launch and changelog.",
                  bodyRu = "Новый Home Dashboard: боковое меню, главный модуль каталога, доступ, последняя игра, быстрый запуск и обновления."},
                {version = "v0.2.23", title = "Game & Universal Script categories",
                  body = "Scripts now separates game-specific modules and universal tools. Infinite Yield runs from the official EdgeIY repository after key verification.",
                  bodyRu = "Скрипты разделены на игровые и универсальные. Infinite Yield запускается из официального EdgeIY только после проверки ключа."},
                {version = "v0.2.22", title = "Recent temporary key prefill",
                  body = "The last verified temporary key is prefilled for manual activation. Remember Me remains opt-in for auto-login; Lifetime keys stay hidden by default.",
                  bodyRu = "Последний подтверждённый временный ключ подставляется для ручной активации. Автовход — только через Remember Me; Lifetime без него не сохраняется."},
                {version = "v0.2.21", title = "Optional Remember Me",
                  body = "Opt-in local session saving with a fresh server check on every startup. Switch Key clears saved access.",
                  bodyRu = "Необязательное запоминание ключа с проверкой через сервер при каждом запуске. Switch Key очищает сохранённый доступ."},
                {version = "v0.2.20", title = "Switch Key in launcher",
                  body = "Change access keys from the main hub without restarting or revoking a license.",
                  bodyRu = "Смена ключа прямо из хаба без перезапуска и блокировки лицензии."},
                {version = "v0.2.18", title = "Clean background restored",
                  body = "Removed the experimental fern border. The launcher uses a clean background and ambient panel glow.",
                  bodyRu = "Экспериментальная кайма из папоротников убрана. Возвращён чистый фон с мягкой подсветкой панелей."},
                {version = "v0.2.16", title = "Key options preview",
                  body = "Added yellow Get Key and gently shimmering green Lifetime buttons below the key activation field.",
                  bodyRu = "Добавлены жёлтая кнопка Get Key и мягко переливающаяся зелёная Lifetime под активацией ключа."},
                {version = "v0.2.15", title = "Loading and access gate redesign",
                  body = "Minimal 3-second loading panel, key-only activation, subtle ambient panel glow and a clean background.",
                  bodyRu = "Новая трёхсекундная загрузка, отдельное окно ключа, мягкая подсветка панелей и чистый фон."},
                {version = "v0.2.14", title = "Smaller hub background leaves",
                 body = "Reduced the in-hub fern-leaf size by about 17% without changing the diagonal animation.",
                 bodyRu = "Размер фоновых листьев уменьшен примерно на 17%; диагональная анимация сохранена."},
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
    auth = { mode = "server", verifyUrl = "" },
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
        dashboardFeatured="ВЫБРАННЫЙ МОДУЛЬ", dashboardWelcome="Добро пожаловать в Paporotnic Hub",
        dashboardLead="Панель управления твоими скриптами", dashboardLaunch="ЗАПУСТИТЬ МОДУЛЬ",
        dashboardBrowse="СМОТРЕТЬ ИГРЫ", dashboardRecent="НЕДАВНЯЯ ИГРА",
        dashboardDiscover="ДОСТУПНЫЕ ИГРЫ", dashboardUniversal="УНИВЕРСАЛЬНЫЕ",
        dashboardOpen="ОТКРЫТЬ РАЗДЕЛ", dashboardAccess="МОЙ ДОСТУП",
        dashboardAccessStatus="Статус", dashboardAccessType="Тип ключа", dashboardLifetime="ПОСТОЯННЫЙ",
        dashboardTemporary="ВРЕМЕННЫЙ", dashboardVerified="ПОДТВЕРЖДЁН",
        dashboardRemember="Автовход", dashboardOn="Вкл", dashboardOff="Выкл",
        dashboardServer="СЕРВЕР АВТОРИЗАЦИИ", dashboardServerChecked="Ключ проверен через VPS",
        dashboardServerNote="Это статус последней проверки, а не мониторинг 24/7.",
        dashboardUpdates="ОБНОВЛЕНИЯ", dashboardEmpty="Пока не запускались игровые модули",
        dashboardCurrent="ТЕКУЩИЙ ПЛЕЙС", dashboardOther="ИГРА В КАТАЛОГЕ",
        dashboardNoModule="Добавь игры в catalog.json, чтобы они появились здесь.",
        dashboardTip="Универсальные скрипты запускаются вручную.",
        dashboardIYInfo="Infinite Yield · EdgeIY · сторонний код",
        dashboardNavigation="НАВИГАЦИЯ", dashboardShortGames="ИГРЫ", dashboardShortUniversal="UNIVERSAL",
        dashboardShortSettings="НАСТРОЙКИ", dashboardSideAccess="ДОСТУП АКТИВЕН",
        dashboardNoRecent="Недавних запусков пока нет",
        searchHint="Поиск игры...", noSearchResults="Игры по запросу не найдены",
        scriptsGame="ИГРОВЫЕ СКРИПТЫ", scriptsUniversal="УНИВЕРСАЛЬНЫЕ",
        universalTitle="УНИВЕРСАЛЬНЫЕ СКРИПТЫ", universalSub="Инструменты, не привязанные к конкретному плейсу.",
        infiniteDesc="Админ-команды и утилиты для Roblox. Совместимость зависит от игры и исполнителя.",
        infiniteCredit="Авторы: EdgeIY и участники проекта • MIT • сторонний скрипт",
        infiniteSource="Источник: github.com/EdgeIY/infiniteyield",
        infiniteWarning="Запускается внешний код из официального репозитория. Выполняй только если доверяешь источнику.",
        infiniteLaunch="EXECUTE IY", infiniteLoading="Загружаем Infinite Yield...",
        infiniteLoaded="Infinite Yield запущен.", infiniteBusy="Уже выполняется запуск скрипта.",
        infiniteMissing="Исполнитель не поддерживает loadstring / HttpGet.",
        home="ГЛАВНАЯ", games="СКРИПТЫ", releases="РЕЛИЗЫ", settings="НАСТРОЙКИ", title="PAPOROTNIC HUB",
        switchKey="СМЕНИТЬ КЛЮЧ", switchReady="Введи другой ключ. Старый ключ остаётся действительным.",
        switchBusy="Дождись завершения проверки ключа.",
        rememberTitle="ЗАПОМНИТЬ МЕНЯ", rememberOn="ЗАПОМИНАНИЕ: ВКЛ", rememberOff="ЗАПОМИНАНИЕ: ВЫКЛ",
        rememberHint="Сохранять этот ключ и проверять его через сервер при следующем запуске.",
        rememberWarning="Внимание: ключ хранится в локальном файле без шифрования. Не включай на общем ПК.",
        rememberEnabled="Ключ сохранён. При следующем запуске проверим его через VPS.",
        rememberDisabled="Запоминание выключено. Локальный сохранённый ключ очищен.",
        rememberUnavailable="Исполнитель не поддерживает readfile/writefile. Запоминание недоступно.",
        rememberSaveError="Не удалось сохранить сессию. Запоминание осталось выключенным.",
        rememberDeleteError="Не удалось гарантированно удалить локальный ключ. Проверь файлы исполнителя.",
        rememberChecking="Проверяем сохранённый ключ через сервер...",
        recentPrefilled="Ключ подставлен. Нажми «Активировать».",
        recentForget="ЗАБЫТЬ КЛЮЧ", recentForgot="Сохранённый временный ключ удалён.",
        recentForgetError="Не удалось очистить сохранённый временный ключ.",
        recentWarning="Временные ключи сохраняются локально без шифрования для подстановки при следующем запуске. Не используй на общем ПК.",
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
        releaseBuild="СБОРКА ЛАУНЧЕРА: v0.2.28",
        themeHeading="ТЕМА ОФОРМЛЕНИЯ", themeHint="Изменения применяются сразу. Сохранение работает, если исполнитель поддерживает запись файлов.",
        themeForest="ЛЕСНАЯ", themeOcean="НОЧНОЙ ОКЕАН", themeEmber="ЗАКАТ", themeViolet="ФИОЛЕТОВАЯ", themeActive="ВЫБРАНО",
         gateSubtitle="Для доступа к хабу требуется ключ", gateIdle="Введите ключ для продолжения.",
         gateProgress="ПОДГОТОВКА ЛАУНЧЕРА", gateLoading="ЗАГРУЗКА", gateReady="ГОТОВО", gateClose="Закрыть лаунчер"
    },
    en = {
        dashboardFeatured="FEATURED MODULE", dashboardWelcome="Welcome to Paporotnic Hub",
        dashboardLead="Your scripts control center", dashboardLaunch="LAUNCH MODULE",
        dashboardBrowse="BROWSE GAMES", dashboardRecent="RECENTLY PLAYED",
        dashboardDiscover="AVAILABLE GAMES", dashboardUniversal="UNIVERSAL TOOLS",
        dashboardOpen="OPEN TOOLS", dashboardAccess="YOUR ACCESS",
        dashboardAccessStatus="Status", dashboardAccessType="Key type", dashboardLifetime="LIFETIME",
        dashboardTemporary="TEMPORARY", dashboardVerified="VERIFIED",
        dashboardRemember="Remember Me", dashboardOn="On", dashboardOff="Off",
        dashboardServer="VERIFICATION SERVER", dashboardServerChecked="Key verified by VPS",
        dashboardServerNote="Last verification only; not a live uptime monitor.",
        dashboardUpdates="LATEST UPDATES", dashboardEmpty="No game module launched yet",
        dashboardCurrent="CURRENT PLACE", dashboardOther="CATALOG GAME",
        dashboardNoModule="Add games to catalog.json to show them here.",
        dashboardTip="Third-party universal tools run only when clicked.",
        dashboardIYInfo="Infinite Yield · EdgeIY · third-party code",
        dashboardNavigation="NAVIGATION", dashboardShortGames="GAMES", dashboardShortUniversal="UNIVERSAL",
        dashboardShortSettings="SETTINGS", dashboardSideAccess="ACCESS GRANTED",
        dashboardNoRecent="No recent launches yet",
        searchHint="Search games...", noSearchResults="No matching games",
        scriptsGame="GAME SCRIPTS", scriptsUniversal="UNIVERSAL SCRIPTS",
        universalTitle="UNIVERSAL SCRIPTS", universalSub="Tools that do not target a single Roblox place.",
        infiniteDesc="Admin commands and Roblox utilities. Compatibility depends on the game and executor.",
        infiniteCredit="By EdgeIY & contributors • MIT • third-party script",
        infiniteSource="Source: github.com/EdgeIY/infiniteyield",
        infiniteWarning="Runs external code directly from the official repository. Only execute if you trust the source.",
        infiniteLaunch="EXECUTE IY", infiniteLoading="Loading Infinite Yield...",
        infiniteLoaded="Infinite Yield started.", infiniteBusy="A script is already launching.",
        infiniteMissing="Executor lacks loadstring / HttpGet support.",
        home="HOME", games="SCRIPTS", releases="RELEASES", settings="SETTINGS", title="PAPOROTNIC HUB",
        switchKey="SWITCH KEY", switchReady="Enter another key. Your previous key stays valid.",
        switchBusy="Wait until verification finishes.",
        rememberTitle="REMEMBER ME", rememberOn="REMEMBER ME: ON", rememberOff="REMEMBER ME: OFF",
        rememberHint="Save this key and verify it with the server on your next launch.",
        rememberWarning="Warning: the key is saved in an unencrypted local file. Avoid shared computers.",
        rememberEnabled="Key saved. It will be checked with the VPS at next launch.",
        rememberDisabled="Remember Me disabled. The locally saved key was cleared.",
        rememberUnavailable="This executor does not support readfile/writefile. Cannot remember keys.",
        rememberSaveError="Could not persist your session. Remember Me remains disabled.",
        rememberDeleteError="Could not fully remove the local key. Check your executor files.",
        rememberChecking="Checking saved key with server...",
        recentPrefilled="Temporary key prefilled. Press Activate.",
        recentForget="FORGET KEY", recentForgot="Saved temporary key cleared.",
        recentForgetError="Could not clear your saved temporary key.",
        recentWarning="Temporary keys are saved locally without encryption for next-launch prefill. Avoid shared computers.",
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
        releaseBuild="LAUNCHER BUILD: v0.2.28",
        themeHeading="COLOR THEME", themeHint="Themes apply instantly. Saving needs executor file access.",
        themeForest="FOREST", themeOcean="NIGHT OCEAN", themeEmber="SUNSET", themeViolet="VIOLET", themeActive="ACTIVE",
         gateSubtitle="An access key is required to continue", gateIdle="Enter your key to continue.",
         gateProgress="PREPARING LAUNCHER", gateLoading="LOADING", gateReady="READY", gateClose="Close launcher"
    }
}
local lang = "en"
local function T(k) return (strings[lang] or strings.en)[k] or k end

-- Themes recolor existing GUI elements instantly; the original fern PNG stays green.
local themes = {
    forest = {
        background=Color3.fromRGB(7,10,11), panel=Color3.fromRGB(14,18,20),
        card=Color3.fromRGB(18,27,23), highlight=Color3.fromRGB(101,244,43),
        text=Color3.fromRGB(246,251,248), muted=Color3.fromRGB(156,170,162),
        border=Color3.fromRGB(46,65,53), alert=Color3.fromRGB(255,139,150),
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
local accentSwatches = {
    {"#65F42B", "FERN"}, {"#76E8BB", "MINT"}, {"#58C7FF", "CYAN"},
    {"#C59EFF", "VIOLET"}, {"#FFB36A", "PEACH"}, {"#FF83C1", "ROSE"},
}
-- Require a bright, legible accent: the launcher draws dark text on accent buttons.
local function parseAccentHex(input)
    if type(input) ~= "string" then return nil end
    local hex=input:gsub("%s+", ""):upper()
    local r,g,b=hex:match("^#?(%x%x)(%x%x)(%x%x)$")
    if not r then return nil end
    r,g,b=tonumber(r,16),tonumber(g,16),tonumber(b,16)
    if 0.299*r + 0.587*g + 0.114*b < 140 then return nil end
    return string.format("#%02X%02X%02X",r,g,b), Color3.fromRGB(r,g,b)
end
local settingsPath = "PaporotnicHub/preferences.json"
local sessionPath = "PaporotnicHub/session.json"
local recentTemporaryPath = "PaporotnicHub/recent-temporary.json"
local supportsSessionFiles = type(readfile)=="function" and type(writefile)=="function"
local rememberMe = false -- OFF by default; never save a key before explicit opt-in.
local themeName = "forest"
local customAccentHex = nil
local showFoliage = true
local lastLaunchedGameId = nil
do
    if type(readfile)=="function" then
        local success, body = pcall(readfile, settingsPath)
        if success and type(body)=="string" then
            local parsed, saved = pcall(function() return HttpService:JSONDecode(body) end)
            if parsed and type(saved)=="table" then
                if type(saved.theme)=="string" and themes[saved.theme] then themeName=saved.theme end
                local normalizedAccent = parseAccentHex(saved.accentHex)
                if normalizedAccent then customAccentHex=normalizedAccent end
                if saved.showFoliage == false then showFoliage=false end
                if saved.language=="ru" or saved.language=="en" then lang=saved.language end
                if saved.rememberMe == true and supportsSessionFiles then rememberMe=true end
                if type(saved.recentGameId)=="string" and #saved.recentGameId<100 then
                    lastLaunchedGameId=saved.recentGameId
                end
            end
        end
    end
end
local palette = {}
for key,color in pairs(themes[themeName]) do palette[key]=color end
if customAccentHex then
    local _,accentColor=parseAccentHex(customAccentHex)
    if accentColor then palette.highlight=accentColor end
end
local themeBindings = setmetatable({}, {__mode="k"})
local function ensureDataFolder()
    if type(makefolder)=="function" then pcall(makefolder,"PaporotnicHub") end
end
local function savePreferences()
    if type(writefile)~="function" then return false end
    ensureDataFolder()
    local ok = pcall(writefile, settingsPath,
        HttpService:JSONEncode({theme=themeName, accentHex=customAccentHex,
            showFoliage=showFoliage, language=lang, rememberMe=rememberMe,
            recentGameId=lastLaunchedGameId}))
    return ok
end

-- Warning: executor file APIs offer no secure keychain. This local JSON stores
-- the real access key in plain text, strictly after an explicit user opt-in.
-- Cached data is NEVER accepted as proof of access without HTTPS /v1/verify.
local function saveSessionKey(key)
    if not rememberMe or not supportsSessionFiles or type(key)~="string" then return false end
    if #key < 4 or #key > 128 then return false end
    ensureDataFolder()
    local ok = pcall(writefile, sessionPath, HttpService:JSONEncode({version=1, key=key}))
    return ok
end
local function readSessionKey()
    if not rememberMe or not supportsSessionFiles then return nil end
    local ok, body = pcall(readfile, sessionPath)
    if not ok or type(body)~="string" then return nil end
    local parsed, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not parsed or type(data)~="table" or data.version ~= 1 then return nil end
    if type(data.key)~="string" or #data.key < 4 or #data.key > 128 then return nil end
    return data.key
end
-- Used for manual prefill ONLY. A saved temporary key is NEVER trusted as
-- authentication, even if the file was written on a previous successful login.
-- Deliberately never store a Lifetime key here (Lifetime may only be saved
-- via the explicit Remember Me opt-in above).
local function saveRecentTemporaryKey(key)
    if not supportsSessionFiles or type(key)~="string" or #key < 4 or #key > 128 then return false end
    ensureDataFolder()
    return pcall(writefile, recentTemporaryPath,
        HttpService:JSONEncode({version=1,kind="temporary",key=key}))
end
local function readRecentTemporaryKey()
    if not supportsSessionFiles then return nil end
    local ok,body=pcall(readfile,recentTemporaryPath)
    if not ok or type(body)~="string" then return nil end
    local parsed,data=pcall(function() return HttpService:JSONDecode(body) end)
    if not parsed or type(data)~="table" or data.version~=1 or data.kind~="temporary" then return nil end
    if type(data.key)~="string" or #data.key < 4 or #data.key > 128 then return nil end
    return data.key
end
local function clearRecentTemporaryKey()
    if type(delfile)=="function" then
        local ok=pcall(delfile,recentTemporaryPath)
        if ok then return true end
    end
    if type(writefile)=="function" then
        ensureDataFolder()
        return pcall(writefile,recentTemporaryPath,HttpService:JSONEncode({version=1}))
    end
    return false
end

local function clearSessionKey()
    -- delfile may not exist. Overwrite with an empty object as a fallback so
    -- stale credentials cannot be read by this launcher even after logout.
    if type(delfile)=="function" then
        local ok = pcall(delfile, sessionPath)
        if ok then return true end
    end
    if type(writefile)=="function" then
        ensureDataFolder()
        return pcall(writefile, sessionPath, HttpService:JSONEncode({version=1}))
    end
    return false
end

local uiConnections = {}
local alive = true
local authenticated = false
local approvedKeyKind = nil -- "temporary" or "lifetime", confirmed by the VPS response.
local authMode = "server"  -- fail closed, even with an offline or stale catalog
local selectedTab = "home"
local scriptCategory = "games" -- Game Scripts / Universal Scripts
local universalRunning = false
local statusText = ""
local uiPhase = "BOOT" -- BOOT / AUTH / UNLOCKING / MAIN
local verifyingKey = false
-- Incremented on Switch Key to cancel any in-flight module fetch from a prior session.
local sessionEpoch = 0
local returnToAuthGate = nil
local authStatusLabel, authSubmitButton, authInput
local recentForgetButton
local screen, root, content, statusLabel, titleLabel, footerLabel
local switchKeyButton -- forward declaration for language changes in Settings
local sidebarButtons = {}
local sidebarAccessText, topVerifyText
local rightRail, premiumHeaderType, premiumHeaderName, premiumScale
local dashboardWallpaper, cornerFerns -- actual graphics are created later, after Settings
local renderRightRail = function() end
local approvedSecondsLeft = nil

local function navigateTo(page, category)
    selectedTab=page
    if category then scriptCategory=category end
    if type(render)=="function" then render() end
end

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
-- Executor-local image bridge. Roblox ImageLabel cannot read PNG bytes directly.
-- We only download pictures from our own static repo, never code here.
-- Fail gracefully if an executor does not provide the necessary APIs.
local graphicCache, graphicWaiters, graphicBusy = {}, {}, {}
local customAssetFn = (type(getcustomasset)=="function" and getcustomasset)
    or (type(getsynasset)=="function" and getsynasset)
    or (type(global.getcustomasset)=="function" and global.getcustomasset)
    or (type(global.getsynasset)=="function" and global.getsynasset)

local function resolveLayeredImage(key)
    local direct = premiumImageId(PREMIUM_ASSETS[key])
    if direct then return direct end
    local fileName = LAYERED_FILES[key]
    if not fileName or type(customAssetFn)~="function" then return nil end
    local filePath = "PaporotnicHub/art_v027_" .. fileName
    local existing = false
    if type(isfile)=="function" then
        local ok,result = pcall(isfile,filePath)
        existing = ok and result == true
    elseif type(readfile)=="function" then
        local ok,result=pcall(readfile,filePath)
        existing = ok and type(result)=="string" and #result>8
    end
    if not existing and type(writefile)=="function" then
        local downloaded,body=pcall(function()
            return game:HttpGet(BASE.."assets/"..fileName)
        end)
        if downloaded and type(body)=="string" and #body>64 and #body<3000000
            and body:sub(1,8)=="\137PNG\r\n\26\n" then
            if type(makefolder)=="function" then pcall(makefolder,"PaporotnicHub") end
            local written=pcall(writefile,filePath,body)
            existing=written
        end
    end
    if not existing then return nil end
    local ok,asset=pcall(customAssetFn,filePath)
    if ok and type(asset)=="string" and #asset>0 then return asset end
    return nil
end
local function attachLayer(image,key)
    local direct=premiumImageId(PREMIUM_ASSETS[key])
    if direct then image.Image=direct; return end
    if graphicCache[key] then image.Image=graphicCache[key]; return end
    if graphicCache[key]==false then return end
    graphicWaiters[key]=graphicWaiters[key] or {}
    table.insert(graphicWaiters[key],image)
    if graphicBusy[key] then return end
    graphicBusy[key]=true
    task.spawn(function()
        local asset=resolveLayeredImage(key)
        graphicCache[key]=asset or false
        for _,target in ipairs(graphicWaiters[key] or {}) do
            if target and target.Parent and asset then target.Image=asset end
        end
        graphicWaiters[key]=nil
        graphicBusy[key]=nil
    end)
end

local function repaintPalette()
    for object, properties in pairs(themeBindings) do
        if object.Parent then
            for property, paletteKey in pairs(properties) do
                pcall(function() object[property]=palette[paletteKey] end)
            end
        end
    end
    task.defer(function() if alive and type(render)=="function" then render() end end)
end
local function setTheme(name)
    if not themes[name] or name==themeName then return end
    themeName=name
    for key,color in pairs(themes[name]) do palette[key]=color end
    -- A user's explicit custom accent takes priority over a theme's default.
    if customAccentHex then
        local _,color=parseAccentHex(customAccentHex)
        if color then palette.highlight=color end
    end
    repaintPalette()
    savePreferences()
end
local function setCustomAccent(input)
    local normalized,color=parseAccentHex(input)
    if not normalized then return false end
    customAccentHex=normalized
    palette.highlight=color
    repaintPalette()
    savePreferences()
    return true
end
local function resetCustomAccent()
    customAccentHex=nil
    palette.highlight=themes[themeName].highlight
    repaintPalette()
    savePreferences()
end
local function setFoliageVisible(enabled)
    showFoliage=(enabled==true)
    if dashboardWallpaper and dashboardWallpaper.Parent then dashboardWallpaper.Visible=showFoliage end
    if cornerFerns and cornerFerns.Parent then cornerFerns.Visible=showFoliage end
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
    -- A muted highlight rim and a tiny interior light wash. The page stays
    -- clean and static; no moving fern textures or background particles.
    create("UIStroke", {Thickness=1.5, Color=palette.highlight, Transparency=0.82}, x)
    local wash=create("Frame", {
        Name="AmbientGlow", Position=UDim2.new(0.44,0,0,0), Size=UDim2.new(0.56,0,1,0),
        BackgroundColor3=palette.highlight, BackgroundTransparency=0.90,
        BorderSizePixel=0, ZIndex=1
    },x)
    corner(wash,12)
    create("UIGradient", {Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.75,0.77),
        NumberSequenceKeypoint.new(1,0.92)
    })}, wash)
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
    -- Display verification results right beneath the access-key textbox,
    -- never in a distant footer while the user is at the AUTH gate.
    if uiPhase=="AUTH" and authStatusLabel and authStatusLabel.Parent then
        authStatusLabel.Text=statusText
        authStatusLabel.TextColor3=warning and palette.alert or palette.highlight
        if authSubmitButton then
            authSubmitButton.Text=verifyingKey and (lang=="ru" and "ПРОВЕРЯЕМ..." or "VERIFYING...") or T("enter")
            authSubmitButton.Active=not verifyingKey
            authSubmitButton.AutoButtonColor=not verifyingKey
        end
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

-- Decorative asset requests removed: startup and main background are clean.

local approvedKey = nil
-- Fixed, reviewed source; never accept arbitrary URLs from catalog.json here.
local INFINITE_YIELD_SOURCE = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"

-- Some Luau executors expose gethwid(). Standard Roblox Luau does not.
-- Never invent a fingerprint: an unsupported executor must be reported to the user.
local function getDeviceHWID()
    local fn = nil
    if type(gethwid) == "function" then fn = gethwid end
    if not fn and type(global.gethwid) == "function" then fn = global.gethwid end
    if not fn then return nil end
    local ok, value = pcall(fn)
    if not ok or type(value) ~= "string" or #value < 8 or #value > 256 then return nil end
    if not value:match("^[!-~]+$") then return nil end
    return value -- Only sent to our own HTTPS API, never printed or stored locally.
end

local function verifyKey(key, onSuccess, onRejected)
    local auth = catalog.auth or {}
    local url = auth.verifyUrl
    if type(url) ~= "string" or not url:match("^https://") or not url:match("/v1/verify$") then
        info(T("authNeedServer"), true)
        return
    end
    local requester = (syn and syn.request) or http_request or request
    if type(requester) ~= "function" then info(T("verifyFail"), true); return end
    key = tostring(key or ""):match("^%s*(.-)%s*$")
    if #key < 4 or #key > 128 then info(T("invalid"), true); return end
    if verifyingKey then return end

    verifyingKey = true
    authenticated = false
    approvedKey = nil
    approvedKeyKind = nil
    approvedSecondsLeft = nil
    info(lang == "ru" and "Проверяем ключ..." or "Verifying key...")
    task.spawn(function()
        local success, result = pcall(function()
            return requester({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ key = key, hub = "paporotnic-hub", hwid = getDeviceHWID() }),
            })
        end)
        if not alive then return end
        verifyingKey = false
        if not success or type(result) ~= "table" then info(T("verifyFail"), true); return end

        local status = tonumber(result.StatusCode or result.Status)
        local parsed, data = pcall(function() return HttpService:JSONDecode(result.Body or "") end)
        if not parsed or type(data) ~= "table" then info(T("verifyFail"), true); return end

        if status == 200 and data.ok == true and data.code == "valid" and data.hub == "paporotnic-hub" then
            authenticated = true
            approvedKey = key
            -- KeySystem v0.3.4 only supplies seconds_left for time-limited keys.
            -- Unknown response shapes fail safe to Lifetime rules: never
            -- persist credentials into recent-temporary.json on mere guesses.
            approvedKeyKind = (type(data.seconds_left)=="number" and data.seconds_left>0)
                and "temporary" or "lifetime"
            approvedSecondsLeft = type(data.seconds_left)=="number" and data.seconds_left or nil
            info(T("activated"))
            task.defer(function() if alive then render() end end)
            if type(onSuccess) == "function" then onSuccess() end
            return
        end

        authenticated = false
        approvedKey = nil
        approvedKeyKind = nil
        approvedSecondsLeft = nil
        local reason = data.code
        if status == 429 or reason == "rate_limited" then
            info(lang == "ru" and "Слишком много проверок. Попробуй позже." or "Too many attempts. Try later.", true)
        elseif reason == "expired" then
            info(lang == "ru" and "Срок действия ключа истёк." or "Key has expired.", true)
        elseif reason == "revoked" then
            info(lang == "ru" and "Ключ заблокирован." or "Key was revoked.", true)
        elseif reason == "hwid_required" then
            info(lang == "ru" and "Не удалось получить HWID устройства. Обратись в поддержку." or "Device HWID unavailable. Contact support.", true)
        elseif reason == "hwid_mismatch" then
            info(lang == "ru" and "HWID не совпадает. Требуется сброс привязки." or "HWID mismatch. Device reset required.", true)
        elseif status == 403 or reason == "invalid_key" then
            info(T("invalid"), true)
        else
            info(T("verifyFail"), true)
        end
        -- Network failures and rate limits are not proof that the key is invalid.
        -- Clear Remember Me only when the VPS definitively rejects a credential.
        if type(onRejected)=="function" and (
            reason=="expired" or reason=="revoked" or reason=="invalid_key" or
            reason=="hwid_mismatch" or reason=="hwid_required" or
            (status == 403 and reason ~= "rate_limited")
        ) then
            onRejected(reason)
        end
        task.defer(function() if alive then render() end end)
    end)
end

local function launch(row)
    if verifyingKey then return end
    local launchEpoch = sessionEpoch
    if not authenticated or type(approvedKey) ~= "string" then info(T("unauth"),true); return end
    if not isSupported(row) then info(T("unsupported"),true); return end
    if row.enabled == false then info(T("unavailable"),true); return end
    if not trustedUrl(row.script) then info(T("badUrl"),true); return end

    -- Check the key again immediately before loading a game module.
    -- A key revoked/expired since the initial activation must be rejected.
    verifyKey(approvedKey, function()
        if not alive or launchEpoch ~= sessionEpoch or not authenticated then return end
        info(T("loading"))
        task.spawn(function()
            local fetched, code = pcall(function() return game:HttpGet(row.script) end)
            if not alive or launchEpoch ~= sessionEpoch or not authenticated then return end
            if not fetched or type(code)~="string" then info(T("loadFail")..tostring(code),true); return end
            if type(loadstring)~="function" then info(T("loadFail").."loadstring unavailable",true); return end
            local buildOK, fn = pcall(function() return loadstring(code) end)
            if not buildOK or type(fn)~="function" then info(T("loadFail")..tostring(fn),true); return end
            -- Lua cannot terminate a module already running, but a pending
            -- network fetch must never start a module after Switch Key.
            if launchEpoch ~= sessionEpoch or not authenticated then return end
            local launched,err=pcall(fn)
            if not alive or launchEpoch ~= sessionEpoch then return end
            if launched then
                if type(row.id)=="string" then
                    lastLaunchedGameId=row.id
                    savePreferences()
                end
                info(T("loaded")); screen.Enabled=false
            else info(T("loadFail")..tostring(err),true) end
        end)
    end)
end

-- Universal tools may run in any Roblox place, unlike game-specific modules.
-- Reuse the SAME server authorization check, including revoked keys and HWID.
-- The only supported third-party source is the exact, hardcoded official URL.
local function launchInfiniteYield()
    if universalRunning or verifyingKey then info(T("infiniteBusy"),true); return end
    if not authenticated or type(approvedKey)~="string" then info(T("unauth"),true); return end
    local launchEpoch = sessionEpoch
    universalRunning=true
    -- The external script executes with the permissions of the user's executor.
    -- Its source can change upstream. It is never launched automatically.
    verifyKey(approvedKey,function()
        if not alive or launchEpoch~=sessionEpoch or not authenticated then
            universalRunning=false
            return
        end
        info(T("infiniteLoading"))
        task.spawn(function()
            if type(loadstring)~="function" then
                universalRunning=false
                info(T("infiniteMissing"),true)
                return
            end
            local fetched, code=pcall(function() return game:HttpGet(INFINITE_YIELD_SOURCE) end)
            if not alive or launchEpoch~=sessionEpoch or not authenticated then
                universalRunning=false
                return
            end
            if not fetched or type(code)~="string" or #code==0 then
                universalRunning=false
                info(T("loadFail")..tostring(code),true)
                return
            end
            local compiled, fn=pcall(function() return loadstring(code) end)
            if not compiled or type(fn)~="function" then
                universalRunning=false
                info(T("loadFail")..tostring(fn),true)
                return
            end
            if not alive or launchEpoch~=sessionEpoch or not authenticated then
                universalRunning=false
                return
            end
            local launched,err=pcall(fn)
            universalRunning=false
            if not alive or launchEpoch~=sessionEpoch then return end
            if launched then
                info(T("infiniteLoaded"))
                screen.Enabled=false
            else
                info(T("loadFail")..tostring(err),true)
            end
        end)
    end)
    -- Network/denial path: verifyKey calls onRejected only for firm rejection.
    -- A transient failure leaves universalRunning set, so guard with a bounded
    -- task and session token; it never authorizes a script by itself.
    task.delay(20,function()
        if alive and launchEpoch==sessionEpoch then universalRunning=false end
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

-- Static background; old diagonal fern field removed.

function render() end

local function renderHome()
    clearPage()
    local function L(ru,en) return lang=="ru" and ru or en end

    -- v0.2.27: layered artwork with a complete graphical fallback for the dashboard to look complete.
    -- ImageLabels overlay an actual styled surface, so missing or restricted
    -- Roblox thumbnails never produce empty black hero/tiles.
    local function block(parent, pos, size, color, radius)
        local f=create("Frame",{
            Position=pos or UDim2.fromOffset(0,0),Size=size or UDim2.fromOffset(100,100),
            BackgroundColor3=color or palette.panel,BorderSizePixel=0,ClipsDescendants=true
        },parent)
        corner(f,radius or 12)
        return f
    end
    local function line(parent,x,y,w,h,color,alpha)
        return create("Frame",{
            Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
            BackgroundColor3=color or palette.border,BackgroundTransparency=alpha or 0,
            BorderSizePixel=0
        },parent)
    end
    local function textAt(parent,value,size,color,x,y,w,h,bold)
        local obj=txt(parent,value,size,color or palette.text,h)
        obj.Position=UDim2.fromOffset(x,y)
        obj.Size=UDim2.fromOffset(w,h)
        obj.TextWrapped=true
        obj.TextTruncate=Enum.TextTruncate.AtEnd
        if bold then obj.Font=Enum.Font.GothamBold end
        return obj
    end
    local function thinBorder(parent,color,alpha)
        create("UIStroke",{Color=color or palette.border,Thickness=1,Transparency=alpha or 0.65},parent)
    end
    local function imageOverlay(parent,url)
        if type(url)~="string" or url=="" then return nil end
        -- BackgroundTransparency=1: fallback underneath remains visible
        -- while Roblox downloads the image or when asset access is denied.
        local img=create("ImageLabel",{
            Name="OptionalArtwork",Size=UDim2.fromScale(1,1),
            BackgroundTransparency=1,BorderSizePixel=0,
            Image=url,ScaleType=Enum.ScaleType.Crop,
            ImageTransparency=0.16
        },parent)
        return img
    end
    local function section(parent,ru,en,target,category)
        local bar=block(parent,nil,UDim2.new(1,-4,0,31),palette.background,0)
        bar.BackgroundTransparency=1
        local dot=block(bar,UDim2.fromOffset(1,9),UDim2.fromOffset(10,10),palette.highlight,4)
        local heading=textAt(bar,L(ru,en),16,palette.text,20,1,450,29,true)
        local all=button(bar,L("СМОТРЕТЬ ВСЕ  >","SEE ALL  >"),118,28,function()
            navigateTo(target,category)
        end,false)
        all.Size=UDim2.fromOffset(118,26)
        all.Position=UDim2.new(1,-122,0,1)
        all.TextSize=11
        all.BackgroundTransparency=0.45
        corner(all,8)
        return bar
    end
    local function callToAction(parent,caption,x,y,w,onClick,accent)
        local b=button(parent,caption,w,39,onClick,accent)
        b.Position=UDim2.fromOffset(x,y)
        b.TextSize=13
        corner(b,10)
        connect(b.MouseEnter,function()
            if b.Parent then TweenService:Create(b,TweenInfo.new(0.13),{BackgroundTransparency=0.14}):Play() end
        end)
        connect(b.MouseLeave,function()
            if b.Parent then TweenService:Create(b,TweenInfo.new(0.16),{BackgroundTransparency=0}):Play() end
        end)
        return b
    end

    local scroll=create("ScrollingFrame",{
        Name="PremiumHomeScroll",Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=3,ScrollBarImageColor3=palette.highlight,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.fromOffset(0,0)
    },content)
    create("UIListLayout",{Padding=UDim.new(0,13),SortOrder=Enum.SortOrder.LayoutOrder},scroll)

    local games={}
    local featured
    for _,gameRow in ipairs(catalog.games or {}) do
        if type(gameRow)=="table" and gameRow.enabled~=false then
            table.insert(games,gameRow)
            if not featured and isSupported(gameRow) then featured=gameRow end
        end
    end
    if not featured then featured=games[1] end

    -- Featured: illustrated-in-UI right third, dark readable left side.
    local hero=block(scroll,nil,UDim2.new(1,-4,0,234),palette.panel,15)
    hero.Name="FeaturedModule"
    thinBorder(hero,palette.border,0.42)
    create("UIGradient",{Rotation=0,Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(9,22,18)),
        ColorSequenceKeypoint.new(0.58,Color3.fromRGB(17,21,35)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(35,25,47))
    })},hero)
    local artPanel=block(hero,UDim2.new(0.57,0,0,0),UDim2.new(0.43,0,1,0),Color3.fromRGB(30,37,54),0)
    create("UIGradient",{Rotation=35,Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(19,47,43)),
        ColorSequenceKeypoint.new(0.45,Color3.fromRGB(28,24,49)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(88,48,65))
    })},artPanel)
    -- Fallback graphic: an angled futuristic module frame, not blank space.
    for i=1,7 do
        line(artPanel,-20+(i*52),-16,2,280,palette.highlight,0.84)
    end
    local halo=block(artPanel,UDim2.new(.53,-88,.48,-88),UDim2.fromOffset(176,176),palette.background,88)
    halo.BackgroundTransparency=0.67
    create("UIStroke",{Color=palette.highlight,Thickness=3,Transparency=0.60},halo)
    local innerRing=block(artPanel,UDim2.new(.53,-55,.48,-55),UDim2.fromOffset(110,110),palette.panel,55)
    innerRing.BackgroundTransparency=0.22
    create("UIStroke",{Color=palette.highlight,Thickness=1.5,Transparency=0.35},innerRing)
    local emblem=textAt(innerRing,"◆",39,palette.highlight,0,24,110,61,true)
    emblem.TextXAlignment=Enum.TextXAlignment.Center
    textAt(artPanel,"MODULE  /  01",10,palette.text,16,15,205,21,true).TextTransparency=0.22
    textAt(artPanel,"PAPOROTNIC",11,palette.text,18,205,230,18,true).TextTransparency=0.48
    local currentImage=""
    if premiumImageId(PREMIUM_ASSETS.heroBanner) then
        currentImage=PREMIUM_ASSETS.heroBanner
    elseif featured and tonumber(featured.universeId) then
        currentImage="rbxthumb://type=GameIcon&id="..tostring(featured.universeId).."&w=420&h=420"
    end
    local optionalArt=imageOverlay(artPanel,currentImage)
    if optionalArt then optionalArt.ImageTransparency=0.16 end
    -- Real layered hero art sourced from the original mockup, independent of UI buttons.
    local featuredArtwork=create("ImageLabel",{
        Name="FeaturedArtwork",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,Image="",ImageTransparency=0.04,
        ScaleType=Enum.ScaleType.Crop
    },hero)
    attachLayer(featuredArtwork,"heroBanner")
    -- Dark left mask keeps copy legible even with a bright user-supplied art.
    local textBackdrop=block(hero,UDim2.fromOffset(0,0),UDim2.new(.67,0,1,0),palette.background,0)
    textBackdrop.BackgroundTransparency=0.08
    create("UIGradient",{Rotation=0,Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.05),
        NumberSequenceKeypoint.new(0.70,0.28),
        NumberSequenceKeypoint.new(1,1)
    })},textBackdrop)
    local pill=block(hero,UDim2.fromOffset(22,18),UDim2.fromOffset(166,27),palette.highlight,9)
    pill.BackgroundTransparency=0.81
    textAt(pill,L("●  ВЫБРАННЫЙ МОДУЛЬ","●  FEATURED MODULE"),10,palette.highlight,10,1,148,25,true)
    local heroTitle=featured and tostring(featured.title or "Game") or T("dashboardWelcome")
    local hTitle=textAt(hero,heroTitle,30,palette.text,22,57,455,71,true)
    hTitle.TextYAlignment=Enum.TextYAlignment.Top
    local desc=textAt(hero,featured and tostring(featured.description or "") or T("dashboardNoModule"),
        13,palette.muted,24,133,445,37,false)
    desc.TextYAlignment=Enum.TextYAlignment.Top
    callToAction(hero,featured and L("▶  ЗАПУСТИТЬ","▶  LAUNCH") or T("dashboardBrowse"),
        23,184,163,function()
            if featured then launch(featured) else navigateTo("games","games") end
        end,true)
    callToAction(hero,L("ПОДРОБНЕЕ","DETAILS"),199,184,123,function()
        navigateTo("games","games")
    end,false)
    local version=block(hero,UDim2.new(1,-139,1,-47),UDim2.fromOffset(121,31),palette.background,9)
    version.BackgroundTransparency=0.12
    thinBorder(version,palette.border,.5)
    textAt(version,featured and tostring(featured.version or "CATALOG") or "LIBRARY",
        11,palette.text,9,1,102,15,true)
    textAt(version,featured and (isSupported(featured) and L("● ТЕКУЩИЙ ПЛЕЙС","● CURRENT PLACE")
        or L("● В КАТАЛОГЕ","● CATALOG")) or "—",9,palette.highlight,9,16,107,14,true)

    section(scroll,"БИБЛИОТЕКА ИГР","GAME LIBRARY","games","games")
    local gameRows=math.max(1,math.ceil(#games/4))
    local gallery=block(scroll,nil,UDim2.new(1,-4,0,gameRows*157),palette.background,0)
    gallery.BackgroundTransparency=1
    -- Only real catalog games. No fake Universal Tools / Updates / Settings tiles.
    for i,item in ipairs(games) do
        local col=(i-1)%4
        local rowIndex=math.floor((i-1)/4)
        local tile=block(gallery,UDim2.new(col*.25,col*3,0,rowIndex*157),
            UDim2.new(.25,-10,0,151),palette.panel,12)
        thinBorder(tile,palette.highlight,.50)
        local cover=block(tile,UDim2.fromOffset(0,0),UDim2.new(1,0,0,98),palette.card,0)
        create("UIGradient",{Rotation=35,Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,palette.card),
            ColorSequenceKeypoint.new(.55,palette.panel),
            ColorSequenceKeypoint.new(1,palette.background)
        })},cover)
        local graphic=block(cover,UDim2.new(.5,-36,.5,-36),UDim2.fromOffset(72,72),palette.highlight,36)
        graphic.BackgroundTransparency=.90
        create("UIStroke",{Color=palette.highlight,Thickness=2,Transparency=.66},graphic)
        local letter=textAt(graphic,tostring(item.title or "G"):sub(1,1):upper(),29,
            palette.highlight,0,12,72,48,true)
        letter.TextXAlignment=Enum.TextXAlignment.Center
        if tonumber(item.universeId) then
            imageOverlay(cover,"rbxthumb://type=GameIcon&id="..tostring(item.universeId).."&w=420&h=420")
        end
        local itemTitle=textAt(tile,tostring(item.title or "Game"),12,palette.text,10,102,156,28,true)
        itemTitle.Size=UDim2.new(1,-20,0,27)
        local state=(item.id==lastLaunchedGameId and L("● НЕДАВНО","● RECENT") or
            (isSupported(item) and L("● ТЕКУЩАЯ ИГРА","● CURRENT PLACE") or L("● В КАТАЛОГЕ","● IN CATALOG")))
        local gameStatus=textAt(tile,state,9,palette.highlight,10,132,154,16,true)
        gameStatus.Size=UDim2.new(1,-20,0,16)
        local tap=create("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},tile)
        connect(tap.MouseButton1Click,function() navigateTo("games","games") end)
    end
    if #games==0 then
        textAt(gallery,L("Игры скоро появятся","Games coming soon"),14,palette.muted,14,28,450,34,false)
    end

    section(scroll,"УНИВЕРСАЛЬНЫЕ СКРИПТЫ","UNIVERSAL SCRIPTS","games","universal")
    local utils=block(scroll,nil,UDim2.new(1,-4,0,171),palette.background,0)
    utils.BackgroundTransparency=1
    local tile=block(utils,UDim2.fromOffset(0,0),UDim2.new(.25,-10,1,-2),palette.panel,12)
    thinBorder(tile,palette.highlight,.35)
    local banner=block(tile,UDim2.fromOffset(0,0),UDim2.new(1,0,0,100),Color3.fromRGB(25,23,27),0)
    local iyFallback=textAt(banner,"INFINITE YIELD",17,Color3.fromRGB(240,240,240),7,27,170,46,true)
    iyFallback.Size=UDim2.new(1,-14,0,46)
    iyFallback.TextXAlignment=Enum.TextXAlignment.Center
    -- The user's own Infinite Yield image is the *only* image source for this card.
    local iyImage=create("ImageLabel",{
        Name="UserInfiniteYieldArtwork",Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,BorderSizePixel=0,Image="",ScaleType=Enum.ScaleType.Crop
    },banner)
    attachLayer(iyImage,"infiniteYieldCard")
    local name=textAt(tile,"Infinite Yield",13,palette.text,10,107,165,21,true)
    name.Size=UDim2.new(1,-20,0,22)
    local sub=textAt(tile,L("Админ-команды и утилиты","Admin commands & utilities"),10,palette.muted,10,128,164,27,false)
    sub.Size=UDim2.new(1,-20,0,26)
    local badge=block(tile,UDim2.fromOffset(10,155),UDim2.fromOffset(85,14),palette.highlight,5)
    textAt(badge,"UNIVERSAL",9,palette.background,8,0,77,14,true)
    local tap=create("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},tile)
    connect(tap.MouseButton1Click,function() navigateTo("games","universal") end)
    if not catalogOk then
        local note=txt(scroll,T("offline"),10,palette.alert,24)
        note.Size=UDim2.new(1,-8,0,24)
    end
end

local function renderGameScripts(panel)
    local heading=txt(panel,T("supported"),22,palette.text,38)
    heading.Font=Enum.Font.GothamBold
    heading.Size=UDim2.new(1,-348,0,38)

    local searchWrap=create("Frame",{
        Position=UDim2.new(1,-330,0,1), Size=UDim2.fromOffset(330,38),
        BackgroundColor3=palette.card, BorderSizePixel=0
    },panel)
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
    },panel)
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


local function renderUniversalScripts(panel)
    local heading=txt(panel,T("universalTitle"),22,palette.text,38)
    heading.Font=Enum.Font.GothamBold
    local subtitle=txt(panel,T("universalSub"),13,palette.muted,26)
    subtitle.Position=UDim2.fromOffset(0,37)

    local row=card(panel,204)
    row.Position=UDim2.fromOffset(0,78)
    local iconHolder=create("Frame",{
        Position=UDim2.fromOffset(4,13), Size=UDim2.fromOffset(86,86),
        BackgroundColor3=palette.card,BorderSizePixel=0
    },row)
    corner(iconHolder,14)
    local iconText=txt(iconHolder,"IY",29,palette.highlight,56,Enum.TextXAlignment.Center)
    iconText.Font=Enum.Font.GothamBold
    iconText.Position=UDim2.fromOffset(0,15)
    local iconArtwork=create("ImageLabel",{
        Name="InfiniteYieldOriginalLogo",Position=UDim2.fromOffset(0,0),
        Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,Image="",ScaleType=Enum.ScaleType.Fit
    },iconHolder)
    attachLayer(iconArtwork,"infiniteYield")
    local title=txt(row,"Infinite Yield",21,palette.text,30)
    title.Font=Enum.Font.GothamBold
    title.Position=UDim2.fromOffset(106,3)
    title.Size=UDim2.new(1,-112,0,30)
    local desc=txt(row,T("infiniteDesc"),13,palette.muted,42)
    desc.Position=UDim2.fromOffset(106,39)
    desc.Size=UDim2.new(1,-112,0,42)
    local credit=txt(row,T("infiniteCredit"),12,palette.highlight,22)
    credit.Position=UDim2.fromOffset(106,84)
    credit.Size=UDim2.new(1,-112,0,22)
    local source=txt(row,T("infiniteSource"),12,palette.muted,22)
    source.Position=UDim2.fromOffset(4,113)
    source.Size=UDim2.new(1,-10,0,22)
    local run=button(row,T("infiniteLaunch"),144,38,launchInfiniteYield,true)
    run.Name="InfiniteYieldExecute"
    run.Position=UDim2.new(1,-148,1,-40)
    local foot=txt(row,T("infiniteWarning"),11,palette.alert,38)
    foot.Position=UDim2.fromOffset(4,149)
    foot.Size=UDim2.new(1,-166,0,38)
end

local function renderGames()
    clearPage()
    local categoryBar=create("Frame",{
        Size=UDim2.new(1,0,0,44), BackgroundTransparency=1,
    },content)
    local gameTab=button(categoryBar,T("scriptsGame"),220,40,function()
        scriptCategory="games"
        renderGames()
    end,scriptCategory=="games")
    gameTab.Name="GameScriptsTab"
    gameTab.Position=UDim2.fromOffset(0,0)
    local universalTab=button(categoryBar,T("scriptsUniversal"),220,40,function()
        scriptCategory="universal"
        renderGames()
    end,scriptCategory=="universal")
    universalTab.Name="UniversalScriptsTab"
    universalTab.Position=UDim2.fromOffset(246,0)
    local panel=create("Frame",{
        Position=UDim2.fromOffset(0,58),
        Size=UDim2.new(1,0,1,-58), BackgroundTransparency=1
    },content)
    if scriptCategory=="universal" then
        renderUniversalScripts(panel)
    else
        renderGameScripts(panel)
    end
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
    local L=function(ru,en) return lang=="ru" and ru or en end
    local scroll=create("ScrollingFrame",{
        Name="ThemeEditorScroll",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=palette.highlight,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        CanvasSize=UDim2.fromOffset(0,760)
    },content)
    local page=create("Frame",{
        Size=UDim2.new(1,-14,0,750),BackgroundTransparency=1,BorderSizePixel=0
    },scroll)
    local heading=txt(page,T("settings"),22,palette.text,38)
    heading.Font=Enum.Font.GothamBold
    local languageButton=button(page,T("lang"),240,39,function()
        lang=lang=="ru" and "en" or "ru"
        savePreferences()
        if titleLabel then titleLabel.Text=T("title") end
        if footerLabel then footerLabel.Text=T("footer") end
        if switchKeyButton then switchKeyButton.Text=T("switchKey") end
        task.defer(function() if alive then render() end end)
    end,false)
    languageButton.Position=UDim2.fromOffset(0,48)

    local themeHeading=txt(page,T("themeHeading"),16,palette.text,27)
    themeHeading.Font=Enum.Font.GothamBold
    themeHeading.Position=UDim2.fromOffset(0,107)
    for index,name in ipairs(themeOrder) do
        local theme=themes[name]
        local selected=(name==themeName)
        local label=T("theme"..name:sub(1,1):upper()..name:sub(2))
        local tile=create("TextButton",{
            Position=UDim2.fromOffset((index-1)*204,141),Size=UDim2.fromOffset(190,74),
            BackgroundColor3=palette.panel,BorderSizePixel=0,Text="",AutoButtonColor=true
        },page)
        corner(tile,11)
        create("UIStroke",{Thickness=selected and 2 or 1,
            Color=selected and palette.highlight or palette.border,
            Transparency=selected and 0 or .35},tile)
        local swatch=create("Frame",{
            Position=UDim2.fromOffset(13,14),Size=UDim2.fromOffset(18,18),
            BackgroundColor3=theme.highlight,BorderSizePixel=0
        },tile)
        corner(swatch,5)
        local labelText=txt(tile,label,13,palette.text,24)
        labelText.Font=Enum.Font.GothamBold
        labelText.Position=UDim2.fromOffset(40,11)
        labelText.Size=UDim2.new(1,-49,0,26)
        local selection=txt(tile,selected and T("themeActive") or "",11,palette.highlight,20)
        selection.Position=UDim2.fromOffset(13,44)
        selection.Size=UDim2.new(1,-25,0,20)
        connect(tile.MouseButton1Click,function() setTheme(name) end)
    end
    local hint=txt(page,T("themeHint"),12,palette.muted,26)
    hint.Position=UDim2.fromOffset(0,219)
    hint.TextYAlignment=Enum.TextYAlignment.Center

    local accentTitle=txt(page,L("ЦВЕТ АКЦЕНТА", "ACCENT COLOR"),16,palette.text,26)
    accentTitle.Font=Enum.Font.GothamBold
    accentTitle.Position=UDim2.fromOffset(0,257)
    local accentInfo=txt(page,L("Выбери цвет или введи HEX; фон и акцент настраиваются отдельно.",
        "Pick a swatch or enter HEX; the theme and accent are independent."),12,palette.muted,22)
    accentInfo.Position=UDim2.fromOffset(0,281)
    for i,swatch in ipairs(accentSwatches) do
        local hex,name=swatch[1],swatch[2]
        local _,color=parseAccentHex(hex)
        local selected=customAccentHex==hex
        local b=create("TextButton",{
            Position=UDim2.fromOffset((i-1)*57,310),Size=UDim2.fromOffset(47,38),
            BackgroundColor3=color,Text="",BorderSizePixel=0,AutoButtonColor=true
        },page)
        corner(b,9)
        create("UIStroke",{Thickness=selected and 2.5 or 1,
            Color=selected and palette.text or palette.border,
            Transparency=selected and 0 or .3},b)
        connect(b.MouseButton1Click,function() setCustomAccent(hex) end)
    end
    local accentLabel=txt(page,L("Свой цвет", "Custom HEX"),12,palette.muted,24)
    accentLabel.Position=UDim2.fromOffset(0,364)
    local hexBox=create("TextBox",{
        Position=UDim2.fromOffset(112,363),Size=UDim2.fromOffset(160,32),
        BackgroundColor3=palette.card,TextColor3=palette.text,
        PlaceholderText="#65F42B",PlaceholderColor3=palette.muted,
        Text=customAccentHex or "",BorderSizePixel=0,
        Font=Enum.Font.Code,TextSize=14,ClearTextOnFocus=false
    },page)
    corner(hexBox,7)
    local applyButton=button(page,L("ПРИМЕНИТЬ", "APPLY"),113,32,function()
        local ok=setCustomAccent(hexBox.Text)
        if not ok then
            info(L("Введите яркий HEX-цвет: #RRGGBB.", "Enter a bright HEX color: #RRGGBB."),true)
        else
            info(L("Цвет акцента изменён.", "Accent color updated."))
        end
    end,true)
    applyButton.Position=UDim2.fromOffset(283,363)
    local resetButton=button(page,L("СБРОСИТЬ ЦВЕТ", "RESET ACCENT"),162,32,function()
        resetCustomAccent()
        info(L("Вернули стандартный цвет выбранной темы.", "Restored this theme's default accent."))
    end,false)
    resetButton.Position=UDim2.fromOffset(408,363)
    local fileWarning=txt(page,L("Настройки сохраняются между запусками, если исполнитель поддерживает запись файлов.",
        "Preferences persist when the executor supports file access."),11,palette.muted,25)
    fileWarning.Position=UDim2.fromOffset(0,402)

    local foliageToggle=button(page,showFoliage and L("ЛИСТВА: ВКЛ", "FOLIAGE: ON")
        or L("ЛИСТВА: ВЫКЛ", "FOLIAGE: OFF"),206,34,function()
        setFoliageVisible(not showFoliage)
        if alive then render() end
    end,showFoliage)
    foliageToggle.Position=UDim2.fromOffset(0,438)
    local foliageInfo=txt(page,L("Декоративные папоротники по краям. Логотип останется.",
        "Decorative corner ferns; the logo stays visible."),12,palette.muted,32)
    foliageInfo.Position=UDim2.fromOffset(222,438)
    foliageInfo.Size=UDim2.new(1,-230,0,32)

    local rememberHeading=txt(page,T("rememberTitle"),16,palette.text,28)
    rememberHeading.Font=Enum.Font.GothamBold
    rememberHeading.Position=UDim2.fromOffset(0,496)
    local rememberToggle=button(page,rememberMe and T("rememberOn") or T("rememberOff"),246,38,function()
        if not supportsSessionFiles then info(T("rememberUnavailable"),true);return end
        if rememberMe then
            rememberMe=false
            local cleared=clearSessionKey()
            local prefsSaved=savePreferences()
            if approvedKeyKind=="temporary" and type(approvedKey)=="string" then
                saveRecentTemporaryKey(approvedKey)
            else clearRecentTemporaryKey() end
            info(cleared and prefsSaved and T("rememberDisabled") or T("rememberDeleteError"),
                not (cleared and prefsSaved))
        else
            if not authenticated or type(approvedKey)~="string" then return end
            rememberMe=true
            local stored=saveSessionKey(approvedKey)
            local prefsSaved=stored and savePreferences()
            if not stored or not prefsSaved then
                rememberMe=false;clearSessionKey();savePreferences()
                info(T("rememberSaveError"),true)
            else
                clearRecentTemporaryKey()
                info(T("rememberEnabled"))
            end
        end
        if alive then render() end
    end,rememberMe)
    rememberToggle.Position=UDim2.fromOffset(0,531)
    if not supportsSessionFiles then
        rememberToggle.Active=false
        rememberToggle.AutoButtonColor=false
    end
    local rememberDesc=txt(page,T("rememberHint"),12,palette.muted,34)
    rememberDesc.Position=UDim2.fromOffset(261,533)
    rememberDesc.Size=UDim2.new(1,-270,0,34)
    local rememberWarning=txt(page,T("rememberWarning"),11,palette.alert,32)
    rememberWarning.Position=UDim2.fromOffset(0,575)
    rememberWarning.Size=UDim2.new(1,-15,0,32)
    local recentHint=txt(page,T("recentWarning"),11,palette.alert,34)
    recentHint.Position=UDim2.fromOffset(0,604)
    recentHint.Size=UDim2.new(1,-15,0,34)
    recentHint.TextWrapped=true
    local hideHint=txt(page,T("hide"),13,palette.muted,28)
    hideHint.Position=UDim2.fromOffset(0,650)
    local exit=button(page,T("exit"),260,39,function()
        if global.__PaporotnicLauncherStop then global.__PaporotnicLauncherStop() end
    end,false)
    exit.Position=UDim2.fromOffset(0,681)
    local note=txt(page,T("note"),12,palette.muted,36)
    note.Position=UDim2.fromOffset(0,723)
    note.Size=UDim2.new(1,-15,0,32)
end

function render()
    if not alive or not content then return end
    -- Repaint navigation selection and language on every page change.
    for _,entry in ipairs(sidebarButtons) do
        local nav=entry.button
        if nav and nav.Parent then
            local selected=entry.page==selectedTab and
                (entry.page~="games" or entry.category==scriptCategory)
            nav.BackgroundColor3=selected and palette.highlight or palette.card
            nav.TextColor3=selected and palette.background or palette.text
            nav.Text=entry.prefix..T(entry.labelKey)
        end
    end
    if sidebarAccessText and sidebarAccessText.Parent then
        sidebarAccessText.Text=authenticated and
            ((approvedKeyKind=="temporary" and T("dashboardTemporary") or T("dashboardLifetime")).."  •  "..T("dashboardVerified")) or "—"
    end
    if rightRail then
        rightRail.Visible=(selectedTab=="home")
        if selectedTab=="home" then
            content.Size=UDim2.new(1,-573,1,-116)
            renderRightRail()
        else
            content.Size=UDim2.new(1,-266,1,-116)
        end
    end
    if premiumHeaderType and premiumHeaderType.Parent then
        premiumHeaderType.Text=approvedKeyKind=="temporary" and T("dashboardTemporary") or T("dashboardLifetime")
    end
    if selectedTab=="games" then renderGames()
    elseif selectedTab=="releases" then renderReleases()
    elseif selectedTab=="settings" then renderSettings()
    else renderHome() end
end

screen=create("ScreenGui",{Name="PaporotnicUniversalLauncher",ResetOnSpawn=false,
    IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1000},playerGui)
-- Responsive premium desktop layout. The screenshot uses a 1.77 aspect ratio;
-- UIScale keeps it visible on 1366x768 and downscales on smaller viewports.
root=create("CanvasGroup",{
    Name="LayeredDashboardWindow",AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(1332,754),
    Active=true,Visible=false,BackgroundColor3=palette.background,
    BorderSizePixel=0,ClipsDescendants=true,GroupTransparency=1},screen)
corner(root,15)
local rootStroke=create("UIStroke",{Thickness=1,Color=palette.border,Transparency=1,Enabled=false},root)
premiumScale=create("UIScale",{Scale=1},root)
local function fitPremiumWindow()
    local camera=workspace.CurrentCamera
    local vp=camera and camera.ViewportSize or Vector2.new(1600,900)
    premiumScale.Scale=math.clamp(math.min((vp.X-28)/1332,(vp.Y-30)/754),0.48,1)
end
fitPremiumWindow()
if workspace.CurrentCamera then
    connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),fitPremiumWindow)
end

-- First visual layer: true graphic wallpaper. All controls are separate GUI elements.
dashboardWallpaper=create("ImageLabel",{
    Name="LayeredForestBackground",Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),
    Visible=showFoliage,BackgroundTransparency=1,BorderSizePixel=0,Image="",ImageTransparency=.69,
    ScaleType=Enum.ScaleType.Crop
},root)
attachLayer(dashboardWallpaper,"wallpaper")

local top=create("Frame",{Size=UDim2.new(1,0,0,77),Active=true,
    BackgroundColor3=palette.background,BorderSizePixel=0},root)
-- Fine green bottom accent, mirroring the reference's lime header line.
create("Frame",{Position=UDim2.fromOffset(0,75),Size=UDim2.new(1,0,0,2),
    BackgroundColor3=palette.border,BorderSizePixel=0},top)
-- Actual fern icon, manually extracted from the visual reference (not a faux P).
local brandMark=create("Frame",{
    Name="BrandMark",Position=UDim2.fromOffset(21,13),
    Size=UDim2.fromOffset(48,48),BackgroundColor3=palette.background,
    BackgroundTransparency=1,BorderSizePixel=0
},top)
local brandFallback=txt(brandMark,"",25,palette.highlight,48,Enum.TextXAlignment.Center)
brandFallback.Font=Enum.Font.GothamBold
local brandFern=create("ImageLabel",{
    Name="RealFernLogo",Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,BorderSizePixel=0,Image="",ScaleType=Enum.ScaleType.Fit
},brandMark)
attachLayer(brandFern,"fernLogo")
titleLabel=txt(top,"Paporotnic Hub",24,palette.text,37)
titleLabel.Font=Enum.Font.GothamBold
titleLabel.Position=UDim2.fromOffset(77,10)
titleLabel.Size=UDim2.fromOffset(244,38)
local subtitle=txt(top,"ROBLOX SCRIPT PLATFORM",10,palette.muted,20)
subtitle.Position=UDim2.fromOffset(79,47)
subtitle.Size=UDim2.fromOffset(239,19)
local accentLine=create("Frame",{Position=UDim2.fromOffset(0,75),
    Size=UDim2.fromOffset(238,2),BackgroundColor3=palette.highlight,BorderSizePixel=0},top)
create("UIGradient",{Rotation=0,Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.8)
})},accentLine)

local function headerChip(textValue,x,w)
    local chip=create("Frame",{Position=UDim2.fromOffset(x,20),Size=UDim2.fromOffset(w,36),
        BackgroundColor3=palette.panel,BorderSizePixel=0},top)
    corner(chip,19)
    create("UIStroke",{Color=palette.border,Thickness=1,Transparency=0.67},chip)
    local t=txt(chip,textValue,11,palette.text,36,Enum.TextXAlignment.Center)
    t.Font=Enum.Font.GothamBold
    return chip,t
end
local stateChip,stateText=headerChip("●  ACCESS VERIFIED",326,170)
local apiChip,apiText=headerChip("KEY SYSTEM",510,139)
local buildChip,buildText=headerChip("HUB  v0.2.28",663,150)

local profile=create("Frame",{Position=UDim2.new(1,-333,0,9),Size=UDim2.fromOffset(189,58),
    BackgroundColor3=palette.panel,BorderSizePixel=0},top)
corner(profile,25)
local avatar=create("ImageLabel",{Position=UDim2.fromOffset(8,6),Size=UDim2.fromOffset(46,46),
    Image="rbxthumb://type=AvatarHeadShot&id="..tostring(localPlayer.UserId).."&w=150&h=150",
    BackgroundColor3=palette.card,BorderSizePixel=0},profile)
corner(avatar,23)
create("UIStroke",{Color=palette.highlight,Thickness=1.8,Transparency=0.13},avatar)
premiumHeaderName=txt(profile,localPlayer.DisplayName,12,palette.text,21)
premiumHeaderName.Font=Enum.Font.GothamBold
premiumHeaderName.Position=UDim2.fromOffset(61,8)
premiumHeaderName.Size=UDim2.fromOffset(121,20)
premiumHeaderName.TextTruncate=Enum.TextTruncate.AtEnd
premiumHeaderType=txt(profile,"LICENSE VERIFIED",10,palette.highlight,20)
premiumHeaderType.Position=UDim2.fromOffset(62,29)
premiumHeaderType.Size=UDim2.fromOffset(121,19)
local topSettings=button(top,"⚙",36,36,function() navigateTo("settings") end,false)
topSettings.Position=UDim2.new(1,-133,0,19)
topSettings.TextSize=19
local collapse=button(top,"—",36,36,function() screen.Enabled=not screen.Enabled end,false)
collapse.Position=UDim2.new(1,-90,0,19)
local close=button(top,"×",36,36,function()
    if type(global.__PaporotnicLauncherStop)=="function" then global.__PaporotnicLauncherStop() end
end,false)
close.Position=UDim2.new(1,-47,0,19)
close.TextSize=24

local sidebar=create("Frame",{
    Name="DashboardSidebar",Position=UDim2.fromOffset(0,77),
    Size=UDim2.new(0,224,1,-77),BackgroundColor3=palette.background,
    BorderSizePixel=0},root)
create("Frame",{Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),
    BackgroundColor3=palette.border,BorderSizePixel=0},sidebar)
sidebar.ClipsDescendants=true
cornerFerns=create("ImageLabel",{
    Name="LayeredFernCornerDecor",Position=UDim2.fromOffset(0,-77),
    Size=UDim2.fromOffset(1332,750),Visible=showFoliage,BackgroundTransparency=1,
    BorderSizePixel=0,Image="",ImageTransparency=.06,
    ScaleType=Enum.ScaleType.Stretch
},sidebar)
attachLayer(cornerFerns,"fernCorners")
local sideAccent=create("Frame",{Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(4,332),
    BorderSizePixel=0,BackgroundColor3=palette.highlight,BackgroundTransparency=0.88},sidebar)
create("UIGradient",{Rotation=90,Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(1,1)
})},sideAccent)
local navOptions={
    {"home",nil,"  ","home"},
    {"games","games","  ","dashboardShortGames"},
    {"games","games","   ","scriptsGame"},
    {"games","universal","   ","scriptsUniversal"},
    {"releases",nil,"  ","releases"},
    {"settings",nil,"  ","settings"}
}
local scriptsGroup=txt(sidebar,"SCRIPTS",11,palette.muted,25)
scriptsGroup.Position=UDim2.fromOffset(26,140)
scriptsGroup.Size=UDim2.fromOffset(164,25)
scriptsGroup.Font=Enum.Font.GothamBold
for i,row in ipairs(navOptions) do
    local page,category,icon,labelKey=row[1],row[2],row[3],row[4]
    local positions={22,80,177,236,305,363}
    local y=positions[i]
    local nav=button(sidebar,icon..T(labelKey),197,i==1 and 48 or 42,function()
        navigateTo(page,category)
    end,false)
    nav.Name="Sidebar_"..(category or page)
    nav.TextSize=(i==3 or i==4) and 11 or 13
    nav.Position=UDim2.fromOffset(13,y)
    nav.TextXAlignment=Enum.TextXAlignment.Left
    create("UIPadding",{PaddingLeft=UDim.new(0,(i==3 or i==4) and 30 or 14)},nav)
    corner(nav,9)
    -- Game Scripts and Games share a destination; main Games stays as a
    -- conventional navigation entry while the subtab highlights the category.
    table.insert(sidebarButtons,{button=nav,page=page,category=category,prefix=icon,labelKey=labelKey})
end
local separator=create("Frame",{Position=UDim2.fromOffset(14,419),Size=UDim2.fromOffset(194,1),
    BackgroundColor3=palette.border,BorderSizePixel=0},sidebar)

local accessSection=create("Frame",{
    Name="SidebarAccessCard",Position=UDim2.new(0,12,1,-241),
    Size=UDim2.new(1,-25,0,223),BackgroundColor3=palette.panel,BorderSizePixel=0
},sidebar)
corner(accessSection,14)
create("UIStroke",{Thickness=1,Color=palette.border,Transparency=0.62},accessSection)
local sideTitle=txt(accessSection,T("dashboardAccess"),14,palette.text,30)
sideTitle.Font=Enum.Font.GothamBold
sideTitle.Position=UDim2.fromOffset(12,10)
sideTitle.Size=UDim2.new(1,-24,0,29)
local sideKeyType=txt(accessSection,"—",12,palette.highlight,24)
sideKeyType.Name="SideKeyType"
sideKeyType.Position=UDim2.fromOffset(13,48)
sideKeyType.Size=UDim2.new(1,-26,0,24)
sidebarAccessText=txt(accessSection,"—",12,palette.text,27)
sidebarAccessText.Position=UDim2.fromOffset(13,78)
sidebarAccessText.Size=UDim2.new(1,-26,0,27)
local sideServer=txt(accessSection,"● VERIFIED BY VPS",10,palette.highlight,25)
sideServer.Position=UDim2.fromOffset(13,107)
sideServer.Size=UDim2.new(1,-26,0,25)
local sideSwitch=button(accessSection,T("switchKey"),170,39,function()
    if type(returnToAuthGate)=="function" then returnToAuthGate() end
end,true)
sideSwitch.Name="SidebarSwitchKey"
sideSwitch.Position=UDim2.fromOffset(13,144)
sideSwitch.TextSize=12
corner(sideSwitch,9)
local sideHide=button(accessSection,"F7  ·  HIDE",170,29,function() screen.Enabled=false end,false)
sideHide.Position=UDim2.fromOffset(13,187)
sideHide.TextSize=10
sideHide.BackgroundTransparency=0.34
corner(sideHide,8)

content=create("Frame",{
    Name="PageContent",Position=UDim2.fromOffset(239,93),
    Size=UDim2.new(1,-573,1,-116),BackgroundTransparency=1
},root)
rightRail=create("Frame",{
    Name="DashboardRightRail",Position=UDim2.new(1,-313,0,93),
    Size=UDim2.fromOffset(296,637),BackgroundTransparency=1
},root)
local function rrLabel(parent,val,size,color,x,y,w,h,bold)
    local t=txt(parent,val,size,color or palette.text,h)
    t.Position=UDim2.fromOffset(x,y)
    t.Size=UDim2.fromOffset(w,h)
    t.TextWrapped=true
    if bold then t.Font=Enum.Font.GothamBold end
    return t
end
local function rrPanel(y,height)
    local p=create("Frame",{Position=UDim2.fromOffset(0,y),Size=UDim2.fromOffset(295,height),
        BackgroundColor3=palette.panel,BorderSizePixel=0},rightRail)
    corner(p,13)
    create("UIStroke",{Color=palette.border,Transparency=0.62,Thickness=1},p)
    return p
end
renderRightRail=function()
    if not rightRail or not rightRail.Parent then return end
    for _,child in ipairs(rightRail:GetChildren()) do child:Destroy() end
    local L=function(ru,en) return lang=="ru" and ru or en end
    local access=rrPanel(0,184)
    rrLabel(access,"♛  "..L("Доступ","Access Status"),16,palette.text,13,10,180,29,true)
    local active=create("Frame",{Position=UDim2.fromOffset(215,14),Size=UDim2.fromOffset(66,22),
        BackgroundColor3=palette.highlight,BackgroundTransparency=0.83,BorderSizePixel=0},access)
    corner(active,12)
    create("UIStroke",{Color=palette.highlight,Thickness=1,Transparency=0.21},active)
    rrLabel(active,"ACTIVE",10,palette.highlight,7,2,60,18,true)
    local timeText= approvedKeyKind=="temporary" and
        (type(approvedSecondsLeft)=="number" and
            (tostring(math.max(1,math.ceil(approvedSecondsLeft/3600))).."h "..L("осталось","left")) or L("Ограничен","Limited")) or L("Никогда","Never")
    local rows={
        {L("Тип лицензии","License Type"),approvedKeyKind=="temporary" and L("Временный","Temporary") or "Lifetime"},
        {L("Срок","Expires"),timeText},
        {"HWID",(type(gethwid)=="function" or type(global.gethwid)=="function") and L("Доступен","Available") or L("Нет API","Not available")},
        {L("Проверка","Verification"),"VERIFIED"},
    }
    for i,r in ipairs(rows) do
        local y=47+(i-1)*30
        rrLabel(access,r[1],11,palette.muted,16,y,150,22,false)
        local v=rrLabel(access,r[2],11,(i==1 or i==2 or i==3 or i==4) and palette.highlight or palette.text,169,y,112,22,true)
        v.TextXAlignment=Enum.TextXAlignment.Right
        if i~=4 then
            create("Frame",{Position=UDim2.fromOffset(14,y+27),Size=UDim2.fromOffset(267,1),
                BackgroundColor3=palette.border,BackgroundTransparency=0.55,BorderSizePixel=0},access)
        end
    end
    local server=rrPanel(197,126)
    rrLabel(server,"▤  "..L("Статус систем","System Status"),15,palette.text,13,10,254,27,true)
    local srv={
        {L("Проверка ключа","Key verification"),"PASSED"},
        {L("Каталог модулей","Module catalog"),catalogOk and L("ЗАГРУЖЕН","LOADED") or "OFFLINE"},
        {L("Мониторинг 24/7","Live uptime"),L("НЕТ ДАННЫХ","NOT TRACKED")}
    }
    for i,r in ipairs(srv) do
        rrLabel(server,"●",11,i==3 and palette.muted or palette.highlight,14,38+(i-1)*26,13,21,true)
        rrLabel(server,r[1],10,palette.muted,30,38+(i-1)*26,148,21,false)
        local v=rrLabel(server,r[2],10,i==3 and palette.muted or (r[2]=="OFFLINE" and palette.alert or palette.highlight),174,38+(i-1)*26,105,21,true)
        v.TextXAlignment=Enum.TextXAlignment.Right
    end
    local announces=rrPanel(337,134)
    rrLabel(announces,"◈  "..L("Объявления","Announcements"),15,palette.text,13,9,270,28,true)
    local note=create("Frame",{Position=UDim2.fromOffset(10,40),Size=UDim2.fromOffset(274,83),
        BackgroundColor3=palette.card,BorderSizePixel=0},announces)
    corner(note,9)
    rrLabel(note,"✦  "..L("Добро пожаловать!","Welcome to Paporotnic"),12,palette.text,10,8,249,23,true)
    local message=tostring(catalog.announcement or L("Больше игр скоро.","More modules coming soon."))
    local announcetext=rrLabel(note,message,10,palette.muted,11,30,253,49,false)
    announcetext.TextYAlignment=Enum.TextYAlignment.Top
    announcetext.TextTruncate=Enum.TextTruncate.AtEnd
    local updates=rrPanel(485,150)
    rrLabel(updates,"↻  "..L("Обновления","Latest Updates"),15,palette.text,13,8,250,28,true)
    local recent={
        {"v0.2.28",L("Редактор оформления","Theme Editor")},
        {"v0.2.27",L("Слои и графика","Layered Visual Fix")},
        {"v0.2.26",L("Чистый интерфейс","Clean Rework")},
        {"v0.2.25",L("Premium Dashboard","Premium Dashboard")},
        {"v0.2.24",L("Главная страница","Home Foundation")},
    }
    for i,r in ipairs(recent) do
        local y=40+(i-1)*26
        local bg=create("Frame",{Position=UDim2.fromOffset(10,y),Size=UDim2.fromOffset(275,23),
            BorderSizePixel=0,BackgroundColor3=i==1 and palette.card or palette.panel},updates)
        if i==1 then corner(bg,6) end
        rrLabel(bg,r[1],10,i==1 and palette.highlight or palette.muted,7,0,64,21,true)
        rrLabel(bg,r[2],10,palette.text,81,0,181,21,false)
    end
end

-- Existing status is preserved, now as a subtle bottom overlay (not a fake monitor).
statusLabel=txt(root,"",11,palette.highlight,23)
statusLabel.Position=UDim2.new(0,239,1,-26)
statusLabel.Size=UDim2.new(1,-572,0,22)
statusLabel.TextXAlignment=Enum.TextXAlignment.Center
footerLabel=txt(root,"",9,palette.muted,18)
footerLabel.Position=UDim2.new(1,-315,1,-20)
footerLabel.Size=UDim2.new(0,295,0,18)
footerLabel.TextXAlignment=Enum.TextXAlignment.Center

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
    returnToAuthGate=nil
    authenticated=false
    approvedKey=nil
    approvedKeyKind=nil
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

-- Intro and login share a single fixed-size panel. The existing screen blur
-- remains until the key has been verified; the full hub is inaccessible before then.
local function playLaunchIntro()
    local overlay=create("Frame",{
        Name="PaporotnicGateOverlay", Size=UDim2.fromScale(1,1),
        Position=UDim2.fromScale(0,0), BackgroundColor3=palette.background,
        BackgroundTransparency=0.57, BorderSizePixel=0,
        Active=true, ZIndex=100
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

    local glow=create("Frame",{
        Name="GateAmbientGlow", AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(514,394),
        BackgroundColor3=palette.highlight,BackgroundTransparency=0.975,
        BorderSizePixel=0,ZIndex=101
    },overlay)
    corner(glow,22)
    create("UIStroke",{Thickness=8,Color=palette.highlight,Transparency=0.965},glow)

    local gate=create("Frame",{
        Name="AccessGate", AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(480,370),
        BackgroundColor3=palette.panel, BackgroundTransparency=0.025,
        BorderSizePixel=0,ZIndex=102
    },overlay)
    corner(gate,15)
    create("UIStroke",{Thickness=1.5,Color=palette.highlight,Transparency=0.62},gate)

    local miniAccent=create("Frame",{
        Position=UDim2.fromOffset(28,28),Size=UDim2.fromOffset(34,3),
        BackgroundColor3=palette.highlight,BorderSizePixel=0,ZIndex=103
    },gate)
    corner(miniAccent,3)

    local bootBody=create("CanvasGroup",{
        Name="BootContent", Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,GroupTransparency=0,ZIndex=104
    },gate)
    local authBody=create("CanvasGroup",{
        Name="AuthContent", Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,GroupTransparency=1,Visible=false,ZIndex=104
    },gate)

    local bootTitle=txt(bootBody,"PAPOROTNIC HUB",32,palette.text,50)
    bootTitle.Font=Enum.Font.GothamBold
    bootTitle.Position=UDim2.fromOffset(28,89)
    bootTitle.Size=UDim2.new(1,-56,0,50)
    local bootSub=txt(bootBody,T("gateProgress"),12,palette.muted,22)
    bootSub.Position=UDim2.fromOffset(29,144)
    bootSub.Size=UDim2.new(1,-58,0,22)

    local progressTrack=create("Frame",{
        Position=UDim2.fromOffset(29,215),Size=UDim2.new(1,-58,0,11),
        BackgroundColor3=palette.card,BorderSizePixel=0,ClipsDescendants=true
    },bootBody)
    corner(progressTrack,8)
    create("UIStroke",{Thickness=1,Color=palette.border,Transparency=0.55},progressTrack)
    local progressFill=create("Frame",{
        Name="ProgressFill",Size=UDim2.fromScale(0,1),
        BackgroundColor3=palette.highlight,BorderSizePixel=0
    },progressTrack)
    corner(progressFill,8)
    create("UIGradient",{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,palette.highlight:Lerp(palette.text,0.28)),
        ColorSequenceKeypoint.new(1,palette.highlight)
    })},progressFill)

    local loadingLabel=txt(bootBody,T("gateLoading"),12,palette.muted,25)
    loadingLabel.Position=UDim2.fromOffset(29,241)
    loadingLabel.Size=UDim2.new(0.72,0,0,25)
    local progressLabel=txt(bootBody,"0%",15,palette.highlight,25,Enum.TextXAlignment.Right)
    progressLabel.Font=Enum.Font.GothamBold
    progressLabel.Position=UDim2.new(1,-126,0,241)
    progressLabel.Size=UDim2.fromOffset(97,25)
    local bootFoot=txt(bootBody,"PAPOROTNIC  /  ACCESS CONTROL",10,palette.muted,20)
    bootFoot.Position=UDim2.fromOffset(29,335)
    bootFoot.Size=UDim2.new(1,-58,0,20)

    local authTitle=txt(authBody,"PAPOROTNIC HUB",27,palette.text,42)
    authTitle.Font=Enum.Font.GothamBold
    authTitle.Position=UDim2.fromOffset(28,55)
    authTitle.Size=UDim2.new(1,-56,0,42)
    local authSub=txt(authBody,T("gateSubtitle"),13,palette.muted,24)
    authSub.Position=UDim2.fromOffset(29,94)
    authSub.Size=UDim2.new(1,-58,0,24)

    authInput=create("TextBox",{
        Name="AccessKeyInput",Size=UDim2.new(1,-58,0,42),
        Position=UDim2.fromOffset(29,132),BackgroundColor3=palette.card,
        BackgroundTransparency=0.05,BorderSizePixel=0,ClearTextOnFocus=false,
        Text="",PlaceholderText=T("key"),Font=Enum.Font.Gotham,
        TextSize=15,TextColor3=palette.text,PlaceholderColor3=palette.muted,
        TextXAlignment=Enum.TextXAlignment.Left
    },authBody)
    corner(authInput,8)
    pad(authInput,13,0)
    create("UIStroke",{Thickness=1,Color=palette.border,Transparency=0.28},authInput)

    local prefilledRecentKey=nil
    -- A one-click privacy control on the login screen. It is visible only
    -- when a verified temporary key has been prefilled from the local cache.
    recentForgetButton=button(authBody,T("recentForget"),116,22,function()
        if not alive or uiPhase~="AUTH" or verifyingKey then return end
        local cleared=clearRecentTemporaryKey()
        prefilledRecentKey=nil
        if authInput then authInput.Text="" end
        if recentForgetButton then recentForgetButton.Visible=false end
        info(cleared and T("recentForgot") or T("recentForgetError"),not cleared)
    end,false)
    recentForgetButton.Name="ForgetRecentTemporaryKey"
    recentForgetButton.Position=UDim2.fromOffset(335,179)
    recentForgetButton.TextSize=10
    recentForgetButton.Visible=false

    authStatusLabel=txt(authBody,T("gateIdle"),12,palette.muted,22)
    authStatusLabel.Name="KeyStatus"
    authStatusLabel.Position=UDim2.fromOffset(29,179)
    authStatusLabel.Size=UDim2.new(1,-185,0,22)
    authStatusLabel.TextWrapped=false

    authSubmitButton=button(authBody,T("enter"),422,43,nil,true)
    authSubmitButton.Name="ActivateKeyButton"
    authSubmitButton.Position=UDim2.fromOffset(29,218)

    -- Reserved actions for upcoming key distribution / lifetime purchase.
    -- These are visual-only placeholders: no URL, payment or key issuance yet.
    local keyActions=create("Frame",{
        Name="KeyOptions", Position=UDim2.fromOffset(29,276),
        Size=UDim2.fromOffset(422,40), BackgroundTransparency=1,
        BorderSizePixel=0
    },authBody)

    local getKeyButton=create("TextButton",{
        Name="GetKeyButton", Position=UDim2.fromOffset(0,0),
        Size=UDim2.fromOffset(205,40), BackgroundColor3=Color3.fromRGB(245,195,65),
        BorderSizePixel=0, Text="",
        AutoButtonColor=false, Active=false, Selectable=false
    },keyActions)
    corner(getKeyButton,9)
    create("TextLabel",{
        Name="GetKeyLabel", Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1, Text="GET KEY",
        Font=Enum.Font.GothamBold, TextSize=13,
        TextColor3=Color3.fromRGB(49,34,9)
    },getKeyButton)
    create("UIGradient",{
        Rotation=10,
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,230,132)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(239,169,43))
        })
    },getKeyButton)
    create("UIStroke",{
        Thickness=1.4, Color=Color3.fromRGB(255,223,116), Transparency=0.36
    },getKeyButton)

    local lifetimeButton=create("TextButton",{
        Name="LifetimeButton", Position=UDim2.fromOffset(217,0),
        Size=UDim2.fromOffset(205,40), BackgroundColor3=Color3.fromRGB(24,103,69),
        BorderSizePixel=0, Text="",
        AutoButtonColor=false, Active=false, Selectable=false
    },keyActions)
    corner(lifetimeButton,9)
    create("TextLabel",{
        Name="LifetimeLabel", Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1, Text="LIFETIME",
        Font=Enum.Font.GothamBold, TextSize=13,
        TextColor3=Color3.fromRGB(241,255,246)
    },lifetimeButton)
    local lifetimeGradient=create("UIGradient",{
        Offset=Vector2.new(-0.35,0),
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(18,80,57)),
            ColorSequenceKeypoint.new(0.35,Color3.fromRGB(35,139,97)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(95,209,148)),
            ColorSequenceKeypoint.new(0.65,Color3.fromRGB(35,139,97)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(18,80,57))
        })
    },lifetimeButton)
    local lifetimeGlow=create("UIStroke",{
        Thickness=1.8, Color=Color3.fromRGB(98,238,163), Transparency=0.55
    },lifetimeButton)
    -- Soft emerald shimmer, deliberately subtle and never flashing.
    TweenService:Create(lifetimeGradient,
        TweenInfo.new(3.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
        {Offset=Vector2.new(0.35,0)}):Play()
    TweenService:Create(lifetimeGlow,
        TweenInfo.new(2.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
        {Transparency=0.20,Thickness=2.3}):Play()

    local authFoot=txt(authBody,"PAPOROTNIC  /  SECURE ACCESS",10,palette.muted,20)
    authFoot.Position=UDim2.fromOffset(29,336)
    authFoot.Size=UDim2.new(1,-58,0,20)

    local close=button(gate,"X",29,29,function() stop() end,false)
    close.Name="CloseGate"
    close.Position=UDim2.new(1,-47,0,18)
    close.TextSize=13
    close.ZIndex=110

    local function revealMain()
        if not alive or uiPhase~="UNLOCKING" or not overlay.Parent then return end
        -- Keep UNLOCKING until the UI transition has completed.
        root.Visible=true
        -- Keep the main window at its original 980 x 720 size, but reveal it
        -- only after successful server authorization.
        local t=TweenInfo.new(0.70,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
        local mainFade=TweenService:Create(root,t,{GroupTransparency=0})
        local backdropFade=TweenService:Create(overlay,t,{BackgroundTransparency=1})
        local gateFade=TweenService:Create(gate,t,{BackgroundTransparency=1})
        local bootOrAuthFade=TweenService:Create(authBody,t,{GroupTransparency=1})
        local glowFade=TweenService:Create(glow,t,{BackgroundTransparency=1})
        local blurFade=TweenService:Create(blur,t,{Size=0})
        mainFade:Play()
        backdropFade:Play()
        gateFade:Play()
        bootOrAuthFade:Play()
        glowFade:Play()
        blurFade:Play()
        mainFade.Completed:Wait()
        if not alive or not root.Parent then return end
        root.GroupTransparency=0
        rootStroke.Enabled=true
        TweenService:Create(rootStroke,TweenInfo.new(0.24,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
            Transparency=0
        }):Play()
        -- Preserve the activation gate for Switch Key (no 3-second boot again).
        -- Hiding the whole overlay removes its click surface from the hub.
        if overlay.Parent then overlay.Visible=false end
        if introBlur==blur then
            blur.Size=0
            blur.Enabled=false
        end
        uiPhase="MAIN"
    end

    -- Return to the original gate. Switching keys is also a local logout:
    -- drop the remembered credential, so developer tests can start clean.
    returnToAuthGate = function()
        if not alive or uiPhase~="MAIN" then return end
        if verifyingKey then
            info(T("switchBusy"),true)
            return
        end
        sessionEpoch = sessionEpoch + 1
        rememberMe=false
        local cacheCleared=not supportsSessionFiles or clearSessionKey()
        local recentCleared=not supportsSessionFiles or clearRecentTemporaryKey()
        local preferenceCleared=not supportsSessionFiles or savePreferences()
        authenticated=false
        approvedKey=nil
        approvedKeyKind=nil
        approvedSecondsLeft=nil
        selectedTab="home"
        statusText=""
        if statusLabel then statusLabel.Text="" end
        if authInput then authInput.Text="" end
        prefilledRecentKey=nil
        if recentForgetButton then recentForgetButton.Visible=false end
        uiPhase="AUTH"
        if authStatusLabel then
            local cacheOk=cacheCleared and recentCleared and preferenceCleared
            authStatusLabel.Text=cacheOk and T("switchReady") or T("rememberDeleteError")
            authStatusLabel.TextColor3=cacheOk and palette.muted or palette.alert
        end
        if authSubmitButton then
            authSubmitButton.Text=T("enter")
            authSubmitButton.Active=true
            authSubmitButton.AutoButtonColor=true
        end

        -- Fail closed: fully hide the unlocked interface before showing AUTH.
        root.Visible=false
        root.GroupTransparency=1
        rootStroke.Enabled=false
        overlay.Visible=true
        overlay.BackgroundTransparency=0.57
        gate.BackgroundTransparency=0.025
        glow.BackgroundTransparency=0.975
        bootBody.Visible=false
        authBody.Visible=true
        authBody.GroupTransparency=0
        if blur.Parent then
            blur.Size=0
            blur.Enabled=true
            TweenService:Create(blur,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
                Size=9
            }):Play()
        end
    end

    local function finishActivation()
        if not alive or uiPhase~="AUTH" or not authenticated then return end
        -- A verified temporary key is cached solely for MANUAL prefill.
        -- Lifetime keys are never cached unless Remember Me was enabled.
        if rememberMe and type(approvedKey)=="string" then
            if not saveSessionKey(approvedKey) then
                rememberMe=false
                clearSessionKey()
                savePreferences()
                if approvedKeyKind=="temporary" then saveRecentTemporaryKey(approvedKey) end
                info(T("rememberSaveError"),true)
            else
                clearRecentTemporaryKey()
            end
        elseif approvedKeyKind=="temporary" and type(approvedKey)=="string" then
            saveRecentTemporaryKey(approvedKey)
        else
            -- Last successful sign-in was Lifetime: do not keep a previous
            -- temporary key as the "most recent" login.
            clearRecentTemporaryKey()
        end
        if not rememberMe then clearSessionKey() end -- purge any stale auto-login file
        uiPhase="UNLOCKING"
        authSubmitButton.Text=T("gateReady")
        task.delay(0.42,function()
            if alive then revealMain() end
        end)
    end

    local function submitKey()
        if not alive or uiPhase~="AUTH" or verifyingKey then return end
        local entered=authInput.Text
        verifyKey(entered,finishActivation,function(reason)
            -- Definitive rejection of an old prefilled temporary key.
            -- Never erase a different cached key or clear on network errors.
            local old=readRecentTemporaryKey()
            if old and old==entered and (reason=="expired" or reason=="revoked" or reason=="invalid_key") then
                clearRecentTemporaryKey()
                prefilledRecentKey=nil
                if recentForgetButton then recentForgetButton.Visible=false end
            end
        end)
    end
    connect(authSubmitButton.MouseButton1Click,submitKey)
    connect(authInput.FocusLost,function(enterPressed)
        if enterPressed then submitKey() end
    end)
    connect(authInput:GetPropertyChangedSignal("Text"),function()
        if uiPhase=="AUTH" and not verifyingKey then
            if recentForgetButton then
                recentForgetButton.Visible=(prefilledRecentKey~=nil and authInput.Text==prefilledRecentKey)
            end
            authStatusLabel.Text=T("gateIdle")
            authStatusLabel.TextColor3=palette.muted
        end
    end)

    -- A genuine 0→100 counter with a 3.15-second linear animation. There is
    -- no progress-jumping or early reveal on fast clients.
    local counter=Instance.new("NumberValue")
    counter.Name="PaporotnicBootProgress"
    counter.Value=0
    counter.Parent=overlay
    connect(counter:GetPropertyChangedSignal("Value"),function()
        if not alive or not progressFill.Parent then return end
        local fraction=math.clamp(counter.Value/100,0,1)
        progressFill.Size=UDim2.new(fraction,0,1,0)
        progressLabel.Text=string.format("%d%%",math.floor(counter.Value+0.5))
    end)
    local counterTween=TweenService:Create(counter,TweenInfo.new(3.15,Enum.EasingStyle.Linear),{
        Value=100
    })
    counterTween:Play()
    counterTween.Completed:Wait()
    if not alive or not overlay.Parent then return end
    progressFill.Size=UDim2.fromScale(1,1)
    progressLabel.Text="100%"
    loadingLabel.Text=T("gateReady")
    counter:Destroy()

    task.wait(0.22)
    if not alive or not overlay.Parent then return end
    authBody.Visible=true
    local transition=TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    TweenService:Create(bootBody,transition,{GroupTransparency=1}):Play()
    local authFade=TweenService:Create(authBody,transition,{GroupTransparency=0})
    authFade:Play()
    authFade.Completed:Wait()
    if not alive or not overlay.Parent then return end
    bootBody.Visible=false
    uiPhase="AUTH"
    if not catalogOk then
        info(T("authNeedServer"),true)
    else
        authStatusLabel.Text=T("gateIdle")
        -- Without Remember Me, ONLY prefill the last verified temporary key;
        -- do not attempt auto-login and never prefill Lifetime credentials.
        if not rememberMe then
            local lastTemporary=readRecentTemporaryKey()
            if lastTemporary then
                prefilledRecentKey=lastTemporary
                authInput.Text=lastTemporary
                authStatusLabel.Text=T("recentPrefilled")
                if recentForgetButton then recentForgetButton.Visible=true end
            end
        end
        -- One auto-login attempt per launch. Even a saved key MUST pass the
        -- existing HTTPS verifier and HWID binding before revealing the hub.
        local savedKey=readSessionKey()
        if savedKey then
            authStatusLabel.Text=T("rememberChecking")
            verifyKey(savedKey,finishActivation,function()
                -- Only a definite server rejection invalidates a cache.
                rememberMe=false
                clearSessionKey()
                savePreferences()
            end)
        end
    end
end

task.spawn(playLaunchIntro)
print("[Paporotnic Universal Launcher] v0.2.28 | PlaceId="..tostring(game.PlaceId))
