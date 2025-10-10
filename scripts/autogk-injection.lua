--[[  
    ENHANCED AUTO GOALKEEPER v3.1 - ULTRA RESPONSIVE TIMING
    Created by: cypherm1232-del
    Repository: github.com/cypherm1232-del/autogk-whitelist-script
    
    IMPROVEMENTS v3.1:
    - Lightning-fast reaction times (sub-100ms)
    - Multi-timeframe prediction system
    - Emergency threat detection
    - Ultra-responsive dive system
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
    [337777099] = true,  --
}

-- Security Check Function
local function validateAccess()
    local userId = LocalPlayer.UserId
    local userName = LocalPlayer.Name
    
    if whitelist[userId] then
        print("✅ [AutoGK] Access granted for " .. userName .. " (ID: " .. userId .. ")")
        return true
    else
        print("❌ [AutoGK] Access denied for " .. userName .. " (ID: " .. userId .. ")")
        LocalPlayer:Kick("🚫 AutoGK V3.1: Unauthorized Access\n\nYou are not whitelisted for this script.\nContact the script owner if you believe this is an error.\n\nUser ID: " .. userId)
        return false
    end
end

-- Check access before loading main script
if not validateAccess() then
    error("AutoGK V3.1: Access denied - script terminated")
    return
end

-- ═══════════════════════════════════════════════════════
-- MAIN AUTOGK V3.1 SCRIPT - ULTRA RESPONSIVE
-- ═══════════════════════════════════════════════════════

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Virtual Input Manager
local vim = game:GetService("VirtualInputManager") or {}
if not vim.SendKeyEvent then
    vim.SendKeyEvent = function() end
end

-- PERFECT TIMING CONFIG v3.1
local CONFIG = {
    -- Ultra-aggressive detection ranges
    MAX_DETECT_DISTANCE = 80,
    REACT_DISTANCE = 60,
    CRITICAL_DISTANCE = 35,
    INSTANT_REACT_DISTANCE = 20,
    MIDDLE_ZONE_WIDTH = 4.0,
    
    -- Super sensitive speed thresholds
    MIN_SPEED = 5,
    LOW_SPEED = 15,
    MEDIUM_SPEED = 30,
    HIGH_SPEED = 50,
    CRITICAL_SPEED = 70,
    EXTREME_SPEED = 90,
    
    -- INSTANT timing system
    BASE_COOLDOWN = 0.1,
    QUICK_COOLDOWN = 0.05,
    INSTANT_COOLDOWN = 0.02,
    LIGHTNING_COOLDOWN = 0.01,
    DIVE_SEQUENCE_DELAY = 0.02,
    BALL_CHECK_INTERVAL = 0.01, -- Check 100 times per second!
    
    -- Advanced prediction
    PREDICTION_STEPS = 12,
    PREDICTION_TIME = 0.6,
    GRAVITY = Vector3.new(0, -196.2, 0),
    AIR_RESISTANCE = 0.92,
    
    -- Enhanced positioning thresholds
    HEIGHT_THRESHOLD_LOW = -1.5,
    HEIGHT_THRESHOLD_MID = 2.8,
    HEIGHT_THRESHOLD_HIGH = 5.5,
    SIDE_THRESHOLD_WEAK = 1.2,
    SIDE_THRESHOLD_STRONG = 2.5,
    
    -- Controls
    DIVE_LEFT = Enum.KeyCode.Z,
    DIVE_RIGHT = Enum.KeyCode.C,
    JUMP_DIVE = Enum.KeyCode.Space,
    MIDDLE_SAVE = Enum.KeyCode.F,  -- NEW: F key for middle shots
    TOGGLE_KEY = Enum.KeyCode.H,
    DEBUG_KEY = Enum.KeyCode.G,
}

-- State Management
local state = {
    lastDive = 0,
    lastBallCheck = 0,
    lastCleanup = 0,
    foundBalls = {},
    activeBall = nil,
    isEnabled = true,
    debugMode = false,
    isDiving = false,
    diveSequenceActive = false,
    
    stats = {
        totalDives = 0,
        jumpDives = 0,
        sideDives = 0,
        middleSaves = 0,
        ballsDetected = 0,
        highSpeedReactions = 0,
        extremeSpeedReactions = 0,
        sessionStartTime = tick()
    }
}

-- Utility Functions
local function getDistance3D(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function getDistance2D(pos1, pos2)
    local flat1 = Vector3.new(pos1.X, 0, pos1.Z)
    local flat2 = Vector3.new(pos2.X, 0, pos2.Z)
    return (flat1 - flat2).Magnitude
end

local function performCleanup()
    local now = tick()
    if now - state.lastCleanup < 8 then return end
    state.lastCleanup = now
    collectgarbage("collect")
end

-- Lightning-Fast Ball Detection
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
        Workspace:FindFirstChild("Football"),
        ReplicatedStorage:FindFirstChild("Balls"),
        Workspace
    }
    
    for _, location in ipairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetChildren()) do
                if obj:IsA("BasePart") and obj.Parent then
                    local name = obj.Name:lower()
                    local isBall = name:find("ball") or name:find("soccer") or 
                                  name:find("football") or obj.Shape == Enum.PartType.Ball or
                                  name:find("puck") or (obj.Size.X > 1.5 and obj.Size.Y > 1.5)
                    
                    if isBall and obj.AssemblyLinearVelocity then
                        local velocity = obj.AssemblyLinearVelocity
                        if velocity.Magnitude > 0.5 or obj.Position.Y > -10 then
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

-- Multi-Timeframe Prediction System
local function predictBallTrajectory(ballPos, velocity, steps, predictionTime)
    predictionTime = predictionTime or CONFIG.PREDICTION_TIME
    local positions = {}
    local currentPos = ballPos
    local currentVel = velocity
    
    local deltaTime = predictionTime / steps
    local speedFactor = math.min(velocity.Magnitude / 50, 2)
    
    for i = 1, steps do
        local timeStep = deltaTime * speedFactor
        
        local gravityEffect = CONFIG.GRAVITY * timeStep
        local airResistance = CONFIG.AIR_RESISTANCE ^ timeStep
        
        currentVel = (currentVel + gravityEffect) * airResistance
        currentPos = currentPos + (currentVel * timeStep)
        
        local confidence = math.max(0, 1 - (i * 0.08))
        
        table.insert(positions, {
            position = currentPos,
            velocity = currentVel,
            time = i * timeStep,
            confidence = confidence
        })
    end
    
    return positions
end

-- PERFECT Ball Analysis (Instant Detection)
local function analyzeBallAdvanced(ballData, playerPos)
    if not ballData.object or not ballData.object.Parent then 
        return nil 
    end
    
    local ball = ballData.object
    local ballPos = ball.Position
    local velocity = ball.AssemblyLinearVelocity
    local speed = velocity.Magnitude
    local distance = getDistance3D(ballPos, playerPos)
    
    -- Instant prediction for perfect timing
    local predictionTime = math.min(distance / math.max(speed, 5), 0.5)
    local impactPoint = ballPos + (velocity * predictionTime)
    
    -- Super aggressive threat detection
    local directionToPlayer = (playerPos - ballPos).Unit
    local threatLevel = velocity:Dot(directionToPlayer)
    
    -- MUCH more aggressive approach detection
    local isApproaching = speed > CONFIG.MIN_SPEED and 
                         (threatLevel > 0 or distance < CONFIG.REACT_DISTANCE)
    
    -- Ultra-high priority calculation for instant reactions
    local speedBonus = speed > CONFIG.LOW_SPEED and 10 or 0
    local distanceBonus = distance < CONFIG.CRITICAL_DISTANCE and 20 or 0
    local threatBonus = threatLevel > 0 and 15 or 0
    
    local priority = (speed / 5) + (500 / math.max(distance, 1)) + speedBonus + distanceBonus + threatBonus
    
    return {
        ball = ball,
        position = ballPos,
        velocity = velocity,
        speed = speed,
        distance = distance,
        threatLevel = threatLevel,
        isApproaching = isApproaching,
        priority = priority,
        impactPoint = impactPoint,
        timeToImpact = distance / math.max(speed, 5)
    }
end

-- PERFECT Target Selection (Ultra-Aggressive)
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
           analysis.speed >= CONFIG.MIN_SPEED then -- Removed approaching condition for max coverage
            table.insert(candidates, analysis)
        end
    end
    
    -- Sort by priority for instant reactions
    table.sort(candidates, function(a, b) 
        return a.priority > b.priority
    end)
    
    return candidates[1]
end

-- PERFECT Dive System (Lightning Fast, F Key Fixed)
local function performAdvancedDive(ballAnalysis, character)
    if state.isDiving then 
        return false, "busy" 
    end
    
    local hrp = character.HumanoidRootPart
    if not hrp then 
        return false, "no_hrp" 
    end
    
    local impactPoint = ballAnalysis.impactPoint
    local playerPos = hrp.Position
    local localImpact = hrp.CFrame:PointToObjectSpace(impactPoint)
    local heightDiff = impactPoint.Y - playerPos.Y
    
    local diveMade = false
    local diveType = "none"
    
    state.isDiving = true
    
    -- INSTANT key press function (triple tap for reliability)
    local function sendKey(key, holdTime)
        holdTime = holdTime or 0.1
        spawn(function()
            pcall(function()
                -- Triple tap for maximum reliability
                for i = 1, 3 do
                    vim:SendKeyEvent(true, key, false, game)
                    wait(0.005)
                    vim:SendKeyEvent(false, key, false, game)
                    wait(0.005)
                end
                wait(holdTime - 0.03)
                -- Final longer press
                vim:SendKeyEvent(true, key, false, game)
                wait(holdTime)
                vim:SendKeyEvent(false, key, false, game)
            end)
        end)
    end
    
    -- PERFECT dive decision logic
    local absX = math.abs(localImpact.X)
    local isHighShot = heightDiff > CONFIG.HEIGHT_THRESHOLD_HIGH
    local isMidShot = heightDiff > CONFIG.HEIGHT_THRESHOLD_LOW and heightDiff <= CONFIG.HEIGHT_THRESHOLD_MID
    local isLowShot = heightDiff <= CONFIG.HEIGHT_THRESHOLD_LOW
    
    -- FIXED: Perfect middle shot detection
    local isMiddleShot = absX <= CONFIG.MIDDLE_ZONE_WIDTH
    
    if isMiddleShot then
        -- MIDDLE SHOTS - F key with perfect timing
        sendKey(CONFIG.MIDDLE_SAVE, 0.15) -- Longer F key hold for guaranteed saves
        diveMade, diveType = true, "perfect_middle_F"
        state.stats.middleSaves = state.stats.middleSaves + 1
        
    else
        -- SIDE SHOTS - Instant reactions
        if isHighShot then
            -- High side shots - instant jump + dive
            spawn(function()
                sendKey(CONFIG.JUMP_DIVE, 0.08)
                wait(0.02) -- Minimal delay
                local sideKey = localImpact.X > 0 and CONFIG.DIVE_RIGHT or CONFIG.DIVE_LEFT
                sendKey(sideKey, 0.1)
            end)
            diveMade, diveType = true, localImpact.X > 0 and "perfect_high_right" or "perfect_high_left"
            state.stats.jumpDives = state.stats.jumpDives + 1
            
        else
            -- Mid and low side shots - instant side dive
            local sideKey = localImpact.X > 0 and CONFIG.DIVE_RIGHT or CONFIG.DIVE_LEFT
            sendKey(sideKey, 0.15) -- Longer hold for guaranteed saves
            diveMade, diveType = true, localImpact.X > 0 and "perfect_side_right" or "perfect_side_left"
            state.stats.sideDives = state.stats.sideDives + 1
        end
    end
    
    -- Ultra-quick state reset
    spawn(function()
        wait(0.15)
        state.isDiving = false
    end)
    
    return diveMade, diveType
end

-- PERFECT Main Logic (Lightning Fast Reactions)
local function autoGoalkeeperAdvanced()
    if not state.isEnabled or state.isDiving then 
        return 
    end
    
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
    
    -- INSTANT urgency system
    local urgencyLevel = 0
    if ballAnalysis.distance <= CONFIG.INSTANT_REACT_DISTANCE then
        urgencyLevel = 3 -- INSTANT
    elseif ballAnalysis.distance <= CONFIG.CRITICAL_DISTANCE or ballAnalysis.speed >= CONFIG.HIGH_SPEED then
        urgencyLevel = 2 -- CRITICAL
    elseif ballAnalysis.distance <= CONFIG.REACT_DISTANCE or ballAnalysis.speed >= CONFIG.MEDIUM_SPEED then
        urgencyLevel = 1 -- HIGH
    end
    
    -- INSTANT cooldowns
    local cooldowns = {0.1, 0.05, 0.02, 0.01}
    local cooldownToUse = cooldowns[urgencyLevel + 1]
    
    if now - state.lastDive < cooldownToUse then 
        return 
    end
    
    -- PERFECT Save Decision - React to EVERYTHING within range
    local shouldDive = ballAnalysis.distance <= CONFIG.REACT_DISTANCE and ballAnalysis.speed >= CONFIG.MIN_SPEED
    
    if not shouldDive then 
        return 
    end
    
    -- Perform PERFECT save
    local diveMade, diveType = performAdvancedDive(ballAnalysis, character)
    
    if diveMade then
        state.lastDive = now
        state.stats.totalDives = state.stats.totalDives + 1
        
        if urgencyLevel >= 2 then
            state.stats.extremeSpeedReactions = state.stats.extremeSpeedReactions + 1
        elseif urgencyLevel >= 1 then
            state.stats.highSpeedReactions = state.stats.highSpeedReactions + 1
        end
        
        if state.debugMode then
            print(string.format("🔥 PERFECT SAVE! Type: %s | Speed: %.1f | Distance: %.1f | Urgency: %d", 
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
    print(string.format("🥅 Auto Goalkeeper v3.1 %s", state.isEnabled and "ENABLED" or "DISABLED"))
    
    if state.isEnabled then
        local uptime = tick() - state.stats.sessionStartTime
        print("📊 Ultra-Responsive Session Stats:")
        print(string.format("   Uptime: %.1fs | Total Dives: %d", uptime, state.stats.totalDives))
        print(string.format("   Jump Dives: %d | Side Dives: %d | Middle Saves: %d", 
              state.stats.jumpDives, state.stats.sideDives, state.stats.middleSaves))
        print(string.format("   High-speed: %d | Extreme: %d | Balls Tracked: %d", 
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

-- Main update loop with error handling
local connection
connection = RunService.Heartbeat:Connect(function()
    local success, error = pcall(autoGoalkeeperAdvanced)
    if not success and state.debugMode then
        print("⚠️ AutoGK Error: " .. tostring(error))
    end
end)

-- Cleanup
local function cleanup()
    if connection then
        connection:Disconnect()
    end
    local sessionTime = tick() - state.stats.sessionStartTime
    print(string.format("🥅 Auto Goalkeeper v3.1 stopped after %.1fs", sessionTime))
    print(string.format("📈 Final Stats - Dives: %d | Jump: %d | Side: %d | Middle: %d", 
          state.stats.totalDives, state.stats.jumpDives, state.stats.sideDives, state.stats.middleSaves))
end

Players.PlayerRemoving:Connect(function(p)
    if p == player then cleanup() end
end)

-- Startup Messages
print("🥅 ENHANCED AUTO GOALKEEPER v3.1 LOADED! (PERFECT TIMING)")
print("🎮 Controls: H = Toggle ON/OFF | G = Debug Mode")
print("🔥 v3.1 PERFECT Features:")
print("   • Lightning-fast reactions (10ms cooldowns)")
print("   • Triple-tap key system for reliability") 
print("   • F key fixed with perfect middle detection")
print("   • 100x per second ball checking")
print("🐐 made by the goat svetho")
print("🔒 Whitelist protection active - User: " .. LocalPlayer.Name .. " (ID: " .. LocalPlayer.UserId .. ")")
print("✅ Script loaded successfully!")
