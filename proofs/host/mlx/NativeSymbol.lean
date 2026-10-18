import host.mlx.NativeHostState
import host.ts.RenameParametricArrayBuffer
import host.ts.RenameParametricArrayBinding

set_option Elab.async false
set_option maxRecDepth 1000000

namespace Host.Ts

theorem decodeArgs_ptr_u64_u64 (F : Ffi) (s : St F.S) (b off : Nat)
    (h1 h2 : Int) (bs : List Byte) (hb : bufBytes F s b = some bs) :
    decodeArgs F s [.str chars!"ptr",.str chars!"u64",.str chars!"u64"]
      [.ptr (.js b) off,.big h1,.big h2] =
      M.pure (some [.jsPtr b off (bs.drop off),.big h1,.big h2]) := by
  have hptr : nameEq chars!"ptr" chars!"ptr" = true := Nat.beq_refl _
  have hu64 : nameEq chars!"u64" chars!"u64" = true := Nat.beq_refl _
  have hp : nameEq chars!"u64" chars!"ptr" = false := by decide +kernel
  have hpointer : nameEq chars!"u64" chars!"pointer" = false := by decide +kernel
  have hbuffer : nameEq chars!"u64" chars!"buffer" = false := by decide +kernel
  have hcstring : nameEq chars!"u64" chars!"cstring" = false := by decide +kernel
  funext β k
  simp only [decodeArgs,decodeArg,hptr,hu64,hp,hpointer,hbuffer,hcstring,
    Bool.true_or,Bool.false_or,Bool.cond_true,Bool.cond_false,hb,Option.map_some,M.bind,M.pure]

/-- Original symbol-wrapper dispatch, before the native model's result is
completed into a host state. -/
theorem step_ffi_ptr_u64_u64 (F : Ffi) (s : St F.S) {receiver : Val}
    (fn types b off : Nat) (h1 h2 : Int) (name returns : Name) (fo to : Obj) (bs : List Byte)
    (native : F.S) (result : Ret) (writes : List (Nat × Nat × List Byte))
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js b) off,.big h1,.big h2])
    (hfn : s.obj? fn = some fo)
    (hfk : fo.kind = .fn (.native (.ffi .symbol) [.str name,.obj types,.str returns]))
    (ht : s.obj? types = some to)
    (htk : to.kind = .array [.str chars!"ptr",.str chars!"u64",.str chars!"u64"])
    (hb : bufBytes F s b = some bs)
    (hcall : F.call s.ffi name [.jsPtr b off (bs.drop off),.big h1,.big h2] =
      M.pure (some (native,result,writes))) :
    step F s = ffiDone F s name [.jsPtr b off (bs.drop off),.big h1,.big h2]
      (some (native,result,writes)) := by
  funext β k
  simp only [step,hc,callStep,hfn,hfk,callNative,ffiN]
  rw [elemsOf_array F s types to _ ht htk]
  dsimp only [M.bind,M.pure]
  rw [decodeArgs_ptr_u64_u64 F s b off h1 h2 bs hb]
  simp only [M.bind,M.pure]
  rw [hcall]
  rfl

def finishBuffer {S : Type} (s : St S) (native : S) (b off : Nat) (o : Obj)
    (bs ws : List Byte) (name : Name) (args : List Arg) : St S :=
  let u := (s.setFfi native).setObj b
    {o with kind := .buf (bs.take off ++ ws ++ bs.drop (off + len ws))}
  (u.setTrace (⟨name,args,Host.Mlx.Ffi.status0⟩::u.trace)).ret (.num zeroN)

theorem ffiDone_status0_buffer (F : Ffi) (s : St F.S) (native : F.S)
    (b off : Nat) (o : Obj) (bs ws : List Byte) (name : Name) (args : List Arg)
    (ho : s.obj? b = some o) (hk : o.kind = .buf bs) :
    ffiDone F s name args (some (native,Host.Mlx.Ffi.status0,[(b,off,ws)])) =
      M.pure (finishBuffer s native b off o bs ws name args) := by
  have ho' : (s.setFfi native).obj? b = some o := ho
  rw [ffiDone,applyWrites_one_buffer F (s.setFfi native) b off ws bs o ho' hk]
  rfl

def finishBig {S : Type} (s : St S) (native : S) (name : Name) (args : List Arg) (value : Int) : St S :=
  ((s.setFfi native).setTrace (⟨name,args,.big value⟩::s.trace)).ret (.big value)

theorem ffiDone_big_empty (F : Ffi) (s : St F.S) (native : F.S)
    (name : Name) (args : List Arg) (value : Int) :
    ffiDone F s name args (some (native,.big value,[])) = M.pure (finishBig s native name args value) := rfl

end Host.Ts

namespace Host.Ts.Owned.Parametric

theorem fixed_handle_value {ν : Nat → F64} {C : CSrv} {R : Ren} {handle : Nat} {v : Val}
    (h : (Annotated.Value.handle handle).Holds ν C R v) :
    v = .big (Int.ofNat (R.handle handle)) := by cases h; rfl

theorem fixed_ordinary_big_value {ν : Nat → F64} {C : CSrv} {R : Ren} {value : Int} {v : Val}
    (h : (Annotated.Value.ordinaryBig value).Holds ν C R v) : v = .big value := by cases h; rfl

theorem StateR.finishBig {S : Type} {NR : NumV → NumV → Prop}
    {FR FR' : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s s' : St S}
    (h : StateR NR FR R live framed before after old old' s s')
    (native native' : S) (hn : FR' R native native') (name : Name) (args args' : List Arg) (value value' : Int)
    (he : TreeR NR R (event ⟨name,args,.big value⟩) (event ⟨name,args',.big value'⟩))
    (hv : ValueR NR R (.big value) (.big value')) :
    StateR NR FR' R live framed before after old old'
      (Host.Ts.finishBig s native name args value) (Host.Ts.finishBig s' native' name args' value') :=
  ((h.setFfi native native' hn).traceCons _ _ he).go
    (.node _ (.cons (.value hv) .nil)) ⟨True.intro,True.intro⟩

theorem event_ptr_handles_roles {NR : NumV → NumV → Prop} {R : Ren}
    (name : Name) (b off h1 h2 : Nat) (bs bs' : List Byte)
    (hb : ListR (ByteR NR R) bs bs') (hz : NR zeroN zeroN) :
    TreeR NR R
      (event ⟨name,[.jsPtr b off bs,.big (Int.ofNat h1),.big (Int.ofNat h2)],Host.Mlx.Ffi.status0⟩)
      (event ⟨name,[.jsPtr (R.a b) off bs',.big (Int.ofNat (R.handle h1)),
        .big (Int.ofNat (R.handle h2))],Host.Mlx.Ffi.status0⟩) := by
  refine .node _ (.cons (.atom _ _) (.cons ?_ (.cons ?_ .nil)))
  · exact .node _ (.cons (.node _ (.cons (.address b) (.cons (.atom _ _) (.cons (bytes_roles hb) .nil))))
      (.cons (.node _ (.cons (.value (.handle h1)) .nil))
        (.cons (.node _ (.cons (.value (.handle h2)) .nil)) .nil)))
  · exact .node _ (.cons (.number hz) .nil)

/-- Lift a paired native result through the original buffer update, trace
recording and status return. The native relation may grow its graph support. -/
theorem StateR.finishBuffer {S : Type} {NR : NumV → NumV → Prop}
    {FR FR' : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s s' : St S}
    (h : StateR NR FR R live framed before after old old' s s')
    (native native' : S) (hn : FR' R native native')
    (b off h1 h2 : Nat) (o o' : Obj) (bs bs' ws ws' : List Byte) (name : Name)
    (ha : live b) (ho : s.heap.get b = some (.obj o)) (hk : o.kind = .buf bs)
    (hr : ObjectR NR R o o') (hol : treeSupport live (Encode.obj o))
    (hb : ListR (ByteR NR R) bs bs') (hw : ListR (ByteR NR R) ws ws')
    (hs : b < 2^64) (ht : R.a b < 2^64) (hz : NR zeroN zeroN) :
    StateR NR FR' R live framed before after old old'
      (Host.Ts.finishBuffer s native b off o bs ws name
        [.jsPtr b off (bs.drop off),.big (Int.ofNat h1),.big (Int.ofNat h2)])
      (Host.Ts.finishBuffer s' native' (R.a b) off o' bs' ws' name
        [.jsPtr (R.a b) off (bs'.drop off),.big (Int.ofNat (R.handle h1)),.big (Int.ofNat (R.handle h2))]) := by
  have hh := (h.setFfi native native' hn).write_buffer b off o o' bs bs' ws ws'
    ha ho hk hr hol hb hw hs ht
  exact (hh.traceCons _ _ (event_ptr_handles_roles name b off h1 h2 _ _ (hb.drop off) hz)).go
    (.node _ (.cons (.value (.num hz)) .nil)) ⟨True.intro,True.intro⟩

def objectKindAt {S : Type} (s : St S) (a : Nat) : Owned.Tree :=
  match s.obj? a with
  | some o => Encode.kind o.kind
  | none => .node "Absent" []

def slotPartRoles (handle : Nat) (n i : Nat) : List Annotated.Tree :=
  match n with
  | 0 => []
  | n+1 => .byte (.part .u64 (.handle handle) i)::slotPartRoles handle n (i+1)

def slotKindRole (handle : Nat) : Annotated.Tree :=
  .node "Kind.buf" [.node "List" (slotPartRoles handle 8 0)]

theorem slot_parts_exact {ν : Nat → F64} {C : CSrv} {R : Ren}
    (handle n i : Nat) (bs : List Byte)
    (h : Annotated.ForestHolds ν C R (slotPartRoles handle n i) (bs.map Encode.byte)) :
    bs = cellParts .u64 (.big (Int.ofNat (R.handle handle))) n i := by
  induction n generalizing i bs with
  | zero => cases bs <;> cases h; rfl
  | succ n ih =>
    cases bs with
    | nil => cases h
    | cons b bs =>
      cases h with | cons hb hs =>
        cases hb with | byte hb =>
          cases hb with | part k role j c hc =>
            cases hc
            exact congrArg (Byte.part .u64 (.big (Int.ofNat (R.handle handle))) i :: ·) (ih _ _ hs)

theorem slot_role (ν : Nat → F64) (C : CSrv) (R : Ren) (handle : Nat) :
    (slotKindRole handle).Holds ν C R
      (Encode.kind (.buf (cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0))) := by
  refine .node _ (.cons (.node _ ?_) .nil)
  have aux : ∀ n i, Annotated.ForestHolds ν C R
      (slotPartRoles handle n i) ((cellParts .u64 (.big (Int.ofNat (R.handle handle))) n i).map Encode.byte) := by
    intro n
    induction n with
    | zero => intro i; exact .nil
    | succ n ih => intro i; exact .cons (.byte (.part _ _ _ _ (.handle handle))) (ih (i+1))
  exact aux 8 0

theorem slot_role_source (ν : Nat → F64) (C : CSrv) (handle : Nat) :
    (slotKindRole handle).Holds ν C Annotated.identity
      (Encode.kind (.buf (cellParts .u64 (.big (Int.ofNat handle)) 8 0))) :=
  slot_role ν C Annotated.identity handle

/-- Completing the write preserves the fixed output-slot annotation, so a
subsequent wrapper can read the owned handle without repicking its role. -/
theorem finishBuffer_slot_role {S : Type} (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) (native : S) (a handle : Nat) (o : Obj) (name : Name) (args : List Arg)
    (bound : R.a a < 2^64) :
    (slotKindRole handle).Holds ν C R
      (objectKindAt (finishBuffer s native (R.a a) 0 o
        (cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0)
        (cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0) name args) (R.a a)) := by
  have patch :
      (cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0).take 0 ++
        cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0 ++
        (cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0).drop
          (0 + len (cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0)) =
      cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0 := rfl
  simp only [objectKindAt,finishBuffer,St.ret,St.setTrace,St.setFfi,St.setObj,St.obj?,
    PTrie.get_set_u64 _ _ _ bound,patch]
  exact slot_role ν C R handle

/-- A fixed annotation on the output slot determines its actual tagged bytes.
It is a heap occurrence annotation, not an assumed native read or step. -/
theorem slot_kind_exact {ν : Nat → F64} {C : CSrv} {R : Ren} {handle : Nat} {k : Kind}
    (h : (slotKindRole handle).Holds ν C R (Encode.kind k)) :
    k = .buf (cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0) := by
  have hp := Annotated.Tree.paired (slot_role_source ν C handle) h
  obtain ⟨bs,rfl,_⟩ := kind_buffer hp
  cases h with | node tag hs =>
    cases hs with | cons hb hs =>
      cases hb with | node tag hbs =>
        exact congrArg Kind.buf (slot_parts_exact handle 8 0 _ hbs)


end Host.Ts.Owned.Parametric
