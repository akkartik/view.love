-- major tests for text editing flows

function test_initial_state()
  io.write('\ntest_initial_state')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{}
  Text.redraw_all(Editor_state)
  edit.draw(Editor_state)
  check_eq(#Editor_state.lines, 1, 'F - test_initial_state/#lines')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_initial_state/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_initial_state/cursor:pos')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_initial_state/screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 1, 'F - test_initial_state/screen_top:pos')
end

function test_move_left()
  io.write('\ntest_move_left')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'a'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=2}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'left')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_move_left')
end

function test_move_right()
  io.write('\ntest_move_right')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'a'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'right')
  check_eq(Editor_state.cursor1.pos, 2, 'F - test_move_right')
end

function test_move_left_to_previous_line()
  io.write('\ntest_move_left_to_previous_line')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'left')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_move_left_to_previous_line/line')
  check_eq(Editor_state.cursor1.pos, 4, 'F - test_move_left_to_previous_line/pos')  -- past end of line
end

function test_move_right_to_next_line()
  io.write('\ntest_move_right_to_next_line')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=4}  -- past end of line
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'right')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_move_right_to_next_line/line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_move_right_to_next_line/pos')
end

function test_move_to_start_of_word()
  io.write('\ntest_move_to_start_of_word')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=3}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_move_to_start_of_word')
end

function test_move_to_start_of_previous_word()
  io.write('\ntest_move_to_start_of_previous_word')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=4}  -- at the space between words
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_move_to_start_of_previous_word')
end

function test_skip_to_previous_word()
  io.write('\ntest_skip_to_previous_word')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=5}  -- at the start of second word
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_skip_to_previous_word')
end

function test_skip_past_tab_to_previous_word()
  io.write('\ntest_skip_past_tab_to_previous_word')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def\tghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=10}  -- within third word
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left')
  check_eq(Editor_state.cursor1.pos, 9, 'F - test_skip_past_tab_to_previous_word')
end

function test_skip_multiple_spaces_to_previous_word()
  io.write('\ntest_skip_multiple_spaces_to_previous_word')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc  def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=6}  -- at the start of second word
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_skip_multiple_spaces_to_previous_word')
end

function test_move_to_start_of_word_on_previous_line()
  io.write('\ntest_move_to_start_of_word_on_previous_line')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-left')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_move_to_start_of_word_on_previous_line/line')
  check_eq(Editor_state.cursor1.pos, 5, 'F - test_move_to_start_of_word_on_previous_line/pos')
end

function test_move_past_end_of_word()
  io.write('\ntest_move_past_end_of_word')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right')
  check_eq(Editor_state.cursor1.pos, 4, 'F - test_move_past_end_of_word')
end

function test_skip_to_next_word()
  io.write('\ntest_skip_to_next_word')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=4}  -- at the space between words
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right')
  check_eq(Editor_state.cursor1.pos, 8, 'F - test_skip_to_next_word')
end

function test_skip_past_tab_to_next_word()
  io.write('\ntest_skip_past_tab_to_next_word')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc\tdef'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}  -- at the space between words
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right')
  check_eq(Editor_state.cursor1.pos, 4, 'F - test_skip_past_tab_to_next_word')
end

function test_skip_multiple_spaces_to_next_word()
  io.write('\ntest_skip_multiple_spaces_to_next_word')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc  def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=4}  -- at the start of second word
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right')
  check_eq(Editor_state.cursor1.pos, 9, 'F - test_skip_multiple_spaces_to_next_word')
end

function test_move_past_end_of_word_on_next_line()
  io.write('\ntest_move_past_end_of_word_on_next_line')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=8}
  edit.draw(Editor_state)
  edit.run_after_keychord(Editor_state, 'M-right')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_move_past_end_of_word_on_next_line/line')
  check_eq(Editor_state.cursor1.pos, 4, 'F - test_move_past_end_of_word_on_next_line/pos')
end

function test_click_with_mouse()
  io.write('\ntest_click_with_mouse')
  -- display two lines with cursor on one of them
  App.screen.init{width=50, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- click on the other line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- cursor moves
  check_eq(Editor_state.cursor1.line, 1, 'F - test_click_with_mouse/cursor:line')
  check_nil(Editor_state.selection1.line, 'F - test_click_with_mouse/selection is empty to avoid perturbing future edits')
end

function test_click_with_mouse_to_left_of_line()
  io.write('\ntest_click_with_mouse_to_left_of_line')
  -- display a line with the cursor in the middle
  App.screen.init{width=50, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=3}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- click to the left of the line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left-4,Editor_state.top+5, 1)
  -- cursor moves to start of line
  check_eq(Editor_state.cursor1.line, 1, 'F - test_click_with_mouse_to_left_of_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_click_with_mouse_to_left_of_line/cursor:pos')
  check_nil(Editor_state.selection1.line, 'F - test_click_with_mouse_to_left_of_line/selection is empty to avoid perturbing future edits')
end

function test_click_with_mouse_takes_margins_into_account()
  io.write('\ntest_click_with_mouse_takes_margins_into_account')
  -- display two lines with cursor on one of them
  App.screen.init{width=100, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.left = 50  -- occupy only right side of screen
  Editor_state.lines = load_array{'abc', 'def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- click on the other line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- cursor moves
  check_eq(Editor_state.cursor1.line, 1, 'F - test_click_with_mouse_takes_margins_into_account/cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'F - test_click_with_mouse_takes_margins_into_account/cursor:pos')
  check_nil(Editor_state.selection1.line, 'F - test_click_with_mouse_takes_margins_into_account/selection is empty to avoid perturbing future edits')
end

function test_click_with_mouse_on_empty_line()
  io.write('\ntest_click_with_mouse_on_empty_line')
  -- display two lines with the first one empty
  App.screen.init{width=50, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'', 'def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- click on the empty line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- cursor moves
  check_eq(Editor_state.cursor1.line, 1, 'F - test_click_with_mouse_on_empty_line/cursor')
end

function test_draw_text()
  io.write('\ntest_draw_text')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_draw_text/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_draw_text/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_draw_text/screen:3')
end

function test_draw_wrapping_text()
  io.write('\ntest_draw_wrapping_text')
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'defgh', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_draw_wrapping_text/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'de', 'F - test_draw_wrapping_text/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'fgh', 'F - test_draw_wrapping_text/screen:3')
end

function test_draw_word_wrapping_text()
  io.write('\ntest_draw_word_wrapping_text')
  App.screen.init{width=60, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc ', 'F - test_draw_word_wrapping_text/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def ', 'F - test_draw_word_wrapping_text/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_draw_word_wrapping_text/screen:3')
end

function test_click_with_mouse_on_wrapping_line()
  io.write('\ntest_click_with_mouse_on_wrapping_line')
  -- display two lines with cursor on one of them
  App.screen.init{width=50, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def ghi jkl mno pqr stu'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=20}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- click on the other line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- cursor moves
  check_eq(Editor_state.cursor1.line, 1, 'F - test_click_with_mouse_on_wrapping_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'F - test_click_with_mouse_on_wrapping_line/cursor:pos')
  check_nil(Editor_state.selection1.line, 'F - test_click_with_mouse_on_wrapping_line/selection is empty to avoid perturbing future edits')
end

function test_click_with_mouse_on_wrapping_line_takes_margins_into_account()
  io.write('\ntest_click_with_mouse_on_wrapping_line_takes_margins_into_account')
  -- display two lines with cursor on one of them
  App.screen.init{width=100, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.left = 50  -- occupy only right side of screen
  Editor_state.lines = load_array{'abc def ghi jkl mno pqr stu'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=20}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- click on the other line
  edit.draw(Editor_state)
  edit.run_after_mouse_click(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- cursor moves
  check_eq(Editor_state.cursor1.line, 1, 'F - test_click_with_mouse_on_wrapping_line_takes_margins_into_account/cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'F - test_click_with_mouse_on_wrapping_line_takes_margins_into_account/cursor:pos')
  check_nil(Editor_state.selection1.line, 'F - test_click_with_mouse_on_wrapping_line_takes_margins_into_account/selection is empty to avoid perturbing future edits')
end

function test_draw_text_wrapping_within_word()
  -- arrange a screen line that needs to be split within a word
  io.write('\ntest_draw_text_wrapping_within_word')
  App.screen.init{width=60, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abcd e fghijk', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abcd ', 'F - test_draw_text_wrapping_within_word/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'e fgh', 'F - test_draw_text_wrapping_within_word/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ijk', 'F - test_draw_text_wrapping_within_word/screen:3')
end

function test_draw_wrapping_text_containing_non_ascii()
  -- draw a long line containing non-ASCII
  io.write('\ntest_draw_wrapping_text_containing_non_ascii')
  App.screen.init{width=60, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'madam I’m adam', 'xyz'}  -- notice the non-ASCII apostrophe
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'mad', 'F - test_draw_wrapping_text_containing_non_ascii/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'am I', 'F - test_draw_wrapping_text_containing_non_ascii/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, '’m a', 'F - test_draw_wrapping_text_containing_non_ascii/screen:3')
end

function test_click_on_wrapping_line()
  io.write('\ntest_click_on_wrapping_line')
  -- display a wrapping line
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
                               --  12345678901234
  Editor_state.lines = load_array{"madam I'm adam"}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'madam ', 'F - test_click_on_wrapping_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, "I'm ad", 'F - test_click_on_wrapping_line/baseline/screen:2')
  y = y + Editor_state.line_height
  -- click past end of second screen line
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of screen line
  check_eq(Editor_state.cursor1.line, 1, 'F - test_click_on_wrapping_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 12, 'F - test_click_on_wrapping_line/cursor:pos')
end

function test_click_on_wrapping_line_rendered_from_partway_at_top_of_screen()
  io.write('\ntest_click_on_wrapping_line_rendered_from_partway_at_top_of_screen')
  -- display a wrapping line from its second screen line
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
                               --  12345678901234
  Editor_state.lines = load_array{"madam I'm adam"}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=8}
  Editor_state.screen_top1 = {line=1, pos=7}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, "I'm ad", 'F - test_click_on_wrapping_line_rendered_from_partway_at_top_of_screen/baseline/screen:2')
  y = y + Editor_state.line_height
  -- click past end of second screen line
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of screen line
  check_eq(Editor_state.cursor1.line, 1, 'F - test_click_on_wrapping_line_rendered_from_partway_at_top_of_screen/cursor:line')
  check_eq(Editor_state.cursor1.pos, 12, 'F - test_click_on_wrapping_line_rendered_from_partway_at_top_of_screen/cursor:pos')
end

function test_click_past_end_of_wrapping_line()
  io.write('\ntest_click_past_end_of_wrapping_line')
  -- display a wrapping line
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
                               --  12345678901234
  Editor_state.lines = load_array{"madam I'm adam"}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'madam ', 'F - test_click_past_end_of_wrapping_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, "I'm ad", 'F - test_click_past_end_of_wrapping_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'am', 'F - test_click_past_end_of_wrapping_line/baseline/screen:3')
  y = y + Editor_state.line_height
  -- click past the end of it
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of line
  check_eq(Editor_state.cursor1.pos, 15, 'F - test_click_past_end_of_wrapping_line/cursor')  -- one more than the number of UTF-8 code-points
end

function test_click_past_end_of_wrapping_line_containing_non_ascii()
  io.write('\ntest_click_past_end_of_wrapping_line_containing_non_ascii')
  -- display a wrapping line containing non-ASCII
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
                               --  12345678901234
  Editor_state.lines = load_array{'madam I’m adam'}  -- notice the non-ASCII apostrophe
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'madam ', 'F - test_click_past_end_of_wrapping_line_containing_non_ascii/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'I’m ad', 'F - test_click_past_end_of_wrapping_line_containing_non_ascii/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'am', 'F - test_click_past_end_of_wrapping_line_containing_non_ascii/baseline/screen:3')
  y = y + Editor_state.line_height
  -- click past the end of it
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of line
  check_eq(Editor_state.cursor1.pos, 15, 'F - test_click_past_end_of_wrapping_line_containing_non_ascii/cursor')  -- one more than the number of UTF-8 code-points
end

function test_click_past_end_of_word_wrapping_line()
  io.write('\ntest_click_past_end_of_word_wrapping_line')
  -- display a long line wrapping at a word boundary on a screen of more realistic length
  App.screen.init{width=160, height=80}
  Editor_state = edit.initialize_test_state()
                                -- 0        1         2
                                -- 123456789012345678901
  Editor_state.lines = load_array{'the quick brown fox jumped over the lazy dog'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'the quick brown fox ', 'F - test_click_past_end_of_word_wrapping_line/baseline/screen:1')
  y = y + Editor_state.line_height
  -- click past the end of the screen line
  edit.run_after_mouse_click(Editor_state, App.screen.width-2,y-2, 1)
  -- cursor moves to end of screen line
  check_eq(Editor_state.cursor1.pos, 20, 'F - test_click_past_end_of_word_wrapping_line/cursor')
end

function test_select_text()
  io.write('\ntest_select_text')
  -- display a line of text
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  -- select a letter
  App.fake_key_press('lshift')
  edit.run_after_keychord(Editor_state, 'S-right')
  App.fake_key_release('lshift')
  edit.key_released(Editor_state, 'lshift')
  -- selection persists even after shift is released
  check_eq(Editor_state.selection1.line, 1, 'F - test_select_text/selection:line')
  check_eq(Editor_state.selection1.pos, 1, 'F - test_select_text/selection:pos')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_select_text/cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'F - test_select_text/cursor:pos')
end

function test_cursor_movement_without_shift_resets_selection()
  io.write('\ntest_cursor_movement_without_shift_resets_selection')
  -- display a line of text with some part selected
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.selection1 = {line=1, pos=2}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  -- press an arrow key without shift
  edit.run_after_keychord(Editor_state, 'right')
  -- no change to data, selection is reset
  check_nil(Editor_state.selection1.line, 'F - test_cursor_movement_without_shift_resets_selection')
  check_eq(Editor_state.lines[1].data, 'abc', 'F - test_cursor_movement_without_shift_resets_selection/data')
end

function test_copy_does_not_reset_selection()
  io.write('\ntest_copy_does_not_reset_selection')
  -- display a line of text with a selection
  App.screen.init{width=75, height=80}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.selection1 = {line=1, pos=2}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  -- copy selection
  edit.run_after_keychord(Editor_state, 'C-c')
  check_eq(App.clipboard, 'a', 'F - test_copy_does_not_reset_selection/clipboard')
  -- selection is reset since shift key is not pressed
  check(Editor_state.selection1.line, 'F - test_copy_does_not_reset_selection')
end

function test_move_cursor_using_mouse()
  io.write('\ntest_move_cursor_using_mouse')
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.starty for each line Editor_state.line_cache
  edit.run_after_mouse_release(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  check_eq(Editor_state.cursor1.line, 1, 'F - test_move_cursor_using_mouse/cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'F - test_move_cursor_using_mouse/cursor:pos')
  check_nil(Editor_state.selection1.line, 'F - test_move_cursor_using_mouse/selection:line')
  check_nil(Editor_state.selection1.pos, 'F - test_move_cursor_using_mouse/selection:pos')
end

function test_select_text_using_mouse()
  io.write('\ntest_select_text_using_mouse')
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.starty for each line Editor_state.line_cache
  -- press and hold on first location
  edit.run_after_mouse_press(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- drag and release somewhere else
  edit.run_after_mouse_release(Editor_state, Editor_state.left+20,Editor_state.top+Editor_state.line_height+5, 1)
  check_eq(Editor_state.selection1.line, 1, 'F - test_select_text_using_mouse/selection:line')
  check_eq(Editor_state.selection1.pos, 2, 'F - test_select_text_using_mouse/selection:pos')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_select_text_using_mouse/cursor:line')
  check_eq(Editor_state.cursor1.pos, 4, 'F - test_select_text_using_mouse/cursor:pos')
end

function test_select_text_using_mouse_and_shift()
  io.write('\ntest_select_text_using_mouse_and_shift')
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.starty for each line Editor_state.line_cache
  -- click on first location
  edit.run_after_mouse_press(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  edit.run_after_mouse_release(Editor_state, Editor_state.left+8,Editor_state.top+5, 1)
  -- hold down shift and click somewhere else
  App.fake_key_press('lshift')
  edit.run_after_mouse_press(Editor_state, Editor_state.left+20,Editor_state.top+5, 1)
  edit.run_after_mouse_release(Editor_state, Editor_state.left+20,Editor_state.top+Editor_state.line_height+5, 1)
  App.fake_key_release('lshift')
  check_eq(Editor_state.selection1.line, 1, 'F - test_select_text_using_mouse_and_shift/selection:line')
  check_eq(Editor_state.selection1.pos, 2, 'F - test_select_text_using_mouse_and_shift/selection:pos')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_select_text_using_mouse_and_shift/cursor:line')
  check_eq(Editor_state.cursor1.pos, 4, 'F - test_select_text_using_mouse_and_shift/cursor:pos')
end

function test_select_text_repeatedly_using_mouse_and_shift()
  io.write('\ntest_select_text_repeatedly_using_mouse_and_shift')
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'xyz'}
  Text.redraw_all(Editor_state)
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  Editor_state.selection1 = {}
  edit.draw(Editor_state)  -- populate line_cache.starty for each line Editor_state.line_cache
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
  check_eq(Editor_state.selection1.line, 1, 'F - test_select_text_repeatedly_using_mouse_and_shift/selection:line')
  check_eq(Editor_state.selection1.pos, 2, 'F - test_select_text_repeatedly_using_mouse_and_shift/selection:pos')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_select_text_repeatedly_using_mouse_and_shift/cursor:line')
  check_eq(Editor_state.cursor1.pos, 2, 'F - test_select_text_repeatedly_using_mouse_and_shift/cursor:pos')
end

function test_pagedown()
  io.write('\ntest_pagedown')
  App.screen.init{width=120, height=45}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- initially the first two lines are displayed
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_pagedown/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_pagedown/baseline/screen:2')
  -- after pagedown the bottom line becomes the top
  edit.run_after_keychord(Editor_state, 'pagedown')
  check_eq(Editor_state.screen_top1.line, 2, 'F - test_pagedown/screen_top')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_pagedown/cursor')
  y = Editor_state.top
  App.screen.check(y, 'def', 'F - test_pagedown/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_pagedown/screen:2')
end

function test_pagedown_often_shows_start_of_wrapping_line()
  io.write('\ntest_pagedown_often_shows_start_of_wrapping_line')
  -- draw a few lines ending in part of a wrapping line
  App.screen.init{width=50, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_pagedown_often_shows_start_of_wrapping_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def ', 'F - test_pagedown_often_shows_start_of_wrapping_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_pagedown_often_shows_start_of_wrapping_line/baseline/screen:3')
  -- after pagedown we start drawing from the bottom _line_ (multiple screen lines)
  edit.run_after_keychord(Editor_state, 'pagedown')
  check_eq(Editor_state.screen_top1.line, 2, 'F - test_pagedown_often_shows_start_of_wrapping_line/screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 1, 'F - test_pagedown_often_shows_start_of_wrapping_line/screen_top:pos')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_pagedown_often_shows_start_of_wrapping_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_pagedown_often_shows_start_of_wrapping_line/cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'def ', 'F - test_pagedown_often_shows_start_of_wrapping_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_pagedown_often_shows_start_of_wrapping_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_pagedown_often_shows_start_of_wrapping_line/screen:3')
end

function test_pagedown_can_start_from_middle_of_long_wrapping_line()
  io.write('\ntest_pagedown_can_start_from_middle_of_long_wrapping_line')
  -- draw a few lines starting from a very long wrapping line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def ghi jkl mno pqr stu vwx yza bcd efg hij', 'XYZ'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=2}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc ', 'F - test_pagedown_can_start_from_middle_of_long_wrapping_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def ', 'F - test_pagedown_can_start_from_middle_of_long_wrapping_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_pagedown_can_start_from_middle_of_long_wrapping_line/baseline/screen:3')
  -- after pagedown we scroll down the very long wrapping line
  edit.run_after_keychord(Editor_state, 'pagedown')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_pagedown_can_start_from_middle_of_long_wrapping_line/screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 9, 'F - test_pagedown_can_start_from_middle_of_long_wrapping_line/screen_top:pos')
  y = Editor_state.top
  App.screen.check(y, 'ghi ', 'F - test_pagedown_can_start_from_middle_of_long_wrapping_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl ', 'F - test_pagedown_can_start_from_middle_of_long_wrapping_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno ', 'F - test_pagedown_can_start_from_middle_of_long_wrapping_line/screen:3')
end

function test_pagedown_never_moves_up()
  io.write('\ntest_pagedown_never_moves_up')
  -- draw the final screen line of a wrapping line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=9}
  Editor_state.screen_top1 = {line=1, pos=9}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  -- pagedown makes no change
  edit.run_after_keychord(Editor_state, 'pagedown')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_pagedown_never_moves_up/screen_top:line')
  check_eq(Editor_state.screen_top1.pos, 9, 'F - test_pagedown_never_moves_up/screen_top:pos')
end

function test_down_arrow_moves_cursor()
  io.write('\ntest_down_arrow_moves_cursor')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- initially the first three lines are displayed
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_down_arrow_moves_cursor/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_down_arrow_moves_cursor/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_down_arrow_moves_cursor/baseline/screen:3')
  -- after hitting the down arrow, the cursor moves down by 1 line
  edit.run_after_keychord(Editor_state, 'down')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_down_arrow_moves_cursor/screen_top')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_down_arrow_moves_cursor/cursor')
  -- the screen is unchanged
  y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_down_arrow_moves_cursor/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_down_arrow_moves_cursor/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_down_arrow_moves_cursor/screen:3')
end

function test_down_arrow_scrolls_down_by_one_line()
  io.write('\ntest_down_arrow_scrolls_down_by_one_line')
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_down_arrow_scrolls_down_by_one_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_down_arrow_scrolls_down_by_one_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_down_arrow_scrolls_down_by_one_line/baseline/screen:3')
  -- after hitting the down arrow the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'down')
  check_eq(Editor_state.screen_top1.line, 2, 'F - test_down_arrow_scrolls_down_by_one_line/screen_top')
  check_eq(Editor_state.cursor1.line, 4, 'F - test_down_arrow_scrolls_down_by_one_line/cursor')
  y = Editor_state.top
  App.screen.check(y, 'def', 'F - test_down_arrow_scrolls_down_by_one_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_down_arrow_scrolls_down_by_one_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_down_arrow_scrolls_down_by_one_line/screen:3')
end

function test_down_arrow_scrolls_down_by_one_screen_line()
  io.write('\ntest_down_arrow_scrolls_down_by_one_screen_line')
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_down_arrow_scrolls_down_by_one_screen_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_down_arrow_scrolls_down_by_one_screen_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_down_arrow_scrolls_down_by_one_screen_line/baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting the down arrow the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'down')
  check_eq(Editor_state.screen_top1.line, 2, 'F - test_down_arrow_scrolls_down_by_one_screen_line/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'F - test_down_arrow_scrolls_down_by_one_screen_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 5, 'F - test_down_arrow_scrolls_down_by_one_screen_line/cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'def', 'F - test_down_arrow_scrolls_down_by_one_screen_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_down_arrow_scrolls_down_by_one_screen_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_down_arrow_scrolls_down_by_one_screen_line/screen:3')
end

function test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word()
  io.write('\ntest_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word')
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghijkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghij', 'F - test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word/baseline/screen:3')
  -- after hitting the down arrow the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'down')
  check_eq(Editor_state.screen_top1.line, 2, 'F - test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'F - test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word/cursor:line')
  check_eq(Editor_state.cursor1.pos, 5, 'F - test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word/cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'def', 'F - test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghij', 'F - test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'kl', 'F - test_down_arrow_scrolls_down_by_one_screen_line_after_splitting_within_word/screen:3')
end

function test_page_down_followed_by_down_arrow_does_not_scroll_screen_up()
  io.write('\ntest_page_down_followed_by_down_arrow_does_not_scroll_screen_up')
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghijkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghij', 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/baseline/screen:3')
  -- after hitting pagedown the screen scrolls down to start of a long line
  edit.run_after_keychord(Editor_state, 'pagedown')
  check_eq(Editor_state.screen_top1.line, 3, 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/baseline2/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/baseline2/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/baseline2/cursor:pos')
  -- after hitting down arrow the screen doesn't scroll down further, and certainly doesn't scroll up
  edit.run_after_keychord(Editor_state, 'down')
  check_eq(Editor_state.screen_top1.line, 3, 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/cursor:line')
  check_eq(Editor_state.cursor1.pos, 5, 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'ghij', 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'kl', 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_page_down_followed_by_down_arrow_does_not_scroll_screen_up/screen:3')
end

function test_up_arrow_moves_cursor()
  io.write('\ntest_up_arrow_moves_cursor')
  -- display the first 3 lines with the cursor on the bottom line
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_up_arrow_moves_cursor/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_up_arrow_moves_cursor/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_up_arrow_moves_cursor/baseline/screen:3')
  -- after hitting the up arrow the cursor moves up by 1 line
  edit.run_after_keychord(Editor_state, 'up')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_up_arrow_moves_cursor/screen_top')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_up_arrow_moves_cursor/cursor')
  -- the screen is unchanged
  y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_up_arrow_moves_cursor/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_up_arrow_moves_cursor/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_up_arrow_moves_cursor/screen:3')
end

function test_up_arrow_scrolls_up_by_one_line()
  io.write('\ntest_up_arrow_scrolls_up_by_one_line')
  -- display the lines 2/3/4 with the cursor on line 2
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'def', 'F - test_up_arrow_scrolls_up_by_one_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_up_arrow_scrolls_up_by_one_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_up_arrow_scrolls_up_by_one_line/baseline/screen:3')
  -- after hitting the up arrow the screen scrolls up by one line
  edit.run_after_keychord(Editor_state, 'up')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_up_arrow_scrolls_up_by_one_line/screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_up_arrow_scrolls_up_by_one_line/cursor')
  y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_up_arrow_scrolls_up_by_one_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_up_arrow_scrolls_up_by_one_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_up_arrow_scrolls_up_by_one_line/screen:3')
end

function test_up_arrow_scrolls_up_by_one_screen_line()
  io.write('\ntest_up_arrow_scrolls_up_by_one_screen_line')
  -- display lines starting from second screen line of a line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=3, pos=6}
  Editor_state.screen_top1 = {line=3, pos=5}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'jkl', 'F - test_up_arrow_scrolls_up_by_one_screen_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_up_arrow_scrolls_up_by_one_screen_line/baseline/screen:2')
  -- after hitting the up arrow the screen scrolls up to first screen line
  edit.run_after_keychord(Editor_state, 'up')
  y = Editor_state.top
  App.screen.check(y, 'ghi ', 'F - test_up_arrow_scrolls_up_by_one_screen_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_up_arrow_scrolls_up_by_one_screen_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_up_arrow_scrolls_up_by_one_screen_line/screen:3')
  check_eq(Editor_state.screen_top1.line, 3, 'F - test_up_arrow_scrolls_up_by_one_screen_line/screen_top')
  check_eq(Editor_state.screen_top1.pos, 1, 'F - test_up_arrow_scrolls_up_by_one_screen_line/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'F - test_up_arrow_scrolls_up_by_one_screen_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_up_arrow_scrolls_up_by_one_screen_line/cursor:pos')
end

function test_up_arrow_scrolls_up_to_final_screen_line()
  io.write('\ntest_up_arrow_scrolls_up_to_final_screen_line')
  -- display lines starting just after a long line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi', 'jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'ghi', 'F - test_up_arrow_scrolls_up_to_final_screen_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_up_arrow_scrolls_up_to_final_screen_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_up_arrow_scrolls_up_to_final_screen_line/baseline/screen:3')
  -- after hitting the up arrow the screen scrolls up to final screen line of previous line
  edit.run_after_keychord(Editor_state, 'up')
  y = Editor_state.top
  App.screen.check(y, 'def', 'F - test_up_arrow_scrolls_up_to_final_screen_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_up_arrow_scrolls_up_to_final_screen_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_up_arrow_scrolls_up_to_final_screen_line/screen:3')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_up_arrow_scrolls_up_to_final_screen_line/screen_top')
  check_eq(Editor_state.screen_top1.pos, 5, 'F - test_up_arrow_scrolls_up_to_final_screen_line/screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_up_arrow_scrolls_up_to_final_screen_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 5, 'F - test_up_arrow_scrolls_up_to_final_screen_line/cursor:pos')
end

function test_up_arrow_scrolls_up_to_empty_line()
  io.write('\ntest_up_arrow_scrolls_up_to_empty_line')
  -- display a screenful of text with an empty line just above it outside the screen
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'', 'abc', 'def', 'ghi', 'jkl'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_up_arrow_scrolls_up_to_empty_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_up_arrow_scrolls_up_to_empty_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_up_arrow_scrolls_up_to_empty_line/baseline/screen:3')
  -- after hitting the up arrow the screen scrolls up by one line
  edit.run_after_keychord(Editor_state, 'up')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_up_arrow_scrolls_up_to_empty_line/screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_up_arrow_scrolls_up_to_empty_line/cursor')
  y = Editor_state.top
  -- empty first line
  y = y + Editor_state.line_height
  App.screen.check(y, 'abc', 'F - test_up_arrow_scrolls_up_to_empty_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_up_arrow_scrolls_up_to_empty_line/screen:3')
end

function test_pageup()
  io.write('\ntest_pageup')
  App.screen.init{width=120, height=45}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  Editor_state.screen_bottom1 = {}
  -- initially the last two lines are displayed
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'def', 'F - test_pageup/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_pageup/baseline/screen:2')
  -- after pageup the cursor goes to first line
  edit.run_after_keychord(Editor_state, 'pageup')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_pageup/screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_pageup/cursor')
  y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_pageup/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_pageup/screen:2')
end

function test_pageup_scrolls_up_by_screen_line()
  io.write('\ntest_pageup_scrolls_up_by_screen_line')
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi', 'jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=1}
  Editor_state.screen_top1 = {line=2, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'ghi', 'F - test_pageup_scrolls_up_by_screen_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_pageup_scrolls_up_by_screen_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_pageup_scrolls_up_by_screen_line/baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting the page-up key the screen scrolls up to top
  edit.run_after_keychord(Editor_state, 'pageup')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_pageup_scrolls_up_by_screen_line/screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_pageup_scrolls_up_by_screen_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_pageup_scrolls_up_by_screen_line/cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'abc ', 'F - test_pageup_scrolls_up_by_screen_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_pageup_scrolls_up_by_screen_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi', 'F - test_pageup_scrolls_up_by_screen_line/screen:3')
end

function test_pageup_scrolls_up_from_middle_screen_line()
  io.write('\ntest_pageup_scrolls_up_from_middle_screen_line')
  -- display a few lines starting from the middle of a line (Editor_state.cursor1.pos > 1)
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=2, pos=5}
  Editor_state.screen_top1 = {line=2, pos=5}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'jkl', 'F - test_pageup_scrolls_up_from_middle_screen_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_pageup_scrolls_up_from_middle_screen_line/baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting the page-up key the screen scrolls up to top
  edit.run_after_keychord(Editor_state, 'pageup')
  check_eq(Editor_state.screen_top1.line, 1, 'F - test_pageup_scrolls_up_from_middle_screen_line/screen_top')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_pageup_scrolls_up_from_middle_screen_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_pageup_scrolls_up_from_middle_screen_line/cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'abc ', 'F - test_pageup_scrolls_up_from_middle_screen_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_pageup_scrolls_up_from_middle_screen_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_pageup_scrolls_up_from_middle_screen_line/screen:3')
end

function test_left_arrow_scrolls_up_in_wrapped_line()
  io.write('\ntest_left_arrow_scrolls_up_in_wrapped_line')
  -- display lines starting from second screen line of a line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.screen_top1 = {line=3, pos=5}
  Editor_state.screen_bottom1 = {}
  -- cursor is at top of screen
  Editor_state.cursor1 = {line=3, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'jkl', 'F - test_left_arrow_scrolls_up_in_wrapped_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_left_arrow_scrolls_up_in_wrapped_line/baseline/screen:2')
  -- after hitting the left arrow the screen scrolls up to first screen line
  edit.run_after_keychord(Editor_state, 'left')
  y = Editor_state.top
  App.screen.check(y, 'ghi ', 'F - test_left_arrow_scrolls_up_in_wrapped_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_left_arrow_scrolls_up_in_wrapped_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_left_arrow_scrolls_up_in_wrapped_line/screen:3')
  check_eq(Editor_state.screen_top1.line, 3, 'F - test_left_arrow_scrolls_up_in_wrapped_line/screen_top')
  check_eq(Editor_state.screen_top1.pos, 1, 'F - test_left_arrow_scrolls_up_in_wrapped_line/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'F - test_left_arrow_scrolls_up_in_wrapped_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 4, 'F - test_left_arrow_scrolls_up_in_wrapped_line/cursor:pos')
end

function test_right_arrow_scrolls_down_in_wrapped_line()
  io.write('\ntest_right_arrow_scrolls_down_in_wrapped_line')
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- cursor is at bottom right of screen
  Editor_state.cursor1 = {line=3, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_right_arrow_scrolls_down_in_wrapped_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_right_arrow_scrolls_down_in_wrapped_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_right_arrow_scrolls_down_in_wrapped_line/baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting the right arrow the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'right')
  check_eq(Editor_state.screen_top1.line, 2, 'F - test_right_arrow_scrolls_down_in_wrapped_line/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'F - test_right_arrow_scrolls_down_in_wrapped_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 6, 'F - test_right_arrow_scrolls_down_in_wrapped_line/cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'def', 'F - test_right_arrow_scrolls_down_in_wrapped_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_right_arrow_scrolls_down_in_wrapped_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_right_arrow_scrolls_down_in_wrapped_line/screen:3')
end

function test_home_scrolls_up_in_wrapped_line()
  io.write('\ntest_home_scrolls_up_in_wrapped_line')
  -- display lines starting from second screen line of a line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.screen_top1 = {line=3, pos=5}
  Editor_state.screen_bottom1 = {}
  -- cursor is at top of screen
  Editor_state.cursor1 = {line=3, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'jkl', 'F - test_home_scrolls_up_in_wrapped_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_home_scrolls_up_in_wrapped_line/baseline/screen:2')
  -- after hitting home the screen scrolls up to first screen line
  edit.run_after_keychord(Editor_state, 'home')
  y = Editor_state.top
  App.screen.check(y, 'ghi ', 'F - test_home_scrolls_up_in_wrapped_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_home_scrolls_up_in_wrapped_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'mno', 'F - test_home_scrolls_up_in_wrapped_line/screen:3')
  check_eq(Editor_state.screen_top1.line, 3, 'F - test_home_scrolls_up_in_wrapped_line/screen_top')
  check_eq(Editor_state.screen_top1.pos, 1, 'F - test_home_scrolls_up_in_wrapped_line/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'F - test_home_scrolls_up_in_wrapped_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_home_scrolls_up_in_wrapped_line/cursor:pos')
end

function test_end_scrolls_down_in_wrapped_line()
  io.write('\ntest_end_scrolls_down_in_wrapped_line')
  -- display the first three lines with the cursor on the bottom line
  App.screen.init{width=Editor_state.left+30, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi jkl', 'mno'}
  Text.redraw_all(Editor_state)
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  -- cursor is at bottom right of screen
  Editor_state.cursor1 = {line=3, pos=5}
  edit.draw(Editor_state)
  local y = Editor_state.top
  App.screen.check(y, 'abc', 'F - test_end_scrolls_down_in_wrapped_line/baseline/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'def', 'F - test_end_scrolls_down_in_wrapped_line/baseline/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_end_scrolls_down_in_wrapped_line/baseline/screen:3')  -- line wrapping includes trailing whitespace
  -- after hitting end the screen scrolls down by one line
  edit.run_after_keychord(Editor_state, 'end')
  check_eq(Editor_state.screen_top1.line, 2, 'F - test_end_scrolls_down_in_wrapped_line/screen_top')
  check_eq(Editor_state.cursor1.line, 3, 'F - test_end_scrolls_down_in_wrapped_line/cursor:line')
  check_eq(Editor_state.cursor1.pos, 8, 'F - test_end_scrolls_down_in_wrapped_line/cursor:pos')
  y = Editor_state.top
  App.screen.check(y, 'def', 'F - test_end_scrolls_down_in_wrapped_line/screen:1')
  y = y + Editor_state.line_height
  App.screen.check(y, 'ghi ', 'F - test_end_scrolls_down_in_wrapped_line/screen:2')
  y = y + Editor_state.line_height
  App.screen.check(y, 'jkl', 'F - test_end_scrolls_down_in_wrapped_line/screen:3')
end

function test_search()
  io.write('\ntest_search')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc', 'def', 'ghi', 'deg'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  -- search for a string
  edit.run_after_keychord(Editor_state, 'C-f')
  edit.run_after_textinput(Editor_state, 'd')
  edit.run_after_keychord(Editor_state, 'return')
  check_eq(Editor_state.cursor1.line, 2, 'F - test_search/1/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_search/1/cursor:pos')
  -- reset cursor
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  -- search for second occurrence
  edit.run_after_keychord(Editor_state, 'C-f')
  edit.run_after_textinput(Editor_state, 'de')
  edit.run_after_keychord(Editor_state, 'down')
  edit.run_after_keychord(Editor_state, 'return')
  check_eq(Editor_state.cursor1.line, 4, 'F - test_search/2/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_search/2/cursor:pos')
end

function test_search_upwards()
  io.write('\ntest_search_upwards')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc abd'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=2}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  -- search for a string
  edit.run_after_keychord(Editor_state, 'C-f')
  edit.run_after_textinput(Editor_state, 'a')
  -- search for previous occurrence
  edit.run_after_keychord(Editor_state, 'up')
  check_eq(Editor_state.cursor1.line, 1, 'F - test_search_upwards/2/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_search_upwards/2/cursor:pos')
end

function test_search_wrap()
  io.write('\ntest_search_wrap')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=3}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  -- search for a string
  edit.run_after_keychord(Editor_state, 'C-f')
  edit.run_after_textinput(Editor_state, 'a')
  edit.run_after_keychord(Editor_state, 'return')
  -- cursor wraps
  check_eq(Editor_state.cursor1.line, 1, 'F - test_search_wrap/1/cursor:line')
  check_eq(Editor_state.cursor1.pos, 1, 'F - test_search_wrap/1/cursor:pos')
end

function test_search_wrap_upwards()
  io.write('\ntest_search_wrap_upwards')
  App.screen.init{width=120, height=60}
  Editor_state = edit.initialize_test_state()
  Editor_state.lines = load_array{'abc abd'}
  Text.redraw_all(Editor_state)
  Editor_state.cursor1 = {line=1, pos=1}
  Editor_state.screen_top1 = {line=1, pos=1}
  Editor_state.screen_bottom1 = {}
  edit.draw(Editor_state)
  -- search upwards for a string
  edit.run_after_keychord(Editor_state, 'C-f')
  edit.run_after_textinput(Editor_state, 'a')
  edit.run_after_keychord(Editor_state, 'up')
  -- cursor wraps
  check_eq(Editor_state.cursor1.line, 1, 'F - test_search_wrap_upwards/1/cursor:line')
  check_eq(Editor_state.cursor1.pos, 5, 'F - test_search_wrap_upwards/1/cursor:pos')
end
