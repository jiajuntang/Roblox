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
local FEED_REACH = 10
local FISH_PER_EVENT = 3
local penguins = {}
local playerBonuses = {} -- [userId] = {speed = fractional, jump = fractional}

local fishRewards = {
    {weight = 40, speed = 0.01, jump = 0.02, tier = "Common"},
    {weight = 30, speed = 0.05, jump = 0,    tier = "Uncommon"},
    {weight = 20, speed = 0.03, jump = 0.04, tier = "Rare"},
    {weight = 7,  speed = 0,    jump = 0.10, tier = "Epic"},
    {weight = 3,  speed = 0.05, jump = 0.15, tier = "Legendary"},
}

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

local function getBonus(userId)
    return playerBonuses[userId] or {speed = 0, jump = 0}
end

local function setAllStats(speed, jump)
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local hum = ch:FindFirstChild("Humanoid")
            if hum then
                local bonus = getBonus(p.UserId)
                hum.WalkSpeed = speed + DEFAULT_SPEED * bonus.speed
                hum.JumpPower = jump + DEFAULT_JUMP * bonus.jump
            end
        end
    end
end

local function applyBonusesOnSpawn(player, ch)
    task.wait(1.2)
    if not ch or not ch.Parent then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local bonus = getBonus(player.UserId)
    hum.WalkSpeed = DEFAULT_SPEED + DEFAULT_SPEED * bonus.speed
    hum.JumpPower = DEFAULT_JUMP + DEFAULT_JUMP * bonus.jump
end

Players.PlayerAdded:Connect(function(p)
    playerBonuses[p.UserId] = playerBonuses[p.UserId] or {speed = 0, jump = 0}
    p.CharacterAdded:Connect(function(ch)
        applyBonusesOnSpawn(p, ch)
    end)
end)

for _,p in pairs(Players:GetPlayers()) do
    playerBonuses[p.UserId] = playerBonuses[p.UserId] or {speed = 0, jump = 0}
end

Players.PlayerRemoving:Connect(function(p)
    playerBonuses[p.UserId] = nil
end)

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

    -- Body (dark ellipsoid "torpedo" shape)
    local body = Instance.new("Part")
    body.Name = "HumanoidRootPart"
    body.Size = Vector3.new(3.2, 4.4, 2.6)
    body.BrickColor = BrickColor.new("Really black")
    body.Material = Enum.Material.SmoothPlastic
    body.Position = pos
    body.Anchored = false
    body.Parent = pen
    local bodyMesh = Instance.new("SpecialMesh")
    bodyMesh.MeshType = Enum.MeshType.Sphere
    bodyMesh.Scale = Vector3.new(1, 1, 1)
    bodyMesh.Parent = body

    -- Belly (cream-white front, follows the body curve)
    local belly = Instance.new("Part")
    belly.Name = "Belly"
    belly.Size = Vector3.new(2.6, 3.8, 2.4)
    belly.BrickColor = BrickColor.new("Institutional white")
    belly.Material = Enum.Material.SmoothPlastic
    belly.Anchored = false
    belly.Parent = pen
    local bellyMesh = Instance.new("SpecialMesh")
    bellyMesh.MeshType = Enum.MeshType.Sphere
    bellyMesh.Scale = Vector3.new(1, 1, 1)
    bellyMesh.Parent = belly

    local bWeld = Instance.new("Weld")
    bWeld.Part0 = body
    bWeld.Part1 = belly
    bWeld.C0 = CFrame.new(0, -0.2, 0.25)
    bWeld.Parent = belly

    -- Head (rounded)
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Size = Vector3.new(2.2, 2.2, 2.2)
    head.BrickColor = BrickColor.new("Really black")
    head.Material = Enum.Material.SmoothPlastic
    head.Anchored = false
    head.Parent = pen

    local hWeld = Instance.new("Weld")
    hWeld.Part0 = body
    hWeld.Part1 = head
    hWeld.C0 = CFrame.new(0, 2.9, 0)
    hWeld.Parent = head

    -- White throat (wraps under the chin, bridges head-to-belly)
    local throat = Instance.new("Part")
    throat.Name = "Throat"
    throat.Size = Vector3.new(1.6, 1.2, 1.4)
    throat.BrickColor = BrickColor.new("Institutional white")
    throat.Material = Enum.Material.SmoothPlastic
    throat.Anchored = false
    throat.Parent = pen
    local throatMesh = Instance.new("SpecialMesh")
    throatMesh.MeshType = Enum.MeshType.Sphere
    throatMesh.Scale = Vector3.new(1, 1, 1)
    throatMesh.Parent = throat

    local tWeld = Instance.new("Weld")
    tWeld.Part0 = head
    tWeld.Part1 = throat
    tWeld.C0 = CFrame.new(0, -0.6, 0.45)
    tWeld.Parent = throat

    -- Left eye (white sclera)
    local leftEye = Instance.new("Part")
    leftEye.Name = "LeftEye"
    leftEye.Shape = Enum.PartType.Ball
    leftEye.Size = Vector3.new(0.32, 0.32, 0.32)
    leftEye.BrickColor = BrickColor.new("Institutional white")
    leftEye.Material = Enum.Material.SmoothPlastic
    leftEye.Anchored = false
    leftEye.Parent = pen

    local leWeld = Instance.new("Weld")
    leWeld.Part0 = head
    leWeld.Part1 = leftEye
    leWeld.C0 = CFrame.new(-0.45, 0.25, 0.95)
    leWeld.Parent = leftEye

    -- Left pupil
    local leftPupil = Instance.new("Part")
    leftPupil.Name = "LeftPupil"
    leftPupil.Shape = Enum.PartType.Ball
    leftPupil.Size = Vector3.new(0.2, 0.2, 0.2)
    leftPupil.BrickColor = BrickColor.new("Really black")
    leftPupil.Material = Enum.Material.SmoothPlastic
    leftPupil.Anchored = false
    leftPupil.Parent = pen

    local lpWeld = Instance.new("Weld")
    lpWeld.Part0 = leftEye
    lpWeld.Part1 = leftPupil
    lpWeld.C0 = CFrame.new(0, 0, 0.1)
    lpWeld.Parent = leftPupil

    -- Right eye (white sclera)
    local rightEye = Instance.new("Part")
    rightEye.Name = "RightEye"
    rightEye.Shape = Enum.PartType.Ball
    rightEye.Size = Vector3.new(0.32, 0.32, 0.32)
    rightEye.BrickColor = BrickColor.new("Institutional white")
    rightEye.Material = Enum.Material.SmoothPlastic
    rightEye.Anchored = false
    rightEye.Parent = pen

    local reWeld = Instance.new("Weld")
    reWeld.Part0 = head
    reWeld.Part1 = rightEye
    reWeld.C0 = CFrame.new(0.45, 0.25, 0.95)
    reWeld.Parent = rightEye

    -- Right pupil
    local rightPupil = Instance.new("Part")
    rightPupil.Name = "RightPupil"
    rightPupil.Shape = Enum.PartType.Ball
    rightPupil.Size = Vector3.new(0.2, 0.2, 0.2)
    rightPupil.BrickColor = BrickColor.new("Really black")
    rightPupil.Material = Enum.Material.SmoothPlastic
    rightPupil.Anchored = false
    rightPupil.Parent = pen

    local rpWeld = Instance.new("Weld")
    rpWeld.Part0 = rightEye
    rpWeld.Part1 = rightPupil
    rpWeld.C0 = CFrame.new(0, 0, 0.1)
    rpWeld.Parent = rightPupil

    -- Beak (dark orange wedge pointing forward and slightly down)
    local beak = Instance.new("Part")
    beak.Name = "Beak"
    beak.Size = Vector3.new(0.5, 0.5, 0.95)
    beak.BrickColor = BrickColor.new("CGA brown")
    beak.Material = Enum.Material.SmoothPlastic
    beak.Anchored = false
    beak.Parent = pen
    local beakMesh = Instance.new("SpecialMesh")
    beakMesh.MeshType = Enum.MeshType.Wedge
    beakMesh.Scale = Vector3.new(1, 1, 1)
    beakMesh.Parent = beak

    local beakWeld = Instance.new("Weld")
    beakWeld.Part0 = head
    beakWeld.Part1 = beak
    beakWeld.C0 = CFrame.new(0, -0.15, 1.15) * CFrame.Angles(math.rad(180), 0, 0)
    beakWeld.Parent = beak

    -- Left flipper (curved, tapered leaf shape hanging down the side)
    local leftFlipper = Instance.new("Part")
    leftFlipper.Name = "LeftFlipper"
    leftFlipper.Size = Vector3.new(0.6, 3.2, 1.4)
    leftFlipper.BrickColor = BrickColor.new("Really black")
    leftFlipper.Material = Enum.Material.SmoothPlastic
    leftFlipper.Anchored = false
    leftFlipper.Parent = pen
    local lfMesh = Instance.new("SpecialMesh")
    lfMesh.MeshType = Enum.MeshType.Sphere
    lfMesh.Scale = Vector3.new(1, 1, 1)
    lfMesh.Parent = leftFlipper

    local lfpWeld = Instance.new("Weld")
    lfpWeld.Part0 = body
    lfpWeld.Part1 = leftFlipper
    lfpWeld.C0 = CFrame.new(-1.7, 0, 0.05) * CFrame.Angles(0, 0, math.rad(8))
    lfpWeld.Parent = leftFlipper

    -- Right flipper
    local rightFlipper = Instance.new("Part")
    rightFlipper.Name = "RightFlipper"
    rightFlipper.Size = Vector3.new(0.6, 3.2, 1.4)
    rightFlipper.BrickColor = BrickColor.new("Really black")
    rightFlipper.Material = Enum.Material.SmoothPlastic
    rightFlipper.Anchored = false
    rightFlipper.Parent = pen
    local rfMesh = Instance.new("SpecialMesh")
    rfMesh.MeshType = Enum.MeshType.Sphere
    rfMesh.Scale = Vector3.new(1, 1, 1)
    rfMesh.Parent = rightFlipper

    local rfpWeld = Instance.new("Weld")
    rfpWeld.Part0 = body
    rfpWeld.Part1 = rightFlipper
    rfpWeld.C0 = CFrame.new(1.7, 0, 0.05) * CFrame.Angles(0, 0, math.rad(-8))
    rfpWeld.Parent = rightFlipper

    -- Left foot (flat orange webbed pad)
    local leftFoot = Instance.new("Part")
    leftFoot.Name = "LeftFoot"
    leftFoot.Size = Vector3.new(0.95, 0.35, 1.5)
    leftFoot.BrickColor = BrickColor.new("Deep orange")
    leftFoot.Material = Enum.Material.SmoothPlastic
    leftFoot.Anchored = false
    leftFoot.Parent = pen
    local lfootMesh = Instance.new("SpecialMesh")
    lfootMesh.MeshType = Enum.MeshType.Sphere
    lfootMesh.Scale = Vector3.new(1, 1, 1)
    lfootMesh.Parent = leftFoot

    local lfWeld = Instance.new("Weld")
    lfWeld.Part0 = body
    lfWeld.Part1 = leftFoot
    lfWeld.C0 = CFrame.new(-0.55, -2.25, 0.45)
    lfWeld.Parent = leftFoot

    -- Right foot
    local rightFoot = Instance.new("Part")
    rightFoot.Name = "RightFoot"
    rightFoot.Size = Vector3.new(0.95, 0.35, 1.5)
    rightFoot.BrickColor = BrickColor.new("Deep orange")
    rightFoot.Material = Enum.Material.SmoothPlastic
    rightFoot.Anchored = false
    rightFoot.Parent = pen
    local rfootMesh = Instance.new("SpecialMesh")
    rfootMesh.MeshType = Enum.MeshType.Sphere
    rfootMesh.Scale = Vector3.new(1, 1, 1)
    rfootMesh.Parent = rightFoot

    local rfWeld = Instance.new("Weld")
    rfWeld.Part0 = body
    rfWeld.Part1 = rightFoot
    rfWeld.C0 = CFrame.new(0.55, -2.25, 0.45)
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
                {leftFlipper},
                {rightFlipper},
                {leftFoot},
                {rightFoot},
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

local function rollFishReward()
    local total = 0
    for _,r in pairs(fishRewards) do total = total + r.weight end
    local roll = math.random(1, total)
    local acc = 0
    for _,r in pairs(fishRewards) do
        acc = acc + r.weight
        if roll <= acc then return r end
    end
    return fishRewards[1]
end

local function feedPenguin(pen, player)
    local head = pen:FindFirstChild("Head")
    if head then
        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 160, 0, 45)
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.Adornee = head
        bill.Parent = head
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 0.25
        label.Text = "YUM!"
        label.TextColor3 = Color3.fromRGB(0, 0, 0)
        label.TextSize = 18
        label.Font = Enum.Font.GothamBold
        label.Parent = bill
        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)
        task.delay(2, function()
            if bill and bill.Parent then bill:Destroy() end
        end)
    end

    local reward = rollFishReward()
    local userId = player.UserId
    playerBonuses[userId] = playerBonuses[userId] or {speed = 0, jump = 0}
    playerBonuses[userId].speed = playerBonuses[userId].speed + reward.speed
    playerBonuses[userId].jump = playerBonuses[userId].jump + reward.jump

    local ch = player.Character
    if ch then
        local hum = ch:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = hum.WalkSpeed + DEFAULT_SPEED * reward.speed
            hum.JumpPower = hum.JumpPower + DEFAULT_JUMP * reward.jump
        end
    end

    local pg = player:FindFirstChild("PlayerGui")
    if pg then
        local msg = reward.tier .. "!"
        if reward.speed > 0 then
            msg = msg .. " +" .. math.floor(reward.speed * 100 + 0.5) .. "% speed"
        end
        if reward.jump > 0 then
            msg = msg .. " +" .. math.floor(reward.jump * 100 + 0.5) .. "% jump"
        end
        local hint = Instance.new("Hint")
        hint.Text = msg
        hint.Parent = pg
        task.delay(4, function()
            if hint and hint.Parent then hint:Destroy() end
        end)
    end
end

local function giveFish(player)
    local bp = player:FindFirstChild("Backpack")
    if not bp then return end

    local tool = Instance.new("Tool")
    tool.Name = "Fish"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    tool.ToolTip = "Feed to a penguin (within " .. FEED_REACH .. " studs)"

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.9, 0.6, 2.2)
    handle.BrickColor = BrickColor.new("Cyan")
    handle.Material = Enum.Material.SmoothPlastic
    handle.Massless = true
    handle.Parent = tool
    local fishMesh = Instance.new("SpecialMesh")
    fishMesh.MeshType = Enum.MeshType.Sphere
    fishMesh.Scale = Vector3.new(1, 1, 1)
    fishMesh.Parent = handle

    tool.Activated:Connect(function()
        local ch = tool.Parent
        if not ch then return end
        local plr = Players:GetPlayerFromCharacter(ch)
        if not plr then return end
        local root = ch:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local closest = nil
        local closestDist = FEED_REACH
        for _,pen in pairs(penguins) do
            if pen and pen.Parent then
                local pRoot = pen:FindFirstChild("HumanoidRootPart")
                if pRoot then
                    local d = (pRoot.Position - root.Position).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closest = pen
                    end
                end
            end
        end

        if closest then
            feedPenguin(closest, plr)
            tool:Destroy()
        end
    end)

    tool.Parent = bp
end

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
        for i = 1, FISH_PER_EVENT do
            giveFish(p)
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
