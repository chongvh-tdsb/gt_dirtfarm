To clear **2 tiles on both sides** (instead of just column 0 and column 98), we need to modify the `clearSide()` function so it checks and punches columns `0, 1` on the left side, and columns `97, 98` (or `98, 99`) on the right side.

Here is the updated script that clears 2 width-columns on both the left and right sides, followed by the dirt clearing:

```lua
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
    local function clearTwoColumns(col1, col2)
        for tiley = 24, 53 do
            if GetTile(col1, tiley).bg ~= 0 or GetTile(col2, tiley).bg ~= 0 or GetTile(col1, tiley).fg ~= 0 or GetTile(col2, tiley).fg ~= 0 then
                FindPath(col1, tiley - 1)
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
    
    -- Clear 2 tiles on the left side (Columns 0 and 1)
    clearTwoColumns(0, 1)
    -- Clear 2 tiles on the right side (Columns 98 and 99)
    clearTwoColumns(98, 99)
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

function hookVariant(variant)
    if variant.v1 == "OnDialogRequest" then
        return true
    end
    return false
end

AddHook(hookVariant, "OnVariant")

-- Execution: Clears 2 tiles on both sides, then clears dirt
clearSide()
sleep(200)
clearDirt()

```