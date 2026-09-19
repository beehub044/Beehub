local teleportService = game:GetService("TeleportService")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")
local lighting = game:GetService("Lighting")
local soundService = game:GetService("SoundService")
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
  sound.SoundId = "rbxassetid://80378206876530"
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

-- 🐝 BEE HUB NEON YELLOW + HONEY YELLOW THEME
local val6 = {
  Default = {
    Background = Color3.fromRGB(30, 22, 0),
    BackgroundTransparency = 0.05,
    Container = Color3.fromRGB(48, 36, 4),
    ContainerTransparency = 0.1,
    Element = Color3.fromRGB(75, 58, 8),
    ElementTransparency = 0.15,
    ElementHover = Color3.fromRGB(130, 100, 15),
    Accent = Color3.fromRGB(255, 255, 0),
    AccentDark = Color3.fromRGB(255, 215, 0),
    AccentGlow = Color3.fromRGB(255, 255, 120),
    Text = Color3.fromRGB(255, 255, 220),
    TextDark = Color3.fromRGB(255, 240, 160),
    TextMuted = Color3.fromRGB(200, 175, 90),
    Border = Color3.fromRGB(255, 235, 59),
    BorderTransparency = 0.25,
    GradientStart = Color3.fromRGB(70, 55, 5),
    GradientEnd = Color3.fromRGB(25, 18, 0),
    Font = Enum.Font.GothamBold,
  },
}

local BEE_IMAGE = "rbxassetid://126492054871369"

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

function val3:CreateWindow(p13)
  local element2 = p13 or {}
  iterate()

  if val5:FindFirstChild("ServerHopUI") then
    val5:FindFirstChild("ServerHopUI")
  end

  local name = element2.Name or "BEE HUB 🐝🍯 | PREMIUM 👑 | AVATAR CHANGER!"
  local subtitle = element2.Subtitle or "By Beehubs"
  local version = element2.Version or "v5"
  local default = val6.Default
  local element3 = { AnimationSpeed = 0.25, CornerRadius = 10, ElementCornerRadius = 6 }
  local val10 = { Tabs = {}, CurrentTab = nil, Theme = default }

  local create2 = object:Create("ScreenGui", {
    Name = "ServerHopUI", Parent = val5, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, IgnoreGuiInset = true, })

  -- ⚡ Neon glow behind main frame
  local glow = object:Create("ImageLabel", {
    Name = "NeonGlow",
    Parent = create2,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 560, 0, 440),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromRGB(255, 255, 0),
    ImageTransparency = 0.6,
    ZIndex = 0,
  })

  tweenService:Create(glow, TweenInfo.new(
    1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true
  ), {
    ImageTransparency = 0.3,
    Size = UDim2.new(0, 580, 0, 460),
  }):Play()

  -- ✅ BIGGER MAIN FRAME (520x400)
  local create3 = object:Create("Frame", {
    Name = "MainContainer", Parent = create2, BackgroundColor3 = default.Background, BackgroundTransparency = default.BackgroundTransparency, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 520, 0, 400), AnchorPoint = Vector2.new(0.5, 0.5), ClipsDescendants = true, }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, element3.CornerRadius) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 2, }), object:Create("UIGradient", {
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, default.GradientStart), ColorSequenceKeypoint.new(1, default.GradientEnd), }), Rotation = 135, }), })

  -- 🖼️ Background Watermark
  object:Create("ImageLabel", {
    Name = "Watermark",
    Parent = create3,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0.8, 0, 0.8, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Image = BEE_IMAGE,
    ImageTransparency = 0.85,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 0,
  })

  -- 🖼️ Big Bee Logo above the window
  local bigLogo = object:Create("ImageLabel", {
    Name = "BeeLogo",
    Parent = create3,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0, -60),
    Size = UDim2.new(0, 100, 0, 100),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Image = BEE_IMAGE,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 5,
  })

  -- ⚡ Big logo pulsing
  tweenService:Create(bigLogo, TweenInfo.new(
    1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true
  ), {
    Size = UDim2.new(0, 110, 0, 110),
  }):Play()

  local create4 = object:Create("CanvasGroup", {
    Name = "CanvasGroup", Parent = create3, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, GroupTransparency = 1, })

  object:Tween(
    create4, { GroupTransparency = 0 }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out
  )

  -- ✅ TALLER HEADER (44)
  local create5 = object:Create("Frame", {
    Name = "Header", Parent = create4, BackgroundColor3 = default.Container, BackgroundTransparency = default.ContainerTransparency, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 0, 44), }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, element3.CornerRadius) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1.5, }), })

  -- 🖼️ Header Logo
  object:Create("ImageLabel", {
    Name = "Logo",
    Parent = create5,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0.5, -14),
    Size = UDim2.new(0, 28, 0, 28),
    Image = BEE_IMAGE,
    ScaleType = Enum.ScaleType.Fit,
  })

  object:Create("TextLabel", {
    Name = "Title", Parent = create5, BackgroundTransparency = 1, Position = UDim2.new(0, 44, 0, 4), Size = UDim2.new(0.6, 0, 0, 20), Font = default.Font, Text = name, TextColor3 = default.Accent, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, })

  object:Create("TextLabel", {
    Name = "Subtitle", Parent = create5, BackgroundTransparency = 1, Position = UDim2.new(0, 44, 0, 24), Size = UDim2.new(0, 0.6, 0, 14), Font = default.Font, Text = subtitle .. " | " .. version, TextColor3 = default.TextMuted, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, })

  local create6 = object:Create("TextButton", {
    Name = "Close", Parent = create5, BackgroundColor3 = default.Element, BackgroundTransparency = default.ElementTransparency, Position = UDim2.new(1, -32, 0.5, -14), Size = UDim2.new(0, 26, 0, 26), Font = default.Font, Text = "X", TextColor3 = default.Accent, TextSize = 12, AutoButtonColor = false, }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, 4) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1, }), })

  local create7 = object:Create("UIStroke", {
    Color = default.Accent, Thickness = 2, Transparency = 0, })

  -- 🖼️ Toggle Button Icon
  local create8 = object:Create("ImageButton", {
    Name = "ToggleUI", Parent = create2, BackgroundColor3 = default.Background, BackgroundTransparency = 0.2, Position = UDim2.new(0, 20, 0.5, -25), Size = UDim2.new(0, 50, 0, 50), Image = BEE_IMAGE, Visible = false, }, {
    object:Create("UICorner", { CornerRadius = UDim.new(1, 0) }), object:Create("UIAspectRatioConstraint", { AspectRatio = 1 }), create7, })

  -- ⚡ Stronger neon glow pulse
  task.spawn(function()
    tweenService:Create(create7, TweenInfo.new(
      0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true
    ), {
      Color = Color3.fromRGB(255, 255, 0),
      Thickness = 3.5,
      Transparency = 0
    }):Play()
  end)

  create6.MouseButton1Click:Connect(function()
    object:AnimateClick(create6)
    task.wait(0.08)
    create3.Visible = false
    glow.Visible = false
    create8.Visible = true
  end)

  create8.MouseButton1Click:Connect(function()
    object:AnimateClick(create8)
    task.wait(0.08)
    create3.Visible = true
    glow.Visible = true
    create8.Visible = false
  end)

  object:MakeDraggable(create3, create5, element3)
  object:MakeDraggable(create8, create8, element3)

  local create9 = object:Create("Frame", {
    Name = "ContentArea", Parent = create4, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 60), Size = UDim2.new(1, -16, 1, -68), })

  local udim = UDim2.new(0, 130, 1, 0)

  local val11 = {
    object:Create("UICorner", { CornerRadius = UDim.new(0, element3.CornerRadius) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1.5, }), }

  local create10 = object:Create("ScrollingFrame", {
    Name = "TabList", Parent = object:Create("Frame", {
      Name = "TabContainer", Parent = create9, BackgroundColor3 = default.Container, BackgroundTransparency = default.ContainerTransparency, Size = udim, }, val11), BackgroundTransparency = 1, Position = UDim2.new(0, 4, 0, 4), Size = UDim2.new(1, -8, 1, -8), ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, }, {
    object:Create("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), }), })

  local create11 = object:Create("Frame", {
    Name = "MainContent", Parent = create9, BackgroundColor3 = default.Container, BackgroundTransparency = default.ContainerTransparency, Position = UDim2.new(0, 136, 0, 0), Size = UDim2.new(1, -136, 1, 0), ClipsDescendants = true, }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, element3.CornerRadius) }), object:Create("UIStroke", {
      Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1.5, }), })

  function val10:CreateTab(p14)
    local val12 = { Name = p14 }

    local create12 = object:Create("TextButton", {
      Name = p14, Parent = create10, BackgroundColor3 = default.Element, BackgroundTransparency = default.ElementTransparency, Size = UDim2.new(1, 0, 0, 32), Font = default.Font, Text = p14, TextColor3 = default.TextDark, TextSize = 11, AutoButtonColor = false, }, {
      object:Create("UICorner", { CornerRadius = UDim.new(0, element3.ElementCornerRadius) }), })

    local create13 = object:Create("ScrollingFrame", {
      Name = p14 .. "Content", Parent = create11, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), ScrollBarThickness = 2, ScrollBarImageColor3 = default.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, }, {
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
      end)

      create14.MouseLeave:Connect(function()
        object:Tween(create14, { BackgroundColor3 = default.Element }, 0.2)
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
        Parent = create13, BackgroundColor3 = val13 and default.Accent or default.Element, BackgroundTransparency = default.ElementTransparency, Size = UDim2.new(1, 0, 0, 32), Font = default.Font, Text = p15 .. ": " .. (val13 and "ENABLED" or "DISABLED"), TextColor3 = val13 and default.Background or default.Text, TextSize = 10, AutoButtonColor = false, }, {
        object:Create("UICorner", { CornerRadius = UDim.new(0, element3.ElementCornerRadius) }), object:Create("UIStroke", {
          Color = default.Border, Transparency = default.BorderTransparency, Thickness = 1, }), })

      create15.MouseButton1Click:Connect(function()
        object:AnimateClick(create15)
        val13 = not val13

        create15.BackgroundColor3 = val13 and default.Accent or default.Element
        create15.TextColor3 = val13 and default.Background or default.Text
        create15.Text = p15 .. ": " .. (val13 and "ENABLED" or "DISABLED")

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

-- 🐝 BEE HUB 🐝🍯
local reneBaterboniaWindow = val3:CreateWindow({
  Name = "BEE HUB 🐝🍯 | PREMIUM 👑", Subtitle = "By Beehubs | v25.2", Version = "v5", })

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

scriptsTab:CreateButton("🔛ON hub🔛", function()
  pcall(function()
    loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/davizin713/ONhub/refs/heads/main/script.lua", true
    ))()
  end)
end)

scriptsTab:CreateButton("🌀Horizon🌀", function()
  pcall(function()
    script_key = "Trial"
    loadstring(game:HttpGet("https://api.getpolsec.com/scripts/hosted/6582551b42d21c6b7eb55f1d76d8d50ce53cb35592093d6615b5e83437594dc0.lua"))()
  end)
end)

scriptsTab:CreateButton("🐟Nasi hub🐟", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/JualNasiRendang/loader/refs/heads/main/main.lua"))()
  end)
end)

scriptsTab:CreateButton("🍋Lennon🍋", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lennonxscripts/lennonhubv2/refs/heads/main/stealaneggv2"))()
  end)
end)

scriptsTab:CreateButton("🔻Miranda🔻", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/stealaeggs"))()
  end)
end)

scriptsTab:CreateButton("🔲 Lkz 🔲", function()
  pcall(function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/65bf3459d87ba3ac46350e154b640929.lua"))()
  end)
end)

scriptsTab:CreateButton("0️⃣ Zeroin 0️⃣", function()
  pcall(function() loadstring(game:HttpGet("https://zeroinhub.com/api/script"))() end)
end)

scriptsTab:CreateButton("🆔 Decode 🆔", function()
  pcall(function()
    loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/ItzYumi/Decode/refs/heads/main/DE%3ACODE.lua", true
    ))()
  end)
end)

scriptsTab:CreateButton("⬛ Blxyo hub ⬛", function()
  pcall(function()
    loadstring(game:HttpGet("https://flowauth.net/val/loaders/69d3463240384f3a73fbe32c178093a2.lua"))()
  end)
end)

scriptsTab:CreateButton("🇯🇵 Hoshi hub 🇯🇵", function()
  pcall(function() loadstring(game:HttpGet("https://hoshihub.site/loader.lua"))() end)
end)

scriptsTab:CreateButton("👾 Sena hub 👾", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/senarblx/sena/refs/heads/main/loader"))()
  end)
end)

scriptsTab:CreateButton("🎉 Vincetore 🎉", function()
  pcall(function()
    script_key = "KEYLESS"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tutorkah104-rgb/Sae/refs/heads/main/Sae.luau"))()
  end)
end)

scriptsTab:CreateButton("🕳️ Void 🕳️", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/VoidShell-null/VoidShell-Hub/refs/heads/main/Scripts/StealAnEgg.luau"))()
  end)
end)

scriptsTab:CreateButton("🌄 SHADER 🌄", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua"))()
  end)
end)

scriptsTab:CreateButton("👑 ANIMATION PACK 👑", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/arjhaysaver-byte/BEE-SCRIPT-ANIMATION-PACK/refs/heads/main/bee_hub.lua"))()
  end)
end)

scriptsTab:CreateButton("🌶️ CHILLI HUB 🌶️", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))()
  end)
end)

scriptsTab:CreateButton("🥶 JOSHBNS HUB 🥶", function()
  pcall(function()
    loadstring(game:HttpGet("https://flowauth.net/v1/loaders/e890aad1c32cda0a0e14d000aa06dd97.lua"))()
  end)
end)

scriptsTab:CreateButton("👑AVATAR CHANGER BEE👑", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/beehub044/Beehub/refs/heads/main/deepseek_lua_20260918_91d104%20(1).lua"))()
  end)
end)

scriptsTab:CreateButton("💨ANIMATION ADJUSTABLE💨", function()
  pcall(function()
    loadstring(game:HttpGet("https://api.rubis.app/v2/scrap/PwFrcMysMOIJuWAQ/raw"))()
  end)
end)

scriptsTab:CreateButton("🥬FAKE ADMIN🥬", function()
  pcall(function()
    loadstring(game:HttpGet("https://flowauth.net/v1/loaders/e890aad1c32cda0a0e14d000aa06dd97.lua"))()
  end)
end)

scriptsTab:CreateButton("🔄!SERVER HOP!🔄", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/desyble/serverprivate/refs/heads/main/loader.luau",true))()
  end)
end)

scriptsTab:CreateLabel("🔑 KEY REQUIRED")

scriptsTab:CreateButton("🟠 BIGFROOT 🟠", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hanniii1/Loader/refs/heads/main/BFLoader.lua"))()
  end)
end)

scriptsTab:CreateButton("🟣 FYY 🟣", function()
  pcall(function() loadstring(game:HttpGet("https://FyyCommunity.com"))() end)
end)

scriptsTab:CreateButton("🔴 Speed hub 🔴", function()
  pcall(function()
    loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true
    ))()
  end)
end)

-- 🔪 MM2 TAB (12 scripts total)
local mm2Tab = reneBaterboniaWindow:CreateTab("MM2")
mm2Tab:CreateLabel("🔪 Murder Mystery 2 Scripts")

mm2Tab:CreateButton("Vant Hub", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ilickyourmum21-cmd/my-mm2-script/refs/heads/main/main.lua"))()
  end)
end)

mm2Tab:CreateButton("Heatragram Hub", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/OlejenkaMolejenka1337/script2/refs/heads/main/scriptOBF.lua"))()
  end)
end)

mm2Tab:CreateButton("MOZQL HUB", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/snxpzscripts/mm2/refs/heads/main/gumba.lua"))()
  end)
end)

mm2Tab:CreateButton("Kagu Hub", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Kaguya11/KaguHubRework/main/Scripts/Loader.lua"))()
  end)
end)

mm2Tab:CreateLabel("⚡ More MM2 Scripts")

mm2Tab:CreateButton("Waguri", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Waguriiiii/Murder-mystery-2/refs/heads/main/Waguri.lua"))()
  end)
end)

mm2Tab:CreateButton("Flora", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WymsHub/FloraHub/refs/heads/main/MurderMystery2"))()
  end)
end)

mm2Tab:CreateButton("Valt", function()
  pcall(function()
    loadstring(game:HttpGet("https://valtscripts.xyz/mm2"))()
  end)
end)

mm2Tab:CreateButton("Riftware", function()
  pcall(function()
    loadstring(game:HttpGet("https://riftware.wtf/", true))()
  end)
end)

mm2Tab:CreateButton("Onyx", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/zyntrix20/OnyxHub/refs/heads/main/Loader"))()
  end)
end)

mm2Tab:CreateButton("Overdrive", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/yxkal999YT/overdrivehub.xyz/refs/heads/main/auth.lua", true))()
  end)
end)

mm2Tab:CreateButton("Ruthless Hub", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ValuesScripts/ValueScript/refs/heads/main/RuthlessHub"))()
  end)
end)

mm2Tab:CreateButton("Thunder Hub", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kittenpalms/mm2/refs/heads/main/script"))()
  end)
end)

mm2Tab:CreateLabel("⚠️ Use alt account")

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

ownerTab:CreateButton("Tiktok - PC DEV BEE 🐝", function(p28)
  helper3("renehubs.rblx", p28, "Tiktok - renehubs.rblx")
end)

ownerTab:CreateButton("Discord", function(p29)
  helper3("https://discord.gg/XA74SmVHn", p29, "Discord")
end)

ownerTab:CreateButton("Promoter: Tawewie", function(p30)
  helper3("Tawewie", p30, "Promoter: Tawewie")
end)

ownerTab:CreateButton("Promoter - Renzzz", function(p31)
  helper3("Renzzz", p31, "Promoter - Renzzz")
end)

ownerTab:CreateButton("Promoter - Vhen", function(p32)
  helper3("Vhen", p32, "Promoter - Vhen")
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