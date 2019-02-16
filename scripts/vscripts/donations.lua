require('libraries/JSON')


DONATIONS_API_URL_LATEST = "http://spintd.prutt.se/latest"
DONATIONS_API_URL_TOP = "http://spintd.prutt.se/top"

DONATIONS_BANNER_RESULT_TABLE = {}
DONATIONS_TOP_TEN_RESULT_TABLE = {}


local function callback_banner(result)
	-- Decode response into lua table

	--print("Result " .. result)

	local resultTable = {}
	local errorMSg = nil

	
	resultTable, errorMSg = JSON:decode(result)

	if errorMSg then
		print(" Can't decode result: " .. result)
		print(" errorMSg: " .. errorMSg)
	else

		DONATIONS_BANNER_RESULT_TABLE = resultTable

		--PrintTable(resultTable)

  	end

end

local function callback_top_ten(result)
	-- Decode response into lua table

	--print("Result " .. result)

	local resultTable = {}
	local errorMSg = nil

	
	resultTable, errorMSg = JSON:decode(result)

	if errorMSg then
		print(" Can't decode result: " .. result)
		print(" errorMSg: " .. errorMSg)
	else

		DONATIONS_TOP_TEN_RESULT_TABLE = resultTable

		--PrintTable(resultTable)

  	end

end

function GetDonations()

	local req = CreateHTTPRequestScriptVM("GET", DONATIONS_API_URL_LATEST )

	--for key, value in pairs(values) do
	--	req:SetHTTPRequestGetOrPostParameter(key, value)
	--end

	req:Send(function(result)
		callback_banner(result.Body)
	end)

	local req2 = CreateHTTPRequestScriptVM("GET", DONATIONS_API_URL_TOP )

	--for key, value in pairs(values) do
	--	req:SetHTTPRequestGetOrPostParameter(key, value)
	--end

	req2:Send(function(result)
		callback_top_ten(result.Body)
	end)

end

function SendDonationsTopTenToPlayer(player)
  CustomGameEventManager:Send_ServerToPlayer(player, "DonationsTopTenUpdate", DONATIONS_TOP_TEN_RESULT_TABLE )
end

function SendDonationsBannerToAll()
  	CustomGameEventManager:Send_ServerToAllClients("DonationsBannerUpdate", DONATIONS_BANNER_RESULT_TABLE )
end

function SendDonationsBannerToPlayer(player)
  CustomGameEventManager:Send_ServerToPlayer(player, "DonationsBannerUpdate", DONATIONS_BANNER_RESULT_TABLE )
end