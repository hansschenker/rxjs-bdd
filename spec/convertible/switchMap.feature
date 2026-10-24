Feature: switchMap

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And inner.active = false
  And source.completed = false
  And source.subscribe()

Scenario: StartInner
  Given subscription.active == true
  And inner.active == false
  When source.next(value)
  Then inner.active = true
  And inner.subscribe(project(value))

Scenario: SwitchToNewInner
  Given subscription.active == true
  And inner.active == true
  When source.next(value)
  Then inner.unsubscribe()
  And inner.subscribe(project(value))

Scenario: ForwardInnerValue
  Given inner.active == true
  When inner.next(value)
  Then emit value

Scenario: InnerCompletesSourceActive
  Given inner.active == true
  And source.completed == false
  When inner.complete()
  Then inner.active = false

Scenario: InnerCompletesAfterSourceCompleted
  Given inner.active == true
  And source.completed == true
  When inner.complete()
  Then inner.active = false
  And complete

Scenario: CompleteSourceIdle
  Given subscription.active == true
  And inner.active == false
  When source.complete()
  Then complete

Scenario: CompleteSourceBusy
  Given subscription.active == true
  And inner.active == true
  When source.complete()
  Then source.completed = true

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then inner.unsubscribe()
  And error err

Scenario: ErrorInner
  Given inner.active == true
  When inner.error(err)
  Then source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And inner.unsubscribe()
  And subscription.active = false

