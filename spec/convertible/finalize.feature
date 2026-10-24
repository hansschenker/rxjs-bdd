Feature: finalize

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And source.subscribe()
  And finalizer.register()

Scenario: ForwardValue
  Given subscription.active == true
  When source.next(value)
  Then emit value

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then complete
  And finalizer.call()

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then error err
  And finalizer.call()

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And finalizer.call()
  And subscription.active = false

