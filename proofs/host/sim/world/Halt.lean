import host.sim.world.LoopSeg
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The decode loop's halts over a world

`DecodeAddrHalt.lean` (and `SegFinal.lean`, its instance without frames) over a world `Wd`: a
halting chain under `relQW` (`HaltSegW`, the laws `haltLawsW`), from the loop template itself at a
cut (`cut_haltW`) or from the final template start with the look-ahead reference
(`finalStartW`, `last_haltW`), with the obligations `CutGStepW`, `LastGStepW`; the checked halting
cases split at the epilogue's spread (`ExitCaseW`, `ExitCaseW.toSeg`).

A fact of a halting chain's end relation at maps fixing the loop's fixed addresses (`HaltFinW`)
holds of the halted target (`cut_haltW`, `last_haltW`); the EOS halts' fact is
`generation.stats.finishReason` `"stop"` (`stopFin`, `HaltStopW`). Under any frames `W` a string
read through the `generation` binding and two own properties transfers when the cell and the two
objects carry no frame of `W` (`RelB.ownW_map`, `RelB.statsFieldW_str`), so a halting chain
supplies only facts of its template's end state (`HaltStopSrc`, `HaltStopSrc.toW`). -/

/-- The laws of a halting chain at `A` over `Wd` (`haltLaws`). -/
def haltLawsW (Wd : World) (A : Addr) : SegLaws Wd.F where
  KR K K' := K'.lo = K.lo ∧ K'.hi = K.hi ∧ K'.fr A.emit = K.fr A.emit
  TR t t' := Wd.Grows t t'
  krefl _ := ⟨rfl, rfl, rfl⟩
  ktrans h1 h2 := ⟨h2.1.trans h1.1, h2.2.1.trans h1.2.1, h2.2.2.trans h1.2.2⟩
  trefl t := World.Grows.refl Wd t
  ttrans h1 h2 := World.Grows.trans Wd h1 h2

/-- **A halting chain** at `A` over `Wd` under the frames `W` (`HaltSegA`). -/
structure HaltSegW (Wd : World) (A : Addr) (W : Nat → Option WFrame) (P : Wd.Par) (r : List NumV)
    (s0 st0 : St Wd.F.S) (tab1 : List SymE) (xs : List Val) where
  S0 : SSrv
  tab : S0.tab = tab1
  QA : (Nat → F64) → Ctx → Prop
  case : SegCase (haltLawsW Wd A) (relQW Wd.F (Wd.R P r) W QA) st0 S0 .halt
  QF : (Nat → F64) → Ctx → Prop
  rend : ∀ x s S, case.Rend x s S → relQW Wd.F (Wd.R P r) W QF x s S
  emitG : ∃ o, case.sF.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ xs)
  cell : case.sF.cell? A.cE = some (some (.obj A.emit))

/-- **A fact of a halting chain's end** `Fin`: at its end relation, under a map fixing the
addresses `fixA`, the target satisfies `Fin`. -/
def HaltFinW {Wd : World} {A : Addr} {W : Nat → Option WFrame} {P : Wd.Par} {r : List NumV} {s0 st0 : St Wd.F.S}
    {tab1 : List SymE} {xs : List Val} (hs : HaltSegW Wd A W P r s0 st0 tab1 xs) (fixA : List Nat)
    (Fin : St Wd.F.S → Prop) : Prop :=
  ∀ x, hs.case.Rend x hs.case.sF hs.case.SF → (∀ a ∈ fixA, x.M.a a = a) → Fin x.t

/-- The EOS stop's fact: `generation.stats.finishReason` is `"stop"`. -/
def stopFin {S : Type} (env : Env) (t : St S) : Prop :=
  statsFieldW t env chars!"finishReason" = some (.str chars!"stop")

/-- **The finish reason of a halting chain** (`HaltFinW` at `stopFin`): at its end relation, under a
map fixing `fixA` (with the `generation` cell), the target's `generation.stats.finishReason` is
`"stop"` (from the template's end state and the relation, `HaltFinW.ofRel`). -/
abbrev HaltStopW {Wd : World} {A : Addr} {W : Nat → Option WFrame} {P : Wd.Par} {r : List NumV} {s0 st0 : St Wd.F.S}
    {tab1 : List SymE} {xs : List Val} (hs : HaltSegW Wd A W P r s0 st0 tab1 xs) (fixA : List Nat) (env : Env) : Prop :=
  HaltFinW hs fixA (stopFin env)

/-! ## The finish reason through the relation under frames -/

section Transfer
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- At an address carrying no frame of `W`, the target's object at the image has the image's
properties (the image, or a framed array, `FramedObj`). -/
theorem RelB.obj?_props (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o)
    (hw : W a = none) : ∃ o', t.obj? (M.a a) = some o' ∧ o'.props = M.props o.props := by
  have hs := h.slot (.inl hw) (obj?_iff.1 ho)
  cases hfr : K.fr a with
  | none => exact ⟨M.obj o, obj?_iff.2 ((SlotOK.none_iff hfr).1 hs), rfl⟩
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨o1, o', ho1, ht, xs, _, rfl⟩ := (SlotOK.some_iff hfr).1 hs
    cases ho1
    exact ⟨_, obj?_iff.2 ht, rfl⟩

/-- At a present address carrying no frame of `W` and holding no object, the target holds none. -/
theorem RelB.obj?_noneW (h : RelB F FR W stk M ν K s S t C) {a : Nat} (hp : Present s a) (ho : s.obj? a = none)
    (hw : W a = none) : t.obj? (M.a a) = none := by
  obtain ⟨hh, hg⟩ := Present.get hp
  cases hh with
  | obj o => rw [obj?_iff.2 hg] at ho; cases ho
  | cell v =>
    have hs := h.slot (.inl hw) hg
    cases hfr : K.fr a with
    | none =>
      have ht : t.heap.get (M.a a) = some (M.hobj (.cell v)) := (SlotOK.none_iff hfr).1 hs
      unfold St.obj?
      rw [ht]
      rfl
    | some p =>
      obtain ⟨pre, pre'⟩ := p
      obtain ⟨o1, o', ho1, -, -⟩ := (SlotOK.some_iff hfr).1 hs
      cases ho1

/-- **An own data property under the frames**: at a present address carrying no frame of `W`. -/
theorem RelB.ownW_map (h : RelB F FR W stk M ν K s S t C) {a : Nat} (hp : Present s a) (hw : W a = none)
    (k : List Char) : ownW t (.obj (M.a a)) k = (ownW s (.obj a) k).map M.val := by
  show (t.obj? (M.a a)).bind (fun o => (findProp (.str k) o.props).bind Host.Load.Extract.data) =
    ((s.obj? a).bind (fun o => (findProp (.str k) o.props).bind Host.Load.Extract.data)).map M.val
  cases ho : s.obj? a with
  | none => rw [h.obj?_noneW hp ho hw]; rfl
  | some o =>
    obtain ⟨o', ht, hps⟩ := h.obj?_props ho hw
    rw [ht]
    simp only [Option.bind_some]
    rw [hps]
    have e : findProp (.str k) (M.props o.props) = (findProp (.str k) o.props).map M.prop :=
      findProp_map h.inj (show Supp.key (Present s) S.tab.length (.str k) from trivial) (h.obj?_supp ho).2.2.1
    rw [e]
    cases findProp (.str k) o.props with
    | none => rfl
    | some p => cases p <;> rfl

/-- An own data property's value is supported. -/
theorem RelB.ownW_supp (h : RelB F FR W stk M ν K s S t C) {a : Nat} {k : List Char} {w : Val}
    (hw : ownW s (.obj a) k = some w) : Supp.val (Present s) S.tab.length w := by
  change (s.obj? a).bind (fun o => (findProp (.str k) o.props).bind Host.Load.Extract.data) = some w at hw
  cases ho : s.obj? a with
  | none => rw [ho] at hw; cases hw
  | some o =>
    rw [ho] at hw
    simp only [Option.bind_some] at hw
    cases hf : findProp (.str k) o.props with
    | none => rw [hf] at hw; cases hw
    | some p =>
      rw [hf] at hw
      have hp := findProp_supp (h.obj?_supp ho).2.2.1 hf
      cases p with
      | data v _ _ => cases hw; exact hp
      | acc _ _ _ => cases hw

/-- **The `generation.stats` string under the frames**: with the `generation` cell fixed by the map
and the cell, the generation object and its `stats` object carrying no frame of `W`, a string the
source reads at `generation.stats.<key>` the target reads too. -/
theorem RelB.statsFieldW_str (h : RelB F FR W stk M ν K s S t C) {env : Env} {cG g w : Nat} {key x : List Char}
    (hl : lookupEnv chars!"generation" env = some cG) (hfa : M.a cG = cG) (hwc : W cG = none)
    (hc : s.cell? cG = some (some (.obj g))) (hwg : W g = none)
    (hst : ownW s (.obj g) chars!"stats" = some (.obj w)) (hww : W w = none)
    (hk : ownW s (.obj w) key = some (.str x)) : statsFieldW t env key = some (.str x) := by
  have hct : t.cell? cG = some (some (.obj (M.a g))) := by
    have := h.cell? hc (.inl hwc); rw [hfa] at this; exact this
  have hpg : Present s g := h.cell?_supp hc
  have hpw : Present s w := h.ownW_supp hst
  have h1 : ownW t (.obj (M.a g)) chars!"stats" = some (.obj (M.a w)) := by
    rw [h.ownW_map hpg hwg, hst]; rfl
  have h2 : ownW t (.obj (M.a w)) key = some (.str x) := by
    rw [h.ownW_map hpw hww, hk]; rfl
  have hb : bindingOf t env chars!"generation" = some (.obj (M.a g)) := by
    unfold bindingOf; rw [hl, Option.bind_some, hct]; rfl
  unfold statsFieldW
  rw [hb]
  show (ownW t (.obj (M.a g)) chars!"stats").bind (fun stats => ownW t stats key) = _
  rw [h1]
  exact h2

end Transfer

/-- **What a halting chain supplies for its finish reason**: facts of the template's end state
only. The `generation` binding's cell (`A.gen`, unframed by `W`) holds the generation object `g`,
whose own `stats` is the object `w`, whose own `finishReason` is `"stop"`; neither object carries
a frame of `W`. (Kernel checks of the template's end state and of `W`.) -/
def HaltStopSrc {Wd : World} {A : Addr} {W : Nat → Option WFrame} {P : Wd.Par} {r : List NumV} {s0 st0 : St Wd.F.S}
    {tab1 : List SymE} {xs : List Val} (hs : HaltSegW Wd A W P r s0 st0 tab1 xs) : Prop :=
  W A.gen = none ∧ ∃ g w, hs.case.sF.cell? A.gen = some (some (.obj g)) ∧ W g = none ∧
    ownW hs.case.sF (.obj g) chars!"stats" = some (.obj w) ∧ W w = none ∧
    ownW hs.case.sF (.obj w) chars!"finishReason" = some (.str chars!"stop")

/-- **The finish reason of a halting chain from its template's end state** (any world, any
frames): `HaltStopW` holds when the loop's fixed addresses include the `generation` cell and the
entry environment binds `generation` there. -/
theorem HaltStopSrc.toW {Wd : World} {A : Addr} {W : Nat → Option WFrame} {P : Wd.Par} {r : List NumV}
    {s0 st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val} {hs : HaltSegW Wd A W P r s0 st0 tab1 xs}
    {fixA : List Nat} {env : Env} (h : HaltStopSrc hs) (hgf : A.gen ∈ fixA)
    (hgen : lookupEnv chars!"generation" env = some A.gen) : HaltStopW hs fixA env := by
  intro x hx hfix
  obtain ⟨hwc, g, w, hc, hwg, hst, hww, hk⟩ := h
  exact (hs.rend x _ _ hx).1.statsFieldW_str hgen (hfix _ hgf) hwc hc hwg hst hww hk

section Halt
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {G : St Wd.F.S → CSrv → Prop}
  {P : Wd.Par} {W : Nat → Option WFrame} {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE}
  {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat}

/-- The obligation of a halting chain at a cut over `Wd` (`CutGStepA`). -/
def CutGStepW (A : Addr) (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (P : Wd.Par) (W : Nat → Option WFrame)
    (Fr : LoopFramesA A) (fixA : List Nat) {s0 : St Wd.F.S} {tab0 : List SymE} {toks : List NumV} {i : Nat}
    (hs : HaltSegW Wd A W P (toks.drop i) s0 s0 tab0 []) (V : LoopVals) (G : St Wd.F.S → CSrv → Prop) : Prop :=
  ∀ (nx : Nat) (M : Map) (K : Ctx) (t : St Wd.F.S) (C : CSrv) (xF : SegInst Wd.F),
    Gx i M t C → (∀ a ∈ fixA, M.a a = a) →
    RelF Wd.F (Wd.R P (toks.drop i)) W M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
    runC Wd.F hs.case.n t C = some (xF.t, xF.C) → Wd.Grows t xF.t →
    Ext M xF.M tab0.length → xF.ν = V i nx → xF.K.lo = Wd.lo P → xF.K.hi = Wd.E P → xF.K.fr A.emit = K.fr A.emit →
    hs.case.Rend xF hs.case.sF hs.case.SF → G xF.t xF.C

/-- The halt of a chain from a related start: the halted end pair, its map extending the start's,
its context keeping the band and the `emitted` frame. -/
theorem HaltSegW.halt {r : List NumV} {st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val}
    (hs : HaltSegW Wd A W P r s0 st0 tab1 xs) {x : SegInst Wd.F}
    (h : relQW Wd.F (Wd.R P r) W hs.QA x st0 hs.S0) :
    ∃ x1, x.Step (haltLawsW Wd A) hs.case.n hs.S0.tab.length x1 ∧ hs.case.Rend x1 hs.case.sF hs.case.SF ∧
      (∃ v, x1.t.ctl = .halt (.normal v)) :=
  let ⟨x1, hst, hend, hv, _⟩ := seg_halt hs.case h
  ⟨x1, hst, hend, hv⟩

/-- **A halt at the cut of iteration `i`** over `Wd` (`cut_haltA`), with the finish reason when
the chain gives it. -/
theorem cut_haltW {i : Nat} {t : St Wd.F.S} {C : CSrv} {env : Env} {nm : Name}
    (hs : HaltSegW Wd A W P (toks.drop i) s0 s0 tab0 []) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hinv : LoopInvW Wd A Gx (relW Wd P W) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C)
    (hgood : ∀ nx, nx ≤ 2 ^ 20 → Good (V i nx) hs.S0.oracle)
    (hQA : ∀ nx (K : Ctx), nx ≤ 2 ^ 20 → (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P →
      K.hi = Wd.E P → hs.QA (V i nx) K)
    (henv : lookupEnv nm env = some A.cE) (hG : CutGStepW A Gx P W Fr fixA hs V G) :
    ∃ tF CF v, runC Wd.F hs.case.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (elementsW tF) = some (E0 ++ (toks.take (i - 1)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∀ Fin, HaltFinW hs fixA Fin → Fin tF := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, htokM, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have h1 : RelF Wd.F (Wd.R P (toks.drop i)) W M (V i nx) K s0 hs.S0 t C :=
    h.srvSwap hs.tab ⟨fun j e he => h.srv.num j e (by rw [hs.tab] at he; exact he), hgood nx hnx⟩
  have hKfr : ∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs := fun a => by
    rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a
  obtain ⟨x1, hst, hend, ⟨v, hv⟩⟩ := hs.halt (x := ⟨M, V i nx, K, t, C⟩) ⟨h1, hQA nx K hnx hKfr hlo hhi⟩
  obtain ⟨hF, -⟩ := hs.rend x1 _ _ hend
  have hext : Ext M x1.M tab0.length := by rw [← hs.tab]; exact hst.ext
  have hMa : x1.M.a = M.a := hext.a
  obtain ⟨hklo, hkhi, hke⟩ := hst.kr
  refine ⟨x1.t, x1.C, v, hst.run, hv, ?_, hst.le, ?_,
    fun Fin hfin => hfin x1 hend fun a ha => by rw [hMa]; exact hfix a ha⟩
  · have hk : x1.K.fr A.emit = some (arrOf s0 A.emit, E0 ++ (toks.take (i - 1)).map Val.num) := by
      rw [hke, hfr, frA_emit]
    obtain ⟨o, hg, hkind⟩ := hs.emitG
    refine (hF.emittedW henv hs.cell (by rw [hMa]; exact hfix _ hcE) (by rw [hMa]; exact hfix _ hb) hk hg hkind
      hwc hwe).trans ?_
    simp [Map.vals]
  · exact hG nx M K t C x1 hGx hfix h hKfr hlo hhi hst.run hst.tr hext hst.val (hklo.trans hlo) (hkhi.trans hhi)
      hke hend

/-- The obligation of a halting chain from the final template start over `Wd` (`LastGStepA`). -/
def LastGStepW (A : Addr) (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (P : Wd.Par) (W : Nat → Option WFrame)
    (Fr : LoopFramesA A) (fixA : List Nat) {s0 : St Wd.F.S} {tab0 : List SymE} {toks : List NumV} {T : Nat}
    {xs : List Val}
    (hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs)
    (V : LoopVals) (tk : Nat → Nat) (G : St Wd.F.S → CSrv → Prop) : Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St Wd.F.S) (C : CSrv) (xF : SegInst Wd.F),
    Gx (T - 2) M t C → (∀ a ∈ fixA, M.a a = a) →
    RelF Wd.F (Wd.R P (toks.drop (T - 2))) W M (V (T - 2) nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
    runC Wd.F hs.case.n t C = some (xF.t, xF.C) → Wd.Grows t xF.t →
    Ext (M.setNum tab0.length toks[T - 2]) xF.M (tab0.length + 1) → xF.ν = V (T - 2) (tk T) →
    xF.K.lo = Wd.lo P → xF.K.hi = Wd.E P → xF.K.fr A.emit = K.fr A.emit →
    hs.case.Rend xF hs.case.sF hs.case.SF → G xF.t xF.C

/-- **A halt from the final template start** over `Wd` (`last_haltA`), with the finish reason when
the chain gives it. -/
theorem last_haltW {T : Nat} {t : St Wd.F.S} {C : CSrv} {env : Env} {nm : Name} {ks : List Nat}
    (st : LoopStartW Wd A P s0 tab0) (hks : ks = [A.tok] ∨ ks = [A.tok, tab0.length])
    (hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      (ks.map fun k => .num (.ref k)))
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hupd : ∀ nx, upd (V (T - 2) nx) A.nxt (F64.ofNat (tk T)) = V (T - 2) (tk T))
    (hinv : LoopInvW Wd A Gx (relW Wd P W) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) hs.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
      hs.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE) (hG : LastGStepW A Gx P W Fr fixA hs V tk G) :
    ∃ tF CF v, runC Wd.F hs.case.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (elementsW tF) = some (E0 ++ (toks.take (T - 3 + ks.length)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∀ Fin, HaltFinW hs fixA Fin → Fin tF := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, htokM, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have hT1 : T - 2 + 1 = T - 1 := by omega
  have hi : T - 2 < toks.length := by omega
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 2 + 1) := List.drop_eq_getElem_cons hi
  have hT2 : T - 2 + 2 = T := by omega
  have hx : C.val toks[T - 2] = some (F64.ofNat (tk T)) := by
    have := hvals (T - 2) hi; rw [hT2] at this; exact this
  -- the look-ahead reference
  have h1 := h.extendVar' (Wd.laws _ _) hfrN (fun q hq => by cases hq) hx
  have hf : Wd.R P (toks.drop (T - 2 + 1)) (M.setNum tab0.length toks[T - 2]) (tab0.length + 1)
      (Wd.pushTok s0.ffi tab0.length) t.ffi := by
    have := h.ffi
    rw [hdrop] at this
    exact Wd.addToken this
  have h2 := h1.withSrcFfi (FR' := Wd.R P (toks.drop (T - 2 + 1))) (Wd.pushTok s0.ffi tab0.length)
    (by simpa using hf)
  rw [hupd] at h2
  have h3 : RelF Wd.F (Wd.R P (toks.drop (T - 2 + 1))) W (M.setNum tab0.length toks[T - 2])
      (V (T - 2) (tk T)) K (Wd.finalStartW s0 tab0.length) hs.S0 t C :=
    h2.srvSwap (by rw [hs.tab]) ⟨fun j e he => h2.srv.num j e (by rw [hs.tab] at he; exact he), hgood⟩
  rw [hT1] at h3
  have hKfr : ∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs := fun a => by
    rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a
  -- the chain
  obtain ⟨x1, hst, hend, ⟨v, hv⟩⟩ :=
    hs.halt (x := ⟨M.setNum tab0.length toks[T - 2], V (T - 2) (tk T), K, t, C⟩) ⟨h3, hQA K hKfr hlo hhi⟩
  obtain ⟨hF, -⟩ := hs.rend x1 _ _ hend
  have hS0 : hs.S0.tab.length = tab0.length + 1 := by rw [hs.tab]; simp
  have hext : Ext (M.setNum tab0.length toks[T - 2]) x1.M (tab0.length + 1) := by rw [← hS0]; exact hst.ext
  have hMa : x1.M.a = M.a := hext.a
  obtain ⟨hklo, hkhi, hke⟩ := hst.kr
  refine ⟨x1.t, x1.C, v, hst.run, hv, ?_, hst.le, ?_,
    fun Fin hfin => hfin x1 hend fun a ha => by rw [hMa]; exact hfix a ha⟩
  · -- the emitted tokens
    have hk : x1.K.fr A.emit = some (arrOf s0 A.emit, E0 ++ (toks.take (T - 2 - 1)).map Val.num) := by
      rw [hke, hfr, frA_emit]
    obtain ⟨o, hg, hkind⟩ := hs.emitG
    refine (hF.emittedW henv hs.cell (by rw [hMa]; exact hfix _ hcE) (by rw [hMa]; exact hfix _ hb) hk hg hkind
      hwc hwe).trans ?_
    have hnum : ∀ j, j < tab0.length + 1 → x1.M.num j = (M.setNum tab0.length toks[T - 2]).num j :=
      fun j hj => hext.num j hj
    have hnt : x1.M.num A.tok = toks[T - 3] := by
      rw [hnum A.tok (by have := st.htok; omega), (Map.setNum_ext M tab0.length toks[T - 2]).num A.tok st.htok]
      have := htokM; rw [show T - 2 - 1 = T - 3 by omega, List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    rcases hks with rfl | rfl
    · show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (x1.M.nv (.ref A.tok))]) = _
      simp only [Map.nv, hnt]
      rw [show T - 2 - 1 = T - 3 by omega, show T - 3 + [A.tok].length = T - 3 + 1 by rfl,
        ← take_map_succ toks (T - 3) (by omega), List.append_assoc]
    · have hnn : x1.M.num tab0.length = toks[T - 2] := by
        rw [hnum tab0.length (by omega), Map.setNum_self]
      show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (x1.M.nv (.ref A.tok)),
        Val.num (x1.M.nv (.ref tab0.length))]) = _
      simp only [Map.nv, hnt, hnn]
      rw [show T - 2 - 1 = T - 3 by omega, show T - 3 + [A.tok, tab0.length].length = T - 3 + 1 + 1 by rfl,
        ← take_map_succ toks (T - 3 + 1) (by omega), ← take_map_succ toks (T - 3) (by omega)]
      simp only [List.append_assoc, List.singleton_append, show T - 3 + 1 = T - 2 by omega]
  · exact hG hi nx M K t C x1 hGx hfix h hKfr hlo hhi hst.run hst.tr hext hst.val (hklo.trans hlo) (hkhi.trans hhi)
      hke hend

end Halt

/-! ## The checked halting cases as chains -/

/-- A checked halting case at `A` over `Wd` from `st0`, split at the epilogue's spread of
`forwarded` (`ExitCaseA`). -/
structure ExitCaseW (Wd : World) (A : Addr) (okA okB : St Wd.F.S → SSrv → Bool) (s0 st0 : St Wd.F.S)
    (tab1 : List SymE) (aN : Nat) (xs : List Val) where
  S0 : SSrv
  tab : S0.tab = tab1
  nA : Nat
  sP : St Wd.F.S
  SP : SSrv
  okA0 : okA st0 S0 = true
  runA : runOk Wd.F okA nA st0 S0 = some (sP, SP)
  okP : okA sP SP = true
  haltP : isHalt sP.ctl = false
  sA : St Wd.F.S
  SA : SSrv
  stepA : interpS (step Wd.F sP).run SP = some (sA, SA)
  acc : List Val
  env : Env
  fs : List Frame
  ctlA : sA.ctl = .ret (.obj A.fwd)
  stackA : sA.stack = .l (.spread acc [] env) :: fs
  roomA : sA.next + margin < Sim.bound
  arrA : Present sA aArrayProto
  newA : sA.next = aN
  sB : St Wd.F.S
  SB : SSrv
  stepB : interpS (step Wd.F sA).run SA = some (sB, SB)
  okB0 : okB sB SB = true
  nB : Nat
  sF : St Wd.F.S
  SF : SSrv
  runB : runOk Wd.F okB nB sB SB = some (sF, SF)
  halt : ∃ v, sF.ctl = .halt (.normal v)
  emitG : ∃ o, sF.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ xs)
  cell : sF.cell? A.cE = some (some (.obj A.emit))

/-- An exit case's steps. -/
abbrev ExitCaseW.n {Wd : World} {A : Addr} {okA okB : St Wd.F.S → SSrv → Bool} {s0 st0 : St Wd.F.S}
    {tab1 : List SymE} {aN : Nat} {xs : List Val} (ec : ExitCaseW Wd A okA okB s0 st0 tab1 aN xs) : Nat :=
  ec.nA + 1 + 1 + ec.nB

section ExitSeg
variable {Wd : World} {A : Addr} {P : Wd.Par} {W : Nat → Option WFrame} {VBOk : (Nat → F64) → Prop}
  {okA okB : St Wd.F.S → SSrv → Bool} {s0 st0 : St Wd.F.S} {tab1 : List SymE} {aN : Nat} {xs : List Val}

/-- The spread's new context: the framed accumulator at the new array (`kp_frameAtA`). -/
theorem kp_frameAtW {jsA jsB : Disp.JSP Wd.F} {xs' : List Nat}
    (hjA : jsA.lo = Wd.lo P ∧ jsA.hi = Wd.E P ∧ ∀ a, a ∈ jsA.framed ↔ a ∈ xs')
    (hjB : jsB.lo = Wd.lo P ∧ jsB.hi = Wd.E P ∧ ∀ a, a ∈ jsB.framed ↔ a ∈ xs' ++ [aN]) {K : Ctx}
    (hK : Disp.Kp jsA K) (p : List Val × List Val) : Disp.Kp jsB (Disp.Ctx.frameAt K aN p) := by
  obtain ⟨hlo, hhi, hfr⟩ := hK
  refine ⟨hlo.trans (hjA.1.trans hjB.1.symm), hhi.trans (hjA.2.1.trans hjB.2.1.symm), fun a => ?_⟩
  rw [hjB.2.2]
  show (bif Nat.beq a aN then some p else K.fr a) ≠ none ↔ _
  by_cases ha : a = aN
  · subst ha; simp
  · rw [Addr.beq_ne ha, Bool.cond_false, hfr, hjA.2.2]
    simp [ha]

/-- **A checked halting case as a halting chain** over `Wd` under the frames `W`
(`ExitCaseA.toSeg`). -/
noncomputable def ExitCaseW.toSeg {fx : List Nat} (ec : ExitCaseW Wd A okA okB s0 st0 tab1 aN xs)
    (SA : AccSimG Wd P W VBOk okA (A.fwd :: A.emit :: fx)) (SB : AccSimG Wd P W VBOk okB (A.fwd :: A.emit :: fx ++ [aN]))
    (haN2 : aN ≠ A.emit) (hwf : W A.fwd = none) (hwn : W aN = none) (r : List NumV) :
    HaltSegW Wd A W P r s0 st0 tab1 xs where
  S0 := ec.S0
  tab := ec.tab
  QA ν K := Disp.Kp SA.jsP K ∧ VBOk ν
  QF ν K := Disp.Kp SB.jsP K ∧ VBOk ν
  case :=
    { Rend := relQW Wd.F (Wd.R P r) W fun ν K => Disp.Kp SB.jsP K ∧ VBOk ν
      sF := ec.sF
      SF := ec.SF
      chain :=
        .cons ec.nA (PieceSim.ofRunOkW (SA.sim r) (fun _ _ h => h)
            (fun M ν K n s t s1 t1 S S1 C C1 hq hr hok hrun hrc =>
              SA.ng r M ν K n s t s1 t1 S S1 C C1 hq.1 hq.2 hr hok hrun hrc)
            ec.okA0 ec.runA) (interpS_runOk_len ec.runA) <|
        .cons 1 (PieceSim.ofLastW (SA.simL r) (fun _ _ h => h)
            (fun M ν K s t s1 t1 S S1 C C1 hq hr hh hok hs ht =>
              SA.ngL r M ν K s t s1 t1 S S1 C C1 hq.1 hq.2 hr hh hok hs ht)
            ec.okP ec.haltP ec.stepA) (interpS_len _ _ _ _ ec.stepA) <|
        .cons 0 (PieceSim.relOfXW (fun r env fs he => by rw [ec.stackA] at he; cases he)) (Nat.le_refl _) <|
        .cons 1 (PieceSim.spreadW (Q' := fun ν K => Disp.Kp SB.jsP K ∧ VBOk ν) ec.ctlA ec.stackA ec.roomA ec.arrA
            ec.stepB hwf (by rw [ec.newA]; exact hwn)
            (fun ν K hq => by
              have := (hq.1.2.2 A.fwd).2 (by rw [SA.hj.2.2]; simp)
              exact Option.ne_none_iff_exists'.1 this)
            (fun M ν K pre pre' hq _ => by
              rw [ec.newA]
              refine ⟨⟨kp_frameAtW SA.hj SB.hj hq.1 _, hq.2⟩, rfl, rfl, ?_⟩
              show (bif Nat.beq A.emit aN then _ else K.fr A.emit) = K.fr A.emit
              rw [Addr.beq_ne haN2.symm]; rfl)
            (fun t t' he => by show Host.Mlx.Ffi.NGrow _ _; rw [he]; exact Host.Mlx.Ffi.NGrow.refl _))
          (interpS_len _ _ _ _ ec.stepB) <|
        .cons ec.nB (PieceSim.ofRunOkRelW (SB.sim r) (fun _ _ h => h)
            (fun M ν K n s t s1 t1 S S1 C C1 hq hr hok hrun hrc =>
              SB.ng r M ν K n s t s1 t1 S S1 C C1 hq.1 hq.2 hr hok hrun hrc)
            ec.okB0 ec.runB (fun v hv => by obtain ⟨w, hw⟩ := ec.halt; rw [hw] at hv; cases hv))
          (interpS_runOk_len ec.runB) <|
        .nil _ _ _
      fin := fun x hx => by
        obtain ⟨w, hw⟩ := ec.halt
        exact ⟨x.M.val w, by rw [hx.1.ctl, hw]; rfl⟩ }
  rend _ _ _ h := h
  emitG := ec.emitG
  cell := ec.cell

theorem ExitCaseW.toSeg_n {fx : List Nat} (ec : ExitCaseW Wd A okA okB s0 st0 tab1 aN xs)
    (SA : AccSimG Wd P W VBOk okA (A.fwd :: A.emit :: fx)) (SB : AccSimG Wd P W VBOk okB (A.fwd :: A.emit :: fx ++ [aN]))
    (haN2 : aN ≠ A.emit) (hwf : W A.fwd = none) (hwn : W aN = none) (r : List NumV) :
    (ec.toSeg SA SB haN2 hwf hwn r).case.n = ec.n := by
  show ec.nA + (1 + (0 + (1 + (ec.nB + 0)))) = ec.nA + 1 + 1 + ec.nB
  omega

end ExitSeg

end Host.Ts.Sim
