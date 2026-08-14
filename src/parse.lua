local parse = { }

-- Parse the arguments into an easier table:
-- {
--   [1] = { flag = "flag1", value = "value1" },
--   [2] = { flag = "flag2", value = "value2" },
-- }
-- A value of "" means the flag is considered removed or ignored in order to maintain ordering
function parse.args(args)
  -- Remove cmd
  args[0] = nil
  local new_args = { }
  -- Iterate by item:
  -- When on a string that starts with a dash (Indicating a flag), then check the next item:
  -- - If the item doesnt start with a dash, use that as the value
  -- - If the item does start with a dash, check the type:
  --   - If the type is a string, then use a nil value (The flag is probably something like "-y")
  --   - If the type is a number, then assume the dash means a negative number and use that as the value
  for i, item in ipairs(args) do
    local pair = { flag = item, value = nil }
    if item:match("^-.+$") then
      local next = args[i+1]
      if next and (not next:match("^-.+$") or tonumber(next)) then
        pair.value = next
        args[i+1] = ""
      end
      table.insert(new_args, pair)
    end
  end
  return new_args
end

function parse.arg_itr(args)
  local i = 0
  return function()
    i = i + 1
    local pair = args[i]
    if pair then
      -- Value can be nil
      return pair.flag, pair.value, pair
    end
  end
end

function parse.arg_concat(args, sep)
  local concat = ""
  for f, v in parse.arg_itr(args) do
    if v ~= "" then
      if concat ~= "" then
        concat = concat .. sep .. f
      else
        concat = concat .. f
      end
      if v then
        concat = concat .. sep .. (v or "")
      end
    end
  end
  return concat
end

return parse

