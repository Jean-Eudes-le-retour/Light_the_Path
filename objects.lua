local objects = {}

-- 'state' defines the image used to draw the object (i.e. same image is equivalent to same state), rotation will define the rotation of said image when drawn.
-- This is why items such as mirrors have 2 states: one for horizontal/vertical mirrors and one for diagonal mirrors. pwheel on the other hand can only take one state (but 2 rotations!)
-- It is worth noting that color can also influence the image used to represent the object (details to be discussed)
local Object = {t = 0, id = 0, xpos = nil, ypos = nil, state = 0, rotation = 0, colour = 0, canMove = false, canChangeState = false, canChangeColour = false}
local Types =     {"wall","glass","source","mirror","dmirror","pwheel","receiver" }
local numStates = {    15,      1,       2,       2,        2,       1,         2 }
local ID = {} -- contains the ID of the newest object of each type (i.e. the amount of each types unless some have been deleted); int:ID[int:type]
ObjectReferences = {} -- contains tables of references to each object of each type sorted by type and ID; Object:ObjectReferences[int:type][int:id]

function Object:new(t,xpos,ypos,state,rotation,colour,canMove,canChangeState,canChangeColour)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.t = Types[t] and t or TYPE_WALL
  ID[o.t] = ID[o.t] + 1
  o.id = ID[o.t]
  o.xpos = xpos or 1
  o.ypos = ypos or 1
  o.state = state or 0
  o.rotation = rotation or 0
  o.colour = colour or 0
  o.canMove = canMove or false
  o.canChangeState = canChangeState or false
  o.canChangeColour = canChangeColour or false
  
  --index the object and return the reference
  ObjectReferences[o.t][o.id] = o
  return o
end

function Object:rightClick(shiftClick)
  shiftClick = shiftClick or false
  if not self.canChangeState then return false end
  self.state = shiftClick and self.state-1 or self.state+1
  self.state = self.state%numStates[self.t]
  return true
end

function Object:changePosition(xpos,ypos) -- note that this only changes the position info for the object not the position in the grid; do not call directly or may cause weirdness
  self.xpos = xpos
  self.ypos = ypos
end

function Object:delete()
  ObjectReferences[self.t][self.id] = nil
end

function objects.getNumType(t) -- will return the amount of the specified type
  local amount = 0
  for i=1,ID[t] or 0 do
    if ObjectReferences[t][i] then amount = amount+1 end
  end
  return amount
end

function objects.getID(t)
  return ID[t] or 0
end

function objects.resetObjects() -- must also be run once for initialization of variables (this is accomplished via grid.clearGrid() or grid.init())
  for i = 1,#Types do
    ID[i] = 0
    ObjectReferences[i] = {}
  end
end

function objects.newObject(t,xpos,ypos,state,rotation,colour,canMove,canChangeState,canChangeColour)
  return Object:new(t,xpos,ypos,state,rotation,colour,canMove,canChangeState,canChangeColour)
end

return objects