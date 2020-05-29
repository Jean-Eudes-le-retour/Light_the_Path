local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 22
level.y = 10
level.name = "Projo"

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
  for i=1,level.y do
    grid.set(TYPE_WALL, i, 1, {canMove = true, canRotate = true})
	grid.set(TYPE_WALL, 1, i, {canMove = true, canRotate = true})
  end
  grid.set(TYPE_SOURCE, 2, 3, {state =  1, color =  COLOR_RED, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_SOURCE, 2, 4, {state =  1, color =  COLOR_GREEN, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_SOURCE, 2, 5, {state =  1, color =  COLOR_BLUE, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_SOURCE, 2, 6, {state =  1, color =  COLOR_YELLOW, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_SOURCE, 2, 7, {state =  1, color =  COLOR_MAGENTA, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_SOURCE, 2, 8, {state =  1, color =  COLOR_CYAN, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_SOURCE, 2, 9, {state =  1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
  
  grid.set(TYPE_RECEIVER, 3, 3, {state =  1, color =  COLOR_RED, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_RECEIVER, 3, 4, {state =  1, color =  COLOR_GREEN, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_RECEIVER, 3, 5, {state =  1, color =  COLOR_BLUE, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_RECEIVER, 3, 6, {state =  1, color =  COLOR_YELLOW, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_RECEIVER, 3, 7, {state =  1, color =  COLOR_MAGENTA, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_RECEIVER, 3, 8, {state =  1, color =  COLOR_CYAN, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_RECEIVER, 3, 9, {state =  1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})

  for i=4,6 do
  grid.set(TYPE_MIRROR, i, 3, {state =  1, color =  COLOR_RED, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_MIRROR, i, 4, {state =  1, color =  COLOR_GREEN, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_MIRROR, i, 5, {state =  1, color =  COLOR_BLUE, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_MIRROR, i, 6, {state =  1, color =  COLOR_YELLOW, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_MIRROR, i, 7, {state =  1, color =  COLOR_MAGENTA, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_MIRROR, i, 8, {state =  1, color =  COLOR_CYAN, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_MIRROR, i, 9, {state =  1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
  end
  
  grid.set(TYPE_PWHEEL, 2, 10, {rotation = 1, color = COLOR_YELLOW, canMove = true, canRotate = true})
  grid.set(TYPE_PWHEEL, 3, 10, {rotation = 1, color = COLOR_YELLOW, canMove = true, canRotate = true})
  grid.set(TYPE_PWHEEL, 4, 10, {rotation = 1, color = COLOR_YELLOW, canMove = true, canRotate = true})
  
  grid.set(TYPE_PWHEEL, 7, 3, {state =  1, color =  COLOR_RED, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_PWHEEL, 7, 4, {state =  1, color =  COLOR_GREEN, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_PWHEEL, 7, 5, {state =  1, color =  COLOR_BLUE, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_PWHEEL, 7, 6, {state =  1, color =  COLOR_YELLOW, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_PWHEEL, 7, 7, {state =  1, color =  COLOR_MAGENTA, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_PWHEEL, 7, 8, {state =  1, color =  COLOR_CYAN, canMove = true, canRotate = true, canChangeColor =  true})
  grid.set(TYPE_PWHEEL, 7, 9, {state =  1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})

-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
end

function level.update(dt) -- dt is time since last update in seconds
-- CHECK WIN CONDITION -- use grid functions to check object states, update level.complete accordingly
  if win_condition then level.complete = true end

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