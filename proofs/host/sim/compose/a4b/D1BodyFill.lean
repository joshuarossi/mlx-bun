import host.sim.compose.a4b.D1Forward
import host.sim.compose.HookMem
import host.sim.compose.a4b.SetupD1Body
import host.sim.compose.a4b.SetupD1Reserved
import host.sim.template.a4pre_d1_prompt_identity.Facts
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
  B := fun x => Host.Route.AneFresh x.t ∧ fixedCells x ∧ NativeAt 0 0 D1Body.s155 x.t

/-- The returned cut at the route's prompt. -/
noncomputable def returnedPromptCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) : ICut FF :=
  SetupD1PromptIdentity.withPrompt (π.map natV) (returnedSavedCut NB T tk)

kernel_rfl cntBody : countersOkB D1Call.s1 D1Body.s155 = true

/-- The D1 forward keeps the node map and pops no readback, so a stretch's property crosses it. -/
theorem prompt_forward_returned (NB T : Nat) (tk : Nat → Nat) (ρ : List Nat) {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) :
    CutStep (withMem Mem (withMem NatForward (SetupD1PromptIdentity.forwardPromptCut NB T tk (ρ.map natV))))
      (withMem Mem (returnedPromptCut NB T tk ρ)) 1541184 := by
  rintro t C ⟨x, rfl, rfl, ⟨π, K0, hr, hb, hi, hv, hem⟩, ⟨⟨⟨hf, hc⟩, hp⟩, hnat⟩, hm⟩
  obtain ⟨x', h⟩ := SetupD1.run_full hr hb hf hc
  have ip : SetupD1Input.InputAt π (x'.M.node 15235) x'.t x'.C := by
    rw [h.inputNode]
    exact hi.grow h.nativeGrow h.server
  have reserved : SetupD1Values.Reserved T tk x'.ν :=
    SetupD1Reserved.body_reserved hr.srv.num h.relation.srv.num h.ext h.server hv
  have emitted : x'.M.a 2590 = 2590 := (congrFun h.ext.a 2590).trans hem
  have hnat' : NativeAt 0 0 D1Body.s155 x'.t := NativeAt.step hnat rfl hr h.relation h.ext.big h.ext.node cntBody
  have hp' : SetupD1PromptIdentity.PromptAt (ρ.map natV) x' := by
    obtain ⟨origin, hfb, _⟩ := h.book
    have e0 := SetupD1PromptIdentity.forward_prompt hfb
    have e : x'.K.fr 2665 = some ([], π.map natV) := e0
    exact e.trans ((SetupD1PromptIdentity.forward_prompt hb).symm.trans hp)
  exact ⟨x'.t, x'.C, h.run, x', rfl, rfl, ⟨π, K0, h.relation, h.book, ip, reserved, emitted⟩,
    ⟨⟨h.fresh, h.anchors, hnat'⟩, hp'⟩,
    hMem x x' ⟨h.server, h.ext.node, h.nativeGrow,
      tokens_of_grow hr h.relation h.nativeGrow (countersOkB_tokens cntBody), congrFun h.ext.a 12504⟩ hm⟩

/-- The final forward. `hfin`: its graph, from what the return knows. -/
noncomputable def fwd_D1_cold_DFirst__g2_fin_first__g3f_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem Mem' : Nat → SegInst FF → Prop) (hWit : ∀ L x y, y.t = x.t → y.C = x.C → y.M.a 12504 = x.M.a 12504 → Mem L x → Mem L y)
    (hfin : ∀ x y : SegInst FF, (returnedPromptCut NB T tk π).R y (returnedPromptCut NB T tk π).s0
        ⟨(returnedPromptCut NB T tk π).tab0, []⟩ → (returnedPromptCut NB T tk π).B y → CSrv.Le x.C y.C →
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens → y.M.a 12504 = x.M.a 12504 →
      Mem 1 x → Mem' 1 y) :
    FwdPiece FF [final_cold.r0] [⟨[(0, .o), (1, .cap), (2, .n)], Stage.Cache.KvDFirst.O⟩]
      (fun _ => forwardCut NB T tk π Mem) (fun _ => withMem (Mem' 1) (returnedPromptCut NB T tk π)) where
  m := [(9, .L)]
  np := 0
  nb := 1541184
  O := []
  chk _ _ := rfl
  ok _ _ _ _ _ := FwdCall.warm (toForwardPrompt NB T tk π hWit)
    (hookMem (fun x0 => prompt_forward_returned NB T tk π (fun _ _ h h0 => h0.trans h))
      (fun x y _ hy hby htr hm => hfin x y hy hby htr.server htr.nodes htr.tokens htr.emit hm)) (CutConv.refl _)

end Host.Ts.Sim.Compose.D1First
