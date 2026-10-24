Feature: skipWhile

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And skipping = true
  And index = 0
  And source.subscribe()

Scenario: SkipValue
  Given subscription.active == true
  And skipping == true
  And predicate(value, index) == true
  When source.next(value)
  Then index = index + 1
  And emit nothing

Scenario: StopSkipping
  Given subscription.active == true
  And skipping == true
  And predicate(value, index) == false
  When source.next(value)
  Then skipping = false
  And index = index + 1
  And emit value

Scenario: ForwardAfterSkipping
  Given subscription.active == true
  And skipping == false
  When source.next(value)
  Then emit value

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And subscription.active = false

