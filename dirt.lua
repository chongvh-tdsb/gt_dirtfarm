function punch(x,y)
    local packet = {}
    packet.type = 3
    packet.state = 2592
    packet.value = 18
    packet.px = x
    packet.py = y
    packet.x = (GetLocal().posX)
    packet.y = (GetLocal().posY)
    SendPacketRaw(false,packet)
end

function place(x,y,id)
    local packet = {}
    packet.type = 3
    packet.value = id
    packet.px = x
    packet.py = y
    packet.x = (GetLocal().posX)
    packet.y = (GetLocal().posY)
    sendPacketRaw(false,packet)
end

function collectRaw(object)
    local packet = {}
    packet.type = 11
    packet.value = object.id
    packet.x = object.posX
    packet.y = object.posY
    SendPacketRaw(false,packet)
end

function collect(range)
    for _,object in pairs(GetObjectList()) do
        if math.abs(GetLocal().posX - object.posX) <= (32 * range) and math.abs(GetLocal().posY - object.posY) < (32 * range) and findItem(object.itemid) < 200 then
            collectRaw(object)
            sleep(15)
        end
    end
end

function findItem(itemID)
    for _,item in pairs(GetInventory()) do
        if item.id == itemID then
            return item.amount
        end
    end
    return 0
end

function join(world,id)
    if getLocal() then
        while getLocal() do
            SendPacket(3, "action|quit_to_exit")
            Sleep(3500)
        end
    end
    if id ~= nil then
        while not getLocal() do
            SendPacket(3,"action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0")
            Sleep(4000)
            if getLocal() then
                if GetTile(math.floor(GetLocal().posX / 32),math.floor(GetLocal().posY / 32)).fg == 6 then
                    while GetTile(math.floor(GetLocal().posX / 32),math.floor(GetLocal().posY / 32)).fg == 6 do
                        SendPacket(3,"action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0")
                        Sleep(4000)
                    end
                end
            end
        end
    else
        while not getLocal() do
            SendPacket(3,"action|join_request\nname|"..world:upper().."\ninvitedWorld|0")
            Sleep(4000)
        end
    end
end

function clearSide()
    local function clearColumn(column)
        -- nothing to do on this side? skip without walking there at all
        local dirty = false
        for tiley = 24, 53 do
            if GetTile(column, tiley).bg ~= 0 or GetTile(column + 1, tiley).bg ~= 0 then
                dirty = true
                break
            end
        end
        if not dirty then
            return
        end

        for tiley = 24, 53 do
            if GetTile(column, tiley).bg ~= 0 or GetTile(column + 1, tiley).bg ~= 0 then
                FindPath(column, tiley - 1)
                Sleep(150)
                for _, c in ipairs({column, column + 1}) do
                    local tries = 0
                    while GetTile(c, tiley).bg ~= 0 and tries < 8 do
                        punch(c, tiley)
                        Sleep(190)
                        tries = tries + 1
                    end
                end
                collect(3)
            end
        end
    end
    clearColumn(0)
    clearColumn(98)
end
function clearDirt()
    for tiley = 27, 51, 12 do
        for tilex = 2, 97, 1 do
            if GetTile(tilex,tiley-2).bg ~= 0 or GetTile(tilex,tiley).bg ~= 0 or GetTile(tilex,tiley+2).bg ~= 0 then 
                FindPath(tilex - 1,tiley)
                Sleep(100)
                for i = -2, 2, 2 do
                    local tries = 0
                    while GetTile(tilex,tiley+i).bg ~= 0 and tries < 8 do
                        punch(tilex,tiley+i)
                        sleep(190)
                        tries = tries + 1
                    end
                    collect(3)
                end
            end
        end
        if (tiley + 6) ~= 57 then
            for tilex = 97, 2, -1 do
                if GetTile(tilex,tiley+4).bg ~= 0 or GetTile(tilex,tiley+6).bg ~= 0 or GetTile(tilex,tiley+8).bg ~= 0 then 
                    FindPath(tilex + 1,tiley + 6)
                    sleep(100)
                    for i = 4, 8, 2 do
                        local tries = 0
                        while GetTile(tilex,tiley+i).bg ~= 0 and tries < 8 do
                            punch(tilex,tiley+i)
                            sleep(190)
                            tries = tries + 1
                        end
                        collect(3)
                    end
                end
            end
        end
    end
end

function breakLava()
    local lava = {}
    for _,tile in pairs(GetTiles()) do
        if tile.fg == 4 then
            lava[#lava + 1] = {x = tile.x, y = tile.y}
        end
    end

    for _,t in ipairs(lava) do
        if GetTile(t.x,t.y).fg == 4 then
            FindPath(t.x,t.y-1)
            Sleep(150)
            local tries = 0
            while GetTile(t.x,t.y).fg == 4 and tries < 8 do
                punch(t.x,t.y)
                sleep(190)
                tries = tries + 1
            end
            tries = 0
            while GetTile(t.x,t.y).fg == 0 and tries < 8 do
                place(t.x,t.y,2)
                sleep(190)
                tries = tries + 1
            end
        end
    end
end

function checkEmpty(x,y)
    for i = 1, 5 do
        if GetTile((x-3)+i,y).fg == 0 then
            return true
        end
    end
    return false
end

function placeDirt()
    for tiley = 24, 2, -2 do
        for tilex = 4, 92, 5 do
            if checkEmpty(tilex,tiley) then
                FindPath(tilex,tiley+1)
                Sleep(100)
                for i = 1, 5 do
                    if (tilex-3)+i <= 92 then
                        local tries = 0
                        while GetTile((tilex-3)+i,tiley).fg == 0 and tries < 8 do
                            place((tilex-3)+i,tiley,2)
                            sleep(190)
                            tries = tries + 1
                        end
                    end
                end
            end
        end
        for tilex = 92, 4, -5 do
            if checkEmpty(tilex,tiley-2) then
                FindPath(tilex,tiley-1)
                Sleep(100)
                for i = 1, 5 do
                    if (tilex-3)+i <= 92 then
                        local tries = 0
                        while GetTile((tilex-3)+i,tiley-2).fg == 0 and tries < 8 do
                            place((tilex-3)+i,tiley-2,2)
                            sleep(190)
                            tries = tries + 1
                        end
                    end
                end
            end
        end
    end
end

function hookVariant(variant)
    if variant.v1 == "OnDialogRequest" then
        return true
    end
    return false
end

AddHook(hookVariant, "OnVariant")

clearSide()
sleep(200)
clearDirt()
sleep(200)
breakLava()
sleep(200)
placeDirt()