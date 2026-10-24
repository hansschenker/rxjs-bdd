Feature: throwIfEmpty

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And seen = false
  And source.subscribe()

Scenario: ForwardValue
  Given subscription.active == true
  When source.next(value)
  Then seen = true
  And emit value

Scenario: CompleteEmpty
  Given subscription.active == true
  And seen == false
  When source.complete()
  Then error errorFactory()

Scenario: CompleteNonEmpty
  Given subscription.active == true
  And seen == true
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

