local VORPcore = exports.vorp_core:GetCore()

local panModeActive = false
local panningActive = false
local panningAnimActive = false
local panProp = nil
local PanPromptGroup = GetRandomIntInRange(0, 0xffffff)
local PromptPan
local PromptExit

local JumpBlockControls = {
    0xE4D2CE1D,
    0xAA56B926,
    0x5181713D,
    0xD10A3A36,
}

local JumpBlockPanKeyControls = {
    0xD9D0E1C0,
}

local JumpBlockControlTypes = { 0, 1 }

local SprintControls = {
    0x8FFC75D6,
    0x5AA007D7,
}

local function GetPanKey()
    return ResolveKey(Config.Keys and Config.Keys.Pan) or KeyMap.SPACE
end

local function GetExitKey()
    return ResolveKey(Config.Keys and Config.Keys.ExitMode) or KeyMap.X
end

local function PromptCompleted(prompt)
    if UiPromptHasStandardModeCompleted then
        return UiPromptHasStandardModeCompleted(prompt, 0)
    end
    return PromptHasStandardModeCompleted(prompt, 0)
end

local function WasExitPressed()
    local key = GetExitKey()
    return IsControlJustPressed(0, key)
        or IsDisabledControlJustPressed(0, key)
        or PromptCompleted(PromptExit)
end

local function IsInGoldWater()
    local playerPed = PlayerPedId()
    if not IsPedOnFoot(playerPed) or not IsEntityInWater(playerPed) then
        return false
    end
    local coords = GetEntityCoords(playerPed)
    local water = Citizen.InvokeNative(0x5BA7A68A346A5A91, coords.x, coords.y, coords.z)
    for k, _ in pairs(Config.locations) do
        if water == Config.locations[k].hash then
            return true
        end
    end
    return false
end

local function AttachPanProp()
    if panProp and DoesEntityExist(panProp) then
        return
    end
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    panProp = CreateObject(GetHashKey('p_cs_miningpan01x'), coords.x, coords.y, coords.z, true, true, true)
    local righthand = GetEntityBoneIndexByName(playerPed, "SKEL_R_HAND")
    AttachEntityToEntity(panProp, playerPed, righthand, 0.2, 0.0, -0.20, -100.0, -50.0, 0.0, false, false, false, true, 2, true)
end

local function RemovePanProp()
    if panProp and DoesEntityExist(panProp) then
        DetachEntity(panProp, true, true)
        DeleteObject(panProp)
    end
    panProp = nil
end

local function DisableSprintControls()
    if Config.DisableSprintWhilePanning == false then
        return
    end
    for i = 1, #SprintControls do
        DisableControlAction(0, SprintControls[i], true)
    end
end

local function DisableJumpControls()
    if Config.DisableJumpWhilePanning == false or not panModeActive then
        return
    end
    for t = 1, #JumpBlockControlTypes do
        local controlType = JumpBlockControlTypes[t]
        for i = 1, #JumpBlockControls do
            DisableControlAction(controlType, JumpBlockControls[i], true)
        end
        if panningActive then
            for i = 1, #JumpBlockPanKeyControls do
                DisableControlAction(controlType, JumpBlockPanKeyControls[i], true)
            end
        end
    end
end

local function ApplyHardJumpBlock(ped)
    if Config.DisableJumpWhilePanning == false or not panModeActive then
        return
    end
    Citizen.InvokeNative(0xC1E8A365BF3B29F2, ped, 2, true)
end

local function ClearHardJumpBlock(ped)
    Citizen.InvokeNative(0xC1E8A365BF3B29F2, ped, 2, false)
end

local function DisablePanModeMovementControls()
    DisableSprintControls()
    DisableJumpControls()
    if panModeActive then
        ApplyHardJumpBlock(PlayerPedId())
    end
end

local function WasPanKeyPressed()
    local key = GetPanKey()
    if panningActive then
        return IsDisabledControlJustPressed(0, key)
    end
    return IsControlJustPressed(0, key) or PromptCompleted(PromptPan)
end

local function ApplyPanningMoveSpeed(ped)
    if Config.DisableSprintWhilePanning == false then
        return
    end
    SetPedMaxMoveBlendRatio(ped, 1.0)
end

local function ResetPanningMoveSpeed(ped)
    SetPedMaxMoveBlendRatio(ped, 3.0)
end

local function GetPanningAnimFlag()
    if Config.PanningCanMove == false then
        return Config.CrouchAnimFlag or 1
    end
    return Config.PanningAnimFlag or 31
end

local function ClearPanningAnim(ped)
    local pan = Config.Anims.Panning
    if Config.PanningCanMove then
        StopAnimTask(ped, pan.dict, pan.name, 1.0)
        ClearPedSecondaryTask(ped)
    else
        ClearPedTasks(ped, true, true)
    end
end

local function SetupPrompts()
    local str = _U('PromptPan')
    PromptPan = UiPromptRegisterBegin()
    UiPromptSetControlAction(PromptPan, GetPanKey())
    str = VarString(10, 'LITERAL_STRING', str)
    UiPromptSetText(PromptPan, str)
    UiPromptSetEnabled(PromptPan, true)
    UiPromptSetVisible(PromptPan, true)
    UiPromptSetStandardMode(PromptPan, true)
    UiPromptSetGroup(PromptPan, PanPromptGroup, 0)
    UiPromptRegisterEnd(PromptPan)

    str = _U('PromptExit')
    PromptExit = UiPromptRegisterBegin()
    UiPromptSetControlAction(PromptExit, GetExitKey())
    str = VarString(10, 'LITERAL_STRING', str)
    UiPromptSetText(PromptExit, str)
    UiPromptSetEnabled(PromptExit, true)
    UiPromptSetVisible(PromptExit, true)
    UiPromptSetStandardMode(PromptExit, true)
    UiPromptSetGroup(PromptExit, PanPromptGroup, 0)
    UiPromptRegisterEnd(PromptExit)
end

local function ShowPanPrompts()
    UiPromptSetEnabled(PromptPan, not panningActive)
    UiPromptSetVisible(PromptPan, true)
    UiPromptSetEnabled(PromptExit, true)
    UiPromptSetVisible(PromptExit, true)
    local groupLabel = VarString(10, 'LITERAL_STRING', _U('PanModeTitle'))
    UiPromptSetActiveGroupThisFrame(PanPromptGroup, groupLabel, 0, 0, 0, 0)
end

local function StopPanMode(leftWater, silent)
    if not panModeActive and not panningActive and not panProp then
        return
    end
    panModeActive = false
    panningActive = false
    panningAnimActive = false
    local ped = PlayerPedId()
    ResetPanningMoveSpeed(ped)
    ClearHardJumpBlock(ped)
    RemovePanProp()
    ClearPanningAnim(ped)
    ClearPedTasks(ped, true, true)
    if silent then
        return
    end
    if leftWater then
        VORPcore.NotifyTip(_U('LeftWater'), 4000)
    else
        VORPcore.NotifyTip(_U('PanModeEnded'), 4000)
    end
end

local function PanModeLoop()
    while panModeActive do
        Wait(0)
        local ped = PlayerPedId()
        DisablePanModeMovementControls()
        ApplyPanningMoveSpeed(ped)
        if panProp and DoesEntityExist(panProp) then
            if not IsEntityAttachedToEntity(panProp, ped) then
                AttachPanProp()
            end
        end
        ShowPanPrompts()
        if WasExitPressed() then
            if panningActive then
                panningActive = false
                ClearPanningAnim(PlayerPedId())
                AttachPanProp()
            end
            StopPanMode(false)
            break
        end
        if panningActive then
            if WasPanKeyPressed() or PromptCompleted(PromptPan) then
                VORPcore.NotifyTip(_U('StillPanning'), 4000)
            end
        elseif WasPanKeyPressed() or PromptCompleted(PromptPan) then
            if not IsInGoldWater() then
                VORPcore.NotifyTip(_U('NotInWater'), 5000)
            else
                panningActive = true
                CreateThread(function()
                    local toolResult = VORPcore.Callback.TriggerAwait('snow_goldpan:useTool')
                    if not panModeActive then
                        panningActive = false
                        return
                    end
                    if not toolResult or not toolResult.success then
                        panningActive = false
                        StopPanMode(false, true)
                        return
                    end
                    if toolResult.broken then
                        panningActive = false
                        StopPanMode(false, true)
                        return
                    end
                    Goldpan()
                    panningActive = false
                end)
            end
        end
    end
end

local function StartPanMode()
    if panModeActive or panningActive then
        return
    end
    panModeActive = true
    AttachPanProp()
    CreateThread(PanModeLoop)
end

RegisterNetEvent('snow_goldpan:client:startgoldpfanne')
AddEventHandler('snow_goldpan:client:startgoldpfanne', function()
    StartPanMode()
end)

local function WaitInPanMode(ms, onTick)
    local endTime = GetGameTimer() + ms
    while GetGameTimer() < endTime do
        if not panModeActive then
            return false
        end
        if onTick then
            onTick()
        end
        Wait(0)
    end
    return panModeActive
end

function Goldpan()
    if not panModeActive then
        return
    end
    if not IsInGoldWater() then
        VORPcore.NotifyTip(_U('NotInWater'), 5000)
        return
    end
    local playerPed = PlayerPedId()
    AttachPanProp()
    local totalTime = Config.GoldPanTime or (Config.CrouchTime + Config.PanningTime)
    VORPcore.NotifyTip(_U('YouAreGoldpaning'), totalTime)
    CrouchAnim()
    if not WaitInPanMode(Config.CrouchTime or 2000) then return end
    ClearPedTasks(playerPed, true, true)
    AttachPanProp()
    if not panModeActive then return end
    PlayPanningPhase()
    if not panModeActive then return end
    local success = not Config.DoSkillCheck or DoSkillCheck()
    ClearPanningAnim(playerPed)
    AttachPanProp()
    if not panModeActive then return end
    if success then
        TriggerServerEvent('snow_goldpan:server:addreward')
    else
        VORPcore.NotifyTip(_U('FailedSkillcheck'), 5000)
    end
end

function DoSkillCheck()
    local randomizer = math.random(Config.MaxDifficulty, Config.MinDifficulty)
    local skillCheckResult = exports["syn_minigame"]:taskBar(randomizer, 7)
    return skillCheckResult == 100
end

CreateThread(function()
    SetupPrompts()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end
    StopPanMode(false, true)
    if PromptPan then
        UiPromptDelete(PromptPan)
    end
    if PromptExit then
        UiPromptDelete(PromptExit)
    end
end)

--- UTILS ---

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

local function PlayAnimLoop(ped, dict, name, blendIn, flag)
    LoadAnimDict(dict)
    flag = flag or 1
    FreezeEntityPosition(ped, false)
    TaskPlayAnim(ped, dict, name, blendIn or 1.0, 1.0, -1, flag, 0.0, false, false, false, '', false)
end

local function KeepPanningAnimPlaying(ped, dict, name, flag)
    FreezeEntityPosition(ped, false)
    DisablePanModeMovementControls()
    ApplyPanningMoveSpeed(ped)
    if not IsEntityPlayingAnim(ped, dict, name, flag) then
        PlayAnimLoop(ped, dict, name, 1.0, flag)
    end
end

function CrouchAnim()
    local anim = Config.Anims.Crouch
    PlayAnimLoop(PlayerPedId(), anim.dict, anim.name, 0.5, Config.CrouchAnimFlag or 1)
end

function GoldPanningAnim()
    local anim = Config.Anims.Panning
    PlayAnimLoop(PlayerPedId(), anim.dict, anim.name, 1.0, GetPanningAnimFlag())
end

function PlayPanningPhase()
    local ped = PlayerPedId()
    local dict = Config.Anims.Panning.dict
    local flag = GetPanningAnimFlag()
    local sequence = Config.PanningSequence
    panningAnimActive = true
    FreezeEntityPosition(ped, false)
    ApplyPanningMoveSpeed(ped)
    if sequence and #sequence > 0 then
        local elapsed = 0
        local total = Config.PanningTime or 10000
        for i = 1, #sequence do
            if elapsed >= total then break end
            local step = sequence[i]
            local stepDuration = step.duration or math.floor(total / #sequence)
            if elapsed + stepDuration > total then
                stepDuration = total - elapsed
            end
            local stepName = step.name
            PlayAnimLoop(ped, dict, stepName, 1.0, flag)
            if not WaitInPanMode(stepDuration, function()
                KeepPanningAnimPlaying(ped, dict, stepName, flag)
            end) then
                panningAnimActive = false
                ResetPanningMoveSpeed(ped)
                return
            end
            elapsed = elapsed + stepDuration
        end
        if elapsed < total then
            WaitInPanMode(total - elapsed, function()
                DisablePanModeMovementControls()
                ApplyPanningMoveSpeed(ped)
            end)
        end
        panningAnimActive = false
        ResetPanningMoveSpeed(ped)
        return
    end
    local animName = Config.Anims.Panning.name
    PlayAnimLoop(ped, dict, animName, 1.0, flag)
    WaitInPanMode(Config.PanningTime or 10000, function()
        KeepPanningAnimPlaying(ped, dict, animName, flag)
    end)
    panningAnimActive = false
    ResetPanningMoveSpeed(ped)
end
