Feature: publishBehavior

Scenario: SubscriberAttaches
  Given subject.stopped == false
  And subject.hasError == false
  When subscriber.subscribe()
  Then subject.attach(subscriber)
  And subscribers.count = subscribers.count + 1
  And emit subject.value

Scenario: Connect
  Given connected == false
  And subject.stopped == false
  When connection.connect()
  Then source.subscribe(subject)
  And connected = true

Scenario: ForwardSourceValue
  Given connected == true
  When source.next(value)
  Then subject.value = value
  And subject.next(value)

Scenario: CompleteSource
  Given connected == true
  When source.complete()
  Then subject.stopped = true
  And subject.complete()

Scenario: LateSubscriberAfterCompletion
  Given subject.stopped == true
  When subscriber.subscribe()
  Then complete

Scenario: ErrorSource
  Given connected == true
  When source.error(err)
  Then subject.hasError = true
  And subject.error(err)

Scenario: LateSubscriberAfterError
  Given subject.hasError == true
  When subscriber.subscribe()
  Then error subject.thrownError

Scenario: SubscriberDetaches
  Given subscribers.count > 0
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And subscribers.count = subscribers.count - 1

