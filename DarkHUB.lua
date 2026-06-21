local Fluent           = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer
local Options          = Fluent.Options

-- Stealth: IDs únicos por sessão para evitar fingerprint de nomes fixos
local _RC = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local function _RS(n)
    local t = {}
    for i = 1, n do t[i] = _RC:sub(math.random(1, #_RC), math.random(1, #_RC)) end
    return table.concat(t)
end
local _TAG     = _RS(7)          -- prefixo único de instâncias criadas
local _GLS     = "_" .. _RS(13) -- key getgenv para loadstring original
local _GRQ     = "_" .. _RS(13) -- key getgenv para require original
local _BRKJIT  = math.random(370, 620) -- intervalo de re-scan com jitter
local _FF_NAME = _TAG .. _RS(4) -- nome do ForceField (ex: "XqkRpmWrtZ")
local _BB_NAME = _TAG .. _RS(4) -- nome do BillboardGui
local _BV_NAME = _TAG .. _RS(4) -- nome do BodyVelocity
local _BG_NAME = _TAG .. _RS(4) -- nome do BodyGyro

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

-- Tentar proteger/mover a GUI do menu para evitar varreduras de AC
task.defer(function()
    pcall(function()
        local hui = pcall(function() return gethui() end) and gethui()
        for _, g in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            pcall(function()
                if syn and syn.protect_gui then syn.protect_gui(g) end
                if protect_gui then protect_gui(g) end
                if hui then g.Parent = hui end
            end)
        end
    end)
end)

local Tabs = {
    ESP      = Window:AddTab({ Title = "ESP",            Icon = "eye"        }),
    Movement = Window:AddTab({ Title = "Movement",       Icon = "move"       }),
    World    = Window:AddTab({ Title = "World",          Icon = "sun"        }),
    Player   = Window:AddTab({ Title = "Player",         Icon = "user"       }),
    Bypass   = Window:AddTab({ Title = "Bypass",         Icon = "shield-off" }),
    Fling    = Window:AddTab({ Title = "Fling",          Icon = "swords"     }),
    External = Window:AddTab({ Title = "External Tools", Icon = "package"    }),
    Settings = Window:AddTab({ Title = "Settings",       Icon = "settings"   }),
}

local function opt(key)
    local o = Options[key]
    return o and o.Value
end

local function getChar() return LocalPlayer.Character end
local function getHRP()  local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function disconnectAll(t)
    for _, c in ipairs(t) do c:Disconnect() end
    table.clear(t)
end

local function playerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then list[#list + 1] = p.Name end
    end
    return #list > 0 and list or { "(none)" }
end

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

-- URLs suspeitas que ACs usam para reportar ou verificar
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

local matchesAC   = function(n) return matchesList(n, AC_PATS)   end
local matchesBan  = function(n) return matchesList(n, BAN_PATS)  end
local matchesKick = function(n) return matchesList(n, KICK_PATS) end

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
local antiBanKickConns = {}

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
        pcall(function()
            local n = v.Name
            if v:IsA("LocalScript") or v:IsA("Script") then
                if matchesAC(n) or matchesBan(n) or matchesKick(n) then task.wait(); nukeInstance(v, _statsDummy) end
            elseif v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
                if matchesAC(n) or matchesBan(n) or matchesKick(n) then nukeInstance(v, _statsDummy) end
            end
        end)
    end)
    local tick    = 0
    local curLimit = _BRKJIT
    breakerConns[2] = RunService.Heartbeat:Connect(function()
        tick += 1
        if tick < curLimit then return end
        tick = 0
        curLimit = math.random(370, 620) -- re-jitter a cada ciclo
        if opt("ACBreakerEnabled") then task.spawn(runFullScan) end
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
                            if v:IsA("BindableEvent")  then disableSignal(v.Event)         end
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

local function startAntiBanKickMonitor()
    disconnectAll(antiBanKickConns)
    antiBanKickConns[1] = game.DescendantAdded:Connect(function(v)
        if not opt("AntiKickBanEnabled") then return end
        pcall(function()
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
                if matchesKick(v.Name) or matchesBan(v.Name) then
                    if v:IsA("RemoteEvent")    then disableSignal(v.OnClientEvent) end
                    if v:IsA("BindableEvent")  then disableSignal(v.Event)         end
                    if v:IsA("RemoteFunction") then pcall(function() v.OnClientInvoke = function() return nil end end) end
                    pcall(function() v:Destroy() end)
                end
            end
        end)
    end)
end

local function stopAntiBanKickMonitor() disconnectAll(antiBanKickConns) end

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

        -- Usar keys aleatórias de sessão para não deixar "_DH_origLS" como fingerprint
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
            -- Spoof __tostring do ambiente para não revelar hooks
            local origTS = rawget(gmt, "__tostring")
            gmt.__tostring = newcclosure(function(v)
                if origTS then return origTS(v) end
                return tostring(v)
            end)
            setreadonly(gmt, true)
        end)
    end)
    return ok, wiped, spoofed
end

local namecallHooked   = false
local namecallOriginal = nil
local newindexHooked   = false
local newindexOriginal = nil
local indexHooked      = false
local indexOriginal    = nil
local protectHumanoid  = nil
local protectHRP       = nil

local function initNamecallHook()
    if namecallHooked then return true end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        namecallOriginal = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local nameL  = ""
            pcall(function() nameL = self.Name:lower() end)

            -- Bloquear HttpGetAsync / GetAsync para URLs suspeitas de AC
            if method == "GetAsync" or method == "HttpGetAsync" or method == "PostAsync" then
                local args = { ... }
                local url  = type(args[1]) == "string" and args[1] or ""
                if matchesACUrl(url) then return "" end
            end

            if opt("AntiKickBanEnabled") then
                if (method == "Kick" or method == "BootFromGame") and self == LocalPlayer then return end
                if method == "KickPlayer" and self == Players then
                    local a = { ... }
                    if a[1] == LocalPlayer.UserId or a[1] == LocalPlayer then return end
                end
                if method == "FireServer" or method == "InvokeServer" then
                    if matchesKick(nameL) or matchesBan(nameL) then return end
                end
                if method == "Fire" or method == "Invoke" then
                    if matchesKick(nameL) or matchesBan(nameL) then
                        return method == "Invoke" and false or nil
                    end
                end
                if (method == "FireClient" or method == "FireAllClients") and (matchesKick(nameL) or matchesBan(nameL)) then
                    return
                end
            end

            if opt("AntiCheatRemoteBlock") then
                if method == "FireServer" or method == "InvokeServer" or method == "Fire" or method == "Invoke" then
                    if matchesAC(nameL) then return end
                end
            end

            if opt("GodHookDamage") and method == "TakeDamage" and self == protectHumanoid then
                return 0
            end

            return namecallOriginal(self, ...)
        end)
        setreadonly(mt, true)
        namecallHooked = true
    end)
    return ok
end

local function initNewindexHook()
    if newindexHooked then return true end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        newindexOriginal = mt.__newindex
        setreadonly(mt, false)
        mt.__newindex = newcclosure(function(self, prop, val)
            if opt("SpeedProtectEnabled") and prop == "WalkSpeed" and self == protectHumanoid then
                local desired = opt("SpeedEnabled") and (opt("SpeedValue") or 50) or 16
                if val ~= desired then return end
            end
            if opt("NoClipProtectEnabled") and opt("NoClipEnabled") and prop == "CanCollide" and val == true and self ~= protectHRP then
                local c = getChar()
                if c then
                    local ok2, desc = pcall(function() return self:IsDescendantOf(c) end)
                    if ok2 and desc then return end
                end
            end
            if opt("FlyProtectEnabled") and opt("FlyEnabled") and prop == "PlatformStand" and val == false and self == protectHumanoid then
                return
            end
            if opt("GodProtectEnabled") and self == protectHumanoid then
                if (prop == "Health" and val <= 0) or (prop == "MaxHealth" and val <= 0) then return end
            end
            return newindexOriginal(self, prop, val)
        end)
        setreadonly(mt, true)
        newindexHooked = true
    end)
    return ok
end

local function initIndexHook()
    if indexHooked then return true end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        indexOriginal = mt.__index
        setreadonly(mt, false)
        mt.__index = newcclosure(function(self, prop)
            if opt("SpeedSpoofEnabled") and prop == "WalkSpeed" and self == protectHumanoid then
                return 16
            end
            return indexOriginal(self, prop)
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
        disc(hum:GetPropertyChangedSignal("Health"))
        disc(hum:GetPropertyChangedSignal("MaxHealth"))
        disc(hum.StateChanged)
        disc(hum.ChildAdded)
    end
    if hrp then
        disc(hrp:GetPropertyChangedSignal("CFrame"))
        disc(hrp:GetPropertyChangedSignal("Anchored"))
        disc(hrp:GetPropertyChangedSignal("AssemblyLinearVelocity"))
        disc(hrp.ChildAdded)
        disc(hrp.ChildRemoved)
    end
    disc(char.ChildAdded)
    disc(char.ChildRemoved)
    disc(char.DescendantAdded)
    disc(char.DescendantRemoving)
    return count
end

local highlights    = {}
local billboards    = {}
local bbHealthConns = {}

local function removeHighlight(player)
    if highlights[player] then highlights[player]:Destroy(); highlights[player] = nil end
end

local function removeBillboard(player)
    if bbHealthConns[player] then bbHealthConns[player]:Disconnect(); bbHealthConns[player] = nil end
    if billboards[player]    then billboards[player]:Destroy();       billboards[player]    = nil end
end

local function createHighlight(player)
    local char = player.Character; if not char then return end
    removeHighlight(player)
    local h = Instance.new("Highlight")
    h.FillTransparency    = 0.5
    h.OutlineTransparency = 0
    h.FillColor    = opt("ESPFillColor")    or Color3.fromRGB(255, 50, 50)
    h.OutlineColor = opt("ESPOutlineColor") or Color3.fromRGB(255, 255, 255)
    h.Adornee = char; h.Parent = char
    highlights[player] = h
end

local function createBillboard(player)
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    removeBillboard(player)

    local bb = Instance.new("BillboardGui")
    -- Nome aleatório por sessão para evitar detecção por nome fixo
    bb.Name = _BB_NAME; bb.Adornee = hrp; bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 100, 0, 30); bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.ResetOnSpawn = false; bb.Parent = char

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Text = player.Name; nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Name = "NameTag"
    nameLabel.Visible = opt("ESPNameTags") or false
    nameLabel.Parent = bb

    local barBg = Instance.new("Frame")
    barBg.Name = "HealthBarBg"; barBg.Size = UDim2.new(1, 0, 0.3, 0)
    barBg.Position = UDim2.new(0, 0, 0.7, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    barBg.BorderSizePixel = 0; barBg.Visible = opt("ESPHealthBar") or false
    barBg.Parent = bb

    local barFill = Instance.new("Frame")
    barFill.Name = "HealthFill"; barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    barFill.BorderSizePixel = 0; barFill.Parent = barBg

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local function updateBar()
            if not barFill.Parent then return end
            local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            barFill.Size = UDim2.new(pct, 0, 1, 0)
            barFill.BackgroundColor3 = Color3.fromRGB(math.floor((1 - pct) * 255), math.floor(pct * 200), 0)
        end
        bbHealthConns[player] = hum.HealthChanged:Connect(updateBar)
        updateBar()
    end

    billboards[player] = bb
end

local function updateESPForPlayer(player)
    if player == LocalPlayer then return end
    local char     = player.Character
    local alive    = char and char:FindFirstChild("HumanoidRootPart")
    local sameTeam = opt("ESPTeamCheck") and (player.Team == LocalPlayer.Team)
    local espOn    = opt("ESPEnabled")
    local tagOn    = opt("ESPNameTags")
    local barOn    = opt("ESPHealthBar")

    if espOn and alive and not sameTeam then
        if not highlights[player] or not highlights[player].Parent then createHighlight(player) end
        local h = highlights[player]
        if h then
            h.FillColor    = opt("ESPFillColor")    or Color3.fromRGB(255, 50, 50)
            h.OutlineColor = opt("ESPOutlineColor") or Color3.fromRGB(255, 255, 255)
        end
    else
        removeHighlight(player)
    end

    if (tagOn or barOn) and alive then
        if not billboards[player] or not billboards[player].Parent then createBillboard(player) end
        local bb = billboards[player]
        if bb then
            local nl = bb:FindFirstChild("NameTag");     if nl then nl.Visible = tagOn or false end
            local bg = bb:FindFirstChild("HealthBarBg"); if bg then bg.Visible = barOn or false end
        end
    else
        removeBillboard(player)
    end
end

local function refreshESP()
    for _, p in ipairs(Players:GetPlayers()) do updateESPForPlayer(p) end
end

Players.PlayerRemoving:Connect(function(p) removeHighlight(p); removeBillboard(p) end)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5); updateESPForPlayer(p) end)
end)

Tabs.ESP:AddSection("Player ESP")
Tabs.ESP:AddToggle("ESPEnabled",   { Title = "Enable ESP",  Default = false, Callback = function() refreshESP() end })
Tabs.ESP:AddToggle("ESPTeamCheck", { Title = "Team Check",  Default = false, Callback = function() refreshESP() end })
local espFill = Tabs.ESP:AddColorpicker("ESPFillColor",    { Title = "Fill Color",    Default = Color3.fromRGB(255, 50, 50)   })
local espOut  = Tabs.ESP:AddColorpicker("ESPOutlineColor", { Title = "Outline Color", Default = Color3.fromRGB(255, 255, 255) })
espFill:OnChanged(function() refreshESP() end)
espOut:OnChanged(function()  refreshESP() end)

Tabs.ESP:AddSection("Name Tags & Health")
Tabs.ESP:AddToggle("ESPNameTags",  { Title = "Name Tags",  Default = false, Callback = function() refreshESP() end })
Tabs.ESP:AddToggle("ESPHealthBar", { Title = "Health Bar", Default = false, Callback = function() refreshESP() end })

local function applySpeed()
    local hum = getHum(); if not hum then return end
    hum.WalkSpeed = opt("SpeedEnabled") and (opt("SpeedValue") or 50) or 16
end

local function applyNoClip()
    local char = getChar(); if not char then return end
    local target = not (opt("NoClipEnabled") or false)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.CanCollide ~= target then
            p.CanCollide = target
        end
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
    flyBV.Name = _BV_NAME -- nome aleatório por sessão
    flyBV.Velocity = Vector3.zero; flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge); flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.Name = _BG_NAME -- nome aleatório por sessão
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
        Fluent:Notify({ Title = "Vehicle Fly", Content = "Você precisa estar dentro de um veículo.", Duration = 3 })
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

local function applyAntiRagdoll()
    local hum = getHum(); if not hum then return end
    local en = opt("AntiRagdollEnabled") or false
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not en) end)
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     not en) end)
end

local antiFallConn

local function setupAntiFallDamage()
    if antiFallConn then antiFallConn:Disconnect(); antiFallConn = nil end
    local hum = getHum(); if not hum then return end
    local savedHealth, wasFalling = hum.Health, false
    antiFallConn = hum.StateChanged:Connect(function(_, newState)
        if not opt("AntiFallDamageEnabled") then return end
        if newState == Enum.HumanoidStateType.Freefall then
            savedHealth = hum.Health; wasFalling = true
        elseif wasFalling then
            wasFalling = false
            task.spawn(function()
                task.wait()
                if hum.Parent and hum.Health < savedHealth then hum.Health = savedHealth end
            end)
        end
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

local waypoints     = {}
local waypointCount = 0
local waypointDrop  = nil

Tabs.Movement:AddSection("Movement")
Tabs.Movement:AddToggle("SpeedEnabled",        { Title = "Speed Hack",        Default = false, Callback = function()  applySpeed()  end })
Tabs.Movement:AddSlider("SpeedValue",          { Title = "Walk Speed",        Default = 50, Min = 16, Max = 300, Rounding = 0, Callback = function() applySpeed() end })
Tabs.Movement:AddToggle("NoClipEnabled",       { Title = "NoClip",            Default = false, Callback = function()  applyNoClip() end })
Tabs.Movement:AddToggle("FlyEnabled",          { Title = "Fly",               Default = false, Callback = function(s) if s then enableFly()         else disableFly()         end end })
Tabs.Movement:AddSlider("FlySpeed",            { Title = "Fly Speed",         Default = 50,  Min = 10, Max = 300, Rounding = 0, Callback = function() end })
Tabs.Movement:AddToggle("VehicleFlyEnabled",   { Title = "Vehicle Fly",       Default = false, Callback = function(s) if s then enableVehicleFly()  else disableVehicleFly()  end end })
Tabs.Movement:AddSlider("VehicleFlySpeed",     { Title = "Vehicle Fly Speed", Default = 100, Min = 10, Max = 500, Rounding = 0, Callback = function() end })
Tabs.Movement:AddToggle("InfinityJumpEnabled", { Title = "Infinity Jump",     Default = false, Callback = function(s) if s then enableInfinityJump() else disableInfinityJump() end end })
Tabs.Movement:AddToggle("WalkOnAirEnabled",    { Title = "Walk on Air",       Default = false, Callback = function(s) if s then enableWalkOnAir()   else disableWalkOnAir()   end end })

Tabs.Movement:AddSection("Safety")
Tabs.Movement:AddToggle("AntiRagdollEnabled",    { Title = "Anti-Ragdoll",     Default = false, Callback = function() applyAntiRagdoll() end })
Tabs.Movement:AddToggle("AntiFallDamageEnabled", { Title = "Anti-Fall Damage", Default = false, Callback = function(s)
    if s then setupAntiFallDamage() else if antiFallConn then antiFallConn:Disconnect(); antiFallConn = nil end end
end })

Tabs.Movement:AddSection("Teleport")
Tabs.Movement:AddToggle("ClickTPEnabled", { Title = "Click TP", Default = false, Callback = function() end })
Tabs.Movement:AddButton({
    Title    = "TP to Spawn",
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
            Fluent:Notify({ Title = "TP to Spawn", Content = "Teletransportado para o spawn.", Duration = 3 })
        else
            Fluent:Notify({ Title = "TP to Spawn", Content = "Spawn não encontrado.", Duration = 3 })
        end
    end,
})

Tabs.Movement:AddSection("Waypoints")
Tabs.Movement:AddInput("WaypointName", { Title = "Waypoint Name", Placeholder = "Nome do waypoint", Numeric = false, Finished = false, Callback = function() end })
Tabs.Movement:AddButton({
    Title    = "Save Waypoint",
    Callback = function()
        local hrp = getHRP(); if not hrp then return end
        local name = opt("WaypointName")
        if not name or name == "" then waypointCount += 1; name = "WP" .. waypointCount end
        waypoints[name] = hrp.CFrame
        local keys = {}
        for k in pairs(waypoints) do keys[#keys + 1] = k end
        if waypointDrop then pcall(function() waypointDrop:SetValues(keys) end) end
        Fluent:Notify({ Title = "Waypoints", Content = "Waypoint '" .. name .. "' salvo!", Duration = 3 })
    end,
})
waypointDrop = Tabs.Movement:AddDropdown("WaypointSelect", { Title = "Select Waypoint", Values = {}, Multi = false, Default = nil, Callback = function() end })
Tabs.Movement:AddButton({
    Title    = "Teleport to Waypoint",
    Callback = function()
        local sel = opt("WaypointSelect")
        if not sel or sel == "" then Fluent:Notify({ Title = "Waypoints", Content = "Selecione um waypoint.", Duration = 3 }); return end
        local cf = waypoints[sel]
        if not cf then Fluent:Notify({ Title = "Waypoints", Content = "Waypoint não encontrado.", Duration = 3 }); return end
        local hrp = getHRP()
        if hrp then hrp.CFrame = cf; Fluent:Notify({ Title = "Waypoints", Content = "Teleportado para '" .. sel .. "'.", Duration = 3 }) end
    end,
})
Tabs.Movement:AddButton({
    Title    = "Delete Waypoint",
    Callback = function()
        local sel = opt("WaypointSelect")
        if not sel or sel == "" then Fluent:Notify({ Title = "Waypoints", Content = "Selecione um waypoint.", Duration = 3 }); return end
        waypoints[sel] = nil
        local keys = {}
        for k in pairs(waypoints) do keys[#keys + 1] = k end
        if waypointDrop then pcall(function() waypointDrop:SetValues(keys) end) end
        Fluent:Notify({ Title = "Waypoints", Content = "Waypoint '" .. sel .. "' deletado.", Duration = 3 })
    end,
})

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

Tabs.Movement:AddSection("Utility")
Tabs.Movement:AddToggle("AntiAFKEnabled", { Title = "Anti-AFK", Default = false, Callback = function() end })
LocalPlayer.Idled:Connect(function()
    if opt("AntiAFKEnabled") then
        pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
    end
end)

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

local freecamActive    = false
local freecamConn      = nil
local freecamMouseConn = nil
local freecamCF        = CFrame.new(0, 10, 0)

local function stopFreecam()
    freecamActive = false
    if freecamConn      then freecamConn:Disconnect();      freecamConn      = nil end
    if freecamMouseConn then freecamMouseConn:Disconnect(); freecamMouseConn = nil end
    Camera.CameraType = Enum.CameraType.Custom
    local hum = getHum(); if hum then Camera.CameraSubject = hum end
end

local function startFreecam()
    if freecamActive then stopFreecam() end
    freecamActive = true; freecamCF = Camera.CFrame
    Camera.CameraType = Enum.CameraType.Scriptable

    freecamConn = RunService.RenderStepped:Connect(function(dt)
        if not freecamActive then return end
        local speed = (opt("FreecamSpeed") or 1) * 60 * dt
        local dir   = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir += freecamCF.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir -= freecamCF.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir -= freecamCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir += freecamCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis         end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis         end
        if dir.Magnitude > 0 then
            freecamCF = CFrame.new(freecamCF.Position + dir.Unit * speed) * (freecamCF - freecamCF.Position)
        end
        Camera.CFrame = freecamCF
    end)

    freecamMouseConn = UserInputService.InputChanged:Connect(function(input)
        if not freecamActive or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = input.Delta
        freecamCF = CFrame.new(freecamCF.Position)
            * (freecamCF - freecamCF.Position)
            * CFrame.Angles(0, math.rad(-d.X * 0.3), 0)
            * CFrame.Angles(math.rad(-d.Y * 0.3), 0, 0)
    end)
end

Tabs.World:AddSection("Lighting")
Tabs.World:AddToggle("FullbrightEnabled",    { Title = "Fullbright",     Default = false, Callback = setFullbright    })
Tabs.World:AddToggle("NoFogEnabled",         { Title = "No Fog",         Default = false, Callback = setNoFog         })
Tabs.World:AddToggle("RemoveEffectsEnabled", { Title = "Remove Effects", Default = false, Callback = setRemoveEffects })

Tabs.World:AddSection("Freecam")
Tabs.World:AddToggle("FreecamEnabled", { Title = "Freecam",       Default = false, Callback = function(s) if s then startFreecam() else stopFreecam() end end })
Tabs.World:AddSlider("FreecamSpeed",   { Title = "Freecam Speed", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function() end })

Tabs.Player:AddSection("Player TP")
local playerTPDrop = Tabs.Player:AddDropdown("PlayerTPTarget", { Title = "Select Player", Values = playerList(), Multi = false, Default = 1 })
Tabs.Player:AddButton({
    Title    = "Teleport",
    Callback = function()
        local name = opt("PlayerTPTarget")
        if not name or name == "(none)" then return end
        local target = Players:FindFirstChild(name)
        if not target or not target.Character then Fluent:Notify({ Title = "Player TP", Content = "Jogador não encontrado.", Duration = 3 }); return end
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = getHRP()
        if tHRP and hrp then hrp.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0); Fluent:Notify({ Title = "Player TP", Content = "Teleportado para " .. name, Duration = 3 }) end
    end,
})
Tabs.Player:AddButton({
    Title    = "Refresh List",
    Callback = function()
        local list = playerList()
        pcall(function() playerTPDrop:SetValues(list) end)
        Fluent:Notify({ Title = "Player TP", Content = "Lista atualizada.", Duration = 2 })
    end,
})

Tabs.Player:AddSection("Player Spy")
local playerSpyDrop = Tabs.Player:AddDropdown("PlayerSpyTarget", { Title = "Spy on Player", Values = playerList(), Multi = false, Default = 1 })

local function startSpy()
    local name = opt("PlayerSpyTarget"); if not name or name == "(none)" then return end
    local target = Players:FindFirstChild(name)
    if not target or not target.Character then Fluent:Notify({ Title = "Player Spy", Content = "Jogador não encontrado.", Duration = 3 }); return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if hum then Camera.CameraSubject = hum; Fluent:Notify({ Title = "Player Spy", Content = "Espionando " .. name, Duration = 3 }) end
end

local function stopSpy()
    local hum = getHum(); if hum then Camera.CameraSubject = hum end
end

Tabs.Player:AddToggle("SpyEnabled", { Title = "Enable Spy", Default = false, Callback = function(s) if s then startSpy() else stopSpy() end end })
playerSpyDrop:OnChanged(function() if opt("SpyEnabled") then startSpy() end end)

Tabs.Player:AddSection("God Mode")
Tabs.Player:AddParagraph({
    Title   = "Aviso",
    Content = "Ative múltiplos métodos ao mesmo tempo para maior proteção.\nMétodos avançados requerem executor compatível.",
})
Tabs.Player:AddToggle("GodHealthRestore", { Title = "Health Restore",   Default = false, Callback = function() end })
Tabs.Player:AddToggle("GodForcefield", {
    Title    = "Forcefield",
    Default  = false,
    Callback = function(state)
        local char = getChar(); if not char then return end
        -- Usa _FF_NAME (aleatório por sessão) em vez de "DH_FF" fixo
        for _, v in ipairs(char:GetChildren()) do if v:IsA("ForceField") and v.Name == _FF_NAME then v:Destroy() end end
        if state then
            local ff = Instance.new("ForceField"); ff.Name = _FF_NAME; ff.Visible = false; ff.Parent = char
        end
    end,
})
Tabs.Player:AddToggle("GodMaxHealth", {
    Title    = "Infinite Health",
    Default  = false,
    Callback = function(state)
        local hum = getHum(); if not hum then return end
        if state then hum.MaxHealth = math.huge; hum.Health = math.huge
        else          hum.MaxHealth = 100;       hum.Health = 100 end
    end,
})
Tabs.Player:AddToggle("GodDeadState", {
    Title    = "Disable Dead State",
    Default  = false,
    Callback = function(state)
        local hum = getHum(); if not hum then return end
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not state) end)
    end,
})
Tabs.Player:AddToggle("GodHookDamage", {
    Title    = "Hook TakeDamage",
    Default  = false,
    Callback = function(state)
        if not state then return end
        if not initNamecallHook() then
            Fluent:Notify({ Title = "God Mode", Content = "Executor não suporta hook de TakeDamage.", Duration = 4 })
        end
    end,
})

local flyGuardConn

local function startFlyGuard()
    if flyGuardConn then flyGuardConn:Disconnect() end
    flyGuardConn = RunService.Heartbeat:Connect(function()
        if not opt("FlyProtectEnabled") or not opt("FlyEnabled") then return end
        if not flyBV or not flyBV.Parent then task.spawn(enableFly) end
    end)
end

local function stopFlyGuard()
    if flyGuardConn then flyGuardConn:Disconnect(); flyGuardConn = nil end
end

Tabs.Bypass:AddSection("Game Bypass")
Tabs.Bypass:AddParagraph({
    Title   = "Aviso",
    Content = "Apaga globals do executor, falsifica funções de identificação,\nhookeia loadstring/require e bloqueia leituras via __index.\nRequer executor com getgenv() + metamétodos.",
})
Tabs.Bypass:AddToggle("GameBypassEnabled", {
    Title    = "Fingerprint Wipe",
    Default  = false,
    Callback = function(state)
        if not state then return end
        local ok, wiped, spoofed = runGameBypass()
        Fluent:Notify({
            Title      = "Fingerprint Wipe",
            Content    = ok and "Bypass aplicado com sucesso." or "Executor não suporta getgenv().",
            SubContent = ok and ("Globals apagadas: " .. wiped .. "  |  Funções falsificadas: " .. spoofed) or nil,
            Duration   = 5,
        })
    end,
})

Tabs.Bypass:AddSection("Anti-Kick & Ban")
Tabs.Bypass:AddParagraph({
    Title   = "Aviso",
    Content = "Bloqueia Kick(), BootFromGame(), KickPlayer() e qualquer\nFireServer/InvokeServer com nome de kick ou ban.\nDestrói remotes de kick/ban e monitora novos.",
})
Tabs.Bypass:AddToggle("AntiKickBanEnabled", {
    Title    = "Anti-Kick & Ban",
    Default  = false,
    Callback = function(state)
        if state then
            local ok      = initNamecallHook()
            local removed = destroyKickBanRemotes()
            startAntiBanKickMonitor()
            Fluent:Notify({
                Title      = "Anti-Kick & Ban",
                Content    = ok and "Ativo — kicks e bans bloqueados." or "Executor sem suporte a metamétodos.",
                SubContent = removed > 0 and ("Remotes destruídas: " .. removed) or "Nenhuma remote de kick/ban encontrada.",
                Duration   = 5,
            })
        else
            stopAntiBanKickMonitor()
            Fluent:Notify({ Title = "Anti-Kick & Ban", Content = "Desativado.", Duration = 4 })
        end
    end,
})

Tabs.Bypass:AddSection("Anti-Cheat Bypass")
Tabs.Bypass:AddParagraph({
    Title   = "Aviso",
    Content = "Breaker: varre todos os serviços, desconecta signals,\nhookeia loadstring/require e re-scana em intervalo aleatório.\nScan: varredura única + inspeção de source de scripts.\nMonitor: DescendantAdded no player.\nRemote Block: bloqueia FireServer de AC.\nHTTP Block: bloqueia GetAsync de URLs suspeitas.",
})
Tabs.Bypass:AddToggle("ACBreakerEnabled", {
    Title    = "Anti-Cheat Breaker",
    Default  = false,
    Callback = function(state)
        if state then
            initNamecallHook()
            if Options.AntiCheatRemoteBlock then Options.AntiCheatRemoteBlock:SetValue(true) end
            local r = runFullScan()
            startBreakerMonitor()
            Fluent:Notify({
                Title      = "Anti-Cheat Breaker",
                Content    = "Ativo — anti-cheat destruído em todos os serviços.",
                SubContent = "Desativados: " .. r.disabled .. "  |  Destruídos: " .. r.destroyed .. (r.conns > 0 and ("  |  Signals: " .. r.conns) or ""),
                Duration   = 6,
            })
        else
            stopBreakerMonitor()
            Fluent:Notify({ Title = "Anti-Cheat Breaker", Content = "Monitor desativado.", Duration = 3 })
        end
    end,
})
Tabs.Bypass:AddButton({
    Title    = "Full Scan & Disable",
    Callback = function()
        local r = runPlayerScan(); initNamecallHook()
        Fluent:Notify({
            Title      = "Anti-Cheat Scan",
            Content    = "Scan concluído.",
            SubContent = "Scripts desativados: " .. r.disabled .. "  |  Remotes removidas: " .. r.destroyed,
            Duration   = 5,
        })
    end,
})
Tabs.Bypass:AddToggle("AntiCheatMonitor", {
    Title    = "Anti-Cheat Monitor",
    Default  = false,
    Callback = function(state)
        if state then runPlayerScan(); startACMonitor(); Fluent:Notify({ Title = "Anti-Cheat Monitor", Content = "Monitor ativo.", Duration = 4 })
        else stopACMonitor() end
    end,
})
Tabs.Bypass:AddToggle("AntiCheatRemoteBlock", {
    Title    = "Remote Report Block",
    Default  = false,
    Callback = function(state)
        if not state then return end
        local ok = initNamecallHook()
        Fluent:Notify({ Title = "Remote Report Block", Content = ok and "Ativo — remotes de AC bloqueadas." or "Executor sem suporte.", Duration = 4 })
    end,
})

Tabs.Bypass:AddSection("Action Protect")
Tabs.Bypass:AddToggle("SpeedProtectEnabled",  { Title = "Speed Protect",  Default = false, Callback = function(s) if s then initNewindexHook() end end })
Tabs.Bypass:AddToggle("SpeedSpoofEnabled",    { Title = "Speed Spoof",    Default = false, Callback = function(s) if s then initIndexHook()    end end })
Tabs.Bypass:AddToggle("NoClipProtectEnabled", { Title = "NoClip Protect", Default = false, Callback = function(s) if s then initNewindexHook() end end })
Tabs.Bypass:AddToggle("FlyProtectEnabled",    { Title = "Fly Protect",    Default = false, Callback = function(s) if s then initNewindexHook(); startFlyGuard() else stopFlyGuard() end end })
Tabs.Bypass:AddToggle("GodProtectEnabled",    { Title = "God Protect",    Default = false, Callback = function(s) if s then initNewindexHook() end end })
Tabs.Bypass:AddButton({
    Title    = "Disconnect AC Signals",
    Callback = function()
        local count = disconnectACSignals()
        Fluent:Notify({ Title = "Signal Blocker", Content = "Sinais de AC desconectados: " .. count, Duration = 4 })
    end,
})

Tabs.Bypass:AddSection("General Spoof")
Tabs.Bypass:AddButton({
    Title    = "Activate All Spoofs",
    Callback = function()
        local keys = {
            "GameBypassEnabled","AntiKickBanEnabled","ACBreakerEnabled",
            "AntiCheatMonitor","AntiCheatRemoteBlock",
            "SpeedProtectEnabled","SpeedSpoofEnabled",
            "NoClipProtectEnabled","FlyProtectEnabled","GodProtectEnabled",
        }
        for _, k in ipairs(keys) do if Options[k] then Options[k]:SetValue(true) end end
        disconnectACSignals()
        Fluent:Notify({ Title = "General Spoof", Content = "Todos os spoofs e proteções ativados!", Duration = 5 })
    end,
})

Tabs.Bypass:AddSection("Fake Lag")
Tabs.Bypass:AddToggle("FakeLagEnabled", {
    Title    = "Lag Switch",
    Default  = false,
    Callback = function(state)
        local hrp = getHRP(); if not hrp then return end
        hrp.Anchored = state
        Fluent:Notify({ Title = "Lag Switch", Content = state and "Lag Switch ativado." or "Lag Switch desativado.", Duration = 3 })
    end,
})

local touchFlingActive  = false
local flingLoopRunning  = false
local flingAllActive    = false
local flingActive       = false
local flingOldPos       = nil
local fallenPartsHeight = workspace.FallenPartsDestroyHeight

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

local function setNoClipState(state)
    Options.NoClipEnabled:SetValue(state); applyNoClip()
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

    local vMult = opt("FlingVelocity") or 1

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
        local limit = opt("AntiFlingThreshold") or 80
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

Tabs.Fling:AddSection("Fling Target")
local flingTargetDrop = Tabs.Fling:AddDropdown("FlingTargetPlayer", { Title = "Select Target", Values = playerList(), Multi = false, Default = 1, Callback = function() end })
Tabs.Fling:AddButton({
    Title    = "Fling Target",
    Callback = function()
        local name = opt("FlingTargetPlayer")
        if not name or name == "(none)" then Fluent:Notify({ Title = "Fling Target", Content = "Selecione um alvo.", Duration = 3 }); return end
        local target = Players:FindFirstChild(name)
        if not target then Fluent:Notify({ Title = "Fling Target", Content = "Jogador não encontrado.", Duration = 3 }); return end
        task.spawn(skidFling, target)
    end,
})
Tabs.Fling:AddButton({
    Title    = "Refresh Targets",
    Callback = function() pcall(function() flingTargetDrop:SetValues(playerList()) end) end,
})

Tabs.Fling:AddSection("Fling Velocity")
Tabs.Fling:AddSlider("FlingVelocity", { Title = "Velocity Multiplier", Default = 1, Min = 0.1, Max = 5, Rounding = 1, Callback = function() end })

Tabs.Fling:AddSection("Touch Fling")
Tabs.Fling:AddToggle("TouchFlingEnabled", {
    Title    = "Touch Fling",
    Default  = false,
    Callback = function(state)
        touchFlingActive = state
        if state then
            setNoClipState(true)
            if not flingLoopRunning then task.spawn(runTouchFling) end
        else
            if not opt("FlingAllEnabled") then setNoClipState(false) end
        end
    end,
})

Tabs.Fling:AddSection("Fling All")
Tabs.Fling:AddToggle("FlingAllEnabled", {
    Title    = "Fling All",
    Default  = false,
    Callback = function(state)
        flingAllActive = state
        if state then
            setNoClipState(true)
            Fluent:Notify({ Title = "Fling All", Content = "Fling All ativado.", Duration = 3 })
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
        else
            if not opt("TouchFlingEnabled") then setNoClipState(false) end
        end
    end,
})

Tabs.Fling:AddSection("Anti-Fling")
Tabs.Fling:AddToggle("AntiFlingEnabled", {
    Title    = "Anti-Fling",
    Default  = false,
    Callback = function(state) if state then setupAntiFling() else cleanupAntiFling() end end,
})
Tabs.Fling:AddSlider("AntiFlingThreshold", { Title = "Velocity Limit", Default = 80, Min = 20, Max = 300, Rounding = 0, Callback = function() end })

Tabs.External:AddSection("External Scripts")
Tabs.External:AddParagraph({ Title = "Aviso", Content = "Estes scripts são de terceiros carregados via HttpGet.\nUse com responsabilidade." })
Tabs.External:AddButton({
    Title    = "Infinity Yield",
    Callback = function()
        Fluent:Notify({ Title = "Infinity Yield", Content = "Carregando Infinity Yield...", Duration = 3 })
        task.spawn(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
    end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    protectHumanoid = char:FindFirstChildOfClass("Humanoid")
    protectHRP      = char:FindFirstChild("HumanoidRootPart")

    applySpeed(); applyNoClip(); refreshESP()

    if opt("FlyEnabled")          then enableFly()          end
    if opt("VehicleFlyEnabled")   then enableVehicleFly()   end
    if opt("InfinityJumpEnabled") then enableInfinityJump() end
    if opt("WalkOnAirEnabled")    then enableWalkOnAir()    end
    if touchFlingActive and not flingLoopRunning then task.spawn(runTouchFling) end

    local hum = protectHumanoid
    if hum then
        if opt("GodForcefield") then
            local ff = Instance.new("ForceField"); ff.Name = _FF_NAME; ff.Visible = false; ff.Parent = char
        end
        if opt("GodMaxHealth") then hum.MaxHealth = math.huge; hum.Health = math.huge end
        if opt("GodDeadState") then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end) end
    end

    if opt("AntiRagdollEnabled")    then applyAntiRagdoll()    end
    if opt("AntiFallDamageEnabled") then setupAntiFallDamage() end

    if opt("AntiFlingEnabled") then
        clearNCCs()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then addNCCsForPlayer(p) end
        end
    end

    if protectHRP then protectHRP.Anchored = false end
    if opt("FakeLagEnabled") then Options.FakeLagEnabled:SetValue(false) end

    task.spawn(function()
        task.wait(0.3)
        disconnectACSignals()
        if opt("FlyProtectEnabled") then startFlyGuard() end
    end)
end)

do
    local c = getChar()
    if c then
        protectHumanoid = c:FindFirstChildOfClass("Humanoid")
        protectHRP      = c:FindFirstChild("HumanoidRootPart")
    end
end

RunService.Stepped:Connect(function()
    if opt("NoClipEnabled") then applyNoClip() end
end)

RunService.Heartbeat:Connect(function()
    local hum = protectHumanoid; if not hum or not hum.Parent then return end
    if opt("GodHealthRestore") then hum.Health = hum.MaxHealth end
    if opt("GodMaxHealth") and hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge; hum.Health = math.huge end
end)

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("DarkHUB")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Tabs.Settings:AddSection("Server Info")
Tabs.Settings:AddParagraph({
    Title   = "Server Info",
    Content = "Place ID:  " .. game.PlaceId
        .. "\nGame ID:   " .. game.GameId
        .. "\nPlayers:   " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers,
})

Tabs.Settings:AddSection("Server Actions")
Tabs.Settings:AddButton({
    Title    = "Rejoin",
    Callback = function()
        Fluent:Notify({ Title = "Rejoin", Content = "Reconectando ao servidor...", Duration = 3 })
        task.spawn(function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end) end)
    end,
})
Tabs.Settings:AddButton({
    Title    = "Server Hop",
    Callback = function()
        Fluent:Notify({ Title = "Server Hop", Content = "Procurando servidor alternativo...", Duration = 3 })
        task.spawn(function()
            local ok, found = pcall(function()
                local data = HttpService:JSONDecode(HttpService:GetAsync(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                ))
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        return true
                    end
                end
                return false
            end)
            if not ok or not found then
                Fluent:Notify({ Title = "Server Hop", Content = "Nenhum servidor alternativo encontrado.", Duration = 4 })
            end
        end)
    end,
})

Window:SelectTab(1)

Fluent:Notify({
    Title      = "DarkHUB",
    Content    = "Script carregado com sucesso!",
    SubContent = "Universal Script",
    Duration   = 5,
})
