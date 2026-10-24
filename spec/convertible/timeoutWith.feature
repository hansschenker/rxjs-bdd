Feature: timeoutWith

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And seen = 0
  And fallback.active = false
  And timer.pending = true
  And source.subscribe()
  And timer.start(due)

Scenario: ValueRestartsTimer
  Given subscription.active == true
  And fallback.active == false
  And due.isNumber == true
  When source.next(value)
  Then timer.cancel()
  And seen = seen + 1
  And lastValue = value
  And emit value
  And timer.start(due)
  And timer.pending = true

Scenario: ValueCancelsTimer
  Given subscription.active == true
  And fallback.active == false
  And due.isNumber == false
  When source.next(value)
  Then timer.cancel()
  And timer.pending = false
  And seen = seen + 1
  And lastValue = value
  And emit value

Scenario: TimerFiresSwitchingToFallback
  Given timer.pending == true
  When timer.fire()
  Then timer.pending = false
  And source.unsubscribe()
  And fallback.active = true
  And fallback.subscribe(withObservable)

Scenario: ForwardFallbackValue
  Given fallback.active == true
  When fallback.next(value)
  Then emit value

Scenario: CompleteFallback
  Given fallback.active == true
  When fallback.complete()
  Then complete

Scenario: ErrorFallback
  Given fallback.active == true
  When fallback.error(err)
  Then error err

Scenario: CompleteSource
  Given subscription.active == true
  And fallback.active == false
  When source.complete()
  Then timer.cancel()
  And timer.pending = false
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  And fallback.active == false
  When source.error(err)
  Then timer.cancel()
  And timer.pending = false
  And error err

Scenario: UnsubscribeSource
  Given subscription.active == true
  And fallback.active == false
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And timer.cancel()
  And timer.pending = false
  And subscription.active = false

Scenario: UnsubscribeFallback
  Given fallback.active == true
  When subscriber.unsubscribe()
  Then fallback.unsubscribe()
  And subscription.active = false

