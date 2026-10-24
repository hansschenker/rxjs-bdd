Feature: combineLatestWith

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And ready.count = 0
  And active.count = inputs.count
  And latest.clear()
  And inputs.subscribeAll()

Scenario: InputFirstValueNotAllReady
  Given subscription.active == true
  And latest.has(index) == false
  And ready.count + 1 < inputs.count
  When input.next(value, index)
  Then latest.set(index, value)
  And ready.count = ready.count + 1
  And emit nothing

Scenario: InputFirstValueAllReady
  Given subscription.active == true
  And latest.has(index) == false
  And ready.count + 1 == inputs.count
  When input.next(value, index)
  Then latest.set(index, value)
  And ready.count = ready.count + 1
  And emit project(latest.values())

Scenario: InputLaterValue
  Given subscription.active == true
  And latest.has(index) == true
  When input.next(value, index)
  Then latest.set(index, value)
  And emit project(latest.values())

Scenario: InputCompletesOthersActive
  Given subscription.active == true
  And active.count > 1
  When input.complete(index)
  Then active.count = active.count - 1

Scenario: LastInputCompletes
  Given subscription.active == true
  And active.count == 1
  When input.complete(index)
  Then active.count = 0
  And complete

Scenario: ErrorInput
  Given subscription.active == true
  When input.error(err, index)
  Then inputs.unsubscribeAll()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then inputs.unsubscribeAll()
  And latest.clear()
  And subscription.active = false

