local debugUtils = require("debugUtils")
local objects = require("objects")
local audio = require("audio")

-- THE MODULE MUST BE INITIALIZED; grid.init is grid.setDimensions
local grid = {}

local grid_size_x = 16*2 --DEFAULT
local grid_size_y = 9 *2 --DEFAULT
local texture_scale = 1  --PLACEHOLDER
local texture_scale_factor = 1
local true_texture_scale = 1
local tile_size = TEXTURE_BASE_SIZE --PLACEHOLDER
local drawbox_pos_x, drawbox_pos_y = 0, 0
local drawbox_offset_x, drawbox_offset_y = 0, 0
local true_drawbox_pos_x, true_drawbox_pos_y = 0, 0
local cursor_grid_frac_pos_x, cursor_grid_frac_pos_y = 0, 0
local cursor_grid_pos_x, cursor_grid_pos_y = 0, 0

-- Change the grid's dimensions; also refer to grid.defineDrawbox
function grid.setDimensions(x_res,y_res,mode,x_val,y_val)
  Grid = {} -- GLOBAL VARIABLE
  if type(x_res) == "number" then grid_size_x = math.floor(x_res) end
  if type(y_res) == "number" then grid_size_y = math.floor(y_res) end
  grid.clear()
  local grid_x_pixel_dim, grid_y_pixel_dim = grid_size_x*TEXTURE_BASE_SIZE, grid_size_y*TEXTURE_BASE_SIZE
  UpdateBackgroundFG = true
  canvas_WL = love.graphics.newCanvas( grid_x_pixel_dim, grid_y_pixel_dim )
  canvas_GL = love.graphics.newCanvas( grid_x_pixel_dim, grid_y_pixel_dim )
  canvas_OL = love.graphics.newCanvas( grid_x_pixel_dim, grid_y_pixel_dim )
  canvas_BG = love.graphics.newCanvas( grid_x_pixel_dim, grid_y_pixel_dim )
  canvas_GD = love.graphics.newCanvas( grid_x_pixel_dim, grid_y_pixel_dim )
  for i=1,#TEXTURE_LASER do
    LaserFrame[i] = love.graphics.newCanvas( grid_x_pixel_dim, grid_y_pixel_dim )
  end
  return grid.defineDrawbox(mode,x_val,y_val)
end
grid.init = grid.setDimensions

-- Returns the grid's dimensions (which are local to prevent external modifications)
function grid.getDimensions()
  return grid_size_x, grid_size_y
end

-- Only works for centered-type drawboxes!
function grid.setOffset(x_offset, y_offset, scale_factor)
  drawbox_offset_x = x_offset or drawbox_offset_x
  drawbox_offset_y = y_offset or drawbox_offset_y
  texture_scale_factor = scale_factor or texture_scale_factor
  true_texture_scale = texture_scale_factor*texture_scale
  tile_size = TEXTURE_BASE_SIZE*true_texture_scale
  true_drawbox_pos_x = (love.graphics.getWidth() - tile_size*(2*drawbox_offset_x + grid_size_x))/2
  true_drawbox_pos_y = (love.graphics.getHeight() - tile_size*(2*drawbox_offset_y + grid_size_y))/2
end

function grid.getDrawboxInfo()
  return true_drawbox_pos_x, true_drawbox_pos_y, true_texture_scale
end

-- Clears the grid of all objects and resets all objects
function grid.clear()
  for i=1,grid_size_x do
    Grid[i]={}
  end
  objects.resetObjects()
end

-- Place a new object within the grid. The preferred function to create new objects.
function grid.set(t,xpos,ypos,options) -- state,rotation,color,canMove,canRotate,canChangeColor,glass,canChangeState
  if type(options) ~= "table" then options = {} end
  if xpos > grid_size_x or ypos > grid_size_y or xpos < 1 or ypos < 1 then return nil end
  if Grid[xpos][ypos] then Grid[xpos][ypos]:delete() end
  local o = objects.newObject(t,xpos,ypos,options)
  Grid[xpos][ypos] = o
  return o
end

-- grid.set, but softer, may be preferred when programming a level (will never erase a block at destination)
function grid.fit(t,xpos,ypos,options) -- state,rotation,color,canMove,canRotate,canChangeColor,glass
  if (not xpos) then xpos = math.ceil(grid_size_x/2) end
  if (not ypos) then ypos = math.ceil(grid_size_y/2) end
  for i=0,math.max(grid_size_x-1, grid_size_y-1) do
    for j=-i,i do
      if j == i or j == -i then
        for k=-i,i do
          if (Grid[xpos+k] and (ypos+j>0 and ypos+j<=grid_size_y) and (not Grid[xpos+k][ypos+j])) then 
            return grid.set(t,xpos+k,ypos+j,options)
          end
        end
      elseif (Grid[xpos-i] and (ypos+j>0 and ypos+j<=grid_size_y) and (not Grid[xpos-i][ypos+j])) then
        return grid.set(t,xpos-i,ypos+j,options)
      elseif (Grid[xpos+i] and (ypos+j>0 and ypos+j<=grid_size_y) and (not Grid[xpos+i][ypos+j])) then
        return grid.set(t,xpos+i,ypos+j,options)
      end
    end
  end
  print("Could not fit the "..(t and TYPES[t] or "wall"))
  return nil
end

-- Insert the given object into the grid at given position, moves existing object elsewhere (see grid.fit), can fail if no space remains
function grid.insert(t,xpos,ypos,options)
  if (not xpos) then xpos = math.ceil(grid_size_x/2) end
  if (not ypos) then ypos = math.ceil(grid_size_y/2) end
  local o = grid.fit(t,xpos,ypos,options)
  if o then grid.move(o,xpos,ypos,true) end
  return o
end

-- Will attempt to move an object from one point to another within the grid (Might want to make the function ignore 'canMove' and test this externally before moving?)
function grid.move(o,xpos,ypos,force)
  if not (xpos > grid_size_x or xpos < 1 or ypos > grid_size_y or ypos < 1) then
    if Grid[xpos][ypos] then
      local dest_o = Grid[xpos][ypos]
      if DEVELOPER_MODE or force or (not dest_o.glass and dest_o.canMove) then
        force = true
        dest_o:changePosition(o.xpos,o.ypos)
        Grid[o.xpos][o.ypos] = dest_o
        dest_o:update()
        audio.playSound(2 + objects.getSFXOffset(dest_o.t))
      end -- implicit else force = false
    else
      force = true
    end
    if force then
      o:changePosition(xpos,ypos)
      Grid[xpos][ypos] = o
      o:update()
      audio.playSound(2 + objects.getSFXOffset(o.t))
      return true
    end
  end
  print("Couldn't move the object")
  Grid[o.xpos][o.ypos] = o
  o:update()
  audio.playSound(2 + objects.getSFXOffset(o.t))
  return false
end

-- Deletes the object from the grid. Then deletes the object from ObjectReferences table via Object:delete(); garbage collection should handle the rest; optionally does not delete the object reference.
function grid.delete(xpos,ypos,o,keep_reference)
  o = o or Grid[xpos][ypos] -- if object is passed directly, it takes precedence on the coordinates (can call delete(nil,nil,Object))
  if not o then return false end
  o:update()
  Grid[o.xpos][o.ypos] = nil -- assumes correct info is stored in the object (shouldn't be an issue)
  if not keep_reference then o:delete() end
  return true
end

-- Returns whether t string matches the object at x and y OR if not specified, the object type at x and y
function grid.check(xpos,ypos,t)
  if t then
    if Grid[xpos] and Grid[xpos][ypos] and Grid[xpos][ypos].t == t then return true end
    return false
  end
  if Grid[xpos] and Grid[xpos][ypos] then return Grid[xpos][ypos].t end
  return nil
end
grid.checkGrid = grid.check

function grid.getState(xpos,ypos)
  if Grid[xpos] and Grid[xpos][ypos] then return Grid[xpos][ypos].state end
  return nil
end

function grid.getColor(xpos,ypos)
  if Grid[xpos] and Grid[xpos][ypos] then return Grid[xpos][ypos].color end
  return nil
end

function grid.getRotation(xpos,ypos)
  if Grid[xpos] and Grid[xpos][ypos] then return Grid[xpos][ypos].rotation end
  return nil
end
function grid.getTileSize()
  return tile_size
end
function grid.getTextureScale()
  return true_texture_scale
end

-- Function calculates the variables necessary to define the grid's visual bounding box.
-- All arguments are optional, will do x-perfect-fit y-centered by default; mode needs to contain "y" to fit to y instead;
-- Secondary axis alignment depends on "l"/"t" for left and "r"/"b" for right (equivalent to top and bottom);
-- x_val and y_val represent distance to screen edge (positive values on primary axis results in smaller box)
function grid.defineDrawbox(mode,x_val,y_val) 
  local x_dim, y_dim = love.graphics.getDimensions()
  local x_grid, y_grid = grid.getDimensions()
  x_val, y_val = x_val or 0, y_val or 0
  drawbox_offset_x, drawbox_offset_y, texture_scale_factor = 0, 0, 1
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
  debugUtils.print({drawbox_pos_x,drawbox_pos_y},"pos","drawbox_|_pos")
--------------
  true_drawbox_pos_x, true_drawbox_pos_y, true_texture_scale = drawbox_pos_x, drawbox_pos_y, texture_scale
  return drawbox_pos_x, drawbox_pos_y, texture_scale
end

-- Updates the cursor's position relative to the grid (this is the first operation in game.update() so there should be no reason to use it anywhere else)
function grid.updateCursorPosition(getFraction,cursor_pos_x,cursor_pos_y)
  if not cursor_pos_x then cursor_pos_x, cursor_pos_y = love.mouse.getPosition() end
  cursor_grid_frac_pos_x = (cursor_pos_x-true_drawbox_pos_x)/tile_size
  cursor_grid_frac_pos_y = (cursor_pos_y-true_drawbox_pos_y)/tile_size
  cursor_grid_pos_x = math.ceil(cursor_grid_frac_pos_x)
  cursor_grid_pos_y = math.ceil(cursor_grid_frac_pos_y)
  if getFraction then return cursor_grid_frac_pos_x, cursor_grid_frac_pos_y end
  return cursor_grid_pos_x, cursor_grid_pos_y
end

-- Returns the cursor's position relative to the grid (optionally, if getFraction is defined, the fractional position; (0.5,0.5) is the center of tile (1,1))
function grid.getCursorPosition(getFraction)
  if getFraction then return cursor_grid_frac_pos_x, cursor_grid_frac_pos_y end
  return cursor_grid_pos_x, cursor_grid_pos_y
end

--Return coordinates of specified tile (or position based on grid based position)
function grid.getTilePosition(grid_pos_x, grid_pos_y)
  return true_drawbox_pos_x+(grid_pos_x-1)*tile_size, true_drawbox_pos_y+(grid_pos_y-1)*tile_size
end


return grid