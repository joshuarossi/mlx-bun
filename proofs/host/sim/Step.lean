import host.sim.State
namespace Host.Ts.Sim

/-! # One machine step

Each supported kind of source step has a lemma of the shape

`Rel F FR M ν K s S t C → (structure of s) → (side conditions) →
  s.next + margin < bound → MSim (StepPost …) S C (step F s) (step F t)`

where the side conditions are facts about the source state that the checked
run's `ok` decides. `StepPost` keeps the server growth and the relation of the
resulting states. Native-state requirements are collected in `FRLaws`. -/

/-- Allocation room within one step: every supported step allocates fewer addresses. -/
def margin : Nat := 2 ^ 30

/-- The native relation is stable under extension of the map at fresh number
references, and weakens as the reference bound grows. -/
structure FRLaws {F : Ffi} (FR : Map → Nat → F.S → F.S → Prop) : Prop where
  stable : ∀ M M' n x y, FR M n x y → Ext M M' n → FR M' n x y
  mono : ∀ M n n' x y, FR M n x y → n ≤ n' → FR M n' x y

def StepPostB (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame)
    (M : Map) (ν : Nat → F64) (K : Ctx) (S : SSrv) (C : CSrv) : Map → SSrv → CSrv → St F.S → St F.S → Prop :=
  fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧ RelB F FR W stk M' ν K s1 S' t1 C'

/-- `StepPostB` without a stack base. -/
abbrev StepPostW (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (M : Map) (ν : Nat → F64)
    (K : Ctx) (S : SSrv) (C : CSrv) : Map → SSrv → CSrv → St F.S → St F.S → Prop :=
  StepPostB F FR W [] M ν K S C

/-- `StepPostW` without frames. -/
abbrev StepPost (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (ν : Nat → F64) (K : Ctx)
    (S : SSrv) (C : CSrv) : Map → SSrv → CSrv → St F.S → St F.S → Prop :=
  StepPostW F FR noFrames M ν K S C

/-- A step lemma's conclusion gives the target step of `StepSim`. -/
theorem StepPost.run {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64}
    {K : Ctx} {S : SSrv} {C : CSrv}
    {s t s1 : St F.S} {S1 : SSrv}
    (h : MSim (StepPost F FR M ν K S C) S C (step F s) (step F t))
    (hs : interpS (step F s).run S = some (s1, S1)) :
    ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧
      Rel F FR M' ν K s1 S1 t1 C1 := by
  obtain ⟨M', t1, C1, ht, hg, hr⟩ := MSim.run h s1 S1 hs
  exact ⟨M', t1, C1, ht, hg.ext, hr⟩

end Host.Ts.Sim
