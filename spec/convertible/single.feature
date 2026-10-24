Feature: single

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And seen = false
  And match.exists = false
  And index = 0
  And source.subscribe()

Scenario: NonMatchingValue
  Given subscription.active == true
  And predicate(value, index) == false
  When source.next(value)
  Then seen = true
  And index = index + 1
  And emit nothing

Scenario: FirstMatchingValue
  Given subscription.active == true
  And predicate(value, index) == true
  And match.exists == false
  When source.next(value)
  Then seen = true
  And match.value = value
  And match.exists = true
  And index = index + 1
  And emit nothing

Scenario: SecondMatchingValue
  Given subscription.active == true
  And predicate(value, index) == true
  And match.exists == true
  When source.next(value)
  Then error SequenceError
  And source.unsubscribe()

Scenario: CompleteWithMatch
  Given subscription.active == true
  And match.exists == true
  When source.complete()
  Then emit match.value
  And complete

Scenario: CompleteWithoutMatch
  Given subscription.active == true
  And match.exists == false
  And seen == true
  When source.complete()
  Then error NotFoundError

Scenario: CompleteEmpty
  Given subscription.active == true
  And seen == false
  When source.complete()
  Then error EmptyError

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then match.exists = false
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And match.exists = false
  And subscription.active = false

