Feature: repeat

Scenario: SubscribePositiveCount
  Given subscription.active == false
  And count > 0
  When subscriber.subscribe()
  Then subscription.active = true
  And soFar = 0
  And executing = true
  And source.subscribe()

Scenario: SubscribeNonPositiveCount
  Given subscription.active == false
  And count <= 0
  When subscriber.subscribe()
  Then complete

Scenario: ForwardValue
  Given executing == true
  When source.next(value)
  Then emit value

Scenario: ErrorSource
  Given executing == true
  When source.error(err)
  Then error err

Scenario: CompleteWithRemainingNoDelay
  Given executing == true
  And soFar + 1 < count
  And delay.kind == "none"
  When source.complete()
  Then soFar = soFar + 1
  And source.unsubscribe()
  And source.subscribe()

Scenario: CompleteWithRemainingNumericDelay
  Given executing == true
  And soFar + 1 < count
  And delay.kind == "number"
  When source.complete()
  Then soFar = soFar + 1
  And source.unsubscribe()
  And executing = false
  And delayTimer.start(delay)

Scenario: CompleteWithRemainingNotifierDelay
  Given executing == true
  And soFar + 1 < count
  And delay.kind == "function"
  When source.complete()
  Then soFar = soFar + 1
  And source.unsubscribe()
  And executing = false
  And delayNotifier.subscribe(delay(soFar))

Scenario: CompleteExhausted
  Given executing == true
  And soFar + 1 >= count
  When source.complete()
  Then complete

Scenario: DelayTimerFires
  Given executing == false
  And delay.kind == "number"
  When delayTimer.fire()
  Then executing = true
  And source.subscribe()

Scenario: DelayNotifierEmits
  Given executing == false
  And delay.kind == "function"
  When delayNotifier.next()
  Then delayNotifier.unsubscribe()
  And executing = true
  And source.subscribe()

Scenario: DelayNotifierCompletes
  Given executing == false
  And delay.kind == "function"
  When delayNotifier.complete()
  Then complete

Scenario: UnsubscribeExecution
  Given executing == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And subscription.active = false

Scenario: UnsubscribeWhileDelayPending
  Given executing == false
  When subscriber.unsubscribe()
  Then delayTimer.cancel()
  And delayNotifier.unsubscribe()
  And subscription.active = false

