Feature: partition

Scenario: SubscribeOutput
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And source.subscribe()

Scenario: ForwardSelectedValue
  Given subscription.active == true
  And predicate(value) == output.selects
  When source.next(value)
  Then emit value

Scenario: DropUnselectedValue
  Given subscription.active == true
  And predicate(value) != output.selects
  When source.next(value)
  Then emit nothing

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

