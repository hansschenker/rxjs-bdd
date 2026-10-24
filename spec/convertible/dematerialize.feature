Feature: dematerialize

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And source.subscribe()

Scenario: NextNotification
  Given subscription.active == true
  And notification.kind == "N"
  When source.next(notification)
  Then emit notification.value

Scenario: CompleteNotification
  Given subscription.active == true
  And notification.kind == "C"
  When source.next(notification)
  Then complete
  And source.unsubscribe()

Scenario: ErrorNotification
  Given subscription.active == true
  And notification.kind == "E"
  When source.next(notification)
  Then error notification.error
  And source.unsubscribe()

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And subscription.active = false

