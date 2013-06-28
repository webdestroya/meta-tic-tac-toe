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

    @setupBinds()

    $("a[data-action='switch']").click _.bind(@switchSides, this)
    $("button[data-action='save']").click _.bind(@saveGame, this)
    $("a.place-marker").click _.bind(@placeMarker, this)


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
    @turn = state.turn
    
    for row, r in state.board
      for col, c in row
        @grid[r][c] = new Grid(col, $("#gameboard table[data-board-row='#{r}'][data-board-col='#{c}']") )

    @updateOverallScoreboard()
    return

  saveGame: (event) ->

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

    if @turn != @letter
      alert "It's not your turn!"
      return

    elm = $(event.target).parent()

    board_row = elm.data("board-row")
    board_col = elm.data("board-col")
    row = elm.data("row")
    col = elm.data("col")

    @grid[board_row][board_col].move(row, col, @letter)

    CHANNEL.trigger 'client-player-move',
      board: [board_row, board_col],
      grid: [row, col],
      letter: @letter

    @turn = if @turn == "X" then "O" else "X"

    @updateOverallScoreboard()

    return

  updateOverallScoreboard: ->
    for cell, pos in _.flatten(@grid, true)
      winner = cell.winner()
      if winner == ' '
        $(".overall-board td[data-pos='#{pos}']").html '&nbsp;'
      else
        $(".overall-board td[data-pos='#{pos}']").text winner
    return

  # PRESENCE STUFF

  presenceSubscriptionSuccess: (members) ->
    console.log "PRESENCE SUCCESS: ", members
    if members.count == 2
      @setLetter("O")
      $("#wait_overlay").hide()
    return

  presenceSubscriptionError: ->
    alert "PROBLEM SUBSCRIPING TO PRES"
    return

  presenceMemberAdded: (member) ->
    console.log "MEMBER ADDED: ", member
    $("#wait_overlay").hide()

    new_letter = if @letter == "X" then "O" else "X"
    CHANNEL.trigger 'client-switch', {letter: new_letter}
    return

  presenceMemberRemoved: (member) ->
    console.log "MEMBER REMOVED: ", member
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

    @turn = if data.letter == "X" then "O" else "X"
    return


  playerJoin: (data) ->
    if @letter == "X"
      CHANNEL.trigger 'client-set-letter', 
        letter: 'O'

    $("#wait_overlay").hide()
    return


  setLetter: (@letter) ->
    $("#gameboard .place-marker").text @letter
    $("span.player-letter").text @letter
    return

  serialize: ->
    return


window.GameState = GameState