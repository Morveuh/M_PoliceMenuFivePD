_menuPool = NativeUI.CreatePool()
carsGarageMenu = NativeUI.CreateMenu("~u~Police Nationale", "Garage Police Nationale")
_menuPool:Add(carsGarageMenu)
carsGarageMenu:SetMenuWidthOffset(Config.MenuWidth)
_menuPool:MouseControlsEnabled(false)
_menuPool:ControlDisablingEnabled(false)

-- Add cars to the menu function
function addCarList(menu)
    local carsubmenu = _menuPool:AddSubMenu(menu,"Vehicules Police Nationale")

    for _, vehicles in pairs(Config.Vehicles) do
        local vehicleItem = NativeUI.CreateItem(vehicles.Label, "")
        vehicleItem:SetRightBadge(BadgeStyle.Car)
        carsubmenu:AddItem(vehicleItem)
        carsubmenu:SetMenuWidthOffset(Config.MenuWidth)
        
        carsubmenu.OnItemSelect = function(_, _, index)
            spawnCar(Config.Vehicles[index].Hash)
        end
    end
end

function DelCar(menu)
    local delcarsubmenu = NativeUI.CreateItem('Ranger le véhicule', '')
    delcarsubmenu:RightLabel("❌")
    carsGarageMenu:AddItem(delcarsubmenu)
    delcarsubmenu.Activated = function(ParentMenu, SelectedItem)
        if (IsPedSittingInAnyVehicle(PlayerPedId())) then 
            local vehicles = GetVehiclePedIsIn(PlayerPedId(), false)
    
            if (GetPedInVehicleSeat(vehicles, -1) == PlayerPedId()) then 
                SetEntityAsMissionEntity(vehicles, true, true)
                DeleteVehicle(vehicles)
    
                if (DoesEntityExist(vehicles)) then 
                    notify('Impossible de ~r~rangez~w~ le véhicule.')
                else 
                    notify('Vous avez ~r~rangez~w~ le véhicule.')
                end 
            else 
                notify('Vous devez ~r~être~w~ dans le siège du conducteur.')
            end 
        else
            notify('Vous ~r~n\'êtes~w~ pas dans un véhicule.')
        end
    end
end

addCarList(carsGarageMenu)
DelCar(carsGarageMenu)
_menuPool:RefreshIndex()

-- Display Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		for k,v in pairs(Config.PoliceCarGarages) do
			DrawMarker(1, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.PointMarkerG.x, Config.PointMarkerG.y, Config.PointMarkerG.z, Config.PointMarkerG.r, Config.PointMarkerG.g, Config.PointMarkerG.b, 100, false, true, 2, false, false, false, false)
			if (GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, true) < 5) then
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

        for k,v in pairs(Config.PoliceCarGarages) do

            if (GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, true) < 5) then
                hintToDisplay("Appuyez sur ~b~[E]~w~ pour accéder au Garage.")

                _menuPool:MouseControlsEnabled(false)
                _menuPool:ControlDisablingEnabled(false)

                -- If E is pressed
                if IsControlJustPressed(1, 51) then
                    carsGarageMenu:Visible(not carsGarageMenu:Visible())
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

function spawnCar(car, name)
    local Ped = PlayerPedId()

    local WaitTime = 0
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        CancelEvent()
        RequestModel(car)
        Citizen.Wait(200)

    WaitTime = WaitTime + 1

    if WaitTime == 30 then
        CancelEvent()
        notify('Impossible de ~r~charger~w~ le véhicule.')
        return
    end
end
    local vehicle = CreateVehicle(car, 442.81, -1019.61, 28.24, 90.89, true, false)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetEntityAsNoLongerNeeded(vehicle)
    SetModelAsNoLongerNeeded(vehicle)
    SetVehicleDirtLevel(vehicle, 0)

    if name then

    else
        notify('Le véhicule est ~b~sortie~w~.')
	end
end

function DeleteVehicle(entity)
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(entity))
end

Citizen.CreateThread(function()
    local hash = GetHashKey("s_m_y_cop_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "s_m_y_cop_01", 459.0, -1017.16, 27.16, 90.0, false, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
end)
