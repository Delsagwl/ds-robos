local QBCore = exports['qb-core']:GetCoreObject()

local estoyRobando = false
local policiaActivos = 0
local roboActivo = false
local pedAtacada = {}

function LoadAnim(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(10)
    end
end

function IsBlacklistedWeapon()
    local arma = GetSelectedPedWeapon(PlayerPedId())
    if arma ~= nil then
        for _, v in pairs(Robos.armasBloqueadas) do
            if arma == GetHashKey(v) then
                return true
            end
        end
    end
    return false
end

RegisterNetEvent("ds-robos:Client:TogleRobarNPC", function()
    QBCore.Functions.TriggerCallback('ds-robos:server:GetCops', function(policias)
        policiaActivos = policias
        if Robos.Debug then
            Robos.MinimoPolicia = 0
        end
        if policiaActivos >= Robos.MinimoPolicia then
            estoyRobando = not estoyRobando
            if estoyRobando then
                QBCore.Functions.Notify("Robo a NPC activo", "success")
            else
                QBCore.Functions.Notify("Robo a NPC desactivado", "info")
            end
        else
            estoyRobando = false
            QBCore.Functions.Notify("No hay suficientes policías de servicio", "error")
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 3000
        local usuario = PlayerPedId()
        -- TODO: 
        -- Activar / Desactivar robo
        -- Detectar arma en la mano
        if not roboActivo  then
            sleep = 1000
            if not IsBlacklistedWeapon() and not IsPedInAnyVehicle(usuario, false) then
                local apuntando, victima = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))
                if apuntando and not IsPedAPlayer(victima) and not IsPedInAnyVehicle(victima, false) then
                    QBCore.Functions.TriggerCallback('ds-robos:server:GetCops', function(policias)
                        if not Robos.Debug and policias and policias >= Robos.MinimoPolicia then
                            sleep = 10
                            local luck = math.random(1, 100)
                            if luck > Robos.huida then
                                if DoesEntityExist(victima) and IsEntityAPed(victima) and not IsEntityDead(victima) then
                                    local distance = GetDistanceBetweenCoords(GetEntityCoords(usuario, true), GetEntityCoords(victima, true), false)
                                    if distance < 6 then
                                        if pedAtacada[victima] == nil then
                                            roboActivo = true
                                            LoadAnim('missfbi5ig_22')
                                            LoadAnim('oddjobs@shop_robbery@rob_till')
                                            TaskSetBlockingOfNonTemporaryEvents(victima, true)
                                            FreezeEntityPosition(victima, true)
                                            QBCore.Functions.Notify("Sigue apuntando con el arma para robarle", "neutral")
                                            local player = PlayerPedId()
                                            local coords = GetEntityCoords(player)
                                            TaskPlayAnim(victima, "missfbi5ig_22", "hands_up_anxious_scientist", 8.0, -1, -1, 12, 1, 0, 0, 0)
                                            Wait(2000)
                                            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId(), true), GetEntityCoords(victima, true), false)
                                            if not IsEntityDead(victima) and distance < 6 then
                                                PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
                                                ExecuteCommand(Robos.comando.." "..Robos.entorno)
                                                PlaySoundFrontend(-1, 'YES', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
                                                QBCore.Functions.Notify("La persona está obedeciendo", "success")
                                                TaskPlayAnim(usuario, "oddjobs@shop_robbery@rob_till", "loop", 8.0, 1.0, Robos.tiempoRobo, 1)
                                                PlaySoundFrontend(-1, 'Grab_Parachute', 'BASEJUMPS_SOUNDS', 1)
                                                Wait(Robos.tiempoRobo)
                                                FreezeEntityPosition(victima, false)
                                                FreezeEntityPosition(usuario, false)
                                                pedAtacada[victima] = true
                                                TaskReactAndFleePed(victima, usuario)
                                                SetPedKeepTask(victima, true)
                                                ClearPedTasks(victima)
                                                Wait(1000 * 59)
                                                roboActivo = false
                                            else
                                                QBCore.Functions.Notify("La persona huyó", "info")
                                                PlaySoundFrontend(-1, 'Out_Of_Bounds_Timer', 'DLC_HEISTS_GENERAL_FRONTEND_SOUNDS', 1)
                                                FreezeEntityPosition(victima, false)
                                                TaskReactAndFleePed(victima, usuario)
                                                SetPedKeepTask(victima, true)
                                            end
                                        else
                                            Wait(2000)
                                            QBCore.Functions.Notify("Ya has robado a esta persona", "error")
                                        end
                                    end
                                end
                            else
                                QBCore.Functions.Notify("La persona huyó", "info")
                                roboActivo = false
                                if DoesEntityExist(victima) then
                                    TaskReactAndFleePed(victima, usuario)
                                    SetPedKeepTask(victima, true)
                                end
                                Wait(100)
                            end
                        else
                            QBCore.Functions.Notify("No es un buen momento", "info")
                            roboActivo = false
                            Wait(100)
                        end
                    end)
                end
            end
        end
        Wait(sleep)
    end
end)