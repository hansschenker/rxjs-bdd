Feature: withLatestFrom

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And ready.count = 0
  And latest.clear()
  And secondaries.subscribeAll()
  And source.subscribe()

Scenario: SecondaryFirstValue
  Given subscription.active == true
  And latest.has(index) == false
  When secondary.next(value, index)
  Then latest.set(index, value)
  And ready.count = ready.count + 1

Scenario: SecondaryLaterValue
  Given subscription.active == true
  And latest.has(index) == true
  When secondary.next(value, index)
  Then latest.set(index, value)

Scenario: SourceValueBeforeAllReady
  Given subscription.active == true
  And ready.count < secondaries.count
  When source.next(value)
  Then emit nothing

Scenario: SourceValueCombined
  Given subscription.active == true
  And ready.count == secondaries.count
  When source.next(value)
  Then emit project(value, latest.values())

Scenario: SecondaryCompletes
  Given subscription.active == true
  When secondary.complete(index)
  Then nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then secondaries.unsubscribeAll()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then secondaries.unsubscribeAll()
  And latest.clear()
  And error err

Scenario: ErrorSecondary
  Given subscription.active == true
  When secondary.error(err, index)
  Then source.unsubscribe()
  And secondaries.unsubscribeAll()
  And latest.clear()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And secondaries.unsubscribeAll()
  And latest.clear()
  And subscription.active = false

