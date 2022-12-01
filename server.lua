VLRP = Settings.Main.Core

local hasPaid = {}
local CollectedTax = 0
local Day = os.date("%A")
local Hour = tonumber(os.date("%H"))
local Min = tonumber(os.date("%M"))
local Month = os.date("%B")
local Time = Settings.Tax['TaxSeason']
local TaxStatus = 'Loading...'

-- print('^2[Variable Check] ^7', Day, Hour, Min, Month)

-- Handles Tax Seasons
Citizen.CreateThread(function()
    while TaxStatus == 'Loading...' do
        for k, v in pairs(Time) do
            if not k then
                print('[Debug] No time specified in Settings.Tax.TaxSeason, please fill in a time')
            end

            if v.Day == 'Everyday' then
                v.Day = Day
            end

            if v and (v.Day == Day) then
                TaxStatus = 'InProgress' -- Any Payments made are on time
                Log(nil, nil, nil, 'Tax Season Live.', 'Tax Season', true, 16776960)
            elseif v and (v.Day ~= Day) then
                TaxStatus = 'Approaching' -- Taxes Approaching
                -- Log(nil, nil, nil, 'Tax Season Near. \n\n**'..v.Day..'**', 'Tax Season', true, 3447003)
            end
        end
        Wait(0)
    end
end)

VLRP.Functions.CreateCallback('mcs_taxes:server:hasPaid', function(source, cb, CID)
    if not CID then
        return print('[Debug] Invalid CID Passed in Callback')
    end
    print(CID)
    local Player = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {CID})
    if not Player then
        return print('[Debug] Database error cannot find player in players table.', CID)
    end
    local TaxInfo = {}

    local taxPayer = VLRP.Functions.GetPlayerByCitizenId(CID)

    for _, data in pairs(Player) do
        for k, v in pairs(data) do
            if k == 'paidTaxes' then
                print(v)
                if v == 1 then
                    TaxInfo.HasPaid = true
                else
                    TaxInfo.HasPaid = false
                end
            elseif k == 'evadedTaxes' then
                if v > 0 then
                    TaxInfo.OwesTaxes = v
                else
                    TaxInfo.OwesTaxes = 0
                end
                -- print('Player Owes $'..formatNumber(v)..' In Taxes')
            end
        end
    end

    if not TaxInfo then
        return print('Error Finding Taxes')
    end

    ---print(CID, TaxStatus, tostring(TaxInfo.HasPaid), TaxInfo.OwesTaxes)
    if TaxStatus == 'InProgress' then
        if TaxInfo.HasPaid then
            cb(TaxStatus, true)
        else
            cb(TaxStatus, false)
            PayTaxes(CID, 'Normal')
        end
    elseif TaxStatus == 'Approaching' and TaxInfo.HasPaid then -- Reset Tax Status on new cycle
        ResetTaxStatus(CID)
        cb(TaxStatus)
    end
end)

function PayTaxes(id, status, owed)
    if not id then
        return print('[Debug] Invalid CitizendID Passed.')
    end

    local Player = VLRP.Functions.GetPlayerByCitizenId(id)
    if not Player then
        return print('[Debug] Player is not online we will get them next login.', id)
    end

    local Bank = Player.PlayerData.money.bank
    local Bracket = GetBracket(Bank)
    if not Bracket then
        return print('Failed to get Bracket.')
    end

    local LateFee = owed or 0
    local BracketData = Settings.Brackets[Bracket]
    if not BracketData then
        return print('Failed to get Bracket Information.')
    end

    local Tax = VLRP.Shared.Round(Bank * BracketData.hit + LateFee)

    if Bank >= Tax then
        Player.Functions.RemoveMoney('bank', Tax)
        Settings.Functions.Notify('You have paid $' .. formatNumber(Tax) .. ' in taxes.', 'Taxes', 10000, 'server',
            Player.PlayerData.source)
        MySQL.Async.execute(
            "UPDATE `players` SET `paidTaxes`= @status, `evadedTaxes` = @evadedTaxes WHERE `citizenid` = @cid", {
                ["@status"] = 1,
                ["@cid"] = id,
                ['@evadedTaxes'] = 0
            }, function()
            end)
        hasPaid[id] = true
        Log(id, Bracket, Tax, 'A Player has paid taxes', 'Taxes', false, 2895667)
        CollectedTax = CollectedTax + Tax
        PayComany()
    else
        Settings.Functions.Notify('You have missed $' .. Tax ..
                                      ' in taxes, please pay at your city hall or face tax evasion.', 'Taxes', 10000,
            'server', Player.PlayerData.source)
        MySQL.Async.execute(
            "UPDATE `players` SET `paidTaxes`= @status, `evadedTaxes` = @evadedTaxes WHERE `citizenid` = @cid", {
                ["@status"] = 1,
                ["@cid"] = id,
                ['@evadedTaxes'] = Tax
            }, function()
            end)
    end
end

GetBracket = function(Amount)
    for bracket, info in pairs(Settings.Brackets) do
        if info.min < Amount and info.max > Amount then
            return bracket, Settings.Brackets[bracket]
        end
    end
end
exports('GetBracket', GetBracket)

GetTaxSeason = function()
    return TaxStatus
end
exports('GetTaxSeason', GetTaxSeason)

ResetTaxStatus = function(id)
    print('[Reset Called] ', id)
    if not id then
        print('[Debug] Invalid CitizenId Passed into reset')
    end

    print('[Reset Called] ', id)
    MySQL.Async.execute("UPDATE `players` SET `paidTaxes`= @status WHERE `citizenid` = @cid", {
        ["@status"] = 0,
        ["@cid"] = id
    }, function()
    end)
end

Log = function(id, bracket, amount, context, header, status, color)
    print('Log Called')
    local embedData = {}

    if status then
        embedData = {{
            ['title'] = header or 'Taxes',
            ['color'] = color or 1752220,
            ['footer'] = {
                ['text'] = os.date('%c')
            },
            ['description'] = context,
            ['author'] = {
                ['name'] = Settings.Main.ServerName,
                ['icon_url'] = Settings.Main.ServerLogo
            },
            ['fields'] = {}
        }}
    else
        local Player = VLRP.Functions.GetPlayerByCitizenId(id)
        if not Player then
            return print('[Debug] Invalid CitizenId inside log function.')
        end
        embedData = {{
            ['title'] = header or 'Taxes',
            ['color'] = color or 1752220,
            ['footer'] = {
                ['text'] = os.date('%c')
            },
            ['description'] = context,
            ['author'] = {
                ['name'] = Settings.Main.ServerName,
                ['icon_url'] = Settings.Main.ServerLogo
            },
            ['fields'] = {{
                ['name'] = '**Citizen Id**',
                ['value'] = id,
                ['inline'] = false
            }, {
                ['name'] = '**Bracket**',
                ['value'] = bracket,
                ['inline'] = false
            }, {
                ['name'] = '**Taxes Paid**',
                ['value'] = '$' .. formatNumber(amount),
                ['inline'] = false
            }}
        }}
    end

    PerformHttpRequest(Settings.Main.Webhook, function()
    end, 'POST', json.encode({
        username = 'MCS Taxes 1.0.0',
        embeds = embedData
    }), {
        ['Content-Type'] = 'application/json'
    })
end

PayComany = function()
    for company, data in pairs(Settings.Tax.Funds) do
        exports[Settings.Main.Naming.Scripts .. 'management']:AddMoney(company, (data.take * CollectedTax))
        print(company .. ' Was Paid ' .. CollectedTax)
    end
    CollectedTax = 0
end

formatNumber = function(n)
    n = tostring(n)
    return n:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function get_timezone_offset(ts)
    local utcdate = os.date("!*t", ts)
    local localdate = os.date("*t", ts)
    localdate.isdst = false -- this is the trick
    return os.difftime(os.time(localdate), os.time(utcdate))
end

---------------------------------------------------- Debug
RegisterCommand('GetTaxSeason', function()
    return print(GetTaxSeason())
end, false)

RegisterCommand('ForceTaxes', function()
    --
end, true)
