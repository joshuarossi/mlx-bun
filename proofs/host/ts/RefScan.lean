import host.ts.Link
set_option Elab.async false

namespace Host.Ts.RefScan

/-- Work items retain the original scanner's nesting fuel. Administrative
items only expose a list or optional child; they do not consume that fuel. -/
inductive Task where
  | emit (n : Nat)
  | expr (fuel : Nat) (e : Expr)
  | elem (fuel : Nat) (e : Elem)
  | key (fuel : Nat) (k : Key)
  | prop (fuel : Nat) (p : Property)
  | pat (fuel : Nat) (p : Pat)
  | func (fuel : Nat) (f : Func)
  | cls (fuel : Nat) (c : Class)
  | member (fuel : Nat) (m : Member)
  | decls (fuel : Nat) (ds : List (Pat × Option Expr))
  | stmt (fuel : Nat) (s : Stmt)
  | exprOpt (fuel : Nat) (e : Option Expr)
  | patOpt (fuel : Nat) (p : Option Pat)
  | stmtOpt (fuel : Nat) (s : Option Stmt)
  | stmtsOpt (fuel : Nat) (ss : Option (List Stmt))
  | patField (fuel : Nat) (p : Key × Pat)
  | field (fuel : Nat) (p : Key × Option Expr)
  | decl (fuel : Nat) (p : Pat × Option Expr)
  | forHead (fuel : Nat) (h : Option ForHead)
  | switchCase (fuel : Nat) (c : Option Expr × List Stmt)
  | catchOpt (fuel : Nat) (c : Option (Option Pat × List Stmt))
  | item (i : Item)

def Task.denote : Task → List Nat → List Nat
  | .emit n, acc => n :: acc
  | .expr f e, acc => refsE f e acc
  | .elem f e, acc => refsEl f e acc
  | .key f k, acc => refsK f k acc
  | .prop f p, acc => refsP f p acc
  | .pat f p, acc => refsPat f p acc
  | .func f fn, acc => refsF f fn acc
  | .cls f c, acc => refsC f c acc
  | .member f m, acc => refsMem f m acc
  | .decls f ds, acc => refsDecls f ds acc
  | .stmt f s, acc => refsS f s acc
  | .exprOpt f e, acc => match e with | some e => refsE f e acc | none => acc
  | .patOpt f p, acc => match p with | some p => refsPat f p acc | none => acc
  | .stmtOpt f s, acc => match s with | some s => refsS f s acc | none => acc
  | .stmtsOpt f ss, acc => match ss with | some ss => ss.foldl (fun a s => refsS f s a) acc | none => acc
  | .patField f (k,p), acc => refsPat f p (refsK f k acc)
  | .field f (k,e), acc => match e with | some e => refsE f e (refsK f k acc) | none => refsK f k acc
  | .decl f (p,e), acc => match e with | some e => refsE f e (refsPat f p acc) | none => refsPat f p acc
  | .forHead f h, acc => match h with
    | some (.decl _ ds) => refsDecls f ds acc
    | some (.expr e) => refsE f e acc
    | none => acc
  | .switchCase f (e,ss), acc => ss.foldl (fun a s => refsS f s a)
      (match e with | some e => refsE f e acc | none => acc)
  | .catchOpt f h, acc => match h with
    | some (p,ss) => ss.foldl (fun a s => refsS f s a)
        (match p with | some p => refsPat f p acc | none => acc)
    | none => acc
  | .item it, acc => match it with
    | .stmt s => refsS refsFuel s acc
    | .export_ s => refsS refsFuel s acc
    | .exportDefault e => refsE refsFuel e acc
    | .exportNamed specs none => specs.foldl (fun a (l,_) => pack l :: a) acc
    | _ => acc

def Task.children : Task → List Task
  | .emit n => [.emit n]
  | .expr 0 _ | .elem 0 _ | .key 0 _ | .prop 0 _ | .pat 0 _ | .func 0 _
  | .cls 0 _ | .member 0 _ | .decls 0 _ | .stmt 0 _ => [.emit 0]
  | .expr (f+1) e => match e with
    | .lit _ | .this | .super => []
    | .id n => [.emit (pack n)]
    | .template t _ ss => .exprOpt f t :: ss.map (.expr f)
    | .array es => es.map (.elem f)
    | .object ps => ps.map (.prop f)
    | .func fn | .arrow fn => [.func f fn]
    | .cls c => [.cls f c]
    | .member o _ _ | .priv o _ _ => [.expr f o]
    | .index o k _ => [.expr f o, .expr f k]
    | .call c args _ | .new c args => .expr f c :: args.map (.elem f)
    | .chain x | .unary _ x | .update _ _ x | .await x => [.expr f x]
    | .bin _ a b | .log _ a b | .seq a b => [.expr f a, .expr f b]
    | .cond c a b => [.expr f c, .expr f a, .expr f b]
    | .assign _ p v => [.pat f p, .expr f v]
    | .yield e _ => [.exprOpt f e]
  | .elem (f+1) e => match e with
    | .hole => []
    | .expr e | .spread e => [.expr f e]
  | .key (f+1) k => match k with | .computed e => [.expr f e] | _ => []
  | .prop (f+1) p => match p with
    | .init k v => [.key f k, .expr f v]
    | .short n => [.emit (pack n)]
    | .method _ k fn => [.key f k, .func f fn]
    | .spread e => [.expr f e]
  | .pat (f+1) p => match p with
    | .id _ => []
    | .expr e => [.expr f e]
    | .array ps r => ps.map (.patOpt f) ++ [.patOpt f r]
    | .object ps r => ps.map (.patField f) ++ [.patOpt f r]
    | .dflt p e => [.pat f p, .expr f e]
  | .func (f+1) (.mk _ ps r b _ _ _) =>
    ps.map (.pat f) ++ [.patOpt f r] ++ match b with
      | .block ss => ss.map (.stmt f)
      | .expr e => [.expr f e]
  | .cls (f+1) (.mk _ sup ms) => .exprOpt f sup :: ms.map (.member f)
  | .member (f+1) m => match m with
    | .ctor fn => [.func f fn]
    | .method _ _ k fn => [.key f k, .func f fn]
    | .field _ k e => [.key f k, .exprOpt f e]
    | .block ss => ss.map (.stmt f)
  | .decls (f+1) ds => ds.map (.decl f)
  | .stmt (f+1) s => match s with
    | .expr e => [.expr f e]
    | .decl _ ds => [.decls f ds]
    | .func fn => [.func f fn]
    | .cls c => [.cls f c]
    | .enum _ _ ms => ms.map (.field f)
    | .ret e => [.exprOpt f e]
    | .if_ c t e => [.expr f c, .stmt f t, .stmtOpt f e]
    | .block ss => ss.map (.stmt f)
    | .for_ i t u b => [.forHead f i, .exprOpt f t, .exprOpt f u, .stmt f b]
    | .forOf _ _ p e b | .forIn _ p e b => [.pat f p, .expr f e, .stmt f b]
    | .while_ c b => [.expr f c, .stmt f b]
    | .doWhile b c => [.stmt f b, .expr f c]
    | .switch d cs => .expr f d :: cs.map (.switchCase f)
    | .try_ b h fin => b.map (.stmt f) ++ [.catchOpt f h, .stmtsOpt f fin]
    | .throw e => [.expr f e]
    | .break _ | .continue _ | .empty => []
    | .labeled _ s => [.stmt f s]
  | .exprOpt f e => match e with | some e => [.expr f e] | none => []
  | .patOpt f p => match p with | some p => [.pat f p] | none => []
  | .stmtOpt f s => match s with | some s => [.stmt f s] | none => []
  | .stmtsOpt f ss => match ss with | some ss => ss.map (.stmt f) | none => []
  | .patField f (k,p) => [.key f k, .pat f p]
  | .field f (k,e) => [.key f k, .exprOpt f e]
  | .decl f (p,e) => [.pat f p, .exprOpt f e]
  | .forHead f h => match h with
    | some (.decl _ ds) => [.decls f ds]
    | some (.expr e) => [.expr f e]
    | none => []
  | .switchCase f (e,ss) => .exprOpt f e :: ss.map (.stmt f)
  | .catchOpt f h => match h with
    | some (p,ss) => .patOpt f p :: ss.map (.stmt f)
    | none => []
  | .item it => match it with
    | .stmt s | .export_ s => [.stmt refsFuel s]
    | .exportDefault e => [.expr refsFuel e]
    | .exportNamed specs none => specs.map (fun (l,_) => .emit (pack l))
    | _ => []

theorem option_apply (o : Option α) (f : α → β → γ) (d : β → γ) (x : β) :
    (match o with | some a => f a | none => d) x =
      match o with | some a => f a x | none => d x := by cases o <;> rfl

macro "scan_simp" : tactic => `(tactic|
  simp only [Task.children, Task.denote, List.foldl_cons, List.foldl_nil,
    List.foldl_append, List.foldl_map, Function.comp_def, refsE, refsEl, refsK,
    refsP, refsPat, refsF, refsC, refsMem, refsDecls, refsS, option_apply, id_eq] <;> try rfl)

/-- Each expansion has exactly the original mutual scanner's meaning,
including duplicate references, traversal order and the exhaustion marker. -/
theorem Task.children_denote (t : Task) (acc : List Nat) :
    t.children.foldl (fun a t => t.denote a) acc = t.denote acc := by
  cases t with
  | emit n => rfl
  | expr f e => cases f with
    | zero => rfl
    | succ f => cases e <;> scan_simp
  | elem f e => cases f with
    | zero => rfl
    | succ f => cases e <;> scan_simp
  | key f k => cases f with
    | zero => rfl
    | succ f => cases k <;> scan_simp
  | prop f p => cases f with
    | zero => rfl
    | succ f => cases p <;> scan_simp
  | pat f p => cases f with
    | zero => rfl
    | succ f =>
      cases p <;> scan_simp
      · rename_i ps r; cases r <;> rfl
      · rename_i ps r; cases r <;> rfl
  | func f fn => cases f with
    | zero => rfl
    | succ f => cases fn with
      | mk name ps r b async gen arrow => cases b <;> scan_simp
  | cls f c => cases f with
    | zero => rfl
    | succ f => cases c <;> scan_simp
  | member f m => cases f with
    | zero => rfl
    | succ f =>
      cases m <;> scan_simp
      rename_i k e
      cases e <;> rfl
  | decls f ds =>
    cases f <;> scan_simp
    congr 1
    funext a p
    cases p.2 <;> rfl
  | stmt f s => cases f with
    | zero => rfl
    | succ f =>
      cases s <;> scan_simp
      · congr 1
        funext a p
        cases p.2 <;> rfl
      · rename_i c t e
        cases e <;> rfl
  | exprOpt f e => cases e <;> scan_simp
  | patOpt f p => cases p <;> scan_simp
  | stmtOpt f s => cases s <;> scan_simp
  | stmtsOpt f ss => cases ss <;> scan_simp
  | patField f p => cases p <;> scan_simp
  | field f p => rcases p with ⟨k,e⟩; cases e <;> scan_simp
  | decl f p => rcases p with ⟨p,e⟩; cases e <;> scan_simp
  | forHead f h => cases h with
    | none => rfl
    | some h => cases h <;> rfl
  | switchCase f c => cases c <;> scan_simp
  | catchOpt f c => cases c with
    | none => rfl
    | some c => cases c <;> scan_simp
  | item it =>
    cases it <;> scan_simp
    rename_i specs src
    cases src <;> scan_simp

structure State where
  todo : List Task
  acc : List Nat

def State.denote (s : State) : List Nat := s.todo.foldl (fun a t => t.denote a) s.acc

def step (s : State) : State := match s.todo with
  | [] => s
  | .emit n :: rest => ⟨rest, n :: s.acc⟩
  | t :: rest => ⟨t.children ++ rest, s.acc⟩

theorem step_denote (s : State) : (step s).denote = s.denote := by
  rcases s with ⟨todo,acc⟩
  cases todo with
  | nil => rfl
  | cons t rest =>
    cases t <;> first
      | rfl
      | (simp only [step, State.denote, List.foldl_append, List.foldl_cons]
         exact congrArg (fun a => rest.foldl (fun a t => t.denote a) a)
           (Task.children_denote _ acc))

def run : Nat → State → State
  | 0, s => s
  | n+1, s => run n (step s)

theorem run_denote (n : Nat) (s : State) : (run n s).denote = s.denote := by
  induction n generalizing s with
  | zero => rfl
  | succ n ih => exact (ih (step s)).trans (step_denote s)

theorem run_add (n m : Nat) (s : State) : run (n+m) s = run m (run n s) := by
  induction n generalizing s with
  | zero => simp only [Nat.zero_add, run]
  | succ n ih => simpa only [Nat.succ_add, run] using ih (step s)

def initial (m : Module) : State := ⟨m.map .item, []⟩

theorem initial_denote (m : Module) : (initial m).denote = refsM m := by
  simp only [initial, State.denote, List.foldl_map, Task.denote, refsM]
  rfl

theorem completed (m : Module) (n : Nat) (s : State)
    (hr : run n (initial m) = s) (hd : s.todo = []) : refsM m = s.acc := by
  have h := run_denote n (initial m)
  rw [hr, initial_denote] at h
  simpa only [State.denote, hd, List.foldl_nil] using h.symm

end Host.Ts.RefScan
