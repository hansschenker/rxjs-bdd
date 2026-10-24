Feature: connect

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And subject.create()
  And selectorOutput.subscribe()
  And source.subscribe(subject)

Scenario: ForwardSourceValueToSubject
  Given subscription.active == true
  When source.next(value)
  Then subject.next(value)

Scenario: ForwardSelectorOutputValue
  Given subscription.active == true
  When selectorOutput.next(value)
  Then emit value

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then subject.complete()

Scenario: CompleteSelectorOutput
  Given subscription.active == true
  When selectorOutput.complete()
  Then complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then subject.error(err)

Scenario: ErrorSelectorOutput
  Given subscription.active == true
  When selectorOutput.error(err)
  Then error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And selectorOutput.unsubscribe()
  And subscription.active = false

