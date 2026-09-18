--[[

    ██████╗ ███████╗███████╗    ██╗  ██╗██╗   ██╗██████╗ 
    ██╔══██╗██╔════╝██╔════╝    ██║  ██║██║   ██║██╔══██╗
    ██████╔╝█████╗  █████╗      ███████║██║   ██║██████╔╝
    ██╔══██╗██╔══╝  ██╔══╝      ██╔══██║██║   ██║██╔══██╗
    ██████╔╝███████╗███████╗    ██║  ██║╚██████╔╝██████╔╝
    ╚═════╝ ╚══════╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 

    BEE HUB 🐝🍯 | PREMIUM 👑
    Original: Eggs ESP Menu by ThiAez
    Redesigned & English Translation

]] 

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

--==================================================
-- STARTUP SOUND 🔊
--==================================================

local startupSound = nil
local soundEnabled = true

local function playStartupSound()
    if not soundEnabled then return end

    -- 🔧 Change this SoundId to whatever you want
    local sound = Instance.new("Sound")
    sound.Name = "BEE_HUB_Startup"
    sound.SoundId = "rbxassetid://90464858133755"  -- 👈 bee/premium chime
    sound.Volume = 0.7
    sound.PlaybackSpeed = 1
    sound.Parent = SoundService
    sound:Play()

    startupSound = sound

    -- Auto-cleanup after 10s
    task.delay(10, function()
        if sound and sound.Parent then
            sound:Destroy()
        end
    end)
end

-- 🎉 Play immediately on execution
playStartupSound()

--==================================================
-- CONFIGURATION
--==================================================

local Config = {
    -- ESP
    ESPFillTransparency = 0.50,
    ESPOutlineTransparency = 0,
    ESPNameSize = 13,
    ESPDistanceSize = 11,

    -- Colors (Honey / Gold Theme)
    GlobalESPColor = Color3.fromRGB(255, 200, 0),
    CustomESPColor = Color3.fromRGB(255, 175, 0),

    PrimaryColor = Color3.fromRGB(255, 185, 0),
    SecondaryColor = Color3.fromRGB(255, 215, 80),
    DarkBg = Color3.fromRGB(18, 14, 8),
    PanelBg = Color3.fromRGB(28, 22, 12),
    ButtonBg = Color3.fromRGB(45, 35, 18),
    ButtonHover = Color3.fromRGB(65, 50, 25),
    TextPrimary = Color3.fromRGB(255, 245, 220),
    TextSecondary = Color3.fromRGB(200, 180, 140),
    AccentRed = Color3.fromRGB(200, 55, 45),

    -- TP
    TPHeight = 3,
    MovementSpeed = 500,

    -- Auto Egg
    BestEggName = "cherub",
    AutoEggHoldTime = 3,
    AutoFarmHoldTime = 2,
    AutoEggDelay = 0.8,

    -- UI Size
    PCWidth = 500,
    PCHeight = 730,
    MobileWidth = 370,
    MobileHeight = 540,
    AnimationTime = 0.18,
}

--==================================================
-- MAIN OBJECTS
--==================================================

local TargetParent = LocalPlayer:WaitForChild("PlayerGui")
local RenderedEggsFolder = Workspace:WaitForChild("RenderedEggs", 10)

if not RenderedEggsFolder then
    warn("[BEE HUB] Workspace.RenderedEggs not found. GUI will still load.")
end

--==================================================
-- STATE
--==================================================

local mainESPActive = false
local autoBestEggActive = false
local autoBestEggThread = nil
local autoFarmActive = false
local autoFarmThread = nil
local autoFarmEggs = {}
local autoFarmProcessed = {}
local autoFarmCurrentName = nil
local StopAutoFarmBtn
local StatusLabel
local currentSearchQuery = ""
local sortMode = "Name"
local tpKeybind = Enum.KeyCode.T
local listeningForKey = false
local isMobileMode = false
local isMinimized = false
local movementMode = "AutoFarm"
local movementActive = false
local movementHumanoid = nil
local movementPartsState = nil
local ModeAutoFarmBtn
local ModeTeleportBtn

local eggData = {}

--==================================================
-- HELPER FUNCTIONS
--==================================================

local function getCharacter()
    return LocalPlayer.Character
end

local function getRootPart()
    local character = getCharacter()
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

local function getEggImage(eggName)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return "" end
    local main = playerGui:FindFirstChild("Main")
    local index = main and main:FindFirstChild("Index")
    local holders = index and index:FindFirstChild("Holders")
    local eggsHolder = holders and holders:FindFirstChild("EggsHolder")
    if not eggsHolder then return "" end
    local eggFrame = eggsHolder:FindFirstChild(eggName)
    if not eggFrame then return "" end
    local imageLabel = eggFrame:FindFirstChild("ImageLabel")
    if imageLabel and imageLabel:IsA("ImageLabel") then
        return imageLabel.Image or ""
    end
    return ""
end

local function getTargetCFrame(target)
    if not target or not target.Parent then return nil end
    if target:IsA("Model") then return target:GetPivot() end
    if target:IsA("BasePart") then return target.CFrame end
    return nil
end

local function getTargetPosition(target)
    local targetCFrame = getTargetCFrame(target)
    if not targetCFrame then return nil end
    return targetCFrame.Position
end

local function getDistanceToTarget(target)
    local root = getRootPart()
    local targetPosition = getTargetPosition(target)
    if not root or not targetPosition then return math.huge end
    return (root.Position - targetPosition).Magnitude
end

local function tween(object, properties, duration)
    if not object or not object.Parent then return end
    local info = TweenInfo.new(
        duration or Config.AnimationTime,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )
    TweenService:Create(object, info, properties):Play()
end

local function createSectionLabel(parent, text, yPos)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = "◆ " .. text .. " ◆"
    label.TextColor3 = Config.PrimaryColor
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

--==================================================
-- ESP: CREATE NAME + DISTANCE LABEL
--==================================================

local function createEggLabel(egg)
    local data = eggData[egg]
    if not data then return end
    if data.NameBillboard and data.NameBillboard.Parent then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESP_Info"
    billboard.Size = UDim2.new(0, 180, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 2000
    billboard.Enabled = false
    billboard.Parent = egg

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "EggName"
    nameLabel.Size = UDim2.new(1, 0, 0, 23)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = egg.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 245, 220)
    nameLabel.TextStrokeTransparency = 0.35
    nameLabel.TextSize = Config.ESPNameSize
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1, 0, 0, 18)
    distanceLabel.Position = UDim2.new(0, 0, 0, 22)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0 studs"
    distanceLabel.TextColor3 = Config.PrimaryColor
    distanceLabel.TextStrokeTransparency = 0.4
    distanceLabel.TextSize = Config.ESPDistanceSize
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = billboard

    data.NameBillboard = billboard
end

local function updateEggLabel(egg)
    local data = eggData[egg]
    if not data or not data.NameBillboard then return end
    local billboard = data.NameBillboard
    if not billboard.Parent then return end
    local nameLabel = billboard:FindFirstChild("EggName")
    local distanceLabel = billboard:FindFirstChild("Distance")
    if nameLabel then nameLabel.Text = egg.Name end
    if distanceLabel then
        local distance = getDistanceToTarget(egg)
        if distance == math.huge then
            distanceLabel.Text = "?"
        else
            distanceLabel.Text = string.format("%d studs", math.floor(distance + 0.5))
        end
    end
end

local function updateEggESP(egg)
    if not egg then return end
    if not egg:IsA("Model") and not egg:IsA("BasePart") then return end

    if not eggData[egg] then
        eggData[egg] = {
            Highlight = nil,
            NameBillboard = nil,
            CustomColor = Config.CustomESPColor,
            CustomActive = false
        }
    end

    local data = eggData[egg]
    local shouldShow = false
    local color = Config.GlobalESPColor

    if data.CustomActive then
        shouldShow = true
        color = data.CustomColor or Config.CustomESPColor
    elseif mainESPActive then
        shouldShow = true
        color = Config.GlobalESPColor
    end

    if shouldShow then
        if not data.Highlight or not data.Highlight.Parent then
            local highlight = Instance.new("Highlight")
            highlight.Name = "EggESP_Highlight"
            highlight.Adornee = egg
            highlight.FillTransparency = Config.ESPFillTransparency
            highlight.OutlineTransparency = Config.ESPOutlineTransparency
            highlight.Parent = egg
            data.Highlight = highlight
        end
        data.Highlight.FillColor = color
        data.Highlight.OutlineColor = color
        data.Highlight.Enabled = true
        createEggLabel(egg)
        if data.NameBillboard then data.NameBillboard.Enabled = true end
        updateEggLabel(egg)
    else
        if data.Highlight then data.Highlight.Enabled = false end
        if data.NameBillboard then data.NameBillboard.Enabled = false end
    end
end

local function updateAllESP()
    if not RenderedEggsFolder then return end
    for _, egg in ipairs(RenderedEggsFolder:GetChildren()) do
        updateEggESP(egg)
    end
end

local function applyGlobalESP(state)
    mainESPActive = state
    updateAllESP()
end

local function removeEggData(egg)
    local data = eggData[egg]
    if not data then return end
    if data.Highlight then data.Highlight:Destroy() end
    if data.NameBillboard then data.NameBillboard:Destroy() end
    eggData[egg] = nil
end

--==================================================
-- TELEPORT
--==================================================

local function teleportToModel(target)
    local root = getRootPart()
    if not root then return false end
    local targetCFrame = getTargetCFrame(target)
    if not targetCFrame then return false end
    root.CFrame = targetCFrame * CFrame.new(0, Config.TPHeight, 0)
    return true
end

local function setNoclip(enabled)
    local character = getCharacter()
    if not character then return end
    if enabled then
        movementPartsState = {}
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                movementPartsState[part] = part.CanCollide
                part.CanCollide = false
            end
        end
    elseif movementPartsState then
        for part, oldCanCollide in pairs(movementPartsState) do
            if part and part.Parent then part.CanCollide = oldCanCollide end
        end
        movementPartsState = nil
    end
end

local function moveToModel(target)
    if movementMode == "Teleport" then return teleportToModel(target) end
    if movementActive then return false end

    local character = getCharacter()
    local root = getRootPart()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local targetCFrame = getTargetCFrame(target)
    if not root or not humanoid or not targetCFrame then return false end

    local destination = targetCFrame.Position + Vector3.new(0, Config.TPHeight, 0)
    local startDistance = (root.Position - destination).Magnitude
    if startDistance <= 2 then
        root.CFrame = targetCFrame * CFrame.new(0, Config.TPHeight, 0)
        return true
    end

    movementActive = true
    movementHumanoid = humanoid
    local oldAutoRotate = humanoid.AutoRotate
    local success = false
    local startTime = os.clock()
    local maxTime = math.max(3, (startDistance / Config.MovementSpeed) + 2)

    setNoclip(true)
    humanoid.AutoRotate = false

    while movementActive and os.clock() - startTime <= maxTime do
        if not target or not target.Parent then break end
        if getRootPart() ~= root then break end
        local offset = destination - root.Position
        local distance = offset.Magnitude
        if distance <= 2 then
            root.CFrame = targetCFrame * CFrame.new(0, Config.TPHeight, 0)
            success = true
            break
        end
        local dt = RunService.Heartbeat:Wait()
        local step = math.min(distance, Config.MovementSpeed * dt)
        root.CFrame = root.CFrame + offset.Unit * step
    end

    movementActive = false
    if humanoid.Parent then humanoid.AutoRotate = oldAutoRotate end
    movementHumanoid = nil
    setNoclip(false)
    return success
end

local function stopMovement()
    movementActive = false
    if movementHumanoid and movementHumanoid.Parent then movementHumanoid.AutoRotate = true end
    movementHumanoid = nil
    setNoclip(false)
end

local function updateMovementModeButtons()
    if not ModeAutoFarmBtn or not ModeTeleportBtn then return end
    if movementMode == "AutoFarm" then
        ModeAutoFarmBtn.BackgroundColor3 = Config.PrimaryColor
        ModeAutoFarmBtn.TextColor3 = Color3.fromRGB(30, 20, 5)
        ModeTeleportBtn.BackgroundColor3 = Config.ButtonBg
        ModeTeleportBtn.TextColor3 = Config.TextSecondary
    else
        ModeAutoFarmBtn.BackgroundColor3 = Config.ButtonBg
        ModeAutoFarmBtn.TextColor3 = Config.TextSecondary
        ModeTeleportBtn.BackgroundColor3 = Config.PrimaryColor
        ModeTeleportBtn.TextColor3 = Color3.fromRGB(30, 20, 5)
    end
end

local function setMovementMode(mode)
    if mode ~= "AutoFarm" and mode ~= "Teleport" then return end
    stopMovement()
    movementMode = mode
    updateMovementModeButtons()
    if StatusLabel then
        StatusLabel.Text = mode == "AutoFarm" and "● Mode: AutoFarm (move + noclip 500)" or "● Mode: Teleport (instant)"
        StatusLabel.TextColor3 = Config.PrimaryColor
    end
end

local function teleportToHomePlot()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return false end

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local dataFolder = plot:FindFirstChild("Data")
        if dataFolder then
            local ownerValue = dataFolder:FindFirstChild("Owner")
            if ownerValue then
                local isOwner = false
                if ownerValue:IsA("StringValue") then
                    isOwner = ownerValue.Value == LocalPlayer.Name
                elseif ownerValue:IsA("ObjectValue") then
                    isOwner = ownerValue.Value == LocalPlayer
                else
                    isOwner = tostring(ownerValue.Value) == LocalPlayer.Name
                end
                if isOwner then
                    return moveToModel(plot)
                end
            end
        end
    end
    return false
end

--==================================================
-- AUTO BEST EGG
--==================================================

local function holdEKey(duration)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(duration)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function findBestEgg()
    if not RenderedEggsFolder then return nil end
    for _, egg in ipairs(RenderedEggsFolder:GetChildren()) do
        if string.find(egg.Name:lower(), Config.BestEggName:lower(), 1, true) then
            return egg
        end
    end
    return nil
end

local function stopAutoBestEgg()
    autoBestEggActive = false
    stopMovement()
    if autoBestEggThread then
        task.cancel(autoBestEggThread)
        autoBestEggThread = nil
    end
end

local function startAutoBestEgg()
    stopAutoBestEgg()
    autoBestEggActive = true
    autoBestEggThread = task.spawn(function()
        while autoBestEggActive do
            local egg = findBestEgg()
            if egg and egg.Parent then
                local teleported = moveToModel(egg)
                if teleported then
                    task.wait(0.3)
                    if autoBestEggActive and egg.Parent then
                        holdEKey(Config.AutoEggHoldTime)
                    end
                    task.wait(0.2)
                    if autoBestEggActive then
                        teleportToHomePlot()
                    end
                    task.wait(Config.AutoEggDelay)
                end
            else
                task.wait(0.5)
            end
        end
    end)
end

--==================================================
-- AUTOFARM
--==================================================

local function setAutoFarmButtonState(button, active)
    if not button then return end
    if active then
        button.Text = "FARM ON"
        button.BackgroundColor3 = Config.PrimaryColor
        button.TextColor3 = Color3.fromRGB(30, 20, 5)
    else
        button.Text = "Farm"
        button.BackgroundColor3 = Config.ButtonBg
        button.TextColor3 = Config.TextPrimary
    end
end

local function isValidEgg(egg)
    return egg
        and egg.Parent == RenderedEggsFolder
        and (egg:IsA("Model") or egg:IsA("BasePart"))
end

local function getAutoFarmEggs()
    local found = {}
    if not RenderedEggsFolder then return found end
    for _, egg in ipairs(RenderedEggsFolder:GetChildren()) do
        if isValidEgg(egg) and autoFarmEggs[egg.Name] and not autoFarmProcessed[egg] then
            table.insert(found, egg)
        end
    end
    table.sort(found, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    return found
end

local function stopAutoFarm()
    autoFarmActive = false
    stopMovement()
    autoFarmCurrentName = nil
    if autoFarmThread then
        task.cancel(autoFarmThread)
        autoFarmThread = nil
    end
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function startAutoFarm()
    stopAutoFarm()
    autoFarmActive = true
    if StopAutoFarmBtn then StopAutoFarmBtn.Visible = true end

    autoFarmThread = task.spawn(function()
        while autoFarmActive do
            local eggs = getAutoFarmEggs()
            if #eggs == 0 then
                autoFarmActive = false
                autoFarmCurrentName = nil
                autoFarmThread = nil
                if StopAutoFarmBtn then StopAutoFarmBtn.Visible = false end
                break
            end

            local didWork = false
            for _, egg in ipairs(eggs) do
                if not autoFarmActive then break end
                if isValidEgg(egg) and not autoFarmProcessed[egg] then
                    didWork = true
                    autoFarmCurrentName = egg.Name
                    StatusLabel.Text = "● Farming: " .. egg.Name
                    StatusLabel.TextColor3 = Config.PrimaryColor

                    local success = moveToModel(egg)
                    if success and autoFarmActive then
                        task.wait(0.3)
                        if autoFarmActive and isValidEgg(egg) then
                            holdEKey(Config.AutoFarmHoldTime)
                        end
                        if autoFarmActive then
                            task.wait(0.2)
                            teleportToHomePlot()
                        end
                        autoFarmProcessed[egg] = true
                        task.wait(0.2)
                    end
                end
            end

            autoFarmCurrentName = nil
            if not didWork then
                autoFarmActive = false
                autoFarmThread = nil
                if StopAutoFarmBtn then StopAutoFarmBtn.Visible = false end
                break
            end
            task.wait(0.2)
        end

        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        if not autoFarmActive then
            StatusLabel.Text = "● AutoFarm finished: no eggs left"
            StatusLabel.TextColor3 = Config.TextSecondary
        end
    end)
end

--==================================================
-- MAIN GUI
--==================================================

local oldGui = nil
pcall(function()
    oldGui = TargetParent:FindFirstChild("BEE_HUB_Premium")
end)
if oldGui then
    pcall(function() oldGui:Destroy() end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BEE_HUB_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetParent

--==================================================
-- DEVICE SELECTION MENU
--==================================================

local DeviceFrame = Instance.new("Frame")
DeviceFrame.Name = "DeviceSelectionFrame"
DeviceFrame.Size = UDim2.new(0, 340, 0, 180)
DeviceFrame.Position = UDim2.new(0.5, -170, 0.5, -90)
DeviceFrame.BackgroundColor3 = Config.DarkBg
DeviceFrame.BackgroundTransparency = 0.05
DeviceFrame.BorderSizePixel = 0
DeviceFrame.Active = true
DeviceFrame.Parent = ScreenGui

local DeviceCorner = Instance.new("UICorner")
DeviceCorner.CornerRadius = UDim.new(0, 14)
DeviceCorner.Parent = DeviceFrame

local DeviceStroke = Instance.new("UIStroke")
DeviceStroke.Color = Config.PrimaryColor
DeviceStroke.Thickness = 2
DeviceStroke.Transparency = 0.3
DeviceStroke.Parent = DeviceFrame

local DeviceGradient = Instance.new("UIGradient")
DeviceGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.PrimaryColor),
    ColorSequenceKeypoint.new(1, Config.SecondaryColor),
})
DeviceGradient.Rotation = 45
DeviceGradient.Parent = DeviceStroke

local DeviceTitle = Instance.new("TextLabel")
DeviceTitle.Size = UDim2.new(1, 0, 0, 40)
DeviceTitle.Position = UDim2.new(0, 0, 0, 15)
DeviceTitle.BackgroundTransparency = 1
DeviceTitle.Text = "🐝 BEE HUB 🍯"
DeviceTitle.TextColor3 = Config.PrimaryColor
DeviceTitle.TextSize = 22
DeviceTitle.Font = Enum.Font.GothamBlack
DeviceTitle.Parent = DeviceFrame

local DeviceSubtitle = Instance.new("TextLabel")
DeviceSubtitle.Size = UDim2.new(1, 0, 0, 18)
DeviceSubtitle.Position = UDim2.new(0, 0, 0, 52)
DeviceSubtitle.BackgroundTransparency = 1
DeviceSubtitle.Text = "👑 PREMIUM 👑"
DeviceSubtitle.TextColor3 = Config.SecondaryColor
DeviceSubtitle.TextSize = 13
DeviceSubtitle.Font = Enum.Font.GothamBold
DeviceSubtitle.Parent = DeviceFrame

local DevicePrompt = Instance.new("TextLabel")
DevicePrompt.Size = UDim2.new(1, 0, 0, 16)
DevicePrompt.Position = UDim2.new(0, 0, 0, 75)
DevicePrompt.BackgroundTransparency = 1
DevicePrompt.Text = "Select Your Device"
DevicePrompt.TextColor3 = Config.TextSecondary
DevicePrompt.TextSize = 11
DevicePrompt.Font = Enum.Font.Gotham
DevicePrompt.Parent = DeviceFrame

local PCBtn = Instance.new("TextButton")
PCBtn.Size = UDim2.new(0, 130, 0, 50)
PCBtn.Position = UDim2.new(0, 30, 0, 105)
PCBtn.BackgroundColor3 = Config.ButtonBg
PCBtn.Text = "💻 PC"
PCBtn.TextColor3 = Config.TextPrimary
PCBtn.TextSize = 15
PCBtn.Font = Enum.Font.GothamBold
PCBtn.Parent = DeviceFrame

local PCCorner = Instance.new("UICorner")
PCCorner.CornerRadius = UDim.new(0, 8)
PCCorner.Parent = PCBtn

local PCStroke = Instance.new("UIStroke")
PCStroke.Color = Config.PrimaryColor
PCStroke.Thickness = 1.5
PCStroke.Transparency = 0.5
PCStroke.Parent = PCBtn

local MobileBtn = Instance.new("TextButton")
MobileBtn.Size = UDim2.new(0, 130, 0, 50)
MobileBtn.Position = UDim2.new(1, -160, 0, 105)
MobileBtn.BackgroundColor3 = Config.ButtonBg
MobileBtn.Text = "📱 Mobile"
MobileBtn.TextColor3 = Config.TextPrimary
MobileBtn.TextSize = 15
MobileBtn.Font = Enum.Font.GothamBold
MobileBtn.Parent = DeviceFrame

local MobileCorner = Instance.new("UICorner")
MobileCorner.CornerRadius = UDim.new(0, 8)
MobileCorner.Parent = MobileBtn

local MobileStroke = Instance.new("UIStroke")
MobileStroke.Color = Config.PrimaryColor
MobileStroke.Thickness = 1.5
MobileStroke.Transparency = 0.5
MobileStroke.Parent = MobileBtn

--==================================================
-- MAIN FRAME
--==================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, Config.PCWidth, 0, Config.PCHeight)
MainFrame.Position = UDim2.new(0.5, -Config.PCWidth / 2, 0.4, -Config.PCHeight / 2)
MainFrame.BackgroundColor3 = Config.DarkBg
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.PrimaryColor
MainStroke.Thickness = 2
MainStroke.Transparency = 0.4
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.PrimaryColor),
    ColorSequenceKeypoint.new(0.5, Config.SecondaryColor),
    ColorSequenceKeypoint.new(1, Config.PrimaryColor),
})
MainGradient.Rotation = 45
MainGradient.Parent = MainStroke

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 65)
TopBar.BackgroundColor3 = Color3.fromRGB(12, 9, 4)
TopBar.BackgroundTransparency = 0.05
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local TopBarBottom = Instance.new("Frame")
TopBarBottom.Size = UDim2.new(1, 0, 0, 14)
TopBarBottom.Position = UDim2.new(0, 0, 1, -14)
TopBarBottom.BackgroundColor3 = Color3.fromRGB(12, 9, 4)
TopBarBottom.BorderSizePixel = 0
TopBarBottom.Parent = TopBar

local AuthorLabel = Instance.new("TextLabel")
AuthorLabel.Size = UDim2.new(1, -55, 0, 12)
AuthorLabel.Position = UDim2.new(0, 14, 0, 6)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Text = "BEE HUB 🐝🍯 | PREMIUM 👑"
AuthorLabel.TextColor3 = Config.PrimaryColor
AuthorLabel.TextSize = 13
AuthorLabel.Font = Enum.Font.GothamBlack
AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
AuthorLabel.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -55, 0, 18)
TitleLabel.Position = UDim2.new(0, 14, 0, 22)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Ride A Pet — Eggs ESP"
TitleLabel.TextColor3 = Config.TextPrimary
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local GameLabel = Instance.new("TextLabel")
GameLabel.Size = UDim2.new(1, -55, 0, 12)
GameLabel.Position = UDim2.new(0, 14, 0, 42)
GameLabel.BackgroundTransparency = 1
GameLabel.Text = "By ThiAez • Redesigned"
GameLabel.TextColor3 = Config.TextSecondary
GameLabel.TextSize = 10
GameLabel.Font = Enum.Font.Gotham
GameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameLabel.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 34, 0, 34)
MinimizeBtn.Position = UDim2.new(1, -42, 0, 15)
MinimizeBtn.BackgroundColor3 = Config.ButtonBg
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Config.PrimaryColor
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

local MinStroke = Instance.new("UIStroke")
MinStroke.Color = Config.PrimaryColor
MinStroke.Thickness = 1
MinStroke.Transparency = 0.5
MinStroke.Parent = MinimizeBtn

--==================================================
-- CONTENT CONTAINER
--==================================================

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -24, 1, -78)
ContentContainer.Position = UDim2.new(0, 12, 0, 72)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

--==================================================
-- STATUS LABEL
--==================================================

StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -140, 0, 22)
StatusLabel.Position = UDim2.new(0, 0, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "● System ready"
StatusLabel.TextColor3 = Config.PrimaryColor
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = ContentContainer

--==================================================
-- BUTTON STYLING
--==================================================

local function styleButton(button)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Config.PrimaryColor
    stroke.Transparency = 0.7
    stroke.Thickness = 1
    stroke.Parent = button

    button.AutoButtonColor = false

    button.MouseEnter:Connect(function()
        tween(button, {
            BackgroundTransparency = math.max(0, button.BackgroundTransparency - 0.15)
        }, 0.10)
        tween(stroke, { Transparency = 0.3 }, 0.10)
    end)

    button.MouseLeave:Connect(function()
        tween(button, {
            BackgroundTransparency = math.min(0.5, button.BackgroundTransparency + 0.15)
        }, 0.10)
        tween(stroke, { Transparency = 0.7 }, 0.10)
    end)
end

--==================================================
-- MODE BUTTONS
--==================================================

ModeAutoFarmBtn = Instance.new("TextButton")
ModeAutoFarmBtn.Size = UDim2.new(0.5, -4, 0, 36)
ModeAutoFarmBtn.Position = UDim2.new(0, 0, 0, 28)
ModeAutoFarmBtn.BackgroundColor3 = Config.PrimaryColor
ModeAutoFarmBtn.Text = "🏃 AutoFarm"
ModeAutoFarmBtn.TextColor3 = Color3.fromRGB(30, 20, 5)
ModeAutoFarmBtn.TextSize = 12
ModeAutoFarmBtn.Font = Enum.Font.GothamBold
ModeAutoFarmBtn.Parent = ContentContainer
styleButton(ModeAutoFarmBtn)

ModeTeleportBtn = Instance.new("TextButton")
ModeTeleportBtn.Size = UDim2.new(0.5, -4, 0, 36)
ModeTeleportBtn.Position = UDim2.new(0.5, 4, 0, 28)
ModeTeleportBtn.BackgroundColor3 = Config.ButtonBg
ModeTeleportBtn.Text = "⚡ Teleport"
ModeTeleportBtn.TextColor3 = Config.TextSecondary
ModeTeleportBtn.TextSize = 12
ModeTeleportBtn.Font = Enum.Font.GothamBold
ModeTeleportBtn.Parent = ContentContainer
styleButton(ModeTeleportBtn)

ModeAutoFarmBtn.MouseButton1Click:Connect(function() setMovementMode("AutoFarm") end)
ModeTeleportBtn.MouseButton1Click:Connect(function() setMovementMode("Teleport") end)
updateMovementModeButtons()

--==================================================
-- STOP AUTOFARM
--==================================================

StopAutoFarmBtn = Instance.new("TextButton")
StopAutoFarmBtn.Size = UDim2.new(0, 130, 0, 24)
StopAutoFarmBtn.Position = UDim2.new(1, -130, 0, 0)
StopAutoFarmBtn.BackgroundColor3 = Config.AccentRed
StopAutoFarmBtn.Text = "■ Stop AutoFarm"
StopAutoFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopAutoFarmBtn.TextSize = 11
StopAutoFarmBtn.Font = Enum.Font.GothamBold
StopAutoFarmBtn.Visible = false
StopAutoFarmBtn.Parent = ContentContainer
styleButton(StopAutoFarmBtn)

StopAutoFarmBtn.MouseButton1Click:Connect(function()
    stopAutoFarm()
    StopAutoFarmBtn.Visible = false
    StatusLabel.Text = "● AutoFarm stopped"
    StatusLabel.TextColor3 = Config.AccentRed
end)

--==================================================
-- SECTION: ESP
--==================================================

local ESPHeader = createSectionLabel(ContentContainer, "ESP SETTINGS", 70)

local ToggleGlobalESPBtn = Instance.new("TextButton")
ToggleGlobalESPBtn.Size = UDim2.new(1, 0, 0, 38)
ToggleGlobalESPBtn.Position = UDim2.new(0, 0, 0, 92)
ToggleGlobalESPBtn.BackgroundColor3 = Config.ButtonBg
ToggleGlobalESPBtn.Text = "✨ ESP All: OFF"
ToggleGlobalESPBtn.TextColor3 = Config.TextPrimary
ToggleGlobalESPBtn.TextSize = 14
ToggleGlobalESPBtn.Font = Enum.Font.GothamBold
ToggleGlobalESPBtn.Parent = ContentContainer
styleButton(ToggleGlobalESPBtn)

ToggleGlobalESPBtn.MouseButton1Click:Connect(function()
    mainESPActive = not mainESPActive
    if mainESPActive then
        ToggleGlobalESPBtn.Text = "✨ ESP All: ON"
        ToggleGlobalESPBtn.TextColor3 = Config.PrimaryColor
        StatusLabel.Text = "● ESP activated"
        StatusLabel.TextColor3 = Config.PrimaryColor
    else
        ToggleGlobalESPBtn.Text = "✨ ESP All: OFF"
        ToggleGlobalESPBtn.TextColor3 = Config.TextPrimary
        StatusLabel.Text = "● ESP deactivated"
        StatusLabel.TextColor3 = Config.TextSecondary
    end
    applyGlobalESP(mainESPActive)
end)

--==================================================
-- SECTION: SOUND TOGGLE 🔊
--==================================================

local SoundToggleBtn = Instance.new("TextButton")
SoundToggleBtn.Size = UDim2.new(1, 0, 0, 32)
SoundToggleBtn.Position = UDim2.new(0, 0, 0, 138)
SoundToggleBtn.BackgroundColor3 = Config.ButtonBg
SoundToggleBtn.Text = "🔊 Startup Sound: ON"
SoundToggleBtn.TextColor3 = Config.PrimaryColor
SoundToggleBtn.TextSize = 12
SoundToggleBtn.Font = Enum.Font.GothamBold
SoundToggleBtn.Parent = ContentContainer
styleButton(SoundToggleBtn)

SoundToggleBtn.MouseButton1Click:Connect(function()
    soundEnabled = not soundEnabled
    if soundEnabled then
        SoundToggleBtn.Text = "🔊 Startup Sound: ON"
        SoundToggleBtn.TextColor3 = Config.PrimaryColor
        playStartupSound()  -- preview
    else
        SoundToggleBtn.Text = "🔇 Startup Sound: OFF"
        SoundToggleBtn.TextColor3 = Config.TextSecondary
        if startupSound and startupSound.Parent then
            startupSound:Stop()
            startupSound:Destroy()
        end
    end
end)

--==================================================
-- SECTION: AUTOMATION
--==================================================

local AutoHeader = createSectionLabel(ContentContainer, "AUTOMATION", 180)

local AutoBestEggBtn = Instance.new("TextButton")
AutoBestEggBtn.Size = UDim2.new(1, 0, 0, 38)
AutoBestEggBtn.Position = UDim2.new(0, 0, 0, 202)
AutoBestEggBtn.BackgroundColor3 = Config.ButtonBg
AutoBestEggBtn.Text = "🥚 Auto Best Egg: OFF"
AutoBestEggBtn.TextColor3 = Config.TextPrimary
AutoBestEggBtn.TextSize = 14
AutoBestEggBtn.Font = Enum.Font.GothamBold
AutoBestEggBtn.Parent = ContentContainer
styleButton(AutoBestEggBtn)

AutoBestEggBtn.MouseButton1Click:Connect(function()
    autoBestEggActive = not autoBestEggActive
    if autoBestEggActive then
        AutoBestEggBtn.Text = "🥚 Auto Best Egg: ON"
        AutoBestEggBtn.TextColor3 = Config.PrimaryColor
        StatusLabel.Text = "● Auto Best Egg active"
        StatusLabel.TextColor3 = Config.PrimaryColor
        startAutoBestEgg()
    else
        AutoBestEggBtn.Text = "🥚 Auto Best Egg: OFF"
        AutoBestEggBtn.TextColor3 = Config.TextPrimary
        StatusLabel.Text = "● System ready"
        StatusLabel.TextColor3 = Config.PrimaryColor
        stopAutoBestEgg()
    end
end)

--==================================================
-- SECTION: NAVIGATION
--==================================================

local NavHeader = createSectionLabel(ContentContainer, "NAVIGATION", 250)

local TPHomeBtn = Instance.new("TextButton")
TPHomeBtn.Size = UDim2.new(1, 0, 0, 38)
TPHomeBtn.Position = UDim2.new(0, 0, 0, 272)
TPHomeBtn.BackgroundColor3 = Config.ButtonBg
TPHomeBtn.Text = "🏠 Teleport Home"
TPHomeBtn.TextColor3 = Config.TextPrimary
TPHomeBtn.TextSize = 14
TPHomeBtn.Font = Enum.Font.GothamBold
TPHomeBtn.Parent = ContentContainer
styleButton(TPHomeBtn)

TPHomeBtn.MouseButton1Click:Connect(function()
    local success = teleportToHomePlot()
    if success then
        StatusLabel.Text = movementMode == "AutoFarm" and "● Moved Home (500 + noclip)" or "● Teleported Home"
        StatusLabel.TextColor3 = Config.PrimaryColor
    else
        StatusLabel.Text = "● Plot not found"
        StatusLabel.TextColor3 = Config.AccentRed
    end
end)

local KeybindBtn = Instance.new("TextButton")
KeybindBtn.Size = UDim2.new(1, 0, 0, 32)
KeybindBtn.Position = UDim2.new(0, 0, 0, 318)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(22, 17, 8)
KeybindBtn.Text = "⌨ Home Key: [" .. tpKeybind.Name .. "]"
KeybindBtn.TextColor3 = Config.TextSecondary
KeybindBtn.TextSize = 12
KeybindBtn.Font = Enum.Font.Gotham
KeybindBtn.Parent = ContentContainer
styleButton(KeybindBtn)

KeybindBtn.MouseButton1Click:Connect(function()
    listeningForKey = true
    KeybindBtn.Text = "Press a key..."
    KeybindBtn.TextColor3 = Config.PrimaryColor
end)

local ToggleListBtn = Instance.new("TextButton")
ToggleListBtn.Size = UDim2.new(1, 0, 0, 38)
ToggleListBtn.Position = UDim2.new(0, 0, 0, 358)
ToggleListBtn.BackgroundColor3 = Config.ButtonBg
ToggleListBtn.Text = "📋 Show Egg List ▼"
ToggleListBtn.TextColor3 = Config.TextPrimary
ToggleListBtn.TextSize = 14
ToggleListBtn.Font = Enum.Font.GothamBold
ToggleListBtn.Parent = ContentContainer
styleButton(ToggleListBtn)

--==================================================
-- LIST CONTAINER
--==================================================

local ListContainerFrame = Instance.new("Frame")
ListContainerFrame.Size = UDim2.new(1, 0, 0, 390)
ListContainerFrame.Position = UDim2.new(0, 0, 0, 404)
ListContainerFrame.BackgroundColor3 = Color3.fromRGB(22, 17, 8)
ListContainerFrame.BackgroundTransparency = 0.05
ListContainerFrame.Visible = false
ListContainerFrame.Parent = ContentContainer

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 10)
ListCorner.Parent = ListContainerFrame

local ListStroke = Instance.new("UIStroke")
ListStroke.Color = Config.PrimaryColor
ListStroke.Transparency = 0.6
ListStroke.Thickness = 1
ListStroke.Parent = ListContainerFrame

local EggCountLabel = Instance.new("TextLabel")
EggCountLabel.Size = UDim2.new(1, -12, 0, 20)
EggCountLabel.Position = UDim2.new(0, 8, 0, 6)
EggCountLabel.BackgroundTransparency = 1
EggCountLabel.Text = "🐝 Eggs detected: 0"
EggCountLabel.TextColor3 = Config.TextSecondary
EggCountLabel.TextSize = 12
EggCountLabel.Font = Enum.Font.GothamBold
EggCountLabel.TextXAlignment = Enum.TextXAlignment.Left
EggCountLabel.Parent = ListContainerFrame

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.48, -6, 0, 28)
RefreshBtn.Position = UDim2.new(0, 6, 0, 30)
RefreshBtn.BackgroundColor3 = Config.ButtonBg
RefreshBtn.Text = "🔄 Refresh"
RefreshBtn.TextColor3 = Config.TextPrimary
RefreshBtn.TextSize = 13
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.Parent = ListContainerFrame
styleButton(RefreshBtn)

local SortBtn = Instance.new("TextButton")
SortBtn.Size = UDim2.new(0.48, -6, 0, 28)
SortBtn.Position = UDim2.new(0.52, 0, 0, 30)
SortBtn.BackgroundColor3 = Config.ButtonBg
SortBtn.Text = "Sort: Name"
SortBtn.TextColor3 = Config.TextPrimary
SortBtn.TextSize = 13
SortBtn.Font = Enum.Font.GothamBold
SortBtn.Parent = ListContainerFrame
styleButton(SortBtn)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -12, 0, 28)
SearchBox.Position = UDim2.new(0, 6, 0, 64)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 27, 12)
SearchBox.PlaceholderText = "🔍 Search eggs..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 130, 90)
SearchBox.Text = ""
SearchBox.TextColor3 = Config.TextPrimary
SearchBox.TextSize = 13
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = ListContainerFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchBox

local SearchPadding = Instance.new("UIPadding")
SearchPadding.PaddingLeft = UDim.new(0, 10)
SearchPadding.Parent = SearchBox

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -12, 1, -102)
ScrollList.Position = UDim2.new(0, 6, 0, 100)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 5
ScrollList.ScrollBarImageColor3 = Config.PrimaryColor
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollList.Parent = ListContainerFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollList

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 6)
end)

--==================================================
-- SORT EGGS
--==================================================

local function getEggsForList()
    local eggs = {}
    if not RenderedEggsFolder then return eggs end
    for _, egg in ipairs(RenderedEggsFolder:GetChildren()) do
        if egg:IsA("Model") or egg:IsA("BasePart") then
            table.insert(eggs, egg)
        end
    end
    table.sort(eggs, function(a, b)
        if sortMode == "Distance" then
            return getDistanceToTarget(a) < getDistanceToTarget(b)
        end
        return a.Name:lower() < b.Name:lower()
    end)
    return eggs
end

--==================================================
-- CREATE LIST ITEM
--==================================================

local function createEggListItem(egg, itemHeight, textSize)
    local ItemFrame = Instance.new("Frame")
    ItemFrame.Size = UDim2.new(1, -6, 0, itemHeight)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(38, 29, 14)
    ItemFrame.BackgroundTransparency = 0.1
    ItemFrame.Parent = ScrollList

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = ItemFrame

    local itemStroke = Instance.new("UIStroke")
    itemStroke.Color = Config.PrimaryColor
    itemStroke.Transparency = 0.8
    itemStroke.Thickness = 1
    itemStroke.Parent = ItemFrame

    local eggIcon = Instance.new("ImageLabel")
    eggIcon.Size = UDim2.new(0, itemHeight - 8, 0, itemHeight - 8)
    eggIcon.Position = UDim2.new(0, 5, 0.5, -(itemHeight - 8) / 2)
    eggIcon.BackgroundTransparency = 1
    eggIcon.Image = getEggImage(egg.Name)
    eggIcon.ScaleType = Enum.ScaleType.Fit
    eggIcon.Parent = ItemFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -215, 1, 0)
    nameLabel.Position = UDim2.new(0, itemHeight + 7, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = egg.Name
    nameLabel.TextColor3 = Config.TextPrimary
    nameLabel.TextSize = textSize
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = ItemFrame

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(0, 55, 1, 0)
    distanceLabel.Position = UDim2.new(1, -155, 0, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Config.SecondaryColor
    distanceLabel.TextSize = textSize - 1
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Text = "--"
    distanceLabel.Parent = ItemFrame

    local distance = getDistanceToTarget(egg)
    if distance ~= math.huge then
        distanceLabel.Text = string.format("%dm", math.floor(distance + 0.5))
    end

    local TPBtn = Instance.new("TextButton")
    TPBtn.Size = UDim2.new(0, 38, 0, itemHeight - 8)
    TPBtn.Position = UDim2.new(1, -152, 0.5, -(itemHeight - 8) / 2)
    TPBtn.BackgroundColor3 = Config.ButtonBg
    TPBtn.Text = "TP"
    TPBtn.TextColor3 = Config.TextPrimary
    TPBtn.TextSize = 10
    TPBtn.Font = Enum.Font.GothamBold
    TPBtn.Parent = ItemFrame
    styleButton(TPBtn)

    TPBtn.MouseButton1Click:Connect(function()
        if not egg.Parent then return end
        local success = teleportToModel(egg)
        if success then
            StatusLabel.Text = "● TP: " .. egg.Name
            StatusLabel.TextColor3 = Config.PrimaryColor
        end
    end)

    local AutoFarmBtn = Instance.new("TextButton")
    AutoFarmBtn.Size = UDim2.new(0, 58, 0, itemHeight - 8)
    AutoFarmBtn.Position = UDim2.new(1, -110, 0.5, -(itemHeight - 8) / 2)
    AutoFarmBtn.BackgroundColor3 = Config.ButtonBg
    AutoFarmBtn.Text = "Farm"
    AutoFarmBtn.TextColor3 = Config.TextPrimary
    AutoFarmBtn.TextSize = 9
    AutoFarmBtn.Font = Enum.Font.GothamBold
    AutoFarmBtn.Parent = ItemFrame
    styleButton(AutoFarmBtn)

    setAutoFarmButtonState(AutoFarmBtn, autoFarmEggs[egg.Name] == true)

    AutoFarmBtn.MouseButton1Click:Connect(function()
        if not egg.Parent then return end
        local name = egg.Name
        autoFarmEggs[name] = not autoFarmEggs[name]

        for processedEgg in pairs(autoFarmProcessed) do
            if processedEgg and processedEgg.Name == name then
                autoFarmProcessed[processedEgg] = nil
            end
        end

        setAutoFarmButtonState(AutoFarmBtn, autoFarmEggs[name] == true)

        if autoFarmEggs[name] then
            StatusLabel.Text = "● AutoFarm selected: " .. name
            StatusLabel.TextColor3 = Config.PrimaryColor
            if not autoFarmActive then
                startAutoFarm()
            end
        else
            StatusLabel.Text = "● AutoFarm removed: " .. name
            StatusLabel.TextColor3 = Config.TextSecondary
            local anySelected = false
            for _ in pairs(autoFarmEggs) do
                anySelected = true
                break
            end
            if not anySelected then
                stopAutoFarm()
                StopAutoFarmBtn.Visible = false
            end
        end
        StopAutoFarmBtn.Visible = autoFarmActive
    end)

    local ESPItemBtn = Instance.new("TextButton")
    ESPItemBtn.Size = UDim2.new(0, 46, 0, itemHeight - 8)
    ESPItemBtn.Position = UDim2.new(1, -48, 0.5, -(itemHeight - 8) / 2)
    ESPItemBtn.BackgroundColor3 = Config.PrimaryColor
    ESPItemBtn.TextColor3 = Color3.fromRGB(30, 20, 5)
    ESPItemBtn.TextSize = 10
    ESPItemBtn.Font = Enum.Font.GothamBold
    ESPItemBtn.Parent = ItemFrame
    styleButton(ESPItemBtn)

    local data = eggData[egg]
    if data and data.CustomActive then
        ESPItemBtn.Text = "ON"
        ESPItemBtn.BackgroundColor3 = Config.SecondaryColor
    else
        ESPItemBtn.Text = "ESP"
        ESPItemBtn.BackgroundColor3 = Config.PrimaryColor
    end

    ESPItemBtn.MouseButton1Click:Connect(function()
        if not eggData[egg] then
            eggData[egg] = {
                Highlight = nil,
                NameBillboard = nil,
                CustomColor = Config.CustomESPColor,
                CustomActive = false
            }
        end
        local eggInfo = eggData[egg]
        eggInfo.CustomActive = not eggInfo.CustomActive
        eggInfo.CustomColor = Config.CustomESPColor

        if eggInfo.CustomActive then
            ESPItemBtn.Text = "ON"
            ESPItemBtn.BackgroundColor3 = Config.SecondaryColor
            StatusLabel.Text = "● Yellow ESP: " .. egg.Name
        else
            ESPItemBtn.Text = "ESP"
            ESPItemBtn.BackgroundColor3 = Config.PrimaryColor
            StatusLabel.Text = "● Yellow ESP off"
        end
        updateEggESP(egg)
    end)
end

--==================================================
-- POPULATE LIST
--==================================================

local function clearEggList()
    for _, child in ipairs(ScrollList:GetChildren()) do
        if child ~= UIListLayout then
            child:Destroy()
        end
    end
end

local function populateList()
    clearEggList()

    if not RenderedEggsFolder then
        EggCountLabel.Text = "🐝 Eggs: 0  |  Results: 0"
        return
    end

    local query = currentSearchQuery:lower()
    local eggs = getEggsForList()
    local visibleCount = 0
    local itemHeight = isMobileMode and 34 or 38
    local textSize = isMobileMode and 11 or 13

    for _, egg in ipairs(eggs) do
        local matches = query == "" or string.find(egg.Name:lower(), query, 1, true)
        if matches then
            visibleCount += 1
            createEggListItem(egg, itemHeight, textSize)
        end
    end

    EggCountLabel.Text = "🐝 Eggs: " .. tostring(#eggs) .. "  |  Results: " .. tostring(visibleCount)

    if visibleCount == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, -10, 0, 35)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "🍯 No eggs found"
        emptyLabel.TextColor3 = Config.TextSecondary
        emptyLabel.TextSize = 12
        emptyLabel.Font = Enum.Font.GothamItalic
        emptyLabel.Parent = ScrollList
    end
end

--==================================================
-- LIST CONTROLS
--==================================================

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local newQuery = SearchBox.Text
    if newQuery == currentSearchQuery then return end
    currentSearchQuery = newQuery
    populateList()
end)

RefreshBtn.MouseButton1Click:Connect(function()
    populateList()
    updateAllESP()
    StatusLabel.Text = "● List refreshed"
    StatusLabel.TextColor3 = Config.PrimaryColor
end)

SortBtn.MouseButton1Click:Connect(function()
    if sortMode == "Name" then
        sortMode = "Distance"
        SortBtn.Text = "Sort: Distance"
    else
        sortMode = "Name"
        SortBtn.Text = "Sort: Name"
    end
    populateList()
end)

ToggleListBtn.MouseButton1Click:Connect(function()
    ListContainerFrame.Visible = not ListContainerFrame.Visible
    if ListContainerFrame.Visible then
        ToggleListBtn.Text = "📋 Hide Egg List ▲"
        populateList()
    else
        ToggleListBtn.Text = "📋 Show Egg List ▼"
    end
end)

--==================================================
-- MINIMIZE
--==================================================

local currentExpandedWidth = Config.PCWidth
local currentExpandedHeight = Config.PCHeight

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentContainer.Visible = false
        tween(MainFrame, {
            Size = UDim2.new(0, currentExpandedWidth, 0, TopBar.Size.Y.Offset)
        }, 0.20)
        MinimizeBtn.Text = "+"
    else
        tween(MainFrame, {
            Size = UDim2.new(0, currentExpandedWidth, 0, currentExpandedHeight)
        }, 0.20)
        task.delay(0.12, function()
            if not isMinimized then
                ContentContainer.Visible = true
            end
        end)
        MinimizeBtn.Text = "—"
    end
end)

--==================================================
-- DRAG / MOVE MENU
--==================================================

local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- KEYBIND
--==================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if listeningForKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            tpKeybind = input.KeyCode
            listeningForKey = false
            KeybindBtn.Text = "⌨ Home Key: [" .. tpKeybind.Name .. "]"
            KeybindBtn.TextColor3 = Config.TextSecondary
        end
        return
    end

    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == tpKeybind then
            teleportToHomePlot()
        end
    end
end)

--==================================================
-- AUTO ESP UPDATE
--==================================================

task.spawn(function()
    while ScreenGui.Parent do
        if mainESPActive then
            for egg, data in pairs(eggData) do
                if egg and egg.Parent then
                    if data.NameBillboard and data.NameBillboard.Enabled then
                        updateEggLabel(egg)
                    end
                end
            end
        end
        task.wait(0.20)
    end
end)

--==================================================
-- DETECT NEW / REMOVED EGGS
--==================================================

if RenderedEggsFolder then
    RenderedEggsFolder.ChildAdded:Connect(function(egg)
        autoFarmProcessed[egg] = nil
        task.wait(0.05)
        updateEggESP(egg)
        if ListContainerFrame.Visible then
            populateList()
        end
    end)

    RenderedEggsFolder.ChildRemoved:Connect(function(egg)
        removeEggData(egg)
        if ListContainerFrame.Visible then
            populateList()
        end
    end)

    for _, egg in ipairs(RenderedEggsFolder:GetChildren()) do
        updateEggESP(egg)
    end
end

--==================================================
-- PC MODE
--==================================================

local function setPCMode()
    isMobileMode = false
    currentExpandedWidth = Config.PCWidth
    currentExpandedHeight = Config.PCHeight

    MainFrame.Size = UDim2.new(0, Config.PCWidth, 0, Config.PCHeight)
    MainFrame.Position = UDim2.new(0.5, -Config.PCWidth / 2, 0.4, -Config.PCHeight / 2)

    TopBar.Size = UDim2.new(1, 0, 0, 65)
    AuthorLabel.TextSize = 13
    TitleLabel.TextSize = 15
    GameLabel.TextSize = 10
    ContentContainer.Size = UDim2.new(1, -24, 1, -78)
    ContentContainer.Position = UDim2.new(0, 12, 0, 72)
    StatusLabel.TextSize = 12

    StopAutoFarmBtn.Size = UDim2.new(0, 130, 0, 24)
    StopAutoFarmBtn.Position = UDim2.new(1, -130, 0, 0)

    ModeAutoFarmBtn.Size = UDim2.new(0.5, -4, 0, 36)
    ModeAutoFarmBtn.Position = UDim2.new(0, 0, 0, 28)
    ModeTeleportBtn.Size = UDim2.new(0.5, -4, 0, 36)
    ModeTeleportBtn.Position = UDim2.new(0.5, 4, 0, 28)

    ESPHeader.Position = UDim2.new(0, 0, 0, 70)
    ToggleGlobalESPBtn.Position = UDim2.new(0, 0, 0, 92)
    SoundToggleBtn.Position = UDim2.new(0, 0, 0, 138)
    AutoHeader.Position = UDim2.new(0, 0, 0, 180)
    AutoBestEggBtn.Position = UDim2.new(0, 0, 0, 202)
    NavHeader.Position = UDim2.new(0, 0, 0, 250)
    TPHomeBtn.Position = UDim2.new(0, 0, 0, 272)
    KeybindBtn.Position = UDim2.new(0, 0, 0, 318)
    ToggleListBtn.Position = UDim2.new(0, 0, 0, 358)
    ListContainerFrame.Position = UDim2.new(0, 0, 0, 404)
    ListContainerFrame.Size = UDim2.new(1, 0, 0, 390)

    DeviceFrame:Destroy()
    MainFrame.Visible = true
    populateList()
end

--==================================================
-- MOBILE MODE
--==================================================

local function setMobileMode()
    isMobileMode = true
    currentExpandedWidth = Config.MobileWidth
    currentExpandedHeight = Config.MobileHeight

    MainFrame.Size = UDim2.new(0, Config.MobileWidth, 0, Config.MobileHeight)
    MainFrame.Position = UDim2.new(0.5, -Config.MobileWidth / 2, 0.5, -Config.MobileHeight / 2)

    TopBar.Size = UDim2.new(1, 0, 0, 55)
    AuthorLabel.TextSize = 11
    AuthorLabel.Position = UDim2.new(0, 12, 0, 4)
    TitleLabel.TextSize = 13
    TitleLabel.Position = UDim2.new(0, 12, 0, 20)
    GameLabel.TextSize = 9
    GameLabel.Position = UDim2.new(0, 12, 0, 36)
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -36, 0, 12)

    ContentContainer.Size = UDim2.new(1, -20, 1, -64)
    ContentContainer.Position = UDim2.new(0, 10, 0, 60)
    StatusLabel.TextSize = 11

    StopAutoFarmBtn.Size = UDim2.new(0, 110, 0, 20)
    StopAutoFarmBtn.Position = UDim2.new(1, -110, 0, 0)

    ModeAutoFarmBtn.Size = UDim2.new(0.5, -3, 0, 32)
    ModeAutoFarmBtn.Position = UDim2.new(0, 0, 0, 24)
    ModeAutoFarmBtn.TextSize = 11
    ModeTeleportBtn.Size = UDim2.new(0.5, -3, 0, 32)
    ModeTeleportBtn.Position = UDim2.new(0.5, 3, 0, 24)
    ModeTeleportBtn.TextSize = 11

    ESPHeader.Position = UDim2.new(0, 0, 0, 62)
    ESPHeader.TextSize = 10
    ToggleGlobalESPBtn.Position = UDim2.new(0, 0, 0, 82)
    ToggleGlobalESPBtn.Size = UDim2.new(1, 0, 0, 34)
    ToggleGlobalESPBtn.TextSize = 12

    SoundToggleBtn.Position = UDim2.new(0, 0, 0, 122)
    SoundToggleBtn.Size = UDim2.new(1, 0, 0, 28)
    SoundToggleBtn.TextSize = 11

    AutoHeader.Position = UDim2.new(0, 0, 0, 158)
    AutoHeader.TextSize = 10
    AutoBestEggBtn.Position = UDim2.new(0, 0, 0, 178)
    AutoBestEggBtn.Size = UDim2.new(1, 0, 0, 34)
    AutoBestEggBtn.TextSize = 12

    NavHeader.Position = UDim2.new(0, 0, 0, 220)
    NavHeader.TextSize = 10
    TPHomeBtn.Position = UDim2.new(0, 0, 0, 240)
    TPHomeBtn.Size = UDim2.new(1, 0, 0, 34)
    TPHomeBtn.TextSize = 12

    KeybindBtn.Position = UDim2.new(0, 0, 0, 280)
    KeybindBtn.Size = UDim2.new(1, 0, 0, 28)
    KeybindBtn.TextSize = 11

    ToggleListBtn.Position = UDim2.new(0, 0, 0, 314)
    ToggleListBtn.Size = UDim2.new(1, 0, 0, 34)
    ToggleListBtn.TextSize = 12

    ListContainerFrame.Position = UDim2.new(0, 0, 0, 354)
    ListContainerFrame.Size = UDim2.new(1, 0, 0, 170)

    EggCountLabel.TextSize = 11
    RefreshBtn.Size = UDim2.new(0.48, -5, 0, 24)
    RefreshBtn.Position = UDim2.new(0, 5, 0, 27)
    RefreshBtn.TextSize = 11
    SortBtn.Size = UDim2.new(0.48, -5, 0, 24)
    SortBtn.Position = UDim2.new(0.52, 0, 0, 27)
    SortBtn.TextSize = 11
    SearchBox.Size = UDim2.new(1, -10, 0, 24)
    SearchBox.Position = UDim2.new(0, 5, 0, 56)
    SearchBox.TextSize = 11
    ScrollList.Size = UDim2.new(1, -10, 1, -88)
    ScrollList.Position = UDim2.new(0, 5, 0, 88)

    DeviceFrame:Destroy()
    MainFrame.Visible = true
    populateList()
end

--==================================================
-- DEVICE BUTTONS
--==================================================

PCBtn.MouseButton1Click:Connect(function()
    setPCMode()
end)

MobileBtn.MouseButton1Click:Connect(function()
    setMobileMode()
end)

--==================================================
-- END
--==================================================

print("[BEE HUB 🐝🍯 | PREMIUM 👑] Loaded successfully with sound.")