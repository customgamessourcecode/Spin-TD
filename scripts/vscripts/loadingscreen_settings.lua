function TryPressSettingsButtonEvent( eventSourceIndex, args )

  --PrintTable(args)

  --print( "My event: ( " .. eventSourceIndex .. ", " .. args['value'] .. " )" )


  if GameRules:PlayerHasCustomGameHostPrivileges(PlayerResource:GetPlayer(args.PlayerID)) then

      local Change = false

      if args.category == "Gamemode" then
        if GAMEMODE ~= args.value then
          GAMEMODE = args.value
          Change = true
        end
      elseif args.category == "Difficulty" then
         if DIFFICULTY ~= args.value then
          DIFFICULTY = args.value
          Change = true
        end
      end

      if Change then
        CustomGameEventManager:Send_ServerToAllClients( "Button_Pressed", args )
      end
  end

end

function TryPressToggle( eventSourceIndex, args )

  if GameRules:PlayerHasCustomGameHostPrivileges(PlayerResource:GetPlayer(args.PlayerID)) then

    if args.id == 0 then
      PLUS_MODE_ENABLED = not PLUS_MODE_ENABLED

      --print("PLUS_MODE_ENABLED: " .. tostring(PLUS_MODE_ENABLED))
    end

    CustomGameEventManager:Send_ServerToAllClients( "Toggle_Pressed", args )
  end
end

function PlayerPicksColor( eventSourceIndex, args )
  if GameRules:PlayerHasCustomGameHostPrivileges(PlayerResource:GetPlayer(args.PlayerID)) then

    PlayerPreSelectColor[args.PlayerID] = args.index+1
    CustomGameEventManager:Send_ServerToAllClients( "Player_Changed_Color", args )
  end
end

function CastPlusVote( eventSourceIndex, args )
  --PrintTable(args)

  PLUS_VOTE_STATUS[args.PlayerID] = args.value
  CustomGameEventManager:Send_ServerToAllClients( "PlusModeVoteStatus", PLUS_VOTE_STATUS )
end

function RequestTopTenDonations( eventSourceIndex, args)
  SendDonationsTopTenToPlayer(PlayerResource:GetPlayer(args.PlayerID))
end