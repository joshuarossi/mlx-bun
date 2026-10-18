import host.ts.RenameAnnotations
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

def valueNumeric (P : NumV → Prop) : Val → Prop
  | .num n => P n
  | _ => True
def cellNumeric (P : NumV → Prop) : Cell → Prop
  | .num n => P n
  | _ => True
def byteNumeric (P : NumV → Prop) : Byte → Prop
  | .lit _ => True
  | .part _ c _ => cellNumeric P c
mutual
  def treeNumeric (P : NumV → Prop) : Tree → Prop
    | .value v => valueNumeric P v
    | .cell c => cellNumeric P c
    | .byte b => byteNumeric P b
    | .number n => P n
    | .node _ fields => forestNumeric P fields
    | _ => True
  def forestNumeric (P : NumV → Prop) : List Tree → Prop
    | [] => True
    | field::fields => treeNumeric P field ∧ forestNumeric P fields
end
def heapObjectNumeric (P : NumV → Prop) : HObj → Prop
  | .cell none => True
  | .cell (some v) => valueNumeric P v
  | .obj o => treeNumeric P (Encode.obj o)

theorem ValueR.identity {P : NumV → Prop} {NR : NumV → NumV → Prop}
    (numeric : ∀ n, P n → NR n n) (v : Val) (closed : valueNumeric P v) :
    ValueR NR Annotated.identity v v := by
  cases v with
  | undef => exact .undef
  | null => exact .null
  | bool b => exact .bool b
  | str name => exact .str name
  | num n => exact .num (numeric n closed)
  | big i => exact .ordinaryBig i
  | obj a => exact .obj a
  | sym a => simpa only [Annotated.identity_sym] using ValueR.sym (NR:=NR) (R:=Annotated.identity) a
  | ptr m off => cases m <;> exact .ptr _ off

theorem CellR.identity {P : NumV → Prop} {NR : NumV → NumV → Prop}
    (numeric : ∀ n, P n → NR n n) (c : Cell) (closed : cellNumeric P c) :
    CellR NR Annotated.identity c c := by
  cases c with
  | num n => exact .num (numeric n closed)
  | big i => exact .ordinaryBig i

theorem ByteR.identity {P : NumV → Prop} {NR : NumV → NumV → Prop}
    (numeric : ∀ n, P n → NR n n) (b : Byte) (closed : byteNumeric P b) :
    ByteR NR Annotated.identity b b := by
  cases b with
  | lit b => exact .lit b
  | part k c i => exact .part k i (.identity numeric c closed)

mutual
  theorem TreeR.identity {P : NumV → Prop} {NR : NumV → NumV → Prop}
      (numeric : ∀ n, P n → NR n n) (t : Tree) (closed : treeNumeric P t) :
      TreeR NR Annotated.identity t t := by
    cases t with
    | atom α x => exact .atom α x
    | value v => exact .value (.identity numeric v closed)
    | cell c => exact .cell (.identity numeric c closed)
    | byte b => exact .byte (.identity numeric b closed)
    | address a => exact .address a
    | symbol a => simpa only [Annotated.identity_sym] using TreeR.symbol (NR:=NR) (R:=Annotated.identity) a
    | region a => exact .region a
    | number n => exact .number (numeric n closed)
    | node tag fields => exact .node tag (ForestR.identity numeric fields closed)
  theorem ForestR.identity {P : NumV → Prop} {NR : NumV → NumV → Prop}
      (numeric : ∀ n, P n → NR n n) (fields : List Tree) (closed : forestNumeric P fields) :
      ForestR NR Annotated.identity fields fields := by
    cases fields with
    | nil => exact .nil
    | cons field fields => exact .cons (TreeR.identity numeric field closed.1) (ForestR.identity numeric fields closed.2)
end

theorem HeapObjectR.identity {P : NumV → Prop} {NR : NumV → NumV → Prop}
    (numeric : ∀ n, P n → NR n n) (o : HObj) (closed : heapObjectNumeric P o) :
    HeapObjectR NR Annotated.identity o o := by
  cases o with
  | cell value => cases value with
    | none => exact .uninitialized
    | some v => exact .cell (.identity numeric v closed)
  | obj o => exact .obj (.identity numeric (Encode.obj o) closed)

/-- Source-only closure and numeric-availability certificates establish the
initial heap relation. No target heap or execution is an input. -/
theorem HeapR.identity {S : Type} {P : NumV → Prop} {NR : NumV → NumV → Prop}
    (numeric : ∀ n, P n → NR n n) (s : St S) (live : Nat → Prop)
    (bound : ∀ a, live a → a < s.next)
    (closed : ∀ a o, live a → s.heap.get a = some o → heapObjectNumeric P o ∧ treeSupport live (Encode.hobj o)) :
    HeapR NR Annotated.identity live (fun _ => False) [] [] s s := by
  refine ⟨?_,bound,bound,fun _ impossible => False.elim impossible,fun _ _ _ _ equal => equal,fun _ => rfl⟩
  intro a alive
  change SlotR NR Annotated.identity live (fun _ => False) [] [] a (s.heap.get a) (s.heap.get a)
  cases read : s.heap.get a with
  | none => exact .absent (fun impossible => impossible)
  | some o =>
    have safe := closed a o alive read
    exact .regular (fun impossible => impossible) (.identity numeric o safe.1) safe.2

private theorem list_identity {α : Type} {p : α → Prop} {rel : α → α → Prop}
    (identity : ∀ x, p x → rel x x) (xs : List α) (closed : listSupport p xs) : ListR rel xs xs := by
  induction xs with
  | nil => exact .nil
  | cons x xs ih => exact .cons (identity x closed.1) (ih closed.2)

/-- A complete initial runtime relation follows from finite certificates for
its actual heap, control, frames, jobs and stores. Its existing trace is the
unchanged trace frame; native correspondence remains an explicit invariant. -/
theorem StateR.identity {S : Type} {P : NumV → Prop} {NR : NumV → NumV → Prop}
    (numeric : ∀ n, P n → NR n n) (s : St S) (live : Nat → Prop) (FR : Ren → S → S → Prop)
    (bound : ∀ a, live a → a < s.next)
    (heap : ∀ a o, live a → s.heap.get a = some o → heapObjectNumeric P o ∧ treeSupport live (Encode.hobj o))
    (control : treeNumeric P (Encode.ctl s.ctl)) (controlLive : treeSupport live (Encode.ctl s.ctl))
    (stack : listSupport (fun f => treeNumeric P (Encode.frame f)) s.stack)
    (stackLive : listSupport (fun f => treeSupport live (Encode.frame f)) s.stack)
    (jobs : listSupport (fun j => treeNumeric P (Encode.job j)) s.jobs)
    (jobsLive : listSupport (fun j => treeSupport live (Encode.job j)) s.jobs)
    (stores : treeNumeric P (Encode.stores s.stores)) (storesLive : treeSupport live (Encode.stores s.stores))
    (native : FR Annotated.identity s.ffi s.ffi) :
    StateR NR FR Annotated.identity live (fun _ => False) [] [] s.trace s.trace s s :=
  ⟨HeapR.identity numeric s live bound heap,TreeR.identity numeric _ control,controlLive,
    list_identity (fun f closed => TreeR.identity numeric (Encode.frame f) closed) _ stack,stackLive,
    list_identity (fun j closed => TreeR.identity numeric (Encode.job j) closed) _ jobs,jobsLive,
    TreeR.identity numeric _ stores,storesLive,native,[],[],rfl,rfl,.nil⟩

theorem numberRoles_reflexive_value (ν : Nat → F64) (C : CSrv) (n : NumV) (x : F64)
    (value : C.val n = some x) : NumberRoles ν ν C C n n := by
  have denote : NumDenote ν C (.lit x) n := by
    exact value
  exact ⟨.lit x,denote,denote⟩
end Host.Ts.Owned.Parametric
