import host.ts.Run
namespace Host.Ts.Sim

/-! # Images of machine data under a cross-iteration map

A loop iteration of the decode route runs the same code on states that
differ in the resources allocated since the loop began (heap addresses,
native handles, regions and graph nodes) and in the values of loop-carried
numbers. `Map` sends a source (template) iteration's names to a target
iteration's names. Numbers are related by value: a source number reference
`ref i` (an entry of the template's symbolic table) is sent to the target's
number `num i`, whose concrete value is the entry evaluated at the target
iteration's valuation (`Rel`). Bigints are sent by one function `big`, so
equal source bigints have equal images. -/

structure Map where
  a : Nat → Nat
  num : Nat → NumV
  big : Int → Int
  region : Nat → Nat
  node : Nat → Nat

namespace Map
variable (R : Map)

/-- Native handles appear in the JS runtime as nonnegative bigints. -/
def handle (h : Nat) : Nat := (R.big (Int.ofNat h)).toNat

/-- Symbols past the well-known ones are addresses `+ 16` (`Symbol()` allocates a cell). -/
def sym (i : Nat) : Nat := bif Nat.blt i 16 then i else R.a (i - 16) + 16

def nv : NumV → NumV
  | .lit x => .lit x
  | .ref i => R.num i

def mem : Mem → Mem
  | .js b => .js (R.a b)
  | .ext r => .ext (R.region r)

def val : Val → Val
  | .num x => .num (R.nv x)
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
  | .num x => .num (R.nv x)
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
  | .num x => .num (R.nv x)
  | .big i => .big (R.big i)
  | .jsPtr b o bs => .jsPtr (R.a b) o (bs.map R.byte)
  | .extPtr r o => .extPtr (R.region r) o
  | .other v => .other (R.val v)
  | a => a

def ret : Ret → Ret
  | .num x => .num (R.nv x)
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

end Map

end Host.Ts.Sim
