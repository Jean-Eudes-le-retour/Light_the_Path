local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.
local ui_elements = require("ui_elements")

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 17
level.y = 10
level.name = "Delayed"
level.track_id = 4
level.canModify = true

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = -0.5
level.y_val = nil

local m
local d,s,r
local flag = {}
local last_time = game_time
local c = 7

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
  s = grid.set(TYPE_SOURCE,2,5,{color = COLOR_WHITE, rotation = 1})
  for i=3,7 do if not Grid[2][i] then grid.set(TYPE_WALL,2,i) end end

-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
	m = ui_elements.create(UI_DIALOG)
	m.text = {
  {{0.5,0.5,0.5},"*Huff* *Urff* *Huff* *Cough* *Urgh* *AHHhhh* *Huff*"},
  {{0.5,0.5,0.5},"Ah! There you are, my not-so-brilliant assistant!\n\nHuh...? What was I doing...? Why, my morning jog around the laboratory of course! From my living \z
  quarters to the biodome, then to the particle collider and through the main storage bay to the antimatter reactor, into the main elevator shaft and past the xenolife studies \z
  department, across the toxic waste dumping unit, through the portal to XF-T30 and back.\n\nWhat? Stop looking at me like that. Is it so hard to believe I'm still \z
  in good shape? I may look old, but I'm REAL fast!"},
  {{0.5,0.5,0.5},"Oh, but no matter how fast I get, I still won't hold a candle to light. I mean, I'm fast, but light's like... Super duper fast.\n\nSo fast, in fact, that my \z
  inventions can't quite keep up with their limited processing speed."},
  {{0.5,0.5,0.5},"You may not have noticed it up to now, but my inventions take a whole 'tick' to process their inputs. What's \z
  a 'tick' I hear you ask? Why, a unit of measurement my crazy co-worker who thinks we all live in a simulation keeps insisting I use. From what he's told me, it appears a tick \z
  corresponds to the time between 2 frames because Vsync is enabled. Whatever that gibberish means. Regardless, it's pretty fast, so much so it'd be hard to notice if it weren't for \z
  the fact that ignoring this phenomenon would make processing information as light near impossible. Which is why I came up with another great invention!\n\nPRESENTING: THE DELAY!"},
  {{0.5,0.5,0.5},"This wonderful item will allow you to synchronize your system so that everything runs smoothly, it opens up all kinds of new possibilities!\n\nThe number shown \z
  corresponds to the amount of ticks it takes for light to go through. This can be changed with ",{0,0,0},"SCROLL WHEEL",{0.5,0.5,0.5},"."},
  {{0.5,0.5,0.5},"You can also change the direction through which the output will be sent depending on the input with ",{0,0,0},"RIGHT CLICK",
  {0.5,0.5,0.5},". Additionally, the delay can be set to turn the input signal into another set color by opening the selection menu with the \z
  corresponding cursor or ",{0,0,0},"MIDDLE MOUSE BUTTON",{0.5,0.5,0.5},".\n\nI'm giving you these tools exceptionally, so don't \z
  expect to always have access to every one of these features, however, for this experiment, you will be free to modify the optics workbench at will!"},
  {{0.5,0.5,0.5},"Your goal is to produce an exclusive receiver. That is to say, a receiver which will not turn on if its input is not PRECISELY the color we're expecting.\n\n\z
  You should have all the necessary tools to do so, so now, with the laser on the grid as the input, and the ",{1,0,0},"RED",{0.5,0.5,0.5}," receiver as the output, make this \z
  receiver only turn on if the light from the laser is exactly ",{1,0,0},"RED",{0.5,0.5,0.5},". Just turn on the laser when you think you're ready!"}
  }
	m.charname = {}
  for i=1,7 do
    m.animation[i] = ANIMATION_1
    m.charname[i] = "Professor Luminario"
  end
  m.isBlocking = true
	m:resize()
end

function level.update(dt) -- dt is time since last update in seconds
  if flag[4] then
    if not flag[5] and s.state == 2 then
      m = ui_elements.create(UI_DIALOG)
      m.text = {{{0.5,0.5,0.5},"Alright, I'll just run a few tests to see if your contraption works..."}}
      m.charname = {"Professor Luminario","Professor Luminario"}
      m.animation[1] = ANIMATION_1
      m.animation[2] = ANIMATION_1
      m.noSkip = true
      m:resize()
      last_time = game_time
      flag[5] = true
    elseif flag[5] then
      if c ~= COLOR_RED and r.state == 2 then
        table.insert(m.text,{{0.5,0.5,0.5},"Something wasn't quite right here. Back to the drawing board!"})
        m.noSkip = false
        ui_elements.clickDialog(m)
        c = COLOR_WHITE
        s:changeColor(c)
        if s.state == 2 then s:changeState() end
        flag[5] = false
      elseif c == COLOR_RED and r.state == 2 then
        table.insert(m.text,{{0.5,0.5,0.5},"Good job! I knew you had it in you! Your future is very bright! I for one simply cannot wait to dump all my tedious tasks on you!"})
        m.noSkip = false
        ui_elements.clickDialog(m)
        if s.state == 2 then s:changeState() end
        level.complete = true
        flag[5] = false
      end
      if game_time - last_time > 2 then
        last_time = game_time
        if c == COLOR_WHITE then
          c = COLOR_MAGENTA
        elseif c == COLOR_MAGENTA then
          c = COLOR_YELLOW
        elseif c == COLOR_YELLOW then
          c = COLOR_RED
        elseif c == COLOR_RED then
          table.insert(m.text,{{0.5,0.5,0.5},"Not sure how long red light should take to be detected but we don't have all day!"})
          m.noSkip = false
          ui_elements.clickDialog(m)
          c = COLOR_WHITE
          if s.state == 2 then s:changeState() end
          flag[5] = false
        end
        s:changeColor(c)
      end
    end
  else
    if not flag[1] and ((m.page == 4 and m.finished) or (m.page>4)) then
      flag[1] = true
      d = grid.insert(TYPE_DELAY,9,5,{canMove = true, delay = 30})
      last_time = game_time
    elseif m.page == 5 and game_time - last_time > 1 then
      last_time = game_time
      s:changeState()
    elseif m.page == 6 and game_time - last_time > 1 then
      if not flag[2] then
        flag[2] = true
        d.delay = 5
        if s.state == 1 then s:changeState() end
      end
      last_time = game_time
      s:changeState()
      if flag[3] then d:changeState() d:changeColor(d.color + 1) flag[3] = false else flag[3] = true end
    elseif m.page == 7 then
      if d then d:delete() d = nil end
      if s.state == 2 then s:changeState() end
      r = grid.set(TYPE_RECEIVER,16,5,{color = COLOR_RED, rotation = 3})
      flag[4] = true
    end
  end
end

return level