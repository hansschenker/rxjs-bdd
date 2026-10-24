Feature: takeUntil

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And notifier.subscribe()
  And source.subscribe()

Scenario: ForwardValue
  Given subscription.active == true
  When source.next(value)
  Then emit value

Scenario: NotifierEmits
  Given subscription.active == true
  When notifier.next()
  Then complete
  And source.unsubscribe()
  And notifier.unsubscribe()

Scenario: NotifierCompletesSilently
  Given subscription.active == true
  When notifier.complete()
  Then nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then notifier.unsubscribe()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then notifier.unsubscribe()
  And error err

Scenario: ErrorNotifier
  Given subscription.active == true
  When notifier.error(err)
  Then source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And notifier.unsubscribe()
  And subscription.active = false

