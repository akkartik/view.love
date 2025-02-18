-- https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value/26367080#26367080
function deepcopy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  seen = seen or {}
  if seen[obj] then return seen[obj] end
  local result = setmetatable({}, getmetatable(obj))
  seen[obj] = result
  for k,v in pairs(obj) do
    result[deepcopy(k, seen)] = deepcopy(v, seen)
  end
  return result
end

function minmax(a, b)
  return math.min(a,b), math.max(a,b)
end
