local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.
local ui_elements = require("ui_elements")

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 10
level.y = 6
level.name = "Phosphor Wheel"

local dialog_num = 1
local flag = false
local winCond = false

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
  grid.set(TYPE_RECEIVER, 9, 2, {rotation = 3, color = COLOR_WHITE})
  grid.set(TYPE_PWHEEL, 2, 2, {rotation = 1, color = COLOR_YELLOW})
  
  grid.set(TYPE_MIRROR, 7, 4, {color = COLOR_BLUE})
  grid.set(TYPE_MIRROR, 8, 4, {color = COLOR_BLUE})
  
  grid.set(TYPE_SOURCE, 3, 4, {color = COLOR_BLUE})

-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
	m = ui_elements.create(UI_DIALOG)
	m.text = {
    {{0.5,0.5,0.5},"Now we are going to look at phosphor wheels! But first let's briefly talk about the energy of visible light. The details can get quite complicated but in very short: We can see colors in a spectrum; ",{1,0,0},"RED",{0.5,0.5,0.5},", ",{1,1,0},"YELLOW",{0.5,0.5,0.5},", ",{0,1,0},"GREEN",{0.5,0.5,0.5},", ",{0,1,1},"CYAN",{0.5,0.5,0.5},", ",{0,0,1},"BLUE",{0.5,0.5,0.5},". The closer a color is to ",{0,0,1},"BLUE",{0.5,0.5,0.5},", the more energy it has."},
	{{0.5,0.5,0.5},"Back to phosphor wheels! When a high energy beam hits them, a fluorescence phenomenon happens. That means that a lower energy light is produced. In my laboratory the only light with enough energy to make this phenomenon happen is ",{0,0,1},"BLUE",{0.5,0.5,0.5}," light."},
	{{0.5,0.5,0.5}, "The color of the emitted beam depends on the composition of the phosphor: for example a Y2O2S:Eu3+ coating will result in a ",{1,0,0},"RED",{0.5,0.5,0.5}," color and a ZnO:Zn one in a ",{0,1,0},"GREEN",{0.5,0.5,0.5}," light [1].\n\n[1] Shionoya, Shigeo (1999). 'VI: Phosphors for cathode ray tubes'. Phosphor handbook. Boca Raton, Fla.: CRC Press. ISBN 978-0-8493-7560-6."},
	{{0.5,0.5,0.5},"Here we have a ",{1,1,0},"YELLOW",{0.5,0.5,0.5}," phosphor wheel, commonly used in ",{1,1,1},"WHITE",{0.5,0.5,0.5}," LEDs. When it is illuminated with ",{0,0,1},"BLUE",{0.5,0.5,0.5}," light, it produces ",{1,1,0},"YELLOW",{0.5,0.5,0.5}," light.\n\nTry it out now!"}}
    m.charname = {"Professor Luminario","Professor Luminario","Professor Luminario","Professor Luminario"}
	m.animation[1] = ANIMATION_1
	m.animation[2] = ANIMATION_1
	m.animation[3] = ANIMATION_1
	m.animation[4] = ANIMATION_1
	m:resize()
end

function level.update(dt) -- dt is time since last update in seconds
-- CHECK WIN CONDITION -- use grid functions to check object states, update level.complete accordingly
  if winCond then level.complete = true end

-- OPTIONAL INTERACTIVE LEVEL FUNCTIONS -- direct modifications of object states do not trigger and UpdateObjectType flag! (Needs to be done manually)
  if grid.getState(3, 4)==2 and grid.getState(3, 2)==2 and grid.getColor(3, 2)==COLOR_BLUE and (grid.getRotation(3, 2)==0 or grid.getRotation(3, 2)==2) and dialog_num==1 then
    m:close()
    dialog_num = dialog_num + 1
    m = ui_elements.create(UI_DIALOG)
    m.text = {
{{0.5,0.5,0.5},"Here the ",{0,0,1},"BLUE",{0.5,0.5,0.5}," dichroic mirror is very useful, it directs the ",{0,0,1},"BLUE",{0.5,0.5,0.5}," beam to the phosphor wheel and then when ",{1,1,0},"YELLOW",{0.5,0.5,0.5}," light is produced and reflected back, it lets it go through."},
{{0.5,0.5,0.5},"Lets make ",{1,1,1},"WHITE",{0.5,0.5,0.5}," light with ",{0,0,1},"BLUE",{0.5,0.5,0.5}," sources only!"},
{{0.5,0.5,0.5},"Here is another ",{0,0,1},"BLUE",{0.5,0.5,0.5}," source, turn on the ",{1,1,1},"WHITE",{0.5,0.5,0.5}," receiver!"}
                     }
    m.charname = {"Professor Luminario","Professor Luminario","Professor Luminario"}
    m.animation[1] = ANIMATION_1
    m.animation[2] = ANIMATION_1
    m.animation[3] = ANIMATION_1
    m:resize()
  end 
  if dialog_num==1 and m.page==4 then
    m.noSkip = true
    m.isBlocking = false
  end
  if dialog_num==2 and m.page==3 then
    if not flag then
      flag = true
      grid.insert(TYPE_SOURCE, 5, 4, {color = COLOR_BLUE})
    end
    m.noSkip = true
    m.isBlocking = false
  end
  if grid.getState(9, 2)==2 and dialog_num==2 then
    m:close()
    dialog_num = dialog_num + 1
    m = ui_elements.create(UI_DIALOG)
    m.text = {
{{0.5,0.5,0.5},"That is pretty much how ",{1,1,1},"WHITE",{0.5,0.5,0.5}," LEDs are made."},
{{0.5,0.5,0.5},"To be more accurate, they are made with a transmissive phosphor coating instead of a reflective one like ours. That means that the light goes through the phosphor instead of bouncing from it."},
{{0.5,0.5,0.5},"The coating is also made not to convert all of the ",{0,0,1},"BLUE",{0.5,0.5,0.5}," light into ",{1,1,0},"YELLOW",{0.5,0.5,0.5}," light so that some ",{0,0,1},"BLUE",{0.5,0.5,0.5}," light can still go through. It can then blend directly with the ",{1,1,0},"YELLOW",{0.5,0.5,0.5}," light into ",{1,1,1},"WHITE",{0.5,0.5,0.5}," light."},
}
    m.charname = {"Professor Luminario","Professor Luminario","Professor Luminario"}
    m.animation[1] = ANIMATION_1
    m.animation[2] = ANIMATION_1
    m.animation[3] = ANIMATION_1
    m:resize()
	winCond = true
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