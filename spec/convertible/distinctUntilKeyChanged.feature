Feature: distinctUntilKeyChanged

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
  Then previous.key = keyOf(value)
  And previous.exists = true
  And emit value

Scenario: ChangedValue
  Given subscription.active == true
  And previous.exists == true
  And comparator(previous.key, keyOf(value)) == false
  When source.next(value)
  Then previous.key = keyOf(value)
  And emit value

Scenario: UnchangedValue
  Given subscription.active == true
  And previous.exists == true
  And comparator(previous.key, keyOf(value)) == true
  When source.next(value)
  Then emit nothing

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
  And previous.exists = false
  And subscription.active = false

