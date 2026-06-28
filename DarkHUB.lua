local Fluent           = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local Stats            = game:GetService("Stats")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer
local Options          = Fluent.Options

local Booted = false
local function notify(o) if Booted then Fluent:Notify(o) end end

local protectHumanoid, protectHRP
local Mouse = LocalPlayer:GetMouse()
local getSilentTarget

local F = {
    speed = false, noclip = false, fly = false,
    antiKickBan = false, remoteBlock = false,
    silentAim = false,
}

local _RC = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local function _RS(n)
    local t = {}
    for i = 1, n do local r = math.random(1, #_RC); t[i] = _RC:sub(r, r) end
    return table.concat(t)
end
local _TAG     = _RS(7)
local _GLS     = "_" .. _RS(13)
local _GRQ     = "_" .. _RS(13)
local _BB_NAME = _TAG .. _RS(4)
local _BV_NAME = _TAG .. _RS(4)
local _BG_NAME = _TAG .. _RS(4)

local function opt(k) local o = Options[k]; return o and o.Value end
local function getChar() return LocalPlayer.Character end
local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function disconnectAll(t)
    for _, c in ipairs(t) do pcall(function() c:Disconnect() end) end
    table.clear(t)
end

local function playerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then list[#list + 1] = p.Name end
    end
    return #list > 0 and list or { "(none)" }
end

local function httpGet(url)
    local fn = (syn and syn.request) or (http and http.request) or http_request or request
    if fn then
        local ok, res = pcall(fn, { Url = url, Method = "GET" })
        if ok and res and res.Body then return res.Body end
    end
    return game:HttpGet(url)
end

local preExistingGuis = {}
pcall(function()
    for _, g in ipairs(LocalPlayer.PlayerGui:GetChildren()) do preExistingGuis[g] = true end
end)

local Window = Fluent:CreateWindow({
    Title       = "DarkHUB",
    SubTitle    = "Universal Script",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = false,
    Theme       = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl,
})
Fluent:ToggleTransparency(false)

local function protectGui()
    pcall(function()
        local hui = pcall(function() return gethui() end) and gethui()
        for _, g in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            if not preExistingGuis[g] then
                pcall(function()
                    if syn and syn.protect_gui then syn.protect_gui(g) end
                    if protect_gui then protect_gui(g) end
                    if hui then g.Parent = hui end
                end)
            end
        end
    end)
end

local Tabs = {
    Player   = Window:AddTab({ Title = "Player",   Icon = "user"     }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "move"     }),
    Visuals  = Window:AddTab({ Title = "Visuals",  Icon = "eye"      }),
    Combat   = Window:AddTab({ Title = "Combat",   Icon = "swords"   }),
    Fling    = Window:AddTab({ Title = "Fling",    Icon = "wind"     }),
    Bypass   = Window:AddTab({ Title = "Bypass",   Icon = "shield"   }),
    External = Window:AddTab({ Title = "External", Icon = "package"  }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local BAN_PATS = {
    "ban","banned","bancheck","checkban","isban","banstatus","banplayer","tempban","permban",
    "blacklist","blocklist","punish","suspend","penalt","sanction","unban","banlist",
    "banuser","bandata","bansystem","banmanager","banhandler","getban","setban","addban",
    "banreason","banlog","banrecord","baninfo","banentry","banstore","bandb",
    "banwave","flagged","flaguser","flaglog","restrictuser","restriction","restric",
    "databreach","penaltysystem","moderationlog","modaction","modlog","modban",
}
local KICK_PATS = {
    "kick","boot","kickplayer","kickuser","forceleave","removeplayer","disconnectplayer",
    "kickclient","kicklocal","kickme","forcedc","forceout","kickall","ejector",
    "forcedisconnect","forcelogout","terminate","expel","evict","eject","forceremove",
}
local AC_PATS = {
    "anticheat","anti_cheat","anticheater","antihack","anti_hack","antiac",
    "detecthack","hackdetect","hackcheck","hackfound","hackwarn","hackalert",
    "exploitdetect","exploitcheck","checkexploit","isexploit","exploitfound","exploitguard","exploitalert",
    "scripthunt","scriptdetect","scriptcheck","scriptguard","scriptfound","scriptscan",
    "cheatchecker","cheatdetect","cheatercheck","cheaterdetect","cheaterreport","cheateralert",
    "antiexploit","anti_exploit","exploitprevention",
    "securitycheck","security_check","securitymonitor","securityreport","securitylog","securitysystem",
    "gameguard","gameguardian","gameprotect","gamesecurity","gameintegrity","gamepolice",
    "playerguard","playerprotect","playercheck","playermonitor","playerwatch","playerverify",
    "reportcheat","reportexploit","flagcheat","flagexploit","reportplayer","flagplayer","reportuser",
    "monitorplayer","watchplayer","surveillanceplayer","scanplayer","probeplayer",
    "bandetect","kickdetect","kickcheck","banmonitor",
    "ac_","_ac","_ac_","accheck","acscan","aclog","acreport","acsystem",
    "integritycheck","trustcheck","validateplayer","verifyclient","clientcheck",
    "protector","enforcer","warden","sentinel","guardian","sheriff",
    "telemetry","anomalydetect","anomalycheck","ratelimitcheck","trustscore","violat",
    "suspicious","suspectlog","watchdog","watchservice","sentry","patrol","overseer",
    "auditlog","reportlog","detectionlog","filterlog","filterevent","filtercheck",
    "admincheck","moderator","modcheck","modguard","moderationcheck","modverify",
}
local AC_SOURCE_PATS = {
    "identifyexecutor","getexecutorname","is_sirhurt_closure","checkcaller",
    "getrawmetatable","setreadonly","getnamecallmethod","hookmetamethod",
    "syn%.","krnl","fluxus","delta_loaded","electron_loaded","celery_loaded",
    "antiexploit","anticheat","anti_cheat","detectexploit","hackdetect",
    "getconnections","hookfunction","replaceclosure","newcclosure","clonefunction",
    "getscriptbytecode","decompile","getscripthash","firesignal",
    "gethiddenproperty","sethiddenproperty","getupvalues","getprotos",
}
local EXECUTOR_GLOBALS = {
    "syn","SYNAPSE_LOADED","issynapse","is_sirhurt_closure","getsynasset","ssm","proto_syn",
    "KRNL_LOADED","KRNL_BYPASS","krnl","fluxus","FLUXUS_LOADED","fluxus_request",
    "Delta","DELTA_LOADED","Electron","ELECTRON_LOADED","Celery","CELERY_LOADED","Calamari","CALAMARI_LOADED",
    "elysian","oxygen","pebc","SW","SCRIPTWARE","SCRIPTWARE_LOADED","Axios","AXIOS_LOADED",
    "Nihon","NIHON_LOADED","ProtoSmasher","PROTOSMASHER_LOADED","Sentinel","SENTINEL_LOADED",
    "Vape","VAPE_LOADED","JJSploit","HttpSpy","HORIZON_LOADED","horizon","Coco_Z","COCOZ_LOADED",
    "Infiltrate","INFILTRATE","secure_call","identifyexecutor","getexecutorname",
    "rconsolecreate","rconsoledestroy","rconsolesettitle","rconsoleprint","rconsoleclear",
    "consolecreate","consoledestroy","consolesettitle","consoleprint",
    "getconnections","getrawmetatable","setreadonly","newcclosure","clonefunction",
    "hookmetamethod","hookfunction","replaceclosure",
    "getupvalues","getupvalue","setupvalue","getprotos","getproto","getconsts","getconstants","setconstant",
    "getgc","getinstances","getnilinstances","filtergc","iscclosure","islclosure","checkcaller",
    "getscriptbytecode","decompile","getscripthash","getscriptenviroment",
    "firesignal","fireclickdetector","fireproximityprompt","gethiddenproperty","sethiddenproperty",
    "readfile","writefile","appendfile","delfile","listfiles","isfile","isfolder","makefolder","delfolder",
    "request","http_request","websocket","cloneref","compareinstances","Drawing","cleardrawcache","isrenderobj",
}
local AC_URL_PATS = {
    "anticheat","exploit","cheatreport","hackdetect","moderation/report","bancheck","trustcheck",
}

local EXECUTOR_GLOBALS_SET = {}
for _, g in ipairs(EXECUTOR_GLOBALS) do EXECUTOR_GLOBALS_SET[g] = true end

local function matchesList(name, list)
    local n = name:lower()
    for _, p in ipairs(list) do
        if n:find(p, 1, true) then return true end
    end
    return false
end
local function matchesAC(n)   return matchesList(n, AC_PATS)   end
local function matchesBan(n)  return matchesList(n, BAN_PATS)  end
local function matchesKick(n) return matchesList(n, KICK_PATS) end
local function matchesACUrl(url)
    if type(url) ~= "string" then return false end
    local u = url:lower()
    for _, p in ipairs(AC_URL_PATS) do
        if u:find(p, 1, true) then return true end
    end
    return false
end

local _statsDummy = { disabled = 0, destroyed = 0, conns = 0 }

local function disableSignal(signal)
    if not getconnections then return 0 end
    local count = 0
    local ok, conns = pcall(getconnections, signal)
    if ok and conns then
        for _, c in ipairs(conns) do pcall(function() c:Disconnect(); count += 1 end) end
    end
    return count
end

local function nukeInstance(v, stats)
    pcall(function()
        if v:IsA("RemoteEvent") then
            stats.conns += disableSignal(v.OnClientEvent)
        elseif v:IsA("BindableEvent") then
            stats.conns += disableSignal(v.Event)
        elseif v:IsA("RemoteFunction") then
            pcall(function() v.OnClientInvoke = function() return nil end end)
        elseif v:IsA("BindableFunction") then
            pcall(function() v.OnInvoke = function() return nil end end)
        elseif v:IsA("LocalScript") or v:IsA("Script") then
            pcall(function() v.Disabled = true; stats.disabled += 1 end)
        end
        pcall(function() v:Destroy(); stats.destroyed += 1 end)
    end)
end

local function readSource(v)
    local src = ""
    pcall(function() src = v.Source or "" end)
    if src == "" and decompile then
        pcall(function() src = decompile(v) or "" end)
    end
    return src:lower()
end

local function sourceIsAC(v)
    local src = readSource(v)
    if src == "" then return false end
    for _, p in ipairs(AC_SOURCE_PATS) do
        if src:find(p, 1, true) then return true end
    end
    return false
end

local function scanRoots(roots, deepSource)
    local stats = { disabled = 0, destroyed = 0, conns = 0 }
    for _, root in ipairs(roots) do
        pcall(function()
            for _, v in ipairs(root:GetDescendants()) do
                pcall(function()
                    local n = v.Name
                    if v:IsA("LocalScript") or v:IsA("Script") then
                        if matchesAC(n) or matchesBan(n) or matchesKick(n) or (deepSource and sourceIsAC(v)) then
                            nukeInstance(v, stats)
                        end
                    elseif v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
                        if matchesAC(n) or matchesBan(n) or matchesKick(n) then
                            nukeInstance(v, stats)
                        end
                    end
                end)
            end
        end)
    end
    return stats
end

local function runPlayerScan()
    local roots = { LocalPlayer.PlayerGui, LocalPlayer.Backpack, LocalPlayer.PlayerScripts }
    pcall(function() roots[#roots + 1] = game:GetService("ReplicatedStorage") end)
    return scanRoots(roots, true)
end

local function runFullScan()
    return scanRoots(game:GetChildren(), true)
end

local acMonitorConns   = {}
local breakerConns     = {}

local function startACMonitor()
    disconnectAll(acMonitorConns)
    for _, loc in ipairs({ LocalPlayer.PlayerGui, LocalPlayer.Backpack, LocalPlayer.PlayerScripts }) do
        acMonitorConns[#acMonitorConns + 1] = loc.DescendantAdded:Connect(function(v)
            if not opt("AntiCheatMonitor") then return end
            pcall(function()
                local n = v.Name
                if (v:IsA("LocalScript") or v:IsA("Script")) and (matchesAC(n) or matchesBan(n)) then
                    task.wait(); nukeInstance(v, _statsDummy)
                elseif (v:IsA("RemoteEvent") or v:IsA("BindableEvent") or v:IsA("RemoteFunction")) and (matchesAC(n) or matchesBan(n)) then
                    nukeInstance(v, _statsDummy)
                end
            end)
        end)
    end
end

local function stopACMonitor() disconnectAll(acMonitorConns) end

local function startBreakerMonitor()
    disconnectAll(breakerConns)
    breakerConns[1] = game.DescendantAdded:Connect(function(v)
        if not opt("ACBreakerEnabled") then return end
        if not (v:IsA("LocalScript") or v:IsA("Script") or v:IsA("RemoteEvent")
            or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction")) then return end
        local n = v.Name
        if matchesAC(n) or matchesBan(n) or matchesKick(n) then
            task.spawn(function() task.wait(); nukeInstance(v, _statsDummy) end)
        end
    end)
end

local function stopBreakerMonitor() disconnectAll(breakerConns) end

local function destroyKickBanRemotes()
    local removed = 0
    for _, svc in ipairs(game:GetChildren()) do
        pcall(function()
            for _, v in ipairs(svc:GetDescendants()) do
                pcall(function()
                    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
                        if matchesKick(v.Name) or matchesBan(v.Name) then
                            if v:IsA("RemoteEvent")    then disableSignal(v.OnClientEvent) end
                            if v:IsA("BindableEvent")  then disableSignal(v.Event) end
                            if v:IsA("RemoteFunction") then pcall(function() v.OnClientInvoke = function() return nil end end) end
                            v:Destroy(); removed += 1
                        end
                    end
                end)
            end
        end)
    end
    return removed
end

local function runGameBypass()
    local wiped, spoofed = 0, 0
    local ok = pcall(function()
        local env = getgenv()
        for _, g in ipairs(EXECUTOR_GLOBALS) do
            pcall(function() if rawget(env, g) ~= nil then env[g] = nil; wiped += 1 end end)
        end
        local spoofFns = {
            identifyexecutor   = function() return "Roblox", 1 end,
            getexecutorname    = function() return "Roblox" end,
            is_sirhurt_closure = function() return false end,
            checkcaller        = function() return false end,
            iscclosure         = function(f) return type(f) == "function" end,
            islclosure         = function(f) return type(f) == "function" end,
        }
        for name, fn in pairs(spoofFns) do
            pcall(function() env[name] = newcclosure(fn); spoofed += 1 end)
        end
        local origLS = rawget(env, _GLS) or loadstring
        rawset(env, _GLS, origLS)
        env.loadstring = newcclosure(function(src, chunk)
            if type(src) == "string" then
                local sl = src:lower()
                for _, p in ipairs(AC_SOURCE_PATS) do
                    if sl:find(p, 1, true) then return function() end end
                end
            end
            return origLS(src, chunk)
        end)
        local origReq = rawget(env, _GRQ) or require
        rawset(env, _GRQ, origReq)
        env.require = newcclosure(function(module, ...)
            if type(module) == "userdata" then
                local ok2, n = pcall(function() return module.Name end)
                if ok2 and type(n) == "string" and (matchesAC(n) or matchesBan(n)) then return {} end
            end
            return origReq(module, ...)
        end)
        pcall(function()
            local gmt = getmetatable(env)
            if not gmt then return end
            local origIdx = rawget(gmt, "__index")
            setreadonly(gmt, false)
            gmt.__index = newcclosure(function(t, k)
                if EXECUTOR_GLOBALS_SET[k] then return nil end
                if origIdx then
                    return type(origIdx) == "function" and origIdx(t, k) or rawget(origIdx, k)
                end
            end)
            setreadonly(gmt, true)
        end)
    end)
    return ok, wiped, spoofed
end

local remoteCache = setmetatable({}, { __mode = "k" })
local function classifyRemote(inst)
    local v = remoteCache[inst]
    if v == nil then
        local nm = inst.Name
        v = { k = matchesKick(nm) or matchesBan(nm), a = matchesAC(nm) }
        remoteCache[inst] = v
    end
    return v
end

local FIRE_METHODS = {
    FireServer = true, InvokeServer = true, Fire = true,
    Invoke = true, FireClient = true, FireAllClients = true,
}

local namecallHooked, namecallOriginal = false, nil

local function initNamecallHook()
    if namecallHooked then return true end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        namecallOriginal = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            if F.antiKickBan or F.remoteBlock then
                local method = getnamecallmethod()
                if FIRE_METHODS[method] then
                    local v = classifyRemote(self)
                    if F.antiKickBan and v.k then
                        return (method == "Invoke" or method == "InvokeServer") and false or nil
                    end
                    if F.remoteBlock and v.a then return end
                elseif method == "Kick" or method == "BootFromGame" then
                    if F.antiKickBan and self == LocalPlayer then return end
                elseif method == "KickPlayer" then
                    if F.antiKickBan and self == Players then
                        local a1 = ...
                        if a1 == LocalPlayer or a1 == LocalPlayer.UserId then return end
                    end
                elseif method == "GetAsync" or method == "HttpGetAsync" or method == "PostAsync" then
                    local url = ...
                    if type(url) == "string" and matchesACUrl(url) then return "" end
                end
            end
            return namecallOriginal(self, ...)
        end)
        setreadonly(mt, true)
        namecallHooked = true
    end)
    return ok
end

local indexHooked, indexOriginal = false, nil

local function initIndexHook()
    if indexHooked then return true end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        indexOriginal = mt.__index
        setreadonly(mt, false)
        mt.__index = newcclosure(function(self, key)
            if F.silentAim and self == Mouse and (key == "Hit" or key == "Target" or key == "UnitRay") then
                local part = getSilentTarget and select(2, getSilentTarget())
                if part then
                    if key == "Hit"    then return CFrame.new(part.Position) end
                    if key == "Target" then return part end
                    if key == "UnitRay" then
                        local origin = Camera.CFrame.Position
                        return Ray.new(origin, (part.Position - origin).Unit * 1000)
                    end
                end
            end
            return indexOriginal(self, key)
        end)
        setreadonly(mt, true)
        indexHooked = true
    end)
    return ok
end

local function disconnectACSignals()
    local char = getChar(); if not char then return 0 end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local count = 0
    local function disc(sig) count += disableSignal(sig) end
    if hum then
        disc(hum:GetPropertyChangedSignal("WalkSpeed"))
        disc(hum:GetPropertyChangedSignal("JumpPower"))
        disc(hum:GetPropertyChangedSignal("MaxHealth"))
    end
    if hrp then
        disc(hrp:GetPropertyChangedSignal("Anchored"))
        disc(hrp:GetPropertyChangedSignal("AssemblyLinearVelocity"))
    end
    return count
end

local playerDropdowns = {}

local function refreshPlayerDropdowns()
    local list = playerList()
    for _, d in ipairs(playerDropdowns) do pcall(function() d:SetValues(list) end) end
end

local dropdownDirty = false
local function queueDropdownRefresh()
    if dropdownDirty then return end
    dropdownDirty = true
    task.delay(2, function() dropdownDirty = false; refreshPlayerDropdowns() end)
end

local espData = {}
local espContainer

local function getESPContainer()
    if espContainer and espContainer.Parent then return espContainer end
    espContainer = Instance.new("Folder")
    espContainer.Name = _TAG .. _RS(3)
    pcall(function() if gethui then espContainer.Parent = gethui() end end)
    if not espContainer.Parent then
        pcall(function() espContainer.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
    end
    return espContainer
end

local function updateHealthVisual(d)
    local hum = d.hum
    if not hum then return end
    local h  = math.floor(hum.Health + 0.5)
    local mh = math.floor(hum.MaxHealth + 0.5)
    if h == d.lastHealth and mh == d.lastMaxHealth then return end
    d.lastHealth, d.lastMaxHealth = h, mh
    local pct = math.clamp(h / math.max(mh, 1), 0, 1)
    d.barFill.Size = UDim2.new(pct, 0, 1, 0)
    d.barFill.BackgroundColor3 = Color3.fromRGB(
        math.floor((1 - pct) * 220 + 25),
        math.floor(pct * 195 + 25),
        math.floor(pct * 70 + 25)
    )
    d.healthText.Text = h .. " / " .. mh
end

local function buildESP(player)
    if player == LocalPlayer or espData[player] then return end
    local container = getESPContainer()

    local hl = Instance.new("Highlight")
    hl.Name = _RS(5)
    hl.FillTransparency    = 0.5
    hl.OutlineTransparency = 1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    hl.Parent = container

    local bb = Instance.new("BillboardGui")
    bb.Name = _BB_NAME
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = 1000
    bb.Size = UDim2.fromOffset(170, 42)
    bb.StudsOffset = Vector3.new(0, 2.3, 0)
    bb.ClipsDescendants = false
    bb.Enabled = false
    bb.Parent = container

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameTag"
    nameLabel.Size = UDim2.new(1, 0, 0.46, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = player.Name
    nameLabel.TextScaled = true
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 1
    nameLabel.Parent = bb

    local nameConstraint = Instance.new("UITextSizeConstraint")
    nameConstraint.MaxTextSize = 16
    nameConstraint.MinTextSize = 7
    nameConstraint.Parent = nameLabel

    local nameStroke = Instance.new("UIStroke")
    nameStroke.Thickness = 1.6
    nameStroke.Color = Color3.fromRGB(0, 0, 0)
    nameStroke.Transparency = 0.2
    nameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    nameStroke.Parent = nameLabel

    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(1, 0, 0.28, 0)
    healthText.Position = UDim2.new(0, 0, 0.46, 0)
    healthText.BackgroundTransparency = 1
    healthText.Font = Enum.Font.GothamMedium
    healthText.TextScaled = true
    healthText.TextColor3 = Color3.fromRGB(230, 230, 230)
    healthText.TextStrokeTransparency = 1
    healthText.Parent = bb

    local htConstraint = Instance.new("UITextSizeConstraint")
    htConstraint.MaxTextSize = 12
    htConstraint.MinTextSize = 6
    htConstraint.Parent = healthText

    local htStroke = Instance.new("UIStroke")
    htStroke.Thickness = 1.2
    htStroke.Color = Color3.fromRGB(0, 0, 0)
    htStroke.Transparency = 0.35
    htStroke.Parent = healthText

    local barBg = Instance.new("Frame")
    barBg.Name = "HealthBarBg"
    barBg.Size = UDim2.new(0.85, 0, 0.17, 0)
    barBg.Position = UDim2.new(0.075, 0, 0.83, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    barBg.BackgroundTransparency = 0.1
    barBg.BorderSizePixel = 0
    barBg.Parent = bb

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = barBg

    local bgStroke = Instance.new("UIStroke")
    bgStroke.Thickness = 1
    bgStroke.Color = Color3.fromRGB(0, 0, 0)
    bgStroke.Transparency = 0.25
    bgStroke.Parent = barBg

    local barFill = Instance.new("Frame")
    barFill.Name = "HealthFill"
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 220, 90)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = barFill

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.25),
    })
    fillGradient.Rotation = 90
    fillGradient.Parent = barFill

    espData[player] = {
        highlight = hl, billboard = bb, nameLabel = nameLabel,
        healthText = healthText, barBg = barBg, barFill = barFill,
        hum = nil, root = nil, lastScale = 0, lastHealth = nil, lastMaxHealth = nil,
    }
end

local function bindESP(player)
    local d = espData[player]; if not d then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    d.highlight.Adornee = char
    d.billboard.Adornee = root
    d.root = root
    d.hum = char and char:FindFirstChildOfClass("Humanoid")
    d.lastHealth = nil
    d.lastMaxHealth = nil
end

local function destroyESP(player)
    local d = espData[player]; if not d then return end
    pcall(function() d.highlight:Destroy() end)
    pcall(function() d.billboard:Destroy() end)
    espData[player] = nil
end

local function espIsOn()
    return opt("ESPEnabled") or opt("ESPNameTags") or opt("ESPHealthBar")
end

local function enableESPAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            buildESP(p)
            bindESP(p)
        end
    end
end

local function disableESPAll()
    for p in pairs(espData) do destroyESP(p) end
end

local function onESPToggle()
    if espIsOn() then enableESPAll() else disableESPAll() end
end

local function hookPlayerESP(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(char)
        if not espData[p] then return end
        pcall(function() char:WaitForChild("HumanoidRootPart", 6) end)
        bindESP(p)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do hookPlayerESP(p) end

Players.PlayerAdded:Connect(function(p)
    hookPlayerESP(p)
    if espIsOn() then buildESP(p); bindESP(p) end
    queueDropdownRefresh()
end)

Players.PlayerRemoving:Connect(function(p)
    destroyESP(p)
    queueDropdownRefresh()
end)

local espWasActive = false
local espAccum = 0
RunService.Heartbeat:Connect(function(dt)
    local espOn = opt("ESPEnabled")
    local tagOn = opt("ESPNameTags")
    local barOn = opt("ESPHealthBar")
    if not (espOn or tagOn or barOn) then
        if espWasActive then
            for _, d in pairs(espData) do
                d.highlight.Enabled = false
                d.billboard.Enabled = false
            end
            espWasActive = false
        end
        return
    end
    espWasActive = true
    espAccum += dt
    if espAccum < 0.1 then return end
    espAccum = 0

    local teamChk = opt("ESPTeamCheck")
    local fill    = opt("ESPFillColor") or Color3.fromRGB(255, 50, 50)
    local bbOn    = tagOn or barOn
    local camPos  = workspace.CurrentCamera.CFrame.Position
    local myTeam  = LocalPlayer.Team
    for player, d in pairs(espData) do
        local root = d.root
        local sameTeam = teamChk and player.Team == myTeam
        if root and root.Parent and not sameTeam then
            if d.highlight.Enabled ~= espOn then d.highlight.Enabled = espOn end
            if espOn and d.highlight.FillColor ~= fill then d.highlight.FillColor = fill end
            if d.billboard.Enabled ~= bbOn then d.billboard.Enabled = bbOn end
            if bbOn then
                if d.nameLabel.Visible ~= tagOn then d.nameLabel.Visible = tagOn end
                if d.healthText.Visible ~= barOn then d.healthText.Visible = barOn end
                if d.barBg.Visible ~= barOn then d.barBg.Visible = barOn end
                if barOn then updateHealthVisual(d) end
                local dist  = (camPos - root.Position).Magnitude
                local scale = math.clamp(60 / math.max(dist, 1), 0.4, 1.15)
                if math.abs(scale - d.lastScale) > 0.04 then
                    d.lastScale = scale
                    d.billboard.Size = UDim2.fromOffset(170 * scale, 42 * scale)
                end
            end
        else
            if d.highlight.Enabled then d.highlight.Enabled = false end
            if d.billboard.Enabled then d.billboard.Enabled = false end
        end
    end
end)

local function applySpeed()
    local hum = getHum(); if not hum then return end
    hum.WalkSpeed = F.speed and (opt("SpeedValue") or 50) or 16
end

local noclipParts = {}
local noclipChar  = nil

local function refreshNoclipParts()
    table.clear(noclipParts)
    noclipChar = getChar()
    if not noclipChar then return end
    for _, p in ipairs(noclipChar:GetDescendants()) do
        if p:IsA("BasePart") then noclipParts[#noclipParts + 1] = p end
    end
end

local function applyNoClip()
    local char = getChar(); if not char then return end
    if char ~= noclipChar then refreshNoclipParts() end
    for i = #noclipParts, 1, -1 do
        local p = noclipParts[i]
        if p.Parent then
            if p.CanCollide then p.CanCollide = false end
        else
            table.remove(noclipParts, i)
        end
    end
end

local function restoreNoClip()
    local char = getChar(); if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and not p.CanCollide then p.CanCollide = true end
    end
end

local flyConn, flyBV, flyBG

local function disableFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV   then flyBV:Destroy();     flyBV   = nil end
    if flyBG   then flyBG:Destroy();     flyBG   = nil end
    local hum = getHum(); if hum then hum.PlatformStand = false end
end

local function enableFly()
    disableFly()
    local char = getChar(); if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum  = char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand = true end
    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = _BV_NAME
    flyBV.Velocity = Vector3.zero; flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge); flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.Name = _BG_NAME
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); flyBG.CFrame = Camera.CFrame; flyBG.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        local speed = opt("FlySpeed") or 50
        local dir   = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir += Camera.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir -= Camera.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis             end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis             end
        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
        flyBG.CFrame   = Camera.CFrame
    end)
end

local vFlyConn, vFlyBV, vFlyBG

local function disableVehicleFly()
    if vFlyConn then vFlyConn:Disconnect(); vFlyConn = nil end
    if vFlyBV   then vFlyBV:Destroy();     vFlyBV   = nil end
    if vFlyBG   then vFlyBG:Destroy();     vFlyBG   = nil end
end

local function enableVehicleFly()
    disableVehicleFly()
    local char = getChar(); if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then
        notify({ Title = "Vehicle Fly", Content = "Você precisa estar dentro de um veículo.", Duration = 3 })
        Options.VehicleFlyEnabled:SetValue(false); return
    end
    local root = (hum.SeatPart.Parent and hum.SeatPart.Parent:IsA("Model") and hum.SeatPart.Parent.PrimaryPart) or hum.SeatPart
    vFlyBV = Instance.new("BodyVelocity")
    vFlyBV.Name = _BV_NAME
    vFlyBV.Velocity = Vector3.zero; vFlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge); vFlyBV.Parent = root
    vFlyBG = Instance.new("BodyGyro")
    vFlyBG.Name = _BG_NAME
    vFlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); vFlyBG.CFrame = Camera.CFrame; vFlyBG.Parent = root
    vFlyConn = RunService.RenderStepped:Connect(function()
        local h = char:FindFirstChildOfClass("Humanoid")
        if not h or not h.SeatPart then
            disableVehicleFly()
            pcall(function() Options.VehicleFlyEnabled:SetValue(false) end)
            return
        end
        local speed = opt("VehicleFlySpeed") or 100
        local dir   = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir += Camera.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir -= Camera.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis             end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis             end
        vFlyBV.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
        vFlyBG.CFrame   = Camera.CFrame
    end)
end

local infJumpConn

local function disableInfinityJump()
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
end

local function enableInfinityJump()
    disableInfinityJump()
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        local hum = getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local walkOnAirConn

local function enableWalkOnAir()
    if walkOnAirConn then walkOnAirConn:Disconnect() end
    walkOnAirConn = RunService.Heartbeat:Connect(function()
        if not opt("WalkOnAirEnabled") then return end
        local hrp = getHRP(); if not hrp then return end
        local hum = getHum(); if not hum then return end
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, math.max(v.Y, 0), v.Z)
        end
    end)
end

local function disableWalkOnAir()
    if walkOnAirConn then walkOnAirConn:Disconnect(); walkOnAirConn = nil end
end

local function startSpy()
    local name = opt("PlayerSpyTarget"); if not name or name == "(none)" then return end
    local target = Players:FindFirstChild(name)
    if not target or not target.Character then notify({ Title = "Spectate", Content = "Jogador não encontrado.", Duration = 3 }); return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if hum then Camera.CameraSubject = hum; notify({ Title = "Spectate", Content = "Espionando " .. name, Duration = 3 }) end
end

local function stopSpy()
    local hum = getHum(); if hum then Camera.CameraSubject = hum end
end

local origLighting  = {}
local hiddenEffects = {}

local function saveOrigLighting()
    if next(origLighting) then return end
    origLighting.Brightness     = Lighting.Brightness
    origLighting.Ambient        = Lighting.Ambient
    origLighting.OutdoorAmbient = Lighting.OutdoorAmbient
    origLighting.FogEnd         = Lighting.FogEnd
    origLighting.FogStart       = Lighting.FogStart
end

local function setFullbright(on)
    saveOrigLighting()
    if on then
        Lighting.Brightness     = 2
        Lighting.Ambient        = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness     = origLighting.Brightness
        Lighting.Ambient        = origLighting.Ambient
        Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
    end
end

local function setNoFog(on)
    saveOrigLighting()
    if on then
        Lighting.FogEnd = 9e9; Lighting.FogStart = 9e9
        local atmo = Lighting:FindFirstChildOfClass("Atmosphere"); if atmo then atmo.Density = 0 end
    else
        Lighting.FogEnd = origLighting.FogEnd; Lighting.FogStart = origLighting.FogStart
        local atmo = Lighting:FindFirstChildOfClass("Atmosphere"); if atmo then atmo.Density = 0.395 end
    end
end

local function setRemoveEffects(on)
    if on then
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("PostEffect") then obj.Enabled = false; hiddenEffects[#hiddenEffects + 1] = obj end
        end
    else
        for _, obj in ipairs(hiddenEffects) do pcall(function() obj.Enabled = true end) end
        table.clear(hiddenEffects)
    end
end

local touchFlingActive  = false
local flingLoopRunning  = false
local flingAllActive    = false
local flingActive       = false
local flingOldPos       = nil
local fallenPartsHeight = workspace.FallenPartsDestroyHeight

local function setNoClipState(state)
    Options.NoClipEnabled:SetValue(state)
end

local function runTouchFling()
    if flingLoopRunning then return end
    flingLoopRunning = true
    local flip = 0.1
    while touchFlingActive do
        RunService.Heartbeat:Wait()
        local hrp = getHRP()
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            hrp.AssemblyLinearVelocity = vel
            RunService.Stepped:Wait()
            hrp.AssemblyLinearVelocity = vel + Vector3.new(0, flip, 0)
            flip = -flip
        end
    end
    flingLoopRunning = false
end

local function skidFling(target)
    local char  = getChar()
    local hum   = char and char:FindFirstChildOfClass("Humanoid")
    local hrp   = hum and hum.RootPart
    local tChar = target.Character
    if not (char and hum and hrp and tChar) then return end

    local tHum    = tChar:FindFirstChildOfClass("Humanoid")
    local tHRP    = tHum and tHum.RootPart
    local tHead   = tChar:FindFirstChild("Head")
    local tAcc    = tChar:FindFirstChildOfClass("Accessory")
    local tHandle = tAcc and tAcc:FindFirstChild("Handle")

    if hrp.AssemblyLinearVelocity.Magnitude < 50 then flingOldPos = hrp.CFrame end
    if tHum and tHum.Sit then return end
    Camera.CameraSubject = tHRP or tHead or tHum
    if not tChar:FindFirstChildWhichIsA("BasePart") then return end

    local vMult = 1

    local function fpos(base, pos, ang)
        hrp.CFrame                  = CFrame.new(base.Position) * pos * ang
        hrp.AssemblyLinearVelocity  = Vector3.new(9e7 * vMult, 9e7 * 10 * vMult, 9e7 * vMult)
        hrp.AssemblyAngularVelocity = Vector3.new(9e8 * vMult, 9e8 * vMult, 9e8 * vMult)
    end

    local function sfBase(base)
        local endTime = tick() + 2
        local angle   = 0
        repeat
            if not (hrp and tHum) then break end
            angle += 100
            if base.AssemblyLinearVelocity.Magnitude < 50 then
                local off = tHum.MoveDirection * base.AssemblyLinearVelocity.Magnitude / 1.25
                fpos(base, CFrame.new(0,  1.5, 0) + off,                CFrame.Angles(math.rad(angle), 0, 0)); task.wait()
                fpos(base, CFrame.new(0, -1.5, 0) + off,                CFrame.Angles(math.rad(angle), 0, 0)); task.wait()
                fpos(base, CFrame.new(0,  1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0)); task.wait()
                fpos(base, CFrame.new(0, -1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0)); task.wait()
            else
                fpos(base, CFrame.new(0,  1.5,  tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                fpos(base, CFrame.new(0, -1.5, -tHum.WalkSpeed), CFrame.Angles(0, 0, 0));            task.wait()
                fpos(base, CFrame.new(0, -1.5, 0),               CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                fpos(base, CFrame.new(0, -1.5, 0),               CFrame.Angles(0, 0, 0));            task.wait()
            end
        until tick() > endTime or not flingActive
    end

    workspace.FallenPartsDestroyHeight = 0 / 0
    flingActive = true
    local bv = Instance.new("BodyVelocity")
    bv.Name = _BV_NAME
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Parent = hrp
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if tHRP then sfBase(tHRP) elseif tHead then sfBase(tHead) elseif tHandle then sfBase(tHandle) end
    bv:Destroy()
    flingActive = false
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Camera.CameraSubject = hum

    if flingOldPos then
        local attempts = 0
        repeat
            attempts += 1
            hrp.CFrame = flingOldPos * CFrame.new(0, 0.5, 0)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then
                    p.AssemblyLinearVelocity  = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                end
            end
            task.wait()
        until (hrp.Position - flingOldPos.Position).Magnitude < 25 or attempts > 30
        workspace.FallenPartsDestroyHeight = fallenPartsHeight
    end
end

local antiFlingConns = {}
local antiFlingNCCs  = {}

local function clearNCCs()
    for _, ncc in ipairs(antiFlingNCCs) do pcall(function() ncc:Destroy() end) end
    table.clear(antiFlingNCCs)
end

local function addNCCsForPlayer(player)
    if not opt("AntiFlingEnabled") then return end
    local char  = getChar(); if not char then return end
    local myHRP = char:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local other = player.Character; if not other then return end
    for _, part in ipairs(other:GetDescendants()) do
        if part:IsA("BasePart") then
            local ncc = Instance.new("NoCollisionConstraint")
            ncc.Part0 = myHRP; ncc.Part1 = part; ncc.Parent = char
            antiFlingNCCs[#antiFlingNCCs + 1] = ncc
        end
    end
end

local function setupAntiFling()
    clearNCCs(); disconnectAll(antiFlingConns)
    antiFlingConns[#antiFlingConns + 1] = RunService.Heartbeat:Connect(function()
        local hrp   = getHRP(); if not hrp then return end
        local limit = 80
        if hrp.AssemblyLinearVelocity.Magnitude > limit then
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            addNCCsForPlayer(p)
            antiFlingConns[#antiFlingConns + 1] = p.CharacterAdded:Connect(function()
                task.wait(0.5); addNCCsForPlayer(p)
            end)
        end
    end
    antiFlingConns[#antiFlingConns + 1] = Players.PlayerAdded:Connect(function(p)
        antiFlingConns[#antiFlingConns + 1] = p.CharacterAdded:Connect(function()
            task.wait(0.5); addNCCsForPlayer(p)
        end)
    end)
end

local function cleanupAntiFling()
    disconnectAll(antiFlingConns); clearNCCs()
end

local waypoints     = {}
local waypointCount = 0
local waypointDrop  = nil

Tabs.Player:AddSection("Teleport to Player")
local playerTPDrop = Tabs.Player:AddDropdown("PlayerTPTarget", { Title = "Select Player", Values = playerList(), Multi = false, Default = 1 })
playerDropdowns[#playerDropdowns + 1] = playerTPDrop
Tabs.Player:AddButton({
    Title = "Teleport",
    Callback = function()
        local name = opt("PlayerTPTarget")
        if not name or name == "(none)" then return end
        local target = Players:FindFirstChild(name)
        if not target or not target.Character then notify({ Title = "Player TP", Content = "Jogador não encontrado.", Duration = 3 }); return end
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = getHRP()
        if tHRP and hrp then hrp.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0); notify({ Title = "Player TP", Content = "Teleportado para " .. name, Duration = 3 }) end
    end,
})

Tabs.Player:AddSection("Spectate")
local playerSpyDrop = Tabs.Player:AddDropdown("PlayerSpyTarget", { Title = "Spy on Player", Values = playerList(), Multi = false, Default = 1 })
playerDropdowns[#playerDropdowns + 1] = playerSpyDrop
Tabs.Player:AddToggle("SpyEnabled", { Title = "Enable Spectate", Default = false, Callback = function(s) if s then startSpy() else stopSpy() end end })
playerSpyDrop:OnChanged(function() if opt("SpyEnabled") then startSpy() end end)

Tabs.Movement:AddSection("Movement")
Tabs.Movement:AddToggle("SpeedEnabled", { Title = "Speed Hack", Default = false, Callback = function(s) F.speed = s; applySpeed() end })
Tabs.Movement:AddSlider("SpeedValue", { Title = "Walk Speed", Default = 50, Min = 16, Max = 300, Rounding = 0, Callback = function() applySpeed() end })
Tabs.Movement:AddToggle("NoClipEnabled", { Title = "NoClip", Default = false, Callback = function(s) F.noclip = s; if s then applyNoClip() else restoreNoClip() end end })
Tabs.Movement:AddToggle("InfinityJumpEnabled", { Title = "Infinity Jump", Default = false, Callback = function(s) if s then enableInfinityJump() else disableInfinityJump() end end })
Tabs.Movement:AddToggle("WalkOnAirEnabled", { Title = "Levitation", Default = false, Callback = function(s) if s then enableWalkOnAir() else disableWalkOnAir() end end })

Tabs.Movement:AddSection("Fly")
Tabs.Movement:AddToggle("FlyEnabled", { Title = "Fly", Default = false, Callback = function(s) F.fly = s; if s then enableFly() else disableFly() end end })
Tabs.Movement:AddSlider("FlySpeed", { Title = "Fly Speed", Default = 50, Min = 10, Max = 300, Rounding = 0, Callback = function() end })
Tabs.Movement:AddToggle("VehicleFlyEnabled", { Title = "Vehicle Fly", Default = false, Callback = function(s) if s then enableVehicleFly() else disableVehicleFly() end end })
Tabs.Movement:AddSlider("VehicleFlySpeed", { Title = "Vehicle Fly Speed", Default = 100, Min = 10, Max = 500, Rounding = 0, Callback = function() end })

Tabs.Movement:AddSection("Teleport")
Tabs.Movement:AddToggle("ClickTPEnabled", { Title = "Click TP", Default = false, Callback = function() end })
Tabs.Movement:AddButton({
    Title = "TP to Spawn",
    Callback = function()
        local hrp = getHRP(); if not hrp then return end
        local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
        if not spawn then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("SpawnLocation") then spawn = v; break end
            end
        end
        if spawn then
            hrp.CFrame = CFrame.new(spawn.Position + Vector3.new(0, 3, 0))
            notify({ Title = "TP to Spawn", Content = "Teletransportado para o spawn.", Duration = 3 })
        else
            notify({ Title = "TP to Spawn", Content = "Spawn não encontrado.", Duration = 3 })
        end
    end,
})

Tabs.Movement:AddSection("Waypoints")
Tabs.Movement:AddInput("WaypointName", { Title = "Waypoint Name", Placeholder = "Nome do waypoint", Numeric = false, Finished = false, Callback = function() end })
Tabs.Movement:AddButton({
    Title = "Save Waypoint",
    Callback = function()
        local hrp = getHRP(); if not hrp then return end
        local name = opt("WaypointName")
        if not name or name == "" then waypointCount += 1; name = "WP" .. waypointCount end
        waypoints[name] = hrp.CFrame
        local keys = {}
        for k in pairs(waypoints) do keys[#keys + 1] = k end
        if waypointDrop then pcall(function() waypointDrop:SetValues(keys) end) end
        notify({ Title = "Waypoints", Content = "Waypoint '" .. name .. "' salvo!", Duration = 3 })
    end,
})
waypointDrop = Tabs.Movement:AddDropdown("WaypointSelect", { Title = "Select Waypoint", Values = {}, Multi = false, Default = nil, Callback = function() end })
Tabs.Movement:AddButton({
    Title = "Teleport to Waypoint",
    Callback = function()
        local sel = opt("WaypointSelect")
        if not sel or sel == "" then notify({ Title = "Waypoints", Content = "Selecione um waypoint.", Duration = 3 }); return end
        local cf = waypoints[sel]
        if not cf then notify({ Title = "Waypoints", Content = "Waypoint não encontrado.", Duration = 3 }); return end
        local hrp = getHRP()
        if hrp then hrp.CFrame = cf; notify({ Title = "Waypoints", Content = "Teleportado para '" .. sel .. "'.", Duration = 3 }) end
    end,
})
Tabs.Movement:AddButton({
    Title = "Delete Waypoint",
    Callback = function()
        local sel = opt("WaypointSelect")
        if not sel or sel == "" then notify({ Title = "Waypoints", Content = "Selecione um waypoint.", Duration = 3 }); return end
        waypoints[sel] = nil
        local keys = {}
        for k in pairs(waypoints) do keys[#keys + 1] = k end
        if waypointDrop then pcall(function() waypointDrop:SetValues(keys) end) end
        notify({ Title = "Waypoints", Content = "Waypoint '" .. sel .. "' deletado.", Duration = 3 })
    end,
})

Tabs.Movement:AddSection("Misc")
Tabs.Movement:AddToggle("AntiAFKEnabled", { Title = "Anti-AFK", Default = false, Callback = function() end })

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not opt("ClickTPEnabled") then return end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { getChar() }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ray    = Camera:ScreenPointToRay(input.Position.X, input.Position.Y)
    local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if result then
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0)) end
    end
end)

LocalPlayer.Idled:Connect(function()
    if opt("AntiAFKEnabled") then
        pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
    end
end)

Tabs.Visuals:AddSection("Player ESP")
Tabs.Visuals:AddToggle("ESPEnabled",   { Title = "Enable ESP", Default = false, Callback = function() onESPToggle() end })
Tabs.Visuals:AddToggle("ESPTeamCheck", { Title = "Team Check", Default = false, Callback = function() end })
Tabs.Visuals:AddToggle("ESPNameTags",  { Title = "Name Tags",  Default = false, Callback = function() onESPToggle() end })
Tabs.Visuals:AddToggle("ESPHealthBar", { Title = "Health Bar", Default = false, Callback = function() onESPToggle() end })
Tabs.Visuals:AddColorpicker("ESPFillColor", { Title = "ESP Color", Default = Color3.fromRGB(255, 50, 50) })

Tabs.Visuals:AddSection("Lighting")
Tabs.Visuals:AddToggle("FullbrightEnabled",    { Title = "Fullbright",     Default = false, Callback = setFullbright })
Tabs.Visuals:AddToggle("NoFogEnabled",         { Title = "No Fog",         Default = false, Callback = setNoFog })
Tabs.Visuals:AddToggle("RemoveEffectsEnabled", { Title = "Remove Effects", Default = false, Callback = setRemoveEffects })

local GuiService = game:GetService("GuiService")

local function getTargetPart(char, partName)
    if partName == "Head" then
        return char:FindFirstChild("Head")
    elseif partName == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
end

local function isVisible(part)
    local origin = workspace.CurrentCamera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { getChar(), workspace.CurrentCamera }
    local res = workspace:Raycast(origin, part.Position - origin, params)
    return (not res) or res.Instance:IsDescendantOf(part.Parent)
end

local function pickTarget(partName, teamCheck, wallCheck, fov, fromMouse)
    local cam = workspace.CurrentCamera
    local ref
    if fromMouse then
        local mp = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        ref = Vector2.new(mp.X, mp.Y - inset.Y)
    else
        ref = cam.ViewportSize / 2
    end
    local best, bestPart, bestDist = nil, nil, fov or math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not (teamCheck and p.Team == LocalPlayer.Team) then
                local part = getTargetPart(char, partName)
                if part then
                    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(sp.X, sp.Y) - ref).Magnitude
                        if d < bestDist and (not wallCheck or isVisible(part)) then
                            best, bestPart, bestDist = p, part, d
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

function getSilentTarget()
    if not F.silentAim then return nil end
    return pickTarget(opt("SilentAimPart") or "Head", opt("SilentAimTeamCheck"), opt("SilentAimWallCheck"), opt("SilentAimFOV") or 9999, true)
end

local fovGui, fovCircle
local function ensureFovCircle()
    if fovGui and fovGui.Parent then return end
    fovGui = Instance.new("ScreenGui")
    fovGui.Name = _TAG .. _RS(3)
    fovGui.IgnoreGuiInset = true
    fovGui.ResetOnSpawn = false
    fovGui.DisplayOrder = 9998
    pcall(function() if gethui then fovGui.Parent = gethui() end end)
    if not fovGui.Parent then pcall(function() fovGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end) end
    fovCircle = Instance.new("Frame")
    fovCircle.Name = "FOV"
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.BackgroundTransparency = 1
    fovCircle.BorderSizePixel = 0
    fovCircle.Parent = fovGui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1, 0); corner.Parent = fovCircle
    local stroke = Instance.new("UIStroke"); stroke.Thickness = 1.5; stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Transparency = 0.15; stroke.Parent = fovCircle
end

local aimKeybind

Tabs.Combat:AddSection("Aimbot")
Tabs.Combat:AddToggle("AimbotEnabled", { Title = "Aimbot", Default = false })
aimKeybind = Tabs.Combat:AddKeybind("AimbotKey", { Title = "Aim Key (hold)", Mode = "Hold", Default = "E" })
Tabs.Combat:AddDropdown("AimbotPart", { Title = "Target Part", Values = { "Head", "Torso", "HumanoidRootPart" }, Multi = false, Default = 1 })
Tabs.Combat:AddToggle("AimbotTeamCheck", { Title = "Team Check", Default = true })
Tabs.Combat:AddToggle("AimbotWallCheck", { Title = "Visible Check (walls)", Default = false })
Tabs.Combat:AddSlider("AimbotFOV", { Title = "FOV", Default = 120, Min = 20, Max = 500, Rounding = 0, Callback = function() end })
Tabs.Combat:AddSlider("AimbotSmooth", { Title = "Smoothness", Default = 0.6, Min = 0, Max = 0.95, Rounding = 2, Callback = function() end })
Tabs.Combat:AddToggle("AimbotFOVCircle", { Title = "Show FOV Circle", Default = false })

Tabs.Combat:AddSection("Silent Aim")
Tabs.Combat:AddToggle("SilentAimEnabled", {
    Title = "Silent Aim",
    Default = false,
    Callback = function(s)
        F.silentAim = s
        if s and not initIndexHook() then
            notify({ Title = "Silent Aim", Content = "Executor não suporta metamétodos.", Duration = 4 })
        end
    end,
})
Tabs.Combat:AddDropdown("SilentAimPart", { Title = "Target Part", Values = { "Head", "Torso", "HumanoidRootPart" }, Multi = false, Default = 1 })
Tabs.Combat:AddToggle("SilentAimTeamCheck", { Title = "Team Check", Default = true })
Tabs.Combat:AddToggle("SilentAimWallCheck", { Title = "Visible Check (walls)", Default = false })
Tabs.Combat:AddSlider("SilentAimFOV", { Title = "FOV", Default = 150, Min = 30, Max = 2000, Rounding = 0, Callback = function() end })

Tabs.Combat:AddSection("Triggerbot")
Tabs.Combat:AddToggle("TriggerbotEnabled", { Title = "Triggerbot", Default = false })
Tabs.Combat:AddToggle("TriggerTeamCheck", { Title = "Team Check", Default = true })
Tabs.Combat:AddSlider("TriggerDelay", { Title = "Delay (s)", Default = 0.1, Min = 0, Max = 1, Rounding = 2, Callback = function() end })

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if opt("AimbotFOVCircle") then
        ensureFovCircle()
        local r = opt("AimbotFOV") or 120
        fovCircle.Visible = true
        fovCircle.Size = UDim2.fromOffset(r * 2, r * 2)
        fovCircle.Position = UDim2.fromOffset(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    elseif fovCircle then
        fovCircle.Visible = false
    end

    if not opt("AimbotEnabled") then return end
    if not (aimKeybind and aimKeybind:GetState()) then return end
    local _, part = pickTarget(opt("AimbotPart") or "Head", opt("AimbotTeamCheck"), opt("AimbotWallCheck"), opt("AimbotFOV") or 120, false)
    if part then
        local smooth = opt("AimbotSmooth") or 0.6
        local alpha  = math.clamp(1 - smooth, 0.03, 1)
        local goal   = CFrame.new(cam.CFrame.Position, part.Position)
        cam.CFrame   = cam.CFrame:Lerp(goal, alpha)
    end
end)

local lastShot = 0
RunService.Heartbeat:Connect(function()
    if not opt("TriggerbotEnabled") then return end
    local now = tick()
    if now - lastShot < (opt("TriggerDelay") or 0.1) then return end
    local _, part = pickTarget(opt("AimbotPart") or "Head", opt("TriggerTeamCheck"), true, 8, false)
    if part then
        if mouse1press and mouse1release then
            mouse1press(); task.wait(0.02); mouse1release()
            lastShot = now
        end
    end
end)

Tabs.Fling:AddSection("Fling Target")
local flingTargetDrop = Tabs.Fling:AddDropdown("FlingTargetPlayer", { Title = "Select Target", Values = playerList(), Multi = false, Default = 1, Callback = function() end })
playerDropdowns[#playerDropdowns + 1] = flingTargetDrop
Tabs.Fling:AddButton({
    Title = "Fling Target",
    Callback = function()
        local name = opt("FlingTargetPlayer")
        if not name or name == "(none)" then notify({ Title = "Fling", Content = "Selecione um alvo.", Duration = 3 }); return end
        local target = Players:FindFirstChild(name)
        if not target then notify({ Title = "Fling", Content = "Jogador não encontrado.", Duration = 3 }); return end
        task.spawn(skidFling, target)
    end,
})

Tabs.Fling:AddSection("Mass Fling")
Tabs.Fling:AddToggle("TouchFlingEnabled", {
    Title = "Touch Fling",
    Default = false,
    Callback = function(state)
        touchFlingActive = state
        if state then
            setNoClipState(true)
            if not flingLoopRunning then task.spawn(runTouchFling) end
        elseif not opt("FlingAllEnabled") then
            setNoClipState(false)
        end
    end,
})
Tabs.Fling:AddToggle("FlingAllEnabled", {
    Title = "Fling All",
    Default = false,
    Callback = function(state)
        flingAllActive = state
        if state then
            setNoClipState(true)
            notify({ Title = "Fling All", Content = "Fling All ativado.", Duration = 3 })
            task.spawn(function()
                while flingAllActive do
                    local targets = {}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                            targets[#targets + 1] = p
                        end
                    end
                    if #targets == 0 then task.wait(1); continue end
                    for _, t in ipairs(targets) do
                        if not flingAllActive then break end
                        skidFling(t); task.wait(0.1)
                    end
                end
                if not opt("TouchFlingEnabled") then setNoClipState(false) end
            end)
        elseif not opt("TouchFlingEnabled") then
            setNoClipState(false)
        end
    end,
})

Tabs.Fling:AddSection("Anti-Fling")
Tabs.Fling:AddToggle("AntiFlingEnabled", { Title = "Anti-Fling", Default = false, Callback = function(state) if state then setupAntiFling() else cleanupAntiFling() end end })

Tabs.Bypass:AddSection("Protection")
Tabs.Bypass:AddParagraph({
    Title = "Status",
    Content = "As proteções vêm DESATIVADAS por padrão para máxima\nfluidez. Ative manualmente as que quiser, ou use o botão\nabaixo para ligar todas de uma vez.",
})
Tabs.Bypass:AddButton({
    Title = "Activate All Protections",
    Callback = function()
        for _, k in ipairs({
            "GameBypassEnabled","AntiKickBanEnabled","AntiCheatRemoteBlock",
            "ACBreakerEnabled","AntiCheatMonitor",
        }) do
            if Options[k] then Options[k]:SetValue(true) end
        end
        disconnectACSignals()
        notify({ Title = "Bypass", Content = "Todas as proteções ativadas!", Duration = 5 })
    end,
})

Tabs.Bypass:AddSection("Anti-Cheat")
Tabs.Bypass:AddToggle("GameBypassEnabled", {
    Title = "Fingerprint Wipe",
    Default = false,
    Callback = function(state)
        if not state then return end
        local ok, wiped, spoofed = runGameBypass()
        notify({
            Title = "Fingerprint Wipe",
            Content = ok and "Bypass aplicado com sucesso." or "Executor não suporta getgenv().",
            SubContent = ok and ("Globals apagadas: " .. wiped .. "  |  Funções falsificadas: " .. spoofed) or nil,
            Duration = 5,
        })
    end,
})
Tabs.Bypass:AddToggle("AntiCheatRemoteBlock", {
    Title = "Remote Report Block",
    Default = false,
    Callback = function(state)
        F.remoteBlock = state
        if state then
            local ok = initNamecallHook()
            notify({ Title = "Remote Report Block", Content = ok and "Ativo — remotes de AC bloqueadas." or "Executor sem suporte.", Duration = 4 })
        end
    end,
})
Tabs.Bypass:AddToggle("ACBreakerEnabled", {
    Title = "Anti-Cheat Breaker (pesado)",
    Default = false,
    Callback = function(state)
        if state then
            F.remoteBlock = true; initNamecallHook()
            if Options.AntiCheatRemoteBlock then Options.AntiCheatRemoteBlock:SetValue(true) end
            local r = runFullScan()
            startBreakerMonitor()
            notify({
                Title = "Anti-Cheat Breaker",
                Content = "Ativo — anti-cheat destruído em todos os serviços.",
                SubContent = "Desativados: " .. r.disabled .. "  |  Destruídos: " .. r.destroyed .. (r.conns > 0 and ("  |  Signals: " .. r.conns) or ""),
                Duration = 6,
            })
        else
            stopBreakerMonitor()
            notify({ Title = "Anti-Cheat Breaker", Content = "Monitor desativado.", Duration = 3 })
        end
    end,
})
Tabs.Bypass:AddToggle("AntiCheatMonitor", {
    Title = "Anti-Cheat Monitor",
    Default = false,
    Callback = function(state)
        if state then runPlayerScan(); startACMonitor(); notify({ Title = "Anti-Cheat Monitor", Content = "Monitor ativo.", Duration = 4 })
        else stopACMonitor() end
    end,
})
Tabs.Bypass:AddButton({
    Title = "Full Scan & Disable",
    Callback = function()
        local r = runPlayerScan(); initNamecallHook()
        notify({
            Title = "Anti-Cheat Scan",
            Content = "Scan concluído.",
            SubContent = "Scripts desativados: " .. r.disabled .. "  |  Remotes removidas: " .. r.destroyed,
            Duration = 5,
        })
    end,
})

Tabs.Bypass:AddSection("Anti-Kick & Ban")
Tabs.Bypass:AddToggle("AntiKickBanEnabled", {
    Title = "Anti-Kick & Ban",
    Default = false,
    Callback = function(state)
        F.antiKickBan = state
        if state then
            local ok = initNamecallHook()
            notify({ Title = "Anti-Kick & Ban", Content = ok and "Ativo — kicks e bans bloqueados." or "Executor sem suporte a metamétodos.", Duration = 5 })
        else
            notify({ Title = "Anti-Kick & Ban", Content = "Desativado.", Duration = 4 })
        end
    end,
})
Tabs.Bypass:AddButton({
    Title = "Destroy Kick/Ban Remotes",
    Callback = function()
        local removed = destroyKickBanRemotes()
        notify({ Title = "Anti-Kick & Ban", Content = "Remotes destruídas: " .. removed, Duration = 4 })
    end,
})

Tabs.Bypass:AddSection("Misc")
Tabs.Bypass:AddToggle("FakeLagEnabled", {
    Title = "Lag Switch",
    Default = false,
    Callback = function(state)
        local hrp = getHRP(); if not hrp then return end
        hrp.Anchored = state
        notify({ Title = "Lag Switch", Content = state and "Lag Switch ativado." or "Lag Switch desativado.", Duration = 3 })
    end,
})

Tabs.External:AddSection("External Scripts")
Tabs.External:AddParagraph({ Title = "Aviso", Content = "Scripts de terceiros carregados via HttpGet.\nUse com responsabilidade." })
Tabs.External:AddButton({
    Title = "Infinity Yield",
    Callback = function()
        notify({ Title = "Infinity Yield", Content = "Carregando...", Duration = 3 })
        task.spawn(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
    end,
})
Tabs.External:AddButton({
    Title = "Dex Explorer",
    Callback = function()
        notify({ Title = "Dex Explorer", Content = "Carregando...", Duration = 3 })
        task.spawn(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
    end,
})
Tabs.External:AddButton({
    Title = "Remote Spy (SimpleSpy)",
    Callback = function()
        notify({ Title = "SimpleSpy", Content = "Carregando...", Duration = 3 })
        task.spawn(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))() end)
    end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    protectHumanoid = char:FindFirstChildOfClass("Humanoid")
    protectHRP      = char:FindFirstChild("HumanoidRootPart")

    applySpeed()
    if F.noclip then applyNoClip() end

    if F.fly                      then enableFly()          end
    if opt("VehicleFlyEnabled")   then enableVehicleFly()   end
    if opt("InfinityJumpEnabled") then enableInfinityJump() end
    if opt("WalkOnAirEnabled")    then enableWalkOnAir()    end
    if touchFlingActive and not flingLoopRunning then task.spawn(runTouchFling) end

    if opt("AntiFlingEnabled") then
        clearNCCs()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then addNCCsForPlayer(p) end
        end
    end

    if protectHRP then protectHRP.Anchored = false end
    if opt("FakeLagEnabled") then Options.FakeLagEnabled:SetValue(false) end
end)

do
    local c = getChar()
    if c then
        protectHumanoid = c:FindFirstChildOfClass("Humanoid")
        protectHRP      = c:FindFirstChild("HumanoidRootPart")
    end
end

RunService.Stepped:Connect(function()
    if F.noclip then applyNoClip() end
end)

local function serverHop()
    notify({ Title = "Server Hop", Content = "Procurando outro servidor...", Duration = 3 })
    task.spawn(function()
        local placeId = game.PlaceId
        local found, cursor, pages = {}, nil, 0
        repeat
            pages += 1
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
            if cursor then url = url .. "&cursor=" .. cursor end
            local ok, body = pcall(httpGet, url)
            if not ok then break end
            local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
            if not ok2 or not data or not data.data then break end
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and tonumber(s.playing or 0) < tonumber(s.maxPlayers or 0) then
                    found[#found + 1] = s.id
                end
            end
            cursor = data.nextPageCursor
        until (not cursor) or #found >= 50 or pages >= 5
        if #found == 0 then
            notify({ Title = "Server Hop", Content = "Nenhum servidor disponível encontrado.", Duration = 4 })
            return
        end
        local target = found[math.random(1, #found)]
        local ok = pcall(function() TeleportService:TeleportToPlaceInstance(placeId, target, LocalPlayer) end)
        if not ok then notify({ Title = "Server Hop", Content = "Falha ao teleportar.", Duration = 4 }) end
    end)
end

TeleportService.TeleportInitFailed:Connect(function(_, result)
    if result == Enum.TeleportResult.Flooded or result == Enum.TeleportResult.GameFull or result == Enum.TeleportResult.Failure then
        task.wait(2); serverHop()
    end
end)

local statsActive = false
local statsGui, statsRenderConn, fpsLabel, pingLabel

local function stopStats()
    statsActive = false
    if statsRenderConn then statsRenderConn:Disconnect(); statsRenderConn = nil end
    if statsGui then statsGui:Destroy(); statsGui = nil end
    fpsLabel, pingLabel = nil, nil
end

local function getPing()
    local ok, ping = pcall(function()
        return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
    end)
    return ok and ping or 0
end

local function startStats()
    stopStats()
    statsActive = true

    statsGui = Instance.new("ScreenGui")
    statsGui.Name = _TAG .. _RS(3)
    statsGui.ResetOnSpawn = false
    statsGui.IgnoreGuiInset = true
    statsGui.DisplayOrder = 9999
    statsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if gethui then statsGui.Parent = gethui() end end)
    if not statsGui.Parent then
        pcall(function() statsGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
    end

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, 6)
    frame.Size = UDim2.new(0, 0, 0, 30)
    frame.AutomaticSize = Enum.AutomaticSize.X
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = statsGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Transparency = 0.3
    stroke.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Rotation = 90
    grad.Color = ColorSequence.new(Color3.fromRGB(34, 34, 42), Color3.fromRGB(16, 16, 20))
    grad.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 16)
    layout.Parent = frame

    local function mkLabel()
        local l = Instance.new("TextLabel")
        l.AutomaticSize = Enum.AutomaticSize.X
        l.Size = UDim2.new(0, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextSize = 14
        l.TextColor3 = Color3.fromRGB(240, 240, 240)
        l.Text = ""
        l.Parent = frame
        return l
    end

    fpsLabel  = mkLabel()
    pingLabel = mkLabel()

    local accum, frames = 0, 0
    statsRenderConn = RunService.RenderStepped:Connect(function(dt)
        accum += dt; frames += 1
        if accum >= 0.5 and fpsLabel then
            local fps = math.floor(frames / accum + 0.5)
            accum, frames = 0, 0
            fpsLabel.Text = "FPS  " .. fps
            fpsLabel.TextColor3 = fps >= 50 and Color3.fromRGB(120, 235, 140)
                or fps >= 30 and Color3.fromRGB(245, 215, 110)
                or Color3.fromRGB(245, 110, 110)
        end
    end)

    task.spawn(function()
        while statsActive and statsGui and statsGui.Parent do
            if pingLabel then
                local p = getPing()
                pingLabel.Text = "Ping  " .. p .. " ms"
                pingLabel.TextColor3 = p <= 90 and Color3.fromRGB(120, 235, 140)
                    or p <= 180 and Color3.fromRGB(245, 215, 110)
                    or Color3.fromRGB(245, 110, 110)
            end
            task.wait(1)
        end
    end)
end

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("DarkHUB")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Tabs.Settings:AddSection("Display")
Tabs.Settings:AddToggle("StatsEnabled", {
    Title = "Show Stats (Ping / FPS)",
    Default = false,
    Callback = function(s) if s then startStats() else stopStats() end end,
})

Tabs.Settings:AddSection("Server Info")
Tabs.Settings:AddParagraph({
    Title = "Server Info",
    Content = "Place ID:  " .. game.PlaceId
        .. "\nGame ID:   " .. game.GameId
        .. "\nPlayers:   " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers,
})

Tabs.Settings:AddSection("Server Actions")
Tabs.Settings:AddButton({
    Title = "Rejoin",
    Callback = function()
        notify({ Title = "Rejoin", Content = "Reconectando ao servidor...", Duration = 3 })
        task.spawn(function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end) end)
    end,
})
Tabs.Settings:AddButton({ Title = "Server Hop", Callback = serverHop })

Window:SelectTab(1)

task.defer(function()
    protectGui()
    Booted = true
    Fluent:Notify({
        Title = "DarkHUB",
        Content = "Script carregado com sucesso!",
        SubContent = "Universal Script",
        Duration = 6,
    })
end)
