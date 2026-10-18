import host.ts.RenameMaterializeState
import host.ts.RenameShapes
set_option maxRecDepth 1000000
namespace Host.Ts

theorem ffi_call_mk (S : Type)
    (call : S → Name → List Arg → M (Option (S × Ret × List (Nat × Nat × List Byte))))
    (read : S → Nat → Nat → Nat → Option (List Byte)) (addr : Name → Nat)
    (back : S → Arg → M (Option (S × Ret × List (Nat × Nat × List Byte)))) :
    (Ffi.mk S call read addr back).call = call := rfl

private theorem materialize_buffer_patch (C : CSrv) (o : Obj) (bs bytes : List Byte) (off : Nat) :
    (materializer C).obj { o with kind := .buf (bs.take off ++ bytes ++ bs.drop (off + len bytes)) } =
      { (materializer C).obj o with
        kind := .buf ((bs.map (materializer C).byte).take off ++ bytes.map (materializer C).byte ++
          (bs.map (materializer C).byte).drop (off + len (bytes.map (materializer C).byte))) } := by
  simp only [NameMap.obj, NameMap.kind, List.map_append, List.map_take, List.map_drop, len_map]

/-- Every actual JS-buffer write commutes with full-state numeric materialization.
Failure also corresponds: materialization changes neither object kinds nor buffer addresses. -/
theorem applyWrites_materialize (F : Ffi) (ffiMap : CSrv → F.S → F.S) (C : CSrv)
    (s : St F.S) (writes : List (Nat × Nat × List Byte)) :
    applyWrites F (materializeStateWith ffiMap C s) (writes.map (materializer C).write) =
      (applyWrites F s writes).map (materializeStateWith ffiMap C) := by
  induction writes generalizing s with
  | nil => rfl
  | cons w ws ih =>
    obtain ⟨b, off, bytes⟩ := w
    simp only [List.map_cons, NameMap.write, materializer, id_eq, applyWrites,
      materializeStateWith_obj]
    cases ho : s.obj? b with
    | none => rfl
    | some o =>
      obtain ⟨kind, proto, props, priv, ext⟩ := o
      cases kind <;> try rfl
      rename_i bs
      simp only [Option.map_some, NameMap.obj, NameMap.kind]
      have hu := materializeStateWith_setObj ffiMap C s b
        { kind := .buf (bs.take off ++ bytes ++ bs.drop (off + len bytes))
          proto := proto, props := props, priv := priv, extensible := ext }
      rw [materialize_buffer_patch C ⟨.buf bs, proto, props, priv, ext⟩ bs bytes off] at hu
      dsimp only [materializer, NameMap.obj] at hu
      rw [← hu]
      exact ih _

theorem materializeStateWith_setFfi {S : Type} (ffiMap : CSrv → S → S) (C : CSrv) (s : St S) (native : S) :
    materializeStateWith ffiMap C (s.setFfi native) =
      (materializeStateWith ffiMap C s).setFfi (ffiMap C native) := rfl

theorem materializeStateWith_setTrace {S : Type} (ffiMap : CSrv → S → S) (C : CSrv)
    (s : St S) (trace : List Event) :
    materializeStateWith ffiMap C (s.setTrace trace) =
      (materializeStateWith ffiMap C s).setTrace (trace.map (materializer C).event) := rfl

theorem applyWrites_one_buffer (F : Ffi) (s : St F.S) (b off : Nat)
    (bytes bs : List Byte) (o : Obj) (ho : s.obj? b = some o) (hk : o.kind = .buf bs) :
    applyWrites F s [(b, off, bytes)] = some (s.setObj b
      { o with kind := .buf (bs.take off ++ bytes ++ bs.drop (off + len bytes)) }) := by
  simp only [applyWrites, ho, hk]

theorem decodeArgs_ptr_u64 (F : Ffi) (s : St F.S) (b off : Nat) (handle : Int) (bs : List Byte)
    (hb : bufBytes F s b = some bs) :
    decodeArgs F s [.str chars!"ptr", .str chars!"u64"] [.ptr (.js b) off, .big handle] =
      M.pure (some [.jsPtr b off (bs.drop off), .big handle]) := by
  have hptr : nameEq chars!"ptr" chars!"ptr" = true := Nat.beq_refl (pack chars!"ptr")
  have hu64 : nameEq chars!"u64" chars!"u64" = true := Nat.beq_refl (pack chars!"u64")
  have hp : nameEq chars!"u64" chars!"ptr" = false := by decide +kernel
  have hpointer : nameEq chars!"u64" chars!"pointer" = false := by decide +kernel
  have hbuffer : nameEq chars!"u64" chars!"buffer" = false := by decide +kernel
  have hcstring : nameEq chars!"u64" chars!"cstring" = false := by decide +kernel
  funext β k
  simp only [decodeArgs, decodeArg, hptr, hu64, hp, hpointer, hbuffer, hcstring,
    Bool.true_or, Bool.false_or, Bool.cond_true, Bool.cond_false, hb, Option.map_some, M.bind, M.pure]

theorem bufBytes_of_obj (F : Ffi) (s : St F.S) (b : Nat) (o : Obj) (bs : List Byte)
    (ho : s.obj? b = some o) (hk : o.kind = .buf bs) : bufBytes F s b = some bs := by
  obtain ⟨kind, proto, props, priv, ext⟩ := o
  dsimp only at hk
  subst kind
  simp only [bufBytes, ho]

theorem elemsOf_array (F : Ffi) (s : St F.S) (a : Nat) (o : Obj) (es : List Val)
    (ho : s.obj? a = some o) (hk : o.kind = .array es) :
    elemsOf F s (.obj a) = M.pure (some es) := by
  obtain ⟨kind, proto, props, priv, ext⟩ := o
  dsimp only at hk
  subst kind
  simp only [elemsOf, ho]

/-- Interpreter dispatch of the actual native-symbol wrapper with its pointer/u64
signature. The concrete native symbol theorem supplies `hcall`; no machine-step
simulation premise is used. -/
theorem step_ffi_ptr_u64 (F : Ffi) (s : St F.S) {receiver : Val} (fn types b off : Nat) (handle : Int)
    (name returns : Name) (fo to : Obj) (bs : List Byte)
    (native : F.S) (result : Ret) (writes : List (Nat × Nat × List Byte))
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js b) off, .big handle])
    (hfn : s.obj? fn = some fo)
    (hfk : fo.kind = .fn (.native (.ffi .symbol) [.str name, .obj types, .str returns]))
    (ht : s.obj? types = some to) (htk : to.kind = .array [.str chars!"ptr", .str chars!"u64"])
    (hb : bufBytes F s b = some bs)
    (hcall : F.call s.ffi name [.jsPtr b off (bs.drop off), .big handle] =
      M.pure (some (native, result, writes))) :
    step F s = ffiDone F s name [.jsPtr b off (bs.drop off), .big handle]
      (some (native, result, writes)) := by
  funext β k
  simp only [step, hc, callStep, hfn, hfk, callNative, ffiN]
  rw [elemsOf_array F s types to _ ht htk]
  dsimp only [M.bind, M.pure]
  rw [decodeArgs_ptr_u64 F s b off handle bs hb]
  simp only [M.bind, M.pure]
  rw [hcall]
  rfl

/-- The actual FFI completion path preserves numeric materialization through JS
buffer writes, trace recording, and the status return. Native call correctness is
discharged separately by the concrete symbol's theorem. -/
theorem ffiDone_status0_materialize (F : Ffi) (ffiMap : CSrv → F.S → F.S) (C : CSrv)
    (s u : St F.S) (native : F.S) (name : Name) (args : List Arg)
    (writes : List (Nat × Nat × List Byte))
    (hw : applyWrites F (s.setFfi native) writes = some u) :
    let t := (u.setTrace (⟨name, args, Host.Mlx.Ffi.status0⟩ :: u.trace)).ret (.num zeroN)
    ffiDone F s name args (some (native, Host.Mlx.Ffi.status0, writes)) = M.pure t ∧
      ffiDone F (materializeStateWith ffiMap C s) name (args.map (materializer C).arg)
        (some (ffiMap C native, Host.Mlx.Ffi.status0, writes.map (materializer C).write)) =
          M.pure (materializeStateWith ffiMap C t) := by
  dsimp only
  have hw' : applyWrites F ((materializeStateWith ffiMap C s).setFfi (ffiMap C native))
      (writes.map (materializer C).write) = some (materializeStateWith ffiMap C u) := by
    rw [← materializeStateWith_setFfi, applyWrites_materialize, hw]
    rfl
  constructor
  · simp only [ffiDone, hw, Host.Mlx.Ffi.status0, retVal, retS]
  · simp only [ffiDone, hw', Host.Mlx.Ffi.status0, retVal, retS]
    rfl

/-- Lift a proved native-symbol result through the interpreter's actual wrapper,
buffer writes, trace and return. Concrete symbol lemmas discharge the two call
equations; this theorem does not assume a machine-step simulation. -/
theorem step_ffi_ptr_u64_materialize (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (C : CSrv) (s u : St F.S) {receiver : Val} (fn types b off : Nat) (handle : Int)
    (name returns : Name) (fo to : Obj) (bs : List Byte)
    (native : F.S) (writes : List (Nat × Nat × List Byte))
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js b) off, .big handle])
    (hfn : s.obj? fn = some fo)
    (hfk : fo.kind = .fn (.native (.ffi .symbol) [.str name, .obj types, .str returns]))
    (ht : s.obj? types = some to) (htk : to.kind = .array [.str chars!"ptr", .str chars!"u64"])
    (hb : bufBytes F s b = some bs)
    (hb' : bufBytes F (materializeStateWith ffiMap C s) b = some (bs.map (materializer C).byte))
    (hw : applyWrites F (s.setFfi native) writes = some u)
    (hcall : F.call s.ffi name [.jsPtr b off (bs.drop off), .big handle] =
      M.pure (some (native, Host.Mlx.Ffi.status0, writes)))
    (hcall' : F.call (ffiMap C s.ffi) name
      [.jsPtr b off ((bs.map (materializer C).byte).drop off), .big handle] =
      M.pure (some (ffiMap C native, Host.Mlx.Ffi.status0, writes.map (materializer C).write))) :
    let args := [Arg.jsPtr b off (bs.drop off), .big handle]
    let t := (u.setTrace (⟨name, args, Host.Mlx.Ffi.status0⟩ :: u.trace)).ret (.num zeroN)
    step F s = M.pure t ∧
      step F (materializeStateWith ffiMap C s) = M.pure (materializeStateWith ffiMap C t) := by
  dsimp only
  have hdone := ffiDone_status0_materialize F ffiMap C s u native name
    [Arg.jsPtr b off (bs.drop off), .big handle] writes hw
  have hcs : (materializeStateWith ffiMap C s).ctl =
      .call (.obj fn) ((materializer C).val receiver) [.ptr (.js b) off, .big handle] := by
    change (materializer C).ctl s.ctl = _
    rw [hc]
    rfl
  have hfn' : (materializeStateWith ffiMap C s).obj? fn = some ((materializer C).obj fo) := by
    rw [materializeStateWith_obj, hfn]
    rfl
  have hfk' : ((materializer C).obj fo).kind = .fn (.native (.ffi .symbol)
      [.str name, .obj types, .str returns]) := by
    change (materializer C).kind fo.kind = _
    rw [hfk]
    rfl
  have ht' : (materializeStateWith ffiMap C s).obj? types = some ((materializer C).obj to) := by
    rw [materializeStateWith_obj, ht]
    rfl
  have htk' : ((materializer C).obj to).kind = .array [.str chars!"ptr", .str chars!"u64"] := by
    change (materializer C).kind to.kind = _
    rw [htk]
    rfl
  have hcall'' : F.call (materializeStateWith ffiMap C s).ffi name
      [.jsPtr b off ((bs.map (materializer C).byte).drop off), .big handle] =
      M.pure (some (ffiMap C native, Host.Mlx.Ffi.status0, writes.map (materializer C).write)) := by
    rw [materializeStateWith_ffi]
    exact hcall'
  constructor
  · rw [step_ffi_ptr_u64 F s fn types b off handle name returns fo to bs native
      Host.Mlx.Ffi.status0 writes hc hfn hfk ht htk hb hcall]
    exact hdone.1
  · rw [step_ffi_ptr_u64 F (materializeStateWith ffiMap C s) fn types b off handle name returns
      ((materializer C).obj fo) ((materializer C).obj to) (bs.map (materializer C).byte)
      (ffiMap C native) Host.Mlx.Ffi.status0 (writes.map (materializer C).write)
      hcs hfn' hfk' ht' htk' hb' hcall'']
    simpa only [List.map_cons, List.map_nil, NameMap.arg, List.map_drop, materializer, id_eq] using hdone.2

end Host.Ts
