import host.ts.RenameRetainedAllocation
import host.ts.RenameRuntimeArraySchedule
import host.ts.RenameRuntimeArrayEmpty
import host.ts.RenameRuntimeArraySpread

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RetainedNotes.arrayCreated (notes : RetainedNotes) (runtime : RuntimeNotes) (owner : Nat) (roles : List Value) : RetainedNotes :=
  {notes with runtime := runtime,arrays := notes.arrays.write owner roles}

private theorem retain_array_pure {S : Type} {notes : RetainedNotes} {runtime : RuntimeNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (newRuntime : RuntimeInventory runtime ν₀ ν C₀ C R live t₀ t)
    (source : RuntimePureEffects s₀ t₀) (target : RuntimePureEffects s t) :
    RetainedInventory (notes.withRuntime runtime) ν₀ ν C₀ C R live t₀ t := by
  have heap := inventory.heapInventory.pure_effects source target (.refl C₀) (.refl C)
  exact ⟨newRuntime,heap.privates,heap.captures,
    inventory.arrays.pure_effects source target (.refl C₀) (.refl C),
    inventory.publicFields.pure_effects source target (.refl C₀) (.refl C),
    inventory.buffers.pure_effects source target (.refl C₀) (.refl C)⟩

private theorem retain_array_allocation {S : Type} {notes : RetainedNotes} {runtime : RuntimeNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val}
    {s₀ s t₀ t : St S} {NR : NumV → NumV → Prop}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s) (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (object₀ object : HObj) (roles : List Value) (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64)
    (newRuntime : RuntimeInventory runtime ν₀ ν C₀ C R (LiveAfter live s₀.next) t₀ t)
    (arrays : ArrayInventory (notes.arrays.write s₀.next roles) ν₀ ν C₀ C R (LiveAfter live s₀.next) t₀ t)
    (sourceHeap : t₀.heap = (s₀.alloc object₀).2.heap) (targetHeap : t.heap = (s.alloc object).2.heap) :
    RetainedInventory (notes.arrayCreated runtime s₀.next roles) ν₀ ν C₀ C R (LiveAfter live s₀.next) t₀ t := by
  have prior := inventory.allocate_return heap object₀ object sourceBound targetBound
  refine ⟨newRuntime,?_,?_,arrays,?_,?_⟩
  · exact prior.privates.frame (fun _ h => h)
      (fun a _ _ => congrArg (fun heap : PTrie HObj => heap.get a) sourceHeap)
      (fun a _ _ => congrArg (fun heap : PTrie HObj => heap.get (R.a a)) targetHeap)
  · exact prior.captures.frame (fun _ h => h)
      (fun a _ _ => congrArg (fun heap : PTrie HObj => heap.get a) sourceHeap)
      (fun a _ _ => congrArg (fun heap : PTrie HObj => heap.get (R.a a)) targetHeap)
  · exact prior.publicFields.frame (fun _ h => h)
      (fun a _ _ _ => congrArg (fun heap : PTrie HObj => heap.get a) sourceHeap)
      (fun a _ _ _ => congrArg (fun heap : PTrie HObj => heap.get (R.a a)) targetHeap)
  · exact prior.buffers.frame (fun _ h => h)
      (fun a _ _ => congrArg (fun heap : PTrie HObj => heap.get a) sourceHeap)
      (fun a _ _ => congrArg (fun heap : PTrie HObj => heap.get (R.a a)) targetHeap)

private theorem argument_effects {S : Type} (s : St S) (kind : Nat) (fn this : Val) (acc : List Val) (rest : List Elem) (env : Env) :
    RuntimePureEffects s (argumentState s kind fn this acc rest env) := by
  induction rest generalizing acc with
  | nil => unfold argumentState; split <;> exact ⟨rfl,rfl,rfl⟩
  | cons e rest ih => cases e with
    | expr _ => exact ⟨rfl,rfl,rfl⟩
    | spread _ => exact ⟨rfl,rfl,rfl⟩
    | hole => exact ih (.undef::acc)

section
variable {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
  {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
  {s₀ s : St F.S}

theorem RetainedInventory.array_entry_step (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (e : Expr) (rest : List Elem) (env : Env) (control : s₀.ctl = .ev (.array (.expr e::rest)) env) :
    interpC (step F s₀).run C₀ = some (arrayElement s₀ [] e rest env,C₀) ∧
    interpC (step F s).run C = some (arrayElement s [] e rest (R.env env),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (arrayElement s₀ [] e rest env) (arrayElement s [] e rest (R.env env)) ∧
    RetainedInventory (notes.withRuntime (notes.runtime.arrayElement [] e rest env)) ν₀ ν C₀ C R live
      (arrayElement s₀ [] e rest env) (arrayElement s [] e rest (R.env env)) := by
  obtain ⟨left,right,post,runtime⟩ := inventory.runtime.array_entry_step F FR notes.runtime ν₀ ν C₀ C R live framed before after old old' s₀ s h e rest env control
  exact ⟨left,right,post,retain_array_pure inventory runtime ⟨rfl,rfl,rfl⟩ ⟨rfl,rfl,rfl⟩⟩

theorem RetainedInventory.array_next_step (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value : Val) (role : Value) (acc : List Val) (roles : List Value) (e : Expr) (rest : List Elem)
    (env : Env) (frames : List Frame) (tail : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .l (.array acc (.expr e::rest) env)::frames)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = arrayLiteralFrameNote roles (.expr e::rest) env::tail) :
    ∃ (targetValue : Val) (targetAcc : List Val) (targetFrames : List Frame),
      interpC (step F s₀).run C₀ = some (arrayElement {s₀ with stack := frames} (value::acc) e rest env,C₀) ∧
      interpC (step F s).run C = some (arrayElement {s with stack := targetFrames} (targetValue::targetAcc) e rest (R.env env),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (arrayElement {s₀ with stack := frames} (value::acc) e rest env)
        (arrayElement {s with stack := targetFrames} (targetValue::targetAcc) e rest (R.env env)) ∧
      RetainedInventory (notes.withRuntime ({notes.runtime with stack := tail}.arrayElement (role::roles) e rest env)) ν₀ ν C₀ C R live
        (arrayElement {s₀ with stack := frames} (value::acc) e rest env)
        (arrayElement {s with stack := targetFrames} (targetValue::targetAcc) e rest (R.env env)) := by
  obtain ⟨v,vs,fs,left,right,post,runtime⟩ := inventory.runtime.array_next_step F FR notes.runtime ν₀ ν C₀ C R live framed before after old old'
    s₀ s h value role acc roles e rest env frames tail control stack controlNote stackNotes
  exact ⟨v,vs,fs,left,right,post,retain_array_pure inventory runtime ⟨rfl,rfl,rfl⟩ ⟨rfl,rfl,rfl⟩⟩

theorem RetainedInventory.array_empty_step (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (control : s₀.ctl = .ev (.array []) env)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    interpC (step F s₀).run C₀ = some ((s₀.alloc (valueArray [])).2.ret (.obj s₀.next),C₀) ∧
    interpC (step F s).run C = some ((s.alloc (valueArray [])).2.ret (.obj s.next),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old'
      ((s₀.alloc (valueArray [])).2.ret (.obj s₀.next)) ((s.alloc (valueArray [])).2.ret (.obj s.next)) ∧
    RetainedInventory (notes.arrayCreated {notes.runtime with control := returnNote (.obj s₀.next)} s₀.next []) ν₀ ν C₀ C R (LiveAfter live s₀.next)
      ((s₀.alloc (valueArray [])).2.ret (.obj s₀.next)) ((s.alloc (valueArray [])).2.ret (.obj s.next)) := by
  obtain ⟨left,right,post,runtime,arrays⟩ := inventory.runtime.array_empty_step F FR notes.runtime notes.arrays ν₀ ν C₀ C R live framed before after old old'
    s₀ s h inventory.arrays env control prototypeLive prototypeFixed sourceBound targetBound
  exact ⟨left,right,post,retain_array_allocation inventory h.heap _ _ [] sourceBound targetBound runtime arrays rfl rfl⟩

theorem RetainedInventory.array_final_step (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value : Val) (role : Value) (acc : List Val) (roles : List Value) (env : Env) (frames : List Frame) (tail : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .l (.array acc [] env)::frames)
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = arrayLiteralFrameNote roles [] env::tail)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    ∃ (targetValue : Val) (targetAcc : List Val) (targetFrames : List Frame),
      let t₀ := ({s₀ with stack := frames}.alloc (valueArray (value::acc).reverse)).2.ret (.obj s₀.next)
      let t := ({s with stack := targetFrames}.alloc (valueArray (targetValue::targetAcc).reverse)).2.ret (.obj s.next)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old' t₀ t ∧
      RetainedInventory (notes.arrayCreated {notes.runtime with control := returnNote (.obj s₀.next),stack := tail} s₀.next (role::roles).reverse)
        ν₀ ν C₀ C R (LiveAfter live s₀.next) t₀ t := by
  obtain ⟨v,vs,fs,left,right,post,runtime,arrays⟩ := inventory.runtime.array_final_step F FR notes.runtime notes.arrays ν₀ ν C₀ C R live framed before after old old'
    s₀ s h inventory.arrays value role acc roles env frames tail control stack controlNote stackNotes prototypeLive prototypeFixed sourceBound targetBound
  exact ⟨v,vs,fs,left,right,post,retain_array_allocation inventory h.heap _ _ (role::roles).reverse sourceBound targetBound runtime arrays rfl rfl⟩

theorem RetainedInventory.array_argument_spread_step (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a : Nat) (elements : List Value) (entry : notes.arrays.owners a = some elements)
    (fnRole thisRole : Value) (roles : List Value) (kind : Nat) (fn this : Val) (acc : List Val)
    (rest : List Elem) (env : Env) (frames : List Frame) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj a)) (stack : s₀.stack = .c (.spread kind fn this acc rest env)::frames) (ordinary : kind ≤ 1)
    (stackNotes : notes.runtime.stack = argumentFrameNote true kind fnRole thisRole roles rest env::tail) :
    ∃ (values targetValues : List Val) (targetFn targetThis : Val) (targetAcc : List Val) (targetFrames : List Frame),
      let t₀ := argumentState {s₀ with stack := frames} kind fn this (values.reverse ++ acc) rest env
      let t := argumentState {s with stack := targetFrames} kind targetFn targetThis (targetValues.reverse ++ targetAcc) rest (R.env env)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ({notes.runtime with stack := tail}.arguments kind fnRole thisRole (elements.reverse ++ roles) rest env))
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨values,vs,fn',this',acc',fs,left,right,post,runtime,_⟩ := inventory.runtime.array_argument_spread_step F FR notes.runtime notes.arrays ν₀ ν C₀ C R live framed before after old old'
    s₀ s h inventory.arrays a elements entry fnRole thisRole roles kind fn this acc rest env frames tail control stack ordinary stackNotes
  exact ⟨values,vs,fn',this',acc',fs,left,right,post,retain_array_pure inventory runtime
    ((show RuntimePureEffects s₀ {s₀ with stack := frames} from ⟨rfl,rfl,rfl⟩).trans (argument_effects _ kind fn this _ rest env))
    ((show RuntimePureEffects s {s with stack := fs} from ⟨rfl,rfl,rfl⟩).trans (argument_effects _ kind fn' this' _ rest (R.env env)))⟩
end
end Host.Ts.Owned.Annotated
