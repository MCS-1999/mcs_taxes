# mcs_taxes
Taxes Script used in VacationLifeRP, and thought Id Share!

Features:
    - Webhook : Shows How much Players have paid in taxes and what bracket they are in.
    - Schedule : Currently you can schedule when to tax players by day, I removed by hour cause its easily avoidable if they catch on.
    - Brackets : Customizabale Brackets add as many or as little as you heart desires.
    - Society : Allow jobs to get paid a percentage of taxes paid to the city! them tax dollars be looking real nice in my new heat units.

Planned:
    - Property Taxing
    - Vehicle Taxing
    - IRS Pentalies (late fee wip)
    - and idk pretty basic ass script tbh
    - documents
    - tax returns



Instructions:
    - Run SQL
    - Setup Config
    - Run Script
    - Done.
    - Also Please dont rename script, it make me sad :c but you do have free will.

Exports:
   Server - exports['mcs_taxes']:GetTaxSeason() -- returns a string, and the current seasons which are 'approaching', 'InProgress'
   Server - exports['mcs_taxes']:GetBracket(amount) -- retunrs the expected bracket index, so you can pull the pracket info like tax rating, and min,max qulification.

   ```lua
   ['T5'] = {min = 1000, max = 10000, hit = 0.22, latefee = 100}, -- example bracket from config

   local bracket, data = exports['mcs_taxes']:GetBracket(10000)
    -- lets say the player has $10k in bank, we use this feature maybe as a banker or tax agent to determine what bracket they may qualify for and what are their requiremets

    print(bracket) -- shows what bracket the amount would qualify for

    -- now they want to know how much they need to stay in the bracket or how much their percentage is .

    local min, max, perc, fee = data.min, data.max, data.hit, data.latefee

   ```

About me: 
    - 23 Yrs Old
    - Studying Game Development and Full Stack Development
    - 7 Years Active Development on FiveM
    - 10 Years Playing FiveM
    - Im Cool, and so are you
    - I def wasted 100$ on MW2 xD


Ways to Support me:
    - https://ko-fi.com/vacationliferp
    - https://ko-fi.com/coldstix


Ways to connect with me:
    - MW2 Gaming Club : https://discord.gg/pcPKBPyxfG Invite some friends.
    - Twitch : https://www.twitch.tv/mcs_1999 I dont really stream, but hey one day right?



Why Free?

    - We all get better by learning from each other. use this to build off of and get better. and support is ALWAYS Free