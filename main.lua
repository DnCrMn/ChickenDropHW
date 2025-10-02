--game where animals fall from top player clicks
--before hit the bottom
--game ends when animal hits bottom

function love.load()
    nukeImg = love.graphics.newImage("assets/images/nuke.png")
    powerUpImg = love.graphics.newImage("assets/images/power_up.png")
    backgroundImageNormal = love.graphics.newImage("assets/images/bg_normal.png")
    backgroundImageGameOver = love.graphics.newImage("assets/images/bg_game_over.png")
    gameOverText = love.graphics.newImage("assets/images/game_over_text.png")

    math.randomseed(os.time())
    math.random(); math.random(); math.random()
    startx = { math.random(0, love.graphics.getWidth() - nukeImg:getWidth()),
        math.random(0, love.graphics.getWidth() - nukeImg:getWidth()),
        math.random(0, love.graphics.getWidth() - nukeImg:getWidth()),
        math.random(0, love.graphics.getWidth() - nukeImg:getWidth()),
        math.random(0, love.graphics.getWidth() - nukeImg:getWidth()) }
    starty = { 0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2),
        0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2),
        0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2),
        0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2),
        0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2) }

    powerUpStartX = 0
    powerUpStartY = 0

    gameOver = false                  -- Game state
    enablePowerUp = false             -- Enables power up to fall from the top of the screen
    showPowerUp = false               -- Bool that shows the power up in draw

    score = 0                         -- Current score

    timerStart = love.timer.getTime() -- Start time of love timer
    powerUpTimer = 0                  -- Elapsed time of power up on screen
    effectTimer = 0                   -- Elapsed time of power up effect

    nukeSpeed = 80                    -- How fast the nuke falls
    previousSpeed = 80                -- Last speed of the nuke before power up
    powerUpLimit = 3                  -- Time in seconds the power up is visible
    effectLimit = 2                   -- Time in seconds the power up effect is valid
end

-------------------------------------------------
--MOUSE PRESS
--1 = left, 2 = right, 3 = middle wheel
-------------------------------------------------
function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        for i, v in ipairs(startx) do
            if x >= startx[i] and x <= startx[i] + nukeImg:getWidth() and y >= starty[i] and y <= starty[i] + nukeImg:getHeight() then
                score = score + 1 -- Add 1 to score
                -- Randomize starting x and y postion
                startx[i] = math.random(0, love.graphics.getWidth() - nukeImg:getWidth())
                starty[i] = math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2) * -1

                -- Increase nuke speed every 15 score
                if (score % 10 == 0 and score > 0) then
                    nukeSpeed = nukeSpeed + 20 
                end

                -- Get power up every time you get 25 score
                if (score % 25 == 0 and score > 0) then
                    showPowerUp = true
                    powerUpStartX = math.random(0, love.graphics.getWidth() -
                        powerUpImg:getWidth())
                    powerUpStartY = math.random(0, love.graphics.getHeight() -
                        powerUpImg:getHeight())
                    timerStart = love.timer.getTime()
                end
            end
        end

        -- Start power up effect when player clicks the power up
        -- And the sprite is shown
        if (showPowerUp) then
            if x >= powerUpStartX and x <= powerUpStartX + nukeImg:getWidth() and
                y >= powerUpStartY and y <= powerUpStartY + nukeImg:getHeight() then
                powerUpPlayer()
            end
        end
    end
end

-------------------------------------------------
--UPDATE
-------------------------------------------------
function love.update(dt)
    -- Do gameplay stuff until game over
    if (not gameOver) then
        for i, v in ipairs(starty) do
            if starty[i] + nukeImg:getHeight() >= love.graphics.getHeight() then
                gameOver = true
            end
            starty[i] = starty[i] + nukeSpeed * dt
        end
    end

    if (enablePowerUp) then
        timePowerUp()
    end

    if (showPowerUp) then
        powerUpTimer = love.timer.getTime() - timerStart -- Get current time in seconds
        if (powerUpTimer > powerUpLimit) then
            showPowerUp = false
            enablePowerUp = false
        end
    end
end

-------------------------------------------------
--DRAW
-------------------------------------------------
function love.draw()
    -- Draw different background Images depending on
    if (not gameOver) then
        love.graphics.draw(backgroundImageNormal, 0, 0)
    else
        love.graphics.draw(backgroundImageGameOver, 0, 0)
    end

    for i, v in ipairs(startx) do
        love.graphics.draw(nukeImg, startx[i], starty[i])
    end

    -- Only draw power up if it is enabled
    if (showPowerUp) then
        love.graphics.draw(powerUpImg, powerUpStartX, powerUpStartY)
    end

    love.graphics.setNewFont(20) -- Make text bigger
    love.graphics.print("Score: " .. score, 670, 570)
    -- Show game over text when you fail
    if (gameOver) then
        love.graphics.draw(gameOverText, 0, 0)
        love.graphics.print("Press 'r' to try again.", (love.graphics.getWidth() / 2) - 100, 150)
    end
end

-------------------------------------------------
--Key Pressed
--key = key currently pressed in keyboard
-------------------------------------------------
function love.keypressed(key)
    -- If user presses "r", game restarts
    if key == "r" then
        resetGame()
    end
end

-------------------------------------------------
--Reset Game
-------------------------------------------------
function resetGame()
    -- Reinitialize variables
    gameOver = false
    showPowerUp = false
    enablePowerUp = false
    score = 0
    nukeSpeed = 80

    math.randomseed(os.time())
    math.random(); math.random(); math.random()
    startx = { math.random(0, love.graphics.getWidth() - nukeImg:getWidth()),
        math.random(0, love.graphics.getWidth() - nukeImg:getWidth()),
        math.random(0, love.graphics.getWidth() - nukeImg:getWidth()),
        math.random(0, love.graphics.getWidth() - nukeImg:getWidth()),
        math.random(0, love.graphics.getWidth() - nukeImg:getWidth()) }
    starty = { 0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2),
        0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2),
        0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2),
        0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2),
        0 - math.random(nukeImg:getHeight(), nukeImg:getHeight() * 2) }
end

-------------------------------------------------
--Power Up Player
-------------------------------------------------
function powerUpPlayer()
    -- Makes the nuke drop slower
    enablePowerUp = true
    showPowerUp = false
    previousSpeed = nukeSpeed   -- store nuke speed
    nukeSpeed = nukeSpeed / 2 -- slightly slow down the nuke

    -- Start timer for how long the effect should last
    timerStart = love.timer.getTime()
end

-------------------------------------------------
--Reset Power Up effect
-------------------------------------------------
function resetEffect()
    nukeSpeed = previousSpeed
    enablePowerUp = false
end

function timePowerUp()
    effectTimer = love.timer.getTime() - timerStart -- Get current time in seconds

    -- Disable power up effect if time limit has passed
    if (effectTimer > effectLimit) then
        resetEffect()
    end
end
