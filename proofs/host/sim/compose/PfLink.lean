import host.sim.compose.JsAbove
import host.sim.compose.a4b.SetupChunkStage
import host.sim.compose.CompactDrop
import host.sim.compose.RestartW
import host.sim.template.FullShiftGen
import host.sim.template.Sigma
import host.sim.template.PostOk
import host.sim.CasesL
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Pf
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose.SetupChunk

/-! # A forward's end into a template the classes share

The pre-final cut and POST's entry hold the prompt and the frames `W0`: the step's chunk, buffer and view are garbage after its forward,
and the template has collected them. `PfFacts` are the generated checks that the state holds a copy of the template under a walked map,
except at `W0`, where `WideImg` relates the two. `pfRel` is the relation there, through the compaction that drops those frames and adds
`W0`'s (`Conv.full_compactW`). The template may sit above the class's address counter: only the target's need be above it. -/

theorem jsShiftBad_aboveR {D : RData} {n : Nat} (hfix : ∀ b, b < n → D.a b = b) {i : Int}
    (h : jsShiftBadB D.map i = true) : jsAboveB n i = true := by
  cases hp : jsPtrOf i with
  | none => simp only [jsShiftBadB, hp] at h; cases h
  | some p =>
    obtain ⟨b, off⟩ := p
    obtain ⟨he, hb, _⟩ := jsPtrOf_some hp
    simp only [jsAboveB, hp]
    apply Nat.ble_eq_true_of_le
    refine Nat.le_of_not_lt fun hn => ?_
    have ha : D.map.a b = b := hfix b hn
    have hi : D.map.big i = i := Conv.rdata_big_js D i (by rw [hp]; exact Option.some_ne_none _)
    unfold jsShiftBadB at h
    simp only [hp] at h
    rw [ha, hi, he] at h
    simp only [decide_true, Nat.blt_eq.mpr hb, Bool.and_self, Bool.not_true] at h
    cases h

theorem thetaOf_off {l : List (Nat × SymE)} {j : Nat} (h : j ∉ l.map Prod.fst) : thetaOf l j = .var j := by
  have hn : l.find? (fun p => p.1 == j) = none := by
    rw [List.find?_eq_none]
    intro p hp he
    apply h
    have : p.1 = j := by simpa using he
    rw [← this]
    exact List.mem_map_of_mem hp
  simp only [thetaOf, hn, Option.map_none, Option.getD_none]

/-- Addresses below every renamed key are fixed. -/
theorem jsFix_of_keys {D : RData} {n : Nat} (hn : n ≤ D.n0) (hk : (PTrie.keys D.heap).all (Nat.ble n) = true) :
    ∀ b, b < n → D.a b = b := by
  intro b hb
  rw [RData.a_old D (Nat.lt_of_lt_of_le hb hn)]
  cases hg : D.heap.get b with
  | none => rfl
  | some y =>
    have := Nat.le_of_ble_eq_true (List.all_eq_true.mp hk b (PTrie.mem_keys D.heap b y hg))
    omega

theorem framedNext_empty {F : Ffi} {s : St F.S} {a : Nat} (M : Map) (K : Ctx)
    (he : arrOf s a = []) : Shift.framedNext M K s a = K.fr a := by
  unfold Shift.framedNext
  cases hf : K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    cases hg : s.heap.get a with
    | none => rfl
    | some obj =>
      cases obj with
      | cell v => rfl
      | obj o =>
        cases hk : o.kind <;>
          simp_all only [arrOf, hg, hk, List.drop_nil, Map.vals, List.map_nil, List.append_nil]


/-- What a link needs of a frame after it. -/
def WideP (D : RData) (s0 s1 : St FF.S) (a : Nat) (w : WFrame) : Prop :=
  a ≠ 2665 ∧ D.a a = a ∧ Present s0 a ∧ WFix D.map (Present s0) w ∧
    ∀ h, s0.heap.get a = some h → ∃ h1, s1.heap.get a = some h1 ∧ WideImg w (D.map.hobj h) h1

/-- A ghost's two entries: cells, or an object a frame may hold and a map. -/
def ghostChkB : Option HObj → Option HObj → Bool
  | some (.cell _), some (.cell _) => true
  | some (.obj o), some (.obj o1) =>
    (match o.kind with | .ordinary | .map _ | .box _ => true | _ => false) &&
      (match o1.kind with | .map _ => true | _ => false)
  | _, _ => false

theorem wideP_ghost {D : RData} {s0 s1 : St FF.S} {a : Nat} (hn : a ≠ 2665) (hfix : D.a a = a)
    (hc : ghostChkB (s0.heap.get a) (s1.heap.get a) = true) : WideP D s0 s1 a .ghost := by
  cases h0 : s0.heap.get a with
  | none => rw [h0] at hc; cases hc
  | some x0 =>
    cases h1 : s1.heap.get a with
    | none => rw [h0, h1] at hc; cases x0 <;> cases hc
    | some x1 =>
      refine ⟨hn, hfix, Present.of_get h0, trivial, fun h hg => ?_⟩
      rw [h0] at hg
      cases hg
      refine ⟨x1, h1, ?_⟩
      rw [h0, h1] at hc
      cases x0 with
      | cell v => cases x1 with
        | cell v1 => trivial
        | obj o1 => cases hc
      | obj o => cases x1 with
        | cell v1 => cases hc
        | obj o1 =>
          simp only [ghostChkB, Bool.and_eq_true] at hc
          refine ⟨?_, ?_⟩
          · change Wideable (D.map.kind o.kind)
            cases hk : o.kind <;> first | trivial | (rw [hk] at hc; simp at hc)
          · cases hk : o1.kind <;> first | exact ⟨_, rfl⟩ | (rw [hk] at hc; simp at hc)

theorem wideP_memo {D : RData} {s0 s1 : St FF.S} {a : Nat} {gs : List Nat} {o0 o1 : Obj} {es : List (Val × Val)} (hn : a ≠ 2665)
    (hfix : D.a a = a) (h0 : s0.heap.get a = some (.obj o0)) (h1 : s1.heap.get a = some (.obj o1)) (hk : o1.kind = .map es)
    (hi : D.map.obj o0 = { o1 with kind := .map (StringIndex.dropCodes gs es) }) : WideP D s0 s1 a (.memo gs) := by
  refine ⟨hn, hfix, Present.of_get h0, trivial, fun h hg => ?_⟩
  rw [h0] at hg
  cases hg
  exact ⟨.obj o1, h1, es, hk, hi⟩

theorem lookupW_mem : ∀ {L : List (Nat × WFrame)} {a : Nat} {w : WFrame}, Disp.lookupW a L = some w → (a, w) ∈ L
  | [], _, _, h => by cases h
  | (b, x) :: L, a, w, h => by
    by_cases e : a = b
    · subst e
      simp only [Disp.lookupW, Nat.beq_refl, Bool.cond_true, Option.some.injEq] at h
      subst h
      exact List.mem_cons_self
    · have hb : Nat.beq a b = false := by
        cases he : Nat.beq a b with
        | false => rfl
        | true => exact absurd (Nat.eq_of_beq_eq_true he) e
      simp only [Disp.lookupW, hb, Bool.cond_false] at h
      exact List.mem_cons_of_mem _ (lookupW_mem h)

theorem lookupW_ne : ∀ {L : List (Nat × WFrame)} {a : Nat}, a ∈ L.map Prod.fst → Disp.lookupW a L ≠ none
  | [], _, h => by cases h
  | (b, x) :: L, a, h => by
    by_cases e : a = b
    · subst e
      simp [Disp.lookupW]
    · have hb : Nat.beq a b = false := by
        cases he : Nat.beq a b with
        | false => rfl
        | true => exact absurd (Nat.eq_of_beq_eq_true he) e
      simp only [Disp.lookupW, hb, Bool.cond_false]
      simp only [List.map_cons, List.mem_cons] at h
      exact lookupW_ne (h.resolve_left e)

/-- A frame a link keeps beside the prompt's: in place, empty in both templates, not one of `W0`'s. -/
structure KeptF (D : RData) (s0 s1 : St FF.S) (W0 : Nat → Option WFrame) (a : Nat) : Prop where
  ne : a ≠ 2665
  none : W0 a = none
  fix : D.a a = a
  get : s0.heap.get a = some (.obj (Template.objOf s0 a))
  kind : (Template.objOf s0 a).kind = .array []
  img : s1.heap.get a = some (.obj { D.map.obj (Template.objOf s0 a) with kind := .array ([] ++ arrOf s1 a) })
  empty : arrOf s1 a = []

/-- The generated checks: `s1` holds a copy of `s0` under `D.map`, the prompt and `kept` in place and empty, the frames `W0` related by
`WideImg`; no address of `s0` lands on a dropped frame. -/
structure PfCore (s0 s1 : St FF.S) (tab0 tab1 : List SymE) (D : RData) (inv : PTrie Nat)
    (θ : Nat → SymE) (P0 : LoadP) (nJ : Nat) (kept drop : List Nat) (W0 : Nat → Option WFrame) : Prop where
  num : checkNum D.map θ ⟨tab0, []⟩ ⟨tab1, []⟩ = true
  heap : ∀ a h, s0.heap.get a = some h → a ≠ 2665 → W0 a = none → s1.heap.get (D.a a) = some (D.map.hobj h)
  wide : ∀ a w, W0 a = some w → a ≠ 2665 ∧ D.a a = a ∧ Present s0 a ∧ WFix D.map (Present s0) w ∧
    ∀ h, s0.heap.get a = some h → ∃ h1, s1.heap.get a = some h1 ∧ WideImg w (D.map.hobj h) h1
  notDrop : ∀ a, Present s0 a → ∀ b ∈ drop, D.a a ≠ b
  fixP : D.a 2665 = 2665
  getP : s0.heap.get 2665 = some (.obj (Template.objOf s0 2665))
  kindP : (Template.objOf s0 2665).kind = .array []
  imgP : s1.heap.get 2665 =
    some (.obj { D.map.obj (Template.objOf s0 2665) with kind := .array ([] ++ arrOf s1 2665) })
  emptyP : arrOf s1 2665 = []
  keepF : ∀ a ∈ kept, KeptF D s0 s1 W0 a
  n0 : D.n0 = s0.next
  n1 : D.n1 = s1.next
  ren : checkRen s0 D inv = true
  bound : ∀ a, Present s0 a → a < s0.next
  ctl : s1.ctl = D.map.ctl s0.ctl
  stack : s1.stack = s0.stack.map D.map.frame
  jobs : s1.jobs = s0.jobs.map D.map.job
  stores : s1.stores = D.map.stores s0.stores
  heapSupp : ∀ a h, s0.heap.get a = some h → Supp.hobj (Present s0) tab0.length h
  ctlSupp : Supp.ctl (Present s0) tab0.length s0.ctl
  stackSupp : ∀ f ∈ s0.stack, Supp.frame (Present s0) tab0.length f
  jobsSupp : ∀ j ∈ s0.jobs, Supp.job (Present s0) tab0.length j
  storesSupp : Supp.stores (Present s0) tab0.length s0.stores
  band : D.checkBand 18151 = true
  nh0 : 18151 ≤ D.nh0
  intr : ∀ a, a < aFirst → D.a a = a
  inactive : (bridgeOf s0.ffi).active = false
  raised : Raised setupP P0
  bigs : bigsOutB (mlxOf s0.ffi).next setupP.E (mlxOf s0.ffi) = true
  free : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < setupP.E) s0.trace s0
  loLe : 18151 ≤ (mlxOf s0.ffi).next
  hi0 : (mlxOf s0.ffi).next ≤ setupP.E
  nhi0 : (mlxOf s0.ffi).nnext ≤ setupP.NE
  hi1 : (mlxOf s1.ffi).next ≤ setupP.E
  nhi1 : (mlxOf s1.ffi).nnext ≤ setupP.NE
  jsHeap : JsHeapAbove nJ s0
  jsRoots : noBigRootsP (jsAboveB nJ) s0.trace s0 = true
  jsNative : bigsOutB jsLoN jsHiN (mlxOf s0.ffi) = true
  jsFix : ∀ b, b < nJ → D.a b = b

/-- The checks with a shift keeping every node at or above the template's order. -/
structure PfFacts (s0 s1 : St FF.S) (tab0 tab1 : List SymE) (D : RData) (inv : PTrie Nat)
    (θ : Nat → SymE) (P0 : LoadP) (nJ : Nat) (kept drop : List Nat) (W0 : Nat → Option WFrame) : Prop
    extends PfCore s0 s1 tab0 tab1 D inv θ P0 nJ kept drop W0 where
  shift : Conv.FullShiftQ P0 tab0.length D.map s0.ffi s1.ffi

section
variable {s0 s1 : St FF.S} {tab0 tab1 : List SymE} {D : RData} {inv : PTrie Nat} {θ : Nat → SymE}
  {P0 : LoadP} {nJ : Nat} {kept drop : List Nat} {W0 : Nat → Option WFrame}

/-- The target's room crosses to a template at or above the tail's counters. -/
theorem linkRoomLe {NB T : Nat} {tk : Nat → Nat} {W : Nat → Option WFrame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {t : St FF.S} {S : SSrv} {C : CSrv}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W [] M ν K s1 S t C)
    (hH : (mlxOf s1.ffi).next ≤ (mlxOf s0.ffi).next) (hN : (mlxOf s1.ffi).nnext ≤ (mlxOf s0.ffi).nnext) :
    NRoom setupP (Host.Load.Layers.toLoad s0.ffi) (Host.Load.Layers.toLoad t.ffi) := by
  obtain ⟨P', hP, hf⟩ := hr.ffi.1
  obtain ⟨_, hE, hNE, _⟩ := Raised.restart (.inl rfl) hP
  constructor
  · have h := hf.load.mlx.hroom.2
    rw [hE] at h
    change (mlxOf t.ffi).next + (setupP.E - (mlxOf s1.ffi).next) < 2 ^ 46 at h
    change (mlxOf t.ffi).next + (setupP.E - (mlxOf s0.ffi).next) < 2 ^ 46
    omega
  · have h := hf.load.mlx.nroom.2.2
    rw [hNE] at h
    change (mlxOf t.ffi).nnext + (setupP.NE - (mlxOf s1.ffi).nnext) < 2 ^ 62 at h
    change (mlxOf t.ffi).nnext + (setupP.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
    omega

/-- A final's own offsets give the room when its counters are past the entry's. -/
theorem linkRoomAt {H N : Nat} {t : St FF.S} (hnat : NativeAt H N s1 t) (hH : H ≤ 2 ^ 40) (hN : N ≤ 2 ^ 40)
    (hhi : (mlxOf s1.ffi).next ≤ setupP.E) (hnhi : (mlxOf s1.ffi).nnext ≤ setupP.NE) :
    NRoom setupP (Host.Load.Layers.toLoad s0.ffi) (Host.Load.Layers.toLoad t.ffi) := by
  obtain ⟨h1, h2⟩ := hnat
  have hE : setupP.E = 131072 := rfl
  have hNE : setupP.NE = 1099511627776 := rfl
  constructor
  · change (mlxOf t.ffi).next + (setupP.E - (mlxOf s0.ffi).next) < 2 ^ 46
    omega
  · change (mlxOf t.ffi).nnext + (setupP.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
    omega


/-- The frames a link keeps: the prompt's and those listed. -/
abbrev keepOf (kept : List Nat) : Nat → Bool := fun a => Nat.beq a 2665 || kept.contains a

theorem keepOf_false {kept : List Nat} {a : Nat} (h : keepOf kept a = false) : a ≠ 2665 ∧ a ∉ kept := by
  simp only [keepOf, Bool.or_eq_false_iff] at h
  refine ⟨fun e => ?_, fun hm => ?_⟩
  · subst e
    simp at h
  · rw [List.contains_iff_mem.mpr hm] at h
    cases h.2

theorem keepOf_true {kept : List Nat} {a : Nat} (h : keepOf kept a = true) : a = 2665 ∨ a ∈ kept := by
  simp only [keepOf, Bool.or_eq_true] at h
  rcases h with h | h
  · exact .inl (Nat.eq_of_beq_eq_true h)
  · exact .inr (List.contains_iff_mem.mp h)

theorem pfShift {FS : Map → FF.S → FF.S → Prop} (F : PfCore s0 s1 tab0 tab1 D inv θ P0 nJ kept drop W0) (hsh : FS D.map s0.ffi s1.ffi)
    {K : Ctx} {π : List Nat} {kw : List Nat} {W : Nat → Option WFrame}
    (hfr : ∀ a, K.fr a ≠ none ↔ a ∈ 2665 :: (kept ++ (kw ++ drop))) (hkw : ∀ b ∈ kw, W0 b ≠ none)
    (hwk : ∀ a w, W0 a = some w → K.fr a = none ∨ W a = some w) (hlo : K.lo = 18151) (hhi : K.hi = 131072)
    (hP : K.fr 2665 = some ([], π.map natV)) (hK : ∀ b ∈ kept, ∃ q, K.fr b = some ([], q)) :
    ShiftW FF (fun σ x y => x = s0.ffi ∧ FS σ x y) D.map θ (keepOf kept) W0 W K
      s0 ⟨tab0, []⟩ s1 ⟨tab1, []⟩ := by
  have hinj : ∀ a b, Present s0 a → Present s0 b → D.a a = D.a b → a = b :=
    a_inj (fun x hx => by rw [F.n0]; exact F.bound x hx) F.ren
  refine
    { num := checkNum_sound F.num
      heap := ?_
      unfr := ?_
      framed := ?_
      wide := ?_
      next := ?_
      present := ?_
      inj := hinj
      presentBound := F.bound
      ctl := F.ctl
      stack := F.stack
      jobs := F.jobs
      stores := F.stores
      ffi := ⟨rfl, hsh⟩
      heapSupp := F.heapSupp
      ctlSupp := F.ctlSupp
      stackSupp := F.stackSupp
      jobsSupp := F.jobsSupp
      storesSupp := F.storesSupp
      bigFixed := ?_
      bigExt := RData.big_ext _
      intr := F.intr }
  · intro a h ha hkp hw
    exact F.heap a h ha (keepOf_false hkp).1 hw
  · intro a h ha hkp hw
    change K.fr (D.a a) = none
    cases e : K.fr (D.a a) with
    | none => rfl
    | some p =>
      have hm := (hfr _).mp (by rw [e]; exact Option.some_ne_none _)
      rcases List.mem_cons.mp hm with h1 | h1
      · exact absurd (hinj _ _ (Present.of_get ha) (Present.of_get F.getP) (h1.trans F.fixP.symm)) (keepOf_false hkp).1
      · rcases List.mem_append.mp h1 with h0 | h1
        · have k := F.keepF _ h0
          have e2 : a = D.a a := hinj _ _ (Present.of_get ha) (Present.of_get k.get) k.fix.symm
          rw [← e2] at h0
          exact absurd h0 (keepOf_false hkp).2
        · rcases List.mem_append.mp h1 with h2 | h2
          · obtain ⟨w, hb⟩ := Option.ne_none_iff_exists'.1 (hkw _ h2)
            obtain ⟨-, hfix, hpr, -, -⟩ := F.wide _ w hb
            have e2 : a = D.a a := hinj _ _ (Present.of_get ha) hpr hfix.symm
            rw [← e2, hw] at hb
            cases hb
          · exact absurd rfl (F.notDrop a (Present.of_get ha) _ h2)
  · intro a hkp
    rcases keepOf_true hkp with rfl | hm
    · exact ⟨F.fixP, [], π.map natV, _, _, hP, F.getP, F.kindP, F.imgP⟩
    · have k := F.keepF a hm
      obtain ⟨q, hq⟩ := hK a hm
      exact ⟨k.fix, [], q, _, _, hq, k.get, k.kind, k.img⟩
  · intro a w hw
    obtain ⟨hn, hfix, hpr, hwf, hkeep⟩ := F.wide a w hw
    have hk : keepOf kept a = false := by
      cases e : keepOf kept a with
      | false => rfl
      | true =>
        rcases keepOf_true e with h | h
        · exact absurd h hn
        · have := (F.keepF a h).none
          rw [this] at hw
          cases hw
    exact ⟨hk, hfix, hpr, hwf, hwk a w hw, hkeep⟩
  · intro k
    change D.a (s0.next + k) = _
    rw [← F.n0, RData.a_fresh, F.n1]
  · intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    change Present s1 (D.a a)
    by_cases hf : a = 2665
    · subst hf
      rw [F.fixP]
      exact Present.of_get F.imgP
    · cases hw : W0 a with
      | none => exact Present.of_get (F.heap a h ha hf hw)
      | some w =>
        obtain ⟨-, hfix, -, -, hkeep⟩ := F.wide a w hw
        obtain ⟨h1, hg1, -⟩ := hkeep h ha
        rw [hfix]
        exact Present.of_get hg1
  · intro i hi
    rw [hlo, hhi] at hi
    exact RData.big_fixed D F.band F.nh0 (by decide) i hi

/-- The prompt's frame after the link. -/
theorem frames_prompt (F : PfCore s0 s1 tab0 tab1 D inv θ P0 nJ kept drop W0) (M : Map) (K : Ctx) :
    frW M K (keepOf kept) W0 s1 2665 = K.fr 2665 :=
  framedNext_empty M K F.emptyP

theorem lookupW_isSome {L : List (Nat × WFrame)} {a : Nat} : (Disp.lookupW a L).isSome = true ↔ a ∈ L.map Prod.fst := by
  constructor
  · intro h
    obtain ⟨w, hw⟩ := Option.isSome_iff_exists.mp h
    exact List.mem_map.mpr ⟨(a, w), lookupW_mem hw, rfl⟩
  · intro h
    cases e : Disp.lookupW a L with
    | none => exact absurd e (lookupW_ne h)
    | some w => rfl

/-- The frames after the link are the prompt's, the list's and those kept. -/
theorem framed_after (F : PfCore s0 s1 tab0 tab1 D inv θ P0 nJ kept drop W0) (M : Map) (K : Ctx) {L : List (Nat × WFrame)}
    (hW : ∀ a, W0 a = Disp.lookupW a L) {xs : List Val} (hP : K.fr 2665 = some ([], xs))
    (hK : ∀ b ∈ kept, ∃ q, K.fr b = some ([], q)) (a : Nat) :
    frW M K (keepOf kept) W0 s1 a ≠ none ↔ a ∈ 2665 :: (L.map Prod.fst ++ kept) := by
  rw [List.mem_cons, List.mem_append]
  cases e : keepOf kept a with
  | true =>
    have hv : frW M K (keepOf kept) W0 s1 a ≠ none := by
      simp only [frW, e, cond_true]
      rcases keepOf_true e with rfl | hm
      · rw [framedNext_empty M K F.emptyP, hP]
        exact Option.some_ne_none _
      · obtain ⟨q, hq⟩ := hK a hm
        rw [framedNext_empty M K (F.keepF a hm).empty, hq]
        exact Option.some_ne_none _
    refine ⟨fun _ => ?_, fun _ => hv⟩
    rcases keepOf_true e with h | h
    · exact .inl h
    · exact .inr (.inr h)
  | false =>
    obtain ⟨h1, h2⟩ := keepOf_false e
    simp only [frW, e, cond_false]
    rw [or_iff_right h1, or_iff_left h2, hW a, ← lookupW_isSome]
    cases (Disp.lookupW a L).isSome <;> simp

/-- A frame new at the link: the tail doesn't frame it. -/
theorem newFrames {K : Ctx} {fr : List Nat} {L : List (Nat × WFrame)} {W W0 : Nat → Option WFrame}
    (hW : ∀ a, W0 a = Disp.lookupW a L) (hfr : ∀ a, K.fr a ≠ none ↔ a ∈ fr)
    (hd : (L.map Prod.fst).all (fun a => !fr.contains a) = true) :
    ∀ a w, W0 a = some w → K.fr a = none ∨ W a = some w := by
  intro a w hw
  refine .inl ?_
  cases e : K.fr a with
  | none => rfl
  | some p =>
    exfalso
    have h1 := (hfr a).mp (by rw [e]; exact Option.some_ne_none _)
    have h2 : a ∈ L.map Prod.fst := List.mem_map.mpr ⟨(a, w), lookupW_mem ((hW a).symm.trans hw), rfl⟩
    have h3 := List.all_eq_true.mp hd a h2
    rw [List.contains_iff_mem.mpr h1] at h3
    cases h3

/-- The fresh band the compaction reclaims is clear of the fixed bigs. -/
theorem linkBand (F : PfCore s0 s1 tab0 tab1 D inv θ P0 nJ kept drop W0) {K : Ctx} (hlo : K.lo = 18151) (hhi : K.hi = 131072) :
    ∀ j : Int, ((mlxOf s0.ffi).next : Int) ≤ j ∧ j < setupP.E → ¬ BigFixed K.lo K.hi j ∧ 0 ≤ j ∧ j < 2 ^ 56 := by
  intro j hj
  have hl := F.loLe
  rw [hlo, hhi]
  change _ ∧ j < 131072 at hj
  unfold BigFixed
  constructor
  · omega
  · constructor <;> omega

/-- The compaction's relation at the link's frames, with the JS bookkeeping back. -/
theorem pfRelOf (F : PfCore s0 s1 tab0 tab1 D inv θ P0 nJ kept drop W0) {NB T : Nat} {tk : Nat → Nat}
    {W : Nat → Option WFrame} {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W []
      M ν K s1 ⟨tab1, []⟩ t C)
    (hc : RelF FF (FullRXD { setupP with rest := machReads T tk } NB) W0
      ((M.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf t.ffi).next) (Shift.valuation θ ν)
      ⟨frW M K (keepOf kept) W0 s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩ s0 ⟨tab0, []⟩ t C)
    (hlo : K.lo = 18151) :
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W0 []
      (((M.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf t.ffi).next).withJs) (Shift.valuation θ ν)
      ⟨frW M K (keepOf kept) W0 s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩ s0 ⟨tab0, []⟩ t C := by
  let N' := (M.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf t.ffi).next
  let K' : Ctx := ⟨frW M K (keepOf kept) W0 s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩
  have hJs : NoBigSt (JsBad N') K'.base s0 :=
    noBigSt_of_above F.jsHeap F.jsRoots (fun j hj => by
      have hbad := jsBad_after (M := M) (N := N') (σ := D.map) hr.ffi.2 rfl
        (fun _ h => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) h) hj
      exact jsShiftBad_aboveR F.jsFix hbad)
  exact (hc.withJs (by change K.lo ≤ 2 ^ 56; rw [hlo]; change 18151 ≤ 2 ^ 56; decide) hJs
    (fullRXD_withJs hc.ffi F.jsNative)).toJ (BigJs.withJs N')

/-- **The relation at the template.** -/
theorem pfRel (F : PfFacts s0 s1 tab0 tab1 D inv θ P0 nJ kept drop W0) {NB T : Nat} {tk : Nat → Nat}
    {W : Nat → Option WFrame} {π : List Nat} {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {kw : List Nat}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W []
      M ν K s1 ⟨tab1, []⟩ t C)
    (hfr : ∀ a, K.fr a ≠ none ↔ a ∈ 2665 :: (kept ++ (kw ++ drop))) (hkw : ∀ b ∈ kw, W0 b ≠ none)
    (hwk : ∀ a w, W0 a = some w → K.fr a = none ∨ W a = some w) (hlo : K.lo = 18151) (hhi : K.hi = 131072)
    (hP : K.fr 2665 = some ([], π.map natV)) (hK : ∀ b ∈ kept, ∃ q, K.fr b = some ([], q))
    (hroomN : NRoom setupP (Host.Load.Layers.toLoad s0.ffi) (Host.Load.Layers.toLoad t.ffi))
    (hNB : NB ≤ P0.NL) (hD : K.D + (s1.next - s0.next) < Sim.bound) (hge : s0.next ≤ s1.next + K.D) :
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W0 []
      (((M.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf t.ffi).next).withJs) (Shift.valuation θ ν)
      ⟨frW M K (keepOf kept) W0 s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩ s0 ⟨tab0, []⟩ t C := by
  have hs := pfShift F.toPfCore (FS := Conv.FullShiftQX P0 tab0.length) (F.shift.toX F.inactive) hfr hkw hwk hlo hhi hP hK
  have hoff : t.next = s1.next + K.D := hr.offset
  exact pfRelOf F.toPfCore hr (Conv.full_compactW NB (P := setupP) (r := machReads T tk)
    (s0 := s0) (s1 := s1) (S0 := ⟨tab0, []⟩) (S1 := ⟨tab1, []⟩) (W1 := W) (W0 := W0) (kp := keepOf kept)
    F.raised hNB hr.ofJ hs F.bigs F.free (linkBand F.toPfCore hlo hhi) (fun _ h => nomatch h) (by omega) (by omega) hroomN) hlo

end

open Host.Load.Run.Tpl in
/-- What the pre-final cut holds: the prompt, the reserved values, and the variables its table reads at
the quantities of the tail just finished. -/
structure PfBook (T : Nat) (tk : Nat → Nat) (cap : Nat) (π : List Nat) (x : SegInst FF) : Prop where
  vocab : ∀ k ∈ π, k < 248320
  valuation : VBOkF loopVB x.ν
  promptValue : x.ν 9 = F64.ofNat π.length
  rowValue : x.ν 10 = F64.ofNat (π.length - 1)
  offsetValue : x.ν 11 = F64.ofNat (π.length - 1)
  capValue : x.ν 16 = F64.ofNat (capL (π.length - 1))
  context : Disp.KpJ PostOk.J0 cap x.K
  prompt : x.K.fr 2665 = some ([], π.map natV)
  inputs : setupInputs T tk x

open Host.Load.Run.Tpl in
/-- **The pre-final cut**: a prompt of length `L` at the template `s`. -/
noncomputable def cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S =>
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideGPf [] x.M x.ν x.K s S x.t x.C ∧
    PfBook T tk cap π x
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt H N s x.t

end Host.Ts.Sim.Compose.Pf
