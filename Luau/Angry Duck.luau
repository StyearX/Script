local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/projects/refs/heads/main/UI/NotificationLibrary/Source.luau"))()
local NotificationHandler = NotificationLibrary:New({
	BackgroundColor = Color3.fromRGB(68, 71, 0), -- background color of the notification
	-- TitleColor = Color3.fromRGB(), -- title text color
	-- DescriptionColor = Color3.fromRGB(), -- description text color
	-- Mode = "Light", -- either "Dark" or "Light" | very important to set this so it looks better
	VerticalPosition = "Bottom", -- either "Top" or "Bottom"
	HorizontalPosition = "Right", -- either "Right" or "Left"
})

	NotificationHandler:Create({
		Title = "MadDuck",
		Description = "Get a job nigger stop skidding",
		Duration = 3,
		Image = "rbxassetid://11113512609",
	})
