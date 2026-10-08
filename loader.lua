-- ================================================
--   Universal Loader
--   GitHub: https://github.com/USERNAME/REPO
-- ================================================

local RAW = "https://raw.githubusercontent.com/mingaja/ascend-hub/main"

-- ================================================
--   DAFTAR GAME (tambah di sini terus)
--   Format: ["PlaceId"] = "path/ke/script.lua"
-- ================================================

local GAMES = {
    ["93978595733734"] = "games/vd/main.lua",

    -- tambah game baru di sini:
    -- ["PLACEID"] = "games/NAMA/main.lua",
}

-- ================================================
--   LOADER ENGINE (gak perlu diubah)
-- ================================================

local function fetch(url)
    local ok, res = pcall(game.HttpGet, game, url, true)
    if ok and res and res ~= "" and not res:find("^404") then
        return res
    end
    return nil
end

local function run(code)
    local fn, err = loadstring(code)
    if fn then
        local ok, runErr = pcall(fn)
        if not ok then
            warn("[Loader] Runtime error: " .. tostring(runErr))
        end
    else
        warn("[Loader] Compile error: " .. tostring(err))
    end
end

-- ================================================
--   MAIN
-- ================================================

local placeId = tostring(game.PlaceId)
local scriptPath = GAMES[placeId]

if scriptPath then
    print("[Loader] ✅ " .. tostring(game.Name) .. " | Fetching script...")
    local code = fetch(RAW .. "/" .. scriptPath)
    if code then
        print("[Loader] Running...")
        run(code)
    else
        warn("[Loader] ❌ Gagal fetch script. Cek koneksi atau path di GAMES table.")
    end
else
    warn("[Loader] ❌ Game belum didukung.")
    warn("[Loader] PlaceId: " .. placeId)
    warn("[Loader] Game: " .. tostring(game.Name))
end
