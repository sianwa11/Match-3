require 'src/Dependencies'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

function love.load()
  --nearest neighbour function
  love.graphics.setDefaultFilter('nearest','nearest')

  --title
  love.window.setTitle('Match 3')

  math.randomseed(os.time())

  --initializevirtual resolution
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    resizable = true
  })

  -- set music to loop and start
  -- gSounds['music']:setLooping(true)
  -- gSounds['music']:play()

  --initialize state machine
  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['begin-game'] = function() return BeginGameState() end,
    ['play'] = function() return PlayState() end,
    ['game-over'] = function() return GameOverState() end
  }
  gStateMachine:change('start')

  --keep track of scrolling our background
  backgroundX = 0
  backgroundScrollSpeed = 80

  --initialize input table
  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.keypressed(key)
  -- add to our table of keys pressed this frame
  love.keyboard.keysPressed[key] = true
end


function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
  --scroll background across all states
  backgroundX = backgroundX - backgroundScrollSpeed * dt

  --if we've scrolled entire image, reset to 0
  if backgroundX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
    backgroundX = 0
  end

  gStateMachine:update(dt)

  love.keyboard.keypressed = {}
end

function love.draw()
  push:start()

  love.graphics.draw(gTextures['background'], backgroundX, 0)

  gStateMachine:render()
  push:finish()
end
