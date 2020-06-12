local objects = require("objects")
local grid = require("grid")
local tiles = require("tiles")
local game = require("game")
local ui_elements = require("ui_elements")

local level = {}

level.complete = false
level.x = 16
level.y = 9
level.name = "Intro"

level.noUI = true
level.track_id = false
local m
local flag1 = false

function level.load()
  grid.setDimensions(level.x,level.y)
  UpdateBackgroundFG = false
  m = ui_elements.create(UI_DIALOG)
  m.text = {
  {{0.5,0.5,0.5},"Saturday afternoon, you were taking a stroll through the woods a few kilometers out of town as you'd done so many times \z
  in the past. Something about the air this particular day was reminiscent of your youth, simpler times where each and every step \z
  would lead you to new discoveries and the world seemed so filled with exciting adventures at every turn..."},
  {{0.5,0.5,0.5},"\"How naive I was!\", you exclaimed to yourself...\nSaturday afternoons have become your only escape from your daily routine \z
  at work. But the thought that this weekly excursion could in turn fall into the routine as well was slowly creeping up on you. You were determined \z
  to avoid this at all cost. Besides, you were feeling adventurous today."},
  {{0.5,0.5,0.5},"\"I should take some time for myself...\"\n\nYes, you should."},
  {{0.5,0.5,0.5},"\"Maybe I'll go deeper into the woods just this time! I might just discover some new spot to camp out at!\"\n\nI don't know why, but this \z
  is starting to sound suspiciously similar to the intro to some poorly written horror movie. That, or a game where plot really just came as an afterthough... \z
  Regardless. YOU GO, GUY!"},
  {{0.5,0.5,0.5},"As you make your way through the woods, you realize just how easy it is to try and keep things fresh in life. Before you knew it, you'd gotten \z
  yourself lost. You've walked through countless overgrown pathways through the woods. You couldn't even remember how long it'd been since you left your usual trail. \z
  It must have been 5... no, 15... no 30 minutes? Honestly, who could even tell..?"},
  {{0.5,0.5,0.5},"Well obviously I could...\n\nAnd believe me you don't want to know, lest you'd be reminded of the impending deadlines you still need to meet."},
  {{0.5,0.5,0.5},"Anyways, it was finally at that point that you stopped in your tracks. Realizing the situation you were in, you still couldn't help but show a \z
  massive smile across your face as this experience had reignited something you forgot you still had in you: the adventurous spirit of a kid, ever free of worries."},
  {{0.5,0.5,0.5},"It was at that point that you noticed what appeared to be a structure in a clearing...\n\"Can't seem to quite be able to escape civilization...\", you \z
  thought to yourself.\n"},
  {{0.5,0.5,0.5},"The structure itself was still worthy of attention. Nothing you'd ever really seen before, but not so outlandish it would feel out of place... If it \z
  weren't for the fact that it was out in the woods away from any other form of man-made structure!\n\nTrust me on this, man, nothing good ever comes of stories like these. \z
  It could be haunted, or cursed, or maybe it holds government secrets, or maybe a secret sect performs rituals here, or maybe it's a portal to an alternate dimension of \z
  man-eating monsters, or maybe it's an altar to our eternal overlords the space lizardmen built by our ancestors to quell their anger, and your impudent presence will \z
  invite their wrath back onto us, ultimately leading to our untimely end!\n\nPlease, just back off."},
  {{0.5,0.5,0.5},"But it was too late, your curiosity was piqued, and you started walking towards the peculiar structure, ignoring the suggestions of yours truly, a beacon of \z
  reason, your trusty inner voice...\n\nAS ALWAYS MIGHT I ADD!"},
  {{0.5,0.5,0.5},"As you got closer, you notice that the structure was not so much a monument as it was some form of entrance, suggesting something bigger... Underground...?\n\n\z
  This is your last chance I'm telling you. Turn back now or reap the consequences of your carelessness."},
  {{0.5,0.5,0.5},"Now in front of the entrance, you slowly lean in to inspect the shut door. The shape and materials suggest a modern sliding door system, but the state of disrepair \z
  made the idea of the door being anywhere near as 'recent' as ancient pyramids quite unlikely...\n\nI'm telling you, it's space lizardmen."},
  {{0.5,0.5,0.5},"\"So you're FINALLY here! You took your sweet time, the directions I gave you couldn't be any clearer!\", exclaimed a static-filled voice.\n\n\z
  You look up to notice the intercom perched over the entrance. Without even getting the time to settle your confusion, the voice continues,\n\n\"Alright get in here already, \z
  I've waited long enough!\""},
  {{0.5,0.5,0.5},"The door slides open in a split second, creating a powerful vacuum pulling you down through what could only be described as a massive slide.\n\z
  Before you knew it, you'd reached the bottom where you're greated by an odd character, dressed much like a scientist."},
  {{0.5,0.5,0.5},"Well, you're dressed... Quite unprofessionally. Not the best impression for the first day on the job. So be it, I can tolerate your whims so long as \z
  you're useful with the lab work."},
  {{0.5,0.5,0.5},"I... Uh.... Wuuuuuuuuuuuuhhhh...?"},
  {{0.5,0.5,0.5},"Not the eloquent one I see... Well, the loud ones aren't always the smartest I suppose. Follow me, we'll see what you're capable of soon enough!"},
  {{0.5,0.5,0.5},"Who... Who are you...?"},
  {{0.5,0.5,0.5},"Can't even remember your employer's name? Not to mention that you are in the presence of the illustrious genius Professor Luminario!\nAlright then, \z
  no time to waste, I'll show you around."},
  {" "}
  }
  m.charname = {}
  m.animation[15] = ANIMATION_1
  for i=1,14 do m.charname[i] = "Narrator" end
  for i=15,19,2 do
    m.charname[i] = "?"
    m.animation[i] = ANIMATION_1
  end
  for i=16,18,2 do
    m.charname[i] = "You"
    m.animation[i] = nil
  end
  m:resize()
end

function level.update(dt)
  if not flag1 then
    love.graphics.setCanvas(canvas_BG)
    love.graphics.clear()
    love.graphics.setCanvas()
    if m.page == 15 then
      flag1 = true
      UpdateBackgroundFG = true
    end
  end

  if m.page == 20 then
    load_level(0)
  end
end

return level