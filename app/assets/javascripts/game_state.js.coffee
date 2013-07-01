
MAX_IDLE_TIME = 900 # seconds to idle before we redirect them
IDLE_INTERVAL = 10 # update the idle counter ever X seconds

window.initializeGameState = (game_id, state) ->
  window.CHANNEL = PUSHER.subscribe "private-game-#{game_id}"
  window.PRESENCE = PUSHER.subscribe "presence-game-#{game_id}"

  # We connected to pusher, its all good
  CHANNEL.bind 'pusher:subscription_succeeded', ->
    window.game = new GameState(game_id)
    window.game.load state
    # CHANNEL.trigger 'client-player-join', {}
    return

  # If we are unable to connect to pusher
  CHANNEL.bind 'pusher:subscription_error', (status) ->
    alert "Sorry, but we could not connect to Pusher"
    return

  return


class GameState


  constructor: (@game_id) ->
    # first guy on is X
    @letter = 'X'
    @turn = 'X'

    @grid = [
      [null, null, null],
      [null, null, null],
      [null, null, null]
    ]

    @overall_score = [
      [' ', ' ', ' '],
      [' ', ' ', ' '],
      [' ', ' ', ' ']
    ]

    @last_move = null

    @setupBinds()

    $("a[data-action='switch']").click _.bind(@switchSides, this)
    $("button[data-action='save']").click _.bind(@saveGame, this)
    $("a.place-marker").click _.bind(@placeMarker, this)

    @idleTime = 0
    window.setInterval _.bind(@runIdleTimer, this), IDLE_INTERVAL*1000

  runIdleTimer: ->
    @idleTime = @idleTime + IDLE_INTERVAL

    if @idleTime >= MAX_IDLE_TIME
      PUSHER.disconnect()
      window.location.href = GAME_DETAILS.expire_path

    return


  setupBinds: ->

    PRESENCE.bind 'pusher:subscription_succeeded', _.bind(@presenceSubscriptionSuccess, this)
    PRESENCE.bind 'pusher:subscription_error', _.bind(@presenceSubscriptionError, this)

    PRESENCE.bind 'pusher:member_added', _.bind(@presenceMemberAdded, this)
    PRESENCE.bind 'pusher:member_removed', _.bind(@presenceMemberRemoved, this)

    CHANNEL.bind 'client-player-join', _.bind(@playerJoin, this)
    CHANNEL.bind 'client-switch', _.bind(@playerSwitch, this)
    # CHANNEL.bind 'client-set-letter', _.bind(@setLetter, this)

    CHANNEL.bind 'client-player-move', _.bind(@playerMove, this)
    return

  load: (state) ->
    # set the turn, but we need to reverse it.
    @setTurn state.turn, false
    @finished = state.finished
    @winner = state.winner
    @overall_score = state.overall_score
    
    for row, r in state.board
      for col, c in row
        @grid[r][c] = new Grid(col, $("#gameboard table[data-board-row='#{r}'][data-board-col='#{c}']") )

    @updateOverallScoreboard()
    return

  saveGame: (event) ->
    $("button[data-action='save']").text "Saving..."
    $("button[data-action='save']").attr("disabled", "disabled")
    $.ajax
      type: "PUT",
      url: "/games/#{@game_id}.json",
      data: 
        game:
          winner: @overallWinner()
          finished: @overallWinner() != ' '
          turn: @turn
          overall_score: JSON.stringify(@overall_score)
          game_state: JSON.stringify( @serialize() )
      dataType: 'json',
      success: _.bind(@saveSuccess, this)
    return

  # check the validity of a move
  # returns an array of boolean (is the move valid), and a string
  # (the message)
  isValidMove: (board_row, board_col, row, col) ->
    
    # Is it actually the player's turn?
    return [false, "It's not your turn!"] if @turn != @letter

    # if this is the first move, then anything goes
    if @last_move != null
      # [board row, boardcol, row, col, letter]
      [last_board_row, last_board_col, last_row, last_col, last_letter] = @last_move

      # This is the next cell
      cell = @grid[last_row][last_col]

      # the cell where the next move should be is not full, so it should be there
      if !cell.isFull()
        if last_row != board_row || last_col != board_col
          return [false, "You must play on the highlighted grid."]


    return [true, "Valid"]

  saveSuccess: (msg) ->
    $("button[data-action='save']").text "Saved!"
    if @overallWinner() == ' '
      window.setTimeout _.bind(@resetSaveButton, this), 1000
    return

  resetSaveButton: ->
    $("button[data-action='save']").text "Save"
    $("button[data-action='save']").removeAttr("disabled")
    return

  switchSides: (event) ->
    event.preventDefault()
    cur_letter = @letter
    @setLetter(if @letter == "X" then "O" else "X")
    CHANNEL.trigger 'client-switch', {letter: cur_letter}

    return

  playerSwitch: (data) ->
    @setLetter(data.letter)
    return

  placeMarker: (event) ->
    event.preventDefault()

    elm = $(event.target).parent()

    board_row = elm.data("board-row")
    board_col = elm.data("board-col")
    row = elm.data("row")
    col = elm.data("col")

    # Validate the move
    valid = @isValidMove(board_row, board_col, row, col)
    unless valid[0]
      alert valid[1]
      return

    @grid[board_row][board_col].move(row, col, @letter)

    @last_move = [board_row, board_col, row, col, @letter]

    CHANNEL.trigger 'client-player-move',
      board: [board_row, board_col],
      grid: [row, col],
      letter: @letter

    @setTurn @letter
    @setNextGrid row, col

    @updateOverallScoreboard()

    @saveGame()

    @idleTime = 0

    return

  setNextGrid: (row, col) ->
    $("#gameboard div.span2").removeClass("next-turn")
    next_grid = $("#gameboard div[data-board-pos='#{row},#{col}']")
    next_grid.addClass("next-turn")
    return

  updateOverallScoreboard: ->
    for cell, pos in _.flatten(@grid, true)

      # only recalculate the score if we need to
      if @overall_score[pos] == ' '
        @overall_score[pos] = cell.winner()

      if @overall_score[pos] == ' '
        $(".overall-board td[data-pos='#{pos}']").html '&nbsp;'
      else
        $(".overall-board td[data-pos='#{pos}']").text @overall_score[pos]

    @handleOverallWinner()
    return

  handleOverallWinner: ->
    @winner = @overallWinner()

    return unless @winner == "X" || @winner == "O"
    
    $("button[data-action='save']").hide()
    
    PUSHER.disconnect()
    return

  overallWinner: ->
    return Grid.find_winner(@overall_score)

  # PRESENCE STUFF

  presenceSubscriptionSuccess: (members) ->
    # console.log "PRESENCE SUCCESS: ", members
    if members.count == 2
      @setLetter("O")
      $("#wait_overlay").hide()
    return

  presenceSubscriptionError: ->
    alert "PROBLEM SUBSCRIPING TO PRES"
    return

  presenceMemberAdded: (member) ->
    $("#wait_overlay").hide()

    new_letter = if @letter == "X" then "O" else "X"
    CHANNEL.trigger 'client-switch', {letter: new_letter}
    return

  presenceMemberRemoved: (member) ->
    $("#wait_overlay").show()
    return

  # END PRESENCE STUFF


  ###
  This is called when a player has submitted a move
  data:
    letter: 'X'
    board: [0,0] This is the position on the large grid
    grid: [0,0] This is the row/col of the smaller board
  ###
  playerMove: (data) ->
    board = data.board
    grid = data.grid
    @grid[board[0]][board[1]].move(grid[0], grid[1], data.letter)

    @updateOverallScoreboard()

    @setTurn data.letter
    @setNextGrid grid[0], grid[1]

    @idleTime = 0

    @last_move = [board[0], board[1], grid[0], grid[1], data.letter]
    return


  playerJoin: (data) ->
    if @letter == "X"
      CHANNEL.trigger 'client-set-letter', 
        letter: 'O'

    $("#wait_overlay").hide()
    return

  # Pass in the letter of the player who just took a turn
  # if swap = false, then dont do the swapping calculation
  setTurn: (current_turn_letter, swap=true) ->
    if swap
      @turn = if current_turn_letter == "X" then "O" else "X"
    else 
      @turn = current_turn_letter

    if @turn == @letter
      $("#turn_notice").addClass("alert-success").text("It's your turn! Make your move!")
    else
      $("#turn_notice").removeClass("alert-success").text("It's your opponent's turn!")

    return


  setLetter: (@letter) ->
    $("#gameboard .place-marker").text @letter
    $("span.player-letter").text @letter
    @setTurn @turn, false
    return

  serialize: ->
    state = [ [null, null, null], [null, null, null], [null, null, null] ]
    for row, r in state
      for col, c in row
        state[r][c] = @grid[r][c].serialize()

    return state


window.GameState = GameState