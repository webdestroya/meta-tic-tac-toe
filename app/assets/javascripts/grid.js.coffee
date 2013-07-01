
WIN_PATTERNS = [
    [(/OOO....../), [0,1,2], 'O'], [(/...OOO.../), [3,4,5], 'O'],
    [(/......OOO/), [6,7,8], 'O'], [(/O..O..O../), [0,3,6], 'O'],
    [(/.O..O..O./), [1,4,7], 'O'], [(/..O..O..O/), [2,5,8], 'O'],
    [(/O...O...O/), [0,4,8], 'O'], [(/..O.O.O../), [2,4,6], 'O'],
    [(/XXX....../), [0,1,2], 'X'], [(/...XXX.../), [3,4,5], 'X'],
    [(/......XXX/), [6,7,8], 'X'], [(/X..X..X../), [0,3,6], 'X'],
    [(/.X..X..X./), [1,4,7], 'X'], [(/..X..X..X/), [2,5,8], 'X'],
    [(/X...X...X/), [0,4,8], 'X'], [(/..X.X.X../), [2,4,6], 'X']
  ]




class Grid

  constructor: (data, elm) ->
    @table = $(elm)
    @squares = [
      [' ', ' ', ' '],
      [' ', ' ', ' '],
      [' ', ' ', ' ']
    ]

    @load(data)

  load: (data) ->
    @squares = data
    for square, pos in _.flatten(@squares)
      if square != ' '
        @table.find("td[data-grid-pos='#{pos}']").text(square)
    return

  move: (row, col, letter = ' ') ->
    @squares[row][col] = letter

    @table.find("td[data-coord='#{row},#{col}']").text(letter)
    return

  winner: ->
    Grid.find_winner _.flatten(@squares)

  isFull: ->
    _.flatten(@squares).indexOf(' ') == -1

  serialize: ->
    return @squares


Grid.find_winner = (str_or_array) ->
  if Object.prototype.toString.call(str_or_array) == '[object Array]'
    str_or_array = str_or_array.join('')
  
  for pattern in WIN_PATTERNS
    return pattern[2] if pattern[0].test(str_or_array)

  return ' '

window.Grid = Grid