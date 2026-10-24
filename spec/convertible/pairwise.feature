Feature: pairwise

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And previous.exists = false
  And source.subscribe()

Scenario: FirstValue
  Given subscription.active == true
  And previous.exists == false
  When source.next(value)
  Then previous.value = value
  And previous.exists = true
  And emit nothing

Scenario: LaterValue
  Given subscription.active == true
  And previous.exists == true
  When source.next(value)
  Then emit pair(previous.value, value)
  And previous.value = value

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then previous.exists = false
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And previous.exists = false
  And subscription.active = false

