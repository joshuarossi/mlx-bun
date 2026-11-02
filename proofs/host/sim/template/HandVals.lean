/-! # The compile bookkeeping's values at POST's end

`nextTraceId` v20, `computeG`'s and the sampler's `#traceId` v22, v23 and payload v24, v25, `computeG`'s trace dims v26, and `traceCalls` v200, per row
count: rows of one or two tokens compile fewer traces before POST than every longer row, whose counts are equal at the shared pre-final cut. -/

namespace Host.Load.Run.Tpl

def handVal (L v : Nat) : Option Nat :=
  bif Nat.ble L 2 then
    (match v with
     | 20 => some 6 | 22 => some 4 | 23 => some 5 | 24 => some 4 | 25 => some 5 | 26 => some 1 | 200 => some 5
     | _ => none)
  else
    (match v with
     | 20 => some 8 | 22 => some 5 | 23 => some 7 | 24 => some 5 | 25 => some 7 | 26 => some (L - 1) | 200 => some 7
     | _ => none)

end Host.Load.Run.Tpl
