Feature: catchError

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And replacement.active = false
  And source.subscribe()

Scenario: ForwardValue
  Given subscription.active == true
  And replacement.active == false
  When source.next(value)
  Then emit value

Scenario: CompleteSource
  Given subscription.active == true
  And replacement.active == false
  When source.complete()
  Then complete

Scenario: CatchSourceError
  Given subscription.active == true
  And replacement.active == false
  And selector.throws == false
  When source.error(err)
  Then source.unsubscribe()
  And replacement.active = true
  And replacement.subscribe(selector(err, caught))

Scenario: SelectorThrows
  Given subscription.active == true
  And replacement.active == false
  And selector.throws == true
  When source.error(err)
  Then source.unsubscribe()
  And error thrown

Scenario: ForwardReplacementValue
  Given replacement.active == true
  When replacement.next(value)
  Then emit value

Scenario: CompleteReplacement
  Given replacement.active == true
  When replacement.complete()
  Then complete

Scenario: ErrorReplacement
  Given replacement.active == true
  When replacement.error(err)
  Then error err

Scenario: UnsubscribeSource
  Given subscription.active == true
  And replacement.active == false
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And subscription.active = false

Scenario: UnsubscribeReplacement
  Given replacement.active == true
  When subscriber.unsubscribe()
  Then replacement.unsubscribe()
  And subscription.active = false

