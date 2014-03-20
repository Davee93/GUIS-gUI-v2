local ADDON_NAME = ...

local ns = select(2, ...)

local L = {}
local Locale = GetLocale()

L.Search = "Search"
L.ReloadUI = "Reload UI"
L.Profiles = "Profiles"
L.New_Profile = "New Profile"
L.Enable_All = "Enable All"
L.Disable_All = "Disable All"
L.Profile_Name = "Profile Name"
L.Set_To = "Set To.."
L.Add_To = "Add To.."
L.Remove_From = "Remove From.."
L.Delete_Profile = "Delete Profile.."
L.Confirm_Delete = "Are you sure you want to delete this profile? Hold down shift and click again if you are."

if Locale == "deDE" then
	L.Search = "Suchen"
	L.ReloadUI = "Reload UI"
	L.Profiles = "Profils"
	L.New_Profile = "Neues Profil"
	L.Enable_All = "Alle An"
	L.Disable_All = "Alle Aus"
	L.Profile_Name = "Profil Name"
	L.Set_To = "Aktivieren.."
	L.Add_To = "Hinzuf\195\188gen zu.."
	L.Remove_From = "Entfernen von.."
	L.Delete_Profile = "Profil L\195\182schen"
	L.Confirm_Delete = "Bist du dir sicher das du dieses Profil l\195\182schen m\195\182chtest? Dann halte Shift gedr\195\188ckt und klicke nochmals."
end

if Locale == "frFR" then
	L.Search = "Rechercher"
	L.ReloadUI = "Recharger UI"
	L.Profiles = "Profils"
	L.New_Profile = "Nouveau profil"
	L.Enable_All = "Activer tous"
	L.Disable_All = "D\195\169sactiver tous"
	L.Profile_Name = "profil nom"
	L.Set_To = "Mettez \195\160.."
	L.Add_To = "Ajouter \195\160.."
	L.Remove_From = "Retirer de.."
	L.Delete_Profile = "Supprimer le profil"
	L.Confirm_Delete = "Etes-vous sûr de vouloir supprimer ce profil? Maintenez la touche Shift et re-cliquez si vous êtes sûr."
end

ns.L = L