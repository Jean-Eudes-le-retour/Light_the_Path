local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.
local ui_elements = require("ui_elements")

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 13
level.y = 8
level.name = "Dichroic Prism"

local dialog_num = 1
local flag = {}

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
    grid.set(TYPE_WALL, i, level.y-1)
    grid.set(TYPE_WALL, i, level.y)
  end
  for i=1,level.y do
    grid.set(TYPE_WALL, 1, i)
    grid.set(TYPE_WALL, level.x, i)
  end
    grid.set(TYPE_RECEIVER, 7, 2, {rotation = 2, color = COLOR_WHITE})
  
    grid.set(TYPE_MIRROR, 3, 5, {rotation = 1, color = COLOR_RED})
    grid.set(TYPE_MIRROR, 4, 5, {rotation = 1, color = COLOR_BLUE})
  
    grid.set(TYPE_SOURCE, 2, 4, {rotation = 1, color = COLOR_RED})
    grid.set(TYPE_SOURCE, 7, 6, {color = COLOR_GREEN})
    grid.set(TYPE_SOURCE, 12, 5, {rotation = 3, color = COLOR_BLUE})
-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
	m = ui_elements.create(UI_DIALOG)
	m.text = {
    {{0.5,0.5,0.5},"We saw earlier that you could extract the three primary ",{1,0,0},"CO",{0,1,0},"LO",{0,0,1},"RS",{0.5,0.5,0.5}," from ",{1,1,1},"WHITE",{0.5,0.5,0.5},", but we can also do the reverse! Here we have a ",{1,0,0},"RED",{0.5,0.5,0.5},", a ",{0,1,0},"GREEN",{0.5,0.5,0.5}," and a ",{0,0,1},"BLUE",{0.5,0.5,0.5}," laser source. Using the dichroic mirrors, make all beams overlap each other."}}
    m.charname = {"Professor Luminario"}
    m.animation[1] = ANIMATION_1
    m:resize()
end

function level.update(dt) -- dt is time since last update in seconds
  if grid.getState(7, 2)==2 and dialog_num==1 then
    m:close()
    dialog_num = dialog_num + 1
    m = ui_elements.create(UI_DIALOG)
    m.text = {
{{0.5,0.5,0.5},"You just made a dichroic prism! It is used in almost all projectors, I'll show you why in just a moment."},
{{0.5,0.5,0.5},"Instead of always using two elements, people have engineered it into a single element. In my laboratory it looks like this."},
{{0.5,0.5,0.5},"By blocking the different channels we can create different colors: ",{1,0,0},"RED",{0.5,0.5,0.5}," ..."},
{{0.5,0.5,0.5},"... ",{1,1,0},"YELLOW",{0.5,0.5,0.5}," ..."},
{{0.5,0.5,0.5},"... ",{0,1,0},"GREEN",{0.5,0.5,0.5}," ..."},
{{0.5,0.5,0.5},"... ",{0,1,1},"CYAN",{0.5,0.5,0.5}," ..."},
{{0.5,0.5,0.5},"... ",{0,0,1},"BLUE",{0.5,0.5,0.5}," ..."},
{{0.5,0.5,0.5},"... ",{1,0,1},"MAGENTA",{0.5,0.5,0.5}," ..."},
{{0.5,0.5,0.5},"... And technically ",{0,0,0},"BLACK",{0.5,0.5,0.5},", the absence of color."},
{{0.5,0.5,0.5},"This is how all colors are created inside projectors. The details on how the beams are blocked and how to make darker shades of color, notably brown are missing from my laboratory. I think I left them at home, but if you are interested you can always search for 'digital micromirror devices' on the interwebs or whatever."},
    }
    m.charname = {"Professor Luminario","Professor Luminario","Professor Luminario","Professor Luminario","Professor Luminario","Professor Luminario","Professor Luminario","Professor Luminario","Professor Luminario","Professor Luminario"}
	for i=1,10 do
		m.animation[i] = ANIMATION_1
	end
	m:resize()
  end
  if dialog_num==1 then
    m.noSkip = true
    m.isBlocking = false
  end
  if dialog_num==2 and m.page==2 then
    if not flag[1] then
      flag[1] = true
      grid.delete(12,5)
      grid.delete(7,5)
      grid.set(TYPE_LOGIC, 7, 4,{state = LOGIC_OR}):setSides("out","in","in","in")
      grid.set(TYPE_SOURCE, 12, 4, {rotation = 3, state = 2, color = COLOR_BLUE})
    end
  end
  if dialog_num==2 and m.page==3 then
    if not flag[2] then
      flag[2] = true
      grid.set(TYPE_WALL,8,4)
      grid.set(TYPE_WALL,7,5)
      grid.delete(6,4)
    end
  end
  if dialog_num==2 and m.page==4 then
    if not flag[3] then
      flag[3] = true
      grid.set(TYPE_WALL,8,4)
      grid.delete(6,4)
      grid.delete(7,5)
    end
  end
  if dialog_num==2 and m.page==5 then
    if not flag[4] then
      flag[4] = true
      grid.set(TYPE_WALL,6,4)
      grid.set(TYPE_WALL,8,4)
      grid.delete(7,5)
    end
  end
  if dialog_num==2 and m.page==6 then
    if not flag[5] then
      flag[5] = true
      grid.set(TYPE_WALL,6,4)
      grid.delete(8,4)
      grid.delete(7,5)
    end
  end
  if dialog_num==2 and m.page==7 then
    if not flag[6] then
      flag[6] = true
      grid.set(TYPE_WALL,6,4)
      grid.set(TYPE_WALL,7,5)
      grid.delete(8,4)
    end
  end
  if dialog_num==2 and m.page==8 then
    if not flag[7] then
      flag[7] = true
      grid.set(TYPE_WALL,7,5)
      grid.delete(6,4)
      grid.delete(8,4)
    end
  end
  if dialog_num==2 and m.page==9 then
    if not flag[8] then
      flag[8] = true
      grid.set(TYPE_WALL,8,4)
      grid.set(TYPE_WALL,6,4)
      grid.set(TYPE_WALL,7,5)
    end
  end
  if dialog_num==2 and m.page==10 then
    if not flag[9] then
      flag[9] = true
      level.complete = true
    end
  end
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