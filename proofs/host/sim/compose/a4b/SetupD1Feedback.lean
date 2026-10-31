import host.sim.template.a4pre_d1_feedback.Native
import host.sim.template.a4pre_d1_post_small.Small
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1Feedback
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl

structure Endpoint (M : Map) (t : St FF.S) : Prop where
  object : t.obj? (M.a 2827805) = some (M.obj (Template.objOf D1Post.s4 2827805))
  private_handle : D1Endpoint.privateVal (M.obj (Template.objOf D1Post.s4 2827805)) (chars!"handle") =
    some (.big (M.big 22018))
  native : D1Feedback.NativeAt M t

theorem object_at {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {t : St FF.S} {S : SSrv} {C : CSrv}
    {bytes : List Byte} (h : RelB FF FR W [] M ν K D1Post.s4 S t C)
    (hk : Disp.KpJ (D1PostSmall.J bytes) 4096 K) :
    t.obj? (M.a 2827805) = some (M.obj (Template.objOf D1Post.s4 2827805)) := by
  have hfr : K.fr 2827805 = none := by
    by_contra hn
    have hm := (hk.1.2.2 2827805).mp hn
    exact (by decide : 2827805 ∉ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view]) hm
  exact h.obj? D1Feedback.input_object hfr

theorem endpoint {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Host.Ts.Sim.Ctx} {t : St FF.S} {S : SSrv} {C : CSrv} {bytes : List Byte}
    {W : Nat → Option WFrame}
    (h : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W []
      M ν K D1Post.s4 S t C)
    (hk : Disp.KpJ (D1PostSmall.J bytes) 4096 K) : Endpoint M t :=
  ⟨object_at h hk, congrFun D1Feedback.mapped_input_handle M, D1Feedback.native h.ffi.1 rfl⟩

theorem endpoint_ngrow {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Host.Ts.Sim.Ctx} {t : St FF.S} {S : SSrv} {C : CSrv} {bytes : List Byte}
    {W : Nat → Option WFrame} {y0 : Host.Mlx.Ffi.St}
    (h : RelB FF (Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))) W [] M ν K D1Post.s4 S t C)
    (hk : Disp.KpJ (D1PostSmall.J bytes) 4096 K) : Endpoint M t :=
  ⟨object_at h hk, congrFun D1Feedback.mapped_input_handle M, D1Feedback.native h.ffi.1.1 rfl⟩

theorem Endpoint.actual_private_handle {M : Map} {t : St FF.S} (h : Endpoint M t) :
    D1Endpoint.privateVal (Template.objOf t (M.a 2827805)) (chars!"handle") =
      some (.big (Int.ofNat (M.handle 22018))) := by
  have he : Template.objOf t (M.a 2827805) = M.obj (Template.objOf D1Post.s4 2827805) := by
    unfold Template.objOf
    rw [obj?_iff.1 h.object]
    rfl
  rw [he, h.private_handle, h.native.handle_value]

/-- The readback reference's numeric interpretation, independent of sampled-token correctness. -/
theorem read_value {M : Map} {ν : Nat → F64} {C : CSrv} {token : Nat}
    (h : Srv M ν ⟨D1Post.S4.tab, []⟩ C) (hv : ν 1 = F64.ofNat token) :
    C.val (M.nv (.ref 1)) = some (F64.ofNat token) := by
  have hn := h.num 1 _ D1Feedback.read_expression
  simpa only [Map.nv, SymE.eval, hv] using hn

/-- The old endpoint relation is retained literally when its consequence is attached. -/
theorem strengthen_ngrow {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Host.Ts.Sim.Ctx} {t : St FF.S} {S : SSrv} {C : CSrv} {bytes : List Byte}
    {W : Nat → Option WFrame} {y0 : Host.Mlx.Ffi.St}
    (h : RelB FF (Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))) W [] M ν K D1Post.s4 S t C)
    (hk : Disp.KpJ (D1PostSmall.J bytes) 4096 K) :
    RelB FF (Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))) W [] M ν K D1Post.s4 S t C ∧ Endpoint M t :=
  ⟨h, endpoint_ngrow h hk⟩

theorem forget {A : Prop} {M : Map} {t : St FF.S} (h : A ∧ Endpoint M t) : A := h.1

/-- Only the current producing node needs evaluation and readback semantics. -/
theorem Endpoint.eval {Cx : Inference.Contracts.Mlx.M1Max.Contract}
    (P : Host.Mlx.MlxContract Cx) (K : Host.Mlx.KernelContract Cx)
    (env : Host.Mlx.FfiEval.Env Host.Mlx.FfiEval.InKey) (sources : Host.Mlx.FfiEval.KernelSources)
    {M : Map} {t : St FF.S} (C : CSrv) {token : Nat} (h : Endpoint M t) (ht : token < 248320)
    (produced : ∃ r, Host.Mlx.FfiEval.evalR P K env
      (Host.Mlx.FfiEval.ffiGraph (Host.Mlx.FfiEval.concrete C.val) sources (mlxOf t.ffi)) (M.node 17776) = some r ∧
      Host.Mlx.itemUint32 r = some token) :
    ∃ ids, Host.Mlx.FfiEval.evalR P K env
      (Host.Mlx.FfiEval.ffiGraph (Host.Mlx.FfiEval.concrete C.val) sources (mlxOf t.ffi)) (M.node 17777) = some ids ∧
      Host.Mlx.GlueStep.TokenBuffer ids token := h.native.input.eval P K env sources C ht produced
end Host.Ts.Sim.Compose.SetupD1Feedback
