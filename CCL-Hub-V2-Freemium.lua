local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ==========================================
--               CONFIGURATION
-- ==========================================
local Config = {
    AimAssistEnabled = false,
    AimKey = Enum.UserInputType.MouseButton2,
    AssistStrength = 0.1,
    MaxFOV = 150,
    
    PredictionEnabled = false,
    PredictionFactor = 0.05,

    HighlightEnabled = false,
    
    FlyEnabled = false,
    FlySpeed = 50,
}

local isAiming = false
local menuOpen = false

-- ==========================================
--               UI CREATION
-- ==========================================
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CCL_HUB_X"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Notification Container
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 250, 1, -20)
NotifContainer.Position = UDim2.new(1, -260, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

-- Main Menu Canvas
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.05 -- Slight glass effect
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.GroupTransparency = 1 
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UIScale = Instance.new("UIScale", MainFrame)
UIScale.Scale = 0.7

-- Rounded Edges & Outline (Only the edges pop)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(100, 150, 255)
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Draggable Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CCL Hub X"
Title.TextColor3 = Color3.fromRGB(100, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 1, 0)
Divider.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
Divider.BorderSizePixel = 0
Divider.Parent = TopBar

-- Scrolling Container for Options
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -55)
ScrollFrame.Position = UDim2.new(0, 0, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
ScrollFrame.Parent = MainFrame

local ScrollLayout = Instance.new("UIListLayout", ScrollFrame)
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollLayout.Padding = UDim.new(0, 8)
ScrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ScrollPadding = Instance.new("UIPadding", ScrollFrame)
ScrollPadding.PaddingTop = UDim.new(0, 5)
ScrollPadding.PaddingBottom = UDim.new(0, 15)

-- ==========================================
--            DRAGGING LOGIC
-- ==========================================
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
--            UI HELPER FUNCTIONS
-- ==========================================
local function sendNotification(message)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 45)
    NotifFrame.Position = UDim2.new(1, 50, 0, 0)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    NotifFrame.Parent = NotifContainer
    
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 6)
    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Color = Color3.fromRGB(50, 50, 60)
    NotifStroke.Thickness = 1
    
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 4, 1, 0)
    SideBar.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    SideBar.Parent = NotifFrame
    Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 6)
    
    local NotifText = Instance.new("TextLabel")
    NotifText.Size = UDim2.new(1, -20, 1, 0)
    NotifText.Position = UDim2.new(0, 15, 0, 0)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = message
    NotifText.TextColor3 = Color3.fromRGB(220, 220, 220)
    NotifText.Font = Enum.Font.GothamMedium
    NotifText.TextSize = 13
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    NotifText.Parent = NotifFrame
    
    local NotifLayout = Instance.new("UIListLayout", NotifContainer)
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    
    TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    task.delay(3, function()
        local fadeOut = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
        TweenService:Create(NotifText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(SideBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(NotifStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        fadeOut:Play()
        fadeOut.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

local layoutCounter = 1
local function createSection(name)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.9, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = string.upper(name)
    Label.TextColor3 = Color3.fromRGB(100, 150, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.LayoutOrder = layoutCounter
    layoutCounter = layoutCounter + 1
    Label.Parent = ScrollFrame
end

local function createToggle(name, configKey)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0.9, 0, 0, 38)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Container.LayoutOrder = layoutCounter
    layoutCounter = layoutCounter + 1
    Container.Parent = ScrollFrame
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 44, 0, 22)
    Button.Position = UDim2.new(1, -55, 0.5, -11)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Button.Text = ""
    Button.Parent = Container
    Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 18, 0, 18)
    Indicator.Position = UDim2.new(0, 2, 0.5, -9)
    Indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Indicator.Parent = Button
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    Button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        local isEnabled = Config[configKey]
        
        local targetColor = isEnabled and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(40, 40, 45)
        local targetPos = isEnabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local indicatorColor = isEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        
        TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = targetPos, BackgroundColor3 = indicatorColor}):Play()
        
        sendNotification(name .. (isEnabled and " Enabled" or " Disabled"))
    end)
end

local function createSlider(name, configKey, min, max)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0.9, 0, 0, 50)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Container.LayoutOrder = layoutCounter
    layoutCounter = layoutCounter + 1
    Container.Parent = ScrollFrame
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -30, 0, 20)
    Label.Position = UDim2.new(0, 15, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = name .. " : " .. Config[configKey]
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderBG = Instance.new("TextButton", Container)
    SliderBG.Size = UDim2.new(1, -30, 0, 6)
    SliderBG.Position = UDim2.new(0, 15, 0, 32)
    SliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SliderBG.Text = ""
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame", SliderBG)
    local percent = (Config[configKey] - min) / (max - min)
    Fill.Size = UDim2.new(percent, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local draggingSlider = false
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = SliderBG.AbsolutePosition.X
            local sliderSize = SliderBG.AbsoluteSize.X
            local newPercent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            
            TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(newPercent, 0, 1, 0)}):Play()
            local val = math.floor(min + ((max - min) * newPercent))
            Config[configKey] = val
            Label.Text = name .. " : " .. val
        end
    end)
end

-- Populate Menu Sections
createSection("Combat Settings")
createToggle("Aim Assist", "AimAssistEnabled")
createToggle("Movement Prediction", "PredictionEnabled")

createSection("Visuals & Movement")
createToggle("Player Outlines (ESP)", "HighlightEnabled")
createToggle("Flight Mode", "FlyEnabled")
createSlider("Flight Speed", "FlySpeed", 16, 200)

-- Update ScrollCanvas size based on layout
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y + 20)
ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y + 20)
end)

-- ==========================================
--               INPUT LOGIC
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
        if menuOpen then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
            TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        else
            local closeUI = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {GroupTransparency = 1})
            TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.8}):Play()
            closeUI:Play()
            closeUI.Completed:Connect(function() MainFrame.Visible = false end)
        end
    end
    
    if not gameProcessed and input.UserInputType == Config.AimKey then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AimKey then
        isAiming = false
    end
end)

-- ==========================================
--          FRAMEWORK LOGIC LOOP
-- ==========================================
local function applyHighlight(character)
    if character:FindFirstChild("FPS_Highlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "FPS_Highlight"
    
    -- ONLY THE EDGES ESP SETTINGS:
    highlight.FillTransparency = 1 -- Removes the center fill entirely
    highlight.OutlineTransparency = 0 -- Keeps the bright outline
    highlight.OutlineColor = Color3.fromRGB(255, 50, 50) -- Red outlines
    
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("FPS_Highlight")
            if Config.HighlightEnabled then
                if not highlight then applyHighlight(player.Character) end
                if highlight then highlight.Enabled = true end
            else
                if highlight then highlight.Enabled = false end
            end
        end
    end
    
    if Config.AimAssistEnabled and isAiming then
        local bestTarget = nil
        local shortestDistance = Config.MaxFOV
        local viewportCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local head = player.Character:FindFirstChild("Head")
                if player.Character.Humanoid.Health > 0 and head then
                    local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local screenDist = (Vector2.new(screenPoint.X, screenPoint.Y) - viewportCenter).Magnitude
                        if screenDist < shortestDistance then
                            shortestDistance = screenDist
                            bestTarget = head
                        end
                    end
                end
            end
        end
        
        if bestTarget then
            local targetPos = bestTarget.Position
            if Config.PredictionEnabled then
                targetPos = targetPos + (bestTarget.AssemblyLinearVelocity * Config.PredictionFactor)
            end
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), Config.AssistStrength)
        end
    end
    
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") then
        local rootPart = localPlayer.Character.HumanoidRootPart
        local humanoid = localPlayer.Character.Humanoid
        
        if Config.FlyEnabled then
            humanoid.PlatformStand = true
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            rootPart.Velocity = moveDir * Config.FlySpeed
        else
            if humanoid.PlatformStand then
                humanoid.PlatformStand = false
            end
        end
    end
end)

sendNotification("CCL Hub X Loaded. Press Right Shift.")
