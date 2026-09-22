local SaveManager = {
    Folder = "ObsidianSettings",
    Ignore = {},
    Parser = {
        Toggle = function(Idx, Object, Value)
            Object:SetValue(Value)
        end,
        Slider = function(Idx, Object, Value)
            Object:SetValue(Value)
        end,
        Dropdown = function(Idx, Object, Value)
            Object:SetValue(Value)
        end,
        Input = function(Idx, Object, Value)
            Object:SetValue(Value)
        end,
        ColorPicker = function(Idx, Object, Value)
            Object:SetValue(Color3.fromRGB(Value[1], Value[2], Value[3]))
            if Object.SetTransparency and Value[4] then
                Object:SetTransparency(Value[4])
            end
        end,
        KeyPicker = function(Idx, Object, Value)
            Object:SetValue({Value[1], Value[2]})
        end,
    }
}

local HttpService = game:GetService("HttpService")

function SaveManager:SetFolder(Folder)
    self.Folder = Folder
    self:BuildFolderTree()
end

function SaveManager:SetLibrary(Lib)
    self.Library = Lib
end

function SaveManager:IgnoreThemeSettings()
    self:SetIgnoreIndexes({
        "BackgroundColor", "MainColor", "AccentColor",
        "OutlineColor", "FontColor"
    })
end

function SaveManager:SetIgnoreIndexes(List) {
    for _, Key in ipairs(List) do
        self.Ignore[Key] = true
    end
}

function SaveManager:BuildFolderTree()
    local Paths = {
        self.Folder,
        self.Folder .. "/settings"
    }

    for _, Path in ipairs(Paths) do
        if not isfolder(Path) then
            makefolder(Path)
        end
    end
end

function SaveManager:Save(Name)
    if not Name or #Name == 0 then return false end

    local FullPath = self.Folder .. "/settings/" .. Name .. ".json"
    local Data = {}

    for Idx, Option in pairs(self.Library.Options) do
        if self.Ignore[Idx] then continue end

        if Option.Type == "Toggle" then
            Data[Idx] = { Type = "Toggle", Value = Option.Value }
        elseif Option.Type == "Slider" then
            Data[Idx] = { Type = "Slider", Value = Option.Value }
        elseif Option.Type == "Dropdown" then
            Data[Idx] = { Type = "Dropdown", Value = Option.Value }
        elseif Option.Type == "Input" then
            Data[Idx] = { Type = "Input", Value = Option.Value }
        elseif Option.Type == "ColorPicker" then
            Data[Idx] = {
                Type = "ColorPicker",
                Value = {
                    math.floor(Option.Value.R * 255),
                    math.floor(Option.Value.G * 255),
                    math.floor(Option.Value.B * 255),
                    Option.Transparency
                }
            }
        elseif Option.Type == "KeyPicker" then
            Data[Idx] = {
                Type = "KeyPicker",
                Value = { Option.Value, Option.Mode }
            }
        end
    end

    local Success, Encoded = pcall(function()
        return HttpService:JSONEncode(Data)
    end)

    if Success then
        writefile(FullPath, Encoded)
        return true
    end

    return false
end

function SaveManager:Load(Name)
    if not Name or #Name == 0 then return false end

    local FullPath = self.Folder .. "/settings/" .. Name .. ".json"
    if not isfile(FullPath) then return false end

    local Success, RawData = pcall(function()
        return readfile(FullPath)
    end)

    if not Success then return false end

    local DecodeSuccess, Data = pcall(function()
        return HttpService:JSONDecode(RawData)
    end)

    if not DecodeSuccess then return false end

    for Idx, Saved in pairs(Data) do
        local Option = self.Library.Options[Idx]
        if Option and self.Parser[Saved.Type] then
            task.spawn(function()
                self.Parser[Saved.Type](Idx, Option, Saved.Value)
            end)
        end
    end

    return true
end

function SaveManager:Delete(Name)
    if not Name or #Name == 0 then return false end

    local FullPath = self.Folder .. "/settings/" .. Name .. ".json"
    if isfile(FullPath) then
        delfile(FullPath)
        return true
    end

    return false
end

function SaveManager:RefreshConfigList()
    local List = {}
    local Files = listfiles(self.Folder .. "/settings")

    for _, File in ipairs(Files) do
        if File:sub(-5) == ".json" then
            local Pos = File:find("%.json$")
            local Name = File:sub(#self.Folder + 11, Pos - 1)
            table.insert(List, Name)
        end
    end

    return List
end

function SaveManager:BuildConfigSection(Tab)
    local Groupbox = Tab:AddRightGroupbox("Configuration")

    local ConfigDropdown = Groupbox:AddDropdown("SaveManager_ConfigList", {
        Text = "Config List",
        Values = self:RefreshConfigList(),
        AllowNull = true,
    })

    local ConfigInput = Groupbox:AddInput("SaveManager_ConfigName", {
        Text = "Config Name",
        Placeholder = "My Config"
    })

    Groupbox:AddButton({
        Text = "Create Config",
        Func = function()
            local Name = ConfigInput.Value
            if #Name > 0 then
                self:Save(Name)
                ConfigDropdown:SetValues(self:RefreshConfigList())
                ConfigDropdown:SetValue(Name)
            end
        end
    })

    Groupbox:AddButton({
        Text = "Save Config",
        Func = function()
            local Name = ConfigDropdown.Value
            if Name and #Name > 0 then
                self:Save(Name)
            end
        end
    })

    Groupbox:AddButton({
        Text = "Load Config",
        Func = function()
            local Name = ConfigDropdown.Value
            if Name and #Name > 0 then
                self:Load(Name)
            end
        end
    })

    Groupbox:AddButton({
        Text = "Delete Config",
        Func = function()
            local Name = ConfigDropdown.Value
            if Name and #Name > 0 then
                self:Delete(Name)
                ConfigDropdown:SetValues(self:RefreshConfigList())
                ConfigDropdown:SetValue(nil)
            end
        end
    })

    Groupbox:AddButton({
        Text = "Refresh List",
        Func = function()
            ConfigDropdown:SetValues(self:RefreshConfigList())
        end
    })

    local AutoLoadToggle = Groupbox:AddToggle("SaveManager_AutoLoad", {
        Text = "Auto Load Config",
        Default = false
    })

    if isfile(self.Folder .. "/settings/autoload.txt") then
        local Name = readfile(self.Folder .. "/settings/autoload.txt")
        if isfile(self.Folder .. "/settings/" .. Name .. ".json") then
            self:Load(Name)
        end
    end

    AutoLoadToggle:OnChanged(function(Value)
        if Value then
            local Name = ConfigDropdown.Value
            if Name and #Name > 0 then
                writefile(self.Folder .. "/settings/autoload.txt", Name)
            end
        else
            if isfile(self.Folder .. "/settings/autoload.txt") then
                delfile(self.Folder .. "/settings/autoload.txt")
            end
        end
    end)
end

return SaveManager