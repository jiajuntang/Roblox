local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local origBright = Lighting.Brightness
local origFogEnd = Lighting.FogEnd
local origFogColor = Lighting.FogColor
local origAmbient = Lighting.Ambient

local WEATHER_INTERVAL = 60
local WEATHER_DURATION = 120
local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50
local TALK_INTERVAL = 2
local penguins = {}

local penguinSayings = {
    "My name is Guin Guin, also known as Marky Penguin!",
    "YI WU!",
    "Am I adopted?",
    "I am hungry...",
    "plssss fishhhh",
    "Do you like me?",
    "1+1=67.",
    "OI think my moms kinda homeless",
    "I think i am kinda homelesss",
    "I think that my fish is kinda penguinless",
    "yes = no and no = yes",
    "WHAT ARE YOU",
    "Can i eat you?",
    "I like ROTTEN FISH",
    "My favourite colour is totally penguin",
    "PLSSSS i need fish i think i am kinda penguinlesss",
    "I am not penguining",
    "My brain isnt braining",
    "HIIIIIIIIIIIIIIIIIIII",
    "Wait a minute, Who are you?????",
}

local jealousSayings = {
    {weight = 20, text = "did you see that so perfect right?"},
    {weight = 40, text = "i took 10 years to learn this"},
    {weight = 30, text = "i totally got this"},
    {weight = 10, text = "its so perfect"},
}

local glitchySayings = {
    {weight = 50, text = "i am tottally okay"},
    {weight = 50, text = "say i not malfunctioning"},
}

local function weightedPick(choices)
    local total = 0
    for _,c in pairs(choices) do total = total + c.weight end
    local roll = math.random(1, total)
    local acc = 0
    for _,c in pairs(choices) do
        acc = acc + c.weight
        if roll <= acc then return c.text end
    end
    return choices[1].text
end

local function announce(msg)
    for _,p in pairs(Players:GetPlayers()) do
        local hint = Instance.new("Hint")
        hint.Text = msg
        local pg = p:FindFirstChild("PlayerGui")
        if pg then
            hint.Parent = pg
            task.delay(5, function()
                if hint and hint.Parent then hint:Destroy() end
            end)
        end
    end
end

local function setAllStats(speed, jump)
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local hum = ch:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = speed
                hum.JumpPower = jump
            end
        end
    end
end

local function clearPenguins()
    for _,pen in pairs(penguins) do
        if pen and pen.Parent then pen:Destroy() end
    end
    penguins = {}
end

local function resetWeather()
    Lighting.Brightness = origBright
    Lighting.FogEnd = origFogEnd
    Lighting.FogColor = origFogColor
    Lighting.Ambient = origAmbient
    setAllStats(DEFAULT_SPEED, DEFAULT_JUMP)
    clearPenguins()
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local sword = ch:FindFirstChild("Weather Sword")
            if sword then sword:Destroy() end
        end
        local bp = p:FindFirstChild("Backpack")
        if bp then
            local sword = bp:FindFirstChild("Weather Sword")
            if sword then sword:Destroy() end
        end
    end
    announce("The weather has cleared!")
end

local function sonicMode()
    announce("SONIC MODE! Speed +20% Jump +10%!")
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(200, 200, 255)
    setAllStats(DEFAULT_SPEED * 1.2, DEFAULT_JUMP * 1.1)
end

local function hackerEvent()
    announce("HACKER EVENT! Speed +20% Jump +40%!")
    Lighting.Brightness = 0.8
    Lighting.Ambient = Color3.fromRGB(0, 255, 0)
    Lighting.FogEnd = 500
    Lighting.FogColor = Color3.fromRGB(0, 50, 0)
    setAllStats(DEFAULT_SPEED * 1.2, DEFAULT_JUMP * 1.4)
end

local function snowStorm()
    announce("SNOW STORM! Speed -25% Jump -5%!")
    Lighting.FogEnd = 100
    Lighting.FogColor = Color3.fromRGB(220, 220, 235)
    Lighting.Brightness = 1.5
    Lighting.Ambient = Color3.fromRGB(180, 180, 200)
    setAllStats(DEFAULT_SPEED * 0.75, DEFAULT_JUMP * 0.95)
end

local function sandStorm()
    announce("SAND STORM! Visibility reduced!")
    Lighting.FogEnd = 80
    Lighting.FogColor = Color3.fromRGB(194, 178, 128)
    Lighting.Brightness = 1.2
    Lighting.Ambient = Color3.fromRGB(180, 160, 120)
    setAllStats(DEFAULT_SPEED, DEFAULT_JUMP)
end

local function penguinTalk(pen, role)
    local head = pen:FindFirstChild("Head")
    if not head then
        head = pen:FindFirstChild("HumanoidRootPart")
    end
    if not head then return end

    local msg
    if role == "jealous" then
        msg = weightedPick(jealousSayings)
    elseif role == "glitchy" then
        msg = weightedPick(glitchySayings)
    else
        msg = penguinSayings[math.random(1, #penguinSayings)]
    end

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.Adornee = head
    bill.Parent = head
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 0.3
    label.Text = msg
    label.TextColor3 = Color3.fromRGB(0, 0, 0)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.Parent = bill
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)
    task.delay(3, function()
        if bill and bill.Parent then bill:Destroy() end
    end)
end

local function findNearestPlayer(pos)
    local best = nil
    local bestDist = 999999
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local root = ch:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (root.Position - pos).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = root
                end
            end
        end
    end
    return best, bestDist
end

local function spawnPenguin(pos, role)
    role = role or "normal"
    local pen = Instance.new("Model")
    pen.Name = "Penguin"
    pen:SetAttribute("Role", role)

    -- Body (black rectangle, acts as HumanoidRootPart)
    local body = Instance.new("Part")
    body.Name = "HumanoidRootPart"
    body.Size = Vector3.new(2.5, 3.5, 1.8)
    body.BrickColor = BrickColor.new("Really black")
    body.Material = Enum.Material.SmoothPlastic
    body.Position = pos
    body.Anchored = false
    body.Parent = pen

    -- White belly (front)
    local belly = Instance.new("Part")
    belly.Name = "Belly"
    belly.Size = Vector3.new(2, 2.8, 0.3)
    belly.BrickColor = BrickColor.new("White")
    belly.Material = Enum.Material.SmoothPlastic
    belly.Anchored = false
    belly.Parent = pen

    local bWeld = Instance.new("Weld")
    bWeld.Part0 = body
    bWeld.Part1 = belly
    bWeld.C0 = CFrame.new(0, -0.1, 0.75)
    bWeld.Parent = belly

    -- Head (black square)
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 2, 2)
    head.BrickColor = BrickColor.new("Really black")
    head.Material = Enum.Material.SmoothPlastic
    head.Anchored = false
    head.Parent = pen

    local hWeld = Instance.new("Weld")
    hWeld.Part0 = body
    hWeld.Part1 = head
    hWeld.C0 = CFrame.new(0, 2.5, 0)
    hWeld.Parent = head

    -- Left eye (small black)
    local leftEye = Instance.new("Part")
    leftEye.Name = "LeftEye"
    leftEye.Size = Vector3.new(0.3, 0.3, 0.3)
    leftEye.BrickColor = BrickColor.new("Really black")
    leftEye.Material = Enum.Material.Metal
    leftEye.Anchored = false
    leftEye.Parent = pen

    local leWeld = Instance.new("Weld")
    leWeld.Part0 = head
    leWeld.Part1 = leftEye
    leWeld.C0 = CFrame.new(-0.45, 0.2, 1.05)
    leWeld.Parent = leftEye

    -- Right eye (small black)
    local rightEye = Instance.new("Part")
    rightEye.Name = "RightEye"
    rightEye.Size = Vector3.new(0.3, 0.3, 0.3)
    rightEye.BrickColor = BrickColor.new("Really black")
    rightEye.Material = Enum.Material.Metal
    rightEye.Anchored = false
    rightEye.Parent = pen

    local reWeld = Instance.new("Weld")
    reWeld.Part0 = head
    reWeld.Part1 = rightEye
    reWeld.C0 = CFrame.new(0.45, 0.2, 1.05)
    reWeld.Parent = rightEye

    -- Beak (yellow)
    local beak = Instance.new("Part")
    beak.Name = "Beak"
    beak.Size = Vector3.new(0.7, 0.35, 0.5)
    beak.BrickColor = BrickColor.new("New Yeller")
    beak.Material = Enum.Material.SmoothPlastic
    beak.Anchored = false
    beak.Parent = pen

    local beakWeld = Instance.new("Weld")
    beakWeld.Part0 = head
    beakWeld.Part1 = beak
    beakWeld.C0 = CFrame.new(0, -0.3, 1.2)
    beakWeld.Parent = beak

    -- Left arm (short black)
    local leftArm = Instance.new("Part")
    leftArm.Name = "LeftArm"
    leftArm.Size = Vector3.new(0.4, 1.5, 0.8)
    leftArm.BrickColor = BrickColor.new("Really black")
    leftArm.Material = Enum.Material.SmoothPlastic
    leftArm.Anchored = false
    leftArm.Parent = pen

    local laWeld = Instance.new("Weld")
    laWeld.Part0 = body
    laWeld.Part1 = leftArm
    laWeld.C0 = CFrame.new(-1.45, 0.3, 0)
    laWeld.Parent = leftArm

    -- Right arm (short black)
    local rightArm = Instance.new("Part")
    rightArm.Name = "RightArm"
    rightArm.Size = Vector3.new(0.4, 1.5, 0.8)
    rightArm.BrickColor = BrickColor.new("Really black")
    rightArm.Material = Enum.Material.SmoothPlastic
    rightArm.Anchored = false
    rightArm.Parent = pen

    local raWeld = Instance.new("Weld")
    raWeld.Part0 = body
    raWeld.Part1 = rightArm
    raWeld.C0 = CFrame.new(1.45, 0.3, 0)
    raWeld.Parent = rightArm

    -- Left leg (short black)
    local leftLeg = Instance.new("Part")
    leftLeg.Name = "LeftLeg"
    leftLeg.Size = Vector3.new(0.5, 1, 0.8)
    leftLeg.BrickColor = BrickColor.new("Really black")
    leftLeg.Material = Enum.Material.SmoothPlastic
    leftLeg.Anchored = false
    leftLeg.Parent = pen

    local llWeld = Instance.new("Weld")
    llWeld.Part0 = body
    llWeld.Part1 = leftLeg
    llWeld.C0 = CFrame.new(-0.55, -2.25, 0)
    llWeld.Parent = leftLeg

    -- Right leg (short black)
    local rightLeg = Instance.new("Part")
    rightLeg.Name = "RightLeg"
    rightLeg.Size = Vector3.new(0.5, 1, 0.8)
    rightLeg.BrickColor = BrickColor.new("Really black")
    rightLeg.Material = Enum.Material.SmoothPlastic
    rightLeg.Anchored = false
    rightLeg.Parent = pen

    local rlWeld = Instance.new("Weld")
    rlWeld.Part0 = body
    rlWeld.Part1 = rightLeg
    rlWeld.C0 = CFrame.new(0.55, -2.25, 0)
    rlWeld.Parent = rightLeg

    -- Left foot (yellow)
    local leftFoot = Instance.new("Part")
    leftFoot.Name = "LeftFoot"
    leftFoot.Size = Vector3.new(0.7, 0.3, 1.1)
    leftFoot.BrickColor = BrickColor.new("New Yeller")
    leftFoot.Material = Enum.Material.SmoothPlastic
    leftFoot.Anchored = false
    leftFoot.Parent = pen

    local lfWeld = Instance.new("Weld")
    lfWeld.Part0 = leftLeg
    lfWeld.Part1 = leftFoot
    lfWeld.C0 = CFrame.new(0, -0.65, 0.2)
    lfWeld.Parent = leftFoot

    -- Right foot (yellow)
    local rightFoot = Instance.new("Part")
    rightFoot.Name = "RightFoot"
    rightFoot.Size = Vector3.new(0.7, 0.3, 1.1)
    rightFoot.BrickColor = BrickColor.new("New Yeller")
    rightFoot.Material = Enum.Material.SmoothPlastic
    rightFoot.Anchored = false
    rightFoot.Parent = pen

    local rfWeld = Instance.new("Weld")
    rfWeld.Part0 = rightLeg
    rfWeld.Part1 = rightFoot
    rfWeld.C0 = CFrame.new(0, -0.65, 0.2)
    rfWeld.Parent = rightFoot

    -- Humanoid
    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 100
    hum.Health = 100
    hum.WalkSpeed = 10
    hum.JumpPower = 50
    hum.Parent = pen

    pen.PrimaryPart = body
    pen.Parent = workspace
    table.insert(penguins, pen)

    -- Movement AI (skips while PlatformStand is active so stunts can play out)
    task.spawn(function()
        while pen and pen.Parent and hum.Health > 0 do
            local pRoot = pen:FindFirstChild("HumanoidRootPart")
            if not pRoot then break end
            if hum.PlatformStand then
                task.wait(0.5)
            else
                local nearestRoot, dist = findNearestPlayer(pRoot.Position)
                if nearestRoot then
                    if dist > 100 then
                        pRoot.CFrame = nearestRoot.CFrame * CFrame.new(math.random(-10, 10), 5, math.random(-10, 10))
                    elseif dist > 20 then
                        hum:MoveTo(nearestRoot.Position)
                        if math.random(1, 3) == 1 then
                            hum.Jump = true
                        end
                    else
                        local wanderX = math.random(-15, 15)
                        local wanderZ = math.random(-15, 15)
                        hum:MoveTo(nearestRoot.Position + Vector3.new(wanderX, 0, wanderZ))
                        if math.random(1, 5) == 1 then
                            hum.Jump = true
                        end
                    end
                else
                    local wanderX = math.random(-30, 30)
                    local wanderZ = math.random(-30, 30)
                    hum:MoveTo(pos + Vector3.new(wanderX, 0, wanderZ))
                end
                task.wait(math.random(1, 3))
            end
        end
    end)

    if role == "jealous" then
        -- Failed stunts: leap + chaotic spin, then sprawl out, then stand up
        task.spawn(function()
            while pen and pen.Parent and hum.Health > 0 do
                task.wait(math.random(5, 8))
                if not (pen and pen.Parent and hum.Health > 0) then break end
                local root = pen:FindFirstChild("HumanoidRootPart")
                if root then
                    hum.PlatformStand = true
                    root.AssemblyLinearVelocity = Vector3.new(
                        math.random(-10, 10),
                        math.random(30, 50),
                        math.random(-10, 10)
                    )
                    root.AssemblyAngularVelocity = Vector3.new(
                        math.random(-20, 20),
                        math.random(-10, 10),
                        math.random(-20, 20)
                    )
                end
                task.wait(2.5)
                if pen and pen.Parent and hum.Health > 0 then
                    hum.PlatformStand = false
                end
            end
        end)
    elseif role == "glitchy" then
        -- Every 10s: restore previously hidden limb, hide a new random one
        task.spawn(function()
            local limbs = {
                {leftArm},
                {rightArm},
                {leftLeg, leftFoot},
                {rightLeg, rightFoot},
            }
            local currentHidden = nil
            while pen and pen.Parent and hum.Health > 0 do
                task.wait(10)
                if not (pen and pen.Parent and hum.Health > 0) then break end
                if currentHidden then
                    for _,part in pairs(limbs[currentHidden]) do
                        if part and part.Parent then
                            part.Transparency = 0
                            part.CanCollide = true
                        end
                    end
                end
                local newIdx = math.random(1, #limbs)
                currentHidden = newIdx
                for _,part in pairs(limbs[newIdx]) do
                    if part and part.Parent then
                        part.Transparency = 1
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- Global talk scheduler: one penguin speaks every TALK_INTERVAL seconds
task.spawn(function()
    while true do
        task.wait(TALK_INTERVAL)
        local alive = {}
        for _,pen in pairs(penguins) do
            if pen and pen.Parent then
                local hum = pen:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(alive, pen)
                end
            end
        end
        if #alive > 0 then
            local pen = alive[math.random(1, #alive)]
            local role = pen:GetAttribute("Role") or "normal"
            penguinTalk(pen, role)
        end
    end
end)

local function penguinEvent()
    announce("PENGUIN EVENT! Penguins are everywhere!")
    Lighting.Brightness = 1.8
    Lighting.Ambient = Color3.fromRGB(200, 230, 255)
    Lighting.FogEnd = 300
    Lighting.FogColor = Color3.fromRGB(200, 220, 240)
    setAllStats(DEFAULT_SPEED, DEFAULT_JUMP)
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local root = ch:FindFirstChild("HumanoidRootPart")
            if root then
                local roles = {}
                for i = 1, 10 do roles[i] = "normal" end
                local jealousIdx = math.random(1, 10)
                local glitchyIdx
                repeat
                    glitchyIdx = math.random(1, 10)
                until glitchyIdx ~= jealousIdx
                roles[jealousIdx] = "jealous"
                roles[glitchyIdx] = "glitchy"

                for i = 1, 10 do
                    local offset = Vector3.new(math.random(-20, 20), 5, math.random(-20, 20))
                    spawnPenguin(root.Position + offset, roles[i])
                end
            end
        end
    end
end

local function chaosEvent()
    announce("CHAOS EVENT! Everyone gets a sword!")
    setAllStats(DEFAULT_SPEED, DEFAULT_JUMP)
    Lighting.Brightness = 0.5
    Lighting.Ambient = Color3.fromRGB(255, 50, 50)
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local hum = ch:FindFirstChild("Humanoid")
            local bp = p:FindFirstChild("Backpack")
            if hum and bp then
                if not bp:FindFirstChild("Weather Sword") and not ch:FindFirstChild("Weather Sword") then
                    local dmg = math.floor(hum.MaxHealth * 0.25)
                    local tool = Instance.new("Tool")
                    tool.Name = "Weather Sword"
                    tool.RequiresHandle = true
                    tool.CanBeDropped = false
                    local handle = Instance.new("Part")
                    handle.Name = "Handle"
                    handle.Size = Vector3.new(1, 1, 5)
                    handle.BrickColor = BrickColor.new("Really red")
                    handle.Material = Enum.Material.Neon
                    handle.Massless = true
                    handle.Parent = tool
                    local canHit = true
                    tool.Activated:Connect(function()
                        if not canHit then return end
                        canHit = false
                        local chr = tool.Parent
                        if not chr then canHit = true return end
                        local plr = Players:GetPlayerFromCharacter(chr)
                        if not plr then canHit = true return end
                        local root = chr:FindFirstChild("HumanoidRootPart")
                        if not root then canHit = true return end
                        handle.BrickColor = BrickColor.new("Bright yellow")
                        task.delay(0.15, function()
                            if handle and handle.Parent then
                                handle.BrickColor = BrickColor.new("Really red")
                            end
                        end)
                        for _,other in pairs(Players:GetPlayers()) do
                            if other ~= plr and other.Character then
                                local oRoot = other.Character:FindFirstChild("HumanoidRootPart")
                                local oHum = other.Character:FindFirstChild("Humanoid")
                                if oRoot and oHum and oHum.Health > 0 then
                                    local dist = (oRoot.Position - root.Position).Magnitude
                                    if dist <= 10 then
                                        oHum:TakeDamage(dmg)
                                    end
                                end
                            end
                        end
                        task.wait(1)
                        canHit = true
                    end)
                    tool.Parent = bp
                end
            end
        end
    end
end

print("WEATHER SYSTEM LOADED")

while true do
    task.wait(WEATHER_INTERVAL)
    local roll = math.random(1, 100)
    if roll <= 15 then
        sonicMode()
    elseif roll <= 25 then
        hackerEvent()
    elseif roll <= 30 then
        snowStorm()
    elseif roll <= 80 then
        penguinEvent()
    elseif roll <= 95 then
        sandStorm()
    else
        chaosEvent()
    end
    task.wait(WEATHER_DURATION)
    resetWeather()
end
