local positions = {}

StartState = Class{__includes = BaseState}

function StartState:init()
  --currentky selected menu item
  self.currentMenuItem = 1

  --colours we'll use to change the title text
  self.colors = {
    [1] = {0.8, 0.3, 0.3, 1},
    [2] = {0.4, 0.8, 0.9, 1},
    [3] = {0.9, 0.9, 0.2, 1},
    [4] = {0.4, 0.3, 0.5, 1},
    [5] = {0.6, 0.8, 0.3, 1},
    [6] = {0.8, 0.4, 0.1, 1}
  }

  --letterrs of MATCH 3 and their spacing relative to the center
  self.letterTable = {
    {'M', -108},
    {'A', -64},
    {'T', -28},
    {'C', 2},
    {'H', 40},
    {'3', 112}
  }

  --time for a color change if its been a half of a second
  self.colorTimer = Timer.every(0.075, function()
    --shift every colour to the next, looping the last to front
    --assign it to 0 so the loop below moves it to 1
    self.colors[0] = self.colors[6]

    for i = 6, 1, -1 do
      self.colors[i] = self.colors[i - 1]
    end
  end)

  --generate full table of tiles just for display
  for i = 1, 64 do
    table.insert(positions, gFrames['tiles'][math.random(18)][math.random(6)])
  end

  --used to animate our full screen transition rect
  self.transitionAlpha = 0

  --if we've selected an option we need to pause input while we animate out
  self.pauseInput = false
end

function StartState:update(dt)
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end

  -- as long as can still input, i.e., we're not in a transition...
  if not self.pauseInput then
    --change menu selection

    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
      self.currentMenuItem = self.currentMenuItem == 1 and 2 or 1
      gSounds['select']:play()
    end

    -- switch to another state via one of the menu options

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
      if self.currentMenuItem == 1 then

        -- tween, using Timer, the transition rect's alpha to 255, then
        -- transition to the BeginGame state after the animation is over
        Timer.tween(1, {
          [self] = {transitionAlpha = 1}
        }):finish(function()
          gStateMachine:change('begin-game', {
            level = 1
          })

          --remove color timer from timer
          self.colorTimer:remove()
        end)
      else
        love.event.quit()
      end

      --turn off input during transition
      self.pauseInput = true
    end
  end

  --update out Timer which will be used for fade transition
  Timer.update(dt)
end

function StartState:render()
  --render all tiles and their drop shadows
  for y = 1, 8 do
    for x = 1, 8 do
      --render shadow first
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x],
        (x - 1) * 32 + 128 + 3, (y - 1) * 32 + 16 + 3)

      --render tile
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x],
        (x - 1) * 32 + 128, (y - 1) * 32 + 16)
    end
  end

  -- keep the background and tiles a little darker than normal
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

  self:drawMatch3Text(-60)
  self:drawOptions(12)

  -- draw our transition rect; is normally fully transparent, unless we're moving to a new state
  love.graphics.setColor(1, 1, 1, self.transitionAlpha)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

--[[
    Draw the centered MATCH-3 text with background rect, placed along the Y
    axis as needed, relative to the center.
]]
function StartState:drawMatch3Text(y)
  --draw semi-transparent rect behind MATCH 3
  love.graphics.setColor(1, 1, 1, 0.5)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y - 11, 150, 58, 6)

  --print MATCH-3 letters in their corresponding current colors
  for i = 1, 6 do
      love.graphics.setColor(self.colors[i])
      love.graphics.printf(self.letterTable[i][1], 0, VIRTUAL_HEIGHT / 2 + y,
          VIRTUAL_WIDTH + self.letterTable[i][2], 'center')
  end
end

--[[
    Draws "Start" and "Quit Game" text over semi-transparent rectangles.
]]
function StartState:drawOptions(y)
  --draw rect behind start and quit game text
  love.graphics.setColor(1, 1, 1, 0.5)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y, 150, 58, 6)


  --draw Start text
  love.graphics.setFont(gFonts['medium'])
  self:drawTextShadow('Start', VIRTUAL_HEIGHT / 2 + y + 8)

  if self.currentMenuItem == 1 then
    love.graphics.setColor(0.4, 0.6, 1, 1)
  else
    love.graphics.setColor(0.2, 0.3, 0.5, 1)
  end

  love.graphics.printf('Start', 0, VIRTUAL_HEIGHT / 2 + y + 8, VIRTUAL_WIDTH, 'center')

  --draw Quit Game text
  love.graphics.setFont(gFonts['medium'])
  self:drawTextShadow('Quit Game', VIRTUAL_HEIGHT / 2 + y + 33)

  if self.currentMenuItem == 2 then
    love.graphics.setColor(0.4, 0.6, 1, 1)
  else
    love.graphics.setColor(0.2, 0.3, 0.5, 1)
  end

  love.graphics.printf('Quit Game', 0, VIRTUAL_HEIGHT / 2 + y + 33, VIRTUAL_WIDTH, 'center')
end

--[[
    Helper function for drawing just text backgrounds; draws several layers of the same text, in
    black, over top of one another for a thicker shadow.
]]
function StartState:drawTextShadow(text, y)
  love.graphics.setColor(0.1, 0.1, 0.2, 1)
  love.graphics.printf(text, 2, y + 1, VIRTUAL_WIDTH, 'center')
  love.graphics.printf(text, 1, y + 1, VIRTUAL_WIDTH, 'center')
  love.graphics.printf(text, 0, y + 1, VIRTUAL_WIDTH, 'center')
  love.graphics.printf(text, 1, y + 2, VIRTUAL_WIDTH, 'center')
end