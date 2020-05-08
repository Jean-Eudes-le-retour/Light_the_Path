require "objects.lua"
require "grid.lua"


LaserRef = {}
local Id = objects.getId(source)

function Laser.new()
  for i=1,Id do 
    source_i = ObjectReferences[source][i]
    l ={}
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

function Laser.collision(laser)



end
function Laser.rotation(laser_rot , mirror_rot) 
  if laser_rot == 0 an
end

function Laser.propagation(rotation,xpos_end,ypos_end,blocked)
  if blocked then
    return xpos_end,ypos_end
  else
    if rotation == 0 then
      ypos_end = ypos_end -1
    end
    if rotation == 1 then
      ypos_end = ypos_end -1
      xpos_end = xpos_end +1
    end
    if rotation == 2 then
      ypos_end = xpos_end +1
    end
    if rotation == 3 then
      ypos_end = ypos_end +1
      xpos_end = xpos_end +1
    end
    if rotation == 4 then
      ypos_end = ypos_end +1
    end
    if rotation == 5 then
      ypos_end = ypos_end +1
      xpos_end = xpos_end -1
    end
    if rotation == 6 then
      xpos_end = xpos_end -1
    end
    if rotation == 7 then
      ypos_end = ypos_end -1
      xpos_end = xpos_end -1
    end
    return xpos_end , ypos_end
  end
end
  
function Laser.update()
  for i=1,Id do
    local col 
    local col_type 
    laser.collision(LaserRef[i])
    Laser.propagation(LaserRef[i].rotation,LaserRef[i].xpos_end,LaserRef[i].ypos_end,LaserRef[i].blocked)
    
    



end