Settings = {}
Settings.Functions = {}

Settings.Main = {
    ['Core'] = exports['qb-core']:GetCoreObject(), -- [List the export you use to gain access to your core api]
    ['Naming'] = { -- this is if you renamed your scripts from the original.
        ['Scripts'] = 'qb-', -- if you renamed your scripts then just change it to what they are names (i.e vlrp-, blrp-, etc)
        ['Core'] = 'QBCORE:' -- this is for when we use base framework events/callbacks (i.e QBCORE:Notfiy, VLRP:Notify, etc)
    },
    ['Webhook'] = 'enter_me_bro', -- Enter your webhook, this wont display any priate information, just shares who and how much someone paid, and their tax bracket -
    -- This can be used as a log or something to share with the community. its not needed.

    ['ServerName'] = 'VacationLifeRP',
    ['ServerLogo'] = 'https://cdn.discordapp.com/attachments/1013224502626353224/1013225048053661696/Asset_11jt.png'
}

Settings.Brackets =
    { -- Add as many as you would like, but min, max can not be greater then the next tier up. has to be greater then the one above it.
        --[[
        ['Example'] = {
            min = min_to_enter_bracket, 
            max = max_to_enter_bracket, 
            hit = percentage_of_bank_amount_to_take, 
            latefee = how_much_the_late_fee_will_be_when_paid_after_taxseason
        }, 
    ]]

        ['T1'] = {
            min = 0,
            max = 59999,
            hit = 0.05,
            latefee = 800
        },
        ['T2'] = {
            min = 60000,
            max = 120000,
            hit = 0.08,
            latefee = 8000
        },
        ['T3'] = {
            min = 129999,
            max = 650000,
            hit = 0.12,
            latefee = 80000
        },
        ['T4'] = {
            min = 659999,
            max = 3000000,
            hit = 0.17,
            latefee = 200000
        },
        ['T5'] = {
            min = 3999999,
            max = 9999999999999,
            hit = 0.22,
            latefee = 1000000
        }
    }

Settings.Tax = {
    ['taxOffline'] = true, -- if true, this will even tax offline bank accounts.
    ['TaxSeason'] = {{
        Day = 'Saturday'
    }, {
        Day = 'Monday'
    }, {
        Day = 'Tuesday'
    }, {
        Day = 'Thursday'
    } -- {Day = 'Everday', Hour = 15}, -- Allows for Everyday.
    }, -- so we use your machines local time to determine the day and hour we want to execute a tax collection.
    --[[ -- 
        Hour (0 to 23) --  Number 
        Day (Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
    ]] --
    ['Funds'] = { -- societies that get a percentage of the funds collected. this is out of 100% (i.e 1.0) (this will use vlrp-management)
        ['sahp'] = {
            label = 'San Andreas Highway Patrol',
            take = (math.random(50) / 100)
        },
        ['safr'] = {
            label = 'San Andreas Fire and Rescue',
            take = (math.random(50) / 100)
        },
        ['sadoj'] = {
            label = 'San Andreas Department of Justice',
            take = (math.random(50) / 100)
        },
        ['samdot'] = {
            label = 'San Andreas Department of Transportation',
            take = (math.random(50) / 100)
        }
    }
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| Functions
Settings.Functions.Notify =
    function(msg, header, length, cType, source) -- cType, is 'server' or 'client', if applicable, header can be ussed as a title.
        if cType == 'client' then
            return exports['vlrp-base']:Notify(msg, header, length)
        elseif cType == 'server' then
            if not source then
                return print('[Debug] - Invalid Source Passed, make sure the player id is online.')
            end
            return exports['vlrp-base']:Notify(source, msg, header, length)
        end
    end
