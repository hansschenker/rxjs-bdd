Feature: materialize

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And source.subscribe()

Scenario: WrapValue
  Given subscription.active == true
  When source.next(value)
  Then emit Notification.createNext(value)

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then emit Notification.createComplete()
  And complete

Scenario: WrapError
  Given subscription.active == true
  When source.error(err)
  Then emit Notification.createError(err)
  And complete

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And subscription.active = false

