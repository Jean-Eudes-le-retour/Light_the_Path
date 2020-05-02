local debugUtils = require("debugUtils")
local objects = require("objects")
local bit = require("bit")
local bnot, band, bor, rshift, lshift = bit.bnot, bit.band, bit.bor, bit.rshift, bit.lshift


-- THE MODULE MUST BE INITIALIZED; grid.init is grid.setDimensions
local grid = {}

local grid_size_x = 16*2 --DEFAULT
local grid_size_y = 9 *2 --DEFAULT
local texture_scale = 1  --PLACEHOLDER
local tile_size = TEXTURE_BASE_SIZE --PLACEHOLDER
local drawbox_pos_x, drawbox_pos_y = 0, 0
local cursor_grid_pos_x, cursor_grid_pos_y = 0, 0

-- Change the grid's dimensions; also refer to grid.defineDrawbox
function grid.setDimensions(x_res,y_res,mode,x_val,y_val)
  Grid = {} -- GLOBAL VARIABLE
  if type(x_res) == "number" then grid_size_x = math.floor(x_res) end
  if type(y_res) == "number" then grid_size_y = math.floor(y_res) end
  grid.clearGrid()
  -- maybe attempt to place objects back into the grid here (rather than resetting the objects in clearGrid())
  return grid.defineDrawbox(mode,x_val,y_val)
end
grid.init = grid.setDimensions

-- Returns the grid's dimensions (which are local to prevent external modifications)
function grid.getDimensions()
  return grid_size_x, grid_size_y
end

-- Clears the grid of all objects and resets all objects
function grid.clearGrid()
  for i=1,grid_size_x do
    Grid[i]={}
  end
  objects.resetObjects()
end

-- Place a new object within the grid. The preferred function to create new objects.
function grid.setNewObject(t,xpos,ypos,state,rotation,colour,canMove,canChangeState,canChangeColour)
  if xpos > grid_size_x or ypos > grid_size_y or xpos < 1 or ypos < 1 then return nil end
  if Grid[xpos][ypos] then Grid[xpos][ypos]:delete() end
  Grid[xpos][ypos] = objects.newObject(t,xpos,ypos,state,rotation,colour,canMove,canChangeState,canChangeColour)
  return true
end

-- Will attempt to move an object from one point to another within the grid (Might want to make the function ignore 'canMove' and test this externally before moving?)
function grid.moveObject(o,xpos,ypos,old_xpos,old_ypos)
  if Grid[xpos][ypos] then
    local dest_o = Grid[xpos][ypos]
    if dest_o.canMove then
      Grid[old_xpos][old_ypos] = o
      return false
    else
      dest_o:changePosition(old_xpos,old_ypos)
      Grid[old_xpos][old_ypos] = dest_o
    end
  end
  o:changePosition(xpos,ypos)
  Grid[xpos][ypos] = o
  return true
end

-- Deletes the object from the grid. Then deletes the object from ObjectReferences table via Object:delete(); garbage collection should handle the rest.
function grid.deleteObject(xpos,ypos,o)
  o = o or Grid[xpos][ypos] -- if object is passed directly, it takes precedence on the coordinates (can call deleteObject(nil,nil,Object))
  if not o then return false end
  Grid[o.xpos][o.ypos] = nil -- assumes correct info is stored in the object (shouldn't be an issue)
  o:delete()
  return true
end

-- Returns whether t string matches the object at x and y OR if not specified, the object at x and y
function grid.checkGrid(xpos,ypos,t)
  if t then
    if Grid[xpos] and Grid[xpos][ypos] and Grid[xpos][ypos].t == t then return true end
    return false
  end
  if Grid[xpos] and Grid[xpos][ypos] then return Grid[xpos][ypos].t end
  return nil
end

-- Function calculates the variables necessary to define the grid's visual bounding box.
-- All arguments are optional, will do x-perfect-fit y-centered by default; mode needs to contain "y" to fit to y instead;
-- Secondary axis alignment depends on "l"/"t" for left and "r"/"b" for right (equivalent to top and bottom);
-- x_val and y_val represent distance to screen edge (positive values on primary axis results in smaller box)
function grid.defineDrawbox(mode,x_val,y_val) 
  local x_dim, y_dim = love.graphics.getDimensions()
  local x_grid, y_grid = grid.getDimensions()
  x_val, y_val = x_val or 0, y_val or 0
  drawbox_pos_x, drawbox_pos_y = 0, 0

--DEBUG INFO--
  debugUtils.print({x_dim,y_dim},"pos","|_dim")
  debugUtils.print({x_grid,y_grid},"pos","|_grid")
--------------
  if type(mode) ~= "string" then mode = " " end
  if string.find(mode,"y") then
    x_dim, y_dim = y_dim, x_dim
    x_grid, y_grid = y_grid, x_grid
  end
  texture_scale = x_dim/((x_grid+2*x_val)*TEXTURE_BASE_SIZE)
  tile_size = texture_scale*TEXTURE_BASE_SIZE
  drawbox_pos_x = math.floor(x_val*tile_size)
  if string.find(mode,"l") or string.find(mode,"t") then 
    drawbox_pos_y = math.floor(y_val*tile_size)
  elseif string.find(mode,"r") or string.find(mode,"b") then
    drawbox_pos_y = math.floor(y_dim-(y_grid+y_val)*tile_size)
  else
    drawbox_pos_y = math.floor((y_dim-y_grid*tile_size)/2)
  end

  if string.find(mode,"y") then drawbox_pos_x, drawbox_pos_y = drawbox_pos_y, drawbox_pos_x end
--DEBUG INFO--
  debugUtils.print(texture_scale,"texture scale factor")
  debugUtils.print({drawbox_pos_x,drawbox_pos_y},"pos","DRAWBOX_|_POS")
--------------
  return drawbox_pos_x, drawbox_pos_y, texture_scale
end

function grid.updatePosition(cursor_pos_x,cursor_pos_y)
  if not cursor_pos_x then cursor_pos_x, cursor_grid_pos_y = love.mouse.getPosition() end
  cursor_grid_pos_x = math.ceil((cursor_pos_x-drawbox_pos_x)/tile_size)
  cursor_grid_pos_y = math.ceil((cursor_pos_y-drawbox_pos_y)/tile_size)
  return cursor_grid_pos_x, cursor_grid_pos_y
end

function grid.getPosition()
  return cursor_grid_pos_x, cursor_grid_pos_y
end

--Return top left corner outer pixel coordinates of specified tile
function grid.getTilePosition(grid_pos_x, grid_pos_y)
  return math.floor(drawbox_pos_x+(grid_pos_x-1)*tile_size), math.floor(drawbox_pos_y+(grid_pos_y-1)*tile_size)
end

-- NOTE THAT THESE FUNCTIONS DO NOT NEED TO BE IN GRID, IN FACT THEY SHOULD PROBABLY BE MOVED TO ANOTHER MODULE AS THEY DOESN'T REALLY RELATE TO THE GRID
-- Used exclusively in updateWallState(), do not use.
function grid.checkWallAt(xpos,ypos,state,index,update_self)
  if Grid[xpos] and Grid[xpos][ypos] and Grid[xpos][ypos].t == TYPE_WALL then
    state = state + lshift(1,index)
    if update_self then updateWallState(xpos,ypos,false) end
  end
  index = index+1
  return state, index
end
-- Update wall data of wall at x,y and neighbors if updateNeighbors. Foolproof. If nothing specified updates all walls in the game (includes non-placed walls)
function grid.updateWallState(xpos,ypos,updateNeighbors)
  local index = 0
  local state = 0
  local wallIsPresent = false
  if updateNeighbors == nil then updateNeighbors = true end
  if xpos and ypos then
    wallIsPresent = grid.checkGrid(xpos,ypos,TYPE_WALL)
    for i=xpos-1,xpos+1 do
      state, index = grid.checkWallAt(i,ypos-1,state,index,updateNeighbors)
    end
    state, index = grid.checkWallAt(xpos+1,ypos,state,index,updateNeighbors)
    for i=xpos+1,xpos-1,-1 do
      state, index = grid.checkWallAt(i,ypos+1,state,index,updateNeighbors)
    end
    state, index = grid.checkWallAt(xpos-1,ypos,state,index,updateNeighbors)
    if not wallIsPresent then return end

    -- code allowing comparison of 15 possible wall states
    -- invert state to represent empty space with bits instead of walls
    state = band(bnot(state),255)
    -- an empty space in cardinal directions renders the information on corner blocks useless - reduce possible configurations
    if band(state,2)~=0 then state = bor(state,7) end
    if band(state,8)~=0 then state = bor(state,28) end
    if band(state,32)~=0 then state = bor(state,112) end
    if band(state,128)~=0 then state = bor(state,193) end
    -- rotate the configuration clockwise and compare with table
    local old_bit1 = 0
    local old_bit2 = 0
    for i=0,3 do
      if WALL_STATE_CONFIGURATIONS[state] then
        Grid[xpos][ypos].state = WALL_STATE_CONFIGURATIONS[state]
        Grid[xpos][ypos].rotation = (-i)%4
        return true
      end
      old_bit1 = band(state,1) ~= 0 and 64 or 0
      old_bit2 = band(state,2) ~= 0 and 128 or 0
      state = bor(rshift(state,2),(old_bit1+old_bit2))
    end
    return false
  else
    for i=1,objects.getID(TYPE_WALL) do
      local o = ObjectReferences[TYPE_WALL][i]
      if o then grid.updateWallState(o.xpos,o.ypos,false) end -- extra precaution in case objects were externally deleted
    end
    return true
  end
end

return grid