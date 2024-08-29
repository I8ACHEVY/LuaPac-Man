MapSheet = {}
FruitSheet = {}
HighScore = {}

WindowWidth = 450
WindowHeight = 630
TitleScreen = nil
Font = nil
Map = nil
Scale = 16

SoundVolume = 1
Pause = false
CurrentState = 'title'
Level = 1

CatchPoint = { 200, 400, 800, 1600, 12000 }
ReadyTimer = 4.5
Dots = 244

function love.load()
    require("debug")
    require "pacMan"
    require "ghosts"
    require "pacManStates"
    require "levels"
    GetMaps = require('map')

    love.math.setRandomSeed(love.timer.getTime())
    love.graphics.setDefaultFilter('nearest')
    love.keyboard.setKeyRepeat(true)

    love.window.setMode(WindowWidth, WindowHeight)
    love.window.setTitle('LuaPacMan')


    Font = love.graphics.newFont('assets/fonts/emulogic.ttf', 8)
    love.graphics.setFont(Font)

    TitleScreen = love.graphics.newImage('assets/images/title.png')
    SettingsScreen = love.graphics.newImage('assets/images/settings.png')
    ScoreScreen = love.graphics.newImage('assets/images/highscore.png')
    CreditScreen = love.graphics.newImage('assets/images/credit.png')

    FruitAtlas = love.graphics.newImage('assets/images/fruits.png')

    FruitSheet['cherries'] = love.graphics.newQuad(0 * 16, 0, 16, 16, FruitAtlas:getDimensions())
    FruitSheet['strawberry'] = love.graphics.newQuad(1 * 16, 0, 16, 16, FruitAtlas:getDimensions())
    FruitSheet['peach'] = love.graphics.newQuad(2 * 16, 0, 16, 16, FruitAtlas:getDimensions())
    FruitSheet['apple'] = love.graphics.newQuad(3 * 16, 0, 16, 16, FruitAtlas:getDimensions())
    FruitSheet['grapes'] = love.graphics.newQuad(4 * 16, 0, 16, 16, FruitAtlas:getDimensions())
    FruitSheet['bell'] = love.graphics.newQuad(5 * 16, 0, 16, 16, FruitAtlas:getDimensions())
    FruitSheet['galaxian'] = love.graphics.newQuad(6 * 16, 0, 16, 16, FruitAtlas:getDimensions())
    FruitSheet['key'] = love.graphics.newQuad(6 * 16, 0, 16, 16, FruitAtlas:getDimensions())

    MapAtlas = love.graphics.newImage('assets/images/pacmanSpriteSheet.png')

    MapSheet[1] = love.graphics.newQuad(0 * 16, 0, 16, 16, MapAtlas:getDimensions())
    MapSheet[2] = love.graphics.newQuad(1 * 16, 0, 16, 16, MapAtlas:getDimensions())
    MapSheet[3] = love.graphics.newQuad(2 * 16, 0, 16, 16, MapAtlas:getDimensions())
    MapSheet[4] = love.graphics.newQuad(3 * 16, 0, 16, 16, MapAtlas:getDimensions())
    MapSheet[5] = love.graphics.newQuad(4 * 16, 0, 16, 16, MapAtlas:getDimensions())
    MapSheet[6] = love.graphics.newQuad(5 * 16, 0, 16, 16, MapAtlas:getDimensions())
    MapSheet[9] = love.graphics.newQuad(6 * 16, 0, 16, 16, MapAtlas:getDimensions())
    MapSheet[8] = love.graphics.newQuad(7 * 16, 0, 16, 16, MapAtlas:getDimensions())

    SoundIntro = love.audio.newSource('assets/sfx/pacman_beginning.wav', 'static')
    SoundDnom = love.audio.newSource('assets/sfx/pacman_chomp.wav', 'static')
    SoundDeath = love.audio.newSource('assets/sfx/pacman_death.wav', 'static')
    SoundGnom = love.audio.newSource('assets/sfx/pacman_eatghost.wav', 'static')
    SoundFnom = love.audio.newSource('assets/sfx/pacman_eatfruit.wav', 'static')
    SoundPause = love.audio.newSource('assets/sfx/pacman_intermission.wav', 'static')
    SoundExtra = love.audio.newSource('assets/sfx/pacman_extrapac.wav', 'static')

    GetHighScore()

    SoundIntro:play()
end

function love.update(dt)
    if Pause then return end
    pacMan_states[CurrentState].update(dt)
end

function love.draw()
    pacMan_states[CurrentState].draw()
end

-- Extra Keyboard Options --

function love.keypressed(key)
    if key == 'm' then
        if SoundVolume == 1 then
            SoundVolume = 0
        else
            SoundVolume = 1
        end
        love.audio.setVolume(SoundVolume)
    end
    pacMan_states[CurrentState].keypressed(key)
end

-- Maps --

function DrawMap()
    for a = 1, #Map do
        for b = 1, #Map[a] do
            aa = a - 1
            bb = b - 1
            local curChar = Map[a][b]
            if curChar > 0 then
                love.graphics.draw(MapAtlas, MapSheet[curChar], bb * Scale, aa * Scale, 0, 1, 1)
            end
            local collectChar = Collectable[a][b]
            if collectChar > 0 then
                love.graphics.draw(MapAtlas, MapSheet[collectChar], bb * Scale, aa * Scale, 0, 1, 1)
            end
            local fruitChar = Fruit[a][b]
            if fruitChar > 0 then
                love.graphics.draw(
                    FruitAtlas, FruitSheet[Levels[Level].bonus],
                    aa * Scale + Scale * 0.5,
                    bb * Scale + Scale * 0.5,
                    0, 1.6, 1.6,
                    16 * 0.5, 16 * 0.5
                )
            end
        end
    end
end

function Animation(self, dt)
    self.animationTimer = self.animationTimer - dt
    if self.animationTimer <= 0 then
        self.animationTimer = 1 / self.fps
        self.keyframe = self.keyframe + 1
        if self.keyframe > self.numberFrame then self.keyframe = 1 end
    end
end

function HandleDirection(self)
    if self.direction == 'left' then
        self.scaleSignX = -1
        self.scaleSignY = 1
        self.angle = 0
    elseif self.direction == 'right' then
        self.scaleSignX = -1
        self.scaleSignY = -1
        self.angle = math.pi
    elseif self.direction == 'up' and self == pacMan then
        self.scaleSignX = -1
        self.scaleSignY = 1
        self.angle = math.pi * 0.5
    elseif self.direction == 'down' and self == pacMan then
        self.scaleSignX = -1
        self.scaleSignY = 1
        self.angle = math.pi * 3 * 0.5
    end
end

-- Greatest Number as Output --

function Round(value)
    local floor = math.floor(value)
    if (value % 1 >= 0.5) then return floor + 1 end
    return floor
end

-- Value range Safety --

function Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

-- Saving High Score --

function WriteScore()
    local tmp = {}
    tmp[1] = pacMan.score
    for a = 1, #HighScore do
        table.insert(tmp, HighScore[a])
    end
    local reset = ''
    for a = 1, #tmp do
        reset = reset .. tmp[a] .. '\n'
    end
    local file = io.open('highscore.score', 'w+')
    f:write(reset)
    f:close()
end

function FileExists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function LinesFrom(file)
    if not FileExists(file) then return { 0 } end
    Lines = {}
    for line in io.lines(file) do
        Lines[#Lines + 1] = tonumber(line)
    end
    return Lines
end

function GetHighScore()
    if FileExists('highscore.score') then
        HighScore = LinesFrom('highscore.score')
    else
        local file = io.open('highscore.score', 'w')
        --       f:write('0')
        f:close()
        HighScore = { 0 }
    end
end
