Feature: merge

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And inputs.subscribeUpTo(concurrent)
  And active.count = inputs.admitted
  And pending.count = inputs.count - inputs.admitted

Scenario: ForwardInputValue
  Given active.count > 0
  When input.next(value, index)
  Then emit value

Scenario: InputCompletesWithPending
  Given active.count > 0
  And pending.count > 0
  When input.complete(index)
  Then inputs.subscribeNext()
  And pending.count = pending.count - 1

Scenario: InputCompletesOthersActive
  Given active.count > 1
  And pending.count == 0
  When input.complete(index)
  Then active.count = active.count - 1

Scenario: LastInputCompletes
  Given active.count == 1
  And pending.count == 0
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
  And pending.count = 0
  And subscription.active = false

