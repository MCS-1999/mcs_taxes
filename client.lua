VLRP = Settings.Main.Core
PlayerData = nil
local hasPaid = false


RegisterNetEvent('VLRP:Client:OnPlayerLoaded', function()
    PlayerData = VLRP.Functions.GetPlayerData()
    Init()
end)

Init = function()
    print(PlayerData.citizenid)
    VLRP.Functions.TriggerCallback('mcs_taxes:server:hasPaid', function(action)
        --print('[Debug] Client Ready.')
        if action ~= 'InProgress' then
            return print('[TaxSeason]: ', action)
        end
        --print(action)
    end, PlayerData.citizenid)
end