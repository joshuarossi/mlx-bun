import host.mlx.OrdinaryCachedCall

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

noncomputable section

namespace Host.Load.Run.Full.Ordinary.CachedCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def fixedNumber (n : Nat) : Number := .literal (.lit (.fin false n 0))

def kernelConfig : Config := {
  outs := closedMetadata [([1,1,16,128],12),([1,1,16,128],12),([1,1,48,128],12)]
  grid := [fixedNumber 2560,fixedNumber 1,fixedNumber 1]
  group := [fixedNumber 32,fixedNumber 1,fixedNumber 1]
  ints := [(chars!"C",fixedNumber 10240),(chars!"HK",fixedNumber 16),(chars!"HV",fixedNumber 48),
    (chars!"DK",fixedNumber 128),(chars!"DV",fixedNumber 128)]
  dtypes := [(chars!"T",12)]
  init := none }

noncomputable def capturedConfig : Cfg := match d1.prim with
  | .kernel _ config _ => config
  | _ => ⟨[],[],[],[],[],none⟩

def baseRoles (rest : Nat → GraphNode) (i : Nat) : GraphNode := match i with
  | 22590 => ⟨closedShape [1,1,10240],12,none⟩
  | 10 | 11 => ⟨closedShape [128],12,none⟩
  | 15255 => ⟨closedShape [1,1,16,128],12,some (.kernel 18182 kernelConfig 0,trace.ins)⟩
  | 15256 => ⟨closedShape [1,1,16,128],12,some (.kernel 18182 kernelConfig 1,trace.ins)⟩
  | 15257 => ⟨closedShape [1,1,48,128],12,some (.kernel 18182 kernelConfig 2,trace.ins)⟩
  | _ => rest i

noncomputable def initialRoles (rest : Nat → GraphNode) : Nat → GraphNode := roles (coupledRoles (baseRoles rest))

noncomputable def initialNode (i : Nat) : Node := (source.nodes.get i).getD ⟨.zeros,[],[],0⟩

theorem fixed_config_holds (ν : Nat → F64) (C : CSrv) : kernelConfig.Holds ν C capturedConfig := by
  refine ⟨?_,?_,?_,?_,rfl,.none⟩
  · exact closedMetadata_holds ν C [([1,1,16,128],12),([1,1,16,128],12),([1,1,48,128],12)]
      (by dsimp [listSupport]; decide +kernel)
  · exact .cons (.literal _ _ rfl) (.cons (.literal _ _ rfl) (.cons (.literal _ _ rfl) .nil))
  · exact .cons (.literal _ _ rfl) (.cons (.literal _ _ rfl) (.cons (.literal _ _ rfl) .nil))
  · exact .cons ⟨rfl,.literal _ _ rfl⟩ (.cons ⟨rfl,.literal _ _ rfl⟩
      (.cons ⟨rfl,.literal _ _ rfl⟩ (.cons ⟨rfl,.literal _ _ rfl⟩ (.cons ⟨rfl,.literal _ _ rfl⟩ .nil))))

theorem opaque_node_holds (ν : Nat → F64) (C : CSrv) (shape : List Int) (dtype : Nat) (n : Node)
    (exact : listSupport (fun i => F64.toInt? (F64.ofInt i) = some i) shape)
    (hs : n.shape = shape.map Dim.lit) (hd : n.dtype = dtype) :
    GraphNode.Holds ν C Host.Ts.Owned.Annotated.identity ⟨closedShape shape,dtype,none⟩ n := by
  refine ⟨?_,hd,?_⟩
  · rw [hs]
    exact closedShape_holds ν C shape exact
  · intro p ins h; cases h

theorem kernel_node_holds (ν : Nat → F64) (C : CSrv) (shape : List Int) (index : Nat) (n : Node)
    (exact : listSupport (fun i => F64.toInt? (F64.ofInt i) = some i) shape)
    (hs : n.shape = shape.map Dim.lit) (hd : n.dtype = 12)
    (hp : n.prim = .kernel 18182 capturedConfig index) (hi : n.ins = trace.ins) :
    GraphNode.Holds ν C Host.Ts.Owned.Annotated.identity
      ⟨closedShape shape,12,some (.kernel 18182 kernelConfig index,trace.ins)⟩ n := by
  refine ⟨?_,hd,?_⟩
  · rw [hs]
    exact closedShape_holds ν C shape exact
  · intro p ins h
    have he : (.kernel 18182 kernelConfig index,trace.ins) = (p,ins) := Option.some.inj h
    cases he
    refine ⟨?_,hi⟩
    rw [hp]
    exact .kernel 18182 index (fixed_config_holds ν C)

theorem initial_node_lookup (i : Nat) (hi : N0 i) : source.nodes.get i = some (initialNode i) := by
  simp [N0] at hi
  rcases hi with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> host_kernel_rfl

/-- The finite initial annotation is checked against the exact ordinary-call
source nodes. Numeric tables and valuations are arbitrary because these native
configuration and geometry occurrences are fixed literals. -/
theorem initial_annotations (ν : Nat → F64) (C : CSrv) (rest : Nat → GraphNode)
    (i : Nat) (hi : N0 i) :
    (initialRoles rest i).Holds ν C Host.Ts.Owned.Annotated.identity (initialNode i) := by
  simp [N0] at hi
  rcases hi with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals first
    | apply opaque_node_holds ν C _ _ _ (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
    | apply kernel_node_holds ν C _ _ _ (by dsimp [listSupport]; decide +kernel)
        (by host_kernel_rfl) (by host_kernel_rfl) (by host_kernel_rfl) (by host_kernel_rfl)

theorem initial_role_cut (rest : Nat → GraphNode) (i : Nat) (hi : N0 i) :
    (initialRoles rest i).graph = none → boundary i := by
  simp [N0] at hi
  rcases hi with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [initialRoles,roles,coupledRoles,baseRoles,boundary,trace]

/-- Only the target interpretation remains to be supplied by the surrounding
body invariant. The source interpretation and opaque-root cut are established
by the exact source snapshot. -/
theorem initial_node_relation {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (rest : Nat → GraphNode) (i : Nat) (hi : N0 i) (n n' : Node)
    (lookup : source.nodes.get i = some n)
    (target : (initialRoles rest i).Holds ν C R n') :
    Host.Mlx.Ffi.Annotated.NodeRel (initialRoles rest) ν₀ ν C₀ C R boundary i n n' := by
  have he : initialNode i = n := Option.some.inj ((initial_node_lookup i hi).symm.trans lookup)
  subst n
  exact ⟨initial_annotations ν₀ C₀ rest i hi,target,initial_role_cut rest i hi⟩

def requiredHandles (h : Nat) : Prop := h ∈ [1354,29376,29377,18182]

theorem required_handle_bound (h : Nat) (hh : requiredHandles h) : h < source.next := by
  rw [source_handle_counter]
  simp [requiredHandles] at hh
  rcases hh with rfl | rfl | rfl | rfl <;> decide +kernel

theorem required_handles_are_objects (h : Nat) (hh : requiredHandles h) : source.arrs.get h = none := by
  simp [requiredHandles] at hh
  rcases hh with rfl | rfl | rfl | rfl <;> host_kernel_rfl

end Host.Load.Run.Full.Ordinary.CachedCall
