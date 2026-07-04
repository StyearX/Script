
local serviceNames = {
    "Workspace", "Players", "ReplicatedStorage", "ReplicatedFirst",
    "ServerScriptService", "ServerStorage", "ScriptContext", "StarterGui",
    "CoreGui", "GuiService", "UserInputService", "ContextActionService",
    "GamepadService", "VirtualInputManager", "TweenService", "RunService",
    "PhysicsService", "Debris", "CollectionService", "PathfindingService",
    "HttpService", "MarketplaceService", "DataStoreService", "MemoryStoreService",
    "MessagingService", "TeleportService", "FriendsService", "GroupService",
    "GamePassService", "BadgeService", "SocialService", "Chat",
    "TextChatService", "TextService", "Lighting", "SoundService",
    "MaterialService", "RenderSettings", "AssetService", "AvatarEditorService",
    "InsertService", "ContentProvider", "Teams", "LogService", "VirtualUser",
    "HotbarService", "KeyframeSequenceProvider", "PartCacheService",
    "PolicyService", "ProximityPromptService", "Stats", "UserGameSettings",
    "UserSettings", "VRService", "VoiceChatService", "UgcValidationService",
    "IntersectService", "TestService"
}

for _, name in ipairs(serviceNames) do
    _G[name] = game:GetService(name)
end
