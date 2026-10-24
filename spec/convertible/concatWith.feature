Feature: concatWith

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And current = 0
  And input.subscribe(0)

Scenario: ForwardInputValue
  Given subscription.active == true
  When input.next(value, index)
  Then emit value

Scenario: InputCompletesMoreRemain
  Given subscription.active == true
  And current + 1 < inputs.count
  When input.complete(index)
  Then current = current + 1
  And input.subscribe(current)

Scenario: LastInputCompletes
  Given subscription.active == true
  And current + 1 == inputs.count
  When input.complete(index)
  Then complete

Scenario: ErrorInput
  Given subscription.active == true
  When input.error(err, index)
  Then error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then input.unsubscribe(current)
  And subscription.active = false

