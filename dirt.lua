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
        for tiley = 24, 53 do
            if GetTile(column, tiley).bg == 14 or GetTile(column + 1, tiley).bg == 14 then
                FindPath(column, tiley - 1)
                while GetTile(column, tiley).bg == 14 do
                    punch(column, tiley)
                    Sleep(190)
                end
                while GetTile(column + 1, tiley).bg == 14 do
                    punch(column + 1, tiley)
                    Sleep(190)
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
                    while GetTile(tilex,tiley+i).bg ~= 0 do
                        punch(tilex,tiley+i)
                        sleep(190)
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
                        while GetTile(tilex,tiley+i).bg ~= 0 do
                            punch(tilex,tiley+i)
                            sleep(190)
                        end
                        collect(3)
                    end
                end
            end
        end
    end
end

function breakLava()
    for _,tile in pairs(GetTiles()) do
        if tile.fg == 4 then
            FindPath(tile.x,tile.y-1)
            Sleep(100)
            while GetTile(tile.x,tile.y).fg == 4 do
                punch(tile.x,tile.y)
                sleep(190)
            end
            while GetTile(tile.x,tile.y).fg == 0 do
                place(tile.x,tile.y,2)
                sleep(190)
            end
        end
    end
end

function plantFirst()
    FindPath(2,23)
    Sleep(500)
    for tilex = 2, 25, 1 do
        if GetTile(tilex,23).fg == 0 then
            FindPath(tilex,23)
            Sleep(100)
            while GetTile(tilex,23).fg == 0 do
                place(tilex,23,3)
                sleep(190)
            end
        end
    end
    Sleep(25000)
end

function checkEmpty(x,y)
    for i = 1, 5 do
        if GetTile((x-3)+i,y).fg == 0 then
            return true
        end
    end
    return false
end

function plantHarvest(x,y)
    while findItem(2) == 0 do
        for tilex = 2, 25, 1 do
            if GetTile(tilex,23).readyharvest then
                FindPath(tilex,23)
                sleep(100)
                while GetTile(tilex,23).fg == 3 do
                    punch(tilex,23)
                    sleep(190)
                end
                collect(3)
                while GetTile(tilex,23).fg == 0 do
                    place(tilex,23,3)
                    sleep(190)
                end
            end
            if findItem(2) > 180 then
                break
            end
        end
    end
    while math.floor(GetLocal().posX / 32) ~= x and math.floor(GetLocal().posY / 32) ~= y do
        FindPath(x,y)
        sleep(600)
    end
end

function placeDirt()
    for tiley = 24, 2, -2 do
        for tilex = 4, 97, 5 do
            if checkEmpty(tilex,tiley) then
                FindPath(tilex,tiley+1)
                Sleep(100)
                for i = 1, 5 do
                    if (tilex-3)+i <= 97 then
                        if findItem(2) == 0 then
                            plantHarvest(tilex,tiley+1)
                            sleep(200)
                        end
                        if GetTile((tilex-3)+i,tiley).fg == 0  then
                            while GetTile((tilex-3)+i,tiley).fg == 0 do
                                place((tilex-3)+i,tiley,2)
                                sleep(190)
                            end
                        end
                    end
                end
            end
        end
        for tilex = 97, 4, 5 do
            if checkEmpty(tilex,tiley-2) then
                FindPath(tilex,tiley-1)
                Sleep(100)
                for i = 1, 5 do
                    if (tilex-3)+i ~= 98 or (tilex-3)+i ~= 99 then
                        if findItem(2) == 0 then
                            plantHarvest(tilex,tiley-2)
                            sleep(200)
                        end
                        if GetTile((tilex-3)+i,tiley-2).fg == 0  then
                            while GetTile((tilex-3)+i,tiley-2).fg == 0 do
                                place((tilex-3)+i,tiley-2,2)
                                sleep(190)
                            end
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
plantFirst()
sleep(200)
placeDirt()