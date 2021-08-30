--//Services
local Players = game:GetService("Players")
local Chat_Service = game:GetService("Chat")
local Starter_GUI = game:GetService("StarterGui")
local Teleport_Service = game:GetService("TeleportService")
local Replicated_Storage = game:GetService("ReplicatedStorage")
local Replicated_First = game:GetService("ReplicatedFirst")


Replicated_First:RemoveDefaultLoadingScreen()


--//Instances
local L_Player = Players.LocalPlayer
local Raw_Game_MT = getrawmetatable(game); setreadonly(Raw_Game_MT, false)


--//Shared
local Settings = {
	Toggled = true;
	Prefix = "//";
	Separator = "/";
}


--//Data
Info = {
	Commands = {
		["rejoin"] = function(Properties)

			local Arguments = Properties.Args;

			if not Settings.Toggled then return end

			print("pushing")

			Notifications.Push({
				Parameters = {
					Title = "Rejoining";
					Text = "Rejoining Server!";
					Duration = 3;
					Icon = "rbxassetid://7369795078";
				}
			})

			Teleport_Service:TeleportToPlaceInstance(game.PlaceId, game.JobId, L_Player)

		end,
		["toggle"] = function(Properties)

			Settings.Toggled = not Settings.Toggled

			local Check = (Settings.Toggled and "on") or "off"

			Notifications.Push({
				Parameters = {
					Title = "Toggled "..Check.."!";
					Text = "Everything is now turned "..Check.."!";
					Duration = 5;
				}
			})

		end,
	}
}


--//Libraries
Notifications = {
	Push = function(Properties)

		Starter_GUI:SetCore("SendNotification", Properties.Parameters)

		print("pushed")

	end,
};

Notifications.Push({
	Parameters = {
		Title = "CommandOS Loaded!";
		Text = "Successfully loaded CommandOS!";
		Duration = 8;
	}
})

General_Library = {

	Check_Prefix = function(Raw_Message)

		local First_Characters = string.sub(Raw_Message, 1, #Settings.Prefix)

		if First_Characters ~= Settings.Prefix then return false end

		return true

	end,

	Run_Command = function(Properties)

		local Command = tostring(Properties.Command)
		local Arguments = Properties.Arguments

		local Command_Function = Info.Commands[Command]

		if not Command_Function then

			Notifications.Push({
				Parameters = {
					Title = "ERROR";
					Text = Command.." is an invalid command!";
					Duration = 2;
				}
			})

			return

		end

		Command_Function({
			Args = Arguments;
		})

	end,

}

Connection_Library = {
	Chatted = function(Rawer_Message)
		
		local Raw_message = Rawer_Message:lower()

		local Ret = General_Library.Check_Prefix(Raw_Message)

		if not Ret then return end

		local Raw_String = string.sub(Raw_Message, #Settings.Prefix+1)

		local Arguments = string.split(Raw_String, Settings.Separator)
		local Command = Arguments[1]


		General_Library.Run_Command({
			Command = Command;
			Arguments = Arguments;
		})


		print(Raw_String, Arguments, First_Characters)

	end,
	PlayerAdded = function(Child)

		if Child == L_Player or not Settings.Toggled then return end
		
		Notifications.Push({
			Parameters = {
				Title = "Player Joined";
				Text = tostring(Child.Name).." ("..tostring(Child.DisplayName)..") has joined the server!";
				Duration = 2;
			}
		})

	end,
	PlayerRemoving = function(Child)

		if Child == L_Player or not Settings.Toggled then return end

		Notifications.Push({
			Parameters = {
				Title = "Player Left";
				Text = tostring(Child.Name).." ("..tostring(Child.DisplayName)..") has left the server!";
				Duration = 2;
			}
		})

	end,
}


--//Connections
L_Player.Chatted:Connect(Connection_Library.Chatted)

Players.PlayerAdded:Connect(Connection_Library.PlayerAdded)
Players.PlayerRemoving:Connect(Connection_Library.PlayerRemoving)

print("Yawn yea")

Connection_Library.PlayerAdded(L_Player)


local Old_Namecall = Raw_Game_MT.__namecall

Raw_Game_MT.__namecall = function(self, ...)

	local Arguments = {...}

	if self == Replicated_Storage.DefaultChatSystemChatEvents.SayMessageRequest and Settings.Toggled and Arguments[1]:lower() ~= "toggle" then

		local Ret = General_Library.Check_Prefix(tostring(Arguments[1]))

		print(Arguments[1], Ret)

		if Ret then self = nil end

	end

	return Old_Namecall(self, ...)

end
