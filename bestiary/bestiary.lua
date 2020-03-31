--[[
    This was developed by gpedro, Flyckks, Ricardo Monteiro and lBaah
    Published by lBaah from www.demona.online.
    Demona Online is developed by Ricardo Monteiro and lBaah.
]]

Bestiary = {}

dofile('data/modules/scripts/bestiary/assets.lua')

STORAGE_RANGE_BESTIARY_COUNT = 6520000
STORAGE_RANGE_BESTIARY_STAGE = 6520000
STORAGE_RANGE_BESTIARY_CHARM = 6130000


Bestiary.S_Packets = {
    SendBestiaryData = 0xd5,
    SendBestiaryOverview = 0xd6,
    SendBestiaryMonsterData = 0xd7
}

Bestiary.C_Packets = {
    RequestBestiaryData = 0xe1,
    RequestBestiaryOverview = 0xe2,
    RequestBestiaryMonsterData = 0xe3,
    RequestCharmUnlock = 0xe4
}

Bestiary.findRaceByName = function(race)
    local races = Bestiary.Races
    for i = 1, #races do
        if (races[i].name == race) then
            return races[i]
        end
    end
    return false
end

Bestiary.getRaceByMonsterId = function(monsterId)
    local races = Bestiary.Races
    for i = 1, #races do
        if table.contains(races[i].monsters, monsterId) then
            return races[i].name
        end
    end
    return false
end

Bestiary.sendCreatures = function (playerId, msg)
    local player = Player(playerId)
    if not player then
        return true
    end

    local unknown = msg:getByte()
    local raceName = msg:getString()

    local race = Bestiary.findRaceByName(raceName)
    if not race then
        print("> [Bestiary]: race was not found")
        return true
    end

    local msg = NetworkMessage()
    msg:addByte(Bestiary.S_Packets.SendBestiaryOverview)
    msg:addString(race.name) -- race name
    msg:addU16(#race.monsters) -- monster count

    for i = 1, #race.monsters do
		msg:addU16(race.monsters[i]) -- monster raceid
        if player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + race.monsters[i]) > 0 and player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + race.monsters[i]) < BestiaryMonsters[race.monsters[i]].FirstUnlock then
            msg:addU16(1) -- monstro 0/3
		elseif player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + race.monsters[i]) >= BestiaryMonsters[race.monsters[i]].FirstUnlock and player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + race.monsters[i]) < BestiaryMonsters[race.monsters[i]].SecondUnlock then
            msg:addU16(2) -- monstro desbloqueado 1/3
		elseif player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + race.monsters[i]) >= BestiaryMonsters[race.monsters[i]].SecondUnlock and player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + race.monsters[i]) < BestiaryMonsters[race.monsters[i]].toKill then
            msg:addU16(3) -- monstro desbloqueado 2/3 
		elseif player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + race.monsters[i]) >= BestiaryMonsters[race.monsters[i]].toKill then
            msg:addU16(4) -- monstro desbloqueado 3/3
        else
			msg:addByte(0x00) -- desabilitado
		end
    end

    msg:sendToPlayer(player)
end

Bestiary.sendRaces = function(playerId, msg)
    local player = Player(playerId)
    if not player then
        return true
    end
    local msg = NetworkMessage()
    msg:addByte(Bestiary.S_Packets.SendBestiaryData)
    msg:addU16(#Bestiary.Races)
	
    for k, race in ipairs(Bestiary.Races) do
        msg:addString(race.name)
        msg:addU16(#race.monsters)
		msg:addU16(math.random(2, 6)) -- current
    end
    msg:sendToPlayer(player)
end


    local player = Player(playerId)
function Player.getBestiaryCount(self, id)
    return math.max(player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + monsterId, 0))
end


Bestiary.sendMonsterData = function(playerId, msg)
    local player = Player(playerId)
    if not player then
        return true
    end

    local monsterId = msg:getU16()
    local race = Bestiary.getRaceByMonsterId(monsterId)
    if not race then
        print("> [Bestiary]: race was not found")
        return true
    end

    local bestiaryMonster = BestiaryMonsters[monsterId]
    if not bestiaryMonster then
        print("> [Bestiary]: monster was not found")
        return true
    end

    local monster = MonsterType(bestiaryMonster.name)
    local monsterCharm = MonsterType(bestiaryMonster.CharmsPoints)
	local monsterName = monster:getName()
    if not monster then
        print("> [Bestiary]: monstertype was not found")
        return true
    end

    -- TODO
    local firstMaxKill = bestiaryMonster.FirstUnlock
    local secondMaxKill = bestiaryMonster.SecondUnlock
    local thirdMaxKill = bestiaryMonster.toKill
    local killCounter = 1

    local msg = NetworkMessage()
    msg:addByte(Bestiary.S_Packets.SendBestiaryMonsterData)
    msg:addU16(monsterId)
    msg:addString(race)

    local currentLevel = 1
    if player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + monsterId) < firstMaxKill then
        currentLevel = 1
    elseif player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + monsterId) < secondMaxKill then
        currentLevel = 2
    elseif player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + monsterId) < thirdMaxKill then
        currentLevel = 3
    elseif player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + monsterId) > thirdMaxKill then
        currentLevel = 4
    end    



    local killCoutner = 0
    if player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + monsterId) > 0 then
        killCoutner = player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + monsterId)
    end    

    msg:addByte(currentLevel) 
    msg:addU32(killCoutner) -- kill count
    msg:addU16(firstMaxKill) -- max kill first phase
    msg:addU16(secondMaxKill)  -- max kill second phase
    msg:addU16(thirdMaxKill)  -- max kill third phase
    msg:addByte(bestiaryMonster.Stars)  -- Difficult
    msg:addByte(1) -- TODO: occourrence

    local lootSize = #monster:getLoot()
    msg:addByte(lootSize)

    if lootSize > 0 then
        local loots = monster:getLoot()
        for i = 1, lootSize do
            local loot = loots[i]
            local item = ItemType(loot.itemId)
            if item then
                local type = 0
                local difficult = Bestiary.calculateDifficult(loot.chance)

                if killCounter == 0 then
                    msg:addU16(0x00)
                    msg:addByte(0x0) -- 0 = normal loot   /  1 = special event loot
                    msg:addByte(difficult)
                else 
                    msg:addItemId(loot.itemId)
                    msg:addByte(difficult)
                    msg:addByte(0x0) -- 0 = normal loot   /  1 = special event loot
                    msg:addString(item:getName())
                    msg:addByte(item:isStackable() and 0x1 or 0x0)
                end 
            end
        end
    end

    if currentLevel > 1 then
        msg:addU16(bestiaryMonster.CharmsPoints)
        local attackMode = 0
        if monster:isPassive() then
            attackMode = 2
        elseif monster:targetDistance() then
            attackMode = 1
        end

        msg:addByte(attackMode) -- 0 = meele / 1 = distance / 2 = doenst attack
        msg:addByte(0x2) -- flag for cast spells
        msg:addU32(monster:maxHealth())
        msg:addU32(monster:experience())
        msg:addU16(monster:baseSpeed())
        msg:addU16(monster:armor())
    end

    if currentLevel > 2 then
        local monsterElements = Bestiary.getMonsterElements(monster)

        -- elements size
        msg:addByte(#monsterElements)
        local i = 0
        for _, value in pairs(monsterElements) do
            -- elements id
            msg:addByte(i)

            -- element percent
            msg:addU16(value)

            i = i + 1
        end
        
        msg:addU16(1) -- enable or disable description
        msg:addString(""..monster:getName().."")
    end

    if currentLevel > 3 then
        -- charm things
        msg:addByte(0)
        msg:addByte(0)
    end

    msg:sendToPlayer(player)
end

Bestiary.getMonsterElements = function (monster) 
    local elements = monster:getElementList()
    local monsterElements = Bestiary.getDefaultElements()

    for element, value in pairs(elements) do
        if monsterElements[element] then
            local percent = 100 + tonumber(value)
            monsterElements[element] = percent
        end
    end

    return monsterElements
end

Bestiary.calculateDifficult = function (chance)
    chance = chance / 1000

    if chance < 0.2 then
       return 4
    end 

    if chance < 1 then
       return 3
    end 

    if chance < 5 then
       return 2
    end 

    if chance < 25 then
        return 1
    end

    return 0
end

Bestiary.createEmptyLootSlot = function (msg, difficult, type)
    msg:addU16(0x0)
    msg:addByte(difficult)
    msg:addByte(type)
end

Bestiary.createLootSlot = function (msg, itemId, itemName, difficult, type, isStackable)
    msg:addItemId(itemId)
    msg:addByte(difficult)
    msg:addString(itemName)
    msg:addByte(type)
    msg:addByte(isStackable and 0x0 or 0x1)
end

function onRecvbyte(player, msg, byte)
    if (byte == Bestiary.C_Packets.RequestBestiaryData) then
        Bestiary.sendRaces(player:getId())
        
        sendCharm(player:getId())
    elseif (byte == Bestiary.C_Packets.RequestBestiaryOverview) then
        Bestiary.sendCreatures(player:getId(), msg)
	elseif (byte == Bestiary.C_Packets.RequestCharmUnlock) then
		local charmId = msg:getByte()
		local lockMonster = msg:getByte()
		local raceId = msg:getU16()
        unlockCharm(player, charmId, lockMonster, raceId)
		sendCharm(player:getId())
    elseif (byte == Bestiary.C_Packets.RequestBestiaryMonsterData) then
        Bestiary.sendMonsterData(player:getId(), msg)
    end
end


dofile('data/modules/scripts/bestiary/charms.lua')