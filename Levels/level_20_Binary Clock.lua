local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 50
level.y = 10
level.name = "FLIPFLOPFUN"

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = nil
level.y_val = nil

local flag = false
local wait = 0
-- IMPORTANT FUNCTIONS --
function level.load()
-- CREATE GRID -- grid is made to the specified dimensions, and drawbox is defined (by default, x fits to screen and y is centered)
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
  
-- PREPARE LEVEL -- use grid.set(...) or grid.fit(...)
--grid.fit(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState)
	for i=0,3 do
		placeDFF(5+i*12,3)
	end
	
	grid.set(TYPE_MIRROR, 3, 5, {state =  0, rotation = 0, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, 2, 6, {state =  0, rotation = 0, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_DELAY, 2, 5, {state =  5, delay = 30})
	grid.set(TYPE_LOGIC,3,6,{state = LOGIC_NOT}):setSides("out","out",nil,"in")
	grid.set(TYPE_LOGIC,10,6,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out","in","in")
	grid.set(TYPE_LOGIC,49,4,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("out",nil,"out","in")

	wait = game_time
-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
end

function level.update(dt) -- dt is time since last update in seconds
-- CHECK WIN CONDITION -- use grid functions to check object states, update level.complete accordingly
  if win_condition then level.complete = true end

-- OPTIONAL INTERACTIVE LEVEL FUNCTIONS -- direct modifications of object states do not trigger and UpdateObjectType flag! (Needs to be done manually)
	if flag == false and game_time > wait + 0.1 then
		flag = true
		for i=0,3 do
			grid.set(TYPE_LOGIC,5+i*12+1,5,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out","in",nil)
			grid.set(TYPE_LOGIC,5+i*12+5,6,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out",nil,"in")
		end
	end
end

function placeDFF(x,y) -- coor en haut a gauche (9X7)
	grid.set(TYPE_LOGIC,x,y+5,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out","in",nil)
	grid.set(TYPE_LOGIC,x+1,y+5,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides("out","out",nil,"in")
	grid.set(TYPE_LOGIC,x+1,y+2,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out","in","in")
	grid.set(TYPE_LOGIC,x+2,y+2,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides("out",nil,nil,"in")
	grid.set(TYPE_LOGIC,x+2,y+1,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides(nil,"out","in","in")
	grid.set(TYPE_LOGIC,x+3,y+1,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides("out","out","out","in")
	grid.set(TYPE_LOGIC,x+3,y+3,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out","in","in")
	grid.set(TYPE_LOGIC,x+4,y+3,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides(nil,"out","out","in")
	grid.set(TYPE_LOGIC,x+5,y+3,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out","in","in")
	grid.set(TYPE_LOGIC,x+6,y+3,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides("out","out","out","in")
	grid.set(TYPE_LOGIC,x+6,y+1,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides(nil,"out","in","in")
	grid.set(TYPE_LOGIC,x+7,y+1,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides(nil,"out",nil,"in")
	grid.set(TYPE_LOGIC,x+8,y+1,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("out",nil,"out","in")
	grid.set(TYPE_RECEIVER, x+8, y-1, {color=COLOR_WHITE, rotation=2})
	grid.set(TYPE_LOGIC,x,y+3,{state = LOGIC_OR, canMove = true, canRotate = true}):setSides("out","out",nil,"in")
	grid.set(TYPE_MIRROR, x+1, y, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+3, y, {state =  0, rotation = 0, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x, y+1, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x, y+4, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+4, y+4, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+3, y+5, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+5, y+2, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+8, y+2, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x, y+6, {state =  0, rotation = 0, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+6, y+6, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
end

return level

--[[

function placeDFF(x,y) -- coor en haut a gauche (9X6)
	grid.set(TYPE_LOGIC,x,y+5,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out",nil,"in")
	grid.set(TYPE_LOGIC,x+1,y+5,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides("out","out",nil,"in")
	grid.set(TYPE_LOGIC,x+1,y+2,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out","in",nil)
	grid.set(TYPE_LOGIC,x+2,y+2,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides("out",nil,nil,"in")
	grid.set(TYPE_LOGIC,x+2,y+1,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides(nil,"out","in","in")
	grid.set(TYPE_LOGIC,x+3,y+1,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides("out","out","out","in")
	grid.set(TYPE_LOGIC,x+3,y+3,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out","in","in")
	grid.set(TYPE_LOGIC,x+4,y+3,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides(nil,"out","out","in")
	grid.set(TYPE_LOGIC,x+5,y+3,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides("in","out",nil,"in")
	grid.set(TYPE_LOGIC,x+6,y+3,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides("out","out",nil,"in")
	grid.set(TYPE_LOGIC,x+6,y+1,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides(nil,"out","in","in")
	grid.set(TYPE_LOGIC,x+7,y+1,{state = LOGIC_NOT, canMove = true, canRotate = true}):setSides(nil,"out",nil,"in")
	grid.set(TYPE_LOGIC,x+8,y+1,{state = LOGIC_AND, canMove = true, canRotate = true}):setSides(nil,"out","out","in")
	grid.set(TYPE_LOGIC,x,y+3,{state = LOGIC_OR, canMove = true, canRotate = true}):setSides("out","out",nil,"in")
	grid.set(TYPE_MIRROR, x+1, y, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+3, y, {state =  0, rotation = 0, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x, y+1, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x, y+4, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+4, y+4, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+3, y+5, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+5, y+2, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
	grid.set(TYPE_MIRROR, x+8, y+2, {state =  0, rotation = 1, color =  COLOR_WHITE, canMove = true, canRotate = true, canChangeColor =  true})
end

]]