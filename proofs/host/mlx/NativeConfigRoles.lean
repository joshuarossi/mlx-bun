import host.mlx.ReplayObjects
import host.mlx.NativeAlloc
import host.mlx.NativeConfig

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def emptyConfig : Config := ⟨[],[],[],[],[],none⟩

theorem Config.Holds.empty (ν : Nat → F64) (C : CSrv) : emptyConfig.Holds ν C Cfg.empty :=
  ⟨.nil,.nil,.nil,.nil,rfl,.none⟩

theorem Config.Holds.setGrid {ν : Nat → F64} {C : CSrv} {r : Config} {c : Cfg}
    (h : r.Holds ν C c) {roles : List Number} {values : List NumV} (hv : ListR (Number.Holds ν C) roles values) :
    Config.Holds ν C {r with grid := roles} {c with grid := values} :=
  ⟨h.output,hv,h.group,h.ints,h.dtypes,h.init⟩

theorem Config.Holds.setGroup {ν : Nat → F64} {C : CSrv} {r : Config} {c : Cfg}
    (h : r.Holds ν C c) {roles : List Number} {values : List NumV} (hv : ListR (Number.Holds ν C) roles values) :
    Config.Holds ν C {r with group := roles} {c with group := values} :=
  ⟨h.output,h.grid,hv,h.ints,h.dtypes,h.init⟩

theorem Config.Holds.setInit {ν : Nat → F64} {C : CSrv} {r : Config} {c : Cfg}
    (h : r.Holds ν C c) {role : Number} {value : NumV} (hv : role.Holds ν C value) :
    Config.Holds ν C {r with init := some role} {c with init := some value} :=
  ⟨h.output,h.grid,h.group,h.ints,h.dtypes,.some hv⟩

theorem Config.Holds.addInt {ν : Nat → F64} {C : CSrv} {r : Config} {c : Cfg}
    (h : r.Holds ν C c) (name : Name) {role : Number} {value : NumV} (hv : role.Holds ν C value) :
    Config.Holds ν C {r with ints := r.ints ++ [(name,role)]} {c with ints := c.ints ++ [(name,value)]} :=
  ⟨h.output,h.grid,h.group,h.ints.append (.cons ⟨rfl,hv⟩ .nil),h.dtypes,h.init⟩

theorem Config.Holds.addDtype {ν : Nat → F64} {C : CSrv} {r : Config} {c : Cfg}
    (h : r.Holds ν C c) (name : Name) (dtype : Nat) :
    Config.Holds ν C {r with dtypes := r.dtypes ++ [(name,dtype)]} {c with dtypes := c.dtypes ++ [(name,dtype)]} :=
  ⟨h.output,h.grid,h.group,h.ints,congrArg (· ++ [(name,dtype)]) h.dtypes,h.init⟩

theorem Config.Holds.addOutput {ν : Nat → F64} {C : CSrv} {r : Config} {c : Cfg}
    (h : r.Holds ν C c) {role : Shape} {value : List Dim} (dtype : Nat) (hv : Shape.Holds ν C role value) :
    Config.Holds ν C {r with outs := r.outs ++ [(role,dtype)]} {c with outs := c.outs ++ [(value,dtype)]} :=
  ⟨h.output.append (.cons ⟨hv,rfl⟩ .nil),h.grid,h.group,h.ints,h.dtypes,h.init⟩

theorem ObjectRel.write_config (roles : Nat → Object) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (slot : Nat) (role : Config) (source target : Cfg)
    (hs : role.Holds ν₀ C₀ source) (ht : role.Holds ν C target) :
    ObjectRel (objectWrite roles slot (.config role)) ν₀ ν C₀ C R slot (.cfg source) (.cfg target) := by
  constructor
  · simp only [objectWrite,ite_true]; exact .config hs
  · simp only [objectWrite,ite_true]; exact .config ht

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

variable {NR : NumV → NumV → Prop} {R : Ren} {NodeRel : Nat → Node → Node → Prop}
  {objects : Nat → Object} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
  {H N : Nat → Prop} {tail : List NumV} {s s' : St}

/-- The fixed configuration annotation yields the target payload and both
interpretations of its numeric fields from the source object lookup. -/
theorem config_view_roles
    (h : Live NR R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (a : Nat) (ha : H a) (role : Config) (source : Cfg)
    (hr : objects a = .config role) (hc : s.obj? a = some (.cfg source)) :
    ∃ target, s'.obj? (R.handle a) = some (.cfg target) ∧ role.Holds ν₀ C₀ source ∧ role.Holds ν C target := by
  have hv := h.objs a ha
  change OptionR (ObjectRel objects ν₀ ν C₀ C R a) (s.obj? a) (s'.obj? (R.handle a)) at hv
  rw [hc] at hv
  cases ht : s'.obj? (R.handle a) with
  | none => rw [ht] at hv; cases hv
  | some obj =>
    rw [ht] at hv
    cases hv with | some pair =>
      have hs := pair.source
      have ht' := pair.target
      rw [hr] at hs ht'
      cases hs with | config hs =>
        cases ht' with | config ht' => exact ⟨_,rfl,hs,ht'⟩

/-- Updating a configuration retains every other indexed object annotation.
The local field laws are about exact records, not a native execution premise. -/
theorem cfgUpdate_roles
    (h : Live NR R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (a : Nat) (ha : H a) (role updated : Config) (source : Cfg)
    (hr : objects a = .config role) (hc : s.obj? a = some (.cfg source))
    (sourceUpdate targetUpdate : Cfg → Cfg)
    (sourceFields : ∀ c, role.Holds ν₀ C₀ c → updated.Holds ν₀ C₀ (sourceUpdate c))
    (targetFields : ∀ c, role.Holds ν C c → updated.Holds ν C (targetUpdate c))
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    ∃ target, s'.obj? (R.handle a) = some (.cfg target) ∧
      Ffi.cfgUpdate s (.big (Int.ofNat a)) (fun c => some (sourceUpdate c)) =
        ok (s.setObj a (.cfg (sourceUpdate source))) status0 ∧
      Ffi.cfgUpdate s' (.big (Int.ofNat (R.handle a))) (fun c => some (targetUpdate c)) =
        ok (s'.setObj (R.handle a) (.cfg (targetUpdate target))) status0 ∧
      Live NR R NodeRel (ObjectRel (objectWrite objects a (.config updated)) ν₀ ν C₀ C R) H N tail
        (s.setObj a (.cfg (sourceUpdate source))) (s'.setObj (R.handle a) (.cfg (targetUpdate target))) := by
  obtain ⟨target,ht,hsf,htf⟩ := h.config_view_roles a ha role source hr hc
  exact ⟨target,ht,cfgUpdate_success s a source _ _ hc rfl,
    cfgUpdate_success s' (R.handle a) target _ _ ht rfl,
    h.setObjectRoles a ha _ _
      (ObjectRel.write_config objects ν₀ ν C₀ C R a updated _ _ (sourceFields _ hsf) (targetFields _ htf))
      (fun _ ne _ _ p => ObjectRel.write_frame ne p) bs bt⟩

/-- The empty Metal configuration receives its fixed empty annotation when
the original constructor allocates its fresh handle. -/
theorem config_new_roles
    (h : Live NR R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (bs : s.next < 2^64) (bt : s'.next < 2^64) :
    Ffi.call s chars!"mlx_fast_metal_kernel_config_new" [] = ok (s.newObj (.cfg .empty)).2 (.big (Int.ofNat s.next)) ∧
      Ffi.call s' chars!"mlx_fast_metal_kernel_config_new" [] = ok (s'.newObj (.cfg .empty)).2 (.big (Int.ofNat s'.next)) ∧
      Live NR R NodeRel (ObjectRel (objectWrite objects s.next (.config emptyConfig)) ν₀ ν C₀ C R)
        (fun a => a = s.next ∨ H a) N tail (s.newObj (.cfg .empty)).2 (s'.newObj (.cfg .empty)).2 :=
  ⟨Constructor.call .config s,Constructor.call .config s',
    h.newObjectRoles _ _ (ObjectRel.write_config objects ν₀ ν C₀ C R s.next emptyConfig _ _
      (Config.Holds.empty ν₀ C₀) (Config.Holds.empty ν C))
      (fun _ ne _ _ p => ObjectRel.write_frame ne p) bs bt⟩

theorem config_grid_roles
    (h : Live NR R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (a : Nat) (ha : H a) (role : Config) (source : Cfg)
    (hr : objects a = .config role) (hc : s.obj? a = some (.cfg source))
    (rx ry rz : Number) (x₀ y₀ z₀ x y z : NumV)
    (hx₀ : rx.Holds ν₀ C₀ x₀) (hy₀ : ry.Holds ν₀ C₀ y₀) (hz₀ : rz.Holds ν₀ C₀ z₀)
    (hx : rx.Holds ν C x) (hy : ry.Holds ν C y) (hz : rz.Holds ν C z)
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    ∃ target, s'.obj? (R.handle a) = some (.cfg target) ∧
      Ffi.call s chars!"mlx_fast_metal_kernel_config_set_grid" [.big (Int.ofNat a),.num x₀,.num y₀,.num z₀] =
        ok (s.setObj a (.cfg {source with grid := [x₀,y₀,z₀]})) status0 ∧
      Ffi.call s' chars!"mlx_fast_metal_kernel_config_set_grid" [.big (Int.ofNat (R.handle a)),.num x,.num y,.num z] =
        ok (s'.setObj (R.handle a) (.cfg {target with grid := [x,y,z]})) status0 ∧
      Live NR R NodeRel (ObjectRel (objectWrite objects a (.config {role with grid := [rx,ry,rz]})) ν₀ ν C₀ C R) H N tail
        (s.setObj a (.cfg {source with grid := [x₀,y₀,z₀]})) (s'.setObj (R.handle a) (.cfg {target with grid := [x,y,z]})) := by
  obtain ⟨target,ht,hs,ht',hl⟩ := h.cfgUpdate_roles a ha role {role with grid := [rx,ry,rz]} source hr hc
    (fun c => {c with grid := [x₀,y₀,z₀]}) (fun c => {c with grid := [x,y,z]})
    (fun _ h => h.setGrid (.cons hx₀ (.cons hy₀ (.cons hz₀ .nil))))
    (fun _ h => h.setGrid (.cons hx (.cons hy (.cons hz .nil)))) bs bt
  exact ⟨target,ht,by rw [call_cfgGrid]; exact hs,by rw [call_cfgGrid]; exact ht',hl⟩

theorem config_group_roles
    (h : Live NR R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (a : Nat) (ha : H a) (role : Config) (source : Cfg)
    (hr : objects a = .config role) (hc : s.obj? a = some (.cfg source))
    (rx ry rz : Number) (x₀ y₀ z₀ x y z : NumV)
    (hx₀ : rx.Holds ν₀ C₀ x₀) (hy₀ : ry.Holds ν₀ C₀ y₀) (hz₀ : rz.Holds ν₀ C₀ z₀)
    (hx : rx.Holds ν C x) (hy : ry.Holds ν C y) (hz : rz.Holds ν C z)
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    ∃ target, s'.obj? (R.handle a) = some (.cfg target) ∧
      Ffi.call s chars!"mlx_fast_metal_kernel_config_set_thread_group" [.big (Int.ofNat a),.num x₀,.num y₀,.num z₀] =
        ok (s.setObj a (.cfg {source with group := [x₀,y₀,z₀]})) status0 ∧
      Ffi.call s' chars!"mlx_fast_metal_kernel_config_set_thread_group" [.big (Int.ofNat (R.handle a)),.num x,.num y,.num z] =
        ok (s'.setObj (R.handle a) (.cfg {target with group := [x,y,z]})) status0 ∧
      Live NR R NodeRel (ObjectRel (objectWrite objects a (.config {role with group := [rx,ry,rz]})) ν₀ ν C₀ C R) H N tail
        (s.setObj a (.cfg {source with group := [x₀,y₀,z₀]})) (s'.setObj (R.handle a) (.cfg {target with group := [x,y,z]})) := by
  obtain ⟨target,ht,hs,ht',hl⟩ := h.cfgUpdate_roles a ha role {role with group := [rx,ry,rz]} source hr hc
    (fun c => {c with group := [x₀,y₀,z₀]}) (fun c => {c with group := [x,y,z]})
    (fun _ h => h.setGroup (.cons hx₀ (.cons hy₀ (.cons hz₀ .nil))))
    (fun _ h => h.setGroup (.cons hx (.cons hy (.cons hz .nil)))) bs bt
  exact ⟨target,ht,by rw [call_cfgGroup]; exact hs,by rw [call_cfgGroup]; exact ht',hl⟩

theorem config_init_roles
    (h : Live NR R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (a : Nat) (ha : H a) (role : Config) (source : Cfg)
    (hr : objects a = .config role) (hc : s.obj? a = some (.cfg source))
    (valueRole : Number) (x₀ x : NumV) (hx₀ : valueRole.Holds ν₀ C₀ x₀) (hx : valueRole.Holds ν C x)
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    ∃ target, s'.obj? (R.handle a) = some (.cfg target) ∧
      Ffi.call s chars!"mlx_fast_metal_kernel_config_set_init_value" [.big (Int.ofNat a),.num x₀] =
        ok (s.setObj a (.cfg {source with init := some x₀})) status0 ∧
      Ffi.call s' chars!"mlx_fast_metal_kernel_config_set_init_value" [.big (Int.ofNat (R.handle a)),.num x] =
        ok (s'.setObj (R.handle a) (.cfg {target with init := some x})) status0 ∧
      Live NR R NodeRel (ObjectRel (objectWrite objects a (.config {role with init := some valueRole})) ν₀ ν C₀ C R) H N tail
        (s.setObj a (.cfg {source with init := some x₀})) (s'.setObj (R.handle a) (.cfg {target with init := some x})) := by
  obtain ⟨target,ht,hs,ht',hl⟩ := h.cfgUpdate_roles a ha role {role with init := some valueRole} source hr hc
    (fun c => {c with init := some x₀}) (fun c => {c with init := some x})
    (fun _ h => h.setInit hx₀) (fun _ h => h.setInit hx) bs bt
  exact ⟨target,ht,by rw [call_cfgInit]; exact hs,by rw [call_cfgInit]; exact ht',hl⟩

theorem config_int_roles
    (h : Live NR R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (a : Nat) (ha : H a) (role : Config) (source : Cfg)
    (hr : objects a = .config role) (hc : s.obj? a = some (.cfg source))
    (name : Name) (name₀ name' : Arg) (hn₀ : cstrArg name₀ = some name) (hn : cstrArg name' = some name)
    (valueRole : Number) (x₀ x : NumV) (hx₀ : valueRole.Holds ν₀ C₀ x₀) (hx : valueRole.Holds ν C x)
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    ∃ target, s'.obj? (R.handle a) = some (.cfg target) ∧
      Ffi.call s chars!"mlx_fast_metal_kernel_config_add_template_arg_int" [.big (Int.ofNat a),name₀,.num x₀] =
        ok (s.setObj a (.cfg {source with ints := source.ints ++ [(name,x₀)]})) status0 ∧
      Ffi.call s' chars!"mlx_fast_metal_kernel_config_add_template_arg_int" [.big (Int.ofNat (R.handle a)),name',.num x] =
        ok (s'.setObj (R.handle a) (.cfg {target with ints := target.ints ++ [(name,x)]})) status0 ∧
      Live NR R NodeRel (ObjectRel (objectWrite objects a (.config {role with ints := role.ints ++ [(name,valueRole)]})) ν₀ ν C₀ C R) H N tail
        (s.setObj a (.cfg {source with ints := source.ints ++ [(name,x₀)]}))
        (s'.setObj (R.handle a) (.cfg {target with ints := target.ints ++ [(name,x)]})) := by
  obtain ⟨target,ht,hs,ht',hl⟩ := h.cfgUpdate_roles a ha role {role with ints := role.ints ++ [(name,valueRole)]} source hr hc
    (fun c => {c with ints := c.ints ++ [(name,x₀)]}) (fun c => {c with ints := c.ints ++ [(name,x)]})
    (fun _ h => h.addInt name hx₀) (fun _ h => h.addInt name hx) bs bt
  exact ⟨target,ht,by rw [call_cfgInt _ _ _ _ _ hn₀]; exact hs,by rw [call_cfgInt _ _ _ _ _ hn]; exact ht',hl⟩

end Host.Mlx.Ffi.NativeRoles.Live

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts

theorem call_config_dtype_arg (s : St) (a : Nat) (nm dtypeArg : Arg) (name : Name) (dtype : Nat)
    (hn : cstrArg nm = some name) (hd : argNat dtypeArg = some dtype) :
    Ffi.call s chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype" [.big (Int.ofNat a),nm,dtypeArg] =
      cfgUpdate s (.big (Int.ofNat a)) (fun c => some {c with dtypes := c.dtypes ++ [(name,dtype)]}) := by
  have hs : symOf chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype" = some .cfgDtype := by decide +kernel
  unfold Ffi.call
  rw [hs]
  simp only [hn,hd]

theorem call_config_output_arg (s : St) (a : Nat) (sh count dtypeArg : Arg) (shape : List Dim) (dtype : Nat)
    (hn : dimsArg sh count = some shape) (hd : argNat dtypeArg = some dtype) :
    Ffi.call s chars!"mlx_fast_metal_kernel_config_add_output_arg" [.big (Int.ofNat a),sh,count,dtypeArg] =
      cfgUpdate s (.big (Int.ofNat a)) (fun c => some {c with outs := c.outs ++ [(shape,dtype)]}) := by
  have hs : symOf chars!"mlx_fast_metal_kernel_config_add_output_arg" = some .cfgOutput := by decide +kernel
  unfold Ffi.call
  rw [hs]
  simp only [hn,hd]

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

variable {NR : NumV → NumV → Prop} {R : Ren} {NodeRel : Nat → Node → Node → Prop}
  {objects : Nat → Object} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
  {H N : Nat → Prop} {tail : List NumV} {s s' : St}

theorem config_dtype_roles
    (h : Live NR R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (a : Nat) (ha : H a) (role : Config) (source : Cfg)
    (hr : objects a = .config role) (hc : s.obj? a = some (.cfg source))
    (name : Name) (name₀ name' dtype₀ dtype' : Arg) (dtype : Nat)
    (hn₀ : cstrArg name₀ = some name) (hn : cstrArg name' = some name)
    (hd₀ : argNat dtype₀ = some dtype) (hd : argNat dtype' = some dtype)
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    ∃ target, s'.obj? (R.handle a) = some (.cfg target) ∧
      Ffi.call s chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype" [.big (Int.ofNat a),name₀,dtype₀] =
        ok (s.setObj a (.cfg {source with dtypes := source.dtypes ++ [(name,dtype)]})) status0 ∧
      Ffi.call s' chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype" [.big (Int.ofNat (R.handle a)),name',dtype'] =
        ok (s'.setObj (R.handle a) (.cfg {target with dtypes := target.dtypes ++ [(name,dtype)]})) status0 ∧
      Live NR R NodeRel (ObjectRel (objectWrite objects a (.config {role with dtypes := role.dtypes ++ [(name,dtype)]})) ν₀ ν C₀ C R) H N tail
        (s.setObj a (.cfg {source with dtypes := source.dtypes ++ [(name,dtype)]}))
        (s'.setObj (R.handle a) (.cfg {target with dtypes := target.dtypes ++ [(name,dtype)]})) := by
  obtain ⟨target,ht,hs,ht',hl⟩ := h.cfgUpdate_roles a ha role {role with dtypes := role.dtypes ++ [(name,dtype)]} source hr hc
    (fun c => {c with dtypes := c.dtypes ++ [(name,dtype)]}) (fun c => {c with dtypes := c.dtypes ++ [(name,dtype)]})
    (fun _ h => h.addDtype name dtype) (fun _ h => h.addDtype name dtype) bs bt
  exact ⟨target,ht,by rw [call_config_dtype_arg _ _ _ _ _ _ hn₀ hd₀]; exact hs,
    by rw [call_config_dtype_arg _ _ _ _ _ _ hn hd]; exact ht',hl⟩

theorem config_output_roles
    (h : Live NR R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (a : Nat) (ha : H a) (role : Config) (source : Cfg)
    (hr : objects a = .config role) (hc : s.obj? a = some (.cfg source))
    (shapeRole : Shape) (shape₀ shape' : List Dim) (dtype : Nat) (sh₀ sh' count₀ count' dtype₀ dtype' : Arg)
    (hn₀ : dimsArg sh₀ count₀ = some shape₀) (hn : dimsArg sh' count' = some shape')
    (hd₀ : argNat dtype₀ = some dtype) (hd : argNat dtype' = some dtype)
    (hs₀ : Shape.Holds ν₀ C₀ shapeRole shape₀) (hs : Shape.Holds ν C shapeRole shape')
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    ∃ target, s'.obj? (R.handle a) = some (.cfg target) ∧
      Ffi.call s chars!"mlx_fast_metal_kernel_config_add_output_arg" [.big (Int.ofNat a),sh₀,count₀,dtype₀] =
        ok (s.setObj a (.cfg {source with outs := source.outs ++ [(shape₀,dtype)]})) status0 ∧
      Ffi.call s' chars!"mlx_fast_metal_kernel_config_add_output_arg" [.big (Int.ofNat (R.handle a)),sh',count',dtype'] =
        ok (s'.setObj (R.handle a) (.cfg {target with outs := target.outs ++ [(shape',dtype)]})) status0 ∧
      Live NR R NodeRel (ObjectRel (objectWrite objects a (.config {role with outs := role.outs ++ [(shapeRole,dtype)]})) ν₀ ν C₀ C R) H N tail
        (s.setObj a (.cfg {source with outs := source.outs ++ [(shape₀,dtype)]}))
        (s'.setObj (R.handle a) (.cfg {target with outs := target.outs ++ [(shape',dtype)]})) := by
  obtain ⟨target,ht,hsource,htarget,hl⟩ := h.cfgUpdate_roles a ha role {role with outs := role.outs ++ [(shapeRole,dtype)]} source hr hc
    (fun c => {c with outs := c.outs ++ [(shape₀,dtype)]}) (fun c => {c with outs := c.outs ++ [(shape',dtype)]})
    (fun _ h => h.addOutput dtype hs₀) (fun _ h => h.addOutput dtype hs) bs bt
  exact ⟨target,ht,by rw [call_config_output_arg _ _ _ _ _ _ _ hn₀ hd₀]; exact hsource,
    by rw [call_config_output_arg _ _ _ _ _ _ _ hn hd]; exact htarget,hl⟩

end Host.Mlx.Ffi.NativeRoles.Live
