import host.mlx.OrdinaryMetadataCut
import host.mlx.NativeVectorFreeHost
import host.mlx.OrdinaryVectorHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.MetadataHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩

noncomputable def freePost : Host.Ts.St LSt :=
  finishStatus FreeCall.input FreeCall.input.ffi chars!"mlx_vector_array_free" [.big (Int.ofNat 29371)]
noncomputable def ndimPost : Host.Ts.St LSt :=
  finishBig NdimCall.input NdimCall.input.ffi chars!"mlx_array_ndim" [.big (Int.ofNat 1365)] (Int.ofNat (len NdimCall.node.shape))
noncomputable def shapePost : Host.Ts.St LSt :=
  finishPointer ShapeCall.input ShapeCall.input.ffi chars!"mlx_array_shape" [.big (Int.ofNat 1365)] (4*1365) 0

theorem source_free_post : freePost = FreeCall.output := by host_kernel_rfl
theorem source_ndim_post : ndimPost = NdimCall.output := by host_kernel_rfl
theorem source_shape_post : shapePost = ShapeCall.output := by host_kernel_rfl

theorem source_free_step : step F FreeCall.input = M.pure FreeCall.output := by
  have hk := FreeCall.source_kind
  rw [FreeCall.source_caps] at hk
  have hcall : F.call FreeCall.input.ffi chars!"mlx_vector_array_free" [.big (Int.ofNat 29371)] =
      M.pure (some (FreeCall.input.ffi,status0,[])) := by
    simpa only [F] using Host.Load.Owned.load_vector_free FreeCall.input.ffi (.big (Int.ofNat 29371))
  rw [step_ffi_one_u64 F FreeCall.input 4710 4413 (Int.ofNat 29371) chars!"mlx_vector_array_free"
    FreeCall.returns FreeCall.calleeObject FreeCall.signatureObject (.obj 4817) FreeCall.input.ffi status0
    FreeCall.source_control (by simp only [Host.Ts.St.obj?,FreeCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,FreeCall.source_signature]) FreeCall.source_signature_kind hcall,
    ffiDone_status0_empty]
  change M.pure freePost = _
  rw [source_free_post]

theorem source_ndim_step : step F NdimCall.input = M.pure NdimCall.output := by
  have hk := NdimCall.source_kind
  rw [NdimCall.source_caps] at hk
  have hcall : F.call NdimCall.input.ffi chars!"mlx_array_ndim" [.big (Int.ofNat 1365)] =
      M.pure (some (NdimCall.input.ffi,.big (Int.ofNat (len NdimCall.node.shape)),[])) := by
    simpa only [F,Int.ofNat_eq_natCast] using Host.Load.Owned.call_ndim NdimCall.input.ffi 1365 NdimCall.node NdimCall.source_node
  rw [step_ffi_one_u64 F NdimCall.input 4635 4263 (Int.ofNat 1365) chars!"mlx_array_ndim"
    NdimCall.returns NdimCall.calleeObject NdimCall.signatureObject (.obj 4817) NdimCall.input.ffi
    (.big (Int.ofNat (len NdimCall.node.shape))) NdimCall.source_control
    (by simp only [Host.Ts.St.obj?,NdimCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,NdimCall.source_signature]) NdimCall.source_signature_kind hcall,
    ffiDone_big_empty]
  change M.pure ndimPost = _
  rw [source_ndim_post]

theorem source_shape_step : step F ShapeCall.input = M.pure ShapeCall.output := by
  have hk := ShapeCall.source_kind
  rw [ShapeCall.source_caps] at hk
  have hcall : F.call ShapeCall.input.ffi chars!"mlx_array_shape" [.big (Int.ofNat 1365)] =
      M.pure (some (ShapeCall.input.ffi,.ptr (4*1365) 0,[])) := by
    simpa only [F] using Host.Load.Owned.call_shape ShapeCall.input.ffi 1365 ShapeCall.node ShapeCall.source_node
  rw [step_ffi_one_u64 F ShapeCall.input 4636 4265 (Int.ofNat 1365) chars!"mlx_array_shape"
    ShapeCall.returns ShapeCall.calleeObject ShapeCall.signatureObject (.obj 4817) ShapeCall.input.ffi
    (.ptr (4*1365) 0) ShapeCall.source_control (by simp only [Host.Ts.St.obj?,ShapeCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,ShapeCall.source_signature]) ShapeCall.source_signature_kind hcall,
    ffiDone_pointer_empty]
  change M.pure shapePost = _
  rw [source_shape_post]

/-- Actual rest421 disposes the temporary vector through the original host
wrapper while preserving any complete native invariant supplied at entry. -/
theorem free_transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → LSt → LSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' FreeCall.input s)
    (role : (Host.Ts.Owned.Annotated.Value.handle 29371).Holds ν C R (callArgument s.ctl 0))
    (signatureFrame : ¬ framed 4413) :
    ∃ t, interpC (step F FreeCall.input).run C₀ = some (FreeCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' FreeCall.output t ∧
      t.ffi = s.ffi ∧ t.ctl = .ret (.num zeroN) := by
  have hk := FreeCall.source_kind
  rw [FreeCall.source_caps] at hk
  have hz : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
  obtain ⟨h₀,ht,hr⟩ := step_vector_free_from_source _ FR R C₀ C ν live framed before after old old'
    FreeCall.input s h 4710 4413 29371 FreeCall.calleeObject FreeCall.signatureObject FreeCall.returns (.obj 4817)
    FreeCall.source_control FreeCall.source_callee hk FreeCall.source_signature FreeCall.source_signature_kind
    signatureFrame hz role
  change StateR _ _ _ _ _ _ _ _ _ freePost _ at hr
  rw [source_free_post] at hr
  exact ⟨_,by simpa only [F,Host.Load.ffi,← source_free_post,freePost] using h₀,
    by simpa only [F,Host.Load.ffi] using ht,hr,rfl,rfl⟩

/-- The exact original disposal also preserves every heap address and the
allocation counter, so host occurrence annotations survive its return. -/
theorem free_transport_heap (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → LSt → LSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' FreeCall.input s)
    (role : (Host.Ts.Owned.Annotated.Value.handle 29371).Holds ν C R (callArgument s.ctl 0))
    (signatureFrame : ¬ framed 4413) :
    ∃ t, interpC (step F FreeCall.input).run C₀ = some (FreeCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' FreeCall.output t ∧
      t.ffi = s.ffi ∧ t.ctl = .ret (.num zeroN) ∧ t.heap = s.heap ∧ t.next = s.next := by
  have hk := FreeCall.source_kind
  rw [FreeCall.source_caps] at hk
  have hz : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
  obtain ⟨h₀,ht,hr⟩ := step_vector_free_from_source _ FR R C₀ C ν live framed before after old old'
    FreeCall.input s h 4710 4413 29371 FreeCall.calleeObject FreeCall.signatureObject FreeCall.returns (.obj 4817)
    FreeCall.source_control FreeCall.source_callee hk FreeCall.source_signature FreeCall.source_signature_kind
    signatureFrame hz role
  change StateR _ _ _ _ _ _ _ _ _ freePost _ at hr
  rw [source_free_post] at hr
  exact ⟨_,by simpa only [F,Host.Load.ffi,← source_free_post,freePost] using h₀,
    by simpa only [F,Host.Load.ffi] using ht,hr,rfl,rfl,rfl,rfl⟩

/-- Actual rest484 obtains rank from the owned node, allowing dimensions to
vary while retaining their list length and every indexed native annotation. -/
theorem ndim_transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' NdimCall.input s)
    (role : (Host.Ts.Owned.Annotated.Value.handle 1365).Holds ν C R (callArgument s.ctl 0))
    (signatureFrame : ¬ framed 4263) (handleLive : H 1365) :
    ∃ t, interpC (step F NdimCall.input).run C₀ = some (NdimCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R live framed before after old old' NdimCall.output t ∧ t.ffi = s.ffi := by
  have hk := NdimCall.source_kind
  rw [NdimCall.source_caps] at hk
  obtain ⟨h₀,ht,hr⟩ := step_ndim_from_source _ _ R C₀ C ν live framed before after old old' NdimCall.input s h
    _ _ H N tail h.native.2 (fun _ _ _ p => p.base.shape) 4635 4263 1365 NdimCall.calleeObject
    NdimCall.signatureObject NdimCall.returns (.obj 4817) NdimCall.node NdimCall.source_control NdimCall.source_callee
    hk NdimCall.source_signature NdimCall.source_signature_kind signatureFrame handleLive NdimCall.source_node role
  change StateR _ _ _ _ _ _ _ _ _ ndimPost _ at hr
  rw [source_ndim_post] at hr
  exact ⟨_,by simpa only [F,Host.Load.ffi,← source_ndim_post,ndimPost] using h₀,
    by simpa only [F,Host.Load.ffi] using ht,hr,rfl⟩

theorem source_ndim_rank : len NdimCall.node.shape = 3 := by host_kernel_rfl

/-- The original rank query returns ordinary bigint three and leaves both
the host heap and allocation counter unchanged. -/
theorem ndim_transport_heap_literal (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' NdimCall.input s)
    (role : (Host.Ts.Owned.Annotated.Value.handle 1365).Holds ν C R (callArgument s.ctl 0))
    (signatureFrame : ¬ framed 4263) (handleLive : H 1365) :
    ∃ t, interpC (step F NdimCall.input).run C₀ = some (NdimCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R live framed before after old old' NdimCall.output t ∧
      t.ffi = s.ffi ∧ t.heap = s.heap ∧ t.next = s.next ∧ t.ctl = .ret (.big 3) := by
  have hk := NdimCall.source_kind
  rw [NdimCall.source_caps] at hk
  obtain ⟨h₀,ht,hr⟩ := step_ndim_from_source _ _ R C₀ C ν live framed before after old old' NdimCall.input s h
    _ _ H N tail h.native.2 (fun _ _ _ p => p.base.shape) 4635 4263 1365 NdimCall.calleeObject
    NdimCall.signatureObject NdimCall.returns (.obj 4817) NdimCall.node NdimCall.source_control NdimCall.source_callee
    hk NdimCall.source_signature NdimCall.source_signature_kind signatureFrame handleLive NdimCall.source_node role
  change StateR _ _ _ _ _ _ _ _ _ ndimPost _ at hr
  rw [source_ndim_post] at hr
  refine ⟨_,by simpa only [F,Host.Load.ffi,← source_ndim_post,ndimPost] using h₀,
    by simpa only [F,Host.Load.ffi] using ht,hr,rfl,rfl,rfl,?_⟩
  change Ctl.ret (.big (Int.ofNat (len NdimCall.node.shape))) = _
  rw [source_ndim_rank]
  rfl

/-- Rank lookup also retains the exact pending caller continuation. -/
theorem ndim_transport_heap_literal_stack (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' NdimCall.input s)
    (role : (Host.Ts.Owned.Annotated.Value.handle 1365).Holds ν C R (callArgument s.ctl 0))
    (signatureFrame : ¬ framed 4263) (handleLive : H 1365) :
    ∃ t, interpC (step F NdimCall.input).run C₀ = some (NdimCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R live framed before after old old' NdimCall.output t ∧
      t.ffi = s.ffi ∧ t.heap = s.heap ∧ t.next = s.next ∧ t.ctl = .ret (.big 3) ∧ t.stack = s.stack := by
  have hk := NdimCall.source_kind
  rw [NdimCall.source_caps] at hk
  obtain ⟨h₀,ht,hr⟩ := step_ndim_from_source _ _ R C₀ C ν live framed before after old old' NdimCall.input s h
    _ _ H N tail h.native.2 (fun _ _ _ p => p.base.shape) 4635 4263 1365 NdimCall.calleeObject
    NdimCall.signatureObject NdimCall.returns (.obj 4817) NdimCall.node NdimCall.source_control NdimCall.source_callee
    hk NdimCall.source_signature NdimCall.source_signature_kind signatureFrame handleLive NdimCall.source_node role
  change StateR _ _ _ _ _ _ _ _ _ ndimPost _ at hr
  rw [source_ndim_post] at hr
  refine ⟨_,by simpa only [F,Host.Load.ffi,← source_ndim_post,ndimPost] using h₀,
    by simpa only [F,Host.Load.ffi] using ht,hr,rfl,rfl,rfl,?_,rfl⟩
  change Ctl.ret (.big (Int.ofNat (len NdimCall.node.shape))) = _
  rw [source_ndim_rank]
  rfl

/-- Actual rest529 returns the shape region supplied by native ownership;
all target native lookups follow from the entry graph invariant. -/
theorem shape_transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' ShapeCall.input s)
    (role : (Host.Ts.Owned.Annotated.Value.handle 1365).Holds ν C R (callArgument s.ctl 0))
    (signatureFrame : ¬ framed 4265) (handleLive : H 1365)
    (region : R.region (4*1365) = 4*R.handle 1365) :
    ∃ t, interpC (step F ShapeCall.input).run C₀ = some (ShapeCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R live framed before after old old' ShapeCall.output t ∧ t.ffi = s.ffi ∧
      t.ctl = .ret (.ptr (.ext (R.region (4*1365))) 0) := by
  have hk := ShapeCall.source_kind
  rw [ShapeCall.source_caps] at hk
  obtain ⟨h₀,ht,hr⟩ := step_shape_from_source _ _ R C₀ C ν live framed before after old old' ShapeCall.input s h
    _ _ H N tail h.native.2 4636 4265 1365 ShapeCall.calleeObject ShapeCall.signatureObject ShapeCall.returns
    (.obj 4817) ShapeCall.node ShapeCall.source_control ShapeCall.source_callee hk ShapeCall.source_signature
    ShapeCall.source_signature_kind signatureFrame handleLive ShapeCall.source_node region role
  change StateR _ _ _ _ _ _ _ _ _ shapePost _ at hr
  rw [source_shape_post] at hr
  exact ⟨_,by simpa only [F,Host.Load.ffi,← source_shape_post,shapePost] using h₀,
    by simpa only [F,Host.Load.ffi] using ht,hr,rfl,rfl⟩

end Host.Load.Run.Full.Ordinary.MetadataHost
