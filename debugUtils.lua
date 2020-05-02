local debugUtils = {}

-- Give table of variables to print, optional table of different part in each variable OR difference mode, optional constant_part
-- Modes include : "enum","pos"
function debugUtils.print(variable,difference,constant_part)
  if type(variable) ~= "table" then variable = {variable} end
  constant_part = constant_part or ""
  constant_part = tostring(constant_part)
  if type(difference) ~= "table" then
    if type(difference) == "string" then
      if difference == "pos" then
        difference = {"x","y"}
      elseif difference == "enum" then
        difference = {}
        for i=1,#variable do difference[i] = i end
      else
        constant_part = difference
        difference = {}
      end
    else
      difference = {}
    end
  end
    
  local s = ""
  for i=1,#variable do
    if constant_part == "" then
      if difference[i] then
        s = s..tostring(difference[i]).." is "..tostring(variable[i]).."; "
      else
        s = s..tostring(variable[i]).."; "
      end
    else
      s = s..string.gsub(constant_part,"|",tostring(difference[i] or "")).." is "..tostring(variable[i]).."; "
    end
  end
  print(s)
end

local Flag = {}
function debugUtils.setFlag(i)
  Flag[i] = Flag[i] and Flag[i]+1 or 1
  print("Flag "..tostring(i).." was reached "..tostring(Flag[i]).." times")
end

return debugUtils