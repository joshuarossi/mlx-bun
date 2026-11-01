import host.sim.template.a4pre_d1_body.Output
import host.sim.template.a4pre_d1_body.History
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyOutput
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

private theorem objOf_spec (s : St FF.S) (a : Nat) (hp : (s.obj? a).isSome = true) :
    s.obj? a = some (objOf s a) := by
  unfold Template.objOf
  cases h : s.obj? a with
  | none => rw [h] at hp; cases hp
  | some o => rw [obj?_iff.1 h]

private theorem unframed {J : Disp.JSP FF} {K : Host.Ts.Sim.Ctx} {a : Nat}
    (hk : Disp.Kp J K) (hn : a ∉ J.framed) : K.fr a = none := by
  by_contra h
  exact hn ((hk.2.2 a).mp h)

kernel_rfl cacheUnframed : D1Endpoint.caches.all (fun a =>
    !([2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view].contains a)) = true

theorem targetCaches {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {t : St FF.S} {S : SSrv} {C : CSrv}
    {bs : List Byte} (hr : RelB FF FR W [] M ν K D1Body.s155 S t C)
    (hk : Disp.Kp (D1Frames.typedJ bs) K) :
    ∀ a ∈ D1Endpoint.caches, ∃ o, t.obj? (M.a a) = some o ∧ updatedB o = true := by
  intro a ha
  have hp := List.all_eq_true.mp cachePresent a ha
  have hn : a ∉ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view] := by
    intro hm
    have hh := List.all_eq_true.mp cacheUnframed a ha
    rw [List.contains_iff_mem.mpr hm] at hh
    cases hh
  exact ⟨M.obj (objOf D1Body.s155 a), hr.obj? (objOf_spec _ _ hp) (unframed hk hn),
    List.all_eq_true.mp (congrFun mappedCachesUpdated M) a ha⟩

theorem targetCacheArray {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {t : St FF.S} {S : SSrv} {C : CSrv}
    {bs : List Byte} (hr : RelB FF FR W [] M ν K D1Body.s155 S t C)
    (hk : Disp.Kp (D1Frames.typedJ bs) K) :
    ∃ o, t.obj? (M.a 2672295) = some o ∧
      o.kind = .array (D1Endpoint.caches.map (fun a => Val.obj (M.a a))) := by
  refine ⟨M.obj (objOf D1Body.s155 2672295), hr.obj? cacheArrayPresent (unframed hk (by
    change _ ∉ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view]; decide)), ?_⟩
  change M.kind (objOf D1Body.s155 2672295).kind = _
  rw [cacheArray]
  simp only [Map.kind, Map.vals, List.map_map]
  rfl

theorem targetOutput {P : LoadP} {NB : Nat} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {t : St FF.S} {S : SSrv} {C : CSrv}
    {bs : List Byte} (hr : RelB FF (Disp.FRJ (FullRXD P NB)) W [] M ν K D1Body.s155 S t C)
    (hk : Disp.Kp (D1Frames.typedJ bs) K) :
    (∃ o, t.obj? (M.a 2826766) = some o ∧
      D1Endpoint.privateVal o (chars!"handle") = some (.big (M.big 21985))) ∧
    (mlxOf t.ffi).arrs.get (M.handle 21985) = some (M.node 17763) ∧
    ((mlxOf t.ffi).nodes.get (M.node 17763)).map (fun n => (n.shape, n.dtype)) =
      some (M.dims [.lit 1, .lit 1, .lit 5120], 12) := by
  refine ⟨⟨M.obj (objOf D1Body.s155 2826766), hr.obj? outputPresent (unframed hk (by
    change _ ∉ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view]; decide)),
    congrFun mappedHandle M⟩, ?_, ?_⟩
  · obtain ⟨P', hP, rr⟩ := hr.ffi.1
    have hp : PH (mlxOf D1Body.s155.ffi) 21985 := .inl (by rw [D1Body.outputNode]; rfl)
    have hh := rr.load.mlx.arrs 21985 hp
    change (mlxOf t.ffi).arrs.get (M.handle 21985) =
      ((mlxOf D1Body.s155.ffi).arrs.get 21985).map M.node at hh
    rw [D1Body.outputNode] at hh
    exact hh
  · obtain ⟨P', hP, rr⟩ := hr.ffi.1
    cases hs : (mlxOf D1Body.s155.ffi).nodes.get 17763 with
    | none =>
      have hh := shapeDtype
      rw [hs] at hh
      cases hh
    | some nd =>
      obtain ⟨nd', hn, hrn⟩ := rr.load.mlx.nodes 17763 nd hs
      have hh := shapeDtype
      rw [hs] at hh
      simp only [Option.map_some, Option.some.injEq, Prod.mk.injEq] at hh
      rw [hn]
      simp only [Option.map_some]
      rw [hrn.1, hrn.2.1, hh.1, hh.2]

end Host.Load.Run.Tpl.D1BodyOutput
