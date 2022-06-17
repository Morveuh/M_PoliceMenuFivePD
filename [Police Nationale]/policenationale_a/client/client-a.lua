_menuPool = NativeUI.CreatePool()
armoryMenu = NativeUI.CreateMenu("~u~Police Nationale", "Armurerie Police Nationale")
_menuPool:Add(armoryMenu)
armoryMenu:SetMenuWidthOffset(Config.MenuWidth)
_menuPool:MouseControlsEnabled(false)
_menuPool:ControlDisablingEnabled(false)

-- Add weapons to the menu function
function addWeaponList(menu)
    local armorySubMenu = _menuPool:AddSubMenu(menu,"Armurerie")

    for _, weapon in pairs(Config.Weapons) do
        local weaponItem = NativeUI.CreateItem(weapon.Label, "")
        weaponItem:SetRightBadge(BadgeStyle.Gun)
        armorySubMenu:AddItem(weaponItem)
        armorySubMenu:SetMenuWidthOffset(Config.MenuWidth)
        
        armorySubMenu.OnItemSelect = function(_, _, index)
            giveWeapon(Config.Weapons[index].Hash, Config.Weapons[index].Ammo)
        end
    end
end

function ClearWeapons(menu)
    local clearSubMenu = NativeUI.CreateItem('Ranger les armes', '')
    clearSubMenu:RightLabel("❌")
    armoryMenu:AddItem(clearSubMenu)
    clearSubMenu.Activated = function(ParentMenu, SelectedItem)
        RemoveAllPedWeapons(PlayerPedId(), true)
        notify("Vous avez ~r~rendu~w~ toutes les armes.")
    end
end

addWeaponList(armoryMenu)
ClearWeapons(armoryMenu)
_menuPool:RefreshIndex()

-- Display Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		for k,armory in pairs(Config.PoliceArmories) do
			if (GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), armory.x, armory.y, armory.z, -1) < 2.0) then
				DrawMarker(1, armory.x, armory.y, armory.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.PointMarkerA.x, Config.PointMarkerA.y, Config.PointMarkerA.z, Config.PointMarkerA.r, Config.PointMarkerA.g, Config.PointMarkerA.b, 100, false, true, 2, false, false, false, false)
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

        for k,armory in pairs(Config.PoliceArmories) do

            if (GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), armory.x, armory.y, armory.z, -1) < 2.0) then
                hintToDisplay("Appuyez sur ~b~[E]~w~ pour accéder à l'Armurerie.")

                _menuPool:MouseControlsEnabled(false)
                _menuPool:ControlDisablingEnabled(false)

                -- If E is pressed
                if IsControlJustPressed(1, 51) and GetLastInputMethod(2) then
                    armoryMenu:Visible(not armoryMenu:Visible())
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

function giveWeapon(weaponModel, ammo)
    local weaponModel = GetHashKey(weaponModel)

    GiveWeaponToPed(PlayerPedId(), weaponModel, ammo, false, true)
    PlaySoundFrontend(-1, 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET', false)
end

Citizen.CreateThread(function()
    local hash = GetHashKey("s_m_y_cop_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "s_m_y_cop_01", 454.18048095703, -980.11981201172, 29.689603805542, 90.0, false, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
end)