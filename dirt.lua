function punch(x, y)
    local packet = {}
    packet.type = 3
    packet.state = 2592
    packet.value = 18
    packet.px = x
    packet.py = y
    packet.x = GetLocal().posX
    packet.y = GetLocal().posY
    SendPacketRaw(false, packet)
end

function place(x, y, id)
    local packet = {}
    packet.type = 3
    packet.value = id
    packet.px = x
    packet.py = y
    packet.x = GetLocal().posX
    packet.y = GetLocal().posY
    SendPacketRaw(false, packet)
end

function collectRaw(object)
    local packet = {}
    packet.type = 11
    packet.value = object.id
    packet.x = object.posX
    packet.y = object.posY
    SendPacketRaw(false, packet)
end

function getItemAmount(itemID)
    for _, item in pairs(GetInventory()) do
        if item.id == itemID then
            return item.amount
        end
    end
    return 0
end

function collect(range)
    for _, object in pairs(GetObjectList()) do
        local dx = math.abs(GetLocal().posX - object.posX)
        local dy = math.abs(GetLocal().posY - object.posY)
        if dx <= (32 * range) and dy < (32 * range) and getItemAmount(object.itemid) < 200 then
            collectRaw(object)
            Sleep(15)
        end
    end
end

function join(world, id)
    if GetLocal() then
        while GetLocal() do
            SendPacket(3, "action|quit_to_exit")
            Sleep(3500)
        end
    end

    if id ~= nil then
        while not GetLocal() do
            SendPacket(3, "action|join_request\nname|" .. world:upper() .. "|" .. id:upper() .. "\ninvitedWorld|0")
            Sleep(4000)
            if GetLocal() then
                local tx = math.floor(GetLocal().posX / 32)
                local ty = math.floor(GetLocal().posY / 32)
                if GetTile(tx, ty).fg == 6 then
                    while GetTile(tx, ty).fg == 6 do
                        SendPacket(3, "action|join_request\nname|" .. world:upper() .. "|" .. id:upper() .. "\ninvitedWorld|0")
                        Sleep(4000)
                    end
                end
            end
        end
    else
        while not GetLocal() do
            SendPacket(3, "action|join_request\nname|" .. world:upper() .. "\ninvitedWorld|0")
            Sleep(4000)
        end
    end
end

function clearSide()
    local function clearTwoColumns(col1, col2)
        for tiley = 24, 53 do
            local t1, t2 = GetTile(col1, tiley), GetTile(col2, tiley)
            if t1.bg ~= 0 or t2.bg ~= 0 or t1.fg ~= 0 or t2.fg ~= 0 then
                FindPath(col1, tiley - 1)
                Sleep(100)
                while GetTile(col1, tiley).bg ~= 0 or GetTile(col1, tiley).fg ~= 0 do
                    punch(col1, tiley)
                    Sleep(190)
                end
                while GetTile(col2, tiley).bg ~= 0 or GetTile(col2, tiley).fg ~= 0 do
                    punch(col2, tiley)
                    Sleep(190)
                end
                collect(3)
            end
        end
    end

    -- 2 columns on each side
    clearTwoColumns(0, 1)
    clearTwoColumns(98, 99)
end

function clearDirt()
    for tiley = 27, 51, 12 do
        for tilex = 2, 97, 1 do
            if GetTile(tilex, tiley - 2).bg ~= 0 or GetTile(tilex, tiley).bg ~= 0 or GetTile(tilex, tiley + 2).bg ~= 0 then
                FindPath(tilex - 1, tiley)
                Sleep(100)
                for i = -2, 2, 2 do
                    while GetTile(tilex, tiley + i).bg ~= 0 do
                        punch(tilex, tiley + i)
                        Sleep(190)
                    end
                    collect(3)
                end
            end
        end

        if (tiley + 6) ~= 57 then
            for tilex = 97, 2, -1 do
                if GetTile(tilex, tiley + 4).bg ~= 0 or GetTile(tilex, tiley + 6).bg ~= 0 or GetTile(tilex, tiley + 8).bg ~= 0 then
                    FindPath(tilex + 1, tiley + 6)
                    Sleep(100)
                    for i = 4, 8, 2 do
                        while GetTile(tilex, tiley + i).bg ~= 0 do
                            punch(tilex, tiley + i)
                            Sleep(190)
                        end
                        collect(3)
                    end
                end
            end
        end
    end
end

clearSide()
Sleep(200)
clearDirt()
