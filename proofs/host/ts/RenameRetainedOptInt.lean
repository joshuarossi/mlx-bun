import host.ts.RenameSingleParameterEntryFields
import host.ts.RenameRetainedOptIntBody
import host.ts.RenameRetainedSingleParameterBody
import host.ts.RenameRetainedClosure

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric

def optIntParameterNotes (notes : RetainedNotes) (parameter : Nat) (meaning : SymE) (n : Nat)
    (callerNotes : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote (.ordinaryBig (Int.ofNat (packedOptInt n))),callerNotes,
    notes.runtime.cells.write parameter (.literal meaning)⟩

/-- Bind the current closed numeric argument, run both pinned statements and
return the exact packed ordinary bigint to an arbitrary caller. All addresses,
heaps, servers and resource maps remain parameters of the theorem. -/
theorem RetainedInventory.optInt_parameter
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (caller : List Frame) (parameter bigintFn : Nat) (global builtin : Obj) (data : List Val)
    (w e : Bool) (n : Nat) (bound : n < 2^32) (meaning : SymE)
    (closed : ∀ valuation, meaning.eval valuation = F64.ofNat n)
    (control : source.ctl = .ret .undef)
    (stack : source.stack = .k (.params optIntFunction [.id chars!"value"] [.num (.lit (F64.ofNat n))] env)::.k (.fn .call)::caller)
    (parameterLookup : lookupEnv chars!"value" env = some parameter)
    (bigintLookup : lookupEnv chars!"BigInt" env = none)
    (parameterRead : source.heap.get parameter = some (.cell none))
    (globalRead : source.heap.get aGlobal = some (.obj global)) (globalKind : global.kind = .ordinary)
    (globalProperty : findProp (.str chars!"BigInt") global.props = some (.data (.obj bigintFn) w e))
    (builtinRead : source.heap.get bigintFn = some (.obj builtin))
    (builtinKind : builtin.kind = .fn (.native (.num .bigint) data))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (functionNote : Tree) (callerNotes : List Tree)
    (stackNotes : notes.runtime.stack = parameterFrameNote optIntFunction [.id chars!"value"] [.literal meaning] env::functionNote::callerNotes)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64) :
    ∃ result,
      runC F 39 source C₀ = some ({source.setCell parameter (.num (.lit (F64.ofNat n))) with ctl := .ret (.big (Int.ofNat (packedOptInt n))),stack := caller},C₀) ∧
      runC F 39 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {source.setCell parameter (.num (.lit (F64.ofNat n))) with ctl := .ret (.big (Int.ofNat (packedOptInt n))),stack := caller} result ∧
      RetainedInventory (optIntParameterNotes notes parameter meaning n callerNotes) ν₀ ν C₀ C R live
        {source.setCell parameter (.num (.lit (F64.ofNat n))) with ctl := .ret (.big (Int.ofNat (packedOptInt n))),stack := caller} result := by
  let value := Val.num (.lit (F64.ofNat n))
  let base := {(source.setCell parameter value).ret .undef with stack := .k (.fn .call)::caller}
  let entered := enterBlock base optIntStatements env
  have parameterLive : live parameter := by
    have supported := h.stackLive
    rw [stack] at supported
    exact env_lookup_live chars!"value" env parameter supported.1.1.2.2.2.1 parameterLookup
  have parameterBound : parameter < 2^64 := Nat.lt_of_lt_of_le (h.heap.sourceBound parameter parameterLive) sourceBound
  have globalNe : aGlobal ≠ parameter := by
    intro equal
    rw [equal,parameterRead] at globalRead
    cases globalRead
  have builtinNe : bigintFn ≠ parameter := by
    intro equal
    rw [equal,parameterRead] at builtinRead
    cases builtinRead
  obtain ⟨targetBody,left3,right3,hBody,invBody⟩ := inventory.single_parameter_body h (some chars!"optInt") chars!"value"
    optIntStatements env (.k (.fn .call)::caller) parameter value (.literal meaning) (functionNote::callerNotes)
    control stack parameterLookup parameterRead stackNotes rfl sourceBound targetBound
  change Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' entered targetBody at hBody
  change RetainedInventory (singleParameterBodyNotes notes (some chars!"optInt") chars!"value" optIntStatements env env parameter
    (.literal meaning) (functionNote::callerNotes)) ν₀ ν C₀ C R live entered targetBody at invBody
  obtain ⟨result,left36,right36,post,retained,_,_,_⟩ := invBody.optInt_body hBody env caller parameter bigintFn global builtin data
    w e n bound meaning closed rfl rfl parameterLookup bigintLookup
    (by change (source.setCell parameter value).heap.get parameter = _; simp only [St.setCell,PTrie.get_set_u64 _ _ _ parameterBound,ite_true]; rfl)
    (by change (source.setCell parameter value).heap.get aGlobal = _; simp only [St.setCell,PTrie.get_set_u64 _ _ _ parameterBound,ite_eq_right globalNe]; exact globalRead)
    globalKind globalProperty
    (by change (source.setCell parameter value).heap.get bigintFn = _; simp only [St.setCell,PTrie.get_set_u64 _ _ _ parameterBound,ite_eq_right builtinNe]; exact builtinRead)
    builtinKind (by simp only [singleParameterBodyNotes,RetainedNotes.withRuntime,RuntimeNotes.bodyEntered,RuntimeNotes.initialized,RuntimeNotes.parameterArgument,Notes.write,ite_true]) globalLive globalFixed (blockFrameNote optIntStatements env) emptyScopeNote functionNote callerNotes rfl
  exact ⟨result,runC_join F left3 left36,runC_join F right3 right36,post,retained⟩

def optIntCallNotes (notes : RetainedNotes) (start : Nat) (meaning : SymE) (n : Nat) (thisRole : Value) : RetainedNotes :=
  notes.withRuntime ⟨returnNote (.ordinaryBig (Int.ofNat (packedOptInt n))),notes.runtime.stack,
    (notes.runtime.cells.write start thisRole).write (start+1) (.literal meaning)⟩

noncomputable def optIntCallResult {S : Type} (source : St S) (env : Env) (receiver : Val) (n : Nat) : St S :=
  let entered := closureState source optIntFunction env false .undef receiver [.num (.lit (F64.ofNat n))] .call
  {entered.setCell (source.next+1) (.num (.lit (F64.ofNat n))) with ctl := .ret (.big (Int.ofNat (packedOptInt n))),stack := source.stack}

/-- Whole pinned optInt invocation for closed bounded numeric arguments. Fresh
receiver/parameter cells are allocated and initialized by the real closure and
scheduler. The current caller is resumed with the proved ordinary bigint. -/
theorem RetainedInventory.optInt_call
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (address : Nat) (function : Obj) (env : Env) (receiver : Val)
    (bigintFn : Nat) (global builtin : Obj) (data : List Val) (w e : Bool)
    (n : Nat) (bound : n < 2^32) (meaning : SymE) (closed : ∀ valuation, meaning.eval valuation = F64.ofNat n)
    (control : source.ctl = .call (.obj address) receiver [.num (.lit (F64.ofNat n))])
    (functionRead : source.heap.get address = some (.obj function))
    (functionKind : function.kind = .fn (.closure optIntFunction env false .undef))
    (bigintLookup : lookupEnv chars!"BigInt" env = none)
    (globalRead : source.heap.get aGlobal = some (.obj global)) (globalKind : global.kind = .ordinary)
    (globalProperty : findProp (.str chars!"BigInt") global.props = some (.data (.obj bigintFn) w e))
    (builtinRead : source.heap.get bigintFn = some (.obj builtin))
    (builtinKind : builtin.kind = .fn (.native (.num .bigint) data))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (fnRole thisRole : Value) (controlNote : notes.runtime.control = callNote fnRole thisRole [.literal meaning])
    (sourceBound : source.next+3 ≤ 2^64) (targetBound : target.next+3 ≤ 2^64) :
    ∃ result, runC F 40 source C₀ = some (optIntCallResult source env receiver n,C₀) ∧
      runC F 40 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ClosureLive live source.next false .undef optIntFunction)
        framed before after old old' (optIntCallResult source env receiver n) result ∧
      RetainedInventory (optIntCallNotes notes source.next meaning n thisRole) ν₀ ν C₀ C R
        (ClosureLive live source.next false .undef optIntFunction) (optIntCallResult source env receiver n) result := by
  let value := Val.num (.lit (F64.ofNat n))
  let entered := closureState source optIntFunction env false .undef receiver [value] .call
  let bodyEnv := closureEnvironment source optIntFunction env false .undef receiver
  obtain ⟨targetHome,targetThis,targetArgs,left1,right1,h1,inv1⟩ := inventory.closure_step F FR notes ν₀ ν C₀ C R live framed
    before after old old' source target h address function optIntFunction env false .undef receiver [value] fnRole thisRole
    [.literal meaning] control functionRead functionKind controlNote sourceBound targetBound
  have sourceNext : entered.next = source.next+2 := by change source.next+1+1 = source.next+2; omega
  have targetNext : (closureState target optIntFunction (R.env env) false targetHome targetThis targetArgs .call).next = target.next+2 := by
    have a := h1.heap.fresh 0
    have b := h.heap.fresh 2
    simp only [Nat.add_zero] at a
    exact a.symm.trans b
  obtain ⟨_,_,_,globalSupport⟩ := h.heap.readOrdinary aGlobal global globalLive globalRead globalKind
  have fnLive : live bigintFn := (PropsR.support_find globalSupport.2.2.1 chars!"BigInt" globalProperty).1
  have frame := closureState_heap_below F source optIntFunction env false .undef receiver [value] .call sourceBound
  have enteredGlobal : entered.heap.get aGlobal = some (.obj global) := (frame aGlobal (h.heap.sourceBound aGlobal globalLive)).trans globalRead
  have enteredBuiltin : entered.heap.get bigintFn = some (.obj builtin) := (frame bigintFn (h.heap.sourceBound bigintFn fnLive)).trans builtinRead
  have parameterRead : entered.heap.get (source.next+1) = some (.cell none) := by
    change ((source.heap.set source.next (.cell (some receiver))).set (source.next+1) (.cell none)).get (source.next+1) = _
    rw [PTrie.get_set_u64 _ _ _ (by omega)]
    simp only [ite_true]
  obtain ⟨result,left39,right39,post,retained⟩ := inv1.optInt_parameter h1 bodyEnv source.stack (source.next+1) bigintFn global builtin data
    w e n bound meaning closed rfl (closureState_stack source optIntFunction env false .undef receiver [value] .call)
    (singleParameter_lookup source (some chars!"optInt") chars!"value" optIntStatements env receiver)
    ((singleParameter_lookup_other source (some chars!"optInt") chars!"value" chars!"BigInt" optIntStatements env receiver
      (by decide +kernel) (by decide +kernel)).trans bigintLookup) parameterRead enteredGlobal globalKind globalProperty enteredBuiltin builtinKind
    (ClosureLive.grow live source.next false .undef optIntFunction aGlobal globalLive) globalFixed callBoundaryNote notes.runtime.stack rfl
    (by rw [sourceNext]; omega) (by rw [targetNext]; omega)
  refine ⟨result,?_,?_,post,retained⟩
  · exact runC_cons F 39 source entered _ C₀ C₀ C₀ (by rw [control]; rfl) left1 left39
  · exact runC_cons F 39 target _ _ C C C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1 right39

def optIntNullParameterNotes (notes : RetainedNotes) (parameter : Nat) (callerNotes : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote (.ordinaryBig 0),callerNotes,notes.runtime.cells.write parameter .null⟩

theorem RetainedInventory.optInt_null_parameter
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (caller : List Frame) (parameter : Nat)
    (control : source.ctl = .ret .undef)
    (stack : source.stack = .k (.params optIntFunction [.id chars!"value"] [.null] env)::.k (.fn .call)::caller)
    (parameterLookup : lookupEnv chars!"value" env = some parameter)
    (parameterRead : source.heap.get parameter = some (.cell none))
    (functionNote : Tree) (callerNotes : List Tree)
    (stackNotes : notes.runtime.stack = parameterFrameNote optIntFunction [.id chars!"value"] [.null] env::functionNote::callerNotes)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64) :
    ∃ result, runC F 17 source C₀ = some ({source.setCell parameter .null with ctl := .ret (.big 0),stack := caller},C₀) ∧
      runC F 17 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {source.setCell parameter .null with ctl := .ret (.big 0),stack := caller} result ∧
      RetainedInventory (optIntNullParameterNotes notes parameter callerNotes) ν₀ ν C₀ C R live
        {source.setCell parameter .null with ctl := .ret (.big 0),stack := caller} result := by
  have parameterLive : live parameter := by
    have supported := h.stackLive
    rw [stack] at supported
    exact env_lookup_live chars!"value" env parameter supported.1.1.2.2.2.1 parameterLookup
  have parameterBound : parameter < 2^64 := Nat.lt_of_lt_of_le (h.heap.sourceBound parameter parameterLive) sourceBound
  obtain ⟨targetBody,left3,right3,hBody,invBody⟩ := inventory.single_parameter_body h (some chars!"optInt") chars!"value"
    optIntStatements env (.k (.fn .call)::caller) parameter .null .null (functionNote::callerNotes)
    control stack parameterLookup parameterRead stackNotes rfl sourceBound targetBound
  obtain ⟨result,left14,right14,post,retained,_,_,_⟩ := invBody.optInt_null_body hBody env caller parameter rfl rfl parameterLookup
    (by change (source.setCell parameter .null).heap.get parameter = _; simp only [St.setCell,PTrie.get_set_u64 _ _ _ parameterBound,ite_true])
    (blockFrameNote optIntStatements env) emptyScopeNote functionNote callerNotes rfl
  exact ⟨result,runC_join F left3 left14,runC_join F right3 right14,post,retained⟩

def optIntNullCallNotes (notes : RetainedNotes) (start : Nat) (thisRole : Value) : RetainedNotes :=
  notes.withRuntime ⟨returnNote (.ordinaryBig 0),notes.runtime.stack,(notes.runtime.cells.write start thisRole).write (start+1) .null⟩
noncomputable def optIntNullCallResult {S : Type} (source : St S) (env : Env) (receiver : Val) : St S :=
  let entered := closureState source optIntFunction env false .undef receiver [.null] .call
  {entered.setCell (source.next+1) .null with ctl := .ret (.big 0),stack := source.stack}

/-- The complete null invocation performs no BigInt/global lookup. -/
theorem RetainedInventory.optInt_null_call
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (address : Nat) (function : Obj) (env : Env) (receiver : Val)
    (control : source.ctl = .call (.obj address) receiver [.null])
    (functionRead : source.heap.get address = some (.obj function))
    (functionKind : function.kind = .fn (.closure optIntFunction env false .undef))
    (fnRole thisRole : Value) (controlNote : notes.runtime.control = callNote fnRole thisRole [.null])
    (sourceBound : source.next+3 ≤ 2^64) (targetBound : target.next+3 ≤ 2^64) :
    ∃ result, runC F 18 source C₀ = some (optIntNullCallResult source env receiver,C₀) ∧
      runC F 18 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ClosureLive live source.next false .undef optIntFunction)
        framed before after old old' (optIntNullCallResult source env receiver) result ∧
      RetainedInventory (optIntNullCallNotes notes source.next thisRole) ν₀ ν C₀ C R
        (ClosureLive live source.next false .undef optIntFunction) (optIntNullCallResult source env receiver) result := by
  let entered := closureState source optIntFunction env false .undef receiver [.null] .call
  let bodyEnv := closureEnvironment source optIntFunction env false .undef receiver
  obtain ⟨targetHome,targetThis,targetArgs,left1,right1,h1,inv1⟩ := inventory.closure_step F FR notes ν₀ ν C₀ C R live framed
    before after old old' source target h address function optIntFunction env false .undef receiver [.null] fnRole thisRole
    [.null] control functionRead functionKind controlNote sourceBound targetBound
  have sourceNext : entered.next = source.next+2 := singleParameter_next source (some chars!"optInt") chars!"value" optIntStatements env receiver .null
  have targetNext : (closureState target optIntFunction (R.env env) false targetHome targetThis targetArgs .call).next = target.next+2 := by
    have a := h1.heap.fresh 0
    have b := h.heap.fresh 2
    simp only [Nat.add_zero] at a
    exact a.symm.trans b
  obtain ⟨result,left17,right17,post,retained⟩ := inv1.optInt_null_parameter h1 bodyEnv source.stack (source.next+1) rfl
    (closureState_stack source optIntFunction env false .undef receiver [.null] .call)
    (singleParameter_lookup source (some chars!"optInt") chars!"value" optIntStatements env receiver)
    (singleParameter_uninitialized source (some chars!"optInt") chars!"value" optIntStatements env receiver .null (by omega))
    callBoundaryNote notes.runtime.stack rfl (by rw [sourceNext]; omega) (by rw [targetNext]; omega)
  refine ⟨result,?_,?_,post,retained⟩
  · exact runC_cons F 17 source entered _ C₀ C₀ C₀ (by rw [control]; rfl) left1 left17
  · exact runC_cons F 17 target _ _ C C C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1 right17

end Host.Ts.Owned.Annotated
