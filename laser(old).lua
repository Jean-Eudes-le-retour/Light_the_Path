local objects = require("objects")
local grid = require("grid")

local Laser = {}
LaserRef = {}
local Id = 0
-- color_table = { [i:used in NUM_COLORS][R , G , B ] }
local color_table = { {R=1 , G=0 , B=0}, 
                      {R=0 , G=1 , B=0},
                      {R=1 , G=1 , B=0},
                      {R=0 , G=0 , B=1},
                      {R=1 , G=0 , B=1},
                      {R=0 , G=1 , B=1},
                      {R=1 , G=1 , B=1},
                      {R=0 , G=0 , B=0}}
-- rotation_table = [laser.rot, laser.state , mirror.rot , mirror.state ][rotated_laser.rotation , rotated_laser.state ]
local rotation_possibilities = {{1,0,0,1},
                                {1,0,1,1},
                                {0,0,0,1},
                                {0,0,1,1},
                                {1,1,0,1},
                                {1,1,1,1},
                                {0,1,0,1},
                                {0,1,1,1}}
local rotation_outcome = { {0,1},
                           {0,0},
                           {1,1},
                           {1,0},
                           {0,0},
                           {0,1},
                           {1,0},
                           {1,1} }
                           
                           
              

-- This function is to be used only once to create the first lasers 
function Laser.new()
  local Id_source = objects.getId(source)
  for i=1,Id_source do 
    source_i = ObjectReferences[source][i]
    local l ={}
    setmetatable(l, self)
    self.__index = self
    l.xpos_start = source_i.xpos
    l.ypos_start = source_i.ypos
    l.xpos_end = source_i.xpos +1
    l.ypos_end = source_i.ypos +1
    l.rotation = source_i.rotation
    l.state = source_i.state
    l.color = source_i.color
    l.blocked = false
    LaserRef[i]= l 
    Id = Id +1
  end
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
  l.state = state
  l.color = color
  l.blocked = false
  LaserRef[Id]= l 
end

function Laser.rotation ( laser_rot , laser_state,  mirror_rot , mirror_state )
  for i=1,8 do
    if rotation_possibilities[i] == {laser_rot , laser_state,  mirror_rot , mirror_state} then
      return rotation_outcome[i]
    end
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

-- -- Thesefunctions manages color merges and separations
function Laser.colors_merge (id_color1 , id_color2)
  local red = color_table[id_color1][R] or color_table[id_color2][R]
  local green = color_table[id_color1][G] or color_table[id_color2][G]
  local blue = color_table[id_color1][B] or color_table[id_color2][B]
  for i=1,8 do
    if {red , green ,blue } == color_table[i] then
      return i
    end
  end
end
  
  
function Laser.colors_separate (id_color_laser, id_color_mirror)
  local red1 = color_table[id_color_laser][R] and color_table[id_color_mirror][R]
  local red2 = color_table[id_color_laser][R] and not(color_table[id_color_mirror][R])
  local green1 = color_table[id_color_laser][G] and color_table[id_color_mirror][G]
  local green2 = color_table[id_color_laser][G] and not(color_table[id_color_mirror][G])
  local blue1 = color_table[id_color_laser][B] and color_table[id_color_mirror][B]
  local blue2 = color_table[id_color_laser][B] and not(color_table[id_color_mirror][B])
  for i=1,8 do
    if {red1,green1,blue1} == color_table[i] then
      local id_color_reflected_laser = i
    end
    if {red2,green2,blue2} == color_table[i] then
      local id_color_refracted_laser = i
    end
  end
  return id_color_reflected_laser , id_color_refracted_laser
end



-- This function returns whether all receiver have been activated or not
function Laser.success ()
  local Id_receiver = objects.getId(receiver)
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



-- rotation 0 = upward , rotation 1 = right , rotation 2 = downward , rotation 3 = left

function Laser.propagation(rotation,state,xpos_end,ypos_end,blocked)
  if blocked then
    return xpos_end,ypos_end
  else
    if rotation == 1 and state == 0 then
      ypos_end = ypos_end -1
    end
    if rotation == 0 and state == 0 then
      ypos_end = xpos_end +1
    end
    if rotation == 1 and state == 1 then
      ypos_end = ypos_end +1
    end
    if rotation == 0 and state == 1 then
      xpos_end = xpos_end -1
    end
    return xpos_end , ypos_end
  end
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
    if collision == "mirror" and LaserRef[i].blocked==false then 
      id_color_reflected_laser , id_color_refracted_laser = Laser.colors_separate (LaserRef[i].color, Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].color)
      rotation_reflected_laser , state_reflected_laser = Laser.rotation ( LaserRef[i].rotation , LaserRef[i].state , Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].rotation , Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].state )
      Laser.add (LaserRef[i].xpos_end , LaserRef[i].ypos_end , LaserRef[i].xpos_end ,LaserRef[i].ypos_end ,rotation_reflected_laser , state_reflected_laser, id_color_reflected_laser , false )
      Laser.add (LaserRef[i].xpos_end , LaserRef[i].ypos_end , LaserRef[i].xpos_end ,LaserRef[i].ypos_end ,LaserRef[i].rotation,LaserRef[i].state,id_color_refracted_laser , false )
      LaserRef[i].blocked = true
    end
    
    if collision == "pwheel" and (LaserRef[i].blocked==false) then
      if LaserRef[i].color == COLOR_GREEN or LaserRef[i].color==COLOR_BLUE then
        LaserRef[i].blocked = true
        Laser.add (LaserRef[i].xpos_end,LaserRef[i].ypos_end,LaserRef[i].xpos_end ,LaserRef[i].ypos_end , LaserRef[i].rotation, LaserRef[i].state ,Grid[LaserRef[i].xpos_end][LaserRef[i].ypos_end].color , false )
      end
    end
    Laser.propagation(LaserRef[i].rotation,LaserRef[i].xpos_end,LaserRef[i].ypos_end,LaserRef[i].blocked)
  end
end


--function Laser.draw()
--  for i=1,Id do
--      love.graphics.setColor(1,1,1)
--    love.graphics.rectangle("fill",LaserRef[i].xpos_start,LaserRef[i].xpos_start,rlight.w,rlight.l)
--  end
--end

return Laser