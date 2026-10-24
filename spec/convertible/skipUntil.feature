Feature: skipUntil

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And gate.open = false
  And notifier.subscribe()
  And source.subscribe()

Scenario: DropWhileGateClosed
  Given subscription.active == true
  And gate.open == false
  When source.next(value)
  Then emit nothing

Scenario: ForwardWhenGateOpen
  Given subscription.active == true
  And gate.open == true
  When source.next(value)
  Then emit value

Scenario: NotifierOpensGate
  Given gate.open == false
  When notifier.next()
  Then gate.open = true
  And notifier.unsubscribe()

Scenario: NotifierCompletesWhileGateClosed
  Given gate.open == false
  When notifier.complete()
  Then nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then notifier.unsubscribe()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then notifier.unsubscribe()
  And error err

Scenario: ErrorNotifier
  Given gate.open == false
  When notifier.error(err)
  Then source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And notifier.unsubscribe()
  And subscription.active = false

