import host.sim.footprint.Objects

namespace Host.Mlx.Ffi.Footprint
open Host.Ts FullKeep

/-- The six setters dispatched by the actual Metal configuration API. -/
def ConfigSym : Sym → Bool
  | .cfgOutput | .cfgGrid | .cfgGroup | .cfgInit | .cfgInt | .cfgDtype => true
  | _ => false

macro "config_dispatch_w" : tactic => `(tactic|
  (unfold call
   rw [show symOf _ = some _ from by assumption]
   dsimp only
   repeat' (first
     | (allx_goal; reduce_call)
     | (allx_goal; case_call)
     | with_reducible refine cfgUpdate_w (Writes.refl _) _ _ ?_
     | (intro h he; exact ⟨_, _, rfl, he⟩)
     | with_reducible exact result_stuck
     | split)))

theorem call_cfgOutput_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .cfgOutput) :
    AllX (Result (FirstHandle args) (fun _ => False) s id) (call s name args) := by
  config_dispatch_w

theorem call_cfgGroup_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .cfgGroup) :
    AllX (Result (FirstHandle args) (fun _ => False) s id) (call s name args) := by
  config_dispatch_w

theorem call_cfgInit_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .cfgInit) :
    AllX (Result (FirstHandle args) (fun _ => False) s id) (call s name args) := by
  config_dispatch_w

theorem call_cfgInt_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .cfgInt) :
    AllX (Result (FirstHandle args) (fun _ => False) s id) (call s name args) := by
  config_dispatch_w

theorem call_cfgDtype_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some .cfgDtype) :
    AllX (Result (FirstHandle args) (fun _ => False) s id) (call s name args) := by
  config_dispatch_w

theorem call_config_w (s : St) (name : Name) (args : List Arg)
    (ha : (symOf name).any ConfigSym = true) :
    AllX (Result (FirstHandle args) (fun _ => False) s id) (call s name args) := by
  cases hn : symOf name with
  | none => simp only [hn, Option.any] at ha; contradiction
  | some x =>
    rw [hn] at ha
    cases x <;> simp only [Option.any, ConfigSym] at ha <;> try contradiction
    all_goals first
      | exact call_cfgOutput_w s name args hn
      | exact call_cfgGrid_w s name args hn
      | exact call_cfgGroup_w s name args hn
      | exact call_cfgInit_w s name args hn
      | exact call_cfgInt_w s name args hn
      | exact call_cfgDtype_w s name args hn

theorem fullCall_config_w (p : Host.Ts.Sim.Full.FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any ConfigSym = true) :
    AllX (Result (FirstHandle args) (fun _ => False) (Host.Ts.Sim.Full.mlxOf p) Host.Ts.Sim.Full.mlxOf)
      (Host.Ts.Sim.Full.FF.call p name args) := by
  apply fullCall_w p name args hm hp (call_config_w _ name args ha)
  cases hn : symOf name with
  | none => simp only [hn, Option.any] at ha; contradiction
  | some x =>
    rw [hn] at ha
    cases x <;> simp only [Option.any, ConfigSym] at ha <;> try contradiction
    all_goals unfold SymShape.symShapeCall; rw [hn]; exact result_stuck

end Host.Mlx.Ffi.Footprint
