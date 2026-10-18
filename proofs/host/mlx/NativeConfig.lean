import host.mlx.ObjectRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem cfgUpdate_success (s : St) (a : Nat) (c d : Cfg) (f : Cfg → Option Cfg)
    (hc : s.obj? a = some (.cfg c)) (hf : f c = some d) :
    cfgUpdate s (.big (Int.ofNat a)) f = ok (s.setObj a (.cfg d)) status0 := by
  unfold cfgUpdate
  simp only [argNat_big_nat, Option.bind_some, hc, Option.map_some, hf]

theorem call_cfgGrid (s : St) (a : Nat) (x y z : NumV) :
    call s chars!"mlx_fast_metal_kernel_config_set_grid" [.big (Int.ofNat a),.num x,.num y,.num z] =
      cfgUpdate s (.big (Int.ofNat a)) (fun c => some { c with grid := [x,y,z] }) := by
  have hs : symOf chars!"mlx_fast_metal_kernel_config_set_grid" = some .cfgGrid := by decide +kernel
  unfold call; rw [hs]

theorem call_cfgGroup (s : St) (a : Nat) (x y z : NumV) :
    call s chars!"mlx_fast_metal_kernel_config_set_thread_group" [.big (Int.ofNat a),.num x,.num y,.num z] =
      cfgUpdate s (.big (Int.ofNat a)) (fun c => some { c with group := [x,y,z] }) := by
  have hs : symOf chars!"mlx_fast_metal_kernel_config_set_thread_group" = some .cfgGroup := by decide +kernel
  unfold call; rw [hs]

theorem call_cfgInit (s : St) (a : Nat) (x : NumV) :
    call s chars!"mlx_fast_metal_kernel_config_set_init_value" [.big (Int.ofNat a),.num x] =
      cfgUpdate s (.big (Int.ofNat a)) (fun c => some { c with init := some x }) := by
  have hs : symOf chars!"mlx_fast_metal_kernel_config_set_init_value" = some .cfgInit := by decide +kernel
  unfold call; rw [hs]

theorem call_cfgInt (s : St) (a : Nat) (nm : Arg) (name : List Char) (x : NumV)
    (hn : cstrArg nm = some name) :
    call s chars!"mlx_fast_metal_kernel_config_add_template_arg_int" [.big (Int.ofNat a),nm,.num x] =
      cfgUpdate s (.big (Int.ofNat a)) (fun c => some { c with ints := c.ints ++ [(name,x)] }) := by
  have hs : symOf chars!"mlx_fast_metal_kernel_config_add_template_arg_int" = some .cfgInt := by decide +kernel
  unfold call; rw [hs]; simp only [hn]

theorem call_cfgDtype (s : St) (a : Nat) (nm : Arg) (name : List Char) (dt : Nat)
    (hn : cstrArg nm = some name) :
    call s chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype" [.big (Int.ofNat a),nm,.big (Int.ofNat dt)] =
      cfgUpdate s (.big (Int.ofNat a)) (fun c => some { c with dtypes := c.dtypes ++ [(name,dt)] }) := by
  have hs : symOf chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype" = some .cfgDtype := by decide +kernel
  unfold call; rw [hs]; simp only [hn, argNat_big_nat]

theorem call_cfgOutput (s : St) (a : Nat) (sh nd : Arg) (shape : List Dim) (dt : Nat)
    (hd : dimsArg sh nd = some shape) :
    call s chars!"mlx_fast_metal_kernel_config_add_output_arg" [.big (Int.ofNat a),sh,nd,.big (Int.ofNat dt)] =
      cfgUpdate s (.big (Int.ofNat a)) (fun c => some { c with outs := c.outs ++ [(shape,dt)] }) := by
  have hs : symOf chars!"mlx_fast_metal_kernel_config_add_output_arg" = some .cfgOutput := by decide +kernel
  unfold call; rw [hs]; simp only [hd, argNat_big_nat]

namespace Live
variable {NR : NumV → NumV → Prop} {R : Ren}
  {NodeRel : Nat → Node → Node → Prop} {H N : Nat → Prop} {tail : List NumV} {s s' : St}

theorem cfg_view (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s')
    (a : Nat) (ha : H a) (c : Cfg) (hc : s.obj? a = some (.cfg c)) :
    ∃ c', s'.obj? (R.handle a) = some (.cfg c') ∧ CfgR NR c c' := by
  have hv := h.objs a ha
  change OptionR (ObjectR NR R) (s.obj? a) (s'.obj? (R.handle a)) at hv
  rw [hc] at hv
  cases ht : s'.obj? (R.handle a) with
  | none => rw [ht] at hv; cases hv
  | some o =>
    rw [ht] at hv
    cases hv with
    | some hr => cases hr with
      | cfg hr => exact ⟨_, rfl, hr⟩

/-- Actual configuration updates preserve every live native resource when the
field update satisfies its numeric roles. The two callbacks may produce
different literal sizes and different number references. -/
theorem cfgUpdate (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s')
    (a : Nat) (ha : H a) (c c' d d' : Cfg) (f f' : Cfg → Option Cfg)
    (hc : s.obj? a = some (.cfg c)) (hc' : s'.obj? (R.handle a) = some (.cfg c'))
    (hf : f c = some d) (hf' : f' c' = some d') (hd : CfgR NR d d')
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    Ffi.cfgUpdate s (.big (Int.ofNat a)) f = ok (s.setObj a (.cfg d)) status0 ∧
      Ffi.cfgUpdate s' (.big (Int.ofNat (R.handle a))) f' = ok (s'.setObj (R.handle a) (.cfg d')) status0 ∧
      Live NR R NodeRel (fun _ => ObjectR NR R) H N tail
        (s.setObj a (.cfg d)) (s'.setObj (R.handle a) (.cfg d')) :=
  ⟨cfgUpdate_success s a c d f hc hf, cfgUpdate_success s' (R.handle a) c' d' f' hc' hf',
    h.setObj a ha _ _ (.cfg hd) bs bt⟩

end Live
end Host.Mlx.Ffi.NativeRoles
