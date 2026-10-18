import host.ts.RenameRetainedNormalize
import host.ts.RenameRetainedObjectVariable
import host.ts.RenameRetainedMlxParameterBlock
import host.ts.RenameRetainedPrivateObjectRead
import host.ts.RenameRuntimeCallEntry
import host.ts.RuntimeInventoryMethod
import host.ts.RenameLookupFrame
import host.ts.RenameRuntimeDriverRegistry
import host.ts.RenameRetainedConstructorReturn
import host.ts.RenameRuntimeReturns

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Ts.Owned.Annotated.MlxConstruction
open Parametric

def registerArgs : List Elem :=
  [.expr .this,.expr (.id chars!"handle"),.expr (.priv .this chars!"token" false)]
def registerCaller (env : Env) (frames : List Frame) : List Frame := .s (.block [] env)::frames
def registerNotes (notes : RetainedNotes) (env : Env) (tail : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote .undef,blockFrameNote [] env::tail,notes.runtime.cells⟩
def registerOutput {S : Type} (source : St S) (env : Env) (frames : List Frame) : St S :=
  {source with ctl := .ret .undef,stack := registerCaller env frames}

private theorem reg_one (F : Ffi) (source target : St F.S) (C : CSrv)
    (active : isHalt source.ctl = false) (execution : interpC (step F source).run C = some (target,C)) :
    runC F 1 source C = some (target,C) := runC_cons F 0 source target target C C C active execution rfl

/-- The real registration expression consumes the receiver/argument cell
roles and the structural token field. Its inherited method is selected from
an initialized source prototype path. The native finalization builtin is the
original pure registration rule, not an assumed callback execution. -/
theorem register_block {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (frames : List Frame) (head : Tree) (tail : List Tree) (value : Val)
    (registryCell registry callee thisCell parameterCell owner brand token : Nat)
    (object calleeObject : Obj) (argument : Val) (argumentRole : Value) (data : List Val)
    (w e tw te : Bool)
    (control : source.ctl = .ret value)
    (stack : source.stack = .s (.block [.expr registerExpression] env)::frames)
    (stackNotes : notes.runtime.stack = head::tail)
    (registryLookup : lookupEnv chars!"registry" env = some registryCell)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (parameterLookup : lookupEnv chars!"handle" env = some parameterCell)
    (brandLookup : lookupEnv (privName chars!"token") env = some brand)
    (registryRead : source.heap.get registryCell = some (.cell (some (.obj registry))))
    (thisRead : source.heap.get thisCell = some (.cell (some (.obj owner))))
    (parameterRead : source.heap.get parameterCell = some (.cell (some argument)))
    (objectRead : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (tokenDescriptor : findPriv brand chars!"token" object.priv = some (.data (.obj token) tw te))
    (path : OrdinaryLookup source chars!"register" 16 registry (some (.data (.obj callee) w e)))
    (calleeRead : source.heap.get callee = some (.obj calleeObject))
    (calleeKind : calleeObject.kind = .fn (.native (.fn .finRegister) data))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (parameterNote : notes.runtime.cells.cells parameterCell = some argumentRole) :
    ∃ result,
      runC F 15 source C₀ = some (registerOutput source env frames,C₀) ∧
      runC F 15 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (registerOutput source env frames) result ∧
      RetainedInventory (registerNotes notes env tail) ν₀ ν C₀ C R live (registerOutput source env frames) result ∧
      result.heap = target.heap ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨s1,left1,right1,h1,runtime1⟩ := inventory.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    source target h value (.expr registerExpression) [] env frames head tail control stack stackNotes
  have pure1 := PureRuntimeCase.blockNext h value (.expr registerExpression) [] env frames control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  host_normalize_retained h1, inv1
  obtain ⟨left2,right2,h2,runtime2⟩ := inv1.runtime.statement_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h1 (.expression registerExpression) env rfl
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h2, inv2
  obtain ⟨left3,right3,h3,runtime3⟩ := inv2.runtime.call_entry_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h2 (.method (.id chars!"registry") chars!"register" false) registerArgs false env rfl
  have inv3 := inv2.heap_step runtime3 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h3, inv3
  obtain ⟨left4,right4,h4,inv4⟩ := inv3.variable_object_step h3 chars!"registry" env registryCell registry
    rfl registryLookup registryRead
  host_normalize_retained h4, inv4
  have registryAlive : live registry := h4.controlLive.1
  let source4 : St F.S := {source with ctl := .ret (.obj registry), stack := .c (.member (.str chars!"register") registerArgs env false false)::registerCaller env frames}
  obtain ⟨_,left5,right5,h5,runtime5,_,_,_⟩ := inv4.runtime.method_object_path_step F FR _ notes.publicFields ν₀ ν C₀ C R
    live framed before after old old' _ _ h4 inv4.publicFields registry callee chars!"register" registerArgs env false false
    w e (registerCaller env frames) (CallEntry.frameNote registerArgs false env (.method (.id chars!"registry") chars!"register" false))
    (blockFrameNote [] env::tail) rfl rfl (path.frame_live (reached:=source4) h.heap (fun _ _ => rfl) registryAlive) rfl
  have inv5 := inv4.heap_step runtime5 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h5, inv5
  obtain ⟨_,_,left6,right6,h6,runtime6⟩ := inv5.runtime.call_start_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h5 (.method false) callee (.obj registry) (.obj registry) registerArgs env (registerCaller env frames)
    (blockFrameNote [] env::tail) rfl rfl rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h6, inv6
  obtain ⟨_,left7,right7,h7,runtime7⟩ := inv6.runtime.this_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h6 env thisCell (.obj owner) (.obj owner) rfl thisLookup thisRead thisNote
  have inv7 := inv6.heap_step runtime7 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h7, inv7
  obtain ⟨_,_,_,_,_,left8,right8,h8,runtime8⟩ := inv7.runtime.argument_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h7 (.obj owner) (.obj owner) (.obj callee) (.obj registry) [] 0 (.obj callee) (.obj registry) [] registerArgs.tail env
    (registerCaller env frames) (blockFrameNote [] env::tail) rfl rfl (by decide) rfl rfl
  have inv8 := inv7.heap_step runtime8 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h8, inv8
  obtain ⟨_,left9,right9,h9,runtime9⟩ := inv8.runtime.variable_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h8 chars!"handle" env parameterCell argument argumentRole rfl parameterLookup parameterRead parameterNote
  have inv9 := inv8.heap_step runtime9 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h9, inv9
  obtain ⟨_,_,_,_,_,left10,right10,h10,runtime10⟩ := inv9.runtime.argument_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h9 argument argumentRole (.obj callee) (.obj registry) [.obj owner] 0 (.obj callee) (.obj registry) [.obj owner]
    registerArgs.tail.tail env (registerCaller env frames) (blockFrameNote [] env::tail) rfl rfl (by decide) rfl rfl
  have inv10 := inv9.heap_step runtime10 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h10, inv10
  obtain ⟨s13,left13,right13,h13,inv13,heap13,native13,next13⟩ := inv10.this_private_object_block h10 env thisCell owner brand token
    chars!"token" object tw te rfl thisLookup brandLookup thisRead objectRead ordinary tokenDescriptor thisNote
  obtain ⟨_,_,_,_,_,left14,right14,h14,runtime14⟩ := inv13.runtime.argument_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h13 (.obj token) (.obj token) (.obj callee) (.obj registry) [argumentRole,.obj owner] 0 (.obj callee) (.obj registry)
    [argument,.obj owner] [] env (registerCaller env frames) (blockFrameNote [] env::tail) rfl rfl (by decide) rfl rfl
  have inv14 := inv13.heap_step runtime14 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h14, inv14
  obtain ⟨left15,right15,h15,inv15⟩ := inv14.finalization_register_step h14 callee calleeObject data (.obj registry)
    [.obj owner,argument,.obj token] rfl calleeRead calleeKind
  have l1 := reg_one F _ _ C₀ (by rw [control]; rfl) left1
  have r1 := reg_one F _ _ C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1
  have l2 := reg_one F _ _ C₀ rfl left2
  have r2 := reg_one F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have l3 := reg_one F _ _ C₀ rfl left3
  have r3 := reg_one F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have l4 := reg_one F _ _ C₀ rfl left4
  have r4 := reg_one F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  have l5 := reg_one F _ _ C₀ rfl left5
  have r5 := reg_one F _ _ C (h4.control.isHalt_eq.trans rfl) right5
  have l6 := reg_one F _ _ C₀ rfl left6
  have r6 := reg_one F _ _ C (h5.control.isHalt_eq.trans rfl) right6
  have l7 := reg_one F _ _ C₀ rfl left7
  have r7 := reg_one F _ _ C (h6.control.isHalt_eq.trans rfl) right7
  have l8 := reg_one F _ _ C₀ rfl left8
  have r8 := reg_one F _ _ C (h7.control.isHalt_eq.trans rfl) right8
  have l9 := reg_one F _ _ C₀ rfl left9
  have r9 := reg_one F _ _ C (h8.control.isHalt_eq.trans rfl) right9
  have l10 := reg_one F _ _ C₀ rfl left10
  have r10 := reg_one F _ _ C (h9.control.isHalt_eq.trans rfl) right10
  have l14 := reg_one F _ _ C₀ rfl left14
  have r14 := reg_one F _ _ C (h13.control.isHalt_eq.trans rfl) right14
  have l15 := reg_one F _ _ C₀ rfl left15
  have r15 := reg_one F _ _ C (h14.control.isHalt_eq.trans rfl) right15
  have l5 := runC_join F (m:=4) (n:=1) (runC_join F (m:=3) (n:=1) (runC_join F (m:=2) (n:=1) (runC_join F l1 l2) l3) l4) l5
  have r5 := runC_join F (m:=4) (n:=1) (runC_join F (m:=3) (n:=1) (runC_join F (m:=2) (n:=1) (runC_join F r1 r2) r3) r4) r5
  have l10 := runC_join F (m:=9) (n:=1) (runC_join F (m:=8) (n:=1) (runC_join F (m:=7) (n:=1) (runC_join F (m:=6) (n:=1) (runC_join F (m:=5) (n:=1) l5 l6) l7) l8) l9) l10
  have r10 := runC_join F (m:=9) (n:=1) (runC_join F (m:=8) (n:=1) (runC_join F (m:=7) (n:=1) (runC_join F (m:=6) (n:=1) (runC_join F (m:=5) (n:=1) r5 r6) r7) r8) r9) r10
  exact ⟨_,runC_join F (m:=14) (n:=1) (runC_join F (m:=13) (n:=1) (runC_join F (m:=10) (n:=3) l10 left13) l14) l15,
    runC_join F (m:=14) (n:=1) (runC_join F (m:=13) (n:=1) (runC_join F (m:=10) (n:=3) r10 right13) r14) r15,
    h15,inv15,heap13.trans effects1.2.heap,native13.trans effects1.2.native,next13.trans effects1.2.next⟩

end Host.Ts.Owned.Annotated.MlxConstruction
