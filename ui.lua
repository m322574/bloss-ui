local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local CaptureService = game:GetService("CaptureService")
local Lighting = game:GetService("Lighting")

local function copyTable(t)
	local out = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			out[k] = copyTable(v)
		else
			out[k] = v
		end
	end
	return out
end

local function clampNum(v, lo, hi)
	if v < lo then
		return lo
	end
	if v > hi then
		return hi
	end
	return v
end

local function mixColor(a, b, t)
	return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function hexToColor(hex)
	local r = tonumber(hex:sub(2, 3), 16)
	local g = tonumber(hex:sub(4, 5), 16)
	local b = tonumber(hex:sub(6, 7), 16)
	if not r or not g or not b then
		return Color3.new(1, 1, 1)
	end
	return Color3.fromRGB(r, g, b)
end

local function sanitizeString(s, maxLen)
	if type(s) ~= "string" then
		return ""
	end
	s = s:gsub("%c", "")
	s = s:match("^%s*(.-)%s*$") or ""
	if #s > maxLen then
		s = s:sub(1, maxLen)
	end
	return s
end

local function isHexColor(s)
	if type(s) ~= "string" then
		return false
	end
	return s:match("^#%x%x%x%x%x%x$") ~= nil
end

local ASSETS = {
	LoaderLogo = "152989766",
	Avatar = "7395055006",
}

local CONFIG = {
	GuiName = "Blossom",
	AutoPlay = true,
	StartupDelay = 0.25,
	DestroyModifier = Enum.KeyCode.LeftShift,
	DestroyKey = Enum.KeyCode.Delete,
	DebugKey = Enum.KeyCode.F1,
	ScreenshotKey = Enum.KeyCode.F12,
	HideKey = Enum.KeyCode.RightShift,
	Grid = 4,
	Brand = {
		Name = "Blossom",
		Tag = "script hub",
		AvatarImageId = ASSETS.Avatar,
	},
	Layout = {
		MaxWidth = 560,
		CompactWidth = 420,
		Padding = 16,
		Gap = 12,
		CornerRadius = 12,
		SmallCornerRadius = 8,
		TitleSize = 24,
		BodySize = 13,
		CaptionSize = 12,
		ButtonHeight = 32,
		RowHeight = 40,
		InputHeight = 36,
		MinScale = 0.6,
	},
	Theme = {
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
	},
	Durations = {
		Scale = 1,
		PreloadTimeout = 6,
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
		Shimmer = 1.4,
		LoopGap = 0.5,
	},
	Easing = {
		Fill = "Quint",
		FillDir = "Out",
		Fade = "Quad",
		FadeDir = "Out",
		Slide = "Quint",
		SlideDir = "Out",
		Pop = "Back",
		PopDir = "Out",
		Hover = "Quad",
		HoverDir = "Out",
		Press = "Quad",
		PressDir = "Out",
		Spin = "Linear",
		SpinDir = "Out",
		Theme = "Quint",
		ThemeDir = "Out",
	},
	Quality = {
		Auto = true,
		Level = "Auto",
		FpsLow = 30,
		FpsHigh = 50,
		SampleFrames = 16,
		WarmupFrames = 6,
		RecheckInterval = 8,
		UpgradeMargin = 3,
		Low = { Shimmer = false, Blur = false, Instant = true, DurationScale = 0.8, ScalePop = false },
		Medium = { Shimmer = true, Blur = false, Instant = false, DurationScale = 0.95, ScalePop = true },
		High = { Shimmer = true, Blur = true, Instant = false, DurationScale = 1, ScalePop = true },
	},
	Gallery = {
		DefaultSpeed = 1,
		CountdownEnabled = true,
		LoopEnabled = false,
		Speeds = { 1, 0.5, 0.25 },
	},
	Debug = {
		StartVisible = false,
		UpdateRate = 0.25,
	},
	Screenshot = {
		FlashDuration = 0.2,
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
		PetalCount = 14,
		TitleColor = "#FCEFF4",
		SubColor = "#C79BAC",
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
}

local SKINS = {
	["Obsidian"] = copyTable(CONFIG.Theme),
	["Porcelain"] = {
		Name = "Porcelain",
		Mode = "light",
		Accent = "#0E8C6D",
		Base = "#F3F5F9",
		PanelTransparency = 0,
		CardTransparency = 0,
		StrokeTransparency = 0.72,
		StrokeThickness = 1,
		GradientTop = "#FFFFFF",
		GradientTopTransparency = 0.9,
		GradientBottomTransparency = 1,
		TextPrimary = "#11151C",
		TextSecondary = "#5A6272",
		TextDisabled = "#98A0AD",
		DimColor = "#AEB6C2",
		DimTransparency = 0.35,
		ProgressTrack = "#D3DAE4",
		ProgressFill = "#0E8C6D",
		SkeletonBase = "#DDE3EC",
		SkeletonHighlight = "#EFF3F8",
		ShimmerTransparency = 0.35,
		Font = "GothamMedium",
		CornerRadius = 10,
		Spacing = 12,
		BackgroundImage = "",
		LogoImage = "",
		SpinnerImage = "",
		TextureImage = "",
		BlurEnabled = false,
		BlurSize = 8,
		SidebarColor = "#E9EDF3",
		CardColor = "#FFFFFF",
		DividerColor = "#DCE3EC",
		BannerA = "#BFE9DE",
		BannerB = "#CFE4FF",
		BannerC = "#F3F5F9",
	},
	["Ember"] = {
		Name = "Ember",
		Mode = "dark",
		Accent = "#FF9A5A",
		Base = "#100D0B",
		PanelTransparency = 0,
		CardTransparency = 0,
		StrokeTransparency = 0.9,
		StrokeThickness = 1,
		GradientTop = "#FFFFFF",
		GradientTopTransparency = 0.94,
		GradientBottomTransparency = 1,
		TextPrimary = "#F6EDE6",
		TextSecondary = "#A8958A",
		TextDisabled = "#5E5148",
		DimColor = "#0A0705",
		DimTransparency = 0.38,
		ProgressTrack = "#241C17",
		ProgressFill = "#FF9A5A",
		SkeletonBase = "#1C1613",
		SkeletonHighlight = "#2A211B",
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
		SidebarColor = "#0A0705",
		CardColor = "#1A1411",
		DividerColor = "#2A211B",
		BannerA = "#7A2E0C",
		BannerB = "#C75B24",
		BannerC = "#120B07",
	},
	["Sakura"] = {
		Name = "Sakura",
		Mode = "light",
		Accent = "#D6568C",
		Base = "#FBF3F6",
		PanelTransparency = 0,
		CardTransparency = 0,
		StrokeTransparency = 0.74,
		StrokeThickness = 1,
		GradientTop = "#FFFFFF",
		GradientTopTransparency = 0.9,
		GradientBottomTransparency = 1,
		TextPrimary = "#1C1418",
		TextSecondary = "#6B5A62",
		TextDisabled = "#A8959E",
		DimColor = "#B9A6AE",
		DimTransparency = 0.34,
		ProgressTrack = "#EEDCE4",
		ProgressFill = "#D6568C",
		SkeletonBase = "#EEDCE4",
		SkeletonHighlight = "#F8EDF1",
		ShimmerTransparency = 0.35,
		Font = "GothamMedium",
		CornerRadius = 12,
		Spacing = 12,
		BackgroundImage = "",
		LogoImage = "",
		SpinnerImage = "",
		TextureImage = "",
		BlurEnabled = false,
		BlurSize = 8,
		SidebarColor = "#F6E9EF",
		CardColor = "#FFFFFF",
		DividerColor = "#EFDCE5",
		BannerA = "#F3C3D8",
		BannerB = "#F7C0D6",
		BannerC = "#FBF3F6",
	},
	["Midnight"] = {
		Name = "Midnight",
		Mode = "dark",
		Accent = "#7C8CFF",
		Base = "#080A14",
		PanelTransparency = 0,
		CardTransparency = 0,
		StrokeTransparency = 0.9,
		StrokeThickness = 1,
		GradientTop = "#FFFFFF",
		GradientTopTransparency = 0.94,
		GradientBottomTransparency = 1,
		TextPrimary = "#E8ECFF",
		TextSecondary = "#8890B4",
		TextDisabled = "#4C5470",
		DimColor = "#04060F",
		DimTransparency = 0.4,
		ProgressTrack = "#161A2C",
		ProgressFill = "#7C8CFF",
		SkeletonBase = "#131728",
		SkeletonHighlight = "#1D2338",
		ShimmerTransparency = 0.3,
		Font = "GothamMedium",
		CornerRadius = 12,
		Spacing = 12,
		BackgroundImage = "",
		LogoImage = "",
		SpinnerImage = "",
		TextureImage = "",
		BlurEnabled = true,
		BlurSize = 14,
		SidebarColor = "#05060D",
		CardColor = "#121628",
		DividerColor = "#1E2438",
		BannerA = "#2A1E7A",
		BannerB = "#4C3BC9",
		BannerC = "#070A12",
	},
	["Ice"] = {
		Name = "Ice",
		Mode = "light",
		Accent = "#0F7FA8",
		Base = "#EFF6FA",
		PanelTransparency = 0,
		CardTransparency = 0,
		StrokeTransparency = 0.76,
		StrokeThickness = 1,
		GradientTop = "#FFFFFF",
		GradientTopTransparency = 0.9,
		GradientBottomTransparency = 1,
		TextPrimary = "#0E1B22",
		TextSecondary = "#4C6470",
		TextDisabled = "#93A8B3",
		DimColor = "#A7BCC6",
		DimTransparency = 0.35,
		ProgressTrack = "#D5E5EE",
		ProgressFill = "#0F7FA8",
		SkeletonBase = "#DCEAF2",
		SkeletonHighlight = "#F2F9FC",
		ShimmerTransparency = 0.34,
		Font = "GothamMedium",
		CornerRadius = 10,
		Spacing = 12,
		BackgroundImage = "",
		LogoImage = "",
		SpinnerImage = "",
		TextureImage = "",
		BlurEnabled = false,
		BlurSize = 8,
		SidebarColor = "#E4EFF6",
		CardColor = "#FFFFFF",
		DividerColor = "#D6E6EF",
		BannerA = "#C3E6F5",
		BannerB = "#BDF0E6",
		BannerC = "#EFF6FA",
	},
	["Moss"] = {
		Name = "Moss",
		Mode = "dark",
		Accent = "#8BD16B",
		Base = "#0A0F0B",
		PanelTransparency = 0,
		CardTransparency = 0,
		StrokeTransparency = 0.9,
		StrokeThickness = 1,
		GradientTop = "#FFFFFF",
		GradientTopTransparency = 0.94,
		GradientBottomTransparency = 1,
		TextPrimary = "#EAF3E6",
		TextSecondary = "#92A48C",
		TextDisabled = "#52604E",
		DimColor = "#050805",
		DimTransparency = 0.4,
		ProgressTrack = "#18211A",
		ProgressFill = "#8BD16B",
		SkeletonBase = "#141B15",
		SkeletonHighlight = "#1E281F",
		ShimmerTransparency = 0.3,
		Font = "GothamMedium",
		CornerRadius = 8,
		Spacing = 12,
		BackgroundImage = "",
		LogoImage = "",
		SpinnerImage = "",
		TextureImage = "",
		BlurEnabled = true,
		BlurSize = 12,
		SidebarColor = "#060A07",
		CardColor = "#131A14",
		DividerColor = "#1F2921",
		BannerA = "#1D4A31",
		BannerB = "#4E8F55",
		BannerC = "#08110B",
	},
	["Sandstone"] = {
		Name = "Sandstone",
		Mode = "light",
		Accent = "#A9713F",
		Base = "#F7F1E7",
		PanelTransparency = 0,
		CardTransparency = 0,
		StrokeTransparency = 0.72,
		StrokeThickness = 1,
		GradientTop = "#FFFFFF",
		GradientTopTransparency = 0.9,
		GradientBottomTransparency = 1,
		TextPrimary = "#241C14",
		TextSecondary = "#6E6052",
		TextDisabled = "#A6988A",
		DimColor = "#BCAC99",
		DimTransparency = 0.36,
		ProgressTrack = "#E9DFD1",
		ProgressFill = "#A9713F",
		SkeletonBase = "#EDE3D5",
		SkeletonHighlight = "#FAF5EC",
		ShimmerTransparency = 0.34,
		Font = "GothamMedium",
		CornerRadius = 12,
		Spacing = 12,
		BackgroundImage = "",
		LogoImage = "",
		SpinnerImage = "",
		TextureImage = "",
		BlurEnabled = false,
		BlurSize = 8,
		SidebarColor = "#F1E8DA",
		CardColor = "#FFFDF9",
		DividerColor = "#E5D9C8",
		BannerA = "#EFD9B8",
		BannerB = "#DCC7A6",
		BannerC = "#FBF7EF",
	},
}

local SKIN_ORDER = { "Sakura", "Obsidian", "Porcelain", "Ember", "Midnight", "Ice", "Moss", "Sandstone" }

local BUILTIN_SKINS = {}
for _, skinName in ipairs(SKIN_ORDER) do
	BUILTIN_SKINS[skinName] = true
end

local function skinNames()
	local out = {}
	for _, skinName in ipairs(SKIN_ORDER) do
		if SKINS[skinName] then
			table.insert(out, skinName)
		end
	end
	return out
end

local function registerSkin(name, theme)
	local cleanName = sanitizeString(tostring(name or ""), 24)
	if cleanName == "" then
		return nil
	end
	local clean = copyTable(theme or CONFIG.Theme)
	clean.Name = cleanName
	SKINS[cleanName] = clean
	local known = false
	for _, skinName in ipairs(SKIN_ORDER) do
		if skinName == cleanName then
			known = true
			break
		end
	end
	if not known then
		table.insert(SKIN_ORDER, cleanName)
	end
	return cleanName
end

local FEATURES = {
	{
		Name = "Animation",
		Controls = {
			{ Type = "Slider", Label = "Duration scale", Min = 0.25, Max = 2, Step = 0.05, Value = CONFIG.Durations.Scale, OnChange = function(value)
				CONFIG.Durations.Scale = value
			end },
			{ Type = "Slider", Label = "Hover time", Min = 0.04, Max = 0.6, Step = 0.02, Value = CONFIG.Durations.Hover, OnChange = function(value)
				CONFIG.Durations.Hover = value
			end },
			{ Type = "Slider", Label = "Transition time", Min = 0.1, Max = 2, Step = 0.05, Value = CONFIG.Durations.Transition, OnChange = function(value)
				CONFIG.Durations.Transition = value
			end },
			{ Type = "Button", Text = "Replay current loader", Variant = "Primary", OnClick = function(api)
				api.PlayLoader()
			end },
		},
	},
	{
		Name = "Capture",
		Controls = {
			{ Type = "Button", Text = "Toggle debug overlay", OnClick = function(api)
				api.ToggleDebug()
			end },
			{ Type = "Button", Text = "Save screenshot", OnClick = function(api)
				api.Capture()
			end },
		},
	},
	{
		Name = "Interface",
		Controls = {
			{ Type = "Input", Label = "Status message", Placeholder = "Type and press Enter", OnSubmit = function(text, api)
				api.Toast(text)
			end },
		},
	},
}

local SCHEMA = {
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
local DIR_NAMES = { "In", "Out", "InOut" }

local EASING_STYLES = {
	Linear = Enum.EasingStyle.Linear,
	Quad = Enum.EasingStyle.Quad,
	Cubic = Enum.EasingStyle.Cubic,
	Quart = Enum.EasingStyle.Quart,
	Quint = Enum.EasingStyle.Quint,
	Sine = Enum.EasingStyle.Sine,
	Exponential = Enum.EasingStyle.Exponential,
	Circular = Enum.EasingStyle.Circular,
	Back = Enum.EasingStyle.Back,
	Bounce = Enum.EasingStyle.Bounce,
	Elastic = Enum.EasingStyle.Elastic,
}

local EASING_DIRS = {
	In = Enum.EasingDirection.In,
	Out = Enum.EasingDirection.Out,
	InOut = Enum.EasingDirection.InOut,
}

local CONFIG_SCHEMA = {
	{
		key = "Durations",
		type = "group",
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
		type = "group",
		fields = {
			{ key = "Fill", type = "enum", options = EASING_NAMES },
			{ key = "FillDir", type = "enum", options = DIR_NAMES },
			{ key = "Fade", type = "enum", options = EASING_NAMES },
			{ key = "FadeDir", type = "enum", options = DIR_NAMES },
			{ key = "Slide", type = "enum", options = EASING_NAMES },
			{ key = "SlideDir", type = "enum", options = DIR_NAMES },
			{ key = "Pop", type = "enum", options = EASING_NAMES },
			{ key = "PopDir", type = "enum", options = DIR_NAMES },
			{ key = "Hover", type = "enum", options = EASING_NAMES },
			{ key = "HoverDir", type = "enum", options = DIR_NAMES },
			{ key = "Press", type = "enum", options = EASING_NAMES },
			{ key = "PressDir", type = "enum", options = DIR_NAMES },
			{ key = "Spin", type = "enum", options = EASING_NAMES },
			{ key = "SpinDir", type = "enum", options = DIR_NAMES },
			{ key = "Theme", type = "enum", options = EASING_NAMES },
			{ key = "ThemeDir", type = "enum", options = DIR_NAMES },
		},
	},
	{
		key = "Layout",
		type = "group",
		fields = {
			{ key = "MaxWidth", type = "number", min = 240, max = 1200 },
			{ key = "CompactWidth", type = "number", min = 200, max = 900 },
			{ key = "Padding", type = "number", min = 0, max = 64 },
			{ key = "Gap", type = "number", min = 0, max = 48 },
			{ key = "CornerRadius", type = "number", min = 0, max = 40 },
			{ key = "SmallCornerRadius", type = "number", min = 0, max = 40 },
			{ key = "TitleSize", type = "number", min = 12, max = 48 },
			{ key = "BodySize", type = "number", min = 12, max = 32 },
			{ key = "CaptionSize", type = "number", min = 12, max = 24 },
			{ key = "ButtonHeight", type = "number", min = 24, max = 72 },
			{ key = "RowHeight", type = "number", min = 28, max = 96 },
			{ key = "InputHeight", type = "number", min = 24, max = 80 },
			{ key = "MinScale", type = "number", min = 0.3, max = 1 },
		},
	},
	{
		key = "Quality",
		type = "group",
		fields = {
			{ key = "Level", type = "enum", options = { "Auto", "Low", "Medium", "High" } },
			{ key = "Auto", type = "bool" },
			{ key = "FpsLow", type = "number", min = 10, max = 120 },
			{ key = "FpsHigh", type = "number", min = 15, max = 240 },
			{ key = "SampleFrames", type = "number", min = 4, max = 240 },
			{ key = "WarmupFrames", type = "number", min = 0, max = 60 },
			{ key = "RecheckInterval", type = "number", min = 0, max = 120 },
			{ key = "UpgradeMargin", type = "number", min = 0, max = 15 },
		},
	},
	{ key = "Theme", type = "theme" },
}

local PLAYER
local PLAYER_GUI
local Gui
local Root
local RootScale
local Backdrop
local Stage
local Main
local MainColumn
local MainScale
local MainShadow
local SidebarPanel
local ContentPanel
local BannerTitle
local BannerSubtitle
local NavList
local NavPill
local NavIndicator
local Customize
local DebugFrame
local CountdownLabel
local ToastGroup
local ToastLabel
local ToastStripe
local ToastSeq = 0
local Blur
local CURRENT_THEME = copyTable(CONFIG.Theme)
local TC = {}
local QUALITY = { Name = "Medium", Shimmer = true, Blur = false, Instant = false, DurationScale = 1, ScalePop = true }
local TOKEN = 0
local PLAYING = false
local DESTROYED = false
local ACTIVE_SPEED = 1
local MainVisible = false
local REFRESH = {}
local CONNS = {}
local TWEENS = {}
local STAGE_TWEENS = {}
local STAGE_CONNS = {}
local DebugState = { conn = nil, visible = false, clock = 0, frames = 0, fps = 0, instances = nil, instClock = 0 }
local GalleryState = { speed = 1, loop = false, countdown = true }
local AutoExecute = false


local function dur(v)
	return v * CONFIG.Durations.Scale * QUALITY.DurationScale / ACTIVE_SPEED
end

local function isLowEnd()
	return QUALITY.Name == "Low"
end

local function mdur(v)
	local d = v * CONFIG.Durations.Scale * QUALITY.DurationScale / ACTIVE_SPEED
	if isLowEnd() then
		return math.min(d, 0.12)
	end
	return d
end

local function ti(v, style, dir, repeatCount, reverses, delayTime)
	local s = EASING_STYLES[style] or Enum.EasingStyle.Quad
	local d = EASING_DIRS[dir] or Enum.EasingDirection.Out
	return TweenInfo.new(math.max(0.01, v), s, d, repeatCount or 0, reverses or false, delayTime or 0)
end

local function trackConn(c)
	for i = #CONNS, 1, -1 do
		local item = CONNS[i]
		if item.Connected == false then
			table.remove(CONNS, i)
		end
	end
	table.insert(CONNS, c)
	return c
end

local function trackStageConn(c)
	table.insert(STAGE_CONNS, c)
	return c
end

local TWEEN_INDEX = setmetatable({}, { __mode = "k" })

local function cancelPropTweens(target, props)
	local index = TWEEN_INDEX[target]
	if not index then
		return
	end
	for key in pairs(props) do
		local existing = index[key]
		if existing then
			index[key] = nil
			pcall(function()
				existing:Cancel()
			end)
		end
	end
end

local function playTween(target, info, props, list)
	if DESTROYED or target == nil then
		return nil
	end
	cancelPropTweens(target, props)
	local ok, tw = pcall(function()
		return TweenService:Create(target, info, props)
	end)
	if not ok or tw == nil then
		return nil
	end
	local played = pcall(function()
		tw:Play()
	end)
	if not played then
		return nil
	end
	local index = TWEEN_INDEX[target]
	if not index then
		index = {}
		TWEEN_INDEX[target] = index
	end
	for key in pairs(props) do
		index[key] = tw
	end
	local store = list or TWEENS
	for i = #store, 1, -1 do
		local item = store[i]
		if item.PlaybackState ~= Enum.PlaybackState.Playing then
			table.remove(store, i)
		end
	end
	table.insert(store, tw)
	return tw
end

local function uiTween(target, props, duration, style, dir)
	if target == nil then
		return nil
	end
	return playTween(target, ti(mdur(duration or CONFIG.Durations.Hover), style or "Quad", dir or "Out"), props)
end

local function cancelList(list)
	for i = #list, 1, -1 do
		local tw = list[i]
		pcall(function()
			tw:Cancel()
		end)
		table.remove(list, i)
	end
end

local function hoverTime(entering)
	local base = CONFIG.Durations.Hover
	return entering and base * 0.6 or base * 1.25
end

local function hoverTween(target, props, entering)
	return uiTween(target, props, hoverTime(entering), CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
end

local function new(class, props, parent)
	local inst = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			if k ~= "Parent" and k ~= "Role" and k ~= "Tier" and k ~= "TextRole" and k ~= "ImageRole" and k ~= "Pooled" then
				inst[k] = v
			end
		end
		if props.Role then
			inst:SetAttribute("Role", props.Role)
		end
		if props.Tier then
			inst:SetAttribute("Tier", props.Tier)
		end
		if props.TextRole then
			inst:SetAttribute("TextRole", props.TextRole)
		end
		if props.ImageRole then
			inst:SetAttribute("ImageRole", props.ImageRole)
		end
		if props.Pooled then
			inst:SetAttribute("Pooled", true)
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local ThemeCache = {
	list = nil,
	fonts = {},
	animated = {
		Panel = true,
		Sidebar = true,
		Card = true,
		Surface = true,
		Backdrop = true,
		Input = true,
		Button = true,
	},
}

local function themeFont()
	local name = tostring(CURRENT_THEME.Font or "")
	local cached = ThemeCache.fonts[name]
	if cached then
		return cached
	end
	local ok, f = pcall(function()
		return Enum.Font[name]
	end)
	f = (ok and f) or Enum.Font.GothamMedium
	ThemeCache.fonts[name] = f
	return f
end

local function boldFont()
	local name = CURRENT_THEME.Font
	if name == "Gotham" or name == "GothamMedium" or name == "GothamBold" then
		return Enum.Font.GothamBold
	end
	return themeFont()
end

local function tierColor(tier)
	if tier == "Secondary" then
		return TC.textSecondary
	elseif tier == "Disabled" then
		return TC.textDisabled
	elseif tier == "Accent" then
		return TC.accent
	elseif tier == "OnAccent" then
		return TC.onAccent
	end
	return TC.textPrimary
end

local function textRoleSize(role, L)
	if role == "Title" then
		return L.TitleSize
	elseif role == "Caption" then
		return L.CaptionSize
	end
	return L.BodySize
end

local function refreshAll()
	for i = #REFRESH, 1, -1 do
		local fn = REFRESH[i]
		local ok = pcall(fn)
		if not ok then
			table.remove(REFRESH, i)
		end
	end
end

local function recomputeColors(th)
	TC = {
		accent = hexToColor(th.Accent),
		base = hexToColor(th.Base),
		textPrimary = hexToColor(th.TextPrimary),
		textSecondary = hexToColor(th.TextSecondary),
		textDisabled = hexToColor(th.TextDisabled),
		onAccent = th.Mode == "dark" and Color3.fromRGB(28, 8, 18) or Color3.new(1, 1, 1),
		dim = hexToColor(th.DimColor),
		track = hexToColor(th.ProgressTrack),
		fill = hexToColor(th.ProgressFill),
		skeleton = hexToColor(th.SkeletonBase),
		shimmer = hexToColor(th.SkeletonHighlight),
		gradientTop = hexToColor(th.GradientTop),
		sidebar = hexToColor(th.SidebarColor or th.Base),
		card = hexToColor(th.CardColor or th.Base),
		divider = hexToColor(th.DividerColor or th.ProgressTrack),
		bannerA = hexToColor(th.BannerA or th.Accent),
		bannerB = hexToColor(th.BannerB or th.ProgressFill),
		bannerC = hexToColor(th.BannerC or th.Base),
	}
	local dark = th.Mode == "dark"
	TC.button = mixColor(TC.base, TC.textPrimary, dark and 0.08 or 0.05)
	TC.buttonHover = mixColor(TC.base, TC.textPrimary, dark and 0.13 or 0.09)
	TC.buttonPressed = mixColor(TC.base, TC.textPrimary, dark and 0.18 or 0.13)
	TC.accentHover = mixColor(TC.accent, Color3.new(1, 1, 1), 0.14)
	TC.accentPressed = mixColor(TC.accent, Color3.new(0, 0, 0), 0.12)
end

local function checkValue(v, f)
	if f.type == "number" then
		if type(v) ~= "number" then
			return false, nil, "must be a number"
		end
		if v ~= v or v == math.huge or v == -math.huge then
			return false, nil, "must be a finite number"
		end
		local c = clampNum(v, f.min, f.max)
		if c ~= v then
			return true, c, f.key .. " clamped to " .. tostring(c)
		end
		return true, c, nil
	elseif f.type == "bool" then
		if type(v) ~= "boolean" then
			return false, nil, "must be true or false"
		end
		return true, v, nil
	elseif f.type == "enum" then
		if type(v) ~= "string" then
			return false, nil, "must be one of " .. table.concat(f.options, ", ")
		end
		local s = sanitizeString(v, 32)
		for _, opt in ipairs(f.options) do
			if s == opt then
				return true, s, nil
			end
		end
		return false, nil, "must be one of " .. table.concat(f.options, ", ")
	elseif f.type == "color" then
		if type(v) ~= "string" then
			return false, nil, "must be a hex color like #4FC3F7"
		end
		local s = sanitizeString(v, 8)
		if not isHexColor(s) then
			return false, nil, "must be a hex color like #4FC3F7"
		end
		return true, string.upper(s), nil
	elseif f.type == "image" then
		if type(v) ~= "string" and type(v) ~= "number" then
			return false, nil, "must be a numeric asset id"
		end
		local s = sanitizeString(tostring(v), 64)
		local id = s:match("^rbxassetid://(%d+)$") or s:match("^(%d+)$")
		if not id then
			return false, nil, "must be a numeric asset id"
		end
		return true, id, nil
	elseif f.type == "string" then
		if type(v) ~= "string" then
			return false, nil, "must be a string"
		end
		local s = sanitizeString(v, f.maxLen or 32)
		return true, s, nil
	end
	return false, nil, "is not supported"
end

local function validateFields(data, schema, defaults)
	local out = {}
	local errors = {}
	local notes = {}
	if type(data) ~= "table" then
		return nil, { "value must be a JSON object" }, {}
	end
	for _, f in ipairs(schema) do
		local v = data[f.key]
		if v == nil then
			out[f.key] = defaults[f.key]
		else
			local ok, val, msg = checkValue(v, f)
			if ok then
				out[f.key] = val
				if msg then
					table.insert(notes, msg)
				end
			else
				out[f.key] = defaults[f.key]
				table.insert(errors, f.key .. " " .. msg)
			end
		end
	end
	local unknown = {}
	for k in pairs(data) do
		local found = false
		for _, f in ipairs(schema) do
			if f.key == k then
				found = true
				break
			end
		end
		if not found then
			table.insert(unknown, sanitizeString(tostring(k), 40))
		end
	end
	table.sort(unknown)
	if #unknown > 0 then
		table.insert(notes, "ignored fields: " .. table.concat(unknown, ", "))
	end
	return out, errors, notes
end

local function validateTheme(data)
	return validateFields(data, SCHEMA, CONFIG.Theme)
end

local function validateConfig(data)
	local out = {}
	local errors = {}
	local notes = {}
	if type(data) ~= "table" then
		return nil, { "value must be a JSON object" }, {}
	end
	for _, group in ipairs(CONFIG_SCHEMA) do
		if group.type == "group" then
			local raw = data[group.key]
			if raw ~= nil then
				if type(raw) ~= "table" then
					table.insert(errors, group.key .. " must be a JSON object")
				else
					local clean = copyTable(CONFIG[group.key])
					for _, f in ipairs(group.fields) do
						local v = raw[f.key]
						if v ~= nil then
							local ok, val, msg = checkValue(v, f)
							if ok then
								clean[f.key] = val
								if msg then
									table.insert(notes, msg)
								end
							else
								table.insert(errors, group.key .. "." .. f.key .. " " .. msg)
							end
						end
					end
					out[group.key] = clean
				end
			end
		elseif group.type == "theme" then
			local raw = data[group.key]
			if raw ~= nil then
				local clean, themeErrors, themeNotes = validateTheme(raw)
				for _, e in ipairs(themeErrors) do
					table.insert(errors, "Theme." .. e)
				end
				for _, n in ipairs(themeNotes) do
					table.insert(notes, "Theme " .. n)
				end
				if clean then
					out.Theme = clean
				end
			end
		end
	end
	local unknown = {}
	for k in pairs(data) do
		local found = false
		for _, g in ipairs(CONFIG_SCHEMA) do
			if g.key == k then
				found = true
				break
			end
		end
		if not found then
			table.insert(unknown, sanitizeString(tostring(k), 40))
		end
	end
	table.sort(unknown)
	if #unknown > 0 then
		table.insert(notes, "ignored fields: " .. table.concat(unknown, ", "))
	end
	return out, errors, notes
end

local function themeToJSON(th)
	local ordered = {}
	for _, f in ipairs(SCHEMA) do
		ordered[f.key] = th[f.key]
	end
	local ok, json = pcall(function()
		return HttpService:JSONEncode(ordered)
	end)
	if ok and type(json) == "string" then
		return json
	end
	return "{}"
end

local function decodeJSON(text)
	if type(text) ~= "string" or #text == 0 then
		return nil, "nothing to parse"
	end
	if #text > 40000 then
		return nil, "input too large"
	end
	local ok, result = pcall(function()
		return HttpService:JSONDecode(text)
	end)
	if not ok then
		return nil, "invalid JSON"
	end
	if type(result) ~= "table" then
		return nil, "top level must be a JSON object"
	end
	return result, nil
end

local SkinStore = { Folder = "Blossom", File = "Blossom/themes.txt" }

function SkinStore.fn(name)
	local ok, fn = pcall(function()
		return _G[name]
	end)
	if ok and type(fn) == "function" then
		return fn
	end
	return nil
end

function SkinStore.read()
	local readfile = SkinStore.fn("readfile")
	if not readfile then
		return nil
	end
	local isfile = SkinStore.fn("isfile")
	if isfile then
		local okCheck, exists = pcall(isfile, SkinStore.File)
		if not okCheck or not exists then
			return nil
		end
	end
	local ok, data = pcall(readfile, SkinStore.File)
	if ok and type(data) == "string" and #data > 0 and #data <= 40000 then
		return data
	end
	return nil
end

function SkinStore.write(json)
	local writefile = SkinStore.fn("writefile")
	if not writefile then
		return false
	end
	local makefolder = SkinStore.fn("makefolder")
	local isfolder = SkinStore.fn("isfolder")
	if makefolder and isfolder then
		local okCheck, exists = pcall(isfolder, SkinStore.Folder)
		if not okCheck or not exists then
			pcall(makefolder, SkinStore.Folder)
		end
	end
	return pcall(writefile, SkinStore.File, json) == true
end

local function saveCustomSkins()
	if not PLAYER then
		return
	end
	local payload = {
		active = PLAYER:GetAttribute("BlossomSkin") or CURRENT_THEME.Name,
		autoExecute = AutoExecute,
		themes = {},
	}
	local count = 0
	for _, skinName in ipairs(skinNames()) do
		if not BUILTIN_SKINS[skinName] then
			payload.themes[skinName] = SKINS[skinName]
			count = count + 1
		end
	end
	local ok, json = pcall(function()
		return HttpService:JSONEncode(payload)
	end)
	if not ok or type(json) ~= "string" then
		return
	end
	PLAYER:SetAttribute("BlossomThemes", json)
	SkinStore.write(json)
end

local function loadCustomSkins()
	if not PLAYER then
		return
	end
	local raw = SkinStore.read()
	if not raw then
		raw = PLAYER:GetAttribute("BlossomThemes")
	end
	if type(raw) ~= "string" or raw == "" then
		return
	end
	local data = decodeJSON(raw)
	if not data then
		return
	end
	local themes = data.themes
	if type(themes) ~= "table" then
		themes = data
	end
	for name, theme in pairs(themes) do
		if type(name) == "string" and type(theme) == "table" then
			local clean, errors = validateTheme(theme)
			if clean and #errors == 0 then
				registerSkin(name, clean)
			end
		end
	end
	if type(data.active) == "string" and SKINS[data.active] then
		PLAYER:SetAttribute("BlossomSkin", data.active)
	end
	AutoExecute = data.autoExecute == true
	PLAYER:SetAttribute("BlossomThemes", raw)
end

local function strokeSpec(role)
	local t = CURRENT_THEME
	if role == "Accent" then
		return TC.accent, 0.35
	elseif role == "Focus" then
		return TC.accent, 0.12
	elseif role == "Selected" then
		return TC.accent, 0.4
	elseif role == "Plain" then
		return TC.divider, 0.6
	elseif role == "CardEdge" then
		return TC.textPrimary, math.min(1, t.StrokeTransparency + 0.04)
	elseif role == "Soft" then
		return TC.textPrimary, math.min(1, t.StrokeTransparency + 0.03)
	end
	return TC.textPrimary, t.StrokeTransparency
end

local function strokeApply(stroke, role)
	local color, alpha = strokeSpec(role)
	stroke.Color = color
	stroke.Transparency = alpha
	stroke.Thickness = math.max(1, CURRENT_THEME.StrokeThickness)
end

local function gradientApply(grad, role)
	local th = CURRENT_THEME
	if role == "Banner" then
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, TC.bannerB),
			ColorSequenceKeypoint.new(0.55, TC.bannerA),
			ColorSequenceKeypoint.new(1, TC.bannerC),
		})
		grad.Transparency = NumberSequence.new(0)
		grad.Rotation = 24
	elseif role == "BannerWave" then
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, TC.bannerB),
			ColorSequenceKeypoint.new(0.5, TC.bannerA),
			ColorSequenceKeypoint.new(1, TC.bannerC),
		})
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.55, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		grad.Rotation = 112
	elseif role == "BannerScrim" then
		grad.Color = ColorSequence.new(TC.base)
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.24),
			NumberSequenceKeypoint.new(0.6, 0.7),
			NumberSequenceKeypoint.new(1, 0.98),
		})
		grad.Rotation = 90
	elseif role == "Header" then
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, TC.accent),
			ColorSequenceKeypoint.new(0.55, TC.bannerA),
			ColorSequenceKeypoint.new(1, TC.base),
		})
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.82),
			NumberSequenceKeypoint.new(0.5, 0.95),
			NumberSequenceKeypoint.new(1, 1),
		})
		grad.Rotation = 12
	elseif role == "Shimmer" then
		grad.Color = ColorSequence.new(TC.shimmer)
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.45, th.ShimmerTransparency),
			NumberSequenceKeypoint.new(0.6, th.ShimmerTransparency),
			NumberSequenceKeypoint.new(1, 1),
		})
		grad.Rotation = 0
	else
		grad.Color = ColorSequence.new(TC.gradientTop)
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, th.GradientTopTransparency),
			NumberSequenceKeypoint.new(1, th.GradientBottomTransparency),
		})
		grad.Rotation = 90
	end
end

local manageBlur

local function strokeColorFor(role)
	local color = strokeSpec(role)
	return color
end

local function strokeTransparencyFor(role)
	local _, alpha = strokeSpec(role)
	return alpha
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

local THEME_TWEENS = {}

local function applyTheme(th, animated)
	cancelList(THEME_TWEENS)
	CURRENT_THEME = copyTable(th)
	recomputeColors(CURRENT_THEME)
	if QUALITY.Name ~= "High" or PLAYING then
		animated = false
	end
	local infoUse = ti(dur(CONFIG.Durations.ThemeCrossfade), CONFIG.Easing.Theme, CONFIG.Easing.ThemeDir)
	local function set(inst, prop, value)
		if animated and ThemeCache.animated[inst:GetAttribute("Role")] then
			local fetched, current = pcall(function()
				return inst[prop]
			end)
			if fetched and current ~= nil and sameValue(current, value) then
				return
			end
			playTween(inst, infoUse, { [prop] = value }, THEME_TWEENS)
		else
			inst[prop] = value
		end
	end
	local function setNow(inst, prop, value)
		inst[prop] = value
	end
	local t = CURRENT_THEME
	local function styleAll()
	local list = ThemeCache.list
	if not list then
		if not Gui then
			return
		end
		list = Gui:GetDescendants()
		ThemeCache.list = list
	end
	for _, d in ipairs(list) do
		local role = d:GetAttribute("Role")
		if d:IsA("UIStroke") then
			strokeApply(d, role)
		elseif d:IsA("UIGradient") then
			gradientApply(d, role)
		elseif d:IsA("UICorner") then
			local r = t.CornerRadius
			if role == "Small" then
				r = math.min(r, CONFIG.Layout.SmallCornerRadius)
			elseif role == "Dot" then
				r = 999
			end
			setNow(d, "CornerRadius", UDim.new(0, r))
		elseif d:IsA("UIListLayout") then
			if role == "Gap" then
				setNow(d, "Padding", UDim.new(0, t.Spacing))
			end
		elseif d:IsA("UIPadding") then
			if role == "Pad" then
				setNow(d, "PaddingTop", UDim.new(0, t.Spacing))
				setNow(d, "PaddingBottom", UDim.new(0, t.Spacing))
				setNow(d, "PaddingLeft", UDim.new(0, t.Spacing))
				setNow(d, "PaddingRight", UDim.new(0, t.Spacing))
			end
		elseif d:IsA("Frame") or d:IsA("TextButton") or d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("ImageLabel") or d:IsA("ImageButton") then
			if role == "Panel" then
				set(d, "BackgroundColor3", TC.base)
				set(d, "BackgroundTransparency", t.PanelTransparency)
			elseif role == "Sidebar" then
				set(d, "BackgroundColor3", TC.sidebar)
				set(d, "BackgroundTransparency", 0)
			elseif role == "Card" then
				set(d, "BackgroundColor3", TC.card)
				set(d, "BackgroundTransparency", t.CardTransparency)
			elseif role == "Button" then
				set(d, "BackgroundColor3", TC.button)
				set(d, "BackgroundTransparency", 0)
			elseif role == "Ghost" then
				set(d, "BackgroundColor3", TC.button)
				set(d, "BackgroundTransparency", 0.94)
			elseif role == "Input" then
				set(d, "BackgroundColor3", TC.base)
				set(d, "BackgroundTransparency", 0)
			elseif role == "Divider" then
				set(d, "BackgroundColor3", TC.divider)
			elseif role == "SliderKnob" then
				set(d, "BackgroundColor3", TC.textPrimary)
			elseif role == "Backdrop" then
				local level = d:GetAttribute("BackdropLevel")
				if level == "loading" then
					set(d, "BackgroundColor3", hexToColor(CONFIG.Loading.BackdropColor))
					set(d, "BackgroundTransparency", CONFIG.Loading.BackdropTransparency)
				elseif level == "main" then
					set(d, "BackgroundColor3", TC.dim)
					set(d, "BackgroundTransparency", 1)
				else
					set(d, "BackgroundColor3", TC.dim)
					set(d, "BackgroundTransparency", t.DimTransparency)
				end
			elseif role == "Accent" then
				set(d, "BackgroundColor3", TC.accent)
			elseif role == "Track" then
				set(d, "BackgroundColor3", TC.track)
			elseif role == "Fill" then
				set(d, "BackgroundColor3", TC.fill)
			elseif role == "Skeleton" then
				set(d, "BackgroundColor3", TC.skeleton)
			elseif role == "Knob" then
				local parentOn = d.Parent and d.Parent:GetAttribute("On") == true
				set(d, "BackgroundColor3", parentOn and TC.onAccent or TC.textSecondary)
			elseif role == "Surface" then
				set(d, "BackgroundColor3", TC.base)
			end
		end
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
			local tier = d:GetAttribute("Tier") or "Primary"
			local textRole = d:GetAttribute("TextRole")
			local size = textRoleSize(textRole, CONFIG.Layout)
			if d:GetAttribute("Bold") == true then
				setNow(d, "Font", boldFont())
			else
				setNow(d, "Font", themeFont())
			end
			if d:GetAttribute("FixedSize") ~= true and d.Name ~= "Countdown" then
				setNow(d, "TextSize", size)
			end
			if tier == "OnAccent" then
				local bgRole = d:GetAttribute("Role") or (d.Parent and d.Parent:GetAttribute("Role"))
				if bgRole ~= "Accent" then
					set(d, "TextColor3", tierColor("Primary"))
				else
					set(d, "TextColor3", TC.onAccent)
				end
			else
				set(d, "TextColor3", tierColor(tier))
			end
			if d:IsA("TextBox") then
				set(d, "PlaceholderColor3", TC.textSecondary)
			end
		end
		if d:IsA("ImageLabel") or d:IsA("ImageButton") then
			local imageRole = d:GetAttribute("ImageRole")
			if imageRole == "Background" and t.BackgroundImage ~= "" then
				set(d, "Image", "rbxassetid://" .. t.BackgroundImage)
			elseif imageRole == "Logo" then
				if t.LogoImage ~= "" then
					set(d, "Image", "rbxassetid://" .. t.LogoImage)
				end
			elseif imageRole == "Spinner" and t.SpinnerImage ~= "" then
				set(d, "Image", "rbxassetid://" .. t.SpinnerImage)
			elseif imageRole == "Texture" and t.TextureImage ~= "" then
				set(d, "Image", "rbxassetid://" .. t.TextureImage)
			end
		end
	end
	end
	pcall(styleAll)
	manageBlur()
	refreshAll()
end

local LoadingActive = false
local LoadingLogo
local LoadingRotor
local LogoSpinTween
local LogoFloatTween

manageBlur = function()
	local t = CURRENT_THEME
	local seeThrough = (tonumber(CONFIG.Loading.BackdropTransparency) or 0) > 0.45
	local want = QUALITY.Blur and t.BlurEnabled and LoadingActive and seeThrough
	if want then
		if not Blur then
			Blur = new("BlurEffect", { Name = "BlossomBlur", Size = 0, Enabled = true }, Lighting)
			playTween(Blur, ti(dur(CONFIG.Durations.Fade), "Quad", "Out"), { Size = t.BlurSize })
		else
			playTween(Blur, ti(dur(CONFIG.Durations.Fade), "Quad", "Out"), { Size = t.BlurSize })
		end
	elseif Blur then
		local ref = Blur
		playTween(ref, ti(dur(CONFIG.Durations.Fade), "Quad", "In"), { Size = 0 })
		local delayTime = dur(CONFIG.Durations.Fade) + 0.1
		task.delay(delayTime, function()
			if DESTROYED then
				return
			end
			if Blur == ref then
				ref:Destroy()
				Blur = nil
			end
		end)
	end
end

local function setBackdrop(level)
	if not Backdrop then
		return
	end
	Backdrop:SetAttribute("BackdropLevel", level)
	Backdrop.Visible = true
	local t = CURRENT_THEME
	local color = TC.dim
	local target = t.DimTransparency
	if level == "loading" then
		color = hexToColor(CONFIG.Loading.BackdropColor)
		target = CONFIG.Loading.BackdropTransparency
	elseif level == "main" then
		target = 1
	end
	uiTween(Backdrop, { BackgroundTransparency = target, BackgroundColor3 = color }, CONFIG.Durations.Fade, CONFIG.Easing.Fade, CONFIG.Easing.FadeDir)
end

local function preloadThemeImages(th)
	local urls = {}
	for _, key in ipairs({ "BackgroundImage", "LogoImage", "SpinnerImage", "TextureImage" }) do
		local id = th[key]
		if type(id) == "string" and id ~= "" then
			table.insert(urls, "rbxassetid://" .. id)
		end
	end
	if #urls == 0 then
		return true
	end
	local done = false
	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(urls)
		end)
		done = true
	end)
	local started = os.clock()
	while not done and os.clock() - started < CONFIG.Durations.PreloadTimeout do
		task.wait(0.05)
	end
	return done
end

local function viewportSize()
	local cam = workspace.CurrentCamera
	if cam then
		return cam.ViewportSize
	end
	return Vector2.new(1280, 720)
end

local function updateRootScale()
	if not RootScale then
		return
	end
	local vp = viewportSize()
	local s = math.min(vp.X / 760, vp.Y / 520)
	RootScale.Scale = clampNum(s, CONFIG.Layout.MinScale, 1)
end

local function fitWidth(w)
	if not RootScale then
		return w
	end
	local vp = viewportSize()
	local avail = vp.X / math.max(0.1, RootScale.Scale) - 32
	return math.max(160, math.min(w, avail))
end

local function makeLabel(props, parent)
	local p = props or {}
	local L = CONFIG.Layout
	local textRole = p.TextRole
	local tier = p.Tier or "Primary"
	local size = p.TextSize or textRoleSize(textRole, L)
	local built = {
		Name = p.Name or "Label",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = p.Size or UDim2.new(1, 0, 0, size + 6),
		Text = p.Text or "",
		Font = themeFont(),
		TextSize = size,
		TextColor3 = p.Color or tierColor(tier),
		TextXAlignment = p.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = p.TextWrapped == true,
		LayoutOrder = p.LayoutOrder or 0,
		Tier = tier,
		Role = p.Role,
		TextRole = textRole,
	}
	if p.Position then
		built.Position = p.Position
	end
	if p.AnchorPoint then
		built.AnchorPoint = p.AnchorPoint
	end
	if p.Visible == false then
		built.Visible = false
	end
	if p.ZIndex then
		built.ZIndex = p.ZIndex
	end
	if p.Truncate then
		built.TextTruncate = Enum.TextTruncate.AtEnd
	end
	local label = new("TextLabel", built, parent)
	if p.Bold then
		label:SetAttribute("Bold", true)
		label.Font = boldFont()
	end
	if p.FixedSize then
		label:SetAttribute("FixedSize", true)
	end
	return label
end

local function addRule(row, inset)
	local pad = tonumber(inset) or 10
	return new("Frame", {
		Name = "Rule",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, pad, 1, 0),
		Size = UDim2.new(1, -pad * 2, 0, 1),
		BackgroundColor3 = TC.divider,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Role = "Divider",
	}, row)
end

local function makeCard(parent, opts)
	opts = opts or {}
	local L = CONFIG.Layout
	local card = new("Frame", {
		Name = opts.Name or "Card",
		BackgroundColor3 = TC.card,
		BackgroundTransparency = CURRENT_THEME.CardTransparency,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = opts.Fixed and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
		LayoutOrder = opts.Order or 0,
		Role = "Card",
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, L.SmallCornerRadius), Role = "Small" }, card)
	new("UIStroke", { Color = TC.textPrimary, Transparency = CURRENT_THEME.StrokeTransparency + 0.04, Thickness = 1, Role = "CardEdge", ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, card)
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
		makeLabel({
			Name = "CardTitle",
			Text = sanitizeString(tostring(opts.Title), 40),
			Tier = "Secondary",
			TextRole = "Caption",
			Bold = true,
			FixedSize = true,
			TextSize = 12,
			LayoutOrder = -10,
			Size = UDim2.new(1, -16, 0, 24),
			Position = UDim2.new(0, 10, 0, 0),
		}, card)
	end
	return card
end

local function makeButton(parent, opts)
	opts = opts or {}
	local L = CONFIG.Layout
	local variant = opts.Variant or "Default"
	local primary = variant == "Primary"
	local ghost = variant == "Ghost"
	local textSize = tonumber(opts.TextSize) or L.BodySize
	local radius = tonumber(opts.Radius) or math.max(2, L.SmallCornerRadius - 2)
	local btn = new("TextButton", {
		Name = opts.Name or "Button",
		AutoButtonColor = false,
		Selectable = true,
		BackgroundColor3 = primary and TC.accent or TC.button,
		BackgroundTransparency = ghost and 0.94 or 0,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, L.ButtonHeight),
		Position = opts.Position,
		AnchorPoint = opts.AnchorPoint,
		Text = sanitizeString(tostring(opts.Text or "Button"), 64),
		Font = opts.Bold and boldFont() or themeFont(),
		TextSize = textSize,
		TextColor3 = primary and TC.onAccent or TC.textPrimary,
		TextXAlignment = opts.TextXAlignment or Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = opts.Order or 0,
		Role = primary and "Accent" or (ghost and "Ghost" or "Button"),
		Tier = primary and "OnAccent" or "Primary",
		TextRole = "Body",
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, radius), Role = "Small" }, btn)
	local state = { enabled = opts.Enabled ~= false, hover = false, pressed = false, active = opts.Active == true }

	local function faceColor()
		if primary or state.active then
			if not state.enabled then
				return TC.accent
			end
			if state.pressed then
				return TC.accentPressed
			end
			if state.hover then
				return TC.accentHover
			end
			return TC.accent
		end
		if not state.enabled then
			return TC.button
		end
		if state.pressed then
			return TC.buttonPressed
		end
		if state.hover then
			return TC.buttonHover
		end
		return TC.button
	end

	local function faceAlpha()
		if not state.enabled then
			return ghost and 1 or 0.55
		end
		if state.active then
			return 0
		end
		if ghost then
			return state.hover and 0.88 or 0.94
		end
		return 0
	end

	local function refresh()
		btn.BackgroundColor3 = faceColor()
		btn.BackgroundTransparency = faceAlpha()
		btn.TextColor3 = state.enabled and ((primary or state.active) and TC.onAccent or TC.textPrimary) or TC.textDisabled
		btn.Font = opts.Bold and boldFont() or themeFont()
		btn.TextSize = textSize
	end

	local function paint(duration, style, dir)
		uiTween(btn, { BackgroundColor3 = faceColor(), BackgroundTransparency = faceAlpha() }, duration, style, dir)
	end

	trackConn(btn.MouseEnter:Connect(function()
		if not state.enabled or state.hover then
			return
		end
		state.hover = true
		paint(hoverTime(true), CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
	end))
	trackConn(btn.MouseLeave:Connect(function()
		if not state.hover and not state.pressed then
			return
		end
		state.hover = false
		state.pressed = false
		paint(hoverTime(false), CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
	end))
	trackConn(btn.MouseButton1Down:Connect(function()
		if not state.enabled or state.pressed then
			return
		end
		state.pressed = true
		paint(CONFIG.Durations.Press * 0.6, CONFIG.Easing.Press, CONFIG.Easing.PressDir)
	end))
	trackConn(btn.MouseButton1Up:Connect(function()
		if not state.pressed then
			return
		end
		state.pressed = false
		paint(hoverTime(true), CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
	end))

	if opts.Divider then
		addRule(btn, opts.DividerInset)
	end

	local comp = { Instance = btn, Refresh = refresh }

	function comp:SetEnabled(value)
		state.enabled = value == true
		btn.Active = state.enabled
		btn.Selectable = state.enabled
		refresh()
	end

	function comp:SetText(value)
		btn.Text = sanitizeString(tostring(value or ""), 64)
	end

	function comp:SetActive(value)
		state.active = value == true
		refresh()
	end

	table.insert(REFRESH, refresh)
	return comp
end

local KNOB_OFF_X = 2
local KNOB_ON_X = 18

local function makeToggle(parent, opts)
	opts = opts or {}
	local height = tonumber(opts.Height) or 42
	local row = new("TextButton", {
		Name = "Toggle",
		AutoButtonColor = false,
		Selectable = true,
		Text = "",
		BackgroundColor3 = TC.button,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, height),
		LayoutOrder = opts.Order or 0,
		Role = "Ghost",
		ZIndex = 2,
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 6), Role = "Small" }, row)
	makeLabel({
		Name = "Label",
		Text = sanitizeString(tostring(opts.Text or "Toggle"), 60),
		Tier = "Primary",
		TextRole = "Body",
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -62, 1, 0),
		Truncate = true,
		ZIndex = 3,
	}, row)
	local pill = new("Frame", {
		Name = "Switch",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 34, 0, 18),
		BackgroundColor3 = TC.track,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, pill)
	new("UIStroke", { Color = TC.textPrimary, Transparency = 0.88, Thickness = 1, Role = "Soft", ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, pill)
	local knob = new("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, KNOB_OFF_X, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundColor3 = TC.textSecondary,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, pill)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, knob)

	local state = { value = opts.Value == true, hover = false, enabled = opts.Enabled ~= false }

	local function trackColor()
		if not state.enabled then
			return TC.track
		end
		return state.value and TC.accent or TC.track
	end

	local function knobColor()
		if not state.enabled then
			return TC.textDisabled
		end
		return state.value and Color3.new(1, 1, 1) or TC.textSecondary
	end

	local function knobPos()
		return UDim2.new(0, state.value and KNOB_ON_X or KNOB_OFF_X, 0.5, 0)
	end

	local function paint(animated)
		if animated == false or QUALITY.Instant then
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
		row.BackgroundColor3 = TC.button
		row.BackgroundTransparency = state.hover and 0.94 or 1
	end

	local function flip()
		if not state.enabled then
			return
		end
		state.value = not state.value
		paint(true)
		if opts.OnChange then
			opts.OnChange(state.value)
		end
	end

	trackConn(row.MouseButton1Click:Connect(flip))
	trackConn(row.MouseEnter:Connect(function()
		state.hover = true
		hoverTween(row, { BackgroundTransparency = 0.94 }, true)
	end))
	trackConn(row.MouseLeave:Connect(function()
		state.hover = false
		hoverTween(row, { BackgroundTransparency = 1 }, false)
	end))

	if opts.Divider ~= false then
		addRule(row)
	end

	local comp = { Instance = row, Refresh = refresh }

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

	table.insert(REFRESH, refresh)
	return comp
end

local function makeListRow(parent, opts)
	opts = opts or {}
	local L = CONFIG.Layout
	local row = new("Frame", {
		Name = "Row",
		BackgroundColor3 = TC.button,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, 46),
		LayoutOrder = opts.Order or 0,
		Role = "Ghost",
	}, parent)
	local icon = new("Frame", {
		Name = "Icon",
		Position = UDim2.new(0, 10, 0.5, -11),
		Size = UDim2.new(0, 22, 0, 22),
		BackgroundColor3 = TC.accent,
		BackgroundTransparency = 0.86,
		BorderSizePixel = 0,
		Role = "Accent",
	}, row)
	new("UICorner", { CornerRadius = UDim.new(0, 6), Role = "Small" }, icon)
	makeLabel({
		Name = "Glyph",
		Text = string.sub(opts.Title or "A", 1, 1),
		Tier = "Accent",
		TextRole = "Caption",
		Bold = true,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
	}, icon)
	makeLabel({
		Name = "Title",
		Text = sanitizeString(tostring(opts.Title or "Row"), 40),
		Tier = "Primary",
		TextRole = "Body",
		Position = UDim2.new(0, 42, 0, 5),
		Size = UDim2.new(1, -70, 0, L.BodySize + 6),
		Truncate = true,
	}, row)
	makeLabel({
		Name = "Subtitle",
		Text = sanitizeString(tostring(opts.Subtitle or ""), 80),
		Tier = "Secondary",
		TextRole = "Caption",
		Position = UDim2.new(0, 42, 0, L.BodySize + 8),
		Size = UDim2.new(1, -70, 0, L.CaptionSize + 6),
		Truncate = true,
	}, row)
	makeLabel({
		Name = "Chevron",
		Text = "›",
		Tier = "Disabled",
		TextRole = "Body",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Right,
	}, row)

	local state = { hover = false }

	local function refresh()
		row.BackgroundColor3 = TC.button
		row.BackgroundTransparency = state.hover and 0.9 or 1
	end

	trackConn(row.MouseEnter:Connect(function()
		state.hover = true
		hoverTween(row, { BackgroundTransparency = 0.9 }, true)
	end))
	trackConn(row.MouseLeave:Connect(function()
		state.hover = false
		hoverTween(row, { BackgroundTransparency = 1 }, false)
	end))

	if opts.Divider ~= false then
		addRule(row)
	end

	table.insert(REFRESH, refresh)
	return { Instance = row, Refresh = refresh }
end

local function makeTextInput(parent, opts)
	opts = opts or {}
	local L = CONFIG.Layout
	local wrap = new("Frame", {
		Name = "Input",
		BackgroundColor3 = TC.base,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, L.InputHeight),
		LayoutOrder = opts.Order or 0,
		Role = "Input",
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, math.max(4, L.SmallCornerRadius - 2)), Role = "Small" }, wrap)
	local stroke = new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = CURRENT_THEME.StrokeTransparency, Thickness = 1, Role = "Edge" }, wrap)
	local box = new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Text = opts.Text or "",
		PlaceholderText = opts.Placeholder or "",
		Font = themeFont(),
		TextSize = L.BodySize,
		TextColor3 = TC.textPrimary,
		PlaceholderColor3 = TC.textSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		TextWrapped = false,
		Tier = "Primary",
		TextRole = "Body",
	}, wrap)

	local function refresh()
		box.TextColor3 = TC.textPrimary
		box.PlaceholderColor3 = TC.textSecondary
		box.Font = themeFont()
		box.TextSize = L.BodySize
		wrap.BackgroundColor3 = TC.base
	end

	trackConn(box.Focused:Connect(function()
		playTween(stroke, ti(mdur(hoverTime(true)), "Quad", "Out"), {
			Color = TC.accent,
			Transparency = 0.25,
		})
	end))
	trackConn(box.FocusLost:Connect(function(enter)
		playTween(stroke, ti(mdur(hoverTime(false)), "Quad", "Out"), {
			Color = TC.textPrimary,
			Transparency = CURRENT_THEME.StrokeTransparency,
		})
		if enter and opts.OnSubmit then
			opts.OnSubmit(box.Text)
		end
	end))

	local comp = { Instance = wrap, Box = box, Refresh = refresh }

	function comp:GetText()
		return box.Text
	end

	function comp:SetText(value)
		box.Text = sanitizeString(tostring(value or ""), 400)
	end

	table.insert(REFRESH, refresh)
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
		Size = opts.Size or UDim2.new(1, 0, 0, 54),
		LayoutOrder = opts.Order or 0,
	}, parent)
	local header = new("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 6),
		Size = UDim2.new(1, -20, 0, 18),
	}, wrap)
	makeLabel({
		Name = "Label",
		Text = sanitizeString(tostring(opts.Label or "Slider"), 48),
		Tier = "Primary",
		TextRole = "Body",
		Size = UDim2.new(1, -70, 1, 0),
		Truncate = true,
	}, header)
	local valueLabel = makeLabel({
		Name = "Value",
		Text = "",
		Tier = "Secondary",
		TextRole = "Caption",
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, 64, 1, 0),
		Position = UDim2.new(1, -64, 0, 0),
	}, header)
	local trackFrame = new("Frame", {
		Name = "Track",
		Position = UDim2.new(0, 10, 0, 36),
		Size = UDim2.new(1, -20, 0, 4),
		BackgroundColor3 = TC.track,
		BorderSizePixel = 0,
		Role = "Track",
	}, wrap)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, trackFrame)
	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = TC.fill,
		BorderSizePixel = 0,
		Role = "Fill",
	}, trackFrame)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, fill)
	local knob = new("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = TC.textPrimary,
		BorderSizePixel = 0,
		Role = "SliderKnob",
	}, trackFrame)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, knob)

	local state = {
		value = clampNum(tonumber(opts.Value) or minV, minV, maxV),
		dragging = false,
		offset = 0,
	}

	local function snap(v)
		local steps = math.floor((v - minV) / step + 0.5)
		return clampNum(minV + steps * step, minV, maxV)
	end

	local function alphaOf(v)
		if maxV - minV <= 0 then
			return 0
		end
		return (v - minV) / (maxV - minV)
	end

	local function decimals()
		if step >= 1 then
			return 0
		end
		if step >= 0.1 then
			return 1
		end
		return 2
	end

	local function formatValue(v)
		if type(opts.Format) == "function" then
			local ok, text = pcall(opts.Format, v)
			if ok and text ~= nil then
				return sanitizeString(tostring(text), 16)
			end
		end
		return string.format("%." .. decimals() .. "f", v)
	end

	local function place(animated)
		local a = alphaOf(state.value)
		if animated then
			uiTween(fill, { Size = UDim2.new(a, 0, 1, 0) }, hoverTime(false), CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
			uiTween(knob, { Position = UDim2.new(a, 0, 0.5, 0) }, hoverTime(false), CONFIG.Easing.Hover, CONFIG.Easing.HoverDir)
		else
			fill.Size = UDim2.new(a, 0, 1, 0)
			knob.Position = UDim2.new(a, 0, 0.5, 0)
		end
		valueLabel.Text = formatValue(state.value)
	end

	local function commit(value, animated)
		local nextValue = snap(clampNum(value, minV, maxV))
		local changed = nextValue ~= state.value
		state.value = nextValue
		place(animated)
		if changed and opts.OnChange then
			opts.OnChange(state.value)
		end
	end

	local function valueFromInput(input)
		local width = trackFrame.AbsoluteSize.X
		if width <= 0 then
			return state.value
		end
		local a = clampNum((input.Position.X - trackFrame.AbsolutePosition.X) / width, 0, 1)
		return minV + a * (maxV - minV)
	end

	local function beginDrag(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local fromKnob = input.Target == knob
		state.offset = fromKnob and (state.value - valueFromInput(input)) or 0
		state.dragging = true
		if not fromKnob then
			commit(valueFromInput(input), false)
		end
	end

	trackConn(trackFrame.InputBegan:Connect(beginDrag))
	trackConn(knob.InputBegan:Connect(beginDrag))
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if not state.dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				state.dragging = false
				state.offset = 0
				place(true)
				return
			end
		elseif input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		commit(valueFromInput(input) + state.offset, false)
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not state.dragging then
			return
		end
		state.dragging = false
		state.offset = 0
		place(true)
	end))
	trackConn(trackFrame.MouseEnter:Connect(function()
		hoverTween(knob, { Size = UDim2.new(0, 15, 0, 15) }, true)
	end))
	trackConn(trackFrame.MouseLeave:Connect(function()
		hoverTween(knob, { Size = UDim2.new(0, 12, 0, 12) }, false)
	end))

	local function refresh()
		trackFrame.BackgroundColor3 = TC.track
		fill.BackgroundColor3 = TC.accent
		knob.BackgroundColor3 = TC.textPrimary
		valueLabel.TextColor3 = TC.textSecondary
	end

	local comp = { Instance = wrap, Refresh = refresh }

	function comp:Set(value)
		commit(tonumber(value) or state.value, false)
	end

	function comp:Get()
		return state.value
	end

	table.insert(REFRESH, refresh)
	place(false)
	if opts.Divider ~= false then
		addRule(wrap)
	end
	return comp
end

local toast
local playGallery
local applyConfigNow
local openCustomize
local closeCustomize
local toggleDebug
local captureShot
local showMain
local hideMain
local setLoading

local function clearStage()
	if not Stage then
		return
	end
	cancelList(STAGE_TWEENS)
	for i = #STAGE_CONNS, 1, -1 do
		local c = STAGE_CONNS[i]
		pcall(function()
			c:Disconnect()
		end)
		table.remove(STAGE_CONNS, i)
	end
	for _, child in ipairs(Stage:GetChildren()) do
		child:Destroy()
	end
	ThemeCache.list = nil
end

local function later(seconds, fn)
	local ref = TOKEN
	task.delay(seconds, function()
		if DESTROYED or TOKEN ~= ref then
			return
		end
		fn()
	end)
end

local function stageGroup(width, height)
	return new("CanvasGroup", {
		Name = "Loader",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, width, 0, height),
		GroupTransparency = 1,
		ZIndex = 4,
	}, Stage)
end

local function petalRain()
	if not Stage then
		return
	end
	local vp = viewportSize()
	local count = math.floor(clampNum(tonumber(CONFIG.Loading.PetalCount) or 0, 0, 32))
	if count <= 0 or vp.X <= 0 or vp.Y <= 0 then
		return
	end
	local petalColor = hexToColor(CONFIG.Loading.PetalColor or CONFIG.Loading.LogoColor)
	for _ = 1, count do
		local width = 7 + math.random() * 6
		local height = width * 1.4
		local x = math.random() * vp.X
		local startY = -30 + math.random() * (vp.Y * 0.85)
		local drift = (math.random() * 2 - 1) * 34
		local travel = (vp.Y + 40) - startY
		local fall = math.max(0.6, travel / (240 + math.random() * 140))
		local spin = (math.random() * 2 - 1) * 190
		local petal = new("Frame", {
			Name = "Petal",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, x, 0, startY),
			Size = UDim2.new(0, width, 0, height),
			BackgroundColor3 = petalColor,
			BackgroundTransparency = 0.28 + math.random() * 0.3,
			BorderSizePixel = 0,
			ZIndex = 1,
		}, Stage)
		new("UICorner", { CornerRadius = UDim.new(0.5, 0), Role = "Dot" }, petal)
		playTween(petal, ti(fall, "Linear", "Out"), {
			Position = UDim2.new(0, x + drift, 0, vp.Y + 40),
		}, STAGE_TWEENS)
		playTween(petal, ti(fall, "Linear", "Out"), { Rotation = spin }, STAGE_TWEENS)
	end
end

local function ambientPetals(parent, opts)
	opts = opts or {}
	local cfg = CONFIG.Ambient or {}
	if not parent or isLowEnd() or cfg.Petals == false then
		return
	end
	local vp = viewportSize()
	local spanW = tonumber(opts.Width) or vp.X
	local spanH = tonumber(opts.Height) or (vp.Y + 90)
	local count = math.floor(clampNum(tonumber(opts.Count) or tonumber(cfg.Count) or 8, 0, 24))
	if count <= 0 or spanW <= 0 or spanH <= 0 then
		return
	end
	local fade = tonumber(opts.Transparency) or 0.35
	local depth = tonumber(opts.ZIndex) or 1
	local layer = new("Frame", {
		Name = opts.Name or "Petals",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = depth,
	}, parent)
	local tint = hexToColor(CONFIG.Loading.PetalColor or CONFIG.Loading.LogoColor)
	for i = 1, count do
		local width = 6 + math.random() * 5
		local height = width * 1.4
		local lane = (i - 0.5) / count * spanW
		local x = lane + (math.random() * 80 - 40)
		local drift = (math.random() * 2 - 1) * 60
		local speed = clampNum(tonumber(opts.Speed) or tonumber(cfg.Speed) or 62, 20, 200) + math.random() * 36
		local fall = spanH / speed
		local delayTime = math.random() * fall
		local petal = new("Frame", {
			Name = "Petal",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, x, 0, -50),
			Size = UDim2.new(0, width, 0, height),
			Rotation = math.random() * 360,
			BackgroundColor3 = tint,
			BackgroundTransparency = fade + math.random() * 0.25,
			BorderSizePixel = 0,
			ZIndex = depth,
		}, layer)
		new("UICorner", { CornerRadius = UDim.new(0.5, 0), Role = "Dot" }, petal)
		playTween(petal, ti(fall, "Linear", "Out", -1, false, delayTime), {
			Position = UDim2.new(0, x + drift, 0, spanH - 50),
		})
		playTween(petal, ti(fall * 1.6, "Linear", "Out", -1, false, delayTime), {
			Rotation = petal.Rotation + 220,
		})
	end
end

local function loaderSplash()
	local markSize = clampNum(tonumber(CONFIG.Loading.LogoSize) or 64, 32, 160)
	local spinTime = math.max(0.35, tonumber(CONFIG.Loading.LogoSpin) or 1.6)
	local titleY = markSize + 14
	local subY = titleY + 26
	local barY = subY + 26
	local groupH = barY + 14
	local w = fitWidth(math.max(260, math.min(320, markSize + 160)))
	local g = stageGroup(w, groupH)
	if not isLowEnd() then
		g.Position = UDim2.new(0.5, 0, 0.5, 10)
		playTween(g, ti(dur(CONFIG.Durations.Splash) * 0.4, "Quint", "Out"), { Position = UDim2.fromScale(0.5, 0.5) })
	end

	local mark = new("Frame", {
		Name = "Mark",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 2),
		Size = UDim2.new(0, markSize, 0, markSize),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, g)
	local bloom = new("Frame", {
		Name = "Bloom",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, mark)
	local petalTint = hexToColor(CONFIG.Loading.PetalColor or CONFIG.Loading.LogoColor)
	local coreTint = hexToColor(CONFIG.Loading.LogoCoreColor)
	for i = 1, 5 do
		local angle = (i - 1) * math.pi * 2 / 5 - math.pi * 0.5
		local petal = new("Frame", {
			Name = "Petal",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5 + math.cos(angle) * 0.21, 0.5 + math.sin(angle) * 0.21),
			Size = UDim2.new(0, markSize * 0.34, 0, markSize * 0.42),
			Rotation = (i - 1) * 72,
			BackgroundColor3 = petalTint,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			ZIndex = 3,
		}, bloom)
		new("UICorner", { CornerRadius = UDim.new(0.5, 0), Role = "Dot" }, petal)
	end
	local core = new("Frame", {
		Name = "Core",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, markSize * 0.24, 0, markSize * 0.24),
		BackgroundColor3 = coreTint,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, bloom)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, core)
	playTween(bloom, ti(spinTime * 2, "Linear", "Out", -1), { Rotation = 360 }, STAGE_TWEENS)
	petalRain()

	makeLabel({
		Name = "Title",
		Text = sanitizeString(tostring(CONFIG.Brand.Name or "Blossom"), 24),
		Tier = "Primary",
		TextRole = "Title",
		Color = hexToColor(CONFIG.Loading.TitleColor or "#FCEFF4"),
		Bold = true,
		FixedSize = true,
		TextSize = 17,
		Position = UDim2.new(0, 0, 0, titleY),
		Size = UDim2.new(1, 0, 0, 24),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 3,
	}, g)
	makeLabel({
		Name = "Sub",
		Text = "loading",
		Tier = "Secondary",
		TextRole = "Caption",
		Color = hexToColor(CONFIG.Loading.SubColor or "#C79BAC"),
		FixedSize = true,
		TextSize = 11,
		Position = UDim2.new(0, 0, 0, subY),
		Size = UDim2.new(1, 0, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 3,
	}, g)
	local bar = new("Frame", {
		Name = "Progress",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, barY),
		Size = UDim2.new(0, 148, 0, 3),
		BackgroundColor3 = TC.track,
		BorderSizePixel = 0,
		Role = "Track",
		ZIndex = 3,
	}, g)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, bar)
	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = TC.accent,
		BorderSizePixel = 0,
		Role = "Fill",
		ZIndex = 4,
	}, bar)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, fill)
	playTween(fill, ti(dur(CONFIG.Durations.Splash), "Quint", "Out"), { Size = UDim2.new(1, 0, 1, 0) }, STAGE_TWEENS)

	local inTime = dur(CONFIG.Durations.Splash) * 0.4
	local outTime = dur(CONFIG.Durations.Splash) * 0.35
	local total = inTime + dur(CONFIG.Durations.SplashHold) + outTime
	playTween(g, ti(inTime, CONFIG.Easing.Fade, CONFIG.Easing.FadeDir), { GroupTransparency = 0 })
	later(inTime + dur(CONFIG.Durations.SplashHold), function()
		playTween(g, ti(outTime, CONFIG.Easing.Fade, "In"), { GroupTransparency = 1 })
	end)
	return total
end

local function stopLogoSpin()
	if LogoSpinTween then
		pcall(function()
			LogoSpinTween:Cancel()
		end)
		LogoSpinTween = nil
	end
	if LogoFloatTween then
		pcall(function()
			LogoFloatTween:Cancel()
		end)
		LogoFloatTween = nil
	end
	if LoadingRotor then
		LoadingRotor.Rotation = 0
		LoadingRotor.Size = UDim2.fromScale(1, 1)
	end
end

local function startLogoSpin()
	stopLogoSpin()
	if not LoadingRotor then
		return
	end
	if CONFIG.Loading.LogoMode == "Image" and CONFIG.Loading.LogoImageId ~= "" then
		local pulse = math.max(0.3, tonumber(CONFIG.Loading.LogoPulse) or 1.1)
		local float = math.max(0.3, tonumber(CONFIG.Loading.LogoFloat) or 1.8)
		LogoSpinTween = playTween(LoadingRotor, ti(pulse, "Sine", "InOut", -1, true), { Size = UDim2.fromScale(1.07, 1.07) })
		if LoadingLogo then
			local baseY = tonumber(CONFIG.Loading.LogoOffsetY) or -104
			LogoFloatTween = playTween(LoadingLogo, ti(float, "Sine", "InOut", -1, true), { Position = UDim2.new(0.5, 0, 0.5, baseY - 7) })
		end
		return
	end
	LoadingRotor.Rotation = 0
	local spin = math.max(0.2, tonumber(CONFIG.Loading.LogoSpin) or 1.6)
	LogoSpinTween = playTween(LoadingRotor, ti(spin, "Linear", "Out", -1), { Rotation = 360 })
end

setLoading = function(active)
	LoadingActive = active == true
	manageBlur()
	if LoadingLogo then
		LoadingLogo.Visible = LoadingActive
	end
	if LoadingActive then
		startLogoSpin()
	else
		stopLogoSpin()
	end
end

showMain = function(animated)
	if not Main then
		return
	end
	MainVisible = true
	Main.Visible = true
	setLoading(false)
	setBackdrop("main")
	if animated and not QUALITY.Instant then
		MainColumn.Position = UDim2.new(0.5, 0, 0.5, 16)
		uiTween(MainColumn, { Position = UDim2.fromScale(0.5, 0.5) }, CONFIG.Durations.Slide, "Quint", "Out")
		if MainScale then
			if QUALITY.ScalePop then
				MainScale.Scale = 0.97
				uiTween(MainScale, { Scale = 1 }, CONFIG.Durations.Slide, "Quint", "Out")
			else
				MainScale.Scale = 1
			end
		end
	else
		MainColumn.Position = UDim2.fromScale(0.5, 0.5)
		if MainScale then
			MainScale.Scale = 1
		end
	end
end

hideMain = function(instant)
	if not Main then
		return
	end
	MainVisible = false
	if instant or QUALITY.Instant then
		Main.Visible = false
		if MainScale then
			MainScale.Scale = 1
		end
		MainColumn.Position = UDim2.fromScale(0.5, 0.5)
		return
	end
	local outTime = mdur(CONFIG.Durations.Fade) * 0.7
	if MainScale then
		uiTween(MainScale, { Scale = 0.97 }, outTime, "Quad", "In")
	end
	local p = MainColumn.Position
	uiTween(MainColumn, { Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + 10) }, outTime, "Quad", "In")
	task.delay(outTime + 0.05, function()
		if DESTROYED or MainVisible or not Main then
			return
		end
		Main.Visible = false
		if MainScale then
			MainScale.Scale = 1
		end
		MainColumn.Position = UDim2.fromScale(0.5, 0.5)
	end)
end
local JsonBox
local StatusLabel
local FlashFrame
local SpeedButtons = {}
local SkinButtons = {}
local rebuildThemeChips
local StatusIsError = false
local CustomTab = "Theme"

local function setButtonActive(comp, on)
	if comp and comp.SetActive then
		comp:SetActive(on == true)
	end
end

local function statusText(message, isError)
	if not StatusLabel then
		return
	end
	StatusIsError = isError == true
	StatusLabel.Text = sanitizeString(tostring(message or ""), 400)
	StatusLabel.TextColor3 = isError and Color3.fromRGB(255, 132, 132) or TC.textSecondary
end

local function refreshStatus()
	if StatusLabel and StatusIsError then
		StatusLabel.TextColor3 = Color3.fromRGB(255, 132, 132)
	end
end

toast = function(text, isError)
	if not ToastGroup or not ToastLabel then
		return
	end
	ToastLabel.Text = sanitizeString(tostring(text or ""), 140)
	ToastLabel.TextColor3 = isError and Color3.fromRGB(255, 140, 140) or TC.textPrimary
	if ToastStripe then
		ToastStripe.BackgroundColor3 = isError and Color3.fromRGB(255, 92, 92) or TC.accent
	end
	ToastSeq = ToastSeq + 1
	local ref = ToastSeq
	local onScreen = ToastGroup.Visible and ToastGroup.GroupTransparency < 0.5
	ToastGroup.Visible = true
	if onScreen and not QUALITY.Instant then
		ToastGroup.Position = UDim2.new(1, -16, 0, 16)
		playTween(ToastGroup, ti(mdur(0.12), "Quad", "Out"), { GroupTransparency = 0 })
		playTween(ToastGroup, ti(mdur(0.16), "Quint", "Out"), { Position = UDim2.new(1, -23, 0, 16) })
		task.delay(mdur(0.2), function()
			if DESTROYED or ToastSeq ~= ref or not ToastGroup then
				return
			end
			playTween(ToastGroup, ti(mdur(0.24), "Quint", "Out"), { Position = UDim2.new(1, -16, 0, 16) })
		end)
	else
		ToastGroup.GroupTransparency = 1
		ToastGroup.Position = UDim2.new(1, 56, 0, 16)
		playTween(ToastGroup, ti(dur(CONFIG.Durations.Slide), CONFIG.Easing.Slide, CONFIG.Easing.SlideDir), { Position = UDim2.new(1, -16, 0, 16), GroupTransparency = 0 })
	end
	task.delay(math.max(2, dur(CONFIG.Durations.Fade) * 4), function()
		if DESTROYED or ToastSeq ~= ref or not ToastGroup then
			return
		end
		playTween(ToastGroup, ti(dur(CONFIG.Durations.Fade), CONFIG.Easing.Slide, "In"), { Position = UDim2.new(1, 56, 0, 16), GroupTransparency = 1 })
		task.delay(dur(CONFIG.Durations.Fade) + 0.08, function()
			if DESTROYED or ToastSeq ~= ref or not ToastGroup then
				return
			end
			ToastGroup.Visible = false
		end)
	end)
end

captureShot = function()
	local ok, err = pcall(function()
		CaptureService:CaptureScreenshot()
	end)
	if ok then
		toast("Screenshot saved")
		if FlashFrame then
			FlashFrame.BackgroundTransparency = 1
			FlashFrame.Visible = true
			playTween(FlashFrame, ti(dur(CONFIG.Durations.Press), "Quad", "Out"), { BackgroundTransparency = 0.55 })
			later(dur(CONFIG.Durations.Press) + 0.05, function()
				playTween(FlashFrame, ti(dur(CONFIG.Durations.Fade), "Quad", "In"), { BackgroundTransparency = 1 })
			end)
		end
	else
		toast("Capture failed: " .. sanitizeString(tostring(err), 60), true)
	end
end

local function updateScale()
	updateRootScale()
	if not MainColumn then
		return
	end
	local vp = viewportSize()
	local scaleNow = RootScale and RootScale.Scale or 1
	local availW = vp.X / math.max(0.1, scaleNow) - 40
	local availH = vp.Y / math.max(0.1, scaleNow) - 72
	local w = math.floor(clampNum(math.min(CONFIG.Layout.MaxWidth, availW), 300, CONFIG.Layout.MaxWidth))
	local h = math.floor(clampNum(math.min(430, availH), 280, 430))
	MainColumn.Size = UDim2.new(0, w, 0, h)
	local sideW = math.floor(clampNum(w * 0.3, 138, 168))
	if SidebarPanel then
		SidebarPanel.Size = UDim2.new(0, math.max(120, sideW - 16), 1, -54)
	end
	if ContentPanel then
		ContentPanel.Position = UDim2.new(0, sideW, 0, 38)
		ContentPanel.Size = UDim2.new(1, -sideW, 1, -38)
	end
	if MainShadow then
		MainShadow.Size = UDim2.new(0, w + 20, 0, h + 20)
	end
end

local function makeSection(parent, title, order)
	return makeCard(parent, {
		Name = "Section",
		Order = order or 0,
		Title = title,
	})
end

local function makeSettingRow(parent, opts)
	opts = opts or {}
	local width = tonumber(opts.ControlWidth) or 160
	local row = new("Frame", {
		Name = "Setting",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.new(1, 0, 0, tonumber(opts.Height) or 42),
		LayoutOrder = opts.Order or 0,
	}, parent)
	makeLabel({
		Name = "Label",
		Text = sanitizeString(tostring(opts.Label or ""), 48),
		Tier = "Primary",
		TextRole = "Body",
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -width - 24, 1, 0),
		Truncate = true,
	}, row)
	if type(opts.Build) == "function" then
		opts.Build(row)
	end
	if opts.Divider ~= false then
		addRule(row)
	end
	return row
end

local function buildFeatureControl(parent, item, order, api)
	local base = order * 10
	if item.Type == "Button" then
		local button = makeButton(parent, {
			Text = sanitizeString(tostring(item.Text or "Button"), 40),
			Variant = item.Variant == "Primary" and "Primary" or nil,
			Order = base,
			Size = UDim2.new(1, 0, 0, 38),
			Divider = true,
		})
		if type(item.OnClick) == "function" then
			trackConn(button.Instance.MouseButton1Click:Connect(function()
				item.OnClick(api)
			end))
		end
		return
	end
	if item.Type == "Input" then
		makeSettingRow(parent, {
			Label = sanitizeString(tostring(item.Label or "Input"), 40),
			Order = base,
			ControlWidth = 170,
			Build = function(row)
				local input = makeTextInput(row, {
					Text = item.Value ~= nil and sanitizeString(tostring(item.Value), 400) or "",
					Placeholder = sanitizeString(tostring(item.Placeholder or "Type here and press Enter"), 80),
					Size = UDim2.new(0, 170, 0, CONFIG.Layout.InputHeight),
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
		return
	end
	if item.Type == "Toggle" then
		makeToggle(parent, {
			Text = sanitizeString(tostring(item.Label or item.Text or "Toggle"), 40),
			Value = item.Value == true,
			Order = base,
			OnChange = function(value)
				if type(item.OnChange) == "function" then
					item.OnChange(value, api)
				end
			end,
		})
		return
	end
	if item.Type == "Slider" then
		makeSlider(parent, {
			Label = sanitizeString(tostring(item.Label or "Slider"), 40),
			Min = item.Min,
			Max = item.Max,
			Step = item.Step,
			Value = item.Value,
			Format = item.Format,
			Order = base,
			OnChange = function(value)
				if type(item.OnChange) == "function" then
					item.OnChange(value, api)
				end
			end,
		})
	end
end

local function buildFeatures(addPage)
	local valid = {}
	for _, category in ipairs(FEATURES) do
		if type(category) == "table" and type(category.Controls) == "table" and #category.Controls > 0 then
			table.insert(valid, category)
		end
	end
	if #valid == 0 then
		return
	end
	local api = {
		Config = CONFIG,
		State = GalleryState,
		Toast = function(message)
			toast(message)
		end,
		OpenCustomize = function()
			openCustomize()
		end,
		CloseCustomize = function()
			closeCustomize()
		end,
		PlayLoader = function()
			playGallery()
		end,
		ApplyConfig = function()
			applyConfigNow()
		end,
		ToggleDebug = function()
			toggleDebug()
		end,
		Capture = function()
			captureShot()
		end,
		CycleSkin = function()
			local names = skinNames()
			if #names == 0 then
				return
			end
			local current = PLAYER and PLAYER:GetAttribute("BlossomSkin") or names[1]
			local index = table.find(names, current) or 0
			local nextName = names[(index % #names) + 1]
			applyTheme(SKINS[nextName], true)
			if PLAYER then
				PLAYER:SetAttribute("BlossomSkin", nextName)
			end
			saveCustomSkins()
			for otherName, otherBtn in pairs(SkinButtons) do
				setButtonActive(otherBtn, otherName == nextName)
			end
			toast("Skin: " .. nextName)
		end,
	}
	for index, category in ipairs(valid) do
		if index > 1 then
			task.wait()
			if DESTROYED then
				return
			end
		end
		local name = sanitizeString(tostring(category.Name or "Category " .. index), 24)
		if name == "" then
			name = "Category " .. index
		end
		local subtitle = sanitizeString(tostring(category.Description or ""), 120)
		local scroll = addPage(name, subtitle)
		local group = makeCard(scroll, { Name = "Group", Order = 2 })
		for order, item in ipairs(category.Controls) do
			if type(item) == "table" then
				buildFeatureControl(group, item, order, api)
			end
		end
	end
end

local CATEGORY_ICONS = {
	Home = "home",
	Loader = "ring",
	Loaders = "ring",
	Interface = "sliders",
	Animation = "diamond",
	Capture = "camera",
	Settings = "cog",
}

local function makeCategoryIcon(kind, parent)
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
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, cx, 0, cy),
			Size = UDim2.new(0, w, 0, h),
			BackgroundColor3 = TC.textDisabled,
			BackgroundTransparency = filled and 0 or 1,
			BorderSizePixel = 0,
			Rotation = rot or 0,
			ZIndex = 3,
		}, box)
		new("UICorner", { CornerRadius = UDim.new(0, radius or 1) }, f)
		if not filled then
			new("UIStroke", { Color = TC.textDisabled, Transparency = 0, Thickness = 1.6 }, f)
		end
		return f
	end
	if kind == "list" then
		shape(8, 4, 13, 2, 0, 1, true)
		shape(8, 8, 13, 2, 0, 1, true)
		shape(5.5, 12, 8, 2, 0, 1, true)
	elseif kind == "sliders" then
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
	local info = ti(mdur(CONFIG.Durations.Hover), "Quad", "Out")
	for _, child in ipairs(box:GetChildren()) do
		if child:IsA("Frame") then
			local stroke = child:FindFirstChildOfClass("UIStroke")
			if not stroke then
				if animated and not QUALITY.Instant then
					playTween(child, info, { BackgroundColor3 = color })
				else
					child.BackgroundColor3 = color
				end
			else
				if animated and not QUALITY.Instant then
					playTween(stroke, info, { Color = color })
				else
					stroke.Color = color
				end
			end
		end
	end
end

local function buildMain()
	Main = new("Frame", {
		Name = "Main",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 3,
	}, Root)
	local L = CONFIG.Layout
	local topH = 38
	local headerH = 78
	MainShadow = new("Frame", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 10),
		Size = UDim2.new(0, 600, 0, 500),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.68,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, Main)
	new("UICorner", { CornerRadius = UDim.new(0, 18) }, MainShadow)
	ambientPetals(Main)
	MainColumn = new("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, L.MaxWidth, 0, 420),
		BackgroundColor3 = TC.base,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Role = "Panel",
		ZIndex = 3,
	}, Main)
	MainScale = new("UIScale", { Scale = 1 }, MainColumn)
	new("UICorner", { CornerRadius = UDim.new(0, L.CornerRadius), Role = "Corner" }, MainColumn)
	new("UIStroke", { Color = TC.textPrimary, Transparency = CURRENT_THEME.StrokeTransparency, Thickness = 1, Role = "Edge", ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, MainColumn)
	ambientPetals(MainColumn, {
		Name = "PetalOverlay",
		ZIndex = 60,
		Count = 6,
		Width = L.MaxWidth,
		Height = 510,
		Transparency = 0.55,
	})

	local titlebar = new("Frame", {
		Name = "Titlebar",
		Size = UDim2.new(1, 0, 0, topH),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
	}, MainColumn)
	new("Frame", {
		Name = "BarSep",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = TC.divider,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Role = "Divider",
		ZIndex = 6,
	}, titlebar)
	local mark = new("Frame", {
		Name = "Mark",
		Position = UDim2.new(0, 16, 0.5, -3),
		Size = UDim2.new(0, 6, 0, 6),
		BackgroundColor3 = TC.accent,
		BorderSizePixel = 0,
		Role = "Accent",
		ZIndex = 7,
	}, titlebar)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, mark)
	makeLabel({
		Name = "Wordmark",
		Text = sanitizeString(tostring(CONFIG.Brand.Name or "Blossom"), 24),
		Tier = "Primary",
		TextRole = "Caption",
		Bold = true,
		FixedSize = true,
		TextSize = 13,
		Position = UDim2.new(0, 28, 0, 0),
		Size = UDim2.new(0, 160, 1, 0),
		ZIndex = 7,
	}, titlebar)
	makeLabel({
		Name = "Version",
		Text = "v2.0",
		Tier = "Disabled",
		TextRole = "Caption",
		FixedSize = true,
		TextSize = 11,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -42, 0.5, 0),
		Size = UDim2.new(0, 40, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 7,
	}, titlebar)
	local closeBtn = makeButton(titlebar, {
		Text = "X",
		Variant = "Ghost",
		Size = UDim2.new(0, 24, 0, 24),
		TextSize = 12,
		Bold = true,
		Radius = 6,
	})
	closeBtn.Instance.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Instance.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.Instance.ZIndex = 7
	trackConn(closeBtn.Instance.MouseButton1Click:Connect(function()
		hideMain(false)
	end))

	local drag = { active = false, start = nil, center = nil, target = nil, current = nil, conn = nil }
	local function overClose(pos)
		local btn = closeBtn.Instance
		local ap = btn.AbsolutePosition
		local as = btn.AbsoluteSize
		return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
	end
	local function isInteractive(obj)
		while obj and obj ~= MainColumn do
			if obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ImageButton") or obj:IsA("ScrollingFrame") then
				return true
			end
			if obj:GetAttribute("NoDrag") == true then
				return true
			end
			obj = obj.Parent
		end
		return false
	end
	local function overWindow(pos)
		local ap = MainColumn.AbsolutePosition
		local as = MainColumn.AbsoluteSize
		if as.X <= 0 or as.Y <= 0 then
			return false
		end
		return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
	end
	local function blockedAt(pos)
		local ok, list = pcall(function()
			return UserInputService:GetGuiObjectsAtPosition(pos.X, pos.Y)
		end)
		if not ok or type(list) ~= "table" then
			return false
		end
		for _, obj in ipairs(list) do
			if obj ~= MainColumn and obj ~= Main and obj ~= Root and obj ~= Stage and isInteractive(obj) then
				return true
			end
		end
		return false
	end
	local function clampCenter(c)
		local vp = viewportSize()
		local halfW = MainColumn.AbsoluteSize.X * 0.5
		local halfH = MainColumn.AbsoluteSize.Y * 0.5
		local minX = halfW + 8
		local minY = halfH + 8
		return Vector2.new(
			clampNum(c.X, minX, math.max(minX, vp.X - halfW - 8)),
			clampNum(c.Y, minY, math.max(minY, vp.Y - halfH - 8))
		)
	end

	local function applyDrag(center)
		local rs = math.max(0.1, RootScale and RootScale.Scale or 1)
		MainColumn.Position = UDim2.new(0, center.X / rs, 0, center.Y / rs)
	end

	local function stopDragLoop()
		if drag.conn then
			pcall(function()
				drag.conn:Disconnect()
			end)
			drag.conn = nil
		end
	end

	local function startDragLoop()
		if drag.conn then
			return
		end
		drag.conn = RunService.RenderStepped:Connect(function(dt)
			if not drag.target or not drag.current then
				return
			end
			local remaining = drag.target - drag.current
			if remaining.Magnitude < 0.35 then
				drag.current = drag.target
				applyDrag(drag.target)
				if not drag.active then
					stopDragLoop()
				end
				return
			end
			drag.current = drag.current:Lerp(drag.target, clampNum(dt * 38, 0, 1))
			applyDrag(drag.current)
		end)
		trackConn(drag.conn)
	end

	local function beginDrag(input)
		if drag.active or DESTROYED then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local pos = input.Position
		if not pos then
			return
		end
		if not MainVisible or MainColumn.Visible == false then
			return
		end
		if Customize and Customize.Visible then
			return
		end
		if overClose(pos) or not overWindow(pos) then
			return
		end
		if blockedAt(pos) then
			return
		end
		drag.active = true
		drag.start = pos
		local ap = MainColumn.AbsolutePosition
		local as = MainColumn.AbsoluteSize
		drag.center = Vector2.new(ap.X + as.X * 0.5, ap.Y + as.Y * 0.5)
		drag.target = drag.center
		drag.current = drag.center
		cancelPropTweens(MainColumn, { Position = true })
		startDragLoop()
		if MainShadow then
			uiTween(MainShadow, { BackgroundTransparency = 0.58 }, CONFIG.Durations.Hover * 1.6, "Quad", "Out")
		end
	end
	trackConn(UserInputService.InputBegan:Connect(beginDrag))
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if not drag.active or not drag.center or not drag.start then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		drag.target = clampCenter(drag.center + (input.Position - drag.start))
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not drag.active then
			return
		end
		drag.active = false
		if drag.target then
			drag.target = clampCenter(drag.target)
		end
		if MainShadow then
			uiTween(MainShadow, { BackgroundTransparency = 0.68 }, CONFIG.Durations.Hover * 1.6, "Quad", "Out")
		end
	end))

	SidebarPanel = new("Frame", {
		Name = "Sidebar",
		Position = UDim2.new(0, 8, 0, topH + 8),
		Size = UDim2.new(0, 168, 1, -(topH + 16)),
		BackgroundColor3 = TC.sidebar,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Role = "Sidebar",
		ZIndex = 4,
	}, MainColumn)
	new("UICorner", { CornerRadius = UDim.new(0, L.CornerRadius), Role = "Corner" }, SidebarPanel)
	new("UIStroke", { Color = TC.textPrimary, Transparency = CURRENT_THEME.StrokeTransparency + 0.04, Thickness = 1, Role = "CardEdge" }, SidebarPanel)
	local portraitId = tostring(CONFIG.Brand.AvatarImageId or ""):gsub("%D", "")
	local avatar = new("Frame", {
		Name = "Avatar",
		Position = UDim2.new(0, 14, 0, 13),
		Size = UDim2.new(0, 34, 0, 34),
		BackgroundColor3 = TC.accent,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Role = "Accent",
		ZIndex = 6,
	}, SidebarPanel)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, avatar)
	new("UIStroke", { Color = TC.textPrimary, Transparency = 0.84, Thickness = 1, Role = "Soft" }, avatar)
	makeLabel({
		Name = "Letter",
		Text = string.sub(sanitizeString(tostring(CONFIG.Brand.Name or "B"), 24), 1, 1),
		Tier = "OnAccent",
		TextRole = "Caption",
		Bold = true,
		FixedSize = true,
		TextSize = 16,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 7,
	}, avatar)
	local portrait = new("ImageLabel", {
		Name = "Portrait",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = portraitId ~= "" and ("rbxassetid://" .. portraitId) or "",
		ScaleType = Enum.ScaleType.Crop,
		Visible = portraitId ~= "",
		ZIndex = 8,
	}, avatar)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, portrait)
	if portraitId == "" and PLAYER then
		task.spawn(function()
			local ok, url = pcall(function()
				return Players:GetUserThumbnailAsync(PLAYER.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
			end)
			if ok and type(url) == "string" and url ~= "" and not DESTROYED and portrait.Parent then
				portrait.Image = url
				portrait.Visible = true
			end
		end)
	end
	makeLabel({
		Name = "Brand",
		Text = sanitizeString(tostring(CONFIG.Brand.Name or "Blossom"), 24),
		Tier = "Primary",
		TextRole = "Body",
		Bold = true,
		FixedSize = true,
		TextSize = 15,
		Position = UDim2.new(0, 56, 0, 12),
		Size = UDim2.new(1, -64, 0, 20),
		Truncate = true,
		ZIndex = 6,
	}, SidebarPanel)
	makeLabel({
		Name = "Tag",
		Text = sanitizeString(tostring(CONFIG.Brand.Tag or "script hub"), 24),
		Tier = "Secondary",
		TextRole = "Caption",
		FixedSize = true,
		TextSize = 11,
		Position = UDim2.new(0, 56, 0, 30),
		Size = UDim2.new(1, -64, 0, 16),
		ZIndex = 6,
	}, SidebarPanel)

	NavList = new("ScrollingFrame", {
		Name = "Nav",
		Position = UDim2.new(0, 8, 0, 66),
		Size = UDim2.new(1, -16, 1, -130),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0,
		ZIndex = 5,
	}, SidebarPanel)
	NavPill = new("Frame", {
		Name = "Pill",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = TC.accent,
		BackgroundTransparency = 0.88,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, NavList)
	new("UICorner", { CornerRadius = UDim.new(0, 8), Role = "Small" }, NavPill)
	NavIndicator = new("Frame", {
		Name = "Indicator",
		Position = UDim2.new(0, -6, 0, 8),
		Size = UDim2.new(0, 3, 0, 16),
		BackgroundColor3 = TC.accent,
		BorderSizePixel = 0,
		Role = "Accent",
		ZIndex = 7,
	}, NavPill)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, NavIndicator)

	local footer = new("Frame", {
		Name = "Footer",
		Position = UDim2.new(0, 0, 1, -58),
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
	}, SidebarPanel)
	new("Frame", {
		Name = "FooterSep",
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 0, 1),
		BackgroundColor3 = TC.divider,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Role = "Divider",
		ZIndex = 6,
	}, footer)
	local customizeBtn = makeButton(footer, {
		Text = "Customize",
		Variant = "Ghost",
		Size = UDim2.new(1, -24, 0, 28),
		TextSize = L.CaptionSize + 1,
	})
	customizeBtn.Instance.Position = UDim2.new(0, 12, 0, 8)
	trackConn(customizeBtn.Instance.MouseButton1Click:Connect(function()
		openCustomize()
	end))
	local chip = new("Frame", {
		Name = "Chip",
		Position = UDim2.new(0, 12, 0, 36),
		Size = UDim2.new(0, 24, 0, 16),
		BackgroundColor3 = TC.button,
		BorderSizePixel = 0,
		Role = "Button",
		ZIndex = 6,
	}, footer)
	new("UICorner", { CornerRadius = UDim.new(0, 4), Role = "Small" }, chip)
	makeLabel({
		Name = "Key",
		Text = "RS",
		Tier = "Secondary",
		TextRole = "Caption",
		FixedSize = true,
		TextSize = 10,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 7,
	}, chip)
	makeLabel({
		Name = "Hint",
		Text = "close · drag",
		Tier = "Disabled",
		TextRole = "Caption",
		FixedSize = true,
		TextSize = 10,
		Position = UDim2.new(0, 42, 0, 36),
		Size = UDim2.new(1, -52, 0, 16),
		Truncate = true,
		ZIndex = 6,
	}, footer)

	ContentPanel = new("Frame", {
		Name = "Content",
		Position = UDim2.new(0, 168, 0, topH),
		Size = UDim2.new(1, -168, 1, -topH),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, MainColumn)
	local banner = new("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, headerH),
		BackgroundColor3 = TC.base,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1,
	}, ContentPanel)
	new("UIGradient", { Role = "Header" }, banner)
	local headerMark = new("Frame", {
		Name = "Mark",
		Position = UDim2.new(0, 18, 0, 24),
		Size = UDim2.new(0, 3, 0, 16),
		BackgroundColor3 = TC.accent,
		BorderSizePixel = 0,
		Role = "Accent",
		ZIndex = 4,
	}, banner)
	new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, headerMark)
	BannerTitle = makeLabel({
		Name = "Title",
		Text = "Home",
		Tier = "Primary",
		TextRole = "Title",
		Bold = true,
		FixedSize = true,
		TextSize = 18,
		Position = UDim2.new(0, 29, 0, 20),
		Size = UDim2.new(1, -45, 0, 24),
		Truncate = true,
		ZIndex = 4,
	}, banner)
	BannerSubtitle = makeLabel({
		Name = "Sub",
		Text = "",
		Tier = "Secondary",
		TextRole = "Caption",
		FixedSize = true,
		TextSize = 11,
		Position = UDim2.new(0, 29, 0, 44),
		Size = UDim2.new(1, -45, 0, 16),
		Truncate = true,
		ZIndex = 4,
	}, banner)
	new("Frame", {
		Name = "HeaderRule",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = TC.divider,
		BorderSizePixel = 0,
		Role = "Divider",
		ZIndex = 4,
	}, banner)

	local pagesHost = new("Frame", {
		Name = "Pages",
		Position = UDim2.new(0, 0, 0, headerH),
		Size = UDim2.new(1, 0, 1, -headerH),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 2,
	}, ContentPanel)
	local pagesVeil = new("Frame", {
		Name = "Veil",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = TC.base,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 20,
		Role = "Surface",
	}, pagesHost)
	local pages = {}
	local pageMeta = {}
	local navRows = {}
	local navIcons = {}
	local navLabels = {}
	local activeIndex = 0
	local loadersIndex = 0

	local function switchPage(index)
		if index == activeIndex or not pages[index] then
			return
		end
		local out = pages[activeIndex]
		local inn = pages[index]
		activeIndex = index
		if out then
			out.Visible = false
			out.Position = UDim2.fromOffset(0, 0)
		end
		inn.Visible = true
		inn.ZIndex = 3
		local slideTime = mdur(CONFIG.Durations.Slide)
		local pillTime = mdur(0.24)
		local fadeTime = mdur(0.2)
		if QUALITY.Instant then
			inn.Position = UDim2.fromOffset(0, 0)
			slideTime = 0.16
			pillTime = 0.12
			fadeTime = 0.1
		else
			inn.Position = UDim2.fromOffset(0, 10)
			playTween(inn, ti(slideTime, CONFIG.Easing.Slide, CONFIG.Easing.SlideDir), { Position = UDim2.fromOffset(0, 0) })
			if pagesVeil then
				pagesVeil.BackgroundTransparency = 0.84
				playTween(pagesVeil, ti(fadeTime + 0.1, "Quad", "Out"), { BackgroundTransparency = 1 })
			end
		end
		if NavPill then
			playTween(NavPill, ti(pillTime, "Quint", "Out"), { Position = UDim2.new(0, 0, 0, (index - 1) * 34) })
		end
		for i, row in ipairs(navRows) do
			local on = i == index
			local label = navLabels[i]
			local icon = navIcons[i]
			if on then
				row.BackgroundTransparency = 1
				label:SetAttribute("Tier", "Accent")
				tintIcon(icon, TC.accent, true)
				uiTween(label, { TextColor3 = TC.accent }, 0.2, "Quad", "Out")
			else
				label:SetAttribute("Tier", "Secondary")
				tintIcon(icon, TC.textDisabled, true)
				uiTween(label, { TextColor3 = TC.textSecondary }, 0.2, "Quad", "Out")
			end
		end
		local meta = pageMeta[index]
		if BannerTitle and BannerSubtitle and meta then
			BannerTitle.Text = meta.title
			BannerSubtitle.Text = meta.subtitle or ""
			BannerTitle.TextTransparency = 1
			uiTween(BannerTitle, { TextTransparency = 0 }, 0.2, "Quad", "Out")
			BannerSubtitle.TextTransparency = 1
			uiTween(BannerSubtitle, { TextTransparency = 0 }, 0.26, "Quad", "Out")
		end
	end

	local function addPage(title, subtitle)
		local index = #pages + 1
		local page = new("Frame", {
			Name = "Page",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Visible = index == 1,
			ZIndex = index == 1 and 3 or 1,
		}, pagesHost)
		local scroll = new("ScrollingFrame", {
			Name = "Scroll",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = TC.accent,
			ScrollBarImageTransparency = 0.6,
		}, page)
		new("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}, scroll)
		new("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}, scroll)
		pages[index] = page
		pageMeta[index] = { title = title, subtitle = subtitle or "" }

		local row = new("TextButton", {
			Name = "NavRow",
			Position = UDim2.new(0, 0, 0, (index - 1) * 34),
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = TC.button,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Selectable = true,
			ZIndex = 6,
			Role = "Ghost",
		}, NavList)
		local icon = makeCategoryIcon(CATEGORY_ICONS[title] or "grid", row)
		local label = makeLabel({
			Name = "NavText",
			Text = sanitizeString(tostring(title or "Page"), 24),
			Tier = "Secondary",
			TextRole = "Body",
			Position = UDim2.new(0, 36, 0, 0),
			Size = UDim2.new(1, -44, 1, 0),
			Truncate = true,
			ZIndex = 7,
		}, row)
		navRows[index] = row
		navIcons[index] = icon
		navLabels[index] = label
		NavList.CanvasSize = UDim2.new(0, 0, 0, index * 34 + 2)
		trackConn(row.MouseButton1Click:Connect(function()
			switchPage(index)
		end))
		trackConn(row.MouseEnter:Connect(function()
			if index ~= activeIndex then
				hoverTween(row, { BackgroundTransparency = 0.94 }, true)
			end
		end))
		trackConn(row.MouseLeave:Connect(function()
			if index ~= activeIndex then
				hoverTween(row, { BackgroundTransparency = 1 }, false)
			end
		end))
		if index == 1 then
			activeIndex = 1
			tintIcon(icon, TC.accent, false)
			label.TextColor3 = TC.accent
			label:SetAttribute("Tier", "Accent")
			if BannerSubtitle then
				BannerSubtitle.Text = subtitle or ""
			end
		end
		return scroll
	end

	task.wait()
	if DESTROYED then
		return
	end

	local home = addPage("Home", "quick actions")
	local actions = makeSection(home, "Quick actions", 2)
	makeSettingRow(actions, {
		Label = "Customize",
		Order = 0,
		ControlWidth = 88,
		Build = function(row)
			local button = makeButton(row, { Text = "Open", Size = UDim2.new(0, 66, 0, 26), TextSize = L.CaptionSize + 1 })
			button.Instance.AnchorPoint = Vector2.new(1, 0.5)
			button.Instance.Position = UDim2.new(1, -10, 0.5, 0)
			trackConn(button.Instance.MouseButton1Click:Connect(function()
				openCustomize()
			end))
		end,
	})
	makeSettingRow(actions, {
		Label = "Loading animations",
		Order = 1,
		ControlWidth = 88,
		Build = function(row)
			local button = makeButton(row, { Text = "Browse", Variant = "Ghost", Size = UDim2.new(0, 66, 0, 26), TextSize = L.CaptionSize + 1 })
			button.Instance.AnchorPoint = Vector2.new(1, 0.5)
			button.Instance.Position = UDim2.new(1, -10, 0.5, 0)
			trackConn(button.Instance.MouseButton1Click:Connect(function()
				switchPage(loadersIndex)
			end))
		end,
	})
	makeSettingRow(actions, {
		Label = "Auto execute",
		Order = 2,
		ControlWidth = 88,
		Build = function(row)
			local button = makeButton(row, { Text = "Off", Variant = "Ghost", Size = UDim2.new(0, 54, 0, 26), TextSize = L.CaptionSize + 1 })
			button.Instance.AnchorPoint = Vector2.new(1, 0.5)
			button.Instance.Position = UDim2.new(1, -10, 0.5, 0)
			local function paint()
				button:SetText(AutoExecute and "On" or "Off")
				button:SetActive(AutoExecute)
			end
			paint()
			trackConn(button.Instance.MouseButton1Click:Connect(function()
				AutoExecute = not AutoExecute
				paint()
				saveCustomSkins()
				if AutoExecute then
					toast("Auto execute on")
				else
					toast("Auto execute off")
				end
			end))
		end,
	})

	task.wait()
	if DESTROYED then
		return
	end

	loadersIndex = #pages + 1
	local loaders = addPage("Loader", "loading animation")
	local loaderSection = makeSection(loaders, "Animation", 1)
	makeSettingRow(loaderSection, {
		Label = "Blossom loader",
		Order = 1,
		ControlWidth = 88,
		Build = function(row)
			local button = makeButton(row, { Text = "Play", Variant = "Primary", Size = UDim2.new(0, 66, 0, 26), TextSize = L.CaptionSize + 1 })
			button.Instance.AnchorPoint = Vector2.new(1, 0.5)
			button.Instance.Position = UDim2.new(1, -10, 0.5, 0)
			trackConn(button.Instance.MouseButton1Click:Connect(function()
				playGallery()
			end))
		end,
	})
	local playback = makeSection(loaders, "Playback", 2)
	makeToggle(playback, {
		Text = "Loop animations",
		Value = CONFIG.Gallery.LoopEnabled,
		Order = 1,
		OnChange = function(value)
			GalleryState.loop = value
		end,
	})
	makeSettingRow(playback, {
		Label = "Speed",
		Order = 2,
		ControlWidth = 164,
		Build = function(row)
			local speeds = CONFIG.Gallery.Speeds
			for index, speed in ipairs(speeds) do
				local button = makeButton(row, {
					Text = tostring(speed) .. "x",
					Size = UDim2.new(0, 44, 0, 24),
					TextSize = L.CaptionSize,
					Order = index,
				})
				button.Instance.AnchorPoint = Vector2.new(1, 0.5)
				button.Instance.Position = UDim2.new(1, -10 - (#speeds - index) * 50, 0.5, 0)
				SpeedButtons[speed] = button
				trackConn(button.Instance.MouseButton1Click:Connect(function()
					GalleryState.speed = speed
					for otherSpeed, otherBtn in pairs(SpeedButtons) do
						setButtonActive(otherBtn, otherSpeed == speed)
					end
					toast("Speed " .. tostring(speed) .. "x")
				end))
			end
			local defaultBtn = SpeedButtons[CONFIG.Gallery.DefaultSpeed]
			if defaultBtn then
				setButtonActive(defaultBtn, true)
			end
		end,
	})

	task.wait()
	if DESTROYED then
		return
	end

	buildFeatures(addPage)

	task.wait()
	if DESTROYED then
		return
	end

	local settings = addPage("Settings", "appearance and about")
	local appearance = makeSection(settings, "Appearance", 2)
	makeLabel({
		Name = "ThemeLabel",
		Text = "Theme",
		Tier = "Secondary",
		TextRole = "Caption",
		Bold = true,
		FixedSize = true,
		TextSize = 11,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = 1,
	}, appearance)
	local themeChips = new("Frame", {
		Name = "ThemeChips",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
	}, appearance)
	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		FillDirection = Enum.FillDirection.Horizontal,
		Wraps = true,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, themeChips)
	rebuildThemeChips = function()
		for _, child in ipairs(themeChips:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		SkinButtons = {}
		local active = PLAYER and PLAYER:GetAttribute("BlossomSkin") or CURRENT_THEME.Name
		for index, name in ipairs(skinNames()) do
			local chip = makeButton(themeChips, {
				Text = name,
				Variant = "Ghost",
				Size = UDim2.new(0, math.clamp(22 + #name * 7, 80, 132), 0, 24),
				TextSize = L.CaptionSize,
				Order = index,
			})
			SkinButtons[name] = chip
			setButtonActive(chip, name == active)
			trackConn(chip.Instance.MouseButton1Click:Connect(function()
				applyTheme(SKINS[name], true)
				if PLAYER then
					PLAYER:SetAttribute("BlossomSkin", name)
				end
				saveCustomSkins()
				for otherName, otherBtn in pairs(SkinButtons) do
					setButtonActive(otherBtn, otherName == name)
				end
				toast("Theme: " .. name)
			end))
		end
		ThemeCache.list = nil
	end
	rebuildThemeChips()
	makeSettingRow(appearance, {
		Label = "Theme JSON",
		Order = 2,
		ControlWidth = 88,
		Build = function(row)
			local button = makeButton(row, { Text = "Edit", Variant = "Ghost", Size = UDim2.new(0, 66, 0, 26), TextSize = L.CaptionSize + 1 })
			button.Instance.AnchorPoint = Vector2.new(1, 0.5)
			button.Instance.Position = UDim2.new(1, -10, 0.5, 0)
			trackConn(button.Instance.MouseButton1Click:Connect(function()
				openCustomize()
			end))
		end,
	})
	makeSettingRow(appearance, {
		Label = "Re-read config",
		Order = 3,
		ControlWidth = 88,
		Build = function(row)
			local button = makeButton(row, { Text = "Apply", Variant = "Ghost", Size = UDim2.new(0, 66, 0, 26), TextSize = L.CaptionSize + 1 })
			button.Instance.AnchorPoint = Vector2.new(1, 0.5)
			button.Instance.Position = UDim2.new(1, -10, 0.5, 0)
			trackConn(button.Instance.MouseButton1Click:Connect(function()
				applyConfigNow()
			end))
		end,
	})

	local info = makeSection(settings, "Info", 3)
	local infoRows = {
		{ "Version", "Blossom 2.0" },
	}
	for i, entry in ipairs(infoRows) do
		makeListRow(info, { Title = entry[1], Subtitle = entry[2], Order = i })
	end
	table.insert(REFRESH, function()
		if NavPill then
			NavPill.BackgroundColor3 = TC.accent
			NavPill.BackgroundTransparency = 0.88
		end
		if NavIndicator then
			NavIndicator.BackgroundColor3 = TC.accent
		end
		for i, row in ipairs(navRows) do
			row.BackgroundColor3 = TC.button
			row.BackgroundTransparency = 1
			if navLabels[i] then
				navLabels[i].TextColor3 = i == activeIndex and TC.accent or TC.textSecondary
			end
			tintIcon(navIcons[i], i == activeIndex and TC.accent or TC.textDisabled, false)
		end
	end)
	updateScale()
end

local function buildCustomize()
	Customize = new("Frame", {
		Name = "Customize",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 8,
	}, Root)
	local modal = new("Frame", {
		Name = "Modal",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = TC.dim,
		BackgroundTransparency = CURRENT_THEME.DimTransparency,
		BorderSizePixel = 0,
		Role = "Backdrop",
		ZIndex = 8,
	}, Customize)
	trackConn(modal.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			closeCustomize()
		end
	end))
	local panel = new("Frame", {
		Name = "Panel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, fitWidth(440), 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = TC.card,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Role = "Card",
		ZIndex = 9,
	}, Customize)
	new("UISizeConstraint", { MaxSize = Vector2.new(440, 100000) }, panel)
	new("UICorner", { CornerRadius = UDim.new(0, CONFIG.Layout.CornerRadius), Role = "Corner" }, panel)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = CURRENT_THEME.StrokeTransparency, Thickness = 1, Role = "Edge" }, panel)
	new("UIScale", { Scale = 0.96 }, panel)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 14),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
	}, panel)
	new("UIListLayout", {
		Padding = UDim.new(0, 10),
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
	makeLabel({
		Name = "Title",
		Text = "Customize",
		Tier = "Primary",
		TextRole = "Title",
		Bold = true,
		FixedSize = true,
		TextSize = 17,
		Size = UDim2.new(1, -34, 1, 0),
	}, header)
	local closeBtn = makeButton(header, {
		Text = "X",
		Variant = "Ghost",
		Size = UDim2.new(0, 22, 0, 22),
		TextSize = 11,
		Bold = true,
		Radius = 6,
	})
	closeBtn.Instance.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Instance.Position = UDim2.new(1, 0, 0.5, 0)
	trackConn(closeBtn.Instance.MouseButton1Click:Connect(function()
		closeCustomize()
	end))

	makeLabel({
		Name = "Sub",
		Text = "Paste theme or config JSON, then Apply or Save as a theme.",
		Tier = "Secondary",
		TextRole = "Caption",
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 1,
		Truncate = true,
	}, panel)

	local tabs = new("Frame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 2,
	}, panel)
	local themeTab = makeButton(tabs, { Text = "Theme JSON", Variant = "Ghost", Size = UDim2.new(0, 104, 1, 0), TextSize = CONFIG.Layout.CaptionSize, Order = 0 })
	local configTab = makeButton(tabs, { Text = "Config JSON", Variant = "Ghost", Size = UDim2.new(0, 104, 1, 0), TextSize = CONFIG.Layout.CaptionSize, Order = 1 })
	configTab.Instance.Position = UDim2.new(0, 110, 0, 0)

	local box = new("TextBox", {
		Name = "JsonBox",
		BackgroundColor3 = TC.base,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 186),
		Text = "",
		PlaceholderText = "Paste JSON here",
		Font = themeFont(),
		TextSize = CONFIG.Layout.CaptionSize,
		TextColor3 = TC.textPrimary,
		PlaceholderColor3 = TC.textDisabled,
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
	new("UICorner", { CornerRadius = UDim.new(0, CONFIG.Layout.SmallCornerRadius - 2), Role = "Small" }, box)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = CURRENT_THEME.StrokeTransparency, Thickness = 1, Role = "Edge" }, box)
	new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)
	JsonBox = box

	local nameBox = new("TextBox", {
		Name = "ThemeName",
		BackgroundColor3 = TC.base,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Text = "",
		PlaceholderText = "Name for the imported theme",
		Font = themeFont(),
		TextSize = CONFIG.Layout.CaptionSize + 1,
		TextColor3 = TC.textPrimary,
		PlaceholderColor3 = TC.textDisabled,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		TextWrapped = false,
		LayoutOrder = 4,
		Tier = "Primary",
		TextRole = "Body",
		Role = "Input",
	}, panel)
	new("UICorner", { CornerRadius = UDim.new(0, CONFIG.Layout.SmallCornerRadius - 2), Role = "Small" }, nameBox)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = CURRENT_THEME.StrokeTransparency, Thickness = 1, Role = "Edge" }, nameBox)
	new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, nameBox)

	StatusLabel = makeLabel({
		Name = "Status",
		Text = "Paste a theme or config object, then Apply.",
		Tier = "Secondary",
		TextRole = "Caption",
		Size = UDim2.new(1, 0, 0, 32),
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		LayoutOrder = 5,
	}, panel)

	local actions = new("Frame", {
		Name = "Actions",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
		LayoutOrder = 6,
	}, panel)
	local apply = makeButton(actions, { Text = "Apply", Variant = "Primary", Size = UDim2.new(0, 74, 1, 0), TextSize = CONFIG.Layout.CaptionSize + 1, Order = 0 })
	local save = makeButton(actions, { Text = "Save", Variant = "Ghost", Size = UDim2.new(0, 74, 1, 0), TextSize = CONFIG.Layout.CaptionSize + 1, Order = 1 })
	save.Instance.Position = UDim2.new(0, 80, 0, 0)
	local exp = makeButton(actions, { Text = "Export", Variant = "Ghost", Size = UDim2.new(0, 74, 1, 0), TextSize = CONFIG.Layout.CaptionSize + 1, Order = 2 })
	exp.Instance.Position = UDim2.new(0, 160, 0, 0)
	local reset = makeButton(actions, { Text = "Reset", Variant = "Ghost", Size = UDim2.new(0, 74, 1, 0), TextSize = CONFIG.Layout.CaptionSize + 1, Order = 3 })
	reset.Instance.Position = UDim2.new(0, 240, 0, 0)

	local function markTab(name)
		setButtonActive(themeTab, name == "Theme")
		setButtonActive(configTab, name == "Config")
	end
	markTab("Theme")

	trackConn(themeTab.Instance.MouseButton1Click:Connect(function()
		CustomTab = "Theme"
		markTab("Theme")
		statusText("Theme JSON mode. Export dumps the active theme.", false)
	end))
	trackConn(configTab.Instance.MouseButton1Click:Connect(function()
		CustomTab = "Config"
		markTab("Config")
		statusText("Config JSON mode. Paste Durations, Easing, Layout, Quality or Theme.", false)
	end))
	trackConn(exp.Instance.MouseButton1Click:Connect(function()
		if CustomTab == "Theme" then
			JsonBox.Text = themeToJSON(CURRENT_THEME)
			statusText("Current theme copied into the box.", false)
		else
			local payload = {
				Durations = CONFIG.Durations,
				Easing = CONFIG.Easing,
				Layout = CONFIG.Layout,
				Quality = { Level = CONFIG.Quality.Level, FpsLow = CONFIG.Quality.FpsLow, FpsHigh = CONFIG.Quality.FpsHigh, RecheckInterval = CONFIG.Quality.RecheckInterval },
			}
			local ok, json = pcall(function()
				return HttpService:JSONEncode(payload)
			end)
			if ok and type(json) == "string" then
				JsonBox.Text = json
				statusText("Current config copied into the box.", false)
			else
				statusText("Export failed.", true)
			end
		end
	end))
	trackConn(reset.Instance.MouseButton1Click:Connect(function()
		if CustomTab == "Theme" then
			applyTheme(SKINS["Sakura"], true)
			if PLAYER then
				PLAYER:SetAttribute("BlossomSkin", "Sakura")
			end
			saveCustomSkins()
			JsonBox.Text = themeToJSON(CURRENT_THEME)
			if rebuildThemeChips then
				rebuildThemeChips()
			end
			statusText("Reset to Sakura.", false)
		else
			statusText("Config kept. Paste a config object and press Apply.", false)
		end
	end))
	trackConn(save.Instance.MouseButton1Click:Connect(function()
		if CustomTab ~= "Theme" then
			statusText("Switch to Theme JSON to save a theme.", true)
			return
		end
		local data, decodeError = decodeJSON(JsonBox.Text)
		if not data then
			statusText(decodeError or "invalid JSON", true)
			return
		end
		local clean, errors, notes = validateTheme(data)
		if #errors > 0 then
			statusText(table.concat(errors, "; "), true)
			return
		end
		local typed = sanitizeString(nameBox.Text or "", 24)
		local label = typed
		if label == "" then
			label = sanitizeString(tostring(clean.Name or ""), 24)
		end
		if label == "" then
			label = "Custom " .. tostring(#skinNames() + 1)
		end
		if BUILTIN_SKINS[label] then
			if typed == "" then
				label = sanitizeString(label .. " copy", 24)
			else
				statusText("That name belongs to a built-in theme. Pick another.", true)
				return
			end
		end
		local saved = registerSkin(label, clean)
		if not saved then
			statusText("Could not save that theme name.", true)
			return
		end
		saveCustomSkins()
		preloadThemeImages(SKINS[saved])
		applyTheme(SKINS[saved], true)
		if PLAYER then
			PLAYER:SetAttribute("BlossomSkin", saved)
		end
		if rebuildThemeChips then
			rebuildThemeChips()
		end
		nameBox.Text = saved
		local noteText = "Saved theme " .. saved .. "."
		if #notes > 0 then
			noteText = noteText .. " " .. table.concat(notes, "; ")
		end
		statusText(noteText, false)
		toast("Theme saved: " .. saved)
	end))
	trackConn(apply.Instance.MouseButton1Click:Connect(function()
		local raw = JsonBox.Text
		if CustomTab == "Theme" then
			local data, decodeError = decodeJSON(raw)
			if not data then
				statusText(decodeError or "invalid JSON", true)
				return
			end
			local clean, errors, notes = validateTheme(data)
			if #errors > 0 then
				statusText(table.concat(errors, "; "), true)
				return
			end
			preloadThemeImages(clean)
			applyTheme(clean, true)
			local noteText = "Theme applied."
			if #notes > 0 then
				noteText = noteText .. " " .. table.concat(notes, "; ")
			end
			statusText(noteText, false)
			toast("Theme applied")
		else
			local data, decodeError = decodeJSON(raw)
			if not data then
				statusText(decodeError or "invalid JSON", true)
				return
			end
			local clean, errors, notes = validateConfig(data)
			if #errors > 0 then
				statusText(table.concat(errors, "; "), true)
				return
			end
			for groupKey, groupValue in pairs(clean) do
				if groupKey == "Theme" then
					preloadThemeImages(groupValue)
					applyTheme(groupValue, true)
				else
					CONFIG[groupKey] = groupValue
				end
			end
			updateScale()
			applyTheme(CURRENT_THEME, false)
			local noteText = "Config applied."
			if #notes > 0 then
				noteText = noteText .. " " .. table.concat(notes, "; ")
			end
			statusText(noteText, false)
			toast("Config applied")
		end
	end))
	table.insert(REFRESH, refreshStatus)
	table.insert(REFRESH, function()
		box.BackgroundColor3 = TC.base
		box.Font = themeFont()
	end)
end

toggleDebug = function()
	DebugState.visible = not DebugState.visible
	if DebugFrame then
		DebugFrame.Visible = DebugState.visible
	end
	if DebugState.visible then
		if DebugState.conn then
			return
		end
		DebugState.clock = 0
		DebugState.frames = 0
		DebugState.conn = RunService.RenderStepped:Connect(function(dt)
			DebugState.clock = DebugState.clock + dt
			DebugState.frames = DebugState.frames + 1
			if DebugState.clock < CONFIG.Debug.UpdateRate then
				return
			end
			DebugState.fps = math.floor(DebugState.frames / math.max(DebugState.clock, 0.0001) + 0.5)
			DebugState.clock = 0
			DebugState.frames = 0
			if not DebugFrame then
				return
			end
			local lines = DebugFrame:FindFirstChild("Lines")
			if not lines then
				return
			end
			local ms = 1000 / math.max(DebugState.fps, 1)
			DebugState.instClock = DebugState.instClock + CONFIG.Debug.UpdateRate
			if DebugState.instClock >= 1 or not DebugState.instances then
				DebugState.instClock = 0
				DebugState.instances = Gui and #Gui:GetDescendants() or 0
			end
			lines.Text = string.format("fps %d   ms %.1f\ninstances %d\nquality %s  scale %.2f", DebugState.fps, ms, DebugState.instances, QUALITY.Name, QUALITY.DurationScale)
		end)
	elseif DebugState.conn then
		pcall(function()
			DebugState.conn:Disconnect()
		end)
		DebugState.conn = nil
	end
end

local function buildDebug()
	DebugFrame = new("Frame", {
		Name = "Debug",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(0, 208, 0, 72),
		BackgroundColor3 = TC.card,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		Visible = CONFIG.Debug.StartVisible,
		Role = "Card",
		ZIndex = 12,
	}, Root)
	new("UICorner", { CornerRadius = UDim.new(0, CONFIG.Layout.SmallCornerRadius), Role = "Small" }, DebugFrame)
	new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, DebugFrame)
	makeLabel({
		Name = "Lines",
		Text = "fps 0   ms 0.0\ninstances 0\nquality " .. QUALITY.Name,
		Tier = "Secondary",
		TextRole = "Caption",
		Size = UDim2.fromScale(1, 1),
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = false,
	}, DebugFrame)
	DebugState.visible = false
	if CONFIG.Debug.StartVisible then
		toggleDebug()
	end
end

local function buildGui()
	Gui = new("ScreenGui", {
		Name = CONFIG.GuiName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 60,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = true,
	}, PLAYER_GUI)
	Gui:SetAttribute("Building", true)
	local protectGui = SkinStore.fn("protect_gui")
	if protectGui then
		pcall(protectGui, Gui)
	end
	pcall(function()
		if CONFIG.Layout.SafeArea == false then
			Gui.ScreenInsets = Enum.ScreenInsets.None
		else
			Gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
		end
	end)
	Root = new("Frame", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
	}, Gui)
	RootScale = new("UIScale", { Scale = 1 }, Root)
	Backdrop = new("Frame", {
		Name = "Backdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = TC.dim,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		Role = "Backdrop",
		ZIndex = 1,
	}, Root)
	if CONFIG.Loading.LogoMode == "Image" and CONFIG.Loading.LogoImageId ~= "" then
		local logoSize = clampNum(math.floor(tonumber(CONFIG.Loading.LogoSize) or 72), 24, 320)
		local offsetY = tonumber(CONFIG.Loading.LogoOffsetY) or -110
		LoadingLogo = new("Frame", {
			Name = "LoadingLogo",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, offsetY),
			Size = UDim2.new(0, logoSize, 0, logoSize),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 2,
		}, Backdrop)
		LoadingRotor = new("Frame", {
			Name = "Rotor",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, LoadingLogo)
		if CONFIG.Loading.LogoMode == "Image" and CONFIG.Loading.LogoImageId ~= "" then
			local mark = new("ImageLabel", {
				Name = "Mark",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://" .. tostring(CONFIG.Loading.LogoImageId):gsub("%D", ""),
				ScaleType = Enum.ScaleType.Crop,
			}, LoadingRotor)
			new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, mark)
			new("UIStroke", { Color = hexToColor(CONFIG.Loading.LogoColor), Transparency = 0.4, Thickness = 2, Role = "Accent" }, mark)
		else
			local ring = new("Frame", {
				Name = "Ring",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, LoadingRotor)
			new("UICorner", { CornerRadius = UDim.new(1, 0), Role = "Dot" }, ring)
			local ringStroke = new("UIStroke", { Color = hexToColor(CONFIG.Loading.LogoColor), Transparency = 0.2, Thickness = 3 }, ring)
			local dotColor = hexToColor(CONFIG.Loading.LogoColor)
			for _, dotPos in ipairs({ UDim2.fromScale(0.5, 0.06), UDim2.fromScale(0.88, 0.72), UDim2.fromScale(0.12, 0.72) }) do
				new("Frame", {
					Name = "Dot",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = dotPos,
					Size = UDim2.fromScale(0.15, 0.15),
					BackgroundColor3 = dotColor,
					BorderSizePixel = 0,
				}, LoadingRotor)
			end
			new("Frame", {
				Name = "Core",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.3, 0.3),
				BackgroundColor3 = hexToColor(CONFIG.Loading.LogoCoreColor),
				BackgroundTransparency = 0.1,
				BorderSizePixel = 0,
			}, LoadingRotor)
			table.insert(REFRESH, function()
				if not LoadingRotor or not LoadingRotor.Parent then
					return
				end
				ringStroke.Color = hexToColor(CONFIG.Loading.LogoColor)
				ringStroke.Transparency = 0.2
				ringStroke.Thickness = 3
				for _, child in ipairs(LoadingRotor:GetChildren()) do
					if child.Name == "Dot" then
						child.BackgroundColor3 = hexToColor(CONFIG.Loading.LogoColor)
					elseif child.Name == "Core" then
						child.BackgroundColor3 = hexToColor(CONFIG.Loading.LogoCoreColor)
					end
				end
			end)
		end
	end
	Stage = new("Frame", {
		Name = "Stage",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, Root)
	FlashFrame = new("Frame", {
		Name = "Flash",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
	}, Root)
	CountdownLabel = new("TextLabel", {
		Name = "Countdown",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Font = boldFont(),
		TextSize = 64,
		TextColor3 = TC.textPrimary,
		TextTransparency = 1,
		TextWrapped = false,
		ZIndex = 14,
	}, Root)
	CountdownLabel:SetAttribute("Bold", true)
	CountdownLabel:SetAttribute("FixedSize", true)
	ToastGroup = new("CanvasGroup", {
		Name = "Toast",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.new(0, 268, 0, 42),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 16,
	}, Root)
	new("UISizeConstraint", { MaxSize = Vector2.new(300, 64) }, ToastGroup)
	local toastCard = new("Frame", {
		Name = "Card",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = TC.card,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Role = "Card",
	}, ToastGroup)
	new("UICorner", { CornerRadius = UDim.new(0, CONFIG.Layout.SmallCornerRadius), Role = "Small" }, toastCard)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = CURRENT_THEME.StrokeTransparency, Thickness = 1, Role = "Edge" }, toastCard)
	ToastStripe = new("Frame", {
		Name = "Stripe",
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundColor3 = TC.accent,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Role = "Accent",
		ZIndex = 2,
	}, ToastGroup)
	new("UICorner", { CornerRadius = UDim.new(0, 2), Role = "Small" }, ToastStripe)
	ToastLabel = new("TextLabel", {
		Name = "Text",
		Position = UDim2.new(0, 15, 0, 0),
		Size = UDim2.new(1, -25, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		Font = themeFont(),
		TextSize = CONFIG.Layout.CaptionSize + 1,
		TextColor3 = TC.textPrimary,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Tier = "Primary",
		TextRole = "Caption",
	}, ToastGroup)
	updateScale()
	task.wait()
	if DESTROYED then
		return
	end
	buildMain()
	task.wait()
	if DESTROYED then
		return
	end
	buildCustomize()
	task.wait()
	if DESTROYED then
		return
	end
	buildDebug()
	Gui:SetAttribute("Building", false)
end
local destroyAll
local UserHidden = false
local CustomizeOpen = false

local function applyControlVisibility()
	if Main then
		Main.Visible = MainVisible and not UserHidden
	end
	if Customize then
		Customize.Visible = CustomizeOpen and not UserHidden
	end
end

local function hideControls()
	if Main then
		Main.Visible = false
	end
	if Customize then
		Customize.Visible = false
	end
end

local function toggleMenuVisibility()
	if PLAYING then
		return
	end
	UserHidden = not UserHidden
	if UserHidden then
		hideMain(false)
		if Customize then
			Customize.Visible = false
		end
	elseif MainVisible then
		Main.Visible = true
		if Customize and CustomizeOpen then
			Customize.Visible = true
		end
	else
		showMain(true)
	end
	toast(UserHidden and "Menu hidden" or "Menu shown")
end

local function waitCancel(seconds, token)
	local deadline = os.clock() + seconds
	while os.clock() < deadline do
		if DESTROYED or TOKEN ~= token then
			return false
		end
		task.wait(0.05)
	end
	return not DESTROYED and TOKEN == token
end

openCustomize = function()
	if not Customize then
		return
	end
	CustomizeOpen = true
	Customize.Visible = not UserHidden
	local modal = Customize:FindFirstChild("Modal")
	local panel = Customize:FindFirstChild("Panel")
	local scale = panel and panel:FindFirstChildOfClass("UIScale")
	if panel and not scale then
		scale = new("UIScale", { Scale = 0.96 }, panel)
	end
	if QUALITY.Instant then
		if scale then
			scale.Scale = 1
		end
		if modal then
			modal.BackgroundTransparency = CURRENT_THEME.DimTransparency
		end
		return
	end
	if modal then
		modal.BackgroundTransparency = 0.9
		playTween(modal, ti(mdur(CONFIG.Durations.Fade), CONFIG.Easing.Fade, "Out"), { BackgroundTransparency = CURRENT_THEME.DimTransparency })
	end
	if scale then
		scale.Scale = 0.96
		playTween(scale, ti(mdur(CONFIG.Durations.Transition), "Quint", "Out"), { Scale = 1 })
	end
end

closeCustomize = function()
	CustomizeOpen = false
	if not Customize then
		return
	end
	local modal = Customize:FindFirstChild("Modal")
	local panel = Customize:FindFirstChild("Panel")
	local scale = panel and panel:FindFirstChildOfClass("UIScale")
	if QUALITY.Instant or not modal then
		Customize.Visible = false
		return
	end
	playTween(modal, ti(mdur(CONFIG.Durations.Fade) * 0.8, "Quad", "In"), { BackgroundTransparency = 1 })
	if scale then
		playTween(scale, ti(mdur(CONFIG.Durations.Fade) * 0.8, "Quad", "In"), { Scale = 0.97 })
	end
	local waitTime = mdur(CONFIG.Durations.Fade) * 0.8 + 0.02
	task.delay(waitTime, function()
		if DESTROYED or not Customize then
			return
		end
		if not CustomizeOpen then
			Customize.Visible = false
		end
	end)
end

applyConfigNow = function()
	updateScale()
	applyTheme(CURRENT_THEME, false)
	toast("Config re-read")
	if not PLAYING then
		playGallery()
	end
end

local function abortLoader(showMenu)
	TOKEN = TOKEN + 1
	PLAYING = false
	ACTIVE_SPEED = 1
	clearStage()
	setLoading(false)
	if showMenu and not DESTROYED then
		if not MainVisible then
			showMain(false)
		end
		setBackdrop("main")
	end
	applyControlVisibility()
end

playGallery = function()
	if DESTROYED then
		return
	end
	if PLAYING then
		abortLoader(true)
	end
	PLAYING = true
	TOKEN = TOKEN + 1
	local token = TOKEN
	ACTIVE_SPEED = GalleryState.speed
	hideControls()

	local function runCountdown()
		if not GalleryState.countdown or not CountdownLabel then
			return true
		end
		for i = 3, 1, -1 do
			if DESTROYED or TOKEN ~= token then
				return false
			end
			CountdownLabel.Text = tostring(i)
			playTween(CountdownLabel, ti(dur(0.16), "Quad", "Out"), { TextTransparency = 0 })
			if not waitCancel(dur(CONFIG.Durations.Countdown), token) then
				return false
			end
			playTween(CountdownLabel, ti(dur(0.16), "Quad", "In"), { TextTransparency = 1 })
			if not waitCancel(dur(CONFIG.Durations.CountdownGap), token) then
				return false
			end
		end
		return TOKEN == token
	end

	if not runCountdown() then
		abortLoader(true)
		return
	end

	Stage.Visible = true
	Backdrop.Visible = true
	setLoading(true)
	setBackdrop("loading")

	local restoreMain = MainVisible
	if restoreMain then
		hideMain(true)
	end

	local launched, result = pcall(loaderSplash)
	if not launched then
		warn("Blossom loader failed: " .. tostring(result))
		toast("Loader reset", true)
		abortLoader(true)
		return
	end
	local total = tonumber(result) or 2
	if total < 0.2 then
		total = 0.2
	end
	task.delay(total + 2, function()
		if not DESTROYED and PLAYING and TOKEN == token then
			warn("Blossom loader watchdog reset")
			abortLoader(true)
		end
	end)

	waitCancel(total + 0.1, token)
	clearStage()
	PLAYING = false
	ACTIVE_SPEED = 1
	if DESTROYED then
		return
	end
	if restoreMain and not MainVisible then
		showMain(true)
	else
		setLoading(false)
		setBackdrop("main")
	end
	applyControlVisibility()
	if token == TOKEN and GalleryState.loop then
		later(dur(CONFIG.Durations.LoopGap), function()
			playGallery()
		end)
	end
end

local function handleInput(input)
	if DESTROYED or (Gui and Gui:GetAttribute("Building") == true) then
		return
	end
	if input.KeyCode == CONFIG.DestroyKey and UserInputService:IsKeyDown(CONFIG.DestroyModifier) then
		destroyAll()
	elseif input.KeyCode == CONFIG.DebugKey then
		toggleDebug()
	elseif input.KeyCode == CONFIG.ScreenshotKey then
		captureShot()
	elseif input.KeyCode == CONFIG.HideKey and not UserInputService:GetFocusedTextBox() then
		toggleMenuVisibility()
	end
end

local SAVED_QUALITY = "Medium"

local function qualityRank(name)
	if name == "Low" then
		return 1
	elseif name == "High" then
		return 3
	end
	return 2
end

local function fpsLevel(fps)
	if fps < (tonumber(CONFIG.Quality.FpsLow) or 30) then
		return "Low"
	elseif fps < (tonumber(CONFIG.Quality.FpsHigh) or 50) then
		return "Medium"
	end
	return "High"
end

local function chooseQuality(fps)
	local measured = fpsLevel(fps)
	if qualityRank(measured) < qualityRank(SAVED_QUALITY) then
		return measured
	end
	return SAVED_QUALITY
end

local function applyQuality(name)
	local preset = CONFIG.Quality[name] or CONFIG.Quality.Medium
	QUALITY = {
		Name = name,
		Shimmer = preset.Shimmer,
		Blur = preset.Blur,
		Instant = preset.Instant == true,
		DurationScale = preset.DurationScale,
		ScalePop = preset.ScalePop == true,
	}
end

local function detectQuality()
	local level = CONFIG.Quality.Level
	local name
	local measuredFps = 0
	if CONFIG.Quality.Auto and level == "Auto" then
		local saved = 5
		pcall(function()
			local level = UserSettings():GetService("UserGameSettings").SavedQualityLevel
			if typeof(level) == "EnumItem" then
				level = level.Value
			end
			if type(level) == "number" then
				saved = level
			end
		end)
		if saved <= 4 then
			SAVED_QUALITY = "Low"
		elseif saved <= 7 then
			SAVED_QUALITY = "Medium"
		else
			SAVED_QUALITY = "High"
		end
		local warm = math.floor(clampNum(tonumber(CONFIG.Quality.WarmupFrames) or 8, 0, 60))
		local target = math.floor(clampNum(tonumber(CONFIG.Quality.SampleFrames) or 30, 4, 240))
		local total = 0
		local count = 0
		local seen = 0
		local conn
		conn = RunService.RenderStepped:Connect(function(dt)
			if dt <= 0 or dt >= 1 then
				return
			end
			if seen < warm then
				seen = seen + 1
				return
			end
			total = total + dt
			count = count + 1
			if count >= target then
				conn:Disconnect()
			end
		end)
		trackConn(conn)
		local started = os.clock()
		while count < target and os.clock() - started < 0.5 do
			task.wait(0.01)
		end
		if count > 0 then
			measuredFps = count / math.max(total, 0.001)
		end
		name = chooseQuality(measuredFps)
		print("Blossom quality " .. name .. "  measured " .. string.format("%.0f", measuredFps) .. " fps  saved ceiling " .. SAVED_QUALITY)
	else
		name = level
		if name == "Auto" then
			name = "Medium"
		end
		SAVED_QUALITY = name
	end
	applyQuality(name)
end

local function startQualityMonitor()
	if not CONFIG.Quality.Auto or CONFIG.Quality.Level ~= "Auto" then
		return
	end
	task.spawn(function()
		while not DESTROYED do
			local interval = tonumber(CONFIG.Quality.RecheckInterval) or 0
			if interval <= 0 then
				return
			end
			task.wait(math.max(2, interval))
			if DESTROYED then
				return
			end
			local frames = 0
			local total = 0
			local conn = RunService.RenderStepped:Connect(function(dt)
				if dt <= 0 or dt >= 1 then
					return
				end
				frames = frames + 1
				total = total + dt
			end)
			task.wait(1)
			pcall(function()
				conn:Disconnect()
			end)
			if not DESTROYED and frames >= 8 then
				local fps = frames / math.max(total, 0.001)
				local target = chooseQuality(fps)
				if target ~= QUALITY.Name then
					local upgrade = qualityRank(target) > qualityRank(QUALITY.Name)
					local boundary = (target == "High") and (tonumber(CONFIG.Quality.FpsHigh) or 50) or (tonumber(CONFIG.Quality.FpsLow) or 30)
					local margin = tonumber(CONFIG.Quality.UpgradeMargin) or 3
					if not upgrade or fps >= boundary + margin then
						applyQuality(target)
						manageBlur()
						print("Blossom quality " .. target .. "  average " .. string.format("%.0f", fps) .. " fps")
					end
				end
			end
		end
	end)
end

local function activeSkinName()
	if PLAYER then
		local stored = PLAYER:GetAttribute("BlossomSkin")
		if type(stored) == "string" and SKINS[stored] then
			return stored
		end
	end
	return "Sakura"
end

local function destroyGuiCopies()
	local hosts = { PLAYER_GUI }
	if PLAYER then
		local pg = PLAYER:FindFirstChild("PlayerGui")
		if pg and pg ~= PLAYER_GUI then
			table.insert(hosts, pg)
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
	local plr = Players.LocalPlayer
	if not plr then
		plr = Players.PlayerAdded:Wait()
	end
	local pg = plr:WaitForChild("PlayerGui", 15)
	if not pg then
		error("PlayerGui did not load in time")
	end
	if not game:IsLoaded() then
		local done = false
		local loaded = game.Loaded:Connect(function()
			done = true
		end)
		local started = os.clock()
		while not done and os.clock() - started < 20 do
			task.wait(0.1)
		end
		loaded:Disconnect()
	end
	local gethui = SkinStore.fn("gethui")
	if gethui then
		local okHidden, hidden = pcall(gethui)
		if okHidden and typeof(hidden) == "Instance" then
			return plr, hidden
		end
	end
	return plr, pg
end

local function showFatal(message)
	pcall(function()
		local gui = Instance.new("ScreenGui")
		gui.Name = CONFIG.GuiName
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 100
		gui.Parent = PLAYER_GUI
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0.5, 0, 0, 24)
		frame.Size = UDim2.new(0, 400, 0, 104)
		frame.BackgroundColor3 = Color3.fromRGB(30, 14, 16)
		frame.BackgroundTransparency = 0.12
		frame.BorderSizePixel = 0
		frame.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = frame
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 120, 120)
		stroke.Transparency = 0.5
		stroke.Thickness = 1
		stroke.Parent = frame
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
		label.Text = "Blossom failed to start:\n" .. sanitizeString(tostring(message), 500)
		label.Parent = frame
	end)
end

local function runStartup()
	Stage.Visible = true
	Backdrop.Visible = true
	Backdrop.BackgroundTransparency = 1
	setLoading(true)
	setBackdrop("loading")
	PLAYING = true
	TOKEN = TOKEN + 1
	local token = TOKEN
	ACTIVE_SPEED = 1
	if CONFIG.AutoPlay then
		local ok, err = pcall(function()
			waitCancel(CONFIG.StartupDelay, token)
			if token ~= TOKEN then
				return
			end
			local total = loaderSplash()
			waitCancel(total + 0.05, token)
			clearStage()
		end)
		if not ok then
			warn("Blossom startup animation failed: " .. tostring(err))
		end
	end
	clearStage()
	if token == TOKEN then
		setLoading(false)
		if not MainVisible then
			showMain(true)
		end
		setBackdrop("main")
		PLAYING = false
		applyControlVisibility()
	end
end

local function main()
	PLAYER, PLAYER_GUI = getEnvironment()
	local previous = _G["BlossomDestroy"]
	if typeof(previous) == "function" then
		pcall(previous)
	end
	destroyGuiCopies()
	_G["BlossomDestroy"] = destroyAll
	detectQuality()
	loadCustomSkins()
	local skinName = activeSkinName()
	CURRENT_THEME = copyTable(SKINS[skinName] or SKINS["Sakura"])
	recomputeColors(CURRENT_THEME)
	trackConn(UserInputService.InputBegan:Connect(handleInput))
	local camera = workspace.CurrentCamera
	if camera then
		local resizePending = false
		trackConn(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if resizePending then
				return
			end
			resizePending = true
			task.delay(0.08, function()
				resizePending = false
				if not DESTROYED then
					updateScale()
				end
			end)
		end))
	end
	buildGui()
	if DESTROYED then
		return
	end
	task.wait()
	if DESTROYED then
		return
	end
	applyTheme(CURRENT_THEME, false)
	preloadThemeImages(CURRENT_THEME)
	local skinBtn = SkinButtons[skinName]
	if skinBtn then
		setButtonActive(skinBtn, true)
	end
	PLAYER:SetAttribute("BlossomSkin", skinName)
	print("Blossom sample theme JSON:")
	print(themeToJSON(CURRENT_THEME))
	runStartup()
	if AutoExecute then
		task.spawn(function()
			task.wait(0.8)
			if DESTROYED then
				return
			end
			local ok, err = pcall(function()
				playGallery()
			end)
			if not ok then
				warn("Blossom auto execute skipped: " .. tostring(err))
			end
		end)
	end
	startQualityMonitor()
end

destroyAll = function()
	if DESTROYED then
		return
	end
	DESTROYED = true
	TOKEN = TOKEN + 1
	PLAYING = false
	if DebugState.conn then
		pcall(function()
			DebugState.conn:Disconnect()
		end)
		DebugState.conn = nil
	end
	cancelList(STAGE_TWEENS)
	cancelList(THEME_TWEENS)
	cancelList(TWEENS)
	for _, c in ipairs(CONNS) do
		pcall(function()
			c:Disconnect()
		end)
	end
	table.clear(CONNS)
	for _, c in ipairs(STAGE_CONNS) do
		pcall(function()
			c:Disconnect()
		end)
	end
	table.clear(STAGE_CONNS)
	table.clear(REFRESH)
	if Blur then
		pcall(function()
			Blur:Destroy()
		end)
		Blur = nil
	end
	if Gui then
		pcall(function()
			Gui:Destroy()
		end)
		Gui = nil
	end
	destroyGuiCopies()
	if _G["BlossomDestroy"] == destroyAll then
		_G["BlossomDestroy"] = nil
	end
	print("Blossom destroyed")
end

local started, failure = pcall(main)
if not started then
	pcall(destroyAll)
	DESTROYED = false
	showFatal(failure)
	warn("Blossom error: " .. tostring(failure))
end
