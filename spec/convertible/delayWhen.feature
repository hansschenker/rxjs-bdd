Feature: delayWhen

Scenario: SubscribeWithoutSubscriptionDelay
  Given subscription.active == false
  And subscriptionDelay.configured == false
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.count = 0
  And source.completed = false
  And source.subscribe()

Scenario: SubscribeWithSubscriptionDelay
  Given subscription.active == false
  And subscriptionDelay.configured == true
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.count = 0
  And source.completed = false
  And subscriptionDelay.pending = true
  And subscriptionDelay.subscribe()

Scenario: SubscriptionDelayEmits
  Given subscriptionDelay.pending == true
  When subscriptionDelay.next()
  Then subscriptionDelay.unsubscribe()
  And subscriptionDelay.pending = false
  And source.subscribe()

Scenario: SubscriptionDelayCompletes
  Given subscriptionDelay.pending == true
  When subscriptionDelay.complete()
  Then subscriptionDelay.pending = false
  And source.subscribe()

Scenario: StartDuration
  Given subscription.active == true
  When source.next(value)
  Then duration.subscribe(value)
  And pending.count = pending.count + 1
  And emit nothing

Scenario: DurationEmitsMorePending
  Given pending.count > 1
  When duration.next(value)
  Then duration.unsubscribe(value)
  And emit value
  And pending.count = pending.count - 1

Scenario: DurationEmitsLastPendingSourceActive
  Given pending.count == 1
  And source.completed == false
  When duration.next(value)
  Then duration.unsubscribe(value)
  And emit value
  And pending.count = 0

Scenario: DurationEmitsLastPendingAfterSourceCompleted
  Given pending.count == 1
  And source.completed == true
  When duration.next(value)
  Then duration.unsubscribe(value)
  And emit value
  And pending.count = 0
  And complete

Scenario: DurationCompletesSilentlyMorePending
  Given pending.count > 1
  When duration.complete(value)
  Then pending.count = pending.count - 1
  And emit nothing

Scenario: DurationCompletesSilentlyLastPendingSourceActive
  Given pending.count == 1
  And source.completed == false
  When duration.complete(value)
  Then pending.count = 0
  And emit nothing

Scenario: DurationCompletesSilentlyLastPendingAfterSourceCompleted
  Given pending.count == 1
  And source.completed == true
  When duration.complete(value)
  Then pending.count = 0
  And complete

Scenario: CompleteWithPending
  Given subscription.active == true
  And pending.count > 0
  When source.complete()
  Then source.completed = true

Scenario: CompleteWithoutPending
  Given subscription.active == true
  And pending.count == 0
  When source.complete()
  Then complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then duration.unsubscribeAll()
  And pending.count = 0
  And error err

Scenario: ErrorDuration
  Given pending.count > 0
  When duration.error(err, value)
  Then duration.unsubscribeAll()
  And source.unsubscribe()
  And pending.count = 0
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And duration.unsubscribeAll()
  And subscriptionDelay.unsubscribe()
  And pending.count = 0
  And subscription.active = false

