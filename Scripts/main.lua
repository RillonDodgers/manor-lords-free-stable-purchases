-- Free Oxen And Horses: standard UE4SS Lua hooks for Manor Lords 0.8.117.
-- Credit the normal price, then run the game's complete normal upgrade action.
-- No executable patches, DLLs, or external helper processes.

if FreeOxenAndHorses and FreeOxenAndHorses.loaded then return end
local scriptDirectory = assert(debug.getinfo(1, "S").source:match("^@(.*[\\/])"), "Cannot locate mod directory")
local versionFile = assert(io.open(scriptDirectory .. "../VERSION", "r"))
local VERSION = assert(versionFile:read("*a")):match("^%s*(.-)%s*$")
versionFile:close()
FreeOxenAndHorses = { loaded = true, version = VERSION }
local MOD = "[FreeOxenAndHorses] "
local FREE = { [13] = "Ox", [19] = "Horse" }
local WEALTH_REASON = "not_enough_wealth"
local installed = {}
local running = false
local purchaseReady = false

local function log(message)
    print(MOD .. tostring(message) .. "\n")
end

local function valid(object)
    if object == nil then return false end
    local ok, result = pcall(function() return object:IsValid() end)
    return ok and result == true
end

local function unwrap(value)
    local ok, result = pcall(function() return value:get() end)
    return ok and result or value
end

local function nameOf(value)
    value = unwrap(value)
    if type(value) == "string" then return value end
    return value:ToString()
end

-- Native eligibility is retained except for its regional-wealth requirement.
-- Read output elements immediately; never retain wrappers across callbacks.
local function eligible(building, id)
    local reasons = {}
    local allowed = building:canUpgrade(id, reasons)
    if allowed then return true end
    local count = 0
    for _, reason in pairs(reasons) do
        count = count + 1
        if nameOf(reason) ~= WEALTH_REASON then return false end
    end
    return count > 0
end

local function fixWidgetObject(widget)
    if not purchaseReady then return end
    if not valid(widget) or not FREE[widget.id] or not valid(widget.building) then return end
    -- The normal update may disable the widget before Blueprint tooltip checks.
    -- Recompute its actual requirements rather than enabling it unconditionally.
    local allowed = eligible(widget.building, widget.id)
    widget:SetIsEnabled(allowed)
    if valid(widget.Btn_Upgrade) then widget.Btn_Upgrade:SetIsEnabled(allowed) end
end

local function fixWidget(context) fixWidgetObject(context:get()) end

local function fixEligibility(context, idParam, reasonsParam)
    if not purchaseReady or not FREE[idParam:get()] then return end
    local reasons = reasonsParam:get()
    local count, onlyWealth = 0, true
    reasons:ForEach(function(_, reason)
        count = count + 1
        if nameOf(reason) ~= WEALTH_REASON then onlyWealth = false end
    end)
    if count > 0 and onlyWealth then
        reasons:Empty()
        return true
    end
end

local function purchase(context, requestParam)
    if running then return end
    local pawn = context:get()
    local requested = requestParam:get()
    local id = requested.upgradeID
    if not FREE[id] or not valid(pawn) or not pawn.upgradeRequestPending then return end
    local queued = pawn.UpgradeRequest
    local building = queued.BuildingMaster
    if queued.upgradeID ~= id or not valid(building) or not valid(requested.BuildingMaster) then return end
    if building:GetAddress() ~= requested.BuildingMaster:GetAddress() then return end
    if not valid(building.Region) then return end

    -- Consume this accepted queue entry once, before the normal pawn tick can
    -- process its paid version. Other upgrade requests are left untouched.
    pawn.upgradeRequestPending = false
    if not eligible(building, id) then
        log(FREE[id] .. " order rejected by normal non-wealth requirements.")
        return
    end

    local region = building.Region
    local before = region.regionalWealth
    local price = building:GetRegionalWealthCostForUpgrade(id)
    if type(price) ~= "number" or price < 0 or price % 1 ~= 0 then
        log("Order rejected: invalid normal purchase price.")
        return
    end

    running = true
    -- Use the reflected wealth field for the temporary credit, avoiding a
    -- misleading income notification. The normal purchase still deducts its cost.
    local ok, result = pcall(function()
        region.regionalWealth = before + price
        return building:BeginUpgrade(id)
    end)
    local after = region.regionalWealth
    -- BeginUpgrade runs synchronously on the game thread. Restore unused credit
    -- after a rejected order, and keep the purchase's regional-wealth cost at zero.
    region.regionalWealth = before
    running = false
    log(string.format("%s order: normal price=%d, success=%s, wealth=%d -> %d (before cleanup=%d)",
        FREE[id], price, tostring(ok and result == true), before, region.regionalWealth, after))
    if not ok then log("Purchase error: " .. tostring(result)) end
end

local function protected(callback)
    return function(...)
        local ok, result = pcall(callback, ...)
        if not ok then log("Hook error: " .. tostring(result)); return end
        return result
    end
end

local function addHook(path, callback, native)
    if installed[path] then return true end
    if not valid(StaticFindObject(path)) then return false end
    local ok, pre, post
    if native then
        ok, pre, post = pcall(RegisterHook, path, function() end, protected(callback))
    else
        ok, pre, post = pcall(RegisterHook, path, protected(callback))
    end
    if not ok then log("Could not register " .. path .. ": " .. tostring(pre)); return false end
    installed[path] = { pre, post }
    log("Hook ready: " .. path)
    return true
end

purchaseReady = addHook("/Script/ManorLords.PawnCPP:addUpgradeRequest", purchase, true)
if purchaseReady then
    addHook("/Script/ManorLords.SMBuildingMaster:canUpgrade", fixEligibility, true)
end

-- Widget classes may load only after a settlement or building panel opens.
LoopAsync(1000, function()
    if not purchaseReady then
        purchaseReady = addHook("/Script/ManorLords.PawnCPP:addUpgradeRequest", purchase, true)
        if purchaseReady then addHook("/Script/ManorLords.SMBuildingMaster:canUpgrade", fixEligibility, true) end
    end
    if not purchaseReady then return false end
    return addHook("/Game/UI/Inventory/upgradeWidget.upgradeWidget_C:updateContents", fixWidget, false)
end)

FreeOxenAndHorses.refresh = function()
    ExecuteInGameThread(function()
        for _, widget in ipairs(FindAllOf("upgradeWidget_C") or {}) do
            if valid(widget) then
                local ok, err = pcall(fixWidgetObject, widget)
                if not ok then log("Refresh error: " .. tostring(err)) end
            end
        end
    end)
end

FreeOxenAndHorses.refresh()
log("Loaded v" .. VERSION .. ". Oxen and horse orders receive their normal purchase price as a temporary credit.")
