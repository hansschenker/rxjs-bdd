Feature: last

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And retained.exists = false
  And index = 0
  And source.subscribe()

Scenario: MatchingValue
  Given subscription.active == true
  And predicate(value, index) == true
  When source.next(value)
  Then retained.value = value
  And retained.exists = true
  And index = index + 1
  And emit nothing

Scenario: NonMatchingValue
  Given subscription.active == true
  And predicate(value, index) == false
  When source.next(value)
  Then index = index + 1
  And emit nothing

Scenario: CompleteWithRetained
  Given subscription.active == true
  And retained.exists == true
  When source.complete()
  Then emit retained.value
  And complete

Scenario: CompleteWithoutMatchNoDefault
  Given subscription.active == true
  And retained.exists == false
  And defaultValue.configured == false
  When source.complete()
  Then error EmptyError

Scenario: CompleteWithoutMatchWithDefault
  Given subscription.active == true
  And retained.exists == false
  And defaultValue.configured == true
  When source.complete()
  Then emit defaultValue
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then retained.exists = false
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And retained.exists = false
  And subscription.active = false

