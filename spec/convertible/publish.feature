Feature: publish

Scenario: SubscriberAttaches
  Given selector.configured == false
  And subject.stopped == false
  And subject.hasError == false
  When subscriber.subscribe()
  Then subject.attach(subscriber)
  And subscribers.count = subscribers.count + 1

Scenario: SubscribeWithSelector
  Given selector.configured == true
  When subscriber.subscribe()
  Then subject.create()
  And selectorOutput.subscribe()
  And source.subscribe(subject)
  And connected = true

Scenario: Connect
  Given selector.configured == false
  And connected == false
  And subject.stopped == false
  When connection.connect()
  Then source.subscribe(subject)
  And connected = true

Scenario: ForwardSourceValue
  Given connected == true
  When source.next(value)
  Then subject.next(value)

Scenario: ForwardSelectorOutputValue
  Given selector.configured == true
  When selectorOutput.next(value)
  Then emit value

Scenario: CompleteSource
  Given connected == true
  When source.complete()
  Then subject.stopped = true
  And subject.complete()

Scenario: CompleteSelectorOutput
  Given selector.configured == true
  When selectorOutput.complete()
  Then complete

Scenario: LateSubscriberAfterCompletion
  Given selector.configured == false
  And subject.stopped == true
  When subscriber.subscribe()
  Then complete

Scenario: ErrorSource
  Given connected == true
  When source.error(err)
  Then subject.hasError = true
  And subject.error(err)

Scenario: ErrorSelectorOutput
  Given selector.configured == true
  When selectorOutput.error(err)
  Then error err

Scenario: LateSubscriberAfterError
  Given selector.configured == false
  And subject.hasError == true
  When subscriber.subscribe()
  Then error subject.thrownError

Scenario: SubscriberDetaches
  Given selector.configured == false
  And subscribers.count > 0
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And subscribers.count = subscribers.count - 1

Scenario: UnsubscribeSelectorOutput
  Given selector.configured == true
  When subscriber.unsubscribe()
  Then selectorOutput.unsubscribe()
  And source.unsubscribe()
  And connected = false

