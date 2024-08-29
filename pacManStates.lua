pacMan_states = {}

pacMan_states.game = {}
pacMan_states.title = {}
pacMan_states.settings = {}
pacMan_states.credit = {}
pacMan_states.score = {}


pacMan_states.game.load = function(dt)
    Map, Obstacle, Collectable, Fruit = GetMaps()
    ReadyTimer = 5
    Level = 1
    pacMan.life = 3
    pacMan.score = 0
    pacMan.lastScore = 0
    pacMan.nextEarnLife = 1
    pacMan:init()
    Ghost_red:init()

    Dots = 244

    SoundIntro:stop()
    SoundPause:play()
end

pacMan_states.game.exit = function()

end

pacMan_states.game.update = function(dt)
    if ReadyTimer >= 0 then
        ReadyTimer = ReadyTimer - dt
        return
    end

    Animation(pacMan, dt)
    Animation(Ghost_red, dt)

    HandleDirection(pacMan)
    HandleDirection(Ghost_red)

    pacMan:update(dt)
    Ghost_red:update(dt)
end

pacMan_states.game.catch = function()
    SoundDeath:play()
    pacMan.life = pacMan.life - 1
    if pacMan.life <= 0 then
        if pacMan.score > HighScore[1] then
            WriteScore()
            HighScore[1] = pacMan.score
        end
        pacMan_states.setState('title')
    end
    pacMan:init()
    Ghost_red:init()

    ReadyTimer = 3
end

pacMan_states.game.addBonus = function()
    local rand = math.random(1, 3)

    if rand == 1 then
        local rx, ry = Ghost_red.x, Ghost_red.y
        if not (rx > 11 and rx < 17 and ry > 16 and ry < 20) or not Ghost_red.state ~= 'goHome' then
            Fruit[Round(ry)][Round(rx)] = 1
        else
            pacMan_states.game.addBonus()
            return
        end
    end
end

pacMan_states.game.draw = function()
    DrawMap()
    pacMan:draw()
    Ghost_red:draw()

    love.graphics.print('High Score', WindowWidth * 0.33, 0, 0, 2, 2)
    love.graphics.print(math.max(HighScore[1], pacMan.score), WindowWidth * 0.40, 23, 0, 2, 2)
    love.graphics.print('1UP', WindowWidth * 0.025, 0, 0, 2, 2)
    love.graphics.print(pacMan.score, WindowWidth * 0.05, 23, 0, 2, 2)
    for i = 1, pacMan.life do
        love.graphics.draw(pacMan.atlas, pacMan.sprites[1], WindowWidth * 0.05 + (32 * i),
            WindowHeight - 32, 0,
            0.8, 0.8)
    end
    if ReadyTimer >= 0 then
        love.graphics.setColor(240, 240, 0, 1)
        love.graphics.print('Ready!', (14.5 - 3) * Scale, 20 * Scale, 0, 2, 1.5)
        love.graphics.setColor(1, 1, 1, 1)
    end
    if Pause then
        love.graphics.setColor(240, 240, 0, 1)
        love.graphics.print('Pause!', (14.5 - 4.5) * Scale, 17 * Scale, 0, 3, 3)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

pacMan_states.game.keypressed = function(key)
    if key == 'left' then
        pacMan:left()
    end

    if key == 'right' then
        pacMan:right()
    end

    if key == 'up' then
        pacMan:up()
    end

    if key == 'down' then
        pacMan:down()
    end

    if key == 'escape' then
        pacMan_states.setState('title')
    end

    if key == 'space' then
        if not Pause then
            Pause = true
        else
            Pause = false
        end
    end
end

-- Title --

Menu = { 'play', 'scores', 'settings', 'credit' }
MenuCursor = 1
MenuPos =
{
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 },
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 + 32 },
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 + 64 },
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 + 96 }
}

pacMan_states.title.load = function()
    MenuCursor = 1
end

pacMan_states.title.exit = function()
end

pacMan_states.title.update = function(dt)
end

pacMan_states.title.keypressed = function(key)
    if key == 'return' then
        if MenuCursor == 1 then
            pacMan_states.setState('game')
        end
        if MenuCursor == 2 then
            pacMan_states.setState('score')
        end
        if MenuCursor == 3 then
            pacMan_states.setState('settings')
        end
        if MenuCursor == 4 then
            pacMan_states.setState('credit')
        end
    end
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'up' then
        MenuCursor = MenuCursor - 1
        if MenuCursor < 1 then
            MenuCursor = #Menu
        end
    end
    if key == 'down' then
        MenuCursor = MenuCursor + 1
        if MenuCursor > #Menu then
            MenuCursor = 1
        end
    end
end

pacMan_states.title.draw = function()
    love.graphics.draw(TitleScreen, 0, 0, 0, 2, 2)
    love.graphics.print(HighScore[1], WindowWidth * 0.40, 60, 0, 2, 2)
    for i, item in ipairs(Menu) do
        love.graphics.print(item, MenuPos[i][1] + 30, MenuPos[i][2], 0, 2, 2)
    end
    love.graphics.print('>', MenuPos[MenuCursor][1], MenuPos[MenuCursor][2], 0, 2, 2)
end

-- settings menu --

SMenu = { 'difficaulty', 'video', 'audio', 'back' }
SMenuCursor = 1
SMenuPos =
{
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 },
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 + 32 },
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 + 64 },
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 + 96 }
}

pacMan_states.settings.load = function()
    SMenuCursor = 1
end

pacMan_states.settings.exit = function()
end

pacMan_states.settings.update = function(dt)
end

pacMan_states.settings.keypressed = function(key)
    if key == 'return' then
        if SMenuCursor == 1 then
            pacMan_states.setState('title')
        end
        if SMenuCursor == 2 then
            pacMan_states.setState('title')
        end
        if SMenuCursor == 3 then
            pacMan_states.setState('title')
        end
        if SMenuCursor == 4 then
            pacMan_states.setState('title')
        end
    end
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'up' then
        SMenuCursor = SMenuCursor - 1
        if SMenuCursor < 1 then
            SMenuCursor = #SMenu
        end
    end
    if key == 'down' then
        SMenuCursor = SMenuCursor + 1
        if SMenuCursor > #SMenu then
            SMenuCursor = 1
        end
    end
end

pacMan_states.settings.draw = function()
    love.graphics.draw(SettingsScreen, 0, 0, 0, 2, 2)
    for i, item in ipairs(SMenu) do
        love.graphics.print(item, SMenuPos[i][1] + 30, SMenuPos[i][2], 0, 2, 2)
    end
    love.graphics.print('>', SMenuPos[SMenuCursor][1], SMenuPos[SMenuCursor][2], 0, 2, 2)
end

-- score menu --

ScMenu = { 'back' }
ScMenuCursor = 1
ScMenuPos =
{
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 + 96 }
}

pacMan_states.score.load = function()
    ScMenuCursor = 1
end

pacMan_states.score.exit = function()
end

pacMan_states.score.update = function(dt)
end

pacMan_states.score.keypressed = function(key)
    if key == 'return' then
        if ScMenuCursor == 1 then
            pacMan_states.setState('title')
        end
    end
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'up' then
        ScMenuCursor = ScMenuCursor - 1
        if ScMenuCursor < 1 then
            ScMenuCursor = #ScMenu
        end
    end
    if key == 'down' then
        ScMenuCursor = ScMenuCursor + 1
        if ScMenuCursor > #ScMenu then
            ScMenuCursor = 1
        end
    end
end

pacMan_states.score.draw = function()
    love.graphics.draw(ScoreScreen, 0, 0, 0, 2, 2)
    for i, item in ipairs(ScMenu) do
        love.graphics.print(item, ScMenuPos[i][1] + 30, ScMenuPos[i][2], 0, 2, 2)
    end
    love.graphics.print('>', ScMenuPos[ScMenuCursor][1], ScMenuPos[ScMenuCursor][2], 0, 2, 2)
end

-- Credit menu --

CMenu = { 'back' }
CMenuCursor = 1
CMenuPos =
{
    { (WindowWidth * 0.35) - 20, WindowHeight * 0.5 + 96 }
}

pacMan_states.credit.load = function()
    CMenuCursor = 1
end

pacMan_states.credit.exit = function()
end

pacMan_states.credit.update = function(dt)
end

pacMan_states.credit.keypressed = function(key)
    if key == 'return' then
        if CMenuCursor == 1 then
            pacMan_states.setState('title')
        end
    end
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'up' then
        CMenuCursor = CMenuCursor - 1
        if CMenuCursor < 1 then
            CMenuCursor = #CMenu
        end
    end
    if key == 'down' then
        CMenuCursor = CMenuCursor + 1
        if CMenuCursor > #CMenu then
            CMenuCursor = 1
        end
    end
end

pacMan_states.credit.draw = function()
    love.graphics.draw(CreditScreen, 0, 0, 0, 2, 2)
    love.graphics.print("Kyle Bowman", 135, 200, 0, 2)
    for i, item in ipairs(CMenu) do
        love.graphics.print(item, CMenuPos[i][1] + 30, CMenuPos[i][2], 0, 2, 2)
    end
    love.graphics.print('>', CMenuPos[CMenuCursor][1], CMenuPos[CMenuCursor][2], 0, 2, 2)
end

pacMan_states.setState = function(state)
    pacMan_states[CurrentState].exit()
    CurrentState = state
    pacMan_states[CurrentState].load()
end
