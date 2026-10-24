Feature: takeWhile

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And index = 0
  And source.subscribe()

Scenario: PassingValue
  Given subscription.active == true
  And predicate(value, index) == true
  When source.next(value)
  Then index = index + 1
  And emit value

Scenario: FailingValueInclusive
  Given subscription.active == true
  And predicate(value, index) == false
  And inclusive == true
  When source.next(value)
  Then emit value
  And complete
  And source.unsubscribe()

Scenario: FailingValueExclusive
  Given subscription.active == true
  And predicate(value, index) == false
  And inclusive == false
  When source.next(value)
  Then complete
  And source.unsubscribe()

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

