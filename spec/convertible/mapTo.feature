Feature: mapTo

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And source.subscribe()

Scenario: EmitConstant
  Given subscription.active == true
  When source.next(value)
  Then emit constant

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

