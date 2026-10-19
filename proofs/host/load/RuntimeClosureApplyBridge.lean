import host.load.RuntimeClosureApplyBridgePlan
import host.ts.RenameRetainedChain
import host.mlx.OrdinaryVectorHost
import host.mlx.NativeAnnotationSupport
import host.mlx.NativeProducerSupport

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ClosureApplyBridge
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_theorem before_vector := fun
    (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S)
    (inst : Inst ν₀ Before.Block2337.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' P.RestStream.micro0.micro23.s37 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro23.s37 s)
    (role : Annotated.Value)
    (controlNote : notes.runtime.control = returnNote role)
    (budget : s.next + 256 ≤ 2^64)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, Before using state, inventory, inst

theorem entry_native_counter :
    P.RestStream.micro0.micro23.s37.ffi.mlx.next = 29377 := by host_kernel_rfl

theorem vector_new_native_counter :
    VectorNew.input.ffi.mlx.next = 29377 := by host_kernel_rfl

theorem vector_new_active : isHalt VectorNew.input.ctl = false := by
  rw [VectorNew.source_control]; rfl

theorem vector_new_source : Before.Block2349.output = VectorNew.input := by host_kernel_rfl

theorem vector_new_server : Before.Block2349.nextServer = VectorNew.initialServer := by host_kernel_rfl

theorem vector_new_ffi : VectorNew.F = P.F := by host_kernel_rfl

theorem vector_new_output_counter : VectorNew.output.ffi.mlx.next = 29378 := by host_kernel_rfl

theorem after_source : VectorNew.output = After.Block2351.input := by host_kernel_rfl

theorem after_server : VectorNew.nextServer = After.Block2351.initialServer := by host_kernel_rfl

theorem typed_source : After.Block2352.output = After.Block2353.input := by host_kernel_rfl

theorem typed_server : After.Block2352.nextServer = After.Block2353.initialServer := by host_kernel_rfl

theorem typed_next_source : After.Block2353.output = After.Block2354.input := by host_kernel_rfl

theorem typed_next_server : After.Block2353.nextServer = After.Block2354.initialServer := by host_kernel_rfl

theorem closure_call_output : After.Block2381.output = P.RestStream.micro0.micro23.s82 := by host_kernel_rfl

theorem typed_heap_offset :
    After.Block2352.output.next =
      P.RestStream.micro0.micro23.s37.next +
        (After.Block2352.output.next - P.RestStream.micro0.micro23.s37.next) := by
  decide +kernel

theorem typed_heap_room :
    After.Block2352.output.next - P.RestStream.micro0.micro23.s37.next + 2 ≤ 256 := by
  decide +kernel

-- Thirteen host steps, the checked empty-vector allocation, then thirty-one host steps.
-- The native rule supplies target execution and updated vector ownership.
host_retained_theorem retained_to_call := fun
    (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S)
    (inst : Inst ν₀ Before.Block2337.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' P.RestStream.micro0.micro23.s37 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro23.s37 s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (role : Annotated.Value)
    (controlNote : notes.runtime.control = returnNote role)
    (budget : s.next + 256 ≤ 2^64)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (arrayBufferLive : live aArrayBufferProto) (arrayBufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (metadata : NativeCaptureNote)
    (constructorSelected : notes.captures.owners After.Block2353.address = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit After.Block2353.codeLiteral)))
    (protoNote : metadata.roles 1 = some (.literal (.lit After.Block2353.protoLiteral)))
    (typedLive : live After.Block2353.protoIndex)
    (typedFixed : R.a After.Block2353.protoIndex = After.Block2353.protoIndex)
    (thisRole : Annotated.Value)
    (thisEntry : notes.runtime.cells.cells After.Block2377.sourceAddress = some thisRole)
    (compiledRole : Annotated.Value)
    (compiledEntry : notes.privates.owners After.Block2378.sourceAddress =
      some ⟨After.Block2378.sourceBrand, After.Block2378.sourceName, compiledRole⟩)
    (signatureFrame : ¬ framed VectorNew.sourceTypes)
    (nativeBound : s.ffi.mlx.next + 1 < 2^64) => by
  have earlier := before_vector notes ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s inst state inventory role controlNote budget globalLive globalFixed
  let mid := Classical.choose earlier
  have post := Classical.choose_spec earlier
  have run13 := post.1
  have stateAtCall := post.2.1
  have retainedAtCall := post.2.2.1
  have instAtCall := post.2.2.2
  have sameCounters : mid.ffi.mlx.next = s.ffi.mlx.next := by
    have entryMap := state.native.2.handleMap.head
    have callMap := stateAtCall.native.2.handleMap.head
    change R.handle 29377 = mid.ffi.mlx.next at callMap
    change R.handle 29377 = s.ffi.mlx.next at entryMap
    exact callMap.symm.trans entryMap
  have targetBound : mid.ffi.mlx.next < 2^64 := by
    rw [sameCounters]
    omega
  have allocation := VectorNew.retained_transport (s := mid) (inst := instAtCall) (h := stateAtCall)
    (inventory := retainedAtCall) (policy := policy) (signatureFrame := signatureFrame)
    (targetBound := targetBound)
  dsimp only at allocation
  let created := Classical.choose allocation
  have allocated := Classical.choose_spec allocation
  have targetRun := allocated.2.1
  have stateCreated := allocated.2.2.1
  have retainedCreated := allocated.2.2.2.1
  have instCreated := allocated.2.2.2.2.1
  have notHalt : isHalt mid.ctl = false := by
    rw [stateAtCall.control.isHalt_eq]
    exact vector_new_active
  have run1 := runC_cons P.F 0 mid created created C C C notHalt targetRun rfl
  have run14 := runC_join P.F run13 run1
  host_normalize_retained stateCreated, retainedCreated
  have arrayPrefix := by
    host_retained_chain_after P.F,
      [After.Block2351.retained_transport, After.Block2352.retained_transport]
      using stateCreated, retainedCreated, instCreated
      continuing_run run14 initial_relation state
  let atTyped := Classical.choose arrayPrefix
  have arrayPost := Classical.choose_spec arrayPrefix
  have run16 := arrayPost.1
  have stateAtTyped := arrayPost.2.1
  have retainedAtTyped := arrayPost.2.2.1
  have instAtTyped := arrayPost.2.2.2
  have heapBound : atTyped.next + 1 < 2^64 := by
    have room : atTyped.next + 2 ≤ 2^64 := chain_next_budget_le state stateAtTyped
      (After.Block2352.output.next - P.RestStream.micro0.micro23.s37.next) 2 256 (2^64)
      typed_heap_offset typed_heap_room budget
    exact Nat.lt_of_lt_of_le (Nat.lt_succ_self (atTyped.next + 1)) room
  have nativeAtTyped : atTyped.ffi.mlx.next < 2^64 := by
    have typedMap := stateAtTyped.native.2.handleMap.head
    change R.handle 29378 = atTyped.ffi.mlx.next at typedMap
    have fresh := state.native.2.handleMap.fresh 1
    change R.handle 29378 = s.ffi.mlx.next + 1 at fresh
    have stepped : atTyped.ffi.mlx.next = s.ffi.mlx.next + 1 :=
      typedMap.symm.trans fresh
    rw [stepped]
    exact nativeBound
  have typedTransport := After.Block2353.retained_transport (s := atTyped) (inst := instAtTyped)
    (h := stateAtTyped) (inventory := retainedAtTyped) (native := stateAtTyped.native.2)
    (metadata := metadata) (selected := constructorSelected) (codeNote := codeNote)
    (protoNote := protoNote) (elements := by host_kernel_rfl)
    (owned := by
      rw [show After.Block2353.handles = [29377] from by host_kernel_rfl]
      exact ⟨Or.inl vector_new_native_counter.symm, trivial⟩)
    (nativeBound := nativeAtTyped)
    (bufferProtoLive := by
      simp only [LiveAfter]
      repeat (first | exact arrayBufferLive | apply Or.inl))
    (bufferProtoFixed := arrayBufferFixed)
    (protoLive := by
      simp only [LiveAfter]
      repeat (first | exact typedLive | apply Or.inl))
    (protoFixed := typedFixed) (targetBound := heapBound)
  let typedResult := Classical.choose typedTransport
  have typedPost := Classical.choose_spec typedTransport
  have notHaltTyped : isHalt atTyped.ctl = false := by
    rw [stateAtTyped.control.isHalt_eq, typed_source, After.Block2353.source_control]
    rfl
  have runTyped := runC_cons P.F 0 atTyped typedResult typedResult C C C notHaltTyped typedPost.2.1 rfl
  have run17 := runC_join P.F run16 runTyped
  have stateTyped := typedPost.2.2.1
  have retainedTyped := typedPost.2.2.2.1
  have instTyped := typedPost.2.2.2.2
  host_normalize_retained stateTyped, retainedTyped
  have updatedPolicy := allocated.2.2.2.2.2.1
  have reached := by
    host_retained_chain_after P.F, [After.Block2354.retained_transport,
      After.Block2355.retained_transport, After.Block2356.retained_transport,
      After.Block2357.retained_transport, After.Block2358.retained_transport,
      After.Block2359.retained_transport, After.Block2360.retained_transport,
      After.Block2361.retained_transport, After.Block2362.retained_transport,
      After.Block2363.retained_transport, After.Block2364.retained_transport,
      After.Block2365.retained_transport, After.Block2366.retained_transport,
      After.Block2367.retained_transport, After.Block2368.retained_transport,
      After.Block2369.retained_transport, After.Block2370.retained_transport,
      After.Block2371.retained_transport, After.Block2372.retained_transport,
      After.Block2373.retained_transport, After.Block2374.retained_transport,
      After.Block2375.retained_transport, After.Block2376.retained_transport,
      After.Block2377.retained_transport, After.Block2378.retained_transport,
      After.Block2379.retained_transport, After.Block2380.retained_transport,
      After.Block2381.retained_transport]
    using stateTyped, retainedTyped, instTyped
    continuing_run run17 initial_relation state
  -- The reached witness is Classical.choose, and this goal has no announced
  -- proposition, so the elaborator cannot bind that witness. Rebind it here.
  run_tac do
    let goal ← Lean.Elab.Tactic.getMainGoal
    goal.withContext do
      let reached ← Lean.mkFVar <$> Lean.Elab.Tactic.getFVarId (Lean.mkIdent `reached)
      let policy ← Lean.mkFVar <$> Lean.Elab.Tactic.getFVarId (Lean.mkIdent `updatedPolicy)
      let witness ← Lean.Meta.mkAppM ``Classical.choose #[reached]
      let spec ← Lean.instantiateMVars (← Lean.Meta.mkAppM ``Classical.choose_spec #[reached])
      let runProof ← Lean.Meta.mkAppM ``And.left #[spec]
      let rest ← Lean.Meta.mkAppM ``And.right #[spec]
      let relProof ← Lean.Meta.mkAppM ``And.left #[rest]
      let rest ← Lean.Meta.mkAppM ``And.right #[rest]
      let invProof ← Lean.Meta.mkAppM ``And.left #[rest]
      let instProof ← Lean.Meta.mkAppM ``And.right #[rest]
      let nativeProof ← Lean.Meta.mkAppM ``Host.Ts.Owned.Parametric.StateR.native #[relProof]
      let liveProof ← Lean.Meta.mkAppM ``And.right #[nativeProof]
      let sourceSupport ← Lean.Meta.mkAppM ``Host.Mlx.Ffi.Annotated.ProducerAnnotations.source #[policy, liveProof]
      let targetSupport ← Lean.Meta.mkAppM ``Host.Mlx.Ffi.Annotated.ProducerAnnotations.target #[policy, liveProof]
      let body ← Lean.instantiateMVars (← Lean.Meta.mkAppM ``And.intro #[runProof,
        ← Lean.Meta.mkAppM ``And.intro #[relProof,
        ← Lean.Meta.mkAppM ``And.intro #[invProof,
        ← Lean.Meta.mkAppM ``And.intro #[instProof,
        ← Lean.Meta.mkAppM ``And.intro #[policy,
        ← Lean.Meta.mkAppM ``And.intro #[sourceSupport, targetSupport]]]]]])
      let bodyType ← Lean.Meta.whnf (← Lean.instantiateMVars (← Lean.Meta.inferType body))
      let witness ← Lean.instantiateMVars witness
      let abstracted ← Lean.Meta.kabstract bodyType witness
      if !abstracted.hasLooseBVars then
        throwError "closure bridge could not bind the reached interpreter state"
      let domain ← Lean.Meta.inferType witness
      let predicate := Lean.mkLambda `result Lean.BinderInfo.default domain abstracted
      let term ← Lean.instantiateMVars (← Lean.Meta.mkAppOptM ``Exists.intro
        #[some domain, some predicate, some witness, some body])
      if term.hasMVar then throwError "closure bridge ownership package still has metavariables"
      let termType ← Lean.instantiateMVars (← Lean.Meta.inferType term)
      unless ← Lean.Meta.isDefEq termType (← goal.getType) do
        throwError "closure bridge ownership package does not match the theorem goal"
      goal.assign (← Lean.instantiateMVars term)
    Lean.Elab.Tactic.replaceMainGoal []

host_assert_retained_schema retained_to_call, 45

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_to_call, 44

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_to_call, 46

/-- error: host_retained_vectorNew: expected no arguments -/
#guard_msgs in
host_retained_vectorNew P.F, P.RestStream.micro0.micro23.s82
  using P.RestStream.micro0.micro23.S82
  to P.RestStream.micro0.micro23.s83
  using P.RestStream.micro0.micro23.S83 as RejectClosurePattern

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let count := saved.messages.toList.length
  let mut rejected := false
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_vectorNew P.F, P.RestStream.micro0.micro23.s50 using P.RestStream.micro0.micro23.S50 to P.RestStream.micro0.micro23.s50 using P.RestStream.micro0.micro23.S50 as RejectClosureEndpoint"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
  for message in (← get).messages.toList.drop count do
    if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
  set saved
  unless rejected do throwError "closure bridge negative did not reject the wrong vector-new endpoint in the kernel"

end Host.Load.Run.Full.Ordinary.ClosureApplyBridge
