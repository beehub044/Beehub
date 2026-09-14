local teleportService = game:GetService("TeleportService")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")
local lighting = game:GetService("Lighting")
local soundService = game:GetService("SoundService")
local localPlayer = players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
--  CONFIG
-- ═══════════════════════════════════════════════════════════
local val = {
  AutoDetectActive = false,
  AutoHopActive = false,
  MaxPlayers = 1,
  AutoDetectThreshold = 3,
  AutoSave = true,
}

local function safeCall()
  if isfile and readfile and isfile("AxionAutoDetectConfig.json") then
    local ok, decoded = pcall(function()
      return httpService:JSONDecode(readfile("AxionAutoDetectConfig.json"))
    end)
    if ok and type(decoded) == "table" then
      for key, value in pairs(decoded) do
        val[key] = value
      end
    end
  end
end

safeCall()

local function iterate()
  for _, child in pairs(lighting:GetChildren()) do
    if child:IsA("BlurEffect") and child.Name:find("Axion") then
      child:Destroy()
    end
  end
end

local val3 = {}

local function safeCall2()
  local ok, result = pcall(function()
    if gethui then return gethui() end
    if syn and syn.protect_gui then
      local sg = Instance.new("ScreenGui")
      syn.protect_gui(sg)
      return coreGui
    end
    return coreGui
  end)
  return ok and result or coreGui
end

local val5 = safeCall2()

-- ═══════════════════════════════════════════════════════════
--  🎵 SOUND HELPERS
-- ═══════════════════════════════════════════════════════════
local SOUND_HOVER = "rbxassetid://9120386436"
local SOUND_CLICK = "rbxassetid://9120386000"
local SOUND_OPEN  = "rbxassetid://106806057419587"

local beeSounds = {}

function beeSounds:Play(soundId, volume, pitch)
  task.spawn(function()
    local s = Instance.new("Sound")
    s.SoundId = soundId
    s.Volume = volume or 0.3
    s.PlaybackSpeed = pitch or 1
    s.Parent = soundService
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
    task.delay(3, function()
      if s and s.Parent then s:Destroy() end
    end)
  end)
end

function beeSounds:Hover() beeSounds:Play(SOUND_HOVER, 0.15, 1 + math.random() * 0.15) end
function beeSounds:Click() beeSounds:Play(SOUND_CLICK, 0.25, 1) end
function beeSounds:Open()  beeSounds:Play(SOUND_OPEN,  0.5,  1) end
function beeSounds:Close() beeSounds:Play(SOUND_CLICK, 0.3,  0.7) end

-- ═══════════════════════════════════════════════════════════
--  🎨 BEE THEME PALETTE
-- ═══════════════════════════════════════════════════════════
local val6 = {
  Default = {
    Background = Color3.fromRGB(38, 28, 3),
    BackgroundTransparency = 0.05,
    Container = Color3.fromRGB(55, 42, 6),
    ContainerTransparency = 0.1,
    Element = Color3.fromRGB(92, 72, 10),
    ElementTransparency = 0.15,
    ElementHover = Color3.fromRGB(140, 108, 18),
    Accent = Color3.fromRGB(255, 215, 45),
    AccentDark = Color3.fromRGB(200, 155, 15),
    AccentGlow = Color3.fromRGB(255, 240, 140),
    HoneyDrip = Color3.fromRGB(255, 185, 25),
    CombLine = Color3.fromRGB(255, 210, 40),
    Text = Color3.fromRGB(255, 250, 220),
    TextDark = Color3.fromRGB(235, 215, 155),
    TextMuted = Color3.fromRGB(180, 155, 95),
    Border = Color3.fromRGB(220, 175, 45),
    BorderTransparency = 0.35,
    GradientStart = Color3.fromRGB(75, 58, 10),
    GradientEnd = Color3.fromRGB(28, 20, 3),
    Font = Enum.Font.Gotham,
  },
}

-- ═══════════════════════════════════════════════════════════
--  🐝 BEE DECORATIONS
-- ═══════════════════════════════════════════════════════════
local beeDecor = {}

function beeDecor:MakeHoneycomb(parent, size, color, transparency)
  local frame = Instance.new("Frame")
  frame.Name = "HoneycombPattern"
  frame.Size = UDim2.new(1, 0, 1, 0)
  frame.BackgroundTransparency = 1
  frame.ZIndex = 0
  frame.Parent = parent

  local hexSize = size or 30
  local cols = math.ceil(380 / hexSize) + 2
  local rows = math.ceil(280 / hexSize) + 2

  for r = 0, rows do
    for c = 0, cols do
      local hex = Instance.new("Frame")
      hex.Size = UDim2.new(0, hexSize - 4, 0, hexSize - 4)
      hex.Position = UDim2.new(0, c * hexSize + (r % 2 == 0 and 0 or hexSize / 2), 0, r * (hexSize * 0.86))
      hex.BackgroundColor3 = color or Color3.fromRGB(255, 210, 40)
      hex.BackgroundTransparency = transparency or 0.92
      hex.BorderSizePixel = 0
      hex.ZIndex = 0
      hex.Parent = frame

      local corner = Instance.new("UICorner")
      corner.CornerRadius = UDim.new(0.5, 0)
      corner.Parent = hex

      local overlay = Instance.new("Frame")
      overlay.Size = UDim2.new(1, 0, 1, 0)
      overlay.BackgroundColor3 = color or Color3.fromRGB(255, 210, 40)
      overlay.BackgroundTransparency = transparency or 0.92
      overlay.BorderSizePixel = 0
      overlay.Rotation = 45
      overlay.ZIndex = 0
      overlay.Parent = hex

      local oCorner = Instance.new("UICorner")
      oCorner.CornerRadius = UDim.new(0.15, 0)
      oCorner.Parent = overlay
    end
  end

  return frame
end

function beeDecor:AttachOrbitingBee(screenGui, windowFrame)
  local bee = Instance.new("TextLabel")
  bee.Name = "OrbitingBee"
  bee.Size = UDim2.new(0, 22, 0, 22)
  bee.BackgroundTransparency = 1
  bee.Text = "🐝"
  bee.TextSize = 18
  bee.Font = Enum.Font.GothamBold
  bee.TextColor3 = Color3.fromRGB(255, 235, 120)
  bee.ZIndex = 50
  bee.Parent = screenGui

  local angle = 0
  local radiusX = 220
  local radiusY = 160

  task.spawn(function()
    while bee.Parent and windowFrame.Parent do
      angle = angle + 0.02
      local cx = windowFrame.AbsolutePosition.X + windowFrame.AbsoluteSize.X / 2
      local cy = windowFrame.AbsolutePosition.Y + windowFrame.AbsoluteSize.Y / 2
      local x = cx + math.cos(angle) * radiusX
      local y = cy + math.sin(angle) * radiusY
      bee.Position = UDim2.new(0, x - 11, 0, y - 11)
      bee.Rotation = math.sin(angle * 4) * 12
      task.wait(0.016)
    end
  end)

  return bee
end

function beeDecor:AddHoneyDrip(button)
  local drip = Instance.new("Frame")
  drip.Name = "HoneyDrip"
  drip.BackgroundColor3 = Color3.fromRGB(255, 190, 30)
  drip.BackgroundTransparency = 0.2
  drip.BorderSizePixel = 0
  drip.Size = UDim2.new(1, 0, 0, 0)
  drip.Position = UDim2.new(0, 0, 1, 0)
  drip.ZIndex = 2
  drip.ClipsDescendants = true
  drip.Parent = button

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 6)
  corner.Parent = drip

  button.MouseEnter:Connect(function()
    tweenService:Create(drip, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
      Size = UDim2.new(1, 0, 0, 4),
      BackgroundTransparency = 0.1,
    }):Play()
  end)

  button.MouseLeave:Connect(function()
    tweenService:Create(drip, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
      Size = UDim2.new(1, 0, 0, 0),
      BackgroundTransparency = 0.2,
    }):Play()
  end)

  return drip
end

function beeDecor:AddHoneyKnob(toggleButton, initialState)
  local knobHolder = Instance.new("Frame")
  knobHolder.Name = "KnobHolder"
  knobHolder.BackgroundTransparency = 1
  knobHolder.Size = UDim2.new(0, 44, 1, 0)
  knobHolder.Position = initialState and UDim2.new(1, -50, 0, 0) or UDim2.new(0, 6, 0, 0)
  knobHolder.ZIndex = 3
  knobHolder.Parent = toggleButton

  local drop = Instance.new("Frame")
  drop.Name = "HoneyDrop"
  drop.Size = UDim2.new(0, 22, 0, 22)
  drop.Position = UDim2.new(0, 0, 0.5, -11)
  drop.BackgroundColor3 = initialState and Color3.fromRGB(255, 215, 45) or Color3.fromRGB(120, 95, 25)
  drop.BorderSizePixel = 0
  drop.ZIndex = 4
  drop.Parent = knobHolder

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0.5, 0)
  corner.Parent = drop

  local stroke = Instance.new("UIStroke")
  stroke.Color = Color3.fromRGB(255, 240, 160)
  stroke.Thickness = 1.5
  stroke.Transparency = initialState and 0.1 or 0.5
  stroke.Parent = drop

  local shine = Instance.new("Frame")
  shine.Size = UDim2.new(0.4, 0, 0.4, 0)
  shine.Position = UDim2.new(0.15, 0, 0.15, 0)
  shine.BackgroundColor3 = Color3.fromRGB(255, 255, 220)
  shine.BackgroundTransparency = 0.4
  shine.BorderSizePixel = 0
  shine.ZIndex = 5
  shine.Parent = drop

  local shineCorner = Instance.new("UICorner")
  shineCorner.CornerRadius = UDim.new(1, 0)
  shineCorner.Parent = shine

  return {
    Holder = knobHolder,
    Drop = drop,
    Stroke = stroke,
    SetState = function(isOn)
      tweenService:Create(knobHolder, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = isOn and UDim2.new(1, -50, 0, 0) or UDim2.new(0, 6, 0, 0),
      }):Play()
      tweenService:Create(drop, TweenInfo.new(0.25), {
        BackgroundColor3 = isOn and Color3.fromRGB(255, 215, 45) or Color3.fromRGB(120, 95, 25),
        Size = isOn and UDim2.new(0, 24, 0, 24) or UDim2.new(0, 22, 0, 22),
      }):Play()
      tweenService:Create(stroke, TweenInfo.new(0.25), {
        Transparency = isOn and 0.1 or 0.5,
      }):Play()
    end,
  }
end

function beeDecor:HoneyExit(windowFrame, screenGui, onComplete)
  local dripContainer = Instance.new("Frame")
  dripContainer.Name = "HoneyExitDrip"
  dripContainer.BackgroundTransparency = 1
  dripContainer.Size = UDim2.new(1, 0, 1, 0)
  dripContainer.ZIndex = 100
  dripContainer.ClipsDescendants = true
  dripContainer.Parent = windowFrame

  for i = 1, 6 do
    local drip = Instance.new("Frame")
    drip.BackgroundColor3 = Color3.fromRGB(255, 185, 25)
    drip.BackgroundTransparency = 0
    drip.BorderSizePixel = 0
    drip.Size = UDim2.new(0, math.random(10, 22), 0, 0)
    drip.Position = UDim2.new((i - 1) / 6 + math.random() * 0.05, 0, 0, 0)
    drip.ZIndex = 101
    drip.Parent = dripContainer

    local dripCorner = Instance.new("UICorner")
    dripCorner.CornerRadius = UDim.new(0.5, 0)
    dripCorner.Parent = drip

    task.delay(i * 0.05, function()
      tweenService:Create(drip, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, drip.Size.X.Offset, 0, windowFrame.AbsoluteSize.Y),
      }):Play()
    end)
  end

  local startPos = windowFrame.Position
  for i = 1, 4 do
    tweenService:Create(windowFrame, TweenInfo.new(0.05), {
      Position = startPos + UDim2.new(0, math.random(-4, 4), 0, math.random(-4, 4)),
    }):Play()
    task.wait(0.05)
  end
  tweenService:Create(windowFrame, TweenInfo.new(0.05), { Position = startPos }):Play()

  task.wait(0.3)
  tweenService:Create(windowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
    Size = UDim2.new(0, 0, 0, 0),
  }):Play()

  for _, d in pairs(windowFrame:GetDescendants()) do
    if d:IsA("GuiObject") and d ~= dripContainer and d.Name ~= "HoneyExitDrip" then
      pcall(function()
        tweenService:Create(d, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
      end)
    end
  end

  task.wait(0.7)
  if onComplete then onComplete() end
end

-- ═══════════════════════════════════════════════════════════
--  🛠 CORE UI HELPERS
-- ═══════════════════════════════════════════════════════════
local object = {}

function object:Create(class, props, children)
  local instance = Instance.new(class)
  for k, v in pairs(props or {}) do
    if k ~= "Parent" then instance[k] = v end
  end
  for _, child in pairs(children or {}) do
    child.Parent = instance
  end
  if props and props.Parent then
    instance.Parent = props.Parent
  end
  return instance
end

function object:Tween(target, props, dur, style, dir)
  if not target then return end
  local t = tweenService:Create(
    target,
    TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
    props
  )
  t:Play()
  return t
end

function object:AnimateClick(target)
  if not target then return end
  local size = target.Size
  object:Tween(target, {
    Size = UDim2.new(size.X.Scale, size.X.Offset - 4, size.Y.Scale, size.Y.Offset - 4),
  }, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
  task.delay(0.08, function()
    object:Tween(target, { Size = size }, 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
  end)
end

function object:MakeDraggable(frame, handle, config)
  local dragging, dragStart, startPos

  handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      dragging = true
      dragStart = input.Position
      startPos = frame.Position
      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          dragging = false
        end
      end)
    end
  end)

  local activeInput
  handle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
      or input.UserInputType == Enum.UserInputType.Touch then
      activeInput = input
    end
  end)

  userInputService.InputChanged:Connect(function(input)
    if input == activeInput and dragging then
      local delta = input.Position - dragStart
      object:Tween(frame, {
        Position = UDim2.new(
          startPos.X.Scale,
          startPos.X.Offset + delta.X,
          startPos.Y.Scale,
          startPos.Y.Offset + delta.Y
        ),
      }, (config.AnimationSpeed or 0.25) * 0.5)
    end
  end)
end

-- ═══════════════════════════════════════════════════════════
--  🪟 WINDOW CREATOR
-- ═══════════════════════════════════════════════════════════
function val3:CreateWindow(opts)
  local opt = opts or {}
  iterate()

  local existing = val5:FindFirstChild("ServerHopUI")
  if existing then existing:Destroy() end

  local name = opt.Name or "BEE HUB 🐝🍯 | PREMIUM 👑"
  local subtitle = opt.Subtitle or "By Beehubs"
  local version = opt.Version or "v5 PREMIUM"
  local default = val6.Default
  local cfg = { AnimationSpeed = 0.25, CornerRadius = 10, ElementCornerRadius = 6 }
  local win = { Tabs = {}, CurrentTab = nil, Theme = default }

  local screenGui = object:Create("ScreenGui", {
    Name = "ServerHopUI",
    Parent = val5,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
  })

  local main = object:Create("Frame", {
    Name = "MainContainer",
    Parent = screenGui,
    BackgroundColor3 = default.Background,
    BackgroundTransparency = default.BackgroundTransparency,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 380, 0, 280),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ClipsDescendants = true,
  }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius) }),
    object:Create("UIStroke", {
      Color = default.Border,
      Transparency = default.BorderTransparency,
      Thickness = 1.5,
    }),
    object:Create("UIGradient", {
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, default.GradientStart),
        ColorSequenceKeypoint.new(1, default.GradientEnd),
      }),
      Rotation = 135,
    }),
  })

  -- 🐝 Honeycomb background
  local combPattern = beeDecor:MakeHoneycomb(main, 30, default.CombLine, 0.94)
  combPattern.ZIndex = 0

  -- 🐝 Honey glow behind header
  local honeyGlow = object:Create("Frame", {
    Name = "HoneyGlow",
    Parent = main,
    BackgroundColor3 = default.AccentGlow,
    BackgroundTransparency = 0.85,
    Size = UDim2.new(1, 0, 0, 60),
    Position = UDim2.new(0, 0, 0, 0),
    ZIndex = 0,
    BorderSizePixel = 0,
  }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius) }),
  })

  task.spawn(function()
    while honeyGlow.Parent do
      tweenService:Create(honeyGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        BackgroundTransparency = 0.65,
      }):Play()
      task.wait(1.8)
      tweenService:Create(honeyGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        BackgroundTransparency = 0.9,
      }):Play()
      task.wait(1.8)
    end
  end)

  -- 🐝 Orbiting bee
  task.defer(function()
    task.wait(0.5)
    beeDecor:AttachOrbitingBee(screenGui, main)
  end)

  -- Content canvas (for fade-in)
  local canvas = object:Create("CanvasGroup", {
    Name = "CanvasGroup",
    Parent = main,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
  })

  object:Tween(canvas, { GroupTransparency = 0 }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

  -- Header
  local header = object:Create("Frame", {
    Name = "Header",
    Parent = canvas,
    BackgroundColor3 = default.Container,
    BackgroundTransparency = default.ContainerTransparency,
    Position = UDim2.new(0, 8, 0, 8),
    Size = UDim2.new(1, -16, 0, 36),
  }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius) }),
    object:Create("UIStroke", {
      Color = default.Border,
      Transparency = default.BorderTransparency,
      Thickness = 1,
    }),
  })

  local titleLabel = object:Create("TextLabel", {
    Name = "Title",
    Parent = header,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 2),
    Size = UDim2.new(0.6, 0, 0, 18),
    Font = default.Font,
    Text = name,
    TextColor3 = default.Accent,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
  })

  task.spawn(function()
    while titleLabel.Parent do
      tweenService:Create(titleLabel, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        TextColor3 = default.AccentGlow,
      }):Play()
      task.wait(1.2)
      tweenService:Create(titleLabel, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        TextColor3 = default.Accent,
      }):Play()
      task.wait(1.2)
    end
  end)

  object:Create("TextLabel", {
    Name = "Subtitle",
    Parent = header,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 18),
    Size = UDim2.new(0.6, 0, 0, 14),
    Font = default.Font,
    Text = subtitle .. " | " .. version,
    TextColor3 = default.TextMuted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
  })

  -- Close button
  local closeBtn = object:Create("TextButton", {
    Name = "Close",
    Parent = header,
    BackgroundColor3 = default.Element,
    BackgroundTransparency = default.ElementTransparency,
    Position = UDim2.new(1, -28, 0.5, -11),
    Size = UDim2.new(0, 22, 0, 22),
    Font = default.Font,
    Text = "X",
    TextColor3 = default.TextDark,
    TextSize = 11,
    AutoButtonColor = false,
  }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
    object:Create("UIStroke", {
      Color = default.Border,
      Transparency = default.BorderTransparency,
      Thickness = 1,
    }),
  })

  -- Floating toggle button
  local glowStroke = object:Create("UIStroke", {
    Color = default.Accent,
    Thickness = 1.5,
    Transparency = 0,
  })

  local toggleBtn = object:Create("ImageButton", {
    Name = "ToggleUI",
    Parent = screenGui,
    BackgroundColor3 = default.Background,
    Position = UDim2.new(0, 20, 0.5, -25),
    Size = UDim2.new(0, 50, 0, 50),
    Image = "rbxassetid://72547915216229",
    Visible = false,
  }, {
    object:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    object:Create("UIAspectRatioConstraint", { AspectRatio = 1 }),
    glowStroke,
  })

  task.spawn(function()
    tweenService:Create(
      glowStroke,
      TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
      { Color = default.AccentGlow, Thickness = 2.5 }
    ):Play()
  end)

  closeBtn.MouseButton1Click:Connect(function()
    beeSounds:Close()
    object:AnimateClick(closeBtn)
    task.wait(0.08)
    beeDecor:HoneyExit(main, screenGui, function()
      main.Visible = false
      toggleBtn.Visible = true
    end)
  end)

  toggleBtn.MouseButton1Click:Connect(function()
    object:AnimateClick(toggleBtn)
    beeSounds:Open()
    task.wait(0.08)

    -- Reset state
    main.Size = UDim2.new(0, 380, 0, 280)
    for _, d in pairs(main:GetDescendants()) do
      pcall(function()
        if d.Name == "HoneyExitDrip" then
          d:Destroy()
        end
      end)
    end

    main.Visible = true
    toggleBtn.Visible = false

    main.Size = UDim2.new(0, 0, 0, 0)
    tweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
      Size = UDim2.new(0, 380, 0, 280),
    }):Play()
  end)

  object:MakeDraggable(main, header, cfg)
  object:MakeDraggable(toggleBtn, toggleBtn, cfg)

  -- Content area
  local contentArea = object:Create("Frame", {
    Name = "ContentArea",
    Parent = canvas,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 50),
    Size = UDim2.new(1, -16, 1, -58),
  })

  local tabContainerStyle = {
    object:Create("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius) }),
    object:Create("UIStroke", {
      Color = default.Border,
      Transparency = default.BorderTransparency,
      Thickness = 1,
    }),
  }

  local tabContainer = object:Create("Frame", {
    Name = "TabContainer",
    Parent = contentArea,
    BackgroundColor3 = default.Container,
    BackgroundTransparency = default.ContainerTransparency,
    Size = UDim2.new(0, 100, 1, 0),
  }, tabContainerStyle)

  local tabList = object:Create("ScrollingFrame", {
    Name = "TabList",
    Parent = tabContainer,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 4, 0, 4),
    Size = UDim2.new(1, -8, 1, -8),
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
  }, {
    object:Create("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 4),
    }),
  })

  local mainContent = object:Create("Frame", {
    Name = "MainContent",
    Parent = contentArea,
    BackgroundColor3 = default.Container,
    BackgroundTransparency = default.ContainerTransparency,
    Position = UDim2.new(0, 106, 0, 0),
    Size = UDim2.new(1, -106, 1, 0),
    ClipsDescendants = true,
  }, {
    object:Create("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius) }),
    object:Create("UIStroke", {
      Color = default.Border,
      Transparency = default.BorderTransparency,
      Thickness = 1,
    }),
  })

  -- ═══════════════════════════════════════════════════════════
  --  📑 CREATE TAB
  -- ═══════════════════════════════════════════════════════════
  function win:CreateTab(tabName)
    local tabData = { Name = tabName }

    local tabBtn = object:Create("TextButton", {
      Name = tabName,
      Parent = tabList,
      BackgroundColor3 = default.Element,
      BackgroundTransparency = default.ElementTransparency,
      Size = UDim2.new(1, 0, 0, 30),
      Font = default.Font,
      Text = "🐝 " .. tabName,
      TextColor3 = default.TextDark,
      TextSize = 11,
      AutoButtonColor = false,
    }, {
      object:Create("UICorner", { CornerRadius = UDim.new(0, cfg.ElementCornerRadius) }),
    })

    local tabContent = object:Create("ScrollingFrame", {
      Name = tabName .. "Content",
      Parent = mainContent,
      BackgroundTransparency = 1,
      Position = UDim2.new(0, 8, 0, 8),
      Size = UDim2.new(1, -16, 1, -16),
      ScrollBarThickness = 2,
      ScrollBarImageColor3 = default.Accent,
      CanvasSize = UDim2.new(0, 0, 0, 0),
      AutomaticCanvasSize = Enum.AutomaticSize.Y,
      Visible = false,
    }, {
      object:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
      }),
    })

    tabBtn.MouseButton1Click:Connect(function()
      beeSounds:Click()
      object:AnimateClick(tabBtn)
      for _, t in pairs(win.Tabs) do
        t.Button.BackgroundColor3 = default.Element
        t.Button.TextColor3 = default.TextDark
        t.Content.Visible = false
      end
      tabBtn.BackgroundColor3 = default.Accent
      tabBtn.TextColor3 = default.Text
      tabContent.Visible = true
    end)

    if #win.Tabs == 0 then
      tabBtn.BackgroundColor3 = default.Accent
      tabBtn.TextColor3 = default.Text
      tabContent.Visible = true
    end

    tabData.Button = tabBtn
    tabData.Content = tabContent
    table.insert(win.Tabs, tabData)

    -- ─── Button ───
    function tabData:CreateButton(text, fn)
      local btn = object:Create("TextButton", {
        Parent = tabContent,
        BackgroundColor3 = default.Element,
        BackgroundTransparency = default.ElementTransparency,
        Size = UDim2.new(1, 0, 0, 32),
        Font = default.Font,
        Text = text,
        TextColor3 = default.Text,
        TextSize = 11,
        AutoButtonColor = false,
      }, {
        object:Create("UICorner", { CornerRadius = UDim.new(0, cfg.ElementCornerRadius) }),
        object:Create("UIStroke", {
          Color = default.Border,
          Transparency = default.BorderTransparency,
          Thickness = 1,
        }),
      })

      btn.MouseEnter:Connect(function()
        object:Tween(btn, { BackgroundColor3 = default.ElementHover }, 0.2)
        beeSounds:Hover()
      end)
      btn.MouseLeave:Connect(function()
        object:Tween(btn, { BackgroundColor3 = default.Element }, 0.2)
      end)

      beeDecor:AddHoneyDrip(btn)

      btn.MouseButton1Click:Connect(function()
        beeSounds:Click()
        object:AnimateClick(btn)
        fn(btn)
      end)

      return btn
    end

    -- ─── Toggle ───
    function tabData:CreateToggle(labelText, defaultState, fn)
      local state = defaultState or false

      local toggle = object:Create("TextButton", {
        Parent = tabContent,
        BackgroundColor3 = state and default.Accent or default.Element,
        BackgroundTransparency = default.ElementTransparency,
        Size = UDim2.new(1, 0, 0, 32),
        Font = default.Font,
        Text = "🍯 " .. labelText,
        TextColor3 = default.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextPosition = UDim2.new(0, 10, 0, 0),
        AutoButtonColor = false,
      }, {
        object:Create("UICorner", { CornerRadius = UDim.new(0, cfg.ElementCornerRadius) }),
        object:Create("UIStroke", {
          Color = default.Border,
          Transparency = default.BorderTransparency,
          Thickness = 1,
        }),
      })

      local knob = beeDecor:AddHoneyKnob(toggle, state)

      toggle.MouseEnter:Connect(function() beeSounds:Hover() end)

      toggle.MouseButton1Click:Connect(function()
        beeSounds:Click()
        object:AnimateClick(toggle)
        state = not state
        toggle.BackgroundColor3 = state and default.Accent or default.Element
        knob.SetState(state)
        fn(state)
      end)

      return toggle
    end

    -- ─── Input ───
    function tabData:CreateInput(placeholder, defaultValue, fn)
      local wrap = object:Create("Frame", {
        Parent = tabContent,
        BackgroundColor3 = default.Element,
        BackgroundTransparency = default.ElementTransparency,
        Size = UDim2.new(1, 0, 0, 32),
      }, {
        object:Create("UICorner", { CornerRadius = UDim.new(0, cfg.ElementCornerRadius) }),
        object:Create("UIStroke", {
          Color = default.Border,
          Transparency = default.BorderTransparency,
          Thickness = 1,
        }),
      })

      local box = object:Create("TextBox", {
        Parent = wrap,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Font = default.Font,
        PlaceholderText = placeholder,
        Text = defaultValue or "",
        TextColor3 = default.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
      })

      box.FocusLost:Connect(function() fn(box.Text) end)
      return box
    end

    -- ─── Label ───
    function tabData:CreateLabel(text)
      return object:Create("TextLabel", {
        Parent = tabContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = default.Font,
        Text = text,
        TextColor3 = default.AccentGlow,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
      })
    end

    return tabData
  end

  return win
end

-- ═══════════════════════════════════════════════════════════
--  🐝 BEE HUB MAIN
-- ═══════════════════════════════════════════════════════════
local reneBaterboniaWindow = val3:CreateWindow({
  Name = "BEE HUB 🐝🍯 | PREMIUM 👑",
  Subtitle = "By Beehubs",
  Version = "v5 PREMIUM",
})

local serverHopperTab = reneBaterboniaWindow:CreateTab("Server Hopper")

local label = serverHopperTab:CreateLabel("Current Server: " .. #players:GetPlayers() .. " player(s)")

local maxPlayers = val.MaxPlayers or 1

serverHopperTab:CreateInput("Max Target Players", tostring(maxPlayers), function(text)
  maxPlayers = tonumber(text) or 1
  val.MaxPlayers = maxPlayers
end)

local autoDetectThreshold = val.AutoDetectThreshold or 3

serverHopperTab:CreateInput("Auto Hop Player Limit", tostring(autoDetectThreshold), function(text)
  autoDetectThreshold = tonumber(text) or 3
  val.AutoDetectThreshold = autoDetectThreshold
end)

local hopping = false
local button

local function hopServer(statusLabel)
  if hopping then return end
  hopping = true

  local placeId = game.PlaceId
  local jobId = game.JobId
  local lbl = statusLabel or button

  if lbl then lbl.Text = "SEARCHING..." end

  task.spawn(function()
    local nextCursor = ""

    for _ = 1, math.random(5, 12) do
      local url = "https://games.roblox.com/v1/games/" .. placeId
        .. "/servers/Public?sortOrder=Desc&limit=100"
        .. (nextCursor ~= "" and "&cursor=" .. nextCursor or "")

      local ok, res = pcall(function() return game:HttpGet(url) end)
      if ok and res then
        local ok2, data = pcall(function() return httpService:JSONDecode(res) end)
        if ok2 and data and data.nextPageCursor then
          nextCursor = data.nextPageCursor
        else
          break
        end
      else
        break
      end
    end

    local url = "https://games.roblox.com/v1/games/" .. placeId
      .. "/servers/Public?sortOrder=Asc&limit=100"
      .. (nextCursor ~= "" and "&cursor=" .. nextCursor or "")

    local ok, res = pcall(function() return game:HttpGet(url) end)
    local target

    if ok and res then
      local ok2, data = pcall(function() return httpService:JSONDecode(res) end)
      if ok2 and data and data.data then
        local candidates = {}
        for _, srv in ipairs(data.data) do
          if srv.id ~= jobId and srv.playing <= maxPlayers and srv.playing > 0 then
            table.insert(candidates, srv)
          end
        end
        if #candidates > 0 then
          table.sort(candidates, function(a, b) return a.playing < b.playing end)
          target = candidates[1]
        end
      end
    end

    if target then
      if lbl then lbl.Text = "JOINING (" .. target.playing .. ")..." end
      teleportService:TeleportToPlaceInstance(placeId, target.id, localPlayer)
    else
      if lbl then lbl.Text = "RETRYING..." end
      task.wait(0.5)
      hopping = false
      hopServer(lbl)
    end
  end)
end

button = serverHopperTab:CreateButton("HOP SERVER NOW", function() hopServer(button) end)

local autoDetectActive

local function refreshPlayerCount()
  local count = #players:GetPlayers()
  label.Text = "Current Server: " .. count .. " player(s)"
  if autoDetectActive and count >= autoDetectThreshold then
    hopServer(button)
  end
end

autoDetectActive = val.AutoDetectActive

serverHopperTab:CreateToggle("AUTO DETECT HOP", val.AutoDetectActive, function(state)
  autoDetectActive = state
  val.AutoDetectActive = state
  if autoDetectActive then refreshPlayerCount() end
end)

players.PlayerAdded:Connect(refreshPlayerCount)
players.PlayerRemoving:Connect(refreshPlayerCount)

local autoHopActive = val.AutoHopActive

serverHopperTab:CreateToggle("AUTO HOP", val.AutoHopActive, function(state)
  autoHopActive = state
  val.AutoHopActive = state
  if autoHopActive then hopServer(button) end
end)

-- ─── AUTO TAB ───
local autoTab = reneBaterboniaWindow:CreateTab("AUTO")
autoTab:CreateLabel("Automated Controls")

autoTab:CreateToggle("AUTO TURN ON DETECT", val.AutoDetectActive, function(state)
  autoDetectActive = state
  val.AutoDetectActive = state
  if autoDetectActive then refreshPlayerCount() end
end)

autoTab:CreateButton("FORCE ENABLE DETECT", function()
  autoDetectActive = true
  val.AutoDetectActive = true
  refreshPlayerCount()
end)

-- ─── SCRIPTS TAB ───
local scriptsTab = reneBaterboniaWindow:CreateTab("Scripts")
scriptsTab:CreateLabel("🟢 NO KEY REQUIRED")

scriptsTab:CreateButton("ON hub", function()
  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/davizin713/ONhub/refs/heads/main/script.lua", true))()
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
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ItzYumi/Decode/refs/heads/main/DE%3ACODE.lua", true))()
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
  pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/d0zBUM6r"))() end)
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
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
  end)
end)

-- ─── OWNER TAB ───
local ownerTab = reneBaterboniaWindow:CreateTab("Owner")
ownerTab:CreateLabel("Social Links")

local function copyToClipboard(value, btn, originalText)
  if setclipboard then
    setclipboard(value)
  elseif syn and syn.write_clipboard then
    syn.write_clipboard(value)
  end
  btn.Text = "COPIED!"
  task.wait(1.5)
  btn.Text = originalText
end

ownerTab:CreateButton("Tiktok - Its Bee", function(btn)
  copyToClipboard("Its Bee", btn, "Tiktok - Its Bee")
end)

ownerTab:CreateButton("Discord", function(btn)
  copyToClipboard("https://discord.gg/M9ZnxTafE", btn, "Discord")
end)

ownerTab:CreateButton("Promoter: Tawewie", function(btn)
  copyToClipboard("Tawewie", btn, "Promoter: Tawewie")
end)

ownerTab:CreateButton("Promoter - None", function(btn)
  copyToClipboard("None", btn, "Promoter - None")
end)

-- ─── CONFIG TAB ───
local configTab = reneBaterboniaWindow:CreateTab("Config")
configTab:CreateLabel("Configuration Manager")

configTab:CreateButton("SAVE CONFIG", function(btn)
  local originalText = btn.Text
  btn.Text = "SAVED!"
  if writefile then
    pcall(function()
      writefile("AxionAutoDetectConfig.json", httpService:JSONEncode(val))
    end)
  end
  task.wait(1)
  btn.Text = originalText
end)

configTab:CreateToggle("AUTO-SAVE ON CHANGE", val.AutoSave or false, function(state)
  val.AutoSave = state
end)

-- ═══════════════════════════════════════════════════════════
--  🚀 BOOT
-- ═══════════════════════════════════════════════════════════
beeSounds:Open()

task.spawn(function()
  task.wait(1.5)
  if val.AutoDetectActive then
    autoDetectActive = true
    refreshPlayerCount()
  end
  if val.AutoHopActive then
    autoHopActive = true
    hopServer(button)
  end
end)