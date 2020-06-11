local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.
local ui_elements = require("ui_elements")

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 10
level.y = 6
level.name = "Activate"

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = -0.5
level.y_val = nil

local m = false
local dialog_num = 1
local flag = {}
local s
local last_time = game_time

-- IMPORTANT FUNCTIONS --
function level.load()
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
  
  for i=1,level.x do
    grid.set(TYPE_WALL, i, 1)
    grid.set(TYPE_WALL, i, level.y-1)
    grid.set(TYPE_WALL, i, level.y)
  end
  for i=1,level.y do
    grid.set(TYPE_WALL, 1, i)
    grid.set(TYPE_WALL, level.x, i)
  end
  s = grid.set(TYPE_SOURCE,2,3,{color = COLOR_WHITE, rotation = 1})
  grid.set(TYPE_RECEIVER,4,3,{color = COLOR_WHITE, rotation = 3}):setSides(nil,nil,"activate")
  grid.set(TYPE_MIRROR,5,3,{color = COLOR_WHITE, state = 2, canMove = false, canRotate = false})
-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
	m = ui_elements.create(UI_DIALOG)
	m.text = {
    {{0.5,0.5,0.5},"You've only been here for a couple of minutes, and I'm already feeling a vague air of cluelessness coming from you...\n\nWas the job's \z
    description not clear enough? Oh well, nevermind that, I know just what's on your mind! You must be wondering why on earth you're redirecting light into \z
    random receivers scattered across my optics workbench!"},
    {{0.5,0.5,0.5},"Well! That's clearly... NONE OF YOUR BUSINESS! I don't have time to explain all the minute details of your work to you. Just know that I use \z
    light throughout my laboratory to transmit information, and it so happens my receivers activate other pieces of equipment I have around the place."},
    {{0.5,0.5,0.5},"See here for example, notice the little antenna on the receiver. It's pointing at the mirror.\n\nIn these situations, when the input on the \z
    receiver changes, the mirror is made to rotate by 90 degrees, whether it be welded or not."},
    {{0.5,0.5,0.5},"If the antenna is pointing to a laser, it will power it on on a rising edge, and off on a falling edge."},
    {{0.5,0.5,0.5},"As a general rule of thumbs, unless specified otherwise, a receiver with an antenna does not need to be activated to complete a level.\n\n\z
    Now you should know everything necessary to complete this level. So get back to work! I'm not paying you to give you free lectures!"}
  }
	m.charname = {"Professor Luminario"}
	m.animation[1] = {}
	m.animation[1][0] = {4,-1}
	m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
	m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
	m.animation[1][3] = m.animation[1][1]
	for i=2,5 do
		m.animation[i] = m.animation[1]
		m.charname[i] = "Professor Luminario"
	end
	m:resize()
end

function level.update(dt) -- dt is time since last update in seconds
  if m.page == 3 and game_time - last_time > 1 then
    last_time = game_time
    if not flag[1] then
      flag[1] = true
      last_time = game_time+2
    else
      s:changeState()
    end
  elseif m.page == 4 then
    if not flag[2] then
      flag[2] = true
      grid.set(TYPE_SOURCE,5,3,{color = COLOR_WHITE, rotation = 1})
      if s.state == 2 then s:changeState() end
      last_time = game_time+0.5
    elseif game_time - last_time > 1 then
      last_time = game_time
      s:changeState()
    end
  elseif m.page == 5 then
    if not flag[3] then
      flag[3] = true
      if s.state == 2 then s:changeState() end
      m.isBlocking = false
      grid.delete(4,3)
      grid.delete(5,3)
      grid.set(TYPE_MIRROR,2,2,{color = COLOR_BLUE, rotation = 1})
      grid.set(TYPE_MIRROR,3,2,{color = COLOR_BLUE, rotation = 1})
      grid.set(TYPE_MIRROR,3,3,{color = COLOR_WHITE, rotation = 1})
      grid.set(TYPE_MIRROR,2,4,{color = COLOR_RED, rotation = 1})
      grid.set(TYPE_MIRROR,3,4,{color = COLOR_RED, rotation = 1})
      grid.set(TYPE_RECEIVER,6,2,{color = COLOR_BLUE, rotation = 3}):setSides(nil,nil,"activate")
      grid.set(TYPE_RECEIVER,6,3,{color = COLOR_GREEN, rotation = 3}):setSides(nil,nil,"activate")
      grid.set(TYPE_RECEIVER,6,4,{color = COLOR_RED, rotation = 3}):setSides(nil,nil,"activate")
      grid.set(TYPE_SOURCE,7,4,{color = COLOR_WHITE, glass = true})
      grid.set(TYPE_MIRROR,7,3,{color = COLOR_YELLOW, glass = true})
      grid.set(TYPE_MIRROR,7,2,{color = COLOR_BLUE, glass = true, state = 2})
      grid.set(TYPE_PWHEEL,8,2,{color = COLOR_WHITE, glass = true, state = 2})
      grid.set(TYPE_MIRROR,8,3,{color = COLOR_WHITE, glass = true, state = 2})
      grid.set(TYPE_RECEIVER,9,3,{color = COLOR_WHITE, glass = true, rotation = 3})
      grid.set(TYPE_GLASS,8,4)
      grid.set(TYPE_GLASS,9,4)
      grid.set(TYPE_GLASS,9,2)
    end
  end
  if grid.getState(9,3) == 2 then level.complete = true end
end

return level