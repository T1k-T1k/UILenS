-- UILenS - Premium GUI Path Monitor for Roblox
-- Enhanced UI Version

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Configuration
local MAIN_GUI_NAME = "UILenS_Premium"
local LOGO_IMAGE_ID = "rbxassetid://120107164785260"
local MONITOR_ENABLED = false
local CORE_GUI_MONITORING = false
local MAX_CONSOLE_MESSAGES = 100
local ACCENT_COLOR = Color3.fromRGB(0, 170, 255)
local DARK_BG = Color3.fromRGB(20, 20, 25)
local LIGHT_BG = Color3.fromRGB(30, 30, 35)
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)

-- Create GUI for all players
local function createMonitorGui(player)
    -- Create main ScreenGui with touch support
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = MAIN_GUI_NAME
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    screenGui.IgnoreGuiInset = true
    
    -- Set parent based on context
    if RunService:IsRunning() and player then
        screenGui.Parent = player:WaitForChild("PlayerGui", 5)
    else
        screenGui.Parent = game:GetService("CoreGui")
    end
    
    if not screenGui.Parent then
        warn("Failed to set ScreenGui parent for player: " .. (player and player.Name or "Unknown"))
        return nil
    end
    
    -- Main container with shadow
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0.6, 0, 0.7, 0)
    mainContainer.Position = UDim2.new(0.2, 0, 0.15, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.ClipsDescendants = true
    mainContainer.Parent = screenGui
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = 0
    shadow.Parent = mainContainer
    
    -- Main frame with rounded corners
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = DARK_BG
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 1
    mainFrame.Parent = mainContainer
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    -- Top bar with gradient
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0.08, 0)
    topBar.BackgroundColor3 = LIGHT_BG
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 2
    topBar.Parent = mainFrame
    
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 8)
    topBarCorner.Parent = topBar
    
    -- Gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ACCENT_COLOR),
        ColorSequenceKeypoint.new(0.1, ACCENT_COLOR),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.1, 0.8),
        NumberSequenceKeypoint.new(1, 1)
    }
    gradient.Rotation = 90
    gradient.Parent = topBar
    
    -- Logo and title container
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.Size = UDim2.new(0.6, 0, 1, 0)
    titleContainer.Position = UDim2.new(0.02, 0, 0, 0)
    titleContainer.BackgroundTransparency = 1
    titleContainer.ZIndex = 3
    titleContainer.Parent = topBar
    
    -- Logo image with subtle shine
    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "Logo"
    logoImage.Size = UDim2.new(0, 32, 0, 32)
    logoImage.Position = UDim2.new(0, 0, 0.5, -16)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = LOGO_IMAGE_ID
    logoImage.ScaleType = Enum.ScaleType.Fit
    logoImage.ZIndex = 3
    logoImage.Parent = titleContainer
    
    -- Title label with subtle glow
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 40, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "UILenS"
    titleLabel.TextColor3 = TEXT_COLOR
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 3
    titleLabel.Parent = titleContainer
    
    local titleStroke = Instance.new("UIStroke")
    titleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    titleStroke.Color = Color3.new(1, 1, 1)
    titleStroke.Transparency = 0.8
    titleStroke.Thickness = 1
    titleStroke.Parent = titleLabel
    
    -- Action buttons container
    local actionButtons = Instance.new("Frame")
    actionButtons.Name = "ActionButtons"
    actionButtons.Size = UDim2.new(0.3, 0, 1, 0)
    actionButtons.Position = UDim2.new(0.7, 0, 0, 0)
    actionButtons.BackgroundTransparency = 1
    actionButtons.ZIndex = 3
    actionButtons.Parent = topBar
    
    -- Minimize button with icon
    local minimizeButton = Instance.new("ImageButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 24, 0, 24)
    minimizeButton.Position = UDim2.new(0.5, -28, 0.5, -12)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minimizeButton.AutoButtonColor = false
    minimizeButton.ZIndex = 4
    minimizeButton.Image = "rbxassetid://3926305904"
    minimizeButton.ImageRectOffset = Vector2.new(124, 204)
    minimizeButton.ImageRectSize = Vector2.new(36, 36)
    minimizeButton.ImageColor3 = TEXT_COLOR
    minimizeButton.Parent = actionButtons
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = minimizeButton
    
    -- Close button with icon
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(0.5, 4, 0.5, -12)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.AutoButtonColor = false
    closeButton.ZIndex = 4
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageRectOffset = Vector2.new(284, 4)
    closeButton.ImageRectSize = Vector2.new(24, 24)
    closeButton.ImageColor3 = TEXT_COLOR
    closeButton.Parent = actionButtons
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Button hover effects
    local function setupButtonHover(button, hoverColor)
        local originalColor = button.BackgroundColor3
        
        button.MouseEnter:Connect(function()
            local tween = TweenService:Create(
                button,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = hoverColor}
            )
            tween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            local tween = TweenService:Create(
                button,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = originalColor}
            )
            tween:Play()
        end)
    end
    
    setupButtonHover(minimizeButton, Color3.fromRGB(80, 80, 90))
    setupButtonHover(closeButton, Color3.fromRGB(220, 80, 80))
    
    -- Console area with subtle border
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Name = "ConsoleFrame"
    consoleFrame.Size = UDim2.new(0.98, 0, 0.7, 0)
    consoleFrame.Position = UDim2.new(0.01, 0, 0.09, 0)
    consoleFrame.BackgroundColor3 = LIGHT_BG
    consoleFrame.BorderSizePixel = 0
    consoleFrame.ZIndex = 2
    consoleFrame.Parent = mainFrame
    
    local consoleCorner = Instance.new("UICorner")
    consoleCorner.CornerRadius = UDim.new(0, 6)
    consoleCorner.Parent = consoleFrame
    
    local consoleStroke = Instance.new("UIStroke")
    consoleStroke.Color = Color3.fromRGB(60, 60, 70)
    consoleStroke.Thickness = 1
    consoleStroke.Parent = consoleFrame
    
    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, 0, 0.06, 0)
    statusBar.Position = UDim2.new(0, 0, 0, 0)
    statusBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    statusBar.BorderSizePixel = 0
    statusBar.ZIndex = 3
    statusBar.Parent = consoleFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusBar
    
    -- Status label with indicator
    local statusContainer = Instance.new("Frame")
    statusContainer.Name = "StatusContainer"
    statusContainer.Size = UDim2.new(0.5, 0, 1, 0)
    statusContainer.Position = UDim2.new(0, 10, 0, 0)
    statusContainer.BackgroundTransparency = 1
    statusContainer.ZIndex = 4
    statusContainer.Parent = statusBar
    
    local statusIndicator = Instance.new("Frame")
    statusIndicator.Name = "StatusIndicator"
    statusIndicator.Size = UDim2.new(0, 10, 0, 10)
    statusIndicator.Position = UDim2.new(0, 0, 0.5, -5)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    statusIndicator.BorderSizePixel = 0
    statusIndicator.ZIndex = 4
    statusIndicator.Parent = statusContainer
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0.5, 0)
    indicatorCorner.Parent = statusIndicator
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 1, 0)
    statusLabel.Position = UDim2.new(0, 15, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.Text = "Monitoring: OFF"
    statusLabel.TextColor3 = TEXT_COLOR
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 4
    statusLabel.Parent = statusContainer
    
    -- Console ScrollingFrame with custom scrollbar
    local consoleScrollFrame = Instance.new("ScrollingFrame")
    consoleScrollFrame.Name = "ConsoleScrollFrame"
    consoleScrollFrame.Size = UDim2.new(1, 0, 0.94, 0)
    consoleScrollFrame.Position = UDim2.new(0, 0, 0.06, 0)
    consoleScrollFrame.BackgroundTransparency = 1
    consoleScrollFrame.BorderSizePixel = 0
    consoleScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
    consoleScrollFrame.ScrollBarThickness = 6
    consoleScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    consoleScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    consoleScrollFrame.ZIndex = 2
    consoleScrollFrame.Parent = consoleFrame
    
    -- Custom scrollbar styling
    consoleScrollFrame.ScrollBarImageTransparency = 0.5
    consoleScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 160)
    
    -- UIListLayout for console messages
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = consoleScrollFrame
    
    -- Controls area with gradient border
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsFrame"
    controlsFrame.Size = UDim2.new(0.98, 0, 0.19, 0)
    controlsFrame.Position = UDim2.new(0.01, 0, 0.8, 0)
    controlsFrame.BackgroundColor3 = LIGHT_BG
    controlsFrame.BorderSizePixel = 0
    controlsFrame.ZIndex = 2
    controlsFrame.Parent = mainFrame
    
    local controlsCorner = Instance.new("UICorner")
    controlsCorner.CornerRadius = UDim.new(0, 6)
    controlsCorner.Parent = controlsFrame
    
    local controlsStroke = Instance.new("UIStroke")
    controlsStroke.Color = Color3.fromRGB(60, 60, 70)
    controlsStroke.Thickness = 1
    controlsStroke.Parent = controlsFrame
    
    -- Controls grid layout
    local controlsGrid = Instance.new("UIGridLayout")
    controlsGrid.Name = "ControlsGrid"
    controlsGrid.CellSize = UDim2.new(0.48, 0, 0.45, 0)
    controlsGrid.CellPadding = UDim2.new(0.02, 0, 0.02, 0)
    controlsGrid.StartCorner = Enum.StartCorner.TopLeft
    controlsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    controlsGrid.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsGrid.Parent = controlsFrame
    
    -- Start/Stop Monitoring Button with icon
    local monitorButton = Instance.new("TextButton")
    monitorButton.Name = "MonitorButton"
    monitorButton.Size = UDim2.new(1, 0, 1, 0)
    monitorButton.BackgroundColor3 = ACCENT_COLOR
    monitorButton.BorderSizePixel = 0
    monitorButton.Font = Enum.Font.GothamBold
    monitorButton.Text = "START MONITORING"
    monitorButton.TextColor3 = TEXT_COLOR
    monitorButton.TextSize = 14
    monitorButton.TextWrapped = true
    monitorButton.ZIndex = 3
    monitorButton.Parent = controlsFrame
    
    local monitorCorner = Instance.new("UICorner")
    monitorCorner.CornerRadius = UDim.new(0, 4)
    monitorCorner.Parent = monitorButton
    
    -- Clear Console Button with icon
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(1, 0, 1, 0)
    clearButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    clearButton.BorderSizePixel = 0
    clearButton.Font = Enum.Font.GothamBold
    clearButton.Text = "CLEAR CONSOLE"
    clearButton.TextColor3 = TEXT_COLOR
    clearButton.TextSize = 14
    clearButton.TextWrapped = true
    clearButton.ZIndex = 3
    clearButton.Parent = controlsFrame
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 4)
    clearCorner.Parent = clearButton
    
    -- CoreGUI Toggle Container
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.Size = UDim2.new(1, 0, 1, 0)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.ZIndex = 3
    toggleContainer.Parent = controlsFrame
    
    -- CoreGUI Toggle Label
    local coreGuiLabel = Instance.new("TextLabel")
    coreGuiLabel.Name = "CoreGuiLabel"
    coreGuiLabel.Size = UDim2.new(0.6, 0, 1, 0)
    coreGuiLabel.Position = UDim2.new(0, 0, 0, 0)
    coreGuiLabel.BackgroundTransparency = 1
    coreGuiLabel.Font = Enum.Font.GothamMedium
    coreGuiLabel.Text = "CoreGUI Monitoring:"
    coreGuiLabel.TextColor3 = TEXT_COLOR
    coreGuiLabel.TextSize = 14
    coreGuiLabel.TextXAlignment = Enum.TextXAlignment.Left
    coreGuiLabel.ZIndex = 3
    coreGuiLabel.Parent = toggleContainer
    
    -- Premium toggle switch
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.Size = UDim2.new(0.35, 0, 0.5, 0)
    toggleFrame.Position = UDim2.new(0.65, 0, 0.25, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 3
    toggleFrame.Parent = toggleContainer
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0.5, 0)
    toggleCorner.Parent = toggleFrame
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    toggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    toggleButton.BorderSizePixel = 0
    toggleButton.ZIndex = 4
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.5, 0)
    buttonCorner.Parent = toggleButton
    
    -- Button hover effects for control buttons
    setupButtonHover(monitorButton, Color3.fromRGB(0, 190, 255))
    setupButtonHover(clearButton, Color3.fromRGB(210, 77, 63))
    
    -- Make the main container draggable with touch support
    local isDragging = false
    local dragStartPos, frameStartPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStartPos
        mainContainer.Position = UDim2.new(
            frameStartPos.X.Scale, 
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale, 
            frameStartPos.Y.Offset + delta.Y
        )
    end
    
    topBar.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) and
            not isDragging then
            
            isDragging = true
            dragStartPos = input.Position
            frameStartPos = mainContainer.Position
            
            -- Capture the input to track movement outside the frame
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                           input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)
    
    -- Create confirmation modal with animation
    local modalBackground = Instance.new("Frame")
    modalBackground.Name = "ConfirmationModal"
    modalBackground.Size = UDim2.new(1, 0, 1, 0)
    modalBackground.Position = UDim2.new(0, 0, 0, 0)
    modalBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    modalBackground.BackgroundTransparency = 0.7
    modalBackground.BorderSizePixel = 0
    modalBackground.Visible = false
    modalBackground.ZIndex = 10
    modalBackground.Parent = screenGui
    
    local modalFrame = Instance.new("Frame")
    modalFrame.Name = "ModalFrame"
    modalFrame.Size = UDim2.new(0.25, 0, 0.18, 0)
    modalFrame.Position = UDim2.new(0.375, 0, 0.41, 0)
    modalFrame.BackgroundColor3 = DARK_BG
    modalFrame.BorderSizePixel = 0
    modalFrame.ZIndex = 11
    modalFrame.Parent = modalBackground
    
    local modalCorners = Instance.new("UICorner")
    modalCorners.CornerRadius = UDim.new(0.05, 0)
    modalCorners.Parent = modalFrame
    
    local modalStroke = Instance.new("UIStroke")
    modalStroke.Color = ACCENT_COLOR
    modalStroke.Thickness = 2
    modalStroke.Parent = modalFrame
    
    local modalTitle = Instance.new("TextLabel")
    modalTitle.Name = "ModalTitle"
    modalTitle.Size = UDim2.new(0.9, 0, 0.4, 0)
    modalTitle.Position = UDim2.new(0.05, 0, 0.1, 0)
    modalTitle.BackgroundTransparency = 1
    modalTitle.Font = Enum.Font.GothamBold
    modalTitle.Text = "Close UILenS?"
    modalTitle.TextColor3 = TEXT_COLOR
    modalTitle.TextSize = 18
    modalTitle.TextWrapped = true
    modalTitle.ZIndex = 11
    modalTitle.Parent = modalFrame
    
    local modalMessage = Instance.new("TextLabel")
    modalMessage.Name = "ModalMessage"
    modalMessage.Size = UDim2.new(0.9, 0, 0.3, 0)
    modalMessage.Position = UDim2.new(0.05, 0, 0.4, 0)
    modalMessage.BackgroundTransparency = 1
    modalMessage.Font = Enum.Font.GothamMedium
    modalMessage.Text = "This will completely remove the UI monitor from your game."
    modalMessage.TextColor3 = TEXT_COLOR
    modalMessage.TextSize = 14
    modalMessage.TextWrapped = true
    modalMessage.ZIndex = 11
    modalMessage.Parent = modalFrame
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(0.9, 0, 0.3, 0)
    buttonContainer.Position = UDim2.new(0.05, 0, 0.65, 0)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.ZIndex = 11
    buttonContainer.Parent = modalFrame
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0.45, 0, 0.9, 0)
    cancelButton.Position = UDim2.new(0, 0, 0, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    cancelButton.BorderSizePixel = 0
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Text = "CANCEL"
    cancelButton.TextColor3 = TEXT_COLOR
    cancelButton.TextSize = 14
    cancelButton.ZIndex = 12
    cancelButton.Parent = buttonContainer
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0.1, 0)
    cancelCorner.Parent = cancelButton
    
    local confirmButton = Instance.new("TextButton")
    confirmButton.Name = "ConfirmButton"
    confirmButton.Size = UDim2.new(0.45, 0, 0.9, 0)
    confirmButton.Position = UDim2.new(0.55, 0, 0, 0)
    confirmButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    confirmButton.BorderSizePixel = 0
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.Text = "CONFIRM"
    confirmButton.TextColor3 = TEXT_COLOR
    confirmButton.TextSize = 14
    confirmButton.ZIndex = 12
    confirmButton.Parent = buttonContainer
    
    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0.1, 0)
    confirmCorner.Parent = confirmButton
    
    -- Button hover effects for modal
    setupButtonHover(cancelButton, Color3.fromRGB(90, 90, 100))
    setupButtonHover(confirmButton, Color3.fromRGB(210, 77, 63))
    
    -- Modal animation
    local function showModal()
        modalBackground.Visible = true
        modalFrame.Size = UDim2.new(0.1, 0, 0.1, 0)
        modalFrame.Position = UDim2.new(0.45, 0, 0.45, 0)
        modalFrame.BackgroundTransparency = 1
        
        local sizeTween = TweenService:Create(
            modalFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.25, 0, 0.18, 0)}
        )
        
        local transparencyTween = TweenService:Create(
            modalFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0}
        )
        
        sizeTween:Play()
        transparencyTween:Play()
    end
    
    local function hideModal()
        local sizeTween = TweenService:Create(
            modalFrame,
            TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Size = UDim2.new(0.1, 0, 0.1, 0)}
        )
        
        local transparencyTween = TweenService:Create(
            modalFrame,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        )
        
        sizeTween:Play()
        transparencyTween:Play()
        
        sizeTween.Completed:Wait()
        modalBackground.Visible = false
    end
    
    -- Button Logic with animations
    closeButton.MouseButton1Click:Connect(showModal)
    
    cancelButton.MouseButton1Click:Connect(hideModal)
    
    confirmButton.MouseButton1Click:Connect(function()
        hideModal()
        
        -- Fade out animation before destruction
        local fadeTween = TweenService:Create(
            mainContainer,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        )
        
        fadeTween:Play()
        fadeTween.Completed:Wait()
        
        -- Completely remove the GUI
        screenGui:Destroy()
    end)
    
    -- Minimize functionality with animation
    minimizeButton.MouseButton1Click:Connect(function()
        if mainFrame.Size.Y.Scale > 0.1 then
            -- Store original size
            mainFrame:SetAttribute("OriginalSizeY", mainFrame.Size.Y.Scale)
            mainFrame:SetAttribute("OriginalSizeX", mainFrame.Size.X.Scale)
            
            -- Animate minimize
            local minimizeTween = TweenService:Create(
                mainFrame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(0.6, 0, 0.08, 0)}
            )
            minimizeTween:Play()
            
            -- Hide all children except top bar
            for _, child in pairs(mainFrame:GetChildren()) do
                if child.Name ~= "TopBar" then
                    child.Visible = false
                end
            end
            
            -- Change icon to maximize
            minimizeButton.ImageRectOffset = Vector2.new(84, 204)
        else
            -- Animate restore
            local maximizeTween = TweenService:Create(
                mainFrame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(
                    mainFrame:GetAttribute("OriginalSizeX") or 0.6,
                    0,
                    mainFrame:GetAttribute("OriginalSizeY") or 0.7,
                    0
                )}
            )
            maximizeTween:Play()
            
            -- Show all children
            for _, child in pairs(mainFrame:GetChildren()) do
                child.Visible = true
            end
            
            -- Change icon back to minimize
            minimizeButton.ImageRectOffset = Vector2.new(124, 204)
        end
    end)
    
    -- Monitor button functionality with animation
    monitorButton.MouseButton1Click:Connect(function()
        MONITOR_ENABLED = not MONITOR_ENABLED
        
        if MONITOR_ENABLED then
            -- Animate button change
            local colorTween = TweenService:Create(
                monitorButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}
            )
            colorTween:Play()
            
            -- Update status
            monitorButton.Text = "STOP MONITORING"
            statusLabel.Text = "Monitoring: ON"
            
            -- Animate status indicator
            local indicatorTween = TweenService:Create(
                statusIndicator,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}
            )
            indicatorTween:Play()
        else
            -- Animate button change
            local colorTween = TweenService:Create(
                monitorButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = ACCENT_COLOR}
            )
            colorTween:Play()
            
            -- Update status
            monitorButton.Text = "START MONITORING"
            statusLabel.Text = "Monitoring: OFF"
            
            -- Animate status indicator
            local indicatorTween = TweenService:Create(
                statusIndicator,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}
            )
            indicatorTween:Play()
        end
    end)
    
    -- Clear button functionality with animation
    clearButton.MouseButton1Click:Connect(function()
        -- Pulse animation
        local pulseOut = TweenService:Create(
            clearButton,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.95, 0, 0.95, 0)}
        )
        
        local pulseIn = TweenService:Create(
            clearButton,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 1, 0)}
        )
        
        pulseOut:Play()
        pulseOut.Completed:Connect(function()
            pulseIn:Play()
            
            -- Clear console messages
            for _, child in pairs(consoleScrollFrame:GetChildren()) do
                if child:IsA("TextLabel") then
                    child:Destroy()
                end
            end
        end)
    end)
    
    -- Premium toggle switch functionality
    local function updateToggleAppearance()
        if CORE_GUI_MONITORING then
            -- Animate toggle on
            local slideTween = TweenService:Create(
                toggleButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.5, 0, 0.1, 0)}
            )
            
            local colorTween = TweenService:Create(
                toggleFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}
            )
            
            slideTween:Play()
            colorTween:Play()
        else
            -- Animate toggle off
            local slideTween = TweenService:Create(
                toggleButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.05, 0, 0.1, 0)}
            )
            
            local colorTween = TweenService:Create(
                toggleFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(70, 70, 80)}
            )
            
            slideTween:Play()
            colorTween:Play()
        end
    end
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            
            CORE_GUI_MONITORING = not CORE_GUI_MONITORING
            updateToggleAppearance()
        end
    end)
    
    -- Initialize toggle appearance
    updateToggleAppearance()
    
    return {
        gui = screenGui,
        consoleFrame = consoleScrollFrame,
        statusLabel = statusLabel
    }
end

-- Function to get element path
local function getElementPath(element)
    local path = {}
    local current = element
    
    while current and current ~= game do
        local elementType = current.ClassName
        local elementName = current.Name
        
        table.insert(path, 1, elementName .. "(" .. elementType .. ")")
        current = current.Parent
    end
    
    return table.concat(path, ".")
end

-- Add message to console with animation
local function addConsoleMessage(player, message, messageType)
    if not player or not player.PlayerGui then return end
    
    local consoleScrollFrame = player.PlayerGui:FindFirstChild(MAIN_GUI_NAME)
    if not consoleScrollFrame then return end
    consoleScrollFrame = consoleScrollFrame.MainContainer.MainFrame.ConsoleFrame.ConsoleScrollFrame
    
    local messageContainer = Instance.new("Frame")
    messageContainer.Name = "Message_" .. HttpService:GenerateGUID(false)
    messageContainer.Size = UDim2.new(0.98, 0, 0, 0)
    messageContainer.AutomaticSize = Enum.AutomaticSize.Y
    messageContainer.BackgroundTransparency = 1
    messageContainer.LayoutOrder = os.time()
    messageContainer.Parent = consoleScrollFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.Parent = messageContainer
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.BackgroundColor3 = 
        messageType == "click" and Color3.fromRGB(20, 40, 60) or
        messageType == "error" and Color3.fromRGB(60, 20, 20) or
        messageType == "info" and Color3.fromRGB(30, 30, 30)
    messageLabel.BorderSizePixel = 0
    messageLabel.Font = Enum.Font.Code
    messageLabel.Text = message
    messageLabel.TextColor3 = 
        messageType == "click" and Color3.fromRGB(150, 220, 255) or
        messageType == "error" and Color3.fromRGB(255, 150, 150) or
        messageType == "info" and Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = messageContainer
    
    local messageCorner = Instance.new("UICorner")
    messageCorner.CornerRadius = UDim.new(0, 4)
    messageCorner.Parent = messageLabel
    
    local messagePadding = Instance.new("UIPadding")
    messagePadding.PaddingLeft = UDim.new(0, 10)
    messagePadding.PaddingRight = UDim.new(0, 10)
    messagePadding.PaddingTop = UDim.new(0, 5)
    messagePadding.PaddingBottom = UDim.new(0, 5)
    messagePadding.Parent = messageLabel
    
    -- Fade in animation
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextTransparency = 1
    
    local fadeIn = TweenService:Create(
        messageLabel,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            BackgroundTransparency = 0,
            TextTransparency = 0
        }
    )
    
    fadeIn:Play()
    
    -- Limit number of messages
    local messages = {}
    for _, child in pairs(consoleScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            table.insert(messages, child)
        end
    end
    
    table.sort(messages, function(a, b)
        return a.LayoutOrder > b.LayoutOrder
    end)
    
    if #messages > MAX_CONSOLE_MESSAGES then
        for i = MAX_CONSOLE_MESSAGES + 1, #messages do
            -- Fade out before destroying
            local fadeOut = TweenService:Create(
                messages[i],
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    BackgroundTransparency = 1,
                    TextTransparency = 1
                }
            )
            
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                messages[i]:Destroy()
            end)
        end
    end
    
    -- Auto-scroll to bottom
    consoleScrollFrame.CanvasPosition = Vector2.new(0, consoleScrollFrame.AbsoluteCanvasSize.Y)
end

-- Check if an element should be ignored
local function shouldIgnoreElement(element)
    local ignoredNames = {
        "promptOverlay", "RobloxPromptGui", "OldMenuFrame", "MenuFrame",
        "LoadingScreen", "PerformanceStats", "TopBar", "ChatBar",
        "ToolTip", "PlayerListContainer", "ErrorPrompt"
    }
    
    local current = element
    while current and current ~= game do
        for _, name in pairs(ignoredNames) do
            if current.Name == name then
                return true
            end
        end
        
        if not CORE_GUI_MONITORING and current.Parent and current.Parent:IsA("CoreGui") then
            return true
        end
        
        current = current.Parent
    end
    
    return false
end

-- Function to set up click monitoring for a player
local function setupClickMonitoring(player)
    if not player or not player.PlayerGui then return end
    
    local guiObjects = {}
    local playerGui = player:WaitForChild("PlayerGui", 5)
    
    local guiData = createMonitorGui(player)
    if not guiData then return end
    
    addConsoleMessage(player, "Welcome to UILenS - Premium GUI Path Monitor", "info")
    addConsoleMessage(player, "Click the 'START MONITORING' button to begin tracking GUI interactions", "info")
    
    local function handleGuiObject(guiObject)
        if not guiObject:IsA("GuiObject") or shouldIgnoreElement(guiObject) then
            return
        end
        
        if not guiObjects[guiObject] then
            guiObjects[guiObject] = true
            
            guiObject.InputBegan:Connect(function(input)
                if not MONITOR_ENABLED then return end
                
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    
                    local pathStr = getElementPath(guiObject)
                    local clickMessage = string.format(
                        "[%s] Click detected on %s\nPath: %s", 
                        os.date("%H:%M:%S"),
                        guiObject.ClassName,
                        pathStr
                    )
                    
                    addConsoleMessage(player, clickMessage, "click")
                end
            end)
        end
    end
    
    local function processDescendantAdded(descendant)
        task.spawn(function()
            if descendant:IsA("GuiObject") then
                handleGuiObject(descendant)
            end
        end)
    end
    
    for _, descendant in pairs(playerGui:GetDescendants()) do
        task.spawn(function()
            processDescendantAdded(descendant)
        end)
    end
    
    playerGui.DescendantAdded:Connect(processDescendantAdded)
    
    game:GetService("CoreGui").DescendantAdded:Connect(function(descendant)
        if CORE_GUI_MONITORING and MONITOR_ENABLED then
            processDescendantAdded(descendant)
        end
    end)
    
    if CORE_GUI_MONITORING then
        for _, descendant in pairs(game:GetService("CoreGui"):GetDescendants()) do
            task.spawn(function()
                processDescendantAdded(descendant)
            end)
        end
    end
end

-- Main initialization
local function initialize()
    for _, player in pairs(Players:GetPlayers()) do
        task.spawn(function()
            setupClickMonitoring(player)
        end)
    end
    
    Players.PlayerAdded:Connect(function(player)
        task.spawn(function()
            setupClickMonitoring(player)
        end)
    end)
end

-- Start the script
initialize()
