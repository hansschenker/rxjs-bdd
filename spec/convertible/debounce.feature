Feature: debounce

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.exists = false
  And duration.active = false
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

Scenario: RestartDuration
  Given subscription.active == true
  And duration.active == true
  When source.next(value)
  Then duration.unsubscribe()
  And pending.value = value
  And pending.exists = true
  And duration.subscribe(value)
  And emit nothing

Scenario: DurationEmits
  Given duration.active == true
  And pending.exists == true
  When duration.next()
  Then duration.unsubscribe()
  And duration.active = false
  And emit pending.value
  And pending.exists = false

Scenario: DurationCompletesSilently
  Given duration.active == true
  When duration.complete()
  Then duration.active = false
  And emit nothing

Scenario: CompleteWithPending
  Given subscription.active == true
  And pending.exists == true
  When source.complete()
  Then duration.unsubscribe()
  And emit pending.value
  And pending.exists = false
  And complete

Scenario: CompleteWithoutPending
  Given subscription.active == true
  And pending.exists == false
  When source.complete()
  Then complete

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
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And duration.unsubscribe()
  And pending.exists = false
  And subscription.active = false

