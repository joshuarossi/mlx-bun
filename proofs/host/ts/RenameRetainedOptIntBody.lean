import host.ts.RenameRuntimeDispatch
import host.ts.RenameOptIntExecution
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameParametricNativeCall
import host.ts.RenameParametricGlobal

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric

theorem optInt_body_shape {S : Type} (s : St S) (env : Env) :
    enterBlock (s.push (.k (.fn .call))) optIntStatements env =
      {s with ctl := .ret .undef,stack := .s (.block optIntStatements env)::.s (.scope [])::.k (.fn .call)::s.stack} := rfl

theorem optInt_body_shape_of {S : Type} (s : St S) (env : Env) (caller : List Frame)
    (control : s.ctl = .ret .undef)
    (stack : s.stack = .s (.block optIntStatements env)::.s (.scope [])::.k (.fn .call)::caller) :
    s = enterBlock ({s with stack := caller}.push (.k (.fn .call))) optIntStatements env := by
  rw [optInt_body_shape]
  cases s with | mk heap next ctl frames aux =>
    dsimp only at control stack
    subst ctl
    subst frames
    rfl

/-- A complete numeric optInt body, with a fixed closed parameter occurrence.
The target literal, global constructor and call result are derived from the
current inventories and live source heap, never supplied as future operands. -/
theorem RetainedInventory.optInt_body
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (caller : List Frame) (parameter bigintFn : Nat) (global builtin : Obj) (data : List Val)
    (w e : Bool) (n : Nat) (bound : n < 2^32) (meaning : SymE)
    (closed : ∀ valuation, meaning.eval valuation = F64.ofNat n)
    (control : s₀.ctl = .ret .undef)
    (stack : s₀.stack = .s (.block optIntStatements env)::.s (.scope [])::.k (.fn .call)::caller)
    (parameterLookup : lookupEnv chars!"value" env = some parameter)
    (bigintLookup : lookupEnv chars!"BigInt" env = none)
    (parameterRead : s₀.heap.get parameter = some (.cell (some (.num (.lit (F64.ofNat n))))))
    (globalRead : s₀.heap.get aGlobal = some (.obj global)) (globalKind : global.kind = .ordinary)
    (globalProperty : findProp (.str chars!"BigInt") global.props = some (.data (.obj bigintFn) w e))
    (builtinRead : s₀.heap.get bigintFn = some (.obj builtin))
    (builtinKind : builtin.kind = .fn (.native (.num .bigint) data))
    (parameterNote : notes.runtime.cells.cells parameter = some (.literal meaning))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (blockNote scopeNote functionNote : Tree) (callerNotes : List Tree)
    (stackNotes : notes.runtime.stack = blockNote::scopeNote::functionNote::callerNotes) :
    ∃ result,
      runC F 36 s₀ C₀ = some ({s₀ with ctl := .ret (.big (Int.ofNat (packedOptInt n))),stack := caller},C₀) ∧
      runC F 36 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {s₀ with ctl := .ret (.big (Int.ofNat (packedOptInt n))),stack := caller} result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.ordinaryBig (Int.ofNat (packedOptInt n))),callerNotes,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live {s₀ with ctl := .ret (.big (Int.ofNat (packedOptInt n))),stack := caller} result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  obtain ⟨targetValue,targetControl,targetValueRole⟩ := (h.control_view control).ret_view
  cases targetValueRole
  obtain ⟨targetBlock,targetRest,targetStack,blockRole,restRoles⟩ := h.stack_view stack
  rw [blockRole.block_view] at targetStack
  cases restRoles with | cons scopeRole restRoles =>
    cases restRoles with | cons callRole callerRoles =>
      rw [scopeRole.emptyScope_view,callRole.call_view] at targetStack
      have sourceLive := h.stackLive
      rw [stack] at sourceLive
      have parameterLive := env_lookup_live chars!"value" env parameter sourceLive.1.1.2.1 parameterLookup
      obtain ⟨targetValue,targetParameterRead,_,_⟩ := h.heap.readCell parameter _ parameterLive parameterRead
      have targetHeld := inventory.runtime.target.cells parameter (.literal meaning) parameterNote
      simp only [cellValueAt,targetParameterRead] at targetHeld
      cases targetHeld with | literal _ x denotation =>
        have same : x = F64.ofNat n := (Option.some.inj denotation).trans (closed ν)
        subst x
        obtain ⟨targetGlobal,targetGlobalRead,globalRole,globalSupport⟩ := h.heap.readOrdinary aGlobal global globalLive globalRead globalKind
        rw [globalFixed] at targetGlobalRead
        obtain ⟨targetFn,property,fnRole⟩ := globalRole.properties.find_data chars!"BigInt" (.obj bigintFn) w e globalProperty
        cases fnRole
        have fnLive : live bigintFn := (PropsR.support_find globalSupport.2.2.1 chars!"BigInt" globalProperty).1
        have notFramed := h.heap.function_notFramed bigintFn builtin _ fnLive builtinRead builtinKind
        obtain ⟨targetBuiltin,targetBuiltinRead,builtinRole,_⟩ := h.heap.readObject bigintFn builtin fnLive notFramed builtinRead
        have nativeRole := builtinRole.kind
        rw [builtinKind] at nativeRole
        obtain ⟨targetData,targetKind,_⟩ := kind_native nativeRole
        have left := run_optInt_body F {s₀ with stack := caller} C₀ env parameter bigintFn global builtin data w e n bound
          parameterLookup bigintLookup parameterRead globalRead globalKind globalProperty builtinRead builtinKind
        rw [←optInt_body_shape_of s₀ env caller control stack] at left
        have targetCanonical : s.stack = .s (.block optIntStatements (R.env env))::.s (.scope [])::.k (.fn .call)::s.stack.drop 3 := by
          rw [targetStack]
          rfl
        have targetCallerRoles : ListR (Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R) caller (s.stack.drop 3) := by
          simpa only [targetStack,List.drop_succ_cons,List.drop_zero] using callerRoles
        have right := run_optInt_body F {s with stack := s.stack.drop 3} C (R.env env) (R.a parameter) (R.a bigintFn)
          targetGlobal targetBuiltin targetData w e n bound
          (by rw [lookupEnv_map,parameterLookup]; rfl) (by rw [lookupEnv_map,bigintLookup]; rfl)
          targetParameterRead targetGlobalRead (globalRole.ordinary globalKind) property targetBuiltinRead targetKind
        rw [←optInt_body_shape_of s (R.env env) (s.stack.drop 3) targetControl targetCanonical] at right
        have savedLive := h.stackLive
        rw [stack] at savedLive
        have related := (h.restack targetCallerRoles savedLive.2.2.2).go
          (c:=.ret (.big (Int.ofNat (packedOptInt n)))) (c':=.ret (.big (Int.ofNat (packedOptInt n))))
          (.node _ (.cons (.value (.ordinaryBig _)) .nil)) ⟨True.intro,True.intro⟩
        have sourceNotes := inventory.runtime.source.stack
        have targetNotes := inventory.runtime.target.stack
        rw [stackNotes,stack,List.map_cons] at sourceNotes
        rw [stackNotes,targetStack,List.map_cons] at targetNotes
        have runtime : RuntimeInventory ⟨returnNote (.ordinaryBig (Int.ofNat (packedOptInt n))),callerNotes,notes.runtime.cells⟩
            ν₀ ν C₀ C R live {s₀ with ctl := .ret (.big (Int.ofNat (packedOptInt n))),stack := caller}
            {s with ctl := .ret (.big (Int.ofNat (packedOptInt n))),stack := s.stack.drop 3} :=
          ⟨inventory.runtime.keyLive,⟨returnNote_holds (.ordinaryBig _),sourceNotes.tail.tail.tail,inventory.runtime.source.cells⟩,
            ⟨returnNote_holds (.ordinaryBig _),by simpa only [targetStack,List.drop_succ_cons,List.drop_zero] using targetNotes.tail.tail.tail,inventory.runtime.target.cells⟩⟩
        exact ⟨_,left,right,related,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C),rfl,rfl,rfl⟩

/-- Null follows the actual short branch without a BigInt lookup. -/
theorem RetainedInventory.optInt_null_body
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (caller : List Frame) (parameter : Nat)
    (control : s₀.ctl = .ret .undef)
    (stack : s₀.stack = .s (.block optIntStatements env)::.s (.scope [])::.k (.fn .call)::caller)
    (parameterLookup : lookupEnv chars!"value" env = some parameter)
    (parameterRead : s₀.heap.get parameter = some (.cell (some .null)))
    (blockNote scopeNote functionNote : Tree) (callerNotes : List Tree)
    (stackNotes : notes.runtime.stack = blockNote::scopeNote::functionNote::callerNotes) :
    ∃ result, runC F 14 s₀ C₀ = some ({s₀ with ctl := .ret (.big 0),stack := caller},C₀) ∧
      runC F 14 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {s₀ with ctl := .ret (.big 0),stack := caller} result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.ordinaryBig 0),callerNotes,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live {s₀ with ctl := .ret (.big 0),stack := caller} result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  obtain ⟨_,targetControl,targetValue⟩ := (h.control_view control).ret_view
  cases targetValue
  obtain ⟨_,_,targetStack,blockRole,restRoles⟩ := h.stack_view stack
  rw [blockRole.block_view] at targetStack
  cases restRoles with | cons scopeRole restRoles =>
    cases restRoles with | cons callRole callerRoles =>
      rw [scopeRole.emptyScope_view,callRole.call_view] at targetStack
      have sourceLive := h.stackLive
      rw [stack] at sourceLive
      obtain ⟨_,targetRead,targetRole,_⟩ := h.heap.readCell parameter .null
        (env_lookup_live chars!"value" env parameter sourceLive.1.1.2.1 parameterLookup) parameterRead
      cases targetRole
      have targetCanonical : s.stack = .s (.block optIntStatements (R.env env))::.s (.scope [])::.k (.fn .call)::s.stack.drop 3 := by
        rw [targetStack]
        rfl
      have targetCallerRoles : ListR (Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R) caller (s.stack.drop 3) := by
        simpa only [targetStack,List.drop_succ_cons,List.drop_zero] using callerRoles
      have left := run_optInt_null_body F {s₀ with stack := caller} C₀ env parameter parameterLookup parameterRead
      rw [←optInt_body_shape_of s₀ env caller control stack] at left
      have right := run_optInt_null_body F {s with stack := s.stack.drop 3} C (R.env env) (R.a parameter)
        (by rw [lookupEnv_map,parameterLookup]; rfl) targetRead
      rw [←optInt_body_shape_of s (R.env env) (s.stack.drop 3) targetControl targetCanonical] at right
      have related := (h.restack targetCallerRoles sourceLive.2.2.2).go
        (c:=.ret (.big 0)) (c':=.ret (.big 0)) (.node _ (.cons (.value (.ordinaryBig 0)) .nil)) ⟨True.intro,True.intro⟩
      have sourceNotes := inventory.runtime.source.stack
      have targetNotes := inventory.runtime.target.stack
      rw [stackNotes,stack,List.map_cons] at sourceNotes
      rw [stackNotes,targetStack,List.map_cons] at targetNotes
      have runtime : RuntimeInventory ⟨returnNote (.ordinaryBig 0),callerNotes,notes.runtime.cells⟩
          ν₀ ν C₀ C R live {s₀ with ctl := .ret (.big 0),stack := caller} {s with ctl := .ret (.big 0),stack := s.stack.drop 3} :=
        ⟨inventory.runtime.keyLive,⟨returnNote_holds (.ordinaryBig 0),sourceNotes.tail.tail.tail,inventory.runtime.source.cells⟩,
          ⟨returnNote_holds (.ordinaryBig 0),by simpa only [targetStack,List.drop_succ_cons,List.drop_zero] using targetNotes.tail.tail.tail,inventory.runtime.target.cells⟩⟩
      exact ⟨_,left,right,related,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C),rfl,rfl,rfl⟩

end Host.Ts.Owned.Annotated
