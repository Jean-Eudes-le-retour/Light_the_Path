local bit = require("bit")
local bnot, band, bor, bxor, rshift, lshift = bit.bnot, bit.band, bit.bor, bit.bxor, bit.rshift, bit.lshift

local objects = {}

-- 'state' defines the image used to draw the object (i.e. same image is equivalent to same state), rotation will define the rotation of said image when drawn.
-- This is why items such as mirrors have 2 states: one for horizontal/vertical mirrors and one for diagonal mirrors. pwheel on the other hand can only take one state (but 2 rotations!)
-- It is worth noting that color will also influence the drawn image (though never the texture itself)
local Object =          {t = 0,     id = 0, xpos = nil, ypos = nil, state = 1, rotation = 0, color = COLOR_WHITE, canMove = false, canRotate = false, canChangeColor = false, glassState = false}
local DEFAULT_WALL =    {t =     TYPE_WALL, state = 13, color =  COLOR_WHITE, canMove = false, canRotate = false, canChangeColor = false, glassState = false, hasMask = false, rotateByEights = false, canChangeState = false}
local DEFAULT_GLASS =   {t =    TYPE_GLASS, state =  1, color =  COLOR_WHITE, canMove = false, canRotate = false, canChangeColor = false, glassState =     0, hasMask = false, rotateByEights = false, canChangeState = false}
local DEFAULT_SOURCE =  {t =   TYPE_SOURCE, state =  1, color =  COLOR_WHITE, canMove = false, canRotate = false, canChangeColor =  true, glassState = false, hasMask =  true, rotateByEights = false, canChangeState =  true}
local DEFAULT_RECEIVER ={t = TYPE_RECEIVER, state =  1, color =  COLOR_BLACK, canMove = false, canRotate = false, canChangeColor = false, glassState = false, hasMask =  true, rotateByEights = false, canChangeState = false}
local DEFAULT_MIRROR =  {t =   TYPE_MIRROR, state =  1, color =  COLOR_WHITE, canMove =  true, canRotate =  true, canChangeColor =  true, glassState = false, hasMask =  true, rotateByEights =  true, canChangeState = false}
local DEFAULT_PWHEEL =  {t =   TYPE_PWHEEL, state =  1, color =  COLOR_WHITE, canMove = false, canRotate = false, canChangeColor = false, glassState = false, hasMask =  true, rotateByEights =  true, canChangeState = false}
local DEFAULT_LOGIC =   {t =    TYPE_LOGIC, state =  1, color =  COLOR_BLACK, canMove = false, canRotate = false, canChangeColor = false, glassState = false, hasMask =  true, rotateByEights = false, canChangeState = false}
local DEFAULT_DELAY =   {t =    TYPE_DELAY, state =  1, color =  COLOR_WHITE, canMove = false, canRotate =  true, canChangeColor = false, glassState = false, hasMask =  true, rotateByEights = false, canChangeState = false}
DEFAULT_OBJECT =  {DEFAULT_WALL,DEFAULT_GLASS,DEFAULT_SOURCE,DEFAULT_RECEIVER,DEFAULT_MIRROR,DEFAULT_PWHEEL,DEFAULT_LOGIC,DEFAULT_DELAY}
TYPES =            {"wall","glass","source","receiver","mirror","pwheel","logic","delay" }
NUM_STATES =       {     1,      1,       2,         2,       2,       2,      3,      1 }
UpdateObjectType = { false,  false,   false,     false,   false,   false,  false,  false }
ObjectReferences = {} -- contains tables of references to each object of each type sorted by type and Id; Object:ObjectReferences[int:type][int:id]
local Id = {} -- contains the Id of the newest object of each type (i.e. the amount of each types unless some have been deleted); int:Id[int:type]

-- DO NOT USE THIS METHOD EXTERNALLY ON OTHER OBJECTS; To create a new object use functions in the "grid" module.
-- Creates a new Object table, with default values as defined in the DEFAULT_OBJECT table. 
function Object:new(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState,canChangeState)
  local o = {}
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
  if type(canRotate)  == "boolean" then o.canRotate = canRotate
  else o.canRotate  = DEFAULT_OBJECT[o.t].canRotate end
  if type(canChangeColor) == "boolean" then o.canChangeColor = canChangeColor
  else o.canChangeColor = DEFAULT_OBJECT[o.t].canChangeColor end
  if type(canChangeState) == "boolean" then o.canChangeState = canChangeState
  else o.canChangeState = DEFAULT_OBJECT[o.t].canChangeState end
  o.glassState = glassState or false
  o.glassRotation = 0
  
  -- Object specific initialization
  if t == TYPE_DELAY then
    o.index = 1
    o.delay = state and (state-1)%60+1 or 1
    o.state = 1
    o.previous_light = {}
    for i=1,61 do
      o.previous_light[i] = {}
      for j=0,3 do
        o.previous_light[i][j] = 0
      end
    end
  end
  
  -- Signals new object was created
  UpdateObjectType[o.t] = true
  if o.glassState then UpdateObjectType[TYPE_GLASS] = true end
  
  -- Index the object and return the reference
  ObjectReferences[o.t][o.id] = o
  return o
end

-- Rotate an object 90 (or 45) degrees clockwise
function Object:rotate(invert)
  if DEFAULT_OBJECT[self.t].rotateByEights then
  --note that textures are indexed starting at 1, if state is ever 0 texture will not load properly, hence self.state-1 at the beginning and +1 at the end
    local eight_rotation = band(self.state-1,1)+lshift(band(self.rotation,3),1)
    eight_rotation = (eight_rotation + (invert and -1 or 1))%8
    self.state = bor(band(self.state,bnot(3)),band(eight_rotation,1)+1)
    self.rotation = rshift(band(eight_rotation,6),1)
  elseif self.t == TYPE_DELAY then
    self.delay = (self.delay + (invert and -2 or 0))%60+1
  elseif self.side then
    local side = self.side
    if self.t == TYPE_LOGIC then
      self.color = COLOR_BLACK
      if invert then
        side[0],side[1],side[2],side[3] = side[1],side[2],side[3],side[0]
      else
        side[0],side[1],side[2],side[3] = side[3],side[0],side[1],side[2] 
      end
    else
      self.rotation = (self.rotation + (invert and -1 or 1))%4
      self.state = 1
    end
  else
    self.rotation = (self.rotation + (invert and -1 or 1))%4
  end

  UpdateObjectType[self.t] = true
end

function Object:changeState()
  self.state = self.state%NUM_STATES[self.t]+1
  UpdateObjectType[self.t] = true
end

-- Remove the reference to object within ObjectReferences and from the grid. If it was externally removed from everywhere else garbage collection should handle the rest
function Object:delete()
  UpdateObjectType[self.t] = true
  ObjectReferences[self.t][self.id] = nil
  if Grid[self.xpos] and Grid[self.xpos][self.ypos] and Grid[self.xpos][self.ypos].id == self.id then Grid[self.xpos][self.ypos] = nil end
end

function Object:setSides(s0,s1,s2,s3)
  self.side = {}
  self.side[0],self.side[1],self.side[2],self.side[3] = s0,s1,s2,s3
  UpdateObjectType[self.t] = true
  return self
end

function Object:activate(deactivate)
  if self.t == TYPE_SOURCE then
    self.state = deactivate and 1 or 2
  elseif self.t == TYPE_MIRROR then
    self.rotation = (self.rotation + 1)%4
  else
    return self
  end
  UpdateObjectType[self.t] = true
  UpdateLaserFG = true
  return self
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






-- ONLY CALLED THROUGH GRID FUNCTIONS DO NOT CALL DIRECTLY: Create a new object (does not place in grid!)
function objects.newObject(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState)
  return Object:new(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState)
end
-- ONLY CALLED THROUGH GRID FUNCTIONS DO NOT CALL DIRECTLY: Note that this only changes the position info for the object not the position in the grid; 
function Object:changePosition(xpos,ypos)
  self.xpos = xpos
  self.ypos = ypos
  if self.t == TYPE_LOGIC then self.color = COLOR_BLACK end
end

return objects