-- major tests for text editing flows
-- Arguably this should be called edit_tests.lua,
-- but that would mess up the git blame at this point.

function test_initial_state()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{}
  Text.redraw_all(Editor_state)
  edit.draw(Editor_state)
  check_eq(#Editor_state.lines, 1, '#lines')
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'cursor:pos')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 1, 'screen_top:pos')
end

function test_move_left()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'a'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=2}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'left', 'left')
  check_eq(Editor_state.cursor1.pos, 1, 'check')
end

function test_move_right()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'a'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'right', 'right')
  check_eq(Editor_state.cursor1.pos, 2, 'check')
end

function test_move_left_to_previous_line()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'left', 'left')
  check_eq(Editor_state.cursor1.line, 1, 'line')
  check_eq(Editor_state.cursor1.pos, 4, 'pos')  -- past end of line
end

function test_move_right_to_next_line()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=4}  -- past end of line
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'right', 'right')
  check_eq(Editor_state.cursor1.line, 2, 'line')
  check_eq(Editor_state.cursor1.pos, 1, 'pos')
end

function test_move_to_start_of_word()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=3}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left', 'left')
  check_eq(Editor_state.cursor1.pos, 1, 'check')
end

function test_move_to_start_of_previous_word()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=4}  -- at the space between words
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left', 'left')
  check_eq(Editor_state.cursor1.pos, 1, 'check')
end

function test_skip_to_previous_word()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=5}  -- at the start of second word
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left', 'left')
  check_eq(Editor_state.cursor1.pos, 1, 'check')
end

function test_skip_past_tab_to_previous_word()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def\tghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=10}  -- within third word
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left', 'left')
  check_eq(Editor_state.cursor1.pos, 9, 'check')
end

function test_skip_multiple_spaces_to_previous_word()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc  def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=6}  -- at the start of second word
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left', 'left')
  check_eq(Editor_state.cursor1.pos, 1, 'check')
end

function test_move_to_start_of_word_on_previous_line()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left', 'left')
  check_eq(Editor_state.cursor1.line, 1, 'line')
  check_eq(Editor_state.cursor1.pos, 5, 'pos')
end

function test_move_past_end_of_word()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right', 'right')
  check_eq(Editor_state.cursor1.pos, 4, 'check')
end

function test_skip_to_next_word()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=4}  -- at the space between words
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right', 'right')
  check_eq(Editor_state.cursor1.pos, 8, 'check')
end

function test_skip_past_tab_to_next_word()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc\tdef'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}  -- at the space between words
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right', 'right')
  check_eq(Editor_state.cursor1.pos, 4, 'check')
end

function test_skip_multiple_spaces_to_next_word()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc  def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=4}  -- at the start of second word
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right', 'right')
  check_eq(Editor_state.cursor1.pos, 9, 'check')
end

function test_move_past_end_of_word_on_next_line()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=8}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right', 'right')
  check_eq(Editor_state.cursor1.line, 2, 'line')
  check_eq(Editor_state.cursor1.pos, 4, 'pos')
end

function test_click_moves_cursor()
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.startpos for each line
  edit.run_after_mouse_release(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'cursor:pos')
  -- selection is empty to avoid perturbing future edits
  check_nil(Editor_state.selection1.line, 'selection:line')
  check_nil(Editor_state.selection1.pos, 'selection:pos')
end

function test_click_to_left_of_line()
  -- display a line with the cursor in the middle
  App.screen.init{width=50, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=3}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  -- click to the left of the line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left-4,Editor_state.top+5, 1)
  -- cursor moves to start of line
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'cursor:pos')
  check_nil(Editor_state.selection1.line, 'selection is empty to avoid perturbing future edits')
end

function test_click_takes_margins_into_account()
  -- display two lines with cursor on one of them
  App.screen.init{width=100, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.left = 50  -- occupy only right side of screen
  Editor_state.lines = load_array{'abc', 'def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  -- click on the other line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- cursor moves
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'cursor:pos')
  check_nil(Editor_state.selection1.line, 'selection is empty to avoid perturbing future edits')
end

function test_click_on_empty_line()
  -- display two lines with the first one empty
  App.screen.init{width=50, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'', 'def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  -- click on the empty line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- cursor moves
  check_eq(Editor_state.cursor1.line, 1, 'cursor')
  -- selection remains empty
  check_nil(Editor_state.selection1.line, 'selection is empty to avoid perturbing future edits')
end

function test_click_below_final_line_of_file()
  -- display one line
  App.screen.init{width=50, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  -- click below first line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+50, 1)
  -- cursor goes to bottom
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 4, 'cursor:pos')
  -- selection remains empty
  check_nil(Editor_state.selection1.line, 'selection is empty to avoid perturbing future edits')
end

function test_draw_text()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'screen:3')
end

function test_draw_wrapping_text()
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'defgh', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'de', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'fgh', 'screen:3')
end

function test_draw_word_wrapping_text()
  App.screen.init{width=60, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc ', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def ', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'screen:3')
end

function test_click_on_wrapping_line()
  -- display two screen lines with cursor on one of them
  App.screen.init{width=50, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def ghi jkl mno pqr stu'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=20}
  Editor_state.screen_top1 = {line=1, pos=1}
  -- click on the other line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- cursor moves
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'cursor:pos')
  check_nil(Editor_state.selection1.line, 'selection is empty to avoid perturbing future edits')
end

function test_click_on_wrapping_line_takes_margins_into_account()
  -- display two screen lines with cursor on one of them
  App.screen.init{width=100, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.left = 50  -- occupy only right side of screen
  Editor_state.lines = load_array{'abc def ghi jkl mno pqr stu'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=20}
  Editor_state.screen_top1 = {line=1, pos=1}
  -- click on the other line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- cursor moves
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'cursor:pos')
  check_nil(Editor_state.selection1.line, 'selection is empty to avoid perturbing future edits')
end

function test_draw_text_wrapping_within_word()
  -- arrange a screen line that needs to be split within a word
  App.screen.init{width=60, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abcd e fghijk', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abcd ', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'e fgh', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ijk', 'screen:3')
end

function test_draw_wrapping_text_containing_non_ascii()
  -- draw a long line containing non-ASCII
  App.screen.init{width=60, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'madam I’m adam', 'xyz'}  -- notice the non-ASCII apostrophe
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'mad', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'am I', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, '’m a', 'screen:3')
end

function test_click_past_end_of_screen_line()
  -- display a wrapping line
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
                               --  12345678901234
  Editor_state.lines = load_array{"madam I'm adam"}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'madam ', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, "I'm ad", 'baseline/screen:2')
  y = y + Editor_state.line_height
  -- click past end of second screen line
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of screen line (one more than final character shown)
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 13, 'cursor:pos')
end

function test_click_on_wrapping_line_rendered_from_partway_at_top_of_screen()
  -- display a wrapping line from its second screen line
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
                               --  12345678901234
  Editor_state.lines = load_array{"madam I'm adam"}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=8}
  Editor_state.screen_top1 = {line=1, pos=7}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, "I'm ad", 'baseline/screen:2')
  y = y + Editor_state.line_height
  -- click past end of second screen line
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of screen line (one more than final character shown)
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 13, 'cursor:pos')
end

function test_click_past_end_of_wrapping_line()
  -- display a wrapping line
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
                               --  12345678901234
  Editor_state.lines = load_array{"madam I'm adam"}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'madam ', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, "I'm ad", 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'am', 'baseline/screen:3')
  y = y + Editor_state.line_height
  -- click past the end of it
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of line
  check_eq(Editor_state.cursor1.pos, 15, 'cursor')  -- one more than the number of UTF-8 code-points
end

function test_click_past_end_of_wrapping_line_containing_non_ascii()
  -- display a wrapping line containing non-ASCII
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
                               --  12345678901234
  Editor_state.lines = load_array{'madam I’m adam'}  -- notice the non-ASCII apostrophe
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'madam ', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'I’m ad', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'am', 'baseline/screen:3')
  y = y + Editor_state.line_height
  -- click past the end of it
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of line
  check_eq(Editor_state.cursor1.pos, 15, 'cursor')  -- one more than the number of UTF-8 code-points
end

function test_click_past_end_of_word_wrapping_line()
  -- display a long line wrapping at a word boundary on a screen of more realistic length
  App.screen.init{width=160, height=80}
  Editor_state = edit.initialize_test_state()
                                -- 0        1         2
                                -- 123456789012345678901
  Editor_state.lines = load_array{'the quick brown fox jumped over the lazy dog'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'the quick brown fox ', 'baseline/screen:1')
  y = y + Editor_state.line_height
  -- click past the end of the screen line
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of screen line (one more than final character shown)
  check_eq(Editor_state.cursor1.pos, 21, 'cursor')
end

function test_select_text()
  -- display a line of text
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- select a letter
  App.fake_key_press('lshift')
  edit.run_after_keychord(Editor_state, 'S-right', 'right')
  App.fake_key_release('lshift')
  edit.key_release(Editor_state, 'lshift')
  -- selection persists even after shift is released
  check_eq(Editor_state.selection1.line, 1, 'selection:line')
  check_eq(Editor_state.selection1.pos, 1, 'selection:pos')
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'cursor:pos')
end

function test_cursor_movement_without_shift_resets_selection()
  -- display a line of text with some part selected
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.selection1 = {line=1, pos=2}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- press an arrow key without shift
  edit.run_after_keychord(Editor_state, 'right', 'right')
  -- no change to data, selection is reset
  check_nil(Editor_state.selection1.line, 'check')
  check_eq(Editor_state.lines[1].data, 'abc', 'data')
end

function test_copy_does_not_reset_selection()
  -- display a line of text with a selection
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.selection1 = {line=1, pos=2}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- copy selection
  edit.run_after_keychord(Editor_state, 'C-c', 'c')
  check_eq(App.clipboard, 'a', 'clipboard')
  -- selection is reset since shift key is not pressed
  check(Editor_state.selection1.line, 'check')
end

function test_move_cursor_using_mouse()

  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.startpos for each line
  edit.run_after_mouse_release(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'cursor:pos')
  check_nil(Editor_state.selection1.line, 'selection:line')
  check_nil(Editor_state.selection1.pos, 'selection:pos')
end

function test_select_text_using_mouse()
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.startpos for each line
  -- press and hold on first location
  edit.run_after_mouse_press(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- drag and release somewhere else
  edit.run_after_mouse_release(Editor_state, Editor_state.left+20,Editor_state.top+Editor_state.line_height+5, 1)
  check_eq(Editor_state.selection1.line, 1, 'selection:line')
  check_eq(Editor_state.selection1.pos, 2, 'selection:pos')
  check_eq(Editor_state.cursor1.line, 2, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 4, 'cursor:pos')
end

function test_select_text_using_mouse_starting_above_text()
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.startpos for each line
  -- press mouse above first line of text
  edit.run_after_mouse_press(Editor_state, Editor_state.left+8,5, 1)
  check(Editor_state.selection1.line ~= nil, 'selection:line-not-nil')
  check_eq(Editor_state.selection1.line, 1, 'selection:line')
  check_eq(Editor_state.selection1.pos, 1, 'selection:pos')
end

function test_select_text_using_mouse_starting_above_text_wrapping_line()
  -- first screen line starts in the middle of a line
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'defgh', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=5}
  Editor_state.screen_top1 = {line=2, pos=3}
  -- press mouse above first line of text
  edit.draw(Editor_state)
  edit.run_after_mouse_press(Editor_state, Editor_state.left+8,5, 1)
  -- selection is at screen top
  check(Editor_state.selection1.line ~= nil, 'selection:line-not-nil')
  check_eq(Editor_state.selection1.line, 2, 'selection:line')
  check_eq(Editor_state.selection1.pos, 3, 'selection:pos')
end

function test_select_text_using_mouse_starting_below_text()
  -- I'd like to test what happens when a mouse click is below some page of
  -- text, potentially even in the middle of a line.
  -- However, it's brittle to set up a text line boundary just right.
  -- So I'm going to just check things below the bottom of the final line of
  -- text when it's in the middle of the screen.
  -- final screen line ends in the middle of screen
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abcde'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'ab', 'baseline:screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'cde', 'baseline:screen:2')
  -- press mouse above first line of text
  edit.run_after_mouse_press(Editor_state, 5,App.screen.height-5, 1)
  -- selection is past bottom-most text in screen
  check(Editor_state.selection1.line ~= nil, 'selection:line-not-nil')
  check_eq(Editor_state.selection1.line, 1, 'selection:line')
  check_eq(Editor_state.selection1.pos, 6, 'selection:pos')
end

function test_select_text_using_mouse_and_shift()
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.startpos for each line
  -- click on first location
  edit.run_after_mouse_press(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  edit.run_after_mouse_release(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- hold down shift and click somewhere else
  App.fake_key_press('lshift')
  edit.run_after_mouse_press(Editor_state, Editor_state.left+20,Editor_state.top+5, 1)
  edit.run_after_mouse_release(Editor_state, Editor_state.left+20,Editor_state.top+Editor_state.line_height+5, 1)
  App.fake_key_release('lshift')
  check_eq(Editor_state.selection1.line, 1, 'selection:line')
  check_eq(Editor_state.selection1.pos, 2, 'selection:pos')
  check_eq(Editor_state.cursor1.line, 2, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 4, 'cursor:pos')
end

function test_select_text_repeatedly_using_mouse_and_shift()
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.startpos for each line
  -- click on first location
  edit.run_after_mouse_press(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  edit.run_after_mouse_release(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- hold down shift and click on a second location
  App.fake_key_press('lshift')
  edit.run_after_mouse_press(Editor_state, Editor_state.left+20,Editor_state.top+5, 1)
  edit.run_after_mouse_release(Editor_state, Editor_state.left+20,Editor_state.top+Editor_state.line_height+5, 1)
  -- hold down shift and click at a third location
  App.fake_key_press('lshift')
  edit.run_after_mouse_press(Editor_state, Editor_state.left+20,Editor_state.top+5, 1)
  edit.run_after_mouse_release(Editor_state, Editor_state.left+8,Editor_state.top+Editor_state.line_height+5, 1)
  App.fake_key_release('lshift')
  -- selection is between first and third location. forget the second location, not the first.
  check_eq(Editor_state.selection1.line, 1, 'selection:line')
  check_eq(Editor_state.selection1.pos, 2, 'selection:pos')
  check_eq(Editor_state.cursor1.line, 2, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'cursor:pos')
end

function test_select_all_text()
  -- display a single line of text
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- select all
  App.fake_key_press('lctrl')
  edit.run_after_keychord(Editor_state, 'C-a', 'a')
  App.fake_key_release('lctrl')
  edit.key_release(Editor_state, 'lctrl')
  -- selection
  check_eq(Editor_state.selection1.line, 1, 'selection:line')
  check_eq(Editor_state.selection1.pos, 1, 'selection:pos')
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 8, 'cursor:pos')
end

function test_pagedown()
  App.screen.init{width=120, height=45}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  -- initially the first two lines are displayed
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  -- after pagedown the bottom line becomes the top
  edit.run_after_keychord(Editor_state, 'pagedown', 'pagedown')
  check_eq(Editor_state.screen_top1.line, 2, 'screen_top')
  check_eq(Editor_state.cursor1.line, 2, 'cursor')
  y = Editor_state.top
  App.screen.check(y, 'def', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'screen:2')
end

function test_pagedown_can_start_from_middle_of_long_wrapping_line()
  -- draw a few lines starting from a very long wrapping line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def ghi jkl mno pqr stu vwx yza bcd efg hij', 'XYZ'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=2}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc ', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def ', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'baseline/screen:3')
  -- after pagedown we scroll down the very long wrapping line
  edit.run_after_keychord(Editor_state, 'pagedown', 'pagedown')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 9, 'screen_top:pos')
  y = Editor_state.top
  App.screen.check(y, 'ghi ', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl ', 'screen:2')
  y = y + Editor_state.line_height
  if Version == '12.0' then
    -- HACK: Maybe v12.0 uses a different font? Strange that it only causes
    -- issues in a couple of places.
    -- We'll need to rethink our tests if issues like this start to multiply.
    App.screen.check(y, 'mno ', 'screen:3')
  else
    App.screen.check(y, 'mn', 'screen:3')
  end
end

function test_pagedown_never_moves_up()
  -- draw the final screen line of a wrapping line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=9}
  Editor_state.screen_top1 = {line=1, pos=9}
  edit.draw(Editor_state)
  -- pagedown makes no change
  edit.run_after_keychord(Editor_state, 'pagedown', 'pagedown')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 9, 'screen_top:pos')
end

function test_down_arrow_moves_cursor()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  -- initially the first three lines are displayed
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'baseline/screen:3')
  -- after hitting the down arrow, the cursor moves down by 1 line
  edit.run_after_keychord(Editor_state, 'down', 'down')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top')
  check_eq(Editor_state.cursor1.line, 2, 'cursor')
  -- the screen is unchanged
  y = Editor_state.top
  App.screen.check(y, 'abc', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'screen:3')
end

function test_down_arrow_scrolls_down_by_one_line()
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'baseline/screen:3')
  -- after hitting the down arrow the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'down', 'down')
  check_eq(Editor_state.screen_top1.line, 2, 'screen_top')
  check_eq(Editor_state.cursor1.line, 4, 'cursor')
  y = Editor_state.top
  App.screen.check(y, 'def', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'screen:3')
end

function test_down_arrow_scrolls_down_by_one_screen_line()
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting the down arrow the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'down', 'down')
  check_eq(Editor_state.screen_top1.line, 2, 'screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 5, 'cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'def', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'screen:3')
end

function test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word()
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghijkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghij', 'baseline/screen:3')
  -- after hitting the down arrow the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'down', 'down')
  check_eq(Editor_state.screen_top1.line, 2, 'screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 5, 'cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'def', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghij', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'kl', 'screen:3')
end

function test_pagedown_followed_by_down_arrow_does_not_scroll_screen_up()
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghijkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghij', 'baseline/screen:3')
  -- after hitting pagedown the screen scrolls down to start of a long line
  edit.run_after_keychord(Editor_state, 'pagedown', 'pagedown')
  check_eq(Editor_state.screen_top1.line, 3, 'baseline2/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'baseline2/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'baseline2/cursor:pos')
  -- after hitting down arrow the screen doesn't scroll down further, and certainly doesn't scroll up
  edit.run_after_keychord(Editor_state, 'down', 'down')
  check_eq(Editor_state.screen_top1.line, 3, 'screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 5, 'cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'ghij', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'kl', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'screen:3')
end

function test_up_arrow_moves_cursor()
  -- display the first 3 lines with the cursor on the bottom line
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'baseline/screen:3')
  -- after hitting the up arrow the cursor moves up by 1 line
  edit.run_after_keychord(Editor_state, 'up', 'up')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top')
  check_eq(Editor_state.cursor1.line, 2, 'cursor')
  -- the screen is unchanged
  y = Editor_state.top
  App.screen.check(y, 'abc', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'screen:3')
end

function test_up_arrow_scrolls_up_by_one_line()
  -- display the lines 2/3/4 with the cursor on line 2
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'def', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'baseline/screen:3')
  -- after hitting the up arrow the screen scrolls up by one line
  edit.run_after_keychord(Editor_state, 'up', 'up')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'cursor')
  y = Editor_state.top
  App.screen.check(y, 'abc', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'screen:3')
end

function test_up_arrow_scrolls_up_by_one_screen_line()
  -- display lines starting from second screen line of a line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=6}
  Editor_state.screen_top1 = {line=3, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'jkl', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'baseline/screen:2')
  -- after hitting the up arrow the screen scrolls up to first screen line
  edit.run_after_keychord(Editor_state, 'up', 'up')
  y = Editor_state.top
  App.screen.check(y, 'ghi ', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'screen:3')
  check_eq(Editor_state.screen_top1.line, 3, 'screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 1, 'screen_top:pos')
  check_eq(Editor_state.cursor1.line, 3, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'cursor:pos')
end

function test_up_arrow_scrolls_up_to_final_screen_line()
  -- display lines starting just after a long line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi', 'jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'ghi', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'baseline/screen:3')
  -- after hitting the up arrow the screen scrolls up to final screen line of previous line
  edit.run_after_keychord(Editor_state, 'up', 'up')
  y = Editor_state.top
  App.screen.check(y, 'def', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'screen:3')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 5, 'screen_top:pos')
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 5, 'cursor:pos')
end

function test_up_arrow_scrolls_up_to_empty_line()
  -- display a screenful of text with an empty line just above it outside the screen
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'', 'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'baseline/screen:3')
  -- after hitting the up arrow the screen scrolls up by one line
  edit.run_after_keychord(Editor_state, 'up', 'up')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'cursor')
  y = Editor_state.top
  -- empty first line
  y = y + Editor_state.line_height
  App.screen.check(y, 'abc', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'screen:3')
end

function test_pageup()
  App.screen.init{width=120, height=45}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  -- initially the last two lines are displayed
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'def', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'baseline/screen:2')
  -- after pageup the cursor goes to first line
  edit.run_after_keychord(Editor_state, 'pageup', 'pageup')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'cursor')
  y = Editor_state.top
  App.screen.check(y, 'abc', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'screen:2')
end

function test_pageup_scrolls_up_by_screen_line()
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi', 'jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'ghi', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting the page-up key the screen scrolls up to top
  edit.run_after_keychord(Editor_state, 'pageup', 'pageup')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'abc ', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'screen:3')
end

function test_pageup_scrolls_up_from_middle_screen_line()
  -- display a few lines starting from the middle of a line (Editor_state.cursor1.pos > 1)
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=5}
  Editor_state.screen_top1 = {line=2, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'jkl', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting the page-up key the screen scrolls up to top
  edit.run_after_keychord(Editor_state, 'pageup', 'pageup')
  check_eq(Editor_state.screen_top1.line, 1, 'screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'abc ', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'screen:3')
end

function test_left_arrow_scrolls_up_in_wrapped_line()
  -- display lines starting from second screen line of a line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.screen_top1 = {line=3, pos=5}
  -- cursor is at top of screen
  Editor_state.cursor1 = {line=3, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'jkl', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'baseline/screen:2')
  -- after hitting the left arrow the screen scrolls up to first screen line
  edit.run_after_keychord(Editor_state, 'left', 'left')
  y = Editor_state.top
  App.screen.check(y, 'ghi ', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'screen:3')
  check_eq(Editor_state.screen_top1.line, 3, 'screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 1, 'screen_top:pos')
  check_eq(Editor_state.cursor1.line, 3, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 4, 'cursor:pos')
end

function test_right_arrow_scrolls_down_in_wrapped_line()
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.screen_top1 = {line=1, pos=1}
  -- cursor is at bottom right of screen
  Editor_state.cursor1 = {line=3, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting the right arrow the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'right', 'right')
  check_eq(Editor_state.screen_top1.line, 2, 'screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 6, 'cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'def', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'screen:3')
end

function test_home_scrolls_up_in_wrapped_line()
  -- display lines starting from second screen line of a line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.screen_top1 = {line=3, pos=5}
  -- cursor is at top of screen
  Editor_state.cursor1 = {line=3, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'jkl', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'baseline/screen:2')
  -- after hitting home the screen scrolls up to first screen line
  edit.run_after_keychord(Editor_state, 'home', 'home')
  y = Editor_state.top
  App.screen.check(y, 'ghi ', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'screen:3')
  check_eq(Editor_state.screen_top1.line, 3, 'screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 1, 'screen_top:pos')
  check_eq(Editor_state.cursor1.line, 3, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'cursor:pos')
end

function test_end_scrolls_down_in_wrapped_line()
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.screen_top1 = {line=1, pos=1}
  -- cursor is at bottom right of screen
  Editor_state.cursor1 = {line=3, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting end the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'end', 'end')
  check_eq(Editor_state.screen_top1.line, 2, 'screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'cursor:line')
  check_eq(Editor_state.cursor1.pos, 8, 'cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'def', 'screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'screen:3')
end

function test_search()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', '’deg'}  -- contains unicode quote in final line
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- search for a string
  edit.run_after_keychord(Editor_state, 'C-f', 'f')
  edit.run_after_text_input(Editor_state, 'd')
  edit.run_after_keychord(Editor_state, 'return', 'return')
  check_eq(Editor_state.cursor1.line, 2, '1/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, '1/cursor:pos')
  -- reset cursor
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  -- search for second occurrence
  edit.run_after_keychord(Editor_state, 'C-f', 'f')
  edit.run_after_text_input(Editor_state, 'de')
  edit.run_after_keychord(Editor_state, 'down', 'down')
  edit.run_after_keychord(Editor_state, 'return', 'return')
  check_eq(Editor_state.cursor1.line, 4, '2/cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, '2/cursor:pos')
end

function test_search_upwards()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'’abc', 'abd'}  -- contains unicode quote
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- search for a string
  edit.run_after_keychord(Editor_state, 'C-f', 'f')
  edit.run_after_text_input(Editor_state, 'a')
  -- search for previous occurrence
  edit.run_after_keychord(Editor_state, 'up', 'up')
  check_eq(Editor_state.cursor1.line, 1, '2/cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, '2/cursor:pos')
end

function test_search_wrap()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'’abc', 'def'}  -- contains unicode quote in first line
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- search for a string
  edit.run_after_keychord(Editor_state, 'C-f', 'f')
  edit.run_after_text_input(Editor_state, 'a')
  edit.run_after_keychord(Editor_state, 'return', 'return')
  -- cursor wraps
  check_eq(Editor_state.cursor1.line, 1, '1/cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, '1/cursor:pos')
end

function test_search_wrap_upwards()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc ’abd'}  -- contains unicode quote
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- search upwards for a string
  edit.run_after_keychord(Editor_state, 'C-f', 'f')
  edit.run_after_text_input(Editor_state, 'a')
  edit.run_after_keychord(Editor_state, 'up', 'up')
  -- cursor wraps
  check_eq(Editor_state.cursor1.line, 1, '1/cursor:line')
  check_eq(Editor_state.cursor1.pos, 6, '1/cursor:pos')
end

function test_search_downwards_from_end_of_line()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=4}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- search for empty string
  edit.run_after_keychord(Editor_state, 'C-f', 'f')
  edit.run_after_keychord(Editor_state, 'down', 'down')
  -- no crash
end

function test_search_downwards_from_final_pos_of_line()
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=3}
  Editor_state.screen_top1 = {line=1, pos=1}
  edit.draw(Editor_state)
  -- search for empty string
  edit.run_after_keychord(Editor_state, 'C-f', 'f')
  edit.run_after_keychord(Editor_state, 'down', 'down')
  -- no crash
end
