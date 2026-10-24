Feature: mergeWith

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And active.count = inputs.count
  And inputs.subscribeAll()

Scenario: ForwardInputValue
  Given active.count > 0
  When input.next(value, index)
  Then emit value

Scenario: InputCompletesOthersActive
  Given active.count > 1
  When input.complete(index)
  Then active.count = active.count - 1

Scenario: LastInputCompletes
  Given active.count == 1
  When input.complete(index)
  Then active.count = 0
  And complete

Scenario: ErrorInput
  Given active.count > 0
  When input.error(err, index)
  Then inputs.unsubscribeAll()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then inputs.unsubscribeAll()
  And subscription.active = false

