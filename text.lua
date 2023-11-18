-- text editor, particularly text drawing, horizontal wrap, vertical scrolling
Text = {}

-- draw a line starting from startpos to screen at y between State.left and State.right
-- return y for the next line, and position of start of final screen line drawn
function Text.draw(State, line_index, y, startpos)
--?   print('text.draw', line_index, y)
  local line = State.lines[line_index]
  local line_cache = State.line_cache[line_index]
  line_cache.starty = y
  line_cache.startpos = startpos
  -- wrap long lines
  local final_screen_line_starting_pos = startpos  -- track value to return
  Text.populate_screen_line_starting_pos(State, line_index)
  assert(#line_cache.screen_line_starting_pos >= 1, 'line cache missing screen line info')
  for i=1,#line_cache.screen_line_starting_pos do
    local pos = line_cache.screen_line_starting_pos[i]
    if pos < startpos then
      -- render nothing
    else
      final_screen_line_starting_pos = pos
      local screen_line = Text.screen_line(line, line_cache, i)
--?       print('text.draw:', screen_line, 'at', line_index,pos, 'after', x,y)
      local frag_len = utf8.len(screen_line)
      -- render any highlights
      if State.selection1.line then
        local lo, hi = Text.clip_selection(State, line_index, pos, pos+frag_len)
        Text.draw_highlight(State, line, State.left,y, pos, lo,hi)
      end
      if line_index == State.cursor1.line then
        -- render search highlight or cursor
        if State.search_term then
          local data = State.lines[State.cursor1.line].data
          local cursor_offset = Text.offset(data, State.cursor1.pos)
          if data:sub(cursor_offset, cursor_offset+#State.search_term-1) == State.search_term then
            local save_selection = State.selection1
            State.selection1 = {line=line_index, pos=State.cursor1.pos+utf8.len(State.search_term)}
            local lo, hi = Text.clip_selection(State, line_index, pos, pos+frag_len)
            Text.draw_highlight(State, line, State.left,y, pos, lo,hi)
            State.selection1 = save_selection
          end
        else
          if pos <= State.cursor1.pos and pos + frag_len > State.cursor1.pos then
            Text.pretend_draw_cursor(State, State.left+Text.x(screen_line, State.cursor1.pos-pos+1), y)
          elseif pos + frag_len == State.cursor1.pos then
            -- Keep pretend cursor_x/cursor_y in sync with upstream.
            Text.pretend_draw_cursor(State, State.left+Text.x(screen_line, State.cursor1.pos-pos+1), y)
          end
        end
      end
      -- render fragment
      App.color(Text_color)
      App.screen.print(screen_line, State.left,y)
      y = y + State.line_height
      if y >= App.screen.height then
        break
      end
    end
  end
  return y, final_screen_line_starting_pos
end

function Text.screen_line(line, line_cache, i)
  local pos = line_cache.screen_line_starting_pos[i]
  local offset = Text.offset(line.data, pos)
  if i >= #line_cache.screen_line_starting_pos then
    return line.data:sub(offset)
  end
  local endpos = line_cache.screen_line_starting_pos[i+1]-1
  local end_offset = Text.offset(line.data, endpos)
  return line.data:sub(offset, end_offset)
end

function Text.draw_cursor(State, x, y)
  -- blink every 0.5s
  if math.floor(Cursor_time*2)%2 == 0 then
    App.color(Cursor_color)
    love.graphics.rectangle('fill', x,y, 3,State.line_height)
  end
  State.cursor_x = x
  State.cursor_y = y+State.line_height
end

function Text.pretend_draw_cursor(State, x, y)
  State.cursor_x = x
  State.cursor_y = y+State.line_height
end

function Text.populate_screen_line_starting_pos(State, line_index)
  local line = State.lines[line_index]
  local line_cache = State.line_cache[line_index]
  if line_cache.screen_line_starting_pos then
    return
  end
  line_cache.screen_line_starting_pos = {1}
  local x = 0
  local pos = 1
  -- try to wrap at word boundaries
  for frag in line.data:gmatch('%S*%s*') do
    local frag_width = App.width(frag)
--?     print('-- frag:', frag, pos, x, frag_width, State.width)
    while x + frag_width > State.width do
--?       print('frag:', frag, pos, x, frag_width, State.width)
      if x < 0.8 * State.width then
        -- long word; chop it at some letter
        -- We're not going to reimplement TeX here.
        local bpos = Text.nearest_pos_less_than(frag, State.width - x)
        -- everything works if bpos == 0, but is a little inefficient
        pos = pos + bpos
        local boffset = Text.offset(frag, bpos+1)  -- byte _after_ bpos
        frag = string.sub(frag, boffset)
--?         if bpos > 0 then
--?           print('after chop:', frag)
--?         end
        frag_width = App.width(frag)
      end
--?       print('screen line:', pos)
      table.insert(line_cache.screen_line_starting_pos, pos)
      x = 0  -- new screen line
    end
    x = x + frag_width
    pos = pos + utf8.len(frag)
  end
end

function Text.keychord_press(State, chord)
--?   print('chord', chord, State.selection1.line, State.selection1.pos)
  --== shortcuts that move the cursor
  if chord == 'left' then
    Text.left(State)
    State.selection1 = {}
  elseif chord == 'right' then
    Text.right(State)
    State.selection1 = {}
  elseif chord == 'S-left' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.left(State)
  elseif chord == 'S-right' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.right(State)
  -- C- hotkeys reserved for drawings, so we'll use M-
  elseif chord == 'M-left' then
    Text.word_left(State)
    State.selection1 = {}
  elseif chord == 'M-right' then
    Text.word_right(State)
    State.selection1 = {}
  elseif chord == 'M-S-left' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.word_left(State)
  elseif chord == 'M-S-right' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.word_right(State)
  elseif chord == 'home' then
    Text.start_of_line(State)
    State.selection1 = {}
  elseif chord == 'end' then
    Text.end_of_line(State)
    State.selection1 = {}
  elseif chord == 'S-home' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.start_of_line(State)
  elseif chord == 'S-end' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.end_of_line(State)
  elseif chord == 'up' then
    Text.up(State)
    State.selection1 = {}
  elseif chord == 'down' then
    Text.down(State)
    State.selection1 = {}
  elseif chord == 'S-up' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.up(State)
  elseif chord == 'S-down' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.down(State)
  elseif chord == 'pageup' then
    Text.pageup(State)
    State.selection1 = {}
  elseif chord == 'pagedown' then
    Text.pagedown(State)
    State.selection1 = {}
  elseif chord == 'S-pageup' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.pageup(State)
  elseif chord == 'S-pagedown' then
    if State.selection1.line == nil then
      State.selection1 = {line=State.cursor1.line, pos=State.cursor1.pos}
    end
    Text.pagedown(State)
  end
end

function Text.pageup(State)
--?   print('pageup')
  -- duplicate some logic from love.draw
  local top2 = Text.to2(State, State.screen_top1)
--?   print(App.screen.height)
  local y = App.screen.height - State.line_height
  while y >= State.top do
--?     print(y, top2.line, top2.screen_line, top2.screen_pos)
    if State.screen_top1.line == 1 and State.screen_top1.pos == 1 then break end
    y = y - State.line_height
    top2 = Text.previous_screen_line(State, top2)
  end
  State.screen_top1 = Text.to1(State, top2)
  State.cursor1 = {line=State.screen_top1.line, pos=State.screen_top1.pos}
  Text.move_cursor_down_to_next_text_line_while_scrolling_again_if_necessary(State)
--?   print(State.cursor1.line, State.cursor1.pos, State.screen_top1.line, State.screen_top1.pos)
--?   print('pageup end')
end

function Text.pagedown(State)
--?   print('pagedown')
  -- If a line/paragraph gets to a page boundary, I often want to scroll
  -- before I get to the bottom.
  -- However, only do this if it makes forward progress.
  local bot2 = Text.to2(State, State.screen_bottom1)
  if bot2.screen_line > 1 then
    bot2.screen_line = math.max(bot2.screen_line-10, 1)
  end
  local new_top1 = Text.to1(State, bot2)
  if Text.lt1(State.screen_top1, new_top1) then
    State.screen_top1 = new_top1
  else
    State.screen_top1 = {line=State.screen_bottom1.line, pos=State.screen_bottom1.pos}
  end
--?   print('setting top to', State.screen_top1.line, State.screen_top1.pos)
  State.cursor1 = {line=State.screen_top1.line, pos=State.screen_top1.pos}
  Text.move_cursor_down_to_next_text_line_while_scrolling_again_if_necessary(State)
--?   print('top now', State.screen_top1.line)
  Text.redraw_all(State)  -- if we're scrolling, reclaim all fragments to avoid memory leaks
--?   print('pagedown end')
end

function Text.up(State)
--?   print('up', State.cursor1.line, State.cursor1.pos, State.screen_top1.line, State.screen_top1.pos)
  local screen_line_starting_pos, screen_line_index = Text.pos_at_start_of_screen_line(State, State.cursor1)
  if screen_line_starting_pos == 1 then
--?     print('cursor is at first screen line of its line')
    -- line is done; skip to previous text line
    if State.cursor1.line > 1 then
      local new_cursor_line = State.cursor1.line-1
--?       print('found previous text line')
      State.cursor1 = {line=new_cursor_line, pos=nil}
      Text.populate_screen_line_starting_pos(State, State.cursor1.line)
      -- previous text line found, pick its final screen line
--?       print('has multiple screen lines')
      local screen_line_starting_pos = State.line_cache[State.cursor1.line].screen_line_starting_pos
--?       print(#screen_line_starting_pos)
      screen_line_starting_pos = screen_line_starting_pos[#screen_line_starting_pos]
      local screen_line_starting_byte_offset = Text.offset(State.lines[State.cursor1.line].data, screen_line_starting_pos)
      local s = string.sub(State.lines[State.cursor1.line].data, screen_line_starting_byte_offset)
      State.cursor1.pos = screen_line_starting_pos + Text.nearest_cursor_pos(s, State.cursor_x, State.left) - 1
    end
  else
    -- move up one screen line in current line
    assert(screen_line_index > 1, 'bumped up against top screen line in line')
    local new_screen_line_starting_pos = State.line_cache[State.cursor1.line].screen_line_starting_pos[screen_line_index-1]
    local new_screen_line_starting_byte_offset = Text.offset(State.lines[State.cursor1.line].data, new_screen_line_starting_pos)
    local s = string.sub(State.lines[State.cursor1.line].data, new_screen_line_starting_byte_offset)
    State.cursor1.pos = new_screen_line_starting_pos + Text.nearest_cursor_pos(s, State.cursor_x, State.left) - 1
--?     print('cursor pos is now '..tostring(State.cursor1.pos))
  end
  if Text.lt1(State.cursor1, State.screen_top1) then
    State.screen_top1 = {
      line=State.cursor1.line,
      pos=Text.pos_at_start_of_screen_line(State, State.cursor1),
    }
    Text.redraw_all(State)  -- if we're scrolling, reclaim all fragments to avoid memory leaks
  end
end

function Text.down(State)
--?   print('down', State.cursor1.line, State.cursor1.pos, State.screen_top1.line, State.screen_top1.pos, State.screen_bottom1.line, State.screen_bottom1.pos)
  assert(State.cursor1.pos, 'cursor has no pos')
  if Text.cursor_at_final_screen_line(State) then
    -- line is done, skip to next text line
--?     print('cursor at final screen line of its line')
    if State.cursor1.line < #State.lines then
      local new_cursor_line = State.cursor1.line+1
      State.cursor1.line = new_cursor_line
      State.cursor1.pos = Text.nearest_cursor_pos(State.lines[State.cursor1.line].data, State.cursor_x, State.left)
--?       print(State.cursor1.pos)
    end
    if State.cursor1.line > State.screen_bottom1.line then
--?       print('screen top before:', State.screen_top1.line, State.screen_top1.pos)
--?       print('scroll up preserving cursor')
      Text.snap_cursor_to_bottom_of_screen(State)
--?       print('screen top after:', State.screen_top1.line, State.screen_top1.pos)
    end
  else
    -- move down one screen line in current line
    local scroll_down = Text.le1(State.screen_bottom1, State.cursor1)
--?     print('cursor is NOT at final screen line of its line')
    local screen_line_starting_pos, screen_line_index = Text.pos_at_start_of_screen_line(State, State.cursor1)
    Text.populate_screen_line_starting_pos(State, State.cursor1.line)
    local new_screen_line_starting_pos = State.line_cache[State.cursor1.line].screen_line_starting_pos[screen_line_index+1]
--?     print('switching pos of screen line at cursor from '..tostring(screen_line_starting_pos)..' to '..tostring(new_screen_line_starting_pos))
    local new_screen_line_starting_byte_offset = Text.offset(State.lines[State.cursor1.line].data, new_screen_line_starting_pos)
    local s = string.sub(State.lines[State.cursor1.line].data, new_screen_line_starting_byte_offset)
    State.cursor1.pos = new_screen_line_starting_pos + Text.nearest_cursor_pos(s, State.cursor_x, State.left) - 1
--?     print('cursor pos is now', State.cursor1.line, State.cursor1.pos)
    if scroll_down then
--?       print('scroll up preserving cursor')
      Text.snap_cursor_to_bottom_of_screen(State)
--?       print('screen top after:', State.screen_top1.line, State.screen_top1.pos)
    end
  end
--?   print('=>', State.cursor1.line, State.cursor1.pos, State.screen_top1.line, State.screen_top1.pos, State.screen_bottom1.line, State.screen_bottom1.pos)
end

function Text.start_of_line(State)
  State.cursor1.pos = 1
  if Text.lt1(State.cursor1, State.screen_top1) then
    State.screen_top1 = {line=State.cursor1.line, pos=State.cursor1.pos}  -- copy
  end
end

function Text.end_of_line(State)
  State.cursor1.pos = utf8.len(State.lines[State.cursor1.line].data) + 1
  if Text.cursor_out_of_screen(State) then
    Text.snap_cursor_to_bottom_of_screen(State)
  end
end

function Text.word_left(State)
  -- skip some whitespace
  while true do
    if State.cursor1.pos == 1 then
      break
    end
    if Text.match(State.lines[State.cursor1.line].data, State.cursor1.pos-1, '%S') then
      break
    end
    Text.left(State)
  end
  -- skip some non-whitespace
  while true do
    Text.left(State)
    if State.cursor1.pos == 1 then
      break
    end
    assert(State.cursor1.pos > 1, 'bumped up against start of line')
    if Text.match(State.lines[State.cursor1.line].data, State.cursor1.pos-1, '%s') then
      break
    end
  end
end

function Text.word_right(State)
  -- skip some whitespace
  while true do
    if State.cursor1.pos > utf8.len(State.lines[State.cursor1.line].data) then
      break
    end
    if Text.match(State.lines[State.cursor1.line].data, State.cursor1.pos, '%S') then
      break
    end
    Text.right_without_scroll(State)
  end
  while true do
    Text.right_without_scroll(State)
    if State.cursor1.pos > utf8.len(State.lines[State.cursor1.line].data) then
      break
    end
    if Text.match(State.lines[State.cursor1.line].data, State.cursor1.pos, '%s') then
      break
    end
  end
  if Text.cursor_out_of_screen(State) then
    Text.snap_cursor_to_bottom_of_screen(State)
  end
end

function Text.match(s, pos, pat)
  local start_offset = Text.offset(s, pos)
  local end_offset = Text.offset(s, pos+1)
  assert(end_offset > start_offset, ('end_offset %d not > start_offset %d'):format(end_offset, start_offset))
  local curr = s:sub(start_offset, end_offset-1)
  return curr:match(pat)
end

function Text.left(State)
  if State.cursor1.pos > 1 then
    State.cursor1.pos = State.cursor1.pos-1
  elseif State.cursor1.line > 1 then
    State.cursor1.line = State.cursor1.line-1
    State.cursor1.pos = utf8.len(State.lines[State.cursor1.line].data) + 1
  end
  if Text.lt1(State.cursor1, State.screen_top1) then
    State.screen_top1 = {
      line=State.cursor1.line,
      pos=Text.pos_at_start_of_screen_line(State, State.cursor1),
    }
    Text.redraw_all(State)  -- if we're scrolling, reclaim all fragments to avoid memory leaks
  end
end

function Text.right(State)
  Text.right_without_scroll(State)
  if Text.cursor_out_of_screen(State) then
    Text.snap_cursor_to_bottom_of_screen(State)
  end
end

function Text.right_without_scroll(State)
  if State.cursor1.pos <= utf8.len(State.lines[State.cursor1.line].data) then
    State.cursor1.pos = State.cursor1.pos+1
  elseif State.cursor1.line <= #State.lines-1 then
    State.cursor1.line = State.cursor1.line+1
    State.cursor1.pos = 1
  end
end

-- result: pos, index of screen line
function Text.pos_at_start_of_screen_line(State, loc1)
  Text.populate_screen_line_starting_pos(State, loc1.line)
  local line_cache = State.line_cache[loc1.line]
  for i=#line_cache.screen_line_starting_pos,1,-1 do
    local spos = line_cache.screen_line_starting_pos[i]
    if spos <= loc1.pos then
      return spos,i
    end
  end
  assert(false, ('invalid pos %d'):format(loc1.pos))
end

function Text.pos_at_end_of_screen_line(State, loc1)
  Text.populate_screen_line_starting_pos(State, loc1.line)
  local line_cache = State.line_cache[loc1.line]
  local most_recent_final_pos = utf8.len(State.lines[loc1.line].data)+1
  for i=#line_cache.screen_line_starting_pos,1,-1 do
    local spos = line_cache.screen_line_starting_pos[i]
    if spos <= loc1.pos then
      return most_recent_final_pos
    end
    most_recent_final_pos = spos-1
  end
  assert(false, ('invalid pos %d'):format(loc1.pos))
end

function Text.cursor_at_final_screen_line(State)
  Text.populate_screen_line_starting_pos(State, State.cursor1.line)
  local screen_lines = State.line_cache[State.cursor1.line].screen_line_starting_pos
--?   print(screen_lines[#screen_lines], State.cursor1.pos)
  return screen_lines[#screen_lines] <= State.cursor1.pos
end

function Text.move_cursor_down_to_next_text_line_while_scrolling_again_if_necessary(State)
  if State.top > App.screen.height - State.line_height then
--?     print('scroll up')
    Text.snap_cursor_to_bottom_of_screen(State)
  end
end

-- should never modify State.cursor1
function Text.snap_cursor_to_bottom_of_screen(State)
--?   print('to2:', State.cursor1.line, State.cursor1.pos)
  local top2 = Text.to2(State, State.cursor1)
--?   print('to2: =>', top2.line, top2.screen_line, top2.screen_pos)
  -- slide to start of screen line
  top2.screen_pos = 1  -- start of screen line
--?   print('snap', State.screen_top1.line, State.screen_top1.pos, State.cursor1.line, State.cursor1.pos, State.screen_bottom1.line, State.screen_bottom1.pos)
--?   print('cursor pos '..tostring(State.cursor1.pos)..' is on the #'..tostring(top2.screen_line)..' screen line down')
  local y = App.screen.height - State.line_height
  -- duplicate some logic from love.draw
  while true do
--?     print(y, 'top2:', top2.line, top2.screen_line, top2.screen_pos)
    if top2.line == 1 and top2.screen_line == 1 then break end
    local h = State.line_height
    if y - h < State.top then
      break
    end
    y = y - h
    top2 = Text.previous_screen_line(State, top2)
  end
--?   print('top2 finally:', top2.line, top2.screen_line, top2.screen_pos)
  State.screen_top1 = Text.to1(State, top2)
--?   print('top1 finally:', State.screen_top1.line, State.screen_top1.pos)
--?   print('snap =>', State.screen_top1.line, State.screen_top1.pos, State.cursor1.line, State.cursor1.pos, State.screen_bottom1.line, State.screen_bottom1.pos)
  Text.redraw_all(State)  -- if we're scrolling, reclaim all fragments to avoid memory leaks
end

function Text.in_line(State, line_index, x,y)
  local line = State.lines[line_index]
  local line_cache = State.line_cache[line_index]
  if line_cache.starty == nil then return false end  -- outside current page
  if y < line_cache.starty then return false end
  Text.populate_screen_line_starting_pos(State, line_index)
  return y < line_cache.starty + State.line_height*(#line_cache.screen_line_starting_pos - Text.screen_line_index(line_cache.screen_line_starting_pos, line_cache.startpos) + 1)
end

-- convert mx,my in pixels to schema-1 coordinates
function Text.to_pos_on_line(State, line_index, mx, my)
  local line = State.lines[line_index]
  local line_cache = State.line_cache[line_index]
  assert(my >= line_cache.starty, 'failed to map y pixel to line')
  -- duplicate some logic from Text.draw
  local y = line_cache.starty
  local start_screen_line_index = Text.screen_line_index(line_cache.screen_line_starting_pos, line_cache.startpos)
  for screen_line_index = start_screen_line_index,#line_cache.screen_line_starting_pos do
    local screen_line_starting_pos = line_cache.screen_line_starting_pos[screen_line_index]
    local screen_line_starting_byte_offset = Text.offset(line.data, screen_line_starting_pos)
--?     print('iter', y, screen_line_index, screen_line_starting_pos, string.sub(line.data, screen_line_starting_byte_offset))
    local nexty = y + State.line_height
    if my < nexty then
      -- On all wrapped screen lines but the final one, clicks past end of
      -- line position cursor on final character of screen line.
      -- (The final screen line positions past end of screen line as always.)
      if screen_line_index < #line_cache.screen_line_starting_pos and mx > State.left + Text.screen_line_width(State, line_index, screen_line_index) then
--?         print('past end of non-final line; return')
        return line_cache.screen_line_starting_pos[screen_line_index+1]-1
      end
      local s = string.sub(line.data, screen_line_starting_byte_offset)
--?       print('return', mx, Text.nearest_cursor_pos(s, mx, State.left), '=>', screen_line_starting_pos + Text.nearest_cursor_pos(s, mx, State.left) - 1)
      return screen_line_starting_pos + Text.nearest_cursor_pos(s, mx, State.left) - 1
    end
    y = nexty
  end
  assert(false, 'failed to map y pixel to line')
end

function Text.screen_line_width(State, line_index, i)
  local line = State.lines[line_index]
  local line_cache = State.line_cache[line_index]
  local start_pos = line_cache.screen_line_starting_pos[i]
  local start_offset = Text.offset(line.data, start_pos)
  local screen_line
  if i < #line_cache.screen_line_starting_pos then
    local past_end_pos = line_cache.screen_line_starting_pos[i+1]
    local past_end_offset = Text.offset(line.data, past_end_pos)
    screen_line = string.sub(line.data, start_offset, past_end_offset-1)
  else
    screen_line = string.sub(line.data, start_pos)
  end
  return App.width(screen_line)
end

function Text.screen_line_index(screen_line_starting_pos, pos)
  for i = #screen_line_starting_pos,1,-1 do
    if screen_line_starting_pos[i] <= pos then
      return i
    end
  end
end

-- convert x pixel coordinate to pos
-- oblivious to wrapping
-- result: 1 to len+1
function Text.nearest_cursor_pos(line, x, left)
  if x < left then
    return 1
  end
  local len = utf8.len(line)
  local max_x = left+Text.x(line, len+1)
  if x > max_x then
    return len+1
  end
  local leftpos, rightpos = 1, len+1
--?   print('-- nearest', x)
  while true do
--?     print('nearest', x, '^'..line..'$', leftpos, rightpos)
    if leftpos == rightpos then
      return leftpos
    end
    local curr = math.floor((leftpos+rightpos)/2)
    local currxmin = left+Text.x(line, curr)
    local currxmax = left+Text.x(line, curr+1)
--?     print('nearest', x, leftpos, rightpos, curr, currxmin, currxmax)
    if currxmin <= x and x < currxmax then
      if x-currxmin < currxmax-x then
        return curr
      else
        return curr+1
      end
    end
    if leftpos >= rightpos-1 then
      return rightpos
    end
    if currxmin > x then
      rightpos = curr
    else
      leftpos = curr
    end
  end
  assert(false, 'failed to map x pixel to pos')
end

-- return the nearest index of line (in utf8 code points) which lies entirely
-- within x pixels of the left margin
-- result: 0 to len+1
function Text.nearest_pos_less_than(line, x)
--?   print('', '-- nearest_pos_less_than', line, x)
  local len = utf8.len(line)
  local max_x = Text.x_after(line, len)
  if x > max_x then
    return len+1
  end
  local left, right = 0, len+1
  while true do
    local curr = math.floor((left+right)/2)
    local currxmin = Text.x_after(line, curr+1)
    local currxmax = Text.x_after(line, curr+2)
--?     print('', x, left, right, curr, currxmin, currxmax)
    if currxmin <= x and x < currxmax then
      return curr
    end
    if left >= right-1 then
      return left
    end
    if currxmin > x then
      right = curr
    else
      left = curr
    end
  end
  assert(false, 'failed to map x pixel to pos')
end

function Text.x_after(s, pos)
  local offset = Text.offset(s, math.min(pos+1, #s+1))
  local s_before = s:sub(1, offset-1)
--?   print('^'..s_before..'$')
  return App.width(s_before)
end

function Text.x(s, pos)
  local offset = Text.offset(s, pos)
  local s_before = s:sub(1, offset-1)
  return App.width(s_before)
end

function Text.to2(State, loc1)
  local result = {line=loc1.line}
  local line_cache = State.line_cache[loc1.line]
  Text.populate_screen_line_starting_pos(State, loc1.line)
  for i=#line_cache.screen_line_starting_pos,1,-1 do
    local spos = line_cache.screen_line_starting_pos[i]
    if spos <= loc1.pos then
      result.screen_line = i
      result.screen_pos = loc1.pos - spos + 1
      break
    end
  end
  assert(result.screen_pos, 'failed to convert schema-1 coordinate to schema-2')
  return result
end

function Text.to1(State, loc2)
  local result = {line=loc2.line, pos=loc2.screen_pos}
  if loc2.screen_line > 1 then
    result.pos = State.line_cache[loc2.line].screen_line_starting_pos[loc2.screen_line] + loc2.screen_pos - 1
  end
  return result
end

function Text.eq1(a, b)
  return a.line == b.line and a.pos == b.pos
end

function Text.lt1(a, b)
  if a.line < b.line then
    return true
  end
  if a.line > b.line then
    return false
  end
  return a.pos < b.pos
end

function Text.le1(a, b)
  if a.line < b.line then
    return true
  end
  if a.line > b.line then
    return false
  end
  return a.pos <= b.pos
end

function Text.offset(s, pos1)
  if pos1 == 1 then return 1 end
  local result = utf8.offset(s, pos1)
  if result == nil then
    print(pos1, #s, s)
  end
  assert(result, "Text.offset returned nil; this is likely a failure to handle utf8")
  return result
end

function Text.previous_screen_line(State, loc2)
  if loc2.screen_line > 1 then
    return {line=loc2.line, screen_line=loc2.screen_line-1, screen_pos=1}
  elseif loc2.line == 1 then
    return loc2
  else
    local l = State.lines[loc2.line-1]
    Text.populate_screen_line_starting_pos(State, loc2.line-1)
    return {line=loc2.line-1, screen_line=#State.line_cache[loc2.line-1].screen_line_starting_pos, screen_pos=1}
  end
end

-- resize helper
function Text.tweak_screen_top_and_cursor(State)
  if State.screen_top1.pos == 1 then return end
  Text.populate_screen_line_starting_pos(State, State.screen_top1.line)
  local line = State.lines[State.screen_top1.line]
  local line_cache = State.line_cache[State.screen_top1.line]
  for i=2,#line_cache.screen_line_starting_pos do
    local pos = line_cache.screen_line_starting_pos[i]
    if pos == State.screen_top1.pos then
      break
    end
    if pos > State.screen_top1.pos then
      -- make sure screen top is at start of a screen line
      local prev = line_cache.screen_line_starting_pos[i-1]
      if State.screen_top1.pos - prev < pos - State.screen_top1.pos then
        State.screen_top1.pos = prev
      else
        State.screen_top1.pos = pos
      end
      break
    end
  end
  -- make sure cursor is on screen
  if Text.lt1(State.cursor1, State.screen_top1) then
    State.cursor1 = {line=State.screen_top1.line, pos=State.screen_top1.pos}
  elseif State.cursor1.line >= State.screen_bottom1.line then
--?     print('too low')
    if Text.cursor_out_of_screen(State) then
--?       print('tweak')
      State.cursor1 = {
          line=State.screen_bottom1.line,
          pos=Text.to_pos_on_line(State, State.screen_bottom1.line, State.right-5, App.screen.height-5),
      }
    end
  end
end

-- slightly expensive since it redraws the screen
function Text.cursor_out_of_screen(State)
  edit.draw(State)
  return State.cursor_y == nil
  -- this approach is cheaper and almost works, except on the final screen
  -- where file ends above bottom of screen
--?   local botpos = Text.pos_at_start_of_screen_line(State, State.cursor1)
--?   local botline1 = {line=State.cursor1.line, pos=botpos}
--?   return Text.lt1(State.screen_bottom1, botline1)
end

function Text.redraw_all(State)
--?   print('clearing fragments')
  State.line_cache = {}
  for i=1,#State.lines do
    State.line_cache[i] = {}
  end
end

function Text.clear_screen_line_cache(State, line_index)
  State.line_cache[line_index].screen_line_starting_pos = nil
end

function trim(s)
  return s:gsub('^%s+', ''):gsub('%s+$', '')
end

function ltrim(s)
  return s:gsub('^%s+', '')
end

function rtrim(s)
  return s:gsub('%s+$', '')
end

function starts_with(s, prefix)
  if #s < #prefix then
    return false
  end
  for i=1,#prefix do
    if s:sub(i,i) ~= prefix:sub(i,i) then
      return false
    end
  end
  return true
end

function ends_with(s, suffix)
  if #s < #suffix then
    return false
  end
  for i=0,#suffix-1 do
    if s:sub(#s-i,#s-i) ~= suffix:sub(#suffix-i,#suffix-i) then
      return false
    end
  end
  return true
end
