import host.ts.RenameIntegerPacking
import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeArguments

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

/-- A fixed numeric meaning's integral domain is chosen independently of the
machine states. Its laws establish the actual literal decoder and roundtrip. -/
structure IntegerLiteralSchema (meaning : SymE) where
  valid : (Nat → F64) → Prop
  value : (Nat → F64) → Int
  decode : ∀ ν, valid ν → F64.toInt? (meaning.eval ν) = some (value ν)
  roundtrip : ∀ ν, valid ν → F64.ofInt (value ν) = meaning.eval ν

def IntegerLiteralSchema.closed (meaning : SymE) (integer : Int)
    (closed : ∀ ν, meaning.eval ν = F64.ofInt integer)
    (decode : F64.toInt? (F64.ofInt integer) = some integer) : IntegerLiteralSchema meaning :=
  ⟨fun _ => True,fun _ => integer,fun ν _ => by rw [closed ν]; exact decode,fun ν _ => (closed ν).symm⟩

/-- Bounded natural meanings cover loop indices and capacities without fixing
their value across valuations. The domain consists only of current arithmetic
bounds and the fixed expression's numeric interpretation. -/
def IntegerLiteralSchema.boundedNatural (meaning : SymE) (number : (Nat → F64) → Nat) :
    IntegerLiteralSchema meaning :=
  ⟨fun ν => number ν < 2^53 ∧ meaning.eval ν = F64.ofNat (number ν),fun ν => Int.ofNat (number ν),
    fun ν held => by rw [held.2]; exact F64.toInt_ofNat53 _ held.1,
    fun ν held => by simpa only [F64.ofInt,F64.ofNat] using held.2.symm⟩

/-- The retained literal note supplies both original arguments. Integral-domain
laws determine the bigint results; neither target operands nor post-state
annotations are premises. All native and host occurrence meanings are framed. -/
theorem RetainedInventory.bigint_literal_step (F : Ffi)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (FR : Ren → F.S → F.S → Prop)
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (fn : Nat) (function : Obj) (data : List Val) (receiver : Val) (sourceValue : F64)
    (control : s₀.ctl = .call (.obj fn) receiver [.num (.lit sourceValue)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.num .bigint) data))
    (meaning : SymE) (schema : IntegerLiteralSchema meaning)
    (sourceValid : schema.valid ν₀) (targetValid : schema.valid ν)
    (fnRole thisRole : Value) (note : notes.runtime.control = callNote fnRole thisRole [.literal meaning]) :
    ∃ t, interpC (step F s₀).run C₀ = some (s₀.ret (.big (schema.value ν₀)),C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (s₀.ret (.big (schema.value ν₀))) t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.exactInteger meaning),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (s₀.ret (.big (schema.value ν₀))) t ∧ t.ffi = s.ffi := by
  obtain ⟨sourceRole,targetRole⟩ := inventory.runtime.call_argument_role fnRole thisRole [.literal meaning]
    (.obj fn) receiver _ control note 0 (.literal meaning) rfl
  have sourceValueMeaning : sourceValue = meaning.eval ν₀ := by
    simp only [control,callArgument,Host.Ts.arg,nthD] at sourceRole
    cases sourceRole with | literal _ _ denotes => exact Option.some.inj denotes
  obtain ⟨targetFunction,targetData,targetThis,targetArgs,targetControl,targetRead,targetKind,_,_,argumentRoles⟩ :=
    h.native_call_view fn function (.num .bigint) data receiver _ control read kind
  cases argumentRoles with | cons argument rest =>
    cases rest
    simp only [targetControl,callArgument,Host.Ts.arg,nthD] at targetRole
    cases targetRole with | literal _ targetValue targetMeaning =>
      have targetValueMeaning : targetValue = meaning.eval ν := Option.some.inj targetMeaning
      obtain ⟨left,right,post⟩ := step_bigint_number_roles F (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        s₀ s h C₀ C fn (R.a fn) receiver targetThis sourceValue targetValue (schema.value ν₀) (schema.value ν)
        function targetFunction data targetData control targetControl (by simp only [St.obj?,read])
        (by simp only [St.obj?,targetRead]) kind targetKind
        (by rw [sourceValueMeaning]; exact schema.decode ν₀ sourceValid)
        (by rw [targetValueMeaning]; exact schema.decode ν targetValid)
        ((schema.roundtrip ν₀ sourceValid).trans sourceValueMeaning.symm)
        ((schema.roundtrip ν targetValid).trans targetValueMeaning.symm)
        ⟨meaning,⟨by change some sourceValue = some (meaning.eval ν₀); rw [sourceValueMeaning],targetMeaning⟩⟩
      have sourceReturn : (Value.exactInteger meaning).Holds ν₀ C₀ identity (.big (schema.value ν₀)) :=
        .exactInteger meaning _ (by change some (F64.ofInt _) = some (meaning.eval ν₀); rw [schema.roundtrip ν₀ sourceValid])
          (schema.decode ν₀ sourceValid)
      have targetReturn : (Value.exactInteger meaning).Holds ν C R (.big (schema.value ν)) :=
        .exactInteger meaning _ (by change some (F64.ofInt _) = some (meaning.eval ν); rw [schema.roundtrip ν targetValid])
          (schema.decode ν targetValid)
      exact ⟨_,left,right,post,
        ⟨⟨inventory.runtime.keyLive,⟨returnNote_holds sourceReturn,inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
          ⟨returnNote_holds targetReturn,inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩,
        inventory.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
        inventory.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
        inventory.arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
        inventory.publicFields.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
        inventory.buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩,rfl⟩

end Host.Ts.Owned.Annotated
