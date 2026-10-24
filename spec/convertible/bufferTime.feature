Feature: bufferTime

Scenario: SubscribeWithCreationInterval
  Given subscription.active == false
  And creationInterval.configured == true
  When subscriber.subscribe()
  Then subscription.active = true
  And buffers.open()
  And closeTimer.start(bufferTimeSpan)
  And creation.start(bufferCreationInterval)
  And source.subscribe()

Scenario: SubscribeWithoutCreationInterval
  Given subscription.active == false
  And creationInterval.configured == false
  When subscriber.subscribe()
  Then subscription.active = true
  And buffers.open()
  And closeTimer.start(bufferTimeSpan)
  And source.subscribe()

Scenario: AppendValue
  Given subscription.active == true
  And buffers.oldestSize + 1 < maxBufferSize
  When source.next(value)
  Then buffers.pushAll(value)
  And emit nothing

Scenario: AppendAndEmitAtMaxSizeThenReopen
  Given subscription.active == true
  And buffers.oldestSize + 1 == maxBufferSize
  And creationInterval.configured == false
  When source.next(value)
  Then buffers.pushAll(value)
  And closeTimer.cancel(buffers.oldest)
  And emit buffers.oldest
  And buffers.closeOldest()
  And buffers.open()
  And closeTimer.start(bufferTimeSpan)

Scenario: AppendAndEmitAtMaxSize
  Given subscription.active == true
  And buffers.oldestSize + 1 == maxBufferSize
  And creationInterval.configured == true
  When source.next(value)
  Then buffers.pushAll(value)
  And closeTimer.cancel(buffers.oldest)
  And emit buffers.oldest
  And buffers.closeOldest()

Scenario: CloseTimerFiresThenReopen
  Given subscription.active == true
  And creationInterval.configured == false
  When closeTimer.fire(index)
  Then emit buffers.at(index)
  And buffers.close(index)
  And buffers.open()
  And closeTimer.start(bufferTimeSpan)

Scenario: CloseTimerFires
  Given subscription.active == true
  And creationInterval.configured == true
  When closeTimer.fire(index)
  Then emit buffers.at(index)
  And buffers.close(index)

Scenario: CreationIntervalTicks
  Given subscription.active == true
  And creationInterval.configured == true
  When creation.tick()
  Then buffers.open()
  And closeTimer.start(bufferTimeSpan)

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then output.emitEach(buffers)
  And closeTimer.cancelAll()
  And creation.cancel()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then buffers.clear()
  And closeTimer.cancelAll()
  And creation.cancel()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And closeTimer.cancelAll()
  And creation.cancel()
  And buffers.clear()
  And subscription.active = false

