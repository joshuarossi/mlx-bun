import host.ts.Loop
namespace Host.Ts

/-! # Renaming fresh resources

A loop's iterations run the same code on states that differ in the
resources allocated since the loop began: heap addresses (cells, objects,
private brands, created symbols), number-table entries, and the symbolic
values of loop-carried numbers. A *renaming* `R` maps the first kind of
names (`R.a` on addresses, `R.n` on number references) and a substitution
`θ` maps the symbolic variables of the number table.

`Renamed FR R tb tb' s s'`: `s'` holds a renamed copy of `s` — every heap
lookup below `s.next`, including an absent entry, corresponds at its renamed address,
and values in the source state refer only to allocated addresses. The renaming is injective on
`s`'s addresses, fixing the intrinsics, and continuing in order on fresh
addresses (so one `R` serves a whole run); control, stack, jobs and stores
renamed; FFI states related by `FR R`; and the events since the bases `tb`,
`tb'` renamed. Entries of `s'` that no address of `s` maps to are not
constrained (an iteration leaves garbage behind). `SrvR R θ S S'`: the
number tables correspond (`S'` holds `θ`-substituted entries at renamed
references, fresh references in order) and `S'`'s oracle answers `S`'s
queries substituted.

`StepSim F FR θ` states the remaining obligation for one complete machine step.
`runS_renamed` is conditional on that obligation; it does not establish it.
Native bigint handles and native regions have separate maps. Their use at ordinary
bigint arithmetic remains an additional obligation of the reachable-state relation. -/

structure Ren where
  a : Nat → Nat
  n : Nat → Nat
  big : Int → Int := id
  region : Nat → Nat := id
  node : Nat → Nat := id

namespace Ren
variable (R : Ren)

/-- Native handles appear in the JS runtime as nonnegative bigints. -/
def handle (h : Nat) : Nat := (R.big (Int.ofNat h)).toNat

/-- Symbols past the well-known ones are addresses `+ 16` (`Symbol()` allocates a cell). -/
def sym (i : Nat) : Nat := bif Nat.blt i 16 then i else R.a (i - 16) + 16

def num : NumV → NumV
  | .lit x => .lit x
  | .ref i => .ref (R.n i)

def mem : Mem → Mem
  | .js b => .js (R.a b)
  | .ext r => .ext (R.region r)

def val : Val → Val
  | .num x => .num (R.num x)
  | .big i => .big (R.big i)
  | .sym i => .sym (R.sym i)
  | .obj a => .obj (R.a a)
  | .ptr m off => .ptr (R.mem m) off
  | v => v

def key : PKey → PKey
  | .str s => .str s
  | .sym i => .sym (R.sym i)

def prop : PropV → PropV
  | .data v w e => .data (R.val v) w e
  | .acc g s e => .acc (R.val g) (R.val s) e

def props (ps : Props) : Props := ps.map fun (k, p) => (R.key k, R.prop p)

def vals (vs : List Val) : List Val := vs.map R.val

def cell : Cell → Cell
  | .num x => .num (R.num x)
  | .big i => .big (R.big i)

def byte : Byte → Byte
  | .lit b => .lit b
  | .part k c i => .part k (R.cell c) i

def abr : Abrupt → Abrupt
  | .throw v => .throw (R.val v)
  | .ret v => .ret (R.val v)
  | a => a

def comp : Comp → Comp
  | .normal v => .normal (R.val v)
  | .abrupt a => .abrupt (R.abr a)

def env (e : Env) : Env := e.map fun (n, c) => (n, R.a c)

def inst : InstMember → InstMember
  | .field k i => .field (R.key k) i
  | .privField b n i => .privField (R.a b) n i
  | .privMethod b n p => .privMethod (R.a b) n (R.prop p)

def bnd : Boundary → Boundary
  | .call => .call
  | .ctor t => .ctor (R.val t)
  | .derived c => .derived (R.a c)
  | .async p => .async (R.a p)
  | .gen g => .gen (R.a g)

def src : IterSrc → IterSrc
  | .index v i => .index (R.val v) i
  | .proto it nx => .proto (R.val it) (R.val nx)

def pairs (ps : List (Val × Val)) : List (Val × Val) := ps.map fun (x, y) => (R.val x, R.val y)

def callF : CallF → CallF
  | .callee as e o => .callee as (R.env e) o
  | .member k as e o c => .member (R.key k) as (R.env e) o c
  | .index k as e o c => .index k as (R.env e) o c
  | .indexK o as e c => .indexK (R.val o) as (R.env e) c
  | .priv b n as e o c => .priv (R.a b) n as (R.env e) o c
  | .method t as e c => .method (R.val t) as (R.env e) c
  | .args k f t acc r e => .args k (R.val f) (R.val t) (R.vals acc) r (R.env e)
  | .spread k f t acc r e => .spread k (R.val f) (R.val t) (R.vals acc) r (R.env e)
  | .newCallee as e => .newCallee as (R.env e)

def exprF : ExprF → ExprF
  | .unary op => .unary op
  | .binL op b e => .binL op b (R.env e)
  | .binR op a => .binR op (R.val a)
  | .logL op b e => .logL op b (R.env e)
  | .cond a b e => .cond a b (R.env e)
  | .seq b e => .seq b (R.env e)
  | .member k o => .member (R.key k) o
  | .indexL k e o => .indexL k (R.env e) o
  | .indexR o => .indexR (R.val o)
  | .priv b n o => .priv (R.a b) n o
  | .chain => .chain
  | .const v => .const (R.val v)
  | .typeof => .typeof

def litF : LitF → LitF
  | .array acc r e => .array (R.vals acc) r (R.env e)
  | .spread acc r e => .spread (R.vals acc) r (R.env e)
  | .object o r e => .object (R.a o) r (R.env e)
  | .objKey o p r e => .objKey (R.a o) p r (R.env e)
  | .objVal o k r e => .objVal (R.a o) (R.key k) r (R.env e)
  | .objSpread o r e => .objSpread (R.a o) r (R.env e)
  | .tmpl acc q s e => .tmpl acc q s (R.env e)
  | .tagged t q acc s e => .tagged (R.val t) q (R.vals acc) s (R.env e)

def target : Target → Target
  | .var n e => .var n (R.env e)
  | .prop o k => .prop (R.val o) (R.key k)
  | .priv o b n => .priv (R.val o) (R.a b) n

def asgF : AsgF → AsgF
  | .pat p e => .pat p (R.env e)
  | .obj op k ke v e => .obj op (k.map R.key) ke v (R.env e)
  | .key op o v e => .key op (R.val o) v (R.env e)
  | .privObj op b n v e => .privObj op (R.a b) n v (R.env e)
  | .old op t v e => .old op (R.target t) v (R.env e)
  | .put op t o => .put op (R.target t) (R.val o)
  | .updObj i p k ke e => .updObj i p (k.map R.key) ke (R.env e)
  | .updKey i p o => .updKey i p (R.val o)
  | .updPrivObj i p b n => .updPrivObj i p (R.a b) n
  | .updOld i p t => .updOld i p (R.target t)

def stmtF : StmtF → StmtF
  | .block r e => .block r (R.env e)
  | .scope res => .scope (R.pairs res)
  | .dispose r c => .dispose (R.pairs r) (R.comp c)
  | .if_ t el e => .if_ t el (R.env e)
  | .decl k p r e => .decl k p r (R.env e)
  | .declNext k r e => .declNext k r (R.env e)
  | .ret => .ret
  | .throw => .throw
  | .try_ h f e => .try_ h f (R.env e)
  | .catch_ f e => .catch_ f (R.env e)
  | .finally_ c => .finally_ (R.comp c)
  | .label l => .label l
  | .switchD cs e => .switchD cs (R.env e)
  | .switchCase d r a e => .switchCase (R.val d) r a (R.env e)
  | .switchBody => .switchBody

def loopF : LoopF → LoopF
  | .forTest c t u b e ns ls => .forTest c t u b (R.env e) ns ls
  | .forBody t u b e ns ls => .forBody t u b (R.env e) ns ls
  | .forUpd t u b e ns ls => .forUpd t u b (R.env e) ns ls
  | .whileTest c b e ls => .whileTest c b (R.env e) ls
  | .whileBody c b e ls => .whileBody c b (R.env e) ls
  | .doBody b c e ls => .doBody b c (R.env e) ls
  | .forOfSrc a k p b e ls => .forOfSrc a k p b (R.env e) ls
  | .forOfIt a k p b e ls => .forOfIt a k p b (R.env e) ls
  | .forOfNext it nx a k p b e ls => .forOfNext (R.val it) (R.val nx) a k p b (R.env e) ls
  | .forOfBody s a k p b e ls => .forOfBody (R.src s) a k p b (R.env e) ls
  | .close c => .close (R.comp c)

def bindF : BindF → BindF
  | .dflt p e m k => .dflt p (R.env e) m k
  | .arr ps r vs e m k => .arr ps r (R.vals vs) (R.env e) m k
  | .arrSrc ps r e m k => .arrSrc ps r (R.env e) m k
  | .obj s ps r u e m k => .obj (R.val s) ps r (u.map R.key) (R.env e) m k
  | .objKey s p ps r u e m k => .objKey (R.val s) p ps r (u.map R.key) (R.env e) m k
  | .objVal s k' p ps r u e m k => .objVal (R.val s) (R.key k') p ps r (u.map R.key) (R.env e) m k
  | .collect acc it nx => .collect (R.vals acc) (R.val it) (R.val nx)
  | .collectIt acc => .collectIt (R.vals acc)

def fnF : FnF → FnF
  | .fn b => .fn (R.bnd b)
  | .params f ps as e => .params f ps (R.vals as) (R.env e)
  | .paramDflt f p ps as e => .paramDflt f p ps (R.vals as) (R.env e)
  | .classHeritage c e => .classHeritage c (R.env e)
  | .classMembers f p ms is e => .classMembers (R.a f) (R.a p) ms (is.map R.inst) (R.env e)
  | .classKey f p m ms is e => .classKey (R.a f) (R.a p) m ms (is.map R.inst) (R.env e)
  | .classStatic f p k ms is e => .classStatic (R.a f) (R.a p) (R.key k) ms (is.map R.inst) (R.env e)
  | .fields o ms e => .fields (R.a o) (ms.map R.inst) (R.env e)
  | .fieldVal o k ms e => .fieldVal (R.a o) (R.key k) (ms.map R.inst) (R.env e)
  | .privVal o b n ms e => .privVal (R.a o) (R.a b) n (ms.map R.inst) (R.env e)
  | .ctorBody o f e as => .ctorBody (R.val o) f (R.env e) (R.vals as)
  | .superRet c k e => .superRet (R.a c) (R.a k) (R.env e)
  | .paramProps o ns e => .paramProps (R.val o) ns (R.env e)
  | .native n d => .native n (R.vals d)
  | .promiseThen p => .promiseThen (R.a p)
  | .yield d => .yield d
  | .ystarIt => .ystarIt
  | .ystarNext it nx => .ystarNext (R.val it) (R.val nx)
  | .ystarResume it nx => .ystarResume (R.val it) (R.val nx)
  | .ystarAIt => .ystarAIt
  | .ystarAResult it nx => .ystarAResult (R.val it) (R.val nx)
  | .ystarAResume it nx => .ystarAResume (R.val it) (R.val nx)
  | .ystarAReturned it nx => .ystarAReturned (R.val it) (R.val nx)
  | .ystarAReturn => .ystarAReturn
  | .await => .await
  | .modules r => .modules (r.map fun (ss, e) => (ss, R.env e))

def frame : Frame → Frame
  | .e f => .e (R.exprF f)
  | .c f => .c (R.callF f)
  | .l f => .l (R.litF f)
  | .a f => .a (R.asgF f)
  | .s f => .s (R.stmtF f)
  | .lp f => .lp (R.loopF f)
  | .b f => .b (R.bindF f)
  | .k f => .k (R.fnF f)

def ctl : Ctl → Ctl
  | .ev e en => .ev e (R.env en)
  | .ex s en => .ex s (R.env en)
  | .ret v => .ret (R.val v)
  | .abr a => .abr (R.abr a)
  | .call f t as => .call (R.val f) (R.val t) (R.vals as)
  | .construct f as nt => .construct (R.val f) (R.vals as) (R.val nt)
  | .bind p v e m k => .bind p (R.val v) (R.env e) m k
  | .short => .short
  | .halt c => .halt (R.comp c)

def stores (ss : List (Nat × Val)) : List (Nat × Val) := ss.map fun (i, v) => (R.a i, R.val v)

def susp (u : Susp) : Susp := ⟨u.frames.map R.frame, R.stores u.stores⟩

def gen : GenState → GenState
  | .start b e => .start b (R.env e)
  | .suspended u => .suspended (R.susp u)
  | .running => .running
  | .done => .done

def reaction : Reaction → Reaction
  | .resume u => .resume (R.susp u)
  | .then_ f r d ss => .then_ (R.val f) (R.val r) (R.a d) (R.stores ss)
  | .adopt p => .adopt (R.a p)
  | .forward p => .forward (R.a p)

def pstate : PState → PState
  | .pending rs => .pending (rs.map R.reaction)
  | .fulfilled v => .fulfilled (R.val v)
  | .rejected v => .rejected (R.val v)

def code : Code → Code
  | .closure f e ar h => .closure f (R.env e) ar (R.val h)
  | .klass c e p is => .klass c (R.env e) (R.val p) (is.map R.inst)
  | .native n d => .native n (R.vals d)
  | .bound t th as => .bound (R.val t) (R.val th) (R.vals as)

def kind : Kind → Kind
  | .ordinary => .ordinary
  | .array es => .array (R.vals es)
  | .fn c => .fn (R.code c)
  | .buf bs => .buf (bs.map R.byte)
  | .extBuf r o l => .extBuf (R.region r) o l
  | .typed k b o l => .typed k (R.a b) o l
  | .view b o l => .view (R.a b) o l
  | .map m => .map (R.pairs m)
  | .set m => .set (R.vals m)
  | .promise p => .promise (R.pstate p)
  | .gen g a q => .gen (R.gen g) a (q.map fun (p, c) => (R.a p, R.comp c))
  | .ns ex => .ns (ex.map fun (n, c) => (n, R.a c))
  | .box v => .box (R.val v)
  | .iter s i m => .iter (R.val s) i m

def obj (o : Obj) : Obj :=
  ⟨R.kind o.kind, R.val o.proto, R.props o.props, o.priv.map (fun ((b, n), p) => ((R.a b, n), R.prop p)), o.extensible⟩

def hobj : HObj → HObj
  | .cell v => .cell (v.map R.val)
  | .obj o => .obj (R.obj o)

def arg : Arg → Arg
  | .num x => .num (R.num x)
  | .big i => .big (R.big i)
  | .jsPtr b o bs => .jsPtr (R.a b) o (bs.map R.byte)
  | .extPtr r o => .extPtr (R.region r) o
  | .other v => .other (R.val v)
  | a => a

def ret : Ret → Ret
  | .num x => .num (R.num x)
  | .big i => .big (R.big i)
  | .ptr r o => .ptr (R.region r) o
  | .callback f as => .callback (R.region f) (as.map R.arg)
  | r => r

def event (e : Event) : Event := ⟨e.sym, e.args.map R.arg, R.ret e.ret⟩

def job (j : Job) : Job := ⟨R.reaction j.r, j.throw, R.val j.v⟩

def write : Nat × Nat × List Byte → Nat × Nat × List Byte
  | (b, off, bs) => (R.a b, off, bs.map R.byte)

theorem cellParts (k : EltK) (c : Cell) : ∀ n i,
    (Host.Ts.cellParts k c n i).map R.byte = Host.Ts.cellParts k (R.cell c) n i
  | 0, _ => rfl
  | n + 1, i => by
    simp only [Host.Ts.cellParts, List.map_cons, byte, cellParts k c n (i + 1)]

end Ren

/-! ## Related states and servers -/

/-- A traversal has address support below `b`: changing a renaming outside the allocated
address range cannot change its result. The number-reference map is held fixed. -/
def AddrSupported {α : Type} (b : Nat) (f : Ren → α) : Prop :=
  ∀ R Q, (∀ a, a < b → R.a a = Q.a a) →
    (R.n = Q.n ∧ R.big = Q.big ∧ R.region = Q.region) → f R = f Q

/-- All JS addresses in the live machine data are allocated. This is separate from heap
lookup correspondence: the latter alone cannot rule out dangling values in control frames. -/
structure AddrClosed {S : Type} (s : St S) : Prop where
  heap : ∀ a h, s.heap.get a = some h → AddrSupported s.next (fun R => R.hobj h)
  ctl : AddrSupported s.next (fun R => R.ctl s.ctl)
  stack : AddrSupported s.next (fun R => s.stack.map R.frame)
  jobs : AddrSupported s.next (fun R => s.aux.jobs.map R.job)
  stores : AddrSupported s.next (fun R => R.stores s.aux.stores)

section
variable {S : Type}

/-- `s'` holds a renamed copy of `s` (see the module comment); `tb`, `tb'` are the traces at the
loop head, from which the events are compared. -/
structure Renamed (FR : Ren → S → S → Prop) (R : Ren) (tb tb' : List Event) (s s' : St S) : Prop where
  heap : ∀ a, a < s.next → s'.heap.get (R.a a) = (s.heap.get a).map R.hobj
  closed : AddrClosed s
  intrinsicBound : aFirst ≤ s.next
  bound : ∀ a, a < s.next → R.a a < s'.next
  inj : ∀ a b, a < s.next → b < s.next → R.a a = R.a b → a = b
  intr : ∀ a, a < aFirst → R.a a = a
  fresh : ∀ k, R.a (s.next + k) = s'.next + k
  ctl : s'.ctl = R.ctl s.ctl
  stack : s'.stack = s.stack.map R.frame
  jobs : s'.aux.jobs = s.aux.jobs.map R.job
  stores : s'.aux.stores = R.stores s.aux.stores
  ffi : FR R s.aux.ffi s'.aux.ffi
  trace : ∃ new, s.aux.trace = new ++ tb ∧ s'.aux.trace = new.map R.event ++ tb'

end

def SymE.subst (θ : Nat → SymE) : SymE → SymE
  | .lit x => .lit x
  | .var i => θ i
  | .bin op a b => .bin op (a.subst θ) (b.subst θ)
  | .un op a => .un op (a.subst θ)

def Ans.subst (θ : Nat → SymE) (q : Ans) : Ans := ⟨q.op, q.a.subst θ, q.b.subst θ, q.r⟩

/-- Substitution is genuine expression substitution at every concrete valuation. -/
theorem SymE.eval_subst (θ : Nat → SymE) (ρ : Nat → F64) (e : SymE) :
    (e.subst θ).eval ρ = e.eval (fun i => (θ i).eval ρ) := by
  induction e with
  | lit _ => rfl
  | var _ => rfl
  | bin op a b ha hb => simp only [subst, eval, ha, hb]
  | un op a ha => simp only [subst, eval, ha]

/-- Oracle correctness after a loop-counter substitution is exactly correctness at the
induced valuation of the template's variables. -/
theorem good_subst (θ : Nat → SymE) (ρ : Nat → F64) (o : List Ans) :
    Good ρ (o.map (Ans.subst θ)) ↔ Good (fun i => (θ i).eval ρ) o := by
  constructor
  · intro h q hq
    have ht := h (q.subst θ) (List.mem_map.mpr ⟨q, hq, rfl⟩)
    simpa only [Ans.subst, SymE.eval_subst] using ht
  · intro h q hq
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hq
    simpa only [Ans.subst, SymE.eval_subst] using h p hp

/-- The servers correspond under `R` and `θ`, and `S'` has `S`'s pending answers substituted
(followed by any others). -/
structure SrvR (R : Ren) (θ : Nat → SymE) (S S' : SSrv) : Prop where
  tab : ∀ i e, nth? S.tab i = some e → nth? S'.tab (R.n i) = some (e.subst θ)
  inj : Function.Injective R.n
  fresh : ∀ k, R.n (S.tab.length + k) = S'.tab.length + k
  oracle : ∃ r, S'.oracle = S.oracle.map (Ans.subst θ) ++ r

theorem nth?_append_keep {α : Type} (ys : List α) :
    ∀ (xs : List α) (i : Nat) (x : α), nth? xs i = some x → nth? (xs ++ ys) i = some x
  | [], _, _, h => by cases h
  | _ :: _, 0, _, h => h
  | _ :: xs, i + 1, x, h => nth?_append_keep ys xs i x h

theorem nth?_append_length {α : Type} (xs : List α) (x : α) :
    nth? (xs ++ [x]) xs.length = some x := by
  induction xs with
  | nil => rfl
  | cons _ _ ih => exact ih

theorem nth?_append_one {α : Type} : ∀ (xs : List α) (x y : α) (i : Nat),
    nth? (xs ++ [x]) i = some y → nth? xs i = some y ∨ (i = xs.length ∧ x = y)
  | [], x, y, 0, h => by
    simp only [List.nil_append, nth?, Option.some.injEq] at h
    exact .inr ⟨rfl, h⟩
  | [], _, _, _ + 1, h => by cases h
  | z :: xs, x, y, 0, h => .inl h
  | z :: xs, x, y, i + 1, h => by
    rcases nth?_append_one xs x y i h with h | ⟨hi, he⟩
    · exact .inl h
    · exact .inr ⟨congrArg Nat.succ hi, he⟩

namespace SrvR

/-- A numeric reference reads the substituted expression at its renamed index. -/
theorem val {R : Ren} {θ : Nat → SymE} {S S' : SSrv} (h : SrvR R θ S S')
    {v : NumV} {e : SymE} (hv : S.val v = some e) :
    S'.val (R.num v) = some (e.subst θ) := by
  cases v with
  | lit f =>
    simp only [SSrv.val, Option.some.injEq] at hv
    subst e
    rfl
  | ref i => exact h.tab i e hv

/-- Allocating a result reference commutes with the same fresh renaming. -/
theorem push {R : Ren} {θ : Nat → SymE} {S S' : SSrv} (h : SrvR R θ S S') (e : SymE) :
    SrvR R θ { S with tab := S.tab ++ [e] } { S' with tab := S'.tab ++ [e.subst θ] } := by
  refine ⟨?_, h.inj, ?_, h.oracle⟩
  · intro i x hx
    rcases nth?_append_one S.tab e x i hx with hx | ⟨rfl, rfl⟩
    · exact nth?_append_keep [e.subst θ] S'.tab (R.n i) _ (h.tab i x hx)
    · have h0 : R.n S.tab.length = S'.tab.length := by simpa using h.fresh 0
      rw [h0]
      exact nth?_append_length S'.tab (e.subst θ)
  · intro k
    simpa only [List.length_append, List.length_cons, List.length_nil, Nat.add_zero, Nat.zero_add,
      Nat.add_assoc] using h.fresh (1 + k)

/-- Consuming a matching oracle query commutes with substitution; target answers after
the source oracle are left untouched. -/
theorem answer {R : Ren} {θ : Nat → SymE} {S S' T : SSrv} (h : SrvR R θ S S')
    {op : NTest} {x y : SymE} {b : Bool} (ha : S.answer op x y = some (b, T)) :
    ∃ T', S'.answer op (x.subst θ) (y.subst θ) = some (b, T') ∧ SrvR R θ T T' := by
  unfold SSrv.answer at ha
  cases ho : S.oracle with
  | nil => simp [ho] at ha
  | cons q qs =>
    by_cases hq : q.op = op ∧ q.a = x ∧ q.b = y
    · simp only [ho, hq, and_self, decide_true, Bool.cond_true,
        Option.some.injEq, Prod.mk.injEq] at ha
      obtain ⟨rfl, rfl⟩ := ha
      obtain ⟨r, hr⟩ := h.oracle
      refine ⟨{ S' with oracle := qs.map (Ans.subst θ) ++ r }, ?_, h.tab, h.inj, h.fresh, r, rfl⟩
      simp only [SSrv.answer, hr, ho, List.map_cons, List.cons_append, Ans.subst,
        hq.1, hq.2.1, hq.2.2, and_self, decide_true, Bool.cond_true]
    · simp [ho, hq] at ha

end SrvR

/-- **The renaming lemma** (one step), for an FFI whose states relate by `FR`: from related
states and servers, a step that succeeds on the template succeeds on the renamed copy, and the
results are related again (same `R`: fresh resources continue in order). -/
def StepSim (F : Ffi) (FR : Ren → F.S → F.S → Prop) (θ : Nat → SymE) : Prop :=
  ∀ (R : Ren) (tb tb' : List Event) (s s' : St F.S) (S S' : SSrv) (t : St F.S) (T : SSrv),
    Renamed FR R tb tb' s s' → SrvR R θ S S' → isHalt s.ctl = false →
    interpS (step F s).run S = some (t, T) →
    ∃ t' T', interpS (step F s').run S' = some (t', T') ∧ Renamed FR R tb tb' t t' ∧ SrvR R θ T T'

/-! ## Runs -/

theorem isHalt_ren (R : Ren) (c : Ctl) : isHalt (R.ctl c) = isHalt c := by
  cases c <;> rfl

/-- Runs of related states stay related. -/
theorem runS_renamed (F : Ffi) (FR : Ren → F.S → F.S → Prop) (θ : Nat → SymE) (h : StepSim F FR θ) :
    ∀ (n : Nat) (R : Ren) (tb tb' : List Event) (s s' : St F.S) (S S' : SSrv) (t : St F.S) (T : SSrv),
    Renamed FR R tb tb' s s' → SrvR R θ S S' → runS F n s S = some (t, T) →
    ∃ t' T', runS F n s' S' = some (t', T') ∧ Renamed FR R tb tb' t t' ∧ SrvR R θ T T' := by
  intro n
  induction n with
  | zero =>
    intro R tb tb' s s' S S' t T hr hS hrun
    simp only [runS, runWith_zero, Option.some.injEq, Prod.mk.injEq] at hrun
    obtain ⟨rfl, rfl⟩ := hrun
    exact ⟨s', S', rfl, hr, hS⟩
  | succ n ih =>
    intro R tb tb' s s' S S' t T hr hS hrun
    have hc : isHalt s'.ctl = isHalt s.ctl := by rw [hr.ctl, isHalt_ren]
    cases hh : isHalt s.ctl
    · simp only [runS, runWith_succ, hh, Bool.cond_false] at hrun
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at hrun
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs, St.rebuild_eq] at hrun
        obtain ⟨s1', S1', h1, hr1, hS1⟩ := h R tb tb' s s' S S' s1 S1 hr hS hh hs
        obtain ⟨t', T', h2, hr2, hS2⟩ := ih R tb tb' s1 s1' S1 S1' t T hr1 hS1 hrun
        refine ⟨t', T', ?_, hr2, hS2⟩
        simp only [runS, runWith_succ, hc, hh, Bool.cond_false, h1, St.rebuild_eq]
        exact h2
    · simp only [runS, runWith_succ, hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at hrun
      obtain ⟨rfl, rfl⟩ := hrun
      refine ⟨s', S', ?_, hr, hS⟩
      simp [runS, runWith_succ, hc, hh]

end Host.Ts
