local handCamera, active = nil, false

local function disableCamera()
    RenderScriptCams(false, true, Config.easeTime, false, false)

    SetTimeout(Config.easeTime * 2, function()
        if handCamera ~= nil and not active then
            SetCamActive(handCamera, false)
            DestroyCam(handCamera)
            handCamera = nil
        end
    end)

    active = false
end

local function setCameraLook()
    local ped = PlayerPedId()
    local cameraCoords = GetGameplayCamCoord()
    local cameraRotation = GetGameplayCamRot(2)
    local gameplayCamFov = GetGameplayCamFov()

    local coordsRelativeToPlayer = GetOffsetFromEntityGivenWorldCoords(ped, cameraCoords.x, cameraCoords.y, cameraCoords.z)
    local leftShoulderCoords = GetOffsetFromEntityInWorldCoords(ped, coordsRelativeToPlayer.x, coordsRelativeToPlayer.y, coordsRelativeToPlayer.z)

    SetCamCoord(handCamera, leftShoulderCoords.x, leftShoulderCoords.y, leftShoulderCoords.z)
    SetCamRot(handCamera, cameraRotation.x, cameraRotation.y, cameraRotation.z, 2)
    AttachCamToEntity(handCamera, ped, coordsRelativeToPlayer.x - Config.leftRange, coordsRelativeToPlayer.y, coordsRelativeToPlayer.z, true)
    SetCamFov(handCamera, gameplayCamFov)

    ShowHudComponentThisFrame(14)
end

local function toggleCamera()
    if not active then
        if GetFollowPedCamViewMode() == 4 or not IsPlayerFreeAiming(PlayerId()) then return end

        if handCamera ~= nil then
            SetCamActive(handCamera, false)
            DestroyCam(handCamera)
            handCamera = nil
        end

        handCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(handCamera, true)
        RenderScriptCams(true, true, Config.easeTime, false, false)
        
        if not DoesCamExist(handCamera) then
            return disableCamera()
        end

        active = true

        startThreads()
        setCameraLook()
    else
        SetCamAffectsAiming(handCamera, true)
        disableCamera()
    end
end

function startThreads()
    if active then 
        return 
    end

    Citizen.CreateThread(function()
        while active do
            Citizen.Wait(0)
    
            if GetFollowPedCamViewMode() == 4 or not IsPlayerFreeAiming(PlayerId()) then
                toggleCamera()
            else
                setCameraLook()
            end
        end
    end)
end

RegisterKeyMapping(Config.keymapping.name, Config.keymapping.description, 'keyboard', Config.keymapping.key)

RegisterCommand(Config.keymapping.name, function()
    toggleCamera()
end)