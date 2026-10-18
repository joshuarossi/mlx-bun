import host.ts.RenameRouteReadFields
import host.ts.RenameParametricDeclarations
import host.ts.RenameParametricLiteral
import host.ts.RenameParametricReturnStep
import host.ts.RenameArrayInventory
import host.ts.RenameHeapInventory
import host.ts.RenamePublicInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Structural evaluation can change control and the stack while keeping all
heap bytes, native state and the next host address exactly unchanged. Numeric
requests may still extend the number server independently on either side. -/
structure RuntimePureEffects {S : Type} (source target : St S) : Prop where
  heap : target.heap = source.heap
  native : target.ffi = source.ffi
  next : target.next = source.next

theorem RuntimePureEffects.refl {S : Type} (s : St S) : RuntimePureEffects s s := ⟨rfl,rfl,rfl⟩
theorem RuntimePureEffects.trans {S : Type} {s t u : St S}
    (first : RuntimePureEffects s t) (second : RuntimePureEffects t u) : RuntimePureEffects s u :=
  ⟨second.heap.trans first.heap,second.native.trans first.native,second.next.trans first.next⟩
theorem RuntimePureEffects.control {S : Type} (s : St S) (control : Ctl) (frames : List Frame) :
    RuntimePureEffects s ({s with stack := frames}.go control) := ⟨rfl,rfl,rfl⟩
theorem RuntimePureEffects.argumentState {S : Type} (s : St S) (kind : Nat) (fn this : Val)
    (acc : List Val) (rest : List Elem) (env : Env) :
    RuntimePureEffects s (argumentState s kind fn this acc rest env) := by
  induction rest generalizing acc with
  | nil => simp only [Parametric.argumentState]; split <;> exact ⟨rfl,rfl,rfl⟩
  | cons e rest ih => cases e with
    | expr e => exact ⟨rfl,rfl,rfl⟩
    | spread e => exact ⟨rfl,rfl,rfl⟩
    | hole => exact ih (.undef::acc)

/-- A fact about the original step, for every number-server valuation. It does
not replace the step or supply a future target execution as a hypothesis. -/
def PureRuntimeStep (F : Ffi) (s : St F.S) : Prop :=
  ∀ C result D, interpC (step F s).run C = some (result,D) → RuntimePureEffects s result

theorem PureRuntimeStep.of_pure (F : Ffi) (s result : St F.S)
    (actual : step F s = M.pure result) (effects : RuntimePureEffects s result) : PureRuntimeStep F s := by
  intro C target D run
  rw [actual] at run
  change some (result,C) = some (target,D) at run
  have eq : result = target := congrArg Prod.fst (Option.some.inj run)
  exact eq ▸ effects

theorem PureRuntimeStep.literal (F : Ffi) (s : St F.S) (literal : Lit) (value : Val) (env : Env)
    (parsed : LiteralValue literal value) (control : s.ctl = .ev (.lit literal) env) : PureRuntimeStep F s :=
  .of_pure F s _ (step_literal_eq F s literal value env parsed control) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.variable (F : Ffi) (s : St F.S) (name : Name) (env : Env) (a : Nat) (value : Val)
    (control : s.ctl = .ev (.id name) env) (lookup : lookupEnv name env = some a)
    (cell : s.heap.get a = some (.cell (some value))) : PureRuntimeStep F s :=
  .of_pure F s _ (step_variable_eq F s name env a value control lookup cell) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.this (F : Ffi) (s : St F.S) (env : Env) (a : Nat) (value : Val)
    (control : s.ctl = .ev .this env) (lookup : lookupEnv nThis env = some a)
    (cell : s.heap.get a = some (.cell (some value))) : PureRuntimeStep F s :=
  .of_pure F s _ (step_this_eq F s env a value control lookup cell) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.descent (F : Ffi) (s : St F.S) (d : Descent) (env : Env)
    (control : s.ctl = .ev d.whole env) : PureRuntimeStep F s :=
  .of_pure F s _ (step_descent_eq F s d env control) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.statement (F : Ffi) (s : St F.S) (a : StatementAction) (env : Env)
    (control : s.ctl = .ex a.statement env) : PureRuntimeStep F s :=
  .of_pure F s _ (step_statement_eq F s a env control) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.binaryLeft (F : Ffi) (s : St F.S) (value : Val) (op : BinOp)
    (right : Expr) (env : Env) (frames : List Frame) (control : s.ctl = .ret value)
    (stack : s.stack = .e (.binL op right env)::frames) : PureRuntimeStep F s :=
  .of_pure F s _ (step_binary_left_eq F s value op right env frames control stack) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.arguments (F : Ffi) (s : St F.S) (value : Val) (kind : Nat) (fn this : Val)
    (acc : List Val) (rest : List Elem) (env : Env) (frames : List Frame) (control : s.ctl = .ret value)
    (stack : s.stack = .c (.args kind fn this acc rest env)::frames) (ordinary : kind ≤ 1) : PureRuntimeStep F s :=
  .of_pure F s _ (step_argument_eq F s value kind fn this acc rest env frames control stack ordinary)
    (RuntimePureEffects.control s s.ctl frames |>.trans
      (RuntimePureEffects.argumentState {s with stack := frames} kind fn this (value::acc) rest env))
theorem PureRuntimeStep.callStart (F : Ffi) (s : St F.S) (mode : CallStart) (a : Nat) (this : Val)
    (args : List Elem) (env : Env) (frames : List Frame) (control : s.ctl = .ret (.obj a))
    (stack : s.stack = mode.frame this args env::frames) : PureRuntimeStep F s := by
  apply PureRuntimeStep.of_pure F s _ (step_callStart_eq F s mode a this args env frames control stack)
  exact (RuntimePureEffects.control s s.ctl frames).trans
    (RuntimePureEffects.argumentState {s with stack := frames} mode.kind (.obj a) (mode.receiver this) [] args env)
theorem PureRuntimeStep.blockNext (F : Ffi) (s : St F.S) (value : Val) (stmt : Stmt) (rest : List Stmt)
    (env : Env) (frames : List Frame) (control : s.ctl = .ret value)
    (stack : s.stack = .s (.block (stmt::rest) env)::frames) : PureRuntimeStep F s :=
  .of_pure F s _ (step_block_next_eq F s value stmt rest env frames control stack) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.declaration (F : Ffi) (s : St F.S) (value : Val) (kind : DeclKind) (p : Pat)
    (rest : List (Pat × Option Expr)) (env : Env) (frames : List Frame) (control : s.ctl = .ret value)
    (stack : s.stack = .s (.decl kind p rest env)::frames) (ordinary : isUsing kind = false) : PureRuntimeStep F s :=
  .of_pure F s _ (step_declaration_value_eq F s value kind p rest env frames control stack ordinary) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.returnExit (F : Ffi) (s : St F.S) (value : Val) (env : Env) (exit : ReturnExit)
    (frames : List Frame) (control : s.ctl = .ret value) (stack : s.stack = exit.frame env::frames) : PureRuntimeStep F s :=
  .of_pure F s _ (step_return_exit_eq F s value env exit frames control stack) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.returnUnwind (F : Ffi) (s : St F.S) (value : Val) (env : Env) (unwind : ReturnUnwind)
    (frames : List Frame) (control : s.ctl = .abr (.ret value)) (stack : s.stack = unwind.frame env::frames) : PureRuntimeStep F s :=
  .of_pure F s _ (step_return_unwind_eq F s value env unwind frames control stack) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.methodDescent (F : Ffi) (s : St F.S) (obj : Expr) (name : Name)
    (args : List Elem) (env : Env) (optionalObj optionalCall : Bool)
    (control : s.ctl = .ev (.call (.member obj name optionalObj) args optionalCall) env) : PureRuntimeStep F s :=
  .of_pure F s _ (step_method_descent_eq F s obj name args env optionalObj optionalCall control) ⟨rfl,rfl,rfl⟩
theorem PureRuntimeStep.methodData (F : Ffi) (s : St F.S) (a : Nat) (o : Obj) (name : Name)
    (args : List Elem) (env : Env) (optionalObj optionalCall : Bool) (value : Val) (w e : Bool) (frames : List Frame)
    (control : s.ctl = .ret (.obj a)) (stack : s.stack = .c (.member (.str name) args env optionalObj optionalCall)::frames)
    (object : s.heap.get a = some (.obj o)) (ordinary : o.kind = .ordinary)
    (field : findProp (.str name) o.props = some (.data value w e)) : PureRuntimeStep F s :=
  .of_pure F s _ (step_method_data_eq F s a o name args env optionalObj optionalCall value w e frames
    control stack object ordinary field) ⟨rfl,rfl,rfl⟩

/-- Numeric arithmetic may allocate a number-server reference; that does not
allocate a host object or mutate the native world. -/
theorem PureRuntimeStep.arithmetic (F : Ffi) (s : St F.S) (op : ArithmeticKind) (a b : NumV)
    (frames : List Frame) (control : s.ctl = .ret (.num b))
    (stack : s.stack = .e (.binR op.jsOp (.num a))::frames) : PureRuntimeStep F s := by
  intro C target D run
  rw [step_arithmetic_eq F s op a b frames control stack,numBin_map] at run
  cases primitive : interpC (numBin op.numOp a b).run C with
  | none => simp only [primitive,Option.map_none] at run; contradiction
  | some value =>
    obtain ⟨value,table⟩ := value
    simp only [primitive,Option.map_some] at run
    have eq : ({s with stack := frames}.ret (.num value)) = target := congrArg Prod.fst (Option.some.inj run)
    exact eq ▸ (show RuntimePureEffects s ({s with stack := frames}.ret (.num value)) from ⟨rfl,rfl,rfl⟩)

section
variable {S : Type} {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren} {live : Nat → Prop}
  {s₀ s result₀ result : St S}

/-- Every retained heap annotation is framed from actual step effects. The
two number servers extend independently; stack/control annotations are supplied
by the corresponding checked runtime primitive. -/
theorem HeapInventory.pure_effects {notes : HeapNotes}
    (inventory : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (source : RuntimePureEffects s₀ result₀) (target : RuntimePureEffects s result)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    HeapInventory notes ν₀ ν D₀ D R live result₀ result :=
  (inventory.mono sourceExtension targetExtension).frame (fun _ h => h)
    (by intro a _; rw [source.heap])
    (by intro a _; rw [target.heap])
theorem ArrayInventory.pure_effects {notes : ArrayNotes}
    (inventory : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (source : RuntimePureEffects s₀ result₀) (target : RuntimePureEffects s result)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    ArrayInventory notes ν₀ ν D₀ D R live result₀ result :=
  (inventory.mono sourceExtension targetExtension).frame (fun _ h => h)
    (by intro a _ _; rw [source.heap])
    (by intro a _ _; rw [target.heap])
theorem PublicInventory.pure_effects {notes : PublicNotes}
    (inventory : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (source : RuntimePureEffects s₀ result₀) (target : RuntimePureEffects s result)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    PublicInventory notes ν₀ ν D₀ D R live result₀ result :=
  (inventory.mono sourceExtension targetExtension).frame (fun _ h => h)
    (by intro a _ _ _; rw [source.heap])
    (by intro a _ _ _; rw [target.heap])
end
end Host.Ts.Owned.Annotated
