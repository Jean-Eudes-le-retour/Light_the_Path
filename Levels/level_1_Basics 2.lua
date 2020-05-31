local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.
local ui_elements = require("ui_elements")

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 9
level.y = 6
level.name = "Basics 2"

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = nil
level.y_val = nil

local m = false
local dialog_num = 1
local flag1 = false
local flag2 = false

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
  grid.set(TYPE_RECEIVER, 5, 1, {rotation = 2, color = COLOR_RED})
  grid.set(TYPE_RECEIVER, 8, 3, {rotation = 3, color = COLOR_GREEN})
  
  grid.set(TYPE_MIRROR, 2, 2, {rotation = 1, color = COLOR_RED})
  
  grid.set(TYPE_SOURCE, 2, 3, {rotation = 1, color = COLOR_YELLOW})

-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
	m = ui_elements.create(UI_DIALOG)
	m.text = {
  {{0.5,0.5,0.5},"Let's give you a quick crash course on how this laboratory works!"},
  {{0.5,0.5,0.5},"To get started, try to position the ",{1,0,0},"RED",{0.5,0.5,0.5}," mirror such that light gets diverted into the ",{1,0,0},"RED",{0.5,0.5,0.5}," receiver up top. Then turn on the ",{1,1,0},"YELLOW",{0.5,0.5,0.5}," laser with ",{0,0,0},"RIGHT CLICK",{0.5,0.5,0.5},". Note that you can rotate certain objects with your ",{0,0,0},"SCROLL WHEEL",{0.5,0.5,0.5}," when hovering over them."}}
	m.charname = {"Professeur Luminario", "Professeur Luminario"}
	m.animation[1] = {}
	m.animation[1][0] = {4,-1}
	m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
	m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
	m.animation[1][3] = m.animation[1][1]
	m.animation[2] = m.animation[1]
	m:resize()
end

function level.update(dt) -- dt is time since last update in seconds
-- CHECK WIN CONDITION -- use grid functions to check object states, update level.complete accordingly

  if grid.getState(5, 4)==2 and level.complete==false then
    m:close()
    level.complete = true
    m = ui_elements.create(UI_DIALOG)
    m.text = {{{1,1,0},"A WINNER IS YOU!",{0.5,0.5,0.5}," You finished this level! PLZ gIvE ",{1,1,0},"5 stR",{0.5,0.5,0.5}," on aPp sTor"}}
    m.charname = {"YAAY"}
    m.animation[1] = {}
    m.animation[1][0] = {4,-1}
    m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[1][3] = m.animation[1][1]
    m:resize()
  end

-- OPTIONAL INTERACTIVE LEVEL FUNCTIONS -- direct modifications of object states do not trigger and UpdateObjectType flag! (Needs to be done manually)
   --when the laser splits and hits red and green, pause and then change the color of the source to cyan and the color of the mirror to blue but do not rotate the mirror
  if dialog_num==1 and m.page==2 then
    m.noSkip = true
    m.isBlocking = false
  end
  if grid.getState(5, 1)==2 and dialog_num==1 then
    m:close()
    dialog_num = dialog_num + 1
    m = ui_elements.create(UI_DIALOG)
    m.text = {
{{0.5,0.5,0.5},"Good! As you can see, a dichroic mirror reflects only part of the incoming laser. Here, the ",{1,1,0},"YELLOW",{0.5,0.5,0.5}," laser, which is a combination of ",{1,0,0},"RED",{0.5,0.5,0.5}," and ",{0,1,0},"GREEN",{0.5,0.5,0.5},", sees its ",{1,0,0},"RED",{0.5,0.5,0.5}," part get diverted while the ",{0,1,0},"GREEN",{0.5,0.5,0.5}," part goes through.\n\nLet's now see what happens with a ",{0,1,1},"CYAN",{0.5,0.5,0.5}," source!"},
{{0.5,0.5,0.5},"Can you see how the ",{0,1,1},"CYAN",{0.5,0.5,0.5}," laser can go through the ",{1,0,0},"RED",{0.5,0.5,0.5}," dichroic mirror? It is because ",{0,1,1},"CYAN",{0.5,0.5,0.5}," is a superposition of ",{0,0,1},"BLUE",{0.5,0.5,0.5}," and ",{0,1,0},"GREEN",{0.5,0.5,0.5},", so it has no ",{1,0,0},"RED",{0.5,0.5,0.5}," constituent to be reflected!"},
{{0.5,0.5,0.5},"Now try to power all of the receivers again."}
                     }
    m.charname = {"Professeur Luminario","Professeur Luminario","Professeur Luminario"}
    m.animation[1] = {}
    m.animation[1][0] = {4,-1}
    m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[1][3] = m.animation[1][1]
	m.animation[2] = m.animation[1]
	m.animation[3] = m.animation[1]
    m:resize()
  end
  
  if dialog_num==2 and m.page==2 then
    if not flag1 then
      flag1 = true
      grid.set(TYPE_WALL, 5, 1)
      grid.set(TYPE_SOURCE, 2, 3, {state = 2, rotation = 1, color = COLOR_CYAN})
    end
  end
  
  if dialog_num==2 and m.page==3 then
    if not flag2 then
      flag2 = true
      grid.set(TYPE_MIRROR, 2, 4, {rotation = 1, color = COLOR_BLUE})
      grid.set(TYPE_RECEIVER, 5, 4, {color = COLOR_BLUE})
      m.noSkip = true
      m.isBlocking = false
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