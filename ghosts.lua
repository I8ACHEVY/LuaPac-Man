-- Fantom Blue --

function SetState(self, state)
    if state == 'fantom' and self.state == 'exitHome' then
        return
    end

    self.state = state
    local reset
    if self.direction == 'up' then
        reset = 'down'
    elseif self.direction == 'right' then
        reset = 'left'
    elseif self.direction == 'down' then
        reset = 'up'
    else
        reset = 'left'
    end
    self.nextDecision = reset
end

local function distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

local fantomAtlas = love.graphics.newImage('assets/images/fantomesPacman5.png')

local function getNextTile(self)
    local roundX, roundY = Round(self.x), Round(self.y)
    if self.direction == 'left' then
        return roundX - 1, roundY
    elseif self.direction == 'right' then
        return roundX + 1, roundY
    elseif self.direction == 'up' then
        return roundX, roundY - 1
    elseif self.direction == 'down' then
        return roundX, roundY + 1
    end
end

local function getSurfaceTile(x, y)
    return
    {
        -- Obstacle[y - 1][x],
        -- Obstacle[y][x + 1],
        -- Obstacle[y + 1][x],
        -- Obstacle[y][x - 1],
        Obstacle[y - 1] and Obstacle[y - 1][x] or 0,
        Obstacle[y] and Obstacle[y][x + 1] or 0,
        Obstacle[y + 1] and Obstacle[y + 1][x] or 0,
        Obstacle[y] and Obstacle[y][x - 1] or 0,
    }
end

local function update(self, dt)
    if self.state == 'goHome' then
        if Round(self.x) == Round(self.startX) and Round(self.y) == Round(self.startY) then
            self:init()
            return
        else
            local dx = Round(self.startX) - self.x
            local dy = Round(self.startY) - self.y
            self.x = self.x + dt * self.speed * self.speedBoost * dx * 0.8
            self.y = self.y + dt * self.speed * self.speedBoost * dy * 0.8
            return
        end
    end

    if Round(self.x) == Round(pacMan.x) and Round(self.y) == Round(pacMan.y) then
        if self.state == 'fantom' then
            SoundGnom:play()
            pacMan.successfulCatch = math.min(pacMan.successfulCatch + 1, 5)
            pacMan.score = pacMan.score + CatchPoint[pacMan.successfulCatch]
            self.state = 'goHome'
            return
        else
            pacMan_states.game.catch()
        end
    end
    if self.state == 'fantom' then
        self.fantomAtlas = love.graphics.newImage('assets/images/fantomesPacman5.png')
        self.currentAtlas = 'fantomAtlas'
        self.animationDirection = 'fantom'
    else
        self.currentAtlas = 'atlas'
        self.animationDirection = self.direction
    end

    if Round(self.x) < 3 and Round(self.y) == 18 then
        self.x = 27; self.nextX = 26
        return
    end
    if Round(self.x) > 27 and Round(self.y) == 18 then
        self.x = 3; self.nextX = 4
        return
    end

    if Round(self.x) == self.nextX and Round(self.y) == self.nextY then
        self.direction = self.nextDecision

        local nX, nY = getNextTile(self)
        local surfaceObstacle = getSurfaceTile(nX, nY)

        local dist = {}
        for i = 1, #surfaceObstacle do
            repeat
                if surfaceObstacle[i] == 1 then
                    break
                end
                if i == 1 and self.direction == 'down' then
                    break
                end
                if i == 2 and self.direction == 'left' then
                    break
                end
                if i == 3 and self.direction == 'up' then
                    break
                end
                if i == 4 and self.direction == 'right' then
                    break
                end
                if i == 1 then
                    table.insert(dist, {
                        dist = math.abs(distance(self.targetX, self.targetY, nX, nY - 1)),
                        x = nX,
                        y = nY - 1,
                        dir =
                        "up"
                    })
                elseif i == 2 then
                    table.insert(dist, {
                        dist = math.abs(distance(self.targetX, self.targetY, nX + 1, nY)),
                        x = nX + 1,
                        y = nY,
                        dir =
                        "right"
                    })
                elseif i == 3 then
                    table.insert(dist, {
                        dist = math.abs(distance(self.targetX, self.targetY, nX, nY + 1)),
                        x = nX,
                        y = nY + 1,
                        dir =
                        "down"
                    })
                elseif i == 4 then
                    table.insert(dist, {
                        dist = math.abs(distance(self.targetX, self.targetY, nX - 1, nY)),
                        x = nX - 1,
                        y = nY,
                        dir =
                        "left"
                    })
                end
            until true
        end

        if self.state == 'fantom' then
            table.sort(dist, function(a, b)
                local aa = love.math.random()
                return aa % 2 > 1
            end)
        else
            table.sort(dist, function(a, b) return a.dist < b.dist end)
        end

        self.nextX = nX
        self.nextY = nY

        self.nextDecision = dist[1].dir
    end

    if self.direction == 'left' or self.direction == 'right' then
        if self.y % 1 ~= 0 then
            self.y = Round(self.y)
        end
    elseif self.direction == 'up' or self.direction == 'down' then
        if self.x % 1 ~= 0 then
            self.x = Round(self.x)
        end
    end

    if self.direction == 'left' then
        self.dirX = -1
        self.dirY = 0
    elseif self.direction == 'right' then
        self.dirX = 1
        self.dirY = 0
    elseif self.direction == 'up' then
        self.dirX = 0
        self.dirY = -1
    elseif self.direction == 'down' then
        self.dirX = 0
        self.dirY = 1
    end
    if not self.state == 'fantom' then
        self.animationDirection = self.direction
    end
    self.x = self.x + dt * self.speed * self.speedBoost * self.dirX
    self.y = self.y + dt * self.speed * self.speedBoost * self.dirY
end

local function draw(self)
    -- self.fantomAtlas = love.graphics.newImage('assets/images/fantomesPacman5.png')
    if self.blink then
        love.graphics.setColor(1, 1, 1, self.blinkTime % 1)
    end

    love.graphics.draw(self[self.currentAtlas], self.sprites[self.animationDirection][self.keyframe],
        (self.x - 1) * Scale + Scale * 0.5,
        (self.y - 1) * Scale + Scale * 0.5,
        self.angle,
        self.scaleSignX * 1.6,
        self.scaleSignY * 1.6,
        16 * 0.5,
        16 * 0.5)
    if self.blink then
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Red Ghost --

Ghost_red = {
    startX = 14.5,
    startY = 15,
    x = 14.5,
    y = 15,
    timer = 0,
    speed = 7.4,
    color = { r = 1, g = 0, b = 0, a = 0.7 },
    dirX = 0,
    dirY = 0,
    direction = "right",
    animationDirection = "right",
    currentAtlas = "atlas",
    keyframe = 1,
    numberFrame = 2,
    fps = 5,
    angle = 0,
    scaleSignX = 1,
    scaleSignY = 1,
    state = "scatter",
    targetX = 25,
    targetY = 1,
    speedBoost = 0.75,
    nextDecision = "right",
    nextX = 16,
    nextY = 15,
    chaseIter = 1,
    scatterIter = 1,
    blink = false,
    blinkTime = 0
}
Ghost_red.animationTimer = 1 / Ghost_red.fps
Ghost_red.atlas = love.graphics.newImage('assets/images/fantomesPacman4.png')
Ghost_red.fantomtAtlas = fantomAtlas
Ghost_red.sprites = {}
Ghost_red.sprites.right = {
    love.graphics.newQuad(4 * 16, 0, 16, 16, Ghost_red.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_red.atlas:getDimensions()),
}
Ghost_red.sprites.down = {
    love.graphics.newQuad(2 * 16, 0, 16, 16, Ghost_red.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_red.atlas:getDimensions()),
}
Ghost_red.sprites.left = {
    love.graphics.newQuad(4 * 16, 0, 16, 16, Ghost_red.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_red.atlas:getDimensions()),
}
Ghost_red.sprites.up = {
    love.graphics.newQuad(6 * 16, 0, 16, 16, Ghost_red.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_red.atlas:getDimensions()),
}
Ghost_red.sprites.fantom = {
    love.graphics.newQuad(0 * 16, 0, 16, 16, fantomAtlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, fantomAtlas:getDimensions()),
}


Ghost_red.draw = function(self)
    draw(self)
end

Ghost_red.update = function(self, dt)
    self.timer = self.timer + dt
    if self.state == 'chase' then
        self.speedBoost = Levels[Level].ghostSpeed
        self.targetX, self.targetY = Round(pacMan.x), Round(pacMan.y)
        if self.timer >= Levels[Level].chaseTime[self.chaseIter] then
            self.chaseIter = self.chaseIter + 1
            if self.chaseIter > 4 then self.chaseIter = 4 end
            self.timer = 0
            SetState(self, 'scatter')
        end
    elseif self.state == 'scatter' then
        self.speedBoost = Levels[Level].ghostSpeed
        if self.timer >= Levels[Level].scatterTime[self.scatterIter] then
            self.scatterIter = self.scatterIter + 1
            if self.scatterIter > 4 then
                self.scatterIter = 4
            end
            self.timer = 0
            SetState(self, 'chase')
        end
        self.targetX, self.targetY = 25, 1
    elseif self.state == 'fantom' then
        self.speedBoost = Levels[Level].ghostFantomSpeed
        if self.timer >= Levels[Level].fantomTime then
            pacMan.speedBoost = Levels[Level].pacManSpeed
            self.timer = 0
            self.blink = false
            self.blinkTime = 0
            SetState(self, 'chase')
        elseif self.timer >= Levels[Level].fantomTime - 2 then
            self.blink = true
            self.blinkTime = self.blinkTime + 3 * dt
        end
    end
    update(self, dt)
end

Ghost_red.init = function(self)
    self.startX = 14.5
    self.startY = 15
    self.x = 14.5
    self.y = 15
    self.timer = 0
    self.dirX = 0
    self.dirY = 0
    self.direction = "right"
    self.animationDirection = "right"
    self.currentAtlas = "atlas"
    self.keyframe = 1
    self.angle = 0
    self.scaleSignX = 1
    self.scaleSignY = 1
    self.state = "scatter"
    self.targetX = 25
    self.targetY = 1
    self.speedBoost = Levels[Level].ghostSpeed
    self.nextDecision = "right"
    self.nextX = 16
    self.nextY = 15
    self.blink = false
    self.blinkTime = 0
end

-- Blue Ghost --

Ghost_blue = {
    startX = 14,
    startY = 18,
    x = 14,
    y = 19,
    timer = 0,
    speed = 7.4,
    color = { r = 0, g = 0, b = 1, a = 0.7 },
    dirX = 0,
    dirY = 0,
    direction = "up",
    animationDirection = "up",
    currentAtlas = "atlas",
    keyframe = 1,
    numberFrame = 2,
    fps = 5,
    angle = 0,
    scaleSignX = 1,
    scaleSignY = 1,
    state = "exitHome",
    targetX = 15,
    targetY = 14,
    speedBoost = 0.75,
    nextDecision = "up",
    nextX = 14,
    nextY = 17,
    chaseIter = 1,
    scatterIter = 1,
    blink = false,
    blinkTime = 0
}
Ghost_blue.animationTimer = 1 / Ghost_blue.fps
Ghost_blue.atlas = love.graphics.newImage('assets/images/fantomesPacman.png')
Ghost_blue.fantomtAtlas = fantomAtlas
Ghost_blue.sprites = {}
Ghost_blue.sprites.right = {
    love.graphics.newQuad(4 * 16, 0, 16, 16, Ghost_blue.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_blue.atlas:getDimensions()),
}
Ghost_blue.sprites.down = {
    love.graphics.newQuad(2 * 16, 0, 16, 16, Ghost_blue.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_blue.atlas:getDimensions()),
}
Ghost_blue.sprites.left = {
    love.graphics.newQuad(4 * 16, 0, 16, 16, Ghost_blue.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_blue.atlas:getDimensions()),
}
Ghost_blue.sprites.up = {
    love.graphics.newQuad(6 * 16, 0, 16, 16, Ghost_blue.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_blue.atlas:getDimensions()),
}
Ghost_blue.sprites.fantom = {
    love.graphics.newQuad(0 * 16, 0, 16, 16, fantomAtlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, fantomAtlas:getDimensions()),
}


Ghost_blue.draw = function(self)
    draw(self)
end

Ghost_blue.update = function(self, dt)
    self.timer = self.timer + dt
    if self.state == 'chase' then
        self.speedBoost = Levels[Level].ghostSpeed
        self.targetX, self.targetY = Round(pacMan.x), Round(pacMan.y)
        if self.timer >= Levels[Level].chaseTime[self.chaseIter] then
            self.chaseIter = self.chaseIter + 1
            if self.chaseIter > 4 then self.chaseIter = 4 end
            self.timer = 0
            SetState(self, 'scatter')
        end
    elseif self.state == 'scatter' then
        self.speedBoost = Levels[Level].ghostSpeed
        if self.timer >= Levels[Level].scatterTime[self.scatterIter] then
            self.scatterIter = self.scatterIter + 1
            if self.scatterIter > 4 then
                self.scatterIter = 4
            end
            self.timer = 0
            SetState(self, 'chase')
        end
        self.targetX, self.targetY = 25, 1
    elseif self.state == 'fantom' then
        self.speedBoost = Levels[Level].ghostFantomSpeed
        if self.timer >= Levels[Level].fantomTime then
            pacMan.speedBoost = Levels[Level].pacManSpeed
            self.timer = 0
            self.blink = false
            self.blinkTime = 0
            SetState(self, 'chase')
        elseif self.timer >= Levels[Level].fantomTime - 2 then
            self.blink = true
            self.blinkTime = self.blinkTime + 3 * dt
        end
    end
    update(self, dt)
end

Ghost_blue.init = function(self)
    self.startX = 14
    self.startY = 18
    self.x = 14
    self.y = 19
    self.timer = 0
    self.dirX = 0
    self.dirY = 0
    self.direction = "up"
    self.animationDirection = "up"
    self.currentAtlas = "atlas"
    self.keyframe = 1
    self.angle = 0
    self.scaleSignX = 1
    self.scaleSignY = 1
    self.state = "exitHome"
    self.targetX = 15
    self.targetY = 15
    self.speedBoost = Levels[Level].ghostSpeed
    self.nextDecision = "up"
    self.nextX = 14
    self.nextY = 17
    self.blink = false
    self.blinkTime = 0
end

-- Pink Ghost --

Ghost_pink = {
    startX = 12,
    startY = 18,
    x = 12,
    y = 19,
    timer = 0,
    speed = 7.4,
    color = { r = 1, g = 0, b = 1, a = 0.7 },
    dirX = 0,
    dirY = 0,
    direction = "up",
    animationDirection = "up",
    currentAtlas = "atlas",
    keyframe = 1,
    numberFrame = 2,
    fps = 5,
    angle = 0,
    scaleSignX = 1,
    scaleSignY = 1,
    state = "exitHome",
    targetX = 15,
    targetY = 15,
    speedBoost = 0.75,
    nextDecision = "up",
    nextX = 12,
    nextY = 17,
    chaseIter = 1,
    scatterIter = 1,
    blink = false,
    blinkTime = 0
}
Ghost_pink.animationTimer = 1 / Ghost_pink.fps
Ghost_pink.atlas = love.graphics.newImage('assets/images/fantomesPacman2.png')
Ghost_pink.fantomtAtlas = fantomAtlas
Ghost_pink.sprites = {}
Ghost_pink.sprites.right = {
    love.graphics.newQuad(4 * 16, 0, 16, 16, Ghost_pink.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_pink.atlas:getDimensions()),
}
Ghost_pink.sprites.down = {
    love.graphics.newQuad(2 * 16, 0, 16, 16, Ghost_pink.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_pink.atlas:getDimensions()),
}
Ghost_pink.sprites.left = {
    love.graphics.newQuad(4 * 16, 0, 16, 16, Ghost_pink.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_pink.atlas:getDimensions()),
}
Ghost_pink.sprites.up = {
    love.graphics.newQuad(6 * 16, 0, 16, 16, Ghost_pink.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_pink.atlas:getDimensions()),
}
Ghost_blue.sprites.fantom = {
    love.graphics.newQuad(0 * 16, 0, 16, 16, fantomAtlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, fantomAtlas:getDimensions()),
}


Ghost_pink.draw = function(self)
    draw(self)
end

Ghost_pink.update = function(self, dt)
    self.timer = self.timer + dt
    if self.state == 'chase' then
        self.speedBoost = Levels[Level].ghostSpeed
        self.targetX, self.targetY = Round(pacMan.x), Round(pacMan.y)
        if self.timer >= Levels[Level].chaseTime[self.chaseIter] then
            self.chaseIter = self.chaseIter + 1
            if self.chaseIter > 4 then self.chaseIter = 4 end
            self.timer = 0
            SetState(self, 'scatter')
        end
    elseif self.state == 'scatter' then
        self.speedBoost = Levels[Level].ghostSpeed
        if self.timer >= Levels[Level].scatterTime[self.scatterIter] then
            self.scatterIter = self.scatterIter + 1
            if self.scatterIter > 4 then
                self.scatterIter = 4
            end
            self.timer = 0
            SetState(self, 'chase')
        end
        self.targetX, self.targetY = 25, 1
    elseif self.state == 'fantom' then
        self.speedBoost = Levels[Level].ghostFantomSpeed
        if self.timer >= Levels[Level].fantomTime then
            pacMan.speedBoost = Levels[Level].pacManSpeed
            self.timer = 0
            self.blink = false
            self.blinkTime = 0
            SetState(self, 'chase')
        elseif self.timer >= Levels[Level].fantomTime - 2 then
            self.blink = true
            self.blinkTime = self.blinkTime + 3 * dt
        end
    end
    update(self, dt)
end

Ghost_pink.init = function(self)
    self.startX = 12
    self.startY = 18
    self.x = 12
    self.y = 19
    self.timer = 0
    self.dirX = 0
    self.dirY = 0
    self.direction = "up"
    self.animationDirection = "up"
    self.currentAtlas = "atlas"
    self.keyframe = 1
    self.angle = 0
    self.scaleSignX = 1
    self.scaleSignY = 1
    self.state = "exitHome"
    self.targetX = 15
    self.targetY = 15
    self.speedBoost = Levels[Level].ghostSpeed
    self.nextDecision = "up"
    self.nextX = 12
    self.nextY = 17
    self.blink = false
    self.blinkTime = 0
end

-- Orange Ghost --

Ghost_orange = {
    startX = 12,
    startY = 18,
    x = 12,
    y = 19,
    timer = 0,
    speed = 7.4,
    color = { r = 1, g = 211 / 255, b = 32 / 255, a = 0.7 },
    dirX = 0,
    dirY = 0,
    direction = "up",
    animationDirection = "up",
    currentAtlas = "atlas",
    keyframe = 1,
    numberFrame = 2,
    fps = 5,
    angle = 0,
    scaleSignX = 1,
    scaleSignY = 1,
    state = "exitHome",
    targetX = 15,
    targetY = 14,
    speedBoost = 0.75,
    nextDecision = "up",
    nextX = 16,
    nextY = 17,
    chaseIter = 1,
    scatterIter = 1,
    blink = false,
    blinkTime = 0
}
Ghost_orange.animationTimer = 1 / Ghost_orange.fps
Ghost_orange.atlas = love.graphics.newImage('assets/images/fantomesPacman3.png')
Ghost_orange.fantomtAtlas = fantomAtlas
Ghost_orange.sprites = {}
Ghost_orange.sprites.right = {
    love.graphics.newQuad(4 * 16, 0, 16, 16, Ghost_orange.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_orange.atlas:getDimensions()),
}
Ghost_orange.sprites.down = {
    love.graphics.newQuad(2 * 16, 0, 16, 16, Ghost_orange.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_orange.atlas:getDimensions()),
}
Ghost_orange.sprites.left = {
    love.graphics.newQuad(4 * 16, 0, 16, 16, Ghost_orange.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_orange.atlas:getDimensions()),
}
Ghost_orange.sprites.up = {
    love.graphics.newQuad(6 * 16, 0, 16, 16, Ghost_orange.atlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, Ghost_orange.atlas:getDimensions()),
}
Ghost_orange.sprites.fantom = {
    love.graphics.newQuad(0 * 16, 0, 16, 16, fantomAtlas:getDimensions()),
    love.graphics.newQuad(1 * 16, 0, 16, 16, fantomAtlas:getDimensions()),
}


Ghost_orange.draw = function(self)
    draw(self)
end

Ghost_orange.update = function(self, dt)
    self.timer = self.timer + dt
    if self.state == 'chase' then
        self.speedBoost = Levels[Level].ghostSpeed
        self.targetX, self.targetY = Round(pacMan.x), Round(pacMan.y)
        if self.timer >= Levels[Level].chaseTime[self.chaseIter] then
            self.chaseIter = self.chaseIter + 1
            if self.chaseIter > 4 then self.chaseIter = 4 end
            self.timer = 0
            SetState(self, 'scatter')
        end
    elseif self.state == 'scatter' then
        self.speedBoost = Levels[Level].ghostSpeed
        if self.timer >= Levels[Level].scatterTime[self.scatterIter] then
            self.scatterIter = self.scatterIter + 1
            if self.scatterIter > 4 then
                self.scatterIter = 4
            end
            self.timer = 0
            SetState(self, 'chase')
        end
        self.targetX, self.targetY = 25, 1
    elseif self.state == 'fantom' then
        self.speedBoost = Levels[Level].ghostFantomSpeed
        if self.timer >= Levels[Level].fantomTime then
            pacMan.speedBoost = Levels[Level].pacManSpeed
            self.timer = 0
            self.blink = false
            self.blinkTime = 0
            SetState(self, 'chase')
        elseif self.timer >= Levels[Level].fantomTime - 2 then
            self.blink = true
            self.blinkTime = self.blinkTime + 3 * dt
        end
    end
    update(self, dt)
end

Ghost_orange.init = function(self)
    self.startX = 16
    self.startY = 18
    self.x = 16
    self.y = 19
    self.timer = 0
    self.dirX = 0
    self.dirY = 0
    self.direction = "up"
    self.animationDirection = "up"
    self.currentAtlas = "atlas"
    self.keyframe = 1
    self.angle = 0
    self.scaleSignX = 1
    self.scaleSignY = 1
    self.state = "exitHome"
    self.targetX = 15
    self.targetY = 15
    self.speedBoost = Levels[Level].ghostSpeed
    self.nextDecision = "up"
    self.nextX = 16
    self.nextY = 17
    self.blink = false
    self.blinkTime = 0
end
