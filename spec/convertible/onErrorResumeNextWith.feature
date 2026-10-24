Feature: onErrorResumeNextWith

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And current = 0
  And input.subscribe(0)

Scenario: ForwardValue
  Given subscription.active == true
  When input.next(value, index)
  Then emit value

Scenario: InputCompletesMoreRemain
  Given subscription.active == true
  And current + 1 < sources.count
  When input.complete(index)
  Then current = current + 1
  And input.subscribe(current)

Scenario: LastInputCompletes
  Given subscription.active == true
  And current + 1 == sources.count
  When input.complete(index)
  Then complete

Scenario: InputErrorsMoreRemain
  Given subscription.active == true
  And current + 1 < sources.count
  When input.error(err, index)
  Then current = current + 1
  And input.subscribe(current)

Scenario: LastInputErrors
  Given subscription.active == true
  And current + 1 == sources.count
  When input.error(err, index)
  Then complete

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then input.unsubscribe(current)
  And subscription.active = false

