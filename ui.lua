local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local CaptureService = game:GetService("CaptureService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blossom = {
	Version = "3.0.2",
	Modules = {},
	ModuleById = {},
	ModuleErrors = {},
}

local function copy(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for key, entry in pairs(value) do
		out[key] = copy(entry)
	end
	return out
end

local function clamp(value, low, high)
	if value < low then
		return low
	end
	if value > high then
		return high
	end
	return value
end

local function mix(a, b, t)
	return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function hex(value)
	if type(value) ~= "string" then
		return Color3.new(1, 1, 1)
	end
	local r = tonumber(value:sub(2, 3), 16)
	local g = tonumber(value:sub(4, 5), 16)
	local b = tonumber(value:sub(6, 7), 16)
	if not r or not g or not b then
		return Color3.new(1, 1, 1)
	end
	return Color3.fromRGB(r, g, b)
end

local function isHex(value)
	return type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil
end

local function clean(text, limit)
	if type(text) ~= "string" then
		return ""
	end
	text = text:gsub("%c", "")
	text = text:match("^%s*(.-)%s*$") or ""
	if limit and #text > limit then
		text = text:sub(1, limit)
	end
	return text
end

local function safeCall(fn, ...)
	if type(fn) ~= "function" then
		return false, "not a function"
	end
	local ok, result = xpcall(fn, function(err)
		return tostring(err) .. "\n" .. debug.traceback("", 2)
	end, ...)
	return ok, result
end

local function viewport()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local Device = {

	mobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
	touch = UserInputService.TouchEnabled,
	hover = UserInputService.MouseEnabled,
}

local BASE_THEME = {
	Name = "Obsidian",
	Mode = "dark",
	Accent = "#F072A8",
	Base = "#0E1116",
	PanelTransparency = 0,
	CardTransparency = 0,
	StrokeTransparency = 0.9,
	StrokeThickness = 1,
	GradientTop = "#FFFFFF",
	GradientTopTransparency = 0.94,
	GradientBottomTransparency = 1,
	TextPrimary = "#EEF2F7",
	TextSecondary = "#8B94A3",
	TextDisabled = "#545C69",
	DimColor = "#05070A",
	DimTransparency = 0.38,
	ProgressTrack = "#2A1C24",
	ProgressFill = "#F072A8",
	SkeletonBase = "#171C24",
	SkeletonHighlight = "#232A34",
	ShimmerTransparency = 0.3,
	Font = "GothamMedium",
	CornerRadius = 10,
	Spacing = 12,
	BackgroundImage = "",
	LogoImage = "",
	SpinnerImage = "",
	TextureImage = "",
	BlurEnabled = true,
	BlurSize = 12,
	SidebarColor = "#0A0C10",
	CardColor = "#15191F",
	DividerColor = "#22272F",
	BannerA = "#5A1233",
	BannerB = "#F072A8",
	BannerC = "#12070E",
}

local function extend(base, overrides)
	local theme = copy(base)
	for key, value in pairs(overrides) do
		theme[key] = value
	end
	return theme
end

local SKINS = {
	Obsidian = copy(BASE_THEME),
	Porcelain = extend(BASE_THEME, {
		Name = "Porcelain", Mode = "light", Accent = "#0E8C6D", Base = "#F3F5F9",
		StrokeTransparency = 0.72, TextPrimary = "#11151C", TextSecondary = "#5A6272",
		TextDisabled = "#98A0AD", DimColor = "#AEB6C2", DimTransparency = 0.35,
		ProgressTrack = "#D3DAE4", ProgressFill = "#0E8C6D", SkeletonBase = "#DDE3EC",
		SkeletonHighlight = "#EFF3F8", ShimmerTransparency = 0.35, BlurEnabled = false,
		BlurSize = 8, SidebarColor = "#E9EDF3", CardColor = "#FFFFFF",
		DividerColor = "#DCE3EC", BannerA = "#BFE9DE", BannerB = "#CFE4FF", BannerC = "#F3F5F9",
	}),
	Ember = extend(BASE_THEME, {
		Name = "Ember", Accent = "#FF9A5A", Base = "#100D0B", TextPrimary = "#F6EDE6",
		TextSecondary = "#A8958A", TextDisabled = "#5E5148", DimColor = "#0A0705",
		ProgressTrack = "#241C17", ProgressFill = "#FF9A5A", SkeletonBase = "#1C1613",
		SkeletonHighlight = "#2A211B", SidebarColor = "#0A0705", CardColor = "#1A1411",
		DividerColor = "#2A211B", BannerA = "#7A2E0C", BannerB = "#C75B24", BannerC = "#120B07",
	}),
	Sakura = extend(BASE_THEME, {
		Name = "Sakura", Mode = "light", Accent = "#D6568C", Base = "#FBF3F6",
		StrokeTransparency = 0.74, TextPrimary = "#1C1418", TextSecondary = "#6B5A62",
		TextDisabled = "#A8959E", DimColor = "#B9A6AE", DimTransparency = 0.34,
		ProgressTrack = "#EEDCE4", ProgressFill = "#D6568C", SkeletonBase = "#EEDCE4",
		SkeletonHighlight = "#F8EDF1", ShimmerTransparency = 0.35, BlurEnabled = false,
		BlurSize = 8, CornerRadius = 12, SidebarColor = "#F6E9EF", CardColor = "#FFFFFF",
		DividerColor = "#EFDCE5", BannerA = "#F3C3D8", BannerB = "#F7C0D6", BannerC = "#FBF3F6",
	}),
	Midnight = extend(BASE_THEME, {
		Name = "Midnight", Accent = "#7C8CFF", Base = "#080A14", TextPrimary = "#E8ECFF",
		TextSecondary = "#8890B4", TextDisabled = "#4C5470", DimColor = "#04060F",
		DimTransparency = 0.4, ProgressTrack = "#161A2C", ProgressFill = "#7C8CFF",
		SkeletonBase = "#131728", SkeletonHighlight = "#1D2338", BlurSize = 14,
		CornerRadius = 12, SidebarColor = "#05060D", CardColor = "#121628",
		DividerColor = "#1E2438", BannerA = "#2A1E7A", BannerB = "#4C3BC9", BannerC = "#070A12",
	}),
	Ice = extend(BASE_THEME, {
		Name = "Ice", Mode = "light", Accent = "#0F7FA8", Base = "#EFF6FA",
		StrokeTransparency = 0.76, TextPrimary = "#0E1B22", TextSecondary = "#4C6470",
		TextDisabled = "#93A8B3", DimColor = "#A7BCC6", DimTransparency = 0.35,
		ProgressTrack = "#D5E5EE", ProgressFill = "#0F7FA8", SkeletonBase = "#DCEAF2",
		SkeletonHighlight = "#F2F9FC", ShimmerTransparency = 0.34, BlurEnabled = false,
		BlurSize = 8, SidebarColor = "#E4EFF6", CardColor = "#FFFFFF",
		DividerColor = "#D6E6EF", BannerA = "#C3E6F5", BannerB = "#BDF0E6", BannerC = "#EFF6FA",
	}),
	Moss = extend(BASE_THEME, {
		Name = "Moss", Accent = "#8BD16B", Base = "#0A0F0B", TextPrimary = "#EAF3E6",
		TextSecondary = "#92A48C", TextDisabled = "#52604E", DimColor = "#050805",
		DimTransparency = 0.4, ProgressTrack = "#18211A", ProgressFill = "#8BD16B",
		SkeletonBase = "#141B15", SkeletonHighlight = "#1E281F", CornerRadius = 8,
		SidebarColor = "#060A07", CardColor = "#131A14", DividerColor = "#1F2921",
		BannerA = "#1D4A31", BannerB = "#4E8F55", BannerC = "#08110B",
	}),
	Sandstone = extend(BASE_THEME, {
		Name = "Sandstone", Mode = "light", Accent = "#A9713F", Base = "#F7F1E7",
		StrokeTransparency = 0.72, TextPrimary = "#241C14", TextSecondary = "#6E6052",
		TextDisabled = "#A6988A", DimColor = "#BCAC99", DimTransparency = 0.36,
		ProgressTrack = "#E9DFD1", ProgressFill = "#A9713F", SkeletonBase = "#EDE3D5",
		SkeletonHighlight = "#FAF5EC", ShimmerTransparency = 0.34, BlurEnabled = false,
		BlurSize = 8, CornerRadius = 12, SidebarColor = "#F1E8DA", CardColor = "#FFFDF9",
		DividerColor = "#E5D9C8", BannerA = "#EFD9B8", BannerB = "#DCC7A6", BannerC = "#FBF7EF",
	}),
}

local SKIN_ORDER = { "Sakura", "Obsidian", "Porcelain", "Ember", "Midnight", "Ice", "Moss", "Sandstone" }
local BUILTIN_SKINS = {}
for _, name in ipairs(SKIN_ORDER) do
	BUILTIN_SKINS[name] = true
end

local function skinNames()
	local names = {}
	for _, name in ipairs(SKIN_ORDER) do
		if SKINS[name] then
			table.insert(names, name)
		end
	end
	return names
end

local function registerSkin(name, theme)
	local label = clean(tostring(name or ""), 24)
	if label == "" then
		return nil
	end
	local skin = copy(theme or BASE_THEME)
	skin.Name = label
	SKINS[label] = skin
	if not table.find(SKIN_ORDER, label) then
		table.insert(SKIN_ORDER, label)
	end
	return label
end

local CONFIG = {
	GuiName = "Blossom",
	AutoPlay = true,
	StartupDelay = 0.25,
	Brand = {
		Name = "Blossom",
		Tag = "script hub",
		AvatarImageId = "7395055006",
	},
	Keys = {
		Destroy = Enum.KeyCode.Delete,
		DestroyModifier = Enum.KeyCode.LeftShift,
		Debug = Enum.KeyCode.F1,
		Screenshot = Enum.KeyCode.F12,
		Hide = Enum.KeyCode.RightShift,
	},
	GamepadKeys = {
		Hide = Enum.KeyCode.ButtonY,
		Debug = Enum.KeyCode.DPadUp,
		Screenshot = Enum.KeyCode.DPadDown,
	},
	Durations = {
		Scale = 1,
		Splash = 1.5,
		SplashHold = 0.5,
		Transition = 0.55,
		Slide = 0.4,
		Countdown = 0.9,
		CountdownGap = 0.12,
		Fade = 0.35,
		ThemeCrossfade = 0.45,
		Hover = 0.16,
		Press = 0.09,
		Toggle = 0.22,
		LoopGap = 0.5,
		PreloadTimeout = 6,
	},
	Easing = {
		Fill = "Quint", FillDir = "Out",
		Fade = "Quad", FadeDir = "Out",
		Slide = "Quint", SlideDir = "Out",
		Pop = "Back", PopDir = "Out",
		Hover = "Quad", HoverDir = "Out",
		Press = "Quad", PressDir = "Out",
		Spin = "Linear", SpinDir = "Out",
		Theme = "Quint", ThemeDir = "Out",
	},
	Layout = {
		MaxWidth = 560,
		Padding = 16,
		Gap = 12,
		CornerRadius = 12,
		MinScale = 0.6,
	},
	Theme = copy(BASE_THEME),
	Gallery = {
		DefaultSpeed = 1,
		Speeds = { 1, 0.5, 0.25 },
		LoopEnabled = false,
		CountdownEnabled = true,
	},
	Debug = {
		StartVisible = false,
		UpdateRate = 0.25,
	},
	Ambient = {
		Petals = true,
		Count = 8,
		Speed = 62,
	},
	Loading = {
		BackdropColor = "#0B0609",
		BackdropTransparency = 0.01,
		PetalColor = "#F49BC0",
		TitleColor = "#FCEFF4",
		LogoMode = "Mark",
		LogoImageId = "",
		LogoSize = 64,
		LogoOffsetY = 0,
		LogoSpin = 1.6,
		LogoPulse = 1.1,
		LogoFloat = 1.8,
		LogoColor = "#F49BC0",
		LogoCoreColor = "#FFF6FA",
	},
	Mobile = {
		ReduceEffects = true,
		TapTarget = 44,
		CompactBreakpoint = 700,
	},
}

local DEFAULT_KEYS = copy(CONFIG.Keys)
local DEFAULT_GAMEPAD_KEYS = copy(CONFIG.GamepadKeys)
local GAMEPAD_LABELS = {
	ButtonA = "A", ButtonB = "B", ButtonX = "X", ButtonY = "Y",
	ButtonL1 = "LB", ButtonR1 = "RB", ButtonL2 = "LT", ButtonR2 = "RT",
	ButtonL3 = "LS", ButtonR3 = "RS", ButtonStart = "Start", ButtonSelect = "Select",
	DPadUp = "D↑", DPadDown = "D↓", DPadLeft = "D←", DPadRight = "D→",
}

local function keyLabel(key)
	if key == nil then
		return "—"
	end
	local name = key.Name
	if type(name) ~= "string" then
		return tostring(key)
	end
	if GAMEPAD_LABELS[name] then
		return GAMEPAD_LABELS[name]
	end
	if name:sub(1, 6) == "Button" then
		return name:sub(7)
	end
	if name:sub(1, 4) == "DPad" then
		return "D" .. name:sub(5)
	end
	return name
end

local function bindingLabel(action)
	return keyLabel(CONFIG.Keys[action]) .. " / " .. keyLabel(CONFIG.GamepadKeys[action])
end

local EASING_STYLES = {
	Linear = Enum.EasingStyle.Linear, Quad = Enum.EasingStyle.Quad, Cubic = Enum.EasingStyle.Cubic,
	Quart = Enum.EasingStyle.Quart, Quint = Enum.EasingStyle.Quint, Sine = Enum.EasingStyle.Sine,
	Exponential = Enum.EasingStyle.Exponential, Circular = Enum.EasingStyle.Circular,
	Back = Enum.EasingStyle.Back, Bounce = Enum.EasingStyle.Bounce, Elastic = Enum.EasingStyle.Elastic,
}

local EASING_DIRS = {
	In = Enum.EasingDirection.In,
	Out = Enum.EasingDirection.Out,
	InOut = Enum.EasingDirection.InOut,
}

local State = {
	gui = nil,
	root = nil,
	backdrop = nil,
	stage = nil,
	main = nil,
	mainColumn = nil,
	mainScale = nil,
	sidebar = nil,
	content = nil,
	banner = nil,
	nav = nil,
	pagesHost = nil,
	customize = nil,
	customizeOpen = false,
	player = nil,
	playerGui = nil,
	theme = copy(BASE_THEME),
	destroyed = false,
	playing = false,
	loading = false,
	token = 0,
	speed = 1,
	activeSpeed = 1,
	mainVisible = false,
	userHidden = false,
	activePage = 1,
	pages = {},
	pageMeta = {},
	navRows = {},
	navIcons = {},
	navLabels = {},
	pageIndexById = {},
	blur = nil,
	modulesPage = nil,
	modulesBuilt = false,
	ready = false,
	autoExecute = false,
	moduleHost = nil,
	moduleRefresh = {},
	compact = nil,
	lastViewport = Vector2.zero,
	rebuildQueued = false,
	windowLocked = false,
	windowCenter = nil,
	captureAction = nil,
	captureButton = nil,
	reopen = nil,
}

local Metrics = {
	compact = false,
	touch = false,
	pad = 16,
	gap = 12,
	row = 40,
	button = 32,
	input = 36,
	nav = 32,
	topbar = 38,
	banner = 78,
	corner = 12,
	titleSize = 18,
	bodySize = 13,
	captionSize = 12,
	scale = 1,
	width = 480,
	height = 420,
	sidebar = 168,
	viewport = Vector2.new(1280, 720),
}

local function computeMetrics()
	local vp = viewport()
	local compact = Device.mobile or vp.X < CONFIG.Mobile.CompactBreakpoint
	local tap = CONFIG.Mobile.TapTarget
	local metrics = {
		viewport = vp,
		compact = compact,
		touch = Device.touch,
		pad = compact and 12 or 16,
		gap = compact and 10 or 12,
		row = Device.touch and math.max(tap, 46) or 40,
		button = Device.touch and math.max(tap, 40) or 32,
		input = Device.touch and math.max(tap, 42) or 36,
		nav = compact and 46 or 32,
		topbar = Device.touch and 44 or 38,
		banner = compact and 62 or 78,
		corner = 12,
		titleSize = compact and 19 or 18,
		bodySize = Device.touch and 14 or 13,
		captionSize = Device.touch and 12 or 12,
		scale = 1,
		width = 480,
		height = 420,
		sidebar = 168,
	}
	if not compact then
		metrics.scale = clamp(math.min(vp.X / 760, vp.Y / 520), CONFIG.Layout.MinScale, 1)
	end
	local availW = vp.X / math.max(0.1, metrics.scale) - 32
	local availH = vp.Y / math.max(0.1, metrics.scale) - 40
	if compact then
		metrics.width = math.floor(clamp(math.min(CONFIG.Layout.MaxWidth, vp.X - 16), 300, 640))
		metrics.height = math.floor(clamp(vp.Y - 28, 320, 640))
	else
		metrics.width = math.floor(clamp(math.min(CONFIG.Layout.MaxWidth, availW), 320, CONFIG.Layout.MaxWidth))
		metrics.height = math.floor(clamp(math.min(430, availH), 300, 430))
	end
	return metrics
end

local Connections = {}
local TweenList = {}
local StageTweens = {}
local PetalTweens = {}
local ThemeTweens = {}
local TweenIndex = setmetatable({}, { __mode = "k" })

local function connect(signal, fn)
	local conn = signal:Connect(fn)
	table.insert(Connections, conn)
	return conn
end

local function ti(seconds, style, dir, repeatCount, reverses, delayTime)
	return TweenInfo.new(
		math.max(0.01, seconds),
		EASING_STYLES[style] or Enum.EasingStyle.Quad,
		EASING_DIRS[dir] or Enum.EasingDirection.Out,
		repeatCount or 0,
		reverses or false,
		delayTime or 0
	)
end

local function duration(value)
	return value * CONFIG.Durations.Scale / math.max(0.05, State.activeSpeed)
end

local function cancelProps(target, props)
	local index = TweenIndex[target]
	if not index then
		return
	end
	for prop in pairs(props) do
		local existing = index[prop]
		if existing then
			index[prop] = nil
			pcall(function()
				existing:Cancel()
			end)
		end
	end
end

local function playTween(target, info, props, list)
	if State.destroyed or target == nil then
		return nil
	end
	cancelProps(target, props)
	local ok, tween = pcall(TweenService.Create, TweenService, target, info, props)
	if not ok or tween == nil then
		return nil
	end
	if not pcall(function()
		tween:Play()
	end) then
		return nil
	end
	local index = TweenIndex[target]
	if not index then
		index = {}
		TweenIndex[target] = index
	end
	for prop in pairs(props) do
		index[prop] = tween
	end
	local store = list or TweenList
	for i = #store, 1, -1 do
		if store[i].PlaybackState ~= Enum.PlaybackState.Playing then
			table.remove(store, i)
		end
	end
	table.insert(store, tween)
	return tween
end

local function uiTween(target, props, seconds, style, dir)
	if target == nil then
		return nil
	end
	return playTween(target, ti(duration(seconds or CONFIG.Durations.Hover), style or "Quad", dir or "Out"), props)
end

local function cancelList(list)
	for i = #list, 1, -1 do
		pcall(function()
			list[i]:Cancel()
		end)
		table.remove(list, i)
	end
end

local Tokens = {}
local FONT_CACHE = {}
local ThemeCache = {
	list = nil,
	animated = { Panel = true, Sidebar = true, Card = true, Surface = true, Backdrop = true, Input = true, Button = true },
}

local function themeFont()
	local name = tostring(State.theme.Font or "")
	local cached = FONT_CACHE[name]
	if cached then
		return cached
	end
	local ok, font = pcall(function()
		return Enum.Font[name]
	end)
	font = (ok and font) or Enum.Font.GothamMedium
	FONT_CACHE[name] = font
	return font
end

local function boldFont()
	local name = State.theme.Font
	if name == "Gotham" or name == "GothamMedium" or name == "GothamBold" then
		return Enum.Font.GothamBold
	end
	return themeFont()
end

local function recalcTokens(theme)
	Tokens = {
		accent = hex(theme.Accent),
		base = hex(theme.Base),
		textPrimary = hex(theme.TextPrimary),
		textSecondary = hex(theme.TextSecondary),
		textDisabled = hex(theme.TextDisabled),
		onAccent = theme.Mode == "dark" and Color3.fromRGB(28, 8, 18) or Color3.new(1, 1, 1),
		dim = hex(theme.DimColor),
		track = hex(theme.ProgressTrack),
		fill = hex(theme.ProgressFill),
		skeleton = hex(theme.SkeletonBase),
		shimmer = hex(theme.SkeletonHighlight),
		gradientTop = hex(theme.GradientTop),
		sidebar = hex(theme.SidebarColor or theme.Base),
		card = hex(theme.CardColor or theme.Base),
		divider = hex(theme.DividerColor or theme.ProgressTrack),
		bannerA = hex(theme.BannerA or theme.Accent),
		bannerB = hex(theme.BannerB or theme.ProgressFill),
		bannerC = hex(theme.BannerC or theme.Base),
	}
	local dark = theme.Mode == "dark"
	Tokens.button = mix(Tokens.base, Tokens.textPrimary, dark and 0.08 or 0.05)
	Tokens.buttonHover = mix(Tokens.base, Tokens.textPrimary, dark and 0.13 or 0.09)
	Tokens.buttonPressed = mix(Tokens.base, Tokens.textPrimary, dark and 0.18 or 0.13)
	Tokens.accentHover = mix(Tokens.accent, Color3.new(1, 1, 1), 0.14)
	Tokens.accentPressed = mix(Tokens.accent, Color3.new(0, 0, 0), 0.12)
end

local function tierColor(tier)
	if tier == "Secondary" then
		return Tokens.textSecondary
	elseif tier == "Disabled" then
		return Tokens.textDisabled
	elseif tier == "Accent" then
		return Tokens.accent
	elseif tier == "OnAccent" then
		return Tokens.onAccent
	end
	return Tokens.textPrimary
end

local function textSize(role)
	if role == "Title" then
		return Metrics.titleSize
	elseif role == "Caption" then
		return Metrics.captionSize
	end
	return Metrics.bodySize
end

local REBUILD = {}
local function refreshAll()
	for i = #REBUILD, 1, -1 do
		local ok = pcall(REBUILD[i])
		if not ok then
			table.remove(REBUILD, i)
		end
	end
end

local function themeList()
	if not ThemeCache.list then
		ThemeCache.list = State.gui and State.gui:GetDescendants() or {}
	end
	return ThemeCache.list
end

local function strokeRole(role)
	local th = State.theme
	if role == "Accent" then
		return Tokens.accent, 0.35
	elseif role == "Focus" then
		return Tokens.accent, 0.12
	elseif role == "Selected" then
		return Tokens.accent, 0.4
	elseif role == "Plain" then
		return Tokens.divider, 0.6
	elseif role == "CardEdge" then
		return Tokens.textPrimary, math.min(1, th.StrokeTransparency + 0.04)
	elseif role == "Soft" then
		return Tokens.textPrimary, math.min(1, th.StrokeTransparency + 0.03)
	end
	return Tokens.textPrimary, th.StrokeTransparency
end

local function treeGradient(role)
	local th = State.theme
	if role == "Header" then
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, Tokens.bannerB),
			ColorSequenceKeypoint.new(0.55, Tokens.bannerA),
			ColorSequenceKeypoint.new(1, Tokens.base),
		}), NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.86),
			NumberSequenceKeypoint.new(0.55, 0.95),
			NumberSequenceKeypoint.new(1, 1),
		}), 16
	elseif role == "Shimmer" then
		return ColorSequence.new(Tokens.shimmer), NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, th.ShimmerTransparency),
			NumberSequenceKeypoint.new(1, 1),
		}), 0
	end
	return ColorSequence.new(Tokens.gradientTop), NumberSequence.new({
		NumberSequenceKeypoint.new(0, th.GradientTopTransparency),
		NumberSequenceKeypoint.new(1, th.GradientBottomTransparency),
	}), 90
end

local function sameValue(a, b)
	if typeof(a) ~= typeof(b) then
		return false
	end
	if typeof(a) == "Color3" then
		return math.abs(a.R - b.R) < 0.004 and math.abs(a.G - b.G) < 0.004 and math.abs(a.B - b.B) < 0.004
	end
	return a == b
end

local manageBlur

local function applyTheme(theme, animated)
	cancelList(ThemeTweens)
	State.theme = copy(theme)
	recalcTokens(State.theme)
	if State.playing then
		animated = false
	end
	if Device.mobile and CONFIG.Mobile.ReduceEffects then
		animated = false
	end
	local th = State.theme
	local info = ti(duration(CONFIG.Durations.ThemeCrossfade), CONFIG.Easing.Theme, CONFIG.Easing.ThemeDir)

	local function set(inst, prop, value)
		if animated and ThemeCache.animated[inst:GetAttribute("Role")] then
			local ok, current = pcall(function()
				return inst[prop]
			end)
			if ok and current ~= nil and sameValue(current, value) then
				return
			end
			playTween(inst, info, { [prop] = value }, ThemeTweens)
		else
			inst[prop] = value
		end
	end

	for _, d in ipairs(themeList()) do
		local role = d:GetAttribute("Role")
		if d:IsA("UIStroke") then
			local color, alpha = strokeRole(role)
			d.Color = color
			d.Transparency = alpha
			d.Thickness = math.max(1, th.StrokeThickness)
		elseif d:IsA("UIGradient") then
			local colors, transparency, rotation = treeGradient(role)
			d.Color = colors
			d.Transparency = transparency
			d.Rotation = rotation
		elseif d:IsA("UICorner") then
			local radius = th.CornerRadius
			if role == "Small" then
				radius = math.min(radius, 8)
			elseif role == "Dot" then
				radius = 999
			end
			d.CornerRadius = UDim.new(0, radius)
		elseif d:IsA("UIListLayout") then
			if role == "Gap" then
				d.Padding = UDim.new(0, th.Spacing)
			end
		elseif d:IsA("UIPadding") then
			if role == "Pad" then
				local pad = UDim.new(0, th.Spacing)
				d.PaddingTop, d.PaddingBottom, d.PaddingLeft, d.PaddingRight = pad, pad, pad, pad
			end
		elseif d:IsA("Frame") or d:IsA("TextButton") or d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("ImageLabel") or d:IsA("ImageButton") then
			if role == "Panel" then
				set(d, "BackgroundColor3", Tokens.base)
				set(d, "BackgroundTransparency", th.PanelTransparency)
			elseif role == "Sidebar" then
				set(d, "BackgroundColor3", Tokens.sidebar)
			elseif role == "Card" then
				set(d, "BackgroundColor3", Tokens.card)
				set(d, "BackgroundTransparency", th.CardTransparency)
			elseif role == "Button" then
				set(d, "BackgroundColor3", Tokens.button)
			elseif role == "Ghost" then
				set(d, "BackgroundColor3", Tokens.button)
			elseif role == "Input" then
				set(d, "BackgroundColor3", Tokens.base)
			elseif role == "Divider" then
				set(d, "BackgroundColor3", Tokens.divider)
			elseif role == "SliderKnob" then
				set(d, "BackgroundColor3", Tokens.textPrimary)
			elseif role == "Backdrop" then
				local level = d:GetAttribute("BackdropLevel")
				if level == "loading" then
					set(d, "BackgroundColor3", hex(CONFIG.Loading.BackdropColor))
					set(d, "BackgroundTransparency", CONFIG.Loading.BackdropTransparency)
				elseif level == "modal" then
					set(d, "BackgroundColor3", Tokens.dim)
					set(d, "BackgroundTransparency", th.DimTransparency)
				else
					set(d, "BackgroundColor3", Tokens.dim)
				end
			elseif role == "Accent" then
				set(d, "BackgroundColor3", Tokens.accent)
			elseif role == "Track" then
				set(d, "BackgroundColor3", Tokens.track)
			elseif role == "Fill" then
				set(d, "BackgroundColor3", Tokens.fill)
			elseif role == "Skeleton" then
				set(d, "BackgroundColor3", Tokens.skeleton)
			elseif role == "Surface" then
				set(d, "BackgroundColor3", Tokens.base)
			end
		end

		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
			d.Font = d:GetAttribute("Bold") == true and boldFont() or themeFont()
			if d:GetAttribute("FixedSize") ~= true then
				d.TextSize = textSize(d:GetAttribute("TextRole"))
			end
			d.TextColor3 = tierColor(d:GetAttribute("Tier") or "Primary")
			if d:IsA("TextBox") then
				d.PlaceholderColor3 = Tokens.textSecondary
			end
		end

		if d:IsA("ImageLabel") or d:IsA("ImageButton") then
			local image = d:GetAttribute("ImageRole")
			if image == "Background" and th.BackgroundImage ~= "" then
				d.Image = "rbxassetid://" .. th.BackgroundImage
			elseif image == "Logo" and th.LogoImage ~= "" then
				d.Image = "rbxassetid://" .. th.LogoImage
			elseif image == "Spinner" and th.SpinnerImage ~= "" then
				d.Image = "rbxassetid://" .. th.SpinnerImage
			elseif image == "Texture" and th.TextureImage ~= "" then
				d.Image = "rbxassetid://" .. th.TextureImage
			end
		end
	end

	manageBlur()
	refreshAll()
end

local function new(className, props, parent)
	local inst = Instance.new(className)
	if props then
		local role, tier, textRole, imageRole
		for key, value in pairs(props) do
			if key == "Role" then
				role = value
			elseif key == "Tier" then
				tier = value
			elseif key == "TextRole" then
				textRole = value
			elseif key == "ImageRole" then
				imageRole = value
			elseif key ~= "Parent" then
				inst[key] = value
			end
		end
		if role then
			inst:SetAttribute("Role", role)
		end
		if tier then
			inst:SetAttribute("Tier", tier)
		end
		if textRole then
			inst:SetAttribute("TextRole", textRole)
		end
		if imageRole then
			inst:SetAttribute("ImageRole", imageRole)
		end
	end
	if parent then
		inst.Parent = parent
	end
	ThemeCache.list = nil
	return inst
end

manageBlur = function()
	local seeThrough = (tonumber(CONFIG.Loading.BackdropTransparency) or 0) > 0.45
	local wanted = State.theme.BlurEnabled and State.loading and seeThrough
	if Device.mobile and CONFIG.Mobile.ReduceEffects then
		wanted = false
	end
	if wanted then
		if not State.blur then
			State.blur = new("BlurEffect", { Name = "BlossomBlur", Size = 0, Enabled = true }, Lighting)
		end
		playTween(State.blur, ti(duration(CONFIG.Durations.Fade), "Quad", "Out"), { Size = State.theme.BlurSize })
	elseif State.blur then
		local blur = State.blur
		playTween(blur, ti(duration(CONFIG.Durations.Fade), "Quad", "In"), { Size = 0 })
		task.delay(duration(CONFIG.Durations.Fade) + 0.1, function()
			if State.blur == blur then
				blur:Destroy()
				State.blur = nil
			end
		end)
	end
end
local toast
local setStatusLabel
local openCustomize, closeCustomize
local playGallery, captureShot, toggleDebug
local showMain, hideMain, toggleMenu, beginKeyCapture, cancelKeyCapture
local saveProfile, loadProfile, applyVisibility

local SliderConnections = {}
local function connectSlider(signal, fn)
	local conn = signal:Connect(fn)
	table.insert(SliderConnections, conn)
	return conn
end

local function clearSliderConnections()
	for i = #SliderConnections, 1, -1 do
		pcall(function()
			SliderConnections[i]:Disconnect()
		end)
		table.remove(SliderConnections, i)
	end
end

local function addRule(row, inset)
	local pad = tonumber(inset) or 10
	return new("Frame", {
		Name = "Rule",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, pad, 1, 0),
		Size = UDim2.new(1, -pad * 2, 0, 1),
		BackgroundColor3 = Tokens.divider,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Role = "Divider",
	}, row)
end

local function makeLabel(parent, opts)
	opts = opts or {}
	local role = opts.TextRole
	local label = new("TextLabel", {
		Name = opts.Name or "Label",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, textSize(role) + 6),
		Position = opts.Position,
		AnchorPoint = opts.AnchorPoint,
		Text = opts.Text or "",
		Font = opts.Bold and boldFont() or themeFont(),
		TextSize = opts.TextSize or textSize(role),
		TextColor3 = opts.Color or tierColor(opts.Tier or "Primary"),
		TextXAlignment = opts.XAlign or Enum.TextXAlignment.Left,
		TextYAlignment = opts.YAlign or Enum.TextYAlignment.Center,
		TextWrapped = opts.Wrapped == true,
		TextTruncate = opts.Truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None,
		LayoutOrder = opts.Order or 0,
		Visible = opts.Visible ~= false,
		ZIndex = opts.ZIndex or 1,
		Tier = opts.Tier or "Primary",
		TextRole = role,
	}, parent)
	if opts.Bold then
		label:SetAttribute("Bold", true)
	end
	if opts.FixedSize then
		label:SetAttribute("FixedSize", true)
	end
	return label
end

local function makeCard(parent, opts)
	opts = opts or {}
	local card = new("Frame", {
		Name = opts.Name or "Card",
		BackgroundColor3 = Tokens.card,
		BackgroundTransparency = State.theme.CardTransparency,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = opts.Order or 0,
		Role = "Card",
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, math.min(State.theme.CornerRadius, 8)), Role = "Small" }, card)
	new("UIStroke", {
		Color = Tokens.textPrimary,
		Transparency = math.min(1, State.theme.StrokeTransparency + 0.04),
		Thickness = 1,
		Role = "CardEdge",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, card)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
	}, card)
	new("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
	}, card)
	if opts.Title then
		makeLabel(card, {
			Name = "CardTitle",
			Text = clean(tostring(opts.Title), 40),
			Tier = "Secondary",
			TextRole = "Caption",
			Bold = true,
			FixedSize = true,
			LayoutOrder = -10,
			Size = UDim2.new(1, -12, 0, 26),
		})
	end
	return card
end

local function makeButton(parent, opts)
	opts = opts or {}
	local variant = opts.Variant or "Default"
	local primary = variant == "Primary"
	local ghost = variant == "Ghost"
	local radius = tonumber(opts.Radius) or math.max(4, Metrics.corner - 4)
	local labelSize = tonumber(opts.TextSize) or Metrics.bodySize
	local button = new("TextButton", {
		Name = opts.Name or "Button",
		AutoButtonColor = false,
		Selectable = true,
		BackgroundColor3 = primary and Tokens.accent or Tokens.button,
		BackgroundTransparency = ghost and 0.94 or 0,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, Metrics.button),
		Position = opts.Position,
		AnchorPoint = opts.AnchorPoint,
		Text = clean(tostring(opts.Text or "Button"), 64),
		Font = opts.Bold and boldFont() or themeFont(),
		TextSize = labelSize,
		TextColor3 = primary and Tokens.onAccent or Tokens.textPrimary,
		TextXAlignment = opts.XAlign or Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = opts.Order or 0,
		ZIndex = opts.ZIndex or 1,
		Role = primary and "Accent" or (ghost and "Ghost" or "Button"),
		Tier = primary and "OnAccent" or "Primary",
		TextRole = "Body",
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, radius), Role = "Small" }, button)

	local state = {
		enabled = opts.Enabled ~= false,
		hover = false,
		pressed = false,
		active = opts.Active == true,
		busy = false,
		last = 0,
	}

	local function faceColor()
		if primary or state.active then
			if state.pressed and state.enabled then
				return Tokens.accentPressed
			end
			if state.hover and state.enabled then
				return Tokens.accentHover
			end
			return Tokens.accent
		end
		if state.pressed and state.enabled then
			return Tokens.buttonPressed
		end
		if state.hover and state.enabled then
			return Tokens.buttonHover
		end
		return Tokens.button
	end

	local function faceAlpha()
		if not state.enabled then
			return ghost and 1 or 0.55
		end
		if state.active then
			return 0
		end
		if ghost then
			return (state.hover or state.pressed) and 0.88 or 0.94
		end
		return 0
	end

	local function textColor()
		if not state.enabled then
			return Tokens.textDisabled
		end
		if primary or state.active then
			return Tokens.onAccent
		end
		return Tokens.textPrimary
	end

	local function refresh()
		button.BackgroundColor3 = faceColor()
		button.BackgroundTransparency = faceAlpha()
		button.TextColor3 = textColor()
		button.Font = opts.Bold and boldFont() or themeFont()
		button.TextSize = labelSize
	end

	local function paint(seconds, style, dir)
		uiTween(button, {
			BackgroundColor3 = faceColor(),
			BackgroundTransparency = faceAlpha(),
		}, seconds, style, dir)
	end

	if Device.hover then
		connect(button.MouseEnter, function()
			if not state.enabled or state.hover then
				return
			end
			state.hover = true
			paint(CONFIG.Durations.Hover * 0.6, CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
		end)
		connect(button.MouseLeave, function()
			if not state.hover and not state.pressed then
				return
			end
			state.hover = false
			state.pressed = false
			paint(CONFIG.Durations.Hover * 1.25, CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
		end)
	end
	connect(button.MouseButton1Down, function()
		if not state.enabled or state.busy or state.pressed then
			return
		end
		state.pressed = true
		paint(CONFIG.Durations.Press * 0.6, CONFIG.Easing.Press, CONFIG.Easing.PressDir)
	end)
	connect(button.MouseButton1Up, function()
		if not state.pressed then
			return
		end
		state.pressed = false
		paint(CONFIG.Durations.Hover * 0.6, CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
	end)

	if opts.Divider then
		addRule(button)
	end

	local comp = { Instance = button }

	function comp:SetEnabled(value)
		state.enabled = value == true
		button.Active = state.enabled and not state.busy
		button.Selectable = state.enabled
		refresh()
	end

	function comp:SetBusy(value)
		state.busy = value == true
		button.TextTransparency = state.busy and 0.45 or 0
		button.Active = state.enabled and not state.busy
	end

	function comp:SetActive(value)
		state.active = value == true
		if not primary then
			button:SetAttribute("Tier", state.active and "OnAccent" or "Primary")
		end
		refresh()
	end

	function comp:SetText(value)
		button.Text = clean(tostring(value or ""), 64)
	end

	function comp:Get()
		return state.active
	end

	function comp:Bind(fn)
		connect(button.MouseButton1Click, function()
			if not state.enabled or state.busy then
				return
			end
			local now = os.clock()
			if now - state.last < 0.18 then
				return
			end
			state.last = now
			local ok, err = safeCall(fn, comp)
			if not ok then
				warn("[Blossom] button callback failed: " .. tostring(err))
				if toast then
					toast("Action failed", true)
				end
			end
		end)
	end

	function comp:Run(fn)
		if not state.enabled or state.busy then
			return
		end
		local now = os.clock()
		if now - state.last < 0.18 then
			return
		end
		state.last = now
		self:SetBusy(true)
		task.spawn(function()
			local ok, err = safeCall(fn, comp)
			if not State.destroyed then
				self:SetBusy(false)
			end
			if not ok then
				warn("[Blossom] button action failed: " .. tostring(err))
				if toast then
					toast("Action failed", true)
				end
			end
		end)
	end

	table.insert(REBUILD, refresh)
	return comp
end

local function makeToggle(parent, opts)
	opts = opts or {}
	local pillW, pillH, knobSize = 40, 22, 18
	if not Device.touch then
		pillW, pillH, knobSize = 34, 18, 14
	end
	local knobOff = math.floor((pillH - knobSize) / 2)
	local knobOn = pillW - knobSize - knobOff

	local row = new("TextButton", {
		Name = "Toggle",
		AutoButtonColor = false,
		Selectable = true,
		Text = "",
		BackgroundColor3 = Tokens.button,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, Metrics.row),
		LayoutOrder = opts.Order or 0,
		Role = "Ghost",
		ZIndex = 2,
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 6), Role = "Small" }, row)
	makeLabel(row, {
		Name = "Label",
		Text = clean(tostring(opts.Text or "Toggle"), 60),
		Tier = "Primary",
		TextRole = "Body",
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -(pillW + 34), 1, 0),
		Truncate = true,
		ZIndex = 3,
	})
	local pill = new("Frame", {
		Name = "Switch",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, pillW, 0, pillH),
		BackgroundColor3 = Tokens.track,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, pill)
	new("UIStroke", {
		Color = Tokens.textPrimary,
		Transparency = 0.88,
		Thickness = 1,
		Role = "Soft",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, pill)
	local knob = new("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, knobOff, 0.5, 0),
		Size = UDim2.new(0, knobSize, 0, knobSize),
		BackgroundColor3 = Tokens.textSecondary,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, pill)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, knob)

	local state = {
		value = opts.Value == true,
		enabled = opts.Enabled ~= false,
	}

	local function trackColor()
		if not state.enabled then
			return Tokens.track
		end
		return state.value and Tokens.accent or Tokens.track
	end

	local function knobColor()
		if not state.enabled then
			return Tokens.textDisabled
		end
		return state.value and Color3.new(1, 1, 1) or Tokens.textSecondary
	end

	local function knobPos()
		return UDim2.new(0, state.value and knobOn or knobOff, 0.5, 0)
	end

	local function paint(animated)
		if animated == false or Device.mobile then
			pill.BackgroundColor3 = trackColor()
			knob.BackgroundColor3 = knobColor()
			knob.Position = knobPos()
			return
		end
		uiTween(pill, { BackgroundColor3 = trackColor() }, CONFIG.Durations.Toggle, "Quad", "Out")
		uiTween(knob, { BackgroundColor3 = knobColor() }, CONFIG.Durations.Toggle, "Quad", "Out")
		uiTween(knob, { Position = knobPos() }, CONFIG.Durations.Toggle, "Quint", "Out")
	end

	local function refresh()
		pill.BackgroundColor3 = trackColor()
		knob.BackgroundColor3 = knobColor()
		knob.Position = knobPos()
		row.BackgroundColor3 = Tokens.button
	end

	connect(row.MouseButton1Click, function()
		if not state.enabled then
			return
		end
		state.value = not state.value
		paint(true)
		if opts.OnChange then
			local ok, err = safeCall(opts.OnChange, state.value)
			if not ok then
				warn("[Blossom] toggle callback failed: " .. tostring(err))
			end
		end
	end)
	if Device.hover then
		connect(row.MouseEnter, function()
			uiTween(row, { BackgroundTransparency = 0.94 }, CONFIG.Durations.Hover, "Quad", "Out")
		end)
		connect(row.MouseLeave, function()
			uiTween(row, { BackgroundTransparency = 1 }, CONFIG.Durations.Hover, "Quad", "Out")
		end)
	end

	if opts.Divider ~= false then
		addRule(row)
	end

	local comp = { Instance = row }
	function comp:Set(value)
		state.value = value == true
		paint(false)
	end
	function comp:Get()
		return state.value
	end
	function comp:SetEnabled(value)
		state.enabled = value == true
		paint(false)
	end
	table.insert(REBUILD, refresh)
	return comp
end

local function makeSlider(parent, opts)
	opts = opts or {}
	local minV = tonumber(opts.Min) or 0
	local maxV = tonumber(opts.Max) or 1
	if maxV < minV then
		minV, maxV = maxV, minV
	end
	local step = tonumber(opts.Step)
	if not step or step <= 0 then
		step = math.max((maxV - minV) / 50, 0.0001)
	end
	local wrap = new("Frame", {
		Name = "Slider",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, Device.touch and 66 or 56),
		LayoutOrder = opts.Order or 0,
	}, parent)
	wrap:SetAttribute("NoDrag", true)
	local header = new("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 6),
		Size = UDim2.new(1, -20, 0, 22),
	}, wrap)
	makeLabel(header, {
		Name = "Label",
		Text = clean(tostring(opts.Label or "Slider"), 48),
		Tier = "Primary",
		TextRole = "Body",
		Size = UDim2.new(1, -70, 1, 0),
		Truncate = true,
	})
	local valueLabel = makeLabel(header, {
		Name = "Value",
		Text = "",
		Tier = "Secondary",
		TextRole = "Caption",
		XAlign = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, 64, 1, 0),
		Position = UDim2.new(1, -64, 0, 0),
	})
	local track = new("Frame", {
		Name = "Track",
		Position = UDim2.new(0, 10, 0, Device.touch and 46 or 40),
		Size = UDim2.new(1, -20, 0, 4),
		BackgroundColor3 = Tokens.track,
		BorderSizePixel = 0,
		Role = "Track",
	}, wrap)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, track)
	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Tokens.fill,
		BorderSizePixel = 0,
		Role = "Fill",
	}, track)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, fill)
	local knobSize = Device.touch and 18 or 12
	local hit = new("Frame", {
		Name = "Hit",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, Device.touch and 40 or 24),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, track)
	hit:SetAttribute("NoDrag", true)
	local knob = new("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, knobSize, 0, knobSize),
		BackgroundColor3 = Tokens.textPrimary,
		BorderSizePixel = 0,
		Role = "SliderKnob",
	}, track)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, knob)

	local state = {
		value = clamp(tonumber(opts.Value) or minV, minV, maxV),
		dragging = false,
		offset = 0,
	}

	local function snap(value)
		return clamp(minV + math.floor((value - minV) / step + 0.5) * step, minV, maxV)
	end

	local function alphaOf(value)
		return maxV - minV <= 0 and 0 or (value - minV) / (maxV - minV)
	end

	local function formatValue(value)
		if type(opts.Format) == "function" then
			local ok, text = safeCall(opts.Format, value)
			if ok and text ~= nil then
				return clean(tostring(text), 16)
			end
		end
		local places = step >= 1 and 0 or (step >= 0.1 and 1 or 2)
		return string.format("%." .. places .. "f", value)
	end

	local function place(animated)
		local alpha = alphaOf(state.value)
		if animated and not Device.mobile then
			uiTween(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, CONFIG.Durations.Hover, CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
			uiTween(knob, { Position = UDim2.new(alpha, 0, 0.5, 0) }, CONFIG.Durations.Hover, CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
		else
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		end
		valueLabel.Text = formatValue(state.value)
	end

	local function commit(value, animated, raw)
		local nextValue = raw and clamp(value, minV, maxV) or snap(clamp(value, minV, maxV))
		local changed = nextValue ~= state.value
		state.value = nextValue
		place(animated)
		if changed and opts.OnChange then
			local ok, err = safeCall(opts.OnChange, state.value)
			if not ok then
				warn("[Blossom] slider callback failed: " .. tostring(err))
			end
		end
	end

	local function valueFromInput(input)
		local width = track.AbsoluteSize.X
		if width <= 0 then
			return state.value
		end
		local alpha = clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
		return minV + alpha * (maxV - minV)
	end

	local function inRect(obj, point, padY)
		local ap, as = obj.AbsolutePosition, obj.AbsoluteSize
		local pad = padY or 0
		return point.X >= ap.X and point.X <= ap.X + as.X and point.Y >= ap.Y - pad and point.Y <= ap.Y + as.Y + pad
	end

	local function visibleOnScreen()
		local node = wrap
		while node and node ~= State.gui do
			if node:IsA("GuiObject") and node.Visible ~= true then
				return false
			end
			node = node.Parent
		end
		return true
	end

	connectSlider(UserInputService.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if State.customizeOpen or not visibleOnScreen() then
			return
		end
		local point = Vector2.new(input.Position.X, input.Position.Y)
		if not inRect(hit, point, 8) then
			return
		end
		local fromKnob = inRect(knob, point, 6)
		state.offset = fromKnob and (state.value - valueFromInput(input)) or 0
		state.dragging = true
		if not fromKnob then
			commit(valueFromInput(input), false, true)
		end
	end)
	connectSlider(UserInputService.InputChanged, function(input)
		if not state.dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				state.dragging = false
				state.offset = 0
				commit(state.value, true)
				return
			end
		elseif input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		commit(valueFromInput(input) + state.offset, false, true)
	end)
	connectSlider(UserInputService.InputEnded, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not state.dragging then
			return
		end
		state.dragging = false
		state.offset = 0
		commit(state.value, true)
	end)
	if Device.hover then
		connect(hit.MouseEnter, function()
			uiTween(knob, { Size = UDim2.new(0, knobSize + 3, 0, knobSize + 3) }, CONFIG.Durations.Hover, "Quad", "Out")
		end)
		connect(hit.MouseLeave, function()
			if state.dragging then
				return
			end
			uiTween(knob, { Size = UDim2.new(0, knobSize, 0, knobSize) }, CONFIG.Durations.Hover, "Quad", "Out")
		end)
	end

	local function refresh()
		track.BackgroundColor3 = Tokens.track
		fill.BackgroundColor3 = Tokens.accent
		knob.BackgroundColor3 = Tokens.textPrimary
		valueLabel.TextColor3 = Tokens.textSecondary
	end

	local comp = { Instance = wrap }
	function comp:Set(value)
		commit(tonumber(value) or state.value, false)
	end
	function comp:Get()
		return state.value
	end
	table.insert(REBUILD, refresh)
	place(false)
	if opts.Divider ~= false then
		addRule(wrap)
	end
	return comp
end

local function makeInput(parent, opts)
	opts = opts or {}
	local wrap = new("Frame", {
		Name = "Input",
		BackgroundColor3 = Tokens.base,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, Metrics.input),
		LayoutOrder = opts.Order or 0,
		Role = "Input",
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, math.max(4, Metrics.corner - 4)), Role = "Small" }, wrap)
	local stroke = new("UIStroke", {
		Color = Tokens.textPrimary,
		Transparency = State.theme.StrokeTransparency,
		Thickness = 1,
		Role = "Edge",
	}, wrap)
	local box = new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Text = opts.Text or "",
		PlaceholderText = clean(tostring(opts.Placeholder or ""), 80),
		Font = themeFont(),
		TextSize = Metrics.bodySize,
		TextColor3 = Tokens.textPrimary,
		PlaceholderColor3 = Tokens.textSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Tier = "Primary",
		TextRole = "Body",
	}, wrap)

	connect(box.Focused, function()
		playTween(stroke, ti(duration(CONFIG.Durations.Hover), "Quad", "Out"), {
			Color = Tokens.accent,
			Transparency = 0.25,
		})
	end)
	connect(box.FocusLost, function(enterPressed)
		playTween(stroke, ti(duration(CONFIG.Durations.Hover), "Quad", "Out"), {
			Color = Tokens.textPrimary,
			Transparency = State.theme.StrokeTransparency,
		})
		if enterPressed and opts.OnSubmit then
			local ok, err = safeCall(opts.OnSubmit, box.Text)
			if not ok then
				warn("[Blossom] input callback failed: " .. tostring(err))
			end
		end
	end)

	local comp = { Instance = wrap, Box = box }
	function comp:GetText()
		return box.Text
	end
	function comp:SetText(value)
		box.Text = clean(tostring(value or ""), 400)
	end
	table.insert(REBUILD, function()
		box.TextColor3 = Tokens.textPrimary
		box.PlaceholderColor3 = Tokens.textSecondary
		box.Font = themeFont()
		box.TextSize = Metrics.bodySize
		wrap.BackgroundColor3 = Tokens.base
	end)
	return comp
end

local function makeRow(parent, opts)
	opts = opts or {}
	local width = tonumber(opts.ControlWidth) or 160
	local row = new("Frame", {
		Name = "Row",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, tonumber(opts.Height) or Metrics.row),
		LayoutOrder = opts.Order or 0,
	}, parent)
	makeLabel(row, {
		Name = "Label",
		Text = clean(tostring(opts.Label or ""), 48),
		Tier = "Primary",
		TextRole = "Body",
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -(width + 24), 1, 0),
		Truncate = true,
	})
	if type(opts.Build) == "function" then
		local ok, err = safeCall(opts.Build, row)
		if not ok then
			warn("[Blossom] row build failed: " .. tostring(err))
		end
	end
	if opts.Divider ~= false then
		addRule(row)
	end
	return row
end

local function makeListRow(parent, opts)
	opts = opts or {}
	local row = new("Frame", {
		Name = "ListRow",
		BackgroundColor3 = Tokens.button,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 50),
		LayoutOrder = opts.Order or 0,
		Role = "Ghost",
	}, parent)
	makeLabel(row, {
		Name = "Title",
		Text = clean(tostring(opts.Title or "Row"), 40),
		Tier = "Primary",
		TextRole = "Body",
		Position = UDim2.new(0, 10, 0, 6),
		Size = UDim2.new(1, -20, 0, 20),
		Truncate = true,
	})
	makeLabel(row, {
		Name = "Subtitle",
		Text = clean(tostring(opts.Subtitle or ""), 80),
		Tier = "Secondary",
		TextRole = "Caption",
		Position = UDim2.new(0, 10, 0, 26),
		Size = UDim2.new(1, -20, 0, 18),
		Truncate = true,
	})
	if opts.Divider ~= false then
		addRule(row)
	end
	return { Instance = row }
end

local function makeIcon(parent, kind)
	local box = new("Frame", {
		Name = "Icon",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, parent)
	local function shape(cx, cy, w, h, rot, radius, filled)
		local part = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, cx, 0, cy),
			Size = UDim2.new(0, w, 0, h),
			BackgroundColor3 = Tokens.textDisabled,
			BackgroundTransparency = filled and 0 or 1,
			BorderSizePixel = 0,
			Rotation = rot or 0,
			ZIndex = 3,
		}, box)
		new("UICorner", { CornerRadius = UDim.new(0, radius or 1) }, part)
		if not filled then
			new("UIStroke", { Color = Tokens.textDisabled, Transparency = 0, Thickness = 1.6 }, part)
		end
		return part
	end
	if kind == "sliders" then
		shape(8, 5, 13, 2, 0, 1, true)
		shape(8, 11, 13, 2, 0, 1, true)
		shape(5, 5, 5, 5, 0, 2.5, true)
		shape(11, 11, 5, 5, 0, 2.5, true)
	elseif kind == "diamond" then
		shape(8, 8, 8, 8, 45, 2, true)
	elseif kind == "ring" then
		shape(8, 8, 12, 12, 0, 6, false)
		shape(8, 4.2, 4, 4, 0, 2, true)
	elseif kind == "cog" then
		shape(8, 8, 11, 11, 0, 5.5, false)
		shape(8, 1.7, 2, 3, 0, 1, true)
		shape(8, 14.3, 2, 3, 0, 1, true)
		shape(1.7, 8, 3, 2, 0, 1, true)
		shape(14.3, 8, 3, 2, 0, 1, true)
	elseif kind == "camera" then
		shape(8, 9.5, 14, 9, 0, 3, false)
		shape(8, 3.6, 5, 3, 0, 1.5, true)
		shape(8, 9.5, 4.5, 4.5, 0, 2.25, false)
	elseif kind == "home" then
		shape(8, 10.6, 10, 7.5, 0, 2, false)
		shape(5.2, 4.9, 6.6, 2.2, -40, 1.1, true)
		shape(10.8, 4.9, 6.6, 2.2, 40, 1.1, true)
	elseif kind == "list" then
		shape(8, 4, 13, 2, 0, 1, true)
		shape(8, 8, 13, 2, 0, 1, true)
		shape(5.5, 12, 8, 2, 0, 1, true)
	else
		shape(4.5, 4.5, 6, 6, 0, 2, true)
		shape(11.5, 4.5, 6, 6, 0, 2, true)
		shape(4.5, 11.5, 6, 6, 0, 2, true)
		shape(11.5, 11.5, 6, 6, 0, 2, true)
	end
	return box
end

local function tintIcon(box, color, animated)
	if not box then
		return
	end
	local info = ti(duration(CONFIG.Durations.Hover), "Quad", "Out")
	for _, child in ipairs(box:GetChildren()) do
		if child:IsA("Frame") then
			local stroke = child:FindFirstChildOfClass("UIStroke")
			if stroke then
				if animated and not Device.mobile then
					playTween(stroke, info, { Color = color })
				else
					stroke.Color = color
				end
			elseif animated and not Device.mobile then
				playTween(child, info, { BackgroundColor3 = color })
			else
				child.BackgroundColor3 = color
			end
		end
	end
end
local CONTROL_TYPES = { Button = true, Toggle = true, Slider = true, Input = true }
local buildModulePage
local runModule, stopModule

local function recordModuleError(id, message)
	table.insert(Blossom.ModuleErrors, {
		Id = tostring(id or "?"),
		Message = tostring(message),
		Time = os.clock(),
	})
	warn("[Blossom] module " .. tostring(id) .. ": " .. tostring(message))
end

local function moduleContext(module)
	return {
		Module = module,
		Config = CONFIG,
		Blossom = Blossom,
		Toast = function(text, isError)
			if toast then
				toast(text, isError)
			end
		end,
		Log = function(...)
			print("[Blossom/" .. module.Id .. "]", ...)
		end,
		IsRunning = function()
			return module.Running == true
		end,
		SetStatus = function(text)
			module.Status = clean(tostring(text or ""), 40)
			if module.Refresh then
				safeCall(module.Refresh)
			end
		end,
	}
end

local function sanitizeModule(spec)
	if type(spec) ~= "table" then
		return nil, "module must be a table"
	end
	local id = clean(tostring(spec.Id or spec.id or ""), 32)
	if id == "" then
		return nil, "module Id is required"
	end
	if not id:match("^[%w_%-]+$") then
		return nil, "module Id may only use letters, numbers, _ and -"
	end
	if Blossom.ModuleById[id] then
		return nil, "duplicate module Id '" .. id .. "'"
	end
	local controls = {}
	if spec.Controls ~= nil then
		if type(spec.Controls) ~= "table" then
			return nil, "Controls must be a table"
		end
		for index, control in ipairs(spec.Controls) do
			if type(control) ~= "table" or not CONTROL_TYPES[control.Type] then
				return nil, "Controls[" .. index .. "] has an unknown Type"
			end
			table.insert(controls, control)
		end
	end
	local title = clean(tostring(spec.Title or spec.title or id), 24)
	return {
		Id = id,
		Title = title ~= "" and title or id,
		Subtitle = clean(tostring(spec.Subtitle or spec.subtitle or "module"), 60),
		Icon = tostring(spec.Icon or "grid"),
		Priority = tonumber(spec.Priority) or 50,
		Controls = controls,
		Run = type(spec.Run) == "function" and spec.Run or nil,
		Stop = type(spec.Stop) == "function" and spec.Stop or nil,
		OnMount = type(spec.OnMount) == "function" and spec.OnMount or nil,
		OnUnmount = type(spec.OnUnmount) == "function" and spec.OnUnmount or nil,
		AutoRun = spec.AutoRun == true,
		AutoStarted = false,
		Running = false,
		Status = "idle",
		Page = nil,
		Refresh = nil,
		Source = clean(tostring(spec.Source or "script"), 80),
	}
end

function Blossom.RegisterModule(spec)
	if State.destroyed then
		return nil, "UI destroyed"
	end
	local module, err = sanitizeModule(spec)
	if not module then
		recordModuleError(type(spec) == "table" and (spec.Id or spec.id) or "?", err)
		return nil, err
	end
	table.insert(Blossom.Modules, module)
	Blossom.ModuleById[module.Id] = module
	if State.ready and buildModulePage then
		local ok, mountErr = safeCall(buildModulePage, module)
		if not ok then
			recordModuleError(module.Id, mountErr)
		end
	end
	if State.ready and State.rebuildModulesPage then
		safeCall(State.rebuildModulesPage)
	end
	if State.ready and State.autoExecute and module.AutoRun and module.Run and not module.AutoStarted then
		module.AutoStarted = true
		runModule(module)
	end
	return module
end

function Blossom.UnregisterModule(id)
	local module = Blossom.ModuleById[tostring(id)]
	if not module then
		return false
	end
	stopModule(module, true)
	if module.OnUnmount then
		safeCall(module.OnUnmount, moduleContext(module))
	end
	if State.onModuleUnregistered then
		local ok, err = safeCall(State.onModuleUnregistered, module)
		if not ok then
			recordModuleError(module.Id, err)
		end
	end
	if module.Page and module.Page.Parent then
		module.Page.Parent.Visible = false
	end
	if module.NavRow then
		module.NavRow.Visible = false
	end
	Blossom.ModuleById[module.Id] = nil
	for index, entry in ipairs(Blossom.Modules) do
		if entry == module then
			table.remove(Blossom.Modules, index)
			break
		end
	end
	if State.rebuildModulesPage then
		safeCall(State.rebuildModulesPage)
	end
	return true
end

function Blossom.GetModules()
	return Blossom.Modules
end

runModule = function(module)
	if module.Running or type(module.Run) ~= "function" then
		return
	end
	module.Running = true
	module.Status = "running"
	module.Error = nil
	module.StartedAt = os.clock()
	if module.Refresh then
		safeCall(module.Refresh)
	end
	refreshAll()
	task.spawn(function()
		local ok, err = safeCall(module.Run, moduleContext(module))
		module.Running = false
		if not ok then
			module.Status = "error"
			module.Error = tostring(err)
			recordModuleError(module.Id, err)
			if toast then
				toast(module.Title .. " failed", true)
			end
		else
			module.Status = "idle"
		end
		if module.Refresh and not State.destroyed then
			safeCall(module.Refresh)
		end
		if not State.destroyed then
			refreshAll()
		end
	end)
end

stopModule = function(module, silent)
	module.Running = false
	if type(module.Stop) == "function" then
		local ok, err = safeCall(module.Stop, moduleContext(module))
		if not ok then
			module.Status = "error"
			module.Error = tostring(err)
			recordModuleError(module.Id, err)
			if toast and not silent then
				toast(module.Title .. " stop failed", true)
			end
		end
	end
	if module.Status ~= "error" then
		module.Status = "idle"
	end
	if module.Refresh and not State.destroyed then
		safeCall(module.Refresh)
	end
	if not State.destroyed then
		refreshAll()
	end
end

local function executorFn(name)
	local ok, fn = pcall(function()
		return _G[name]
	end)
	if ok and type(fn) == "function" then
		return fn
	end
	return nil
end

local function registerExternal(entry, source)
	if type(entry) == "function" then
		local ok, spec = safeCall(entry)
		if not ok then
			recordModuleError(source, spec)
			return false
		end
		entry = spec
	end
	if type(entry) ~= "table" then
		recordModuleError(source, "module did not return a table")
		return false
	end
	entry.Source = source
	return Blossom.RegisterModule(entry) ~= nil
end

local function loadFromGlobal()
	local list = rawget(_G, "BLOSSOM_MODULES")
	if type(list) ~= "table" then
		return 0
	end
	local loaded = 0
	for index, entry in ipairs(list) do
		if registerExternal(entry, "global#" .. index) then
			loaded = loaded + 1
		end
	end
	return loaded
end

local function loadFromReplicatedStorage()
	local folder = ReplicatedStorage:FindFirstChild("BlossomModules") or ReplicatedStorage:FindFirstChild("Blossom")
	if not folder then
		return 0
	end
	local modulesFolder = folder:FindFirstChild("Modules") or folder
	local loaded = 0
	for _, child in ipairs(modulesFolder:GetChildren()) do
		if child:IsA("ModuleScript") then
			local ok, result = pcall(require, child)
			if ok then
				if registerExternal(result, child:GetFullName()) then
					loaded = loaded + 1
				end
			else
				recordModuleError(child.Name, result)
			end
		end
	end
	return loaded
end

local function loadFromFiles()
	local listfiles = executorFn("listfiles")
	local readfile = executorFn("readfile")
	local loadstringFn = executorFn("loadstring") or loadstring
	if not listfiles or not readfile or not loadstringFn then
		return 0
	end
	local ok, files = pcall(listfiles, "Blossom/modules")
	if not ok or type(files) ~= "table" then
		return 0
	end
	local loaded = 0
	for _, path in ipairs(files) do
		if type(path) == "string" and path:match("%.luau?$") then
			local readOk, source = pcall(readfile, path)
			if readOk and type(source) == "string" then
				local chunk, compileErr = loadstringFn(source, "=" .. path)
				if chunk then
					local runOk, result = pcall(chunk)
					if not runOk then
						recordModuleError(path, result)
					elseif type(result) == "table" then
						if registerExternal(result, path) then
							loaded = loaded + 1
						end
					end
				else
					recordModuleError(path, compileErr)
				end
			end
		end
	end
	return loaded
end

function Blossom.LoadModules()
	local before = #Blossom.Modules
	loadFromGlobal()
	loadFromReplicatedStorage()
	loadFromFiles()
	if State.rebuildModulesPage then
		safeCall(State.rebuildModulesPage)
	end
	return #Blossom.Modules - before
end

function Blossom.SetSkin(name)
	local skin = SKINS[name]
	if not skin then
		return false
	end
	applyTheme(skin, true)
	saveProfile()
	if State.skinChips then
		for skinName, chip in pairs(State.skinChips) do
			chip:SetActive(skinName == name)
		end
	end
	return true
end
local CATEGORY_ICONS = {
	Home = "home",
	Loader = "ring",
	Modules = "grid",
	Settings = "cog",
	Controls = "sliders",
}

local ShellConnections = {}
local ShellConnectionStart, ShellConnectionEnd = 0, 0
local ShellRebuildStart, ShellRebuildEnd = 0, 0
local setPage
local addPage
local mountModule
local buildMain

local function connectShell(signal, fn)
	local conn = signal:Connect(fn)
	table.insert(ShellConnections, conn)
	return conn
end

local function clearShell()
	for i = #ShellConnections, 1, -1 do
		pcall(function()
			ShellConnections[i]:Disconnect()
		end)
		table.remove(ShellConnections, i)
	end
	clearSliderConnections()
	if ShellConnectionStart > 0 and ShellConnectionEnd >= ShellConnectionStart then
		for i = ShellConnectionEnd, ShellConnectionStart, -1 do
			local conn = Connections[i]
			if conn then
				pcall(function()
					conn:Disconnect()
				end)
			end
			table.remove(Connections, i)
		end
	end
	ShellConnectionStart, ShellConnectionEnd = 0, 0
	if ShellRebuildStart > 0 and ShellRebuildEnd >= ShellRebuildStart then
		for i = ShellRebuildEnd, ShellRebuildStart, -1 do
			table.remove(REBUILD, i)
		end
	end
	ShellRebuildStart, ShellRebuildEnd = 0, 0
	if State.main then
		pcall(function()
			State.main:Destroy()
		end)
	end
	State.main = nil
	State.mainColumn = nil
	State.sidebar = nil
	State.content = nil
	State.navList = nil
	State.bannerTitle = nil
	State.bannerSub = nil
	State.pagesHost = nil
	State.pages = {}
	State.pageMeta = {}
	State.navRows = {}
	State.pageIndexById = {}
	State.activePage = 0
	State.skinChips = {}
	ThemeCache.list = nil
end

local drag = { active = false, start = nil, center = nil }

local function clampCenter(center)
	local vp = viewport()
	local halfW = State.mainColumn.AbsoluteSize.X * 0.5
	local halfH = State.mainColumn.AbsoluteSize.Y * 0.5
	local minX = halfW + 8
	local minY = halfH + 8
	return Vector2.new(
		clamp(center.X, minX, math.max(minX, vp.X - halfW - 8)),
		clamp(center.Y, minY, math.max(minY, vp.Y - halfH - 8))
	)
end

local function applyCenter(center)
	State.windowCenter = center
	local scale = (State.rootScale and State.rootScale.Scale) or 1
	State.mainColumn.Position = UDim2.fromOffset(center.X / scale, center.Y / scale)
end

local function titlebarBlockedAt(point, titlebar)
	local ok, list = pcall(function()
		return UserInputService:GetGuiObjectsAtPosition(point.X, point.Y)
	end)
	if not ok or type(list) ~= "table" then
		return false
	end
	for _, object in ipairs(list) do
		if object:IsA("TextButton") or object:IsA("ImageButton") then
			local node = object
			while node and node ~= titlebar do
				node = node.Parent
			end
			if node == titlebar then
				return true
			end
		end
	end
	return false
end

local function setBackdrop(level)
	if not State.backdrop then
		return
	end
	State.backdrop:SetAttribute("BackdropLevel", level)
	State.backdrop.Visible = true
	local color, transparency = Tokens.dim, State.theme.DimTransparency
	if level == "loading" then
		color = hex(CONFIG.Loading.BackdropColor)
		transparency = CONFIG.Loading.BackdropTransparency
	elseif level == "main" then
		transparency = 1
	end
	uiTween(State.backdrop, {
		BackgroundTransparency = transparency,
		BackgroundColor3 = color,
	}, CONFIG.Durations.Fade, CONFIG.Easing.Fade, CONFIG.Easing.FadeDir)
end

local function sortedModules()
	local list = {}
	for index, module in ipairs(Blossom.Modules) do
		list[index] = module
	end
	table.sort(list, function(a, b)
		if a.Priority ~= b.Priority then
			return a.Priority < b.Priority
		end
		return a.Title < b.Title
	end)
	return list
end

local function placeRight(instance, width, inset)
	instance.AnchorPoint = Vector2.new(1, 0.5)
	instance.Position = UDim2.new(1, -(inset or 10), 0.5, 0)
	instance.Size = UDim2.new(0, width, 0, instance.Size.Y.Offset)
end

local function smallButton(parent, text, width, order, variant)
	local button = makeButton(parent, {
		Text = text,
		Variant = variant,
		Order = order,
		Size = UDim2.new(0, width, 0, math.max(28, Metrics.button - 4)),
		TextSize = Metrics.captionSize + 1,
	})
	return button
end

addPage = function(title, subtitle, icon, id)
	local index = #State.pages + 1
	local page = new("Frame", {
		Name = "Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Visible = index == 1,
		ZIndex = index == 1 and 3 or 1,
	}, State.pagesHost)
	local scroll = new("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = Device.touch and 3 or 2,
		ScrollBarImageColor3 = Tokens.accent,
		ScrollBarImageTransparency = 0.6,
		ScrollingEnabled = true,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
	}, page)
	new("UIPadding", {
		PaddingTop = UDim.new(0, Metrics.compact and 10 or 12),
		PaddingBottom = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, Metrics.compact and 8 or 12),
		PaddingRight = UDim.new(0, Metrics.compact and 8 or 12),
	}, scroll)
	new("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
	}, scroll)

	local navWidth = clamp(74 + #title * 6, 98, 160)
	local row = new("TextButton", {
		Name = "NavRow",
		Size = Metrics.compact and UDim2.new(0, navWidth, 0, Metrics.nav - 10) or UDim2.new(1, 0, 0, Metrics.nav),
		BackgroundColor3 = Tokens.button,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Selectable = true,
		LayoutOrder = index,
		ZIndex = 6,
		Role = "Ghost",
	}, State.navList)
	new("UICorner", { CornerRadius = UDim.new(0, 8), Role = "Small" }, row)
	local iconBox = makeIcon(row, CATEGORY_ICONS[title] or icon or "grid")
	if Metrics.compact then
		iconBox.Position = UDim2.new(0, 10, 0.5, 0)
		iconBox.Size = UDim2.new(0, 14, 0, 14)
	end
	local label = makeLabel(row, {
		Text = clean(title, 24),
		Tier = "Secondary",
		TextRole = "Body",
		Position = Metrics.compact and UDim2.new(0, 30, 0, 0) or UDim2.new(0, 36, 0, 0),
		Size = Metrics.compact and UDim2.new(1, -36, 1, 0) or UDim2.new(1, -44, 1, 0),
		Truncate = true,
		ZIndex = 7,
	})
	connect(row.MouseButton1Click, function()
		setPage(index)
	end)
	if Device.hover then
		connect(row.MouseEnter, function()
			if index ~= State.activePage then
				uiTween(row, { BackgroundTransparency = 0.94 }, CONFIG.Durations.Hover, "Quad", "Out")
			end
		end)
		connect(row.MouseLeave, function()
			if index ~= State.activePage then
				uiTween(row, { BackgroundTransparency = 1 }, CONFIG.Durations.Hover, "Quad", "Out")
			end
		end)
	end

	State.pages[index] = page
	State.pageMeta[index] = { title = title, subtitle = subtitle or "", icon = icon or "grid" }
	State.navRows[index] = { row = row, icon = iconBox, label = label }
	if id then
		State.pageIndexById[id] = index
	end
	return scroll, row
end

setPage = function(index, instant)
	local target = State.pages[index]
	if not target then
		return
	end
	if index == State.activePage then
		return
	end
	local previous = State.pages[State.activePage]
	State.activePage = index
	if previous then
		previous.Visible = false
	end
	target.Visible = true
	target.ZIndex = 3
	if not instant and not Device.mobile then
		target.Position = UDim2.fromOffset(0, 10)
		playTween(target, ti(duration(CONFIG.Durations.Slide), CONFIG.Easing.Slide, CONFIG.Easing.SlideDir), { Position = UDim2.fromOffset(0, 0) })
	else
		target.Position = UDim2.fromOffset(0, 0)
	end
	for i, item in ipairs(State.navRows) do
		local active = i == index
		item.row:SetAttribute("Role", active and "Accent" or "Ghost")
		item.row.BackgroundColor3 = active and Tokens.accent or Tokens.button
		item.row.BackgroundTransparency = active and 0.84 or 1
		item.label:SetAttribute("Tier", active and "Accent" or "Secondary")
		item.label.TextColor3 = active and Tokens.accent or Tokens.textSecondary
		tintIcon(item.icon, active and Tokens.accent or Tokens.textDisabled, false)
	end
	local meta = State.pageMeta[index]
	if State.bannerTitle and meta then
		State.bannerTitle.Text = meta.title
		State.bannerSub.Text = meta.subtitle or ""
		if not instant and not Device.mobile then
			State.bannerTitle.TextTransparency = 1
			uiTween(State.bannerTitle, { TextTransparency = 0 }, 0.2, "Quad", "Out")
			State.bannerSub.TextTransparency = 1
			uiTween(State.bannerSub, { TextTransparency = 0 }, 0.26, "Quad", "Out")
		else
			State.bannerTitle.TextTransparency = 0
			State.bannerSub.TextTransparency = 0
		end
	end
end

State.onModuleUnregistered = function(module)
	local index = module.Page and State.pageIndexById["module:" .. module.Id]
	if index and State.activePage == index then
		setPage(1, true)
	end
end

local function buildTitlebar(parent)
	local bar = new("Frame", {
		Name = "Titlebar",
		Size = UDim2.new(1, 0, 0, Metrics.topbar),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
	}, parent)
	new("Frame", {
		Name = "Sep",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Tokens.divider,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Role = "Divider",
		ZIndex = 6,
	}, bar)
	local mark = new("Frame", {
		Name = "Mark",
		Position = UDim2.new(0, 16, 0.5, -3),
		Size = UDim2.new(0, 6, 0, 6),
		BackgroundColor3 = Tokens.accent,
		BorderSizePixel = 0,
		Role = "Accent",
		ZIndex = 7,
	}, bar)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, mark)
	makeLabel(bar, {
		Name = "Wordmark",
		Text = clean(CONFIG.Brand.Name, 24),
		Tier = "Primary",
		TextRole = "Caption",
		Bold = true,
		FixedSize = true,
		TextSize = 13,
		Position = UDim2.new(0, 28, 0, 0),
		Size = UDim2.new(0, 140, 1, 0),
		ZIndex = 7,
	})
	local closeSize = Device.touch and 40 or 26
	local lockSize = Device.touch and 54 or 44
	local close = makeButton(bar, {
		Text = "X",
		Variant = "Ghost",
		Size = UDim2.new(0, closeSize, 0, closeSize),
		TextSize = 12,
		Bold = true,
		Radius = 6,
		ZIndex = 7,
	})
	close.Instance.AnchorPoint = Vector2.new(1, 0.5)
	close.Instance.Position = UDim2.new(1, -6, 0.5, 0)
	close:Bind(function()
		toggleMenu()
	end)
	local lock = makeButton(bar, {
		Text = State.windowLocked and "Locked" or "Lock",
		Variant = "Ghost",
		Size = UDim2.new(0, lockSize, 0, closeSize),
		TextSize = 10,
		Bold = true,
		Radius = 6,
		ZIndex = 7,
	})
	lock.Instance.AnchorPoint = Vector2.new(1, 0.5)
	lock.Instance.Position = UDim2.new(1, -(closeSize + 10), 0.5, 0)
	lock:SetActive(State.windowLocked)
	lock:Bind(function()
		State.windowLocked = not State.windowLocked
		lock:SetText(State.windowLocked and "Locked" or "Lock")
		lock:SetActive(State.windowLocked)
		if State.windowLocked then
			drag.active = false
		end
		saveProfile()
		toast(State.windowLocked and "Window locked" or "Window unlocked")
	end)
	if Metrics.compact then
		local gear = makeButton(bar, {
			Text = "",
			Variant = "Ghost",
			Size = UDim2.new(0, closeSize, 0, closeSize),
			Radius = 6,
			ZIndex = 7,
		})
		gear.Instance.AnchorPoint = Vector2.new(1, 0.5)
		gear.Instance.Position = UDim2.new(1, -(closeSize + lockSize + 20), 0.5, 0)
		local icon = makeIcon(gear.Instance, "cog")
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		gear:Bind(function()
			openCustomize("Theme")
		end)
	else
		makeLabel(bar, {
			Name = "Version",
			Text = "v" .. Blossom.Version,
			Tier = "Disabled",
			TextRole = "Caption",
			FixedSize = true,
			TextSize = 11,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -(closeSize + lockSize + 18), 0.5, 0),
			Size = UDim2.new(0, 40, 1, 0),
			XAlign = Enum.TextXAlignment.Right,
			ZIndex = 7,
		})
	end
	return bar
end

local function buildSidebar(parent)
	local sidebar = new("Frame", {
		Name = "Sidebar",
		Position = UDim2.new(0, 8, 0, Metrics.topbar + 8),
		Size = UDim2.new(0, Metrics.sidebar, 1, -(Metrics.topbar + 16)),
		BackgroundColor3 = Tokens.sidebar,
		BorderSizePixel = 0,
		Role = "Sidebar",
		ZIndex = 4,
	}, parent)
	State.sidebar = sidebar
	new("UICorner", { CornerRadius = UDim.new(0, Metrics.corner), Role = "Corner" }, sidebar)
	new("UIStroke", {
		Color = Tokens.textPrimary,
		Transparency = math.min(1, State.theme.StrokeTransparency + 0.04),
		Thickness = 1,
		Role = "CardEdge",
	}, sidebar)
	local avatar = new("Frame", {
		Name = "Avatar",
		Position = UDim2.new(0, 14, 0, 13),
		Size = UDim2.new(0, 34, 0, 34),
		BackgroundColor3 = Tokens.accent,
		BorderSizePixel = 0,
		Role = "Accent",
		ZIndex = 6,
	}, sidebar)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, avatar)
	new("UIStroke", { Color = Tokens.textPrimary, Transparency = 0.84, Thickness = 1, Role = "Soft" }, avatar)
	makeLabel(avatar, {
		Name = "Letter",
		Text = string.sub(clean(CONFIG.Brand.Name, 24), 1, 1),
		Tier = "OnAccent",
		TextRole = "Caption",
		Bold = true,
		FixedSize = true,
		TextSize = 16,
		Size = UDim2.fromScale(1, 1),
		XAlign = Enum.TextXAlignment.Center,
		ZIndex = 7,
	})
	local portraitId = tostring(CONFIG.Brand.AvatarImageId or ""):gsub("%D", "")
	if portraitId ~= "" then
		new("ImageLabel", {
			Name = "Portrait",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://" .. portraitId,
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 8,
		}, avatar)
	elseif State.player then
		task.spawn(function()
			local ok, url = pcall(function()
				return Players:GetUserThumbnailAsync(State.player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
			end)
			if ok and type(url) == "string" and url ~= "" and not State.destroyed and avatar.Parent then
				local image = new("ImageLabel", {
					Name = "Portrait",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Image = url,
					ScaleType = Enum.ScaleType.Crop,
					ZIndex = 8,
				}, avatar)
				new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, image)
			end
		end)
	end
	makeLabel(sidebar, {
		Name = "Brand",
		Text = clean(CONFIG.Brand.Name, 24),
		Tier = "Primary",
		TextRole = "Body",
		Bold = true,
		FixedSize = true,
		TextSize = 15,
		Position = UDim2.new(0, 56, 0, 12),
		Size = UDim2.new(1, -64, 0, 20),
		Truncate = true,
		ZIndex = 6,
	})
	makeLabel(sidebar, {
		Name = "Tag",
		Text = clean(CONFIG.Brand.Tag, 24),
		Tier = "Secondary",
		TextRole = "Caption",
		FixedSize = true,
		TextSize = 11,
		Position = UDim2.new(0, 56, 0, 30),
		Size = UDim2.new(1, -64, 0, 16),
		ZIndex = 6,
	})
	State.navList = new("ScrollingFrame", {
		Name = "Nav",
		Position = UDim2.new(0, 8, 0, 66),
		Size = UDim2.new(1, -16, 1, -130),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0,
		ZIndex = 5,
	}, sidebar)
	new("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
	}, State.navList)
	local footer = new("Frame", {
		Name = "Footer",
		Position = UDim2.new(0, 0, 1, -58),
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
	}, sidebar)
	new("Frame", {
		Name = "Sep",
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 0, 1),
		BackgroundColor3 = Tokens.divider,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Role = "Divider",
		ZIndex = 6,
	}, footer)
	local customize = smallButton(footer, "Customize", 92, 1, "Ghost")
	customize.Instance.AnchorPoint = Vector2.new(0, 0)
	customize.Instance.Position = UDim2.new(0, 10, 0, 8)
	customize:Bind(function()
		openCustomize("Theme")
	end)
	makeLabel(footer, {
		Name = "Hint",
		Text = "drag to move",
		Tier = "Disabled",
		TextRole = "Caption",
		FixedSize = true,
		TextSize = 10,
		Position = UDim2.new(0, 10, 0, 38),
		Size = UDim2.new(1, -20, 0, 14),
		Truncate = true,
		ZIndex = 6,
	})
end

local function buildCompactNav(parent)
	State.navList = new("ScrollingFrame", {
		Name = "Nav",
		Position = UDim2.new(0, 0, 0, Metrics.topbar),
		Size = UDim2.new(1, 0, 0, Metrics.nav),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		ZIndex = 5,
	}, parent)
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
	}, State.navList)
	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, State.navList)
end

local function buildContent(parent)
	local content = new("Frame", {
		Name = "Content",
		Position = Metrics.compact and UDim2.new(0, 0, 0, Metrics.topbar + Metrics.nav) or UDim2.new(0, Metrics.sidebar, 0, Metrics.topbar),
		Size = Metrics.compact and UDim2.new(1, 0, 1, -(Metrics.topbar + Metrics.nav)) or UDim2.new(1, -Metrics.sidebar, 1, -Metrics.topbar),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, parent)
	State.content = content
	local banner = new("Frame", {
		Name = "Banner",
		Size = UDim2.new(1, 0, 0, Metrics.banner),
		BackgroundColor3 = Tokens.base,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1,
	}, content)
	new("UIGradient", { Role = "Header" }, banner)
	local mark = new("Frame", {
		Name = "Mark",
		Position = UDim2.new(0, 16, 0, 22),
		Size = UDim2.new(0, 3, 0, 16),
		BackgroundColor3 = Tokens.accent,
		BorderSizePixel = 0,
		Role = "Accent",
		ZIndex = 4,
	}, banner)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, mark)
	State.bannerTitle = makeLabel(banner, {
		Name = "Title",
		Text = "Home",
		Tier = "Primary",
		TextRole = "Title",
		Bold = true,
		FixedSize = true,
		TextSize = Metrics.titleSize,
		Position = UDim2.new(0, 27, 0, Metrics.compact and 14 or 18),
		Size = UDim2.new(1, -43, 0, 26),
		Truncate = true,
		ZIndex = 4,
	})
	State.bannerSub = makeLabel(banner, {
		Name = "Sub",
		Text = "",
		Tier = "Secondary",
		TextRole = "Caption",
		FixedSize = true,
		TextSize = Metrics.captionSize,
		Position = UDim2.new(0, 27, 0, Metrics.compact and 38 or 42),
		Size = UDim2.new(1, -43, 0, 16),
		Truncate = true,
		ZIndex = 4,
	})
	new("Frame", {
		Name = "Rule",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Tokens.divider,
		BorderSizePixel = 0,
		Role = "Divider",
		ZIndex = 4,
	}, banner)
	State.pagesHost = new("Frame", {
		Name = "Pages",
		Position = UDim2.new(0, 0, 0, Metrics.banner),
		Size = UDim2.new(1, 0, 1, -Metrics.banner),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 2,
	}, content)
end

showMain = function(animated)
	if not State.main then
		return
	end
	State.mainVisible = true
	State.main.Visible = not State.userHidden
	State.loading = false
	manageBlur()
	setBackdrop("main")
	local vp = viewport()
	local target = State.windowCenter or Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	applyCenter(clampCenter(target))
	applyVisibility()
end

hideMain = function(instant)
	if not State.main then
		return
	end
	cancelKeyCapture()
	State.mainVisible = false
	State.main.Visible = false
	applyVisibility()
end

local function updateLayout()
	Metrics = computeMetrics()
	if not State.mainColumn or not State.rootScale then
		return
	end
	if State.relayoutCustomize then
		State.relayoutCustomize()
	end
	if State.compact ~= nil and State.compact ~= Metrics.compact then
		local page = State.activePage
		local pageId
		for id, index in pairs(State.pageIndexById) do
			if index == page then
				pageId = id
				break
			end
		end
		buildMain()
		local target = pageId and State.pageIndexById[pageId]
		if not target or target < 1 or target > #State.pages then
			target = 1
		end
		setPage(target, true)
		applyVisibility()
		return
	end
	State.rootScale.Scale = Metrics.scale
	State.mainColumn.Size = UDim2.fromOffset(Metrics.width, Metrics.height)
	if State.windowCenter then
		applyCenter(clampCenter(State.windowCenter))
	else
		State.mainColumn.Position = UDim2.fromScale(0.5, 0.5)
	end
	if Metrics.compact then
		State.navList.Size = UDim2.new(1, 0, 0, Metrics.nav)
		State.navList.Position = UDim2.new(0, 0, 0, Metrics.topbar)
		State.content.Position = UDim2.new(0, 0, 0, Metrics.topbar + Metrics.nav)
		State.content.Size = UDim2.new(1, 0, 1, -(Metrics.topbar + Metrics.nav))
	else
		State.sidebar.Size = UDim2.new(0, Metrics.sidebar, 1, -(Metrics.topbar + 16))
		State.content.Position = UDim2.new(0, Metrics.sidebar, 0, Metrics.topbar)
		State.content.Size = UDim2.new(1, -Metrics.sidebar, 1, -Metrics.topbar)
	end
end

local function buildHome(scroll)
	local actions = makeCard(scroll, { Title = "Quick actions", Order = 1 })
	makeRow(actions, {
		Label = "Customize",
		Order = 1,
		ControlWidth = 92,
		Build = function(row)
			local button = smallButton(row, "Open", 76, 1)
			placeRight(button.Instance, 76)
			button:Bind(function()
				openCustomize("Theme")
			end)
		end,
	})
	makeRow(actions, {
		Label = "Loading animation",
		Order = 2,
		ControlWidth = 92,
		Build = function(row)
			local button = smallButton(row, "Play", 76, 1, "Primary")
			placeRight(button.Instance, 76)
			button:Bind(function()
				playGallery()
			end)
		end,
	})
	makeRow(actions, {
		Label = "Auto execute modules",
		Order = 3,
		ControlWidth = 92,
		Build = function(row)
			local button = smallButton(row, State.autoExecute and "On" or "Off", 60, 1, "Ghost")
			placeRight(button.Instance, 60)
			button:SetActive(State.autoExecute)
			button:Bind(function()
				State.autoExecute = not State.autoExecute
				button:SetText(State.autoExecute and "On" or "Off")
				button:SetActive(State.autoExecute)
				saveProfile()
				toast(State.autoExecute and "Auto execute on" or "Auto execute off")
			end)
		end,
	})

	local registry = makeCard(scroll, { Title = "Modules", Order = 2 })
	makeListRow(registry, {
		Title = "Loaded",
		Subtitle = tostring(#Blossom.Modules) .. " modules · " .. tostring(#Blossom.ModuleErrors) .. " errors",
		Order = 1,
	})
	makeRow(registry, {
		Label = "Manage modules",
		Order = 2,
		ControlWidth = 92,
		Build = function(row)
			local button = smallButton(row, "Open", 76, 1, "Ghost")
			placeRight(button.Instance, 76)
			button:Bind(function()
				local index = State.pageIndexById.modules
				if index then
					setPage(index)
				end
			end)
		end,
	})
end

local function buildLoader(scroll)
	local play = makeCard(scroll, { Title = "Loading animation", Order = 1 })
	makeRow(play, {
		Label = "Blossom splash",
		Order = 1,
		ControlWidth = 96,
		Build = function(row)
			local button = smallButton(row, "Play", 76, 1, "Primary")
			placeRight(button.Instance, 76)
			button:Bind(function()
				playGallery()
			end)
		end,
	})

	local playback = makeCard(scroll, { Title = "Playback", Order = 2 })
	makeToggle(playback, {
		Text = "Loop animations",
		Value = CONFIG.Gallery.LoopEnabled,
		Order = 1,
		OnChange = function(value)
			CONFIG.Gallery.LoopEnabled = value
		end,
	})
	makeToggle(playback, {
		Text = "3-2-1 countdown",
		Value = CONFIG.Gallery.CountdownEnabled,
		Order = 2,
		OnChange = function(value)
			CONFIG.Gallery.CountdownEnabled = value
		end,
	})
	makeRow(playback, {
		Label = "Speed",
		Order = 3,
		ControlWidth = 178,
		Build = function(row)
			local chips = {}
			local count = #CONFIG.Gallery.Speeds
			for index, speed in ipairs(CONFIG.Gallery.Speeds) do
				local chip = makeButton(row, {
					Text = tostring(speed) .. "x",
					Size = UDim2.new(0, 50, 0, math.max(28, Metrics.button - 4)),
					TextSize = Metrics.captionSize,
					Order = index,
				})
				chip.Instance.AnchorPoint = Vector2.new(1, 0.5)
				chip.Instance.Position = UDim2.new(1, -10 - (count - index) * 56, 0.5, 0)
				chip:SetActive(State.speed == speed)
				chip:Bind(function()
					State.speed = speed
					for _, entry in ipairs(chips) do
						entry.chip:SetActive(entry.speed == speed)
					end
					toast("Speed " .. tostring(speed) .. "x")
				end)
				table.insert(chips, { speed = speed, chip = chip })
			end
		end,
	})
end

local function renderModules(scroll)
	local head = makeCard(scroll, { Title = "Registry", Order = 1 })
	makeRow(head, {
		Label = "Reload module sources",
		Order = 1,
		ControlWidth = 112,
		Build = function(row)
			local button = smallButton(row, "Reload", 84, 1, "Ghost")
			placeRight(button.Instance, 84)
			button:Bind(function()
				local loaded = Blossom.LoadModules()
				toast(loaded .. " new module(s) loaded")
			end)
		end,
	})
	makeListRow(head, {
		Title = "Installed",
		Subtitle = tostring(#Blossom.Modules) .. " module(s) · " .. tostring(#Blossom.ModuleErrors) .. " error(s)",
		Order = 2,
	})
	local list = sortedModules()
	for index, module in ipairs(list) do
		local row = makeRow(head, {
			Label = module.Title,
			Order = 10 + index,
			ControlWidth = 96,
			Build = function(parent)
				local button = smallButton(parent, module.Run and "Run" or "Open", 72, 1, "Ghost")
				placeRight(button.Instance, 72)
				button:Bind(function()
					if module.Run then
						if module.Running then
							stopModule(module)
						else
							runModule(module)
						end
					else
						local pageIndex = State.pageIndexById["module:" .. module.Id]
						if pageIndex then
							setPage(pageIndex)
						end
					end
				end)
				table.insert(REBUILD, function()
					button:SetText(module.Running and "Stop" or (module.Run and "Run" or "Open"))
				end)
			end,
		})
		row:SetAttribute("Tier", "Primary")
	end
	if #Blossom.ModuleErrors > 0 then
		local errors = makeCard(scroll, { Title = "Errors", Order = 2 })
		for index, entry in ipairs(Blossom.ModuleErrors) do
			makeListRow(errors, {
				Title = entry.Id,
				Subtitle = clean(entry.Message, 110),
				Order = index,
			})
		end
	end
end

local function buildModules(scroll)
	State.rebuildModulesPage = function()
		task.defer(function()
			if State.destroyed or not scroll.Parent then
				return
			end
			for _, child in ipairs(scroll:GetChildren()) do
				if child.Name == "Card" then
					child:Destroy()
				end
			end
			renderModules(scroll)
		end)
	end
	renderModules(scroll)
end

local function buildSettings(scroll)
	local themes = makeCard(scroll, { Title = "Theme", Order = 1 })
	local chips = new("Frame", {
		Name = "Chips",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
	}, themes)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}, chips)
	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		FillDirection = Enum.FillDirection.Horizontal,
		Wraps = true,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, chips)
	State.rebuildSkinChips = function()
		for _, child in ipairs(chips:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		State.skinChips = {}
		for index, name in ipairs(skinNames()) do
			local chip = makeButton(chips, {
				Text = name,
				Variant = "Ghost",
				Size = UDim2.new(0, clamp(66 + #name * 6, 96, 148), 0, math.max(30, Metrics.button - 4)),
				TextSize = Metrics.captionSize,
				Order = index,
			})
			chip:SetActive(State.theme.Name == name)
			State.skinChips[name] = chip
			chip:Bind(function()
				Blossom.SetSkin(name)
				toast("Theme: " .. name)
			end)
		end
		ThemeCache.list = nil
	end
	State.rebuildSkinChips()

	local json = makeCard(scroll, { Title = "Advanced", Order = 2 })
	makeRow(json, {
		Label = "Theme JSON",
		Order = 1,
		ControlWidth = 92,
		Build = function(row)
			local button = smallButton(row, "Edit", 72, 1, "Ghost")
			placeRight(button.Instance, 72)
			button:Bind(function()
				openCustomize("Theme")
			end)
		end,
	})
	makeRow(json, {
		Label = "Config JSON",
		Order = 2,
		ControlWidth = 92,
		Build = function(row)
			local button = smallButton(row, "Edit", 72, 1, "Ghost")
			placeRight(button.Instance, 72)
			button:Bind(function()
				openCustomize("Config")
			end)
		end,
	})
	makeRow(json, {
		Label = "Re-apply theme",
		Order = 3,
		ControlWidth = 92,
		Build = function(row)
			local button = smallButton(row, "Apply", 72, 1, "Ghost")
			placeRight(button.Instance, 72)
			button:Bind(function()
				applyTheme(State.theme, false)
				updateLayout()
				toast("Theme re-applied")
			end)
		end,
	})

	local info = makeCard(scroll, { Title = "Info", Order = 3 })
	makeListRow(info, { Title = "Version", Subtitle = "Blossom " .. Blossom.Version, Order = 1 })
	makeListRow(info, { Title = "Layout", Subtitle = Metrics.compact and "compact (touch)" or "desktop", Order = 2 })
	makeListRow(info, { Title = "Tap target", Subtitle = tostring(Metrics.button) .. "px minimum", Order = 3 })
end

local function buildKeybinds(scroll)
	local binds = makeCard(scroll, { Title = "Keybinds", Order = 1 })
	local actions = {
		{ id = "Hide", label = "Hide / show" },
		{ id = "Debug", label = "Debug overlay" },
		{ id = "Screenshot", label = "Screenshot" },
		{ id = "Destroy", label = "Destroy" },
		{ id = "DestroyModifier", label = "Destroy modifier" },
	}
	for order, action in ipairs(actions) do
		local width = 156
		makeRow(binds, {
			Label = action.label,
			Order = order,
			ControlWidth = width,
			Build = function(row)
				local button = makeButton(row, {
					Text = bindingLabel(action.id),
					Variant = "Ghost",
					Size = UDim2.new(0, width, 0, math.max(30, Metrics.button - 4)),
					TextSize = Metrics.captionSize,
					Order = 1,
				})
				placeRight(button.Instance, width)
				button:Bind(function()
					beginKeyCapture(action.id, button)
				end)
				table.insert(REBUILD, function()
					button:SetText(bindingLabel(action.id))
				end)
			end,
		})
	end
	makeRow(binds, {
		Label = "Reset bindings",
		Order = #actions + 1,
		ControlWidth = 112,
		Build = function(row)
			local button = smallButton(row, "Reset", 84, 1, "Ghost")
			placeRight(button.Instance, 84)
			button:Bind(function()
				CONFIG.Keys = copy(DEFAULT_KEYS)
				CONFIG.GamepadKeys = copy(DEFAULT_GAMEPAD_KEYS)
				saveProfile()
				refreshAll()
				toast("Bindings reset")
			end)
		end,
	})

	local touch = makeCard(scroll, { Title = "On-screen actions", Order = 2 })
	local function actionButton(text, order, fn)
		local button = makeButton(touch, {
			Text = text,
			Size = UDim2.new(1, 0, 0, Metrics.button),
			Order = order,
			Divider = true,
		})
		button:Bind(fn)
	end
	actionButton("Hide / show", 1, function()
		toggleMenu()
	end)
	actionButton("Debug overlay", 2, function()
		toggleDebug()
	end)
	actionButton("Screenshot", 3, function()
		captureShot()
	end)
end

local function buildControls(scroll, module)
	if not module.Controls or #module.Controls == 0 then
		return nil
	end
	local api = moduleContext(module)
	local group = makeCard(scroll, { Title = "Settings", Order = 2 })
	for order, item in ipairs(module.Controls) do
		if item.Type == "Button" then
			local button = makeButton(group, {
				Text = clean(tostring(item.Text or "Run"), 40),
				Variant = item.Variant == "Primary" and "Primary" or nil,
				Size = UDim2.new(1, 0, 0, Metrics.button),
				Order = order * 10,
				Divider = true,
			})
			button:Bind(function()
				if type(item.OnClick) == "function" then
					item.OnClick(api)
				end
			end)
		elseif item.Type == "Toggle" then
			makeToggle(group, {
				Text = clean(tostring(item.Label or item.Text or "Toggle"), 40),
				Value = item.Value == true,
				Order = order * 10,
				OnChange = function(value)
					if type(item.OnChange) == "function" then
						item.OnChange(value, api)
					end
				end,
			})
		elseif item.Type == "Slider" then
			makeSlider(group, {
				Label = clean(tostring(item.Label or "Slider"), 40),
				Min = item.Min,
				Max = item.Max,
				Step = item.Step,
				Value = item.Value,
				Format = item.Format,
				Order = order * 10,
				OnChange = function(value)
					if type(item.OnChange) == "function" then
						item.OnChange(value, api)
					end
				end,
			})
		elseif item.Type == "Input" then
			makeRow(group, {
				Label = clean(tostring(item.Label or "Input"), 40),
				Order = order * 10,
				ControlWidth = 180,
				Build = function(row)
					local input = makeInput(row, {
						Text = item.Value ~= nil and clean(tostring(item.Value), 400) or "",
						Placeholder = item.Placeholder,
						Size = UDim2.new(0, 180, 0, Metrics.input),
						OnSubmit = function(text)
							if type(item.OnSubmit) == "function" then
								item.OnSubmit(text, api)
							end
						end,
					})
					input.Instance.AnchorPoint = Vector2.new(1, 0.5)
					input.Instance.Position = UDim2.new(1, -10, 0.5, 0)
				end,
			})
		end
	end
	return group
end

mountModule = function(module)
	local existing = module.Page
	if existing and existing.Parent and existing.Parent.Parent == State.pagesHost then
		return
	end
	local scroll, navRow = addPage(module.Title, module.Subtitle, module.Icon, "module:" .. module.Id)
	module.Page = scroll
	module.NavRow = navRow
	local status = makeCard(scroll, { Title = "Status", Order = 1 })
	local statusLabel = makeLabel(status, {
		Name = "State",
		Text = "idle",
		Tier = "Secondary",
		TextRole = "Caption",
		LayoutOrder = 1,
		Size = UDim2.new(1, -16, 0, 24),
		Position = UDim2.new(0, 8, 0, 0),
		Truncate = true,
	})
	local runButton, stopButton
	if module.Run then
		local buttons = new("Frame", {
			Name = "Actions",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, Metrics.button),
			LayoutOrder = 2,
		}, status)
		runButton = makeButton(buttons, {
			Text = "Run",
			Variant = "Primary",
			Size = UDim2.new(0, 96, 1, 0),
		})
		runButton.Instance.AnchorPoint = Vector2.new(0, 0)
		runButton.Instance.Position = UDim2.new(0, 6, 0, 0)
		runButton:Bind(function()
			runModule(module)
		end)
		stopButton = makeButton(buttons, {
			Text = "Stop",
			Variant = "Ghost",
			Size = UDim2.new(0, 96, 1, 0),
		})
		stopButton.Instance.AnchorPoint = Vector2.new(1, 0)
		stopButton.Instance.Position = UDim2.new(1, -6, 0, 0)
		stopButton:Bind(function()
			stopModule(module)
		end)
	end
	local function refresh()
		local running = module.Running == true
		if runButton then
			runButton:SetText(running and "Running" or "Run")
			runButton:SetEnabled(not running)
		end
		if stopButton then
			stopButton:SetEnabled(running)
		end
		local text = module.Status or "idle"
		if module.Error then
			text = "error · " .. clean(module.Error, 90)
		end
		statusLabel.Text = text
		statusLabel.TextColor3 = module.Status == "error" and Color3.fromRGB(255, 132, 132) or Tokens.textSecondary
	end
	module.Refresh = refresh
	refresh()
	buildControls(scroll, module)
	if module.OnMount then
		local ok, err = safeCall(module.OnMount, moduleContext(module))
		if not ok then
			recordModuleError(module.Id, err)
		end
	end
end

buildModulePage = function(module)
	if not State.ready or not State.pagesHost then
		return
	end
	mountModule(module)
end

buildMain = function()
	if State.main then
		clearShell()
	end
	State.captureAction = nil
	State.captureButton = nil
	Metrics = computeMetrics()
	State.compact = Metrics.compact
	local connectionStart = #Connections + 1
	local rebuildStart = #REBUILD + 1
	State.main = new("Frame", {
		Name = "Main",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 3,
	}, State.root)
	State.mainColumn = new("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(Metrics.width, Metrics.height),
		BackgroundColor3 = Tokens.base,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Role = "Panel",
		ZIndex = 3,
	}, State.main)
	new("UICorner", { CornerRadius = UDim.new(0, Metrics.corner), Role = "Corner" }, State.mainColumn)
	new("UIStroke", {
		Color = Tokens.textPrimary,
		Transparency = State.theme.StrokeTransparency,
		Thickness = 1,
		Role = "Edge",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, State.mainColumn)

	local titlebar = buildTitlebar(State.mainColumn)
	if Metrics.compact then
		buildCompactNav(State.mainColumn)
	else
		buildSidebar(State.mainColumn)
	end
	buildContent(State.mainColumn)

	State.pages = {}
	State.pageMeta = {}
	State.navRows = {}
	State.pageIndexById = {}
	State.activePage = 0

	buildHome(addPage("Home", "quick actions", "home", "home"))
	buildLoader(addPage("Loader", "loading animation", "ring", "loader"))
	buildModules(addPage("Modules", "installed scripts", "grid", "modules"))
	for _, module in ipairs(sortedModules()) do
		mountModule(module)
	end
	buildSettings(addPage("Settings", "appearance and about", "cog", "settings"))
	buildKeybinds(addPage("Controls", "keybinds and position", "sliders", "controls"))
	setPage(1, true)

	ShellConnectionStart = connectionStart
	ShellConnectionEnd = #Connections
	ShellRebuildStart = rebuildStart
	ShellRebuildEnd = #REBUILD

	connectShell(titlebar.InputBegan, function(input)
		if not State.mainVisible or not State.mainColumn or State.windowLocked then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local target = input.Target
		if target and target ~= titlebar and (target:IsA("TextButton") or target:IsA("ImageButton")) then
			return
		end
		local point = Vector2.new(input.Position.X, input.Position.Y)
		if titlebarBlockedAt(point, titlebar) then
			return
		end
		local ap, as = State.mainColumn.AbsolutePosition, State.mainColumn.AbsoluteSize
		drag.active = true
		drag.start = point
		drag.center = Vector2.new(ap.X + as.X * 0.5, ap.Y + as.Y * 0.5)
	end)
	connectShell(UserInputService.InputChanged, function(input)
		if not drag.active or not State.mainColumn then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local point = Vector2.new(input.Position.X, input.Position.Y)
		applyCenter(clampCenter(drag.center + (point - drag.start)))
	end)
	connectShell(UserInputService.InputEnded, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if drag.active then
			drag.active = false
			saveProfile()
		end
	end)

	updateLayout()
end
local function executorFunction(name)
	local ok, fn = pcall(function()
		return _G[name]
	end)
	if ok and type(fn) == "function" then
		return fn
	end
	return nil
end

local function buildToast(parent)
	local group = new("CanvasGroup", {
		Name = "Toast",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.new(0, math.min(300, Metrics.viewport.X - 32), 0, 44),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 16,
	}, parent)
	local card = new("Frame", {
		Name = "Card",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Tokens.card,
		BorderSizePixel = 0,
		Role = "Card",
	}, group)
	new("UICorner", { CornerRadius = UDim.new(0, 8), Role = "Small" }, card)
	new("UIStroke", {
		Color = Tokens.textPrimary,
		Transparency = State.theme.StrokeTransparency,
		Thickness = 1,
		Role = "Edge",
	}, card)
	local stripe = new("Frame", {
		Name = "Stripe",
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundColor3 = Tokens.accent,
		BorderSizePixel = 0,
		Role = "Accent",
		ZIndex = 2,
	}, group)
	new("UICorner", { CornerRadius = UDim.new(0, 2), Role = "Small" }, stripe)
	local label = makeLabel(group, {
		Name = "Text",
		Text = "",
		Tier = "Primary",
		TextRole = "Caption",
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		Wrapped = true,
		ZIndex = 2,
	})
	State.toastGroup = group
	State.toastLabel = label
	State.toastStripe = stripe
	State.toastSeq = 0
end

toast = function(text, isError)
	local group = State.toastGroup
	if not group or not State.toastLabel then
		return
	end
	State.toastLabel.Text = clean(tostring(text or ""), 140)
	State.toastLabel.TextColor3 = isError and Color3.fromRGB(255, 140, 140) or Tokens.textPrimary
	if State.toastStripe then
		State.toastStripe.BackgroundColor3 = isError and Color3.fromRGB(255, 92, 92) or Tokens.accent
	end
	State.toastSeq = State.toastSeq + 1
	local seq = State.toastSeq
	group.Visible = true
	uiTween(group, { GroupTransparency = 0 }, CONFIG.Durations.Fade, CONFIG.Easing.Fade, CONFIG.Easing.FadeDir)
	playTween(group, ti(duration(0.28), "Quint", "Out"), { Position = UDim2.new(1, -16, 0, 16) })
	task.delay(2.4, function()
		if State.destroyed or State.toastSeq ~= seq or not State.toastGroup then
			return
		end
		playTween(State.toastGroup, ti(duration(CONFIG.Durations.Fade), "Quad", "In"), {
			Position = UDim2.new(1, 56, 0, 16),
			GroupTransparency = 1,
		})
		task.delay(duration(CONFIG.Durations.Fade) + 0.08, function()
			if State.destroyed or State.toastSeq ~= seq or not State.toastGroup then
				return
			end
			State.toastGroup.Visible = false
		end)
	end)
end

local THEME_SCHEMA = {
	{ key = "Name", type = "string", maxLen = 32 },
	{ key = "Mode", type = "enum", options = { "dark", "light" } },
	{ key = "Accent", type = "color" },
	{ key = "Base", type = "color" },
	{ key = "PanelTransparency", type = "number", min = 0, max = 0.99 },
	{ key = "CardTransparency", type = "number", min = 0, max = 0.99 },
	{ key = "StrokeTransparency", type = "number", min = 0, max = 1 },
	{ key = "StrokeThickness", type = "number", min = 0, max = 4 },
	{ key = "GradientTop", type = "color" },
	{ key = "GradientTopTransparency", type = "number", min = 0, max = 1 },
	{ key = "GradientBottomTransparency", type = "number", min = 0, max = 1 },
	{ key = "TextPrimary", type = "color" },
	{ key = "TextSecondary", type = "color" },
	{ key = "TextDisabled", type = "color" },
	{ key = "DimColor", type = "color" },
	{ key = "DimTransparency", type = "number", min = 0, max = 1 },
	{ key = "ProgressTrack", type = "color" },
	{ key = "ProgressFill", type = "color" },
	{ key = "SkeletonBase", type = "color" },
	{ key = "SkeletonHighlight", type = "color" },
	{ key = "ShimmerTransparency", type = "number", min = 0, max = 1 },
	{ key = "Font", type = "enum", options = { "Gotham", "GothamMedium", "GothamBold", "SourceSansPro", "Ubuntu", "Roboto" } },
	{ key = "CornerRadius", type = "number", min = 0, max = 24 },
	{ key = "Spacing", type = "number", min = 0, max = 32 },
	{ key = "SidebarColor", type = "color" },
	{ key = "CardColor", type = "color" },
	{ key = "DividerColor", type = "color" },
	{ key = "BannerA", type = "color" },
	{ key = "BannerB", type = "color" },
	{ key = "BannerC", type = "color" },
	{ key = "BackgroundImage", type = "image" },
	{ key = "LogoImage", type = "image" },
	{ key = "SpinnerImage", type = "image" },
	{ key = "TextureImage", type = "image" },
	{ key = "BlurEnabled", type = "bool" },
	{ key = "BlurSize", type = "number", min = 0, max = 40 },
}

local EASING_NAMES = { "Linear", "Quad", "Cubic", "Quart", "Quint", "Sine", "Exponential", "Circular", "Back", "Bounce", "Elastic" }
local DIRECTION_NAMES = { "In", "Out", "InOut" }

local CONFIG_SCHEMA = {
	{
		key = "Durations",
		fields = {
			{ key = "Scale", type = "number", min = 0.1, max = 8 },
			{ key = "Splash", type = "number", min = 0.05, max = 30 },
			{ key = "SplashHold", type = "number", min = 0, max = 30 },
			{ key = "Transition", type = "number", min = 0.05, max = 10 },
			{ key = "Slide", type = "number", min = 0.05, max = 10 },
			{ key = "Countdown", type = "number", min = 0.1, max = 5 },
			{ key = "CountdownGap", type = "number", min = 0, max = 2 },
			{ key = "Fade", type = "number", min = 0.05, max = 10 },
			{ key = "ThemeCrossfade", type = "number", min = 0.05, max = 10 },
			{ key = "Hover", type = "number", min = 0.02, max = 5 },
			{ key = "Press", type = "number", min = 0.02, max = 5 },
			{ key = "Toggle", type = "number", min = 0.02, max = 5 },
			{ key = "LoopGap", type = "number", min = 0, max = 10 },
		},
	},
	{
		key = "Easing",
		fields = {
			{ key = "Fill", type = "enum", options = EASING_NAMES },
			{ key = "FillDir", type = "enum", options = DIRECTION_NAMES },
			{ key = "Fade", type = "enum", options = EASING_NAMES },
			{ key = "FadeDir", type = "enum", options = DIRECTION_NAMES },
			{ key = "Slide", type = "enum", options = EASING_NAMES },
			{ key = "SlideDir", type = "enum", options = DIRECTION_NAMES },
			{ key = "Pop", type = "enum", options = EASING_NAMES },
			{ key = "PopDir", type = "enum", options = DIRECTION_NAMES },
			{ key = "Hover", type = "enum", options = EASING_NAMES },
			{ key = "HoverDir", type = "enum", options = DIRECTION_NAMES },
			{ key = "Press", type = "enum", options = EASING_NAMES },
			{ key = "PressDir", type = "enum", options = DIRECTION_NAMES },
			{ key = "Spin", type = "enum", options = EASING_NAMES },
			{ key = "SpinDir", type = "enum", options = DIRECTION_NAMES },
			{ key = "Theme", type = "enum", options = EASING_NAMES },
			{ key = "ThemeDir", type = "enum", options = DIRECTION_NAMES },
		},
	},
	{
		key = "Layout",
		fields = {
			{ key = "MaxWidth", type = "number", min = 240, max = 1200 },
			{ key = "Padding", type = "number", min = 0, max = 64 },
			{ key = "Gap", type = "number", min = 0, max = 48 },
			{ key = "CornerRadius", type = "number", min = 0, max = 40 },
			{ key = "MinScale", type = "number", min = 0.3, max = 1 },
		},
	},
}

local function checkValue(value, field)
	if field.type == "number" then
		if type(value) ~= "number" or value ~= value then
			return false, nil, "must be a finite number"
		end
		local clamped = clamp(value, field.min, field.max)
		return true, clamped, clamped ~= value and (field.key .. " clamped to " .. tostring(clamped)) or nil
	elseif field.type == "string" then
		if type(value) ~= "string" then
			return false, nil, "must be a string"
		end
		return true, clean(value, field.maxLen or 32)
	elseif field.type == "color" then
		if not isHex(value) then
			return false, nil, "must be a #RRGGBB colour"
		end
		return true, string.upper(value)
	elseif field.type == "enum" then
		if type(value) ~= "string" then
			return false, nil, "must be one of " .. table.concat(field.options, ", ")
		end
		for _, option in ipairs(field.options) do
			if value == option then
				return true, value
			end
		end
		return false, nil, "must be one of " .. table.concat(field.options, ", ")
	elseif field.type == "bool" then
		if type(value) ~= "boolean" then
			return false, nil, "must be true or false"
		end
		return true, value
	elseif field.type == "image" then
		local text = tostring(value or "")
		local id = text:match("^rbxassetid://(%d+)$") or text:match("^(%d+)$")
		if not id then
			return false, nil, "must be a numeric asset id"
		end
		return true, id
	end
	return false, nil, "has an unsupported type"
end

local function validateFields(data, schema, defaults)
	local out = {}
	local errors = {}
	local notes = {}
	if type(data) ~= "table" then
		return nil, { "value must be a JSON object" }, {}
	end
	for _, field in ipairs(schema) do
		local value = data[field.key]
		if value == nil then
			out[field.key] = defaults[field.key]
		else
			local ok, result, note = checkValue(value, field)
			if ok then
				out[field.key] = result
				if note then
					table.insert(notes, note)
				end
			else
				out[field.key] = defaults[field.key]
				table.insert(errors, field.key .. " " .. note)
			end
		end
	end
	return out, errors, notes
end

local function validateTheme(data)
	return validateFields(data, THEME_SCHEMA, BASE_THEME)
end

local function validateConfig(data)
	local out = {}
	local errors = {}
	local notes = {}
	if type(data) ~= "table" then
		return nil, { "value must be a JSON object" }, {}
	end
	for _, group in ipairs(CONFIG_SCHEMA) do
		local raw = data[group.key]
		if raw ~= nil then
			if type(raw) ~= "table" then
				table.insert(errors, group.key .. " must be an object")
			else
				local result = copy(CONFIG[group.key])
				for _, field in ipairs(group.fields) do
					local value = raw[field.key]
					if value ~= nil then
						local ok, checked, note = checkValue(value, field)
						if ok then
							result[field.key] = checked
							if note then
								table.insert(notes, group.key .. "." .. note)
							end
						else
							table.insert(errors, group.key .. "." .. field.key .. " " .. note)
						end
					end
				end
				out[group.key] = result
			end
		end
	end
	if data.Theme ~= nil then
		if type(data.Theme) ~= "table" then
			table.insert(errors, "Theme must be an object")
		else
			local theme, themeErrors, themeNotes = validateTheme(data.Theme)
			if theme then
				out.Theme = theme
			end
			for _, message in ipairs(themeErrors) do
				table.insert(errors, "Theme." .. message)
			end
			for _, message in ipairs(themeNotes) do
				table.insert(notes, "Theme." .. message)
			end
		end
	end
	return out, errors, notes
end

local function themeToJSON(theme)
	local ordered = {}
	for _, field in ipairs(THEME_SCHEMA) do
		ordered[field.key] = theme[field.key]
	end
	local ok, json = pcall(HttpService.JSONEncode, HttpService, ordered)
	return ok and json or "{}"
end

local function decodeJSON(text)
	if type(text) ~= "string" or #text == 0 then
		return nil, "nothing to parse"
	end
	if #text > 40000 then
		return nil, "input too large"
	end
	local ok, result = pcall(HttpService.JSONDecode, HttpService, text)
	if not ok or type(result) ~= "table" then
		return nil, "invalid JSON object"
	end
	return result, nil
end

local function preloadThemeImages(theme)
	local urls = {}
	for _, key in ipairs({ "BackgroundImage", "LogoImage", "SpinnerImage", "TextureImage" }) do
		local id = theme[key]
		if type(id) == "string" and id ~= "" then
			table.insert(urls, "rbxassetid://" .. id)
		end
	end
	if #urls > 0 then
		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync(urls)
			end)
		end)
	end
end

local PROFILE_FOLDER = "Blossom"
local PROFILE_FILE = "Blossom/profile.json"

local function readProfileFile()
	local readfile = executorFunction("readfile")
	local isfile = executorFunction("isfile")
	if not readfile then
		return nil
	end
	if isfile then
		local ok, exists = pcall(isfile, PROFILE_FILE)
		if not ok or not exists then
			return nil
		end
	end
	local ok, data = pcall(readfile, PROFILE_FILE)
	if ok and type(data) == "string" and #data > 0 and #data <= 40000 then
		return data
	end
	return nil
end

local function writeProfileFile(json)
	local writefile = executorFunction("writefile")
	if not writefile then
		return false
	end
	local makefolder = executorFunction("makefolder")
	local isfolder = executorFunction("isfolder")
	if makefolder and isfolder then
		local ok, exists = pcall(isfolder, PROFILE_FOLDER)
		if not ok or not exists then
			pcall(makefolder, PROFILE_FOLDER)
		end
	end
	return pcall(writefile, PROFILE_FILE, json) == true
end

saveProfile = function()
	if not State.player then
		return
	end
	local keys = {}
	for action, key in pairs(CONFIG.Keys) do
		if key and key.Name then
			keys[action] = key.Name
		end
	end
	local gamepad = {}
	for action, key in pairs(CONFIG.GamepadKeys) do
		if key and key.Name then
			gamepad[action] = key.Name
		end
	end
	local vp = viewport()
	local center = State.windowCenter
	local payload = {
		active = State.theme.Name,
		autoExecute = State.autoExecute,
		themes = {},
		keys = keys,
		gamepad = gamepad,
		window = {
			locked = State.windowLocked,
			x = center and clamp(center.X / vp.X, 0, 1) or nil,
			y = center and clamp(center.Y / vp.Y, 0, 1) or nil,
		},
	}
	for _, name in ipairs(skinNames()) do
		if not BUILTIN_SKINS[name] then
			payload.themes[name] = SKINS[name]
		end
	end
	local ok, json = pcall(HttpService.JSONEncode, HttpService, payload)
	if not ok or type(json) ~= "string" then
		return
	end
	State.player:SetAttribute("BlossomProfile", json)
	writeProfileFile(json)
end

local function profileKey(value)
	if type(value) ~= "string" then
		return nil
	end
	local ok, key = pcall(function()
		return Enum.KeyCode[value]
	end)
	if ok and key then
		return key
	end
	return nil
end

loadProfile = function()
	local raw = readProfileFile()
	if not raw and State.player then
		raw = State.player:GetAttribute("BlossomProfile")
	end
	if type(raw) ~= "string" or raw == "" then
		return
	end
	local data = decodeJSON(raw)
	if not data then
		return
	end
	if type(data.themes) == "table" then
		for name, theme in pairs(data.themes) do
			if type(name) == "string" and type(theme) == "table" then
				local validated, errors = validateTheme(theme)
				if validated and #errors == 0 then
					registerSkin(name, validated)
				end
			end
		end
	end
	State.autoExecute = data.autoExecute == true
	if type(data.keys) == "table" then
		for action in pairs(CONFIG.Keys) do
			local key = profileKey(data.keys[action])
			if key then
				CONFIG.Keys[action] = key
			end
		end
	end
	if type(data.gamepad) == "table" then
		for action in pairs(CONFIG.GamepadKeys) do
			local key = profileKey(data.gamepad[action])
			if key then
				CONFIG.GamepadKeys[action] = key
			end
		end
	end
	if type(data.window) == "table" then
		State.windowLocked = data.window.locked == true
		local x = tonumber(data.window.x)
		local y = tonumber(data.window.y)
		if x and y then
			local vp = viewport()
			State.windowCenter = Vector2.new(clamp(x, 0, 1) * vp.X, clamp(y, 0, 1) * vp.Y)
		end
	end
	if type(data.active) == "string" and SKINS[data.active] then
		State.profileSkin = data.active
	end
end

local reportsStatus

local function buildCustomize()
	local customize = new("Frame", {
		Name = "Customize",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 8,
	}, State.root)
	State.customize = customize
	local modal = new("Frame", {
		Name = "Modal",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Tokens.dim,
		BackgroundTransparency = State.theme.DimTransparency,
		BorderSizePixel = 0,
		Active = true,
		Role = "Backdrop",
		ZIndex = 8,
	}, customize)
	modal:SetAttribute("BackdropLevel", "modal")
	local scale = (State.rootScale and State.rootScale.Scale) or 1
	local panelWidth = math.floor(math.min(440, Metrics.viewport.X / math.max(0.1, scale) - 24))
	local boxHeight = math.floor(clamp(Metrics.viewport.Y / math.max(0.1, scale) * 0.3, 96, 220))
	local panel = new("Frame", {
		Name = "Panel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, panelWidth, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Tokens.card,
		BorderSizePixel = 0,
		Active = true,
		Role = "Card",
		ZIndex = 9,
	}, customize)
	State.customizePanel = panel
	new("UISizeConstraint", { MaxSize = Vector2.new(460, 100000) }, panel)
	new("UICorner", { CornerRadius = UDim.new(0, Metrics.corner), Role = "Corner" }, panel)
	new("UIStroke", {
		Color = Tokens.textPrimary,
		Transparency = State.theme.StrokeTransparency,
		Thickness = 1,
		Role = "Edge",
	}, panel)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, panel)
	new("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
	}, panel)

	local header = new("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 24),
		LayoutOrder = 0,
	}, panel)
	makeLabel(header, {
		Text = "Customize",
		Tier = "Primary",
		TextRole = "Title",
		Bold = true,
		FixedSize = true,
		TextSize = 17,
		Size = UDim2.new(1, -34, 1, 0),
	})
	local close = makeButton(header, {
		Text = "X",
		Variant = "Ghost",
		Size = UDim2.new(0, 28, 0, 28),
		TextSize = 11,
		Bold = true,
		Radius = 6,
	})
	close.Instance.AnchorPoint = Vector2.new(1, 0.5)
	close.Instance.Position = UDim2.new(1, 0, 0.5, 0)
	close:Bind(function()
		closeCustomize()
	end)

	makeLabel(panel, {
		Text = "Paste theme or config JSON, then Apply. Theme JSON can be saved as a skin.",
		Tier = "Secondary",
		TextRole = "Caption",
		Size = UDim2.new(1, 0, 0, 30),
		Wrapped = true,
		LayoutOrder = 1,
	})

	local tabs = new("Frame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
		LayoutOrder = 2,
	}, panel)
	local themeTab = makeButton(tabs, { Text = "Theme JSON", Variant = "Ghost", Size = UDim2.new(0, 104, 1, 0), TextSize = Metrics.captionSize, Order = 1 })
	local configTab = makeButton(tabs, { Text = "Config JSON", Variant = "Ghost", Size = UDim2.new(0, 104, 1, 0), TextSize = Metrics.captionSize, Order = 2 })
	configTab.Instance.Position = UDim2.new(0, 110, 0, 0)

	local box = new("TextBox", {
		Name = "Json",
		BackgroundColor3 = Tokens.base,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, boxHeight),
		Text = "",
		PlaceholderText = "Paste JSON here",
		Font = themeFont(),
		TextSize = Metrics.captionSize,
		TextColor3 = Tokens.textPrimary,
		PlaceholderColor3 = Tokens.textDisabled,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		ClearTextOnFocus = false,
		MultiLine = true,
		LayoutOrder = 3,
		Tier = "Primary",
		TextRole = "Caption",
		Role = "Input",
	}, panel)
	new("UICorner", { CornerRadius = UDim.new(0, 6), Role = "Small" }, box)
	new("UIStroke", { Color = Tokens.textPrimary, Transparency = State.theme.StrokeTransparency, Thickness = 1, Role = "Edge" }, box)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, box)
	State.jsonBox = box

	local nameBox = new("TextBox", {
		Name = "Name",
		BackgroundColor3 = Tokens.base,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		Text = "",
		PlaceholderText = "Name for the imported theme",
		Font = themeFont(),
		TextSize = Metrics.captionSize + 1,
		TextColor3 = Tokens.textPrimary,
		PlaceholderColor3 = Tokens.textDisabled,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		LayoutOrder = 4,
		Tier = "Primary",
		TextRole = "Body",
		Role = "Input",
	}, panel)
	new("UICorner", { CornerRadius = UDim.new(0, 6), Role = "Small" }, nameBox)
	new("UIStroke", { Color = Tokens.textPrimary, Transparency = State.theme.StrokeTransparency, Thickness = 1, Role = "Edge" }, nameBox)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, nameBox)
	State.nameBox = nameBox

	local status = makeLabel(panel, {
		Text = "Paste a theme or config object, then Apply.",
		Tier = "Secondary",
		TextRole = "Caption",
		Size = UDim2.new(1, 0, 0, 32),
		YAlign = Enum.TextYAlignment.Top,
		Wrapped = true,
		LayoutOrder = 5,
	})
	State.statusLabel = status

	local actions = new("Frame", {
		Name = "Actions",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, math.max(30, Metrics.button)),
		LayoutOrder = 6,
	}, panel)
	local actionWidth = math.floor((panelWidth - 24 - 18) / 4)
	local actionLabels = { "Apply", "Save", "Export", "Reset" }
	local actionButtons = {}
	for index, text in ipairs(actionLabels) do
		local button = makeButton(actions, {
			Text = text,
			Variant = index == 1 and "Primary" or "Ghost",
			Size = UDim2.new(0, actionWidth, 1, 0),
			TextSize = Metrics.captionSize + 1,
			Order = index,
		})
		button.Instance.AnchorPoint = Vector2.new(0, 0)
		button.Instance.Position = UDim2.new(0, (index - 1) * (actionWidth + 6), 0, 0)
		actionButtons[index] = button
	end

	local function relayout()
		local scale = (State.rootScale and State.rootScale.Scale) or 1
		local vp = viewport()
		local width = math.floor(math.min(440, vp.X / math.max(0.1, scale) - 24))
		local height = math.floor(clamp(vp.Y / math.max(0.1, scale) * 0.3, 96, 220))
		panel.Size = UDim2.new(0, width, 0, 0)
		box.Size = UDim2.new(1, 0, 0, height)
		local actionWidth = math.floor((width - 24 - 18) / 4)
		for index, button in ipairs(actionButtons) do
			button.Instance.Size = UDim2.new(0, actionWidth, 1, 0)
			button.Instance.Position = UDim2.new(0, (index - 1) * (actionWidth + 6), 0, 0)
		end
	end
	State.relayoutCustomize = relayout

	State.customTab = "Theme"
	local function setTab(tab)
		State.customTab = tab == "Config" and "Config" or "Theme"
		themeTab:SetActive(State.customTab == "Theme")
		configTab:SetActive(State.customTab == "Config")
		setStatusLabel(State.customTab == "Theme" and "Theme JSON mode. Export dumps the active theme." or "Config JSON mode. Paste Durations, Easing or Layout.", false)
	end
	State.setCustomTab = setTab
	themeTab:Bind(function()
		setTab("Theme")
	end)
	configTab:Bind(function()
		setTab("Config")
	end)

	local apply = actionButtons[1]
	local save = actionButtons[2]
	local export = actionButtons[3]
	local reset = actionButtons[4]

	apply:Bind(function()
		local data, decodeError = decodeJSON(box.Text)
		if not data then
			setStatusLabel(decodeError, true)
			return
		end
		if State.customTab == "Theme" then
			local cleanTheme, errors, notes = validateTheme(data)
			if #errors > 0 then
				setStatusLabel(table.concat(errors, "; "), true)
				return
			end
			preloadThemeImages(cleanTheme)
			applyTheme(cleanTheme, true)
			local message = "Theme applied."
			if #notes > 0 then
				message = message .. " " .. table.concat(notes, "; ")
			end
			setStatusLabel(message, false)
			toast("Theme applied")
		else
			local config, errors, notes = validateConfig(data)
			if #errors > 0 then
				setStatusLabel(table.concat(errors, "; "), true)
				return
			end
			local themeOverride = nil
			for key, value in pairs(config) do
				if key == "Theme" then
					themeOverride = value
				else
					CONFIG[key] = value
				end
			end
			updateLayout()
			applyTheme(themeOverride or State.theme, themeOverride ~= nil)
			local message = "Config applied."
			if #notes > 0 then
				message = message .. " " .. table.concat(notes, "; ")
			end
			setStatusLabel(message, false)
			toast("Config applied")
		end
	end)

	save:Bind(function()
		if State.customTab ~= "Theme" then
			setStatusLabel("Switch to Theme JSON to save a skin.", true)
			return
		end
		local data, decodeError = decodeJSON(box.Text)
		if not data then
			setStatusLabel(decodeError, true)
			return
		end
		local cleanTheme, errors, notes = validateTheme(data)
		if #errors > 0 then
			setStatusLabel(table.concat(errors, "; "), true)
			return
		end
		local typed = clean(nameBox.Text, 24)
		local label = typed ~= "" and typed or clean(tostring(cleanTheme.Name or ""), 24)
		if label == "" then
			label = "Custom " .. tostring(#skinNames() + 1)
		end
		if BUILTIN_SKINS[label] then
			if typed == "" then
				label = clean(label .. " copy", 24)
			else
				setStatusLabel("That name belongs to a built-in theme.", true)
				return
			end
		end
		local saved = registerSkin(label, cleanTheme)
		if not saved then
			setStatusLabel("Could not save that theme name.", true)
			return
		end
		preloadThemeImages(SKINS[saved])
		applyTheme(SKINS[saved], true)
		nameBox.Text = saved
		saveProfile()
		if State.rebuildSkinChips then
			State.rebuildSkinChips()
		end
		local message = "Saved skin " .. saved .. "."
		if #notes > 0 then
			message = message .. " " .. table.concat(notes, "; ")
		end
		setStatusLabel(message, false)
		toast("Skin saved: " .. saved)
	end)

	export:Bind(function()
		if State.customTab == "Theme" then
			box.Text = themeToJSON(State.theme)
			setStatusLabel("Active theme copied into the box.", false)
		else
			local ok, json = pcall(HttpService.JSONEncode, HttpService, {
				Durations = CONFIG.Durations,
				Easing = CONFIG.Easing,
				Layout = CONFIG.Layout,
			})
			if ok then
				box.Text = json
				setStatusLabel("Active config copied into the box.", false)
			else
				setStatusLabel("Export failed.", true)
			end
		end
	end)

	reset:Bind(function()
		if State.customTab == "Theme" then
			applyTheme(SKINS.Sakura, true)
			box.Text = themeToJSON(State.theme)
			saveProfile()
			if State.rebuildSkinChips then
				State.rebuildSkinChips()
			end
			setStatusLabel("Reset to Sakura.", false)
		else
			setStatusLabel("Config reset: re-open the UI to reload defaults.", false)
		end
	end)

	modal.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			closeCustomize()
		end
	end)

	reportsStatus = function()
		if State.statusLabel then
			State.statusLabel.TextColor3 = Tokens.textSecondary
		end
	end
	table.insert(REBUILD, function()
		box.BackgroundColor3 = Tokens.base
		box.TextColor3 = Tokens.textPrimary
		box.Font = themeFont()
		nameBox.BackgroundColor3 = Tokens.base
		nameBox.TextColor3 = Tokens.textPrimary
		nameBox.Font = themeFont()
		if reportsStatus then
			reportsStatus()
		end
	end)
	setTab("Theme")
end

setStatusLabel = function(message, isError)
	if not State.statusLabel then
		return
	end
	State.statusLabel.Text = clean(tostring(message or ""), 400)
	State.statusLabel.TextColor3 = isError and Color3.fromRGB(255, 132, 132) or Tokens.textSecondary
end

openCustomize = function(tab)
	if not State.customize then
		return
	end
	State.customizeOpen = true
	State.customize.Visible = not State.userHidden
	if State.setCustomTab then
		State.setCustomTab(tab or "Theme")
	end
	local modal = State.customize:FindFirstChild("Modal")
	if modal then
		modal.BackgroundTransparency = 0.9
		playTween(modal, ti(duration(CONFIG.Durations.Fade), "Quad", "Out"), {
			BackgroundTransparency = State.theme.DimTransparency,
		})
	end
	applyVisibility()
end

closeCustomize = function()
	State.customizeOpen = false
	if not State.customize then
		return
	end
	local modal = State.customize:FindFirstChild("Modal")
	if modal then
		playTween(modal, ti(duration(CONFIG.Durations.Fade) * 0.8, "Quad", "In"), { BackgroundTransparency = 1 })
	end
	task.delay(duration(CONFIG.Durations.Fade) * 0.8 + 0.02, function()
		if not State.destroyed and not State.customizeOpen and State.customize then
			State.customize.Visible = false
		end
	end)
	if State.userHidden and State.customize then
		State.customize.Visible = false
	end
end

local function resetCountdown()
	if not State.countdown then
		return
	end
	cancelProps(State.countdown, { TextTransparency = true })
	State.countdown.Text = ""
	State.countdown.TextTransparency = 1
end

local function clearStage()
	resetCountdown()
	if not State.stage then
		return
	end
	cancelList(StageTweens)
	cancelList(PetalTweens)
	for _, child in ipairs(State.stage:GetChildren()) do
		child:Destroy()
	end
	ThemeCache.list = nil
end

local function waitToken(seconds, token)
	local deadline = os.clock() + seconds
	while os.clock() < deadline do
		if State.destroyed or State.token ~= token then
			return false
		end
		task.wait(0.03)
	end
	return not State.destroyed and State.token == token
end

local function ambientPetals(parent, count, span, transparency)
	if Device.mobile and CONFIG.Mobile.ReduceEffects then
		return
	end
	if not CONFIG.Ambient.Petals then
		return
	end
	count = math.floor(clamp(tonumber(count) or CONFIG.Ambient.Count, 0, 20))
	local tint = hex(CONFIG.Loading.PetalColor)
	for _ = 1, count do
		local width = 6 + math.random() * 5
		local petal = new("Frame", {
			Name = "Petal",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(math.random(), 0, 0, -40),
			Size = UDim2.new(0, width, 0, width * 1.4),
			Rotation = math.random() * 360,
			BackgroundColor3 = tint,
			BackgroundTransparency = transparency + math.random() * 0.2,
			BorderSizePixel = 0,
			ZIndex = 1,
		}, parent)
		new("UICorner", { CornerRadius = UDim.new(0.5, 0), Role = "Dot" }, petal)
		local fallTime = span / clamp(CONFIG.Ambient.Speed, 20, 200) + math.random() * 1.2
		playTween(petal, ti(fallTime, "Linear", "Out", -1, false, math.random() * fallTime), {
			Position = UDim2.new(petal.Position.X.Scale, 0, 1, -40),
		}, PetalTweens)
		playTween(petal, ti(fallTime * 1.5, "Linear", "Out", -1), { Rotation = petal.Rotation + 220 }, PetalTweens)
	end
end

local function loaderSplash()
	local vp = viewport()
	local width = math.min(vp.X - 32, 260)
	local orange = new("CanvasGroup", {
		Name = "Splash",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, width, 0, 64),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		ZIndex = 4,
	}, State.stage)
	ambientPetals(State.stage, CONFIG.Ambient.Count, vp.Y, 0.35)
	makeLabel(orange, {
		Name = "Title",
		Text = clean(CONFIG.Brand.Name, 24),
		Tier = "Primary",
		TextRole = "Title",
		Color = hex(CONFIG.Loading.TitleColor),
		Bold = true,
		FixedSize = true,
		TextSize = 17,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		XAlign = Enum.TextXAlignment.Center,
		ZIndex = 3,
	})
	local bar = new("Frame", {
		Name = "Progress",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 34),
		Size = UDim2.new(0, 120, 0, 2),
		BackgroundColor3 = Tokens.track,
		BorderSizePixel = 0,
		Role = "Track",
		ZIndex = 3,
	}, orange)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, bar)
	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Tokens.accent,
		BorderSizePixel = 0,
		Role = "Fill",
		ZIndex = 4,
	}, bar)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, fill)
	playTween(fill, ti(duration(CONFIG.Durations.Splash), "Quint", "Out"), { Size = UDim2.new(1, 0, 1, 0) }, StageTweens)
	local inTime = duration(CONFIG.Durations.Splash) * 0.4
	local outTime = duration(CONFIG.Durations.Splash) * 0.35
	playTween(orange, ti(inTime, CONFIG.Easing.Fade, CONFIG.Easing.FadeDir), { GroupTransparency = 0 })
	local hold = duration(CONFIG.Durations.SplashHold)
	task.delay(inTime + hold, function()
		if State.destroyed then
			return
		end
		playTween(orange, ti(outTime, CONFIG.Easing.Fade, "In"), { GroupTransparency = 1 })
	end)
	return inTime + hold + outTime
end

local function setLoading(active)
	State.loading = active == true
	manageBlur()
end

local function abortLoader(showMenu)
	State.token = State.token + 1
	State.playing = false
	State.activeSpeed = 1
	clearStage()
	setLoading(false)
	if showMenu then
		showMain(false)
		setBackdrop("main")
	end
end

playGallery = function()
	if State.destroyed then
		return
	end
	if State.playing then
		abortLoader(true)
	end
	resetCountdown()
	State.playing = true
	State.token = State.token + 1
	local token = State.token
	State.activeSpeed = State.speed
	local restore = State.mainVisible
	hideMain(true)
	setLoading(true)
	setBackdrop("loading")

	if CONFIG.Gallery.CountdownEnabled and State.countdown then
		for i = 3, 1, -1 do
			if State.destroyed or State.token ~= token then
				abortLoader(true)
				return
			end
			State.countdown.Text = tostring(i)
			playTween(State.countdown, ti(duration(0.16), "Quad", "Out"), { TextTransparency = 0 })
			if not waitToken(duration(CONFIG.Durations.Countdown), token) then
				return
			end
			playTween(State.countdown, ti(duration(0.16), "Quad", "In"), { TextTransparency = 1 })
			if not waitToken(duration(CONFIG.Durations.CountdownGap), token) then
				return
			end
		end
	end
	if State.destroyed or State.token ~= token then
		return
	end
	local total = 2
	local ok, result = safeCall(loaderSplash)
	if ok then
		total = tonumber(result) or 2
	else
		warn("[Blossom] loader failed: " .. tostring(result))
	end
	local finished = waitToken(math.max(0.2, total) + 0.05, token)
	if not finished and (State.destroyed or State.token ~= token) then
		return
	end
	clearStage()
	State.playing = false
	State.activeSpeed = 1
	if State.destroyed then
		return
	end
	if restore then
		showMain(true)
	else
		setLoading(false)
		setBackdrop("main")
	end
	applyVisibility()
	if token == State.token and CONFIG.Gallery.LoopEnabled then
		task.delay(duration(CONFIG.Durations.LoopGap), function()
			if not State.destroyed and not State.playing then
				playGallery()
			end
		end)
	end
end

captureShot = function()
	local ok = pcall(function()
		CaptureService:CaptureScreenshot()
	end)
	if not ok then
		toast("Capture failed", true)
		return
	end
	if State.flash then
		State.flash.Visible = true
		State.flash.BackgroundTransparency = 0.55
		playTween(State.flash, ti(duration(CONFIG.Durations.Fade), "Quad", "In"), { BackgroundTransparency = 1 })
		task.delay(duration(CONFIG.Durations.Fade) + 0.05, function()
			if State.flash then
				State.flash.Visible = false
			end
		end)
	end
	toast("Screenshot saved")
end

local function setDebugActive(active)
	if active then
		if State.debugConn then
			return
		end
		local clock, frames = 0, 0
		State.debugConn = RunService.RenderStepped:Connect(function(dt)
			clock = clock + dt
			frames = frames + 1
			if clock < CONFIG.Debug.UpdateRate then
				return
			end
			local fps = math.floor(frames / math.max(clock, 0.0001) + 0.5)
			clock, frames = 0, 0
			if State.debugLabel then
				State.debugLabel.Text = string.format("fps %d  ·  ms %.1f", fps, 1000 / math.max(fps, 1))
			end
		end)
	elseif State.debugConn then
		pcall(function()
			State.debugConn:Disconnect()
		end)
		State.debugConn = nil
	end
end

toggleDebug = function()
	if State.destroyed then
		return
	end
	State.debugVisible = not State.debugVisible
	applyVisibility()
end

local function buildDebug()
	local frame = new("Frame", {
		Name = "Debug",
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(0, 196, 0, 62),
		BackgroundColor3 = Tokens.card,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		Visible = false,
		Role = "Card",
		ZIndex = 12,
	}, State.root)
	new("UICorner", { CornerRadius = UDim.new(0, 8), Role = "Small" }, frame)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, frame)
	State.debugLabel = makeLabel(frame, {
		Text = "fps 0  ·  ms 0.0",
		Tier = "Secondary",
		TextRole = "Caption",
		Size = UDim2.fromScale(1, 1),
		YAlign = Enum.TextYAlignment.Top,
	})
	State.debugFrame = frame
	State.debugVisible = false
	State.debugConn = nil
	if CONFIG.Debug.StartVisible then
		toggleDebug()
	end
end

applyVisibility = function()
	local mainVisible = State.mainVisible and not State.userHidden
	if State.main then
		State.main.Visible = mainVisible
	end
	if State.customize then
		State.customize.Visible = State.customizeOpen and not State.userHidden
	end
	local debugVisible = State.debugVisible and mainVisible and not State.loading
	if State.debugFrame then
		State.debugFrame.Visible = debugVisible
	end
	setDebugActive(debugVisible)
	if State.reopen then
		State.reopen.Visible = State.ready and not State.loading and not State.playing and (State.userHidden or not State.mainVisible)
	end
end

toggleMenu = function()
	if State.destroyed or State.playing then
		return
	end
	if not State.mainVisible then
		State.userHidden = false
		showMain(true)
		return
	end
	State.userHidden = not State.userHidden
	if State.userHidden then
		cancelKeyCapture()
	end
	applyVisibility()
	toast(State.userHidden and "Menu hidden" or "Menu shown")
end

cancelKeyCapture = function()
	if not State.captureAction then
		return
	end
	State.captureAction = nil
	State.captureButton = nil
	refreshAll()
end

local function inputIsGamepad(input)
	local inputType = input.UserInputType
	local name = inputType and inputType.Name or ""
	return name:sub(1, 7) == "Gamepad"
end

beginKeyCapture = function(action, button)
	if State.destroyed or not CONFIG.Keys[action] then
		return
	end
	if State.captureAction == action then
		State.captureAction = nil
		State.captureButton = nil
		refreshAll()
		toast("Binding cancelled")
		return
	end
	State.captureAction = action
	State.captureButton = button
	if button then
		button:SetText("Press a key…")
	end
	toast("Press a keyboard or controller button")
end

local function finishKeyCapture(input)
	local action = State.captureAction
	if not action then
		return false
	end
	local key = input.KeyCode
	if key == Enum.KeyCode.Escape then
		State.captureAction = nil
		State.captureButton = nil
		refreshAll()
		toast("Binding cancelled")
		return true
	end
	if key == nil or key.Name == nil or key == Enum.KeyCode.Unknown then
		return true
	end
	local gamepad = inputIsGamepad(input)
	if gamepad and (action == "Destroy" or action == "DestroyModifier") then
		toast("Destroy must use a keyboard key", true)
		return true
	end
	if gamepad then
		CONFIG.GamepadKeys[action] = key
	else
		CONFIG.Keys[action] = key
	end
	State.captureAction = nil
	State.captureButton = nil
	saveProfile()
	refreshAll()
	toast(action .. " bound")
	return true
end

local function handleInput(input)
	if State.destroyed or not State.ready then
		return
	end
	if State.captureAction then
		finishKeyCapture(input)
		return
	end
	if UserInputService:GetFocusedTextBox() then
		return
	end
	local keys = CONFIG.Keys
	local gamepadKeys = CONFIG.GamepadKeys
	local isGamepad = inputIsGamepad(input)
	local function matches(action)
		return input.KeyCode == keys[action] or (isGamepad and input.KeyCode == gamepadKeys[action])
	end
	if input.KeyCode == keys.Destroy and not isGamepad and UserInputService:IsKeyDown(keys.DestroyModifier) then
		Blossom.Destroy()
	elseif matches("Debug") then
		toggleDebug()
	elseif matches("Screenshot") then
		captureShot()
	elseif matches("Hide") then
		toggleMenu()
	end
end

local function buildReopen()
	local height = Device.touch and 44 or 36
	local button = makeButton(State.root, {
		Text = clean(CONFIG.Brand.Name, 24),
		Variant = "Primary",
		Size = UDim2.new(0, 112, 0, height),
		TextSize = 12,
		Bold = true,
		Radius = 16,
		ZIndex = 25,
	})
	button.Instance.AnchorPoint = Vector2.new(0, 1)
	button.Instance.Position = UDim2.new(0, 12, 1, -12)
	button.Instance.Visible = false
	button.Instance:SetAttribute("Reopen", true)
	button:Bind(function()
		toggleMenu()
	end)
	State.reopen = button.Instance
end

local function buildGui()
	Metrics = computeMetrics()
	local gui = new("ScreenGui", {
		Name = CONFIG.GuiName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 60,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = true,
	}, State.playerGui)
	State.gui = gui
	gui:SetAttribute("Building", true)
	local protect = executorFunction("protect_gui")
	if protect then
		pcall(protect, gui)
	end
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	end)
	State.root = new("Frame", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
	}, gui)
	State.rootScale = new("UIScale", { Scale = 1 }, State.root)
	State.backdrop = new("Frame", {
		Name = "Backdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Tokens.dim,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		Role = "Backdrop",
		ZIndex = 1,
	}, State.root)
	State.stage = new("Frame", {
		Name = "Stage",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, State.root)
	State.flash = new("Frame", {
		Name = "Flash",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
	}, State.root)
	State.countdown = new("TextLabel", {
		Name = "Countdown",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Font = boldFont(),
		TextSize = 72,
		TextColor3 = Tokens.textPrimary,
		TextTransparency = 1,
		ZIndex = 14,
	}, State.root)
	State.countdown:SetAttribute("Bold", true)
	State.countdown:SetAttribute("FixedSize", true)
	buildToast(State.root)
	buildMain()
	buildCustomize()
	buildDebug()
	buildReopen()
	gui:SetAttribute("Building", false)
end

local function destroyGuiCopies()
	local hosts = { State.playerGui }
	if State.player then
		local playerGui = State.player:FindFirstChild("PlayerGui")
		if playerGui and playerGui ~= State.playerGui then
			table.insert(hosts, playerGui)
		end
	end
	for _, host in ipairs(hosts) do
		if host then
			for _, child in ipairs(host:GetChildren()) do
				if child.Name == CONFIG.GuiName and child:IsA("ScreenGui") then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end
	end
end

local function getEnvironment()
	local player = Players.LocalPlayer
	if not player then
		player = Players.PlayerAdded:Wait()
	end
	local playerGui = player:WaitForChild("PlayerGui", 15)
	if not playerGui then
		error("PlayerGui did not load in time")
	end
	if not game:IsLoaded() then
		local loaded = false
		local conn = game.Loaded:Connect(function()
			loaded = true
		end)
		local started = os.clock()
		while not loaded and os.clock() - started < 20 do
			task.wait(0.1)
		end
		conn:Disconnect()
	end
	local gethui = executorFunction("gethui")
	if gethui then
		local ok, hidden = pcall(gethui)
		if ok and typeof(hidden) == "Instance" then
			return player, hidden
		end
	end
	return player, playerGui
end

local function showFatal(message)
	pcall(function()
		local gui = Instance.new("ScreenGui")
		gui.Name = CONFIG.GuiName
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 100
		gui.Parent = State.playerGui
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0.5, 0, 0, 24)
		frame.Size = UDim2.new(0, 400, 0, 104)
		frame.BackgroundColor3 = Color3.fromRGB(30, 14, 16)
		frame.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = frame
		local label = Instance.new("TextLabel")
		label.Position = UDim2.new(0, 12, 0, 10)
		label.Size = UDim2.new(1, -24, 1, -20)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 13
		label.TextColor3 = Color3.fromRGB(255, 196, 196)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.TextWrapped = true
		label.Text = "Blossom failed to start:\n" .. clean(tostring(message), 500)
		label.Parent = frame
	end)
end

local function registerBuiltins()
	Blossom.RegisterModule({
		Id = "animation",
		Title = "Animation",
		Subtitle = "timing",
		Icon = "diamond",
		Priority = 20,
		Controls = {
			{ Type = "Slider", Label = "Duration scale", Min = 0.25, Max = 2, Step = 0.05, Value = CONFIG.Durations.Scale, OnChange = function(value)
				CONFIG.Durations.Scale = value
			end },
			{ Type = "Slider", Label = "Hover time", Min = 0.04, Max = 0.6, Step = 0.02, Value = CONFIG.Durations.Hover, OnChange = function(value)
				CONFIG.Durations.Hover = value
			end },
			{ Type = "Button", Text = "Replay loader", Variant = "Primary", OnClick = function(api)
				api.Toast("Playing loader")
				playGallery()
			end },
		},
	})
	Blossom.RegisterModule({
		Id = "capture",
		Title = "Capture",
		Subtitle = "screenshots",
		Icon = "camera",
		Priority = 60,
		Controls = {
			{ Type = "Button", Text = "Save screenshot", OnClick = function()
				captureShot()
			end },
			{ Type = "Button", Text = "Toggle debug overlay", OnClick = function()
				toggleDebug()
			end },
		},
	})
	Blossom.RegisterModule({
		Id = "interface",
		Title = "Interface",
		Subtitle = "notifications",
		Icon = "sliders",
		Priority = 70,
		Controls = {
			{ Type = "Input", Label = "Status message", Placeholder = "Type and press Enter", OnSubmit = function(text, api)
				api.Toast(text ~= "" and text or "Hello from a module")
			end },
		},
	})
end

local function runStartup()
	setLoading(true)
	setBackdrop("loading")
	State.token = State.token + 1
	local token = State.token
	if CONFIG.AutoPlay then
		safeCall(function()
			waitToken(CONFIG.StartupDelay, token)
			if State.token ~= token then
				return
			end
			local total = loaderSplash()
			waitToken((tonumber(total) or 2) + 0.05, token)
		end)
	end
	if State.token == token then
		clearStage()
		setLoading(false)
		showMain(true)
		setBackdrop("main")
	end
end

local destroyAll

local function main()
	State.player, State.playerGui = getEnvironment()
	if type(_G.BlossomDestroy) == "function" then
		pcall(_G.BlossomDestroy)
	end
	destroyGuiCopies()
	_G.BlossomDestroy = destroyAll
	_G.Blossom = Blossom
	loadProfile()
	local skin = State.profileSkin
	if not skin or not SKINS[skin] then
		skin = "Sakura"
	end
	State.theme = copy(SKINS[skin] or SKINS.Sakura)
	recalcTokens(State.theme)
	connect(UserInputService.InputBegan, handleInput)
	local camera = workspace.CurrentCamera
	if camera then
		local pending = false
		connect(camera:GetPropertyChangedSignal("ViewportSize"), function()
			if pending then
				return
			end
			pending = true
			task.delay(0.1, function()
				pending = false
				if not State.destroyed then
					updateLayout()
				end
			end)
		end)
	end
	registerBuiltins()
	Blossom.LoadModules()
	buildGui()
	if State.destroyed then
		return
	end
	task.wait()
	if State.destroyed then
		return
	end
	applyTheme(State.theme, false)
	State.ready = true
	runStartup()
	if State.autoExecute then
		task.spawn(function()
			task.wait(1)
			for _, module in ipairs(Blossom.Modules) do
				if module.AutoRun and module.Run and not module.AutoStarted then
					module.AutoStarted = true
					runModule(module)
				end
			end
		end)
	end
end

destroyAll = function()
	if State.destroyed then
		return
	end
	State.destroyed = true
	State.token = State.token + 1
	State.playing = false
	for _, module in ipairs(Blossom.Modules) do
		pcall(stopModule, module, true)
		if module.OnUnmount then
			pcall(module.OnUnmount, moduleContext(module))
		end
	end
	if State.debugConn then
		pcall(function()
			State.debugConn:Disconnect()
		end)
		State.debugConn = nil
	end
	clearSliderConnections()
	cancelList(StageTweens)
	cancelList(ThemeTweens)
	cancelList(TweenList)
	cancelList(PetalTweens)
	for _, conn in ipairs(Connections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(Connections)
	table.clear(REBUILD)
	if State.blur then
		pcall(function()
			State.blur:Destroy()
		end)
		State.blur = nil
	end
	if State.gui then
		pcall(function()
			State.gui:Destroy()
		end)
		State.gui = nil
	end
	destroyGuiCopies()
	if _G.BlossomDestroy == destroyAll then
		_G.BlossomDestroy = nil
	end
	print("Blossom destroyed")
end

Blossom.Config = CONFIG

Blossom.Destroy = function()
	destroyAll()
end

Blossom.Show = function()
	State.userHidden = false
	if not State.mainVisible then
		showMain(true)
	else
		applyVisibility()
	end
end

Blossom.Hide = function()
	State.userHidden = true
	cancelKeyCapture()
	applyVisibility()
end

Blossom.Toast = function(text, isError)
	toast(text, isError)
end

Blossom.ApplySkin = function(name)
	return Blossom.SetSkin(name)
end

Blossom.RefreshLayout = function()
	updateLayout()
end

local started, failure = pcall(main)
if not started then
	pcall(destroyAll)
	State.destroyed = false
	showFatal(failure)
	warn("[Blossom] startup error: " .. tostring(failure))
end
