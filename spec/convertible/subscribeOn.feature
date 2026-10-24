Feature: subscribeOn

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And scheduled = true
  And subscribed = false
  And scheduler.schedule(subscribeSource, delay)

Scenario: ScheduledActionRuns
  Given scheduled == true
  When scheduler.run(subscribeSource)
  Then scheduled = false
  And subscribed = true
  And source.subscribe()

Scenario: ForwardValue
  Given subscription.active == true
  And subscribed == true
  When source.next(value)
  Then emit value

Scenario: CompleteSource
  Given subscription.active == true
  And subscribed == true
  When source.complete()
  Then complete

Scenario: ErrorSource
  Given subscription.active == true
  And subscribed == true
  When source.error(err)
  Then error err

Scenario: UnsubscribeWhileScheduled
  Given subscription.active == true
  And scheduled == true
  When subscriber.unsubscribe()
  Then scheduler.cancel(subscribeSource)
  And scheduled = false
  And subscription.active = false

Scenario: UnsubscribeWhileSubscribed
  Given subscription.active == true
  And subscribed == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And subscription.active = false

