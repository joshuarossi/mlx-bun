import host.sim.compose.PostLink
import host.sim.compose.CompactDrop
import host.sim.CasesL
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Pf
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose.SetupChunk

/-! # A first tail's end into the pre-final cut

`I.pf` holds the prompt only: the tail's chunk, buffer and view are garbage after its forward, and the
template (a `tpl_template` from the tail's end) has collected them. `PfFacts` are the generated checks
that the tail's end holds a copy of it under a walked map, and `pfRel` the relation there, through the
compaction that drops those frames (`Conv.full_compactDropQXD`). -/

/-- The generated checks: `s1` holds a copy of `s0` under `D.map`, the prompt in place and empty; no
address of `s0` lands on a dropped frame. -/
structure PfFacts (s0 s1 : St FF.S) (tab0 tab1 : List SymE) (D : RData) (inv : PTrie Nat)
    (θ : Nat → SymE) (P0 : LoadP) (nJ : Nat) (drop : List Nat) : Prop where
  num : checkNum D.map θ ⟨tab0, []⟩ ⟨tab1, []⟩ = true
  heap : ∀ a h, s0.heap.get a = some h → a ≠ 2665 → s1.heap.get (D.a a) = some (D.map.hobj h)
  notDrop : ∀ a, Present s0 a → ∀ b ∈ drop, D.a a ≠ b
  fixP : D.a 2665 = 2665
  getP : s0.heap.get 2665 = some (.obj (Template.objOf s0 2665))
  kindP : (Template.objOf s0 2665).kind = .array []
  imgP : s1.heap.get 2665 =
    some (.obj { D.map.obj (Template.objOf s0 2665) with kind := .array ([] ++ arrOf s1 2665) })
  emptyP : arrOf s1 2665 = []
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
  {P0 : LoadP} {nJ : Nat} {drop : List Nat}

/-- The frame the pre-final cut keeps. -/
abbrev keepP : Nat → Bool := fun a => Nat.beq a 2665

theorem pfShift (F : PfFacts s0 s1 tab0 tab1 D inv θ P0 nJ drop) {K : Ctx} {π : List Nat}
    (hfr : ∀ a, K.fr a ≠ none ↔ a ∈ 2665 :: drop) (hlo : K.lo = 18151) (hhi : K.hi = 131072)
    (hP : K.fr 2665 = some ([], π.map natV)) :
    ShiftD FF (fun σ x y => x = s0.ffi ∧ Conv.FullShiftQX P0 tab0.length σ x y) D.map θ keepP noFrames K
      s0 ⟨tab0, []⟩ s1 ⟨tab1, []⟩ := by
  have hinj : ∀ a b, Present s0 a → Present s0 b → D.a a = D.a b → a = b :=
    a_inj (fun x hx => by rw [F.n0]; exact F.bound x hx) F.ren
  have hne : ∀ {a : Nat}, keepP a = false → a ≠ 2665 := by
    intro a hk e
    subst e
    simp at hk
  refine
    { num := checkNum_sound F.num
      heap := ?_
      unfr := ?_
      framed := ?_
      wide := fun _ _ h => nomatch h
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
  · intro a h ha hkp _
    exact F.heap a h ha (hne hkp)
  · intro a h ha hkp _
    change K.fr (D.a a) = none
    cases e : K.fr (D.a a) with
    | none => rfl
    | some p =>
      have hm := (hfr _).mp (by rw [e]; exact Option.some_ne_none _)
      rcases List.mem_cons.mp hm with h1 | h1
      · exact absurd (hinj _ _ (Present.of_get ha) (Present.of_get F.getP) (h1.trans F.fixP.symm)) (hne hkp)
      · exact absurd rfl (F.notDrop a (Present.of_get ha) _ h1)
  · intro a hkp
    obtain rfl : a = 2665 := Nat.eq_of_beq_eq_true hkp
    exact ⟨F.fixP, [], π.map natV, _, _, hP, F.getP, F.kindP, F.imgP⟩
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
    · exact Present.of_get (F.heap a h ha hf)
  · intro i hi
    rw [hlo, hhi] at hi
    exact RData.big_fixed D F.band F.nh0 (by decide) i hi

/-- The frames after the link: the prompt's, nothing else. -/
theorem drop_prompt (F : PfFacts s0 s1 tab0 tab1 D inv θ P0 nJ drop) (M : Map) (K : Ctx) (a : Nat) :
    dropNext M K keepP noFrames s1 a = if a = 2665 then K.fr 2665 else none := by
  by_cases h : a = 2665
  · subst h
    rw [if_pos rfl]
    exact Post.framedNext_empty M K F.emptyP
  · rw [if_neg h]
    have hk : keepP a = false := by
      cases e : keepP a with
      | false => rfl
      | true => exact absurd (Nat.eq_of_beq_eq_true e) h
    simp [dropNext, hk]

/-- **The relation at the template.** -/
theorem pfRel (F : PfFacts s0 s1 tab0 tab1 D inv θ P0 nJ drop) {NB T : Nat} {tk : Nat → Nat}
    {W : Nat → Option WFrame} {π : List Nat} {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W []
      M ν K s1 ⟨tab1, []⟩ t C)
    (hfr : ∀ a, K.fr a ≠ none ↔ a ∈ 2665 :: drop) (hlo : K.lo = 18151) (hhi : K.hi = 131072)
    (hP : K.fr 2665 = some ([], π.map natV))
    (hroomN : NRoom setupP (Host.Load.Layers.toLoad s0.ffi) (Host.Load.Layers.toLoad t.ffi))
    (hNB : NB ≤ P0.NL) (hD : K.D + (s1.next - s0.next) < Sim.bound) :
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      (((M.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf t.ffi).next).withJs) (Shift.valuation θ ν)
      ⟨dropNext M K keepP noFrames s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩ s0 ⟨tab0, []⟩ t C := by
  have hs := pfShift F hfr hlo hhi hP
  have hband : ∀ j : Int, ((mlxOf s0.ffi).next : Int) ≤ j ∧ j < setupP.E →
      ¬ BigFixed K.lo K.hi j ∧ 0 ≤ j ∧ j < 2 ^ 56 := by
    intro j hj
    have hl := F.loLe
    rw [hlo, hhi]
    change _ ∧ j < 131072 at hj
    unfold BigFixed
    constructor
    · omega
    · constructor <;> omega
  have hoff : t.next = s1.next + K.D := hr.offset
  have hg := F.grows
  have hc := Conv.full_compactDropQXD NB (P := setupP) (r := machReads T tk)
    (s0 := s0) (s1 := s1) (S0 := ⟨tab0, []⟩) (S1 := ⟨tab1, []⟩) (W1 := W) (W0 := noFrames) (kp := keepP)
    F.raised hNB hr.ofJ hs (fun _ _ h => nomatch h) F.bigs F.free hband (fun _ h => nomatch h) (by omega) hroomN
  let N' := (M.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf t.ffi).next
  let K' : Ctx := ⟨dropNext M K keepP noFrames s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩
  have hJs : NoBigSt (JsBad N') K'.base s0 :=
    noBigSt_of_above F.jsHeap F.jsRoots (fun j hj => by
      have hbad := jsBad_after (M := M) (N := N') (σ := D.map) hr.ffi.2 rfl
        (fun _ h => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) h) hj
      exact Post.jsShiftBad_aboveR F.jsFix hbad)
  have hcJ := (hc.withJs (by change K.lo ≤ 2 ^ 56; rw [hlo]; change 18151 ≤ 2 ^ 56; decide) hJs
    (fullRXD_withJs hc.ffi F.jsNative)).toJ (BigJs.withJs N')
  have hmemo' : K'.fr 4910 = none := by
    change dropNext M K keepP noFrames s1 4910 = none
    rw [drop_prompt F]
    rfl
  exact inactiveMemo hcJ (fun a ha => wideInactive hmemo' a ha)

end

/-- What the pre-final cut holds: the prompt, the reserved values, and the variables its table reads at
the quantities of the tail just finished. -/
structure PfBook (T : Nat) (tk : Nat → Nat) (cap : Nat) (π : List Nat) (x : SegInst FF) : Prop where
  vocab : ∀ k ∈ π, k < 248320
  valuation : VBOkF loopVB x.ν
  promptValue : x.ν 9 = F64.ofNat π.length
  rowValue : x.ν 10 = F64.ofNat (π.length - 1)
  offsetValue : x.ν 11 = F64.ofNat (π.length - 1)
  capValue : x.ν 16 = F64.ofNat (capL (π.length - 1))
  context : Disp.KpJ setupJ cap x.K
  prompt : x.K.fr 2665 = some ([], π.map natV)
  inputs : setupInputs T tk x

/-- **The pre-final cut**: a prompt of length `L` at the template `s`. -/
noncomputable def cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S =>
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP [] x.M x.ν x.K s S x.t x.C ∧
    PfBook T tk cap π x
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt H N s x.t

end Host.Ts.Sim.Compose.Pf
