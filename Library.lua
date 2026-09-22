local cloneref = cloneref or clonereference or function(instance)
    return instance
end
local CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService = cloneref(game:GetService("GuiService"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local SoundService = cloneref(game:GetService("SoundService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local Teams = cloneref(game:GetService("Teams"))
local TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",
        Id = nil,
    },
    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",
        Id = nil,
    },
    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",
        Id = nil,
    },
    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",
        Id = nil,
    },
}

do
    local function RecursiveCreatePath(Path, IsFile)
        if not isfolder or not makefolder then
            return
        end
        local Segments = Path:split("/")
        local TraversedPath = ""
        if IsFile then
            table.remove(Segments, #Segments)
        end
        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end
            TraversedPath = TraversedPath .. Segment .. "/"
        end
        return TraversedPath
    end

    function CustomImageManager.AddAsset(AssetName, RobloxAssetId, URL, ForceRedownload)
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end
        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,
            Id = nil,
        }
        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end
        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end
        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)
        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)
            if Success and NewID then
                AssetID = NewID
            end
        end
        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
        if not getcustomasset or not writefile or not isfile then
            return false, nil
        end
        local AssetData = CustomImageManagerAssets[AssetName]
        RecursiveCreatePath(AssetData.Path, true)
        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end
        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)
        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,
    DevicePlatform = nil,
    IsMobile = false,
    ScreenGui = nil,
    Floats = nil,
    Overlay = nil,
    Window = nil,
    WindowContainer = nil,
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,
    ActiveTab = nil,
    PreviousTab = nil,
    Tabs = {},
    TabButtons = {},
    DependencyBoxes = {},
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},
    Notifications = {},
    NotifySide = "Right",
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Dialogues = {},
    ActiveDialog = nil,
    ActiveLoading = nil,
    ContextMenus = {}, 
    Corners = {},
    SpecificCorners = {},
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",
    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },
    Toggled = false,
    Unloaded = false,
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,
    NotifyOnError = false,
    ForceCheckbox = false,
    CantDragForced = false,
    DraggableElements = {},
    PopOutSnapDistance = 80,
    PopOutDragThreshold = 8,
    PopOutHoldTime = 0.15,
    Signals = {},
    UnloadSignals = {},
    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 6,
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(20, 20, 20),
        MainColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(96, 205, 255),
        OutlineColor = Color3.fromRGB(60, 60, 60),
        FontColor = Color3.fromRGB(240, 240, 240),
        Font = Font.fromEnum(Enum.Font.Gotham),
        RedColor = Color3.fromRGB(255, 90, 100),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),
        BackgroundImage = ""
    },
    Registry = {},
    Scales = {},
    ScalesOffset = {},
    ImageManager = CustomImageManager,
    Notify = nil, 
    Toggle = nil
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)
    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },
    Window = {
        Title = "No Title",
        Footer = "",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 540),
        IconSize = UDim2.fromOffset(24, 24),
        AutoShow = true,
        Center = true,
        Resizable = true,
        AlwaysOnTop = false,
        Snapping = false,
        SnapDistance = 28,
        SnapMargin = 8,
        SnapAvoidCoreGui = true,
        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,
        CornerRadius = 8,
        NotifySide = "Right",
        Font = Enum.Font.Gotham,
        ToggleKeybind = Enum.KeyCode.RightControl,
        ShowMobileButtons = true,
        MobileButtonsSide = "Left",
        UnlockMouseWhileOpen = true,
        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,
        MinSidebarWidth = 140,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,
        CompactWidthActivation = 128,
        BackgroundImage = "",
        Animations = {
            ToggleWindow = true,
            TabSwitch = true,
            Groupbox = true,
            Dropdown = true,
            KeyPicker = true,
        },
        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom",
        TabButtonsStyle = {
            Gap = 4,
            Padding = 6,
            CornerRadius = 6,
            Indicator = true,
            IndicatorWidth = 3,
            IndicatorHeight = 20,
        },
    },
    Groupbox = {
        Side = 1,
        Name = "Groupbox",
        IconName = nil,
        Description = nil,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Tabbox = {
        Side = 1,
        Name = nil,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "Loading",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(24, 24),
        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,
        CurrentStep = 0,
        TotalSteps = 10,
        ShowSidebar = false,
        AutoResizeHeight = false,
        AlwaysOnTop = true,
        WindowWidth = 450,
        WindowHeight = 275,
        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,
        Callback = function() end,
        Changed = function() end,
        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",
        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,
        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Prefix = "",
        Suffix = "",
        Callback = function() end,
        Changed = function() end,
        Disabled = false,
        Visible = true,
        AllowRightClickInput = true
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},
        Multi = false,
        DragSelect = false,
        MaxVisibleDropdownItems = 8,
        KeepDisabledValuePosition = false,
        Callback = function() end,
        Changed = function() end,
        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },
    KeyPicker = {
        Text = "KeyPicker",
        Default = "None",
        DefaultModifiers = {},
        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},
        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,
        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),
        Resizable = true,
        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}
local SideIndex = {
    left = 1,
    right = 2,
}

local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end
    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil
        return Library.Scheme[Index]
    end
    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        return Library.Scheme[AliasIndex]
    end
    return Library.Scheme[Index]
end

local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)
    local Result = Bindable.Event:Wait()
    Bindable:Destroy()
    return Result
end

local function IsMouseInput(Input, IncludeM2)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end

local function IsClickInput(Input, IncludeM2)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end

local function IsHoverInput(Input)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end

local function IsDragInput(Input, IncludeM2)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end

local function IsMouseClickInput(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or
        Input.UserInputType == Enum.UserInputType.MouseButton2 or
        Input.UserInputType == Enum.UserInputType.MouseButton3
end

local function IsMovementInput(Input)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table)
    local Size = 0
    for _, _ in Table do
        Size += 1
    end
    return Size
end

local function IsSequentialArray(Table)
    for Key in Table do
        if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
            return false
        end
    end
    return true
end

local function StopTween(Tween, Destroy)
    if not Tween then
        return
    end
    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end
    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end

local function Trim(Text)
    return Text:match("^%s*(.-)%s*$")
end

local function Round(Value, Rounding)
    if Rounding == 0 then
        return math.floor(Value)
    end
    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

local function FuzzyScore(Text, Search)
    if Search == "" then
        return true, 0
    end
    if Text == "" then
        return false, 0
    end

    local ExactIdx = Text:find(Search, 1, true)
    if ExactIdx then
        local PrevChar = ExactIdx > 1 and Text:sub(ExactIdx - 1, ExactIdx - 1) or ""
        local AtBoundary = ExactIdx == 1 or PrevChar:match("[%s%p_]") ~= nil
        return true, 1e5 - ExactIdx + (AtBoundary and 500 or 0) + (Search:len() * 5)
    end

    local TextLen, SearchLen = Text:len(), Search:len()
    if SearchLen > TextLen then
        return false, 0
    end

    local SearchIdx = 1
    local Score = 0
    local RunLength = 0
    local LastMatchIdx = 0

    for TextIdx = 1, TextLen do
        if SearchIdx > SearchLen then
            break
        end

        if Text:sub(TextIdx, TextIdx) == Search:sub(SearchIdx, SearchIdx) then
            local PrevChar = TextIdx > 1 and Text:sub(TextIdx - 1, TextIdx - 1) or ""
            local AtBoundary = TextIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

            RunLength = (LastMatchIdx == TextIdx - 1) and (RunLength + 1) or 1
            Score += 1 + (AtBoundary and 6 or 0) + math.min(RunLength - 1, 5) * 3

            LastMatchIdx = TextIdx
            SearchIdx += 1
        end
    end

    if SearchIdx <= SearchLen then
        return false, 0 
    end

    Score -= (LastMatchIdx - SearchLen) * 0.05
    return true, Score
end

local function NormalizeSearch(Search)
    return (Search:gsub("%s+", ""))
end

local function TryFuzzyMatch(Text, Search)
    if typeof(Text) ~= "string" or Text == "" then
        return false, 0
    end
    return FuzzyScore(Text:lower(), Search)
end

local function FuzzyMatchScore(Text, Search)
    if typeof(Text) ~= "string" or Text == "" then
        return 0
    end
    local Normalized = NormalizeSearch(Text:lower())
    local Matched, Score = FuzzyScore(Normalized, Search)
    if not Matched then
        return 0
    end
    if Normalized == Search then
        Score += 1000
    end
    return Score
end

local function MatchesSearch(ElementInfo, Search, ForceMatch)
    if not ElementInfo then
        return false
    end
    if ForceMatch then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Text, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Tooltip, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.DisabledTooltip, Search) then
        return true
    end
    if typeof(ElementInfo.Values) == "table" then
        local Checked = 0
        for Key, Value in ElementInfo.Values do
            Checked += 1
            if Checked > 200 then
                break
            end
            if TryFuzzyMatch(Value, Search) or (typeof(Value) ~= "string" and TryFuzzyMatch(tostring(Value), Search)) then
                return true
            end
            if typeof(Key) == "string" and TryFuzzyMatch(Key, Search) then
                return true
            end
        end
    end
    return false
end

local function GetPlayers(ExcludeLocalPlayer)
    local PlayerList = Players:GetPlayers()
    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end
    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)
    return PlayerList
end

local function GetTeams()
    local TeamList = Teams:GetTeams()
    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)
    return TeamList
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end
    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

function Library:UpdateAddons(Parent)
    if not Parent or not Parent.Addons then
        return
    end
    for _, Addon in Parent.Addons do
        Addon:Update()
    end
end

local function CheckDepbox(Box, Search, ForceVisible)
    local VisibleElements = 0
    local BestScore = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            local Visible = false
            if MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Base.Visible = false
            end
            if MatchesSearch(ElementInfo.SubButton, Search, ForceVisible) and ElementInfo.SubButton.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end
            continue
        end

        if ElementInfo.Text and MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
            BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end
        local DepVisible, DepScore = CheckDepbox(Depbox, Search, ForceVisible)
        VisibleElements += DepVisible
        if DepScore > BestScore then
            BestScore = DepScore
        end
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements, BestScore
end

local function RestoreDepbox(Box)
    for _, ElementInfo in Box.Elements do
        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false
        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end
    Box:Resize()
    Box.Holder.Visible = true
    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end
        RestoreDepbox(Depbox)
    end
end

function SyncPopOutVisibility(Box)
    if not Box.PopOutFloat then
        return
    end
    Box.PopOutFloat.Visible = Box.BoxHolder.Visible ~= false and Box.Visible ~= false
end

local function DimPopOutClone(Root)
    for _, Descendant in Root:QueryDescendants("TextLabel, TextButton, TextBox") do
        Descendant.TextTransparency = math.max(Descendant.TextTransparency, 0.45)
    end
    for _, Descendant in Root:QueryDescendants("ImageLabel, ImageButton") do
        Descendant.ImageTransparency = math.max(Descendant.ImageTransparency, 0.45)
    end
    for _, Descendant in Root:QueryDescendants("GuiButton") do
        Descendant.Active = false
        Descendant.AutoButtonColor = false
    end
end

local function IsScreenPointOutsideMain(Point)
    local MainFrame = Library.Window and Library.Window.MainFrame
    if not MainFrame or not Library.Toggled or not MainFrame.Visible then
        return true
    end
    return not Library:MouseIsOverFrame(MainFrame, Point)
end

local function GetTopFloatAt(Point)
    local Best = nil
    local BestOrder = -math.huge
    local Floats = Library.Floats

    for _, Surface in Library.DraggableElements do
        if not Surface or not Surface.Parent or not Surface.Visible then
            continue
        end
        if Floats and Surface.Parent ~= Floats then
            continue
        end
        if not Library:MouseIsOverFrame(Surface, Point) then
            continue
        end
        local SiblingIndex = tonumber(select(2, pcall(function() return Surface:GetSiblingIndex() end))) or 0
        local Order = Surface.ZIndex * 100000 + SiblingIndex
        if Order >= BestOrder then
            BestOrder = Order
            Best = Surface
        end
    end
    return Best
end

local function GetPopOutBodyMaxHeight(Box, Reserved)
    local Float = Box.PopOutFloat
    local ScreenGui = Library.ScreenGui
    if not Float or not ScreenGui then
        return math.huge
    end
    local Gap = 12 * Library.DPIScale
    local MaxBottom = ScreenGui.AbsolutePosition.Y + ScreenGui.AbsoluteSize.Y - Gap
    local Available = math.min(MaxBottom - Float.AbsolutePosition.Y, ScreenGui.AbsoluteSize.Y * 0.9)
    local ScreenMax = math.max(0, Available / Library.DPIScale - Reserved)
    local CustomMax = Box.PopOutMaxHeight
    if typeof(CustomMax) == "number" then
        return math.min(ScreenMax, math.max(0, CustomMax))
    end
    return ScreenMax
end

local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return false, 0
    end
    local HasVisible = false
    local BestScore = 0
    local TabMatches = TryFuzzyMatch(Tab.Name, Search) or TryFuzzyMatch(Tab.Description, Search)
    BestScore = math.max(BestScore, FuzzyMatchScore(Tab.Name, Search), FuzzyMatchScore(Tab.Description, Search))

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end
        local GroupboxMatches = TabMatches or (TryFuzzyMatch(Groupbox.Name, Search) or TryFuzzyMatch(Groupbox.Description, Search))
        BestScore = math.max(BestScore, FuzzyMatchScore(Groupbox.Name, Search), FuzzyMatchScore(Groupbox.Description, Search))
        local VisibleElements = 0

        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                local Visible = false
                if MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
                else
                    ElementInfo.Base.Visible = false
                end
                if MatchesSearch(ElementInfo.SubButton, Search, GroupboxMatches) and ElementInfo.SubButton.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
                else
                    ElementInfo.SubButton.Base.Visible = false
                end
                ElementInfo.Holder.Visible = Visible
                if Visible then
                    VisibleElements += 1
                end
                continue
            end
            if ElementInfo.Text and MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end
            local DepVisible, DepScore = CheckDepbox(Depbox, Search, GroupboxMatches)
            VisibleElements += DepVisible
            if DepScore > BestScore then
                BestScore = DepScore
            end
        end

        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}
        local SubTabScores = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0
            local SubTabMatches = TabMatches or TryFuzzyMatch(SubTab.Name, Search)
            local SubScore = FuzzyMatchScore(SubTab.Name, Search)
            BestScore = math.max(BestScore, SubScore)

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    local Visible = false
                    if MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.Base.Visible = false
                    end
                    if MatchesSearch(ElementInfo.SubButton, Search, SubTabMatches) and ElementInfo.SubButton.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.SubButton.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end
                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end
                    continue
                end
                if ElementInfo.Text and MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                    local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                    SubScore = math.max(SubScore, ElementScore)
                    BestScore = math.max(BestScore, ElementScore)
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end
                local DepVisible, DepScore = CheckDepbox(Depbox, Search, SubTabMatches)
                VisibleElements[SubTab] += DepVisible
                SubScore = math.max(SubScore, DepScore)
                BestScore = math.max(BestScore, DepScore)
            end
            SubTabScores[SubTab] = SubScore
        end

        local BestSubTab = nil
        local BestSubScore = -1

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true
                local SubScore = SubTabScores[SubTab] or 0
                if SubScore > BestSubScore then
                    BestSubScore = SubScore
                    BestSubTab = SubTab
                end
            end
        end

        local ActiveSubTab = Tabbox.ActiveTab
        local ActiveSubVisible = ActiveSubTab and (VisibleElements[ActiveSubTab] or 0) > 0
        local ActiveSubScore = ActiveSubTab and (SubTabScores[ActiveSubTab] or -1) or -1

        if ActiveSubVisible and ActiveSubScore >= BestSubScore then
            ActiveSubTab:Resize()
        elseif BestSubTab then
            BestSubTab:Show()
        end

        Tabbox.BoxHolder.Visible = VisibleTabs > 0
        SyncPopOutVisibility(Tabbox)
    end

    return HasVisible, BestScore
end

local function ResetTab(Tab)
    if not Tab then
        return
    end
    for _, Groupbox in Tab.Groupboxes do
        for _, ElementInfo in Groupbox.Elements do
            ElementInfo.Holder.Visible = ElementInfo.Visible ~= false
            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end
        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end
            RestoreDepbox(Depbox)
        end
        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = Groupbox.Visible ~= false
        SyncPopOutVisibility(Groupbox)
    end
    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            for _, ElementInfo in SubTab.Elements do
                ElementInfo.Holder.Visible = ElementInfo.Visible ~= false
                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end
            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end
                RestoreDepbox(Depbox)
            end
            SubTab.ButtonHolder.Visible = true
        end
        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
        SyncPopOutVisibility(Tabbox)
    end
end

function Library:UpdateSearch(SearchText)
    Library.SearchText = SearchText
    local TabsToSearch = {}
    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and not Tab.IsKeyTab then
            table.insert(TabsToSearch, Tab)
        end
    end
    for _, Tab in TabsToSearch do
        ResetTab(Tab)
    end
    local Search = NormalizeSearch(SearchText:lower())
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true
    local BestTab = nil
    local BestScore = -1
    local ActiveScore = -1
    local ActiveHasVisible = false

    for _, Tab in TabsToSearch do
        local HasVisible, Score = ApplySearchToTab(Tab, Search)
        if not HasVisible then
            continue
        end
        if Tab == Library.ActiveTab then
            ActiveHasVisible = true
            ActiveScore = Score
        end
        if Score > BestScore then
            BestScore = Score
            BestTab = Tab
        end
    end

    if not Library.GlobalSearch then
        for _, Tab in TabsToSearch do
            if Tab ~= BestTab then
                ResetTab(Tab)
            end
        end
    end

    local StayOnActive = ActiveHasVisible and ActiveScore >= BestScore
    if StayOnActive and Library.ActiveTab then
        Library.ActiveTab:RefreshSides()
    elseif BestTab then
        local SearchMarker = SearchText
        task.defer(function()
            if Library.SearchText ~= SearchMarker then
                return
            end
            if Library.ActiveTab ~= BestTab then
                BestTab:Show()
            elseif Library.ActiveTab then
                Library.ActiveTab:RefreshSides()
            end
        end)
    end
    Library.LastSearchTab = nil
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)
            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
end

function Library:SetDPIScale(DPIScale)
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale
    for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
    end
    for _, Option in Options do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
            Option:RefreshPool()
        end
    end
    for _, Notification in Library.Notifications do
        Notification:Resize()
    end
end

function Library:GiveSignal(Connection)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end
    return Connection
end

local function IsValidCustomIcon(Icon)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function IsCustomAssetIcon(Icon, IncludeAssetId)
    return typeof(Icon) == "string" and (Icon:match("^content://") or (Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/")) or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

local FetchIcons = false
local Icons = nil

function Library:GetIcon(IconName)
    if not FetchIcons or not Icons then
        return
    end
    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end
    return Icon
end

function Library:GetCustomIcon(IconName)
    if not IconName then
        return nil
    end
    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end
    if IsCustomAssetIcon(IconName, true) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    elseif IsValidCustomIcon(IconName) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end
    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end
    return nil
end

function Library:ApplyLucideIcon(ImageGui, Icon, Rotation)
    if not ImageGui or not Icon then
        return
    end
    if not (ImageGui:IsA("ImageLabel") or ImageGui:IsA("ImageButton")) then
        return
    end
    ImageGui.Image = Icon.Url or ImageGui.Image
    ImageGui.ImageRectOffset = Icon.ImageRectOffset or ImageGui.ImageRectOffset 
    ImageGui.ImageRectSize = Icon.ImageRectSize or ImageGui.ImageRectSize
    ImageGui.Rotation = Rotation or ImageGui.Rotation
end

function Library:Validate(Table, Template)
    if typeof(Table) ~= "table" then
        return Template
    end
    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end
        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end
    return Table
end

local function FillInstance(Table, Instance)
    local ThemeProperties = Library.Registry[Instance] or {}
    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)
            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end
        Instance[key] = value
    end
    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName, Properties)
    local Instance = Instance.new(ClassName)
    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)
    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end
    return Instance
end

local function SafeParentUI(Instance, Parent)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end
        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end
        Instance.Parent = DestinationParent
    end)
    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI, SkipHiddenUI)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end
    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function SetAlwaysOnTop(Gui, Enabled)
    if not Gui then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Gui, "OnTopOfCoreBlur", Enabled)
        elseif setscriptable then
            setscriptable(Gui, "OnTopOfCoreBlur", true)
            Gui.OnTopOfCoreBlur = Enabled
            setscriptable(Gui, "OnTopOfCoreBlur", false)
        end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "Obsidian",
    DisplayOrder = 998,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    task.defer(function()
        if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
            return
        end
        Library:RemoveFromRegistry(Instance)
    end)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

local Floats = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 10,
    Active = false,
    Parent = ScreenGui,
})

local Overlay = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20,
    Active = false,
    Parent = ScreenGui,
})

Library.Floats = Floats
Library.Overlay = Overlay

local NotificationArea
local NotifyOrder = {}
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        ZIndex = 200,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

local CheckIcon, ArrowIcon, ResizeIcon, KeyIcon, MoveIcon, PopOutIcon, CloseIcon

function Library:SetIconModule(module)
    FetchIcons = true
    Icons = module
    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
    PopOutIcon = Library:GetIcon("square-arrow-down-left")
    CloseIcon = Library:GetIcon("x")
end

local OnlineFetchIcons, OnlineIcons = pcall(function()
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua")
    ))()
end)

if OnlineFetchIcons and OnlineIcons then
    Library:SetIconModule(OnlineIcons)
end

function Library.Cursor:ResetCross() end
function Library.Cursor:ResetIcon() end
function Library.Cursor:ResetCursor() end
function Library.Cursor:ChangeCrossColor() end
function Library.Cursor:ChangeIcon() end
function Library.Cursor:ChangeIconColor() end
function Library.Cursor:ChangeIconSize() end
function Library:ChangeCursorCrossColor() end
function Library:ResetCursorCross() end
function Library:ChangeCursorIcon() end
function Library:ChangeCursorIconColor() end
function Library:ChangeCursorIconSize() end
function Library:ResetCursorIcon() end

function Library:GetBetterColor(Color, Add)
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color)
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color)
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end
    return KeyCode.Name
end

function Library:GetTextBounds(Text, Font, Size, Width)
    local Scale = Library.DPIScale
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size * Scale
    if Width then
        Params.Width = Width * Scale
    else
        Params.Width = workspace.CurrentCamera.ViewportSize.X - 32
    end
    local Bounds = TextService:GetTextBoundsAsync(Params)
    return math.ceil(Bounds.X / Scale), math.ceil(Bounds.Y / Scale)
end

function Library:MouseIsOverFrame(Frame, Mouse)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:IsInsideFrame(ParentFrame, Frame)
    local GuiPos = Frame.AbsolutePosition
    local GuiSize = Frame.AbsoluteSize
    local FramePos = ParentFrame.AbsolutePosition
    local FrameSize = ParentFrame.AbsoluteSize
    return GuiPos.X >= FramePos.X
        and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X
        and GuiPos.Y >= FramePos.Y
        and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end

function Library:SafeCallback(Func, ...)
    if not (Func and typeof(Func) == "function") then
        return
    end
    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError and Library.Notify then
            Library:Notify(Error)
        end
        return Error
    end, ...))
    if not Result[1] then
        return nil
    end
    return table.unpack(Result, 2, Result.n)
end

local function GetOverlappingDraggable(UI, TargetPos)
    local Pos1 = TargetPos or UI.AbsolutePosition
    local Size1 = UI.AbsoluteSize
    for _, Other in ipairs(Library.DraggableElements) do
        if Other == UI or not Other.Visible or not Other.Parent then
            continue
        end
        local Pos2 = Other.AbsolutePosition
        local Size2 = Other.AbsoluteSize
        if Pos1.X < Pos2.X + Size2.X and
            Pos1.X + Size1.X > Pos2.X and
            Pos1.Y < Pos2.Y + Size2.Y and
            Pos1.Y + Size1.Y > Pos2.Y then
            return Other
        end
    end
    return nil
end

local function GetNonOverlappingPosition(UI, StartPos)
    local ScreenSize = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)) - Vector2.new(100, 100)
    local Start = StartPos and Vector2.new(StartPos.X.Offset, StartPos.Y.Offset) or Vector2.new(6, 6)
    local Padding = 6
    local CurrentX = Start.X
    local CurrentY = Start.Y
    local Size = UI.AbsoluteSize
    if Size.X == 0 and Size.Y == 0 then
        RunService.RenderStepped:Wait()
        Size = UI.AbsoluteSize
    end
    if Size.X == 0 then Size = Vector2.new(150, 40) end
    local MaxXInColumn = Size.X

    while true do
        local Obstacle = GetOverlappingDraggable(UI, Vector2.new(CurrentX, CurrentY))
        if not Obstacle then
            break
        end
        if Obstacle.AbsoluteSize.X > MaxXInColumn then
            MaxXInColumn = Obstacle.AbsoluteSize.X
        end
        local NextY = Obstacle.AbsolutePosition.Y + Obstacle.AbsoluteSize.Y + Padding
        if NextY + Size.Y > ScreenSize.Y - Padding then
            local NextX = CurrentX + MaxXInColumn + Padding
            if NextX + Size.X > ScreenSize.X - Padding then
                break
            end
            CurrentY = Start.Y
            CurrentX = NextX
            MaxXInColumn = Size.X
        else
            CurrentY = NextY
        end
    end
    return UDim2.fromOffset(CurrentX, CurrentY)
end

local function PositionDraggable(UI, StartPos)
    UI.Position = GetNonOverlappingPosition(UI, StartPos)
end

local function GetCoreGuiInset()
    local Success, TopLeft, BottomRight = pcall(function()
        return GuiService:GetGuiInset()
    end)
    if Success and TopLeft and BottomRight then
        return TopLeft, BottomRight
    end
    return Vector2.zero, Vector2.zero
end

local function GetSnapEdges(ElemSize, ViewportSize, Margin, AvoidCoreGui)
    local SafeMin, SafeMax = Vector2.zero, ViewportSize
    if AvoidCoreGui then
        local TopLeftInset, BottomRightInset = GetCoreGuiInset()
        SafeMin = TopLeftInset
        SafeMax = ViewportSize - BottomRightInset
    end
    local TargetsX = {
        LeftEdge = SafeMin.X + Margin,
        Center = SafeMin.X + (SafeMax.X - SafeMin.X - ElemSize.X) / 2,
        RightEdge = SafeMax.X - ElemSize.X - Margin,
    }
    local TargetsY = {
        TopEdge = SafeMin.Y + Margin,
        Center = SafeMin.Y + (SafeMax.Y - SafeMin.Y - ElemSize.Y) / 2,
        BottomEdge = SafeMax.Y - ElemSize.Y - Margin,
    }
    return TargetsX, TargetsY
end

local function GetClosestSnapTarget(Value, Targets, Distance)
    local ClosestName, ClosestValue, ClosestDist = nil, nil, Distance
    for Name, Target in Targets do
        local Dist = math.abs(Value - Target)
        if Dist <= ClosestDist then
            ClosestDist = Dist
            ClosestName = Name
            ClosestValue = Target
        end
    end
    return ClosestValue, ClosestName
end

local function GetSnapGuideOffset(Name, SnappedValue, ElemDimension)
    if Name == "RightEdge" or Name == "BottomEdge" then
        return SnappedValue + ElemDimension
    elseif Name == "Center" then
        return SnappedValue + ElemDimension / 2
    end
    return SnappedValue
end

function Library:MakeDraggable(UI, DragFrame, IgnoreToggled, IsMainWindow, SnapConfig)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged
    local SnapGuideX, SnapGuideY

    local function GetSnapGuides()
        if not SnapGuideX then
            SnapGuideX = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 2, 1, 0),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end
        if not SnapGuideY then
            SnapGuideY = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end
        return SnapGuideX, SnapGuideY
    end

    local function HideSnapGuides()
        if SnapGuideX then
            SnapGuideX.Visible = false
        end
        if SnapGuideY then
            SnapGuideY.Visible = false
        end
    end

    InputBegan = DragFrame.InputBegan:Connect(function(Input)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end
        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end
            Dragging = false
            HideSnapGuides()
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input)
        if (not IgnoreToggled and not Library.Toggled) or (IsMainWindow and Library.CantDragForced) or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            HideSnapGuides()
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            local NewX = FramePos.X.Offset + Delta.X
            local NewY = FramePos.Y.Offset + Delta.Y

            if SnapConfig and SnapConfig.Enabled then
                local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local Distance = SnapConfig.Distance or 28
                local Margin = SnapConfig.Margin or 8
                local AbsX = FramePos.X.Scale * ViewportSize.X + NewX
                local AbsY = FramePos.Y.Scale * ViewportSize.Y + NewY
                local ElemSize = UI.AbsoluteSize
                local TargetsX, TargetsY = GetSnapEdges(ElemSize, ViewportSize, Margin, SnapConfig.AvoidCoreGui ~= false)
                local SnappedX, SnappedXName = GetClosestSnapTarget(AbsX, TargetsX, Distance)
                local SnappedY, SnappedYName = GetClosestSnapTarget(AbsY, TargetsY, Distance)

                if SnappedX then
                    NewX = SnappedX - FramePos.X.Scale * ViewportSize.X
                end
                if SnappedY then
                    NewY = SnappedY - FramePos.Y.Scale * ViewportSize.Y
                end

                local GuideX, GuideY = GetSnapGuides()
                GuideX.Visible = SnappedX ~= nil
                if SnappedX then
                    GuideX.Position = UDim2.fromOffset(GetSnapGuideOffset(SnappedXName, SnappedX, ElemSize.X), 0)
                end
                GuideY.Visible = SnappedY ~= nil
                if SnappedY then
                    GuideY.Position = UDim2.fromOffset(0, GetSnapGuideOffset(SnappedYName, SnappedY, ElemSize.Y))
                end
            end
            UI.Position = UDim2.new(FramePos.X.Scale, NewX, FramePos.Y.Scale, NewY)
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end
        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end
        if Changed and Changed.Connected then
            Changed:Disconnect()
        end
        if SnapGuideX then
            SnapGuideX:Destroy()
        end
        if SnapGuideY then
            SnapGuideY:Destroy()
        end
        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end
        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeResizable(UI, DragFrame, Callback)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    InputBegan = DragFrame.InputBegan:Connect(function(Input)
        if not IsClickInput(Input) then
            return
        end
        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
            return
        end
        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end
        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end
        if Changed and Changed.Connected then
            Changed:Disconnect()
        end
        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end
        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeCover(Holder, Place)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }
    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })
    return Cover
end

function Library:MakeLine(Frame, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        LayoutOrder = Info.LayoutOrder or 0,
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })
    return Line
end

function Library:AddOutline(Frame)
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1,
        ZIndex = 2,
        Parent = Frame,
    })
    local ShadowStroke = New("UIStroke", {
        Color = "DarkColor",
        Thickness = 1,
        Transparency = 0.5,
        ZIndex = 1,
        Parent = Frame,
    })
    return OutlineStroke, ShadowStroke
end

function Library:AddBlank(Frame, Size)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

local TransparencyCache = {}
local ActiveTabTweens = setmetatable({}, { __mode = "k" })

function Library:PlayTabAnimation(Tab, Showing, OnComplete)
    if type(Tab) ~= "table" or not Tab.Container then
        if OnComplete then
            OnComplete()
        end
        return
    end

    local TabContainer = Tab.Container
    local Existing = ActiveTabTweens[TabContainer]
    if Existing then
        StopTween(Existing, true)
        ActiveTabTweens[TabContainer] = nil
    end

    local BaseZIndex = TabContainer.ZIndex
    if not (Library.Animations and Library.Animations.TabSwitch) then
        TabContainer.Visible = Showing
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex
        if OnComplete then
            OnComplete()
        end
        return
    end

    if Showing then
        local TweenInfo = Library.TabTransitionInfo or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Offset = Library.TabSwipeOffset or 26
        local SwipeFrom = string.lower(Library.TabSwipeFrom or "bottom")
        local StartPosition
        local StartingPositions = {
            Left = UDim2.fromOffset(-Offset, 0),
            Right = UDim2.fromOffset(Offset, 0),
            Top = UDim2.fromOffset(0, -Offset),
            Bottom = UDim2.fromOffset(0, Offset),
        }

        if SwipeFrom == "auto" and Library.PreviousTab then
            local CurrentOrder = Tab.Button.LayoutOrder
            local PreviousOrder = Library.PreviousTab.Button.LayoutOrder
            if CurrentOrder and PreviousOrder then
                StartPosition = CurrentOrder > PreviousOrder and StartingPositions.Top or StartingPositions.Bottom
            else
                StartPosition = StartingPositions.Bottom
            end
        elseif SwipeFrom == "left" then
            StartPosition = StartingPositions.Left
        elseif SwipeFrom == "top" then
            StartPosition = StartingPositions.Top
        elseif SwipeFrom == "right" then
            StartPosition = StartingPositions.Right
        else
            StartPosition = StartingPositions.Bottom
        end

        TabContainer.ZIndex = BaseZIndex + 1
        TabContainer.Position = StartPosition
        TabContainer.Visible = true

        local Tween = TweenService:Create(TabContainer, TweenInfo, {
            Position = UDim2.fromScale(0, 0)
        })

        ActiveTabTweens[TabContainer] = Tween
        Tween:Play()

        local Connection; Connection = Tween.Completed:Connect(function(PlaybackState)
            if Connection then
                Connection:Disconnect()
            end
            if ActiveTabTweens[TabContainer] == Tween then
                ActiveTabTweens[TabContainer] = nil
            end
            if PlaybackState == Enum.PlaybackState.Cancelled then
                return
            end
            TabContainer.ZIndex = BaseZIndex
            if OnComplete then
                OnComplete()
            end
        end)
    else
        TabContainer.Visible = false
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex
        if OnComplete then
            OnComplete()
        end
    end
end

function Library:MakeBoxPopOut(Box, Options)
    Box.PoppedOut = false
    Box.PopOutEnabled = Options.Enabled ~= false
    Box.PopOutFloat = nil
    Box.PopOutPlaceholder = nil
    Box.PopOutMaxHeight = if typeof(Options.MaxPopOutHeight) == "number" then Options.MaxPopOutHeight else nil
    Box.PopOutWidth = if typeof(Options.PopOutWidth) == "number" then Options.PopOutWidth else nil

    if not Box.PopOutEnabled then
        function Box:SetPoppedOut() end
        function Box:TogglePoppedOut() end
        function Box:RefreshPopOutPlaceholder() end
        function Box:SetMaxPopOutHeight() end
        function Box:SetPopOutWidth() end
        return
    end

    local BoxHolder = Box.BoxHolder
    local Holder = Box.Holder
    local Header = Options.Header
    local Placeholder
    local PlaceholderHeader
    local Float
    local FloatScale
    local HandledChildren = {}
    local OriginalParents = {}
    local OriginalLayoutOrders = {}
    local DragState = "Idle"
    local DragInput
    local PressMouse
    local DragStartPos
    local DragChanged
    local DragDidMove = false

    local function GetPopOutWidth()
        if typeof(Box.PopOutWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutWidth + 0.5))
        end
        if typeof(Box.PopOutDockedWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutDockedWidth + 0.5))
        end
        local Width = Holder.AbsoluteSize.X / Library.DPIScale
        if Width < 50 then
            Width = 200
        end
        return math.max(50, math.floor(Width + 0.5))
    end

    local function ApplyPopOutWidth()
        if not (Box.PoppedOut and Float) then
            return
        end
        Float.Size = UDim2.fromOffset(GetPopOutWidth(), Float.Size.Y.Offset)
        if Box.Resize then
            Box:Resize()
        end
    end

    local function RaiseFloat()
        if not Float or not Floats then
            return
        end
        local MaxZ = Float.ZIndex
        for _, Child in Floats:GetChildren() do
            if Child:IsA("GuiObject") and Child ~= Float then
                MaxZ = math.max(MaxZ, Child.ZIndex)
            end
        end
        Float.ZIndex = MaxZ + 1
        if Float.Parent == Floats then
            Float.Parent = Overlay
        end
        Float.Parent = Floats
    end

    local function CreatePlaceholder()
        local Frame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.12,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = BoxHolder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Frame,
            })
        )
        Library:AddOutline(Frame)

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Frame
        DimPopOutClone(PlaceholderHeader)

        if PopOutIcon then
            local PlaceholderDockIcon = New("ImageButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = "WhiteColor",
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                ZIndex = PlaceholderHeader.ZIndex + 1,
                Parent = Frame,
            })
            Library:ApplyLucideIcon(PlaceholderDockIcon, PopOutIcon)
            PlaceholderDockIcon.MouseButton1Click:Connect(function()
                Box:SetPoppedOut(false)
            end)
        end
        return Frame
    end

    function Box:RefreshPopOutPlaceholder()
        if not Box.PoppedOut or not Placeholder or not Header then
            return
        end
        if PlaceholderHeader then
            PlaceholderHeader:Destroy()
            PlaceholderHeader = nil
        end
        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Placeholder
        DimPopOutClone(PlaceholderHeader)
    end

    function Box:SetPoppedOut(Value, FloatPosition)
        if not Box.PopOutEnabled or Box.Destroyed then
            return
        end
        Value = Value == true
        if Box.PoppedOut == Value then
            if Value and FloatPosition and Float then
                Float.Position = FloatPosition
            end
            return
        end

        if Value then
            if Options.Before then
                Options.Before()
            end
            local BoxChildren = if Options.Children then Options.Children() else { Holder }
            HandledChildren = {}
            table.clear(OriginalParents)
            table.clear(OriginalLayoutOrders)

            for _, Child in BoxChildren do
                if not Child or not Child.Parent then
                    continue
                end
                table.insert(HandledChildren, Child)
                OriginalParents[Child] = Child.Parent
                OriginalLayoutOrders[Child] = Child.LayoutOrder
            end
            if #HandledChildren == 0 then
                return
            end

            local DockedWidth = Holder.AbsoluteSize.X / Library.DPIScale
            if DockedWidth < 50 then DockedWidth = 200 end
            Box.PopOutDockedWidth = math.max(50, math.floor(DockedWidth + 0.5))

            local Width = GetPopOutWidth()
            local AbsolutePosition = Holder.AbsolutePosition
            Placeholder = CreatePlaceholder()
            Box.PopOutPlaceholder = Placeholder

            Float = New("Frame", {
                Active = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = FloatPosition or UDim2.fromOffset(AbsolutePosition.X / Library.DPIScale, AbsolutePosition.Y / Library.DPIScale),
                Size = UDim2.fromOffset(Width, 0),
                ZIndex = 1,
                Parent = Floats,
            })
            FloatScale = New("UIScale", {
                Parent = Float,
            })
            table.insert(Library.Scales, FloatScale)
            FloatScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[FloatScale]) or 0)

            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = Float,
            })

            for _, Child in HandledChildren do
                Child.Parent = Float
            end

            if not table.find(Library.DraggableElements, Float) then
                table.insert(Library.DraggableElements, Float)
            end

            Box.PopOutFloat = Float
            Box.PoppedOut = true
            SyncPopOutVisibility(Box)
            RaiseFloat()

            Float:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                Box:Resize()
            end)

            if Options.After then
                Options.After()
            end
            return
        end

        if Float then
            local DraggableIndex = table.find(Library.DraggableElements, Float)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end
        end

        if FloatScale then
            local ScaleIndex = table.find(Library.Scales, FloatScale)
            if ScaleIndex then
                table.remove(Library.Scales, ScaleIndex)
            end
            FloatScale = nil
        end

        for _, Child in HandledChildren do
            if not Child or not Child.Parent then continue end
            Child.Parent = OriginalParents[Child] or BoxHolder
            Child.LayoutOrder = OriginalLayoutOrders[Child] or 0
        end

        if Placeholder then
            Placeholder:Destroy()
            Placeholder = nil
        end
        PlaceholderHeader = nil
        if Float then
            Float:Destroy()
            Float = nil
        end

        Box.PopOutFloat = nil
        Box.PopOutPlaceholder = nil
        Box.PopOutDockedWidth = nil
        Box.PoppedOut = false

        table.clear(HandledChildren)
        table.clear(OriginalParents)
        table.clear(OriginalLayoutOrders)

        if Options.After then
            Options.After()
        end
    end

    function Box:TogglePoppedOut()
        Box:SetPoppedOut(not Box.PoppedOut)
    end

    function Box:SetMaxPopOutHeight(Height)
        Box.PopOutMaxHeight = Height
        if Box.PoppedOut and Box.Resize then
            Box:Resize()
        end
    end

    function Box:SetPopOutWidth(Width)
        Box.PopOutWidth = Width
        ApplyPopOutWidth()
    end

    local function StopDrag()
        if DragState == "Idle" then
            return
        end
        local WasDragging = DragState == "Dragging"
        local DidMove = DragDidMove
        DragState = "Idle"
        DragInput = nil
        PressMouse = nil
        DragStartPos = nil
        DragDidMove = false

        if DragChanged and DragChanged.Connected then
            DragChanged:Disconnect()
            DragChanged = nil
        end

        if not WasDragging or not Box.PoppedOut or not Float then
            return
        end

        local FloatCenter = Float.AbsolutePosition + (Float.AbsoluteSize * 0.5)
        local NearPlaceholder = false
        if Library.Toggled and Placeholder and Placeholder.Parent then
            local PlaceholderCenter = Placeholder.AbsolutePosition + (Placeholder.AbsoluteSize * 0.5)
            NearPlaceholder = (FloatCenter - PlaceholderCenter).Magnitude <= Library.PopOutSnapDistance
        end

        if NearPlaceholder or (DidMove and not IsScreenPointOutsideMain(FloatCenter)) then
            Box:SetPoppedOut(false)
        end
    end

    local function BeginDrag(Input)
        if DragState ~= "Idle" or Box.Destroyed or not (ScreenGui and ScreenGui.Parent) then
            return
        end
        local Point = Vector2.new(Input.Position.X, Input.Position.Y)
        local Top = GetTopFloatAt(Point)
        if Box.PoppedOut then
            if not Float or Top ~= Float then
                return
            end
        elseif Top ~= nil and not Header:IsDescendantOf(Top) then
            return
        end

        DragState = "Holding"
        DragInput = Input
        PressMouse = Vector2.new(Input.Position.X, Input.Position.Y)
        DragStartPos = nil
        DragDidMove = false

        if Box.PoppedOut and Float then
            RaiseFloat()
        end

        DragChanged = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                StopDrag()
            end
        end)

        task.delay(Library.PopOutHoldTime, function()
            if DragState ~= "Holding" or DragInput ~= Input then
                return
            end
            DragState = "Dragging"
            if Box.PoppedOut and Float then
                RaiseFloat()
                DragStartPos = Float.Position
            end
        end)
    end

    local function UpdateDrag(Input)
        if DragState ~= "Dragging" or not PressMouse then
            return
        end
        if not (ScreenGui and ScreenGui.Parent) then
            StopDrag()
            return
        end

        local MousePosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Delta = MousePosition - PressMouse

        if not Box.PoppedOut then
            if Delta.Magnitude < Library.PopOutDragThreshold then
                return
            end
            Box:SetPoppedOut(true)
            if not Float then return end
            RaiseFloat()
            DragStartPos = Float.Position
            DragDidMove = true
        elseif Delta.Magnitude >= Library.PopOutDragThreshold then
            DragDidMove = true
        end

        if Float and DragStartPos then
            Float.Position = UDim2.new(
                DragStartPos.X.Scale,
                DragStartPos.X.Offset + Delta.X,
                DragStartPos.Y.Scale,
                DragStartPos.Y.Offset + Delta.Y
            )
        end
    end

    local function BindDragSource(Gui)
        Library:GiveSignal(Gui.InputBegan:Connect(function(Input)
            if IsClickInput(Input) then
                BeginDrag(Input)
            end
        end))
    end

    BindDragSource(Header)
    for _, Descendant in Header:QueryDescendants("GuiObject:not(ImageButton)") do
        BindDragSource(Descendant)
    end
    Library:GiveSignal(Header.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("GuiObject") and not Descendant:IsA("ImageButton") then
            BindDragSource(Descendant)
        end
    end))
    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
        if IsHoverInput(Input) then
            UpdateDrag(Input)
        end
    end))
end

function Library:AddDraggableLabel(...)
    local Params = select(1, ...)
    local Text
    local Icon
    local IconPosition = "left"

    if typeof(Params) == "table" then
        Text = Params.Text
        Icon = Params.Icon
        IconPosition = Params.IconPosition or "left"
    elseif typeof(Params) == "string" then
        Text = Params
        Icon = select(2, ...)
        IconPosition = select(3, ...) or "left"
    end

    if typeof(IconPosition) ~= "string" then
        IconPosition = "left"
    end
    IconPosition = string.lower(IconPosition)

    local DraggableLabel = {
        Connections = {},
        Destroyed = false
    }

    local IconImage
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 14,
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )

    local Padding = New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })

    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )

    Library:AddOutline(Label)
    Library:MakeDraggable(Label, Label, true)

    function DraggableLabel:SetText(NewText)
        Label.Text = NewText
    end

    function DraggableLabel:SetIcon(NewIcon)
        Icon = NewIcon
        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        if IsNotEmpty then
            local CustomIcon = Library:GetCustomIcon(Icon)
            IconImage = IconImage or New("ImageLabel", {
                BackgroundTransparency = 1,
                ImageColor3 = "FontColor",
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 2,
                Parent = Label,
            })
            if CustomIcon then
                Library:ApplyLucideIcon(IconImage, CustomIcon)
            end
        end
        if IconImage then IconImage.Visible = IsNotEmpty end
        DraggableLabel:SetIconPosition(IconPosition)
    end

    function DraggableLabel:SetIconPosition(NewPosition)
        IconPosition = string.lower(NewPosition)
        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        Padding.PaddingLeft = UDim.new(0, (IsNotEmpty and IconPosition == "left") and 34 or 12)
        Padding.PaddingRight = UDim.new(0, (IsNotEmpty and IconPosition == "right") and 34 or 12)
        if IconImage then
            if IconPosition == "left" then
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, -22, 0.5, 0)
            else
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 22, 0.5, 0)
            end
        end
    end

    function DraggableLabel:SetVisible(Visible)
        Label.Visible = Visible
    end

    DraggableLabel:SetIcon(Icon)
    DraggableLabel.Label = Label

    if not table.find(Library.DraggableElements, Label) then
        table.insert(Library.DraggableElements, Label)
    end
    PositionDraggable(Label, Label.Position)

    function DraggableLabel:Destroy()
        DraggableLabel.Destroyed = true
        if DraggableLabel.Connections then
            for _, connection in DraggableLabel.Connections do
                connection:Disconnect()
            end
        end
        local ElemIdx = table.find(Library.DraggableElements, Label)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end
        if Label then
            Label:Destroy()
        end
    end

    return DraggableLabel
end

function Library:AddDraggableButton(...)
    local Params = select(1, ...)
    local Text
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Text = Params.Text
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" then
        Text = Params
        Func = select(2, ...)
        ExcludeScaling = select(3, ...)
        ExcludeDragging = select(4, ...)
    end

    local DraggableButton = {
        Connections = {},
        Destroyed = false
    }

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 14,
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )

    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input)
        if not IsClickInput(Input) then
            return
        end
        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end
            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableButton)
            end
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableButton:SetText(NewText)
        local X, Y = Library:GetTextBounds(NewText, Library.Scheme.Font, 14)
        Button.Text = NewText
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableButton:SetText(Text)
    DraggableButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end
    PositionDraggable(Button, Button.Position)

    function DraggableButton:Destroy()
        DraggableButton.Destroyed = true
        if DraggableButton.Connections then
            for _, connection in DraggableButton.Connections do
                connection:Disconnect()
            end
        end
        local ElemIdx = table.find(Library.DraggableElements, Button)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end
        if Button then
            Button:Destroy()
        end
    end

    return DraggableButton
end

function Library:AddDraggableMenu(Name)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )

    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })

    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })

    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)

    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end
    PositionDraggable(Holder, Holder.Position)

    return Holder, Container
end

function Library:AddDraggableImageButton(...)
    local Params = select(1, ...)
    local Icon
    local IconSize
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Icon = Params.Icon
        IconSize = Params.IconSize or 24
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" or typeof(Params) == "number" then
        Icon = Params
        IconSize = select(2, ...)
        Func = select(3, ...)
        ExcludeScaling = select(4, ...)
        ExcludeDragging = select(5, ...)
    end

    local DraggableImageButton = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(IconSize + 12, IconSize + 12),
        Text = "",
        ZIndex = 1,
        Parent = Floats,
    })

    local IconImage = New("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(IconSize, IconSize),
        ImageColor3 = "FontColor",
        ZIndex = 2,
        Parent = Button,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )

    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input)
        if not IsClickInput(Input) then
            return
        end
        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end
            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableImageButton)
            end
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableImageButton:SetIcon(NewIcon)
        Icon = NewIcon or Icon
        local CustomIcon = Library:GetCustomIcon(Icon)
        if CustomIcon then
            Library:ApplyLucideIcon(IconImage, CustomIcon)
        end
    end

    function DraggableImageButton:SetIconSize(NewSize)
        IconSize = NewSize
        IconImage.Size = UDim2.fromOffset(IconSize, IconSize)
        Button.Size = UDim2.fromOffset(IconSize + 12, IconSize + 12)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableImageButton:SetIcon(Icon)
    DraggableImageButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end
    PositionDraggable(Button, Button.Position)

    return DraggableImageButton
end

local CurrentMenu

function Library:AddContextMenu(Holder, Size, Offset, List, ActiveCallback, IgnoreCornerRadius, SpecificCornersOnly, AnimationType)
    local Menu
    local HolderGui = Holder:FindFirstAncestorOfClass("ScreenGui")
    local ParentGui = Overlay
    if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
        ParentGui = HolderGui
    end

    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    end

    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Menu,
    })

    local Corner
    if IgnoreCornerRadius ~= true then
        if SpecificCornersOnly == "top" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            })
            table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "bottom" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            })
            table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            })
            table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_top_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            })
            table.insert(Library.SpecificCorners, Corner)
        else
            Corner = New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            })
            table.insert(Library.Corners, Corner)
        end
    end

    local Table = {
        Connections = {},
        Destroyed = false,
        Active = false,
        ActiveCallback = ActiveCallback,
        Holder = Holder,
        Menu = Menu,
        Corner = Corner,
        List = nil,
        Signal = nil,
        Size = Size,
        AutoSizeY = List == 1,
        OpenCloseTween = nil,
        Animated = function()
            if not AnimationType or AnimationType == "none" then
                return false
            end
            if not (Library.Animations and Library.Animations[AnimationType] == true) then
                return false
            end
            return true, Library[string.format("%sTransitionInfo", AnimationType)] or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    }

    if List == 1 then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    function Table:Open()
        if CurrentMenu == Table then
            return
        elseif CurrentMenu then
            CurrentMenu:Close()
        end

        CurrentMenu = Table
        Table.Active = true
        Menu.ZIndex = 1

        local TargetParent = if ParentGui == Overlay then Overlay else ParentGui
        Menu.Parent = nil
        Menu.Parent = TargetParent

        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset()[2])
            )
        else
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset[2])
            )
        end

        local TargetSize = typeof(Table.Size) == "function" and Table.Size() or Table.Size

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TInfo = Table.Animated()
        if IsAnimated == true then
            local OpenSize = TargetSize
            if Table.AutoSizeY then
                local FullHeight = Menu.AbsoluteSize.Y
                Menu.AutomaticSize = Enum.AutomaticSize.None
                OpenSize = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, 0, FullHeight)
            end
            Menu.Size = UDim2.new(OpenSize.X.Scale, OpenSize.X.Offset, 0, 0)
            Menu.Visible = true
            local Tween = TweenService:Create(Menu, TInfo, { Size = OpenSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                if Connection then
                    Connection:Disconnect()
                end
                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil
                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))
            Tween:Play()
        else
            Menu.Size = TargetSize
            Menu.Visible = true
        end

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset()[2])
                )
            else
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset[2])
                )
            end

            local HolderAllowed = Library:IsInsideFrame(Library.WindowContainer, Holder)
            if not HolderAllowed then
                for _, Surface in Library.DraggableElements do
                    if not (Surface and Library:IsInsideFrame(Surface, Holder)) then
                        continue
                    end
                    HolderAllowed = true
                    break
                end
            end

            if not HolderAllowed and Table.Active then
                Table:Close()
            end
        end)
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end
        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end
        Table.Active = false
        CurrentMenu = nil

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TInfo = Table.Animated()
        if IsAnimated == true then
            if Table.AutoSizeY then
                Menu.AutomaticSize = Enum.AutomaticSize.None
            end
            local CurrentSize = Menu.Size
            local CollapsedSize = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 0)
            local Tween = TweenService:Create(Menu, TInfo, { Size = CollapsedSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function(PlaybackState)
                if Connection then
                    Connection:Disconnect()
                end
                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil
                    Menu.Visible = false
                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))
            Tween:Play()
        else
            Menu.Visible = false
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(NewSize)
        Table.Size = NewSize
        Menu.Size = typeof(NewSize) == "function" and NewSize() or NewSize
    end

    function Table:Destroy()
        Table.Destroyed = true
        if Table.Connections then
            for _, Connection in Table.Connections do
                Connection:Disconnect()
            end
        end
        if CurrentMenu == Table then
            Table:Close()
        end
        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end
        local MenuIndex = table.find(Library.ContextMenus, Table)
        if MenuIndex then
            table.remove(Library.ContextMenus, MenuIndex)
        end
        if Menu then
            Menu:Destroy()
        end
    end

    table.insert(Library.ContextMenus, Table)
    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input)
    if Library.Unloaded then
        return
    end
    if IsClickInput(Input, true) then
        local Location = Input.Position
        if CurrentMenu and not (Library:MouseIsOverFrame(CurrentMenu.Menu, Location) or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)) then
            CurrentMenu:Close()
        end
    end
end))

local TooltipLabel = New("TextLabel", {
    BackgroundColor3 = "BackgroundColor",
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 30,
    Parent = ScreenGui,
})

New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})

table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)

New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})

table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)

local TooltipMeasureId = 0
local LastTooltipText = ""
local LastTooltipMaxWidth = 0

local function UpdateTooltipSize(Force)
    if Library.Unloaded or not TooltipLabel.Visible then
        return
    end
    local MaxWidth = math.max(40, (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale)
    if not Force and TooltipLabel.Text == LastTooltipText and math.abs(MaxWidth - LastTooltipMaxWidth) < 1 and TooltipLabel.Size.X.Offset > 0 then
        return
    end
    TooltipMeasureId += 1
    local MeasureId = TooltipMeasureId
    local Text = TooltipLabel.Text
    local X, Y = Library:GetTextBounds(Text, TooltipLabel.FontFace, TooltipLabel.TextSize, MaxWidth)
    if MeasureId ~= TooltipMeasureId or TooltipLabel.Text ~= Text then
        return
    end
    LastTooltipText = Text
    LastTooltipMaxWidth = MaxWidth
    TooltipLabel.Size = UDim2.fromOffset(X + 8, Y + 4)
end

TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    UpdateTooltipSize(false)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr, DisabledInfoStr, HoverInstance)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if CurrentHoverInstance == HoverInstance or Library.ActiveDialog or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse)) or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string") or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string") then
            return
        end
        CurrentHoverInstance = HoverInstance
        local HolderGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
            TooltipLabel.Parent = HolderGui
        else
            TooltipLabel.Parent = ScreenGui
        end

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Position = UDim2.fromOffset(Mouse.X + 14, Mouse.Y + 12)
        TooltipLabel.Visible = true
        UpdateTooltipSize(true)

        while (Library.Toggled or Library.ActiveLoading) and not Library.ActiveDialog and Library:MouseIsOverFrame(HoverInstance, Mouse) and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse)) do
            TooltipLabel.Position = UDim2.fromOffset(Mouse.X + 14, Mouse.Y + 12)
            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end
        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end
        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end
        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end
            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

local BaseAddons = {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.KeyPicker)
        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        if ParentObj.Type == "Button" or ParentObj.Type == "SubButton" then
            ToggleLabel = ParentObj.Base
        end

        local KeyPicker = {
            Connections = {},
            Text = Info.Text,
            Value = Info.Default,
            Modifiers = Info.DefaultModifiers,
            DisplayValue = Info.Default,
            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,
            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,
            MenuVisible = Info.NoUI ~= true,
            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,
            Type = "KeyPicker",
        }

        if KeyPicker.Mode == "Press" then
            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }
            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false
        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"

        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,
            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,
            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,
            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",
            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",
            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",
            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}
            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then continue end
                if not UserInputService:IsKeyDown(Input) then continue end
                table.insert(ActiveModifiers, Name)
            end
            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end
            local ActiveModifiers = GetActiveModifiers()
            local Holding = true
            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then continue end
                Holding = false
                break
            end
            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then return false end
            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType) and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}
            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end
            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then return {} end
            local ValidModifiers = {}
            for _, name in CurrentModifiers do
                if not Modifiers[name] then continue end
                table.insert(ValidModifiers, name)
            end
            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local SlideOverflow = true
        local LastDisplayText = nil
        local MaxPickerWidth = 85
        local SlidingLabel
        local SlideForwardTween
        local SlideBackTween

        local HandleForwardTween = function(State)
            if State ~= Enum.PlaybackState.Completed then return end
            task.wait(1.5)
            if SlideBackTween then SlideBackTween:Play() end
        end

        local HandleBackTween = function(State)
            if State ~= Enum.PlaybackState.Completed then return end
            task.wait(1.5)
            if SlideForwardTween then SlideForwardTween:Play() end
        end

        local SlideForwardConn, SlideBackConn
        local CancelSlidingTweens = function()
            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end
            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end
            if SlideForwardTween then
                StopTween(SlideForwardTween, true)
                SlideForwardTween = nil
            end
            if SlideBackTween then
                StopTween(SlideBackTween, true)
                SlideBackTween = nil
            end
            RunService.RenderStepped:Wait()
        end

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(18, 18),
            Text = (IsForButton and SlideOverflow) and "" or KeyPicker.Value,
            TextSize = 14,
            TextTransparency = 0.4,
            Parent = ToggleLabel,
        })

        if IsForButton and SlideOverflow then
            Picker.ClipsDescendants = true
            SlidingLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = KeyPicker.Value,
                TextSize = 14,
                FontFace = Picker.FontFace,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Picker,
            })
            Library:AddToRegistry(SlidingLabel, {
                TextColor3 = "FontColor",
            })
        end

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        local PickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Picker,
        })
        table.insert(Library.SpecificCorners, PickerCorner)

        local PickerHoverTween = nil
        local function ApplyPickerTextTransparency(Transparency)
            StopTween(PickerHoverTween)
            PickerHoverTween = nil
            Picker.TextTransparency = Transparency
            if SlidingLabel then
                SlidingLabel.TextTransparency = Transparency
            end
        end

        local function TweenPickerTextTransparency(Transparency)
            StopTween(PickerHoverTween)
            PickerHoverTween = TweenService:Create(Picker, Library.TweenInfo, {
                TextTransparency = Transparency,
            })
            PickerHoverTween:Play()
            if SlidingLabel then
                TweenService:Create(SlidingLabel, Library.TweenInfo, {
                    TextTransparency = Transparency,
                }):Play()
            end
        end

        table.insert(KeyPicker.Connections, Picker.MouseEnter:Connect(function()
            if ParentObj.Disabled then return end
            TweenPickerTextTransparency(0)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseLeave:Connect(function()
            if ParentObj.Disabled then return end
            TweenPickerTextTransparency(0.4)
        end))

        if IsForButton then
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Parent = ToggleLabel.Parent,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 9),
                Parent = Holder,
            })
            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Fill,
                Parent = ToggleLabel,
            })
            ToggleLabel.Parent = Holder
            Picker.Parent = Holder
            Picker.Size = UDim2.new(0, 18, 1, 0)
        end

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })
            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = Holder,
            })
            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })
            local CheckImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })
            if CheckIcon then
                Library:ApplyLucideIcon(CheckImage, CheckIcon)
            end

            function KeybindsToggle:Display(State)
                Label.TextTransparency = State and 0 or 0.5
                CheckImage.ImageTransparency = State and 0 or 1
            end
            function KeybindsToggle:SetText(NewText)
                Label.Text = NewText
            end
            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end
            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal
                Holder.Active = not Normal
                Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22, 0)
                Checkbox.Visible = not Normal
            end

            KeyPicker.DoClick = function(...) end
            table.insert(KeyPicker.Connections, Holder.MouseButton1Click:Connect(function()
                if KeybindsToggle.Normal then return end
                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
                KeyPicker:Update()
            end))

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local ModeButtons = {}
        local ModeCorners = {}
        local TotalModeButtons = GetTableSize(Info.Modes)
        local MenuCornersOnly = if TotalModeButtons == 1 then "no_left" else "no_top_left"
        local MenuTable

        MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)
            PickerCorner.TopLeftRadius = Half
            PickerCorner.BottomLeftRadius = Half
            PickerCorner.TopRightRadius = Active and Zero or Half
            PickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = MenuTable and MenuTable.Corner
            if MenuCorner then
                if MenuCornersOnly == "no_left" then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.BottomLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                else
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end

            for _, Entry in ModeCorners do
                local Corner = Entry.Corner
                if Entry.Style == "single" then
                    Corner.TopLeftRadius = Zero
                    Corner.BottomLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomRightRadius = Half
                elseif Entry.Style == "first" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomLeftRadius = Zero
                    Corner.BottomRightRadius = Zero
                elseif Entry.Style == "last" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Zero
                    Corner.BottomLeftRadius = Half
                    Corner.BottomRightRadius = Half
                end
            end
        end, false, MenuCornersOnly, "KeyPicker")
        
        KeyPicker.Menu = MenuTable

        for Index, Mode in Info.Modes do
            local ModeButton = {}
            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or (TotalModeButtons == 1 and 18 or 19)),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            if Index == 1 and TotalModeButtons == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "single" })
            elseif Index == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, 0),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "first" })
            elseif Index == TotalModeButtons then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "last" })
            end

            function ModeButton:Select()
                for _, btn in ModeButtons do
                    btn:Deselect()
                end
                KeyPicker.Mode = Mode
                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0
                MenuTable:Close()
                if KeyPicker.Update then
                    KeyPicker:Update()
                end
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil
                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            table.insert(KeyPicker.Connections, Button.MouseButton1Click:Connect(function()
                ModeButton:Select()
            end))

            table.insert(KeyPicker.Connections, Button.MouseEnter:Connect(function()
                if KeyPicker.Mode == Mode then return end
                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end))

            table.insert(KeyPicker.Connections, Button.MouseLeave:Connect(function()
                if KeyPicker.Mode == Mode then return end
                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end))

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end
            ModeButtons[Mode] = ModeButton
        end

        local SetPickingState = function(State, SkipUpdate)
            Picking = State
            Library.IsPicking = State
            if ParentObj then
                ParentObj.AnyKeyPickerPicking = Picking
            end
            if IsForButton then
                ToggleLabel.Visible = not Picking
                LastDisplayText = nil
                RunService.RenderStepped:Wait()
            end
            if SkipUpdate ~= true then
                KeyPicker:Update()
            end
        end
        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end
            local DisplayText = PickerText or KeyPicker.DisplayValue
            if IsForButton and SlideOverflow then
                local X, _Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    10000
                )
                local OffsetScale = X + 9
                local TextChanged = LastDisplayText ~= DisplayText
                local LabelWidth
                SlidingLabel.Text = DisplayText
                LastDisplayText = DisplayText

                if Picking then
                    Picker.Size = UDim2.new(1, 0, 1, 0)
                    RunService.RenderStepped:Wait()
                    LabelWidth = Picker.AbsoluteSize.X
                    if LabelWidth <= 0 then
                        LabelWidth = MaxPickerWidth
                    end
                else
                    LabelWidth = math.min(OffsetScale, MaxPickerWidth)
                    Picker.Size = UDim2.new(0, LabelWidth, 1, 0)
                end

                if OffsetScale > LabelWidth then
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SlidingLabel.Size = UDim2.new(0, OffsetScale, 1, 0)
                    local OverflowDistance = OffsetScale - LabelWidth - 4.5
                    if OverflowDistance > 0 then
                        if TextChanged or not SlideForwardTween then
                            SlidingLabel.Position = UDim2.fromOffset(4.5, 0)
                            CancelSlidingTweens()
                            local Duration = math.max(OverflowDistance / 25, 0.35)
                            local TweenInfoObj = TweenInfo.new(
                                Duration,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.InOut
                            )
                            SlideForwardTween = TweenService:Create(SlidingLabel, TweenInfoObj, {
                                Position = UDim2.fromOffset(-OverflowDistance, 0),
                            })
                            SlideBackTween = TweenService:Create(SlidingLabel, TweenInfoObj, {
                                Position = UDim2.fromOffset(4.5, 0),
                            })
                            SlideForwardTween:Play()
                            if SlideForwardConn then
                                SlideForwardConn:Disconnect()
                            end
                            if SlideBackConn then
                                SlideBackConn:Disconnect()
                            end
                            SlideForwardConn = SlideForwardTween.Completed:Connect(HandleForwardTween)
                            SlideBackConn = SlideBackTween.Completed:Connect(HandleBackTween)
                        end
                    else
                        CancelSlidingTweens()
                        SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                        SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                        SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                    end
                else
                    CancelSlidingTweens()
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                    SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                local X, Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    ToggleLabel.AbsoluteSize.X / Library.DPIScale
                )
                Picker.Text = DisplayText
                Picker.Size = IsForButton and UDim2.new(0, X + 9, 1, 0) or UDim2.fromOffset((X + 9), (Y + 4))
            end
        end

        function KeyPicker:Update()
            local Disabled = ParentObj.Disabled == true
            if Disabled and Picking then
                SetPickingState(false, true)
            end
            KeyPicker:Display()
            Picker.Active = not Disabled
            ApplyPickerTextTransparency(Disabled and 0.8 or 0.4)
            if Disabled then
                if MenuTable.Active then
                    MenuTable:Close()
                end
            end
            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end
            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"
            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end
            if Info.NoUI then
                return
            end
            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end
                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(KeyPicker.MenuVisible ~= false)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end
                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end
                if Picking then
                    return false
                end
                if SpecialKeys[Key] ~= nil then
                    if Library.Toggled then
                        return false
                    end
                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key]) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if Picking or ParentObj.Disabled then
                return
            end
            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end
                KeyPicker.Toggled = true
            end
            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
            if IsForButton then
                Library:SafeCallback(ParentObj.Func, KeyPicker.Toggled)
            end
            if Library.ToggleKeybind == KeyPicker and Library.Toggle then
                Library:Toggle()
            end
            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:RunChanged(IsKeyValid, KeyCode)
            if ParentObj.Disabled then
                return
            end
            if IsKeyValid == nil or KeyCode == nil then
                IsKeyValid, KeyCode = pcall(function()
                    if KeyPicker.Value == "None" then
                        return nil
                    end
                    if SpecialKeys[KeyPicker.Value] == nil then
                        return Enum.KeyCode[KeyPicker.Value]
                    end
                    return SpecialKeys[KeyPicker.Value]
                end)
            end
            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
        end

        function KeyPicker:SetValue(Data)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]
            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end
                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end
                return SpecialKeys[Key]
            end)
            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end
            KeyPicker.Modifiers = VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end
            KeyPicker:Update()
            KeyPicker:RunChanged(IsKeyValid, KeyCode)
        end

        function KeyPicker:SetText(Text)
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()
        end

        function KeyPicker:SetMenuVisibility(Visible)
            assert(typeof(Visible) == "boolean", "Visible must be a boolean")
            KeyPicker.MenuVisible = Visible
            KeyPicker:Update()
        end

        table.insert(KeyPicker.Connections, Picker.MouseButton1Click:Connect(function()
            if Picking or Library.IsPicking or ParentObj.Disabled then
                return
            end
            SetPickingState(true)
            if IsForButton and SlideOverflow then
                KeyPicker:Display("...")
            else
                Picker.Text = "..."
                Picker.Size = IsForButton and UDim2.new(0, 29, 1, 0) or UDim2.fromOffset(29, 18)
            end

            local ActiveModifiers = {}
            local CurrentInput = nil
            local IsValidInput = function(InputObj)
                if InputObj.KeyCode == Enum.KeyCode.Escape then
                    return true
                end
                local IsMod = IsModifierInput(InputObj)
                local KeyName
                if SpecialKeysInput[InputObj.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[InputObj.UserInputType]
                elseif InputObj.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[InputObj.KeyCode]
                    else
                        KeyName = InputObj.KeyCode.Name
                    end
                end
                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return false
                        end
                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return false
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return false
                        end
                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return false
                        end
                    end
                end
                return true
            end

            while true do
                local InputObj = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    SetPickingState(false)
                    return
                end
                if IsValidInput(InputObj) then
                    CurrentInput = InputObj
                    break
                end
            end

            while IsModifierInput(CurrentInput) do
                if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                    break
                end
                local ModName = ModifiersInput[CurrentInput.KeyCode]
                if ModName then
                    local text = if #ActiveModifiers > 0 then table.concat(ActiveModifiers, " + ") .. " + " .. ModName .. " + ..." else ModName .. " + ..."
                    KeyPicker:Display(text)
                end

                local NextInput = nil
                local Released = false
                local BeganConn
                local EndedConn

                BeganConn = UserInputService.InputBegan:Connect(function(InputObj)
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return
                    end
                    if IsValidInput(InputObj) then
                        NextInput = InputObj
                    end
                end)
                EndedConn = UserInputService.InputEnded:Connect(function(InputObj)
                    if InputObj.KeyCode == CurrentInput.KeyCode then
                        Released = true
                    end
                end)

                repeat
                    task.wait()
                until Released or NextInput or UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded

                if BeganConn then BeganConn:Disconnect() end
                if EndedConn then EndedConn:Disconnect() end

                if UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded then
                    SetPickingState(false)
                    return
                end

                if Released then
                    break
                elseif NextInput then
                    local OldModName = ModifiersInput[CurrentInput.KeyCode]
                    if OldModName and not table.find(ActiveModifiers, OldModName) then
                        ActiveModifiers[#ActiveModifiers + 1] = OldModName
                    end
                    CurrentInput = NextInput
                    if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                        break
                    end
                end
            end

            local Key = "Unknown"
            if SpecialKeysInput[CurrentInput.UserInputType] ~= nil then
                Key = SpecialKeysInput[CurrentInput.UserInputType]
            elseif CurrentInput.UserInputType == Enum.UserInputType.Keyboard then
                Key = CurrentInput.KeyCode == Enum.KeyCode.Escape and "None" or CurrentInput.KeyCode.Name
            end

            ActiveModifiers = if CurrentInput.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers
            KeyPicker.Toggled = if ParentObj.Type == "Toggle" then ParentObj.Value else false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            repeat
                task.wait()
            until not IsInputDown(CurrentInput) or UserInputService:GetFocusedTextBox()

            SetPickingState(false)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end
            MenuTable:Toggle()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputBegan:Connect(function(Input)
            if Library.Unloaded then
                return
            end
            local IsMouse = IsMouseClickInput(Input)
            if ParentObj.Disabled or KeyPicker.Mode == "Always" or KeyPicker.Value == "Unknown" or KeyPicker.Value == "None" or Picking or Library.IsPicking or UserInputService:GetFocusedTextBox() or (IsMouse and Library.Toggled) then
                return
            end
            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false
            if Key and HoldingModifiers == true and (SpecialKeysInput[Input.UserInputType] == Key or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)) then
                HoldingKey = true
            end
            if HoldingKey then
                if KeyPicker.Mode == "Toggle" then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Press" then
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Hold" then
                    local InputChanged
                    InputChanged = Input.Changed:Connect(function()
                        if KeyPicker:GetState() then
                            return
                        end
                        KeyPicker:Update()
                        if InputChanged and InputChanged.Connected then
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
                KeyPicker:Update()
            end
        end))

        KeyPicker:Update()
        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end
        table.insert(ParentObj.Addons, KeyPicker)
        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        function KeyPicker:Destroy()
            KeyPicker.Destroyed = true
            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end
            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end
            if KeyPicker.Connections then
                for _, Connection in KeyPicker.Connections do
                    Connection:Disconnect()
                end
            end
            if KeybindsToggle and KeybindsToggle.Loaded then
                if KeybindsToggle.Holder then
                    KeybindsToggle.Holder:Destroy()
                end
                local KTIdx = table.find(Library.KeybindToggles, KeybindsToggle)
                if KTIdx then
                    table.remove(Library.KeybindToggles, KTIdx)
                end
            end
            if MenuTable then
                MenuTable:Destroy()
            end
            if IsForButton and SlideOverflow then
                if SlideForwardTween then
                    SlideForwardTween:Destroy()
                end
                if SlideBackTween then
                    SlideBackTween:Destroy()
                end
            end
            if Picker then
                Picker:Destroy()
            end
            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, KeyPicker)
                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end
            Options[Idx] = nil
        end

        Options[Idx] = KeyPicker
        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end

    function Funcs:AddColorPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.ColorPicker)
        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Connections = {},
            Destroyed = false,
            Value = Info.Default,
            Transparency = Info.Transparency or 0,
            Title = Info.Title,
            Callback = Info.Callback,
            Changed = Info.Changed,
            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = ToggleLabel,
        })
        local HolderStroke = New("UIStroke", {
            Color = Library:GetDarkerColor(ColorPicker.Value),
            Parent = Holder,
        })
        local ColorPickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Holder,
        })
        table.insert(Library.SpecificCorners, ColorPickerCorner)

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HolderTransparency,
            })
        )

        local MapSize = Library.IsMobile and 140 or 200
        local BarWidth = 16
        local MenuWidth = MapSize + BarWidth + 6 + 12
        if Info.Transparency then
            MenuWidth += BarWidth + 6
        end

        local ColorMenu
        local FooterCorner
        ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(MenuWidth, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1, function(Active)
                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)
                ColorPickerCorner.TopLeftRadius = Half
                ColorPickerCorner.TopRightRadius = Half
                ColorPickerCorner.BottomRightRadius = Active and Zero or Half
                ColorPickerCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = ColorMenu and ColorMenu.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
                if FooterCorner then
                    FooterCorner.TopLeftRadius = Zero
                    FooterCorner.TopRightRadius = Zero
                    FooterCorner.BottomLeftRadius = Half
                    FooterCorner.BottomRightRadius = Half
                end
            end, false, "no_top_left")
        ColorMenu.List.Padding = UDim.new(0, 0)
        ColorPicker.ColorMenu = ColorMenu

        local ContentHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = ContentHolder,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ContentHolder,
        })

        local FooterHeight = Library.IsMobile and 30 or 22
        local FooterBackground = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Size = UDim2.new(1, 0, 0, FooterHeight),
            Parent = ColorMenu.Menu,
        })
        FooterCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = FooterBackground,
        })
        table.insert(Library.SpecificCorners, FooterCorner)
        Library:MakeLine(FooterBackground, {
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local FooterBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = FooterBackground,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, Info.Resizable and (FooterHeight + 4) or 6),
            Parent = FooterBar,
        })

        local FooterInfoLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = FooterBar,
        })

        local function RefreshFooterInfo()
            FooterInfoLabel.Text = string.format(
                "#%s • %d, %d, %d",
                ColorPicker.Value:ToHex(),
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255)
            )
        end
        RefreshFooterInfo()

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ContentHolder,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, MapSize),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(MapSize, MapSize),
            Parent = ColorHolder,
        })
        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(BarWidth, MapSize),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })
        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(BarWidth, MapSize),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })
            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })
            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        local ResizeGrabber
        if Info.Resizable then
            local BaseMapSize = 200
            local BaseBarWidth = BarWidth
            local BasePadding = 6
            local MinMapSize = 140
            ColorPicker.MapWidth = MapSize
            ColorPicker.MapHeight = MapSize

            local function GetBarWidth(MapWidth)
                return math.clamp(math.floor((MapWidth / BaseMapSize) * BaseBarWidth + 0.5), 12, 24)
            end
            local function GetContentWidth(MapWidth)
                local CurrentBarWidth = GetBarWidth(MapWidth)
                local Width = MapWidth + CurrentBarWidth + BasePadding
                if Info.Transparency then
                    Width += (CurrentBarWidth + BasePadding)
                end
                return Width + 12
            end

            local FixedVerticalOverhead = 6 + 6 + 8 + 20 + 8 + 20 + FooterHeight
            if typeof(ColorPicker.Title) == "string" then
                FixedVerticalOverhead += 8 + 8
            end

            local function ClampToViewport(NewWidth, NewHeight)
                local Camera = workspace.CurrentCamera
                if not Camera then return NewWidth, NewHeight end
                local ViewportSize = Camera.ViewportSize
                local ScreenMargin = 12
                local MaxWidth = ViewportSize.X - ColorMenu.Menu.AbsolutePosition.X - ScreenMargin
                local MaxHeight = ViewportSize.Y - ColorMenu.Menu.AbsolutePosition.Y - ScreenMargin - FixedVerticalOverhead

                while NewWidth > MinMapSize and GetContentWidth(NewWidth) > MaxWidth do
                    NewWidth -= 4
                end
                if NewHeight > MaxHeight then
                    NewHeight = math.max(MinMapSize, math.floor(MaxHeight))
                end
                return NewWidth, NewHeight
            end

            local function UpdateColorMenuSize(NewWidth, NewHeight)
                NewWidth = math.max(MinMapSize, math.floor(NewWidth + 0.5))
                NewHeight = math.max(MinMapSize, math.floor(NewHeight + 0.5))
                NewWidth, NewHeight = ClampToViewport(NewWidth, NewHeight)

                if NewWidth == ColorPicker.MapWidth and NewHeight == ColorPicker.MapHeight then
                    return
                end

                local CurrentBarWidth = GetBarWidth(NewWidth)
                local CursorSize = math.clamp(math.floor((math.min(NewWidth, NewHeight) / BaseMapSize) * 6 + 0.5), 4, 10)

                ColorHolder.Size = UDim2.new(1, 0, 0, NewHeight)
                SatVipMap.Size = UDim2.fromOffset(NewWidth, NewHeight)
                SatVibCursor.Size = UDim2.fromOffset(CursorSize, CursorSize)
                HueSelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)
                if TransparencySelector then
                    TransparencySelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)
                end

                ColorPicker.MapWidth = NewWidth
                ColorPicker.MapHeight = NewHeight
                ColorMenu:SetSize(UDim2.new(0, GetContentWidth(NewWidth), 0, 0))
            end

            ResizeGrabber = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -Library.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = FooterBackground,
            })
            local ResizeGrabberIcon = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = ResizeGrabber,
            })
            if ResizeIcon then
                Library:ApplyLucideIcon(ResizeGrabberIcon, ResizeIcon)
            end

            table.insert(ColorPicker.Connections, ResizeGrabber.InputBegan:Connect(function(Input)
                Library.CantDragForced = true
                local StartMouse = Vector2.new(Mouse.X, Mouse.Y)
                local StartWidth = ColorPicker.MapWidth
                local StartHeight = ColorPicker.MapHeight
                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Delta = Vector2.new(Mouse.X, Mouse.Y) - StartMouse
                    UpdateColorMenuSize(StartWidth + Delta.X, StartHeight + Delta.Y)
                    RunService.RenderStepped:Wait()
                end
                Library.CantDragForced = false
            end))
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })
        local HueBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = HueBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HueBox,
            })
        )

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })
        local RgbBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = RgbBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RgbBox,
            })
        )

        local ContextMenu
        ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)
            ColorPickerCorner.TopLeftRadius = Half
            ColorPickerCorner.BottomLeftRadius = Half
            ColorPickerCorner.TopRightRadius = Active and Zero or Half
            ColorPickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = ContextMenu and ContextMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end
        end, false, "no_top_left")
        ColorPicker.ContextMenu = ContextMenu
        ContextMenu.List.Padding = UDim.new(0, 6)

        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })
                table.insert(ColorPicker.Connections, Button.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end))
                table.insert(ColorPicker.Connections, Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 0.7,
                    }):Play()
                end))
                table.insert(ColorPicker.Connections, Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()
                end))
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...) end 
            CreateButton("Paste color", function()
                if not Library.CopiedColor then
                    return
                end
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)
                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        local ActionHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = ActionHolder,
        })

        local CopyColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Copy color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = CopyColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = CopyColorButton,
            })
        )

        local PasteColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Paste color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = PasteColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = PasteColorButton,
            })
        )

        local CopyColorOriginalText = CopyColorButton.Text
        local PasteColorOriginalText = PasteColorButton.Text
        local CopyColorResetId = 0
        local PasteColorResetId = 0

        table.insert(ColorPicker.Connections, CopyColorButton.MouseEnter:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))
        table.insert(ColorPicker.Connections, CopyColorButton.MouseLeave:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))
        table.insert(ColorPicker.Connections, PasteColorButton.MouseEnter:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))
        table.insert(ColorPicker.Connections, PasteColorButton.MouseLeave:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseButton1Click:Connect(function()
            Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            CopyColorResetId += 1
            local ThisResetId = CopyColorResetId
            CopyColorButton.Text = "Copied color"
            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= CopyColorResetId then
                    return
                end
                CopyColorButton.Text = CopyColorOriginalText
            end)
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseButton1Click:Connect(function()
            PasteColorResetId += 1
            local ThisResetId = PasteColorResetId
            if not Library.CopiedColor then
                PasteColorButton.Text = "Nothing to paste"
            else
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
                PasteColorButton.Text = "Pasted color"
            end
            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= PasteColorResetId then
                    return
                end
                PasteColorButton.Text = PasteColorOriginalText
            end)
        end))

        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then return end
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)
            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end
            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end
            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")
            RefreshFooterInfo()
        end

        local function ApplyHolderVisual(Disabled)
            Holder.Active = not Disabled
            HolderStroke.Transparency = Disabled and 0.5 or 0
            Holder.BackgroundTransparency = Disabled and 0.5 or 0
            if Disabled then
                Holder.BackgroundColor3 = ColorPicker.Value:Lerp(Library.Scheme.BackgroundColor, 0.5)
                HolderTransparency.ImageTransparency = math.clamp((1 - ColorPicker.Transparency) + 0.5, 0, 1)
            else
                Holder.BackgroundColor3 = ColorPicker.Value
                HolderStroke.Color = Library:GetDarkerColor(ColorPicker.Value)
                HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)
            end
        end

        function ColorPicker:RunChanged()
            if ParentObj.Disabled then return end
            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:Update()
            ColorPicker:Display()
            local Disabled = ParentObj.Disabled == true
            ApplyHolderVisual(Disabled)
            if Disabled then
                if ColorMenu.Active then ColorMenu:Close() end
                if ContextMenu.Active then ContextMenu:Close() end
            end
            ColorPicker:RunChanged()
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        table.insert(ColorPicker.Connections, Holder.MouseButton1Click:Connect(function()
            if ParentObj.Disabled then return end
            ColorMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, Holder.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then return end
            ContextMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, SatVipMap.InputBegan:Connect(function(Input)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Mouse.X, MinX, MaxX)
                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end
                RunService.RenderStepped:Wait()
            end
        end))

        table.insert(ColorPicker.Connections, HueSelector.InputBegan:Connect(function(Input)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end
                RunService.RenderStepped:Wait()
            end
        end))

        if TransparencySelector then
            table.insert(ColorPicker.Connections, TransparencySelector.InputBegan:Connect(function(Input)
                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end
                    RunService.RenderStepped:Wait()
                end
            end))
        end

        table.insert(ColorPicker.Connections, HueBox.FocusLost:Connect(function(Enter)
            if not Enter then return end
            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end
            ColorPicker:Update()
        end))

        table.insert(ColorPicker.Connections, RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then return end
            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end
            ColorPicker:Update()
        end))

        for _, BoxPair in { { HueBox, HueBoxStroke }, { RgbBox, RgbBoxStroke } } do
            local TextBoxInstance, Stroke = BoxPair[1], BoxPair[2]
            table.insert(ColorPicker.Connections, TextBoxInstance.Focused:Connect(function()
                Library.Registry[Stroke].Color = "AccentColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))
            table.insert(ColorPicker.Connections, TextBoxInstance.FocusLost:Connect(function()
                Library.Registry[Stroke].Color = "OutlineColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        ColorPicker:Update()
        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end
        table.insert(ParentObj.Addons, ColorPicker)
        ColorPicker.Default = ColorPicker.Value

        function ColorPicker:Destroy()
            ColorPicker.Destroyed = true
            if ColorPicker.Connections then
                for _, Connection in ColorPicker.Connections do
                    Connection:Disconnect()
                end
            end
            if ColorMenu then ColorMenu:Destroy() end
            if ResizeGrabber then ResizeGrabber:Destroy() end
            if ContextMenu then ContextMenu:Destroy() end
            if Holder then Holder:Destroy() end
            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, ColorPicker)
                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end
            Options[Idx] = nil
        end

        Options[Idx] = ColorPicker
        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:AddToggle(Idx, Info)
    local Toggle = {
        Type = "Toggle",
        Callback = Info.Callback or function() end,
        Default = Info.Default or false,
        Value = false,
        Display = Info.Text or "Toggle",
        Visible = true,
        Risky = Info.Risky or false
    }

    local ToggleFrame = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = self.Container
    })

    local Label = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.Gotham,
        Text = Toggle.Display,
        TextColor3 = Toggle.Risky and Color3.fromRGB(255, 85, 85) or Color3.fromRGB(230, 230, 230),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ToggleFrame
    })

    local SwitchBG = Library:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 38, 0, 20),
        Parent = ToggleFrame
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = SwitchBG
    })

    local SwitchStroke = Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(60, 60, 60),
        Thickness = 1,
        Parent = SwitchBG
    })

    local SwitchInner = Library:Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(200, 200, 200),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        Parent = SwitchBG
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = SwitchInner
    })

    local ToggleButton = Library:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = ToggleFrame
    })

    function Toggle:SetValue(Val)
        Toggle.Value = Val
        local Color = Val and Library.AccentColor or Color3.fromRGB(40, 40, 40)
        local Pos = Val and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        local InnerColor = Val and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)

        Library:Tween(SwitchBG, {BackgroundColor3 = Color}, 0.2)
        Library:Tween(SwitchInner, {Position = Pos, BackgroundColor3 = InnerColor}, 0.2)
        Library:Tween(SwitchStroke, {Transparency = Val and 1 or 0}, 0.2)

        Toggle.Callback(Toggle.Value)
        Library:SafeCallback(Toggle.Changed, Toggle.Value)
    end

    ToggleButton.MouseButton1Click:Connect(function()
        Toggle:SetValue(not Toggle.Value)
    end)

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
        Func(Toggle.Value)
    end

    function Toggle:AddKeyPicker(Idx, Info)
        Info.Text = Info.Text or Toggle.Display
        return Library:AddKeyPicker(Idx, Info, ToggleFrame)
    end

    function Toggle:AddColorPicker(Idx, Info)
        return Library:AddColorPicker(Idx, Info, ToggleFrame)
    end

    Toggle:SetValue(Toggle.Default)
    Library.Options[Idx] = Toggle
    return Toggle
end

function Library:AddButton(Info)
    local Button = {
        Type = "Button",
        Display = Info.Text or "Button",
        Func = Info.Func or function() end,
    }

    local ButtonFrame = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = self.Container
    })

    local Outer = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        Size = UDim2.new(1, 0, 1, 0),
        Parent = ButtonFrame
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Outer
    })

    local Stroke = Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(55, 55, 55),
        Thickness = 1,
        Parent = Outer
    })

    local Label = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = Button.Display,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextSize = 13,
        Parent = Outer
    })

    local ClickBtn = Library:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = Outer
    })

    ClickBtn.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Library:Tween(Outer, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.1)
        end
    end)

    ClickBtn.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Library:Tween(Outer, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.1)
        end
    end)

    ClickBtn.MouseEnter:Connect(function()
        Library:Tween(Stroke, {Color = Color3.fromRGB(80, 80, 80)}, 0.1)
    end)

    ClickBtn.MouseLeave:Connect(function()
        Library:Tween(Stroke, {Color = Color3.fromRGB(55, 55, 55)}, 0.1)
    end)

    ClickBtn.MouseButton1Click:Connect(function()
        Button.Func()
    end)

    function Button:AddTooltip(Text)
        Library:AddTooltip(Outer, Text)
        return Button
    end

    return Button
end

function Library:AddSlider(Idx, Info)
    local Slider = {
        Type = "Slider",
        Text = Info.Text or "Slider",
        Min = Info.Min or 0,
        Max = Info.Max or 100,
        Rounding = Info.Rounding or 0,
        Value = Info.Default or Info.Min,
        Suffix = Info.Suffix or "",
        Callback = Info.Callback or function() end,
    }

    local SliderFrame = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 45),
        Parent = self.Container
    })

    local Label = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -60, 0, 20),
        Font = Enum.Font.Gotham,
        Text = Slider.Text,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderFrame
    })

    local ValueLabel = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 60, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "0" .. Slider.Suffix,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = SliderFrame
    })

    local SliderBG = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Position = UDim2.new(0, 0, 0, 28),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = SliderFrame
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = SliderBG
    })

    local SliderFill = Library:Create("Frame", {
        BackgroundColor3 = Library.AccentColor,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = SliderBG
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = SliderFill
    })

    local SliderDot = Library:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        Parent = SliderFill
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = SliderDot
    })

    local function Update(Input)
        local Pos = math.clamp((Input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local Value = Slider.Min + (Slider.Max - Slider.Min) * Pos
        if Slider.Rounding > 0 then
            Value = math.floor(Value * (10 ^ Slider.Rounding) + 0.5) / (10 ^ Slider.Rounding)
        else
            Value = math.floor(Value)
        end
        Slider:SetValue(Value)
    end

    SliderBG.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            local Conn
            Conn = game:GetService("UserInputService").InputChanged:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    Update(Input)
                end
            end)
            local EndConn
            EndConn = game:GetService("UserInputService").InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Conn:Disconnect()
                    EndConn:Disconnect()
                end
            end)
            Update(Input)
        end
    end)

    function Slider:SetValue(Val)
        Slider.Value = math.clamp(Val, Slider.Min, Slider.Max)
        local Percent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
        SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
        ValueLabel.Text = tostring(Slider.Value) .. Slider.Suffix
        Slider.Callback(Slider.Value)
        Library:SafeCallback(Slider.Changed, Slider.Value)
    end

    function Slider:OnChanged(Func)
        Slider.Changed = Func
        Func(Slider.Value)
    end

    Slider:SetValue(Slider.Value)
    Library.Options[Idx] = Slider
    return Slider
end

function Library:AddInput(Idx, Info)
    local Input = {
        Type = "Input",
        Text = Info.Text or "Input",
        Default = Info.Default or "",
        Placeholder = Info.Placeholder or "Type here...",
        Callback = Info.Callback or function() end,
        Value = Info.Default or ""
    }

    local InputFrame = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        Parent = self.Container
    })

    local Label = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = Input.Text,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = InputFrame
    })

    local BoxBG = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 28),
        Parent = InputFrame
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = BoxBG
    })

    local Stroke = Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(55, 55, 55),
        Thickness = 1,
        Parent = BoxBG
    })

    local TextBox = Library:Create("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.Gotham,
        PlaceholderText = Input.Placeholder,
        PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
        Text = Input.Default,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = BoxBG
    })

    TextBox.Focused:Connect(function()
        Library:Tween(Stroke, {Color = Library.AccentColor}, 0.2)
    end)

    TextBox.FocusLost:Connect(function()
        Library:Tween(Stroke, {Color = Color3.fromRGB(55, 55, 55)}, 0.2)
        Input:SetValue(TextBox.Text)
    end)

    function Input:SetValue(Val)
        Input.Value = Val
        TextBox.Text = Val
        Input.Callback(Val)
        Library:SafeCallback(Input.Changed, Val)
    end

    function Input:OnChanged(Func)
        Input.Changed = Func
        Func(Input.Value)
    end

    Library.Options[Idx] = Input
    return Input
end

function Library:AddDropdown(Idx, Info)
    local Dropdown = {
        Type = "Dropdown",
        Values = Info.Values or {},
        Value = Info.Multi and {} or nil,
        Multi = Info.Multi or false,
        AllowNull = Info.AllowNull or false,
        Display = Info.Text or "Dropdown",
        Callback = Info.Callback or function() end,
        MaxVisible = Info.MaxVisible or 6,
        Buttons = {}
    }

    local DropdownFrame = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, Info.Compact and 30 or 52),
        Parent = self.Container
    })

    if not Info.Compact then
        Library:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.Gotham,
            Text = Dropdown.Display,
            TextColor3 = Color3.fromRGB(230, 230, 230),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = DropdownFrame
        })
    end

    local BoxBG = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        Position = Info.Compact and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 28),
        Parent = DropdownFrame
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = BoxBG
    })

    local Stroke = Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(55, 55, 55),
        Thickness = 1,
        Parent = BoxBG
    })

    local ValueLabel = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "None",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = BoxBG
    })

    local Arrow = Library:Create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        Image = "rbxassetid://10709790948",
        ImageColor3 = Color3.fromRGB(150, 150, 150),
        Parent = BoxBG
    })

    local DropBtn = Library:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = BoxBG
    })

    local MenuContainer = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ZIndex = 100,
        Parent = Library.ScreenGui
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MenuContainer
    })

    local MenuStroke = Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(60, 60, 60),
        Thickness = 1,
        Parent = MenuContainer
    })

    local ScrollList = Library:Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 4),
        Size = UDim2.new(1, -8, 1, -8),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
        ZIndex = 101,
        Parent = MenuContainer
    })

    local ListLayout = Library:Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ScrollList
    })

    local DynamicHeight = 0

    local function RecalculateHeight()
        local Count = math.min(#Dropdown.Values, Dropdown.MaxVisible)
        DynamicHeight = (Count * 26) + (Count > 0 and (Count - 1) * 2 or 0) + 8
        MenuContainer.Size = UDim2.new(0, BoxBG.AbsoluteSize.X, 0, DynamicHeight)
        ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end

    local Open = false

    local function ToggleMenu()
        Open = not Open
        if Open then
            MenuContainer.Position = UDim2.new(0, BoxBG.AbsolutePosition.X, 0, BoxBG.AbsolutePosition.Y + BoxBG.AbsoluteSize.Y + 4)
            RecalculateHeight()
            MenuContainer.Visible = true
            Library:Tween(Arrow, {Rotation = 180}, 0.2)
            Library:Tween(Stroke, {Color = Library.AccentColor}, 0.2)
        else
            MenuContainer.Visible = false
            Library:Tween(Arrow, {Rotation = 0}, 0.2)
            Library:Tween(Stroke, {Color = Color3.fromRGB(55, 55, 55)}, 0.2)
        end
    end

    DropBtn.MouseButton1Click:Connect(ToggleMenu)

    game:GetService("UserInputService").InputBegan:Connect(function(Input)
        if Open and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
            local Pos = Input.Position
            local MPos = MenuContainer.AbsolutePosition
            local MSize = MenuContainer.AbsoluteSize
            local BPos = BoxBG.AbsolutePosition
            local BSize = BoxBG.AbsoluteSize

            local InsideMenu = Pos.X >= MPos.X and Pos.X <= MPos.X + MSize.X and Pos.Y >= MPos.Y and Pos.Y <= MPos.Y + MSize.Y
            local InsideBox = Pos.X >= BPos.X and Pos.X <= BPos.X + BSize.X and Pos.Y >= BPos.Y and Pos.Y <= BPos.Y + BSize.Y

            if not InsideMenu and not InsideBox then
                ToggleMenu()
            end
        end
    end)

    function Dropdown:BuildDropdownList()
        for _, Child in ipairs(ScrollList:GetChildren()) do
            if Child:IsA("TextButton") then
                Child:Destroy()
            end
        end
        Dropdown.Buttons = {}

        for _, Value in ipairs(Dropdown.Values) do
            local ItemBtn = Library:Create("TextButton", {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Font = Enum.Font.Gotham,
                Text = "",
                ZIndex = 102,
                Parent = ScrollList
            })

            Library:Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = ItemBtn
            })

            local ItemText = Library:Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -16, 1, 0),
                Font = Enum.Font.Gotham,
                Text = tostring(Value),
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 103,
                Parent = ItemBtn
            })

            ItemBtn.MouseEnter:Connect(function()
                Library:Tween(ItemBtn, {BackgroundTransparency = 0.5}, 0.1)
            end)

            ItemBtn.MouseLeave:Connect(function()
                Library:Tween(ItemBtn, {BackgroundTransparency = 1}, 0.1)
            end)

            ItemBtn.MouseButton1Click:Connect(function()
                if Dropdown.Multi then
                    if Dropdown.Value[Value] then
                        Dropdown.Value[Value] = nil
                    else
                        Dropdown.Value[Value] = true
                    end
                    Dropdown:Display()
                else
                    Dropdown:SetValue(Value)
                    ToggleMenu()
                end
            end)

            Dropdown.Buttons[Value] = {
                Button = ItemBtn,
                Text = ItemText
            }
        end
        RecalculateHeight()
    end

    function Dropdown:Display()
        if Dropdown.Multi then
            local Selected = {}
            for Val, State in pairs(Dropdown.Value) do
                if State then
                    table.insert(Selected, Val)
                end
            end
            ValueLabel.Text = #Selected > 0 and table.concat(Selected, ", ") or "None"

            for Val, BtnObj in pairs(Dropdown.Buttons) do
                local Active = Dropdown.Value[Val]
                BtnObj.Text.TextColor3 = Active and Library.AccentColor or Color3.fromRGB(200, 200, 200)
            end
        else
            ValueLabel.Text = Dropdown.Value and tostring(Dropdown.Value) or "None"
            for Val, BtnObj in pairs(Dropdown.Buttons) do
                local Active = Dropdown.Value == Val
                BtnObj.Text.TextColor3 = Active and Library.AccentColor or Color3.fromRGB(200, 200, 200)
            end
        end
    end

    function Dropdown:SetValue(Val)
        if Dropdown.Multi then
            Dropdown.Value = type(Val) == "table" and Val or {}
        else
            if Val == nil and not Dropdown.AllowNull then
                Val = Dropdown.Values[1]
            end
            Dropdown.Value = Val
        end
        Dropdown:Display()
        Dropdown.Callback(Dropdown.Value)
        Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
    end

    function Dropdown:SetValues(NewValues)
        Dropdown.Values = NewValues
        Dropdown:BuildDropdownList()
        if Dropdown.Multi then
            Dropdown.Value = {}
        else
            Dropdown.Value = Dropdown.AllowNull and nil or Dropdown.Values[1]
        end
        Dropdown:Display()
    end

    function Dropdown:OnChanged(Func)
        Dropdown.Changed = Func
        Func(Dropdown.Value)
    end

    Dropdown:BuildDropdownList()
    Dropdown:SetValue(Info.Default or (Dropdown.Multi and {} or Dropdown.Values[1]))

    Library.Options[Idx] = Dropdown
    return Dropdown
end

function Library:AddDependencyBox(Info)
    local DepBox = {
        Dependencies = Info.Dependencies or {},
        Container = nil
    }

    local BoxFrame = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent = self.Container
    })

    local Layout = Library:Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = BoxFrame
    })

    DepBox.Container = BoxFrame

    local function EvaluateDependencies()
        local Visible = true
        for OptionIdx, ExpectedValue in pairs(DepBox.Dependencies) do
            local Option = Library.Options[OptionIdx]
            if Option then
                if type(ExpectedValue) == "table" then
                    if not table.find(ExpectedValue, Option.Value) then
                        Visible = false
                        break
                    end
                elseif Option.Value ~= ExpectedValue then
                    Visible = false
                    break
                end
            end
        end

        BoxFrame.Visible = Visible
        if Visible then
            BoxFrame.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
        else
            BoxFrame.Size = UDim2.new(1, 0, 0, 0)
        end
    end

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if BoxFrame.Visible then
            BoxFrame.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
        end
    end)

    for OptionIdx, _ in pairs(DepBox.Dependencies) do
        local Option = Library.Options[OptionIdx]
        if Option then
            local OldCallback = Option.Callback
            Option.Callback = function(Val)
                if OldCallback then OldCallback(Val) end
                EvaluateDependencies()
            end
        end
    end

    task.defer(EvaluateDependencies)
    return DepBox
end

function Library:AddLabel(Text, DoesWrap)
    local Label = {}

    local LabelFrame = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Parent = self.Container
    })

    local TextLabel = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = Text or "",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = DoesWrap or false,
        Parent = LabelFrame
    })

    if DoesWrap then
        TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
            LabelFrame.Size = UDim2.new(1, 0, 0, TextLabel.TextBounds.Y)
        end)
    end

    function Label:SetText(NewText)
        TextLabel.Text = NewText
    end

    return Label
end

function Library:AddDivider()
    local DividerFrame = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 8),
        Parent = self.Container
    })

    Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = DividerFrame
    })
end

function Library:AddGroupbox(Container, Title)
    local Groupbox = {
        Container = nil,
        Title = Title or "Groupbox"
    }

    local BoxFrame = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(26, 26, 26),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Container
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = BoxFrame
    })

    Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(45, 45, 45),
        Thickness = 1,
        Parent = BoxFrame
    })

    local Header = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = BoxFrame
    })

    local TitleLabel = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Groupbox.Title,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })

    local InnerContainer = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 28),
        Size = UDim2.new(1, -24, 0, 0),
        Parent = BoxFrame
    })

    local ListLayout = Library:Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = InnerContainer
    })

    Groupbox.Container = InnerContainer

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        InnerContainer.Size = UDim2.new(1, -24, 0, ListLayout.AbsoluteContentSize.Y)
        BoxFrame.Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 36)
    end)

    function Groupbox:AddToggle(Idx, Info) return Library.AddToggle(Groupbox, Idx, Info) end
    function Groupbox:AddButton(Info) return Library.AddButton(Groupbox, Info) end
    function Groupbox:AddSlider(Idx, Info) return Library.AddSlider(Groupbox, Idx, Info) end
    function Groupbox:AddInput(Idx, Info) return Library.AddInput(Groupbox, Idx, Info) end
    function Groupbox:AddDropdown(Idx, Info) return Library.AddDropdown(Groupbox, Idx, Info) end
    function Groupbox:AddDependencyBox(Info) return Library.AddDependencyBox(Groupbox, Info) end
    function Groupbox:AddLabel(Text, Wrap) return Library.AddLabel(Groupbox, Text, Wrap) end
    function Groupbox:AddDivider() return Library.AddDivider(Groupbox) end

    return Groupbox
end

function Library:AddTabbox(Container, Title)
    local Tabbox = {
        Tabs = {},
        Container = nil
    }

    local BoxFrame = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(26, 26, 26),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Container
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = BoxFrame
    })

    Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(45, 45, 45),
        Thickness = 1,
        Parent = BoxFrame
    })

    local Header = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = BoxFrame
    })

    local TabButtonsLayout = Library:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Header
    })

    local InnerContainer = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 28),
        Size = UDim2.new(1, -24, 0, 0),
        Parent = BoxFrame
    })

    Tabbox.Container = InnerContainer

    function Tabbox:AddTab(TabTitle)
        local SubTab = {
            Title = TabTitle,
            Container = nil,
            Groupbox = {}
        }

        local TabContainer = Library:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = InnerContainer
        })

        local ListLayout = Library:Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContainer
        })

        SubTab.Container = TabContainer

        local TabButton = Library:Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = TabTitle,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 12,
            Parent = Header
        })

        TabButton.Size = UDim2.new(1 / math.max(#Tabbox.Tabs + 1, 1), 0, 1, 0)

        for _, ExistingTab in ipairs(Tabbox.Tabs) do
            ExistingTab.Button.Size = UDim2.new(1 / (#Tabbox.Tabs + 1), 0, 1, 0)
        end

        SubTab.Button = TabButton

        local function ShowTab()
            for _, T in ipairs(Tabbox.Tabs) do
                T.Container.Visible = false
                T.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
            SubTab.Container.Visible = true
            SubTab.Button.TextColor3 = Library.AccentColor
            InnerContainer.Size = UDim2.new(1, -24, 0, ListLayout.AbsoluteContentSize.Y)
            BoxFrame.Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 36)
        end

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if SubTab.Container.Visible then
                InnerContainer.Size = UDim2.new(1, -24, 0, ListLayout.AbsoluteContentSize.Y)
                BoxFrame.Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 36)
            end
        end)

        TabButton.MouseButton1Click:Connect(ShowTab)

        function SubTab:AddToggle(Idx, Info) return Library.AddToggle(SubTab, Idx, Info) end
        function SubTab:AddButton(Info) return Library.AddButton(SubTab, Info) end
        function SubTab:AddSlider(Idx, Info) return Library.AddSlider(SubTab, Idx, Info) end
        function SubTab:AddInput(Idx, Info) return Library.AddInput(SubTab, Idx, Info) end
        function SubTab:AddDropdown(Idx, Info) return Library.AddDropdown(SubTab, Idx, Info) end
        function SubTab:AddDependencyBox(Info) return Library.AddDependencyBox(SubTab, Info) end
        function SubTab:AddLabel(Text, Wrap) return Library.AddLabel(SubTab, Text, Wrap) end
        function SubTab:AddDivider() return Library.AddDivider(SubTab) end

        table.insert(Tabbox.Tabs, SubTab)
        if #Tabbox.Tabs == 1 then
            ShowTab()
        end

        return SubTab
    end

    return Tabbox
end

function Library:CreateWindow(Info)
    Info = Info or {}
    local Window = {
        Title = Info.Title or "Obsidian UI",
        SubTitle = Info.SubTitle or "",
        TabButtons = {},
        Tabs = {},
        ActiveTab = nil
    }

    local MainFrame = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.new(0.5, -280, 0.5, -200),
        Size = UDim2.new(0, 560, 0, 400),
        Parent = Library.ScreenGui
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    })

    Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(45, 45, 45),
        Thickness = 1,
        Parent = MainFrame
    })

    Library:MakeDraggable(MainFrame)
    Library:MakeResizable(MainFrame, Vector2.new(480, 320))

    local Topbar = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainFrame
    })

    local TitleLabel = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Window.Title .. (Window.SubTitle ~= "" and (" <font color=\"rgb(150,150,150)\">| " .. Window.SubTitle .. "</font>") or ""),
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        Parent = Topbar
    })

    local ContentArea = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 40),
        Size = UDim2.new(1, -150, 1, -40),
        Parent = MainFrame
    })

    local Sidebar = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 150, 1, -40),
        Parent = MainFrame
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = Sidebar
    })

    local SidebarList = Library:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Sidebar
    })

    Library:Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = Sidebar
    })

    function Window:AddTab(TabName)
        local Tab = {
            Name = TabName,
            LeftContainer = nil,
            RightContainer = nil
        }

        local TabButton = Library:Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(32, 32, 32),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.Gotham,
            Text = TabName,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Sidebar
        })

        Library:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabButton
        })

        Library:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            Parent = TabButton
        })

        local TabContent = Library:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = ContentArea
        })

        local LeftScroll = Library:Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0.5, -12, 1, -16),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
            Parent = TabContent
        })

        local LeftLayout = Library:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = LeftScroll
        })

        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LeftScroll.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 8)
        end)

        local RightScroll = Library:Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 4, 0, 8),
            Size = UDim2.new(0.5, -12, 1, -16),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
            Parent = TabContent
        })

        local RightLayout = Library:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = RightScroll
        })

        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightScroll.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 8)
        end)

        Tab.LeftContainer = LeftScroll
        Tab.RightContainer = RightScroll

        function Tab:AddLeftGroupbox(Title)
            return Library:AddGroupbox(Tab.LeftContainer, Title)
        end

        function Tab:AddRightGroupbox(Title)
            return Library:AddGroupbox(Tab.RightContainer, Title)
        end

        function Tab:AddLeftTabbox(Title)
            return Library:AddTabbox(Tab.LeftContainer, Title)
        end

        function Tab:AddRightTabbox(Title)
            return Library:AddTabbox(Tab.RightContainer, Title)
        end

        local function Activate()
            for _, T in ipairs(Window.Tabs) do
                T.Content.Visible = false
                Library:Tween(T.Button, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.15)
            end
            TabContent.Visible = true
            Library:Tween(TabButton, {BackgroundTransparency = 0, TextColor3 = Library.AccentColor}, 0.15)
            Window.ActiveTab = Tab
        end

        TabButton.MouseButton1Click:Connect(Activate)

        Tab.Button = TabButton
        Tab.Content = TabContent

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            Activate()
        end

        return Tab
    end

    Library.Window = Window
    return Window
end

function Library:Notify(Text, Time)
    Time = Time or 5

    if not Library.NotificationHolder then
        Library.NotificationHolder = Library:Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -280, 1, -20),
            AnchorPoint = Vector2.new(0, 1),
            Size = UDim2.new(0, 260, 1, 0),
            Parent = Library.ScreenGui
        })

        Library:Create("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Library.NotificationHolder
        })
    end

    local NotifFrame = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent = Library.NotificationHolder
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = NotifFrame
    })

    local Stroke = Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(50, 50, 50),
        Thickness = 1,
        Parent = NotifFrame
    })

    local AccentBar = Library:Create("Frame", {
        BackgroundColor3 = Library.AccentColor,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 3, 1, 0),
        Parent = NotifFrame
    })

    local NotifLabel = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -20, 0, 0),
        Font = Enum.Font.Gotham,
        Text = Text,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = NotifFrame
    })

    NotifLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        local TargetHeight = NotifLabel.TextBounds.Y + 16
        Library:Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, TargetHeight)}, 0.2)
    end)

    task.spawn(function()
        local TargetHeight = NotifLabel.TextBounds.Y + 16
        NotifFrame.Size = UDim2.new(1, 0, 0, 0)
        Library:Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, TargetHeight)}, 0.2)
        task.wait(Time)
        Library:Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        NotifFrame:Destroy()
    end)
end

function Library:SetWatermark(Text)
    if not Library.WatermarkFrame then
        Library.WatermarkFrame = Library:Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            Position = UDim2.new(0, 15, 0, 15),
            Size = UDim2.new(0, 0, 0, 26),
            Visible = false,
            Parent = Library.ScreenGui
        })

        Library:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Library.WatermarkFrame
        })

        Library:Create("UIStroke", {
            ApplyStrokeMode = Enum.UIStrokeMode.Border,
            Color = Color3.fromRGB(50, 50, 50),
            Thickness = 1,
            Parent = Library.WatermarkFrame
        })

        Library.WatermarkLabel = Library:Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = "",
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = Library.WatermarkFrame
        })
    end

    Library.WatermarkLabel.Text = Text
    local Width = Library.WatermarkLabel.TextBounds.X + 20
    Library.WatermarkFrame.Size = UDim2.new(0, Width, 0, 26)
end

function Library:SetWatermarkVisibility(Visible)
    if Library.WatermarkFrame then
        Library.WatermarkFrame.Visible = Visible
    end
end

function Library:CreateKeybindFrame()
    local Frame = Library:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        Position = UDim2.new(0, 15, 0.5, -100),
        Size = UDim2.new(0, 200, 0, 30),
        Visible = false,
        Parent = Library.ScreenGui
    })

    Library:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Frame
    })

    Library:Create("UIStroke", {
        ApplyStrokeMode = Enum.UIStrokeMode.Border,
        Color = Color3.fromRGB(50, 50, 50),
        Thickness = 1,
        Parent = Frame
    })

    local Top = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = Frame
    })

    Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "Keybinds",
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    local Container = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 30),
        Size = UDim2.new(1, -20, 0, 0),
        Parent = Frame
    })

    local List = Library:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Container
    })

    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.Size = UDim2.new(1, -20, 0, List.AbsoluteContentSize.Y)
        Frame.Size = UDim2.new(0, 200, 0, List.AbsoluteContentSize.Y + 36)
    end)

    Library:MakeDraggable(Frame)
    Library.KeybindFrame = Frame
    Library.KeybindContainer = Container
end

function Library:SetKeybindFrameVisibility(Visible)
    if not Library.KeybindFrame then
        Library:CreateKeybindFrame()
    end
    Library.KeybindFrame.Visible = Visible
end

function Library:Add3DGrid(Container, Info)
    local GridObj = {
        Items = Info.Items or {},
        Callback = Info.Callback or function() end,
        Selected = nil
    }

    local GridFrame = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, Info.Height or 200),
        Parent = Container
    })

    local Scroll = Library:Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
        Parent = GridFrame
    })

    local UIGrid = Library:Create("UIGridLayout", {
        CellPadding = UDim2.new(0, 6, 0, 6),
        CellSize = UDim2.new(0, Info.ItemSize or 60, 0, Info.ItemSize or 60),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Scroll
    })

    UIGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, UIGrid.AbsoluteContentSize.Y + 6)
    end)

    local ViewportCache = {}

    local function RenderItem(ItemData, ItemFrame)
        if ViewportCache[ItemData] then return end

        local Viewport = Library:Create("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = ItemFrame
        })

        local Camera = Instance.new("Camera")
        Viewport.CurrentCamera = Camera
        Camera.Parent = Viewport

        if ItemData.Model then
            local ModelCopy = ItemData.Model:Clone()
            ModelCopy.Parent = Viewport

            local Primary = ModelCopy.PrimaryPart or ModelCopy:FindFirstChildWhichIsA("BasePart")
            if Primary then
                local Pos = Primary.Position
                Camera.CFrame = CFrame.new(Pos + Vector3.new(0, 1.5, 3.5), Pos)
            end
        end

        ViewportCache[ItemData] = Viewport
    end

    for _, ItemData in ipairs(GridObj.Items) do
        local ItemBtn = Library:Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(32, 32, 32),
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            Parent = Scroll
        })

        Library:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = ItemBtn
        })

        local Stroke = Library:Create("UIStroke", {
            ApplyStrokeMode = Enum.UIStrokeMode.Border,
            Color = Color3.fromRGB(50, 50, 50),
            Thickness = 1,
            Parent = ItemBtn
        })

        ItemBtn.MouseButton1Click:Connect(function()
            GridObj.Selected = ItemData
            GridObj.Callback(ItemData)
        end)

        RenderItem(ItemData, ItemBtn)
    end

    return GridObj
end

function Library:Unload()
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end

    for _, Signal in pairs(Library.Signals or {}) do
        if Signal and Signal.Disconnect then
            Signal:Disconnect()
        end
    end
end

return Library
