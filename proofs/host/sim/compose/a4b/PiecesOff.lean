import host.sim.compose.BundleR
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Gpu
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Prefill

/-! # Rows another prompt length serves

One prompt runs one class. Its bookkeeping names its length, so a row of another length has no state to step from: its piece is empty. -/

section
variable {F : Ffi} {uses : List Row} {obls : List Obl} {A B : Cls.Inst → ICut F} {L : Nat}

/-- Every state of `A i` is at the prompt's length. -/
def Pinned (L : Nat) (A : Cls.Inst → ICut F) : Prop := ∀ i x, (A i).B x → i.L = L

/-- No row is at the prompt's length. -/
def RowsOff (L : Nat) (uses : List Row) : Prop := ∀ r ∈ uses, ∀ i, InRow r i → i.L ≠ L

theorem stepOff {i : Cls.Inst} (hA : Pinned L A) (hL : i.L ≠ L) (n : Nat) : CutStep (A i) (B i) n := by
  rintro t C ⟨x, -, -, -, hb⟩
  exact absurd (hA i x hb) hL

theorem convOff {i : Cls.Inst} (hA : Pinned L A) (hL : i.L ≠ L) : CutConv (A i) (B i) :=
  fun x _ hb => absurd (hA i x hb) hL

def glueOff (hA : Pinned L A) (hr : RowsOff L uses) : GluePiece F uses A B where
  m := []
  n := 0
  O := []
  chk _ _ := rfl
  ok r hm i hi _ := stepOff hA (hr r hm i hi) 0

def stageOff (hA : Pinned L A) (hr : RowsOff L uses) : StagePiece F uses obls A B where
  m := []
  n := 0
  O := []
  chk _ _ := rfl
  ok r hm i hi _ := StageCall.intro (convOff hA (hr r hm i hi)) (CutStep.refl _) (CutConv.refl _)

def fwdOff (hA : Pinned L A) (hr : RowsOff L uses) : FwdPiece F uses obls A B where
  m := []
  np := 0
  nb := 0
  O := []
  chk _ _ := rfl
  ok r hm i hi _ := FwdCall.warm (convOff hA (hr r hm i hi)) (CutStep.refl _) (CutConv.refl _)

end

end Host.Ts.Sim.Compose.Gpu
