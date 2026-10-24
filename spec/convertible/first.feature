Feature: first

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And index = 0
  And source.subscribe()

Scenario: NonMatchingValue
  Given subscription.active == true
  And predicate(value, index) == false
  When source.next(value)
  Then index = index + 1
  And emit nothing

Scenario: MatchingValue
  Given subscription.active == true
  And predicate(value, index) == true
  When source.next(value)
  Then emit value
  And complete
  And source.unsubscribe()

Scenario: CompleteWithoutMatchNoDefault
  Given subscription.active == true
  And defaultValue.configured == false
  When source.complete()
  Then error EmptyError

Scenario: CompleteWithoutMatchWithDefault
  Given subscription.active == true
  And defaultValue.configured == true
  When source.complete()
  Then emit defaultValue
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And subscription.active = false

