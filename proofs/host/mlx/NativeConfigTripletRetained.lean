import host.mlx.NativeConfigIntRetained

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigTripletInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated
open ConfigHost

/-- Grid/group declarations retain the three current literal meanings
through the original i32 decoders. Their numeric tables remain unchanged;
the configuration, all host inventories and producer policy are updated. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (op : ConfigTriplet) (fn types handle : Nat) (x₀ y₀ z₀ : NumV)
    (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle),.num x₀,.num y₀,.num z₀])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str op.name,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (configRole : Config) (sourceConfig : Cfg) (objectRole : objects handle = .config configRole)
    (configRead : s₀.ffi.mlx.obj? handle = some (.cfg sourceConfig))
    (fnRole thisRole : Annotated.Value) (ex ey ez : SymE)
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.handle handle,.literal ex,.literal ey,.literal ez])
    (sourceBound : handle < 2^64) (targetBound : R.handle handle < 2^64) :
    let updated := objectWrite objects handle (.config (op.role configRole
      [(Number.literal ex).decoded .i32,(Number.literal ey).decoded .i32,(Number.literal ez).decoded .i32]))
    ∃ x₀' y₀' z₀' x' y' z' target,
      interpC (step Host.Load.ffi s₀).run C₀ = some (finishTriplet op s₀ handle sourceConfig x₀' y₀' z₀',C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishTriplet op s (R.handle handle) target x' y' z',C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary updated H N tail host)
        R live framed before after old old' (finishTriplet op s₀ handle sourceConfig x₀' y₀' z₀')
        (finishTriplet op s (R.handle handle) target x' y' z') ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote nativeStatusRole}) ν₀ ν C₀ C R live
        (finishTriplet op s₀ handle sourceConfig x₀' y₀' z₀') (finishTriplet op s (R.handle handle) target x' y' z') ∧
      ProducerAnnotations roots H N nodes updated := by
  dsimp only
  let arguments : List Annotated.Value := [.handle handle,.literal ex,.literal ey,.literal ez]
  have handleRole := (inventory.runtime.call_argument_role fnRole thisRole arguments (.obj fn) receiver _
    control controlNote 0 (.handle handle) rfl).2
  obtain ⟨leftX,rightX⟩ := inventory.runtime.call_argument_role fnRole thisRole arguments (.obj fn) receiver _
    control controlNote 1 (.literal ex) rfl
  obtain ⟨leftY,rightY⟩ := inventory.runtime.call_argument_role fnRole thisRole arguments (.obj fn) receiver _
    control controlNote 2 (.literal ey) rfl
  obtain ⟨leftZ,rightZ⟩ := inventory.runtime.call_argument_role fnRole thisRole arguments (.obj fn) receiver _
    control controlNote 3 (.literal ez) rfl
  have sourceX := (ConfigIntegerArgument.literal ex).number (by simpa only [control,callArgument,Host.Ts.arg,nthD] using leftX)
  have sourceY := (ConfigIntegerArgument.literal ey).number (by simpa only [control,callArgument,Host.Ts.arg,nthD] using leftY)
  have sourceZ := (ConfigIntegerArgument.literal ez).number (by simpa only [control,callArgument,Host.Ts.arg,nthD] using leftZ)
  obtain ⟨x₀',y₀',z₀',x',y',z',target,D₀,D,left,right,post,_,_,literalServers⟩ :=
    ConfigHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host live framed before after old old' s₀ s h
      op fn types handle x₀ y₀ z₀ function signatureObject returns receiver control functionRead functionKind signatureRead signatureKind
      signatureFrame handleLive configRole sourceConfig objectRole configRead (.literal ex) (.literal ey) (.literal ez)
      sourceX sourceY sourceZ handleRole ((ConfigIntegerArgument.literal ex).value rightX)
      ((ConfigIntegerArgument.literal ey).value rightY) ((ConfigIntegerArgument.literal ez).value rightZ) sourceBound targetBound
  obtain ⟨sourceTable,targetTable⟩ := literalServers ex ey ez rfl rfl rfl
  subst D₀; subst D
  have runtime : RuntimeInventory {notes.runtime with control := returnNote nativeStatusRole} ν₀ ν C₀ C R live
      (finishTriplet op s₀ handle sourceConfig x₀' y₀' z₀') (finishTriplet op s (R.handle handle) target x' y' z') :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (nativeStatusRole_holds ν₀ C₀ identity),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (nativeStatusRole_holds ν C R),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨x₀',y₀',z₀',x',y',z',target,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C),
    policy.config_write handle (op.role configRole
      [(Number.literal ex).decoded .i32,(Number.literal ey).decoded .i32,(Number.literal ez).decoded .i32])⟩

end Host.Load.Run.Full.Ordinary.ConfigTripletInventory
