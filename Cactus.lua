local Cactus = {}
Cactus.Flags = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function Tween(obj, props, t, style, dir)
	local info = TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function Ripple(parent, color)
	local r = Instance.new("Frame")
	r.BackgroundColor3 = color or Color3.new(1,1,1)
	r.BackgroundTransparency = 0.75
	r.AnchorPoint = Vector2.new(0.5,0.5)
	r.Size = UDim2.fromOffset(0,0)
	r.Position = UDim2.fromScale(0.5,0.5)
	r.ZIndex = (parent.ZIndex or 1) + 10
	Instance.new("UICorner").Parent = r
	r.Parent = parent
	Tween(r, {Size=UDim2.fromOffset(parent.AbsoluteSize.X*2.2,parent.AbsoluteSize.X*2.2),BackgroundTransparency=1}, 0.5, Enum.EasingStyle.Quad)
	game:GetService("Debris"):AddItem(r, 0.55)
end

local function Drag(frame, handle)
	local drag, mousePos, framePos = false, nil, nil
	local dragInput
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true
			mousePos = inp.Position
			framePos = frame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then drag = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if inp == dragInput and drag then
			local d = inp.Position - mousePos
			frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset+d.X, framePos.Y.Scale, framePos.Y.Offset+d.Y)
		end
	end)
end

local function HSV(h,s,v)
	if s==0 then return v,v,v end
	h=h*6
	local i=math.floor(h)
	local f=h-i
	local p=v*(1-s)
	local q=v*(1-s*f)
	local t2=v*(1-s*(1-f))
	if i==0 then return v,t2,p
	elseif i==1 then return q,v,p
	elseif i==2 then return p,v,t2
	elseif i==3 then return p,q,v
	elseif i==4 then return t2,p,v
	else return v,p,q end
end

local function RGB2HSV(r,g,b)
	local mx=math.max(r,g,b)
	local mn=math.min(r,g,b)
	local d=mx-mn
	local h,s,v=0,0,mx
	if mx~=0 then s=d/mx end
	if d~=0 then
		if mx==r then h=(g-b)/d%6
		elseif mx==g then h=(b-r)/d+2
		else h=(r-g)/d+4 end
		h=h/6
	end
	return h,s,v
end

local ACCENT = Color3.fromRGB(170,170,255)
local ACCENT2 = Color3.fromRGB(110,110,190)
local BG = Color3.fromRGB(19,20,25)
local BG2 = Color3.fromRGB(17,18,22)
local BG3 = Color3.fromRGB(16,17,21)
local COMP_BG = Color3.fromRGB(24,25,32)
local LINER = Color3.fromRGB(31,31,45)
local MUTED = Color3.fromRGB(69,71,90)
local STROKE = Color3.fromRGB(28,30,38)

local NotifHolder

local function GetNotifHolder()
	if NotifHolder and NotifHolder.Parent then return NotifHolder end
	local sg = Instance.new("ScreenGui")
	sg.Name = "CactusNotifs"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 9999
	pcall(function() sg.Parent = CoreGui end)
	if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end
	local h = Instance.new("Frame")
	h.AnchorPoint = Vector2.new(1,1)
	h.BackgroundTransparency = 1
	h.Position = UDim2.new(1,-16,1,-16)
	h.Size = UDim2.fromOffset(300,0)
	h.AutomaticSize = Enum.AutomaticSize.Y
	h.Parent = sg
	local ul = Instance.new("UIListLayout")
	ul.SortOrder = Enum.SortOrder.LayoutOrder
	ul.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ul.Padding = UDim.new(0,8)
	ul.Parent = h
	NotifHolder = h
	return h
end

function Cactus.Notify(opts)
	opts = opts or {}
	local title = opts.Title or "Cactus"
	local desc = opts.Description or ""
	local dur = opts.Duration or 4
	local ntype = opts.Type or "Info"
	local accent = ({
		Info = ACCENT,
		Success = Color3.fromRGB(80,210,120),
		Error = Color3.fromRGB(210,70,70),
		Warning = Color3.fromRGB(220,170,40)
	})[ntype] or ACCENT

	local holder = GetNotifHolder()
	local card = Instance.new("Frame")
	card.BackgroundColor3 = BG
	card.Size = UDim2.fromOffset(300,0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.ClipsDescendants = true
	card.Position = UDim2.fromOffset(320,0)
	card.LayoutOrder = tick()
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0,8)
	cc.Parent = card
	local cs = Instance.new("UIStroke")
	cs.Color = LINER
	cs.Parent = card

	local accentBar = Instance.new("Frame")
	accentBar.BackgroundColor3 = accent
	accentBar.Size = UDim2.new(0,3,1,0)
	Instance.new("UICorner").Parent = accentBar
	accentBar.Parent = card

	local inner = Instance.new("Frame")
	inner.BackgroundTransparency = 1
	inner.Position = UDim2.fromOffset(12,0)
	inner.Size = UDim2.new(1,-12,1,0)
	inner.AutomaticSize = Enum.AutomaticSize.Y
	inner.Parent = card

	local ip = Instance.new("UIPadding")
	ip.PaddingTop = UDim.new(0,10)
	ip.PaddingBottom = UDim.new(0,10)
	ip.PaddingRight = UDim.new(0,10)
	ip.Parent = inner

	local il = Instance.new("UIListLayout")
	il.Padding = UDim.new(0,3)
	il.Parent = inner

	local tl = Instance.new("TextLabel")
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.new(1,0,0,0)
	tl.AutomaticSize = Enum.AutomaticSize.Y
	tl.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.SemiBold)
	tl.Text = title
	tl.TextColor3 = Color3.new(1,1,1)
	tl.TextSize = 13
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.TextWrapped = true
	tl.Parent = inner

	if desc ~= "" then
		local dl = Instance.new("TextLabel")
		dl.BackgroundTransparency = 1
		dl.Size = UDim2.new(1,0,0,0)
		dl.AutomaticSize = Enum.AutomaticSize.Y
		dl.FontFace = Font.new("rbxassetid://12187365364")
		dl.Text = desc
		dl.TextColor3 = Color3.fromRGB(110,110,130)
		dl.TextSize = 12
		dl.TextXAlignment = Enum.TextXAlignment.Left
		dl.TextWrapped = true
		dl.Parent = inner
	end

	local prog = Instance.new("Frame")
	prog.BackgroundColor3 = accent
	prog.BackgroundTransparency = 0.4
	prog.AnchorPoint = Vector2.new(0,1)
	prog.Position = UDim2.fromScale(0,1)
	prog.Size = UDim2.new(1,0,0,2)
	prog.Parent = card

	card.Parent = holder
	Tween(card, {Position=UDim2.fromOffset(0,0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	Tween(prog, {Size=UDim2.new(0,0,0,2)}, dur, Enum.EasingStyle.Linear)
	task.delay(dur, function()
		Tween(card, {Position=UDim2.fromOffset(320,0)}, 0.3)
		task.wait(0.35)
		card:Destroy()
	end)
end

local function MakeSection(container, name)
	local section = {}

	local sf = Instance.new("Frame")
	sf.Name = "Sec_"..name
	sf.AutomaticSize = Enum.AutomaticSize.Y
	sf.BackgroundColor3 = BG2
	sf.ClipsDescendants = true
	sf.Size = UDim2.fromOffset(281,60)
	Instance.new("UICorner").Parent = sf

	local hdr = Instance.new("Frame")
	hdr.AnchorPoint = Vector2.new(0.5,0)
	hdr.BackgroundColor3 = BG
	hdr.Position = UDim2.fromScale(0.5,0)
	hdr.Size = UDim2.fromOffset(281,30)
	Instance.new("UICorner").Parent = hdr

	local hl = Instance.new("Frame")
	hl.AnchorPoint = Vector2.new(0.5,1)
	hl.BackgroundColor3 = Color3.fromRGB(26,26,37)
	hl.BorderSizePixel = 0
	hl.Position = UDim2.fromScale(0.5,1)
	hl.Size = UDim2.new(1,1,0,1)
	hl.Parent = hdr

	local hh = Instance.new("Frame")
	hh.AnchorPoint = Vector2.new(0.5,0.5)
	hh.BackgroundTransparency = 1
	hh.ClipsDescendants = true
	hh.Position = UDim2.fromScale(0.5,0.5)
	hh.Size = UDim2.fromOffset(281,30)
	hh.Parent = hdr

	local acc = Instance.new("Frame")
	acc.AnchorPoint = Vector2.new(0,0.5)
	acc.BackgroundColor3 = ACCENT
	acc.Position = UDim2.new(0,-3,0.5,0)
	acc.Size = UDim2.fromOffset(4,18)
	Instance.new("UICorner").Parent = acc
	local ag = Instance.new("UIGradient")
	ag.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,ACCENT),ColorSequenceKeypoint.new(1,ACCENT2)})
	ag.Parent = acc
	acc.Parent = hh

	local nm = Instance.new("TextLabel")
	nm.AnchorPoint = Vector2.new(0,0.5)
	nm.AutomaticSize = Enum.AutomaticSize.XY
	nm.BackgroundTransparency = 1
	nm.FontFace = Font.new("rbxassetid://12187365364")
	nm.Position = UDim2.new(0,14,0.5,0)
	nm.Size = UDim2.fromOffset(1,1)
	nm.Text = name
	nm.TextColor3 = Color3.new(1,1,1)
	nm.TextSize = 12
	nm.Parent = hh

	hdr.Parent = sf

	local ch = Instance.new("Frame")
	ch.Name = "CH"
	ch.AnchorPoint = Vector2.new(0.5,0)
	ch.AutomaticSize = Enum.AutomaticSize.Y
	ch.BackgroundTransparency = 1
	ch.Position = UDim2.fromScale(0.5,1)
	ch.Size = UDim2.fromOffset(1,1)
	ch.Parent = sf

	local cl = Instance.new("UIListLayout")
	cl.Padding = UDim.new(0,4)
	cl.SortOrder = Enum.SortOrder.LayoutOrder
	cl.Parent = ch

	local cp = Instance.new("UIPadding")
	cp.PaddingBottom = UDim.new(0,10)
	cp.PaddingTop = UDim.new(0,5)
	cp.Parent = ch

	sf.Parent = container

	function section:AddToggle(opts)
		opts = opts or {}
		local lbl = opts.Name or "Toggle"
		local def = opts.Default or false
		local cb = opts.Callback or function() end
		local flag = opts.Flag
		local val = def

		local comp = Instance.new("Frame")
		comp.AnchorPoint = Vector2.new(0.5,0)
		comp.BackgroundTransparency = 1
		comp.Position = UDim2.fromScale(0.5,0)
		comp.Size = UDim2.fromOffset(281,30)
		comp.ClipsDescendants = true
		comp.Parent = ch

		local box = Instance.new("Frame")
		box.AnchorPoint = Vector2.new(0,0.5)
		box.BackgroundColor3 = COMP_BG
		box.Position = UDim2.new(0,12,0.5,0)
		box.Size = UDim2.fromOffset(14,14)
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0,3)
		bc.Parent = box
		local bs = Instance.new("UIStroke")
		bs.Color = STROKE
		bs.Parent = box

		local chk = Instance.new("ImageLabel")
		chk.AnchorPoint = Vector2.new(0.5,0.5)
		chk.BackgroundTransparency = 1
		chk.Image = "rbxassetid://83899464799881"
		chk.Position = UDim2.fromScale(0.5,0.5)
		chk.Size = UDim2.fromOffset(8,7)
		chk.ImageTransparency = 1
		chk.Parent = box
		box.Parent = comp

		local tag = Instance.new("TextLabel")
		tag.AnchorPoint = Vector2.new(0,0.5)
		tag.AutomaticSize = Enum.AutomaticSize.XY
		tag.BackgroundTransparency = 1
		tag.FontFace = Font.new("rbxassetid://12187365364")
		tag.Position = UDim2.new(0,32,0.5,0)
		tag.Size = UDim2.fromOffset(1,1)
		tag.Text = lbl
		tag.TextColor3 = MUTED
		tag.TextSize = 12
		tag.Parent = comp

		local btn = Instance.new("TextButton")
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.fromScale(1,1)
		btn.Text = ""
		btn.ZIndex = 5
		btn.Parent = comp

		local function Set(v)
			val = v
			if v then
				Tween(box,{BackgroundColor3=ACCENT},0.15)
				Tween(chk,{ImageTransparency=0},0.15)
				Tween(tag,{TextColor3=Color3.new(1,1,1)},0.15)
				bs.Color = ACCENT
			else
				Tween(box,{BackgroundColor3=COMP_BG},0.15)
				Tween(chk,{ImageTransparency=1},0.15)
				Tween(tag,{TextColor3=MUTED},0.15)
				bs.Color = STROKE
			end
			cb(v)
			if flag then Cactus.Flags[flag] = v end
		end
		Set(def)

		btn.MouseButton1Click:Connect(function()
			Ripple(comp)
			Set(not val)
		end)
		btn.MouseEnter:Connect(function() Tween(comp,{BackgroundColor3=Color3.fromRGB(30,31,40),BackgroundTransparency=0.97},0.1) end)
		btn.MouseLeave:Connect(function() Tween(comp,{BackgroundTransparency=1},0.1) end)

		local obj = {}
		function obj:Set(v) Set(v) end
		function obj:Get() return val end
		if flag then Cactus.Flags[flag] = val end
		return obj
	end

	function section:AddSlider(opts)
		opts = opts or {}
		local lbl = opts.Name or "Slider"
		local mn = opts.Min or 0
		local mx = opts.Max or 100
		local def = math.clamp(opts.Default or mn, mn, mx)
		local sfx = opts.Suffix or ""
		local prec = opts.Precision
		local cb = opts.Callback or function() end
		local flag = opts.Flag
		local val = def
		local dragging = false

		local comp = Instance.new("Frame")
		comp.Active = true
		comp.AnchorPoint = Vector2.new(0.5,0)
		comp.BackgroundTransparency = 1
		comp.Position = UDim2.fromScale(0.5,0)
		comp.Size = UDim2.fromOffset(281,42)
		comp.Parent = ch

		local tag = Instance.new("TextLabel")
		tag.AnchorPoint = Vector2.new(0,0.5)
		tag.AutomaticSize = Enum.AutomaticSize.XY
		tag.BackgroundTransparency = 1
		tag.FontFace = Font.new("rbxassetid://12187365364")
		tag.Position = UDim2.new(0,12,0.5,-10)
		tag.Size = UDim2.fromOffset(1,1)
		tag.Text = lbl
		tag.TextColor3 = Color3.fromRGB(110,110,130)
		tag.TextSize = 12
		tag.Parent = comp

		local vl = Instance.new("TextLabel")
		vl.AnchorPoint = Vector2.new(1,0.5)
		vl.AutomaticSize = Enum.AutomaticSize.XY
		vl.BackgroundTransparency = 1
		vl.FontFace = Font.new("rbxassetid://12187365364")
		vl.Position = UDim2.new(1,-12,0.5,-10)
		vl.Size = UDim2.fromOffset(1,1)
		vl.Text = tostring(def)..sfx
		vl.TextColor3 = Color3.new(1,1,1)
		vl.TextSize = 12
		vl.Parent = comp

		local track = Instance.new("Frame")
		track.Active = true
		track.AnchorPoint = Vector2.new(0,0.5)
		track.BackgroundColor3 = COMP_BG
		track.Position = UDim2.new(0,12,0.5,10)
		track.Size = UDim2.new(1,-24,0,5)
		Instance.new("UICorner").Parent = track
		local ts = Instance.new("UIStroke")
		ts.Color = STROKE
		ts.Parent = track

		local fill = Instance.new("Frame")
		fill.AnchorPoint = Vector2.new(0,0.5)
		fill.BackgroundColor3 = ACCENT
		fill.Position = UDim2.fromScale(0,0.5)
		fill.Size = UDim2.new(0,0,0,7)
		Instance.new("UICorner").Parent = fill
		local fg = Instance.new("UIGradient")
		fg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,ACCENT),ColorSequenceKeypoint.new(1,ACCENT2)})
		fg.Parent = fill

		local ptr = Instance.new("Frame")
		ptr.AnchorPoint = Vector2.new(1,0.5)
		ptr.BackgroundColor3 = Color3.new(1,1,1)
		ptr.Position = UDim2.fromScale(1,0.5)
		ptr.Size = UDim2.fromOffset(10,10)
		Instance.new("UICorner").Parent = ptr

		local glow = Instance.new("Frame")
		glow.AnchorPoint = Vector2.new(0.5,0.5)
		glow.BackgroundColor3 = ACCENT
		glow.BackgroundTransparency = 0.7
		glow.Position = UDim2.fromScale(0.5,0.5)
		glow.Size = UDim2.fromOffset(18,18)
		Instance.new("UICorner").Parent = glow
		glow.Parent = ptr
		ptr.Parent = fill
		fill.Parent = track
		track.Parent = comp

		local function Set(v)
			if prec then
				v = math.floor(v/prec+0.5)*prec
			else
				v = math.round(v)
			end
			v = math.clamp(v,mn,mx)
			val = v
			local pct = (v-mn)/(mx-mn)
			Tween(fill,{Size=UDim2.new(pct,0,0,7)},0.05)
			vl.Text = tostring(v)..sfx
			cb(v)
			if flag then Cactus.Flags[flag] = v end
		end
		Set(def)

		local conn
		track.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				Tween(ptr,{Size=UDim2.fromOffset(13,13)},0.1)
				conn = RunService.Heartbeat:Connect(function()
					if not dragging then conn:Disconnect() return end
					local rel = (Mouse.X-track.AbsolutePosition.X)/track.AbsoluteSize.X
					Set(mn+(mx-mn)*rel)
				end)
			end
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
				dragging = false
				Tween(ptr,{Size=UDim2.fromOffset(10,10)},0.1)
				if conn then conn:Disconnect() end
			end
		end)

		local obj = {}
		function obj:Set(v) Set(v) end
		function obj:Get() return val end
		if flag then Cactus.Flags[flag] = val end
		return obj
	end

	function section:AddDropdown(opts)
		opts = opts or {}
		local lbl = opts.Name or "Dropdown"
		local items = opts.Items or {}
		local def = opts.Default
		local multi = opts.Multi or false
		local cb = opts.Callback or function() end
		local flag = opts.Flag
		local selected = multi and {} or def
		local open = false

		local comp = Instance.new("Frame")
		comp.AnchorPoint = Vector2.new(0.5,0)
		comp.BackgroundTransparency = 1
		comp.Position = UDim2.fromScale(0.5,0)
		comp.Size = UDim2.fromOffset(281,55)
		comp.ZIndex = 4
		comp.Parent = ch

		local tag = Instance.new("TextLabel")
		tag.AutomaticSize = Enum.AutomaticSize.XY
		tag.BackgroundTransparency = 1
		tag.FontFace = Font.new("rbxassetid://12187365364")
		tag.Position = UDim2.fromOffset(12,8)
		tag.Size = UDim2.fromOffset(1,1)
		tag.Text = lbl
		tag.TextColor3 = Color3.fromRGB(110,110,130)
		tag.TextSize = 12
		tag.Parent = comp

		local box = Instance.new("Frame")
		box.AnchorPoint = Vector2.new(0.5,1)
		box.BackgroundColor3 = COMP_BG
		box.ClipsDescendants = true
		box.Position = UDim2.new(0.5,0,1,0)
		box.Size = UDim2.fromOffset(257,22)
		Instance.new("UICorner").Parent = box
		local bStroke = Instance.new("UIStroke")
		bStroke.Color = STROKE
		bStroke.Parent = box
		box.Parent = comp

		local selLbl = Instance.new("TextLabel")
		selLbl.AnchorPoint = Vector2.new(0,0.5)
		selLbl.AutomaticSize = Enum.AutomaticSize.XY
		selLbl.BackgroundTransparency = 1
		selLbl.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium)
		selLbl.Position = UDim2.fromScale(0.025,0.5)
		selLbl.Size = UDim2.fromOffset(1,1)
		selLbl.Text = def or "Select..."
		selLbl.TextColor3 = Color3.fromRGB(190,190,210)
		selLbl.TextSize = 12
		selLbl.Parent = box

		local arr = Instance.new("TextLabel")
		arr.AnchorPoint = Vector2.new(1,0.5)
		arr.BackgroundTransparency = 1
		arr.FontFace = Font.new("rbxassetid://12187365364")
		arr.Position = UDim2.new(1,-8,0.5,0)
		arr.Size = UDim2.fromOffset(12,12)
		arr.Text = "▾"
		arr.TextColor3 = MUTED
		arr.TextSize = 12
		arr.Parent = box

		local drop = Instance.new("Frame")
		drop.AnchorPoint = Vector2.new(0.5,0)
		drop.BackgroundColor3 = Color3.fromRGB(20,21,28)
		drop.BorderSizePixel = 0
		drop.Position = UDim2.new(0.5,0,1,4)
		drop.Size = UDim2.fromOffset(257,0)
		drop.ClipsDescendants = true
		drop.ZIndex = 20
		Instance.new("UICorner").Parent = drop
		local ds = Instance.new("UIStroke")
		ds.Color = LINER
		ds.Parent = drop
		drop.Parent = box

		local dl = Instance.new("UIListLayout")
		dl.SortOrder = Enum.SortOrder.LayoutOrder
		dl.Padding = UDim.new(0,2)
		dl.Parent = drop

		local dp = Instance.new("UIPadding")
		dp.PaddingTop = UDim.new(0,4)
		dp.PaddingBottom = UDim.new(0,4)
		dp.Parent = drop

		local function UpdateSel()
			if multi then
				local keys = {}
				for k in pairs(selected) do table.insert(keys,k) end
				selLbl.Text = #keys>0 and table.concat(keys,", ") or "Select..."
			else
				selLbl.Text = selected or "Select..."
			end
		end

		local function Build()
			for _,c in ipairs(drop:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			for _,item in ipairs(items) do
				local ib = Instance.new("TextButton")
				ib.BackgroundColor3 = ACCENT
				ib.BackgroundTransparency = 1
				ib.Size = UDim2.new(1,0,0,26)
				ib.Text = ""
				ib.ZIndex = 25
				ib.Parent = drop

				local il2 = Instance.new("TextLabel")
				il2.AnchorPoint = Vector2.new(0,0.5)
				il2.BackgroundTransparency = 1
				il2.FontFace = Font.new("rbxassetid://12187365364")
				il2.Position = UDim2.fromOffset(10,0)
				il2.Size = UDim2.new(1,-10,1,0)
				il2.Text = item
				il2.TextColor3 = Color3.fromRGB(160,160,180)
				il2.TextSize = 12
				il2.TextXAlignment = Enum.TextXAlignment.Left
				il2.ZIndex = 25
				il2.Parent = ib

				local isSel = multi and selected[item] or selected==item
				if isSel then
					il2.TextColor3 = Color3.new(1,1,1)
					ib.BackgroundTransparency = 0.82
				end

				ib.MouseEnter:Connect(function() Tween(ib,{BackgroundTransparency=0.85},0.1) end)
				ib.MouseLeave:Connect(function()
					local s2 = multi and selected[item] or selected==item
					Tween(ib,{BackgroundTransparency=s2 and 0.82 or 1},0.1)
				end)
				ib.MouseButton1Click:Connect(function()
					if multi then
						selected[item] = not selected[item] or nil
					else
						selected = item
						open = false
						Tween(drop,{Size=UDim2.fromOffset(257,0)},0.2)
						Tween(arr,{Rotation=0},0.2)
						Tween(bStroke,{Color=STROKE},0.15)
					end
					UpdateSel()
					Build()
					local v = multi and (function() local t={} for k in pairs(selected) do table.insert(t,k) end return t end)() or selected
					cb(v)
					if flag then Cactus.Flags[flag] = v end
				end)
			end
		end
		Build()

		local hbtn = Instance.new("TextButton")
		hbtn.BackgroundTransparency = 1
		hbtn.Size = UDim2.fromScale(1,1)
		hbtn.Text = ""
		hbtn.ZIndex = 10
		hbtn.Parent = box

		hbtn.MouseButton1Click:Connect(function()
			open = not open
			local h2 = open and math.min(#items*28+8,160) or 0
			Tween(drop,{Size=UDim2.fromOffset(257,h2)},0.25,Enum.EasingStyle.Quart)
			Tween(arr,{Rotation=open and 180 or 0},0.2)
			Tween(bStroke,{Color=open and ACCENT or STROKE},0.15)
		end)

		UpdateSel()

		local obj = {}
		function obj:Set(v) selected=v; UpdateSel(); Build() end
		function obj:Get() return selected end
		function obj:SetItems(newItems) items=newItems; Build() end
		if flag then Cactus.Flags[flag] = selected end
		return obj
	end

	function section:AddButton(opts)
		opts = opts or {}
		local lbl = opts.Name or "Button"
		local cb = opts.Callback or function() end
		local color = opts.Color

		local comp = Instance.new("Frame")
		comp.AnchorPoint = Vector2.new(0.5,0)
		comp.BackgroundTransparency = 1
		comp.Position = UDim2.fromScale(0.5,0)
		comp.Size = UDim2.fromOffset(281,38)
		comp.Parent = ch

		local btn = Instance.new("TextButton")
		btn.AnchorPoint = Vector2.new(0.5,0.5)
		btn.ClipsDescendants = true
		btn.Position = UDim2.fromScale(0.5,0.5)
		btn.Size = UDim2.fromOffset(257,28)
		btn.Text = ""
		btn.ZIndex = 5
		Instance.new("UICorner").Parent = btn

		if color then
			btn.BackgroundColor3 = color
			btn.BackgroundTransparency = 0.91
			local cs2 = Instance.new("UIStroke")
			cs2.Color = color
			cs2.Transparency = 0.45
			cs2.Parent = btn
		else
			btn.BackgroundColor3 = COMP_BG
			btn.BackgroundTransparency = 0
			local cs2 = Instance.new("UIStroke")
			cs2.Color = STROKE
			cs2.Parent = btn
		end

		local btl = Instance.new("TextLabel")
		btl.AnchorPoint = Vector2.new(0.5,0.5)
		btl.AutomaticSize = Enum.AutomaticSize.XY
		btl.BackgroundTransparency = 1
		btl.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium)
		btl.Position = UDim2.fromScale(0.5,0.5)
		btl.Size = UDim2.fromOffset(1,1)
		btl.Text = lbl
		btl.TextColor3 = color or Color3.fromRGB(140,140,160)
		btl.TextSize = 13
		btl.Parent = btn

		btn.Parent = comp

		btn.MouseButton1Click:Connect(function()
			Ripple(btn,color)
			Tween(btl,{TextTransparency=0.5},0.08)
			task.delay(0.15,function() Tween(btl,{TextTransparency=0},0.1) end)
			cb()
		end)
		btn.MouseEnter:Connect(function()
			Tween(btn,{BackgroundTransparency=color and 0.82 or 0.15},0.12)
		end)
		btn.MouseLeave:Connect(function()
			Tween(btn,{BackgroundTransparency=color and 0.91 or 0},0.12)
		end)

		local obj = {}
		function obj:Rename(n) btl.Text = n end
		function obj:SetColor(c)
			color = c
			btn.BackgroundColor3 = c
			btl.TextColor3 = c
		end
		return obj
	end

	function section:AddKeybind(opts)
		opts = opts or {}
		local lbl = opts.Name or "Keybind"
		local def = opts.Default or Enum.KeyCode.Unknown
		local cb = opts.Callback or function() end
		local flag = opts.Flag
		local val = def
		local listening = false

		local comp = Instance.new("Frame")
		comp.AnchorPoint = Vector2.new(0.5,0)
		comp.BackgroundTransparency = 1
		comp.Position = UDim2.fromScale(0.5,0)
		comp.Size = UDim2.fromOffset(281,30)
		comp.Parent = ch

		local tag = Instance.new("TextLabel")
		tag.AnchorPoint = Vector2.new(0,0.5)
		tag.AutomaticSize = Enum.AutomaticSize.XY
		tag.BackgroundTransparency = 1
		tag.FontFace = Font.new("rbxassetid://12187365364")
		tag.Position = UDim2.new(0,12,0.5,0)
		tag.Size = UDim2.fromOffset(1,1)
		tag.Text = lbl
		tag.TextColor3 = Color3.new(1,1,1)
		tag.TextSize = 12
		tag.Parent = comp

		local kbf = Instance.new("TextButton")
		kbf.AnchorPoint = Vector2.new(1,0.5)
		kbf.AutomaticSize = Enum.AutomaticSize.X
		kbf.BackgroundColor3 = COMP_BG
		kbf.Position = UDim2.new(1,-12,0.5,0)
		kbf.Size = UDim2.fromOffset(0,20)
		kbf.Text = ""
		Instance.new("UICorner").Parent = kbf
		local ks = Instance.new("UIStroke")
		ks.Color = STROKE
		ks.Parent = kbf
		local kp = Instance.new("UIPadding")
		kp.PaddingLeft = UDim.new(0,7)
		kp.PaddingRight = UDim.new(0,7)
		kp.Parent = kbf

		local kl = Instance.new("TextLabel")
		kl.AutomaticSize = Enum.AutomaticSize.XY
		kl.BackgroundTransparency = 1
		kl.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.SemiBold)
		kl.Size = UDim2.fromOffset(1,1)
		kl.Text = def==Enum.KeyCode.Unknown and "NONE" or tostring(def):sub(14)
		kl.TextColor3 = Color3.new(1,1,1)
		kl.TextSize = 10
		kl.Parent = kbf

		kbf.Parent = comp

		kbf.MouseButton1Click:Connect(function()
			if listening then return end
			listening = true
			kl.Text = "..."
			Tween(kbf,{BackgroundColor3=Color3.fromRGB(38,38,58)},0.15)
			local conn
			conn = UserInputService.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.Keyboard then
					val = inp.KeyCode
					kl.Text = tostring(inp.KeyCode):sub(14)
					listening = false
					Tween(kbf,{BackgroundColor3=COMP_BG},0.15)
					conn:Disconnect()
					if flag then Cactus.Flags[flag] = val end
				end
			end)
		end)

		UserInputService.InputBegan:Connect(function(inp)
			if not listening and inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==val then
				cb(val)
			end
		end)

		local obj = {}
		function obj:Get() return val end
		function obj:Set(k) val=k; kl.Text=tostring(k):sub(14); if flag then Cactus.Flags[flag]=k end end
		if flag then Cactus.Flags[flag] = val end
		return obj
	end

	function section:AddColorPicker(opts)
		opts = opts or {}
		local lbl = opts.Name or "Color"
		local def = opts.Default or Color3.new(1,1,1)
		local cb = opts.Callback or function() end
		local flag = opts.Flag
		local ch2,cs2,cv2 = RGB2HSV(def.R,def.G,def.B)
		local cur = def
		local pickerOpen = false
		local svDrag, hueDrag = false, false

		local comp = Instance.new("Frame")
		comp.AnchorPoint = Vector2.new(0.5,0)
		comp.BackgroundTransparency = 1
		comp.ClipsDescendants = false
		comp.Position = UDim2.fromScale(0.5,0)
		comp.Size = UDim2.fromOffset(281,30)
		comp.ZIndex = 5
		comp.Parent = ch

		local tag = Instance.new("TextLabel")
		tag.AnchorPoint = Vector2.new(0,0.5)
		tag.AutomaticSize = Enum.AutomaticSize.XY
		tag.BackgroundTransparency = 1
		tag.FontFace = Font.new("rbxassetid://12187365364")
		tag.Position = UDim2.new(0,12,0.5,0)
		tag.Size = UDim2.fromOffset(1,1)
		tag.Text = lbl
		tag.TextColor3 = Color3.new(1,1,1)
		tag.TextSize = 12
		tag.Parent = comp

		local prev = Instance.new("TextButton")
		prev.AnchorPoint = Vector2.new(1,0.5)
		prev.BackgroundColor3 = def
		prev.Position = UDim2.new(1,-12,0.5,0)
		prev.Size = UDim2.fromOffset(26,16)
		prev.Text = ""
		local pvc = Instance.new("UICorner")
		pvc.CornerRadius = UDim.new(0,4)
		pvc.Parent = prev
		prev.Parent = comp

		local pf = Instance.new("Frame")
		pf.AnchorPoint = Vector2.new(1,0)
		pf.BackgroundColor3 = Color3.fromRGB(22,23,30)
		pf.BorderSizePixel = 0
		pf.Position = UDim2.new(1,0,1,6)
		pf.Size = UDim2.fromOffset(0,0)
		pf.ClipsDescendants = true
		pf.ZIndex = 30
		Instance.new("UICorner").Parent = pf
		local pfs = Instance.new("UIStroke")
		pfs.Color = Color3.fromRGB(40,40,60)
		pfs.Parent = pf
		pf.Parent = comp

		local svf = Instance.new("ImageLabel")
		svf.BackgroundColor3 = Color3.new(1,0,0)
		svf.Position = UDim2.fromOffset(8,8)
		svf.Size = UDim2.fromOffset(160,120)
		svf.Image = "rbxassetid://6020299385"
		svf.ZIndex = 31
		svf.Parent = pf

		local svBtn = Instance.new("TextButton")
		svBtn.BackgroundTransparency = 1
		svBtn.Size = UDim2.fromScale(1,1)
		svBtn.Text = ""
		svBtn.ZIndex = 32
		svBtn.Parent = svf

		local svH = Instance.new("Frame")
		svH.AnchorPoint = Vector2.new(0.5,0.5)
		svH.BackgroundColor3 = Color3.new(1,1,1)
		svH.Size = UDim2.fromOffset(12,12)
		svH.ZIndex = 33
		Instance.new("UICorner").Parent = svH
		svH.Parent = svf

		local hf = Instance.new("ImageLabel")
		hf.Position = UDim2.fromOffset(176,8)
		hf.Size = UDim2.fromOffset(16,120)
		hf.Image = "rbxassetid://6020299084"
		hf.ZIndex = 31
		hf.Parent = pf

		local hBtn = Instance.new("TextButton")
		hBtn.BackgroundTransparency = 1
		hBtn.Size = UDim2.fromScale(1,1)
		hBtn.Text = ""
		hBtn.ZIndex = 32
		hBtn.Parent = hf

		local hH = Instance.new("Frame")
		hH.AnchorPoint = Vector2.new(0.5,0.5)
		hH.BackgroundColor3 = Color3.new(1,1,1)
		hH.Size = UDim2.fromOffset(22,4)
		hH.ZIndex = 33
		Instance.new("UICorner").Parent = hH
		hH.Parent = hf

		local hex = Instance.new("TextBox")
		hex.AnchorPoint = Vector2.new(0.5,0)
		hex.BackgroundColor3 = Color3.fromRGB(28,29,38)
		hex.Position = UDim2.new(0.5,0,0,136)
		hex.Size = UDim2.fromOffset(184,24)
		hex.FontFace = Font.new("rbxassetid://12187365364")
		hex.Text = string.format("#%02X%02X%02X",math.floor(def.R*255),math.floor(def.G*255),math.floor(def.B*255))
		hex.TextColor3 = Color3.new(1,1,1)
		hex.TextSize = 11
		hex.ZIndex = 31
		hex.ClearTextOnFocus = false
		Instance.new("UICorner").Parent = hex
		hex.Parent = pf

		local function UpdateAll()
			local r,g,b = HSV(ch2,cs2,cv2)
			cur = Color3.new(r,g,b)
			prev.BackgroundColor3 = cur
			svf.BackgroundColor3 = Color3.fromHSV(ch2,1,1)
			svH.Position = UDim2.fromScale(cs2,1-cv2)
			hH.Position = UDim2.new(0.5,0,ch2,0)
			hex.Text = string.format("#%02X%02X%02X",math.floor(r*255),math.floor(g*255),math.floor(b*255))
			cb(cur)
			if flag then Cactus.Flags[flag] = cur end
		end
		UpdateAll()

		svBtn.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true end end)
		hBtn.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType==Enum.UserInputType.MouseButton1 then
				svDrag=false; hueDrag=false
			end
		end)
		RunService.Heartbeat:Connect(function()
			if svDrag then
				cs2 = math.clamp((Mouse.X-svf.AbsolutePosition.X)/svf.AbsoluteSize.X,0,1)
				cv2 = 1-math.clamp((Mouse.Y-svf.AbsolutePosition.Y)/svf.AbsoluteSize.Y,0,1)
				UpdateAll()
			end
			if hueDrag then
				ch2 = math.clamp((Mouse.Y-hf.AbsolutePosition.Y)/hf.AbsoluteSize.Y,0,1)
				UpdateAll()
			end
		end)
		hex.FocusLost:Connect(function()
			local hx = hex.Text:gsub("#","")
			if #hx==6 then
				local r=tonumber(hx:sub(1,2),16)
				local g=tonumber(hx:sub(3,4),16)
				local b=tonumber(hx:sub(5,6),16)
				if r and g and b then
					ch2,cs2,cv2 = RGB2HSV(r/255,g/255,b/255)
					UpdateAll()
				end
			end
		end)

		prev.MouseButton1Click:Connect(function()
			pickerOpen = not pickerOpen
			if pickerOpen then
				Tween(pf,{Size=UDim2.fromOffset(202,168)},0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
			else
				Tween(pf,{Size=UDim2.fromOffset(0,0)},0.2)
			end
		end)

		local obj = {}
		function obj:Set(c) ch2,cs2,cv2=RGB2HSV(c.R,c.G,c.B); UpdateAll() end
		function obj:Get() return cur end
		if flag then Cactus.Flags[flag] = cur end
		return obj
	end

	function section:AddTextBox(opts)
		opts = opts or {}
		local lbl = opts.Name or "Input"
		local ph = opts.Placeholder or "Enter text..."
		local def = opts.Default or ""
		local cb = opts.Callback or function() end
		local flag = opts.Flag

		local comp = Instance.new("Frame")
		comp.AnchorPoint = Vector2.new(0.5,0)
		comp.BackgroundTransparency = 1
		comp.Position = UDim2.fromScale(0.5,0)
		comp.Size = UDim2.fromOffset(281,50)
		comp.Parent = ch

		local tag = Instance.new("TextLabel")
		tag.AutomaticSize = Enum.AutomaticSize.XY
		tag.BackgroundTransparency = 1
		tag.FontFace = Font.new("rbxassetid://12187365364")
		tag.Position = UDim2.fromOffset(12,6)
		tag.Size = UDim2.fromOffset(1,1)
		tag.Text = lbl
		tag.TextColor3 = Color3.fromRGB(100,100,120)
		tag.TextSize = 11
		tag.Parent = comp

		local tbf = Instance.new("Frame")
		tbf.AnchorPoint = Vector2.new(0.5,1)
		tbf.BackgroundColor3 = COMP_BG
		tbf.Position = UDim2.new(0.5,0,1,-4)
		tbf.Size = UDim2.fromOffset(257,24)
		Instance.new("UICorner").Parent = tbf
		local tbs = Instance.new("UIStroke")
		tbs.Color = STROKE
		tbs.Parent = tbf
		local tbp = Instance.new("UIPadding")
		tbp.PaddingLeft = UDim.new(0,8)
		tbp.PaddingRight = UDim.new(0,8)
		tbp.Parent = tbf
		tbf.Parent = comp

		local tb = Instance.new("TextBox")
		tb.AnchorPoint = Vector2.new(0,0.5)
		tb.BackgroundTransparency = 1
		tb.FontFace = Font.new("rbxassetid://12187365364")
		tb.PlaceholderColor3 = Color3.fromRGB(55,55,75)
		tb.PlaceholderText = ph
		tb.Position = UDim2.fromScale(0,0.5)
		tb.Size = UDim2.fromScale(1,1)
		tb.Text = def
		tb.TextColor3 = Color3.new(1,1,1)
		tb.TextSize = 12
		tb.TextXAlignment = Enum.TextXAlignment.Left
		tb.ClearTextOnFocus = false
		tb.Parent = tbf

		tb.Focused:Connect(function() Tween(tbs,{Color=ACCENT},0.15) end)
		tb.FocusLost:Connect(function()
			Tween(tbs,{Color=STROKE},0.15)
			cb(tb.Text)
			if flag then Cactus.Flags[flag] = tb.Text end
		end)

		local obj = {}
		function obj:Set(v) tb.Text=v end
		function obj:Get() return tb.Text end
		if flag then Cactus.Flags[flag] = tb.Text end
		return obj
	end

	function section:AddLabel(opts)
		opts = opts or {}
		local comp = Instance.new("Frame")
		comp.AnchorPoint = Vector2.new(0.5,0)
		comp.BackgroundTransparency = 1
		comp.Position = UDim2.fromScale(0.5,0)
		comp.Size = UDim2.fromOffset(281,0)
		comp.AutomaticSize = Enum.AutomaticSize.Y
		comp.Parent = ch

		local lbl = Instance.new("TextLabel")
		lbl.AnchorPoint = Vector2.new(0,0)
		lbl.AutomaticSize = Enum.AutomaticSize.Y
		lbl.BackgroundTransparency = 1
		lbl.FontFace = Font.new("rbxassetid://12187365364")
		lbl.Position = UDim2.fromOffset(12,6)
		lbl.Size = UDim2.new(1,-24,0,1)
		lbl.Text = opts.Text or ""
		lbl.TextColor3 = Color3.fromRGB(110,110,130)
		lbl.TextSize = 12
		lbl.TextWrapped = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.RichText = true
		lbl.Parent = comp

		local obj = {}
		function obj:Set(t) lbl.Text = t end
		return obj
	end

	function section:AddSeparator()
		local sep = Instance.new("Frame")
		sep.AnchorPoint = Vector2.new(0.5,0)
		sep.BackgroundColor3 = LINER
		sep.BorderSizePixel = 0
		sep.Position = UDim2.fromScale(0.5,0)
		sep.Size = UDim2.fromOffset(249,1)
		sep.Parent = ch
	end

	return section
end

local Library = {}
Library.__index = Library

function Cactus.CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "Cactus"
	local subtitle = opts.Subtitle or ""

	local self = setmetatable({},Library)
	self._tabs = {}
	self._activeTab = nil
	self._open = true

	local sg = Instance.new("ScreenGui")
	sg.Name = "CactusUI"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 100
	pcall(function() sg.Parent = CoreGui end)
	if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end
	self._gui = sg

	local mf = Instance.new("Frame")
	mf.Name = "Main"
	mf.AnchorPoint = Vector2.new(0.5,0.5)
	mf.BackgroundColor3 = BG
	mf.ClipsDescendants = true
	mf.Position = UDim2.fromScale(0.5,0.5)
	mf.Size = UDim2.fromOffset(0,0)
	mf.Parent = sg
	Instance.new("UICorner").Parent = mf
	self._mf = mf

	local hdr = Instance.new("Frame")
	hdr.Name = "Header"
	hdr.AnchorPoint = Vector2.new(0.5,0)
	hdr.BackgroundTransparency = 1
	hdr.Position = UDim2.fromScale(0.5,0)
	hdr.Size = UDim2.fromOffset(695,37)
	hdr.Parent = mf

	local hl = Instance.new("Frame")
	hl.AnchorPoint = Vector2.new(0,1)
	hl.BackgroundColor3 = LINER
	hl.BorderSizePixel = 0
	hl.Position = UDim2.fromScale(0,1)
	hl.Size = UDim2.new(1,1,0,1)
	hl.Parent = hdr

	local logo = Instance.new("TextLabel")
	logo.AnchorPoint = Vector2.new(0,0.5)
	logo.AutomaticSize = Enum.AutomaticSize.XY
	logo.BackgroundTransparency = 1
	logo.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.SemiBold)
	logo.Position = UDim2.new(0,14,0.5,0)
	logo.Size = UDim2.fromOffset(1,1)
	logo.RichText = true
	logo.Text = title..(subtitle~="" and string.format(' <font color="#45475a">%s</font>',subtitle) or "")
	logo.TextColor3 = Color3.new(1,1,1)
	logo.TextSize = 14
	logo.Parent = hdr

	local function MakeWinBtn(offsetX, col)
		local b = Instance.new("TextButton")
		b.AnchorPoint = Vector2.new(1,0.5)
		b.BackgroundColor3 = col
		b.BackgroundTransparency = 0.6
		b.Position = UDim2.new(1,offsetX,0.5,0)
		b.Size = UDim2.fromOffset(14,14)
		b.Text = ""
		b.ZIndex = 10
		local bc2 = Instance.new("UICorner")
		bc2.CornerRadius = UDim.new(1,0)
		bc2.Parent = b
		b.MouseEnter:Connect(function() Tween(b,{BackgroundTransparency=0.2},0.1) end)
		b.MouseLeave:Connect(function() Tween(b,{BackgroundTransparency=0.6},0.1) end)
		b.Parent = hdr
		return b
	end

	local closeBtn = MakeWinBtn(-10, Color3.fromRGB(210,70,70))
	local minBtn = MakeWinBtn(-30, Color3.fromRGB(220,170,40))

	local sidebar = Instance.new("Frame")
	sidebar.AnchorPoint = Vector2.new(0,1)
	sidebar.BackgroundTransparency = 1
	sidebar.Position = UDim2.fromScale(0,1)
	sidebar.Size = UDim2.fromOffset(75,452)
	sidebar.Parent = mf

	local sl = Instance.new("Frame")
	sl.AnchorPoint = Vector2.new(1,0.5)
	sl.BackgroundColor3 = LINER
	sl.BorderSizePixel = 0
	sl.Position = UDim2.fromScale(1,0.5)
	sl.Size = UDim2.new(0,1,1,0)
	sl.Parent = sidebar

	local tabHolder = Instance.new("Frame")
	tabHolder.Name = "TH"
	tabHolder.AnchorPoint = Vector2.new(0.5,0.5)
	tabHolder.BackgroundTransparency = 1
	tabHolder.Position = UDim2.fromScale(0.5,0.5)
	tabHolder.Size = UDim2.fromOffset(75,452)
	tabHolder.Parent = sidebar
	self._tabHolder = tabHolder

	local tl2 = Instance.new("UIListLayout")
	tl2.Padding = UDim.new(0,5)
	tl2.SortOrder = Enum.SortOrder.LayoutOrder
	tl2.Parent = tabHolder

	local tp = Instance.new("UIPadding")
	tp.PaddingLeft = UDim.new(0,9)
	tp.PaddingTop = UDim.new(0,10)
	tp.Parent = tabHolder

	local subHdr = Instance.new("Frame")
	subHdr.Name = "SubHdr"
	subHdr.AnchorPoint = Vector2.new(0.5,0.5)
	subHdr.BackgroundTransparency = 1
	subHdr.Position = UDim2.fromScale(0.554,0.128)
	subHdr.Size = UDim2.fromOffset(621,51)
	subHdr.Parent = mf
	self._subHdr = subHdr

	local shl = Instance.new("UIListLayout")
	shl.FillDirection = Enum.FillDirection.Horizontal
	shl.Padding = UDim.new(0,8)
	shl.SortOrder = Enum.SortOrder.LayoutOrder
	shl.Parent = subHdr

	local shp = Instance.new("UIPadding")
	shp.PaddingLeft = UDim.new(0,25)
	shp.PaddingTop = UDim.new(0,4)
	shp.Parent = subHdr

	local pageArea = Instance.new("Frame")
	pageArea.Name = "PageArea"
	pageArea.AnchorPoint = Vector2.new(1,1)
	pageArea.BackgroundColor3 = BG3
	pageArea.ClipsDescendants = true
	pageArea.Position = UDim2.fromScale(1,1)
	pageArea.Size = UDim2.fromOffset(620,401)
	Instance.new("UICorner").Parent = pageArea
	pageArea.Parent = mf
	self._pageArea = pageArea

	Drag(mf, hdr)

	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		Tween(mf, {Size = minimized and UDim2.fromOffset(695,37) or UDim2.fromOffset(695,489)}, 0.3)
	end)

	closeBtn.MouseButton1Click:Connect(function()
		self:Close()
	end)

	UserInputService.InputBegan:Connect(function(inp)
		if inp.KeyCode == Enum.KeyCode.RightShift then
			if self._open then self:Close() else self:Open() end
		end
	end)

	task.defer(function()
		Tween(mf,{Size=UDim2.fromOffset(695,489)},0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
	end)

	return self
end

function Library:Close()
	self._open = false
	Tween(self._mf,{Size=UDim2.fromOffset(0,0)},0.35,Enum.EasingStyle.Back,Enum.EasingDirection.In)
end

function Library:Open()
	self._open = true
	Tween(self._mf,{Size=UDim2.fromOffset(695,489)},0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end

function Library:Destroy()
	self._gui:Destroy()
end

function Library:AddTab(opts)
	opts = opts or {}
	local name = opts.Name or "Tab"
	local icon = opts.Icon or "rbxassetid://80869096876893"
	local self2 = self

	local tab = {}
	tab._subTabs = {}
	tab._activeSubTab = nil

	local tf = Instance.new("Frame")
	tf.Name = "Tab_"..name
	tf.BackgroundTransparency = 1
	tf.ClipsDescendants = true
	tf.Size = UDim2.fromOffset(55,60)
	Instance.new("UICorner").Parent = tf
	tf.Parent = self._tabHolder

	local ti = Instance.new("ImageLabel")
	ti.AnchorPoint = Vector2.new(0.5,0.5)
	ti.BackgroundTransparency = 1
	ti.Image = icon
	ti.ImageColor3 = MUTED
	ti.Position = UDim2.new(0.5,0,0.5,-8)
	ti.Size = UDim2.fromOffset(22,22)
	ti.Parent = tf

	local tl3 = Instance.new("TextLabel")
	tl3.AnchorPoint = Vector2.new(0.5,0.5)
	tl3.AutomaticSize = Enum.AutomaticSize.XY
	tl3.BackgroundTransparency = 1
	tl3.FontFace = Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold)
	tl3.Position = UDim2.new(0.5,0,0.5,20)
	tl3.Size = UDim2.fromOffset(1,1)
	tl3.Text = name
	tl3.TextColor3 = MUTED
	tl3.TextSize = 11
	tl3.Parent = tf

	local ind = Instance.new("Frame")
	ind.AnchorPoint = Vector2.new(0.5,1)
	ind.BackgroundColor3 = ACCENT
	ind.Position = UDim2.new(0.5,0,1,4)
	ind.Size = UDim2.fromOffset(0,4)
	local ic = Instance.new("UICorner")
	ic.CornerRadius = UDim.new(0,12)
	ic.Parent = ind
	local ig = Instance.new("UIGradient")
	ig.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,ACCENT),ColorSequenceKeypoint.new(1,ACCENT2)})
	ig.Parent = ind
	ind.Parent = tf

	local subHdrFrame = Instance.new("Frame")
	subHdrFrame.BackgroundTransparency = 1
	subHdrFrame.Size = UDim2.fromScale(1,1)
	subHdrFrame.Visible = false
	subHdrFrame.Parent = self._subHdr
	tab._subHdrFrame = subHdrFrame

	local subHdrLayout = Instance.new("UIListLayout")
	subHdrLayout.FillDirection = Enum.FillDirection.Horizontal
	subHdrLayout.Padding = UDim.new(0,8)
	subHdrLayout.SortOrder = Enum.SortOrder.LayoutOrder
	subHdrLayout.Parent = subHdrFrame

	local pageFrame = Instance.new("Frame")
	pageFrame.BackgroundTransparency = 1
	pageFrame.Size = UDim2.fromScale(1,1)
	pageFrame.Visible = false
	pageFrame.ClipsDescendants = true
	pageFrame.Parent = self._pageArea
	tab._pageFrame = pageFrame

	local function SetActive(active)
		if active then
			tf.BackgroundColor3 = Color3.fromRGB(240,240,255)
			Tween(tf,{BackgroundTransparency=0.91},0.2)
			Tween(ti,{ImageColor3=Color3.new(1,1,1)},0.2)
			Tween(tl3,{TextColor3=Color3.new(1,1,1)},0.2)
			Tween(ind,{Size=UDim2.fromOffset(30,4)},0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
		else
			Tween(tf,{BackgroundTransparency=1},0.2)
			Tween(ti,{ImageColor3=MUTED},0.2)
			Tween(tl3,{TextColor3=MUTED},0.2)
			Tween(ind,{Size=UDim2.fromOffset(0,4)},0.2)
		end
	end
	tab._setActive = SetActive

	local tbtn = Instance.new("TextButton")
	tbtn.BackgroundTransparency = 1
	tbtn.Size = UDim2.fromScale(1,1)
	tbtn.Text = ""
	tbtn.ZIndex = 5
	tbtn.Parent = tf

	tbtn.MouseButton1Click:Connect(function()
		Ripple(tf)
		if self2._activeTab == tab then return end
		if self2._activeTab then
			self2._activeTab._setActive(false)
			local pp = self2._activeTab._pageFrame
			local ps = self2._activeTab._subHdrFrame
			Tween(pp,{Position=UDim2.fromOffset(-25,0)},0.22)
			task.delay(0.22,function() pp.Visible=false; pp.Position=UDim2.fromOffset(0,0) end)
			ps.Visible = false
		end
		self2._activeTab = tab
		SetActive(true)
		pageFrame.Position = UDim2.fromOffset(25,0)
		pageFrame.Visible = true
		subHdrFrame.Visible = true
		Tween(pageFrame,{Position=UDim2.fromOffset(0,0)},0.22)
	end)

	table.insert(self._tabs, tab)
	if #self._tabs == 1 then
		task.defer(function()
			self._activeTab = tab
			SetActive(true)
			pageFrame.Visible = true
			subHdrFrame.Visible = true
		end)
	end

	function tab:AddSection(sopts)
		sopts = sopts or {}
		local sc = Instance.new("ScrollingFrame")
		sc.Active = true
		sc.BackgroundTransparency = 1
		sc.Size = UDim2.fromScale(1,1)
		sc.ScrollBarThickness = 1
		sc.ScrollBarImageColor3 = Color3.new()
		sc.CanvasSize = UDim2.fromOffset(0,0)
		sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
		sc.Parent = pageFrame

		local scl = Instance.new("UIListLayout")
		scl.FillDirection = Enum.FillDirection.Horizontal
		scl.Padding = UDim.new(0,20)
		scl.SortOrder = Enum.SortOrder.LayoutOrder
		scl.VerticalAlignment = Enum.VerticalAlignment.Top
		scl.Parent = sc

		local scp = Instance.new("UIPadding")
		scp.PaddingLeft = UDim.new(0,12)
		scp.PaddingTop = UDim.new(0,12)
		scp.Parent = sc

		return MakeSection(sc, sopts.Name or "Section")
	end

	function tab:AddSubTab(stName)
		local subTab = {}
		subTab._sections = {}

		local stf = Instance.new("Frame")
		stf.AutomaticSize = Enum.AutomaticSize.X
		stf.BackgroundTransparency = 1
		stf.Size = UDim2.fromOffset(0,49)
		stf.Parent = subHdrFrame

		local stl = Instance.new("TextLabel")
		stl.AnchorPoint = Vector2.new(0.5,0.5)
		stl.AutomaticSize = Enum.AutomaticSize.XY
		stl.BackgroundTransparency = 1
		stl.FontFace = Font.new("rbxassetid://12187365364")
		stl.Position = UDim2.new(0.5,0,0.5,-3)
		stl.Size = UDim2.fromOffset(1,1)
		stl.Text = stName
		stl.TextColor3 = MUTED
		stl.TextSize = 13
		stl.TextTransparency = 0.15
		Instance.new("UICorner").Parent = stl
		local stlp = Instance.new("UIPadding")
		stlp.PaddingBottom = UDim.new(0,10)
		stlp.PaddingLeft = UDim.new(0,8)
		stlp.PaddingRight = UDim.new(0,8)
		stlp.PaddingTop = UDim.new(0,10)
		stlp.Parent = stl
		stl.Parent = stf

		local stind = Instance.new("Frame")
		stind.AnchorPoint = Vector2.new(0.5,1)
		stind.BackgroundColor3 = ACCENT
		stind.Position = UDim2.new(0.5,0,1,4)
		stind.Size = UDim2.fromOffset(0,4)
		local stic = Instance.new("UICorner")
		stic.CornerRadius = UDim.new(0,12)
		stic.Parent = stind
		stind.Parent = stf

		local stPage = Instance.new("Frame")
		stPage.BackgroundTransparency = 1
		stPage.Size = UDim2.fromScale(1,1)
		stPage.Visible = false
		stPage.ClipsDescendants = true
		stPage.Parent = pageFrame
		subTab._pageFrame = stPage

		local stScroll = Instance.new("ScrollingFrame")
		stScroll.Active = true
		stScroll.BackgroundTransparency = 1
		stScroll.Size = UDim2.fromScale(1,1)
		stScroll.ScrollBarThickness = 1
		stScroll.ScrollBarImageColor3 = Color3.new()
		stScroll.CanvasSize = UDim2.fromOffset(0,0)
		stScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		stScroll.Parent = stPage
		subTab._scroll = stScroll

		local stsl = Instance.new("UIListLayout")
		stsl.FillDirection = Enum.FillDirection.Horizontal
		stsl.Padding = UDim.new(0,20)
		stsl.SortOrder = Enum.SortOrder.LayoutOrder
		stsl.VerticalAlignment = Enum.VerticalAlignment.Top
		stsl.Parent = stScroll

		local stsp = Instance.new("UIPadding")
		stsp.PaddingLeft = UDim.new(0,12)
		stsp.PaddingTop = UDim.new(0,12)
		stsp.Parent = stScroll

		local function SetSubActive(active)
			if active then
				stl.BackgroundColor3 = ACCENT
				Tween(stl,{TextColor3=Color3.new(1,1,1),BackgroundTransparency=0.88},0.2)
				task.defer(function()
					Tween(stind,{Size=UDim2.fromOffset(stl.AbsoluteSize.X,4)},0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
				end)
			else
				Tween(stl,{TextColor3=MUTED,BackgroundTransparency=1},0.2)
				Tween(stind,{Size=UDim2.fromOffset(0,4)},0.2)
			end
		end
		subTab._setActive = SetSubActive

		local stbtn = Instance.new("TextButton")
		stbtn.BackgroundTransparency = 1
		stbtn.Size = UDim2.fromScale(1,1)
		stbtn.Text = ""
		stbtn.ZIndex = 5
		stbtn.Parent = stf

		stbtn.MouseButton1Click:Connect(function()
			if tab._activeSubTab == subTab then return end
			if tab._activeSubTab then
				tab._activeSubTab._setActive(false)
				local pp2 = tab._activeSubTab._pageFrame
				Tween(pp2,{Position=UDim2.fromOffset(-18,0)},0.18)
				task.delay(0.18,function() pp2.Visible=false; pp2.Position=UDim2.fromOffset(0,0) end)
			end
			tab._activeSubTab = subTab
			SetSubActive(true)
			stPage.Position = UDim2.fromOffset(18,0)
			stPage.Visible = true
			Tween(stPage,{Position=UDim2.fromOffset(0,0)},0.18)
		end)

		table.insert(tab._subTabs, subTab)
		if #tab._subTabs == 1 then
			task.defer(function()
				tab._activeSubTab = subTab
				SetSubActive(true)
				stPage.Visible = true
			end)
		end

		function subTab:AddSection(sopts)
			sopts = sopts or {}
			return MakeSection(stScroll, sopts.Name or "Section")
		end

		return subTab
	end

	return tab
end

return Cactus
