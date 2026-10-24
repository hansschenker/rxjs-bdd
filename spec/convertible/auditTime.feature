Feature: auditTime

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.exists = false
  And timer.active = false
  And source.completed = false
  And source.subscribe()

Scenario: StartInterval
  Given subscription.active == true
  And timer.active == false
  When source.next(value)
  Then pending.value = value
  And pending.exists = true
  And timer.active = true
  And timer.start(duration)
  And emit nothing

Scenario: ReplacePendingValue
  Given subscription.active == true
  And timer.active == true
  When source.next(value)
  Then pending.value = value
  And emit nothing

Scenario: TimerFiresSourceActive
  Given timer.active == true
  And pending.exists == true
  And source.completed == false
  When timer.fire()
  Then timer.active = false
  And emit pending.value
  And pending.exists = false

Scenario: TimerFiresAfterSourceCompleted
  Given timer.active == true
  And pending.exists == true
  And source.completed == true
  When timer.fire()
  Then timer.active = false
  And emit pending.value
  And pending.exists = false
  And complete

Scenario: CompleteWithoutPendingWork
  Given subscription.active == true
  And (pending.exists == false or timer.active == false)
  When source.complete()
  Then complete

Scenario: CompleteDeferred
  Given subscription.active == true
  And pending.exists == true
  And timer.active == true
  When source.complete()
  Then source.completed = true
  And emit nothing

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then pending.exists = false
  And timer.cancel()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And timer.cancel()
  And pending.exists = false
  And subscription.active = false

