local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.
local ui_elements = require("ui_elements")

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 17
level.y = 10
level.name = "Light and Logic"
level.track_id = 3

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = -0.5
level.y_val = nil

local r
local m

-- IMPORTANT FUNCTIONS --
function level.load()
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
  
  for i=1,level.x do
    for j=1,2 do grid.set(TYPE_WALL, i, j) end
    for j=0,2 do grid.set(TYPE_WALL, i, level.y-j) end
  end
  for i=3,level.y-2 do
    grid.set(TYPE_WALL, 1, i)
    grid.set(TYPE_WALL, level.x, i)
  end
  grid.set(TYPE_PWHEEL,2,3,{color = COLOR_GREEN, canMove = true, canRotate = true})
  grid.set(TYPE_MIRROR,2,4,{color = COLOR_GREEN})
  grid.set(TYPE_MIRROR,2,6,{color = COLOR_RED})
  grid.set(TYPE_MIRROR,2,7,{color = COLOR_BLUE})
  grid.set(TYPE_MIRROR,3,4,{color = COLOR_WHITE})
  grid.set(TYPE_MIRROR,3,5,{color = COLOR_WHITE})
  grid.set(TYPE_MIRROR,3,6,{color = COLOR_WHITE})
  grid.set(TYPE_SOURCE,2,5,{color = COLOR_WHITE, rotation = 1})
  grid.set(TYPE_LOGIC,5,5,{state = LOGIC_NOT}):setSides("in","out","in","in")
  grid.set(TYPE_LOGIC,7,5,{state = LOGIC_AND, glass = true}):setSides("in","out","in","in")
  grid.set(TYPE_MIRROR,6,3,{color = COLOR_BLACK, rotation = 1, canMove = false, canRotate = false})
  grid.set(TYPE_MIRROR,10,3,{color = COLOR_BLACK, rotation = 1, canMove = false, canRotate = false})
  grid.set(TYPE_MIRROR,6,7,{color = COLOR_BLACK, rotation = 1, canMove = false, canRotate = false})
  grid.set(TYPE_MIRROR,10,7,{color = COLOR_BLACK, rotation = 1, canMove = false, canRotate = false})
  grid.set(TYPE_WALL,8,3)
  grid.set(TYPE_WALL,8,7)
  for i=6,10,2 do
    grid.set(TYPE_WALL,i,4,{glass = true})
    grid.set(TYPE_WALL,i,6,{glass = true})
  end
  for i=6,10 do 
    for j=4,6 do
      if not Grid[i][j] then grid.set(TYPE_GLASS,i,j) end
    end
  end
  r = grid.set(TYPE_RECEIVER,16,5,{color = COLOR_BLACK, rotation = 3})
  

-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
	m = ui_elements.create(UI_DIALOG)
	m.text = {
  {{0.5,0.5,0.5},"Well, well, well, what do we have here? New objects got you confused? Need good ol' Luminario to help out with a few tips?\n\nOh you silly assistant... \z
  Can't get anything done without me can you? I'm always here to answer your calls of distress at the sight of anything new."},
  {{0.5,0.5,0.5},"Let's first get this out of the way:\n\nSee those black mirrors? They serve no functionality. Purely decorative and lets light through granted the light \z
  crosses the glass and not the solid part."},
  {{0.5,0.5,0.5},"What you see here are, as you might have guessed, objects made for logic circuitry. I'll spare you the details, but the one marked with an 'X' is a bitwise \z
  logical AND, and the one marked with a '!' is a bitwise logical NOT."},
  {{0.5,0.5,0.5},"Now, now. Please don't look at me as though I just came up with some outlandish new words on the spot. Tell me. You DO know what these do, right?"},
  {{0.5,0.5,0.5},"..."},
  {{0.5,0.5,0.5},"Ok, I get it, you're pretty slow on the uptake. I'll try to be concise."},
  {{0.5,0.5,0.5},"A logical AND gate generally takes 2 inputs and has an output only if both inputs are on. But in our case, it's more complicated than that. Here, we can have \z
  any number of inputs and outputs, and each of them can be any one of our 8 colors. Therefore, the output is only on if each input is on, and this applies to every \z
  single color individually.\n\nIf you'd like, you can imagine it intuitively as a multiplication of each input color by color. I'll give you and example:\n\n",
  {1,0,1},"MAGENTA",{0,0,0}," AND ",{1,0,0},"RED",{0.5,0.5,0.5}," together is (",{1,0,0},"1 ",{0,1,0},"0 ",{0,0,1},"1",{0.5,0.5,0.5},")",{0,0,0}," AND ",{0.5,0.5,0.5},"(",
  {1,0,0},"1 ",{0,1,0},"0 ",{0,0,1},"0",{0.5,0.5,0.5},") which results in ",{1,0,0},"RED ",{0.5,0.5,0.5},"(",{1,0,0},"1 ",{0,1,0},"0 ",{0,0,1},"0",{0.5,0.5,0.5},")."},
  {{0.5,0.5,0.5},"Now to talk about the logical NOT. Typically, it outputs the opposite of its input. Now what does this mean for us? It means that if you input a combination \z
  of colors that would normally produce ",{1,1,1},"WHITE",{0.5,0.5,0.5}," light, you'll get nothing on the output. Conversely, not having anything as an input will give you ",
  {1,1,1},"WHITE",{0.5,0.5,0.5}," as the output.\n\nFor any other color, the output can be intuitively understood as the complementary color of the sum of the inputs."},
  {{0.5,0.5,0.5},"Now I'm sure you're meaning to ask: \"But... Professor Luminario, why should I use your intriguing light based logic circuitry over conventional electric \z
  circuits?\"\n\nWell, simply because ",{1,0,0},"R ",{1,0.65,0},"A ",{1,1,0},"I ",{1,1,0},"N ",{0,1,0},"B ",{0,1,1},"O ",{0,0,1},"W ",{1,0,1},"S ",{1,0.1,0.6},"!",
  {0.5,0.5,0.5},"\n\nQuod Erat Demonstratum."}
  }
	m.charname = {}
	m.animation[1] = {}
	m.animation[1][0] = {4,-1}
	m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
	m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
	m.animation[1][3] = m.animation[1][1]
  for i=1,9 do
    m.animation[i] = m.animation[1]
    m.charname[i] = "Professor Luminario"
  end
  m.isBlocking = true
	m:resize()
end

function level.update(dt) -- dt is time since last update in seconds
  if r.state == 2 then level.complete = true end
end

return level