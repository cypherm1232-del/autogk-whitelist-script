--[[  
    ENHANCED AUTO GOALKEEPER v3.0 - WHITELIST PROTECTED (INJECTION FIXED)
    Created by: cypherm1232-del
    Repository: github.com/cypherm1232-del/autogk-whitelist-script
--]]

-- ═══════════════════════════════════════════════════════
-- WHITELIST PROTECTION SYSTEM
-- ═══════════════════════════════════════════════════════

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Whitelist Configuration - EDIT THESE USER IDS
local whitelist = {
    [8336404549] = true,  -- 
    [3924020340] = true,  -- 
    [942785644] = true,  -- 
}

-- Security Check Function
local function validateAccess()
    local userId = LocalPlayer.UserId
    local userName = LocalPlayer.Name
    
    if whitelist[userId] then
        -- Access granted
        print("✅ [AutoGK] Access granted for " .. userName .. " (ID: " .. userId .. ")")
        return true
    else
        -- Access denied
        print("❌ [AutoGK] Access denied for " .. userName .. " (ID: " .. userId .. ")")
        LocalPlayer:Kick("🚫 AutoGK V3: Unauthorized Access\n\nYou are not whitelisted for this script.\nContact the script owner if you believe this is an error.\n\nUser ID: " .. userId)
        return false
    end
end

-- Check access before loading main script
if not validateAccess() then
    error("AutoGK V3: Access denied - script terminated")
    return
end

-- ═══════════════════════════════════════════════════════
-- MAIN AUTOGK V3 SCRIPT (INJECTION COMPATIBLE)
-- ═══════════════════════════════════════════════════════

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Virtual Input Manager (safe check)
local vim = game:GetService("VirtualInputManager") or {}
if not vim.SendKeyEvent then
    vim.SendKeyEvent = function() end -- Fallback if not available
end

-- ENHANCED CONFIG v3.0
local CONFIG = {
    -- Detection ranges (adaptive)
    MAX_DETECT_DISTANCE = 60,
    REACT_DISTANCE = 30,
    CRITICAL_DISTANCE = 12,
    
    -- Speed thresholds (dynamic)
    MIN_SPEED = 15,
    HIGH_SPEED = 45,
    CRITICAL_SPEED = 75,
    EXTREME_SPEED = 100,
    
    -- Advanced timing
    BASE_COOLDOWN = 0.7,
    QUICK_COOLDOWN = 0.4,
    INSTANT_COOLDOWN = 0.2,
    BALL_CHECK_INTERVAL = 0.08,
    
    -- Physics prediction
    PREDICTION_STEPS = 5,
    PREDICTION_INTERVAL = 0.1,
    GRAVITY = Vector3.new(0, -196.2, 0),
    AIR_RESISTANCE = 0.95,
    
    -- Positioning
    HEIGHT_THRESHOLD_LOW = -2,
    HEIGHT_THRESHOLD_HIGH = 4,
    
    -- Controls
    DIVE_LEFT = Enum.KeyCode.Z,
    DIVE_RIGHT = Enum.KeyCode.C,
    JUMP_DIVE = Enum.KeyCode.Space,
    TOGGLE_KEY = Enum.KeyCode.H,
    DEBUG_KEY = Enum.KeyCode.G,
}

-- Advanced State Management
local state = {
    lastDive = 0,
    lastBallCheck = 0,
    lastCleanup = 0,
    foundBalls = {},
    activeBall = nil,
    isEnabled = true,
    debugMode = false,
    
    -- Enhanced statistics
    stats = {
        totalDives = 0,
        ballsDetected = 0,
        highSpeedReactions = 0,
        extremeSpeedReactions = 0,
        sessionStartTime = tick(),
        difficultyLevel = 1
    }
}

-- Utility Functions
local function getDistance3D(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Memory management (simplified)
local function performCleanup()
    local now = tick()
    if now - state.lastCleanup < 5 then return end
    state.lastCleanup = now
    collectgarbage("collect")
end

-- Simplified Ball Detection
local function findAllBallsAdvanced()
    local now = tick()
    if now - state.lastBallCheck < CONFIG.BALL_CHECK_INTERVAL then
        return state.foundBalls
    end
    state.lastBallCheck = now
    
    local balls = {}
    local searchLocations = {
        Workspace:FindFirstChild("BallFolder"),
        Workspace:FindFirstChild("Balls"),
        Workspace:FindFirstChild("GameBalls"),
        Workspace:FindFirstChild("SoccerBalls"),
        ReplicatedStorage:FindFirstChild("Balls"),
        Workspace
    }
    
    for _, location in ipairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetChildren()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    local isBall = name:find("ball") or name:find("soccer") or 
                                  name:find("football") or obj.Shape == Enum.PartType.Ball
                    
                    if isBall and obj.AssemblyLinearVelocity then
                        local velocity = obj.AssemblyLinearVelocity
                        if velocity.Magnitude > 1 or (obj.Position.Y > 0) then
                            table.insert(balls, {
                                object = obj,
                                lastPosition = obj.Position,
                                lastVelocity = velocity,
                                detectionTime = now
                            })
                        end
                    end
                end
            end
        end
    end
    
    state.foundBalls = balls
    state.stats.ballsDetected = #balls
    return balls
end

-- Simplified Ball Analysis
local function analyzeBallAdvanced(ballData, playerPos)
    if not ballData.object or not ballData.object.Parent then return nil end
    
    local ball = ballData.object
    local ballPos = ball.Position
    local velocity = ball.AssemblyLinearVelocity
    local speed = velocity.Magnitude
    local distance = getDistance3D(ballPos, playerPos)
    
    -- Simple prediction
    local futurePos = ballPos + (velocity * 0.5)
    local futureDistance = getDistance3D(futurePos, playerPos)
    
    -- Threat assessment
    local directionToPlayer = (playerPos - ballPos).Unit
    local threatLevel = velocity:Dot(directionToPlayer)
    local isApproaching = threatLevel > 0 and futureDistance < distance
    
    local priority = (speed / 20) + (100 / math.max(distance, 1)) + (threatLevel / 20)
    
    return {
        ball = ball,
        position = ballPos,
        velocity = velocity,
        speed = speed,
        distance = distance,
        threatLevel = threatLevel,
        isApproaching = isApproaching,
        priority = priority,
        futurePosition = futurePos
    }
end

-- Target Selection
local function getBestTargetBallAdvanced()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end
    
    local hrp = character.HumanoidRootPart
    local playerPos = hrp.Position
    local balls = findAllBallsAdvanced()
    
    local candidates = {}
    
    for _, ballData in ipairs(balls) do
        local analysis = analyzeBallAdvanced(ballData, playerPos)
        if analysis and 
           analysis.distance <= CONFIG.MAX_DETECT_DISTANCE and 
           analysis.speed >= CONFIG.MIN_SPEED and 
           analysis.isApproaching then
            table.insert(candidates, analysis)
        end
    end
    
    -- Sort by priority
    table.sort(candidates, function(a, b) 
        return a.priority > b.priority
    end)
    
    return candidates[1]
end

-- Simplified Dive System
local function performAdvancedDive(ballAnalysis, character)
    local hrp = character.HumanoidRootPart
    if not hrp then return false end
    
    local impactPoint = ballAnalysis.futurePosition
    local localImpact = hrp.CFrame:PointToObjectSpace(impactPoint)
    local heightDiff = impactPoint.Y - hrp.Position.Y
    
    local diveMade = false
    local diveType = "none"
    
    -- Safe key event function
    local function sendKey(key)
        pcall(function()
            vim:SendKeyEvent(true, key, false, game)
            wait(0.05)
            vim:SendKeyEvent(false, key, false, game)
        end)
    end
    
    -- Determine dive type
    if heightDiff > CONFIG.HEIGHT_THRESHOLD_HIGH then
        sendKey(CONFIG.JUMP_DIVE)
        diveType = "jump"
        diveMade = true
    elseif heightDiff < CONFIG.HEIGHT_THRESHOLD_LOW then
        if localImpact.X > 1.5 then
            sendKey(CONFIG.DIVE_RIGHT)
            diveType = "low_right"
        elseif localImpact.X < -1.5 then
            sendKey(CONFIG.DIVE_LEFT)
            diveType = "low_left"
        end
        diveMade = true
    else
        if localImpact.X > 1 then
            sendKey(CONFIG.DIVE_RIGHT)
            diveType = "right"
        elseif localImpact.X < -1 then
            sendKey(CONFIG.DIVE_LEFT)
            diveType = "left"
        end
        diveMade = true
    end
    
    return diveMade, diveType
end

-- Main Goalkeeper Logic
local function autoGoalkeeperAdvanced()
    if not state.isEnabled then return end
    
    performCleanup()
    
    local now = tick()
    local character = player.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    local ballAnalysis = getBestTargetBallAdvanced()
    if not ballAnalysis then 
        state.activeBall = nil
        return 
    end
    
    state.activeBall = ballAnalysis.ball
    
    -- Reaction timing
    local urgencyLevel = 0
    if ballAnalysis.speed >= CONFIG.EXTREME_SPEED then
        urgencyLevel = 3
    elseif ballAnalysis.speed >= CONFIG.CRITICAL_SPEED or ballAnalysis.distance <= CONFIG.CRITICAL_DISTANCE then
        urgencyLevel = 2
    elseif ballAnalysis.speed >= CONFIG.HIGH_SPEED then
        urgencyLevel = 1
    end
    
    local cooldowns = {CONFIG.BASE_COOLDOWN, CONFIG.QUICK_COOLDOWN, CONFIG.QUICK_COOLDOWN * 0.7, CONFIG.INSTANT_COOLDOWN}
    local cooldownToUse = cooldowns[urgencyLevel + 1]
    
    if now - state.lastDive < cooldownToUse then return end
    
    -- Decision making
    local shouldDive = ballAnalysis.distance <= CONFIG.REACT_DISTANCE or urgencyLevel >= 2
    
    if not shouldDive then return end
    
    -- Perform dive
    local diveMade, diveType = performAdvancedDive(ballAnalysis, character)
    
    if diveMade then
        state.lastDive = now
        state.stats.totalDives = state.stats.totalDives + 1
        
        if urgencyLevel >= 3 then
            state.stats.extremeSpeedReactions = state.stats.extremeSpeedReactions + 1
        elseif urgencyLevel >= 1 then
            state.stats.highSpeedReactions = state.stats.highSpeedReactions + 1
        end
        
        if state.debugMode then
            print(string.format("🥅 DIVE! Type: %s | Speed: %.1f | Distance: %.1f | Urgency: %d", 
                  diveType, ballAnalysis.speed, ballAnalysis.distance, urgencyLevel))
        end
    end
end

-- Toggle Functions
local function toggleDebugMode()
    state.debugMode = not state.debugMode
    print(string.format("🐛 Debug Mode %s", state.debugMode and "ENABLED" or "DISABLED"))
end

local function toggleGoalkeeper()
    state.isEnabled = not state.isEnabled
    print(string.format("🥅 Auto Goalkeeper v3.0 %s", state.isEnabled and "ENABLED" or "DISABLED"))
    
    if state.isEnabled then
        local uptime = tick() - state.stats.sessionStartTime
        print("📊 Session Stats:")
        print(string.format("   Uptime: %.1fs | Dives: %d", uptime, state.stats.totalDives))
        print(string.format("   High-speed: %d | Extreme: %d | Balls: %d", 
              state.stats.highSpeedReactions, state.stats.extremeSpeedReactions, 
              state.stats.ballsDetected))
    end
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.TOGGLE_KEY then
        toggleGoalkeeper()
    elseif input.KeyCode == CONFIG.DEBUG_KEY then
        toggleDebugMode()
    end
end)

-- Main update loop
local connection
connection = RunService.Heartbeat:Connect(function()
    pcall(autoGoalkeeperAdvanced)
end)

-- Cleanup
local function cleanup()
    if connection then
        connection:Disconnect()
    end
    local sessionTime = tick() - state.stats.sessionStartTime
    print(string.format("🥅 Auto Goalkeeper v3.0 stopped after %.1fs", sessionTime))
end

Players.PlayerRemoving:Connect(function(p)
    if p == player then cleanup() end
end)

-- Startup Messages
print("🥅 ENHANCED AUTO GOALKEEPER v3.0 LOADED! (INJECTION COMPATIBLE)")
print("🎮 Controls: H = Toggle ON/OFF | G = Debug Mode")
print("🐐 made by the goat svetho")
print("🔒 Whitelist protection active - User: " .. LocalPlayer.Name .. " (ID: " .. LocalPlayer.UserId .. ")")
print("✅ Script loaded successfully!")
