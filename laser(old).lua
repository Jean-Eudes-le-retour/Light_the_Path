local objects = require("objects")
local grid = require("grid")


LaserRef = {}
local Id_source = objects.getId(source)
local Id_receiver = objects.getId(receiver)
local Id = Id_source



-- This function is to be used only once to create the first lasers 
function Laser.new()
  for i=1,Id_source do 
    source_i = ObjectReferences[source][i]
    local l ={}
    setmetatable(l, self)
    self.__index = self
    l.xpos_start = source_i.xpos
    l.ypos_start = source_i.ypos
    l.xpos_end = source_i.xpos
    l.ypos_end = source_i.ypos
    l.rotation = source_i.rotation
    l.color = source_i.color
    l.blocked = false
    LaserRef[i]= l 
  end
end



-- This function returns whether there is a collision between the laser and the object , and if yes what type of object
function Laser.collision(laser_xpos , laser_ypos  )
  local collison = "none"
  if grid.checkGrid(laser_xpos, laser_ypos , "wall") or grid.checkGrid(laser_xpos, laser_ypos , "source") then
    collision = "wall"
  end
  if grid.checkGrid(laser_xpos, laser_ypos , "receiver" ) then
    collision = "receiver"
  end
  if grid.checkGrid(laser_xpos, laser_ypos , "mirror" ) then
    collision = "mirror"
  end
  if grid.checkGrid(laser_xpos, laser_ypos , "pwheel" ) then
    collision = "pwheel"
  end
  return collision
end


-- This function is used to add a new laser ( after an interaction with in an object ) to LaserRef
function Laser.add (x_start , y_start , x_end , y_end , rotation , color , blocked ) 
  Id = Id +1
  local l ={}
  setmetatable(l, self)
  self.__index = self
  l.xpos_start = x_start
  l.ypos_start = y_start
  l.xpos_end = x_end
  l.ypos_end = y_end
  l.rotation = rotation
  l.color = color
  l.blocked = false
  LaserRef[Id]= l 
end


-- This function returns whether all receiver have been activated or not
function Laser.success ()
  local c=0
  for i=1,Id do
    if Laser.collision(LaserRef[i].xpos_end , LaserRef[i].ypos_end ) == "receiver" then
      c=c +1 
    end
  end
  if c == Id_receiver then
    return true
  else 
    return false
  end
end


function Laser.rotate(laser_rot , mirror_rot) 
  return 1
end

-- 

function Laser.propagation(rotation,xpos_end,ypos_end,blocked)
  if blocked then
    return xpos_end,ypos_end
  else
    if rotation == 0 then
      ypos_end = ypos_end -1
    end
    if rotation == 1 then
      ypos_end = xpos_end +1
    end
    if rotation == 2 then
      ypos_end = ypos_end +1
    end
    if rotation == 3 then
      xpos_end = xpos_end -1
    end
    return xpos_end , ypos_end
  end
end

-- This function manages color merges and separations
function laser.colors ()
  
end

-- This function updates the lasers state and controls the laser reaction to objects
function Laser.update()
  for i=1,Id do
    local collision = laser.collision(LaserRef[i].xpos_end , LaserRef[i].ypos_end)
    if collision == "wall" then
      LaserRef[i].blocked = true
    end
    if collision == "receiver" then
      LaserRef[i].blocked = true
      --if Laser.success () then
      --return true
    end
    if collision == "mirror" then
      if (LaserRef[i].color == COLOR_WHITE) and (Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].color ~= COLOR_WHITE ) and (LaserRef[i].blocked==false) then
        Laser.add (LaserRef[i].xpos_end , LaserRef[i].ypos_end , LaserRef[i].xpos_end ,LaserRef[i].ypos_end ,Laser.rotation(LaserRef[i].rotation) , Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].rotation, Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].color , false )
        Laser.add (LaserRef[i].xpos_end , LaserRef[i].ypos_end , LaserRef[i].xpos_end ,LaserRef[i].ypos_end ,Laser.rotation(LaserRef[i].rotation) , Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].rotation, laser.colors (COLOR_WHITE , Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].color) , false )
      end
      if (LaserRef[i].color == Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].color and (LaserRef[i].blocked==false) ) or (Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].color ==COLOR_WHITE and (LaserRef[i].blocked==false)) then
        Laser.add (LaserRef[i].xpos_end , LaserRef[i].ypos_end , LaserRef[i].xpos_end ,LaserRef[i].ypos_end ,Laser.rotation(LaserRef[i].rotation) , Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].rotation, LaserRef[i].color , false )
      end
      LaserRef[i].blocked = true
    end
    
    if collision == "pwheel" and (LaserRef[i].blocked==false) then
      if LaserRef[i].color == COLOR_GREEN or LaserRef[i].color==COLOR_BLUE then
        LaserRef[i].blocked = true
        Laser.add (LaserRef[i].xpos_end , LaserRef[i].ypos_end , LaserRef[i].xpos_end ,LaserRef[i].ypos_end , LaserRef[i].rotation ,Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].color , false )
      end
    end
    Laser.propagation(LaserRef[i].rotation,LaserRef[i].xpos_end,LaserRef[i].ypos_end,LaserRef[i].blocked)
  end
end

function Laser.draw()
  for i=1,Id do
      love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill",LaserRef[i].xpos_start,LaserRef[i].xpos_start,rlight.w,rlight.l)
  end
end
  