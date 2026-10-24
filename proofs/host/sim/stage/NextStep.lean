import host.sim.stage.Read
import host.sim.stage.NextStepRun
import host.sim.PrefillSched
set_option Elab.async false
namespace Host.Ts.Sim.Stage.NextStep
open Host.Ts Host.Ts.Sim.Stage
open Host.Ts.Sim.Prefill (PStep Phase nextStep phaseOf)

/-! # The `nextPrefillStep` stage contract

`nextPrefillStep({ length: L, position: p, chunkSize: C, tailSplit: true, snapshotAt })`
(contracts/portable/prefill.ts:41-63; called at generation/autoregressive.ts:498-499 with
`snapshotAt` undefined) returns a fresh `PrefillStep` object that encodes the Lean schedule
step `nextStep L p C` (`host.sim.PrefillSched`), with `batchYield` `C + 1 < L - p`, and changes
nothing else: no existing heap entry is written, the jobs, stores and trace are unchanged, the
native state is unchanged (`LiveDelta` allocates and frees nothing under every liveness layer),
under every FFI, native state and caller stack (`prefillStage_holds`, `host.sim.stage.NextStepHolds`).

The inputs (`Dom`): `2 ≤ C` (the route's chunk sizes are 64…2048), `p < L`, `L, C ≤ 2^51`
(the route: `L ≤ 262144`). The call state is the template's (`callSt x`, native state `x`),
the server holds `L`, `p`, `C`. Each input falls in one of five classes (`NextStepRun`); a class's
oracle is correct at its inputs by `LinGood` (`goodLin`, a box of integer parameters), its
template gives the run (`tpl_sim`), and its return state is read off (`*.ret`, `*.obj`, the
table entry of `end`). -/

/-! ## The contract -/

/-- The inputs the contract covers. -/
def Dom (L p C : Nat) : Prop := 2 ≤ C ∧ p < L ∧ L ≤ 2 ^ 51 ∧ C ≤ 2 ^ 51

/-- The call's number server: `L`, the position, `C`. -/
def callSrv (L p C : Nat) : CSrv := ⟨[F64.ofNat L, F64.ofNat p, F64.ofNat C]⟩

/-- The isolated call state, native state `x`. -/
noncomputable def callSt {S : Type} (x : S) : St S := tpl DCby.s1 0 x []

def kindStr (final : Bool) : List Char := if final then chars!"final" else chars!"drain"

def phaseStr : Phase → List Char
  | .chunk => chars!"chunk"
  | .tail => chars!"tail"
  | .decode => chars!"decode"

/-- A `PrefillStep` object's properties, in the literal's order (writable, enumerable). -/
def stepProps (vs ve : Val) (final batch : Bool) (ph : Phase) : Props :=
  [(.str chars!"start", .data vs true true), (.str chars!"end", .data ve true true),
   (.str chars!"kind", .data (.str (kindStr final)) true true), (.str chars!"snapshot", .data (.bool false) true true),
   (.str chars!"batchYield", .data (.bool batch) true true), (.str chars!"phase", .data (.str (phaseStr ph)) true true)]

/-- **The returned step**: the return state returns a fresh object (allocated at or above the
call's counter) with the properties of step `st`, `batchYield` `b`, its numbers read through `C`. -/
def Returns {S : Type} (t t' : St S) (C : CSrv) (st : PStep) (b : Bool) : Prop :=
  ∃ a vs ve, t'.ctl = .ret (.obj a) ∧ t.next ≤ a ∧
    t'.heap.get a = some (.obj ⟨.ordinary, .obj aObjectProto, stepProps vs ve st.final b st.phase, [], true⟩) ∧
    natAt C vs = some st.start ∧ natAt C ve = some st.stop

def batchOf (L p C : Nat) : Bool := decide (C + 1 < L - p)

/-- **The stage**: parameters `(L, p, C)`. -/
def prefillStage (F : Ffi) : Stage F where
  Par := Nat × Nat × Nat
  Pre q t C := Dom q.1 q.2.1 q.2.2 ∧ (∃ x, t = callSt x) ∧ C = callSrv q.1 q.2.1 q.2.2
  Post q t _ t' C' := Framed (fun _ => False) Eq t t' ∧
    Returns t t' C' (nextStep q.1 q.2.1 q.2.2) (batchOf q.1 q.2.1 q.2.2)

/-! ## The schedule's value per class -/

theorem nextStep_dc {L p C : Nat} (h2 : 2 ≤ C) (h : C ≤ L - p - 1) : nextStep L p C = ⟨p, p + C, false, .chunk⟩ := by
  unfold nextStep phaseOf
  rw [ite_eq_left (by omega), ite_eq_left h, ite_eq_right (by omega), ite_eq_left rfl]

theorem nextStep_dt {L p C : Nat} (h1 : 2 ≤ L - p) (h : L - p - 1 < C) :
    nextStep L p C = ⟨p, L - 1, false, if L - p = 2 then .decode else .tail⟩ := by
  unfold nextStep phaseOf
  rw [ite_eq_left (by omega), ite_eq_right (by omega), show p + (L - p - 1) = L - 1 by omega]
  by_cases h2 : L - p = 2
  · rw [ite_eq_left (by omega), ite_eq_left h2]
  · rw [ite_eq_right (by omega), ite_eq_right h2, ite_eq_right (by simp)]

theorem nextStep_fin {L p C : Nat} (h : L - p = 1) : nextStep L p C = ⟨p, L, true, .decode⟩ := by
  unfold nextStep phaseOf
  rw [ite_eq_right (by omega), ite_eq_left h]

/-! ## Reading numbers -/

theorem ρd_0 (L p C : Nat) (h : L < 2 ^ 53) : ρd L p C 0 = Lin.ie L := Lin.ofNat_ie L h
theorem ρd_1 (L p C : Nat) (h : p < 2 ^ 53) : ρd L p C 1 = Lin.ie p := Lin.ofNat_ie p h
theorem ρd_2 (L p C : Nat) (h : C < 2 ^ 53) : ρd L p C 2 = Lin.ie C := Lin.ofNat_ie C h

/-- The server of a class's return state, at the inputs. -/
abbrev srv3 (S : SSrv) (L p C : Nat) : CSrv := ⟨S.tab.map (SymE.eval (ρd L p C))⟩

end Host.Ts.Sim.Stage.NextStep
