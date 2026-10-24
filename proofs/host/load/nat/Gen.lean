import host.load.nat.Tactic
namespace Host.Ts.FfiNat

/-! # The machine's world-independent state functions

Functions polymorphic in the native state type commute with replacing it
(`St.reFfi`). -/

section
variable {S T : Type} (s : St S) (x : T)

@[rel_simp] theorem obj?_reFfi (a : Nat) : (s.reFfi x).obj? a = s.obj? a := rfl
@[rel_simp] theorem cell?_reFfi (a : Nat) : (s.reFfi x).cell? a = s.cell? a := rfl
@[rel_simp] theorem setObj_reFfi (a : Nat) (o : Obj) : (s.reFfi x).setObj a o = (s.setObj a o).reFfi x := rfl
@[rel_simp] theorem setCell_reFfi (a : Nat) (v : Val) : (s.reFfi x).setCell a v = (s.setCell a v).reFfi x := rfl
@[rel_simp] theorem alloc_reFfi (h : HObj) : (s.reFfi x).alloc h = ((s.alloc h).1, (s.alloc h).2.reFfi x) := rfl
@[rel_simp] theorem allocObj_reFfi (k : Kind) (p : Val) (ps : Props) :
    (s.reFfi x).allocObj k p ps = ((s.allocObj k p ps).1, (s.allocObj k p ps).2.reFfi x) := rfl
@[rel_simp] theorem go_reFfi (c : Ctl) : (s.reFfi x).go c = (s.go c).reFfi x := rfl
@[rel_simp] theorem push_reFfi (f : Frame) : (s.reFfi x).push f = (s.push f).reFfi x := rfl
@[rel_simp] theorem ret_reFfi (v : Val) : (s.reFfi x).ret v = (s.ret v).reFfi x := rfl
@[rel_simp] theorem setJobs_reFfi (j : List Job) : (s.reFfi x).setJobs j = (s.setJobs j).reFfi x := rfl
@[rel_simp] theorem setStores_reFfi (t : List (Nat × Val)) : (s.reFfi x).setStores t = (s.setStores t).reFfi x := rfl
@[rel_simp] theorem setTrace_reFfi (t : List Event) : (s.reFfi x).setTrace t = (s.setTrace t).reFfi x := rfl
@[rel_simp] theorem setFfi_reFfi (y : T) : (s.reFfi x).setFfi y = s.reFfi y := rfl
@[rel_simp] theorem closureObj_reFfi (f : Func) (env : Env) (arrow : Bool) (home : Val) :
    closureObj (s.reFfi x) f env arrow home = ((closureObj s f env arrow home).1, (closureObj s f env arrow home).2.reFfi x) := rfl
@[rel_simp] theorem newArray_reFfi (vs : List Val) :
    newArray (s.reFfi x) vs = ((newArray s vs).1, (newArray s vs).2.reFfi x) := rfl
@[rel_simp] theorem iterResult_reFfi (v : Val) (d : Bool) :
    iterResult (s.reFfi x) v d = ((iterResult s v d).1, (iterResult s v d).2.reFfi x) := rfl
@[rel_simp] theorem newPromise_reFfi : newPromise (s.reFfi x) = ((newPromise s).1, (newPromise s).2.reFfi x) := rfl
@[rel_simp] theorem enqueue_reFfi (j : Job) : enqueue (s.reFfi x) j = (enqueue s j).reFfi x := rfl
@[rel_simp] theorem promiseOf_reFfi (p : Nat) : promiseOf (s.reFfi x) p = promiseOf s p := rfl
@[rel_simp] theorem isPromise_reFfi (v : Val) : isPromise (s.reFfi x) v = isPromise s v := by cases v <;> rfl
@[rel_simp] theorem genOf_reFfi (g : Nat) : genOf (s.reFfi x) g = genOf s g := rfl
@[rel_simp] theorem agenQueue_reFfi (g : Nat) : agenQueue (s.reFfi x) g = agenQueue s g := rfl
@[rel_simp] theorem typeofStr_reFfi (v : Val) : typeofStr (s.reFfi x) v = typeofStr s v := by cases v <;> rfl
@[rel_simp] theorem resume_reFfi (c : Comp) : resume (s.reFfi x) c = (resume s c).reFfi x := by cases c <;> rfl

@[rel_simp] theorem cond_reFfi (c : Bool) (t : St S) : (bif c then s.reFfi x else t.reFfi x) = (bif c then s else t).reFfi x := by
  cases c <;> rfl
@[rel_simp] theorem cond_ffi (c : Bool) (t : St S) : (bif c then s else t).ffi = bif c then s.ffi else t.ffi := by
  cases c <;> rfl
@[rel_simp] theorem cond_same {α : Type} (c : Bool) (a : α) : (bif c then a else a) = a := by cases c <;> rfl

@[rel_simp] theorem mk_ffi (h : PTrie HObj) (n : Nat) (c : Ctl) (st : List Frame) (ax : Aux S) :
    (St.mk h n c st ax).ffi = ax.ffi := rfl
@[rel_simp] theorem aux_ffi : s.aux.ffi = s.ffi := rfl

@[rel_simp] theorem setObj_ffi (a : Nat) (o : Obj) : (s.setObj a o).ffi = s.ffi := rfl
@[rel_simp] theorem setCell_ffi (a : Nat) (v : Val) : (s.setCell a v).ffi = s.ffi := rfl
@[rel_simp] theorem alloc_ffi (h : HObj) : (s.alloc h).2.ffi = s.ffi := rfl
@[rel_simp] theorem allocObj_ffi (k : Kind) (p : Val) (ps : Props) : (s.allocObj k p ps).2.ffi = s.ffi := rfl
@[rel_simp] theorem go_ffi (c : Ctl) : (s.go c).ffi = s.ffi := rfl
@[rel_simp] theorem push_ffi (f : Frame) : (s.push f).ffi = s.ffi := rfl
@[rel_simp] theorem ret_ffi (v : Val) : (s.ret v).ffi = s.ffi := rfl
@[rel_simp] theorem setJobs_ffi (j : List Job) : (s.setJobs j).ffi = s.ffi := rfl
@[rel_simp] theorem setStores_ffi (t : List (Nat × Val)) : (s.setStores t).ffi = s.ffi := rfl
@[rel_simp] theorem setTrace_ffi (t : List Event) : (s.setTrace t).ffi = s.ffi := rfl
@[rel_simp] theorem setFfi_ffi (y : S) : (s.setFfi y).ffi = y := rfl
@[rel_simp] theorem closureObj_ffi (f : Func) (env : Env) (arrow : Bool) (home : Val) :
    (closureObj s f env arrow home).2.ffi = s.ffi := rfl
@[rel_simp] theorem newArray_ffi (vs : List Val) : (newArray s vs).2.ffi = s.ffi := rfl
@[rel_simp] theorem iterResult_ffi (v : Val) (d : Bool) : (iterResult s v d).2.ffi = s.ffi := rfl
@[rel_simp] theorem newPromise_ffi : (newPromise s).2.ffi = s.ffi := rfl
@[rel_simp] theorem enqueue_ffi (j : Job) : (enqueue s j).ffi = s.ffi := rfl
@[rel_simp] theorem resume_ffi (c : Comp) : (resume s c).ffi = s.ffi := by cases c <;> rfl

end

section
variable {S T : Type}

@[rel_simp] theorem allocCells_reFfi : ∀ (s : St S) (x : T) (ns : List Name) (env : Env),
    allocCells (s.reFfi x) ns env = ((allocCells s ns env).1, (allocCells s ns env).2.reFfi x)
  | _, _, [], _ => rfl
  | s, x, _ :: ns, _ => allocCells_reFfi (s.alloc (.cell none)).2 x ns _

@[rel_simp] theorem enqueueAll_reFfi : ∀ (s : St S) (x : T) (th : Bool) (v : Val) (rs : List Reaction),
    enqueueAll (s.reFfi x) th v rs = (enqueueAll s th v rs).reFfi x
  | _, _, _, _, [] => rfl
  | s, x, th, v, r :: rs => enqueueAll_reFfi (enqueue s ⟨r, th, v⟩) x th v rs

@[rel_simp] theorem initFuncs_reFfi : ∀ (s : St S) (x : T) (env : Env) (ss : List Stmt),
    initFuncs (s.reFfi x) env ss = (initFuncs s env ss).reFfi x
  | _, _, _, [] => rfl
  | s, x, env, st :: ss => by
    cases st with
    | func f =>
      obtain ⟨n, ps, r, b, a, g, pr⟩ := f
      cases n with
      | none => simp only [initFuncs]; exact initFuncs_reFfi s x env ss
      | some n =>
        simp only [initFuncs]
        cases lookupEnv n env with
        | none => exact initFuncs_reFfi s x env ss
        | some c => simp only [closureObj_reFfi, setCell_reFfi]; exact initFuncs_reFfi _ x env ss
    | _ => simp only [initFuncs]; exact initFuncs_reFfi s x env ss

@[rel_simp] theorem allocCells_ffi : ∀ (s : St S) (ns : List Name) (env : Env), (allocCells s ns env).2.ffi = s.ffi
  | _, [], _ => rfl
  | s, _ :: ns, _ => allocCells_ffi (s.alloc (.cell none)).2 ns _

@[rel_simp] theorem enqueueAll_ffi : ∀ (s : St S) (th : Bool) (v : Val) (rs : List Reaction), (enqueueAll s th v rs).ffi = s.ffi
  | _, _, _, [] => rfl
  | s, th, v, r :: rs => enqueueAll_ffi (enqueue s ⟨r, th, v⟩) th v rs

@[rel_simp] theorem initFuncs_ffi : ∀ (s : St S) (env : Env) (ss : List Stmt), (initFuncs s env ss).ffi = s.ffi
  | _, _, [] => rfl
  | s, env, st :: ss => by
    cases st with
    | func f =>
      obtain ⟨n, ps, r, b, a, g, pr⟩ := f
      cases n with
      | none => simp only [initFuncs]; exact initFuncs_ffi s env ss
      | some n =>
        simp only [initFuncs]
        cases lookupEnv n env with
        | none => exact initFuncs_ffi s env ss
        | some c => exact initFuncs_ffi _ env ss
    | _ => simp only [initFuncs]; exact initFuncs_ffi s env ss

@[rel_simp] theorem hoist_reFfi (s : St S) (x : T) (ss : List Stmt) (env : Env) :
    hoist (s.reFfi x) ss env = ((hoist s ss env).1, (hoist s ss env).2.reFfi x) := by
  unfold hoist
  split
  · rfl
  · simp only [allocCells_reFfi, initFuncs_reFfi]

@[rel_simp] theorem hoist_ffi (s : St S) (ss : List Stmt) (env : Env) : (hoist s ss env).2.ffi = s.ffi := by
  unfold hoist
  split
  · rfl
  · simp only [initFuncs_ffi, allocCells_ffi]

@[rel_simp] theorem enterBlock_reFfi (s : St S) (x : T) (ss : List Stmt) (env : Env) :
    enterBlock (s.reFfi x) ss env = (enterBlock s ss env).reFfi x := by
  unfold enterBlock
  simp only [hoist_reFfi]
  rfl

@[rel_simp] theorem enterBlock_ffi (s : St S) (ss : List Stmt) (env : Env) : (enterBlock s ss env).ffi = s.ffi := by
  unfold enterBlock
  exact hoist_ffi s ss env

@[rel_simp] theorem settle_reFfi (s : St S) (x : T) (p : Nat) (th : Bool) (v : Val) :
    settle (s.reFfi x) p th v = (settle s p th v).reFfi x := by
  unfold settle
  simp only [promiseOf_reFfi]
  split
  · simp only [setObj_reFfi, enqueueAll_reFfi]
  · rfl

@[rel_simp] theorem settle_ffi (s : St S) (p : Nat) (th : Bool) (v : Val) : (settle s p th v).ffi = s.ffi := by
  unfold settle
  split
  · exact enqueueAll_ffi _ _ _ _
  · rfl

@[rel_simp] theorem resolveP_reFfi (s : St S) (x : T) (p : Nat) (v : Val) :
    resolveP (s.reFfi x) p v = (resolveP s p v).reFfi x := by
  unfold resolveP
  simp only [isPromise_reFfi]
  split
  · cases Nat.beq p _ <;> rfl
  · exact settle_reFfi s x p false v

@[rel_simp] theorem resolveP_ffi (s : St S) (p : Nat) (v : Val) : (resolveP s p v).ffi = s.ffi := by
  unfold resolveP
  split
  · cases Nat.beq p _ <;> rfl
  · exact settle_ffi s p false v

@[rel_simp] theorem react_reFfi (s : St S) (x : T) (p : Nat) (r : Reaction) :
    react (s.reFfi x) p r = (react s p r).reFfi x := by
  unfold react
  simp only [promiseOf_reFfi]
  split <;> rfl

@[rel_simp] theorem promiseFor_reFfi (s : St S) (x : T) (v : Val) :
    promiseFor (s.reFfi x) v = ((promiseFor s v).1, (promiseFor s v).2.reFfi x) := by
  unfold promiseFor
  simp only [isPromise_reFfi]
  split
  · rfl
  · simp only [newPromise_reFfi, settle_reFfi]

@[rel_simp] theorem promiseFor_ffi (s : St S) (v : Val) : (promiseFor s v).2.ffi = s.ffi := by
  unfold promiseFor
  split
  · rfl
  · exact settle_ffi _ _ _ _

@[rel_simp] theorem setGen_reFfi (s : St S) (x : T) (g : Nat) (st : GenState) :
    setGen (s.reFfi x) g st = (setGen s g st).reFfi x := by
  unfold setGen
  simp only [obj?_reFfi]
  split
  · split <;> rfl
  · rfl

@[rel_simp] theorem setQueue_reFfi (s : St S) (x : T) (g : Nat) (q : List (Nat × Comp)) :
    setQueue (s.reFfi x) g q = (setQueue s g q).reFfi x := by
  unfold setQueue
  simp only [obj?_reFfi]
  split
  · split <;> rfl
  · rfl

/-- Label frames pushed in order (`exLoopF`). -/
@[rel_simp] theorem foldl_label_reFfi : ∀ (ls : List Name) (s : St S) (x : T),
    ls.foldl (fun s l => s.push (.s (.label l))) (s.reFfi x) = (ls.foldl (fun s l => s.push (.s (.label l))) s).reFfi x
  | [], _, _ => rfl
  | l :: ls, s, x => foldl_label_reFfi ls (s.push (.s (.label l))) x

@[rel_simp] theorem foldl_label_ffi : ∀ (ls : List Name) (s : St S),
    (ls.foldl (fun s l => s.push (.s (.label l))) s).ffi = s.ffi
  | [], _ => rfl
  | l :: ls, s => foldl_label_ffi ls (s.push (.s (.label l)))

theorem react_ffi (s : St S) (p : Nat) (r : Reaction) : (react s p r).ffi = s.ffi := by
  unfold react; split <;> rfl

theorem setGen_ffi (s : St S) (g : Nat) (st : GenState) : (setGen s g st).ffi = s.ffi := by
  unfold setGen; split
  · split <;> rfl
  · rfl

theorem setQueue_ffi (s : St S) (g : Nat) (q : List (Nat × Comp)) : (setQueue s g q).ffi = s.ffi := by
  unfold setQueue; split
  · split <;> rfl
  · rfl

attribute [rel_simp] react_ffi setGen_ffi setQueue_ffi

end

end Host.Ts.FfiNat
