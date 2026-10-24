Feature: skip

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And skipped = 0
  And source.subscribe()

Scenario: SkipValue
  Given subscription.active == true
  And skipped < count
  When source.next(value)
  Then skipped = skipped + 1
  And emit nothing

Scenario: ForwardValue
  Given subscription.active == true
  And skipped >= count
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

