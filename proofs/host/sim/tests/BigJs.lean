import host.ts.Harness
import host.sim.dispatch.OkJs

/-! # Tests: JS pointer integers (`Disp.okJSJ`, `host/sim/steps/BigJs.lean`)

`BigInt(ptr(b))` (`metal-kernel.ts`'s `vectorString`) is rejected by `okJS` and accepted by
`bigJsCallB`; `jsPtrOf` decodes the integer. -/

namespace Host.Ts.Sim.Tests.BigJs
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Disp

/-- `BigInt` at 60 called on a pointer into the buffer at 50 (`nullFfi`). -/
def st : St Unit :=
  ⟨[(50, HObj.obj ⟨.buf [], .null, [], [], true⟩),
    (60, HObj.obj ⟨.fn (.native (.num .bigint) []), .null, [], [], true⟩)].foldl
      (fun h p => h.set p.1 p.2) PTrie.nil, 61,
    .call (.obj 60) .undef [.ptr (.js 50) 3], [], ⟨[], (), [], []⟩⟩

def jsp : JSP nullFfi :=
  { okCall := fun _ _ _ => false, smallB := fun _ _ _ _ => false, lo := 0, hi := 0, framed := [],
    isHandle := fun _ _ => false, isRegion := fun _ _ => false }

kernel_rfl decode : jsPtrOf (ptrInt (.js 2676978) 7) = some (2676978, 7)
kernel_rfl call_js : bigJsCallB (F := nullFfi) st = true
kernel_rfl call_old : okJS jsp st ⟨[], []⟩ = false
kernel_rfl call_new : okJSJ jsp (fun _ _ => false) 0 st ⟨[], []⟩ = true

end Host.Ts.Sim.Tests.BigJs
