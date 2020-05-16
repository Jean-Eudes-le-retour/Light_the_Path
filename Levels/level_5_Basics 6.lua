local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 9
level.y = 5
level.name = "Basics 6"

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = nil
level.y_val = nil

-- IMPORTANT FUNCTIONS --
function level.load()
-- CREATE GRID -- grid is made to the specified dimensions, and drawbox is defined (by default, x fits to screen and y is centered)
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
  
-- PREPARE LEVEL -- use grid.setNewObject(...) or grid.fitNewObject(...)
--grid.fitNewObject(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState)
  for i=1,level.x do
    grid.setNewObject(TYPE_WALL, i, 1)
	grid.setNewObject(TYPE_WALL, i, level.y)
  end
  for i=1,level.y do
	grid.setNewObject(TYPE_WALL, 1, i)
  end
  grid.setNewObject(TYPE_SOURCE, 1, 2, 1, 1, COLOR_BLUE)
  
  grid.setNewObject(TYPE_MIRROR, 3, 2, 2, 2, COLOR_WHITE)
  grid.setNewObject(TYPE_MIRROR, 3, 4, 2, 2, COLOR_WHITE)
  grid.setNewObject(TYPE_MIRROR, 5, 2, 2, 1, COLOR_WHITE)
  grid.setNewObject(TYPE_MIRROR, 5, 4, 2, 1, COLOR_WHITE)
  grid.setNewObject(TYPE_MIRROR, 7, 2, 2, 2, COLOR_WHITE)
  grid.setNewObject(TYPE_MIRROR, 7, 4, 2, 2, COLOR_WHITE)
  grid.setNewObject(TYPE_MIRROR, 9, 4, 2, 1, COLOR_WHITE)
  
  grid.setNewObject(TYPE_PWHEEL, 9, 2, 1, 2, COLOR_YELLOW)
  
  grid.setNewObject(TYPE_MIRROR, 3, 3, 2, 2, COLOR_YELLOW)
  grid.setNewObject(TYPE_RECEIVER, 1, 3, 1, 1, COLOR_YELLOW)
  
  grid.setNewObject(TYPE_WALL, 4, 2)
  grid.setNewObject(TYPE_WALL, 4, 3)
  grid.setNewObject(TYPE_WALL, 6, 4)
  grid.setNewObject(TYPE_WALL, 6, 3)
  grid.setNewObject(TYPE_WALL, 8, 2)
  grid.setNewObject(TYPE_WALL, 8, 3)
  
  grid.setNewObject(TYPE_WALL, 2, 4)
  
  
-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
end

function level.update(dt) -- dt is time since last update in seconds
-- CHECK WIN CONDITION -- use grid functions to check object states, update level.complete accordingly
  if win_condition then level.complete = true end

-- OPTIONAL INTERACTIVE LEVEL FUNCTIONS -- direct modifications of object states do not trigger and UpdateObjectType flag! (Needs to be done manually)
   --when the laser splits and hits red and green, pause and then change the color of the source to cyan and the color of the mirror to blue but do not rotate the mirror
   
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