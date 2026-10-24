Feature: toArray

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And array.clear()
  And source.subscribe()

Scenario: CollectValue
  Given subscription.active == true
  When source.next(value)
  Then array.push(value)
  And emit nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then emit array
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then array.clear()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And array.clear()
  And subscription.active = false

