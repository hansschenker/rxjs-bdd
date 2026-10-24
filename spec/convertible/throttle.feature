Feature: throttle

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And duration.active = false
  And trailing.exists = false
  And source.completed = false
  And source.subscribe()

Scenario: IdleValueLeading
  Given subscription.active == true
  And duration.active == false
  And leading == true
  When source.next(value)
  Then emit value
  And duration.active = true
  And duration.subscribe(value)

Scenario: IdleValueTrailingOnly
  Given subscription.active == true
  And duration.active == false
  And leading == false
  When source.next(value)
  Then trailing.value = value
  And trailing.exists = true
  And duration.active = true
  And duration.subscribe(value)
  And emit nothing

Scenario: BusyValueRetainedAsTrailing
  Given subscription.active == true
  And duration.active == true
  And trailing == true
  When source.next(value)
  Then trailing.value = value
  And trailing.exists = true
  And emit nothing

Scenario: BusyValueIgnored
  Given subscription.active == true
  And duration.active == true
  And trailing == false
  When source.next(value)
  Then emit nothing

Scenario: DurationFiresWithTrailingSourceActive
  Given duration.active == true
  And trailing.exists == true
  And source.completed == false
  When duration.next()
  Then duration.unsubscribe()
  And emit trailing.value
  And trailing.exists = false
  And duration.subscribe(trailing.value)

Scenario: DurationFiresWithTrailingAfterSourceCompleted
  Given duration.active == true
  And trailing.exists == true
  And source.completed == true
  When duration.next()
  Then duration.unsubscribe()
  And duration.active = false
  And emit trailing.value
  And trailing.exists = false
  And complete

Scenario: DurationFiresNoTrailingSourceActive
  Given duration.active == true
  And trailing.exists == false
  And source.completed == false
  When duration.next()
  Then duration.unsubscribe()
  And duration.active = false

Scenario: DurationFiresNoTrailingAfterSourceCompleted
  Given duration.active == true
  And trailing.exists == false
  And source.completed == true
  When duration.next()
  Then duration.unsubscribe()
  And duration.active = false
  And complete

Scenario: DurationCompletesSilentlySourceActive
  Given duration.active == true
  And source.completed == false
  When duration.complete()
  Then duration.active = false

Scenario: DurationCompletesSilentlyAfterSourceCompleted
  Given duration.active == true
  And source.completed == true
  When duration.complete()
  Then duration.active = false
  And trailing.exists = false
  And complete

Scenario: CompleteDeferred
  Given subscription.active == true
  And trailing.exists == true
  And duration.active == true
  When source.complete()
  Then source.completed = true

Scenario: CompleteImmediate
  Given subscription.active == true
  And (trailing.exists == false or duration.active == false)
  When source.complete()
  Then trailing.exists = false
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then trailing.exists = false
  And duration.unsubscribe()
  And error err

Scenario: ErrorDuration
  Given duration.active == true
  When duration.error(err)
  Then trailing.exists = false
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And duration.unsubscribe()
  And trailing.exists = false
  And subscription.active = false

