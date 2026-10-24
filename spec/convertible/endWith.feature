Feature: endWith

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And appending = false
  And source.subscribe()

Scenario: ForwardValue
  Given subscription.active == true
  When source.next(value)
  Then emit value

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then appending = true
  And output.emitEach(appended)
  And appending = false
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And appending = false
  And subscription.active = false

