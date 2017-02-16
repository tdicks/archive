--[[
Loads admins from the sourcemod admins config and provides Gmod rights.
Written for GMod10 so may not work on the later versions.
]]--

local SM = {}
SM.Admins = {}

SM.AdminFile = "../addons/sourcemod/configs/admins.cfg";

print( "=====================================" )
print( "== Loading SourceMod Compatibility ==" )
print( "=====================================" )

function SM.LoadAdmins()
	
	if( file.Exists( SM.AdminFile ) ) then
	
		SM.Admins = util.KeyValuesToTable( file.Read( SM.AdminFile ) )
		
	else
	
		Error( "Couldn't find admin file" )
		
	end
	
end

function SM.PlayerInitialSpawn( ply )

	timer.Simple( 3, SM.CheckAdmin, ply )

end

function SM.Kick( ply, cmd, args )

	local id = args[1]

	ply:ConCommand( string.format( "sm_kick #%s \"Kicked by %s\" \n", id, ply:Nick() ) )
	
end
concommand.Remove( "kickid2" )
concommand.Add( "kickid2", SM.Kick )

function SM.Ban( ply, cmd, args )

	local length = args[1]
	local id = args[2]

	ply:ConCommand( string.format( "sm_ban #%s %s \"Scoreboard Ban\" \n", id, length ) )
	
end
concommand.Remove( "banid2" )
concommand.Add( "banid2", SM.Ban )

function SM.CheckAdmin( ply )

	for K, V in pairs( SM.Admins ) do
	
		if( string.lower( V.identity ) == string.lower( ply:SteamID() ) ) then
		
			if( !ply:IsUserGroup( string.lower( V.group ) ) ) then
			
				ply:SetUserGroup( string.lower( V.group ) )
				ply:ChatPrint( "[SM] - Gmod Access Set (".. string.upper( V.identity ) ..")" )
				
			end
			
			return
			
		end
		
	end
	
	ply:SetUserGroup( "NO_ADMIN" )
	
end

function SM.AdminTimer()

	for K, V in pairs( player.GetAll() ) do
	
		SM.CheckAdmin( V )
		
	end
	
end
timer.Create( "SM_AdminTimer", 5, 0, SM.AdminTimer )
timer.Create( "SM_ReloadAdmins", 30, 0, SM.LoadAdmins )

SM.LoadAdmins()
