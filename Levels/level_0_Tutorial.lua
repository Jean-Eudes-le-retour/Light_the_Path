local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.
local ui_elements = require("ui_elements")

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 9
level.y = 6
level.name = "Tutorial"

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = nil
level.y_val = nil

local m = false
local dialog_num = 1
local flag = {}

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
-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
	m = ui_elements.create(UI_DIALOG)
	m.text = {
  {{0.5,0.5,0.5},"Welcome to my laboratory! I will present to you all of my gadgets and gizmos that I use for my reseach and teach you how to use them. (Click here to continue...)"},
  {{0.5,0.5,0.5},"This is my optics workbench!\n...Ok it may look a bit bland but that's because it is empty. Still, you can see lighter squares; that's where you will be able to put objects and interact with them, and darker squares that represent walls that will block the laser beams."},
  {{0.5,0.5,0.5},"Let's add some basic pieces of equipement!"},
  {{0.5,0.5,0.5},"This is a mirror. You can move it with your cursor by dragging it with the ",{0,0,0},"LEFT MOUSE",{0.5,0.5,0.5}," button held down.\n\nYou can also rotate it with the ",{0,0,0},"SCROLL WHEEL",{0.5,0.5,0.5},".\nTry it now !\n\n(When you're finished, click here to continue...)"}, --4 
  {{0.5,0.5,0.5},"Sometimes it will be stuck in place but will still be able to spin. It will then look like it is on a metal disc:"}, --5 canRotate = false
  {{0.5,0.5,0.5},"And other times it will be stuck in place and won't be able to spin. That's when it is welded to a sheet of metal:"}, --6 canRotate = false canMove = false
  {{0.5,0.5,0.5},"Now let's have some fun ! Here is a laser source. You can turn it on by ",{0,0,0},"RIGHT CLICKING",{0.5,0.5,0.5}, " it.\nNotice how it is also welded to a metal sheet and therefore cannot be moved nor turned."} --7 wait for the player to turn on the laser
  }
	m.charname = {"Professeur Luminario"}
	m.animation[1] = {}
	m.animation[1][0] = {4,-1}
	m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
	m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
	m.animation[1][3] = m.animation[1][1]
	for i=2,9 do
		m.animation[i] = m.animation[1]
		m.charname[i] = "Professeur Luminario"
	end
	m:resize()
end

function level.update(dt) -- dt is time since last update in seconds
-- CHECK WIN CONDITION -- use grid functions to check object states, update level.complete accordingly

  if grid.getState(5, 2)==2 and level.complete==false then
    m:close()
    level.complete = true
    m = ui_elements.create(UI_DIALOG)
    m.text = {{{1,1,0},"You finished your first level!",{0.5,0.5,0.5},"\nI will start to talk about more specialised tools in the next few levels."}}
    m.charname = {"Professeur Luminario"}
    m.animation[1] = {}
    m.animation[1][0] = {4,-1}
    m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[1][3] = m.animation[1][1]
    m:resize()
  end

-- OPTIONAL INTERACTIVE LEVEL FUNCTIONS -- direct modifications of object states do not trigger and UpdateObjectType flag! (Needs to be done manually)
   --when the laser splits and hits red and green, pause and then change the color of the source to cyan and the color of the mirror to blue but do not rotate the mirror
  if dialog_num==1 and m.page==4 then
    if not flag[1] then
      flag[1] = true
      grid.set(TYPE_MIRROR, 5, 3)
	  m.isBlocking = false
    end
  end
  if dialog_num==1 and m.page==5 then
    if not flag[2] then
		flag[2] = true
		for i=2,8 do
		  grid.delete(i, 2)
		  grid.delete(i, 3)
		  grid.delete(i, 4)
		end
		grid.set(TYPE_MIRROR, 5, 3, {state=2,canMove=false})
		m.isBlocking = false
    end
  end
  if dialog_num==1 and m.page==6 then
    if not flag[3] then
      flag[3] = true
      grid.set(TYPE_MIRROR, 5, 3, {state=2,canMove=false, canRotate=false})
	  m.isBlocking = false
    end
  end
  if dialog_num==1 and m.page==7 then
    if not flag[4] then
      flag[4] = true
      grid.set(TYPE_SOURCE, 2, 3, {rotation=1,color=COLOR_CYAN})
	  m.isBlocking = false
	  m.noSkip = true
    end
  end
  if dialog_num==1 and grid.getState(2,3)==2 then
	dialog_num=dialog_num+1
    m:close()
    m = ui_elements.create(UI_DIALOG)
    m.text = {
	{{0.5,0.5,0.5},"...Shiny..."},
	{{0.5,0.5,0.5},"Now this laser beam has to go somewhere ! Let's introduce the receiver. It will turn on when correcty colored light hit it. Most of the time you will need to turn all of the receiver on to finish the challenges.\nTry it out !"} --9 wait for receiver to turn on
}
    m.charname = {"Professeur Luminario","Professeur Luminario"}
    m.animation[1] = {}
    m.animation[1][0] = {4,-1}
    m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
    m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
    m.animation[1][3] = m.animation[1][1]
    m.animation[2] = m.animation[1]
    m:resize()
  end
  if dialog_num==2 and m.page==2 then
    if not flag[5] then
      flag[5] = true
		grid.set(TYPE_MIRROR, 2, 2)
		grid.set(TYPE_RECEIVER, 5, 2, {rotation=2, color=COLOR_CYAN})
		grid.delete(5, 3)
	  m.isBlocking = false
	  m.noSkip = true
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