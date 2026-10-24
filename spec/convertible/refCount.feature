Feature: refCount

Scenario: FirstSubscriberConnects
  Given refCount == 0
  When subscriber.subscribe()
  Then subject.attach(subscriber)
  And refCount = 1
  And connection.connect()
  And connected = true

Scenario: LaterSubscriberAttaches
  Given refCount > 0
  When subscriber.subscribe()
  Then subject.attach(subscriber)
  And refCount = refCount + 1

Scenario: ForwardSourceValue
  Given connected == true
  When source.next(value)
  Then subject.next(value)

Scenario: CompleteSource
  Given connected == true
  When source.complete()
  Then subject.complete()

Scenario: ErrorSource
  Given connected == true
  When source.error(err)
  Then subject.error(err)

Scenario: SubscriberLeavesOthersRemain
  Given refCount > 1
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And refCount = refCount - 1

Scenario: LastSubscriberLeaves
  Given refCount == 1
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And refCount = 0
  And connection.unsubscribe()
  And connected = false

