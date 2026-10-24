Feature: raceWith

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And winner.selected = false
  And competitors.subscribeAll()

Scenario: FirstEmissionSelectsWinner
  Given winner.selected == false
  When competitor.next(value, index)
  Then winner.selected = true
  And winner.index = index
  And competitors.unsubscribeOthers(index)
  And emit value

Scenario: WinnerEmits
  Given winner.selected == true
  And index == winner.index
  When competitor.next(value, index)
  Then emit value

Scenario: CompetitorCompletesBeforeWinner
  Given winner.selected == false
  When competitor.complete(index)
  Then competitors.unsubscribeOthers(index)
  And complete

Scenario: WinnerCompletes
  Given winner.selected == true
  And index == winner.index
  When competitor.complete(index)
  Then complete

Scenario: CompetitorErrorsBeforeWinner
  Given winner.selected == false
  When competitor.error(err, index)
  Then competitors.unsubscribeOthers(index)
  And error err

Scenario: WinnerErrors
  Given winner.selected == true
  And index == winner.index
  When competitor.error(err, index)
  Then error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then competitors.unsubscribeAll()
  And subscription.active = false

