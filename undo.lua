-- https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value/26367080#26367080
function deepcopy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local result = setmetatable({}, getmetatable(obj))
  s[obj] = result
  for k,v in pairs(obj) do
    result[deepcopy(k, s)] = deepcopy(v, s)
  end
  return result
end

function minmax(a, b)
  return math.min(a,b), math.max(a,b)
end
