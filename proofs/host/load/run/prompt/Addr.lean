import host.sim.DecodeAddr
namespace Host.Load.Run.Prompt
open Host.Ts.Sim

/-! The decode loop's constants for `RoutePrompt`'s driver (the prompt from `%proof/decode-input`),
at the prompt `[9707]` of today's template. The driver's allocations before `loadDone` are
`Route`'s two higher from the host module's array (2665) and cell (2666) on; the old literal
`[9707]` (2673200) is not allocated, so those after it are one higher. The route reaches
today's template cut two steps sooner (`PROMPT` takes one step where the literal took three):
natively at 32,711,602 steps, against the checked oracle, its control, stack, jobs, number
table and oracle are `Full.P.s3272`'s under this renaming, and its heap differs only in the six
objects holding the driver's code or environment. `forwarded` 2673447 ↦ 2673448, `emitted`
12502 ↦ 12504, the driver's cells (`emitted`, `cache`, `generation`: below 2665) unchanged; the
table (its entry 79), the native nodes (counter 22539) and the native bigints (the rope base)
equal `addr0`'s. -/

def addrPrompt : Addr :=
  { fwd := 2673448, emit := 12504, cE := 2590, cache := 2586, gen := 2589, tok := 79, nxt := 17,
    tvar := 9, kvar := 14, NL := 20000, N0 := 22539, rope := 5554869888, fwd_emit := by decide }

end Host.Load.Run.Prompt
