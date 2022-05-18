-- primitives for editing drawings
Drawing = {}
geom = require 'geom'

function Drawing.draw(line, y)
  local pmx,pmy = love.mouse.getX(), love.mouse.getY()
  if pmx < 16+Drawing_width and pmy > line.y and pmy < line.y+Drawing.pixels(line.h) then
    love.graphics.setColor(0.75,0.75,0.75)
    love.graphics.rectangle('line', 16,line.y, Drawing_width,Drawing.pixels(line.h))
    if icon[Current_drawing_mode] then
      icon[Current_drawing_mode](16+Drawing_width-20, line.y+4)
    else
      icon[Previous_drawing_mode](16+Drawing_width-20, line.y+4)
    end

    if love.mouse.isDown('1') and love.keyboard.isDown('h') then
      draw_help_with_mouse_pressed(line)
      return
    end
  end

  if line.show_help then
    draw_help_without_mouse_pressed(line)
    return
  end

  local mx,my = Drawing.coord(love.mouse.getX()-16), Drawing.coord(love.mouse.getY()-line.y)

  for _,shape in ipairs(line.shapes) do
    assert(shape)
    if geom.on_shape(mx,my, line, shape) then
      love.graphics.setColor(1,0,0)
    else
      love.graphics.setColor(0,0,0)
    end
    Drawing.draw_shape(16,line.y, line, shape)
  end
  for _,p in ipairs(line.points) do
    if p.deleted == nil then
      if Drawing.near(p, mx,my) then
        love.graphics.setColor(1,0,0)
        love.graphics.circle('line', Drawing.pixels(p.x)+16,Drawing.pixels(p.y)+line.y, 4)
      else
        love.graphics.setColor(0,0,0)
        love.graphics.circle('fill', Drawing.pixels(p.x)+16,Drawing.pixels(p.y)+line.y, 2)
      end
    end
  end
  Drawing.draw_pending_shape(16,line.y, line)
end

function Drawing.current_drawing()
  local x, y = love.mouse.getX(), love.mouse.getY()
  for _,drawing in ipairs(Lines) do
    if drawing.mode == 'drawing' then
      if y >= drawing.y and y < drawing.y + Drawing.pixels(drawing.h) and x >= 16 and x < 16+Drawing_width then
        return drawing
      end
    end
  end
  return nil
end

function Drawing.select_shape_at_mouse()
  for _,drawing in ipairs(Lines) do
    if drawing.mode == 'drawing' then
      local x, y = love.mouse.getX(), love.mouse.getY()
      if y >= drawing.y and y < drawing.y + Drawing.pixels(drawing.h) and x >= 16 and x < 16+Drawing_width then
        local mx,my = Drawing.coord(love.mouse.getX()-16), Drawing.coord(love.mouse.getY()-drawing.y)
        for i,shape in ipairs(drawing.shapes) do
          assert(shape)
          if geom.on_shape(mx,my, drawing, shape) then
            return drawing,i,shape
          end
        end
      end
    end
  end
end

function Drawing.select_point_at_mouse()
  for _,drawing in ipairs(Lines) do
    if drawing.mode == 'drawing' then
      local x, y = love.mouse.getX(), love.mouse.getY()
      if y >= drawing.y and y < drawing.y + Drawing.pixels(drawing.h) and x >= 16 and x < 16+Drawing_width then
        local mx,my = Drawing.coord(love.mouse.getX()-16), Drawing.coord(love.mouse.getY()-drawing.y)
        for i,point in ipairs(drawing.points) do
          assert(point)
          if Drawing.near(point, mx,my) then
            return drawing,i,point
          end
        end
      end
    end
  end
end

function Drawing.select_drawing_at_mouse()
  for _,drawing in ipairs(Lines) do
    if drawing.mode == 'drawing' then
      local x, y = love.mouse.getX(), love.mouse.getY()
      if y >= drawing.y and y < drawing.y + Drawing.pixels(drawing.h) and x >= 16 and x < 16+Drawing_width then
        return drawing
      end
    end
  end
end

function Drawing.contains_point(shape, p)
  if shape.mode == 'freehand' then
    -- not supported
  elseif shape.mode == 'line' or shape.mode == 'manhattan' then
    return shape.p1 == p or shape.p2 == p
  elseif shape.mode == 'polygon' then
    return table.find(shape.vertices, p)
  elseif shape.mode == 'circle' then
    return shape.center == p
  elseif shape.mode == 'arc' then
    return shape.center == p
    -- ugh, how to support angles
  elseif shape.mode == 'deleted' then
    -- already done
  else
    print(shape.mode)
    assert(false)
  end
end

function Drawing.convert_line(drawing, shape)
  -- Perhaps we should do a more sophisticated "simple linear regression"
  -- here:
  --   https://en.wikipedia.org/wiki/Linear_regression#Simple_and_multiple_linear_regression
  -- But this works well enough for close-to-linear strokes.
  assert(shape.mode == 'freehand')
  shape.mode = 'line'
  shape.p1 = insert_point(drawing.points, shape.points[1].x, shape.points[1].y)
  local n = #shape.points
  shape.p2 = insert_point(drawing.points, shape.points[n].x, shape.points[n].y)
end

-- turn a line either horizontal or vertical
function Drawing.convert_horvert(drawing, shape)
  if shape.mode == 'freehand' then
    convert_line(shape)
  end
  assert(shape.mode == 'line')
  local p1 = drawing.points[shape.p1]
  local p2 = drawing.points[shape.p2]
  if math.abs(p1.x-p2.x) > math.abs(p1.y-p2.y) then
    p2.y = p1.y
  else
    p2.x = p1.x
  end
end

function Drawing.smoothen(shape)
  assert(shape.mode == 'freehand')
  for _=1,7 do
    for i=2,#shape.points-1 do
      local a = shape.points[i-1]
      local b = shape.points[i]
      local c = shape.points[i+1]
      b.x = (a.x + b.x + c.x)/3
      b.y = (a.y + b.y + c.y)/3
    end
  end
end

function Drawing.insert_point(points, x,y)
  for i,point in ipairs(points) do
    if Drawing.near(point, x,y) then
      return i
    end
  end
  table.insert(points, {x=x, y=y})
  return #points
end

function Drawing.near(point, x,y)
  local px,py = Drawing.pixels(x),Drawing.pixels(y)
  local cx,cy = Drawing.pixels(point.x), Drawing.pixels(point.y)
  return (cx-px)*(cx-px) + (cy-py)*(cy-py) < 16
end

function Drawing.draw_shape(left,top, drawing, shape)
  if shape.mode == 'freehand' then
    local prev = nil
    for _,point in ipairs(shape.points) do
      if prev then
        love.graphics.line(Drawing.pixels(prev.x)+left,Drawing.pixels(prev.y)+top, Drawing.pixels(point.x)+left,Drawing.pixels(point.y)+top)
      end
      prev = point
    end
  elseif shape.mode == 'line' or shape.mode == 'manhattan' then
    local p1 = drawing.points[shape.p1]
    local p2 = drawing.points[shape.p2]
    love.graphics.line(Drawing.pixels(p1.x)+left,Drawing.pixels(p1.y)+top, Drawing.pixels(p2.x)+left,Drawing.pixels(p2.y)+top)
  elseif shape.mode == 'polygon' then
    local prev = nil
    for _,point in ipairs(shape.vertices) do
      local curr = drawing.points[point]
      if prev then
        love.graphics.line(Drawing.pixels(prev.x)+left,Drawing.pixels(prev.y)+top, Drawing.pixels(curr.x)+left,Drawing.pixels(curr.y)+top)
      end
      prev = curr
    end
    -- close the loop
    local curr = drawing.points[shape.vertices[1]]
    love.graphics.line(Drawing.pixels(prev.x)+left,Drawing.pixels(prev.y)+top, Drawing.pixels(curr.x)+left,Drawing.pixels(curr.y)+top)
  elseif shape.mode == 'circle' then
    local center = drawing.points[shape.center]
    love.graphics.circle('line', Drawing.pixels(center.x)+left,Drawing.pixels(center.y)+top, Drawing.pixels(shape.radius))
  elseif shape.mode == 'arc' then
    local center = drawing.points[shape.center]
    love.graphics.arc('line', 'open', Drawing.pixels(center.x)+left,Drawing.pixels(center.y)+top, Drawing.pixels(shape.radius), shape.start_angle, shape.end_angle, 360)
  elseif shape.mode == 'deleted' then
  else
    print(shape.mode)
    assert(false)
  end
end

function Drawing.draw_pending_shape(left,top, drawing)
  local shape = drawing.pending
  if shape.mode == 'freehand' then
    draw_shape(left,top, drawing, shape)
  elseif shape.mode == 'line' then
    local p1 = drawing.points[shape.p1]
    local mx,my = Drawing.coord(love.mouse.getX()-16), Drawing.coord(love.mouse.getY()-drawing.y)
    if mx < 0 or mx >= 256 or my < 0 or my >= drawing.h then
      return
    end
    love.graphics.line(Drawing.pixels(p1.x)+left,Drawing.pixels(p1.y)+top, Drawing.pixels(mx)+left,Drawing.pixels(my)+top)
  elseif shape.mode == 'manhattan' then
    local p1 = drawing.points[shape.p1]
    local mx,my = Drawing.coord(love.mouse.getX()-16), Drawing.coord(love.mouse.getY()-drawing.y)
    if mx < 0 or mx >= 256 or my < 0 or my >= drawing.h then
      return
    end
    if math.abs(mx-p1.x) > math.abs(my-p1.y) then
      love.graphics.line(Drawing.pixels(p1.x)+left,Drawing.pixels(p1.y)+top, Drawing.pixels(mx)+left,Drawing.pixels(p1.y)+top)
    else
      love.graphics.line(Drawing.pixels(p1.x)+left,Drawing.pixels(p1.y)+top, Drawing.pixels(p1.x)+left,Drawing.pixels(my)+top)
    end
  elseif shape.mode == 'polygon' then
    -- don't close the loop on a pending polygon
    local prev = nil
    for _,point in ipairs(shape.vertices) do
      local curr = drawing.points[point]
      if prev then
        love.graphics.line(Drawing.pixels(prev.x)+left,Drawing.pixels(prev.y)+top, Drawing.pixels(curr.x)+left,Drawing.pixels(curr.y)+top)
      end
      prev = curr
    end
    love.graphics.line(Drawing.pixels(prev.x)+left,Drawing.pixels(prev.y)+top, love.mouse.getX(),love.mouse.getY())
  elseif shape.mode == 'circle' then
    local center = drawing.points[shape.center]
    local mx,my = Drawing.coord(love.mouse.getX()-16), Drawing.coord(love.mouse.getY()-drawing.y)
    if mx < 0 or mx >= 256 or my < 0 or my >= drawing.h then
      return
    end
    local cx,cy = Drawing.pixels(center.x)+left, Drawing.pixels(center.y)+top
    love.graphics.circle('line', cx,cy, math.dist(cx,cy, love.mouse.getX(),love.mouse.getY()))
  elseif shape.mode == 'arc' then
    local center = drawing.points[shape.center]
    local mx,my = Drawing.coord(love.mouse.getX()-16), Drawing.coord(love.mouse.getY()-drawing.y)
    if mx < 0 or mx >= 256 or my < 0 or my >= drawing.h then
      return
    end
    shape.end_angle = geom.angle_with_hint(center.x,center.y, mx,my, shape.end_angle)
    local cx,cy = Drawing.pixels(center.x)+left, Drawing.pixels(center.y)+top
    love.graphics.arc('line', 'open', cx,cy, Drawing.pixels(shape.radius), shape.start_angle, shape.end_angle, 360)
  end
end

function Drawing.pixels(n)  -- parts to pixels
  return n*Drawing_width/256
end
function Drawing.coord(n)  -- pixels to parts
  return math.floor(n*256/Drawing_width)
end

return Drawing