local serviceNames = {
    "Workspace", "Players", "ReplicatedStorage", "ReplicatedFirst", "TweenService",
    "Teams", "StarterGui", "GuiService", "CoreGui", "UserInputService",
    "ContextActionService", "HttpService", "MarketplaceService", "TeleportService",
    "RunService", "CollectionService", "Lighting", "SoundService", "Debris",
    "VirtualUser", "LogService", "AdService", "AnalyticsService", "AssetService", "AvatarEditorService", "BadgeService", "BrowserService", "BulkImportService",
    "CalloutService", "ChangeHistoryService", "Chat", "ChromeService", "ClientSettings",
    "CloudDataService", "CommercialService", "ContentProvider", "ContextualPromptService",
    "CookiesService", "CreationDBService", "CrossExperienceVoiceService", "DataStoreService",
    "EventIngameService", "ExperienceAuthService", "ExperienceNotificationService",
    "ExperienceStateCaptureService", "FaceAnimatorService", "FeatureService", "FriendService",
    "GamepadService", "GamePassService", "GeometryService", "GoogleAnalyticsService",
    "GroupService", "GuidRegistryService", "HapticService", "HeightmapImporterService",
    "HotbarService", "HttpRbxApiService", "IKService", "InGameMenuTaskService",
    "InsertService", "InternalSyncService", "InternalWebTaskService", "IntersectService",
    "InterventionService", "InventoryService", "JointsService", "KeyboardService",
    "KeyframeSequenceProvider", "LanguageService", "LiveScriptingService", "LocalNotificationService",
    "LuauScriptAnalyzerService", "MaterialService", "MemStorageService", "MessageBusService",
    "MemoryStoreService", "MessagingService", "MouseService", "NetworkClient",
    "NetworkServer", "NotificationService", "OmniRecommendationsService", "OpenCloudService",
    "PackageService", "ParallelRbxService", "PartCacheService", "PathfindingService",
    "PermissionsService", "PersonalServerService", "PhysicsService", "PlatformService",
    "PlayerEmulatorService", "PluginDebugService", "PluginGuiService", "PluginManagementService",
    "PluginNetworkService", "PluginPolicyService", "PointsService", "PolicyService",
    "ProcessInstancePhysicsService", "ProfileService", "ProximityPromptService", "PublishService",
    "RbxAnalyticsService", "RenderHooksService", "RenderingTestService", "RenderSettings",
    "ReplicationService", "RuntimeConfigService", "RuntimeScriptService", "SafetyService",
    "ScriptContext", "ScriptProfilerService", "ScriptRegistrationService", "Selection",
    "SensorService", "ServerFetchService", "ServerScriptService", "ServerStorage",
    "SessionService", "ShareVolumeService", "SkinningService", "SocialService",
    "SpawnerService", "StartPageService", "Stats", "StudioAssetService",
    "StudioDeviceEmulatorManager", "StudioPublishService", "StudioService", "SubscriptionService",
    "TestService", "TextChatService", "TextService", "TimerService",
    "TokenService", "TouchInputService", "TranslationService", "UgcValidationService",
    "UIComponentService", "UniversalAppPolicyService", "UrlService", "UserGameSettings",
    "UserService", "UserSettings", "VariantService", "VideoService",
    "VirtualInputManager", "Visit", "VoiceChatInternal", "VoiceChatService",
    "VRService", "WeakRefService", "WebFrameService"
}

for _, name in ipairs(serviceNames) do
    _G[name] = game:GetService(name)
end

_G.S = setmetatable({}, {
    __index = function(_, k)
        return game:GetService(k)
    end
})
