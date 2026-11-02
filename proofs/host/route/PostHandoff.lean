import host.route.ColdEntry
import host.route.Handoff
import host.route.RestartE
import host.route.PostReframe
import host.sim.compose.SetupKeep
import host.sim.template.SetupP
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load Host.Load.Program Host.Load.Run.Prompt Host.Load.Layers
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Iter (TplInputs)
open Host.Mlx.SimGraph.Mach (refPrompt)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # From POST's end to the decode loop

POST's end relates to the decode template through the prompt array's reframing (`RelB.reframe`), the hand-off's restart
(`Conv.full_handoffTbE`) and the frames the loop keeps on `forwarded` and `emitted` (`slotW_frame`).

* `ShiftH`, `ShiftE.ofH`: the template's shift facts, without `grows`.
* `RelB.withFr`, `RelB.atVal`: the relation at other frames, at another valuation agreeing on the table.
* `HandWalk`: what the walk from the template to POST's end checks.
* `postHandoff`: POST's end, its book and the reference held through `L + 2` give the decode cut's invariant. -/

/-- `Template.ShiftJS` without `grows`: POST's end stops below the template's start. -/
structure ShiftH (F : Ffi) (σ : Map) (θ : Nat → SymE) (K : Sim.Ctx) (s0 : St F.S) (S0 : SSrv) (s1 : St F.S) (S1 : SSrv) : Prop where
  num : ∀ i e, nth? S0.tab i = some e → S1.val (σ.num i) = some (e.subst θ)
  heap : ∀ a h, s0.heap.get a = some h → K.fr a = none → s1.heap.get (σ.a a) = some (σ.hobj h)
  framed : ∀ a pre pre', K.fr a = some (pre, pre') → σ.a a = a ∧
    ∃ o xs, s0.heap.get a = some (.obj o) ∧ o.kind = .array pre ∧
      s1.heap.get a = some (.obj { σ.obj o with kind := .array (pre ++ xs) })
  next : ∀ k, σ.a (s0.next + k) = s1.next + k
  present : ∀ a, Present s0 a → Present s1 (σ.a a)
  inj : ∀ a b, Present s0 a → Present s0 b → σ.a a = σ.a b → a = b
  presentBound : ∀ a, Present s0 a → a < s0.next
  framedPresent : ∀ a p, K.fr a = some p → Present s0 a
  ctl : s1.ctl = σ.ctl s0.ctl
  stack : s1.stack = s0.stack.map σ.frame
  jobs : s1.jobs = s0.jobs.map σ.job
  stores : s1.stores = σ.stores s0.stores
  heapSupp : ∀ a h, s0.heap.get a = some h → Supp.hobj (Present s0) S0.tab.length h
  ctlSupp : Supp.ctl (Present s0) S0.tab.length s0.ctl
  stackSupp : ∀ f ∈ s0.stack, Supp.frame (Present s0) S0.tab.length f
  jobsSupp : ∀ j ∈ s0.jobs, Supp.job (Present s0) S0.tab.length j
  storesSupp : Supp.stores (Present s0) S0.tab.length s0.stores
  bigFixed : ∀ i, BigFixed K.lo K.hi i → σ.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → σ.big (ptrInt (.ext r) off) = ptrInt (.ext (σ.region r)) off
  intr : ∀ a, a < aFirst → σ.a a = a

/-- **The shift from the template's facts** at the end's context without the frames' addresses (`ShiftD.ofJS`). -/
theorem ShiftE.ofH {F : Ffi} {FS : Map → F.S → F.S → Prop} {σ : Map} {θ : Nat → SymE} {K : Sim.Ctx}
    {W : Nat → Option WFrame} {s0 s1 : St F.S} {S0 S1 : SSrv} (h : ShiftH F σ θ (K.unW W) s0 S0 s1 S1)
    (hffi : FS σ s0.ffi s1.ffi)
    (hwide : ∀ a w, W a = some w → K.fr a ≠ none ∧ σ.a a = a ∧ Present s0 a ∧ WFix σ (Present s0) w) :
    ShiftE F FS σ θ (kpOf K W) W K s0 S0 s1 S1 := by
  have hu0 : ∀ a, W a = none → (K.unW W).fr a = K.fr a := fun a hw => by
    show (bif (W a).isSome then none else K.fr a) = K.fr a
    rw [hw]; rfl
  have hu1 : ∀ a w, W a = some w → (K.unW W).fr a = none := fun a w hw => by
    show (bif (W a).isSome then none else K.fr a) = none
    rw [hw]; rfl
  have hkpf : ∀ a, kpOf K W a = false → W a = none → K.fr a = none := fun a hk hw => by
    unfold kpOf at hk
    rw [hw] at hk
    cases hf : K.fr a with
    | none => rfl
    | some p => rw [hf] at hk; cases hk
  exact {
    num := h.num
    heap := fun a hh hg hk hw => h.heap a hh hg (by rw [hu0 a hw]; exact hkpf a hk hw)
    unfr := fun a hh hg hk hw => by
      have hKa := hkpf a hk hw
      have hpa : Present s0 a := Present.of_get hg
      cases hk1 : K.fr (σ.a a) with
      | none => rfl
      | some p =>
        exfalso
        cases hw1 : W (σ.a a) with
        | some w =>
          obtain ⟨-, hfix, hp, -⟩ := hwide _ w hw1
          have e := h.inj a (σ.a a) hpa hp hfix.symm
          rw [← e, hw] at hw1
          cases hw1
        | none =>
          obtain ⟨pre, pre'⟩ := p
          have hq0 : (K.unW W).fr (σ.a a) = some (pre, pre') := by rw [hu0 _ hw1, hk1]
          have hfix := (h.framed (σ.a a) pre pre' hq0).1
          have e := h.inj a (σ.a a) hpa (h.framedPresent _ _ hq0) hfix.symm
          rw [← e, hKa] at hk1
          cases hk1
    framed := fun a hk => by
      unfold kpOf at hk
      simp only [Bool.and_eq_true, Option.isSome_iff_exists, Option.isNone_iff_eq_none] at hk
      obtain ⟨⟨p, hp⟩, hw⟩ := hk
      obtain ⟨pre, pre'⟩ := p
      have hq0 : (K.unW W).fr a = some (pre, pre') := by rw [hu0 a hw, hp]
      obtain ⟨hfix, o, xs, hg0, hko, hg1⟩ := h.framed a pre pre' hq0
      exact ⟨hfix, pre, pre', o, xs, hp, hg0, hko, hg1⟩
    wide := fun a w hw => by
      obtain ⟨hK, hfix, hp, hwf⟩ := hwide a w hw
      refine ⟨by simp [kpOf, hw], hfix, hK, hp, fun hh hg => ?_, hwf⟩
      have := h.heap a hh hg (hu1 a w hw)
      rwa [hfix] at this
    next := h.next
    present := h.present
    inj := h.inj
    presentBound := h.presentBound
    ctl := h.ctl
    stack := h.stack
    jobs := h.jobs
    stores := h.stores
    ffi := hffi
    heapSupp := h.heapSupp
    ctlSupp := h.ctlSupp
    stackSupp := h.stackSupp
    jobsSupp := h.jobsSupp
    storesSupp := h.storesSupp
    bigFixed := h.bigFixed
    bigExt := h.bigExt
    intr := h.intr }

/-- An empty oracle holds at every valuation. -/
theorem good_nil (ν : Nat → F64) : Good ν ([] : List Ans) := by
  intro q hq
  cases hq

section Rel
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Sim.Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- The relation at other frames. -/
theorem RelB.withFr (h : RelB F FR W stk M ν K s S t C) {fr' : Nat → Option (List Val × List Val)}
    (hfr : ∀ b h', s.heap.get b = some h' → SlotW M K.fr W b h' (t.heap.get (M.a b)) → SlotW M fr' W b h' (t.heap.get (M.a b)))
    (hpres : ∀ b p, fr' b = some p → Present s b) : RelB F FR W stk M ν { K with fr := fr' } s S t C :=
  { h with
    heap := fun b h' hb => hfr b h' hb (h.heap b h' hb)
    framedPresent := hpres }

/-- The relation at another valuation of the same table's values. -/
theorem RelB.atVal {tab : List SymE} (h : RelB F FR W stk M ν K s ⟨tab, []⟩ t C) {ν' : Nat → F64}
    (hev : ∀ i e, nth? tab i = some e → e.eval ν' = e.eval ν) : RelB F FR W stk M ν' K s ⟨tab, []⟩ t C :=
  { h with
    srv := ⟨fun i e he => by rw [hev i e he]; exact h.srv.num i e he, good_nil _⟩ }

end Rel

/-- The frames at the walk's check: the prompt alone, its template prefix `x0`. -/
def frH (x0 q : List Val) (a : Nat) : Option (List Val × List Val) := bif Nat.beq a 2665 then some (x0, q) else none

/-- The frames of the hand-off's restart: the prompt, and the further frames `W` declares. -/
def frE (W : Nat → Option WFrame) (x0 q : List Val) (a : Nat) : Option (List Val × List Val) :=
  bif Nat.beq a 2665 then some (x0, q) else bif (W a).isSome then some ([], []) else none

/-- POST's end with its prompt array holding the template's elements, the template's queue. -/
def handEnd (sE : St FF.S) (o : Obj) (x0 : List Val) : St FF.S :=
  (withArr sE 2665 o x0).setFfi (fullSetTokens (withArr sE 2665 o x0).ffi [.ref 2])

/-- **What the walk from the decode template's start to POST's end checks.** -/
structure HandWalk (Pd : LoadP) (W : Nat → Option WFrame) (sE : St FF.S) (SE : SSrv) (o : Obj) (s0 : St FF.S) (tab0 : List SymE)
    (κ : Map) (θ : Nat → SymE) (oF oM : Obj) (iE : Nat) : Prop where
  getE : sE.heap.get 2665 = some (.obj o)
  kindE : o.kind = .array []
  suppE : Supp.kind (Present sE) SE.tab.length (.array (arrOf s0 2665))
  tokE : (mlxOf sE.ffi).tokens = [.ref 2]
  itemE : (mlxOf sE.ffi).items.get 17776 = some (.ref 1)
  nodeE : ((mlxOf sE.ffi).nodes.get 17776).isSome = true
  tab1E : nth? SE.tab 1 = some (.var 1)
  tab2E : nth? SE.tab 2 = some (.var 2)
  ne : (handEnd sE o (arrOf s0 2665)).ffi ≠ s0.ffi
  shift : ∀ q (K : Sim.Ctx), K.fr = frH (arrOf s0 2665) q → K.lo = setupP.lo → K.hi = setupP.E →
    ShiftH FF κ θ K s0 ⟨tab0, []⟩ (handEnd sE o (arrOf s0 2665)) SE
  shiftFfi : Conv.FullShiftH Pd tab0.length κ s0.ffi (handEnd sE o (arrOf s0 2665)).ffi
  wide : ∀ a w, W a = some w → κ.a a = a ∧ Present s0 a ∧ WFix κ (Present s0) w
  w2665 : W 2665 = none
  wPresent : ∀ a, W a ≠ none → Present sE a
  big : bigsOutB (mlxOf s0.ffi).next Pd.E (mlxOf s0.ffi) = true
  free : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < Pd.E) s0.trace s0
  nextLo : sE.next ≤ s0.next
  nextHi : s0.next ≤ sE.next + 13
  hLo : Pd.lo = setupP.lo
  hE : Pd.E = setupP.E
  hNE : Pd.NE = setupP.NE
  lo0 : Pd.lo ≤ (mlxOf s0.ffi).next
  nE : (mlxOf sE.ffi).next ≤ 2 ^ 40
  nnE : (mlxOf sE.ffi).nnext ≤ 2 ^ 40
  getF : s0.heap.get addrPrompt.fwd = some (.obj oF)
  kindF : oF.kind = .array (arrOf s0 addrPrompt.fwd)
  getM : s0.heap.get addrPrompt.emit = some (.obj oM)
  kindM : oM.kind = .array (arrOf s0 addrPrompt.emit)
  wF : W addrPrompt.fwd = none
  wM : W addrPrompt.emit = none
  arrM : arrOf s0 addrPrompt.emit = [.num (.ref iE)]
  numM : κ.num iE = .ref 1
  numT : κ.num addrPrompt.tok = .ref 2

theorem frE_2665 (W : Nat → Option WFrame) (x0 q : List Val) : frE W x0 q 2665 = some (x0, q) := rfl

theorem frE_ne {W : Nat → Option WFrame} {x0 q : List Val} {a : Nat} (h : a ≠ 2665) :
    frE W x0 q a = bif (W a).isSome then some ([], []) else none := by
  unfold frE
  rw [beq_false h]
  rfl

theorem framedNext_isSome {F : Ffi} (M : Map) (K : Sim.Ctx) (s : St F.S) (a : Nat) :
    (Shift.framedNext M K s a).isSome = (K.fr a).isSome := by
  unfold Shift.framedNext
  cases K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    dsimp only
    cases s.heap.get a with
    | none => rfl
    | some h =>
      cases h with
      | cell _ => rfl
      | obj o =>
        dsimp only
        cases o.kind <;> rfl


/-- A table entry reading only the variables `u`. -/
def readsOnly (u : Nat → Bool) : SymE → Bool
  | .lit _ => true
  | .var v => u v
  | .bin _ a b => readsOnly u a && readsOnly u b
  | .un _ a => readsOnly u a

theorem eval_of_readsOnly {u : Nat → Bool} {ν ν' : Nat → F64} (h : ∀ v, u v = true → ν v = ν' v) :
    ∀ e, readsOnly u e = true → e.eval ν = e.eval ν'
  | .lit _, _ => rfl
  | .var v, hr => h v hr
  | .bin op a b, hr => by
    simp only [readsOnly, Bool.and_eq_true] at hr
    simp only [SymE.eval, eval_of_readsOnly h a hr.1, eval_of_readsOnly h b hr.2]
  | .un op a, hr => by
    simp only [SymE.eval, eval_of_readsOnly h a hr]

section Hand
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat}

/-- **The relation at POST's end under the hand-off's frames.** -/
theorem reframeEnd {NB T : Nat} {tk : Nat → Nat} {W : Nat → Option WFrame} {Pd : LoadP} {sE : St FF.S} {SE : SSrv} {o : Obj}
    {s0 : St FF.S} {tab0 : List SymE} {κ : Map} {θ : Nat → SymE} {oF oM : Obj} {iE : Nat}
    (hw : HandWalk Pd W sE SE o s0 tab0 κ θ oF oM iE) {x : SegInst FF}
    (hr : RelF FF (FullRXD { setupP with rest := machReads T tk } NB) W x.M x.ν x.K sE SE x.t x.C) {q : List Val}
    (hq : x.K.fr 2665 = some ([], q)) (hdom : ∀ a, x.K.fr a ≠ none ↔ a = 2665 ∨ W a ≠ none) :
    RelF FF (FullRXD { setupP with rest := machReads T tk } NB) W x.M x.ν { x.K with fr := frE W (arrOf s0 2665) q }
      (withArr sE 2665 o (arrOf s0 2665)) SE x.t x.C := by
  refine Host.Route.RelB.reframe hr hw.getE (by decide) (arrOf s0 2665) q hw.w2665 hw.suppE hw.kindE hq (frE_2665 _ _ _) ?_ ?_
  · intro b h' hb hg hs
    rw [show (frE W (arrOf s0 2665) q) = fun a => frE W (arrOf s0 2665) q a from rfl]
    cases hwb : W b with
    | none =>
      have h0 : x.K.fr b = none := by
        by_contra hn
        rcases (hdom b).mp hn with e | e
        · exact hb e
        · exact e hwb
      have h1 : frE W (arrOf s0 2665) q b = none := by rw [frE_ne hb, hwb]; rfl
      exact slotW_same (.inr (h1.trans h0.symm)) hs
    | some w =>
      have h1 : frE W (arrOf s0 2665) q b = some ([], []) := by rw [frE_ne hb, hwb]; rfl
      have hfb : x.K.fr b ≠ none := (hdom b).mpr (.inr (by rw [hwb]; simp))
      refine slotW_same (.inl ⟨by simp [hwb], Option.ne_none_iff_isSome.mp hfb, by simp [h1]⟩) hs
  · intro b p hp
    by_cases hb : b = 2665
    · subst hb
      exact Present.of_get hw.getE
    · rw [frE_ne hb] at hp
      cases hwb : W b with
      | none => rw [hwb] at hp; cases hp
      | some w => exact hw.wPresent b (by rw [hwb]; simp)

/-- At POST's end the template's first two symbols are the target's: its queue and its one item say so. -/
theorem end_nums {NB T : Nat} {tk : Nat → Nat} {W : Nat → Option WFrame} {sE : St FF.S} {SE : SSrv} {x : SegInst FF}
    (hr : RelF FF (FullRXD { setupP with rest := machReads T tk } NB) W x.M x.ν x.K sE SE x.t x.C)
    (htok : (mlxOf sE.ffi).tokens = [.ref 2]) (hit : (mlxOf sE.ffi).items.get 17776 = some (.ref 1))
    (hn : ((mlxOf sE.ffi).nodes.get 17776).isSome = true) (hfrom : FromLoad T tk x) :
    x.M.num 1 = .ref 1 ∧ x.M.num 2 = .ref 2 := by
  obtain ⟨Pm, hP, r0⟩ := hr.ffi
  have hmr : G.MR Pm NB x.M SE.tab.length (mlxOf sE.ffi) (mlxOf x.t.ffi) := r0.load.mlx
  have hrest : Pm.rest = machReads T tk := hP.rest
  have ht : (mlxOf x.t.ffi).tokens = x.M.num 2 :: machReads T tk := by
    have h : (mlxOf x.t.ffi).tokens = (mlxOf sE.ffi).tokens.map x.M.nv ++ Pm.rest := hmr.tokensX
    rw [htok, hrest] at h
    exact h
  obtain ⟨h2, hi⟩ := hfrom.queue ht
  have hi' : (mlxOf x.t.ffi).items.get (x.M.node 17776) = ((mlxOf sE.ffi).items.get 17776).map x.M.nv := hmr.items 17776 hn
  rw [hit] at hi'
  exact ⟨hi _ _ hi', h2⟩

theorem framedNext_prompt {F : Ffi} {M : Map} {K : Sim.Ctx} {s : St F.S} {x0 q : List Val} {o : Obj}
    (hK : K.fr 2665 = some (x0, q)) (hg : s.heap.get 2665 = some (.obj o)) (hk : o.kind = .array x0) :
    Shift.framedNext M K s 2665 = some (x0, q) := by
  unfold Shift.framedNext
  rw [hK]
  dsimp only
  rw [hg]
  dsimp only
  rw [hk]
  simp [Map.vals]

/-- **The hand-off.** POST's end, its book and the reference held through `L + 2` give the decode cut's invariant. -/
theorem postHandoff {NB T cap H N : Nat} {tk : Nat → Nat} {W : Nat → Option WFrame} {Pd : LoadP} {sE : St FF.S} {SE : SSrv} {o : Obj}
    {s0 : St FF.S} {tab0 : List SymE} {κ : Map} {θ : Nat → SymE} {oF oM : Obj} {iE : Nat}
    (hw : HandWalk Pd W sE SE o s0 tab0 κ θ oF oM iE) (hNB : NB ≤ Pd.NL) {Fr : LoopFramesA addrPrompt}
    (hX : Fr.X 2665 = some (arrOf s0 2665, π.map natV)) (hXW : ∀ a, W a ≠ none → Fr.X a ≠ none)
    (hXn : ∀ a, Fr.X a ≠ none → a = 2665 ∨ W a ≠ none) {fixA : List Nat} (hκfix : ∀ a ∈ fixA, κ.a a = a)
    {ρ : Nat → F64} {I : TplInputs} {B : Sim.LoopBase} {toks : Nat → Nat → Nat} {Cr : Nat → List (Option Nat × Option Nat)}
    (hkr : κ.node I.read = toks π.length 1) (hkf : κ.node I.fed = toks π.length 2)
    (hkc : I.caches.map (fun p => (p.1.map κ.node, p.2.map κ.node)) = Cr π.length)
    (hH : H ≤ 2 ^ 40) (hN : N ≤ 2 ^ 40) (hBD : cap ≤ B.D)
    (hBH : (mlxOf sE.ffi).next + H ≤ (mlxOf s0.ffi).next + B.H)
    (hBN : (mlxOf sE.ffi).nnext + N ≤ (mlxOf s0.ffi).nnext + B.N) {x : SegInst FF}
    (hr : RelF FF (FullRXD { setupP with rest := machReads T tk } NB) W x.M x.ν x.K sE SE x.t x.C)
    (hq : x.K.fr 2665 = some ([], π.map natV)) (hdom : ∀ a, x.K.fr a ≠ none ↔ a = 2665 ∨ W a ≠ none)
    (hlo : x.K.lo = setupP.lo) (hhi : x.K.hi = setupP.E) (hD : x.K.D ≤ cap) (hoff : 13 ≤ x.K.D)
    (hres : ∀ j, j < 9 → x.ν j = machVal T tk j) (hnat : Compose.NativeAt H N sE x.t)
    (hval : ∀ i e, nth? tab0 i = some e → e.eval (valL ρ T tk π.length 1 0) = e.eval (Shift.valuation θ x.ν))
    (hfrom : FromLoad T tk x) (hfix : ∀ a ∈ fixA, x.M.a a = a) (hm : memPost P KR NE net env π 2 toks Cr π.length x) :
    ∃ kind, (decCutFirstFb NB addrPrompt (machGxV P KR NE net env π kind NB I) W Pd Fr s0 tab0 fixA
      (valL ρ T tk π.length) tk (.ref 2 :: machReads T tk) [.num (.ref 1)] B).Inv x.t x.C := by
  obtain ⟨kind, hp⟩ := hm rfl
  refine ⟨kind, ?_⟩
  obtain ⟨hn1, hn2⟩ := end_nums hr hw.tokE hw.itemE hw.nodeE hfrom
  have h1 := reframeEnd hw hr hq hdom
  generalize hK1 : ({ x.K with fr := frE W (arrOf s0 2665) (π.map natV) } : Sim.Ctx) = K1 at h1
  have hK1fr : K1.fr = frE W (arrOf s0 2665) (π.map natV) := by rw [← hK1]
  have hK1lo : K1.lo = x.K.lo := by rw [← hK1]
  have hK1hi : K1.hi = x.K.hi := by rw [← hK1]
  have hu : (K1.unW W).fr = frH (arrOf s0 2665) (π.map natV) := by
    funext a
    show (bif (W a).isSome then none else K1.fr a) = _
    rw [hK1fr]
    by_cases ha : a = 2665
    · subst ha
      rw [hw.w2665]
      rfl
    · unfold frH
      rw [frE_ne ha, beq_false ha]
      cases W a <;> rfl
  have hsh := hw.shift (π.map natV) (K1.unW W) hu (hK1lo.trans hlo) (hK1hi.trans hhi)
  have hs2 := ShiftE.ofH (FS := fun σ y z => y = s0.ffi ∧ Conv.FullShiftH Pd tab0.length σ y z) (K := K1) (W := W) hsh
    ⟨rfl, hw.shiftFfi⟩ (fun a w ha => by
      obtain ⟨f, pr, w'⟩ := hw.wide a w ha
      have hne : a ≠ 2665 := by
        rintro rfl
        rw [hw.w2665] at ha
        cases ha
      refine ⟨?_, f, pr, w'⟩
      rw [hK1fr, frE_ne hne, ha]
      simp)
  have hE0 : Pd.E = 131072 := hw.hE
  have hNE0 : Pd.NE = 2 ^ 40 := hw.hNE
  have hoffs := hr.offset
  have hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < Pd.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56 := by
    rintro i ⟨a, b⟩
    have e1 : (K1.lo : Int) ≤ ((mlxOf s0.ffi).next : Int) := by
      rw [hK1lo, hlo, ← hw.hLo]
      exact_mod_cast hw.lo0
    have e2 : (K1.hi : Int) = Pd.E := by rw [hK1hi, hhi, hw.hE]
    have e3 : (Pd.E : Int) = 131072 := by rw [hE0]; rfl
    refine ⟨?_, by omega, by omega⟩
    unfold BigFixed
    rintro (h | ⟨_, h⟩ | ⟨h, _⟩) <;> omega
  have hroom : x.t.next - s0.next < Sim.bound := by
    have := hr.room
    have := hw.nextLo
    omega
  have hge : s0.next ≤ x.t.next := by
    have := hw.nextHi
    omega
  have hroomN : NRoom Pd (toLoad s0.ffi) (toLoad x.t.ffi) := by
    obtain ⟨a, b⟩ := hnat
    have c1 := hw.nE
    have c2 := hw.nnE
    constructor
    · change (mlxOf x.t.ffi).next + (Pd.E - (mlxOf s0.ffi).next) < 2 ^ 46
      omega
    · change (mlxOf x.t.ffi).nnext + (Pd.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
      omega
  have hrel := Conv.full_handoffTbE NB (Pp := setupP) (P0 := Pd) (r := machReads T tk) (tk := .ref 2) (τ := [])
    (S0 := ⟨tab0, []⟩) rfl hw.hLo hw.hE hw.hNE hNB h1 hw.tokE hw.ne hs2 hw.big hw.free hband (good_nil _) hroom hge hroomN
  generalize hM' : (x.M.after κ).rebig (mlxOf s0.ffi).next Pd.E (mlxOf x.t.ffi).next = M' at hrel
  have hM'a : ∀ a, M'.a a = x.M.a (κ.a a) := fun a => by rw [← hM']; rfl
  have hM'num : ∀ i, M'.num i = x.M.nv (κ.num i) := fun i => by rw [← hM']; rfl
  have hK'2665 : Shift.framedNext x.M K1 (handEnd sE o (arrOf s0 2665)) 2665 = some ((arrOf s0 2665), π.map natV) :=
    framedNext_prompt (o := { o with kind := .array (arrOf s0 2665) }) (by rw [hK1fr]; rfl)
      (Host.Ts.Sim.Full.get_set_eq_of_lt _ _ (by decide)) rfl
  have hE2 : M'.vals (arrOf s0 addrPrompt.emit) = [.num (.ref 1)] := by
    rw [hw.arrM]
    show [Val.num (M'.num iE)] = _
    rw [hM'num, hw.numM]
    show [Val.num (x.M.num 1)] = _
    rw [hn1]
  generalize hp1 : M'.vals (arrOf s0 addrPrompt.fwd) = p1
  have hfrF : frA addrPrompt s0 Fr.X p1 [.num (.ref 1)] addrPrompt.fwd = some (arrOf s0 addrPrompt.fwd, M'.vals (arrOf s0 addrPrompt.fwd)) := by
    rw [hp1]
    exact frA_fwd _ _ _ _ _
  have hfrM : frA addrPrompt s0 Fr.X p1 [.num (.ref 1)] addrPrompt.emit = some (arrOf s0 addrPrompt.emit, M'.vals (arrOf s0 addrPrompt.emit)) := by
    rw [hE2]
    rfl
  have hfX : ∀ b, b ≠ addrPrompt.fwd → b ≠ addrPrompt.emit → frA addrPrompt s0 Fr.X p1 [.num (.ref 1)] b = Fr.X b := by
    intro b hF hM
    unfold frA
    rw [beq_false hF, beq_false hM]
    rfl
  have hnf : ∀ b, b ≠ 2665 → W b = none → K1.fr b = none := by
    intro b hb hwb
    rw [hK1fr, frE_ne hb, hwb]
    rfl
  have hne2F : addrPrompt.fwd ≠ 2665 := by decide
  have hne2M : addrPrompt.emit ≠ 2665 := by decide
  have hnx : ∀ b, K1.fr b = none → Shift.framedNext x.M K1 (handEnd sE o (arrOf s0 2665)) b = none := by
    intro b hb
    unfold Shift.framedNext
    rw [hb]
  have hrel2 := RelB.withFr hrel (fr' := frA addrPrompt s0 Fr.X p1 [.num (.ref 1)]) (by
      intro b h' hb hs
      by_cases hbF : b = addrPrompt.fwd
      · subst hbF
        have e : h' = .obj oF := by
          rw [hw.getF] at hb
          exact (Option.some.inj hb).symm
        exact slotW_frame hw.wF (hnx _ (hnf _ hne2F hw.wF)) hfrF ⟨oF, [], e, by rw [List.append_nil]; exact hw.kindF⟩ hs
      · by_cases hbM : b = addrPrompt.emit
        · subst hbM
          have e : h' = .obj oM := by
            rw [hw.getM] at hb
            exact (Option.some.inj hb).symm
          exact slotW_frame hw.wM (hnx _ (hnf _ hne2M hw.wM)) hfrM ⟨oM, [], e, by rw [List.append_nil]; exact hw.kindM⟩ hs
        · have hf := hfX b hbF hbM
          by_cases hb2 : b = 2665
          · subst hb2
            refine slotW_same (.inr ?_) hs
            rw [hf, hX]
            exact hK'2665.symm
          · cases hwb : W b with
            | none =>
              refine slotW_same (.inr ?_) hs
              have h0 : Fr.X b = none := by
                by_contra hn
                rcases hXn b hn with e | e
                · exact hb2 e
                · exact e hwb
              rw [hf, h0]
              exact (hnx b (hnf b hb2 hwb)).symm
            | some w =>
              refine slotW_same (.inl ⟨by simp [hwb], ?_, ?_⟩) hs
              · show (Shift.framedNext x.M K1 (handEnd sE o (arrOf s0 2665)) b).isSome = true
                rw [framedNext_isSome, hK1fr, frE_ne hb2, hwb]
                rfl
              · rw [hf]
                exact Option.ne_none_iff_isSome.mp (hXW b (by rw [hwb]; simp)))
    (by
      intro b p hb
      by_cases hbF : b = addrPrompt.fwd
      · subst hbF
        exact Present.of_get hw.getF
      · by_cases hbM : b = addrPrompt.emit
        · subst hbM
          exact Present.of_get hw.getM
        · rw [hfX b hbF hbM] at hb
          rcases hXn b (by rw [hb]; simp) with e | e
          · subst e
            exact hrel.framedPresent 2665 _ hK'2665
          · cases hwb : W b with
            | none => exact absurd hwb e
            | some w => exact (hw.wide b w hwb).2.1)
  have hrel3 := RelB.atVal hrel2 (ν' := valL ρ T tk π.length 1 0) hval
  have hC1 : x.C.val (.ref 1) = some (F64.ofNat (tk 1)) := by
    have h := hr.srv.num 1 (.var 1) hw.tab1E
    rw [hn1] at h
    exact h.trans (congrArg some ((hres 1 (by decide)).trans (by simp [machVal])))
  have hC2 : x.C.val (.ref 2) = some (F64.ofNat (tk 2)) := by
    have h := hr.srv.num 2 (.var 2) hw.tab2E
    rw [hn2] at h
    exact h.trans (congrArg some ((hres 2 (by decide)).trans (by simp [machVal])))
  obtain ⟨hna, hnb⟩ := hnat
  refine decCutFirstFb_of_rel (x := ⟨M', valL ρ T tk π.length 1 0,
    ⟨frA addrPrompt s0 Fr.X p1 [.num (.ref 1)], s0.trace, x.t.trace, x.t.next - s0.next, K1.lo, K1.hi⟩, x.t, x.C⟩) hrel3 ?_ hC1
  refine ⟨0, p1, rfl, rfl, hK1lo.trans (hlo.trans hw.hLo.symm), hK1hi.trans (hhi.trans hw.hE.symm), rfl, ?_, Nat.zero_le _, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · show some (NumV.ref 2) = some (M'.num addrPrompt.tok)
    rw [hM'num, hw.numT]
    exact congrArg some hn2.symm
  · intro j hj
    cases j with
    | zero => exact hC2
    | succ j =>
      have hj' : j < (machReads T tk).length := by simpa using hj
      have e : (NumV.ref 2 :: machReads T tk)[j + 1] = .lit (F64.ofNat (tk (j + 3))) := by
        simp [machReads]
      rw [e]
      rfl
  · show x.t.next - s0.next ≤ B.D
    have := hw.nextLo
    omega
  · show (mlxOf x.t.ffi).next ≤ (mlxOf s0.ffi).next + B.H
    omega
  · show (mlxOf x.t.ffi).nnext ≤ (mlxOf s0.ffi).nnext + B.N
    omega
  · intro a ha
    show M'.a a = a
    rw [hM'a, hκfix a ha]
    exact hfix a ha
  · rw [← hM']
    exact PostG.handoff (hp) hkr hkf hkc

end Hand

end Host.Route.PrefGraph
