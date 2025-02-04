local camHandle, camActive = 0, false

local function disableCamera()
	RenderScriptCams(false, true, Config.transitionTime, false, false)

	SetTimeout(Config.transitionTime * 2, function()
		if not camHandle or camHandle == 0 and camActive then return end

		SetCamActive(camHandle, false)
		DestroyCam(camHandle, false)
		camHandle = 0
	end)

	camActive = false
end

local function updateCameraPosition()
	local ped = PlayerPedId()
	local cameraCoords = GetGameplayCamCoord()
	local cameraRotation = GetGameplayCamRot(2)
	local gameplayCamFov = GetGameplayCamFov()

	local coordsRelativeToPlayer = GetOffsetFromEntityGivenWorldCoords(ped, cameraCoords.x, cameraCoords.y, cameraCoords.z)

	SetCamCoord(camHandle, coordsRelativeToPlayer.x, coordsRelativeToPlayer.y, coordsRelativeToPlayer.z)
	SetCamRot(camHandle, cameraRotation.x, cameraRotation.y, cameraRotation.z, 2)
	AttachCamToEntity(camHandle, ped, coordsRelativeToPlayer.x - Config.leftOffset, coordsRelativeToPlayer.y, coordsRelativeToPlayer.z, true)
	SetCamFov(camHandle, gameplayCamFov)
end

local function toggleCamera()
	if camActive and camHandle then
		SetCamAffectsAiming(camHandle, false)
		disableCamera()
		return
	end

	if GetFollowPedCamViewMode() == 4 or not IsPlayerFreeAiming(PlayerId()) then return end

	if not camHandle or camHandle == 0 then
		camHandle = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		if not DoesCamExist(camHandle) then return disableCamera() end
	end

	SetCamActive(camHandle, true)
	SetCamAffectsAiming(camHandle, true)
	RenderScriptCams(true, true, Config.transitionTime, false, false)
	camActive = true

	updateCameraPosition()
	CreateThread(function()
		while camActive do
			if GetFollowPedCamViewMode() == 4 or not IsPlayerFreeAiming(PlayerId()) then
				toggleCamera()
			else
				updateCameraPosition()
				ShowHudComponentThisFrame(14)
			end
			Wait(0)
		end
	end)
end

RegisterCommand(Config.keymapping.name, toggleCamera, false)
RegisterKeyMapping(Config.keymapping.name, Config.keymapping.description, "keyboard", Config.keymapping.key)
