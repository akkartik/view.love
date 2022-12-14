-- some constants people might like to tweak
Text_color = {r=0, g=0, b=0}
Cursor_color = {r=1, g=0, b=0}
Focus_stroke_color = {r=1, g=0, b=0}  -- what mouse is hovering over
Highlight_color = {r=0.7, g=0.7, b=0.9}  -- selected text

Margin_top = 15
Margin_left = 25
Margin_right = 25

edit = {}

-- run in both tests and a real run
function edit.initialize_state(top, left, right, font_height, line_height)  -- currently always draws to bottom of screen
  local result = {
    lines = {{data=''}},  -- array of strings

    -- Lines can be too long to fit on screen, in which case they _wrap_ into
    -- multiple _screen lines_.

    -- rendering wrapped text lines needs some additional short-lived data per line:
    --   startpos, the index of data the line starts rendering from, can only be >1 for topmost line on screen
    --   starty, the y coord in pixels the line starts rendering from
    --   fragments: snippets of rendered love.graphics.Text, guaranteed to not straddle screen lines
    --   screen_line_starting_pos: optional array of grapheme indices if it wraps over more than one screen line
    line_cache = {},

    -- Given wrapping, any potential location for the text cursor can be described in two ways:
    -- * schema 1: As a combination of line index and position within a line (in utf8 codepoint units)
    -- * schema 2: As a combination of line index, screen line index within the line, and a position within the screen line.
    --
    -- Most of the time we'll only persist positions in schema 1, translating to
    -- schema 2 when that's convenient.
    --
    -- Make sure these coordinates are never aliased, so that changing one causes
    -- action at a distance.
    screen_top1 = {line=1, pos=1},  -- position of start of screen line at top of screen
    cursor1 = {line=1, pos=1},  -- position of cursor
    screen_bottom1 = {line=1, pos=1},  -- position of start of screen line at bottom of screen

    selection1 = {},
    -- some extra state to compute selection between mouse press and release
    old_cursor1 = nil,
    old_selection1 = nil,
    mousepress_shift = nil,
    -- when selecting text, avoid recomputing some state on every single frame
    recent_mouse = {},

    -- cursor coordinates in pixels
    cursor_x = 0,
    cursor_y = 0,

    font_height = font_height,
    line_height = line_height,
    em = App.newText(love.graphics.getFont(), 'm'),  -- widest possible character width

    top = top,
    left = math.floor(left),
    right = math.floor(right),
    width = right-left,

    filename = love.filesystem.getUserDirectory()..'/lines.txt',  -- '/' should work even on Windows

    -- search
    search_term = nil,
    search_text = nil,
    search_backup = nil,  -- stuff to restore when cancelling search
  }
  return result
end  -- App.initialize_state

function edit.draw(State)
  App.color(Text_color)
  assert(#State.lines == #State.line_cache)
  if not Text.le1(State.screen_top1, State.cursor1) then
    print(State.screen_top1.line, State.screen_top1.pos, State.cursor1.line, State.cursor1.pos)
    assert(false)
  end
  State.cursor_x = nil
  State.cursor_y = nil
  local y = State.top
--?   print('== draw')
  for line_index = State.screen_top1.line,#State.lines do
    local line = State.lines[line_index]
--?     print('draw:', y, line_index, line)
    if y + State.line_height > App.screen.height then break end
    State.screen_bottom1 = {line=line_index, pos=nil}
--?     print('text.draw', y, line_index)
    local startpos = 1
    if line_index == State.screen_top1.line then
      startpos = State.screen_top1.pos
    end
    y, State.screen_bottom1.pos = Text.draw(State, line_index, y, startpos)
    y = y + State.line_height
--?     print('=> y', y)
  end
  if State.search_term then
    Text.draw_search_bar(State)
  end
end

function edit.update(State, dt)
end

function edit.quit(State)
end

function edit.mouse_press(State, x,y, mouse_button)
  if State.search_term then return end
--?   print('press', State.selection1.line, State.selection1.pos)
  for line_index,line in ipairs(State.lines) do
    if Text.in_line(State, line_index, x,y) then
      -- delicate dance between cursor, selection and old cursor/selection
      -- scenarios:
      --  regular press+release: sets cursor, clears selection
      --  shift press+release:
      --    sets selection to old cursor if not set otherwise leaves it untouched
      --    sets cursor
      --  press and hold to start a selection: sets selection on press, cursor on release
      --  press and hold, then press shift: ignore shift
      --    i.e. mouse_released should never look at shift state
      State.old_cursor1 = State.cursor1
      State.old_selection1 = State.selection1
      State.mousepress_shift = App.shift_down()
      State.selection1 = {
          line=line_index,
          pos=Text.to_pos_on_line(State, line_index, x, y),
      }
--?       print('selection', State.selection1.line, State.selection1.pos)
      break
    end
  end
end

function edit.mouse_release(State, x,y, mouse_button)
  if State.search_term then return end
--?   print('release')
  for line_index,line in ipairs(State.lines) do
    if Text.in_line(State, line_index, x,y) then
--?       print('reset selection')
      State.cursor1 = {
          line=line_index,
          pos=Text.to_pos_on_line(State, line_index, x, y),
      }
--?       print('cursor', State.cursor1.line, State.cursor1.pos)
      if State.mousepress_shift then
        if State.old_selection1.line == nil then
          State.selection1 = State.old_cursor1
        else
          State.selection1 = State.old_selection1
        end
      end
      State.old_cursor1, State.old_selection1, State.mousepress_shift = nil
      if eq(State.cursor1, State.selection1) then
        State.selection1 = {}
      end
      break
    end
  end
--?   print('selection:', State.selection1.line, State.selection1.pos)
end

function edit.text_input(State, t)
  if State.search_term then
    State.search_term = State.search_term..t
    State.search_text = nil
    Text.search_next(State)
  end
end

function edit.keychord_press(State, chord, key)
  if State.selection1.line and
      -- printable character created using shift key => delete selection
      -- (we're not creating any ctrl-shift- or alt-shift- combinations using regular/printable keys)
      (not App.shift_down() or utf8.len(key) == 1) and
      chord ~= 'C-a' and chord ~= 'C-c' and chord ~= 'C-x' and chord ~= 'backspace' and chord ~= 'delete' and chord ~= 'C-z' and not App.is_cursor_movement(chord) then
    Text.delete_selection(State, State.left, State.right)
  end
  if State.search_term then
    if chord == 'escape' then
      State.search_term = nil
      State.search_text = nil
      State.cursor1 = State.search_backup.cursor
      State.screen_top1 = State.search_backup.screen_top
      State.search_backup = nil
      Text.redraw_all(State)  -- if we're scrolling, reclaim all fragments to avoid memory leaks
    elseif chord == 'return' then
      State.search_term = nil
      State.search_text = nil
      State.search_backup = nil
    elseif chord == 'backspace' then
      local len = utf8.len(State.search_term)
      local byte_offset = Text.offset(State.search_term, len)
      State.search_term = string.sub(State.search_term, 1, byte_offset-1)
      State.search_text = nil
    elseif chord == 'down' then
      State.cursor1.pos = State.cursor1.pos+1
      Text.search_next(State)
    elseif chord == 'up' then
      Text.search_previous(State)
    end
    return
  elseif chord == 'C-f' then
    State.search_term = ''
    State.search_backup = {
      cursor={line=State.cursor1.line, pos=State.cursor1.pos},
      screen_top={line=State.screen_top1.line, pos=State.screen_top1.pos},
    }
    assert(State.search_text == nil)
  -- zoom
  elseif chord == 'C-=' then
    edit.update_font_settings(State, State.font_height+2)
    Text.redraw_all(State)
  elseif chord == 'C--' then
    edit.update_font_settings(State, State.font_height-2)
    Text.redraw_all(State)
  elseif chord == 'C-0' then
    edit.update_font_settings(State, 20)
    Text.redraw_all(State)
  -- clipboard
  elseif chord == 'C-a' then
    State.selection1 = {line=1, pos=1}
    State.cursor1 = {line=#State.lines, pos=utf8.len(State.lines[#State.lines].data)+1}
  elseif chord == 'C-c' then
    local s = Text.selection(State)
    if s then
      App.setClipboardText(s)
    end
  -- dispatch to text
  else
    for _,line_cache in ipairs(State.line_cache) do line_cache.starty = nil end  -- just in case we scroll
    Text.keychord_press(State, chord)
  end
end

function edit.key_release(State, key, scancode)
end

function edit.update_font_settings(State, font_height)
  State.font_height = font_height
  love.graphics.setFont(love.graphics.newFont(State.font_height))
  State.line_height = math.floor(font_height*1.3)
  State.em = App.newText(love.graphics.getFont(), 'm')
  Text_cache = {}
end

--== some methods for tests

-- Insulate tests from some key globals so I don't have to change the vast
-- majority of tests when they're modified for the real app.
Test_margin_left = 25
Test_margin_right = 0

function edit.initialize_test_state()
  -- if you change these values, tests will start failing
  return edit.initialize_state(
      15,  -- top margin
      Test_margin_left,
      App.screen.width - Test_margin_right,
      14,  -- font height assuming default L??VE font
      15)  -- line height
end

-- all text_input events are also keypresses
-- TODO: handle chords of multiple keys
function edit.run_after_text_input(State, t)
  edit.keychord_press(State, t)
  edit.text_input(State, t)
  edit.key_release(State, t)
  App.screen.contents = {}
  edit.update(State, 0)
  edit.draw(State)
end

-- not all keys are text_input
function edit.run_after_keychord(State, chord)
  edit.keychord_press(State, chord)
  edit.key_release(State, chord)
  App.screen.contents = {}
  edit.update(State, 0)
  edit.draw(State)
end

function edit.run_after_mouse_click(State, x,y, mouse_button)
  App.fake_mouse_press(x,y, mouse_button)
  edit.mouse_press(State, x,y, mouse_button)
  App.fake_mouse_release(x,y, mouse_button)
  edit.mouse_release(State, x,y, mouse_button)
  App.screen.contents = {}
  edit.update(State, 0)
  edit.draw(State)
end

function edit.run_after_mouse_press(State, x,y, mouse_button)
  App.fake_mouse_press(x,y, mouse_button)
  edit.mouse_press(State, x,y, mouse_button)
  App.screen.contents = {}
  edit.update(State, 0)
  edit.draw(State)
end

function edit.run_after_mouse_release(State, x,y, mouse_button)
  App.fake_mouse_release(x,y, mouse_button)
  edit.mouse_release(State, x,y, mouse_button)
  App.screen.contents = {}
  edit.update(State, 0)
  edit.draw(State)
end
