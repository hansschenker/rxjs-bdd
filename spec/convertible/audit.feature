Feature: audit

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.exists = false
  And duration.active = false
  And source.completed = false
  And source.subscribe()

Scenario: StartDuration
  Given subscription.active == true
  And duration.active == false
  When source.next(value)
  Then pending.value = value
  And pending.exists = true
  And duration.active = true
  And duration.subscribe(value)
  And emit nothing

Scenario: ReplacePendingValue
  Given subscription.active == true
  And duration.active == true
  When source.next(value)
  Then pending.value = value
  And emit nothing

Scenario: DurationFiresSourceActive
  Given duration.active == true
  And pending.exists == true
  And source.completed == false
  When duration.next()
  Then duration.unsubscribe()
  And duration.active = false
  And emit pending.value
  And pending.exists = false

Scenario: DurationFiresAfterSourceCompleted
  Given duration.active == true
  And pending.exists == true
  And source.completed == true
  When duration.next()
  Then duration.unsubscribe()
  And duration.active = false
  And emit pending.value
  And pending.exists = false
  And complete

Scenario: DurationCompletesSilentlySourceActive
  Given duration.active == true
  And source.completed == false
  When duration.complete()
  Then duration.active = false
  And emit nothing

Scenario: DurationCompletesSilentlyAfterSourceCompleted
  Given duration.active == true
  And source.completed == true
  When duration.complete()
  Then duration.active = false
  And pending.exists = false
  And complete

Scenario: CompleteWithoutPendingWork
  Given subscription.active == true
  And (pending.exists == false or duration.active == false)
  When source.complete()
  Then complete

Scenario: CompleteDeferred
  Given subscription.active == true
  And pending.exists == true
  And duration.active == true
  When source.complete()
  Then source.completed = true
  And emit nothing

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then pending.exists = false
  And duration.unsubscribe()
  And error err

Scenario: ErrorDuration
  Given duration.active == true
  When duration.error(err)
  Then pending.exists = false
  And duration.active = false
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And duration.unsubscribe()
  And pending.exists = false
  And subscription.active = false

