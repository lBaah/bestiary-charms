--[[
	This was developed by Ricardo Monteiro and lBaah
	Published by lBaah from www.demona.online.
	Demona Online is developed by Ricardo Monteiro and lBaah.
]]

CharmPackets = {
    SendData = 0xd8,
	RequestData = 0xe4
}

CharmsData = {
    {name = "Wound", id = "0", points = "1000", damageType = COMBAT_PHYSICALDAMAGE, message = "You wounded the monster.", type = "Offensive", desc = "Wounds the creature and deals 5% of its initial hit points as Physical Damage."},
	{name = "Enflame", id = "1", points = "1000", damageType = COMBAT_FIREDAMAGE, message = "You enflame the monster.", type = "Offensive", desc = "Burns the creature and deals 5% of its initial hit points as Fire Damage."},
    {name = "Poison", id = "2", points = "1000", damageType = COMBAT_EARTHDAMAGE, message = "You poisoned the monster.", type = "Offensive", desc = "Poisons the creature and deals 5% of its initial hit points as Earth Damage."},
	{name = "Freeze", id = "3", points = "1000", damageType = COMBAT_ICEDAMAGE, message = "You frozen the monster.", type = "Offensive", desc = "Freezes the creature and deals 5% of its initial hit points as Ice Damage."},
    {name = "Zap", id = "4", points = "1000", damageType = COMBAT_ENERGYDAMAGE, message = "You eletrocuted the monster.", type = "Offensive", desc = "Electrifies the creature and deals 5% of its initial hit points as Energy Damage."},
    {name = "Curse", id = "5", points = "1000", damageType = COMBAT_DEATHDAMAGE, message = "You curse the monster.", type = "Offensive", desc = "Curses the creature and deals 5% of its initial hit points as Death Damage."},
    -- criple desativado
    {name = "Cripple", id = "6", points = "99999", type = "Offensive", desc = "Cripples the creature with a certain chance and paralyses it for 10 seconds."}, 
    {name = "Parry", id = "7", points = "1000", message = "You parry the attack.", type = "Defensive", desc = "Any damage taken is reflected to the aggressor with a certain chance."},    
    {name = "Dodge", id = "8", points = "1000", message = "You dodged the attack.", type = "Defensive", desc = "Dodges an attack without taking any damage at all."},
    {name = "Adrenaline Burst", id = "9", points = "1000", message = "Your movements where bursted.", type = "Defensive", desc = "Bursts of adrenaline enhance your reflexes with a certain chance after you get hit and let you move faster for 10 seconds."},
   	-- numb desativado
    {name = "Numb", id = "10", points = "99999", type = "Defensive", desc = "Numbs the creature with a certain chance after its attack and paralyses the creature for 10 seconds."},    
    {name = "Cleanse", id = "11", points = "1000", type = "Defensive", desc = "Cleanses you from within with a certain chance after you get hit and removes one random active negative status effect and temporarily makes you immune against it."},
    -- bless, scavenge, gut, low blow desativados
    {name = "Bless", id = "12", points = "99999", type = "Passive", desc = "Blesses you and reduces skill and xp loss by 3% when killed by the chosen creature."},    
    {name = "Scavenge", id = "13", points = "99999", type = "Passive", desc = "Enhances your chances to successfully skin/dust a skinnable/dustable creature."},
    {name = "Gut", id = "14", points = "99999", type = "Passive", desc = "Gutting the creature yields 10% more creature products."},
    {name = "Low Blow", id = "15", points = "99999", type = "Passive", desc = "Adds 3% critical hit chance to attacks with critical hit weapons."}
}

CharmsChances = {
	offensive = 5,
	defensive = 5,
}

CHARM_STORAGE_CONST = 61301000
CHARM_STORAGE_MONSTER = 61302000
CHARM_STORAGE_LOCKED_RUNE = 61303000

CHARMS_STORAGE_RUNE_COUNT = 61400000
CHARMS_STORAGE_CHARM_EXPANSION = 61401000

CHARM_RUNE_STORAGES = { -- quando houver algum monstro selecionado, essas storages recebem o raceId da criatura que está selecionada
	["Wound"] = 61304000, -- wound
	["Enflame"] = 61304001, -- enflame
	["Poison"] = 61304002, -- poison
	["Freeze"] = 61304003, -- freeze
	["Zap"] = 61304004, -- zap
	["Curse"] = 61304005, -- curse
	["Cripple"] = 61304006, -- cripple
	["Parry"] = 61304007, -- parry
	["Dodge"] = 61304008, -- dodge
	["Adrenaline Burst"] = 61304009, -- adrenaline
	["Numb"] = 61304010, -- numb
	["Cleanse"] = 61304011, -- cleanse
	["Bless"] = 61304012, -- bless
	["Scavenge"] = 61304013, -- scavenge
	["Gut"] = 61304014, -- gut
	["Low Blow"] = 61304015, -- low blow
}

CharmNames = {
	"Wound",
	"Enflame",
	"Poison", -- poison
	"Freeze", -- freeze
	"Zap", -- zap
	"Curse", -- curse
	"Cripple", -- cripple
	"Parry", -- parry
	"Dodge", -- dodge
	"Adrenaline Burst", -- adrenaline
	"Numb", -- numb
	"Cleanse", -- cleanse
	"Bless", -- bless
	"Scavenge", -- scavenge
	"Gut", -- gut
	"Low Blow", -- low blow
}


unlockCharm = function(playerId, charmId, lockCreature, raceId)
-- lBaah 
-- www.demona.online
	local player = Player(playerId)
	if not player then
		return true
	end
	local charmPointsBalance = player:getStorageValue(STORAGE_RANGE_BESTIARY_CHARM)
	if lockCreature == 0 then -- unlock charm rune
		for k, charms in pairs(CharmsData) do
			local charmCost = charms.points
			if tonumber(charms.id) == tonumber(charmId) and (tonumber(charmCost) < tonumber(charmPointsBalance)) then
				player:setStorageValue(CHARM_STORAGE_CONST + charmId, 1)
				charmPointsBalance = charmPointsBalance - tonumber(charmCost)
				player:setStorageValue(STORAGE_RANGE_BESTIARY_CHARM, charmPointsBalance)
			end
		end
	elseif lockCreature == 1 then -- set a creature
		if player:getStorageValue(CHARMS_STORAGE_RUNE_COUNT) <= 2 and not player:isPremium() then
			player:setStorageValue(CHARM_RUNE_STORAGES[CharmNames[charmId+1]], raceId)
			player:popupFYI("Creature has been set! Kill them all!\n\nYou are not a Premium player, so you benefit from up to 3 runes!\nCharm Expansion allow you to set creatures to all runes at once!")
			print("charm count <= 3 and not premium " .. CharmNames[charmId+1])
		elseif player:getStorageValue(CHARMS_STORAGE_CHARM_EXPANSION) > 0 and player:isPremium() then
			player:setStorageValue(CHARM_RUNE_STORAGES[CharmNames[charmId+1]], raceId)
			player:popupFYI("Creature has been set! Kill them all!")
			print("charm expansion and premium " .. CharmNames[charmId+1])
		else 
			player:popupFYI("You have no charm slots available.")
		end
		if player:getStorageValue(CHARMS_STORAGE_RUNE_COUNT) < 0 then
			player:setStorageValue(CHARMS_STORAGE_RUNE_COUNT, 1)
		else
			player:setStorageValue(CHARMS_STORAGE_RUNE_COUNT, player:getStorageValue(CHARMS_STORAGE_RUNE_COUNT)+1)
		end
	elseif lockCreature == 2 and player:removeMoneyNpc(player:getLevel()*100) then -- remove a creature
		player:setStorageValue(CHARM_RUNE_STORAGES[CharmNames[charmId+1]], 0) 
		player:setStorageValue(CHARMS_STORAGE_RUNE_COUNT, player:getStorageValue(CHARMS_STORAGE_RUNE_COUNT)-1)
		player:popupFYI("Creature was removed.")
	else
		player:popupFYI("You have not enough gold!")
	end
end

getUnlockedCharm = function(playerId, charmId)
-- lBaah 
-- www.demona.online
	local player = Player(playerId)
	if not player then
		return true
	end
	if player:getStorageValue(CHARM_STORAGE_CONST + charmId) == 1 then
		return true -- desbloqueado
	else
		return false -- bloqueado
	end	
end

sendCharm = function(playerId, msg)
-- lBaah 
-- www.demona.online
    local player = Player(playerId)
    if not player then
        return true
    end
    local removeRuneCost = player:getLevel(playerId)*100
    if player:getStorageValue(STORAGE_RANGE_BESTIARY_CHARM) < 0 then
        totalCharms = 0
    elseif player:getStorageValue(STORAGE_RANGE_BESTIARY_CHARM) >= 1 then
        totalCharms = player:getStorageValue(STORAGE_RANGE_BESTIARY_CHARM)
    end    
	
    local msg = NetworkMessage()
    msg:addByte(CharmPackets.SendData)
    
    msg:addU32(totalCharms) -- saldão de charms
    msg:addByte(#CharmsData) -- tamanho do array
    
    for k, charms in ipairs(CharmsData) do
	local charmId = k
	msg:addByte(charms.id) -- id
		if getUnlockedCharm(player, charms.id) then
			--msg:addByte(charms.id) -- id
			msg:addString(charms.name) -- nome
			msg:addString(charms.desc) -- descrição
			msg:addByte(0x00) -- unknown (testado com 0 e 1)
			msg:addU16(charms.points) -- pontos necessários para desbloqueio
			
			--[[charm aberto/fechado]]--
			msg:addByte(0x01) -- desbloqueado 1 / bloqueado 0

			if player:getStorageValue(CHARM_RUNE_STORAGES[charms.name]) > 0 then
				msg:addByte(0x01) -- indica se há criatura selecionada
				msg:addU16(player:getStorageValue(CHARM_RUNE_STORAGES[charms.name])) -- passando o raceid da criatura selecionada
				msg:addU32(removeRuneCost) -- valor para remover a runa
			else
				msg:addByte(0x00)
			end
		else
			msg:addString(charms.name) -- nome
			msg:addString(charms.desc) -- descrição
			msg:addByte(0x00) -- unknown (testado com 0 e 1)
			msg:addU16(charms.points) -- pontos necessários para desbloqueio
			msg:addByte(0x00) -- bloqueado
			msg:addByte(0x00) -- nenhum criatura selecionada
		end
	end
    msg:addByte(0x4) -- constante?
    
	-- Enviar lista de mosntros desbloqueados do bestiário
	local unlocked = {}

	-- refatorar
	for raceid, monsters in pairs(BestiaryMonsters) do
        if player:getStorageValue(STORAGE_RANGE_BESTIARY_COUNT + raceid) >= monsters.toKill then
			if player:getStorageValue(CHARM_RUNE_STORAGES["Wound"]) ~= raceid then
				if player:getStorageValue(CHARM_RUNE_STORAGES["Enflame"]) ~= raceid then
					if player:getStorageValue(CHARM_RUNE_STORAGES["Poison"]) ~= raceid then
						if player:getStorageValue(CHARM_RUNE_STORAGES["Freeze"]) ~= raceid then
							if player:getStorageValue(CHARM_RUNE_STORAGES["Zap"]) ~= raceid then
								if player:getStorageValue(CHARM_RUNE_STORAGES["Curse"]) ~= raceid then
									if player:getStorageValue(CHARM_RUNE_STORAGES["Cripple"]) ~= raceid then
										if player:getStorageValue(CHARM_RUNE_STORAGES["Parry"]) ~= raceid then
											if player:getStorageValue(CHARM_RUNE_STORAGES["Dodge"]) ~= raceid then
												if player:getStorageValue(CHARM_RUNE_STORAGES["Adrenaline Burst"]) ~= raceid then
													if player:getStorageValue(CHARM_RUNE_STORAGES["Numb"]) ~= raceid then
														if player:getStorageValue(CHARM_RUNE_STORAGES["Cleanse"]) ~= raceid then
															if player:getStorageValue(CHARM_RUNE_STORAGES["Bless"]) ~= raceid then
																if player:getStorageValue(CHARM_RUNE_STORAGES["Scavenge"]) ~= raceid then
																	if player:getStorageValue(CHARM_RUNE_STORAGES["Gut"]) ~= raceid then
																		if player:getStorageValue(CHARM_RUNE_STORAGES["Low Blow"]) ~= raceid then
																			table.insert(unlocked, raceid)
																		end
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
    end
    msg:addU16(#unlocked)
	for i = 1, #unlocked do
		msg:addU16(unlocked[i]) -- enviar race ids desbloqueados para lista de monstros do charm
	end
    msg:sendToPlayer(player)
end