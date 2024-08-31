pacMan =
{
    x = 14.5,
    y = 24 + 3,
    life = 3,
    score = 0,
    isOnPillEffect = false,
    timer = 0,
    speed = 8,
    speedBoost = 0.8,
    dirX = 0,
    dirY = 0,
    direction = "start",
    keyframe = 1,
    numberFrame = 4,
    fps = 10,
    angle = 0,
    scaleSignX = 1,
    scaleSignY = 1,
    successfulCatch = 0,
    lastScore = 0,
    nextEarnLife = 1
}
pacMan.animationTimer = 1 / pacMan.fps
pacMan.atlas = love.graphics.newImage('assets/images/pacManLana.png');
pacMan.sprites = {
    love.graphics.newQuad(0 * 36, 0, 36, 36, pacMan.atlas:getDimensions()),
    love.graphics.newQuad(1 * 36, 0, 36, 36, pacMan.atlas:getDimensions()),
    love.graphics.newQuad(2 * 36, 0, 36, 36, pacMan.atlas:getDimensions()),
    love.graphics.newQuad(3 * 36, 0, 36, 36, pacMan.atlas:getDimensions()),
}

function pacMan:update(dt)
    if self.isOnPillEffect then
        self.timer = self.timer + dt
        if self.timer >= levels[Level].fantomTime then
            self.isOnPillEffect = false
            self.successfulCatch = 0
        end
    end

    -- Boundary Wrapping --

    local roundX = Round(self.x)
    local roundY = Round(self.y)
    if roundY == 18 then
        if roundX < 3 then
            self.x = 26
            return
        elseif roundX > 27 then
            self.x = 4
            return
        end
    end

    -- Collectables and Fruits --

    local collectableChar = Collectable[roundY][roundX]
    if collectableChar > 0 then
        Collectable[roundY][roundX] = 0
        self:collect(collectableChar)
    end

    local fruitChar = Fruit[roundY][roundX]
    if fruitChar > 0 then
        Fruit[roundY][roundX] = 0
        self:collect('bonus')
    end

    -- Life Increase --

    if self.lastScore < self.nextEarnLife * 10000 and self.score >= self.nextEarnLife * 10000 then
        self.life = self.life + 1
        self.nextEarnLife = self.nextEarnLife + 1
        SoundExtra:play()
    end
    self.lastScore = self.score

    -- Movement --

    --     local nextX = self.x + dt * self.speed * self.speedBoost * self.dirX
    --     local nextY = self.y + dt * self.speed * self.speedBoost * self.dirY
    --     local nextRoundX = Round(nextX)
    --     local nextRoundY = Round(nextY)

    --     if (self.direction == "left" and Obstacle[nextRoundY][nextRoundX - 1] > 0) or
    --         (self.direction == "right" and Obstacle[nextRoundY][nextRoundX + 1] > 0) or
    --         (self.direction == "up" and Obstacle[nextRoundY - 1][nextRoundX] > 0) or
    --         (self.direction == "down" and Obstacle[nextRoundY + 1][nextRoundX] > 0) then
    --         self.dirX, self.dirY = 0, 0
    --         self.x, self.y = nextRoundX, nextRoundY
    --     else
    --         self.x, self.y = nextX, nextY
    --     end
    -- end

    if (self.direction == "left") then
        if Obstacle[roundY][roundX - 1] > 0 then
            self.dirX = 0
            self.x = roundX
        end
    end

    if (self.direction == "right") then
        if Obstacle[roundY][roundX + 1] > 0 then
            self.dirX = 0
            self.x = roundX
        end
    end

    if (self.direction == "up") then
        if Obstacle[roundY - 1][roundX] > 0 then
            self.dirY = 0
            self.y = roundY
        end
    end


    if (self.direction == "down") then
        if Obstacle[roundY + 1][roundX] > 0 then
            self.dirY = 0
            self.y = roundY
        end
    end
    self.x = self.x + dt * self.speed * self.speedBoost * self.dirX
    self.y = self.y + dt * self.speed * self.speedBoost * self.dirY
end

--
function pacMan:draw()
    local sprite = self.sprites[self.keyframe]
    local xPos, yPos = (self.x - 1) * Scale + Scale * 0.5, (self.y - 1) * Scale + Scale * 0.5

    love.graphics.draw(self.atlas, sprite,
        xPos, yPos,
        self.angle,
        self.scaleSignX * 0.8,
        self.scaleSignY * 0.8,
        18, 18)
end

function pacMan:init()
    self.x = 14.5
    self.y = 27
    self.isOnPillEffect = false
    self.timer = 0
    self.speedBoost = levels[Level].pacManSpeed
    self.dirX = 0
    self.dirY = 0
    self.direction = "start"
    self.keyframe = 1
    self.angle = 0
    self.scaleSignX = 1
    self.scaleSignY = 1
    self.successfulCatch = 0
end

function pacMan:collect(item)
    if not SoundDnom:isPlaying() then
        SoundDnom:play()
    end

    if item == 'bonus' then
        self.score = self.score + levels[Level].bonusPoints
        SoundFnom:play()
    elseif item == 8 then
        self.score = self.score + 10
        Dots = Dots - 1
    elseif item == 9 then
        self.score = self.score + 50
        self.isOnPillEffect = true
        self.timer = 0
        Ghost_red.timer = 0
        Ghost_red.blinkTime = 0
        Ghost_red.blink = false
        Ghost_blue.timer = 0
        Ghost_blue.blinkTime = 0
        Ghost_blue.blink = false
        Ghost_pink.timer = 0
        Ghost_pink.blinkTime = 0
        Ghost_pink.blink = false
        Ghost_orange.timer = 0
        Ghost_orange.blinkTime = 0
        Ghost_orange.blink = false

        self.speedBoost = levels[Level].pacManFantomSpeed
        SetState(Ghost_red, 'fantom')
        SetState(Ghost_blue, 'fantom')
        SetState(Ghost_pink, 'fantom')
        SetState(Ghost_orange, 'fantom')

        Dots = Dots - 1
    end
    if Dots <= 0 then
        Level = Level + 1
        if Level >= 3 then Level = 3 end
        pacMan:init()
        Ghost_red:init()
        Ghost_red.chaseIter = 1
        Ghost_red.scatterIter = 1
        Ghost_blue:init()
        Ghost_blue.chaseIter = 1
        Ghost_blue.scatterIter = 1
        Ghost_pink:init()
        Ghost_pink.chaseIter = 1
        Ghost_pink.scatterIter = 1
        Ghost_orange:init()
        Ghost_orange.chaseIter = 1
        Ghost_orange.scatterIter = 1

        Map, Obstacle, Collectable, Fruit = GetMaps()
        ReadyTimer = 4.5
        Dots = 244

        SoundIntro:play()
    elseif Dots == 244 - 70 or Dots == 244 - 170 then
        pacMan_states.game.addBonus()
    end
end

function pacMan:left()
    local roundX = Round(self.x)
    local roundY = Round(self.y)
    if Obstacle[roundY][roundX - 1] == 0 then
        self.dirX = -1
        self.dirY = 0
        self.y = roundY
        self.direction = 'left' or self.direction == 'a'
    end
end

function pacMan:right()
    local roundX = Round(self.x)
    local roundY = Round(self.y)
    if Obstacle[roundY][roundX + 1] == 0 then
        self.dirX = 1
        self.dirY = 0
        self.y = roundY
        self.direction = 'right' or self.direction == 'd'
    end
end

function pacMan:up()
    local roundX = Round(self.x)
    local roundY = Round(self.y)
    if Obstacle[roundY - 1][roundX] == 0 then
        self.dirX = 0
        self.dirY = -1
        self.x = roundX
        self.direction = 'up' or self.direction == 'w'
    end
end

function pacMan:down()
    local roundX = Round(self.x)
    local roundY = Round(self.y)
    if Obstacle[roundY + 1][roundX] == 0 then
        self.dirX = 0
        self.dirY = 1
        self.x = roundX
        self.direction = 'down' or self.direction == 's'
    end
end
