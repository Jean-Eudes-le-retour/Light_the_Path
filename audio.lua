
local DEFAULT_MUFFLE = 0.4
local DEFAULT_VOLUME_STEP = 0.3

-- GAME AUDIO VARIABLES --
local n_track, c_track = false, false
local volume_master = 1
local volume_music = 1
local volume_sfx = 1
local volume_c = 0
local mute_master = false
local mute_music = false
local mute_sfx = false
local muffle = false
local speech = false
local VOLUME_MUFFLE = DEFAULT_MUFFLE
local volume_step = DEFAULT_VOLUME_STEP

local audio = {}

function audio.update(dt)
  if not c_track then
    fade = false
    return
  elseif fade then
    volume_c = volume_c - volume_step*dt
    if volume_c < 0 then
      fade = false
      volume_c = 0
      c_track.track:stop()
      c_track.track:setFilter()
      c_track = n_track
      if c_track then
        c_track.track:seek(0)
        c_track.track:setVolume(0)
        c_track.track:play()
        if muffle then audio.muffle(true) end
      end
    else
      c_track.track:setVolume(volume_c*volume_music)
    end
  elseif volume_c < 1 then
    volume_c = volume_c + volume_step*dt
    if volume_c > 1 then volume_c = 1 end
    volume_step = DEFAULT_VOLUME_STEP
    c_track.track:setVolume(volume_c*volume_music)
  end
  if speech then
    speech = false
    if not SFX[SFX_TYPE]:isPlaying() then
      SFX[SFX_TYPE]:play()
    end
  end
end

function audio.play(track, options)
  if type(options) ~= "table" then options = {} end
  if type(track) == "number" then track = TRACK[track] end
  audio.setVolumeStep(options.step)
  
  print("Now playing : "..(track.name or "Unnamed").." by "..(track.artist or "Unknown"))

  track = track or TRACK[math.ceil(math.random()*#TRACK)]
  track.track:setLooping(options.loop)

  if c_track and c_track.track:isPlaying() then
    fade = true
    n_track = track
  else
    n_track = false -- In case for whatever reason c_track is false but n_track isn't
    volume_c = 0
    c_track = track
    c_track.track:seek(0)
    c_track.track:setVolume(0)
    c_track.track:play()
    if muffle then audio.muffle(true) end
  end

  return track
end

function audio.playSound(sound_id)
  if sound_id > NUM_SFX or sound_id < 1 or mute_sfx then return end
  if SFX[sound_id]:isPlaying() then SFX[sound_id]:stop() end
  SFX[sound_id]:setVolume(volume_sfx)
  SFX[sound_id]:play()
end

function audio.makeSpeech()
  speech = true
end

function audio.fade(step)
  audio.setVolumeStep(step)
  fade = true
end

function audio.stop()
  if c_track then c_track.track:stop() end
end

function audio.setMasterVolume(volume)
  volume = volume or 1
  volume = (volume > 1 and 1) or (volume < 0 and 0) or volume
  volume_master = volume
  love.audio.setVolume(mute_master and 0 or volume_master)
end

function audio.setMusicVolume(volume)
  volume = volume or 1
  volume = (volume > 1 and 1) or (volume < 0 and 0) or volume
  volume_music = volume
  if c_track then c_track.track:setVolume(mute_music and 0 or volume_c*volume_music) end
end

function audio.setSFXVolume(volume)
  volume = volume or 1
  volume = (volume > 1 and 1) or (volume < 0 and 0) or volume
  volume_sfx = volume
  -- Make sure whatever "playsound" function takes into account the muting
end

function audio.muteMaster(mute)
  if type(mute) == "boolean" then
    mute_master = mute
  else
    mute_master = not mute_master
  end
  love.audio.setVolume(mute_master and 0 or volume_master)
end

function audio.muteMusic(mute)
  if type(mute) == "boolean" then
    mute_music = mute
  else
    mute_music = not mute_music
  end
  audio.setMusicVolume(volume_music)
end

function audio.muteSFX(mute)
  if type(mute) == "boolean" then
    mute_sfx = mute
  else
    mute_sfx = not mute_sfx
  end
  audio.setSFXVolume(volume_sfx)
end

function audio.muffle(bool)
  if not c_track then return end
  muffle = bool and true or false
  if muffle then 
    c_track.track:setFilter({
      type = 'lowpass',
      volume = VOLUME_MUFFLE,
      highgain = .05,
    })
  else
    c_track.track:setFilter()
  end
end

function audio.getMuffle()
  return muffle
end

function audio.setVolumeStep(step)
  if type(step) == "number" and step > 0 then
    volume_step = step
  else
    volume_step = DEFAULT_VOLUME_STEP
  end
end

function audio.getMasterVolume()
  return volume_master
end

function audio.getMusicVolume()
  return volume_music
end

function audio.getSFXVolume()
  return volume_sfx
end

function audio.getMasterMute()
  return mute_master
end

function audio.getMusicMute()
  return mute_music
end

function audio.getSFXMute()
  return mute_sfx
end

return audio