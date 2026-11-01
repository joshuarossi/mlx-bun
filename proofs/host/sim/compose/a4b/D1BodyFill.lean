import host.sim.compose.a4b.D1Forward
import host.sim.compose.a4b.SetupD1Body
import host.sim.compose.a4b.SetupD1Reserved
import host.sim.lin.checks.Kv
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable def returnedSavedCut (NB T : Nat) (tk : Nat → Nat) : ICut FF where
  s0 := D1Body.s155
  tab0 := D1Body.S155.tab
  R := fun x s S => ∃ π K0,
    RelB FF (Disp.FRJ (FullRXD { Host.Route.setupP with rest := Host.Route.machReads T tk } NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K s S x.t x.C ∧
    SetupD1.BodyBook π K0 x ∧ SetupD1Input.InputAt π (x.M.node 15235) x.t x.C ∧
    SetupD1Values.Reserved T tk x.ν ∧ x.M.a 2590 = 2590
  B := fun x => Host.Route.AneFresh x.t ∧ fixedCells x

theorem saved_forward_returned (NB T : Nat) (tk : Nat → Nat) :
    CutStep (SetupD1SavedCells.forwardSavedInputCut NB T tk) (returnedSavedCut NB T tk) 1541184 := by
  rintro t C ⟨x, rfl, rfl, ⟨π, K0, hr, hb, hi, hv, hem⟩, hf, hc⟩
  obtain ⟨x', h⟩ := SetupD1.run_full hr hb hf hc
  have ip : SetupD1Input.InputAt π (x'.M.node 15235) x'.t x'.C := by
    rw [h.inputNode]
    exact hi.grow h.nativeGrow h.server
  have reserved : SetupD1Values.Reserved T tk x'.ν :=
    SetupD1Reserved.body_reserved hr.srv.num h.relation.srv.num h.ext h.server hv
  have emitted : x'.M.a 2590 = 2590 := (congrFun h.ext.a 2590).trans hem
  exact ⟨x'.t, x'.C, h.run, x', rfl, rfl,
    ⟨π, K0, h.relation, h.book, ip, reserved, emitted⟩, h.fresh, h.anchors⟩

/-- The returned cut at the route's prompt. -/
noncomputable def returnedPromptCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) : ICut FF :=
  SetupD1PromptIdentity.withPrompt (π.map natV) (returnedSavedCut NB T tk)

kernel_rfl cntBody : countersOkB D1Call.s1 D1Body.s155 = true

/-- The forward's graph step, at the prefix's witness and the return's: what the forward keeps of
the first's nodes and the target's growth. -/
def FwdGraph (A ret : ICut FF) (n : Nat) (Mem Mem' : SegInst FF → Prop) : Prop :=
  ∀ x y, A.R x A.s0 ⟨A.tab0, []⟩ → A.B x → ret.R y ret.s0 ⟨ret.tab0, []⟩ →
    (∀ k, k < (mlxOf A.s0.ffi).nnext → y.M.node k = x.M.node k) →
    runC FF n x.t x.C = some (y.t, y.C) →
    Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
    (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → Mem x → Mem' y

theorem prompt_forward_returned (NB T : Nat) (tk : Nat → Nat) (ρ : List Nat) {Mem Mem' : SegInst FF → Prop}
    (hfwd : FwdGraph (SetupD1PromptIdentity.forwardPromptCut NB T tk (ρ.map natV))
      (returnedPromptCut NB T tk ρ) 1541184 Mem Mem') :
    CutStep (withMem Mem (SetupD1PromptIdentity.forwardPromptCut NB T tk (ρ.map natV)))
      (withMem Mem' (returnedPromptCut NB T tk ρ)) 1541184 := by
  rintro t C ⟨x, rfl, rfl, ⟨π, K0, hr, hb, hi, hv, hem⟩, ⟨⟨hf, hc⟩, hp⟩, hm⟩
  obtain ⟨x', h⟩ := SetupD1.run_full hr hb hf hc
  have ip : SetupD1Input.InputAt π (x'.M.node 15235) x'.t x'.C := by
    rw [h.inputNode]
    exact hi.grow h.nativeGrow h.server
  have reserved : SetupD1Values.Reserved T tk x'.ν :=
    SetupD1Reserved.body_reserved hr.srv.num h.relation.srv.num h.ext h.server hv
  have emitted : x'.M.a 2590 = 2590 := (congrFun h.ext.a 2590).trans hem
  have hp' : SetupD1PromptIdentity.PromptAt (ρ.map natV) x' := by
    obtain ⟨origin, hfb, _⟩ := h.book
    have e : x'.K.fr 2665 = some ([], π.map natV) := SetupD1PromptIdentity.forward_prompt hfb
    exact e.trans ((SetupD1PromptIdentity.forward_prompt hb).symm.trans hp)
  have hR' : (returnedPromptCut NB T tk ρ).R x' D1Body.s155 ⟨D1Body.S155.tab, []⟩ :=
    ⟨π, K0, h.relation, h.book, ip, reserved, emitted⟩
  exact ⟨x'.t, x'.C, h.run, x', rfl, rfl, hR', ⟨⟨h.fresh, h.anchors⟩, hp'⟩,
    hfwd x x' ⟨π, K0, hr, hb, hi, hv, hem⟩ ⟨⟨hf, hc⟩, hp⟩ hR' (fun k _ => congrFun h.ext.node k) h.run h.nativeGrow
      (tokens_of_grow hr h.relation h.nativeGrow (countersOkB_tokens cntBody)) hm⟩

noncomputable def fwd_D1_cold_DFirst__g2_fin_first__g3f_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem Mem' : Nat → SegInst FF → Prop) (hWit : ∀ L x y, y.t = x.t → y.C = x.C → Mem L x → Mem L y)
    (hfwd : FwdGraph (SetupD1PromptIdentity.forwardPromptCut NB T tk (π.map natV))
      (returnedPromptCut NB T tk π) 1541184 (Mem 1) (Mem' 1)) :
    FwdPiece FF [final_cold.r0] [⟨[(0, .o), (1, .cap), (2, .n)], Stage.Cache.KvDFirst.O⟩]
      (fun _ => forwardCut NB T tk π Mem) (fun _ => withMem (Mem' 1) (returnedPromptCut NB T tk π)) where
  m := [(9, .L)]
  np := 0
  nb := 1541184
  O := []
  chk _ _ := rfl
  ok _ _ _ _ _ := FwdCall.warm (toForwardPrompt NB T tk π hWit) (prompt_forward_returned NB T tk π hfwd) (CutConv.refl _)

end Host.Ts.Sim.Compose.D1First
