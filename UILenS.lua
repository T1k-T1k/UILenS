-- UILenS - GUI Path Monitor for Roblox

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Configuration
local MAIN_GUI_NAME = "UILenS"
local LOGO_IMAGE_ID = "rbxassetid://120107164785260" -- Fixed image id format
local MONITOR_ENABLED = false
local CORE_GUI_MONITORING = false
local MAX_CONSOLE_MESSAGES = 100
local MESSAGE_COUNTER = 0 -- For unique message IDs

-- Create GUI for all players
local function createMonitorGui(player)
    -- Create main ScreenGui with ForceGuiOnTopOfCore enabled for better persistence
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = MAIN_GUI_NAME
    screenGui.ResetOnSpawn = false -- Ensure GUI persists after character respawn
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999 -- Make it appear above most GUIs
    screenGui.IgnoreGuiInset = true -- Make it go edge to edge
    
    -- Set parent based on if we're in-game or in Studio
    if RunService:IsRunning() then
        -- In-game: Assign to PlayerGui
        screenGui.Parent = player.PlayerGui
    else
        -- In Studio: Try to use StarterGui
        pcall(function()
            screenGui.Parent = game:GetService("StarterGui")
        end)
    end
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
    mainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Top bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0.07, 0)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    -- Logo image
    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "Logo"
    logoImage.Size = UDim2.new(0, 150, 0, 30)
    logoImage.Position = UDim2.new(0.01, 0, 0.1, 0)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = LOGO_IMAGE_ID
    logoImage.ScaleType = Enum.ScaleType.Fit
    logoImage.Parent = topBar
    
    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.25, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "UILenS"
    titleLabel.TextColor3 = Color3.fromRGB(41, 128, 255)
    titleLabel.TextSize = 22
    titleLabel.Parent = topBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.05, 0, 0.8, 0)
    closeButton.Position = UDim2.new(0.94, 0, 0.1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Parent = topBar
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0.05, 0, 0.8, 0)
    minimizeButton.Position = UDim2.new(0.88, 0, 0.1, 0)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Text = "-"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextSize = 18
    minimizeButton.Parent = topBar
    
    -- Console area - reduced height a bit
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Name = "ConsoleFrame"
    consoleFrame.Size = UDim2.new(0.98, 0, 0.7, 0) -- Smaller console
    consoleFrame.Position = UDim2.new(0.01, 0, 0.08, 0)
    consoleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    consoleFrame.BorderSizePixel = 0
    consoleFrame.Parent = mainFrame
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0.98, 0, 0.07, 0)
    statusLabel.Position = UDim2.new(0.01, 0, 0, 0)
    statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    statusLabel.BorderSizePixel = 0
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.Text = "Monitoring: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 16
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextWrapped = true
    statusLabel.Parent = consoleFrame
    
    -- Console ScrollingFrame
    local consoleScrollFrame = Instance.new("ScrollingFrame")
    consoleScrollFrame.Name = "ConsoleScrollFrame"
    consoleScrollFrame.Size = UDim2.new(1, 0, 0.93, 0)
    consoleScrollFrame.Position = UDim2.new(0, 0, 0.07, 0)
    consoleScrollFrame.BackgroundTransparency = 1
    consoleScrollFrame.BorderSizePixel = 0
    consoleScrollFrame.ScrollBarThickness = 6
    consoleScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    consoleScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    consoleScrollFrame.Parent = consoleFrame
    
    -- UIListLayout for console messages
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = consoleScrollFrame
    
    -- Controls area - adjusted position for smaller console
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsFrame"
    controlsFrame.Size = UDim2.new(0.98, 0, 0.20, 0) -- Increased size for better controls layout
    controlsFrame.Position = UDim2.new(0.01, 0, 0.78, 0) -- Adjusted position
    controlsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    controlsFrame.BorderSizePixel = 0
    controlsFrame.Parent = mainFrame
    
    -- Start/Stop Monitoring Button
    local monitorButton = Instance.new("TextButton")
    monitorButton.Name = "MonitorButton"
    monitorButton.Size = UDim2.new(0.3, 0, 0.35, 0)
    monitorButton.Position = UDim2.new(0.02, 0, 0.1, 0)
    monitorButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    monitorButton.BorderSizePixel = 0
    monitorButton.Font = Enum.Font.GothamBold
    monitorButton.Text = "Start Monitoring GUI Path"
    monitorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    monitorButton.TextSize = 14
    monitorButton.Parent = controlsFrame
    
    -- Clear Console Button
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(0.15, 0, 0.35, 0)
    clearButton.Position = UDim2.new(0.33, 0, 0.1, 0)
    clearButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    clearButton.BorderSizePixel = 0
    clearButton.Font = Enum.Font.GothamBold
    clearButton.Text = "Clear"
    clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearButton.TextSize = 14
    clearButton.Parent = controlsFrame
    
    -- CoreGUI Toggle Label
    local coreGuiLabel = Instance.new("TextLabel")
    coreGuiLabel.Name = "CoreGuiLabel"
    coreGuiLabel.Size = UDim2.new(0.4, 0, 0.35, 0)
    coreGuiLabel.Position = UDim2.new(0.02, 0, 0.55, 0)
    coreGuiLabel.BackgroundTransparency = 1
    coreGuiLabel.Font = Enum.Font.GothamMedium
    coreGuiLabel.Text = "Enable CoreGui Path Monitoring:"
    coreGuiLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    coreGuiLabel.TextSize = 14
    coreGuiLabel.TextXAlignment = Enum.TextXAlignment.Left
    coreGuiLabel.Parent = controlsFrame
    
    -- Improved Toggle Slider Background
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Name = "SliderBackground"
    sliderBackground.Size = UDim2.new(0.12, 0, 0.25, 0) -- Wider slider
    sliderBackground.Position = UDim2.new(0.43, 0, 0.6, 0)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = controlsFrame
    
    -- Make corners rounded
    local sliderCorners = Instance.new("UICorner")
    sliderCorners.CornerRadius = UDim.new(0.5, 0)
    sliderCorners.Parent = sliderBackground
    
    -- Improved Toggle Slider Button
    local sliderButton = Instance.new("Frame")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(0.4, 0, 0.8, 0) -- Slightly smaller for better appearance
    sliderButton.Position = UDim2.new(0.05, 0, 0.1, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderBackground
    
    -- Make slider button rounded
    local buttonCorners = Instance.new("UICorner")
    buttonCorners.CornerRadius = UDim.new(0.5, 0)
    buttonCorners.Parent = sliderButton
    
    -- Make the main frame draggable
    local isDragging = false
    local dragOffset = Vector2.new(0, 0)
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragOffset = mainFrame.Position - UDim2.new(0, input.Position.X, 0, input.Position.Y)
        end
    end)
    
    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            mainFrame.Position = UDim2.new(0, input.Position.X, 0, input.Position.Y) + dragOffset
        end
    end)
    
    -- Create confirmation modal (fullscreen)
    local modalBackground = Instance.new("Frame")
    modalBackground.Name = "ConfirmationModal"
    modalBackground.Size = UDim2.new(10, 0, 10, 0) -- Extra large to ensure full coverage
    modalBackground.Position = UDim2.new(-5, 0, -5, 0) -- Position to cover everything
    modalBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    modalBackground.BackgroundTransparency = 0.5
    modalBackground.BorderSizePixel = 0
    modalBackground.Visible = false
    modalBackground.ZIndex = 10
    modalBackground.Parent = screenGui
    
    local modalFrame = Instance.new("Frame")
    modalFrame.Name = "ModalFrame"
    modalFrame.Size = UDim2.new(0.3, 0, 0.2, 0)
    modalFrame.Position = UDim2.new(0.35, 0, 0.4, 0)
    modalFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    modalFrame.BorderSizePixel = 0
    modalFrame.ZIndex = 11
    modalFrame.Parent = modalBackground
    
    local modalCorners = Instance.new("UICorner")
    modalCorners.CornerRadius = UDim.new(0.05, 0)
    modalCorners.Parent = modalFrame
    
    local modalTitle = Instance.new("TextLabel")
    modalTitle.Name = "ModalTitle"
    modalTitle.Size = UDim2.new(1, 0, 0.3, 0)
    modalTitle.Position = UDim2.new(0, 0, 0.1, 0)
    modalTitle.BackgroundTransparency = 1
    modalTitle.Font = Enum.Font.GothamBold
    modalTitle.Text = "Are you sure you want to close?"
    modalTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    modalTitle.TextSize = 18
    modalTitle.ZIndex = 11
    modalTitle.Parent = modalFrame you want to close?"
    modalTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    modalTitle.TextSize = 18
    modalTitle.ZIndex = 11
    modalTitle.Parent = modalFrame
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0.4, 0, 0.25, 0)
    cancelButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    cancelButton.BorderSizePixel = 0
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 16
    cancelButton.ZIndex = 11
    cancelButton.Parent = modalFrame
    
    local confirmButton = Instance.new("TextButton")
    confirmButton.Name = "ConfirmButton"
    confirmButton.Size = UDim2.new(0.4, 0, 0.25, 0)
    confirmButton.Position = UDim2.new(0.5, 0, 0.6, 0)
    confirmButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    confirmButton.BorderSizePixel = 0
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.Text = "Yes"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.TextSize = 16
    confirmButton.ZIndex = 11
    confirmButton.Parent = modalFrame
    
    -- Add rounded corners to buttons
    local cancelCorners = Instance.new("UICorner")
    cancelCorners.CornerRadius = UDim.new(0.1, 0)
    cancelCorners.Parent = cancelButton
    
    local confirmCorners = Instance.new("UICorner")
    confirmCorners.CornerRadius = UDim.new(0.1, 0)
    confirmCorners.Parent = confirmButton
    
    -- Button Logic
    closeButton.MouseButton1Click:Connect(function()
        modalBackground.Visible = true
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        modalBackground.Visible = false
    end)
    
    confirmButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        modalBackground.Visible = false
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        if mainFrame.Size.Y.Scale > 0.1 then
            -- Store the original size for when we maximize
            mainFrame:SetAttribute("OriginalSizeY", mainFrame.Size.Y.Scale)
            mainFrame:SetAttribute("OriginalSizeX", mainFrame.Size.X.Scale)
            
            -- Minimize
            local minimizeTween = TweenService:Create(
                mainFrame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(0.6, 0, 0.07, 0)}
            )
            minimizeTween:Play()
            
            -- Hide all frames except TopBar
            for _, child in pairs(mainFrame:GetChildren()) do
                if child.Name ~= "TopBar" then
                    child.Visible = false
                end
            end
            
            minimizeButton.Text = "+"
        else
            -- Maximize
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
            
            -- Show all frames
            for _, child in pairs(mainFrame:GetChildren()) do
                child.Visible = true
            end
            
            minimizeButton.Text = "-"
        end
    end)
    
    monitorButton.MouseButton1Click:Connect(function()
        MONITOR_ENABLED = not MONITOR_ENABLED
        
        if MONITOR_ENABLED then
            monitorButton.Text = "Stop Monitoring GUI Path"
            monitorButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
            statusLabel.Text = "Monitoring: ON"
            statusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
        else
            monitorButton.Text = "Start Monitoring GUI Path"
            monitorButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
            statusLabel.Text = "Monitoring: OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        for _, child in pairs(consoleScrollFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end)
    
    -- Make the slider clickable
    local function updateSliderAppearance()
        if CORE_GUI_MONITORING then
            sliderBackground.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            local slideTween = TweenService:Create(
                sliderButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.525, 0, 0.05, 0)}
            )
            slideTween:Play()
        else
            sliderBackground.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            local slideTween = TweenService:Create(
                sliderButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.025, 0, 0.05, 0)}
            )
            slideTween:Play()
        end
    end
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            CORE_GUI_MONITORING = not CORE_GUI_MONITORING
            updateSliderAppearance()
        end
    end)
    
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

-- Add message to console
local function addConsoleMessage(player, message, messageType)
    local guiData = player:GetAttribute("UILenS_GuiData")
    if not guiData then return end
    
    local consoleScrollFrame = player.PlayerGui:FindFirstChild(MAIN_GUI_NAME).MainFrame.ConsoleFrame.ConsoleScrollFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message_" .. os.time() .. "_" .. math.random(1000, 9999)
    messageLabel.Size = UDim2.new(0.98, 0, 0, 40) -- Auto height
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
    messageLabel.LayoutOrder = os.time()
    
    -- Padding within the message
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.Parent = messageLabel
    
    messageLabel.Parent = consoleScrollFrame
    
    -- Limit the number of messages
    local messages = {}
    for _, child in pairs(consoleScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            table.insert(messages, child)
        end
    end
    
    -- Sort by LayoutOrder (timestamp)
    table.sort(messages, function(a, b)
        return a.LayoutOrder > b.LayoutOrder
    end)
    
    -- Remove excess messages
    if #messages > MAX_CONSOLE_MESSAGES then
        for i = MAX_CONSOLE_MESSAGES + 1, #messages do
            messages[i]:Destroy()
        end
    end
    
    -- Scroll to bottom
    consoleScrollFrame.CanvasPosition = Vector2.new(0, 999999)
end

-- Check if an element should be ignored
local function shouldIgnoreElement(element)
    -- List of system GUI elements to ignore
    local ignoredNames = {
        "promptOverlay", "RobloxPromptGui", "OldMenuFrame", "MenuFrame",
        "LoadingScreen", "PerformanceStats", "TopBar", "ChatBar",
        "ToolTip", "PlayerListContainer", "ErrorPrompt"
    }
    
    -- Check if element or any parent is in the ignore list
    local current = element
    while current and current ~= game do
        for _, name in pairs(ignoredNames) do
            if current.Name == name then
                return true
            end
        end
        
        -- Skip CoreGui elements unless explicitly enabled
        if not CORE_GUI_MONITORING and current.Parent and current.Parent:IsA("CoreGui") then
            return true
        end
        
        current = current.Parent
    end
    
    return false
end

-- Function to set up click monitoring for a player
local function setupClickMonitoring(player)
    local guiObjects = {}
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create custom GUI
    local guiData = createMonitorGui(player)
    player:SetAttribute("UILenS_GuiData", true)
    
    -- Add welcome message
    addConsoleMessage(player, "Welcome to UILenS - GUI Path Monitor", "info")
    addConsoleMessage(player, "Click the 'Start Monitoring GUI Path' button to begin tracking GUI interactions", "info")
    
    -- Function to handle gui elements
    local function handleGuiObject(guiObject)
        if not guiObject:IsA("GuiObject") or shouldIgnoreElement(guiObject) then
            return
        end
        
        -- Only track if not already tracked
        if not guiObjects[guiObject] then
            guiObjects[guiObject] = true
            
            -- Connect click event
            guiObject.InputBegan:Connect(function(input)
                if not MONITOR_ENABLED then return end
                
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    
                    local pathStr = getElementPath(guiObject)
                    local clickMessage = string.format(
                        "Clicked [ :// %s :\\ }\nPath: %s", 
                        guiObject.ClassName,
                        pathStr
                    )
                    
                    addConsoleMessage(player, clickMessage, "click")
                end
            end)
        end
    end
    
    -- Function to process descendant addition
    local function processDescendantAdded(descendant)
        task.spawn(function()
            if descendant:IsA("GuiObject") then
                handleGuiObject(descendant)
            end
        end)
    end
    
    -- Process existing PlayerGui
    for _, descendant in pairs(playerGui:GetDescendants()) do
        task.spawn(function()
            processDescendantAdded(descendant)
        end)
    end
    
    -- Setup to track future GUI elements
    playerGui.DescendantAdded:Connect(processDescendantAdded)
    
    -- Also monitor CoreGui if enabled
    game:GetService("CoreGui").DescendantAdded:Connect(function(descendant)
        if CORE_GUI_MONITORING and MONITOR_ENABLED then
            processDescendantAdded(descendant)
        end
    end)
    
    -- Process existing CoreGui elements
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
    -- Set up for existing players
    for _, player in pairs(Players:GetPlayers()) do
        task.spawn(function()
            setupClickMonitoring(player)
        end)
    end
    
    -- Set up for future players
    Players.PlayerAdded:Connect(function(player)
        task.spawn(function()
            setupClickMonitoring(player)
        end)
    end)
end

-- Start the script
initialize()
