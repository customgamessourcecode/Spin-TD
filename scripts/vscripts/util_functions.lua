--[[ Utility Functions ]]
-- Thanks valve


---------------------------------------------------------------------------
-- Broadcast messages to screen
---------------------------------------------------------------------------
function BroadcastMessage( sMessage, fDuration )
	local centerMessage = {
		message = sMessage,
		duration = fDuration
	}
	FireGameEvent( "show_center_message", centerMessage )
end

---------------------------------------------------------------------------
-- GetRandomElement
---------------------------------------------------------------------------
function GetRandomElement( table )
	local nRandomIndex = RandomInt( 1, #table )
    local randomElement = table[ nRandomIndex ]
    return randomElement
end

---------------------------------------------------------------------------
-- ShuffledList
---------------------------------------------------------------------------
function ShuffledList( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

---------------------------------------------------------------------------
-- string.starts
---------------------------------------------------------------------------
function string.starts( string, start )
   return string.sub( string, 1, string.len( start ) ) == start
end

---------------------------------------------------------------------------
-- shallowcopy
---------------------------------------------------------------------------
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

---------------------------------------------------------------------------
-- Table functions
---------------------------------------------------------------------------

function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end

function TableLength( t )
	local nCount = 0
	for _ in pairs( t ) do
		nCount = nCount + 1
	end
	return nCount
end