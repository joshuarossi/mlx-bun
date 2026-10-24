import host.sim.conv.Merge
import host.sim.Prefill
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Prefill

/-! # A stage call reused at a call site: isolate → stage → merge

One stage template `T` (a checked run of the isolated stage, `StageTpl`) with its frozen contract
(`StageTpl.HoldsZ`) serves every call site whose caller state holds a copy of `T`'s start (`Iso`):

* `call_run`: from the caller's relation at the call, the target runs the stage's `T.n + 1` steps to
  a state related to the merged caller state (`Mer`, `merge`), under the glued map, at the
  valuation `νr` binding the stage's new numbers.
* The same as cut steps (`host.sim.Prefill.CutStep`, generic in the world): `cut_isolate` (0 steps,
  into the stage cut `atCall`), `cut_stage` (`T.n + 1` steps, the frozen contract, to the return
  cut `atRet`), `cut_merge` (0 steps, back to the caller's cut after the call); `cut_call` is their
  composition. A conversion is a cut: the map, the valuation and the context change there.

Everything the caller knows at the call (its related pair) is carried through the stage cuts as a
ghost (`atCall`, `atRet` existentially keep it), so the merge reads the caller's own entries from
the call and the frozen contract. -/

section
variable {F : Ffi} {FR FR0 : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {W W0 : Nat → Option WFrame} {stk : List Frame} {ok : St F.S → SSrv → Bool}
  {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop} {NK : Map → F.S → F.S → F.S → Prop}
  {σ : Map} {θ : Nat → SymE} {rs : List Frame} {wr : List Nat} {s sr : St F.S} {S : SSrv}

/-- The stage's table only grows over its run. -/
theorem _root_.Host.Ts.Sim.Stage.StageTpl.len2 (T : StageTpl F ok) : T.S0.tab.length ≤ T.S2.tab.length :=
  Nat.le_trans (interpS_runOk_len T.run) (interpS_len _ _ _ _ T.last)

/-- **The stage at the call**: isolate, the frozen contract, the stage's end related to the
template's return under the caller frames, with the call's caller pair remembered. -/
theorem stage_at_call (T : StageTpl F ok) (hZ : T.HoldsZ FR0 W0 Kp VBOk NK)
    (hFS : ∀ M x y z, FS σ x y → FR M S.tab.length y z → FR0 (M.after σ) T.S0.tab.length x z)
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St F.S} {C : CSrv}
    (hc : RelB F FR W stk M ν K s S t C) (hi : Iso F FS σ θ K rs T.s0 T.S0 s S)
    (hK : Kp (isoCtx K T.s0 t)) (hν : VBOk (Shift.valuation θ ν)) (hg : Good (Shift.valuation θ ν) T.S0.oracle)
    (hroom : t.next - T.s0.next < Sim.bound) :
    ∃ M2 t' C', runC F (T.n + 1) t C = some (t', C') ∧ Ext (M.after σ) M2 T.S0.tab.length ∧
      RelB F FR0 W0 (rs.map M.frame ++ stk) M2 (Shift.valuation θ ν) (isoCtx K T.s0 t) T.s2 T.S2 t' C' ∧
      CSrv.Le C C' ∧ (∀ a, CallerOnly (M.after σ) T.s0 t a → t'.heap.get a = t.heap.get a) ∧
      NK (M.after σ) T.s0.ffi t.ffi t'.ffi := by
  obtain ⟨e, hiso⟩ := isolate_under (W0 := W0) (hFS M) hc hi hg hroom
  obtain ⟨M2, t2, C2, hrun, hext, h2, hle, hfz, hnk⟩ := hZ _ _ _ _ C (rs.map M.frame ++ stk) hK hν hiso
  refine ⟨M2, under t2 (rs.map M.frame ++ stk), C2, by rw [e]; exact hrun, hext, RelB.ofUnder h2 _, hle,
    fun a ha => hfz a ⟨ha.1, ha.2⟩, hnk⟩

/-- **A stage call reused at a call site.** From the caller's relation at the call, the stage's
`T.n + 1` target steps reach a target related to the merged caller state `sr`, under the glued
map, at `νr`, with the caller's frames and context; given the merge's native law `hFM` and the
valuation facts of the new entries `es`. -/
theorem call_run (T : StageTpl F ok) (hZ : T.HoldsZ FR0 W0 Kp VBOk NK)
    (hFS : ∀ M x y z, FS σ x y → FR M S.tab.length y z → FR0 (M.after σ) T.S0.tab.length x z)
    (hfoot : StageFoot wr T.s0 T.s2) (hmer : Mer σ (σ.res T.S0.tab.length S.tab.length) rs wr T.s0 s T.s2 sr)
    {es : List SymE} (hesl : es.length = T.S2.tab.length - T.S0.tab.length) {or : List Ans}
    {M : Map} {ν νr : Nat → F64} {K : Ctx} {t : St F.S} {C : CSrv}
    (hc : RelB F FR W stk M ν K s S t C) (hi : Iso F FS σ θ K rs T.s0 T.S0 s S)
    (hK : Kp (isoCtx K T.s0 t)) (hν : VBOk (Shift.valuation θ ν)) (hg : Good (Shift.valuation θ ν) T.S0.oracle)
    (hroom : t.next - T.s0.next < Sim.bound)
    (hνS : ∀ e ∈ S.tab, e.eval νr = e.eval ν)
    (hes : ∀ j e, nth? es j = some e → ∃ e2, nth? T.S2.tab (T.S0.tab.length + j) = some e2 ∧
      e.eval νr = e2.eval (Shift.valuation θ ν))
    (hgood : Good νr or)
    (hFM : ∀ M2 t' C', Ext (M.after σ) M2 T.S0.tab.length →
      RelB F FR0 W0 (rs.map M.frame ++ stk) M2 (Shift.valuation θ ν) (isoCtx K T.s0 t) T.s2 T.S2 t' C' →
      NK (M.after σ) T.s0.ffi t.ffi t'.ffi →
      FR (M.glue M2 S.tab.length T.S0.tab.length) (S.tab.length + es.length) sr.ffi t'.ffi) :
    ∃ M2 t' C', runC F (T.n + 1) t C = some (t', C') ∧
      RelB F FR W stk (M.glue M2 S.tab.length T.S0.tab.length) νr K sr ⟨S.tab ++ es, or⟩ t' C' := by
  obtain ⟨M2, t', C', hrun, hext, h2, hle, hfz, hnk⟩ := stage_at_call T hZ hFS hc hi hK hν hg hroom
  refine ⟨M2, t', C', hrun, merge ⟨hc, hi, h2, hext, T.len2, hfz, hle, hfoot, hmer⟩ hesl hνS hes hgood
    (hFM M2 t' C' hext h2 hnk)⟩

end

/-! ## As cut steps -/

section
variable {F : Ffi}

/-- `RelB` under the native relation `FR`, frames `W`, stack base `stk`, with a predicate `Q` of the
pair: the relation family of a caller's cut. -/
def relB (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame)
    (Q : SegInst F → Prop) : SRel F :=
  fun x s S => RelB F FR W stk x.M x.ν x.K s S x.t x.C ∧ Q x

/-- **The stage cut at a call** (`T`'s start): some caller pair `c` at the call state `(s, S)` with
`Q`, and the stage's pair its isolation (`isolate`). The caller's pair is a ghost of the cut. -/
def atCall (F : Ffi) (FR FR0 : Map → Nat → F.S → F.S → Prop) (W W0 : Nat → Option WFrame) (stk : List Frame)
    (Q : SegInst F → Prop) (σ : Map) (θ : Nat → SymE) (rs : List Frame) (s : St F.S) (S : SSrv) (S0 : SSrv) :
    SRel F :=
  fun y s0 _ => ∃ c : SegInst F, RelB F FR W stk c.M c.ν c.K s S c.t c.C ∧ Q c ∧
    y = ⟨c.M.after σ, Shift.valuation θ c.ν, isoCtx c.K s0 c.t, c.t, c.C⟩ ∧
    RelB F FR0 W0 (rs.map c.M.frame ++ stk) y.M y.ν y.K s0 S0 y.t y.C

/-- **The stage's return cut** (`T`'s return): the caller pair at the call, the stage's pair at
the return related to `s2` under the caller frames, an extension of the call's isolated map, the
caller-only entries as at the call, the native frame `NK`. -/
def atRet (F : Ffi) (FR FR0 : Map → Nat → F.S → F.S → Prop) (W W0 : Nat → Option WFrame) (stk : List Frame)
    (Q : SegInst F → Prop) (σ : Map) (θ : Nat → SymE) (rs : List Frame) (s : St F.S) (S : SSrv)
    (s0 : St F.S) (S0 S2 : SSrv) (NK : Map → F.S → F.S → F.S → Prop) : SRel F :=
  fun y s2 _ => ∃ c : SegInst F, RelB F FR W stk c.M c.ν c.K s S c.t c.C ∧ Q c ∧
    y.ν = Shift.valuation θ c.ν ∧ y.K = isoCtx c.K s0 c.t ∧ Ext (c.M.after σ) y.M S0.tab.length ∧
    RelB F FR0 W0 (rs.map c.M.frame ++ stk) y.M y.ν y.K s2 S2 y.t y.C ∧ CSrv.Le c.C y.C ∧
    (∀ a, CallerOnly (c.M.after σ) s0 c.t a → y.t.heap.get a = c.t.heap.get a) ∧
    NK (c.M.after σ) s0.ffi c.t.ffi y.t.ffi

variable {FR FR0 : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {W W0 : Nat → Option WFrame} {stk : List Frame} {ok : St F.S → SSrv → Bool}
  {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop} {NK : Map → F.S → F.S → F.S → Prop}
  {σ : Map} {θ : Nat → SymE} {rs : List Frame} {wr : List Nat} {s sr : St F.S} {tab : List SymE}
  {Q : SegInst F → Prop}

/-- **Isolate as a cut step** (no target step): the caller's cut at the call into the stage's
start cut, the caller's pair and bookkeeping kept as the cut's ghost. The isolation's side
conditions (`Iso`, the native law, the oracle at the new valuation, the room) are the
conversion's checks. -/
theorem cut_isolate (T : StageTpl F ok) {B : SegInst F → Prop}
    (hiso : ∀ c : SegInst F, Q c → B c → Iso F FS σ θ c.K rs T.s0 T.S0 s ⟨tab, []⟩)
    (hFS : ∀ M x y z, FS σ x y → FR M tab.length y z → FR0 (M.after σ) T.S0.tab.length x z)
    (hg : ∀ c : SegInst F, Q c → B c → Good (Shift.valuation θ c.ν) T.S0.oracle)
    (hroom : ∀ c : SegInst F, Q c → B c → c.t.next - T.s0.next < Sim.bound) :
    CutStep ((Cut.mk s tab (relB F FR W stk Q)).with B)
      ((Cut.mk T.s0 T.S0.tab (atCall F FR FR0 W W0 stk (fun c => Q c ∧ B c) σ θ rs s ⟨tab, []⟩ T.S0)).with
        fun _ => True) 0 := by
  rintro t C ⟨c, rfl, rfl, ⟨hc, hq⟩, hb⟩
  have h0 := isolate (W0 := W0) (hFS c.M) hc (hiso c hq hb) (hg c hq hb) (hroom c hq hb)
  exact ⟨c.t, c.C, rfl, ⟨c.M.after σ, Shift.valuation θ c.ν, isoCtx c.K T.s0 c.t, c.t, c.C⟩, rfl, rfl,
    ⟨c, hc, ⟨hq, hb⟩, rfl, h0⟩, trivial⟩

/-- **The stage as a cut step**: the frozen contract takes the stage's start cut to its return
cut in `T.n + 1` target steps, for any caller ghost `Q`. -/
theorem cut_stage (T : StageTpl F ok) (hZ : T.HoldsZ FR0 W0 Kp VBOk NK)
    (hKν : ∀ c : SegInst F, Q c → Kp (isoCtx c.K T.s0 c.t) ∧ VBOk (Shift.valuation θ c.ν)) :
    CutStep ((Cut.mk T.s0 T.S0.tab (atCall F FR FR0 W W0 stk Q σ θ rs s ⟨tab, []⟩ T.S0)).with fun _ => True)
      ((Cut.mk T.s2 T.S2.tab (atRet F FR FR0 W W0 stk Q σ θ rs s ⟨tab, []⟩ T.s0 T.S0 T.S2 NK)).with fun _ => True)
      (T.n + 1) := by
  rintro t C ⟨y, rfl, rfl, ⟨c, hc, hq, rfl, h0⟩, -⟩
  obtain ⟨e, hiso⟩ := RelB.strip h0
  obtain ⟨hK, hν⟩ := hKν c hq
  obtain ⟨M2, t2, C2, hrun, hext, h2, hle, hfz, hnk⟩ := hZ _ _ _ _ c.C (rs.map c.M.frame ++ stk) hK hν hiso
  have e' : c.t = under { c.t with stack := T.s0.stack.map (c.M.after σ).frame } (rs.map c.M.frame ++ stk) := e
  refine ⟨under t2 (rs.map c.M.frame ++ stk), C2, by rw [e']; exact hrun,
    ⟨M2, Shift.valuation θ c.ν, isoCtx c.K T.s0 c.t, under t2 (rs.map c.M.frame ++ stk), C2⟩, rfl, rfl,
    ⟨c, hc, hq, rfl, rfl, hext, RelB.ofUnder h2 _, hle, fun a ha => hfz a ⟨ha.1, ha.2⟩, hnk⟩, trivial⟩

/-- **Merge as a cut step** (no target step): the stage's return cut into the caller's cut after
the call, at the merged state `sr` with the new table entries `es` and the valuation `νr ν`; the
caller's family `Q'` and bookkeeping `B'` after the call follow from the ghost (`hQ`). -/
theorem cut_merge (T : StageTpl F ok) (hfoot : StageFoot wr T.s0 T.s2)
    (hmer : Mer σ (σ.res T.S0.tab.length tab.length) rs wr T.s0 s T.s2 sr)
    {es : List SymE} (hesl : es.length = T.S2.tab.length - T.S0.tab.length)
    (νr : (Nat → F64) → Nat → F64) {Q' B' : SegInst F → Prop}
    (hiso : ∀ c : SegInst F, Q c → Iso F FS σ θ c.K rs T.s0 T.S0 s ⟨tab, []⟩)
    (hνS : ∀ ν, ∀ e ∈ tab, e.eval (νr ν) = e.eval ν)
    (hes : ∀ ν j e, nth? es j = some e → ∃ e2, nth? T.S2.tab (T.S0.tab.length + j) = some e2 ∧
      e.eval (νr ν) = e2.eval (Shift.valuation θ ν))
    (hFM : ∀ (c y : SegInst F), Q c → Ext (c.M.after σ) y.M T.S0.tab.length →
      RelB F FR0 W0 (rs.map c.M.frame ++ stk) y.M (Shift.valuation θ c.ν) (isoCtx c.K T.s0 c.t) T.s2 T.S2 y.t y.C →
      NK (c.M.after σ) T.s0.ffi c.t.ffi y.t.ffi →
      FR (c.M.glue y.M tab.length T.S0.tab.length) (tab.length + es.length) sr.ffi y.t.ffi)
    (hQ : ∀ (c y : SegInst F), Q c → CSrv.Le c.C y.C → NK (c.M.after σ) T.s0.ffi c.t.ffi y.t.ffi →
      RelB F FR W stk (c.M.glue y.M tab.length T.S0.tab.length) (νr c.ν) c.K sr ⟨tab ++ es, []⟩ y.t y.C →
      Q' ⟨c.M.glue y.M tab.length T.S0.tab.length, νr c.ν, c.K, y.t, y.C⟩ ∧
        B' ⟨c.M.glue y.M tab.length T.S0.tab.length, νr c.ν, c.K, y.t, y.C⟩) :
    CutStep ((Cut.mk T.s2 T.S2.tab (atRet F FR FR0 W W0 stk Q σ θ rs s ⟨tab, []⟩ T.s0 T.S0 T.S2 NK)).with
        fun _ => True)
      ((Cut.mk sr (tab ++ es) (relB F FR W stk Q')).with B') 0 := by
  rintro t C ⟨y, rfl, rfl, ⟨c, hc, hq, hyν, hyK, hext, h2, hle, hfz, hnk⟩, -⟩
  have h2' : RelB F FR0 W0 (rs.map c.M.frame ++ stk) y.M (Shift.valuation θ c.ν) (isoCtx c.K T.s0 c.t)
      T.s2 T.S2 y.t y.C := by rw [← hyν, ← hyK]; exact h2
  have hm := merge (or := []) ⟨hc, hiso c hq, h2', hext, T.len2, hfz, hle, hfoot, hmer⟩ hesl (hνS c.ν) (hes c.ν)
    (fun q hq => nomatch hq) (hFM c y hq hext h2' hnk)
  obtain ⟨hq', hb'⟩ := hQ c y hq hle hnk hm
  exact ⟨y.t, y.C, rfl, ⟨c.M.glue y.M tab.length T.S0.tab.length, νr c.ν, c.K, y.t, y.C⟩, rfl, rfl, ⟨hm, hq'⟩, hb'⟩

/-- **A stage call at a call site as one cut step**: isolate (0) ; the stage (`T.n + 1`) ;
merge (0), composed with `CutStep.trans`. -/
theorem cut_call (T : StageTpl F ok) (hZ : T.HoldsZ FR0 W0 Kp VBOk NK) {B : SegInst F → Prop}
    (hiso : ∀ c : SegInst F, Q c → B c → Iso F FS σ θ c.K rs T.s0 T.S0 s ⟨tab, []⟩)
    (hFS : ∀ M x y z, FS σ x y → FR M tab.length y z → FR0 (M.after σ) T.S0.tab.length x z)
    (hg : ∀ c : SegInst F, Q c → B c → Good (Shift.valuation θ c.ν) T.S0.oracle)
    (hroom : ∀ c : SegInst F, Q c → B c → c.t.next - T.s0.next < Sim.bound)
    (hKν : ∀ c : SegInst F, Q c → B c → Kp (isoCtx c.K T.s0 c.t) ∧ VBOk (Shift.valuation θ c.ν))
    (hfoot : StageFoot wr T.s0 T.s2)
    (hmer : Mer σ (σ.res T.S0.tab.length tab.length) rs wr T.s0 s T.s2 sr)
    {es : List SymE} (hesl : es.length = T.S2.tab.length - T.S0.tab.length)
    (νr : (Nat → F64) → Nat → F64) {Q' B' : SegInst F → Prop}
    (hνS : ∀ ν, ∀ e ∈ tab, e.eval (νr ν) = e.eval ν)
    (hes : ∀ ν j e, nth? es j = some e → ∃ e2, nth? T.S2.tab (T.S0.tab.length + j) = some e2 ∧
      e.eval (νr ν) = e2.eval (Shift.valuation θ ν))
    (hFM : ∀ (c y : SegInst F), Q c ∧ B c → Ext (c.M.after σ) y.M T.S0.tab.length →
      RelB F FR0 W0 (rs.map c.M.frame ++ stk) y.M (Shift.valuation θ c.ν) (isoCtx c.K T.s0 c.t) T.s2 T.S2 y.t y.C →
      NK (c.M.after σ) T.s0.ffi c.t.ffi y.t.ffi →
      FR (c.M.glue y.M tab.length T.S0.tab.length) (tab.length + es.length) sr.ffi y.t.ffi)
    (hQ : ∀ (c y : SegInst F), Q c ∧ B c → CSrv.Le c.C y.C → NK (c.M.after σ) T.s0.ffi c.t.ffi y.t.ffi →
      RelB F FR W stk (c.M.glue y.M tab.length T.S0.tab.length) (νr c.ν) c.K sr ⟨tab ++ es, []⟩ y.t y.C →
      Q' ⟨c.M.glue y.M tab.length T.S0.tab.length, νr c.ν, c.K, y.t, y.C⟩ ∧
        B' ⟨c.M.glue y.M tab.length T.S0.tab.length, νr c.ν, c.K, y.t, y.C⟩) :
    CutStep ((Cut.mk s tab (relB F FR W stk Q)).with B) ((Cut.mk sr (tab ++ es) (relB F FR W stk Q')).with B')
      (0 + (T.n + 1) + 0) :=
  ((cut_isolate (W0 := W0) T hiso hFS hg hroom).trans
    (cut_stage (Q := fun c => Q c ∧ B c) T hZ (fun c hc => hKν c hc.1 hc.2))).trans
    (cut_merge (Q := fun c => Q c ∧ B c) T hfoot hmer hesl νr (fun c hc => hiso c hc.1 hc.2) hνS hes hFM hQ)

end

end Host.Ts.Sim.Conv
