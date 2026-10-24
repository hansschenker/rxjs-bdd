Feature: isEmpty

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And source.subscribe()

Scenario: FirstValue
  Given subscription.active == true
  When source.next(value)
  Then emit false
  And complete
  And source.unsubscribe()

Scenario: CompleteEmpty
  Given subscription.active == true
  When source.complete()
  Then emit true
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

