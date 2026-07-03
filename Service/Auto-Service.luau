local Environment = (type(getgenv) == "function") and getgenv() or _G

local ServiceList = {
	"Players",
	"Workspace",
	"ReplicatedStorage",
	"ReplicatedFirst",
	"ServerStorage",
	"ServerScriptService",
	"StarterGui",
	"StarterPack",
	"StarterPlayer",
	"Lighting",
	"SoundService",
	"TweenService",
	"RunService",
	"UserInputService",
	"HttpService",
	"TextService",
	"MarketplaceService",
	"TeleportService",
	"DataStoreService",
	"PathfindingService",
	"CollectionService",
	"ContextActionService",
	"GuiService",
	"ContentProvider",
	"CoreGui",
	"Chat",
	"TextChatService",
	"BadgeService",
	"InsertService",
	"PhysicsService",
	"Debris",
	"MaterialService",
	"VRService",
	"HapticService",
	"LocalizationService",
	"ProximityPromptService",
	"GamePassService",
	"GroupService",
	"SocialService",
	"MessagingService",
	"AnalyticsService",
	"LogService",
	"ScriptContext",
	"Stats",
	"AssetService",
	"KeyframeSequenceProvider",
	"AnimationClipProvider",
	"GamepadService",
	"JointsService",
	"KeyboardService",
	"MouseService",
	"NotificationService",
	"PointsService",
	"TestService",
	"TouchInputService",
	"VirtualUser",
	"CookiesService",
	"PolicyService",
	"AvatarEditorService",
	"UserService",
	"VoiceChatService",
	"TextBoxService",
	"VersionControlService",
}

for _, ServiceName in ipairs(ServiceList) do
	local Success, ServiceObject = pcall(game.GetService, game, ServiceName)
	if Success and ServiceObject then
		Environment[ServiceName] = ServiceObject
	end
end

if Environment.Players then
	if not Environment.Players.LocalPlayer then
		Environment.Players.PlayerAdded:Wait()
	end
	Environment.LocalPlayer = Environment.Players.LocalPlayer
end
