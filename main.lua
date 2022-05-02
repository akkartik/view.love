require 'keychord'

lines = {}
width, height, flags = 0, 0, nil

function love.load()
  table.insert(lines, '')
  love.window.setMode(0, 0)  -- maximize
  width, height, flags = love.window.getMode()
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle('fill', 1, 1, width-1, height-1)
  love.graphics.setColor(1, 1, 0)
  love.graphics.rectangle('fill', 1, 1, 400, 10*12)
  love.graphics.setColor(0, 0, 0)
  local text
  for i, line in ipairs(lines) do
    text = love.graphics.newText(love.graphics.getFont(), line)
    love.graphics.draw(text, 12, i*15)
  end
  -- cursor
  love.graphics.print('_', 12+text:getWidth(), #lines*15)
end

function love.update(dt)
end

function love.textinput(t)
  lines[#lines] = lines[#lines]..t
end

function keychord_pressed(chord)
  -- Don't handle any keys here that would trigger love.textinput above.
  if chord == 'return' then
    table.insert(lines, '')
  elseif chord == 'C-r' then
    lines[#lines+1] = eval(lines[#lines])[1]
    lines[#lines+1] = ''
  end
end

function love.keyreleased(key, scancode)
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end

function eval(buf)
  local f = load('return '..buf, 'REPL')
  if f then
    return call_gather(f)
  end
  local f, err = load(buf, 'REPL')
  if f then
    return call_gather(f)
  else
    return {err}
  end
end

-- based on https://github.com/hoelzro/lua-repl
function call_gather(f)
  local success, results = gather_results(xpcall(f, function(...) return debug.traceback() end))
  return results
end

function gather_results(success, ...)
  local n = select('#', ...)
  return success, { n = n, ... }
end
