Feature: retry

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
  Then subscription.active = true
  And soFar = 0
  And executing = true
  And source.subscribe()

Scenario: ForwardValueResettingAttempts
  Given executing == true
  And resetOnSuccess == true
  When source.next(value)
  Then soFar = 0
  And emit value

Scenario: ForwardValue
  Given executing == true
  And resetOnSuccess == false
  When source.next(value)
  Then emit value

Scenario: CompleteSource
  Given executing == true
  When source.complete()
  Then complete

Scenario: ErrorWithRemainingNoDelay
  Given executing == true
  And soFar < count
  And delay.kind == "none"
  When source.error(err)
  Then soFar = soFar + 1
  And source.unsubscribe()
  And source.subscribe()

Scenario: ErrorWithRemainingNumericDelay
  Given executing == true
  And soFar < count
  And delay.kind == "number"
  When source.error(err)
  Then soFar = soFar + 1
  And source.unsubscribe()
  And executing = false
  And delayTimer.start(delay)

Scenario: ErrorWithRemainingNotifierDelay
  Given executing == true
  And soFar < count
  And delay.kind == "function"
  When source.error(err)
  Then soFar = soFar + 1
  And source.unsubscribe()
  And executing = false
  And delayNotifier.subscribe(delay(err, soFar))

Scenario: ErrorExhausted
  Given executing == true
  And soFar >= count
  When source.error(err)
  Then error err

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

Scenario: UnsubscribeAttempt
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

