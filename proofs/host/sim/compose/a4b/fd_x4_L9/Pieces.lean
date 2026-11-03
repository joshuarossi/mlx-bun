import host.sim.compose.a4b.fd_x4_L9.Forward
import host.sim.stage.NextStep
import host.sim.compose.a4b.PiecesOff
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FDX4L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-! # The final step's pieces, from the pre-final cut to the forward's return

A piece's rows are `final_ord`'s; the bookkeeping names the prompt's length. -/

kernel_rfl chkG2 : ([final_ord.r0].all fun r => goodLin r.ps (varsOf r.V fdMap) PRE_fd_x4_L9_r0.S23.oracle) = true
kernel_rfl chkDispatch : ([final_ord.r0].all fun r => goodLin r.ps (varsOf r.V fdMap) PRE_fd_x4_L9_r0.st1.S0.oracle) = true

section
variable (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat)
  (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) (hPin : ∀ L x, Mem L x → π.length = L)

noncomputable def pf_start (hcap : cap ≤ 131072) (hbound : cap + 12 < Sim.bound) :
    StagePiece FF [final_ord.r0] [⟨[(0, .L), (1, .o), (2, .C)], Stage.NextStep.FIN.O⟩]
      (fun i => withMem (Mem i.L) (Pf.cut NB T tk π cap H N PRE_pf_x4_L9.s0 PRE_pf_x4_L9.S0))
      (fun i => withMem (Mem i.L) (Pf.cut NB T tk π (cap + 12) H N PRE_fd_x4_L9_r0.s2 PRE_fd_x4_L9_r0.S2)) where
  m := fdMap
  n := PRE_fd_x4_L9_r0.st0.tpl.n + 1
  O := PRE_fd_x4_L9_r0.st0.S0.oracle
  chk r hr := by
    obtain rfl := List.mem_singleton.mp hr
    exact List.all_eq_true.mp PRE_fd_x4_L9_r0.chk_site0 _ (by simp)
  ok r hr i hi ho := by
    obtain rfl := List.mem_singleton.mp hr
    exact StageCall.intro toStart
      (nps_merged (hMem i.L) hcap (fun x hb hm => ho.1 x.ν (rowMap hi (hPin _ _ hm) hb)))
      (nps_compact (hMem i.L) (Nat.le_refl _) hbound)

noncomputable def g1_piece (hcap : cap ≤ 131072) :
    GluePiece FF [final_ord.r0]
      (fun i => withMem (Mem i.L) (Pf.cut NB T tk π cap H N PRE_fd_x4_L9_r0.s2 PRE_fd_x4_L9_r0.S2))
      (fun i => withMem (Mem i.L) (dispatchCut NB T tk π cap H N i)) where
  m := fdMap
  n := 261
  O := g1Oracle
  chk r hr := by
    obtain rfl := List.mem_singleton.mp hr
    exact List.all_eq_true.mp g1Check _ (by simp)
  ok r hr i hi ho := by
    obtain rfl := List.mem_singleton.mp hr
    exact g1 (hMem i.L) hi (fun x hm => hPin _ _ hm) hcap ho.1

noncomputable def disp_piece (hcap : cap + 18 ≤ 131072) :
    StagePiece FF [final_ord.r0] []
      (fun i => withMem (Mem i.L) (dispatchCut NB T tk π cap H N i))
      (fun i => withMem (Mem i.L) (g2Cut NB T tk π (cap + 18) H N i)) where
  m := fdMap
  n := 155
  O := PRE_fd_x4_L9_r0.st1.S0.oracle
  chk r hr := List.all_eq_true.mp chkDispatch r hr
  ok _ _ i _ ho := StageCall.intro (CutConv.refl _)
    (dispatch_merged NB T tk π cap H N i (hMem i.L) ho.1) (dispatch_compact (hMem i.L) (Nat.le_refl _) hcap)

noncomputable def g2_piece :
    GluePiece FF [final_ord.r0]
      (fun i => withMem (Mem i.L) (g2Cut NB T tk π cap H N i))
      (fun i => withMem (Mem i.L) (forwardCut NB T tk π cap H N i)) where
  m := fdMap
  n := 7
  O := PRE_fd_x4_L9_r0.S23.oracle
  chk r hr := List.all_eq_true.mp chkG2 r hr
  ok _ _ i _ ho := g2 NB T tk π cap H N i (hMem i.L) ho.1

/-- The final forward. `hook`: the graph, from what the return knows. -/
noncomputable def fwd_piece (Mem' : Nat → SegInst FF → Prop) (obls : List Obl) (hcap : cap ≤ 4096 + 1593835520)
    (hpin : ∀ L x, Mem L x → L = 9)
    (hook : ∀ i, InRow final_ord.r0 i → ∀ x y : SegInst FF,
      (forwardCut NB T tk π cap H N i).R x (forwardCut NB T tk π cap H N i).s0 ⟨(forwardCut NB T tk π cap H N i).tab0, []⟩ →
      (returnCut NB T tk π cap H N).R y (returnCut NB T tk π cap H N).s0 ⟨(returnCut NB T tk π cap H N).tab0, []⟩ →
      (returnCut NB T tk π cap H N).B y → NTrack x y → Mem i.L x → Mem' i.L y) :
    FwdPiece FF [final_ord.r0] obls
      (fun i => withMem (Mem i.L) (forwardCut NB T tk π cap H N i))
      (fun i => withMem (Mem' i.L) (returnCut NB T tk π cap H N)) where
  m := [(9, .L)]
  np := 0
  nb := 1502774
  O := []
  chk _ _ := rfl
  ok r hr i hi _ := by
    obtain rfl := List.mem_singleton.mp hr
    by_cases hk : i.L = 9
    · exact FwdCall.warm (CutConv.refl _) (hookMem (fun x0 => flatStep x0 hcap hi hk) (hook i hi)) (CutConv.refl _)
    · refine FwdCall.warm (CutConv.refl _) ?_ (CutConv.refl _)
      exact Gpu.stepOff (A := fun i => withMem (Mem i.L) (forwardCut NB T tk π cap H N i))
        (B := fun i => withMem (Mem' i.L) (returnCut NB T tk π cap H N)) (fun i x hb => hpin i.L x hb.2) hk _

end

end Host.Ts.Sim.Compose.FDX4L9
