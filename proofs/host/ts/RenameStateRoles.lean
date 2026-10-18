import host.ts.RenameOwnedBuffer
namespace Host.Ts.Owned

/-- Runtime structure with occurrence-specific value leaves. Source syntax,
flags and literal indices are exact; resource leaves carry their own maps. -/
inductive Tree : Type 1 where
  | atom (α : Type) (x : α)
  | value (v : Val)
  | cell (c : Cell)
  | byte (b : Byte)
  | address (a : Nat)
  | symbol (a : Nat)
  | region (a : Nat)
  | number (n : NumV)
  | node (tag : String) (fields : List Tree)

mutual
  inductive TreeR (R : Ren) : Tree → Tree → Prop where
    | atom (α : Type) (x : α) : TreeR R (.atom α x) (.atom α x)
    | value {v v' : Val} : ValueR R v v' → TreeR R (.value v) (.value v')
    | cell {c c' : Cell} : CellR R c c' → TreeR R (.cell c) (.cell c')
    | byte {b b' : Byte} : ByteR R b b' → TreeR R (.byte b) (.byte b')
    | address (a : Nat) : TreeR R (.address a) (.address (R.a a))
    | symbol (a : Nat) : TreeR R (.symbol a) (.symbol (R.sym a))
    | region (a : Nat) : TreeR R (.region a) (.region (R.region a))
    | number (n : NumV) : TreeR R (.number n) (.number (R.num n))
    | node (tag : String) {xs ys : List Tree} : ForestR R xs ys →
        TreeR R (.node tag xs) (.node tag ys)
  inductive ForestR (R : Ren) : List Tree → List Tree → Prop where
    | nil : ForestR R [] []
    | cons {x y : Tree} {xs ys : List Tree} : TreeR R x y → ForestR R xs ys →
        ForestR R (x :: xs) (y :: ys)
end

namespace Encode

def atom {α : Type} (x : α) : Tree := .atom α x
def seq (xs : List Tree) : Tree := .node "List" xs
def opt : Option Tree → Tree
  | none => .node "Option.none" []
  | some t => .node "Option.some" [t]
def val : Val → Tree := .value
def cell : Cell → Tree := .cell
def byte : Byte → Tree := .byte
def num : NumV → Tree := .number
def vals (xs : List Val) : Tree := seq (xs.map val)
def key : PKey → Tree
  | .str s => .node "PKey.str" [atom s]
  | .sym s => .node "PKey.sym" [.symbol s]
def prop : PropV → Tree
  | .data v w e => .node "PropV.data" [val v, atom w, atom e]
  | .acc g s e => .node "PropV.acc" [val g, val s, atom e]
def props (ps : Props) : Tree := seq (ps.map fun (k,p) => .node "prop" [key k, prop p])
def abr : Abrupt → Tree
  | .throw v => .node "Abrupt.throw" [val v]
  | .ret v => .node "Abrupt.ret" [val v]
  | .brk l => .node "Abrupt.brk" [atom l]
  | .cont l => .node "Abrupt.cont" [atom l]
def comp : Comp → Tree
  | .normal v => .node "Comp.normal" [val v]
  | .abrupt a => .node "Comp.abrupt" [abr a]
def env (e : Env) : Tree := seq (e.map fun (n,a) => .node "binding" [atom n, .address a])
def pairs (ps : List (Val × Val)) : Tree := seq (ps.map fun (a,b) => .node "pair" [val a,val b])
def inst : InstMember → Tree
  | .field k i => .node "InstMember.field" [(key k), (atom i)]
  | .privField b n i => .node "InstMember.privField" [(Tree.address b), (atom n), (atom i)]
  | .privMethod b n p => .node "InstMember.privMethod" [(Tree.address b), (atom n), (prop p)]

def bnd : Boundary → Tree
  | .call => .node "Boundary.call" []
  | .ctor t => .node "Boundary.ctor" [(val t)]
  | .derived c => .node "Boundary.derived" [(Tree.address c)]
  | .async p => .node "Boundary.async" [(Tree.address p)]
  | .gen g => .node "Boundary.gen" [(Tree.address g)]

def src : IterSrc → Tree
  | .index v i => .node "IterSrc.index" [(val v), (atom i)]
  | .proto it nx => .node "IterSrc.proto" [(val it), (val nx)]

def callF : CallF → Tree
  | .callee as e o => .node "CallF.callee" [(atom as), (env e), (atom o)]
  | .member k as e o c => .node "CallF.member" [(key k), (atom as), (env e), (atom o), (atom c)]
  | .index k as e o c => .node "CallF.index" [(atom k), (atom as), (env e), (atom o), (atom c)]
  | .indexK o as e c => .node "CallF.indexK" [(val o), (atom as), (env e), (atom c)]
  | .priv b n as e o c => .node "CallF.priv" [(Tree.address b), (atom n), (atom as), (env e), (atom o), (atom c)]
  | .method t as e c => .node "CallF.method" [(val t), (atom as), (env e), (atom c)]
  | .args k f t acc r e => .node "CallF.args" [(atom k), (val f), (val t), (vals acc), (atom r), (env e)]
  | .spread k f t acc r e => .node "CallF.spread" [(atom k), (val f), (val t), (vals acc), (atom r), (env e)]
  | .newCallee as e => .node "CallF.newCallee" [(atom as), (env e)]

def exprF : ExprF → Tree
  | .unary op => .node "ExprF.unary" [(atom op)]
  | .binL op b e => .node "ExprF.binL" [(atom op), (atom b), (env e)]
  | .binR op a => .node "ExprF.binR" [(atom op), (val a)]
  | .logL op b e => .node "ExprF.logL" [(atom op), (atom b), (env e)]
  | .cond a b e => .node "ExprF.cond" [(atom a), (atom b), (env e)]
  | .seq b e => .node "ExprF.seq" [(atom b), (env e)]
  | .member k o => .node "ExprF.member" [(key k), (atom o)]
  | .indexL k e o => .node "ExprF.indexL" [(atom k), (env e), (atom o)]
  | .indexR o => .node "ExprF.indexR" [(val o)]
  | .priv b n o => .node "ExprF.priv" [(Tree.address b), (atom n), (atom o)]
  | .chain => .node "ExprF.chain" []
  | .const v => .node "ExprF.const" [(val v)]
  | .typeof => .node "ExprF.typeof" []

def litF : LitF → Tree
  | .array acc r e => .node "LitF.array" [(vals acc), (atom r), (env e)]
  | .spread acc r e => .node "LitF.spread" [(vals acc), (atom r), (env e)]
  | .object o r e => .node "LitF.object" [(Tree.address o), (atom r), (env e)]
  | .objKey o p r e => .node "LitF.objKey" [(Tree.address o), (atom p), (atom r), (env e)]
  | .objVal o k r e => .node "LitF.objVal" [(Tree.address o), (key k), (atom r), (env e)]
  | .objSpread o r e => .node "LitF.objSpread" [(Tree.address o), (atom r), (env e)]
  | .tmpl acc q s e => .node "LitF.tmpl" [(atom acc), (atom q), (atom s), (env e)]
  | .tagged t q acc s e => .node "LitF.tagged" [(val t), (atom q), (vals acc), (atom s), (env e)]

def target : Target → Tree
  | .var n e => .node "Target.var" [(atom n), (env e)]
  | .prop o k => .node "Target.prop" [(val o), (key k)]
  | .priv o b n => .node "Target.priv" [(val o), (Tree.address b), (atom n)]

def asgF : AsgF → Tree
  | .pat p e => .node "AsgF.pat" [(atom p), (env e)]
  | .obj op k ke v e => .node "AsgF.obj" [(atom op), (opt (k.map key)), (atom ke), (atom v), (env e)]
  | .key op o v e => .node "AsgF.key" [(atom op), (val o), (atom v), (env e)]
  | .privObj op b n v e => .node "AsgF.privObj" [(atom op), (Tree.address b), (atom n), (atom v), (env e)]
  | .old op t v e => .node "AsgF.old" [(atom op), (target t), (atom v), (env e)]
  | .put op t o => .node "AsgF.put" [(atom op), (target t), (val o)]
  | .updObj i p k ke e => .node "AsgF.updObj" [(atom i), (atom p), (opt (k.map key)), (atom ke), (env e)]
  | .updKey i p o => .node "AsgF.updKey" [(atom i), (atom p), (val o)]
  | .updPrivObj i p b n => .node "AsgF.updPrivObj" [(atom i), (atom p), (Tree.address b), (atom n)]
  | .updOld i p t => .node "AsgF.updOld" [(atom i), (atom p), (target t)]

def stmtF : StmtF → Tree
  | .block r e => .node "StmtF.block" [(atom r), (env e)]
  | .scope res => .node "StmtF.scope" [(pairs res)]
  | .dispose r c => .node "StmtF.dispose" [(pairs r), (comp c)]
  | .if_ t el e => .node "StmtF.if_" [(atom t), (atom el), (env e)]
  | .decl k p r e => .node "StmtF.decl" [(atom k), (atom p), (atom r), (env e)]
  | .declNext k r e => .node "StmtF.declNext" [(atom k), (atom r), (env e)]
  | .ret => .node "StmtF.ret" []
  | .throw => .node "StmtF.throw" []
  | .try_ h f e => .node "StmtF.try_" [(atom h), (atom f), (env e)]
  | .catch_ f e => .node "StmtF.catch_" [(atom f), (env e)]
  | .finally_ c => .node "StmtF.finally_" [(comp c)]
  | .label l => .node "StmtF.label" [(atom l)]
  | .switchD cs e => .node "StmtF.switchD" [(atom cs), (env e)]
  | .switchCase d r a e => .node "StmtF.switchCase" [(val d), (atom r), (atom a), (env e)]
  | .switchBody => .node "StmtF.switchBody" []

def loopF : LoopF → Tree
  | .forTest c t u b e ns ls => .node "LoopF.forTest" [(atom c), (atom t), (atom u), (atom b), (env e), (atom ns), (atom ls)]
  | .forBody t u b e ns ls => .node "LoopF.forBody" [(atom t), (atom u), (atom b), (env e), (atom ns), (atom ls)]
  | .forUpd t u b e ns ls => .node "LoopF.forUpd" [(atom t), (atom u), (atom b), (env e), (atom ns), (atom ls)]
  | .whileTest c b e ls => .node "LoopF.whileTest" [(atom c), (atom b), (env e), (atom ls)]
  | .whileBody c b e ls => .node "LoopF.whileBody" [(atom c), (atom b), (env e), (atom ls)]
  | .doBody b c e ls => .node "LoopF.doBody" [(atom b), (atom c), (env e), (atom ls)]
  | .forOfSrc a k p b e ls => .node "LoopF.forOfSrc" [(atom a), (atom k), (atom p), (atom b), (env e), (atom ls)]
  | .forOfIt a k p b e ls => .node "LoopF.forOfIt" [(atom a), (atom k), (atom p), (atom b), (env e), (atom ls)]
  | .forOfNext it nx a k p b e ls => .node "LoopF.forOfNext" [(val it), (val nx), (atom a), (atom k), (atom p), (atom b), (env e), (atom ls)]
  | .forOfBody s a k p b e ls => .node "LoopF.forOfBody" [(src s), (atom a), (atom k), (atom p), (atom b), (env e), (atom ls)]
  | .close c => .node "LoopF.close" [(comp c)]

def bindF : BindF → Tree
  | .dflt p e m k => .node "BindF.dflt" [(atom p), (env e), (atom m), (atom k)]
  | .arr ps r vs e m k => .node "BindF.arr" [(atom ps), (atom r), (vals vs), (env e), (atom m), (atom k)]
  | .arrSrc ps r e m k => .node "BindF.arrSrc" [(atom ps), (atom r), (env e), (atom m), (atom k)]
  | .obj s ps r u e m k => .node "BindF.obj" [(val s), (atom ps), (atom r), (seq (u.map key)), (env e), (atom m), (atom k)]
  | .objKey s p ps r u e m k => .node "BindF.objKey" [(val s), (atom p), (atom ps), (atom r), (seq (u.map key)), (env e), (atom m), (atom k)]
  | .objVal s k' p ps r u e m k => .node "BindF.objVal" [(val s), (key k'), (atom p), (atom ps), (atom r), (seq (u.map key)), (env e), (atom m), (atom k)]
  | .collect acc it nx => .node "BindF.collect" [(vals acc), (val it), (val nx)]
  | .collectIt acc => .node "BindF.collectIt" [(vals acc)]

def fnF : FnF → Tree
  | .fn b => .node "FnF.fn" [(bnd b)]
  | .params f ps as e => .node "FnF.params" [(atom f), (atom ps), (vals as), (env e)]
  | .paramDflt f p ps as e => .node "FnF.paramDflt" [(atom f), (atom p), (atom ps), (vals as), (env e)]
  | .classHeritage c e => .node "FnF.classHeritage" [(atom c), (env e)]
  | .classMembers f p ms is e => .node "FnF.classMembers" [(Tree.address f), (Tree.address p), (atom ms), (seq (is.map inst)), (env e)]
  | .classKey f p m ms is e => .node "FnF.classKey" [(Tree.address f), (Tree.address p), (atom m), (atom ms), (seq (is.map inst)), (env e)]
  | .classStatic f p k ms is e => .node "FnF.classStatic" [(Tree.address f), (Tree.address p), (key k), (atom ms), (seq (is.map inst)), (env e)]
  | .fields o ms e => .node "FnF.fields" [(Tree.address o), (seq (ms.map inst)), (env e)]
  | .fieldVal o k ms e => .node "FnF.fieldVal" [(Tree.address o), (key k), (seq (ms.map inst)), (env e)]
  | .privVal o b n ms e => .node "FnF.privVal" [(Tree.address o), (Tree.address b), (atom n), (seq (ms.map inst)), (env e)]
  | .ctorBody o f e as => .node "FnF.ctorBody" [(val o), (atom f), (env e), (vals as)]
  | .superRet c k e => .node "FnF.superRet" [(Tree.address c), (Tree.address k), (env e)]
  | .paramProps o ns e => .node "FnF.paramProps" [(val o), (atom ns), (env e)]
  | .native n d => .node "FnF.native" [(atom n), (vals d)]
  | .promiseThen p => .node "FnF.promiseThen" [(Tree.address p)]
  | .yield d => .node "FnF.yield" [(atom d)]
  | .ystarIt => .node "FnF.ystarIt" []
  | .ystarNext it nx => .node "FnF.ystarNext" [(val it), (val nx)]
  | .ystarResume it nx => .node "FnF.ystarResume" [(val it), (val nx)]
  | .ystarAIt => .node "FnF.ystarAIt" []
  | .ystarAResult it nx => .node "FnF.ystarAResult" [(val it), (val nx)]
  | .ystarAResume it nx => .node "FnF.ystarAResume" [(val it), (val nx)]
  | .ystarAReturned it nx => .node "FnF.ystarAReturned" [(val it), (val nx)]
  | .ystarAReturn => .node "FnF.ystarAReturn" []
  | .await => .node "FnF.await" []
  | .modules r => .node "FnF.modules" [(seq (r.map fun (ss, e) => Tree.node "module" [atom ss, env e]))]

def frame : Frame → Tree
  | .e f => .node "Frame.e" [(exprF f)]
  | .c f => .node "Frame.c" [(callF f)]
  | .l f => .node "Frame.l" [(litF f)]
  | .a f => .node "Frame.a" [(asgF f)]
  | .s f => .node "Frame.s" [(stmtF f)]
  | .lp f => .node "Frame.lp" [(loopF f)]
  | .b f => .node "Frame.b" [(bindF f)]
  | .k f => .node "Frame.k" [(fnF f)]

def ctl : Ctl → Tree
  | .ev e en => .node "Ctl.ev" [(atom e), (env en)]
  | .ex s en => .node "Ctl.ex" [(atom s), (env en)]
  | .ret v => .node "Ctl.ret" [(val v)]
  | .abr a => .node "Ctl.abr" [(abr a)]
  | .call f t as => .node "Ctl.call" [(val f), (val t), (vals as)]
  | .construct f as nt => .node "Ctl.construct" [(val f), (vals as), (val nt)]
  | .bind p v e m k => .node "Ctl.bind" [(atom p), (val v), (env e), (atom m), (atom k)]
  | .short => .node "Ctl.short" []
  | .halt c => .node "Ctl.halt" [(comp c)]

def stores (ss : List (Nat × Val)) : Tree := seq (ss.map fun (a,v) => .node "store" [.address a,val v])
def susp (s : Susp) : Tree := .node "Susp" [seq (s.frames.map frame), stores s.stores]
def gen : GenState → Tree
  | .start b e => .node "GenState.start" [(atom b), (env e)]
  | .suspended u => .node "GenState.suspended" [(susp u)]
  | .running => .node "GenState.running" []
  | .done => .node "GenState.done" []

def reaction : Reaction → Tree
  | .resume u => .node "Reaction.resume" [(susp u)]
  | .then_ f r d ss => .node "Reaction.then_" [(val f), (val r), (Tree.address d), (stores ss)]
  | .adopt p => .node "Reaction.adopt" [(Tree.address p)]
  | .forward p => .node "Reaction.forward" [(Tree.address p)]

def pstate : PState → Tree
  | .pending rs => .node "PState.pending" [(seq (rs.map reaction))]
  | .fulfilled v => .node "PState.fulfilled" [(val v)]
  | .rejected v => .node "PState.rejected" [(val v)]

def code : Code → Tree
  | .closure f e ar h => .node "Code.closure" [(atom f), (env e), (atom ar), (val h)]
  | .klass c e p is => .node "Code.klass" [(atom c), (env e), (val p), (seq (is.map inst))]
  | .native n d => .node "Code.native" [(atom n), (vals d)]
  | .bound t th as => .node "Code.bound" [(val t), (val th), (vals as)]

def kind : Kind → Tree
  | .ordinary => .node "Kind.ordinary" []
  | .array es => .node "Kind.array" [(vals es)]
  | .fn c => .node "Kind.fn" [(code c)]
  | .buf bs => .node "Kind.buf" [(seq (bs.map byte))]
  | .extBuf r o l => .node "Kind.extBuf" [(Tree.region r), (atom o), (atom l)]
  | .typed k b o l => .node "Kind.typed" [(atom k), (Tree.address b), (atom o), (atom l)]
  | .view b o l => .node "Kind.view" [(Tree.address b), (atom o), (atom l)]
  | .map m => .node "Kind.map" [(pairs m)]
  | .set m => .node "Kind.set" [(vals m)]
  | .promise p => .node "Kind.promise" [(pstate p)]
  | .gen g a q => .node "Kind.gen" [(gen g), (atom a), (seq (q.map fun (p, c) => Tree.node "request" [.address p, comp c]))]
  | .ns ex => .node "Kind.ns" [(env ex)]
  | .box v => .node "Kind.box" [(val v)]
  | .iter s i m => .node "Kind.iter" [(val s), (atom i), (atom m)]

def obj (o : Obj) : Tree := .node "Obj" [kind o.kind,val o.proto,props o.props,
  seq (o.priv.map fun ((b,n),p) => .node "private" [.address b,atom n,prop p]),atom o.extensible]
def hobj : HObj → Tree
  | .cell none => .node "HObj.cellNone" []
  | .cell (some v) => .node "HObj.cellSome" [val v]
  | .obj o => .node "HObj.obj" [obj o]
def job (j : Job) : Tree := .node "Job" [reaction j.r,atom j.throw,val j.v]
end Encode

abbrev FrameR (R : Ren) (f f' : Frame) := TreeR R (Encode.frame f) (Encode.frame f')
abbrev ControlR (R : Ren) (c c' : Ctl) := TreeR R (Encode.ctl c) (Encode.ctl c')
abbrev ObjectR (R : Ren) (o o' : Obj) := TreeR R (Encode.obj o) (Encode.obj o')
inductive HeapObjectR (R : Ren) : HObj → HObj → Prop where
  | uninitialized : HeapObjectR R (.cell none) (.cell none)
  | cell {v v' : Val} : ValueR R v v' → HeapObjectR R (.cell (some v)) (.cell (some v'))
  | obj {o o' : Obj} : ObjectR R o o' → HeapObjectR R (.obj o) (.obj o')

end Host.Ts.Owned
