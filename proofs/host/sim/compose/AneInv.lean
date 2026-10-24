import host.sim.world.IterCut
import host.sim.world.Halt
import host.simgraph.compose.AneMem
import host.sim.full.World
import host.sim.full.BridgeA
import host.sim.full.BridgeFrame
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-! # The Neural Engine component of the decode route's cut invariants

Every cut of the route from loadDone on carries A5's `AneCut` (`host.simgraph.compose.AneCut`: the Neural Engine
memory between forwards). The decode loop's cuts carry their graph invariant `Gx` (`decCutW`'s and
`loopCutW`'s bookkeeping, `DecodeInvW`); `withAne Gx An` adds the component `An` of the target:

* `LoopGStepGW.withAne`: a loop case's graph obligation at `withAne Gx An` from `Gx`'s and the component's step
  along the iteration's run; `LastGStepW.withAne`, `CutGStepW.withAne`: a halt's, from `Gx`'s (the goal does
  not read the component).
* `aneAt`: the component at iteration `i`, `AneCut` of the target's Neural Engine memory (`mem`, the world's
  projection) at the reference's data after `i` forwards (its readers `D i` and their values `V i`, its
  surfaces `σ i`); `aneAt_start` at loadDone's (`aneCut_start`); `aneAt_keep`: a step keeping the memory's
  surfaces and the readers' values keeps it at unchanged data (`aneCut_keep`: a decode iteration's forward runs
  on the GPU). A forward on the Neural Engine is `aneCut_forward`'s (the prefill's chunks).
* `aneDec`: the decode route's component, the full-world target's memory A5's `aneMem` of its bridge state at the final
  prefill reference state's data (decode keeps its surfaces and forwards); `aneDec_keep`: an unchanged bridge log
  keeps it (`aneMem_log`); `aneDec_link`: along a decode link, the pinned decode world's relation at both cuts (the
  target's bridge `b0`, A1's `BridgeFb.log_keep`). -/

section
variable {Wd : World} {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat}

/-- A graph invariant with a component `An` of the target. -/
def withAne (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (An : Nat → St Wd.F.S → Prop) :
    Nat → Map → St Wd.F.S → CSrv → Prop :=
  fun i M t C => Gx i M t C ∧ An i t

/-- **A loop case's graph obligation with the component**, from `Gx`'s and the component's step. -/
theorem LoopGStepGW.withAne {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {An : Nat → St Wd.F.S → Prop}
    {W : Nat → Option WFrame} {Fr : LoopFramesA A} {e : IterEndW Wd A P s0 tab0 fixA} {g : GhostP} {V : LoopVals}
    {toks : List NumV} {i : Nat} (h : LoopGStepGW Gx W Fr e g V toks i)
    (ha : ∀ (nx : Nat) (M : Map) (K : Ctx) (t : St Wd.F.S) (C : CSrv) (n : Nat) (x1 : SegInst Wd.F),
      Gx i M t C → An i t → RelF Wd.F (Wd.R P (toks.drop i)) W M (V i nx) K s0 ⟨tab0, []⟩ t C →
      runC Wd.F n t C = some (x1.t, x1.C) →
      RelF Wd.F (Wd.R P (toks.drop i)) W x1.M x1.ν x1.K e.s1 e.S1 x1.t x1.C → An (i + 1) x1.t) :
    LoopGStepGW (withAne Gx An) W Fr e g V toks i :=
  fun hlen nx M K t C n x1 hG hr hfr hlo hhi hrun hgh hr1 =>
    ⟨h hlen nx M K t C n x1 hG.1 hr hfr hlo hhi hrun hgh hr1, ha nx M K t C n x1 hG.1 hG.2 hr hrun hr1⟩

/-- A final chain's graph obligation with the component, from `Gx`'s. -/
theorem LastGStepW.withAne {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {An : Nat → St Wd.F.S → Prop}
    {W : Nat → Option WFrame} {Fr : LoopFramesA A} {toks : List NumV} {T : Nat} {xs : List Val}
    {hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs}
    {V : LoopVals} {tk : Nat → Nat} {G : St Wd.F.S → CSrv → Prop} (h : LastGStepW A Gx P W Fr fixA hs V tk G) :
    LastGStepW A (withAne Gx An) P W Fr fixA hs V tk G :=
  fun hlen nx M K t C xF hG => h hlen nx M K t C xF hG.1

/-- An exit chain's graph obligation with the component, from `Gx`'s. -/
theorem CutGStepW.withAne {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {An : Nat → St Wd.F.S → Prop}
    {W : Nat → Option WFrame} {Fr : LoopFramesA A} {toks : List NumV} {i : Nat}
    {hs : HaltSegW Wd A W P (toks.drop i) s0 s0 tab0 []} {V : LoopVals} {G : St Wd.F.S → CSrv → Prop}
    (h : CutGStepW A Gx P W Fr fixA hs V G) : CutGStepW A (withAne Gx An) P W Fr fixA hs V G :=
  fun nx M K t C xF hG => h nx M K t C xF hG.1

end

section
open Host.Mlx Host.Mlx.FfiAneEval Host.Mlx.SimGraph Inference.Contracts.Mlx
variable {Wd : World} {C : M1Max.Contract} (Pc : MlxPrefillContract C) (Kc : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (G : Graph) (mem : Wd.F.S → FfiAneEval.Mem)

/-- **The Neural Engine component at iteration `i`**: `AneCut` of the target's Neural Engine memory `mem` at the
reference's data after `i` forwards (readers `D i`, their values `V i`, surfaces `σ i`). -/
def aneAt (V : Nat → Nat → Option Value) (D : Nat → List Reader) (σ : Nat → Nat → Surface) :
    Nat → St Wd.F.S → Prop :=
  fun i t => AneCut Pc Kc weights G (V i) (D i) (σ i) (mem t.ffi)

/-- At a target whose memory holds the reference's loaded surfaces, before any reader. -/
theorem aneAt_start {V : Nat → Nat → Option Value} {D : Nat → List Reader} {σ : Nat → Nat → Surface} {i : Nat}
    {t : St Wd.F.S} (hD : D i = []) (hm : mem t.ffi = ⟨σ i, (mem t.ffi).vals, (mem t.ffi).pend⟩) :
    aneAt Pc Kc weights G mem V D σ i t := by
  show AneCut Pc Kc weights G (V i) (D i) (σ i) (mem t.ffi)
  rw [hD, hm]
  exact aneCut_start Pc Kc weights G (V i) (σ i) _ _

/-- **A step keeping the Neural Engine memory's surfaces and the readers' values keeps the component**, at the
reference's data unchanged (a forward on the GPU). -/
theorem aneAt_keep {V : Nat → Nat → Option Value} {D : Nat → List Reader} {σ : Nat → Nat → Surface} {i j : Nat}
    {t t' : St Wd.F.S} (h : aneAt Pc Kc weights G mem V D σ i t) (hV : V j = V i) (hD : D j = D i) (hσ : σ j = σ i)
    (hs : (mem t'.ffi).surf = (mem t.ffi).surf)
    (hv : ∀ r ∈ (D i).map Reader.b, (mem t'.ffi).vals r = (mem t.ffi).vals r) :
    aneAt Pc Kc weights G mem V D σ j t' := by
  show AneCut Pc Kc weights G (V j) (D j) (σ j) (mem t'.ffi)
  rw [hV, hD, hσ]
  exact aneCut_keep Pc Kc weights G h hs hv

end

section
open Host.Mlx Host.Mlx.FfiAneEval Host.Mlx.SimGraph Inference.Contracts.Mlx Host.Ts.Sim.Full
variable {C : M1Max.Contract} (Pc : MlxPrefillContract C) (Kc : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled) (NE : NeuralEngine) (IP : InPlace)
  (G : Graph) (init : Nat → Surface) (rd : Nat → List Reader) (rk : Nat → Option (Nat × AKey)) (sF : Ref.RSt)

/-- **The decode route's Neural Engine component** at every decode cut: `AneCut` of the full-world target's memory
(`aneMem` of its bridge state, from the loaded surfaces `init`) at the final prefill reference state `sF`'s surfaces,
readers and values. -/
def aneDec (NB : Nat) : Nat → St (fullWorld NB).F.S → Prop :=
  aneAt (Wd := fullWorld NB) Pc Kc weights G (fun p => aneMem Pc Kc weights kind NE IP G init (bridgeOf p))
    (fun _ => refVals rk sF) (fun _ => refReaders rd sF) (fun _ => refSurf sF)

/-- **An unchanged bridge log keeps the decode component.** -/
theorem aneDec_keep {NB i j : Nat} {t t' : St (fullWorld NB).F.S}
    (h : aneDec Pc Kc weights kind NE IP G init rd rk sF NB i t) (hlog : (bridgeOf t'.ffi).log = (bridgeOf t.ffi).log) :
    aneDec Pc Kc weights kind NE IP G init rd rk sF NB j t' :=
  have e := aneMem_log Pc Kc weights kind NE IP G init hlog
  aneAt_keep Pc Kc weights G _ h rfl rfl rfl (congrArg FfiAneEval.Mem.surf e)
    fun r _ => congrArg (fun m : FfiAneEval.Mem => m.vals r) e

/-- **A decode link keeps the decode component**: the pinned decode world's relation at both cuts leaves the target's
bridge, its log in particular (`BridgeFb.log_keep`). -/
theorem aneDec_link {b0 : BSt} {NB i j : Nat} {P P' : LoadP} {M M' : Map} {n n' : Nat} {x x' : FF.S}
    {t t' : St (fullWorld NB).F.S} (h : aneDec Pc Kc weights kind NE IP G init rd rk sF NB i t)
    (hr : FullRFb b0 P NB M n x t.ffi) (hr' : FullRFb b0 P' NB M' n' x' t'.ffi) :
    aneDec Pc Kc weights kind NE IP G init rd rk sF NB j t' :=
  aneDec_keep Pc Kc weights kind NE IP G init rd rk sF h (BridgeFb.log_keep hr.bridge hr'.bridge)

end

end Host.Ts.Sim.Compose
