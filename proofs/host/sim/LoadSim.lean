import host.sim.LoadIter
import host.sim.native.CallSim
import host.sim.native.Small
import host.sim.native.Facts
import host.sim.native.Lawful
import host.sim.native.FfiSim
namespace Host.Ts.Sim
open Host.Ts

/-! # The one-step simulation of the load world

The dispatcher's acceptance function with the load world's native deciders, and
its one-step theorem for the native relation with any remaining readbacks. -/

/-- The template's native parameters: handle band from 25000, room up to `131072`
handles and `2 ^ 40` nodes, 20000 pre-loop nodes (closure traces reach node 17771), the template's node counter. -/
def loadP0 : LoadP := ⟨25000, 131072, 2 ^ 40, 20000, 22539, []⟩

/-- Bound on the template variables' values. -/
def loopVB : Nat → Nat := fun _ => 2 ^ 20

/-- Every template variable denotes a natural number below `2 ^ 20`. -/
def LoopVBOk (ν : Nat → F64) : Prop := ∀ v, ∃ k ≤ loopVB v, ν v = F64.ofNat k

/-- The acceptance parameters with framed arrays `framed`. -/
def loadJSP (framed : List Nat) : Disp.JSP LF :=
  { okCall := okCallS loadP0, smallB := smallLoadB loopVB, lo := 25000, hi := 131072, framed := framed,
    isHandle := loadIsHandle, isRegion := loadIsRegion }

theorem loadNativeFacts (framed : List Nat) (r : List NumV) :
    Disp.NativeFacts LF (LR loadP0 r) (loadJSP framed) where
  zero := fun _ _ _ _ hr i => hr.zero_fact i
  inj := fun _ _ _ _ hr i j hi hj he => hr.inj_fact i j hi hj he
  region := fun _ _ _ _ hr r r' h1 h2 he => hr.region_fact r r' h1 h2 he
  range := fun _ _ _ _ hr i hi => hr.range_fact i hi
  host := fun _ _ _ _ hr r h3 hlt => hr.host_fact r h3 hlt
  cb := fun _ _ _ _ hr f hf => hr.cb_fact f hf

/-- **The one-step theorem of the load world**, for any remaining readbacks. -/
theorem loadStepSim (framed : List Nat) (r : List NumV) :
    Disp.StepSimXV LF (LR loadP0 r) (Disp.okJS (loadJSP framed)) (Disp.Kp (loadJSP framed)) LoopVBOk := by
  have hC : FfiCallSim LF (LR loadP0 r) (loadJSP framed).okCall smallLoad := by
    show FfiCallSim LF (LR loadP0 r) (okCallS loadP0) smallLoad
    rw [← okCallS_rest loadP0 r]
    exact loadFfiCallSim _
  exact Disp.stepSimXV (loadFfiSim _) hC (fun _ _ _ _ _ hν hb => smallLoadB_sound hb hν) (loadR_laws _)
    loadFfiLawful (loadNativeFacts framed r)

end Host.Ts.Sim
