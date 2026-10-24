Feature: sample

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.exists = false
  And source.subscribe()
  And notifier.subscribe()

Scenario: StoreLatestValue
  Given subscription.active == true
  When source.next(value)
  Then pending.value = value
  And pending.exists = true
  And emit nothing

Scenario: NotifierEmitsWithPending
  Given pending.exists == true
  When notifier.next()
  Then emit pending.value
  And pending.exists = false

Scenario: NotifierEmitsWithoutPending
  Given pending.exists == false
  When notifier.next()
  Then emit nothing

Scenario: NotifierCompletes
  Given subscription.active == true
  When notifier.complete()
  Then nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then pending.exists = false
  And notifier.unsubscribe()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then pending.exists = false
  And notifier.unsubscribe()
  And error err

Scenario: ErrorNotifier
  Given subscription.active == true
  When notifier.error(err)
  Then pending.exists = false
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And notifier.unsubscribe()
  And pending.exists = false
  And subscription.active = false

