Feature: throttleTime

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And timer.active = false
  And trailing.exists = false
  And source.completed = false
  And source.subscribe()

Scenario: IdleValueLeading
  Given subscription.active == true
  And timer.active == false
  And leading == true
  When source.next(value)
  Then emit value
  And timer.active = true
  And timer.start(duration)

Scenario: IdleValueTrailingOnly
  Given subscription.active == true
  And timer.active == false
  And leading == false
  When source.next(value)
  Then trailing.value = value
  And trailing.exists = true
  And timer.active = true
  And timer.start(duration)
  And emit nothing

Scenario: BusyValueRetainedAsTrailing
  Given subscription.active == true
  And timer.active == true
  And trailing == true
  When source.next(value)
  Then trailing.value = value
  And trailing.exists = true
  And emit nothing

Scenario: BusyValueIgnored
  Given subscription.active == true
  And timer.active == true
  And trailing == false
  When source.next(value)
  Then emit nothing

Scenario: TimerFiresWithTrailingSourceActive
  Given timer.active == true
  And trailing.exists == true
  And source.completed == false
  When timer.fire()
  Then timer.cancel()
  And emit trailing.value
  And trailing.exists = false
  And timer.start(duration)

Scenario: TimerFiresWithTrailingAfterSourceCompleted
  Given timer.active == true
  And trailing.exists == true
  And source.completed == true
  When timer.fire()
  Then timer.cancel()
  And timer.active = false
  And emit trailing.value
  And trailing.exists = false
  And complete

Scenario: TimerFiresNoTrailingSourceActive
  Given timer.active == true
  And trailing.exists == false
  And source.completed == false
  When timer.fire()
  Then timer.cancel()
  And timer.active = false

Scenario: TimerFiresNoTrailingAfterSourceCompleted
  Given timer.active == true
  And trailing.exists == false
  And source.completed == true
  When timer.fire()
  Then timer.cancel()
  And timer.active = false
  And complete

Scenario: CompleteDeferred
  Given subscription.active == true
  And trailing.exists == true
  And timer.active == true
  When source.complete()
  Then source.completed = true

Scenario: CompleteImmediate
  Given subscription.active == true
  And (trailing.exists == false or timer.active == false)
  When source.complete()
  Then trailing.exists = false
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then trailing.exists = false
  And timer.cancel()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And timer.cancel()
  And trailing.exists = false
  And subscription.active = false

