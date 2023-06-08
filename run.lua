run = {}

Editor_state = {}

-- called both in tests and real run
function run.initialize_globals()
  -- tests currently mostly clear their own state

  -- blinking cursor
  Cursor_time = 0
end

-- called only for real run
function run.initialize(arg)
  log_new('run')
  if Settings then
    run.load_settings()
  else
    run.initialize_default_settings()
  end

  if #arg > 0 and Editor_state.filename ~= absolutize(arg[1]) then
    Editor_state.filename = arg[1]
    load_from_disk(Editor_state)
    Text.redraw_all(Editor_state)
    Editor_state.screen_top1 = {line=1, pos=1}
    Editor_state.cursor1 = {line=1, pos=1}
  else
    load_from_disk(Editor_state)
    Text.redraw_all(Editor_state)
  end
  edit.check_locs(Editor_state)



  -- keep a few blank lines around: https://merveilles.town/@akkartik/110084833821965708
  love.window.setTitle('lines.love - '..Editor_state.filename)



  if #arg > 1 then
    print('ignoring commandline args after '..arg[1])
  end

  if rawget(_G, 'jit') then
    jit.off()
    jit.flush()
  end
end

function print_and_log(s)
  print(s)
  log(3, s)
end

function run.load_settings()
  love.graphics.setFont(love.graphics.newFont(Settings.font_height))
  -- determine default dimensions and flags
  App.screen.width, App.screen.height, App.screen.flags = App.screen.size()
  -- set up desired window dimensions
  App.screen.flags.resizable = true
  App.screen.flags.minwidth = math.min(App.screen.width, 200)
  App.screen.flags.minheight = math.min(App.screen.height, 200)
  App.screen.width, App.screen.height = Settings.width, Settings.height
  App.screen.resize(App.screen.width, App.screen.height, App.screen.flags)
  App.screen.move(Settings.x, Settings.y, Settings.displayindex)
  Editor_state = edit.initialize_state(Margin_top, Margin_left, App.screen.width-Margin_right, Settings.font_height, math.floor(Settings.font_height*1.3))
  Editor_state.filename = Settings.filename
  Editor_state.screen_top1 = Settings.screen_top
  Editor_state.cursor1 = Settings.cursor
end

function run.initialize_default_settings()
  local font_height = 20
  love.graphics.setFont(love.graphics.newFont(font_height))
  run.initialize_window_geometry(App.width('m'))
  Editor_state = edit.initialize_state(Margin_top, Margin_left, App.screen.width-Margin_right)
  Editor_state.font_height = font_height
  Editor_state.line_height = math.floor(font_height*1.3)
  Settings = run.settings()
end

function run.initialize_window_geometry(em_width)
  local os = love.system.getOS()
  if os == 'Android' or os == 'iOS' then
    -- maximizing on iOS breaks text rendering: https://github.com/deltadaedalus/vudu/issues/7
    -- no point second-guessing window dimensions on mobile
    App.screen.width, App.screen.height, App.screen.flags = App.screen.size()
    return
  end
  -- maximize window
  App.screen.resize(0, 0)  -- maximize
  App.screen.width, App.screen.height, App.screen.flags = App.screen.size()
  -- shrink height slightly to account for window decoration
  App.screen.height = App.screen.height-100
  App.screen.width = 40*em_width
  App.screen.flags.resizable = true
  App.screen.flags.minwidth = math.min(App.screen.width, 200)
  App.screen.flags.minheight = math.min(App.screen.height, 200)
  App.screen.resize(App.screen.width, App.screen.height, App.screen.flags)
end

function run.resize(w, h)
--?   print(("Window resized to width: %d and height: %d."):format(w, h))
  App.screen.width, App.screen.height = w, h
  Text.redraw_all(Editor_state)
  Editor_state.selection1 = {}  -- no support for shift drag while we're resizing
  Editor_state.right = App.screen.width-Margin_right
  Editor_state.width = Editor_state.right-Editor_state.left
  Text.tweak_screen_top_and_cursor(Editor_state, Editor_state.left, Editor_state.right)
end

function run.file_drop(file)
  -- first make sure to save edits on any existing file
  if Editor_state.next_save then
    save_to_disk(Editor_state)
  end
  -- clear the slate for the new file
  App.initialize_globals()
  Editor_state.filename = file:getFilename()
  file:open('r')
  Editor_state.lines = load_from_file(file)
  file:close()
  Text.redraw_all(Editor_state)
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.cursor1 = {line=1, pos=1}



  -- keep a few blank lines around: https://merveilles.town/@akkartik/110084833821965708
  love.window.setTitle('lines.love - '..Editor_state.filename)



end

function run.draw()
  edit.draw(Editor_state)
end

function run.update(dt)
  Cursor_time = Cursor_time + dt
  edit.update(Editor_state, dt)
end

function run.quit()
  edit.quit(Editor_state)
end

function run.settings()
  if Settings == nil then
    Settings = {}
  end
  if Current_app == 'run' then
    Settings.x, Settings.y, Settings.displayindex = App.screen.position()
  end
  return {
    x=Settings.x, y=Settings.y, displayindex=Settings.displayindex,
    width=App.screen.width, height=App.screen.height,
    font_height=Editor_state.font_height,
    filename=absolutize(Editor_state.filename),
    screen_top=Editor_state.screen_top1, cursor=Editor_state.cursor1
  }
end

function absolutize(path)
  if is_relative_path(path) then
    return love.filesystem.getWorkingDirectory()..'/'..path  -- '/' should work even on Windows
  end
  return path
end

function run.mouse_press(x,y, mouse_button)
  Cursor_time = 0  -- ensure cursor is visible immediately after it moves
  return edit.mouse_press(Editor_state, x,y, mouse_button)
end

function run.mouse_release(x,y, mouse_button)
  Cursor_time = 0  -- ensure cursor is visible immediately after it moves
  return edit.mouse_release(Editor_state, x,y, mouse_button)
end

function run.mouse_wheel_move(dx,dy)
  Cursor_time = 0  -- ensure cursor is visible immediately after it moves
  return edit.mouse_wheel_move(Editor_state, dx,dy)
end

function run.text_input(t)
  Cursor_time = 0  -- ensure cursor is visible immediately after it moves
  return edit.text_input(Editor_state, t)
end

function run.keychord_press(chord, key)
  Cursor_time = 0  -- ensure cursor is visible immediately after it moves
  return edit.keychord_press(Editor_state, chord, key)
end

function run.key_release(key, scancode)
  Cursor_time = 0  -- ensure cursor is visible immediately after it moves
  return edit.key_release(Editor_state, key, scancode)
end

function width(s)
  return love.graphics.getFont():getWidth(s)
end
