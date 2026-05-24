local VORPcore = exports.vorp_core:GetCore()

exports.vorp_inventory:registerUsableItem(Config.GoldPanItem, function(data)
    TriggerClientEvent('snow_goldpan:client:startgoldpfanne', data.source)
end)

RegisterServerEvent('snow_goldpan:server:addreward')
AddEventHandler('snow_goldpan:server:addreward', function()
    local src = source

    if math.random(1, 100) > Config.RewardChance then
        VORPcore.NotifyTip(src, _U('NothingFound'), 5000)
        return
    end

    local items = Config.RewardItems or Config.NormalItems
    if not items or #items == 0 then
        return
    end

    local RewardItem = items[math.random(1, #items)]
    local amount = RewardItem.AmountMin and RewardItem.AmountMax
        and math.random(RewardItem.AmountMin, RewardItem.AmountMax)
        or RewardItem.Amount
        or 1

    local canCarry = exports.vorp_inventory:canCarryItem(src, RewardItem.Name, amount)
    if not canCarry then
        VORPcore.NotifyTip(src, _U('InvFull'), 5000)
        return
    end

    exports.vorp_inventory:addItem(src, RewardItem.Name, amount)
    VORPcore.NotifyTip(src, _U('YouFound') .. amount .. ' ' .. RewardItem.Label, 5000)
end)

VORPcore.Callback.Register('snow_goldpan:useTool', function(source, cb)
    local src = source
    local user = VORPcore.getUser(src)
    if not user then
        cb({ success = false, broken = true })
        return
    end

    local toolItem = Config.GoldPanItem
    local toolUsage = Config.ToolUsage
    local playerItems = exports.vorp_inventory:getUserInventoryItems(src)
    if not playerItems then
        cb({ success = false, broken = true })
        return
    end

    local tool
    local minDurability = 101
    for _, item in ipairs(playerItems) do
        if item.name == toolItem then
            local dura = item.metadata and item.metadata.durability or 100
            if dura < minDurability then
                tool = item
                minDurability = dura
            end
        end
    end

    if not tool then
        VORPcore.NotifyRightTip(src, _U('needNewTool'), 4000)
        cb({ success = false, broken = true })
        return
    end

    local toolMeta = tool.metadata or {}
    local broken = false

    if next(toolMeta) == nil then
        exports.vorp_inventory:subItem(src, toolItem, 1, {})
        exports.vorp_inventory:addItem(src, toolItem, 1, { description = _U('UsageLeft') .. 100 - toolUsage, durability = 100 - toolUsage })
    else
        local durabilityValue = toolMeta.durability - toolUsage
        exports.vorp_inventory:subItem(src, toolItem, 1, toolMeta)

        if durabilityValue >= toolUsage then
            exports.vorp_inventory:addItem(src, toolItem, 1, { description = _U('UsageLeft') .. durabilityValue, durability = durabilityValue })
        else
            broken = true
            if Config.ReturnItemOnDepletion then
                if exports.vorp_inventory:canCarryItem(src, Config.ReturnItemOnDepletion, 1) then
                    exports.vorp_inventory:addItem(src, Config.ReturnItemOnDepletion, 1, {})
                else
                    VORPcore.NotifyTip(src, _U('InvFull'), 5000)
                end
            end
            VORPcore.NotifyRightTip(src, _U('needNewTool'), 4000)
        end
    end

    cb({ success = true, broken = broken })
end)