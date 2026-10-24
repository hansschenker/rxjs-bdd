Feature: bufferCount

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And buffers.count = 0
  And count = 0
  And source.subscribe()

Scenario: OpenBufferAndAppend
  Given subscription.active == true
  And count % startBufferEvery == 0
  And buffers.oldestSize + 1 < bufferSize
  When source.next(value)
  Then buffers.open()
  And buffers.count = buffers.count + 1
  And buffers.pushAll(value)
  And count = count + 1
  And emit nothing

Scenario: AppendValue
  Given subscription.active == true
  And count % startBufferEvery != 0
  And buffers.oldestSize + 1 < bufferSize
  When source.next(value)
  Then buffers.pushAll(value)
  And count = count + 1
  And emit nothing

Scenario: AppendAndEmitFullBuffer
  Given subscription.active == true
  And count % startBufferEvery != 0
  And buffers.oldestSize + 1 == bufferSize
  When source.next(value)
  Then buffers.pushAll(value)
  And count = count + 1
  And emit buffers.oldest
  And buffers.closeOldest()
  And buffers.count = buffers.count - 1

Scenario: OpenAppendAndEmitFullBuffer
  Given subscription.active == true
  And count % startBufferEvery == 0
  And buffers.oldestSize + 1 == bufferSize
  When source.next(value)
  Then buffers.open()
  And buffers.pushAll(value)
  And count = count + 1
  And emit buffers.oldest
  And buffers.closeOldest()

Scenario: CompleteWithOpenBuffers
  Given subscription.active == true
  And buffers.count > 0
  When source.complete()
  Then output.emitEach(buffers)
  And buffers.count = 0
  And complete

Scenario: CompleteWithoutBuffers
  Given subscription.active == true
  And buffers.count == 0
  When source.complete()
  Then complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then buffers.clear()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And buffers.clear()
  And subscription.active = false

