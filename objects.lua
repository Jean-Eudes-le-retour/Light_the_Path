local objects = {}

-- 'state' defines the image used to draw the object (i.e. same image is equivalent to same state), rotation will define the rotation of said image when drawn.
-- This is why items such as mirrors have 2 states: one for horizontal/vertical mirrors and one for diagonal mirrors. pwheel on the other hand can only take one state (but 2 rotations!)
-- It is worth noting that color can also influence the image used to represent the object (details to be discussed)
local Object =          {t = 0,     id = 0, xpos = nil, ypos = nil, state = 1, rotation = 0, color = 0, canMove = false, canChangeState = false, canChangeColor = false, glassState = false}
local DEFAULT_WALL =    {t =     TYPE_WALL, state = 13, color =  0, canMove = false, canChangeState = false, canChangeColor = false, glassState = false, hasMask = false}
local DEFAULT_GLASS =   {t =    TYPE_GLASS, state =  1, color =  0, canMove = false, canChangeState = false, canChangeColor = false, glassState =     0, hasMask = false}
local DEFAULT_SOURCE =  {t =   TYPE_SOURCE, state =  1, color =  7, canMove = false, canChangeState =  true, canChangeColor = false, glassState = false, hasMask =  true}
local DEFAULT_RECEIVER ={t = TYPE_RECEIVER, state =  1, color =  8, canMove = false, canChangeState = false, canChangeColor = false, glassState = false, hasMask =  true}
local DEFAULT_MIRROR =  {t =   TYPE_MIRROR, state =  1, color =  7, canMove =  true, canChangeState = false, canChangeColor = false, glassState = false, hasMask =  true}
local DEFAULT_PWHEEL =  {t =   TYPE_PWHEEL, state =  1, color =  0, canMove =  true, canChangeState = false, canChangeColor = false, glassState = false, hasMask =  true}
local DEFAULT_PRISM =   {t =    TYPE_PRISM, state =  1, color =  0, canMove =  true, canChangeState = false, canChangeColor = false, glassState = false, hasMask = false}
DEFAULT_OBJECT =  {DEFAULT_WALL,DEFAULT_GLASS,DEFAULT_SOURCE,DEFAULT_RECEIVER,DEFAULT_MIRROR,DEFAULT_PWHEEL,DEFAULT_PRISM}
TYPES =            {"wall","glass","source","receiver","mirror","pwheel","prism" }
NUM_STATES =       {     1,      1,       2,         2,       2,       1,      1 }
UpdateObjectType = { false,  false,   false,     false,   false,   false,  false }
ObjectReferences = {} -- contains tables of references to each object of each type sorted by type and Id; Object:ObjectReferences[int:type][int:id]
local Id = {} -- contains the Id of the newest object of each type (i.e. the amount of each types unless some have been deleted); int:Id[int:type]

-- Creates a new Object table, with default values as defined in the DEFAULT_OBJECT table. Please refrain from calling directly (use grid functions!)
function Object:new(t,xpos,ypos,state,rotation,color,canMove,canChangeState,canChangeColor,glassState)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.t = TYPES[t] and t or TYPE_WALL
  Id[o.t] = Id[o.t] + 1
  o.id = Id[o.t]
  o.xpos = xpos or 1
  o.ypos = ypos or 1
  o.state = state or DEFAULT_OBJECT[o.t].state
  o.rotation = rotation or 0
  o.color = color or DEFAULT_OBJECT[o.t].color
  if type(canMove)         == "boolean" then o.canMove = canMove
  else o.canMove         = DEFAULT_OBJECT[o.t].canMove end
  if type(canChangeState)  == "boolean" then o.canChangeState = canChangeState
  else o.canChangeState  = DEFAULT_OBJECT[o.t].canChangeState end
  if type(canChangeColor) == "boolean" then o.canChangeColor = canChangeColor
  else o.canChangeColor = DEFAULT_OBJECT[o.t].canChangeColor end
  o.glassState = glassState or false
  o.glassRotation = 0
  
  -- Signals new object was created
  UpdateObjectType[o.t] = true
  if o.glassState then UpdateObjectType[TYPE_GLASS] = true end
  
  -- Index the object and return the reference
  ObjectReferences[o.t][o.id] = o
  return o
end

-- Might rename Oject:action(mode,shiftClick) so that mode depends on the tool type, and make enum
function Object:rightClick(shiftClick)
  shiftClick = shiftClick or false
  if self.glassState or not self.canChangeState then return false end
  UpdateObjectType[self.t] = true
  self.state = shiftClick and self.state-1 or self.state+1
  self.state = (self.state > NUM_STATES[self.t] and 1 or self.state)
  return true
end

-- Note that this only changes the position info for the object not the position in the grid; do not call directly or may cause weirdness
function Object:changePosition(xpos,ypos)
  self.xpos = xpos
  self.ypos = ypos
end

-- Remove the reference to object within ObjectReferences. If it was externally removed from everywhere else garbage collection should handle the rest
function Object:delete()
  UpdateObjectType[self.t] = true
  ObjectReferences[self.t][self.id] = nil
end

-- Will return the amount of the specified type (note that this cannot be substituted for Id in 'for' loop because objects could have been deleted)
function objects.getNumType(t) 
  local amount = 0
  for i=1,Id[t] or 0 do
    if ObjectReferences[t][i] then amount = amount+1 end
  end
  return amount
end

-- Will return the latest Id of the specified type
function objects.getId(t)
  return Id[t] or 0
end

-- Must also be run once for initialization of variables (this is accomplished via grid.clearGrid() or grid.init()); note that Ids are set back to 0
function objects.resetObjects() 
  for i = 1,#TYPES do
    Id[i] = 0
    ObjectReferences[i] = {}
  end
end

-- Create a new object (does not place in grid!) Refrain from using directly (please use grid functions)
function objects.newObject(t,xpos,ypos,state,rotation,color,canMove,canChangeState,canChangeColor,glassState)
  return Object:new(t,xpos,ypos,state,rotation,color,canMove,canChangeState,canChangeColor,glassState)
end

return objects