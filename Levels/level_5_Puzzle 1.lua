local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 18
level.y = 11
level.name = "Puzzle 1"

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = nil
level.y_val = nil

-- IMPORTANT FUNCTIONS --
function level.load()
-- CREATE GRID -- grid is made to the specified dimensions, and drawbox is defined (by default, x fits to screen and y is centered)
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
  
-- PREPARE LEVEL -- use grid.set(...) or grid.fit(...)
--grid.fit(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState)
  for i=1,level.x do
    grid.set(TYPE_WALL, i, 1)
    grid.set(TYPE_WALL, i, level.y)
  end
  for i=1,level.y do
	grid.set(TYPE_WALL, 1, i)
	grid.set(TYPE_WALL, level.x, i)
  end
  
  for i=4,(level.x-2) do
    grid.set(TYPE_WALL, i, 3)
  end
  grid.set(TYPE_WALL, 4, 2)
  for i=2,4 do
    grid.set(TYPE_WALL, i, 7)
  end
  for i=6, 10 do
    grid.set(TYPE_WALL, i, 7)
  end
  for i=12, 16 do
    grid.set(TYPE_WALL, i, 7)
  end
  
  grid.set(TYPE_SOURCE, 2, 9, {rotation =  1, state =  1, color =  COLOR_WHITE})
  
  grid.set(TYPE_RECEIVER, 5, 2, {rotation =  1, color =  COLOR_RED})
  grid.set(TYPE_RECEIVER, 3, 2, {rotation =  2, color =  COLOR_YELLOW})
  
  grid.set(TYPE_MIRROR, 17, 7, {state =  1, color =  COLOR_YELLOW, canMove = false, canRotate = false})
  grid.set(TYPE_MIRROR, 11, 7, {state =  1, color =  COLOR_MAGENTA, canMove = false, canRotate = false})
  grid.set(TYPE_MIRROR, 5, 7, {state =  1, color =  COLOR_CYAN, canMove = false, canRotate = false})
  
  --player objects

  grid.set(TYPE_MIRROR, 10, 9, {state =  1, color =  COLOR_RED})
  grid.set(TYPE_MIRROR, 11, 9, {state =  1, color =  COLOR_GREEN})
  grid.set(TYPE_MIRROR, 13, 9, {state =  1, color =  COLOR_WHITE})
  grid.set(TYPE_MIRROR, 14, 9, {state =  1, color =  COLOR_WHITE})
  grid.set(TYPE_MIRROR, 15, 9, {state =  1, color =  COLOR_WHITE})
  grid.set(TYPE_MIRROR, 16, 9, {state =  1, color =  COLOR_WHITE})
  
  grid.set(TYPE_LOGIC, 6, 9,{state = LOGIC_OR, canMove = true, canRotate = true}):setSides("in","in","in","out")
  
  grid.set(TYPE_PWHEEL, 8, 9, {state =  2, rotation = 1, color =  COLOR_RED, canMove = true, canRotate = true})

-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
end

function level.update(dt) -- dt is time since last update in seconds
-- CHECK WIN CONDITION -- use grid functions to check object states, update level.complete accordingly
  if grid.getState(3, 2)==2 and grid.getState(5, 2)==2 then level.complete = true end

-- OPTIONAL INTERACTIVE LEVEL FUNCTIONS -- direct modifications of object states do not trigger and UpdateObjectType flag! (Needs to be done manually)

end

return level

--[[

-- LIST OF NOTEWORTHY GLOBAL VARIABLES --

>>    Grid     << All operations to modify Grid should go through grid functions UNLESS you know what you're doing!
table with Grid[x][y] (within game boundary) contaning nil or an Object

>>  canvas_OL  << Love canvases, are drawn in love.draw()
>>  canvas_BG  << 
canvas for the Overlay and the Background respectively; dimensions are (TEXTURE_BASE_SIZE*level.x,TEXTURE_BASE_SIZE*level.y)
They are updated (and thus reset) before level.update() ONLY IF global flags UpdateOverlayFG (->sort of a lie but effect is the same from outside perspective) and UpdateBackgroundFG evaluate to true
(which would be impossible in a regular game without developer mode enabled);

>>  game_time  << (double) The current time since start of the game in seconds. Do not modify.

_________________________________________________________________

ENUMS for readability -- NO ASSIGNMENTS or else everything breaks
_________________________________________________________________

TYPE_WALL, TYPE_GLASS, TYPE_SOURCE, TYPE_RECEIVER, TYPE_MIRROR, TYPE_PWHEEL, TYPE_PRISM;
COLOR_RED, COLOR_GREEN, COLOR_YELLOW, COLOR_BLUE, COLOR_MAGENTA, COLOR_CYAN, COLOR_WHITE, COLOR_BLACK;
Note that color 0 is treated the same as COLOR_BLACK (8); also note that a black receiver is not always in an active state, rather it is treated as an "any" receiver [to be implemented]

If unsure about the default configuration of each object, check objects.lua for the default objects.
Duly note that hasMask, rotateByEights and canChangeState are only defined within the default objects and not every single object.

_________________________________________________________________

FUN IDEAS
_________________________________________________________________
You can change level.x_val, level.y_val, level.drawbox_mode and call love.resize() (with 3rd argument dontResetUI true for efficiency) to emulate a screenshake!
Custom backgrounds with draw operations to background canvas!
Custom drawing on walls ith draw operations to overlay canvas!

]]