Feature: windowTime

Scenario: SubscribeWithCreationInterval
  Given subscription.active == false
  And creationInterval.configured == true
  When subscriber.subscribe()
  Then subscription.active = true
  And windows.open()
  And emit windows.newest()
  And closeTimer.start(windowTimeSpan)
  And creation.start(windowCreationInterval)
  And source.subscribe()

Scenario: SubscribeWithoutCreationInterval
  Given subscription.active == false
  And creationInterval.configured == false
  When subscriber.subscribe()
  Then subscription.active = true
  And windows.open()
  And emit windows.newest()
  And closeTimer.start(windowTimeSpan)
  And source.subscribe()

Scenario: RouteValue
  Given subscription.active == true
  And windows.oldestSize + 1 < maxWindowSize
  When source.next(value)
  Then windows.nextAll(value)
  And emit nothing

Scenario: RouteValueAndCloseAtMaxSizeThenReopen
  Given subscription.active == true
  And windows.oldestSize + 1 == maxWindowSize
  And creationInterval.configured == false
  When source.next(value)
  Then windows.nextAll(value)
  And closeTimer.cancel(windows.oldest)
  And windows.completeOldest()
  And windows.open()
  And emit windows.newest()
  And closeTimer.start(windowTimeSpan)

Scenario: RouteValueAndCloseAtMaxSize
  Given subscription.active == true
  And windows.oldestSize + 1 == maxWindowSize
  And creationInterval.configured == true
  When source.next(value)
  Then windows.nextAll(value)
  And closeTimer.cancel(windows.oldest)
  And windows.completeOldest()

Scenario: CloseTimerFiresThenReopen
  Given subscription.active == true
  And creationInterval.configured == false
  When closeTimer.fire(index)
  Then windows.complete(index)
  And windows.open()
  And emit windows.newest()
  And closeTimer.start(windowTimeSpan)

Scenario: CloseTimerFires
  Given subscription.active == true
  And creationInterval.configured == true
  When closeTimer.fire(index)
  Then windows.complete(index)

Scenario: CreationIntervalTicks
  Given subscription.active == true
  And creationInterval.configured == true
  When creation.tick()
  Then windows.open()
  And emit windows.newest()
  And closeTimer.start(windowTimeSpan)

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then windows.completeAll()
  And closeTimer.cancelAll()
  And creation.cancel()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then windows.errorAll(err)
  And closeTimer.cancelAll()
  And creation.cancel()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And closeTimer.cancelAll()
  And creation.cancel()
  And windows.release()
  And subscription.active = false

