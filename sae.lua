repeat task.wait() until game:IsLoaded()

do local prev = _G.TestBypassFarm; if prev and type(prev.dead)=='boolean' then prev.dead = true end end
local HUB = { conns = {}, dead = false, travelAbort = false }
_G.TestBypassFarm = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end

local Airflow

HUB.Unload = function()
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    pcall(function() clearAllEsp() end)
    if HUB._antiAfkConn then pcall(function() HUB._antiAfkConn:Disconnect() end) end
    pcall(function()
        if Airflow and Airflow.Windows and Airflow.Windows[1] then
            Airflow.Windows[1]:Destroy()
        end
    end)
    _G.TestBypassFarm = nil
    print("[Ascend] Unloaded")
end

local Players           = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService        = game:GetService('RunService')
local UserInputService  = game:GetService('UserInputService')
local Workspace         = game:GetService('Workspace')
local Lighting          = game:GetService('Lighting')
local RS                = ReplicatedStorage
local LP                = Players.LocalPlayer

-- ============================================================
-- ==============================================================================
-- CLIENT AC NEUTRALIZER & UGI CONSTANT WIPER (Layer 1 + Layer 2)
-- ==============================================================================
local function bypassClientDetections()
    if typeof(filtergc) ~= "function" or typeof(debug) ~= "table" or typeof(debug.getupvalues) ~= "function" then
        return false, "no filtergc"
    end
    local ok, fn = pcall(function()
        return filtergc("function", {
            Constants = { "gmatch", "GetFullName" },
        }, true)
    end)
    if not ok or type(fn) ~= "function" then
        return false, "filter miss"
    end
    local setMeta = (typeof(setrawmetatable) == "function" and setrawmetatable)
        or (typeof(setmetatable) == "function" and setmetatable)
    if not setMeta then
        return false, "no setmeta"
    end
    local blocked = 0
    local okUv, ups = pcall(debug.getupvalues, fn)
    if not okUv or type(ups) ~= "table" then
        return false, "no upvalues"
    end
    for _, tbl in pairs(ups) do
        if typeof(tbl) == "table" then
            local okSet = pcall(setMeta, tbl, {
                __newindex = function() end,
            })
            if okSet then
                blocked = blocked + 1
            end
        end
    end
    return blocked > 0, blocked
end

pcall(bypassClientDetections)

-- Runtime AC Detection Table Freezer (Neutralizes violation storage)
pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local setmeta = setrawmetatable or setmetatable
    local getmeta = getrawmetatable or getmetatable

    if getgc and setmeta then
        for _, obj in ipairs(getgc(true)) do
            if typeof(obj) == "table" and not (getmeta and getmeta(obj)) then
                local mainrun = false
                for _, v in pairs(obj) do
                    if v == obj then
                        mainrun = true
                        break
                    end
                end
                if mainrun then
                    for _, v in pairs(obj) do
                        if typeof(v) == "number" and v >= 1 and v <= 3 and obj[v] == nil then
                            pcall(setmeta, obj, { __newindex = function() end })
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- UGI Constant Wiper (neutralizes ReplicatedFirst.UGI watchdog)
pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local setconstant = setconstant or (debug and debug.setconstant)
    local islclosure = islclosure or function(Function)
        return not pcall(setfenv, getfenv(Function))
    end

    if getgc and getconstants and setconstant then
        for _, Function in ipairs(getgc(true)) do
            if typeof(Function) == "function" and islclosure(Function) then
                local ok, Source = pcall(debug.info, Function, "s")
                if ok and type(Source) == "string" and Source:find("ReplicatedFirst", 1, true) and Source:find("UGI", 1, true) then
                    local okC, Constants = pcall(getconstants, Function)
                    if okC and type(Constants) == "table" then
                        for Index, Constant in next, Constants do
                            if type(Constant) == "string" and Constant == "Humanoid" then
                                pcall(setconstant, Function, Index, "")
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Secondary Layer: X-14 Stack Scrubber & Token Neutralizer
pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local islclosure = islclosure or function(fn) return not pcall(setfenv, getfenv(fn)) end
    local HookFn = hookfunction or replaceclosure or hookfunc
    if getgc and getconstants and HookFn and debug and debug.getstack and debug.setstack then
        for _, fn in ipairs(getgc(true)) do
            if typeof(fn) == "function" and islclosure(fn) then
                local ok, consts = pcall(getconstants, fn)
                if ok and type(consts) == "table" and table.find(consts, "X-14") then
                    local cb = nil
                    cb = HookFn(fn, function(...)
                        local stack = debug.getstack(1)
                        if type(stack) == "table" then
                            for idx, val in pairs(stack) do
                                if val == "X-14" then
                                    pcall(debug.setstack, 1, idx, nil)
                                end
                            end
                        end
                        if cb then return cb(...) end
                    end)
                end
            end
        end
    end
end)

-- Layer 3: Anti-Tamper State Table Sanitizer (19-upvalue detection neutralization)
pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local islclosure = islclosure or function(v) return not pcall(setfenv, getfenv(v)) end
    local getupvalues = getupvalues or (debug and debug.getupvalues)
    local getupvalue = getupvalue or (debug and debug.getupvalue)
    local setupvalue = setupvalue or (debug and debug.setupvalue)
    local clonefunction = clonefunction or function(f) return function(...) return f(...) end end

    if getgc and getupvalues and getupvalue and setupvalue then
        for _, v in ipairs(getgc(true)) do
            if typeof(v) == "function" and islclosure(v) then
                local ok, upvs = pcall(getupvalues, v)
                if ok and upvs and #upvs == 19 then
                    local ok2, u2 = pcall(getupvalue, v, 2)
                    if ok2 and typeof(u2) == "function" then
                        local old = clonefunction(u2)
                        pcall(setupvalue, v, 2, function(a, b)
                            if b and typeof(b) == "table" then
                                pcall(setmetatable, b, {})
                            end
                            return old(a, b)
                        end)
                    end
                end
            end
        end
    end
end)

-- ==============================================================================
-- CHARACTER & MOVEMENT HELPERS
-- ==============================================================================
local function findChar() return LP.Character end
local function findHum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function findHRP()
    local ch = LP.Character
    return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart or ch:FindFirstChildWhichIsA("BasePart"))
end

local GetCharacter = findChar
local GetHumanoid  = findHum
local GetHRP       = findHRP

local function GetRootCFrame()
    local hrp = findHRP()
    return hrp and hrp.CFrame
end

-- ==============================================================================
-- BAC TELEMETRY PACKET SPOOFER
-- ==============================================================================
local bxor = bit32.bxor
local unpack = table.unpack

local function isGuid(n)
    return #n==36 and n:sub(9,9)=="-" and n:sub(14,14)=="-" and n:sub(19,19)=="-" and n:sub(24,24)=="-" and n:gsub("-",""):match("^%x+$")~=nil
end

local remoteSet, anyRemote = {}, nil

local function scanRemotes()
    for _, s in ipairs(game:GetChildren()) do
        local ok, list = pcall(s.GetDescendants, s)
        if ok and list then
            for _, o in ipairs(list) do
                if o:IsA("RemoteEvent") and isGuid(o.Name) then
                    remoteSet[o] = true
                    anyRemote = anyRemote or o
                end
            end
        end
    end
end

scanRemotes()

local function parseCounter(v)
    if type(v) ~= "string" then return end
    local n = v:match("^X%-(%d+)$")
    return n and tonumber(n)
end

local function looksLikeState(t, r)
    if type(t) ~= "table" then return false end
    local hR, hM = false, false
    local ok = pcall(function()
        for _, v in pairs(t) do
            if v == r then hR = true
            elseif type(v) == "string" and v:match("^X%-%d+$") then hM = true end
        end
    end)
    return ok and hR and hM
end

local function findState(r)
    for l=2,24 do
        local _, fn = pcall(debug.info, l, "f")
        if type(fn) == "function" then
            local _, ups = pcall(debug.getupvalues, fn)
            if type(ups) == "table" then
                for _, v in pairs(ups) do
                    if looksLikeState(v, r) then return v end
                    if type(v) == "table" then
                        local nested
                        pcall(function()
                            for _, x in pairs(v) do
                                if looksLikeState(x, r) then nested = x; return end
                            end
                        end)
                        if nested then return nested end
                    end
                end
            end
        end
    end
end

local function mapState(st, a1, a2)
    local m = {}
    for k, v in pairs(st) do
        if type(v) == "string" then
            if v:match("^X%-%d+$") then m.marker = m.marker or k
            elseif a1 and v == a1 then m.arg1 = m.arg1 or k
            elseif a2 and v == a2 then m.arg2 = m.arg2 or k end
        end
    end
    return m
end

local model = nil

local function digits(n)
    n = n % 1000
    return math.floor(n/100), math.floor(n/10)%10, n%10
end

local function encode(m, c)
    local d1, d2, d3 = digits(c)
    return m.prefix .. string.char(bxor(d1, m.k1), bxor(d2, m.k2), bxor(d3, m.k3))
end

local function learn(r, a1, a2)
    local st = findState(r)
    if not st then return end
    local map = mapState(st, a1, a2)
    if not map.marker then return end
    local c = parseCounter(rawget(st, map.marker))
    if not c then return end
    local d1, d2, d3 = digits(c)
    local m = {
        state = st, map = map, remote = r,
        prefix = a1:sub(1, 9),
        k1 = bxor(a1:byte(10), d1),
        k2 = bxor(a1:byte(11), d2),
        k3 = bxor(a1:byte(12), d3),
        offset = c - os.time(),
        arg2 = a2
    }
    if encode(m, c) == a1 then return m end
end

local function liveCounter(m)
    if m.state and m.map.marker then
        local _, raw = pcall(rawget, m.state, m.map.marker)
        local c = parseCounter(raw)
        if c and math.abs((c - os.time()) - m.offset) <= 5 then
            return c
        end
    end
    return os.time() + m.offset
end

local function refreshArg2(m)
    if m.state and m.map.arg2 then
        local _, v = pcall(rawget, m.state, m.map.arg2)
        if type(v) == "string" then m.arg2 = v end
    end
    return m.arg2
end

local HookFn = hookfunction or replaceclosure or hookfunc or detour_function

if anyRemote and HookFn then
    local oldFire
    oldFire = HookFn(anyRemote.FireServer, function(self, ...)
        local args = table.pack(...)
        if not remoteSet[self] then
            return oldFire(self, unpack(args, 1, args.n))
        end

        local a1 = args[1]

        if type(a1) == "string" and #a1 == 12 then
            if not model then
                model = learn(self, a1, args[2])
            else
                local c = parseCounter(rawget(model.state, model.map.marker))
                if c and encode(model, c) ~= a1 then
                    local m = learn(self, a1, args[2])
                    if m then m.spoofed = model.spoofed; model = m end
                end
            end
            return oldFire(self, unpack(args, 1, args.n))
        end

        if model and type(a1) == "string" and #a1 == 4 then
            local c = liveCounter(model)
            args[1] = encode(model, c)
            args[2] = refreshArg2(model)
            model.spoofed = (model.spoofed or 0) + 1
            return oldFire(self, unpack(args, 1, math.max(args.n, 2)))
        end

        return oldFire(self, unpack(args, 1, args.n))
    end)
end

task.spawn(function()
    while not HUB.dead do
        task.wait(10)
        local alive = false
        for r in pairs(remoteSet) do
            if r:IsDescendantOf(game) then alive = true; break end
        end
        if not alive then
            table.clear(remoteSet)
            anyRemote = nil
            model = nil
            scanRemotes()
        end
    end
end)

-- Real-time Memory Evidence Scrubber for Character Integrity
task.spawn(function()
    if not getgc then return end
    local st = nil

    local function findIntegrityTable()
        local ok, objs = pcall(getgc, true)
        if ok and objs then
            for _, o in pairs(objs) do
                if type(o) == "table" then
                    local hit = false
                    pcall(function()
                        hit = (rawget(o, "ValidationLocked") ~= nil and rawget(o, "Evidence") ~= nil)
                            or (rawget(o, "ThreatLevel") ~= nil and rawget(o, "LastObservedSample") ~= nil)
                    end)
                    if hit then return o end
                end
            end
        end
        return nil
    end

    track(LP.CharacterAdded:Connect(function()
        task.wait(1)
        st = findIntegrityTable()
    end))

    while not HUB.dead do
        if not st then
            st = findIntegrityTable()
        end

        if st then
            pcall(function()
                local ev = rawget(st, "Evidence")
                if type(ev) == "table" then
                    if (tonumber(ev.Speed)    or 0) > 0 then rawset(ev, "Speed", 0) end
                    if (tonumber(ev.Teleport) or 0) > 0 then rawset(ev, "Teleport", 0) end
                    if (tonumber(ev.Flight)   or 0) > 0 then rawset(ev, "Flight", 0) end
                end
                if rawget(st, "ThreatLevel") ~= "Trusted" then rawset(st, "ThreatLevel", "Trusted") end
                if rawget(st, "ValidationLocked") == true then rawset(st, "ValidationLocked", false) end
                if rawget(st, "FirstSuspiciousAt") ~= nil then rawset(st, "FirstSuspiciousAt", nil) end
                if rawget(st, "KickQueued") == true then rawset(st, "KickQueued", false) end
                if rawget(st, "TamperScore") ~= nil then rawset(st, "TamperScore", 0) end
                if rawget(st, "InvalidHeartbeatCount") ~= nil then rawset(st, "InvalidHeartbeatCount", 0) end

                local los = rawget(st, "LastObservedSample")
                if los ~= nil then
                    if rawget(st, "LastGameplayTrustedSample") == nil then rawset(st, "LastGameplayTrustedSample", los) end
                    if rawget(st, "LastValidatedSample") == nil then rawset(st, "LastValidatedSample", los) end
                    if rawget(st, "LastValidatedGroundedSample") == nil then rawset(st, "LastValidatedGroundedSample", los) end
                    if rawget(st, "LastConfirmedGroundSample") == nil then rawset(st, "LastConfirmedGroundSample", los) end
                    if rawget(st, "LastGoodSample") == nil then rawset(st, "LastGoodSample", los) end
                end
            end)
        end
        task.wait(0.2)
    end
end)


-- ============================================================
-- STATE
-- ============================================================
local farmEnabled    = false
local farmDelay      = 1.5
local farmSpeed      = 750
local moveMethod     = "Tween Glide"
local targetRarities = {}
local targetAreas    = {}
local targetMutations = {}
local ignoredEggs    = {}
local lingerActive   = false
-- === DROP RECOVERY STATE (egg jatuh -> ambil di tempat) ===
local dropRecovery   = true    -- toggle: pulihkan egg jatuh di lapangan
local dropMaxTries   = 3       -- berapa kali coba ambil ulang

-- ============================================================
-- FORCE TARGET EGG (anti "new cycle")
-- ============================================================
-- Masalah: kalau egg target hilang/berubah, farm memulai SIKLUS BARU
-- (balik ke safe zone -> cari egg lain). Yang diinginkan: PAKSA terus
-- mengejar egg yang sama sampai dapat, baru pindah.
-- forceTargetEgg = record egg yang sedang dikejar (UID + posisi).
local forceTargetEgg   = nil   -- { uid=, pos=, areaId=, nestId=, tries=, at= }
local forceMaxTries    = 12    -- batas supaya tidak nyangkut selamanya
local forceEggEnabled  = true  -- toggle UI
local SAFE_WAYPOINT_POS   = Vector3.new(516.4, 70.6, -367.3)
local MAIN_ROAD_Z         = -364.5
local SAFE_BOUNDARY_X     = 580
local SAFE_ZONE_SPEED     = 245

local isBigEgg           -- forward declaration (definisi di section EXTRA FUNCTIONS)
local isMutationAllowed  -- forward declaration (definisi di section EXTRA FUNCTIONS)
-- FIX: NeutralizeTraps dipakai di TravelFlyDirect (L1576) tapi baru
-- didefinisikan di section ANTI-TRAP (L2774) -> nil saat dipanggil.
local NeutralizeTraps
-- FIX: navTo dipakai di PlantAllCarriedEggsInPen (L1317) tapi baru
-- didefinisikan di section DROP RECOVERY (L1800) -> nil saat dipanggil.
local navTo
-- FIX: forceStandUp dipakai di FlyToPoint (L1718) tapi didefinisikan
-- setelahnya (L1909) -> nil saat dipanggil. Forward-declare di sini.
local forceStandUp

-- ============================================================
local S = {
    autoFavoritePets = false,
    autoFusePets = false,
    favRarities = {},
    favNames = {},
    fuseSelectedOnly = false,
    fuseNames = {},
    fuseRarities = {},
    jumpPowerEnabled = false,
    jumpPowerValue = 50,
    infiniteJumpEnabled = false,
    stealBigEggsOnly = false,
    autoHatchEnabled = false,
    autoPlantEnabled = false,
    autoUpgradeBase = false,
    autoUpgradeTreadmill = false,
    autoEquipBestPets = false,
    autoClaimRewards = false,
    autoSellPets = false,
    autoSellEggs = false,
    batAuraEnabled = false,
    batAuraRadius = 20,
    batAuraDelay = 0.2,
    flyEnabled = false,
    flySpeed = 60,
    walkSpeedEnabled = false,
    walkSpeedVal = 24,
    avoidTrapsEnabled = false,
    fpsBoost = false,
    reduceMap = false,
    hideAllPets = false,
    hideAllEggs = false,
    hidePlotVisuals = false,
    selectedSellPetRarities = {},
    selectedSellEggRarities = {},
    placeRarities = {},
}



-- MODULE LOADER
-- ============================================================
local EggState, PlotState, AreaEggSlotIdentity
local function loadModules()
    pcall(function() EggState = require(ReplicatedStorage.Client.EggState) end)
    pcall(function() PlotState = require(ReplicatedStorage.Client.PlotState) end)
    pcall(function()
        AreaEggSlotIdentity = require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity)
    end)
    return EggState ~= nil
end
pcall(loadModules)


local function GetNetRemote(name)
    local net = ReplicatedStorage:FindFirstChild("Packages")
        and ReplicatedStorage.Packages:FindFirstChild("Networking")
    return net and net:FindFirstChild(name)
end


-- ============================================================

-- MISSING VARIABLES & HELPERS
-- ============================================================
local SaveModule = nil
pcall(function() SaveModule = require(ReplicatedStorage.Shared.Save) end)

local DEFAULT_LOW_TIER_SELL = {
    ["Common"] = true, ["Uncommon"] = true, ["Rare"] = true,
    ["Epic"] = true, ["Legendary"] = true, ["Mythic"] = true,
}
local SELL_REQUEST_DELAY = 0.1
local function getSellRarityFilter(selected)
    if not selected or not next(selected) then return DEFAULT_LOW_TIER_SELL end
    return selected
end

-- forward-declare: loop ESP lama nyari GLOBAL yang isinya nil karena fungsi
-- ini baru didefinisiin sebagai local di bawah — egg ESP gagal total diem-diem
local GetEggRarityInfo

-- FIX: AssetsData dulu TIDAK pernah dideklarasikan & TIDAK pernah di-assign.
-- Akibatnya getAssetData() selalu balikin {} -> Rarity = "Unknown" terus.
-- Dideklarasikan local di sini, di-require lazy di getAssetData()/ESP.
local AssetsData

local esp = {
    enabled = false, eggs = true, traps = false, players = false,
    rareEggsOnly = false, maxDistance = 800,
    eggColor     = Color3.fromRGB(255, 200, 50),
    rareEggColor = Color3.fromRGB(255, 60, 220),
    trapColor    = Color3.fromRGB(255, 60, 60),
    playerColor  = Color3.fromRGB(100, 220, 100),
}

-- ESP storage (model ringan: hl + billboard nempel langsung ke egg, no anchor Part)
local espHighlights  = {} -- [key] = {hl=Highlight, bb=BillboardGui, lbl=TextLabel}
local espModelCache  = {} -- [key] = instance, biar gak recursive FindFirstChild tiap tick

local function espWrap(color, label)
    local ok, hex = pcall(function() return color:ToHex() end)
    if ok and hex then return '<font color="#' .. hex .. '">' .. label .. "</font>" end
    return label
end

-- FIX: ambil icon egg dengan banyak fallback, biar SEMUA gambar muncul.
-- Urutan: AssetDirectory.Icon -> ImageId -> Thumbnail -> AssetId -> ItemData
-- FIX: ambil ID gambar egg dengan cara paling tahan banting.
-- 1) cari field yang namanya jelas (Icon/ImageId/Thumbnail/AssetId/Image/DecalId)
-- 2) kalau tidak ada, SCAN SEMUA field entri -> ambil string/angka yang isinya
--    ID Roblox (8-15 digit). Nama field di AssetDirectory tidak selalu sama.
local ICON_FIELD_HINTS = {
    "icon","imageid","image","thumbnail","assetid","decalid","picture",
    "render","photo","banner","displayimage","iconid","thumb","img",
}

local function idFromValue(v)
    if type(v) ~= "string" and type(v) ~= "number" then return nil end
    local s = tostring(v)
    if s == "" then return nil end
    -- rbxassetid://123 / rbxthumb://...id=123 / angka polos
    -- PENTING: pakai %d+ (bukan pola 8-9 digit) supaya ID 10+ digit tidak
    -- kepotong jadi 9 digit.
    local num = s:match("id=(%d+)") or s:match("(%d+)")
    if not num then return nil end
    if #num < 6 then return nil end
    return num
end

local function getEggIconId(egg)
    local raw = nil
    local cat = nil

    pcall(function()
        if not AssetsData then AssetsData = require(ReplicatedStorage.Data.Assets) end
        cat = egg.AssetCategory or (egg.ItemData and egg.ItemData.AssetCategory) or egg.Category
    end)

    -- kumpulkan kandidat tabel: entry AssetDirectory, ItemData, record itu sendiri
    local dirEntry = nil
    pcall(function()
        if AssetsData and cat then
            dirEntry = (AssetsData.Directory or AssetsData)[cat]
        end
    end)

    local candidates = { dirEntry, egg.ItemData, egg }

    -- 1) nama field yang jelas
    for _, t in ipairs(candidates) do
        if type(t) == "table" then
            for _, f in ipairs({"Icon","ImageId","Thumbnail","AssetId","DecalId",
                                "Image","Picture","Render","IconId"}) do
                local num = idFromValue(t[f])
                if num then return "rbxthumb://type=Asset&id=" .. num .. "&w=150&h=150" end
            end
        end
    end

    -- 2) scan semua field (cocokkan nama field dengan hint)
    for _, t in ipairs(candidates) do
        if type(t) == "table" then
            for k, v in pairs(t) do
                local kn = tostring(k):lower():gsub("[^%a]", "")
                local isHint = false
                for _, h in ipairs(ICON_FIELD_HINTS) do
                    if kn:find(h, 1, true) then isHint = true; break end
                end
                if isHint then
                    local num = idFromValue(v)
                    if num then return "rbxthumb://type=Asset&id=" .. num .. "&w=150&h=150" end
                end
            end
        end
    end

    -- 3) terakhir: scan semua field, ambil yang ID-nya paling "masuk akal"
    --    (ID Roblox asset umumnya 8-15 digit, dan bukan ID sound/animasi)
    for _, t in ipairs(candidates) do
        if type(t) == "table" then
            for k, v in pairs(t) do
                local kn = tostring(k):lower()
                -- hindari sound/animation/earning
                if not kn:find("sound") and not kn:find("anim")
                   and not kn:find("earning") and not kn:find("weight")
                   and not kn:find("rate") and not kn:find("price")
                   and not kn:find("rarity") and not kn:find("color") then
                    local num = idFromValue(v)
                    if num and #num >= 8 and #num <= 15 then
                        return "rbxthumb://type=Asset&id=" .. num .. "&w=150&h=150"
                    end
                end
            end
        end
    end

    return nil
end

local function createEspEntry(key, model, color, label, iconId)
    local old = espHighlights[key]
    if old then
        pcall(function() old.hl:Destroy() end)
        pcall(function() old.bb:Destroy() end)
        espHighlights[key] = nil
    end

    -- part target: tempel di modelnya langsung (versi lama = +1 Part per egg)
    local part = nil
    pcall(function()
        if model:IsA("BasePart") then part = model
        else part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true) end
    end)
    if not part then return end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.72
    hl.OutlineTransparency = 0.15
    hl.FillColor = color
    hl.OutlineColor = color
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = model

    local bb = Instance.new("BillboardGui")
    bb.Adornee = part
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(220, 18)
    bb.StudsOffsetWorldSpace = Vector3.new(0, 2.2, 0)
    bb.Parent = part

    -- FIX: background hitam dihapus (BackgroundTransparency = 1).
    -- Pakai UIListLayout horizontal: [gambar] [teks]
    local box = Instance.new("Frame")
    box.AutomaticSize = Enum.AutomaticSize.X
    box.Size = UDim2.new(0, 0, 1, 0)
    box.Position = UDim2.fromScale(0.5, 0)
    box.AnchorPoint = Vector2.new(0.5, 0)
    box.BackgroundTransparency = 1          -- <-- TIDAK ada background hitam lagi
    box.BorderSizePixel = 0
    box.Parent = bb

    local lay = Instance.new("UIListLayout")
    lay.FillDirection = Enum.FillDirection.Horizontal
    lay.VerticalAlignment = Enum.VerticalAlignment.Center
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    lay.Padding = UDim.new(0, 4)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = box

    -- Gambar egg (kalau ada). rbxthumb dipakai karena bisa render Decal juga.
    if iconId and iconId ~= "" then
        local img = Instance.new("ImageLabel")
        img.LayoutOrder = 1
        img.Size = UDim2.fromOffset(20, 20)
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        img.Image = iconId
        img.Parent = box
    end

    local lbl = Instance.new("TextLabel")
    lbl.LayoutOrder = 2
    lbl.BackgroundTransparency = 1
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.RichText = true
    lbl.TextColor3 = Color3.fromRGB(235, 242, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextStrokeTransparency = 0.3
    lbl.Text = espWrap(color, label)
    lbl.Parent = box

    espHighlights[key] = { hl = hl, bb = bb, lbl = lbl, img = box:FindFirstChildWhichIsA("ImageLabel") }
end

local function clearEsp(key)
    local e = espHighlights[key]
    if e then
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.bb:Destroy() end)
        espHighlights[key] = nil
    end
    espModelCache[key] = nil
end

local function clearAllEsp()
    for k in pairs(espHighlights) do clearEsp(k) end
end

-- ESP update loop
task.spawn(function()
    while not false do
        task.wait(1)
        if not esp.enabled then
            clearAllEsp()
        else
            pcall(function()
                local hrp = findHRP()
                local myPos = hrp and hrp.Position or Vector3.zero
                local activeKeys = {}

                -- Egg ESP
                if esp.eggs and EggState and EggState.ReadFieldEggs then
                    local ok, snap = pcall(EggState.ReadFieldEggs)
                    if ok and snap and snap.Records then
                        local slots = Workspace:FindFirstChild("AreaEggSlotsClient")
                        for _, egg in ipairs(snap.Records) do
                            if egg.State == "Slot" and egg.BoundsCFrame then
                                local pos = egg.BoundsCFrame.Position
                                local dist = (pos - myPos).Magnitude
                                if dist <= esp.maxDistance then
                                    local muts = egg.Mutations or {}
                                    local isRare = #muts > 0
                                    if not esp.rareEggsOnly or isRare then
                                        local rName = GetEggRarityInfo(egg)
                                        local mutText = isRare and (" [" .. table.concat(muts, ",") .. "]") or ""
                                        local label = (egg.AssetCategory or "Egg") .. " | " .. rName .. mutText .. " | " .. math.floor(dist) .. "m"
                                        local color = isRare and esp.rareEggColor or esp.eggColor
                                        local key = "egg_" .. tostring(egg.Uid)
                                        activeKeys[key] = true

                                        -- FIX: gambar egg (multi-fallback) -> semua gambar muncul
                                        local iconId = getEggIconId(egg)

                                        -- model cache: cari sekali, pakai terus (hindari FindFirstChild rekursif tiap tick)
                                        local model = espModelCache[key]
                                        if not (model and model.Parent) then
                                            model = (slots and slots:FindFirstChild(tostring(egg.Uid)))
                                                or Workspace:FindFirstChild(egg.Uid, true)
                                            espModelCache[key] = model
                                        end
                                        if model then
                                            if not espHighlights[key] then
                                                createEspEntry(key, model, color, label, iconId)
                                            else
                                                pcall(function() espHighlights[key].lbl.Text = espWrap(color, label) end)
                                                -- FIX: gambar bisa muncul belakangan (AssetsData lazy-load)
                                                -- atau berubah. Update + fallback rbxassetid kalau rbxthumb gagal.
                                                pcall(function()
                                                    local e = espHighlights[key]
                                                    if not e then return end
                                                    local holder = e.bb and e.bb:FindFirstChildWhichIsA("Frame")
                                                    if not holder then return end
                                                    if iconId and iconId ~= "" then
                                                        if not e.img then
                                                            local img = Instance.new("ImageLabel")
                                                            img.LayoutOrder = 1
                                                            img.Size = UDim2.fromOffset(22, 22)
                                                            img.BackgroundTransparency = 1
                                                            img.ScaleType = Enum.ScaleType.Fit
                                                            img.Image = iconId
                                                            img.Parent = holder
                                                            e.img = img
                                                            e.iconId = iconId
                                                        elseif e.iconId ~= iconId then
                                                            e.img.Image = iconId
                                                            e.iconId = iconId
                                                        end
                                                    end
                                                    -- kalau rbxthumb gak ke-load, coba rbxassetid
                                                    if e.img and not e.triedAsset then
                                                        if not e.img.IsLoaded and e.iconId then
                                                            e.triedAsset = true
                                                            local num = e.iconId:match("id=(%d+)")
                                                            if num then
                                                                task.delay(1.5, function()
                                                                    if e.img and e.img.Parent and not e.img.IsLoaded then
                                                                        e.img.Image = "rbxassetid://" .. num
                                                                    end
                                                                end)
                                                            end
                                                        end
                                                    end
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- Trap ESP
                if esp.traps then
                    local debris = Workspace:FindFirstChild("__DEBRIS")
                    if debris then
                        for _, trap in ipairs(debris:GetChildren()) do
                            if trap.Name == "PlayerTrap" and trap:IsA("BasePart") then
                                local dist = (trap.Position - myPos).Magnitude
                                if dist <= esp.maxDistance then
                                    local key = "trap_" .. trap:GetDebugId()
                                    activeKeys[key] = true
                                    local owner = trap:GetAttribute("Owner") or "?"
                                    if not espHighlights[key] then
                                        createEspEntry(key, trap, esp.trapColor, "TRAP @" .. owner)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Player ESP
                if esp.players then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character then
                            local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if oHrp then
                                local dist = (oHrp.Position - myPos).Magnitude
                                if dist <= esp.maxDistance then
                                    local key = "plr_" .. p.UserId
                                    activeKeys[key] = true
                                    local label = p.Name .. " | " .. math.floor(dist) .. "m"
                                    if not espHighlights[key] then
                                        createEspEntry(key, p.Character, esp.playerColor, label)
                                    else
                                        pcall(function() espHighlights[key].lbl.Text = espWrap(esp.playerColor, label) end)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Clear stale
                for k in pairs(espHighlights) do
                    if not activeKeys[k] then clearEsp(k) end
                end
            end)
        end
    end
    clearAllEsp()
end)




-- ============================================================

-- RARITY & AREA DICTIONARIES
-- ============================================================
local RARITY_SCORE_MAP = {
    ["Light & Dark"]=2200, ["LightDark"]=2200, ["Light &Dark"]=2200,
    Exclusive=2100, Admin=2100,
    Mythical=2000, ["Squishy God"]=2000, BrainrotGod=2000,
    Brainrot=1900,
    Eternal=1800, Rainbow=1700, Prismatic=1600, Transcendent=1500,
    Celestial=1400, Cosmic=1300,
    Titan=1200, Superior=1200,
    Secret=1100, Divine=1000,
    Limited=900, Exotic=800, SuperRare=700,
    Mythic=600, Legendary=500, Epic=400, Rare=300,
    Uncommon=200, Common=100,
}
local RARITY_NAMES = {
    "Light & Dark","Exclusive","Admin","Mythical","Squishy God","BrainrotGod","Brainrot",
    "Eternal","Rainbow","Prismatic","Transcendent","Celestial","Cosmic",
    "Titan","Superior","Secret","Divine","Limited","Exotic","SuperRare",
    "Mythic","Legendary","Epic","Rare","Uncommon","Common"
}
local AREA_NAMES = {
    "Forest","Lake","Desert","Jungle","Snow","Volcano",
    "Abyss Ocean","Prehistoric","Cosmic","Cherry Blossom","Titan Temple",
    "Light Dark",
}

local AREA_COORDINATES = {
    ["Base / Plot"]    = Vector3.new(491.7, 70.4, -364.4),
    ["Forest"]         = Vector3.new(596.0, 68.0, -328.0),
    ["Lake"]           = Vector3.new(744.0, 68.5, -408.0),
    ["Desert"]         = Vector3.new(948.0, 69.5, -323.0),
    ["Jungle"]         = Vector3.new(1188.0, 68.5, -408.0),
    ["Snow"]           = Vector3.new(1492.0, 69.0, -315.0),
    ["Volcano"]        = Vector3.new(1882.0, 68.0, -398.0),
    ["Abyss Ocean"]    = Vector3.new(2280.0, 68.0, -326.0),
    ["Prehistoric"]    = Vector3.new(2812.0, 69.0, -398.0),
    ["Cosmic"]         = Vector3.new(3390.0, 68.0, -324.0),
    ["Cherry Blossom"] = Vector3.new(4028.0, 68.5, -396.0),
    ["Titan Temple"]   = Vector3.new(4796.0, 69.5, -328.0),
    ["Light Dark"]     = Vector3.new(5660.0, 70.0, -331.0),
}

-- ============================================================
-- EGG HELPERS
-- ============================================================
local _assetCache = {}
local function getAssetData(record)
    if not record then return {} end
    local item = type(record.ItemData) == "table" and record.ItemData or record
    local cat = item.AssetCategory or item.Category or record.AssetCategory or record.Category
    -- FIX: AssetsData dulu tidak pernah di-assign -> Rarity selalu "Unknown".
    -- Lazy-require di sini (sekali) biar getRarityName bisa baca Rarity._id.
    if not AssetsData then
        pcall(function() AssetsData = require(ReplicatedStorage.Data.Assets) end)
    end
    if AssetsData and cat then
        local cached = _assetCache[cat]
        if cached then return cached end
        local ok, d = pcall(function()
            return (AssetsData.Directory or AssetsData)[cat] or {}
        end)
        if ok and d and next(d) then
            _assetCache[cat] = d
            return d
        end
    end
    return {
        EarningRate = record.EarningRate,
        ModelWeight = record.ModelWeight,
        DropWeight  = record.DropWeight,
        DisplayName = cat or record.DisplayName,
        Rarity      = record.Rarity,
        _id         = cat,
    }
end

local function getEarningRate(record)
    if record and record.EarningRate then return tonumber(record.EarningRate) or 0 end
    return tonumber(getAssetData(record).EarningRate) or 0
end

local function getModelWeight(record)
    if record and record.ModelWeight then return tonumber(record.ModelWeight) or 0 end
    return tonumber(getAssetData(record).ModelWeight) or 0
end

local _rarityKeyMap = nil
local function buildRarityKeyMap()
    _rarityKeyMap = {}
    for canon, _ in pairs(RARITY_SCORE_MAP) do
        _rarityKeyMap[canon:lower():gsub("[^%a%d]", "")] = canon
    end
    _rarityKeyMap.lightdark = "Light & Dark"
    _rarityKeyMap.mythical  = "Mythical"
    _rarityKeyMap.brainrotgod = "BrainrotGod"
    _rarityKeyMap.brainrot  = "Brainrot"
    _rarityKeyMap.squishygod = "Squishy God"
    _rarityKeyMap.superrare = "SuperRare"
end

local function normalizeRarityName(name)
    if not name then return nil end
    local s = tostring(name)
    if RARITY_SCORE_MAP[s] then return s end
    if not _rarityKeyMap then buildRarityKeyMap() end
    local key = s:lower():gsub("[^%a%d]", "")
    return _rarityKeyMap[key] or s
end

-- getRarityName: read record.Rarity._id directly (most reliable)
local function getRarityName(record)
    local item = (record and type(record.ItemData) == "table") and record.ItemData or record
    if item then
        local r = item.Rarity or item.RarityTier or item.Tier
        if r then
            if type(r) == "table" and r._id then return normalizeRarityName(r._id) end
            if type(r) == "string" then return normalizeRarityName(r) end
        end
    end
    local d = getAssetData(record)
    return normalizeRarityName((d.Rarity and d.Rarity._id) or d.Rarity) or "Unknown"
end

-- assigned ke forward-declare di atas (deket blok ESP) biar loop ESP kebaca
GetEggRarityInfo = function(egg)
    if not egg then return "Common", 100 end
    local name = getRarityName(egg)
    -- FIX: kalau rarity tak dikenal, coba baca langsung dari AssetDirectory
    if (not name or name == "Unknown") then
        pcall(function()
            if not AssetsData then AssetsData = require(ReplicatedStorage.Data.Assets) end
            local cat = egg.AssetCategory or (egg.ItemData and egg.ItemData.AssetCategory)
            local d = cat and ((AssetsData.Directory or AssetsData)[cat])
            local r = d and (d.Rarity or d.RarityTier or d.Tier)
            if type(r) == "table" then r = r._id or r.DisplayName or r.Name end
            if r then name = normalizeRarityName(tostring(r)) or name end
        end)
    end
    if not name or name == "" then name = "Unknown" end
    local score = RARITY_SCORE_MAP[name] or 100
    return name, score
end

local function isRarityAllowed(name, filter)
    local f = filter or targetRarities
    if not f or not next(f) then return true end
    -- FIX: dulu "Unknown" selalu lolos walau filter diset -> farm ambil egg sembarangan.
    -- Sekarang: Unknown ditolak kalau filter aktif (biar egg terbaik yang diambil).
    if not name or name == "" then return true end
    if name == "Unknown" then return false end
    -- Direct match
    if f[name] == true then return true end
    -- Case-insensitive match
    local nameLower = string.lower(tostring(name))
    for k, v in pairs(f) do
        if v == true and type(k) == "string" and string.lower(k) == nameLower then
            return true
        end
    end
    return false
end

local function isAreaAllowed(areaId, filter)
    -- FIX: dulu cuma terima 1 argumen, padahal dipanggil dengan (areaId, targetAreas).
    -- Filter argumen ke-2 diabaikan -> sekarang dipakai.
    local f = filter or targetAreas
    if not f or not next(f) then return true end
    if not areaId then return true end
    local aLower = tostring(areaId):lower()
    local aKey = aLower:gsub("[^%a%d]", "")
    for k in pairs(f) do
        local kLower = string.lower(k)
        if kLower == aLower then return true end
        if kLower:gsub("[^%a%d]", "") == aKey then return true end
    end
    return false
end

local _carriedUid = nil

local function isCarryingEgg()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local dg = pg and pg:FindFirstChild("DropHeldEgg")
    if dg and dg.Enabled then return true end
    local ch = LP.Character
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and (
                t:GetAttribute("ItemType") == "AssetEgg" or
                t:GetAttribute("ItemType") == "PetEgg" or
                t:GetAttribute("Uid") ~= nil or
                t.Name:lower():find("egg")
            ) then return true end
        end
    end
    return false
end

-- Delivery confirmation. The stolen egg tool can briefly sit in the Backpack
-- before equipping, so isCarryingEgg() alone may report false while the egg is
-- still in hand. We only look for the UID we are actually stealing, so stored
-- eggs for auto-place are never mistaken for a carried egg.
-- FIX (port dari Oxide): cek "masih pegang egg" pakai cara yang SAMA seperti
-- game, bukan cocok-cocokan UID. Attribute Uid pada Tool TIDAK selalu ada,
-- jadi gate berbasis UID bikin recovery di-skip terus (egg dianggap masih
-- dipegang padahal sudah jatuh).
local function isPlayerCarryingEgg()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local dropGui = pg and pg:FindFirstChild("DropHeldEgg")
    if dropGui and dropGui.Enabled == true then return true end

    local char = LP.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Model") and (t.Name:lower():find("egg")
                or t:GetAttribute("Uid") or t:GetAttribute("AssetCategory")) then
                return true
            end
            if t:IsA("Tool") then
                if EggToolDisplay and EggToolDisplay.IsEggTool and EggToolDisplay.IsEggTool(t) then
                    return true
                end
                if t:GetAttribute("IsEgg") == true
                    or t:GetAttribute("Uid") ~= nil
                    or t:GetAttribute("AssetCategory") ~= nil then
                    return true
                end
                local tn = t.Name:lower()
                if tn:find("egg") then return true end
            end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and EggToolDisplay and EggToolDisplay.IsEggTool
                and EggToolDisplay.IsEggTool(t) then
                return true
            end
        end
    end
    return false
end

-- Kompat: nama lama dipakai di banyak tempat. uid diabaikan (kayak Oxide).
local function hasEggToolAnywhere(uid)
    return isPlayerCarryingEgg()
end

local function GetMatchingFieldEggs()
    if not EggState or not EggState.ReadFieldEggs then return {} end
    local ok, snap = pcall(EggState.ReadFieldEggs)
    if not ok or not snap or not snap.Records then return {} end
    local matched = {}
    for _, rec in ipairs(snap.Records) do
        if rec.State == "Slot" and rec.BoundsCFrame and rec.Uid then
            local ignored = ignoredEggs[rec.Uid] and (os.clock() - ignoredEggs[rec.Uid] < 3)
            if not ignored then
                local rName, rarScore = GetEggRarityInfo(rec)
                local rarOk = isRarityAllowed(rName, next(targetRarities) and targetRarities or nil)
                local areaOk = isAreaAllowed(rec.AreaId, next(targetAreas) and targetAreas or nil)
                local mutOk = isMutationAllowed(rec.Mutations, rec, targetMutations)
                if rarOk and areaOk and mutOk then
                    table.insert(matched, { record = rec, score = rarScore, rarity = rName })
                end
            end
        end
    end
    -- FIX: urutkan by rarity score, tie-break by nilai (EarningRate) lalu mutasi.
    -- Dulu cuma score -> egg bagus bisa kalah dari yang Unknown (score 100 sama).
    table.sort(matched, function(a, b)
        if a.score ~= b.score then return a.score > b.score end
        local va = tonumber(a.record and (a.record.EarningRate or a.record.Value)) or 0
        local vb = tonumber(b.record and (b.record.EarningRate or b.record.Value)) or 0
        if va ~= vb then return va > vb end
        local ma = #((a.record and a.record.Mutations) or {})
        local mb = #((b.record and b.record.Mutations) or {})
        if ma ~= mb then return ma > mb end
        return tostring(a.record and a.record.Uid or "") < tostring(b.record and b.record.Uid or "")
    end)
    -- log 3 teratas biar kelihatan pilihannya bener
    if #matched > 0 then
        local top = {}
        for i = 1, math.min(3, #matched) do
            table.insert(top, string.format("%s(%d)", tostring(matched[i].rarity), matched[i].score))
        end
        print("[FARM] top pick: " .. table.concat(top, " > ") .. "  | total=" .. #matched)
    end
    return matched
end

-- ============================================================


-- SetNoKnockback

-- EXTRA FUNCTIONS FROM UPDATE 2
-- ============================================================
local EggToolDisplay = nil
pcall(function() EggToolDisplay = require(RS.Shared.Eggs.EggToolDisplay) end)

local function SetNoKnockback(enabled)
    if enabled then
        pcall(function()
            local rigSync = GetNetRemote("RE/RigSync/Refresh")
            if rigSync and getconnections then
                for _, conn in ipairs(getconnections(rigSync.OnClientEvent)) do
                    pcall(function() conn:Disconnect() end)
                end
            end
        end)
    end
end
pcall(function() SetNoKnockback(true) end)

local function GetLocalPlotCenter()
    local plotObj = PlotState and PlotState.ResolvePlot and PlotState.ResolvePlot()
    local pt = plotObj and plotObj.CenterPoint and (
        typeof(plotObj.CenterPoint) == "Vector3" and plotObj.CenterPoint or
        (plotObj.CenterPoint:IsA("BasePart") and plotObj.CenterPoint.Position)
    )
    if pt then
        return Vector3.new(pt.X, math.max(pt.Y, 70.4), pt.Z), CFrame.new(pt.X, math.max(pt.Y, 70.4), pt.Z)
    end
    return Vector3.new(464.7, 70.4, -364.0), CFrame.new(464.7, 70.4, -364.0)
end

function isMutationAllowed(muts, record, filter)   -- assign ke forward declaration
    local isParasite = (record and record.HasParasite == true)
        or (type(muts) == "table" and (table.find(muts, "Parasite") or table.find(muts, "Monstrous")))
        or (record and (record.BaseMutation == "Parasite" or record.BaseMutation == "Monstrous"))
    if not filter or type(filter) ~= "table" then return true end
    local count = 0; for _ in pairs(filter) do count = count + 1 end
    if count == 0 then return true end
    local hasMut = type(muts) == "table" and #muts > 0
    local allowed = false
    for _, opt in pairs(filter) do
        if type(opt) == "string" then
            if opt == "Normal Only" and not hasMut and not isParasite then allowed = true
            elseif opt == "Mutated Only" and (hasMut or isParasite) then allowed = true
            elseif (opt == "Parasite / Infested" or opt == "Monstrous") and isParasite then allowed = true
            elseif opt == "Silver Only" and type(muts) == "table" and table.find(muts, "Silver") then allowed = true
            elseif opt == "Gold Only" and type(muts) == "table" and (table.find(muts, "Gold") or table.find(muts, "Golden")) then allowed = true
            elseif opt == "Rainbow Only" and type(muts) == "table" and table.find(muts, "Rainbow") then allowed = true
            end
        end
    end
    return allowed
end

function isBigEgg(record)
    if not record then return false end
    local scale = tonumber(record.AssetScale) or 1
    local nestScale = tonumber(record.NestScale) or 1
    return scale >= 1.35 or nestScale >= 1.0
end

local function DeleteOwnPetRenders()
    local count = 0
    local function sweep(container)
        if not container then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                pcall(function() child:Destroy(); count = count + 1 end)
            end
        end
    end
    sweep(Workspace:FindFirstChild("Pets"))
    sweep(Workspace:FindFirstChild("RenderedPets"))
    return count
end

-- ============================================================
-- AUTO PLACE EGGS
-- ============================================================
local function getPenInfo()
    local pd
    pcall(function() pd = PlotState and PlotState.ResolvePlot and PlotState.ResolvePlot() end)
    if not pd then return nil end
    local pa = pd.PetArea
    if not (pa and pa:IsA("BasePart")) then return nil end
    local cp = pa.CFrame
    local c = pd.CenterPoint
    if typeof(c) == "CFrame" then cp = c
    elseif typeof(c) == "Instance" and c:IsA("BasePart") then cp = c.CFrame end
    return pa, cp
end

local function getMyEggRecords()
    if not EggState then return nil end
    local reader = EggState.ReadOwnedEggs or EggState.ReadOwnerEggs
    if not reader then return nil end
    local ok, snap = pcall(reader, LP.UserId)
    if not ok or type(snap) ~= "table" then return nil end
    return snap.Records or snap
end

local function placeRarityOk(rec)
    if not next(S.placeRarities) then return true end
    local rName = GetEggRarityInfo(rec)
    return isRarityAllowed(rName, S.placeRarities)
end

local function PlantAllCarriedEggsInPen()
    -- ============================================================
    -- VERSI RSPY / COBALT (remote-based) — paling akurat
    -- ============================================================
    -- Cobalt capture (Rspy sell&place.txt) membuktikan remote ASLI:
    --   RF/EggWorld/AskWearTool :InvokeServer(uid)              -> string
    --   RF/EggWorld/AskPlaceEgg :InvokeServer({Uid=, LocalCFrame=})
    --
    -- Ini BEDA dari EggState.PlantEgg (yang dipakai Ref 1) — dan
    -- EggState.PlantEgg tidak selalu jalan karena butuh state internal
    -- yang tidak selalu tersinkron. Remote langsung = jalur resmi client.
    --
    -- Bentuk LocalCFrame (dari Cobalt, persis):
    --   CFrame.new(-11.57, -0.50011444091796875, 14.009, -1,0,0, 0,1,0, 0,0,-1)
    --   -> Y selalu -0.50011444091796875 (ketinggian tanam)
    --   -> rotasi menghadap +Z lokal (matrix -1,0,0, 0,1,0, 0,0,-1)
    -- ============================================================
    if not LP.Character then return 0 end
    if not PlotState then return 0 end

    local myPlot = nil
    pcall(function() myPlot = PlotState.ResolvePlot() end)
    if not myPlot or not myPlot.CenterPoint or not myPlot.PetArea then return 0 end

    local net = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Networking")
    local placeRemote = net and net:FindFirstChild("RF/EggWorld/AskPlaceEgg")
    local wearRemote  = net and net:FindFirstChild("RF/EggWorld/AskWearTool")
    if not placeRemote then
        print("[PLACE] remote AskPlaceEgg tidak ketemu")
        return 0
    end

    local petArea   = myPlot.PetArea
    local centerCF  = myPlot.CenterPoint.CFrame
    local basePetPos = petArea.Position

    -- ============================================================
    -- FIX #3: SLOT EGG — biar TIDAK MENUMPUK di satu titik.
    -- ============================================================
    -- Masalah lama: offset dihitung dari `basePetPos` (tengah PetArea)
    -- dengan grid mulai dari 0 SETIAP run, jadi egg selalu mendarat di
    -- posisi yang sama -> terlihat seperti "cuma 1 telur".
    --
    -- Sekarang:
    --   1. Offset acak DI DALAM footprint PetArea (bukan grid tetap).
    --   2. Cek jarak ke egg yang sudah ada di pen (dari record
    --      Placement.LocalCFrame) -> kalau < MIN_GAP, cari titik lain.
    --   3. Y & ROTASI tetap persis seperti capture Cobalt.
    local PLANT_Y   = -0.50011444091796875
    local PLANT_R00, PLANT_R01, PLANT_R02 = -1, 0, 0
    local PLANT_R10, PLANT_R11, PLANT_R12 =  0, 1, 0
    local PLANT_R20, PLANT_R21, PLANT_R22 =  0, 0, -1

    -- (usedSlots + nextLocalCFrame DIPINDAH ke bawah, setelah `owned` diisi —
    --  dulu dipakai di sini padahal `owned` belum di-assign => selalu kosong
    --  => egg bisa menumpuk. Lihat blok FIX A di bawah.)

    -- ============================================================
    -- FIX #1: KARAKTER HARUS DI PLOT DULU
    -- ============================================================
    -- Server menolak AskPlaceEgg kalau karakter jauh dari plot
    -- ("Get closer to your area to place an egg!"). Dulu tidak ada
    -- langkah ini -> place gagal / hanya 1 yang masuk.
    local plotPos = myPlot.CenterPoint.Position
    local hrpNow  = findHRP()
    if hrpNow and (hrpNow.Position - plotPos).Magnitude > 12 then
        print("[PLACE] pindah ke plot dulu...")
        navTo(plotPos, farmSpeed or 300, true)
        task.wait(0.35)
        hrpNow = findHRP()
        if hrpNow and (hrpNow.Position - plotPos).Magnitude > 25 then
            -- masih jauh -> snap langsung (plot = zona aman, tidak ada AC di sini)
            hrpNow.CFrame = CFrame.new(plotPos + Vector3.new(0, 3, 0))
            hrpNow.AssemblyLinearVelocity  = Vector3.zero
            hrpNow.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.4)
        end
    end

    -- Sinkronkan daftar egg dulu (kalau tersedia).
    -- CEPAT: dulu selalu task.wait(0.35). Sekarang hanya tunggu kalau
    -- data lokal masih kosong.
    local hadData = false
    pcall(function()
        if EggState then
            local rd = EggState.ReadOwnerEggs or EggState.ReadOwnedEggs
            if rd then
                local ok, snap = pcall(rd, LP.UserId)
                if ok and type(snap) == "table" and next(snap.Records or snap) then hadData = true end
            end
        end
    end)
    pcall(function() if EggState and EggState.SyncOwnedEggs then EggState.SyncOwnedEggs() end end)
    task.wait(hadData and 0.08 or 0.3)

    -- Ambil daftar egg yang dimiliki
    local owned = nil
    pcall(function()
        if EggState then
            local reader = EggState.ReadOwnerEggs or EggState.ReadOwnedEggs
            if reader then owned = reader(LP.UserId) end
        end
    end)
    if type(owned) == "table" and owned.Records then owned = owned.Records end

    if type(owned) ~= "table" then
        -- Fallback: scan Tool egg di Character/Backpack
        owned = {}
        local function addEggTools(container)
            if not container then return end
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") then
                    local itype = t:GetAttribute("ItemType")
                    if itype == "AssetEgg" or itype == "PetEgg" then
                        local uid = t:GetAttribute("Uid") or t:GetAttribute("UID")
                        if not uid and EggToolDisplay and EggToolDisplay.GetToolUid then
                            pcall(function() uid = EggToolDisplay.GetToolUid(t) end)
                        end
                        if uid then owned[uid] = { Uid = uid } end
                    end
                end
            end
        end
        pcall(function() addEggTools(LP.Character) end)
        pcall(function() addEggTools(LP:FindFirstChild("Backpack")) end)
    end

    -- ============================================================
    -- FIX A + PERLUAS AREA PLACE + PERCEPAT
    -- ============================================================
    -- BUG yang diperbaiki: blok ini dulu ada DI ATAS (sebelum `owned` diisi),
    -- jadi `type(owned) == "table"` selalu false -> usedSlots KOSONG ->
    -- posisi egg tidak dicek -> bisa menumpuk.
    --
    -- PERLUAS: margin tepi 3 -> 1.2 stud, MIN_GAP 3.2 -> 2.3 stud, dan
    -- ada mode "extend" yang mencoba cincin kedua di luar PetArea kalau
    -- bagian dalam sudah penuh.
    local usedSlots = {}
    if type(owned) == "table" then
        for _, r2 in pairs(owned) do
            if type(r2) == "table" and r2.Placement ~= nil then
                local lc = type(r2.Placement) == "table" and r2.Placement.LocalCFrame or nil
                if typeof(lc) == "CFrame" then
                    usedSlots[#usedSlots + 1] = { x = lc.X, z = lc.Z }
                end
            end
        end
    end

    local MIN_GAP   = 2.3            -- lebih rapat -> lebih banyak muat
    local EDGE      = 1.2            -- margin tepi lebih kecil -> area lebih luas
    local halfX     = math.max(1, petArea.Size.X * 0.5 - EDGE)
    local halfZ     = math.max(1, petArea.Size.Z * 0.5 - EDGE)
    -- cincin cadangan (kalau dalam pen sudah padat)
    local extX      = halfX + math.min(6, petArea.Size.X * 0.25)
    local extZ      = halfZ + math.min(6, petArea.Size.Z * 0.25)

    local function slotFree(ox, oz, gap)
        for _, u in ipairs(usedSlots) do
            local dx, dz = ox - u.x, oz - u.z
            if (dx * dx + dz * dz) < (gap * gap) then return false end
        end
        return true
    end

    local function makeCF(ox, oz)
        usedSlots[#usedSlots + 1] = { x = ox, z = oz }
        return CFrame.new(
            ox, PLANT_Y, oz,
            PLANT_R00, PLANT_R01, PLANT_R02,
            PLANT_R10, PLANT_R11, PLANT_R12,
            PLANT_R20, PLANT_R21, PLANT_R22
        )
    end

    local function nextLocalCFrame()
        -- 1. coba di dalam PetArea dulu (paling aman)
        for _ = 1, 25 do
            local ox = (math.random() * 2 - 1) * halfX
            local oz = (math.random() * 2 - 1) * halfZ
            if slotFree(ox, oz, MIN_GAP) then return makeCF(ox, oz) end
        end
        -- 2. area diperluas (masih dalam plot, sedikit di luar PetArea)
        for _ = 1, 25 do
            local ox = (math.random() * 2 - 1) * extX
            local oz = (math.random() * 2 - 1) * extZ
            if slotFree(ox, oz, MIN_GAP) then return makeCF(ox, oz) end
        end
        -- 3. benar-benar penuh -> jarak dirapatkan
        for _ = 1, 15 do
            local ox = (math.random() * 2 - 1) * extX
            local oz = (math.random() * 2 - 1) * extZ
            if slotFree(ox, oz, MIN_GAP * 0.7) then return makeCF(ox, oz) end
        end
        -- 4. menyerah -> titik acak terakhir
        return makeCF((math.random() * 2 - 1) * extX, (math.random() * 2 - 1) * extZ)
    end

    -- ============================================================
    -- FIX #2: LOOP — dulu pakai `break` saat uid bukan string, jadi
    -- loop BERHENTI TOTAL dan hanya 0-1 egg yang ke-place.
    -- Sekarang: pakai `continue` (lewati item itu saja), dan hitung
    -- setiap alasan skip biar kelihatan di console.
    -- ============================================================
    local placed, failed = 0, 0
    local skippedPlaced, skippedRarity, skippedBad = 0, 0, 0
    local total = 0
    for _ in pairs(owned) do total = total + 1 end
    local MAX_PER_RUN = 30

    for uid, rec in pairs(owned) do
        if placed >= MAX_PER_RUN then break end
        if not farmEnabled and not S.autoPlantEnabled then break end

        -- uid bisa jadi key (string) atau field rec.Uid
        if type(uid) ~= "string" then
            if type(rec) == "table" and type(rec.Uid) == "string" then
                uid = rec.Uid
            else
                skippedBad = skippedBad + 1
                continue          -- <- dulu `break` di sini = bug
            end
        end

        -- lewati yang sudah ada di pen
        if type(rec) == "table" and rec.Placement ~= nil then
            skippedPlaced = skippedPlaced + 1
            continue
        end

        -- filter RARITY (bukan area!) — kalau dropdown diisi
        if next(S.placeRarities) and type(rec) == "table" then
            if not placeRarityOk(rec) then
                skippedRarity = skippedRarity + 1
                continue
            end
        end

        -- 1. WEAR egg tool (server butuh ini sebelum place).
        --    CEPAT: 0.22 -> 0.08, dan tidak nunggu kalau remote tidak ada.
        if wearRemote then
            pcall(function() wearRemote:InvokeServer(uid) end)
            task.wait(0.08)
        end

        -- 2. PLACE dengan CFrame lokal ke CenterPoint.
        --    CEPAT: 0.12 -> 0.05. Kalau gagal, langsung coba titik lain
        --    (tanpa nunggu) supaya total waktu tetap kecil.
        local localCFrame = nextLocalCFrame()
        local ok3, res = pcall(function()
            return placeRemote:InvokeServer({ Uid = uid, LocalCFrame = localCFrame })
        end)
        if ok3 and res == true then
            placed = placed + 1
            task.wait(0.05)
        else
            -- sekali retry cepat di titik berbeda
            task.wait(0.03)
            local retryCF = nextLocalCFrame()
            local ok4, res2 = pcall(function()
                return placeRemote:InvokeServer({ Uid = uid, LocalCFrame = retryCF })
            end)
            if ok4 and res2 == true then
                placed = placed + 1
            else
                failed = failed + 1
            end
            task.wait(0.05)
        end
    end

    print(string.format(
        "[PLACE] berhasil=%d gagal=%d | total=%d skip(sudah-ditaruh=%d rarity=%d invalid=%d)",
        placed, failed, total, skippedPlaced, skippedRarity, skippedBad))
    return placed
end




-- ============================================================
local HOVER_WALKSPEED = 300
local HOVER_HIP_HEIGHT = 5
local HOVER_ARRIVE = 2.5
local HOVER_BRAKE_DIST = 90
local HOVER_BRAKE_MIN = 55


-- ============================================================
-- BYPASS DELIVERY (follows Bypass steal.txt standard)
-- ============================================================
-- TWEEN GLIDE NAVIGATION
-- ============================================================
local function MoveToPoint(target, speed, easeOut)
    local hrp = findHRP()
    if not hrp or not target then return false end

    local start = hrp.Position
    local dist = (target - start).Magnitude
    if dist < 1.0 then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end

    -- FIX (port Oxide): clamp 750 (bukan 1000). Di atas ~750 karakter
    -- kehilangan kontrol & sering overshoot/nyangkut.
    speed = math.clamp(tonumber(speed) or farmSpeed or 750, 50, 750)

    local t0 = os.clock()
    local totalDist = dist
    while not HUB.dead do
        local dt = RunService.Heartbeat:Wait()
        dt = math.clamp(dt, 0.001, 1 / 30)
        -- abort: kena hit saat travel -> hentikan gerak, ambil egg dulu
        if HUB.travelAbort then break end
        hrp = findHRP()
        if not hrp then break end
        local curPos = hrp.Position
        -- Void rescue: if below map, snap back to main road at same X
        if curPos.Y < 60 then
            hrp.CFrame = CFrame.new(curPos.X, 70.4, MAIN_ROAD_Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            curPos = hrp.Position
        end
        local toTarget = target - curPos
        local remain = toTarget.Magnitude
        if remain < 1.0 then break end
        local stepSpeed = speed
        if easeOut then
            local progress = 1 - math.clamp(remain / totalDist, 0, 1)
            stepSpeed = math.max(speed * (1 - progress * 0.8), 35)
        end
        local step = math.min(stepSpeed * dt, remain)
        local dir = toTarget.Unit
        local nextPos = curPos + dir * step
        hrp.CFrame = CFrame.lookAt(nextPos, nextPos + dir)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if os.clock() - t0 > (totalDist / 50 + 5) then break end
    end

    hrp = findHRP()
    if hrp then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    return true
end


-- ============================================================
-- FLY: tinggi + ANIMASI LARI TETAP JALAN
-- ============================================================
-- Kunci animasi lari tetap jalan saat melayang:
--   hum:Move(dir, false)  -> Humanoid berpikir dia SEDANG BERLARI
--                            (ini yang memicu animasi run)
--   char:PivotTo(CFrame)  -> posisi digeser tanpa merusak animasi
--   Humanoid state tetap Running (BUKAN Physics/PlatformStand)
--
-- Dulu cuma set AssemblyLinearVelocity + CFrame -> Humanoid tidak tahu
-- dia "berlari" -> animasi mati / karakter kaku.
--
-- Kalau boleh terbang lebih tinggi, `lift` menambah ketinggian lurus
-- (garis lurus dinaikkan ke atas) supaya kelihatan benar-benar fly.
local FLY_LIFT = 14   -- berapa stud di atas garis lurus (bisa diubah)

local function FlyToPoint(target, speed, easeOut, lift)
    local hrp = findHRP()
    local char = LP.Character
    if not hrp or not target then return false end

    lift = tonumber(lift) or FLY_LIFT

    local start = hrp.Position
    local delta = target - start
    local dist  = delta.Magnitude
    if dist < 1.0 then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end

    speed = math.clamp(tonumber(speed) or farmSpeed or 750, 50, 750)
    local moveTime = math.max(dist / speed, 0.02)
    if easeOut then moveTime = moveTime * 1.25 end

    -- Lift diskalakan dengan jarak: jarak pendek -> lompatan kecil (tidak aneh),
    -- jarak jauh -> terbang tinggi. Minimal 6 stud biar tetap kelihatan fly.
    local flatDist = Vector3.new(delta.X, 0, delta.Z).Magnitude
    local useLift  = math.clamp(math.min(lift, flatDist * 0.22), 6, lift)

    local t0  = os.clock()
    local flatDir = Vector3.new(delta.X, 0, delta.Z)
    if flatDir.Magnitude > 0.001 then flatDir = flatDir.Unit
    else flatDir = Vector3.new(0, 0, -1) end

    local hum = findHum()

    while os.clock() - t0 < moveTime and not HUB.dead do
        RunService.Heartbeat:Wait()
        -- abort: kena hit saat travel -> hentikan gerak, ambil egg dulu
        if HUB.travelAbort then break end
        hrp  = findHRP()
        char = LP.Character
        hum  = findHum()
        if not hrp then break end

        local alpha = math.clamp((os.clock() - t0) / moveTime, 0, 1)
        local a = alpha
        if easeOut then a = math.sin(alpha * (math.pi / 2)) end

        -- titik di garis lurus start->target
        local cur = start:Lerp(target, a)

        -- LIFT: busur ketinggian (naik lalu turun) supaya benar-benar terbang.
        -- sin(alpha*pi) = 0 di awal/akhir, 1 di tengah -> mulus.
        local arc = math.sin(alpha * math.pi) * useLift
        local flyPos = Vector3.new(cur.X, cur.Y + arc, cur.Z)

        if flyPos.Y < 60 then flyPos = Vector3.new(flyPos.X, 70.4, flyPos.Z) end

        pcall(function()
            -- Humanoid harus tetap "Running" supaya animasi lari hidup
            if hum then
                if hum:GetState() == Enum.HumanoidStateType.Physics
                   or hum:GetState() == Enum.HumanoidStateType.PlatformStanding
                   or hum:GetState() == Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
                hum.PlatformStand = false
                -- INI KUNCINYA: suruh Humanoid "berlari" -> animasi run jalan
                hum:Move(flatDir, false)
            end

            -- geser posisi tanpa merusak animasi (bukan set CFrame langsung)
            if char then
                char:PivotTo(CFrame.lookAt(flyPos, flyPos + flatDir))
            else
                hrp.CFrame = CFrame.lookAt(flyPos, flyPos + flatDir)
            end

            -- kecepatan horizontal saja; Y dibiarkan supaya tidak "nabrak"
            local curSpeed = speed
            if easeOut then curSpeed = math.max(speed * (1 - alpha * 0.8), 35) end
            hrp.AssemblyLinearVelocity = Vector3.new(
                flatDir.X * curSpeed,
                hrp.AssemblyLinearVelocity.Y,
                flatDir.Z * curSpeed
            )
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    -- berhenti di target, tetap berdiri + animasi normal
    hrp = findHRP()
    hum = findHum()
    if hrp then
        pcall(function()
            hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    if hum then
        pcall(function()
            hum:Move(Vector3.zero, false)   -- stop animasi lari
            hum.PlatformStand = false
        end)
    end
    if forceStandUp then pcall(forceStandUp) end
    return true
end

local function TravelFlyDirect(targetPos, speed, isApproach)
    local hrp = findHRP()
    if not hrp or not targetPos then return false end
    if S.avoidTrapsEnabled then pcall(NeutralizeTraps) end

    local startPos = hrp.Position
    local isReturningToBase = (targetPos.X < SAFE_BOUNDARY_X)
    -- Altitude untuk jalur KE EGG (keluar) — tetap naik supaya bebas rintangan.
    local flyAltitude = math.max(startPos.Y, targetPos.Y, 70.4) + 28

    if isReturningToBase then
        -- ============================================================
        -- FIX: JALUR PULANG LANGSUNG (bukan naik ke atas lalu turun).
        -- ============================================================
        -- Dulu: naik ke +28 -> geser di langit -> turun ke tanah -> jalan.
        -- Itu bikin karakter "naik atas lalu turun" dan memakan waktu.
        -- Sekarang: terbang LANGSUNG ke titik aman dengan ketinggian
        -- sedang (cukup buat lewatin rintangan, tapi tidak melambung),
        -- lalu masuk safe zone pelan (SAFE_ZONE_SPEED).
        local cruiseY = math.max(startPos.Y, 70.4) + 6
        local horizDist = Vector3.new(targetPos.X - startPos.X, 0, targetPos.Z - startPos.Z).Magnitude

        if horizDist < 40 then
            -- sudah dekat -> langsung, tanpa leg perantara
            FlyToPoint(Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z),
                       SAFE_ZONE_SPEED, isApproach == true)
            return true
        end

        -- satu leg lurus ke titik aman (tanpa melambung ke +28)
        local pDirect = Vector3.new(SAFE_BOUNDARY_X, cruiseY, MAIN_ROAD_Z)
        FlyToPoint(pDirect, speed, false)

        -- masuk ke posisi tujuan, pelan
        local pGoal = Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z)
        MoveToPoint(pGoal, SAFE_ZONE_SPEED, isApproach == true)
        return true
    else
        local totalDist = (targetPos - startPos).Magnitude
        if totalDist < 25 then
            FlyToPoint(Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z), speed, isApproach == true)
            return true
        end

        local pSky1 = Vector3.new(startPos.X, flyAltitude, startPos.Z)
        local pSky2 = Vector3.new(targetPos.X, flyAltitude, targetPos.Z)
        local pGround = Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z)

        FlyToPoint(pSky1, speed, false)
        FlyToPoint(pSky2, speed, false)
        FlyToPoint(pGround, speed, isApproach == true)
        return true
    end
end


-- ============================================================
-- FLY GLIDE: PATH SAMA DENGAN TWEEN GLIDE
-- ============================================================
-- Tween Glide TIDAK DIUBAH SAMA SEKALI (kodenya persis seperti aslinya).
-- Fly Glide sekarang lewat PATH yang sama, cuma mekaniknya FlyToPoint:
--   keluar : (di safe zone) -> road entry -> target egg
--   pulang : -> SAFE_WAYPOINT_POS
-- Dulu Fly Glide bikin jalur sendiri (naik +28 lalu geser di langit).

local function travelToEgg(targetPos, spd)
    spd = spd or farmSpeed
    if moveMethod == "Fly Glide" then
        -- PATH SAMA seperti Tween Glide, cuma mekaniknya FlyToPoint
        local hrpF = findHRP()
        if not hrpF then return end
        local startPosF = hrpF.Position
        if startPosF.X < SAFE_BOUNDARY_X then
            local roadEntryF = Vector3.new(SAFE_BOUNDARY_X + 20, 70.4, MAIN_ROAD_Z)
            FlyToPoint(roadEntryF, spd, false)
        end
        FlyToPoint(targetPos, spd, true)
    else
        -- Tween Glide default
        local hrp = findHRP()
        if not hrp then return end
        local startPos = hrp.Position
        if startPos.X < SAFE_BOUNDARY_X then
            local roadEntry = Vector3.new(SAFE_BOUNDARY_X + 20, 70.4, MAIN_ROAD_Z)
            MoveToPoint(roadEntry, spd, false)
        end
        MoveToPoint(targetPos, spd, true)
    end
end

local function travelToBase(spd)
    spd = spd or farmSpeed
    -- Balik ke safe zone pakai navigasi humanoid (fly/glide). Tidak ada bypass.
    if moveMethod == "Fly Glide" then
        -- PATH SAMA seperti Tween Glide, cuma mekaniknya FlyToPoint
        FlyToPoint(SAFE_WAYPOINT_POS, spd, false)
    else
        MoveToPoint(SAFE_WAYPOINT_POS, spd, false)
    end
    for _ = 1, 3 do
        local hrpEnd = findHRP()
        if not hrpEnd then break end
        if (hrpEnd.Position - SAFE_WAYPOINT_POS).Magnitude <= 8 then break end
        if moveMethod == "Fly Glide" then
            FlyToPoint(SAFE_WAYPOINT_POS, spd, false)
        else
            MoveToPoint(SAFE_WAYPOINT_POS, spd, false)
        end
    end
end

-- Walk to the safe zone without teleporting. Waits out ragdolls and retries, so
-- the farm never snaps and never starts a cycle from a bad position.
local function ensureInSafeZone(spd)
    spd = spd or farmSpeed
    for _ = 1, 8 do
        local hrp = findHRP()
        if hrp then
            if (hrp.Position - SAFE_WAYPOINT_POS).Magnitude <= 12 then return true end
            travelToBase(spd)
            hrp = findHRP()
            if hrp and (hrp.Position - SAFE_WAYPOINT_POS).Magnitude <= 12 then return true end
        end
        task.wait(0.25)
    end
    return false
end

-- ============================================================
-- DROP RECOVERY  (inti: egg jatuh -> LANGSUNG ambil di tempat)
-- ============================================================
-- Alur lama (salah): egg jatuh -> teleport balik ke posisi egg SEMULA
--                     -> bukan ke egg yang jatuh -> gagal / ke guard.
-- Alur baru        : egg jatuh -> cari posisi egg JATUH di field
--                     -> tween-glide/fly ke sana -> carry ulang -> lanjut.
-- TIDAK balik safe zone dulu. TIDAK teleport (biar AC gak kena).

local _dropUid, _dropMon, _dropLastPos = nil, nil, nil

local function stopDropMonitor()
    if _dropMon then pcall(function() _dropMon:Disconnect() end); _dropMon = nil end
    _dropUid, _dropLastPos = nil, nil
end

-- Pantau egg yang lagi dibawa. Begitu lepas dari tangan -> tandai jatuh.
local function startDropMonitor(uid)
    stopDropMonitor()
    _dropUid = uid
    local h0 = findHRP()
    _dropLastPos = h0 and h0.Position or nil
    HUB.eggDropped = false
    _dropMon = track(RunService.Heartbeat:Connect(function()
        local h = findHRP()
        if h then _dropLastPos = h.Position end
        -- Catat HANYA saat pertama kali lepas. Jangan timpa dropPos berulang kali
        -- (dulu ditimpa tiap heartbeat -> posisi "egg jatuh" bergeser terus).
        if _dropUid and not hasEggToolAnywhere(_dropUid) and not HUB.eggDropped then
            HUB.eggDropped = true
            HUB.dropUid    = _dropUid
            HUB.dropPos    = _dropLastPos
            HUB.dropAt     = os.clock()
            print("[DROP] egg lepas dari tangan, posisi dicatat")
        end
    end))
end

-- Cari posisi egg yang jatuh. Dua jalur:
--   A) snapshot field (EggState.ReadFieldEggs) cocokkan UID
--   B) model di Workspace (AreaEggSlotsClient) cocokkan UID
local function findDroppedEggPos(uid)
    if not uid then return nil end
    uid = tostring(uid)

    -- A) snapshot
    local ok, snap = false, nil
    if EggState and EggState.ReadFieldEggs then
        ok, snap = pcall(EggState.ReadFieldEggs)
    end
    if ok and snap and snap.Records then
        for _, rec in ipairs(snap.Records) do
            if tostring(rec.Uid) == uid and rec.BoundsCFrame then
                local st = tostring(rec.State or "")
                -- "Slot" = masih di sarang (bukan jatuh). Sisanya = di lapangan.
                if st ~= "Slot" then
                    return rec.BoundsCFrame.Position, rec
                end
            end
        end
    end

    -- B) model di Workspace
    local roots = { Workspace:FindFirstChild("AreaEggSlotsClient"), Workspace }
    for _, root in ipairs(roots) do
        if root then
            local okW, m = pcall(function() return root:FindFirstChild(uid, true) end)
            if okW and m then
                local bp = m:FindFirstChildWhichIsA("BasePart", true)
                if bp then return bp.Position, nil end
            end
        end
    end
    return nil, nil
end

-- Navigasi ke posisi: Fly (jarak jauh) atau Tween Glide (dekat/akhir).
navTo = function(pos, speed, approach)
    if not pos then return false end
    speed = math.clamp(tonumber(speed) or farmSpeed or 750, 50, 1000)
    local hrp = findHRP()
    local dist = hrp and (pos - hrp.Position).Magnitude or 0
    if moveMethod == "Fly Glide" then
        FlyToPoint(Vector3.new(pos.X, math.max(pos.Y, 70.0) + 1.2, pos.Z), speed, approach == true)
    elseif dist > 60 then
        -- jarak jauh: fly dulu biar cepat & bebas rintangan
        FlyToPoint(Vector3.new(pos.X, math.max(pos.Y, 70.0) + 1.2, pos.Z), speed, false)
    else
        MoveToPoint(pos, speed, approach == true)
    end
    return true
end

-- FIX: karakter kadang tetap "tidur" setelah ragdoll -> tidak bisa carry.
-- Setara dengan lock camera: paksa tegak + AutoRotate + orientasi horizontal.
forceStandUp = function()
    -- ============================================================
    -- FIX: dulu cuma set PlatformStand/AutoRotate + ChangeState.
    -- Itu TIDAK cukup untuk SAE, karena sistem ragdoll game
    -- MENONAKTIFKAN Motor6D (RagdollJoints.Bind). Selama Motor6D
    -- masih disabled, karakter tetap tergeletak walau state sudah
    -- bukan Physics -> "anti ragdoll selesai tapi belum berdiri".
    --
    -- Sekarang: re-enable Motor6D + reset atribut ragdoll + tangani
    -- SEMUA state (Physics / Ragdoll / FallingDown), bukan cuma Physics.
    -- ============================================================
    local h   = findHum()
    local hrp = findHRP()
    local ch  = LP.Character
    if not h then return false end

    pcall(function()
        -- 1. re-enable Motor6D (inti sistem ragdoll SAE)
        if ch then
            for _, v in ipairs(ch:GetDescendants()) do
                if v:IsA("Motor6D") and not v.Enabled then
                    v.Enabled = true
                end
            end
            -- 2. reset atribut penanda ragdoll
            for _, att in ipairs({"Ragdoll","Ragdolled","IsRagdoll","Downed","KnockedBack"}) do
                if ch:GetAttribute(att) ~= nil then ch:SetAttribute(att, false) end
            end
        end

        -- 3. lepas semua pengunci gerak
        h.PlatformStand = false
        h.AutoRotate    = true
        h.Sit           = false

        -- 4. tangani SEMUA state ragdoll, bukan cuma Physics
        local hs = h:GetState()
        if hs == Enum.HumanoidStateType.Physics
           or hs == Enum.HumanoidStateType.Ragdoll
           or hs == Enum.HumanoidStateType.FallingDown then
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
    if hrp then
        pcall(function()
            -- orientasi tegak, hadap arah horizontal (ini yang bikin bisa carry)
            local pos  = hrp.Position
            local look = hrp.CFrame.LookVector
            local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude < 0.001 then flat = Vector3.new(0, 0, -1) end
            hrp.CFrame = CFrame.lookAt(pos, pos + flat.Unit)
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    pcall(function()
        if h:GetState() ~= Enum.HumanoidStateType.Running then
            h:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
    return true
end

local function isRagdolled()
    local h = findHum()
    local ch = LP.Character
    if not h or not ch then return false end
    -- Method 1: HumanoidStateType
    local hs = h:GetState()
    if hs == Enum.HumanoidStateType.Physics
        or hs == Enum.HumanoidStateType.Ragdoll
        or hs == Enum.HumanoidStateType.FallingDown then
        return true
    end
    -- Method 2: Character Attributes
    if ch:GetAttribute("Ragdoll") == true
        or ch:GetAttribute("Ragdolled") == true
        or ch:GetAttribute("IsRagdoll") == true
        or ch:GetAttribute("Downed") == true
        or ch:GetAttribute("KnockedBack") == true then
        return true
    end
    -- Method 3: Motor6D disabled = SAE ragdoll (RagdollJoints.Bind)
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("Motor6D") and not v.Enabled then return true end
    end
    -- Method 4: HRP velocity spike
    local hrp = findHRP()
    if hrp then
        local vel = hrp.AssemblyLinearVelocity
        if Vector3.new(vel.X, 0, vel.Z).Magnitude > 25 then
            return true
        end
    end
    return false
end

-- Inti: ambil ulang egg yang jatuh DI TEMPAT (port alur recarry Oxide).
-- Kunci bedanya dengan versi lama:
--   1. TUNGGU SAMPAI BERDIRI (bukan cuma cek state sekali)
--   2. TUNGGU GUARD TIDUR lagi (kalau tidak, carry langsung di-alert ulang)
--   3. carry ulang 3 jalur: carryRemote -> EggState.CarryFieldEgg -> prompt
--   4. cek hasil pakai isPlayerCarryingEgg() (cara game), bukan cocok UID
local function waitGuardAsleep(targetPos, timeout)
    timeout = timeout or 4.5
    local t0 = os.clock()
    while os.clock() - t0 < timeout and farmEnabled do
        local asleep = false
        pcall(function()
            local areasRoot = Workspace:FindFirstChild("__OBJECTS")
                and Workspace.__OBJECTS:FindFirstChild("Areas")
                and Workspace.__OBJECTS.Areas:FindFirstChild("GuardAreas")
            local guardModel = nil
            if areasRoot then
                for _, areaFolder in ipairs(areasRoot:GetChildren()) do
                    local g = areaFolder:FindFirstChild("Guard")
                        or areaFolder:FindFirstChild("ForestGuardAuthored")
                        or areaFolder:FindFirstChildWhichIsA("Model", true)
                    if g and g.PrimaryPart then
                        local d = (g.PrimaryPart.Position - targetPos).Magnitude
                        if d < 90 then guardModel = g; break end
                    end
                end
            end
            if guardModel then
                local alert = guardModel:GetAttribute("Alert") or guardModel:GetAttribute("Alerted")
                    or guardModel:GetAttribute("IsAlerted") or guardModel:GetAttribute("Chasing")
                local sleeping = guardModel:GetAttribute("Sleeping") or guardModel:GetAttribute("IsSleeping")
                    or guardModel:GetAttribute("Asleep") or guardModel:GetAttribute("Sleep")
                local state = guardModel:GetAttribute("State")
                if sleeping == true then asleep = true
                elseif alert == false then asleep = true
                elseif state and tostring(state):lower():find("sleep") then asleep = true
                else
                    local hum = guardModel:FindFirstChildOfClass("Humanoid")
                    local hrp = guardModel.PrimaryPart or guardModel:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - targetPos).Magnitude
                        if d < 12 and (not hum or hum.MoveDirection.Magnitude < 0.15) then
                            asleep = true
                        end
                    end
                end
                if not asleep then
                    local alertGui = guardModel:FindFirstChild("Alert", true)
                    if alertGui and alertGui:IsA("BillboardGui") and alertGui.Enabled == false then
                        asleep = true
                    end
                end
            else
                if os.clock() - t0 > 1.4 then asleep = true end
            end
        end)
        if asleep then return true end
        task.wait(0.14)
    end
    return false
end

-- ============================================================
-- HIT SAAT TRAVEL KE SAFE ZONE
-- ============================================================
-- Masalah: dulu deteksi kena hit HANYA di window 4s setelah carry
-- (lingerActive). Kalau kena hit DI JALAN saat travel ke safe zone,
-- egg jatuh -> farm balik ke safe zone tanpa ambil egg-nya.
--
-- Sekarang: monitor berjalan SEPANJANG travel.
--   - kena hit terdeteksi  -> anti-ragdoll LANGSUNG aktif (lingerActive=false
--     supaya heartbeat forceStandUp jalan) -> ambil egg jatuh DI TEMPAT
--   - egg sudah dipegang lagi -> travel LANJUT ke safe zone
-- ============================================================
local travelHitMonitor = nil   -- { uid=, startHealth=, onHit= }

local function startTravelHitMonitor(uid, onHit)
    -- hentikan monitor lama kalau ada
    if travelHitMonitor and travelHitMonitor.conn then
        pcall(function() travelHitMonitor.conn:Disconnect() end)
    end

    local startHealth = 100
    local hum0 = findHum()
    if hum0 then startHealth = hum0.Health end

    local m = { uid = uid, startHealth = startHealth, onHit = onHit, fired = false }
    m.conn = track(RunService.Heartbeat:Connect(function()
        if m.fired or not farmEnabled then return end
        -- egg masih di tangan -> belum kena hit
        if hasEggToolAnywhere(uid) then
            -- update health acuan terus (kalau kena damage kecil, tetap acuan baru)
            local hh = findHum()
            if hh and hh.Health > m.startHealth then m.startHealth = hh.Health end
            return
        end

        -- === EGG LEPAS -> KENA HIT ===
        m.fired = true
        print("[HIT] egg lepas saat travel -> anti-ragdoll aktif + ambil ulang")

        -- 1. HENTIKAN travel yang sedang jalan (biar tidak lanjut ke safe zone)
        HUB.travelAbort = true

        -- 2. AKTIFKAN anti-ragdoll SEKARANG (heartbeat forceStandUp jalan)
        lingerActive = false

        -- 2. paksa berdiri segera (re-enable Motor6D + state)
        if forceStandUp then pcall(forceStandUp) end

        -- 3. panggil handler (ambil egg di tempat)
        if m.onHit then pcall(m.onHit) end
    end))
    travelHitMonitor = m
    return m
end

local function stopTravelHitMonitor()
    if travelHitMonitor and travelHitMonitor.conn then
        pcall(function() travelHitMonitor.conn:Disconnect() end)
    end
    travelHitMonitor = nil
end

local function recoverDroppedEgg(uid, origPos, speed)
    if not dropRecovery or not uid then return false end
    -- pastikan flag tidak nyangkut dari siklus sebelumnya
    HUB.eggDropped = false
    speed = math.clamp(tonumber(speed) or farmSpeed or 750, 50, 1000)

    for attempt = 1, math.max(1, dropMaxTries) do
        if not farmEnabled then return false end

        -- 1. tunggu berdiri (paksa tegak, setara lock camera)
        local tStand = os.clock()
        while os.clock() - tStand < 2.0 and farmEnabled do
            local h = findHum()
            if h then
                local hs = h:GetState()
                if hs ~= Enum.HumanoidStateType.Physics
                   and hs ~= Enum.HumanoidStateType.Ragdoll
                   and hs ~= Enum.HumanoidStateType.FallingDown then
                    break
                end
            end
            forceStandUp()
            task.wait(0.1)
        end
        forceStandUp()
        task.wait(0.35)

        if isPlayerCarryingEgg() then return true end

        -- 2. cari posisi egg jatuh, GLIDE/FLY ke sana
        local pos, rec = findDroppedEggPos(uid)
        if not pos then pos = HUB.dropPos or origPos end
        if not pos then return false end
        print(string.format("[DROP] attempt %d -> ambil egg di %s", attempt, tostring(pos)))

        navTo(pos, speed, true)
        if not farmEnabled then return false end

        local hrp = findHRP()
        if hrp and (hrp.Position - pos).Magnitude > 14 then
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 1.8, 0))
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.3)
        end
        forceStandUp()

        -- 3. TUNGGU GUARD TIDUR (Oxide: kalau tidak, carry langsung di-alert)
        waitGuardAsleep(pos, 4.5)
        task.wait(0.1)

        -- 4. carry ulang 3 jalur (persis Oxide)
        local net = ReplicatedStorage:FindFirstChild("Packages")
            and ReplicatedStorage.Packages:FindFirstChild("Networking")
        local carryRemote = net and net:FindFirstChild("RF/EggWorld/AskFieldEggCarry")
        local slotKey = nil
        if rec and rec.AreaId and rec.NestId then
            pcall(function()
                if AreaEggSlotIdentity and AreaEggSlotIdentity.SlotKey then
                    slotKey = AreaEggSlotIdentity.SlotKey(rec.AreaId, rec.NestId)
                end
            end)
            if not slotKey then slotKey = tostring(rec.AreaId) .. ":" .. tostring(rec.NestId) end
        end

        pcall(function()
            if carryRemote then carryRemote:InvokeServer({ Uid = uid, FirstAreaSlotKey = slotKey }) end
        end)
        pcall(function()
            if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(uid, slotKey) end
        end)
        task.wait(0.08)

        -- cari prompt terdekat
        local prompt2 = nil
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Name == "CarryAreaEgg" and d.Enabled then
                local p = d.Parent
                if p and p:IsA("Attachment") then p = p.Parent end
                if p then
                    local act = (d.ActionText or ""):lower()
                    if not act:find("skip") and not act:find("robux") then
                        local h2 = findHRP()
                        local dist = (p.Position - (h2 and h2.Position or pos)).Magnitude
                        if dist < 18 then prompt2 = d; break end
                    end
                end
            end
        end
        if prompt2 then
            prompt2.HoldDuration = 0
            pcall(function() fireproximityprompt(prompt2) end)
            pcall(function() fireproximityprompt(prompt2, 0) end)
        end

        -- carry loop 2.5s
        local tCarry = os.clock()
        while os.clock() - tCarry < 2.5 and farmEnabled do
            if isPlayerCarryingEgg() then return true end
            if isRagdolled() then forceStandUp() end
            pcall(function()
                if carryRemote then carryRemote:InvokeServer({ Uid = uid, FirstAreaSlotKey = slotKey }) end
            end)
            pcall(function()
                if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(uid, slotKey) end
            end)
            if prompt2 then pcall(function() fireproximityprompt(prompt2) end) end
            task.wait(0.08)
        end
        if isPlayerCarryingEgg() then return true end
        task.wait(0.15)
    end

    print("[DROP] gagal ambil ulang egg di lapangan")
    return false
end

-- ============================================================

-- STEAL CORE HELPERS
-- ============================================================
local function fireCarry(uid, slotKey, carryRemote, prompt)
    if carryRemote then pcall(function() carryRemote:InvokeServer(uid, slotKey) end) end
    pcall(function()
        if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(uid, slotKey) end
    end)
    if prompt then
        pcall(function()
            prompt.Enabled = true
            prompt.HoldDuration = 0
            fireproximityprompt(prompt, 0)
        end)
    end
end

local function findPrompt(uid)
    local prompt = nil
    pcall(function()
        local sc = Workspace:FindFirstChild("AreaEggSlotsClient")
        local em = (sc and sc:FindFirstChild(uid)) or Workspace:FindFirstChild(uid, true)
        if em then
            prompt = em:FindFirstChild("CarryAreaEgg", true)
                or em:FindFirstChildWhichIsA("ProximityPrompt", true)
        end
    end)
    return prompt
end

local function waitStandup(waitTime)
    local t0 = os.clock()
    -- Heartbeat connection that keeps forcing reset during standup
    local conn
    conn = RunService.Heartbeat:Connect(function()
        pcall(function()
            local h = findHum()
            local ch = LP.Character
            if h then
                h.PlatformStand = false
                h.AutoRotate = true
            end
            if ch then
                for _, att in ipairs({"Ragdoll","Ragdolled","IsRagdoll","Downed","KnockedBack"}) do
                    if ch:GetAttribute(att) then ch:SetAttribute(att, false) end
                end
            end
        end)
    end)
    while os.clock() - t0 < waitTime and not false do
        if not isRagdolled() then break end
        local h = findHum()
        pcall(function()
            if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end)
        task.wait(0.05)
    end
    -- Stop heartbeat
    if conn then conn:Disconnect() end
    -- Final reset + re-enable Motor6D (SAE ragdoll system)
    pcall(function()
        local ch = LP.Character
        if ch then
            for _, v in ipairs(ch:GetDescendants()) do
                if v:IsA("Motor6D") and not v.Enabled then
                    v.Enabled = true
                end
            end
        end
        local h = findHum()
        if h then
            h.PlatformStand = false
            h.AutoRotate = true
            h:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
    task.wait(0.05)
end

-- ============================================================

-- ============================================================
-- FORCE TARGET EGG: cari record egg yang sedang dikejar
-- ============================================================
-- Kembalikan record terbaru untuk UID yang sedang di-force, atau nil
-- kalau egg sudah benar-benar tidak ada di lapangan.
local function findForcedEggRecord()
    if not forceTargetEgg or not forceTargetEgg.uid then return nil end
    if not EggState or not EggState.ReadFieldEggs then return nil end
    local ok, snap = pcall(EggState.ReadFieldEggs)
    if not ok or not snap or not snap.Records then return nil end
    for _, r in ipairs(snap.Records) do
        if r.Uid == forceTargetEgg.uid then
            -- posisi terbaru (egg bisa bergeser / pindah slot)
            if r.BoundsCFrame then forceTargetEgg.pos = r.BoundsCFrame.Position end
            forceTargetEgg.areaId = r.AreaId or forceTargetEgg.areaId
            forceTargetEgg.nestId = r.NestId or forceTargetEgg.nestId
            return r
        end
    end
    return nil
end

local function clearForceEgg(reason)
    if forceTargetEgg then
        print("[FORCE] stop kejar egg " .. tostring(forceTargetEgg.uid):sub(1, 8)
              .. " (" .. tostring(reason or "?") .. ")")
    end
    forceTargetEgg = nil
end

local function stealCycle()
    if not farmEnabled then return false end

    pcall(function()
        local h = findHum()
        if h then h.PlatformStand = false; h.AutoRotate = true end
    end)

    -- ============================================================
    -- FORCE TARGET EGG: kalau ada egg yang sedang dikejar, PAKSA
    -- lanjut kejar itu — JANGAN mulai siklus baru (cari egg lain).
    -- ============================================================
    local record = nil
    if forceEggEnabled and forceTargetEgg then
        forceTargetEgg.tries = (forceTargetEgg.tries or 0) + 1
        record = findForcedEggRecord()
        if record then
            print("[FORCE] lanjut kejar egg " .. tostring(record.Uid):sub(1, 8)
                  .. " (percobaan " .. forceTargetEgg.tries .. ")")
        else
            -- egg hilang dari snapshot -> cek apakah kita masih bawa
            if _carriedUid == forceTargetEgg.uid or hasEggToolAnywhere(forceTargetEgg.uid) then
                print("[FORCE] egg sudah di tangan, lanjut antar ke base")
            else
                clearForceEgg("egg tidak ada lagi di lapangan")
            end
        end
    end

    -- belum ada target paksa -> pilih egg terbaik seperti biasa
    if not record then
        local eggs = GetMatchingFieldEggs()
        if #eggs == 0 then return false end
        record = eggs[1].record
    end
    if not record or not record.Uid or not record.BoundsCFrame then return false end

    -- verifikasi egg masih ada + ambil data terbaru
    if EggState and EggState.ReadFieldEggs then
        local ok, snap = pcall(EggState.ReadFieldEggs)
        if ok and snap and snap.Records then
            local stillThere = false
            for _, r in ipairs(snap.Records) do
                if r.Uid == record.Uid and r.State == "Slot" then
                    stillThere = true; record = r; break
                end
            end
            if not stillThere then
                -- egg target hilang. Kalau ini egg paksa, jangan ganti egg
                -- selama masih ada kesempatan -> keluar, biar loop panggil
                -- lagi dan tetap mengejar UID yang sama.
                if forceTargetEgg and forceTargetEgg.uid == record.Uid
                   and forceTargetEgg.tries < forceMaxTries then
                    print("[FORCE] egg target belum terbaca, tunggu & ulangi (bukan siklus baru)")
                    return false
                end
                return false
            end
        end
    end

    -- ============================================================
    -- TETAPKAN target paksa saat pertama kali memilih egg
    -- ============================================================
    if forceEggEnabled and (not forceTargetEgg or forceTargetEgg.uid ~= record.Uid) then
        forceTargetEgg = {
            uid    = record.Uid,
            pos    = record.BoundsCFrame.Position,
            areaId = record.AreaId,
            nestId = record.NestId,
            tries  = 1,
            at     = os.clock(),
        }
        print("[FORCE] kunci target egg " .. tostring(record.Uid):sub(1, 8)
              .. " -> dikejar sampai dapat (tidak ganti egg)")
    end

    local targetPos = record.BoundsCFrame.Position
    local speed = math.clamp(farmSpeed or 750, 50, 1000)

    local slotKey = nil
    if record.AreaId and record.NestId then
        pcall(function()
            if AreaEggSlotIdentity and AreaEggSlotIdentity.SlotKey then
                slotKey = AreaEggSlotIdentity.SlotKey(record.AreaId, record.NestId)
            end
        end)
        if not slotKey then
            slotKey = tostring(record.AreaId) .. ":" .. tostring(record.NestId)
        end
    end

    local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
    local carryRemote = net and net:FindFirstChild("RF/EggWorld/AskFieldEggCarry")
    local dropRemote  = net and net:FindFirstChild("RF/EggWorld/AskFieldEggDrop")

    -- Helper: fire all carry methods
    local function doCarry()
        if carryRemote then pcall(function() carryRemote:InvokeServer(record.Uid, slotKey) end) end
        pcall(function()
            if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end
        end)
        local p = nil
        pcall(function()
            local sc = Workspace:FindFirstChild("AreaEggSlotsClient")
            local em = (sc and sc:FindFirstChild(record.Uid)) or Workspace:FindFirstChild(record.Uid, true)
            if em then p = em:FindFirstChild("CarryAreaEgg", true) or em:FindFirstChildWhichIsA("ProximityPrompt", true) end
        end)
        if p then p.HoldDuration = 0; pcall(function() fireproximityprompt(p) end) end
    end

    -- 1. Travel to egg
    travelToEgg(targetPos + Vector3.new(0, 1.2, 0), speed)
    if false or not farmEnabled then return false end

    local hrp = findHRP()
    if hrp then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.2, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    task.wait(0.5)

    -- 2. Carry + fallback table payload
    doCarry()
    if not isCarryingEgg() and carryRemote then
        pcall(function() carryRemote:InvokeServer({ Uid = record.Uid, FirstAreaSlotKey = slotKey }) end)
    end

    -- Carry retry loop 3s
    local tPickup = os.clock()
    local lastRefresh = 0
    while os.clock() - tPickup < 3.0 and farmEnabled do
        if hasEggToolAnywhere(record.Uid) then break end
        doCarry()
        if os.clock() - lastRefresh > 0.3 then
            lastRefresh = os.clock()
            pcall(function()
                local sc = Workspace:FindFirstChild("AreaEggSlotsClient")
                local em = (sc and sc:FindFirstChild(record.Uid)) or Workspace:FindFirstChild(record.Uid, true)
                if em then
                    local p2 = em:FindFirstChild("CarryAreaEgg", true) or em:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p2 then p2.Enabled = true; p2.HoldDuration = 0 end
                end
            end)
        end
        task.wait(0.08)
    end

    -- FIX: cek pakai UID (isCarryingEgg() bisa false padahal tool di Backpack)
    if not hasEggToolAnywhere(record.Uid) then
        if dropRemote then pcall(function() dropRemote:InvokeServer() end) end
        if EggState and EggState.DropFieldEgg then pcall(EggState.DropFieldEgg) end
        ignoredEggs[record.Uid] = os.clock()
        print("[TEST] carry failed")
        return false
    end

_carriedUid = record.Uid
startDropMonitor(record.Uid)   -- pantau: egg lepas dari tangan = jatuh
print("[TEST] carry OK, tunggu guard...")

    -- 3. Linger and wait for guard hit (4s)
    local startHealth = 100
    local hum0 = findHum()
    if hum0 then startHealth = hum0.Health end
    local wasHit = false
    lingerActive = true  -- pause anti-ragdoll
    local tGuard = os.clock()
    while os.clock() - tGuard < 4.0 and farmEnabled do
        -- FIX: dulu pakai isCarryingEgg() yang bisa salah baca -> wasHit tidak
        -- pernah true -> langsung travelToBase tanpa recarry. Sekarang pakai UID.
        if not hasEggToolAnywhere(record.Uid) then wasHit = true; break end
        local h = findHum()
        if h then
            local hs = h:GetState()
            if h.Health < startHealth - 1.5
                or hs == Enum.HumanoidStateType.Physics
                or hs == Enum.HumanoidStateType.Ragdoll
                or hs == Enum.HumanoidStateType.FallingDown then
                wasHit = true
                local tPost = os.clock()
                while os.clock() - tPost < 0.85 do
                    if not hasEggToolAnywhere(record.Uid) then break end
                    task.wait(0.05)
                end
                break
            end
        end
        task.wait(0.05)
    end

    lingerActive = false  -- resume anti-ragdoll

    -- === EGG JATUH -> LANGSUNG AMBIL DI TEMPAT (tanpa balik safe zone) ===
    -- Cek pakai UID (isCarryingEgg() doang bisa salah baca saat tool di Backpack)
    local stillHolding = hasEggToolAnywhere(record.Uid)
    if wasHit or not stillHolding then
        print("[TEST] kena guard / egg jatuh -> recovery DI TEMPAT...")
        task.wait(0.1)

        -- coba cepat dulu (mungkin masih dalam jangkauan)
        local reCarryOk = false
        local tSpam = os.clock()
        while os.clock() - tSpam < 1.2 and farmEnabled do
            if hasEggToolAnywhere(record.Uid) then reCarryOk = true; break end
            doCarry()
            task.wait(0.08)
        end

        -- belum dapat -> cari egg jatuh, glide/fly ke sana, ambil ulang
        if not reCarryOk then
            reCarryOk = recoverDroppedEgg(record.Uid, targetPos, speed)
        end

        if not reCarryOk then
            -- terakhir: kalau egg beneran lepas, jangan drop egg lain
            if not hasEggToolAnywhere(record.Uid) then
                if dropRemote then pcall(function() dropRemote:InvokeServer() end) end
                if EggState and EggState.DropFieldEgg then pcall(EggState.DropFieldEgg) end
            end
            ignoredEggs[record.Uid] = os.clock()
            print("[TEST] re-carry failed completely, skipping")
            clearForceEgg("gagal total, egg di-skip")
            return false
        end

        print("[TEST] recarry OK! -> balik safe zone (monitor hit aktif)")
        -- BYPASS DIHAPUS. Egg sudah dipegang, jadi langsung pulang pakai
        -- navigasi humanoid (Fly jarak jauh -> Tween Glide saat mendekat).
        -- Tidak ada teleport, jadi AC tidak kena Evidence.Teleport.
        --
        -- FIX: travel dipantau. Kalau kena hit DI JALAN:
        --   - anti-ragdoll langsung aktif (monitor set lingerActive=false)
        --   - egg jatuh diambil di tempat
        --   - setelah egg dipegang lagi, travel LANJUT ke safe zone
        local hitAgain = false
        HUB.travelAbort = false
        startTravelHitMonitor(record.Uid, function()
            hitAgain = true
        end)

        travelToBase(speed)
        stopTravelHitMonitor()
        HUB.travelAbort = false

        if not farmEnabled then stopDropMonitor() return false end

        -- kalau kena hit lagi di jalan -> recovery lalu LANJUT travel
        if hitAgain and not hasEggToolAnywhere(record.Uid) then
            print("[HIT] recovery di jalan -> ambil egg, lalu lanjut ke safe zone")
            local okRecover = recoverDroppedEgg(record.Uid, targetPos, speed)
            if okRecover then
                -- egg sudah dipegang lagi -> travel LANJUT (bukan mulai siklus baru)
                print("[HIT] egg didapat lagi -> lanjut travel ke safe zone")
                HUB.travelAbort = false
                startTravelHitMonitor(record.Uid, function() hitAgain = true end)
                travelToBase(speed)
                stopTravelHitMonitor()
                HUB.travelAbort = false
            end
        end
    end

    -- Tunggu delivery: pakai UID (isCarryingEgg() doang bisa salah baca
    -- saat tool masih di Backpack).
    local tDeliver = os.clock()
    while os.clock() - tDeliver < 8 do
        if not hasEggToolAnywhere(record.Uid) then break end
        task.wait(0.1)
    end
    if hasEggToolAnywhere(record.Uid) then
        print("[TEST] timeout, egg belum masuk pen -> skip")
        ignoredEggs[record.Uid] = os.clock()
        stopDropMonitor()
        ensureInSafeZone(speed)
        return false
    end
    stopDropMonitor()
    print("[TEST] DELIVERED! (tanpa bypass)")
    -- egg sudah masuk pen -> target paksa selesai, boleh pilih egg baru
    clearForceEgg("egg berhasil diantar ke base")
    
    -- Check carry status again AFTER attempting movement
    if hasEggToolAnywhere(record.Uid) then
        print("[TEST] Still holding egg after movement attempt, ensuring safety first.")
        ensureInSafeZone(speed)
        _carriedUid = nil
        return false
    end
    
    -- Final push just to be absolutely centered
    ensureInSafeZone(speed)
    _carriedUid = nil


    print("[TEST] cycle selesai")
    return true
end


-- ============================================================
-- ANTI RAGDOLL + FARM LOOP
-- ============================================================
track(RunService.Heartbeat:Connect(function()
    if lingerActive then return end  -- jangan reset saat guard hit window
    local h = findHum()
    if not h then return end
    local hs = h:GetState()
    -- FIX: dulu hanya menangani Physics. Kalau state sudah Ragdoll /
    -- FallingDown (atau Motor6D masih disabled), karakter tetap tergeletak
    -- -> "anti ragdoll sudah selesai tapi humanoid belum berdiri".
    -- Sekarang pakai forceStandUp() yang sekaligus re-enable Motor6D.
    if hs == Enum.HumanoidStateType.Physics
       or hs == Enum.HumanoidStateType.Ragdoll
       or hs == Enum.HumanoidStateType.FallingDown then
        forceStandUp()
    end
end))

task.spawn(function()
    while true do
        if farmEnabled then
            if hasEggToolAnywhere() then
                print("[TEST] still carrying an egg, returning to base before next cycle...")
                travelToBase(farmSpeed)
                local tCarry = os.clock()
                while hasEggToolAnywhere() and os.clock() - tCarry < 6 do
                    task.wait(0.15)
                end
            end

            -- ============================================================
            -- FORCE TARGET EGG: kalau masih ada egg yang dikejar, JANGAN
            -- balik ke safe zone dulu — LANGSUNG kejar lagi egg itu.
            -- Ini yang bikin farm "tidak memulai siklus baru" saat egg
            -- target masih ada / baru jatuh.
            -- ============================================================
            local forceActive = forceEggEnabled and forceTargetEgg ~= nil
            if forceActive and forceTargetEgg.tries
               and forceTargetEgg.tries >= forceMaxTries then
                clearForceEgg("batas percobaan habis (" .. forceMaxTries .. ")")
                forceActive = false
            end

            local didForce = false
            if forceActive then
                -- pastikan egg-nya masih ada sebelum langsung kejar
                local rec = findForcedEggRecord()
                if rec or hasEggToolAnywhere(forceTargetEgg.uid) then
                    print("[FORCE] kejar egg langsung (TANPA balik safe zone)")
                    local cycle = stealCycle
                    local ok, err = pcall(cycle)
                    if not ok then print("[TEST] error: " .. tostring(err)) end
                    task.wait(0.25)
                    didForce = true   -- tetap di jalur force, tidak reset target
                else
                    clearForceEgg("egg tidak ada lagi")
                end
            end

            -- --- alur normal (hanya kalau TIDAK sedang force) ---
            if not didForce then
                -- Settle before starting a new cycle. This is the Farm Delay
                -- slider (minimum 1s) so a new cycle can never start too early.
                task.wait(math.max(tonumber(farmDelay) or 1.5, 1.0))
                -- Walk back to the safe zone (no teleport). Only start a new
                -- cycle once we are actually there, so we never snap/steal afar.
                if ensureInSafeZone(farmSpeed) then
                    task.wait(0.8)
                    local cycle = stealCycle
                    local ok, err = pcall(cycle)
                    if not ok then print("[TEST] error: " .. tostring(err)) end
                else
                    print("[TEST] could not reach the safe zone, retrying...")
                end
            end
        end
        -- ALWAYS yield, even when farming is off, or this becomes a busy loop
        -- and freezes the client.
        task.wait(0.5)
    end
end)

pcall(function()
    local pps = game:GetService("ProximityPromptService")
    track(pps.PromptButtonHoldBegan:Connect(function(prompt, player)
        if player == LP and prompt.Name == "CarryAreaEgg" then
            prompt.HoldDuration = 0
        end
    end))
end)


-- ============================================================
-- BASE & AUTOMATION FUNCTIONS (from Update 2)
-- ============================================================
-- FIX: hatch PER TELUR, satu per satu dengan jeda.
-- Versi lama loop semua egg dalam satu panggilan tanpa jeda nyata
-- (task.wait(0.05) di dalam pcall) -> frame drop & server tolak.
-- Sekarang: ambil daftar uid siap-hatch, lalu proses SATU PER SATU,
-- dengan jeda antar telur supaya tidak membebani frame.
local _hatchQueue = {}
local _hatching = false

local function HatchAllReadyEggs()
    -- ============================================================
    -- VERSI REMOTE (bukti: Rspy Cobalt + Sae.txt + SAE UPDATE2 + Synv)
    -- ============================================================
    -- Cobalt capture:
    --   RF/EggWorld/AskHatch :InvokeServer("589eca8c628249b4978a2ff2931a84a2")
    --   -> satu argumen: UID (string)
    --
    -- Alur lengkap (SAE UPDATE2 / Sae.txt / Synv):
    --   AskHatch:InvokeServer(uid)         -- mulai hatch
    --   task.wait(...)
    --   AskFinishHatch:InvokeServer(uid)   -- selesaikan
    --   -> RemoteFunction, return (true, ?, petUid) kalau BERHASIL
    --
    -- Ini BEDA dari EggState.BeginHatch/FinishHatch yang gw pakai dulu —
    -- itu tidak ada / tidak tersinkron, makanya auto hatch tidak jalan.
    --
    -- DIPROSES PER TELUR (permintaan user): satu egg, jeda, baru egg
    -- berikutnya. Kalau semua sekaligus -> frame drop.
    -- ============================================================
    if _hatching then return 0 end
    if not EggState then
        print("[HATCH] EggState tidak ada")
        return 0
    end
    _hatching = true

    local net = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Networking")
    local AskHatch       = net and net:FindFirstChild("RF/EggWorld/AskHatch")
    local AskFinishHatch = net and net:FindFirstChild("RF/EggWorld/AskFinishHatch")
    if not AskHatch and not AskFinishHatch then
        print("[HATCH] remote AskHatch/AskFinishHatch tidak ketemu")
        _hatching = false
        return 0
    end

    -- sinkronkan daftar egg dulu
    pcall(function() if EggState.SyncOwnedEggs then EggState.SyncOwnedEggs() end end)
    task.wait(0.3)

    -- baca egg yang dimiliki: {[uid] = record}
    local owned = nil
    pcall(function()
        local reader = EggState.ReadOwnerEggs or EggState.ReadOwnedEggs
        if reader then owned = reader(LP.UserId) end
    end)
    if type(owned) == "table" and owned.Records then owned = owned.Records end
    if type(owned) ~= "table" then
        print("[HATCH] ReadOwnerEggs kosong")
        _hatching = false
        return 0
    end

    -- kumpulkan UID (key string ATAU rec.Uid) — jangan `break` saat aneh
    table.clear(_hatchQueue)
    for uid, rec in pairs(owned) do
        local u = nil
        if type(uid) == "string" then
            u = uid
        elseif type(rec) == "table" and type(rec.Uid) == "string" then
            u = rec.Uid
        end
        if u then _hatchQueue[#_hatchQueue + 1] = u end
    end

    if #_hatchQueue == 0 then
        _hatching = false
        return 0
    end

    -- proses SATU PER SATU (jeda nyata di luar pcall -> anti frame drop)
    local hatched = 0
    for i = 1, #_hatchQueue do
        local uid = _hatchQueue[i]
        if not S.autoHatchEnabled and not farmEnabled then break end

        -- 1. mulai hatch
        if AskHatch then
            pcall(function() AskHatch:InvokeServer(uid) end)
            task.wait(0.4)
        end

        -- 2. selesaikan hatch — return true kalau berhasil
        if AskFinishHatch then
            local ok, r1, r2, petUid = pcall(function()
                return AskFinishHatch:InvokeServer(uid)
            end)
            if ok and r1 == true then
                hatched = hatched + 1
                print("[HATCH] " .. tostring(uid):sub(1, 8)
                      .. " -> pet " .. tostring(petUid or r2 or "?"))
            end
            task.wait(0.4)
        end
    end

    _hatching = false
    print("[HATCH] " .. hatched .. "/" .. #_hatchQueue .. " telur berhasil di-hatch")
    return hatched
end

local function UpgradeHomesteadBase()
    local r1 = GetNetRemote("RE/Homestead/AskNearbyPurchase")
    if r1 then pcall(function() r1:FireServer() end) end
    local r2 = GetNetRemote("RE/Homestead/AskBaseTierRaise")
    if r2 then pcall(function() r2:FireServer() end) end
end

local function UpgradeTreadmillTier()
    local rf = GetNetRemote("RF/Treadmill/AskTierRaise")
    if rf then pcall(function() rf:InvokeServer() end) end
end

local function EquipBestPets()
    -- FIX: dulu cuma coba 2 remote dan tidak lapor kalau gagal.
    -- Sekarang: coba SEMUA kandidat remote, dan kembalikan jumlah yang berhasil.
    local CANDIDATES = {
        "RF/Haul/WearBest",
        "RF/PenRoster/ConfirmEquipBestBadge",
        "RF/PenRoster/ConfirmPetsBadge",
        "RF/Haul/FetchWearBestStatus",
    }
    local okCount = 0
    for _, name in ipairs(CANDIDATES) do
        local rf = GetNetRemote(name)
        if rf then
            local ok = pcall(function()
                if rf:IsA("RemoteFunction") then rf:InvokeServer()
                else rf:FireServer() end
            end)
            if ok then okCount = okCount + 1 end
            task.wait(0.15)
        end
    end
    return okCount
end

-- ============================================================
-- AUTO SELL — VERSI SellSelection (bukti: Rspy sell&place.txt + CloverHub)
-- ============================================================
-- Bukti dari Cobalt capture (Rspy):
--   RE/PetSatchel/SellSelection :FireServer({
--       Assets = {},                       -- UID pet
--       Eggs = {"cddeeb20...", "aa867b3a..."}   -- UID egg
--   })
--
-- CloverHub (SAE) juga menjelaskan:
--   "The legacy SellEveryPet path is never used (it ignored filtered IDs
--    in Sept 2 tests)." dan "SellSelection with explicit Assets/Eggs UID
--    arrays, WITHOUT equipping a Tool."
--
-- Artinya: SellPet per-UID TIDAK JALAN. Harus SellSelection + array.
-- JANGAN pakai SellEveryPet (jual semua tanpa filter).
local function SellSelection(assets, eggs)
    local re = GetNetRemote("RE/PetSatchel/SellSelection")
    if not re then
        print("[SELL] remote SellSelection tidak ketemu")
        return false
    end
    local ok = pcall(function()
        re:FireServer({ Assets = assets or {}, Eggs = eggs or {} })
    end)
    return ok
end

local function SellSelectedPets()
    if not SaveModule then
        print("[SELL] SaveModule tidak ada")
        return 0
    end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    local inv = save and save.Inventory
    if type(inv) ~= "table" then
        print("[SELL] save.Inventory bukan table")
        return 0
    end
    local filter = getSellRarityFilter(S.selectedSellPetRarities)
    local uids = {}
    for uid, petData in pairs(inv) do
        if type(petData) == "table" and not petData.Locked then
            local rName = petData.Rarity or "Common"
            if isRarityAllowed(rName, filter) then
                uids[#uids + 1] = tostring(uid)
            end
        end
    end
    if #uids == 0 then return 0 end

    -- kirim dalam batch kecil (hindari payload besar ditolak server)
    local BATCH, sent = 15, 0
    for i = 1, #uids, BATCH do
        local chunk = {}
        for j = i, math.min(i + BATCH - 1, #uids) do chunk[#chunk + 1] = uids[j] end
        if SellSelection(chunk, {}) then sent = sent + #chunk end
        task.wait(SELL_REQUEST_DELAY)
    end
    if sent > 0 then print("[SELL] pet: " .. sent .. " terkirim via SellSelection") end
    return sent
end

local function SellSelectedEggs()
    if not SaveModule then
        print("[SELL] SaveModule tidak ada")
        return 0
    end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    local inv = save and save.EggInventory
    if type(inv) ~= "table" then
        print("[SELL] save.EggInventory bukan table")
        return 0
    end
    local filter = getSellRarityFilter(S.selectedSellEggRarities)
    local uids = {}
    for uid, eggData in pairs(inv) do
        if type(eggData) == "table" and not eggData.Placement and not eggData.Locked then
            local rName = GetEggRarityInfo(eggData)
            if isRarityAllowed(rName, filter) then
                uids[#uids + 1] = tostring(uid)
            end
        end
    end
    if #uids == 0 then return 0 end

    local BATCH, sent = 15, 0
    for i = 1, #uids, BATCH do
        local chunk = {}
        for j = i, math.min(i + BATCH - 1, #uids) do chunk[#chunk + 1] = uids[j] end
        if SellSelection({}, chunk) then sent = sent + #chunk end
        task.wait(SELL_REQUEST_DELAY)
    end
    if sent > 0 then print("[SELL] egg: " .. sent .. " terkirim via SellSelection") end
    return sent
end

local function ClaimAllAvailableRewards()
    pcall(function()
        local rf1 = GetNetRemote("RF/AwayEarnings/AskCollect")
        if rf1 then rf1:InvokeServer() end
    end)
    pcall(function()
        local rf2 = GetNetRemote("RF/Codex/AskRedeemAll")
        if rf2 then rf2:InvokeServer() end
    end)
    pcall(function()
        local rf3 = GetNetRemote("RF/GroupPerk/RedeemPerk")
        if rf3 then rf3:InvokeServer() end
    end)
end

local function ResolveAreaId(name)
    local dir = AreasData and AreasData.Directory
    if type(dir) ~= "table" then return tostring(name) end
    local lower = string.lower(tostring(name))
    for id, info in pairs(dir) do
        if string.lower(tostring(id)) == lower then return id end
        if type(info) == "table" and info.DisplayName
            and string.lower(tostring(info.DisplayName)) == lower then
            return id
        end
    end
    return tostring(name)
end

local AreasData = nil
pcall(function() AreasData = require(RS.Data.Areas) end)
local RarityData = nil
pcall(function() RarityData = require(RS.Data.Rarity) end)

local function SafeTeleport(targetPos)
    local root = findHRP()
    if not root or not targetPos then return false end
    root.CFrame = CFrame.new(targetPos.X, math.max(targetPos.Y, 70.0), targetPos.Z)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function waitForGuardSleep(targetPos, timeout)
    timeout = timeout or 4.5
    local t0 = os.clock()
    while os.clock() - t0 < timeout do
        local guardAsleep = false
        pcall(function()
            local nearest, nd = nil, 1e9
            for _, m in ipairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and m.Name:lower():find("guard") and m.PrimaryPart then
                    local d = (m.PrimaryPart.Position - targetPos).Magnitude
                    if d < nd and d < 90 then nd = d; nearest = m end
                end
            end
            if nearest then
                local alert = nearest:GetAttribute("Alert") or nearest:GetAttribute("Alerted")
                local sleeping = nearest:GetAttribute("Sleeping") or nearest:GetAttribute("IsSleeping")
                if sleeping == true then guardAsleep = true
                elseif alert == false or alert == nil then
                    local hrpG = nearest.PrimaryPart
                    local eggPt = nearest:FindFirstChild("EggPoint", true)
                    local humG = nearest:FindFirstChildOfClass("Humanoid")
                    if hrpG and eggPt and (hrpG.Position - eggPt.Position).Magnitude < 12 
                        and (not humG or humG.MoveDirection.Magnitude < 0.15) then
                        guardAsleep = true
                    elseif os.clock() - t0 > 1.6 then
                        guardAsleep = true
                    end
                end
            else
                if os.clock() - t0 > 1.4 then guardAsleep = true end
            end
        end)
        if guardAsleep then break end
        task.wait(0.14)
    end
end

-- ============================================================
local AssetItemsMod = nil
pcall(function() AssetItemsMod = require(RS.Shared.Util.AssetItems) end)

-- ---------- AUTO FAVORITE ----------
local function FavoriteMatchesPet(category)
    if not category then return false end
    if next(S.favRarities) then
        local _, rarName = GetEggRarityInfo({ AssetCategory = category })
        if not S.favRarities[rarName] then return false end
    end
    if next(S.favNames) then
        for k in pairs(S.favNames) do
            if tostring(k):lower() == tostring(category):lower() then return true end
        end
        return false
    end
    return true
end

local function AutoFavoritePets()
    if not SaveModule or not AssetItemsMod then return 0 end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    if not save or type(save.Inventory) ~= "table" then return 0 end
    local favRe = GetNetRemote("RE/PetSatchel/WriteFavourite")
        or GetNetRemote("RF/PetSatchel/WriteFavourite")
    if not favRe then return 0 end
    local count = 0
    for uid, data in pairs(save.Inventory) do
        local ok, decoded = pcall(AssetItemsMod.Decode, data)
        if ok and decoded and not decoded.IsFavorite then
            if FavoriteMatchesPet(decoded.Category) then
                pcall(function()
                    if favRe:IsA("RemoteEvent") then
                        favRe:FireServer(uid, true)
                    else
                        favRe:InvokeServer(uid, true)
                    end
                end)
                count = count + 1
                if count % 10 == 0 then task.wait(0.05) end
            end
        end
    end
    return count
end

-- ---------- AUTO FUSE (whitelist, anti pet-loss) ----------
local function FuseMatchesPet(category, rarName)
    if S.fuseSelectedOnly then
        if not next(S.fuseNames) then return false end
        return S.fuseNames[category] == true
    end
    if next(S.fuseRarities) then
        return S.fuseRarities[rarName] == true
    end
    return false  -- tanpa filter = JANGAN fuse
end

local function AutoFusePets()
    if not SaveModule or not AssetItemsMod then return false, "modules not ready" end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    if not save or type(save.Inventory) ~= "table" then return false, "no save" end
    if type(save.FusionSlots) ~= "table" then return false, "no FusionSlots" end

    if save.FusionLocked == true then return false, "machine is fusing" end
    if save.FusionEggReward ~= false and save.FusionEggReward ~= nil then
        local revealNet = GetNetRemote("RF/Fusery/FinishReveal")
        if revealNet then pcall(function() revealNet:InvokeServer() end) end
        return false, "claim reward first"
    end

    local equipped = {}
    for _, uid in ipairs(save.EquippedAssets or {}) do equipped[tostring(uid)] = true end

    local groups = {}
    for uid, data in pairs(save.Inventory) do
        if not equipped[tostring(uid)] then
            local ok, decoded = pcall(AssetItemsMod.Decode, data)
            if ok and decoded and not decoded.IsFavorite and not decoded.InFuse then
                local cat = decoded.Category or ""
                local rarName = select(1, GetEggRarityInfo({ AssetCategory = cat }))
                if FuseMatchesPet(cat, rarName) then
                    groups[cat] = groups[cat] or {}
                    table.insert(groups[cat], tostring(uid))
                end
            end
        end
    end

    local cats = {}
    for c, uids in pairs(groups) do
        if #uids >= 3 then table.insert(cats, c) end
    end
    if #cats == 0 then return false, "no 3 pets of same category" end
    table.sort(cats)
    local chosen = groups[cats[1]]
    table.sort(chosen, function(a, b) return tostring(a) < tostring(b) end)

    local fuseNet   = GetNetRemote("RF/Fusery/BeginFuse")
    local insertNet = GetNetRemote("RF/Fusery/LoadPet")
    local revealNet = GetNetRemote("RF/Fusery/FinishReveal")
    local briefNet  = GetNetRemote("RF/Fusery/ConfirmBriefing")
    if not (fuseNet and insertNet and revealNet) then return false, "fuse remotes missing" end

    local price = tonumber(save.FusionPrice) or 0
    if price > 0 and (tonumber(save.Money) or 0) < price then
        return false, "not enough money for fuse"
    end

    local okAll, err = pcall(function()
        if briefNet then briefNet:InvokeServer() end
        for i = 1, 3 do
            local latest = nil
            pcall(function() latest = SaveModule.Get and SaveModule.Get() end)
            if latest and latest.Inventory and latest.Inventory[chosen[i]] then
                insertNet:InvokeServer(chosen[i])
            end
            task.wait(0.05)
        end
        fuseNet:InvokeServer()
        local t0 = os.clock()
        while os.clock() - t0 < 10 do
            local s = nil
            pcall(function() s = SaveModule.Get and SaveModule.Get() end)
            if not s then break end
            if s.FusionEggReward == true then break end
            if s.FusionLocked ~= true and s.FusionEggReward == false then break end
            task.wait(0.25)
        end
        revealNet:InvokeServer()
    end)
    return okAll, (okAll and "fused" or tostring(err))
end

-- ---------- UTILITY ----------
local function SetFullbright(on)
    if on then
        HUB._savedLighting = HUB._savedLighting or {
            Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
            Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
            FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
        }
        pcall(function()
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        end)
    elseif HUB._savedLighting then
        pcall(function()
            local s = HUB._savedLighting
            Lighting.Brightness = s.Brightness; Lighting.ClockTime = s.ClockTime
            Lighting.Ambient = s.Ambient; Lighting.OutdoorAmbient = s.OutdoorAmbient
            Lighting.FogEnd = s.FogEnd; Lighting.GlobalShadows = s.GlobalShadows
        end)
        HUB._savedLighting = nil
    end
end

local function applyMovementTweaks()
    local h = findHum()
    if not h then return end
    if S.jumpPowerEnabled then
        pcall(function() h.UseJumpPower = true; h.JumpPower = S.jumpPowerValue end)
    end
    if S.infiniteJumpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end

-- ============================================================
-- FLY (WASD) / ANTI-TRAP / FPS GOVERNOR / HIDE VISUALS
-- ============================================================
local _flyConns = {}
local _flyBV    = nil
local function stopFly()
    for _, c in ipairs(_flyConns) do pcall(function() c:Disconnect() end) end
    _flyConns = {}
    if _flyBV then pcall(function() _flyBV:Destroy() end); _flyBV = nil end
    local h = findHum()
    if h then pcall(function() h.PlatformStand = false; h:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
end

local function startFly()
    stopFly()
    local hrp = findHRP()
    local h   = findHum()
    if not hrp or not h then return end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AscendFly"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    _flyBV = bv
    h.PlatformStand = true
    local cam = Workspace.CurrentCamera
    table.insert(_flyConns, RunService.RenderStepped:Connect(function()
        if not S.flyEnabled then stopFly(); return end
        local hrpNow = findHRP()
        if not hrpNow or not _flyBV or not _flyBV.Parent then return end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        local speed = math.clamp(tonumber(S.flySpeed) or 60, 10, 400)
        _flyBV.Velocity = (dir.Magnitude > 0) and (dir.Unit * speed) or Vector3.zero
    end))
end

-- ---------- ANTI-TRAP ----------
-- ============================================================
-- ANTI-TRAP  (port dari Oxide — versi lebih aman & lengkap)
-- ============================================================
-- Beda dengan versi lama:
--   lama : Workspace:GetChildren() + v:Destroy()  <- destruktif & detectable,
--          dan trap ada di dalam Workspace.__DEBRIS (bukan child langsung),
--          jadi hampir tidak pernah kena.
--   baru : scan Workspace.__DEBRIS, hanya trap MILIK ORANG LAIN,
--          nonaktifkan (CanTouch/CanQuery=false) TANPA menghapus,
--          pindahkan Hitbox jauh, hapus TouchTransmitter (ini sumber damage).
local _trapCacheAt = 0

-- Nonaktifkan satu trap tanpa menghapusnya.
local function neutralizeOneTrap(d)
    local ok = pcall(function()
        if d:IsA("BasePart") then
            d.CanTouch = false
            d.CanQuery = false
        end
        for _, c in ipairs(d:GetChildren()) do
            if c:IsA("BasePart") then
                c.CanTouch = false
                c.CanQuery = false
                if c.Name == "Hitbox" then
                    c.CFrame = CFrame.new(0, -999, 0)
                end
            end
        end
        local tt = d:FindFirstChildWhichIsA("TouchTransmitter", true)
        if tt then pcall(function() tt:Destroy() end) end
    end)
    return ok
end

NeutralizeTraps = function(force)
    if not force and not S.avoidTrapsEnabled then return 0 end
    local now = os.clock()
    if not force and (now - _trapCacheAt) < 1.5 then return 0 end
    _trapCacheAt = now

    local n = 0
    local debris = Workspace:FindFirstChild("__DEBRIS")
    if debris then
        for _, d in ipairs(debris:GetChildren()) do
            if d.Name == "PlayerTrap" and d:GetAttribute("Owner") ~= LP.Name then
                if neutralizeOneTrap(d) then n = n + 1 end
            end
        end
    end
    -- fallback: kalau trap tidak di __DEBRIS (versi game lain)
    if n == 0 then
        for _, v in ipairs(Workspace:GetChildren()) do
            local nm = v.Name:lower()
            if (v:IsA("BasePart") or v:IsA("Model"))
                and (nm:find("playertrap") or nm:find("trap") or nm:find("spike")) then
                if neutralizeOneTrap(v) then n = n + 1 end
            end
        end
    end
    return n
end

local function ApplyAntiTrap(on)
    if HUB._trapConn then pcall(function() HUB._trapConn:Disconnect() end); HUB._trapConn = nil end
    if not on then return end
    pcall(NeutralizeTraps, true)
    -- trap baru muncul -> langsung dinetralkan (tanpa Destroy)
    HUB._trapConn = Workspace.DescendantAdded:Connect(function(v)
        if not S.avoidTrapsEnabled then return end
        if v.Name == "PlayerTrap" or v.Name:lower():find("trap") or v.Name:lower():find("spike") then
            task.defer(function() pcall(neutralizeOneTrap, v) end)
        end
    end)
    -- pembersih berkala: trap bisa muncul tanpa lewat DescendantAdded
    task.spawn(function()
        while not HUB.dead and S.avoidTrapsEnabled do
            task.wait(1.0)
            pcall(NeutralizeTraps)
        end
    end)
end

-- ---------- FPS GOVERNOR / HIDE VISUALS ----------
local _fpsConns = {}
local _savedPets, _savedEggs, _savedPlot = {}, {}, {}

local function ClearFPSConns()
    for _, c in ipairs(_fpsConns) do pcall(function() c:Disconnect() end) end
    _fpsConns = {}
end

local function HideDescendants(obj, cache)
    if not obj then return end
    for _, v in ipairs(obj:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                if cache[v] == nil then
                    cache[v] = { ltm = v.LocalTransparencyModifier, tr = v.Transparency }
                end
                v.LocalTransparencyModifier = 1
                v.Transparency = 1
            elseif v:IsA("Decal") or v:IsA("Texture") then
                if cache[v] == nil then cache[v] = { tr = v.Transparency } end
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
                or v:IsA("Highlight") or v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
                if cache[v] == nil then cache[v] = { en = v.Enabled } end
                v.Enabled = false
            end
        end)
    end
end

local function RestoreCache(cache)
    for obj, data in pairs(cache) do
        pcall(function()
            if obj and obj.Parent then
                if obj:IsA("BasePart") then
                    obj.LocalTransparencyModifier = data.ltm or 0
                    obj.Transparency = data.tr or 0
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = data.tr or 0
                else
                    obj.Enabled = data.en ~= false
                end
            end
        end)
    end
    table.clear(cache)
end

local function ApplyHideAllPets(on)
    for _, v in ipairs(Workspace:GetChildren()) do
        if v.Name == "ClientRenderedAssets" then
            HideDescendants(v, _savedPets)
        end
    end
    if on then
        table.insert(_fpsConns, Workspace.ChildAdded:Connect(function(c)
            if c.Name == "ClientRenderedAssets" and S.hideAllPets then
                HideDescendants(c, _savedPets)
            end
        end))
    end
end

local function ApplyFPSBoost(on)
    ClearFPSConns()
    if not on then
        RestoreCache(_savedPets); RestoreCache(_savedEggs); RestoreCache(_savedPlot)
        pcall(function()
            Lighting.GlobalShadows = true
        end)
        return
    end
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end)
    table.insert(_fpsConns, Workspace.DescendantAdded:Connect(function(v)
        if not S.fpsBoost then return end
        pcall(function()
            if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
                or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
                v.Enabled = false
            end
        end)
    end))
    for _, v in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
                or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
                v.Enabled = false
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
            end
        end)
    end
    if S.hideAllPets then ApplyHideAllPets(true) end
end

local function SetAntiAFK(on)
    if on then
        if not HUB._antiAfkConn then
            HUB._antiAfkConn = LP.Idled:Connect(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
        end
    else
        if HUB._antiAfkConn then
            pcall(function() HUB._antiAfkConn:Disconnect() end)
            HUB._antiAfkConn = nil
        end
    end
end

-- ---------- FPS & PING PANEL (kecil, logo, draggable) ----------
local LOGO_ID = "rbxassetid://84165946247686"
local _statsPanel = nil
local _statsConn  = nil

local function applyStatsPanel(show)
    if not show then
        if _statsConn then pcall(function() _statsConn:Disconnect() end); _statsConn = nil end
        if _statsPanel then pcall(function() _statsPanel:Destroy() end); _statsPanel = nil end
        return
    end
    if _statsPanel then return end

    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "Ascend_Stats"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 99999
    sg.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(150, 30)
    frame.Position = UDim2.new(1, -162, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(44, 58, 86)
    stroke.Thickness = 1
    stroke.Parent = frame

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.fromOffset(16, 16)
    icon.Position = UDim2.new(0, 7, 0.5, -8)
    icon.BackgroundTransparency = 1
    icon.Image = LOGO_ID
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -32, 1, 0)
    lbl.Position = UDim2.new(0, 28, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.RichText = true
    lbl.Text = "FPS -- | -- ms"
    lbl.Parent = frame

    _statsPanel = sg

    -- draggable (mouse + touch, jadi aman di PC & mobile)
    local dragging, dragStart, startPos = false, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    table.insert(HUB.conns, UserInputService.InputChanged:Connect(function(input)
        if not dragging or not _statsPanel then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    local frames, lastT = 0, os.clock()
    _statsConn = RunService.RenderStepped:Connect(function()
        if not _statsPanel or not _statsPanel.Parent then return end
        frames = frames + 1
        local now = os.clock()
        if now - lastT >= 1 then
            local fps = math.floor(frames / (now - lastT))
            frames, lastT = 0, now
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local fpsCol = fps >= 50 and "150,220,170" or (fps >= 30 and "240,176,108" or "240,120,120")
            local pingCol = ping <= 80 and "150,220,170" or (ping <= 160 and "240,176,108" or "240,120,120")
            lbl.Text = string.format(
                '<font color="rgb(%s)">FPS %d</font>  <font color="#8c9cb8">|</font>  <font color="rgb(%s)">%d ms</font>',
                fpsCol, fps, pingCol, ping)
        end
    end)
end

-- ---------- REDUCE MAP (LIGHTWEIGHT, REVERSIBLE) ----------
local _mapSaved = {}
local _mapConns = {}

local function ClearMapReduceConns()
    for _, c in ipairs(_mapConns) do pcall(function() c:Disconnect() end) end
    _mapConns = {}
end

local function IsProtectedFromReduce(v)
    local node = v
    for _ = 1, 6 do
        if not node or node == Workspace then break end
        local nm = node.Name
        if nm and nm ~= "" then
            local low = nm:lower()
            if low:find("guard", 1, true)
                or low:find("egg", 1, true)
                or low:find("nest", 1, true) then
                return true
            end
        end
        node = node.Parent
    end
    return false
end

local function ReduceOne(v)
    if not v or not v.Parent then return end
    if IsProtectedFromReduce(v) then return end
    pcall(function()
        if v:IsA("BasePart") then
            if _mapSaved[v] == nil then _mapSaved[v] = { cs = v.CastShadow } end
            if v.CastShadow then v.CastShadow = false end
        elseif v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
            or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles")
            or v:IsA("SelectionBox") then
            if _mapSaved[v] == nil then _mapSaved[v] = { en = v.Enabled } end
            if v.Enabled then v.Enabled = false end
        elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            -- lampu: shadow-map + fill cost, matiin (dari addon setReduceMap)
            if _mapSaved[v] == nil then _mapSaved[v] = { en = v.Enabled } end
            if v.Enabled then v.Enabled = false end
        end
    end)
end

local function ApplyReduceMap(on)
    ClearMapReduceConns()
    if not on then
        -- Restore exactly as before
        for obj, data in pairs(_mapSaved) do
            pcall(function()
                if obj and obj.Parent then
                    if data.cs ~= nil then obj.CastShadow = data.cs end
                    if data.en ~= nil then obj.Enabled = data.en end
                end
            end)
        end
        table.clear(_mapSaved)
        return
    end
    task.spawn(function()
        local buf = {}
        for _, v in ipairs(Workspace:GetDescendants()) do
            if not S.reduceMap then return end
            buf[#buf + 1] = v
            if #buf >= 400 then
                for _, x in ipairs(buf) do ReduceOne(x) end
                table.clear(buf)
                task.wait()
            end
        end
        for _, x in ipairs(buf) do ReduceOne(x) end
        if S.reduceMap then
            table.insert(_mapConns, Workspace.DescendantAdded:Connect(function(v)
                if not S.reduceMap then return end
                ReduceOne(v)
            end))
        end
    end)
end

-- Additional worker loops
task.spawn(function()
    while true do
        task.wait(2.5)
        if S.autoHatchEnabled then pcall(HatchAllReadyEggs) end
        if S.autoPlantEnabled then pcall(PlantAllCarriedEggsInPen) end
        if S.autoUpgradeBase then pcall(UpgradeHomesteadBase) end
        if S.autoUpgradeTreadmill then pcall(UpgradeTreadmillTier) end
        if S.autoEquipBestPets then pcall(EquipBestPets) end
        if S.autoClaimRewards then pcall(ClaimAllAvailableRewards) end
        if S.autoSellPets then pcall(SellSelectedPets) end
        if S.autoSellEggs then pcall(SellSelectedEggs) end
        if S.autoFavoritePets then pcall(AutoFavoritePets) end
        if S.autoFusePets then pcall(AutoFusePets) end
    end
end)

-- Movement tweaks loop (infinite jump / jump power / walkspeed)
track(RunService.Heartbeat:Connect(function()
    if HUB.dead then return end
    if S.walkSpeedEnabled then
        local h = findHum()
        if h then pcall(function() h.WalkSpeed = math.clamp(S.walkSpeedVal or 24, 16, 500) end) end
    end
    if S.jumpPowerEnabled or S.infiniteJumpEnabled then
        pcall(applyMovementTweaks)
    end
end))

-- Bat Aura loop
task.spawn(function()
    local batRe = GetNetRemote("RE/BatSwing/Trigger")
    while true do
        task.wait(S.batAuraDelay)
        if S.batAuraEnabled and batRe then
            local hrp = findHRP()
            if hrp then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if oHrp and (oHrp.Position - hrp.Position).Magnitude <= S.batAuraRadius then
                            pcall(function() batRe:FireServer() end)
                            break
                        end
                    end
                end
            end
        end
    end
end)


-- WIND UI
-- ============================================================-- ============================================================
-- UI - Airflow (blue theme)
-- ============================================================
local success, loaded = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/PookiePepelsss/Airflow-UI/refs/heads/main/Source.luau"
    ))()
end)
if not success or not loaded then warn("[Ascend] Airflow failed to load"); return end
Airflow = loaded

-- ---- BLUE THEME (Ascend) ----
Airflow.Theme.Background  = Color3.fromRGB(10, 14, 24)
Airflow.Theme.Surface     = Color3.fromRGB(16, 22, 36)
Airflow.Theme.Surface2    = Color3.fromRGB(20, 27, 44)
Airflow.Theme.Surface3    = Color3.fromRGB(34, 45, 68)
Airflow.Theme.Stroke      = Color3.fromRGB(44, 58, 86)
Airflow.Theme.StrokeHover = Color3.fromRGB(80, 120, 180)
Airflow.Theme.Accent      = Color3.fromRGB(90, 160, 255)
Airflow.Theme.AccentDark  = Color3.fromRGB(10, 16, 28)
Airflow.Theme.Text        = Color3.fromRGB(235, 242, 255)
Airflow.Theme.Muted       = Color3.fromRGB(130, 148, 178)
Airflow.Theme.Success     = Color3.fromRGB(150, 220, 170)
Airflow.Theme.Warning     = Color3.fromRGB(240, 176, 108)
Airflow.Theme.Error       = Color3.fromRGB(240, 120, 120)

local Window = Airflow:CreateWindow({
    Name             = "Ascend official",
    LoadingSubtitle  = "Ascend official",
    Icon             = LOGO_ID,
    ToggleUIKeybind  = "F3",
    Size             = UDim2.fromOffset(520, 390),
    MinSize          = Vector2.new(420, 320),
    KeepOnScreen     = true,
    MaxNotifications = 4,
    OpenButton       = { Title = "Ascend official", Icon = LOGO_ID },
    Loading          = {
        Enabled  = true,
        Title    = "Ascend official",
        Text     = "Starting",
        Duration = 1.2,
    },
})

local function Notify(title, text, dur)
    pcall(function()
        Airflow:Notify({ Title = title, Content = tostring(text), Duration = dur or 3 })
    end)
end

-- ---------- TABS ----------
local FarmTab   = Window:Tab({ Name = "Farm",    Icon = "egg"           })
local BaseTab   = Window:Tab({ Name = "Base",    Icon = "house"         })
local StoreTab  = Window:Tab({ Name = "Store",   Icon = "shopping-cart" })
local PlayerTab = Window:Tab({ Name = "Player",  Icon = "user"          })
local MiscTab   = Window:Tab({ Name = "Misc",    Icon = "wrench"        })

local function rarityValues()
    local t = { "All" }
    for _, v in ipairs(RARITY_NAMES) do t[#t + 1] = v end
    return t
end

-- Multi-select helper: "All" (or empty) = no filter
local function applyMultiFilter(target, v)
    table.clear(target)
    if type(v) == "table" then
        for _, o in ipairs(v) do
            if o ~= "All" then target[o] = true end
        end
    elseif type(v) == "string" and v ~= "All" then
        target[v] = true
    end
end


-- ==========================================================
-- FARM
-- ==========================================================
FarmTab:Section("Steal")
FarmTab:Toggle({
    Name    = "Auto Steal Egg",
    Desc     = "Enable automatic egg steal cycle",
    CurrentValue  = false,
    Callback = function(v)
        farmEnabled = v
        if v then pcall(loadModules) end   -- modul bisa belum ke-load saat script baru jalan
        Notify("Farm", v and "Auto Steal ON" or "Auto Steal OFF")
    end,
})
FarmTab:Dropdown({
    Name    = "Movement Method",
    Options   = { "Tween Glide", "Fly Glide" },
    CurrentOption  = "Tween Glide",
    Callback = function(v) moveMethod = v end,
})
FarmTab:Slider({
    Name    = "Farm Speed",
    Min = 50, Max = 1000, CurrentValue = 750,
    Increment     = 1,
    Callback = function(v) farmSpeed = v end,
})
FarmTab:Slider({
    Name    = "Farm Delay",
    Min = 1, Max = 10, CurrentValue = 2,
    Increment     = 1,
    Callback = function(v) farmDelay = v end,
})
FarmTab:Section("Filters")
FarmTab:Dropdown({
    Name    = "Filter Rarity",
    Options   = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v)
        applyMultiFilter(targetRarities, v)
        Notify("Filter", "Rarity filter updated")
    end,
})
FarmTab:Dropdown({
    Name    = "Filter Area",
    Options   = (function()
        local t = { "All" }
        for _, v in ipairs(AREA_NAMES) do t[#t + 1] = v end
        return t
    end)(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v)
        applyMultiFilter(targetAreas, v)
        Notify("Filter", "Area filter updated")
    end,
})
FarmTab:Dropdown({
    Name = "Filter Mutation",
    Desc = "Mutations allowed to steal (empty = all)",
    Options = { "Normal Only", "Mutated Only", "Parasite / Infested", "Monstrous", "Silver Only", "Gold Only", "Rainbow Only" },
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v)
        applyMultiFilter(targetMutations, v)
        Notify("Filter", "Mutation filter updated")
    end,
})
FarmTab:Toggle({
    Name    = "Steal Big Eggs Only",
    CurrentValue  = false,
    Callback = function(v) S.stealBigEggsOnly = v end,
})
FarmTab:Section("Actions")
FarmTab:Button({
    Name    = "Steal Once",
    Callback = function()
        task.spawn(function()
            local cycle = stealCycle
            local ok, err = pcall(cycle)
            Notify("Farm", ok and "Done" or tostring(err))
        end)
    end,
})
FarmTab:Button({
    Name    = "Clear Ignored Eggs",
    Callback = function()
        table.clear(ignoredEggs)
        Notify("Farm", "Cleared")
    end,
})

FarmTab:Section("Drop Recovery")
FarmTab:Toggle({
    Name    = "Ambil Egg Jatuh Di Tempat",
    Desc    = "Egg jatuh -> cari di lapangan & ambil ulang. TIDAK balik safe zone dulu.",
    CurrentValue = true,
    Callback = function(v)
        dropRecovery = v
        Notify("Drop Recovery", v and "ON" or "OFF")
    end,
})
FarmTab:Toggle({ Name = "Kejar Egg Sampai Dapat (tanpa siklus baru)", CurrentValue = true,
    Desc = "Kalau egg target masih ada, terus kejar egg itu. Tidak balik safe zone dulu.",
    Callback = function(v)
        forceEggEnabled = v
        if not v then clearForceEgg("dimatikan user") end
    end })
FarmTab:Slider({
    Name    = "Maks Coba Ambil Ulang",
    Desc    = "Berapa kali coba ambil egg jatuh sebelum di-skip",
    Min = 1, Max = 8, CurrentValue = 3,
    Callback = function(v) dropMaxTries = math.floor(v) end,
})

-- ==========================================================
-- BASE
-- ==========================================================
BaseTab:Section("Automation")
BaseTab:Toggle({ Name = "Auto Place Eggs", CurrentValue = false,
    Callback = function(v) S.autoPlantEnabled = v end })
BaseTab:Dropdown({
    Name    = "Place Rarities",
    Desc     = "Rarities allowed to be placed in pen (All = every rarity)",
    Options   = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v)
        applyMultiFilter(S.placeRarities, v)
        Notify("Place", "Rarity filter updated")
    end,
})
BaseTab:Toggle({ Name = "Auto Hatch Eggs", CurrentValue = false,
    Callback = function(v) S.autoHatchEnabled = v end })
BaseTab:Toggle({ Name = "Auto Upgrade Base", CurrentValue = false,
    Callback = function(v) S.autoUpgradeBase = v end })
BaseTab:Toggle({ Name = "Auto Upgrade Treadmill", CurrentValue = false,
    Callback = function(v) S.autoUpgradeTreadmill = v end })
BaseTab:Toggle({ Name = "Auto Equip Best Pets", CurrentValue = false,
    Callback = function(v) S.autoEquipBestPets = v end })
BaseTab:Toggle({ Name = "Auto Claim Rewards", CurrentValue = false,
    Callback = function(v) S.autoClaimRewards = v end })
BaseTab:Toggle({ Name = "Auto Favorite Pets", CurrentValue = false,
    Callback = function(v) S.autoFavoritePets = v end })
BaseTab:Dropdown({
    Name    = "Fav Rarities",
    Options   = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v)
        applyMultiFilter(S.favRarities, v)
    end,
})
BaseTab:Section("Run Now")
BaseTab:Button({ Name = "Place Eggs Now",
    Callback = function()
        task.spawn(function()
            local n = PlantAllCarriedEggsInPen()
            Notify("Place", "Planted " .. tostring(n) .. " eggs")
        end)
    end })
BaseTab:Button({ Name = "Hatch All Now",
    Callback = function()
        task.spawn(function()
            local n = HatchAllReadyEggs()
            Notify("Hatch", "Hatched " .. tostring(n) .. " eggs")
        end)
    end })
BaseTab:Button({ Name = "Claim All Rewards",
    Callback = function() pcall(ClaimAllAvailableRewards); Notify("Rewards", "Claimed") end })
BaseTab:Button({ Name = "Upgrade Base Now",
    Callback = function() pcall(UpgradeHomesteadBase); Notify("Base", "Upgraded") end })
BaseTab:Button({ Name = "Upgrade Treadmill Now",
    Callback = function() pcall(UpgradeTreadmillTier); Notify("Treadmill", "Upgraded") end })
BaseTab:Button({ Name = "Favorite Now",
    Callback = function()
        task.spawn(function()
            local n = AutoFavoritePets()
            Notify("Favorite", "Favorited " .. tostring(n))
        end)
    end })

-- ==========================================================
-- STORE
-- ==========================================================
StoreTab:Section("Pets")
StoreTab:Toggle({ Name = "Auto Sell Low-Tier Pets", CurrentValue = false,
    Callback = function(v) S.autoSellPets = v end })
StoreTab:Dropdown({
    Name    = "Pet Sell Rarities",
    Options   = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v)
        applyMultiFilter(S.selectedSellPetRarities, v)
    end,
})
StoreTab:Button({ Name = "Sell Pets Now",
    Callback = function()
        task.spawn(function() pcall(SellSelectedPets); Notify("Sell", "Done") end)
    end })
StoreTab:Section("Eggs")
StoreTab:Toggle({ Name = "Auto Sell Low-Tier Eggs", CurrentValue = false,
    Callback = function(v) S.autoSellEggs = v end })
StoreTab:Dropdown({
    Name    = "Egg Sell Rarities",
    Options   = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v)
        applyMultiFilter(S.selectedSellEggRarities, v)
    end,
})
StoreTab:Button({ Name = "Sell Eggs Now",
    Callback = function()
        task.spawn(function() pcall(SellSelectedEggs); Notify("Sell", "Done") end)
    end })

-- ==========================================================
-- PLAYER
-- ==========================================================
PlayerTab:Section("Combat")
PlayerTab:Toggle({ Name = "Anti-Trap", Desc = "Destroy enemy trap hitboxes",
    CurrentValue = false,
    Callback = function(v)
        avoidTrapsEnabled = v
        ApplyAntiTrap(v)
        Notify("Anti-Trap", v and "ON" or "OFF")
    end })
PlayerTab:Toggle({ Name = "Bat / Slap Aura", CurrentValue = false,
    Callback = function(v) S.batAuraEnabled = v; Notify("Bat Aura", v and "ON" or "OFF") end })
PlayerTab:Slider({ Name = "Aura Radius",
    Min = 5, Max = 60, CurrentValue = 20, Increment = 1,
    Callback = function(v) S.batAuraRadius = v end })
PlayerTab:Slider({ Name = "Swing Delay",
    Min = 1, Max = 20, CurrentValue = 2, Increment = 1,
    Callback = function(v) S.batAuraDelay = v / 10 end })
PlayerTab:Button({ Name = "Swing Bat Once",
    Callback = function()
        local re = GetNetRemote("RE/BatSwing/Trigger")
        if re then pcall(function() re:FireServer() end) end
        Notify("Bat", "Triggered")
    end })
PlayerTab:Toggle({ Name = "Auto Fuse Pets", CurrentValue = false,
    Callback = function(v) S.autoFusePets = v; Notify("Fuse", v and "ON" or "OFF") end })
PlayerTab:Toggle({ Name = "Fuse: Selected Only (whitelist)", CurrentValue = false,
    Callback = function(v) S.fuseSelectedOnly = v end })
PlayerTab:Dropdown({
    Name    = "Fuse Rarities",
    Options   = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v)
        applyMultiFilter(S.fuseRarities, v)
    end,
})
PlayerTab:Button({ Name = "Fuse Once",
    Callback = function()
        task.spawn(function()
            if not next(S.fuseRarities) and not S.fuseSelectedOnly then
                Notify("Fuse", "Set Fuse Rarities first (safety)")
                return
            end
            local ok, msg = AutoFusePets()
            Notify("Fuse", ok and "Fused!" or tostring(msg or "failed"))
        end)
    end })
PlayerTab:Section("Movement")
PlayerTab:Toggle({ Name = "Enable WalkSpeed", CurrentValue = false,
    Callback = function(v)
        walkSpeedEnabled = v
        if not v then local h = findHum(); if h then h.WalkSpeed = 16 end end
    end })
PlayerTab:Slider({ Name = "WalkSpeed Value",
    Min = 16, Max = 500, CurrentValue = 24, Increment = 1,
    Callback = function(v) S.walkSpeedVal = v end })
PlayerTab:Toggle({ Name = "Enable JumpPower", CurrentValue = false,
    Callback = function(v)
        jumpPowerEnabled = v
        if not v then local h = findHum(); if h then h.JumpPower = 50 end end
    end })
PlayerTab:Slider({ Name = "JumpPower Value",
    Min = 50, Max = 300, CurrentValue = 60, Increment = 1,
    Callback = function(v) S.jumpPowerValue = v end })
PlayerTab:Toggle({ Name = "Infinite Jump (hold Space)", CurrentValue = false,
    Callback = function(v) S.infiniteJumpEnabled = v end })
PlayerTab:Toggle({ Name = "Smooth Fly (WASD)", CurrentValue = false,
    Callback = function(v)
        flyEnabled = v
        if v then startFly() else stopFly() end
        Notify("Fly", v and "Enabled" or "Disabled")
    end })
PlayerTab:Slider({ Name = "Fly Speed",
    Min = 20, Max = 250, CurrentValue = 60, Increment = 1,
    Callback = function(v) S.flySpeed = v end })
PlayerTab:Section("Utility")
PlayerTab:Toggle({ Name = "No Knockback", CurrentValue = true,
    Callback = function(v)
        pcall(function() SetNoKnockback(v) end)
        Notify("No Knockback", v and "ON" or "OFF")
    end })
PlayerTab:Toggle({ Name = "Anti-AFK", CurrentValue = false,
    Callback = function(v) SetAntiAFK(v) end })
PlayerTab:Toggle({ Name = "Fullbright", CurrentValue = false,
    Callback = function(v) SetFullbright(v) end })
PlayerTab:Button({ Name = "Delete Pet Renders (FPS)",
    Callback = function()
        local n = DeleteOwnPetRenders()
        Notify("FPS", "Removed " .. tostring(n) .. " models")
    end })
PlayerTab:Dropdown({ Name = "Select Area", Options = areaKeys, CurrentOption = "Forest",
    Callback = function(v) selectedAreaTp = v end })
PlayerTab:Button({ Name = "Travel to Area",
    Callback = function()
        local pos = AREA_COORDINATES[selectedAreaTp]
        if pos then
            Notify("Travel", "Traveling to " .. selectedAreaTp)
            task.spawn(function() MoveToPoint(pos, farmSpeed, false) end)
        end
    end })
PlayerTab:Section("Performance")
PlayerTab:Toggle({ Name = "Reduce Map (Light)",
    Desc = "Disable shadows & particles. Guards & Eggs are PROTECTED. Reversible",
    CurrentValue = false,
    Callback = function(v)
        S.reduceMap = v
        ApplyReduceMap(v)
        Notify("Reduce Map", v and "ON (guards & eggs safe)" or "OFF")
    end })
PlayerTab:Toggle({ Name = "FPS Governor",
    Desc = "Flatten world, kill particles, disable shadows",
    CurrentValue = false,
    Callback = function(v)
        fpsBoost = v
        ApplyFPSBoost(v)
        Notify("FPS", v and "Governor ON" or "Governor OFF")
    end })
PlayerTab:Button({ Name = "Purge All Visuals Now",
    Desc = "Purge all pets/eggs/fences/particles",
    Callback = function()
        S.hideAllPets, S.hideAllEggs, S.hidePlotVisuals = true, true, true
        ApplyHideAllPets(true)
        Notify("FPS", "All visuals purged!")
    end })
PlayerTab:Toggle({ Name = "Hide All Pets",
    Desc = "Hide pet models on plot",
    CurrentValue = false,
    Callback = function(v)
        hideAllPets = v
        if v then ApplyHideAllPets(true) else RestoreCache(_savedPets) end
    end })
PlayerTab:Toggle({ Name = "Hide All Placed Eggs",
    Desc = "Hide eggs that are already placed",
    CurrentValue = false,
    Callback = function(v)
        hideAllEggs = v
        if v then
            for _, c in ipairs(Workspace:GetChildren()) do
                if c.Name == "PlacedEggRenders" then HideDescendants(c, _savedEggs) end
            end
        else
            RestoreCache(_savedEggs)
        end
    end })
PlayerTab:Toggle({ Name = "Hide Plot Visuals & Fences",
    Desc = "Hide fences, decorations, plot signs",
    CurrentValue = false,
    Callback = function(v)
        hidePlotVisuals = v
        if v then
            local plots = Workspace:FindFirstChild("Plots")
            if plots then HideDescendants(plots, _savedPlot) end
        else
            RestoreCache(_savedPlot)
        end
    end })

-- ==========================================================
-- MISC
-- ==========================================================
MiscTab:Section("ESP")
MiscTab:Toggle({ Name = "Enable Egg ESP", CurrentValue = false,
    Callback = function(v) esp.enabled = v; esp.eggs = v end })
MiscTab:Toggle({ Name = "Rare Eggs Only", CurrentValue = false,
    Callback = function(v) esp.rareEggsOnly = v end })
MiscTab:Toggle({ Name = "Trap ESP", CurrentValue = false,
    Callback = function(v) esp.traps = v end })
MiscTab:Toggle({ Name = "Player ESP", CurrentValue = false,
    Callback = function(v) esp.players = v end })
MiscTab:Slider({ Name = "Max ESP Distance",
    Min = 50, Max = 2000, CurrentValue = 800, Increment = 50,
    Callback = function(v) esp.maxDistance = v end })
MiscTab:Section("Server")
MiscTab:Button({
    Name    = "Server Hop (Low Pop)",
    Callback = function()
        task.spawn(function()
            Notify("Server Hop", "Searching...", 2)
            local placeId = game.PlaceId
            local currentJobId = game.JobId
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if not req then Notify("Server Hop", "Executor not supported", 3); return end
            local ok, result = pcall(function()
                local url = string.format(
                    "https://games.roblox.com/v1/games/%d/servers/0?sortOrder=Asc&limit=100", placeId)
                local response = req({ Url = url, Method = "GET" })
                return game:GetService("HttpService"):JSONDecode(response.Body)
            end)
            if ok and result and result.data then
                local valid = {}
                for _, server in ipairs(result.data) do
                    if server.id ~= currentJobId and server.playing < server.maxPlayers and server.playing > 0 then
                        table.insert(valid, server)
                    end
                end
                table.sort(valid, function(a, b) return a.playing < b.playing end)
                if #valid > 0 then
                    Notify("Server Hop", "Hopping (" .. valid[1].playing .. " players)", 3)
                    TeleportService:TeleportToPlaceInstance(placeId, valid[1].id, LP)
                else
                    Notify("Server Hop", "No server found", 3)
                end
            else
                Notify("Server Hop", "Failed to fetch servers", 3)
            end
        end)
    end,
})
MiscTab:Section("Script")
MiscTab:Button({
    Name = "Unload Script",
    Icon = "power",
    Callback = function()
        if HUB.Unload then pcall(HUB.Unload) end
    end,
})

-- ============================================================
-- END
-- ============================================================
print("[Ascend] Loaded!")
