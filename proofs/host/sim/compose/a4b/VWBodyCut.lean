import host.sim.compose.a4b.VWBodyStart
import host.sim.compose.a4b.VWDispatchCompact
import host.sim.template.a4pre_d1_body.SizeAt
import host.sim.lin.Enum
import host.sim.compose.PostValue
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- What the VW forward body keeps across its glue, size bridges and compactions.  The offset
grows at compactions, so each cut names its own bound; the frames stay the forward's. -/
structure BodyBook (i : Cls.Inst) (π : List Nat) (K0 : Ctx) (x : SegInst FF) (Dmax : Nat) : Prop where
  length : π.length = i.L
  vocab : ∀ k ∈ π, k < 248320
  valuation : VBOkF loopVB x.ν
  context : Disp.KpJ (VWFrames.typedJ (tokenBytes (π.take i.n)) (π.take i.n).length) VWFrames.bodyD0 x.K
  incoming : Disp.KpJ setupJ 4096 K0
  incomingPrompt : K0.fr 2665 = some ([], π.map natV)
  incomingMemo : K0.fr 4910 = none
  frames : x.K.fr = (g1Framed K0 π i.n).fr
  offset : x.K.D ≤ Dmax
  lo : x.K.lo = K0.lo
  hi : x.K.hi = K0.hi
  inputEvent : ∃ asR ret pre tr, x.K.base' = pre ++
    ⟨chars!"mlx_array_new_data", .jsPtr (x.M.a VWFrames.buffer) 0 (tokenBytes (π.take i.n)) :: asR, ret⟩ :: tr

theorem BodyBook.prompt {i : Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : BodyBook i π K0 x Dmax) : x.K.fr 2665 = some ([], π.map natV) := by
  rw [hb.frames]
  exact hb.incomingPrompt

theorem BodyBook.chunk {i : Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : BodyBook i π K0 x Dmax) : x.K.fr VWFrames.chunk = some ([], (π.take i.n).map natV) := by
  rw [hb.frames]
  rfl

theorem BodyBook.memo {i : Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : BodyBook i π K0 x Dmax) : x.K.fr 4910 = none := by
  rw [hb.frames]
  exact hb.incomingMemo

/-- The offsets of a body boundary: the JS heap's and the native handles' and nodes'. Compactions
drop source addresses, so each offset grows there and is kept by everything else. `J` counts the
canonical results so far. -/
structure BodyOff where
  D : Nat
  H : Nat
  N : Nat
  J : Nat

/-- Each canonical result of `vs` has its term's value in `es`. -/
def DefsOk (vs : List Nat) (es : List SymE) (ν : Nat → F64) : Prop :=
  ∀ p ∈ vs.zip es, ν p.1 = p.2.eval ν

theorem DefsOk.nil {es : List SymE} {ν : Nat → F64} : DefsOk [] es ν := fun _ h => nomatch h

/-- In the form `RelB.decanon` reads. -/
theorem DefsOk.nth {vs : List Nat} {es : List SymE} {ν : Nat → F64} (h : DefsOk vs es ν) :
    ∀ j v e, nth? vs j = some v → nth? es j = some e → ν v = e.eval ν :=
  fun _ _ _ hv he => h _ (nth?_zip_some hv he)

/-- A body boundary of the prompt `π`, at the variables `m`, within the offsets `O`. -/
noncomputable def bodyCore (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst)
    (Θ : List Nat × List SymE) (O : BodyOff) (m : List (Nat × Q)) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K s S x.t x.C ∧
    BodyBook i π K0 x O.D ∧ NativeAt O.H O.N s x.t ∧ InputAt (π.take i.n) (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν i m ∧ DefsOk (Θ.1.take O.J) (Θ.2.take O.J) x.ν
  B := fun x => AneFresh x.t ∧ fixedCells x

/-- A body boundary of the forward that started at `x0`. -/
noncomputable def bodyCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) (x0 : SegInst FF)
    (Θ : List Nat × List SymE) (O : BodyOff) (m : List (Nat × Q)) (s : St FF.S) (S : SSrv) : ICut FF :=
  withMem (BodyTrail x0) (bodyCore NB T tk π i Θ O m s S)

theorem BodyTrail.ofTrack (x0 x y : SegInst FF) (h : NTrack x y) (ht : BodyTrail x0 x) : BodyTrail x0 y :=
  ht.step (fun k _ => congrFun h.map k) h.nodes h.tokens h.emit

/-- The bridge of the target follows the template's while both sides are inactive. -/
theorem bodyFresh {W : Nat → Option WFrame}
    {NB : Nat} {P : LoadP} {M M' : Map} {ν ν' : Nat → F64} {K K' : Ctx}
    {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (hr : RelB FF (Disp.FRJ (FullRXD P NB)) W [] M ν K sa Sa t C)
    (hr' : RelB FF (Disp.FRJ (FullRXD P NB)) W [] M' ν' K' sb Sb t' C')
    (hi : (bridgeOf sa.ffi).active = false) (he : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hf : AneFresh t) : AneFresh t' := by
  obtain ⟨_, _, r0⟩ := hr.ffi.1
  obtain ⟨_, _, r1⟩ := hr'.ffi.1
  have hi' : (bridgeOf sb.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) he).trans hi
  have hb : bridgeOf t'.ffi = bridgeOf t.ffi :=
    (r1.toR hi').bridge.1.trans (he.trans (r0.toR hi).bridge.1.symm)
  intro Cx Pc Kc weights kind NE IP G init
  rw [hb]
  exact hf Cx Pc Kc weights kind NE IP G init

/-- Extending the map leaves the book's cells alone. -/
theorem BodyBook.ext {i : Cls.Inst} {π : List Nat} {K0 K : Ctx} {M M' : Map} {ν : Nat → F64}
    {t t' : St FF.S} {C C' : CSrv} {Dmax n : Nat}
    (hb : BodyBook i π K0 ⟨M, ν, K, t, C⟩ Dmax) (he : Ext M M' n) :
    BodyBook i π K0 ⟨M', ν, K, t', C'⟩ Dmax := by
  refine ⟨hb.length, hb.vocab, hb.valuation, hb.context, hb.incoming, hb.incomingPrompt,
    hb.incomingMemo, hb.frames, hb.offset, hb.lo, hb.hi, ?_⟩
  change ∃ asR ret pre tr, K.base' = _
  rw [he.a]
  exact hb.inputEvent

theorem setupInputs_ext {T : Nat} {tk : Nat → Nat} {M M' : Map} {ν : Nat → F64} {K K' : Ctx}
    {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : setupInputs T tk ⟨M, ν, K, t, C⟩) (he : Ext M M' n) :
    setupInputs T tk ⟨M', ν, K', t', C'⟩ :=
  ⟨h.1, by change M'.a 2590 = 2590; rw [he.a]; exact h.2⟩

/-- The body's start, at the rows' map, enters the first boundary. -/
theorem fromStart {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {x0 : SegInst FF}
    {Θ : List Nat × List SymE} {s : St FF.S} {S : SSrv} :
    CutConv (withMem (BodyTrail x0) (bodyStartCut NB T tk π i s S))
      (bodyCut NB T tk π i x0 Θ ⟨3571, 0, 0, 0⟩ bodyMap s S) := by
  rintro x ⟨K0, hr, hb, hip, hins, hmap, hk⟩ ⟨⟨hfresh, hids, hnat⟩, htr⟩
  exact ⟨x, rfl, rfl, ⟨K0, hr, ⟨hb.length, hb.vocab, hb.valuation, hk, hb.incoming, hb.incomingPrompt,
    hb.incomingMemo, hb.frames, hb.offset, hb.lo, hb.hi, hb.inputEvent⟩, hnat, hip, hins, hmap, by
      simp only [List.take_zero]; exact DefsOk.nil⟩, ⟨hfresh, hids⟩, htr⟩

theorem fixedCells_ext {M M' : Map} {ν : Nat → F64} {K K' : Ctx}
    {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : fixedCells (⟨M, ν, K, t, C⟩ : SegInst FF)) (he : Ext M M' n) :
    fixedCells (⟨M', ν, K', t', C'⟩ : SegInst FF) := by
  change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
  rw [he.a]
  exact h


end Host.Ts.Sim.Compose.VWFirst
