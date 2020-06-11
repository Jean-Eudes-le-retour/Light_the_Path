local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.
local ui_elements = require("ui_elements")

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 17
level.y = 10
level.name = "Prism or... or"
level.track_id = 3

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = -0.5
level.y_val = nil

local m = false
local dialog_num = 1
local last_time = game_time
local flag = {}

-- IMPORTANT FUNCTIONS --
function level.load()
-- CREATE GRID -- grid is made to the specified dimensions, and drawbox is defined (by default, x fits to screen and y is centered)
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
  
-- PREPARE LEVEL -- use grid.set(...) or grid.fit(...)
--grid.fit(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState)
  for i=1,level.x do
    grid.set(TYPE_WALL, i, 1)
    for j=0,3 do grid.set(TYPE_WALL, i, level.y-j) end
  end
  for i=2,level.y-3 do
    grid.set(TYPE_WALL, 1, i)
    grid.set(TYPE_WALL, 2, i)
    grid.set(TYPE_WALL, level.x, i)
  end
  for i=3,8 do
    grid.set(TYPE_WALL, i, 2)
    grid.set(TYPE_WALL, i, 6)
  end
  for i=6,8 do
    grid.set(TYPE_WALL, i, 3)
    grid.set(TYPE_WALL, i, 5)
  end
  for i=2,6 do
    grid.set(TYPE_RECEIVER, level.x-1, i, {color = COLOR_WHITE, rotation = 3})
  end
  grid.set(TYPE_SOURCE, 4, 4, {color = COLOR_WHITE, rotation = 1})
  grid.set(TYPE_MIRROR, 3, 3, {color = COLOR_WHITE})
  grid.set(TYPE_MIRROR, 3, 5, {color = COLOR_WHITE})
-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
	m = ui_elements.create(UI_DIALOG)
	m.text = {
  {{0.5,0.5,0.5},"I just keep complaining to the higher-ups about my complete lack of funding... Look at what it has led us to! 5 receivers to be powered by a single source? \z
  Downright shameful! They'll be hearing from me again!\n\nI don't have any spare sources lying around right now, but I have to confess, I haven't told you everything \z
  there was to know about the... 'prism' as I had referred to it beforehand."},
  {{0.5,0.5,0.5},"You see, it turns out this device is actually one of the countless absolutely groundbreaking inventions I have come up with! I'm sure you're familiar with \z
  the electronics concept of a logical binary OR gate. You substitute electricity for light, and give it three inputs and three outputs fused into a single beam of light: \z
  that's my Photonic OR gate!"},
  {{0.5,0.5,0.5},"So none of this is new to you... But did you know that, being a piece of electronic equipment, it does not simply redirect the light. In fact, it \z
  reemits the output light through all of its outputs! As such, you can duplicate a single light beam into multiple copies of the same, just like you can fuse multiple light \z
  beams into one."},
  {{0.5,0.5,0.5},"I don't usually unlock this functionality, so most of the OR gates you'll find lying around will be locked to the given amount of outputs and inputs. \z
  However, the ones back in the storage room aren't, and I'll gladly lend some to you right now to move forward with your experiments! Simply ",{0,0,0},"RIGHT CLICK",{0.5,0.5,0.5},
  " on the side you wish to modify to cycle throught the port's direction!\n\nNow get back to work!"},
  }
	m.charname = {"Professor Luminario","Professor Luminario","Professor Luminario","Professor Luminario"}
	m.animation[1] = {}
	m.animation[1][0] = {4,-1}
	m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
	m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
	m.animation[1][3] = m.animation[1][1]
  for i=2,4 do m.animation[i] = m.animation[1] end
  m.isBlocking = true
	m:resize()
end

function level.update(dt) -- dt is time since last update in seconds
  local win = true
  for i=1,objects.getId(TYPE_RECEIVER) do
    win = win and (ObjectReferences[TYPE_RECEIVER][i].state == 2)
  end
  if win then level.complete = true end

  if m.page == 4 and not flag[4] then
    if m.finished then
      last_time = 0
      m.isBlocking = false
      m.noSkip = true
    end
    if not flag[1] then
      last_time = game_time+5
      flag[1] = 0
    elseif flag[1]<3 and (game_time - last_time) > 1 then
      grid.insert(TYPE_LOGIC,9,flag[1] + 3,{state=1,canChangeState = true})
      flag[1] = flag[1] + 1
      last_time = game_time
    end
  end
end

return level