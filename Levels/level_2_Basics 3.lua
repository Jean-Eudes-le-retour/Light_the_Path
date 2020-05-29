local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.
local ui_elements = require("ui_elements")

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 9
level.y = 5
level.name = "Basics 3"

local m = false
local dialog_num = 1
local flag1 = false
local flag2 = false
local flag3 = false
local alt1 = false

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
  grid.set(TYPE_RECEIVER, 4, 1, {rotation = 2, color = COLOR_GREEN})
  --grid.set(TYPE_RECEIVER, 6, 1, {rotation = 2, color = COLOR_BLACK})
  --grid.set(TYPE_RECEIVER, 8, 1, {rotation = 2, color = COLOR_BLACK})
  
  grid.set(TYPE_MIRROR, 3, 2, {rotation = 2, color = COLOR_CYAN})
  grid.set(TYPE_MIRROR, 3, 3, {rotation = 2, color = COLOR_GREEN})
  grid.set(TYPE_MIRROR, 3, 4, {rotation = 2, color = COLOR_YELLOW})
  
  grid.set(TYPE_SOURCE, 2, 3, {rotation = 1, color = COLOR_WHITE})

-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
	m = ui_elements.create(UI_DIALOG)
	m.text = {
    {{0.5,0.5,0.5},"Now let's play around with ",{1,1,1},"WHITE",{0.5,0.5,0.5}," light !\nIt is composed of ",{1,0,0},"RED",{0.5,0.5,0.5},", ",{0,1,0},"GREEN",{0.5,0.5,0.5}," and ",{0,0,1},"BLUE",{0.5,0.5,0.5}," light."},
    {{0.5,0.5,0.5},"Just like before, try to activate the ",{0,1,0},"GREEN",{0.5,0.5,0.5}," reciever."}}
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
  if win_condition then level.complete = true end

-- OPTIONAL INTERACTIVE LEVEL FUNCTIONS -- direct modifications of object states do not trigger and UpdateObjectType flag! (Needs to be done manually)
   --when the laser splits and hits red and green, pause and then change the color of the source to cyan and the color of the mirror to blue but do not rotate the mirror
   
  if dialog_num==1 and m.page==2 and alt1 == false then
	m.noSkip = true
	m.isBlocking = false
  end
  
  if dialog_num==1 and m.page==3 then
	m.noSkip = true
	m.isBlocking = false
  end
  
  if dialog_num==2 and m.page==2 then
    if not flag1 then
      flag1 = true
      grid.set(TYPE_RECEIVER, 6, 1, {rotation = 2, color = COLOR_BLUE})
    end
	m.noSkip = true
	m.isBlocking = false
  end
  
  if dialog_num==3 and m.page==2 then
    if not flag2 then
      flag2 = true
      grid.set(TYPE_RECEIVER, 8, 1, {rotation = 2, color = COLOR_RED})
    end
	m.noSkip = true
	m.isBlocking = false
  end
  
  if grid.getState(4, 1)==2 and dialog_num==1 and grid.getColor(4, 3)==COLOR_GREEN then
    m:close()
    dialog_num = dialog_num + 1
    m = ui_elements.create(UI_DIALOG)
    m.text = {
{{0.5,0.5,0.5},"Now that the ",{0,1,0},"GREEN",{0.5,0.5,0.5}," part of the ",{1,1,1},"WHITE",{0.5,0.5,0.5}," light is deflected, there is only the ",{1,0,0},"RED",{0.5,0.5,0.5}," and ",{0,0,1},"BLUE",{0.5,0.5,0.5}," components left. Combined, that gives ",{1,0,1},"MAGENTA",{0.5,0.5,0.5},"."},
{{0.5,0.5,0.5},"Try to illuminate the ",{0,0,1},"BLUE",{0.5,0.5,0.5}," reciever with the available mirrors!"},
    }
    m.charname = {"Professeur Luminario","Professeur Luminario","Professeur Luminario"}
    m.animation[1] = {}
    m.animation[1][0] = {4,-1}
    m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[1][3] = m.animation[1][1]
    m.animation[2] = {}
    m.animation[2][0] = {4,-1}
    m.animation[2][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[2][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[2][3] = m.animation[1][1]
    m:resize()
  end
  
  if grid.getState(4, 1)==2 and dialog_num==1 and grid.getColor(4, 3)==COLOR_CYAN and alt1 == false then
    m:close()
    alt1 = true
    m = ui_elements.create(UI_DIALOG)
    m.text = {
{{0.5,0.5,0.5},"Interesting, the ",{0,1,0},"GREEN",{0.5,0.5,0.5}," receiver turns on when ",{0,1,1},"CYAN",{0.5,0.5,0.5}," light hits it !"},
{{0.5,0.5,0.5},"..."},
{{0.5,0.5,0.5},"Oh wait, that's because the ",{0,1,0},"GREEN",{0.5,0.5,0.5}," part of CYAN is detected !\nWe are going to need the ",{0,1,1},"CYAN",{0.5,0.5,0.5}," mirror later, change it with the ",{0,1,0},"GREEN",{0.5,0.5,0.5}," one for now."},
    }
    m.charname = {"Professeur Luminario","Professeur Luminario","Professeur Luminario"}
    m.animation[1] = {}
    m.animation[1][0] = {4,-1}
    m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[1][3] = m.animation[1][1]
    m.animation[2] = {love.graphics.newImage("Textures/test1.png")}
    m.animation[2][0] = {4,-1}
    m.animation[2][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[2][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[2][3] = m.animation[1][1]
    m.animation[3] = {}
    m.animation[3][0] = {4,-1}
    m.animation[3][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[3][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[3][3] = m.animation[1][1]
    m:resize()
  end
  
  if grid.getState(4, 1)==2 and grid.getState(6, 1)==2 and dialog_num==2 then
    m:close()
    dialog_num = dialog_num + 1
    m = ui_elements.create(UI_DIALOG)
    m.text = {
{{0.5,0.5,0.5},"Can you see how the ",{0,0,1},"BLUE",{0.5,0.5,0.5}," constituent gets reflected even though the mirror is ",{0,1,1},"CYAN",{0.5,0.5,0.5},"? That's because ",{0,1,1},"CYAN",{0.5,0.5,0.5}," is made of ",{0,1,0},"GREEN",{0.5,0.5,0.5}," and ",{0,0,1},"BLUE",{0.5,0.5,0.5}," and because there is no ",{0,1,0},"GREEN",{0.5,0.5,0.5}," in the ",{1,0,1},"MAGENTA",{0.5,0.5,0.5}," beam, there's only some ",{0,0,1},"BLUE",{0.5,0.5,0.5}," that gets reflected."},
{{0.5,0.5,0.5},"Finally, shine the ",{1,0,0},"RED",{0.5,0.5,0.5}," reciever!"},
    }
    m.charname = {"Professeur Luminario","Professeur Luminario","Professeur Luminario"}
    m.animation[1] = {}
    m.animation[1][0] = {4,-1}
    m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[1][3] = m.animation[1][1]
    m.animation[2] = {}
    m.animation[2][0] = {4,-1}
    m.animation[2][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[2][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[2][3] = m.animation[1][1]
    m:resize()
  end
  
  if grid.getState(4, 1)==2 and grid.getState(6, 1)==2 and grid.getState(8, 1)==2 and dialog_num==3 then
    m:close()
    dialog_num = dialog_num + 1
    m = ui_elements.create(UI_DIALOG)
    m.text = {
{{0.5,0.5,0.5},"Remember, in this laboratory ",{1,1,0},"YELLOW",{0.5,0.5,0.5}," light is made of ",{1,0,0},"RED",{0.5,0.5,0.5}," and ",{0,1,0},"GREEN",{0.5,0.5,0.5},"."}}
    m.charname = {"Professeur Luminario","Professeur Luminario","Professeur Luminario"}
    m.animation[1] = {}
    m.animation[1][0] = {4,-1}
    m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[1][3] = m.animation[1][1]
    m:resize()
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