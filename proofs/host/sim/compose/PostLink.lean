import host.sim.compose.PostGlue
import host.sim.compose.JsAbove
import host.sim.compose.a4b.SetupChunkStage
import host.sim.template.FullShiftGen
import host.sim.template.Sigma
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.SetupChunk

/-! # A forward's return into the L-general POST entry

`PRE_pl_entry.s0` is the D1 forward's return with the row's numbers in table variables. A final's end
holds a copy of it under a walked map (`tpl_restart`): `LinkFacts` are the generated checks of that
copy and `linkRel` the relation at the entry, through the compaction (`Conv.full_compactQXD`). -/

/-- The typed frames without the inactive memo: the compaction's kept frames. -/
def linkW (bs : List Byte) : Nat → Option WFrame :=
  Disp.wAt (Disp.wAt noFrames D1Frames.buffer (.buf bs)) D1Frames.view (.typed .i32 D1Frames.buffer 0 1)

theorem linkW_agree (bs : List Byte) {K : Ctx} (hmemo : K.fr 4910 = none) :
    ∀ a, K.fr a ≠ none → linkW bs a = D1Frames.typedW bs a := by
  intro a ha
  by_cases hv : a = D1Frames.view
  · subst hv; rfl
  · by_cases hb : a = D1Frames.buffer
    · subst hb; rfl
    · simpa only [linkW, D1Frames.typedW, Disp.wAt, beq_false hv, beq_false hb, Bool.cond_false] using
        (wideInactive hmemo a ha).symm

theorem linkW_domain {bs : List Byte} {a : Nat} {w : WFrame} (hw : linkW bs a = some w) :
    a = D1Frames.buffer ∨ a = D1Frames.view := by
  by_cases hv : a = D1Frames.view
  · exact .inr hv
  · by_cases hb : a = D1Frames.buffer
    · exact .inl hb
    · simp only [linkW, Disp.wAt, beq_false hv, beq_false hb, Bool.cond_false, noFrames] at hw
      cases hw

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

private theorem framedNext_empty {F : Ffi} {s : St F.S} {a : Nat} (M : Map) (K : Ctx)
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

theorem frames_perm {a : Nat} (h : a ∈ [D1Frames.chunk, D1Frames.buffer, D1Frames.view, 2665]) :
    a ∈ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view] := by
  simp only [List.mem_cons, List.not_mem_nil, or_false] at h ⊢
  rcases h with rfl | rfl | rfl | rfl <;> simp

/-- The generated checks: `s1` holds a copy of `s0` under `D.map`, the frames in place and empty. -/
structure LinkFacts (s0 s1 : St FF.S) (tab0 tab1 : List SymE) (D : RData) (inv : PTrie Nat)
    (θ : Nat → SymE) (P0 : LoadP) (nJ : Nat) : Prop where
  num : checkNum D.map θ ⟨tab0, []⟩ ⟨tab1, []⟩ = true
  heap : ∀ a h, s0.heap.get a = some h → a ∉ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view] →
    s1.heap.get (D.a a) = some (D.map.hobj h)
  fixP : D.a 2665 = 2665
  fixC : D.a D1Frames.chunk = D1Frames.chunk
  fixB : D.a D1Frames.buffer = D1Frames.buffer
  fixV : D.a D1Frames.view = D1Frames.view
  getP : s0.heap.get 2665 = some (.obj (Template.objOf s0 2665))
  kindP : (Template.objOf s0 2665).kind = .array []
  imgP : s1.heap.get 2665 =
    some (.obj { D.map.obj (Template.objOf s0 2665) with kind := .array ([] ++ arrOf s1 2665) })
  getC : s0.heap.get D1Frames.chunk = some (.obj (Template.objOf s0 D1Frames.chunk))
  kindC : (Template.objOf s0 D1Frames.chunk).kind = .array []
  imgC : s1.heap.get D1Frames.chunk =
    some (.obj { D.map.obj (Template.objOf s0 D1Frames.chunk) with kind := .array ([] ++ arrOf s1 D1Frames.chunk) })
  getB : (s0.heap.get D1Frames.buffer).isSome = true
  imgB : s1.heap.get D1Frames.buffer = (s0.heap.get D1Frames.buffer).map D.map.hobj
  getV : (s0.heap.get D1Frames.view).isSome = true
  imgV : s1.heap.get D1Frames.view = (s0.heap.get D1Frames.view).map D.map.hobj
  framesEmpty : [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view].all (fun a => (arrOf s1 a).isEmpty) = true
  n0 : D.n0 = s0.next
  n1 : D.n1 = s1.next
  grows : s0.next ≤ s1.next
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
  shift : Conv.FullShiftQ P0 tab0.length D.map s0.ffi s1.ffi
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

section
variable {s0 s1 : St FF.S} {tab0 tab1 : List SymE} {D : RData} {inv : PTrie Nat} {θ : Nat → SymE}
  {P0 : LoadP} {nJ : Nat}

theorem linkShift (F : LinkFacts s0 s1 tab0 tab1 D inv θ P0 nJ) {K : Ctx} {bs : List Byte} {π γ : List Nat}
    (hk : Disp.Kp (D1Frames.typedJ bs) K) (hP : K.fr 2665 = some ([], π.map natV))
    (hC : K.fr D1Frames.chunk = some ([], γ.map natV)) :
    ShiftD FF (fun σ x y => x = s0.ffi ∧ Conv.FullShiftQX P0 tab0.length σ x y) D.map θ
      (kpOf K (linkW bs)) (linkW bs) K s0 ⟨tab0, []⟩ s1 ⟨tab1, []⟩ := by
  have hfr : ∀ a, K.fr a ≠ none ↔ a ∈ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view] := hk.2.2
  have hinj : ∀ a b, Present s0 a → Present s0 b → D.a a = D.a b → a = b :=
    a_inj (fun x hx => by rw [F.n0]; exact F.bound x hx) F.ren
  have pB : Present s0 D1Frames.buffer := by
    obtain ⟨h, hh⟩ := Option.isSome_iff_exists.mp F.getB
    exact Present.of_get hh
  have pV : Present s0 D1Frames.view := by
    obtain ⟨h, hh⟩ := Option.isSome_iff_exists.mp F.getV
    exact Present.of_get hh
  have pFr : ∀ a, a ∈ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view] → Present s0 a ∧ D.a a = a := by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl | rfl | rfl
    · exact ⟨Present.of_get F.getP, F.fixP⟩
    · exact ⟨Present.of_get F.getC, F.fixC⟩
    · exact ⟨pB, F.fixB⟩
    · exact ⟨pV, F.fixV⟩
  have hnone : ∀ a, kpOf K (linkW bs) a = false → linkW bs a = none → K.fr a = none := by
    intro a hkp hw
    cases e : K.fr a with
    | none => rfl
    | some p =>
      have : kpOf K (linkW bs) a = true := by
        simp only [kpOf, e, hw, Option.isSome_some, Option.isNone_none, Bool.and_self]
      rw [this] at hkp
      cases hkp
  refine
    { num := checkNum_sound F.num
      heap := ?_
      unfr := ?_
      framed := ?_
      wide := ?_
      next := ?_
      grows := F.grows
      present := ?_
      inj := hinj
      presentBound := F.bound
      ctl := F.ctl
      stack := F.stack
      jobs := F.jobs
      stores := F.stores
      ffi := ⟨rfl, F.shift.toX F.inactive⟩
      heapSupp := F.heapSupp
      ctlSupp := F.ctlSupp
      stackSupp := F.stackSupp
      jobsSupp := F.jobsSupp
      storesSupp := F.storesSupp
      bigFixed := ?_
      bigExt := RData.big_ext _
      intr := F.intr }
  · intro a h ha hkp hw
    exact F.heap a h ha (fun hm => (hfr a).mpr hm (hnone a hkp hw))
  · intro a h ha hkp hw
    change K.fr (D.a a) = none
    cases e : K.fr (D.a a) with
    | none => rfl
    | some p =>
      have hm := (hfr _).mp (by rw [e]; exact Option.some_ne_none _)
      obtain ⟨hp, hfx⟩ := pFr _ hm
      have heq := hinj _ _ hp (Present.of_get ha) hfx
      rw [heq] at hm
      exact absurd (hnone a hkp hw) ((hfr a).mpr hm)
  · intro a hkp
    have hb : (K.fr a).isSome = true ∧ (linkW bs a).isNone = true := by
      simpa only [kpOf, Bool.and_eq_true] using hkp
    have hne : K.fr a ≠ none := by
      intro e
      have h1 := hb.1
      rw [e] at h1
      cases h1
    have hm := (hfr a).mp hne
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
    rcases hm with rfl | rfl | rfl | rfl
    · exact ⟨F.fixP, [], π.map natV, _, _, hP, F.getP, F.kindP, F.imgP⟩
    · exact ⟨F.fixC, [], γ.map natV, _, _, hC, F.getC, F.kindC, F.imgC⟩
    · have he : linkW bs D1Frames.buffer = some (.buf bs) := rfl
      have h2 := hb.2
      rw [he] at h2
      cases h2
    · have he : linkW bs D1Frames.view = some (.typed .i32 D1Frames.buffer 0 1) := rfl
      have h2 := hb.2
      rw [he] at h2
      cases h2
  · intro a w hw
    rcases linkW_domain hw with rfl | rfl
    · have he : linkW bs D1Frames.buffer = some (.buf bs) := rfl
      rw [he] at hw
      cases hw
      refine ⟨?_, F.fixB, (hfr _).mpr (by simp), pB, ?_, trivial⟩
      · simp only [kpOf, he, Option.isNone_some, Bool.and_false]
      · intro h hh
        rw [F.imgB, hh]
        rfl
    · have he : linkW bs D1Frames.view = some (.typed .i32 D1Frames.buffer 0 1) := rfl
      rw [he] at hw
      cases hw
      refine ⟨?_, F.fixV, (hfr _).mpr (by simp), pV, ?_, F.fixB⟩
      · simp only [kpOf, he, Option.isNone_some, Bool.and_false]
      · intro h hh
        rw [F.imgV, hh]
        rfl
  · intro k
    change D.a (s0.next + k) = _
    rw [← F.n0, RData.a_fresh, F.n1]
  · intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    change Present s1 (D.a a)
    by_cases hf : a ∈ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view]
    · rw [(pFr a hf).2]
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl | rfl | rfl
      · exact Present.of_get F.imgP
      · exact Present.of_get F.imgC
      · have hh : s1.heap.get D1Frames.buffer = some (D.map.hobj h) := by rw [F.imgB, ha]; rfl
        exact Present.of_get hh
      · have hh : s1.heap.get D1Frames.view = some (D.map.hobj h) := by rw [F.imgV, ha]; rfl
        exact Present.of_get hh
    · exact Present.of_get (F.heap a h ha hf)
  · intro i hi
    have hlo : K.lo = 18151 := hk.1
    have hhi : K.hi = 131072 := hk.2.1
    rw [hlo, hhi] at hi
    exact RData.big_fixed D F.band F.nh0 (by decide) i hi

theorem linkFrames (F : LinkFacts s0 s1 tab0 tab1 D inv θ P0 nJ) {M : Map} {K : Ctx} {bs : List Byte}
    (hk : Disp.Kp (D1Frames.typedJ bs) K) : Shift.framedNext M K s1 = K.fr := by
  funext a
  by_cases hf : K.fr a = none
  · exact (framedNext_none_iff (M := M) (s1 := s1) a).mpr hf |>.trans hf.symm
  · have ha := (hk.2.2 a).mp hf
    have he := List.all_eq_true.mp F.framesEmpty a ha
    exact framedNext_empty M K (List.isEmpty_iff.mp he)

/-- With the same native counters on both sides the relation's own room is the compaction's. -/
theorem linkRoomSame {NB T : Nat} {tk : Nat → Nat} {W : Nat → Option WFrame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {t : St FF.S} {S : SSrv} {C : CSrv}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W [] M ν K s1 S t C)
    (sameH : (mlxOf s1.ffi).next = (mlxOf s0.ffi).next) (sameN : (mlxOf s1.ffi).nnext = (mlxOf s0.ffi).nnext) :
    NRoom setupP (Host.Load.Layers.toLoad s0.ffi) (Host.Load.Layers.toLoad t.ffi) := by
  obtain ⟨P', hP, hf⟩ := hr.ffi.1
  obtain ⟨_, hE, hNE, _⟩ := Raised.restart (.inl rfl) hP
  constructor
  · have h := hf.load.mlx.hroom.2
    rw [hE] at h
    change (mlxOf t.ffi).next + (setupP.E - (mlxOf s1.ffi).next) < 2 ^ 46 at h
    rw [sameH] at h
    exact h
  · have h := hf.load.mlx.nroom.2.2
    rw [hNE] at h
    change (mlxOf t.ffi).nnext + (setupP.NE - (mlxOf s1.ffi).nnext) < 2 ^ 62 at h
    rw [sameN] at h
    exact h

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

/-- **The relation at the entry.** -/
theorem linkRel (F : LinkFacts s0 s1 tab0 tab1 D inv θ P0 nJ) {NB T cap : Nat} {tk : Nat → Nat}
    {bs : List Byte} {π γ : List Nat} {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) (D1Frames.typedW bs) []
      M ν K s1 ⟨tab1, []⟩ t C)
    (hk : Disp.KpJ (D1Frames.typedJ bs) cap K) (hP : K.fr 2665 = some ([], π.map natV))
    (hC : K.fr D1Frames.chunk = some ([], γ.map natV))
    (hroomN : NRoom setupP (Host.Load.Layers.toLoad s0.ffi) (Host.Load.Layers.toLoad t.ffi)) (hNB : NB ≤ P0.NL)
    (hD : K.D + (s1.next - s0.next) < Sim.bound) :
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) (D1Frames.typedW bs) []
      (((M.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf t.ffi).next).withJs) (Shift.valuation θ ν)
      ⟨Shift.framedNext M K s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩ s0 ⟨tab0, []⟩ t C := by
  have hmemo : K.fr 4910 = none := by
    cases e : K.fr 4910 with
    | none => rfl
    | some p =>
      have hm := (hk.1.2.2 4910).mp (by rw [e]; exact Option.some_ne_none _)
      exact absurd hm (by decide : 4910 ∉ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view])
  have hr0 := inactiveMemo hr.ofJ (linkW_agree bs hmemo)
  have hs := linkShift F hk.1 hP hC
  have hband : ∀ j : Int, ((mlxOf s0.ffi).next : Int) ≤ j ∧ j < setupP.E →
      ¬ BigFixed K.lo K.hi j ∧ 0 ≤ j ∧ j < 2 ^ 56 := by
    intro j hj
    have hlo : K.lo = 18151 := hk.1.1
    have hhi : K.hi = 131072 := hk.1.2.1
    have hl := F.loLe
    rw [hlo, hhi]
    change _ ∧ j < 131072 at hj
    unfold BigFixed
    constructor
    · omega
    · constructor <;> omega
  have hoff : t.next = s1.next + K.D := hr.offset
  have hg := F.grows
  have hc := Conv.full_compactQXD NB (P := setupP) (r := machReads T tk)
    (s0 := s0) (s1 := s1) (S0 := ⟨tab0, []⟩) (S1 := ⟨tab1, []⟩)
    F.raised hNB hr0 hs F.bigs F.free hband (fun _ h => nomatch h) (by omega) hroomN
  let N' := (M.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf t.ffi).next
  let K' : Ctx := ⟨Shift.framedNext M K s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩
  have hJs : NoBigSt (JsBad N') K'.base s0 :=
    noBigSt_of_above F.jsHeap F.jsRoots (fun j hj => by
      have hbad := jsBad_after (M := M) (N := N') (σ := D.map) hr.ffi.2 rfl
        (fun _ h => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) h) hj
      exact jsShiftBad_aboveR F.jsFix hbad)
  have hcJ := (hc.withJs (by change K.lo ≤ 2 ^ 56; rw [hk.1.1]; change 18151 ≤ 2 ^ 56; decide) hJs
    (fullRXD_withJs hc.ffi F.jsNative)).toJ (BigJs.withJs N')
  have hfr : K'.fr = K.fr := linkFrames F hk.1
  have hmemo' : K'.fr 4910 = none := by rw [hfr]; exact hmemo
  exact inactiveMemo hcJ (fun a ha => (linkW_agree bs hmemo' a ha).symm)

end

end Host.Ts.Sim.Compose.Post
