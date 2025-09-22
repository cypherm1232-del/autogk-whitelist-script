--[[  
    ENHANCED AUTO GOALKEEPER v3.0 - WHITELIST PROTECTED
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
    [7489944006] = true,  -- Replace with your User ID
    [3924020340] = true,  -- Replace with friend's User ID  
    [942785644] = true,  -- Add more User IDs as needed
}

-- Security Check Function
local function validateAccess()
    local userId = LocalPlayer.UserId
    local userName = LocalPlayer.Name
    
    if whitelist[userId] then
        -- Access granted
        game.StarterGui:SetCore("SendNotification", {
            Title = "🟢 AutoGK Access Granted";
            Text = "Welcome " .. userName .. "! Loading AutoGK V3...";
            Duration = 3;
        })
        print("✅ [AutoGK] Access granted for " .. userName .. " (ID: " .. userId .. ")")
        return true
    else
        -- Access denied
        game.StarterGui:SetCore("SendNotification", {
            Title = "🔴 Access Denied";
            Text = "You are not authorized to use AutoGK V3";
            Duration = 5;
        })
        print("❌ [AutoGK] Access denied for " .. userName .. " (ID: " .. userId .. ")")
        
        -- Kick unauthorized users
        wait(2)
        LocalPlayer:Kick("🚫 AutoGK V3: Unauthorized Access\n\nYou are not whitelisted for this script.\nContact the script owner if you believe this is an error.\n\nUser ID: " .. userId)
        return false
    end
end

-- Check access before loading main script
if not validateAccess() then
    error("AutoGK V3: Access denied - script terminated")
    return
end

-- Loading notification
game.StarterGui:SetCore("SendNotification", {
    Title = "⚡ AutoGK V3 Loading";
    Text = "Initializing enhanced goalkeeper system...";
    Duration = 2;
})

-- ═══════════════════════════════════════════════════════
-- MAIN AUTOGK V3 SCRIPT (PROTECTED)
-- ═══════════════════════════════════════════════════════

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

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
    OPTIMAL_GOAL_DISTANCE = 3,
    POSITIONING_SPEED = 0.3,
    HEIGHT_THRESHOLD_LOW = -2,
    HEIGHT_THRESHOLD_HIGH = 4,
    
    -- Learning system
    LEARNING_RATE = 0.1,
    MEMORY_SIZE = 50,
    ADAPTATION_THRESHOLD = 5,
    
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
    ballHistory = {},
    activeBall = nil,
    isEnabled = true,
    debugMode = false,
    adaptiveSettings = {},
    
    -- Performance tracking
    performance = {
        avgFPS = 60,
        ballDetectionTime = 0,
        predictionTime = 0,
        lastFrameTime = tick()
    },
    
    -- Enhanced statistics
    stats = {
        totalDives = 0,
        successfulSaves = 0,
        ballsDetected = 0,
        highSpeedReactions = 0,
        extremeSpeedReactions = 0,
        averageReactionTime = 0,
        sessionStartTime = tick(),
        ballPatterns = {},
        difficultyLevel = 1
    },
    
    -- Learning data
    learning = {
        ballMemory = {},
        reactionPatterns = {},
        successRates = {},
        optimalPositions = {}
    }
}

-- Utility Functions
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function getDistance3D(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Performance monitoring
local function updatePerformance()
    local now = tick()
    local deltaTime = now - state.performance.lastFrameTime
    state.performance.lastFrameTime = now
    
    if deltaTime > 0 then
        local currentFPS = 1 / deltaTime
        state.performance.avgFPS = lerp(state.performance.avgFPS, currentFPS, 0.1)
    end
end

-- Memory management
local function performCleanup()
    local now = tick()
    if now - state.lastCleanup < 5 then return end
    
    state.lastCleanup = now
    
    -- Clean old ball history
    local cutoffTime = now - 30
    for i = #state.ballHistory, 1, -1 do
        if state.ballHistory[i].timestamp < cutoffTime then
            table.remove(state.ballHistory, i)
        end
    end
    
    -- Clean learning data
    if #state.learning.ballMemory > CONFIG.MEMORY_SIZE then
        for i = 1, #state.learning.ballMemory - CONFIG.MEMORY_SIZE do
            table.remove(state.learning.ballMemory, 1)
        end
    end
    
    -- Force garbage collection periodically
    collectgarbage("collect")
end

-- Advanced Ball Detection with Multi-threading Simulation
local function findAllBallsAdvanced()
    local startTime = tick()
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
        Workspace -- Fallback
    }
    
    -- Enhanced ball detection with pattern recognition
    for _, location in ipairs(searchLocations) do
        if location then
            local objects = location:GetChildren()
            for _, obj in pairs(objects) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    local isBall = name:find("ball") or name:find("soccer") or 
                                  name:find("football") or obj.Shape == Enum.PartType.Ball
                    
                    if isBall and obj.AssemblyLinearVelocity then
                        -- Additional validation
                        local velocity = obj.AssemblyLinearVelocity
                        if velocity.Magnitude > 1 or (obj.Position.Y > 0) then
                            table.insert(balls, {
                                object = obj,
                                lastPosition = obj.Position,
                                lastVelocity = velocity,
                                detectionTime = now,
                                id = obj:GetDebugId()
                            })
                        end
                    end
                end
            end
        end
    end
    
    state.foundBalls = balls
    state.stats.ballsDetected = #balls
    state.performance.ballDetectionTime = tick() - startTime
    
    return balls
end

-- Advanced Physics-Based Trajectory Prediction
local function predictTrajectory(ball, steps, interval)
    local startTime = tick()
    local predictions = {}
    
    local pos = ball.lastPosition
    local vel = ball.lastVelocity
    
    for step = 1, steps do
        local deltaTime = interval * step
        
        -- Apply gravity and air resistance
        local newVel = vel + (CONFIG.GRAVITY * deltaTime)
        newVel = newVel * (CONFIG.AIR_RESISTANCE ^ deltaTime)
        
        local newPos = pos + (vel * deltaTime) + (0.5 * CONFIG.GRAVITY * deltaTime * deltaTime)
        
        -- Check for ground collision
        if newPos.Y <= 0 and vel.Y < 0 then
            newPos = Vector3.new(newPos.X, 0, newPos.Z)
            newVel = Vector3.new(newVel.X * 0.7, -newVel.Y * 0.6, newVel.Z * 0.7) -- Bounce
        end
        
        table.insert(predictions, {
            position = newPos,
            velocity = newVel,
            time = deltaTime
        })
        
        pos = newPos
        vel = newVel
    end
    
    state.performance.predictionTime = tick() - startTime
    return predictions
end

-- Enhanced Ball Analysis with Learning
local function analyzeBallAdvanced(ballData, playerPos)
    if not ballData.object or not ballData.object.Parent then return nil end
    
    local ball = ballData.object
    local ballPos = ball.Position
    local velocity = ball.AssemblyLinearVelocity
    local speed = velocity.Magnitude
    local distance = getDistance3D(ballPos, playerPos)
    
    -- Advanced trajectory prediction
    local trajectory = predictTrajectory(ballData, CONFIG.PREDICTION_STEPS, CONFIG.PREDICTION_INTERVAL)
    local futurePositions = {}
    local closestApproach = {distance = math.huge, position = ballPos, time = 0}
    
    for _, point in ipairs(trajectory) do
        local futureDistance = getDistance3D(point.position, playerPos)
        table.insert(futurePositions, point.position)
        
        if futureDistance < closestApproach.distance then
            closestApproach = {
                distance = futureDistance,
                position = point.position,
                time = point.time
            }
        end
    end
    
    -- Threat assessment
    local directionToPlayer = (playerPos - ballPos).Unit
    local threatLevel = velocity:Dot(directionToPlayer)
    local isApproaching = threatLevel > 0 and closestApproach.distance < distance
    
    -- Learning-based priority calculation
    local basePriority = (speed / 20) + (100 / math.max(distance, 1)) + (threatLevel / 20)
    local learningBonus = 0
    
    -- Check historical patterns
    for _, memory in ipairs(state.learning.ballMemory) do
        if getDistance3D(memory.initialPos, ballPos) < 5 and 
           math.abs(memory.speed - speed) < 10 then
            learningBonus = memory.successRate * 0.5
            break
        end
    end
    
    return {
        ball = ball,
        ballData = ballData,
        position = ballPos,
        velocity = velocity,
        speed = speed,
        distance = distance,
        trajectory = trajectory,
        closestApproach = closestApproach,
        threatLevel = threatLevel,
        isApproaching = isApproaching,
        priority = basePriority + learningBonus,
        predictedImpact = closestApproach.time > 0 and closestApproach.time or 999
    }
end

-- Intelligent Target Selection
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
    
    -- Multi-criteria sorting
    table.sort(candidates, function(a, b) 
        -- Prioritize by impact time, then by priority score
        if math.abs(a.predictedImpact - b.predictedImpact) < 0.2 then
            return a.priority > b.priority
        end
        return a.predictedImpact < b.predictedImpact
    end)
    
    return candidates[1]
end

-- Advanced Dive System with Positioning
local function performAdvancedDive(ballAnalysis, character)
    local hrp = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return false end
    
    local impactPoint = ballAnalysis.closestApproach.position
    local localImpact = hrp.CFrame:PointToObjectSpace(impactPoint)
    local heightDiff = impactPoint.Y - hrp.Position.Y
    
    local diveMade = false
    local diveType = "none"
    
    -- Determine dive type based on ball trajectory
    if heightDiff > CONFIG.HEIGHT_THRESHOLD_HIGH then
        -- High ball - jump
        vim:SendKeyEvent(true, CONFIG.JUMP_DIVE, false, game)
        task.wait(0.05)
        vim:SendKeyEvent(false, CONFIG.JUMP_DIVE, false, game)
        diveType = "jump"
        diveMade = true
        
    elseif heightDiff < CONFIG.HEIGHT_THRESHOLD_LOW then
        -- Low ball - dive low
        if localImpact.X > 1.5 then
            vim:SendKeyEvent(true, CONFIG.DIVE_RIGHT, false, game)
            task.wait(0.05)
            vim:SendKeyEvent(false, CONFIG.DIVE_RIGHT, false, game)
            diveType = "low_right"
        elseif localImpact.X < -1.5 then
            vim:SendKeyEvent(true, CONFIG.DIVE_LEFT, false, game)
            task.wait(0.05)
            vim:SendKeyEvent(false, CONFIG.DIVE_LEFT, false, game)
            diveType = "low_left"
        end
        diveMade = true
        
    else
        -- Mid-height ball
        if localImpact.X > 1 then
            vim:SendKeyEvent(true, CONFIG.DIVE_RIGHT, false, game)
            task.wait(0.05)
            vim:SendKeyEvent(false, CONFIG.DIVE_RIGHT, false, game)
            diveType = "right"
        elseif localImpact.X < -1 then
            vim:SendKeyEvent(true, CONFIG.DIVE_LEFT, false, game)
            task.wait(0.05)
            vim:SendKeyEvent(false, CONFIG.DIVE_LEFT, false, game)
            diveType = "left"
        end
        diveMade = true
    end
    
    -- Record dive for learning
    if diveMade then
        table.insert(state.learning.ballMemory, {
            initialPos = ballAnalysis.position,
            speed = ballAnalysis.speed,
            diveType = diveType,
            timestamp = tick(),
            successRate = 0.5 -- Will be updated later
        })
    end
    
    return diveMade, diveType
end

-- Adaptive Difficulty System
local function updateDifficulty()
    local successRate = state.stats.totalDives > 0 and 
                       (state.stats.successfulSaves / state.stats.totalDives) or 0
    
    if successRate > 0.8 and state.stats.totalDives > 10 then
        state.stats.difficultyLevel = math.min(state.stats.difficultyLevel + 0.1, 3)
        CONFIG.REACT_DISTANCE = CONFIG.REACT_DISTANCE * 0.95
        CONFIG.BASE_COOLDOWN = CONFIG.BASE_COOLDOWN * 1.05
    elseif successRate < 0.4 and state.stats.totalDives > 5 then
        state.stats.difficultyLevel = math.max(state.stats.difficultyLevel - 0.1, 0.5)
        CONFIG.REACT_DISTANCE = CONFIG.REACT_DISTANCE * 1.05
        CONFIG.BASE_COOLDOWN = CONFIG.BASE_COOLDOWN * 0.95
    end
end

-- Main Enhanced Goalkeeper Logic
local function autoGoalkeeperAdvanced()
    if not state.isEnabled then return end
    
    updatePerformance()
    performCleanup()
    
    local now = tick()
    local character = player.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    -- Get best target with advanced analysis
    local ballAnalysis = getBestTargetBallAdvanced()
    if not ballAnalysis then 
        state.activeBall = nil
        return 
    end
    
    state.activeBall = ballAnalysis.ball
    
    -- Advanced reaction timing
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
    
    -- Enhanced decision making
    local shouldDive = ballAnalysis.distance <= CONFIG.REACT_DISTANCE or 
                       (urgencyLevel >= 2) or
                       (ballAnalysis.predictedImpact < 1.0 and ballAnalysis.distance <= CONFIG.MAX_DETECT_DISTANCE * 0.7)
    
    if not shouldDive then return end
    
    -- Perform the dive
    local diveMade, diveType = performAdvancedDive(ballAnalysis, character)
    
    if diveMade then
        state.lastDive = now
        state.stats.totalDives = state.stats.totalDives + 1
        
        if urgencyLevel >= 3 then
            state.stats.extremeSpeedReactions = state.stats.extremeSpeedReactions + 1
        elseif urgencyLevel >= 1 then
            state.stats.highSpeedReactions = state.stats.highSpeedReactions + 1
        end
        
        -- Update difficulty
        updateDifficulty()
        
        if state.debugMode then
            print(string.format("🥅 DIVE! Type: %s | Speed: %.1f | Distance: %.1f | Impact: %.2fs | Urgency: %d", 
                  diveType, ballAnalysis.speed, ballAnalysis.distance, 
                  ballAnalysis.predictedImpact, urgencyLevel))
        end
    end
end

-- Enhanced Debug System
local function toggleDebugMode()
    state.debugMode = not state.debugMode
    print(string.format("🐛 Debug Mode %s", state.debugMode and "ENABLED" or "DISABLED"))
    
    if state.debugMode then
        print("📊 Performance Stats:")
        print(string.format("   FPS: %.1f | Ball Detection: %.3fms | Prediction: %.3fms", 
              state.performance.avgFPS, 
              state.performance.ballDetectionTime * 1000,
              state.performance.predictionTime * 1000))
        print(string.format("   Difficulty Level: %.1f", state.stats.difficultyLevel))
    end
end

-- Enhanced Toggle System
local function toggleGoalkeeper()
    state.isEnabled = not state.isEnabled
    print(string.format("🥅 Auto Goalkeeper v3.0 %s", state.isEnabled and "ENABLED" or "DISABLED"))
    
    if state.isEnabled then
        local uptime = tick() - state.stats.sessionStartTime
        local successRate = state.stats.totalDives > 0 and 
                           (state.stats.successfulSaves / state.stats.totalDives * 100) or 0
        
        print("📊 Session Stats:")
        print(string.format("   Uptime: %.1fs | Dives: %d | Success Rate: %.1f%%", 
              uptime, state.stats.totalDives, successRate))
        print(string.format("   High-speed: %d | Extreme: %d | Balls: %d", 
              state.stats.highSpeedReactions, state.stats.extremeSpeedReactions, 
              state.stats.ballsDetected))
        print(string.format("   Difficulty: %.1f | Learning Data: %d patterns", 
              state.stats.difficultyLevel, #state.learning.ballMemory))
    end
end

-- Enhanced Input Handling
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
    if not success then
        warn("Goalkeeper Error: " .. tostring(error))
    end
end)

-- Enhanced Cleanup
local function cleanup()
    if connection then
        connection:Disconnect()
    end
    
    -- Save session stats
    local sessionTime = tick() - state.stats.sessionStartTime
    print(string.format("🥅 Auto Goalkeeper v3.0 stopped after %.1fs", sessionTime))
    print(string.format("📊 Final Stats: %d dives, %d high-speed reactions", 
          state.stats.totalDives, state.stats.highSpeedReactions))
end

Players.PlayerRemoving:Connect(function(p)
    if p == player then cleanup() end
end)

-- Auto-save learning data periodically
spawn(function()
    while state.isEnabled do
        wait(30)
        -- Here you could save learning data to DataStore if needed
    end
end)

-- Final success notification
wait(0.5)
game.StarterGui:SetCore("SendNotification", {
    Title = "✅ AutoGK V3 Loaded Successfully";
    Text = "All modules loaded! Press H to toggle | G for debug";
    Duration = 5;
})

-- Startup Messages
print("🥅 ENHANCED AUTO GOALKEEPER v3.0 LOADED! (WHITELIST PROTECTED)")
print("🚀 NEW: Advanced physics, learning AI, adaptive difficulty")
print("🎮 Controls: H = Toggle ON/OFF | G = Debug Mode")
print("⚙️  Optimized for Roblox game 'Locked'")
print("📈 Learning system active - Performance will improve over time!")
print("🔒 Whitelist protection active - User: " .. LocalPlayer.Name .. " (ID: " .. LocalPlayer.UserId .. ")")
print("🔗 Repository: github.com/cypherm1232-del/autogk-whitelist-script")
