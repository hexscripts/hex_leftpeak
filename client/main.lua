local camHandle, camActive = 0, false

local function disableCamera()
	RenderScriptCams(false, true, Config.transitionTime, false, false)

        if handCamera ~= nil and not active then
            SetCamActive(handCamera, false)
            DestroyCam(handCamera)
            handCamera = nil
        end
    end)
	SetTimeout(Config.transitionTime * 2, function()

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
    if not active then 
        return 
    end
	RenderScriptCams(true, true, Config.transitionTime, false, false)

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

RegisterCommand(Config.keymapping.name, toggleCamera, false)
RegisterKeyMapping(Config.keymapping.name, Config.keymapping.description, "keyboard", Config.keymapping.key)
