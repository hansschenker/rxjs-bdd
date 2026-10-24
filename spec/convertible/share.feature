Feature: share

Scenario: FirstSubscriberConnects
  Given connected == false
  When subscriber.subscribe()
  Then subject.create()
  And refCount = 1
  And subject.attach(subscriber)
  And source.subscribe(subject)
  And connected = true

Scenario: LaterSubscriberAttaches
  Given connected == true
  And reset.pending == false
  When subscriber.subscribe()
  Then refCount = refCount + 1
  And subject.attach(subscriber)

Scenario: LaterSubscriberCancelsPendingReset
  Given connected == true
  And reset.pending == true
  When subscriber.subscribe()
  Then resetNotifier.unsubscribe()
  And reset.pending = false
  And refCount = refCount + 1
  And subject.attach(subscriber)

Scenario: ForwardSourceValue
  Given connected == true
  When source.next(value)
  Then subject.next(value)

Scenario: CompleteSourceWithReset
  Given connected == true
  And resetOnComplete.kind == "immediate"
  When source.complete()
  Then subject.complete()
  And subject.reset()
  And connected = false

Scenario: CompleteSourceWithNotifierReset
  Given connected == true
  And resetOnComplete.kind == "notifier"
  When source.complete()
  Then subject.complete()
  And resetNotifier.subscribe(resetOnComplete())
  And reset.pending = true

Scenario: CompleteSourceWithoutReset
  Given connected == true
  And resetOnComplete.kind == "never"
  When source.complete()
  Then subject.complete()

Scenario: ErrorSourceWithReset
  Given connected == true
  And resetOnError.kind == "immediate"
  When source.error(err)
  Then subject.error(err)
  And subject.reset()
  And connected = false

Scenario: ErrorSourceWithNotifierReset
  Given connected == true
  And resetOnError.kind == "notifier"
  When source.error(err)
  Then subject.error(err)
  And resetNotifier.subscribe(resetOnError(err))
  And reset.pending = true

Scenario: ErrorSourceWithoutReset
  Given connected == true
  And resetOnError.kind == "never"
  When source.error(err)
  Then subject.error(err)

Scenario: ResetNotifierEmits
  Given reset.pending == true
  When resetNotifier.next()
  Then resetNotifier.unsubscribe()
  And reset.pending = false
  And source.unsubscribe()
  And subject.reset()
  And connected = false

Scenario: SubscriberLeavesOthersRemain
  Given refCount > 1
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And refCount = refCount - 1

Scenario: LastSubscriberLeavesImmediateReset
  Given refCount == 1
  And resetOnRefCountZero.kind == "immediate"
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And refCount = 0
  And source.unsubscribe()
  And subject.reset()
  And connected = false

Scenario: LastSubscriberLeavesNotifierReset
  Given refCount == 1
  And resetOnRefCountZero.kind == "notifier"
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And refCount = 0
  And resetNotifier.subscribe(resetOnRefCountZero())
  And reset.pending = true

Scenario: LastSubscriberLeavesNoReset
  Given refCount == 1
  And resetOnRefCountZero.kind == "never"
  When subscriber.unsubscribe()
  Then subject.detach(subscriber)
  And refCount = 0

