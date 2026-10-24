Feature: elementAt

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And position = 0
  And source.subscribe()

Scenario: SkipBeforeIndex
  Given subscription.active == true
  And position < index
  When source.next(value)
  Then position = position + 1
  And emit nothing

Scenario: EmitAtIndex
  Given subscription.active == true
  And position == index
  When source.next(value)
  Then emit value
  And complete
  And source.unsubscribe()

Scenario: CompleteTooEarlyWithoutDefault
  Given subscription.active == true
  And position <= index
  And defaultValue.configured == false
  When source.complete()
  Then error ArgumentOutOfRangeError

Scenario: CompleteTooEarlyWithDefault
  Given subscription.active == true
  And position <= index
  And defaultValue.configured == true
  When source.complete()
  Then emit defaultValue
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And position = 0
  And subscription.active = false

