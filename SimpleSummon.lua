-- SimpleSummon.lua

-- Verifica si estas en raid
local function IsInRaidGroup()
    return GetNumRaidMembers() > 0
end

-- Cuenta los fragmentos de alma en Vanilla (solo uno por stack)
local function GetSoulShardCount()
    local count = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink and string.find(itemLink, "Soul Shard") then
                local _, stackCount = GetContainerItemInfo(bag, slot)
                count = count + (stackCount or 1) -- Suma la cantidad en el stack (max 3 en Turtle)
            end
        end
    end
    return count
end

-- Funcion principal
local function SimpleSummon(targetName)
    if not targetName or targetName == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccff[SimpleSummon]|r Debes seleccionar un jugador o escribir su nombre: /ss NombreDelJugador")
        return
    end

    if not (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[SimpleSummon]|r No estas en grupo.")
        return
    end
    
    local zone = GetZoneText()
    local subZone = GetSubZoneText()

    local summZone
    if subZone and subZone ~= "" and subZone ~= zone then
        summZone = subZone .. ", " .. zone
    else
        summZone = zone
    end

    local shards = GetSoulShardCount()

    if shards == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[SimpleSummon]|r No tienes Fragmentos de Alma.")
        return
    end

    -- Enviar mensajes
    SendChatMessage("Te estoy invocando a " .. summZone .. ". Acepta en 10 segundos.", "WHISPER", nil, targetName)

    local channel = IsInRaidGroup() and "RAID" or "PARTY"
    SendChatMessage("Invocando a <" .. targetName .. "> a " .. summZone  .. " (" .. shards .. " shards)", channel)

    -- Lanzar hechizo
    CastSpellByName("Ritual of Summoning")
end

-- Comando /ss
SLASH_SIMPLESUMMON1 = "/ss"
SlashCmdList["SIMPLESUMMON"] = function(msg)
    local name = msg
    if name == nil or name == "" then
        name = UnitName("target")
    end

    SimpleSummon(name)
end