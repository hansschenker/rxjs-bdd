Feature: max

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And retained.exists = false
  And source.subscribe()

Scenario: FirstValue
  Given subscription.active == true
  And retained.exists == false
  When source.next(value)
  Then retained.value = value
  And retained.exists = true
  And emit nothing

Scenario: GreaterValue
  Given subscription.active == true
  And retained.exists == true
  And comparer(value, retained.value) > 0
  When source.next(value)
  Then retained.value = value
  And emit nothing

Scenario: RetainedValueKept
  Given subscription.active == true
  And retained.exists == true
  And comparer(value, retained.value) <= 0
  When source.next(value)
  Then emit nothing

Scenario: CompleteWithRetained
  Given subscription.active == true
  And retained.exists == true
  When source.complete()
  Then emit retained.value
  And complete

Scenario: CompleteEmpty
  Given subscription.active == true
  And retained.exists == false
  When source.complete()
  Then complete

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

