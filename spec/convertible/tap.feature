Feature: tap

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And tapObserver.subscribe()
  And source.subscribe()

Scenario: ForwardValue
  Given subscription.active == true
  When source.next(value)
  Then tapObserver.next(value)
  And emit value

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then tapObserver.complete()
  And complete
  And tapObserver.finalize()

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then tapObserver.error(err)
  And error err
  And tapObserver.finalize()

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then tapObserver.unsubscribe()
  And source.unsubscribe()
  And tapObserver.finalize()
  And subscription.active = false

