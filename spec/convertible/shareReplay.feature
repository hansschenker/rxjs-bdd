Feature: shareReplay

Scenario: FirstSubscriberConnects
  Given connected == false
  And subject.completed == false
  When subscriber.subscribe()
  Then subject.createReplay(bufferSize, windowTime)
  And subject.attach(subscriber)
  And subject.replay(subscriber)
  And refCount = 1
  And source.subscribe(subject)
  And connected = true

Scenario: LaterSubscriberAttaches
  Given connected == true
  When subscriber.subscribe()
  Then refCount = refCount + 1
  And subject.attach(subscriber)
  And subject.replay(subscriber)

Scenario: LateSubscriberAfterCompletion
  Given connected == false
  And subject.completed == true
  When subscriber.subscribe()
  Then subject.replay(subscriber)
  And complete

Scenario: ForwardSourceValue
  Given connected == true
  When source.next(value)
  Then subject.buffer.push(value)
  And subject.next(value)

Scenario: CompleteSource
  Given connected == true
  When source.complete()
  Then subject.completed = true
  And subject.complete()
  And connected = false

Scenario: ErrorSource
  Given connected == true
  When source.error(err)
  Then subject.error(err)
  And subject.reset()
  And connected = false

Scenario: SubscriberLeavesOthersRemain
  Given refCount > 1
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And refCount = refCount - 1

Scenario: LastSubscriberLeavesKeepingConnection
  Given refCount == 1
  And refCountOption == false
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And refCount = 0

Scenario: LastSubscriberLeavesWithReset
  Given refCount == 1
  And refCountOption == true
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And refCount = 0
  And source.unsubscribe()
  And subject.reset()
  And connected = false

