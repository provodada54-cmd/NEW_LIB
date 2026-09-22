local ThemeManager = {
    Folder = "ObsidianSettings",
    Library = nil,
    BuiltInThemes = {
        ["Default"] = {
            AccentColor = Color3.fromRGB(0, 120, 215),
            MainColor = Color3.fromRGB(20, 20, 20),
            BackgroundColor = Color3.fromRGB(26, 26, 26),
            OutlineColor = Color3.fromRGB(45, 45, 45),
            FontColor = Color3.fromRGB(240, 240, 240)
        },
        ["Rose"] = {
            AccentColor = Color3.fromRGB(255, 100, 150),
            MainColor = Color3.fromRGB(25, 20, 22),
            BackgroundColor = Color3.fromRGB(35, 28, 30),
            OutlineColor = Color3.fromRGB(60, 45, 50),
            FontColor = Color3.fromRGB(250, 240, 245)
        },
        ["Mint"] = {
            AccentColor = Color3.fromRGB(0, 255, 150),
            MainColor = Color3.fromRGB(15, 25, 20),
            BackgroundColor = Color3.fromRGB(22, 35, 28),
            OutlineColor = Color3.fromRGB(40, 60, 50),
            FontColor = Color3.fromRGB(240, 250, 245)
        },
        ["Dark Gold"] = {
            AccentColor = Color3.fromRGB(255, 200, 50),
            MainColor = Color3.fromRGB(20, 20, 15),
            BackgroundColor = Color3.fromRGB(30, 30, 25),
            OutlineColor = Color3.fromRGB(55, 55, 45),
            FontColor = Color3.fromRGB(250, 250, 240)
        }
    }
}

local HttpService = game:GetService("HttpService")

function ThemeManager:SetLibrary(Lib)
    self.Library = Lib
end

function ThemeManager:SetFolder(Folder)
    self.Folder = Folder
end

function ThemeManager:ApplyTheme(Theme)
    self.Library.AccentColor = Theme.AccentColor
    
    for Idx, Option in pairs(self.Library.Options) do
        if Option.Type == "Toggle" and Option.Value then
            Option:SetValue(true)
        elseif Option.Type == "Slider" then
            Option:SetValue(Option.Value)
        end
    end
end

function ThemeManager:SaveCustomTheme(Name)
    if not Name or #Name == 0 then return end
    
    local Theme = {
        AccentColor = self.Library.AccentColor:ToHex(),
    }
    
    local FullPath = self.Folder .. "/themes/" .. Name .. ".json"
    writefile(FullPath, HttpService:JSONEncode(Theme))
end

function ThemeManager:LoadCustomTheme(Name)
    local FullPath = self.Folder .. "/themes/" .. Name .. ".json"
    if not isfile(FullPath) then return end
    
    local Data = HttpService:JSONDecode(readfile(FullPath))
    if Data.AccentColor then
        self:ApplyTheme({
            AccentColor = Color3.fromHex(Data.AccentColor)
        })
    end
end

function ThemeManager:RefreshThemeList()
    local List = {}
    for Name, _ in pairs(self.BuiltInThemes) do
        table.insert(List, Name)
    end
    
    if isfolder(self.Folder .. "/themes") then
        local Files = listfiles(self.Folder .. "/themes")
        for _, File in ipairs(Files) do
            if File:sub(-5) == ".json" then
                local Pos = File:find("%.json$")
                local Name = File:sub(#self.Folder + 10, Pos - 1)
                table.insert(List, Name)
            end
        end
    end
    
    return List
end

function ThemeManager:ApplyToTab(Tab)
    local Groupbox = Tab:AddRightGroupbox("Theme Settings")
    
    Groupbox:AddLabel("Accent Color"):AddColorPicker("ThemeManager_AccentColor", {
        Default = self.Library.AccentColor,
        Callback = function(Value)
            self:ApplyTheme({AccentColor = Value})
        end
    })
    
    local ThemeDropdown = Groupbox:AddDropdown("ThemeManager_ThemeList", {
        Text = "Theme List",
        Values = self:RefreshThemeList(),
        Default = "Default"
    })
    
    ThemeDropdown:OnChanged(function(Value)
        if self.BuiltInThemes[Value] then
            self:ApplyTheme(self.BuiltInThemes[Value])
        else
            self:LoadCustomTheme(Value)
        end
    end)
    
    local CustomName = Groupbox:AddInput("ThemeManager_CustomName", {
        Text = "Custom Theme Name",
        Placeholder = "My Theme"
    })
    
    Groupbox:AddButton({
        Text = "Save Custom Theme",
        Func = function()
            local Name = CustomName.Value
            if #Name > 0 then
                if not isfolder(self.Folder .. "/themes") then
                    makefolder(self.Folder .. "/themes")
                end
                self:SaveCustomTheme(Name)
                ThemeDropdown:SetValues(self:RefreshThemeList())
                ThemeDropdown:SetValue(Name)
            end
        end
    })
    
    Groupbox:AddButton({
        Text = "Refresh Themes",
        Func = function()
            ThemeDropdown:SetValues(self:RefreshThemeList())
        end
    })
end

return ThemeManager