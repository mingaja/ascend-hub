local scripts = {
    [1234567890] = "https://raw.githubusercontent.com/USERNAME/REPO/refs/heads/main/GameA.lua",
    [9876543210] = "https://raw.githubusercontent.com/USERNAME/REPO/refs/heads/main/GameB.lua",
}

local url = scripts[game.PlaceId]

if url then
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("Gagal load script: " .. tostring(err))
    end
else
    warn("Game ini belum didukung. PlaceId: " .. game.PlaceId)
end
