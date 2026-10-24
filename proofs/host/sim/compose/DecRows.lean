import host.sim.compose.Shape
import host.sim.compose.Iter
import host.sim.lin.CoverD
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-! # A decode case's links over the decode rows

The regenerated decode templates' pieces are checked over the decode table's rows
(`host.sim.lin.CoverD`: the iteration's step `decI L T i t1`; the link's variables `m`, the template's
`decM` and the link's derived results), like the
prefill's and the route's pieces. `DLink`: a link of a case's chain between cut families of the
step, with its template's oracle `O` and its checks over the rows it is used at, holding at the
run's iterations (`DecAt L T tk`: the iteration's step `decI L T i (tk (i + 1))` at an iteration before the last two, the
run's prompt length within the context with its budget; `DecAt.get_le`: the quantities the decode results take below
`2 ^ 20`)
wherever its oracles are correct. `DLink.link`: the chain's link (an `IterChainW` field) at every
iteration of the case, from the case's cover (`DecP`). -/

section
variable {F : Ffi}

/-- The run's decode iterations: the step of iteration `i.k` at prompt length `L`, budget `T`, the iteration's
token, before the last two iterations, the prompt and the budget within the context. -/
def DecAt (L T : Nat) (tk : Nat → Nat) (i : Cls.Inst) : Prop :=
  i = decI L T i.k (tk (i.k + 1)) ∧ i.k + 2 < T ∧ L + T ≤ 262144

/-- **The admitted steps' positions, length and budget are below `2 ^ 20`.** -/
theorem DecAt.get_le {L T : Nat} {tk : Nat → Nat} {i : Cls.Inst} (h : DecAt L T tk i) {q : Q}
    (hq : q = .o ∨ q = .e ∨ q = .T ∨ q = .k) : i.get q ≤ 2 ^ 20 := by
  obtain ⟨hi, hk, hctx⟩ := h
  have e : i.get q = (decI L T i.k (tk (i.k + 1))).get q := by rw [← hi]
  rw [e]
  rcases hq with rfl | rfl | rfl | rfl <;> simp only [Inst.get, decI, Nat.reducePow] <;> omega

/-- An admitted step's end position is its offset's successor (`decI`'s one row). -/
theorem DecAt.get_e {L T : Nat} {tk : Nat → Nat} {i : Cls.Inst} (h : DecAt L T tk i) : i.get .e = i.get .o + 1 := by
  obtain ⟨hi, -, -⟩ := h
  rw [hi]; rfl

/-- An admitted step's offset's successor is below `2 ^ 31` (the decode results' `int32` forms). -/
theorem DecAt.o_succ_lt31 {L T : Nat} {tk : Nat → Nat} {i : Cls.Inst} (h : DecAt L T tk i) : i.get .o + 1 < 2 ^ 31 :=
  Nat.lt_of_le_of_lt (Nat.succ_le_succ (h.get_le (Or.inl rfl))) (by decide)

/-- An admitted step's offset's successor is exact in binary64. -/
theorem DecAt.o_succ_lt {L T : Nat} {tk : Nat → Nat} {i : Cls.Inst} (h : DecAt L T tk i) : i.get .o + 1 < 2 ^ 53 :=
  Nat.lt_of_le_of_lt (Nat.succ_le_succ (h.get_le (Or.inl rfl))) (by decide)

/-- **A decode link over the rows `uses`** between the cut families `A`, `B` (at the step and the
iteration's start pair), its template's oracle checked over the rows at its variables `m`, its further
oracles `obls`. -/
structure DLink (Adm : Cls.Inst → Prop) (uses : List Row) (m : List (Nat × Q)) (obls : List Obl)
    (A B : Cls.Inst → SegInst F → ICut F) where
  n : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : ∀ r ∈ uses, ∀ i, InRow r i → OblOk i (⟨m, O⟩ :: obls) → Adm i → ∀ x0, CutStep (A i x0) (B i x0) n

/-- **The link at every iteration of the case** from the case's rows, the link used at all of them,
its further oracles checked there. -/
theorem DLink.link {k : DecKind} {rows uses : List Row} {m : List (Nat × Q)} {obls : List Obl}
    {A B : Cls.Inst → SegInst F → ICut F} {L T : Nat} {tk : Nat → Nat} (lk : DLink (DecAt L T tk) uses m obls A B) (hcov : DecP k rows)
    (huse : ∀ r ∈ rows, r ∈ uses) (hobl : ∀ r ∈ rows, ∀ i, InRow r i → OblOk i obls) (h1 : 1 ≤ L)
    (hctx : L + T ≤ 262144) :
    ∀ i x0, DecSel T L tk k i → CutStep (A (decI L T i (tk (i + 1))) x0) (B (decI L T i (tk (i + 1))) x0) lk.n := by
  rintro i x0 ⟨hs, ht, hne⟩
  obtain ⟨r, hr, hin⟩ := hcov L T i (tk (i + 1)) h1 hctx hs ht hne
  exact lk.ok r (huse r hr) _ hin ⟨obl_of_row hin (lk.chk r (huse r hr)), hobl r hr _ hin⟩ ⟨rfl, hs.2.1, hctx⟩ x0

end

end Host.Ts.Sim.Compose
