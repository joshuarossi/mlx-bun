import host.sim.compose.a4b.VWBodyStart
import host.sim.compose.a4b.VWDispatchCompact
import host.sim.template.a4pre_d1_body.SizeAt
import host.sim.lin.Enum
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
drop source addresses, so each offset grows there and is kept by everything else. -/
structure BodyOff where
  D : Nat
  H : Nat
  N : Nat

/-- The target's native counters within the offsets above the template's. -/
def NativeOff (O : BodyOff) (s : St FF.S) (t : St FF.S) : Prop :=
  (mlxOf t.ffi).next ≤ (mlxOf s.ffi).next + O.H ∧ (mlxOf t.ffi).nnext ≤ (mlxOf s.ffi).nnext + O.N

/-- The counters a stretch moves over, inside the fresh band. -/
def countersOkB (sa sb : St FF.S) : Bool :=
  Nat.ble (mlxOf sa.ffi).next (mlxOf sb.ffi).next && Nat.blt (mlxOf sb.ffi).next setupP.E &&
    Nat.ble (mlxOf sa.ffi).nnext (mlxOf sb.ffi).nnext

/-- Both sides allocate the same handles and nodes: the fresh bands of the two relations meet. -/
theorem NativeOff.step {NB T n : Nat} {tk : Nat → Nat} {W : Nat → Option WFrame} {O : BodyOff}
    {M M' : Map} {ν ν' : Nat → F64} {K K' : Ctx} {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (h : NativeOff O sa t)
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W [] M ν K sa Sa t C)
    (hr' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W [] M' ν' K' sb Sb t' C')
    (he : Ext M M' n) (hc : countersOkB sa sb = true) : NativeOff O sb t' := by
  simp only [countersOkB, Bool.and_eq_true] at hc
  obtain ⟨⟨hle, hlt⟩, hnle⟩ := hc
  have hle := Nat.le_of_ble_eq_true hle
  have hlt := Nat.blt_eq.mp hlt
  have hnle := Nat.le_of_ble_eq_true hnle
  obtain ⟨P0, hP0, r0⟩ := hr.ffi.1
  obtain ⟨P1, hP1, r1⟩ := hr'.ffi.1
  obtain ⟨_, hE0, _, _⟩ := Raised.restart (.inl rfl) hP0
  obtain ⟨_, hE1, _, _⟩ := Raised.restart (.inl rfl) hP1
  have a0 := r0.load.mlx.hfreshB ((mlxOf sb.ffi).next - (mlxOf sa.ffi).next) (by
    change (mlxOf sa.ffi).next + _ < P0.E
    rw [hE0]; omega)
  have a1 := r1.load.mlx.hfreshB 0 (by
    change (mlxOf sb.ffi).next + 0 < P1.E
    rw [hE1]; omega)
  have n0 := r0.load.mlx.nfresh ((mlxOf sb.ffi).nnext - (mlxOf sa.ffi).nnext)
  have n1 := r1.load.mlx.nfresh 0
  change M.big (Int.ofNat ((mlxOf sa.ffi).next + _)) = Int.ofNat ((mlxOf t.ffi).next + _) at a0
  change M'.big (Int.ofNat ((mlxOf sb.ffi).next + 0)) = Int.ofNat ((mlxOf t'.ffi).next + 0) at a1
  change M.node ((mlxOf sa.ffi).nnext + _) = (mlxOf t.ffi).nnext + _ at n0
  change M'.node ((mlxOf sb.ffi).nnext + 0) = (mlxOf t'.ffi).nnext + 0 at n1
  rw [he.big] at a1
  rw [he.node] at n1
  have eh : (mlxOf sa.ffi).next + ((mlxOf sb.ffi).next - (mlxOf sa.ffi).next) = (mlxOf sb.ffi).next + 0 := by omega
  have en : (mlxOf sa.ffi).nnext + ((mlxOf sb.ffi).nnext - (mlxOf sa.ffi).nnext) = (mlxOf sb.ffi).nnext + 0 := by omega
  rw [eh, a1] at a0
  rw [en, n1] at n0
  have a2 := Int.ofNat.inj a0
  obtain ⟨h1, h2⟩ := h
  constructor <;> omega

/-- A body boundary of the prompt `π`, at the variables `m`, within the offsets `O`. -/
noncomputable def bodyCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) (O : BodyOff)
    (m : List (Nat × Q)) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K s S x.t x.C ∧
    BodyBook i π K0 x O.D ∧ NativeOff O s x.t ∧ InputAt (π.take i.n) (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν i m
  B := fun x => AneFresh x.t ∧ fixedCells x

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

theorem fixedCells_ext {M M' : Map} {ν : Nat → F64} {K K' : Ctx}
    {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : fixedCells (⟨M, ν, K, t, C⟩ : SegInst FF)) (he : Ext M M' n) :
    fixedCells (⟨M', ν, K', t', C'⟩ : SegInst FF) := by
  change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
  rw [he.a]
  exact h


end Host.Ts.Sim.Compose.VWFirst
