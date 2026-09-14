-- ============================================================
-- 🐝 BEE HUB - YELLOW NEON EDITION
-- ============================================================
local teleportService = game:GetService("TeleportService")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")
local lighting = game:GetService("Lighting")
local soundService = game:GetService("SoundService")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

local val = {
  AutoDetectActive = false, AutoHopActive = false, MaxPlayers = 1, AutoDetectThreshold = 3, AutoSave = true, }

local function safeCall()
  if isfile and readfile and isfile("AxionAutoDetectConfig.json") then
    local val2, success = pcall(function()
      return httpService:JSONDecode(readfile("AxionAutoDetectConfig.json"))
    end)

    if val2 and type(success) == "table" then
      for key, value in pairs(success) do
        val[key] = value
      end
    end
  end
end

safeCall()

local function iterate()
  for key2, value2 in pairs(lighting:GetChildren()) do
    if value2:IsA("BlurEffect") and value2.Name:find("Axion") then
      value2:Destroy()
    end
  end
end

task.spawn(function()
  local sound = Instance.new("Sound")
  sound.SoundId = "rbxassetid://106806057419587"
  sound.Volume = 0.5
  sound.Parent = soundService
  sound:Play()
  sound.Ended:Connect(function() sound:Destroy() end)
end)

local val3 = {}

local function safeCall2()
  local val4, success2 = pcall(function()
    if gethui then
      return gethui()
    end

    if syn and syn.protect_gui then
      local screenGui = Instance.new("ScreenGui")
      syn.protect_gui(screenGui)
      return coreGui
    end

    return coreGui
  end)

  return val4 and success2 or coreGui
end

local val5 = safeCall2()

-- 🐝 CHANGED: YELLOW NEON BEE THEME
local val6 = {
  Default = {
    Background = Color3.fromRGB(20, 18, 5),
    BackgroundTransparency = 0.05,
    Container = Color3.fromRGB(35, 30, 5),
    ContainerTransparency = 0.1,
    Element = Color3.fromRGB(60, 50, 8),
    ElementTransparency = 0.15,
    ElementHover = Color3.fromRGB(110, 90, 10),
    Accent = Color3.fromRGB(255, 235, 60),
    AccentDark = Color3.fromRGB(255, 200, 0),
    AccentGlow = Color3.fromRGB(255, 255, 180),
    AccentNeon = Color3.fromRGB(255, 245, 100),
    Text = Color3.fromRGB(255, 255, 220),
    TextDark = Color3.fromRGB(255, 240, 150),
    TextMuted = Color3.fromRGB(200, 180, 90),
    Border = Color3.fromRGB(255, 220, 50),
    BorderTransparency = 0.15,
    GradientStart = Color3.fromRGB(70, 55, 5),
    GradientEnd = Color3.fromRGB(15, 12, 2),
    Font = Enum.Font.GothamBold,
  },
}

local object = {}

function object:Create(p1, p2, p3)
  local instance = Instance.new(p1)

  for key3, value3 in pairs(p2 or {}) do
    if key3 ~= "Parent" then
      instance[key3] = value3
    end
  end

  for key4, value4 in pairs(p3 or {}) do
    value4.Parent = instance
  end

  if p2 and p2.Parent then
    instance.Parent = p2.Parent
  end

  return instance
end

function object:Tween(p4, p5, p6, p7, p8)
  if not p4 then
    return
  else
    local val7 = p6 or 0.25

    local create = tweenService:Create(p4, TweenInfo.new(
      val7, p7 or Enum.EasingStyle.Quart, p8 or Enum.EasingDirection.Out
    ), p5)

    create:Play()

    return create
  end
end

function object:AnimateClick(p9)
  if not p9 then
    return
  end

  local size = p9.Size

  object:Tween(
    p9, { Size = UDim2.new(size.X.Scale, size.X.Offset - 4, size.Y.Scale, size.Y.Offset - 4) }, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out
  )

  task.delay(0.08, function()
    object:Tween(p9, { Size = size }, 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
  end)
end

function object:MakeDraggable(p10, p11, p12)
  local val8, position, position2

  p11.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      val8 = true
      position = input.Position
      position2 = p10.Position

      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          val8 = false
        end
      end)
    end
  end)

  local val9

  p11.InputChanged:Connect(function(input2)
    if input2.UserInputType == Enum.UserInputType.MouseMovement
      or input2.UserInputType == Enum.UserInputType.Touch then
      val9 = input2
    end
  end)

  userInputService.InputChanged:Connect(function(input3)
    if input3 == val9 and val8 then
      local element = input3.Position - position

      object:Tween(p10, {
        Position = UDim2.new(
          position2.X.Scale, position2.X.Offset + element.X, position2.Y.Scale, position2.Y.Offset + element.Y
        ), }, (p12.AnimationSpeed or 0.25) * 0.5)
    end
  end)
end

-- 🐝 NEW: Bee swarm animation around the main container
local function createBeeSwarm(parentFrame, theme)
  local beeFolder = Instance.new("Folder")
  beeFolder.Name = "BeeSwarm"
  beeFolder.Parent = parentFrame

  for i = 1, 8 do
    local bee = Instance.new("TextLabel")
    bee.Name = "Bee_" .. i
    bee.BackgroundTransparency = 1
    bee.Size = UDim2.new(0, 20, 0, 20)
    bee.Font = Enum.Font.GothamBold
    bee.Text = "🐝"
    bee.TextSize = 14
    bee.TextColor3 = theme.AccentNeon
    bee.TextTransparency = 0.15
    bee.ZIndex = 10
    bee.Parent = parentFrame

    local angle = (i / 8) * math.pi * 2
    local radius = 200 + math.random(-20, 20)

    task.spawn(function()
      local startTime = tick()
      local speed = 0.6 + math.random() * 0.4
      local offsetX = math.random(-30, 30)
      local offsetY = math.random(-30, 30)

      while bee.Parent do
        local t = (tick() - startTime) * speed
        local x = math.cos(t + angle) * radius
        local y = math.sin(t * 1.5 + angle) * (radius * 0.4)

        bee.Position = UDim2.new(0.5, x + offsetX, 0.5, y + offsetY)
        bee.Rotation = math.sin(t * 3) * 20
        bee.TextTransparency = 0.1 + math.abs(math.sin(t * 4)) * 0.3

        runService.RenderStepped:Wait()
      end
    end)
  end

  return beeFolder
end

-- 🐝 NEW: Honeycomb pattern overlay
local function createHoneycombOverlay(parentFrame, theme)
  local honeycomb = Instance.new("Frame")
  honeycomb.Name = "HoneycombOverlay"
  honeycomb.BackgroundTransparency = 1
  honeycomb.Size = UDim2.new(1, 0, 1, 0)
  honeycomb.ZIndex = 0
  honeycomb.Parent = parentFrame

  for row = 0, 6 do
    for col = 0, 5 do
      local dot = Instance.new("Frame")
      dot.BackgroundColor3 = theme.Accent
      dot.BackgroundTransparency = 0.85
      dot.BorderSizePixel = 0
      dot.Size = UDim2.new(0, 6, 0, 6)
      dot.Position = UDim2.new(0, 20 + col * 60 + (row % 2) * 30, 0, 20 + row * 45)
      dot.ZIndex = 0
      dot.Parent = honeycomb

      local corner = Instance.new("UICorner")
      corner.CornerRadius = UDim.new(1, 0)
      corner.Parent = dot
    end
  end

  return honeycomb
end

-- 🐝 CHANGED: Name Tag now shows "BEE HUB 🐝🍯 | PREMIUM👑"
local function createNameTag(parentGui, theme)
  local tag = Instance.new("Frame")
  tag.Name = "PlayerNameTag"
  tag.BackgroundColor3 = theme.Background
  tag.BackgroundTransparency = 0.1
  tag.BorderSizePixel = 0
  tag.Size = UDim2.new(0, 300, 0, 42)
  tag.Position = UDim2.new(0.5, 0, 0.5, -210)
  tag.AnchorPoint = Vector2.new(0.5, 0.5)
  tag.ZIndex = 5
  tag.Parent = parentGui

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = tag

  local stroke = Instance.new("UIStroke")
  stroke.Color = theme.AccentNeon
  stroke.Thickness = 2
  stroke.Transparency = 0
  stroke.Parent = tag

  tweenService:Create(stroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Color = theme.AccentGlow,
    Thickness = 3.5,
  }):Play()

  local gradient = Instance.new("UIGradient")
  gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, theme.GradientStart),
    ColorSequenceKeypoint.new(1, theme.GradientEnd),
  })
  gradient.Rotation = 135
  gradient.Parent = tag

  -- 👑 MAIN TEXT: BEE HUB 🐝🍯 | PREMIUM👑
  local mainLabel = Instance.new("TextLabel")
  mainLabel.Name = "MainLabel"
  mainLabel.BackgroundTransparency = 1
  mainLabel.Size = UDim2.new(1, -20, 0, 24)
  mainLabel.Position = UDim2.new(0, 10, 0, 4)
  mainLabel.Font = Enum.Font.GothamBold
  mainLabel.Text = "BEE HUB 🐝🍯 | PREMIUM👑"
  mainLabel.TextColor3 = theme.AccentNeon
  mainLabel.TextSize = 14
  mainLabel.TextXAlignment = Enum.TextXAlignment.Center
  mainLabel.TextScaled = false
  mainLabel.Parent = tag

  -- Neon glow pulse on the main text
  tweenService:Create(mainLabel, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    TextColor3 = theme.AccentGlow,
    TextTransparency = 0.15,
  }):Play()

  -- Subtitle: player info below
  local subLabel = Instance.new("TextLabel")
  subLabel.Name = "SubLabel"
  subLabel.BackgroundTransparency = 1
  subLabel.Size = UDim2.new(1, -20, 0, 12)
  subLabel.Position = UDim2.new(0, 10, 0, 27)
  subLabel.Font = Enum.Font.Gotham
  subLabel.Text = "👤 " .. localPlayer.DisplayName .. "  •  UID: " .. localPlayer.UserId
  subLabel.TextColor3 = theme.TextMuted
  subLabel.TextSize = 9
  subLabel.TextXAlignment = Enum.TextXAlignment.Center
  subLabel.Parent = tag

  -- Glow orb behind the tag
  local glow = Instance.new("ImageLabel")
  glow.Name = "Glow"
  glow.BackgroundTransparency = 1
  glow.Image = "rbxassetid://5028857084"
  glow.ImageColor3 = theme.AccentNeon
  glow.ImageTransparency = 0.5
  glow.Size = UDim2.new(1, 80, 1, 80)
  glow.Position = UDim2.new(0.5, 0, 0.5, 0)
  glow.AnchorPoint = Vector2.new(0.5, 0.5)
  glow.ZIndex = -1
  glow.Parent = tag

  tweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    ImageTransparency = 0.75,
    Size = UDim2.new(1, 110, 1, 110),
  }):Play()

  return tag
end

function val3:CreateWindow(p13)
  local element2 = p13 or {}
  iterate()

  if val5:FindFirstChild("ServerHopUI") then
    val5:FindFirstChild("ServerHopUI")
  end

  local name = element2.Name or "BEE HUB 🐝🍯 | PREMIUM 👑"
  local subtitle = element2.Subtitle or "By Beehubs"
  local version = element2.Version or "v5 PREMIUM"
  local default = val6.Default
  local element3 = { AnimationSpeed = 0.25, CornerRadius = 10, ElementCornerRadius = 6 }
  local val10 = { Tabs = {}, CurrentTab = nil, Theme = default }

  local create2 = object:Create("ScreenGui", {
    Name = "ServerHopUI", Parent = val5, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, IgnoreGuiInset = true, })

  local nameTag = createNameTag(create2, default)

  local create3 = object:Create("Frame", {
    Name = "MainContainer", Parent = create2, BackgroundColor3 = default.Background, BackgroundTransparency = default.BackgroundTransparency, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 380, 0, 280), AnchorPoint = Vector2.new(0.5, 0.5), ClipsDescendants = true, ZIndex = 3, }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, element3.CornerRadius) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 2, }), object:Create("UIGradient", {
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, default.GradientStart), ColorSequenceKeypoint.new(1, default.GradientEnd), }), Rotation = 135, }), })

  createHoneycombOverlay(create3, default)
  createBeeSwarm(create3, default)

  local create4 = object:Create("CanvasGroup", {
    Name = "CanvasGroup", Parent = create3, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, GroupTransparency = 1, ZIndex = 2, })

  object:Tween(
    create4, { GroupTransparency = 0 }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out
  )

  local create5 = object:Create("Frame", {
    Name = "Header", Parent = create4, BackgroundColor3 = default.Container, BackgroundTransparency = default.ContainerTransparency, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 0, 36), }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, element3.CornerRadius) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1.5, }), })

  object:Create("TextLabel", {
    Name = "Title", Parent = create5, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 2), Size = UDim2.new(0.6, 0, 0, 18), Font = default.Font, Text = name, TextColor3 = default.AccentNeon, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, })

  object:Create("TextLabel", {
    Name = "Subtitle", Parent = create5, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 18), Size = UDim2.new(0, 0.6, 0, 14), Font = default.Font, Text = subtitle .. " | " .. version, TextColor3 = default.TextMuted, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, })

  local create6 = object:Create("TextButton", {
    Name = "Close", Parent = create5, BackgroundColor3 = default.Element, BackgroundTransparency = default.ElementTransparency, Position = UDim2.new(1, -28, 0.5, -11), Size = UDim2.new(0, 22, 0, 22), Font = default.Font, Text = "X", TextColor3 = default.TextDark, TextSize = 11, AutoButtonColor = false, }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, 4) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1, }), })

  local create7 = object:Create("UIStroke", {
    Color = default.AccentNeon, Thickness = 2.5, Transparency = 0, })

  local create8 = object:Create("ImageButton", {
    Name = "ToggleUI", Parent = create2, BackgroundColor3 = default.Background, Position = UDim2.new(0, 20, 0.5, -25), Size = UDim2.new(0, 50, 0, 50), Image = "rbxassetid://72547915216229", Visible = false, ZIndex = 4, }, {
    object:Create("UICorner", { CornerRadius = UDim.new(1, 0) }), object:Create("UIAspectRatioConstraint", { AspectRatio = 1 }), create7, })

  task.spawn(function()
    tweenService:Create(create7, TweenInfo.new(
      0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true
    ), { Color = default.AccentGlow, Thickness = 4 }):Play()
  end)

  task.spawn(function()
    local mainStroke = create3:FindFirstChildOfClass("UIStroke")
    if mainStroke then
      tweenService:Create(mainStroke, TweenInfo.new(
        1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true
      ), { Color = default.AccentGlow, Transparency = 0, Thickness = 3 }):Play()
    end
  end)

  create6.MouseButton1Click:Connect(function()
    object:AnimateClick(create6)
    task.wait(0.08)
    create3.Visible = false
    create8.Visible = true
    nameTag.Visible = false
  end)

  create8.MouseButton1Click:Connect(function()
    object:AnimateClick(create8)
    task.wait(0.08)
    create3.Visible = true
    create8.Visible = false
    nameTag.Visible = true
  end)

  object:MakeDraggable(create3, create5, element3)
  object:MakeDraggable(create8, create8, element3)

  create3:GetPropertyChangedSignal("Position"):Connect(function()
    nameTag.Position = UDim2.new(
      create3.Position.X.Scale,
      create3.Position.X.Offset,
      create3.Position.Y.Scale,
      create3.Position.Y.Offset - 210
    )
  end)

  local create9 = object:Create("Frame", {
    Name = "ContentArea", Parent = create4, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 50), Size = UDim2.new(1, -16, 1, -58), })

  local udim = UDim2.new(0, 100, 1, 0)

  local val11 = {
    object:Create("UICorner", { CornerRadius = UDim.new(0, element3.CornerRadius) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1, }), }

  local create10 = object:Create("ScrollingFrame", {
    Name = "TabList", Parent = object:Create("Frame", {
      Name = "TabContainer", Parent = create9, BackgroundColor3 = default.Container, BackgroundTransparency = default.ContainerTransparency, Size = udim, }, val11), BackgroundTransparency = 1, Position = UDim2.new(0, 4, 0, 4), Size = UDim2.new(1, -8, 1, -8), ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, }, {
    object:Create("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), }), })

  local create11 = object:Create("Frame", {
    Name = "MainContent", Parent = create9, BackgroundColor3 = default.Container, BackgroundTransparency = default.ContainerTransparency, Position = UDim2.new(0, 106, 0, 0), Size = UDim2.new(1, -106, 1, 0), ClipsDescendants = true, }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, element3.CornerRadius) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1, }), })

  function val10:CreateTab(p14)
    local val12 = { Name = p14 }

    local create12 = object:Create("TextButton", {
      Name = p14, Parent = create10, BackgroundColor3 = default.Element, BackgroundTransparency = default.ElementTransparency, Size = UDim2.new(1, 0, 0, 30), Font = default.Font, Text = "🐝 " .. p14, TextColor3 = default.TextDark, TextSize = 11, AutoButtonColor = false, }, {
      object:Create("UICorner", { CornerRadius = UDim.new(0, element3.ElementCornerRadius) }), })

    local create13 = object:Create("ScrollingFrame", {
      Name = p14 .. "Content", Parent = create11, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), ScrollBarThickness = 2, ScrollBarImageColor3 = default.AccentNeon, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, }, {
      object:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), }), })

    create12.MouseButton1Click:Connect(function()
      object:AnimateClick(create12)

      for key5, value5 in pairs(val10.Tabs) do
        value5.Button.BackgroundColor3 = default.Element
        value5.Button.TextColor3 = default.TextDark
        value5.Content.Visible = false
      end

      create12.BackgroundColor3 = default.Accent
      create12.TextColor3 = default.Background
      create13.Visible = true
    end)

    if #val10.Tabs == 0 then
      create12.BackgroundColor3 = default.Accent
      create12.TextColor3 = default.Background
      create13.Visible = true
    end

    val12.Button = create12
    val12.Content = create13

    table.insert(val10.Tabs, val12)

    function val12:CreateButton(text, fn)
      local create14 = object:Create("TextButton", {
        Parent = create13, BackgroundColor3 = default.Element, BackgroundTransparency = default.ElementTransparency, Size = UDim2.new(1, 0, 0, 32), Font = default.Font, Text = text, TextColor3 = default.Text, TextSize = 11, AutoButtonColor = false, }, {
        object:Create("UICorner", { CornerRadius = UDim.new(0, element3.ElementCornerRadius) }), object:Create("UIStroke", {
          Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1, }), })

      create14.MouseEnter:Connect(function()
        object:Tween(create14, { BackgroundColor3 = default.ElementHover }, 0.2)
        local stroke = create14:FindFirstChildOfClass("UIStroke")
        if stroke then
          object:Tween(stroke, { Color = default.AccentNeon, Transparency = 0, Thickness = 2 }, 0.2)
        end
      end)

      create14.MouseLeave:Connect(function()
        object:Tween(create14, { BackgroundColor3 = default.Element }, 0.2)
        local stroke = create14:FindFirstChildOfClass("UIStroke")
        if stroke then
          object:Tween(stroke, { Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1 }, 0.2)
        end
      end)

      create14.MouseButton1Click:Connect(function()
        object:AnimateClick(create14)
        fn(create14)
      end)

      return create14
    end

    function val12:CreateToggle(p15, p16, fn2)
      local val13 = p16 or false

      local create15 = object:Create("TextButton", {
        Parent = create13, BackgroundColor3 = val13 and default.Accent or default.Element, BackgroundTransparency = default.ElementTransparency, Size = UDim2.new(1, 0, 0, 32), Font = default.Font, Text = p15 .. ": " .. (val13 and "ENABLED" or "DISABLED"), TextColor3 = default.Text, TextSize = 10, AutoButtonColor = false, }, {
        object:Create("UICorner", { CornerRadius = UDim.new(0, element3.ElementCornerRadius) }), object:Create("UIStroke", {
          Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1, }), })

      local toggleStroke = create15:FindFirstChildOfClass("UIStroke")
      if val13 and toggleStroke then
        toggleStroke.Color = default.AccentNeon
        toggleStroke.Thickness = 2
        toggleStroke.Transparency = 0
      end

      create15.MouseButton1Click:Connect(function()
        object:AnimateClick(create15)
        val13 = not val13

        create15.BackgroundColor3 = val13 and default.Accent or default.Element
        create15.Text = p15 .. ": " .. (val13 and "ENABLED" or "DISABLED")

        if toggleStroke then
          if val13 then
            toggleStroke.Color = default.AccentNeon
            toggleStroke.Thickness = 2
            toggleStroke.Transparency = 0
          else
            toggleStroke.Color = default.Border
            toggleStroke.Thickness = 1
            toggleStroke.Transparency = default.BorderTransparency
          end
        end

        fn2(val13)
      end)

      return create15
    end

    function val12:CreateInput(placeholderText, p17, fn3)
      local create16 = object:Create("TextBox", {
        Parent = object:Create("Frame", {
          Parent = create13, BackgroundColor3 = default.Element, BackgroundTransparency = default.ElementTransparency, Size = UDim2.new(1, 0, 0, 32), }, {
          object:Create("UICorner", { CornerRadius = UDim.new(0, element3.ElementCornerRadius) }), object:Create("UIStroke", {
            Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1, }), }), BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), Font = default.Font, PlaceholderText = placeholderText, Text = p17 or "", TextColor3 = default.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, })

      create16.FocusLost:Connect(function() fn3(create16.Text) end)
      return create16
    end

    function val12:CreateLabel(text2)
      return (object:Create("TextLabel", {
        Parent = create13, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Font = default.Font, Text = text2, TextColor3 = default.AccentGlow, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, }))
    end

    return val12
  end

  return val10
end

-- 🐝 BEE HUB 🐝🍯 | PREMIUM 👑
local reneBaterboniaWindow = val3:CreateWindow({
  Name = "BEE HUB 🐝🍯 | PREMIUM 👑", Subtitle = "By Beehubs", Version = "v5 PREMIUM", })

local serverHopperTab = reneBaterboniaWindow:CreateTab("Server Hopper")

local label = serverHopperTab:CreateLabel("Current Server: " .. #players:GetPlayers()
  .. " player(s)")

local maxPlayers = val.MaxPlayers or 1

serverHopperTab:CreateInput("Max Target Players", tostring(maxPlayers), function(p18)
  maxPlayers = tonumber(p18) or 1
  val.MaxPlayers = maxPlayers
end)

local autoDetectThreshold = val.AutoDetectThreshold or 3

serverHopperTab:CreateInput("Auto Hop Player Limit", tostring(autoDetectThreshold), function(p19)
  autoDetectThreshold = tonumber(p19) or 3
  val.AutoDetectThreshold = autoDetectThreshold
end)

local val14 = false
local button

local function helper(val15)
  if val14 then
    return
  end

  val14 = true
  local placeId = game.PlaceId
  local jobId = game.JobId
  local label = val15 or button

  if label then
    label.Text = "SEARCHING..."
  end

  task.spawn(function()
    local nextPageCursor = ""

    for i = 1, math.random(5, 12) do
      local val16 = "https://games.roblox.com/val/games/" .. placeId
        .. "/servers/Public?sortOrder=Desc&limit=100"
        .. (nextPageCursor ~= "" and "&cursor=" .. nextPageCursor or "")

      local val17, httpResponse = pcall(function() return game:HttpGet(val16) end)

      if val17 and httpResponse then
        local val18, jsonData = pcall(function() return httpService:JSONDecode(httpResponse) end)

        if val18 and jsonData and jsonData.nextPageCursor then
          nextPageCursor = jsonData.nextPageCursor
        else
          break
        end
      else
        break
      end
    end

    local val19 = "https://games.roblox.com/val/games/" .. placeId
      .. "/servers/Public?sortOrder=Asc&limit=100"
      .. (nextPageCursor ~= "" and "&cursor=" .. nextPageCursor or "")

    local val20, httpResponse2 = pcall(function() return game:HttpGet(val19) end)
    local val21

    if val20 and httpResponse2 then
      local val22, jsonData2 = pcall(function() return httpService:JSONDecode(httpResponse2) end)

      if val22 and jsonData2 and jsonData2.data then
        local val23 = {}

        for index, value6 in ipairs(jsonData2.data) do
          if value6.id ~= jobId and value6.playing <= maxPlayers and value6.playing > 0 then
            table.insert(val23, value6)
          end
        end

        if #val23 > 0 then
          table.sort(val23, function(p21, p22) return p21.playing < p22.playing end)
          val21 = val23[1]
        end
      end
    end

    if val21 then
      if label then
        label.Text = "JOINING (" .. val21.playing .. ")..."
      end

      teleportService:TeleportToPlaceInstance(placeId, val21.id, localPlayer)
    else
      if label then
        label.Text = "RETRYING..."
      end

      task.wait(0.5)
      val14 = false
      helper(label)
    end
  end)
end

button = serverHopperTab:CreateButton("HOP SERVER NOW", function() helper(button) end)
local autoDetectActive

local function helper2()
  local val24 = #players:GetPlayers()
  label.Text = "Current Server: " .. val24 .. " player(s)"

  if autoDetectActive and val24 >= autoDetectThreshold then
    helper(button)
  end
end

autoDetectActive = val.AutoDetectActive

serverHopperTab:CreateToggle("AUTO DETECT HOP", val.AutoDetectActive, function(p23)
  autoDetectActive = p23
  val.AutoDetectActive = p23

  if autoDetectActive then
    helper2()
  end
end)

players.PlayerAdded:Connect(helper2)
players.PlayerRemoving:Connect(helper2)

local autoHopActive = val.AutoHopActive

serverHopperTab:CreateToggle("AUTO HOP", val.AutoHopActive, function(p24)
  autoHopActive = p24
  val.AutoHopActive = p24

  if autoHopActive then
    helper(button)
  end
end)

local autoTab = reneBaterboniaWindow:CreateTab("AUTO")
autoTab:CreateLabel("Automated Controls")

autoTab:CreateToggle("AUTO TURN ON DETECT", val.AutoDetectActive, function(p25)
  autoDetectActive = p25
  val.AutoDetectActive = p25

  if autoDetectActive then
    helper2()
  end
end)

autoTab:CreateButton("FORCE ENABLE DETECT", function()
  autoDetectActive = true
  val.AutoDetectActive = true
  helper2()
end)

local scriptsTab = reneBaterboniaWindow:CreateTab("Scripts")
scriptsTab:CreateLabel("🟢 NO KEY REQUIRED")

scriptsTab:CreateButton("ON hub", function()
  pcall(function()
    loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/davizin713/ONhub/refs/heads/main/script.lua", true
    ))()
  end)
end)

scriptsTab:CreateButton("Horizon", function()
  pcall(function()
    script_key = "Trial"
    loadstring(game:HttpGet("https://api.getpolsec.com/scripts/hosted/6582551b42d21c6b7eb55f1d76d8d50ce53cb35592093d6615b5e83437594dc0.lua"))()
  end)
end)

scriptsTab:CreateButton("Nasi hub PREMIUM version", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/JualNasiRendang/loader/refs/heads/main/main.lua"))()
  end)
end)

scriptsTab:CreateButton("Lennon", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lennonxscripts/lennonhubv2/refs/heads/main/stealaneggv2"))()
  end)
end)

scriptsTab:CreateButton("Miranda", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/stealaeggs"))()
  end)
end)

scriptsTab:CreateButton("Lkz", function()
  pcall(function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/val3/loaders/65bf3459d87ba3ac46350e154b640929.lua"))()
  end)
end)

scriptsTab:CreateButton("Zeroin", function()
  pcall(function() loadstring(game:HttpGet("https://zeroinhub.com/api/script"))() end)
end)

scriptsTab:CreateButton("Decode", function()
  pcall(function()
    loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/ItzYumi/Decode/refs/heads/main/DE%3ACODE.lua", true
    ))()
  end)
end)

scriptsTab:CreateButton("Blxyo hub", function()
  pcall(function()
    loadstring(game:HttpGet("https://flowauth.net/val/loaders/69d3463240384f3a73fbe32c178093a2.lua"))()
  end)
end)

scriptsTab:CreateButton("Hoshi hub", function()
  pcall(function() loadstring(game:HttpGet("https://hoshihub.site/loader.lua"))() end)
end)

scriptsTab:CreateButton("Sena hub", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/senarblx/sena/refs/heads/main/loader"))()
  end)
end)

scriptsTab:CreateButton("Vincetore", function()
  pcall(function()
    script_key = "KEYLESS"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tutorkah104-rgb/Sae/refs/heads/main/Sae.luau"))()
  end)
end)

scriptsTab:CreateButton("Void", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/VoidShell-null/VoidShell-Hub/refs/heads/main/Scripts/StealAnEgg.luau"))()
  end)
end)

scriptsTab:CreateButton("Shader", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua"))()
  end)
end)

scriptsTab:CreateButton("Source Hub", function()
  pcall(function()
     loadstring(game:HttpGet("https://pastebin.com/raw/d0zBUM6r"))()
  end)
end)

scriptsTab:CreateButton("OUROBOROS", function()
  pcall(function()
     loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/Ouroboros/main/loader.lua"))()
  end)
end)

scriptsTab:CreateButton("TSUO", function()
  pcall(function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/Tsuo7/TsuoHub/main/stealanegg"))()
  end)
end)

scriptsTab:CreateButton("ANIMATION PACK", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/arjhaysaver-byte/BEE-SCRIPT-ANIMATION-PACK/refs/heads/main/bee_hub.lua"))()
  end)
end)

scriptsTab:CreateLabel("🔑 KEY REQUIRED")

scriptsTab:CreateButton("Bf", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hanniii1/Loader/refs/heads/main/BFLoader.lua"))()
  end)
end)

scriptsTab:CreateButton("Fyy", function()
  pcall(function() loadstring(game:HttpGet("https://FyyCommunity.com"))() end)
end)

scriptsTab:CreateButton("Speed hub", function()
  pcall(function()
    loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true
    ))()
  end)
end)

local ownerTab = reneBaterboniaWindow:CreateTab("Owner")
ownerTab:CreateLabel("Social Links")

local function helper3(val25, label2, text3)
  if setclipboard then
    setclipboard(val25)
  elseif syn and syn.write_clipboard then
    syn.write_clipboard(val25)
  end

  label2.Text = "COPIED!"
  task.wait(1.5)
  label2.Text = text3
end

ownerTab:CreateButton("Tiktok - Its Bee", function(p28)
  helper3("Its Bee", p28, "Tiktok - Its Bee")
end)

ownerTab:CreateButton("Discord", function(p29)
  helper3("https://discord.gg/M9ZnxTafE", p29, "Discord")
end)

ownerTab:CreateButton("Promoter: Tawewie", function(p30)
  helper3("Tawewie", p30, "Promoter: Tawewie")
end)

ownerTab:CreateButton("Promoter - None", function(p31)
  helper3("None", p31, "Promoter - None")
end)

local configTab = reneBaterboniaWindow:CreateTab("Config")
configTab:CreateLabel("Configuration Manager")

configTab:CreateButton("SAVE CONFIG", function(p32)
  p32.Text = "SAVED!"
  task.wait(1)
  p32.Text = p32.Text
end)

configTab:CreateToggle("AUTO-SAVE ON CHANGE", val.AutoSave or false, function(autoSave)
  val.AutoSave = autoSave
end)

task.spawn(function()
  task.wait(1.5)

  if val.AutoDetectActive then
    autoDetectActive = true
    helper2()
  end

  if val.AutoHopActive then
    autoHopActive = true
    helper(button)
  end
end)