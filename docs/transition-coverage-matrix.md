# Transition Coverage Matrix

This document defines the coverage vocabulary for future operator test analysis.

| Coverage item | Question |
|---|---|
| Source next | What happens when a source value arrives in each relevant state? |
| Source complete | What happens to pending state and output on completion? |
| Source error | Is pending state emitted, discarded, or transformed before error? |
| Timer/scheduler event | What transition occurs when a scheduled boundary fires? |
| Notifier event | Does it open, close, flush, cancel, or complete? |
| Inner next | How is an active inner value handled? |
| Inner complete | Does capacity open, queued work start, or outer completion become possible? |
| Inner error | Is the error forwarded, recovered, or transformed? |
| Subscription | Is source connection immediate, deferred, or shared? |
| Unsubscription | What state and resources are torn down? |
| Concurrency admission | Is work allowed, queued, replaced, or ignored? |
| Cancellation | Which active work is cancelled and under what event? |

The matrix is intentionally broader than ordinary value marbles because RxJS operator semantics also include lifecycle, scheduling, subscription, and teardown.

## Mapping to the catalog

The rule kinds in `spec/operators.json` cover the matrix as follows:

| Coverage item | Catalog rule kind |
|---|---|
| Source next | `state` and `event` |
| Inner next | `inner` (present only for the 37 operators with inner observables or secondary inputs) |
| Concurrency admission | `concurrency` (present only for the 60 operators whose work can overlap or be superseded) |
| Timer/scheduler event | `timer` (present only for the 13 operators that schedule work) |
| Notifier event | `notifier` (present only for the 20 operators that consume a secondary observable) |
| Source complete, Inner complete, notifier completion | `completion` |
| Source error, Inner error, notifier error | `error` |
| Unsubscription | `unsubscription` |
| Cancellation | `cancellation`, including explicit "cancels nothing" rules for operators that never cancel work on their own |
| Subscription | `subscription` |
