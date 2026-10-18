import host.ts.BufferFillRefinement

namespace Host.Ts.BufferFillTests

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-- The actual loader hotspot: `new Uint8Array(512).fill(0)`. -/
theorem full_512 :
    fillCells .u8 (.num (.lit (.zero false))) (zeroBytes 512) 0 512 =
      List.replicate 512 (.part .u8 (.num (.lit (.zero false))) 0) := by rfl

end Host.Ts.BufferFillTests
