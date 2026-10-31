import host.sim.compose.PreFill
import host.route.LoadCut

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-- Keep the loaded valuation prefix and the emitted-token binding. -/
def setupInputs (T : Nat) (tk : Nat → Nat) (x : SegInst Full.FF) : Prop :=
  (∀ j, j < 9 → x.ν j = Host.Route.machVal T tk j) ∧ x.M.a 2590 = 2590

def withSetupInputs (T : Nat) (tk : Nat → Nat) (A : ICut Full.FF) : ICut Full.FF :=
  { A with B := fun x => A.B x ∧ setupInputs T tk x }

/-- The target's native counters within offsets above the template's. -/
def NativeAt (H N : Nat) (s t : St Full.FF.S) : Prop :=
  (Full.mlxOf t.ffi).next ≤ (Full.mlxOf s.ffi).next + H ∧ (Full.mlxOf t.ffi).nnext ≤ (Full.mlxOf s.ffi).nnext + N

/-- The native counters a stretch moves over, inside the fresh band. -/
def countersOkB (sa sb : St Full.FF.S) : Bool :=
  Nat.ble (Full.mlxOf sa.ffi).next (Full.mlxOf sb.ffi).next && Nat.blt (Full.mlxOf sb.ffi).next 131072 &&
    Nat.ble (Full.mlxOf sa.ffi).nnext (Full.mlxOf sb.ffi).nnext

/-- Both sides allocate the same handles and nodes: the fresh bands of the two relations meet. -/
theorem NativeAt.step {H N NB : Nat} {P : LoadP} {W W' : Nat → Option WFrame} {M M' : Map}
    {ν ν' : Nat → F64} {K K' : Ctx} {sa sb t t' : St Full.FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (h : NativeAt H N sa t) (hP : P.E = 131072)
    (hr : RelB Full.FF (Disp.FRJ (Full.FullRXD P NB)) W [] M ν K sa Sa t C)
    (hr' : RelB Full.FF (Disp.FRJ (Full.FullRXD P NB)) W' [] M' ν' K' sb Sb t' C')
    (hbig : M'.big = M.big) (hnode : M'.node = M.node) (hc : countersOkB sa sb = true) :
    NativeAt H N sb t' := by
  simp only [countersOkB, Bool.and_eq_true] at hc
  obtain ⟨⟨hle, hlt⟩, hnle⟩ := hc
  have hle := Nat.le_of_ble_eq_true hle
  have hlt := Nat.blt_eq.mp hlt
  have hnle := Nat.le_of_ble_eq_true hnle
  obtain ⟨P0, hP0, r0⟩ := hr.ffi.1
  obtain ⟨P1, hP1, r1⟩ := hr'.ffi.1
  obtain ⟨_, hE0, _, _⟩ := Full.Raised.restart (.inl rfl) hP0
  obtain ⟨_, hE1, _, _⟩ := Full.Raised.restart (.inl rfl) hP1
  have a0 := r0.load.mlx.hfreshB ((Full.mlxOf sb.ffi).next - (Full.mlxOf sa.ffi).next) (by
    change (Full.mlxOf sa.ffi).next + _ < P0.E
    rw [hE0, hP]; omega)
  have a1 := r1.load.mlx.hfreshB 0 (by
    change (Full.mlxOf sb.ffi).next + 0 < P1.E
    rw [hE1, hP]; omega)
  have n0 := r0.load.mlx.nfresh ((Full.mlxOf sb.ffi).nnext - (Full.mlxOf sa.ffi).nnext)
  have n1 := r1.load.mlx.nfresh 0
  change M.big (Int.ofNat ((Full.mlxOf sa.ffi).next + _)) = Int.ofNat ((Full.mlxOf t.ffi).next + _) at a0
  change M'.big (Int.ofNat ((Full.mlxOf sb.ffi).next + 0)) = Int.ofNat ((Full.mlxOf t'.ffi).next + 0) at a1
  change M.node ((Full.mlxOf sa.ffi).nnext + _) = (Full.mlxOf t.ffi).nnext + _ at n0
  change M'.node ((Full.mlxOf sb.ffi).nnext + 0) = (Full.mlxOf t'.ffi).nnext + 0 at n1
  rw [hbig] at a1
  rw [hnode] at n1
  have eh : (Full.mlxOf sa.ffi).next + ((Full.mlxOf sb.ffi).next - (Full.mlxOf sa.ffi).next) = (Full.mlxOf sb.ffi).next + 0 := by omega
  have en : (Full.mlxOf sa.ffi).nnext + ((Full.mlxOf sb.ffi).nnext - (Full.mlxOf sa.ffi).nnext) = (Full.mlxOf sb.ffi).nnext + 0 := by omega
  rw [eh, a1] at a0
  rw [en, n1] at n0
  have a2 := Int.ofNat.inj a0
  obtain ⟨h1, h2⟩ := h
  constructor <;> omega

/-- The prompt the frame holds. -/
def PromptFr (π : List Nat) (x : SegInst Full.FF) : Prop :=
  x.K.fr 2665 = some ([], π.map natV)

/-- A cut step also exposes the agreements a retained layer needs: the reserved variables, the
emitted-token binding, the prompt's frame and the native offsets. -/
def CutStepKeeps (A B : ICut Full.FF) (n : Nat) : Prop :=
  ∀ x, A.R x A.s0 ⟨A.tab0, []⟩ → A.B x →
    ∃ y, runC Full.FF n x.t x.C = some (y.t, y.C) ∧ B.R y B.s0 ⟨B.tab0, []⟩ ∧ B.B y ∧
      (∀ j, j < 9 → y.ν j = x.ν j) ∧ y.M.a 2590 = x.M.a 2590 ∧ y.K.fr 2665 = x.K.fr 2665 ∧
      ∀ H N, NativeAt H N A.s0 x.t → NativeAt H N B.s0 y.t

def CutConvKeeps (A B : ICut Full.FF) : Prop :=
  ∀ x, A.R x A.s0 ⟨A.tab0, []⟩ → A.B x →
    ∃ y, y.t = x.t ∧ y.C = x.C ∧ B.R y B.s0 ⟨B.tab0, []⟩ ∧ B.B y ∧
      (∀ j, j < 9 → y.ν j = x.ν j) ∧ y.M.a 2590 = x.M.a 2590 ∧ y.K.fr 2665 = x.K.fr 2665 ∧
      ∀ H N, NativeAt H N A.s0 x.t → NativeAt H N B.s0 y.t

theorem CutStepKeeps.step {A B : ICut Full.FF} {n : Nat} (h : CutStepKeeps A B n) :
    CutStep A B n := by
  rintro t C ⟨x, rfl, rfl, hr, hb⟩
  obtain ⟨y, hrun, hr', hb', _⟩ := h x hr hb
  exact ⟨y.t, y.C, hrun, y, rfl, rfl, hr', hb'⟩

theorem CutConvKeeps.conv {A B : ICut Full.FF} (h : CutConvKeeps A B) : CutConv A B := by
  intro x hr hb
  obtain ⟨y, ht, hC, hr', hb', _⟩ := h x hr hb
  exact ⟨y, ht, hC, hr', hb'⟩

theorem CutStepKeeps.withInputs {A B : ICut Full.FF} {n : Nat} (h : CutStepKeeps A B n)
    (T : Nat) (tk : Nat → Nat) : CutStep (withSetupInputs T tk A) (withSetupInputs T tk B) n := by
  rintro t C ⟨x, rfl, rfl, hr, hb, hv, ha⟩
  obtain ⟨y, hrun, hr', hb', hν, hA, -⟩ := h x hr hb
  exact ⟨y.t, y.C, hrun, y, rfl, rfl, hr', hb', fun j hj => (hν j hj).trans (hv j hj), hA.trans ha⟩

theorem CutConvKeeps.withInputs {A B : ICut Full.FF} (h : CutConvKeeps A B)
    (T : Nat) (tk : Nat → Nat) : CutConv (withSetupInputs T tk A) (withSetupInputs T tk B) := by
  rintro x hr ⟨hb, hv, ha⟩
  obtain ⟨y, ht, hC, hr', hb', hν, hA, -⟩ := h x hr hb
  exact ⟨y, ht, hC, hr', hb', fun j hj => (hν j hj).trans (hv j hj), hA.trans ha⟩

/-- The setup cuts' retained layer, at the actual prompt and native offsets. -/
def withSetupPin (T : Nat) (tk : Nat → Nat) (π : List Nat) (A : ICut Full.FF) : ICut Full.FF :=
  { A with B := fun x => A.B x ∧ setupInputs T tk x ∧ PromptFr π x ∧ NativeAt 0 0 A.s0 x.t }

theorem CutStepKeeps.pin {A B : ICut Full.FF} {n : Nat} (h : CutStepKeeps A B n)
    (T : Nat) (tk : Nat → Nat) (π : List Nat) : CutStep (withSetupPin T tk π A) (withSetupPin T tk π B) n := by
  rintro t C ⟨x, rfl, rfl, hr, hb, ⟨hv, ha⟩, hp, hn⟩
  obtain ⟨y, hrun, hr', hb', hν, hA, hf, hN⟩ := h x hr hb
  exact ⟨y.t, y.C, hrun, y, rfl, rfl, hr', hb', ⟨fun j hj => (hν j hj).trans (hv j hj), hA.trans ha⟩,
    hf.trans hp, hN _ _ hn⟩

theorem CutConvKeeps.pin {A B : ICut Full.FF} (h : CutConvKeeps A B)
    (T : Nat) (tk : Nat → Nat) (π : List Nat) : CutConv (withSetupPin T tk π A) (withSetupPin T tk π B) := by
  rintro x hr ⟨hb, ⟨hv, ha⟩, hp, hn⟩
  obtain ⟨y, ht, hC, hr', hb', hν, hA, hf, hN⟩ := h x hr hb
  exact ⟨y, ht, hC, hr', hb', ⟨fun j hj => (hν j hj).trans (hv j hj), hA.trans ha⟩,
    hf.trans hp, hN _ _ hn⟩

end Host.Ts.Sim.Compose
