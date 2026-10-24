Feature: take

Scenario: SubscribePositiveCount
  Given subscription.active == false
  And count > 0
  When subscriber.subscribe()
  Then subscription.active = true
  And taken = 0
  And source.subscribe()

Scenario: SubscribeNonPositiveCount
  Given subscription.active == false
  And count <= 0
  When subscriber.subscribe()
  Then complete

Scenario: TakeValue
  Given subscription.active == true
  And taken + 1 < count
  When source.next(value)
  Then taken = taken + 1
  And emit value

Scenario: TakeFinalValue
  Given subscription.active == true
  And taken + 1 == count
  When source.next(value)
  Then taken = taken + 1
  And emit value
  And complete
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

