_menuPool = NativeUI.CreatePool()
equimentMenu = NativeUI.CreateMenu("~u~Police Nationale", "Équipements Police Nationale")
_menuPool:Add(equimentMenu)
equimentMenu:SetMenuWidthOffset(Config.MenuWidth)
_menuPool:MouseControlsEnabled(false)
_menuPool:ControlDisablingEnabled(false)

-- Add Equipments to the menu function
function addEquipmentList(menu)
    local outfitsSubMenu = _menuPool:AddSubMenu(menu,"Tenues")

    for _, outfit in pairs(Config.Outfits) do
        local outfitItem = NativeUI.CreateItem(outfit.Label, "")
        outfitItem:SetRightBadge(BadgeStyle.Clothes)
        outfitsSubMenu:AddItem(outfitItem)
        outfitsSubMenu:SetMenuWidthOffset(Config.MenuWidth)
        
        outfitsSubMenu.OnItemSelect = function(_, _, index)
            setCopOutfit(Config.Outfits[index].Model)
        end
    end

    local armourCheckbox = NativeUI.CreateCheckboxItem("Gilet pare-balles", bool)
    menu:AddItem(armourCheckbox)
    menu.OnCheckboxChange = function (sender, item, checked_)
        
        -- check if what changed is from this menu
        if item == armourCheckbox then
            bool = checked_

            if bool == true then
                toggleBodyArmour(true)
            else
                toggleBodyArmour(false)
            end
        end
    end
end

addEquipmentList(equimentMenu)
_menuPool:RefreshIndex()

-- Display Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		for k, equipmentMarker in pairs(Config.EquipmentMarkers) do
			DrawMarker(1, equipmentMarker.x, equipmentMarker.y, equipmentMarker.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.PointMarkerE.x, Config.PointMarkerE.y, Config.PointMarkerE.z, Config.PointMarkerE.r, Config.PointMarkerE.g, Config.PointMarkerE.b, 100, false, true, 2, false, false, false, false)
			if (GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), equipmentMarker.x, equipmentMarker.y, equipmentMarker.z, true) < 2.0) then	
            else
                _menuPool:CloseAllMenus()
            end
		end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()

        for k,equipmentMarker in pairs(Config.EquipmentMarkers) do

            if (GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), equipmentMarker.x, equipmentMarker.y, equipmentMarker.z, true) < 2.0) then
                hintToDisplay("Appuyez sur ~b~[E]~w~ pour accéder aux Équipements.")

                _menuPool:MouseControlsEnabled(false)
                _menuPool:ControlDisablingEnabled(false)

                -- If E is pressed
                if IsControlJustPressed(1, 51) then
                    equimentMenu:Visible(not equimentMenu:Visible())
                end
            end  
        end
    end
end)

function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

function KeyboardInput(TextEntry, MaxStringLenght)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry)
	DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', '', '', '', '', MaxStringLenght)
	BlockInput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local Result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		BlockInput = false
		return Result
	else
		Citizen.Wait(500)
		BlockInput = false
		return nil
	end
end

function toggleBodyArmour(bool)

    playerPed = PlayerPedId()

    if bool == true then
        AddArmourToPed(playerPed, 100)
        SetPedArmour(playerPed, 100)
        SetPedComponentVariation(GetPlayerPed(-1), 9, 27, 9, 2)
        notify("Vous avez ~b~mis~w~ le gilet pare-balles.")
    else
        SetPedArmour(playerPed, 0)
        notify("Vous avez ~r~retirer~w~ le gilet pare-balles.")
    end
end

function setCopOutfit(model)
    modelHash = GetHashKey(model)

	RequestModel(modelHash)
	while not HasModelLoaded(modelHash) do
		Citizen.Wait(0)
    end
    
    SetPlayerModel(PlayerId(), modelHash)
end
