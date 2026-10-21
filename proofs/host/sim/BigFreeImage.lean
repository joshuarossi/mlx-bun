import host.sim.Map
namespace Host.Ts.Sim

/-! # Images under a change of the bigint map

`M.withBig b` replaces the bigint map of `M` by `b`. The images send bigints
through `M.big` only at the `.big` constructors of `Val`, `Cell`, `Arg` and
`Ret` (and in `Map.handle`). `NoBig.foo I x` holds when no such bigint of `x`
lies in `I`; if `b` agrees with `M.big` outside `I`, then `x` has the same
image under `M.withBig b` and `M` (`_rebig`). -/

def Map.withBig (M : Map) (b : Int → Int) : Map := { M with big := b }

section
variable (M : Map) (b : Int → Int)

theorem Map.withBig_a (x : Nat) : (M.withBig b).a x = M.a x := rfl
theorem Map.withBig_num (i : Nat) : (M.withBig b).num i = M.num i := rfl
theorem Map.withBig_big (i : Int) : (M.withBig b).big i = b i := rfl
theorem Map.withBig_region (r : Nat) : (M.withBig b).region r = M.region r := rfl
theorem Map.withBig_node (x : Nat) : (M.withBig b).node x = M.node x := rfl

theorem Map.nv_withBig (x : NumV) : (M.withBig b).nv x = M.nv x := by cases x <;> rfl
theorem Map.mem_withBig (m : Mem) : (M.withBig b).mem m = M.mem m := by cases m <;> rfl
theorem Map.sym_withBig (i : Nat) : (M.withBig b).sym i = M.sym i := rfl
theorem Map.key_withBig (k : PKey) : (M.withBig b).key k = M.key k := by cases k <;> rfl
theorem Map.env_withBig (e : Env) : (M.withBig b).env e = M.env e := rfl

theorem Map.keys_withBig (ks : List PKey) : ks.map (M.withBig b).key = ks.map M.key :=
  List.map_congr_left fun k _ => Map.key_withBig M b k

theorem Map.okey_withBig (k : Option PKey) : k.map (M.withBig b).key = k.map M.key := by
  cases k <;> simp [Map.key_withBig]

end

/-! ## Bigint freedom -/

section
variable (I : Int → Prop)

def NoBig.val : Val → Prop
  | .big i => ¬ I i
  | _ => True

def NoBig.prop : PropV → Prop
  | .data v _ _ => NoBig.val I v
  | .acc g s _ => NoBig.val I g ∧ NoBig.val I s

def NoBig.props (ps : Props) : Prop := ∀ x ∈ ps, NoBig.prop I x.2

def NoBig.vals (vs : List Val) : Prop := ∀ v ∈ vs, NoBig.val I v

def NoBig.cell : Cell → Prop
  | .num _ => True
  | .big i => ¬ I i

def NoBig.byte : Byte → Prop
  | .lit _ => True
  | .part _ c _ => NoBig.cell I c

def NoBig.bytes (bs : List Byte) : Prop := ∀ b ∈ bs, NoBig.byte I b

def NoBig.abr : Abrupt → Prop
  | .throw v => NoBig.val I v
  | .ret v => NoBig.val I v
  | _ => True

def NoBig.comp : Comp → Prop
  | .normal v => NoBig.val I v
  | .abrupt a => NoBig.abr I a

def NoBig.inst : InstMember → Prop
  | .field _ _ => True
  | .privField _ _ _ => True
  | .privMethod _ _ p => NoBig.prop I p

def NoBig.insts (is : List InstMember) : Prop := ∀ i ∈ is, NoBig.inst I i

def NoBig.bnd : Boundary → Prop
  | .call => True
  | .ctor t => NoBig.val I t
  | .derived _ => True
  | .async _ => True
  | .gen _ => True

def NoBig.src : IterSrc → Prop
  | .index v _ => NoBig.val I v
  | .proto it nx => NoBig.val I it ∧ NoBig.val I nx

def NoBig.pairs (ps : List (Val × Val)) : Prop := ∀ x ∈ ps, NoBig.val I x.1 ∧ NoBig.val I x.2

def NoBig.callF : CallF → Prop
  | .callee _ _ _ => True
  | .member _ _ _ _ _ => True
  | .index _ _ _ _ _ => True
  | .indexK o _ _ _ => NoBig.val I o
  | .priv _ _ _ _ _ _ => True
  | .method t _ _ _ => NoBig.val I t
  | .args _ f t acc _ _ => NoBig.val I f ∧ NoBig.val I t ∧ NoBig.vals I acc
  | .spread _ f t acc _ _ => NoBig.val I f ∧ NoBig.val I t ∧ NoBig.vals I acc
  | .newCallee _ _ => True

def NoBig.exprF : ExprF → Prop
  | .unary _ => True
  | .binL _ _ _ => True
  | .binR _ a => NoBig.val I a
  | .logL _ _ _ => True
  | .cond _ _ _ => True
  | .seq _ _ => True
  | .member _ _ => True
  | .indexL _ _ _ => True
  | .indexR o => NoBig.val I o
  | .priv _ _ _ => True
  | .chain => True
  | .const v => NoBig.val I v
  | .typeof => True

def NoBig.litF : LitF → Prop
  | .array acc _ _ => NoBig.vals I acc
  | .spread acc _ _ => NoBig.vals I acc
  | .object _ _ _ => True
  | .objKey _ _ _ _ => True
  | .objVal _ _ _ _ => True
  | .objSpread _ _ _ => True
  | .tmpl _ _ _ _ => True
  | .tagged t _ acc _ _ => NoBig.val I t ∧ NoBig.vals I acc

def NoBig.target : Target → Prop
  | .var _ _ => True
  | .prop o _ => NoBig.val I o
  | .priv o _ _ => NoBig.val I o

def NoBig.asgF : AsgF → Prop
  | .pat _ _ => True
  | .obj _ _ _ _ _ => True
  | .key _ o _ _ => NoBig.val I o
  | .privObj _ _ _ _ _ => True
  | .old _ t _ _ => NoBig.target I t
  | .put _ t o => NoBig.target I t ∧ NoBig.val I o
  | .updObj _ _ _ _ _ => True
  | .updKey _ _ o => NoBig.val I o
  | .updPrivObj _ _ _ _ => True
  | .updOld _ _ t => NoBig.target I t

def NoBig.stmtF : StmtF → Prop
  | .block _ _ => True
  | .scope res => NoBig.pairs I res
  | .dispose r c => NoBig.pairs I r ∧ NoBig.comp I c
  | .if_ _ _ _ => True
  | .decl _ _ _ _ => True
  | .declNext _ _ _ => True
  | .ret => True
  | .throw => True
  | .try_ _ _ _ => True
  | .catch_ _ _ => True
  | .finally_ c => NoBig.comp I c
  | .label _ => True
  | .switchD _ _ => True
  | .switchCase d _ _ _ => NoBig.val I d
  | .switchBody => True

def NoBig.loopF : LoopF → Prop
  | .forTest _ _ _ _ _ _ _ => True
  | .forBody _ _ _ _ _ _ => True
  | .forUpd _ _ _ _ _ _ => True
  | .whileTest _ _ _ _ => True
  | .whileBody _ _ _ _ => True
  | .doBody _ _ _ _ => True
  | .forOfSrc _ _ _ _ _ _ => True
  | .forOfIt _ _ _ _ _ _ => True
  | .forOfNext it nx _ _ _ _ _ _ => NoBig.val I it ∧ NoBig.val I nx
  | .forOfBody s _ _ _ _ _ _ => NoBig.src I s
  | .close c => NoBig.comp I c

def NoBig.bindF : BindF → Prop
  | .dflt _ _ _ _ => True
  | .arr _ _ vs _ _ _ => NoBig.vals I vs
  | .arrSrc _ _ _ _ _ => True
  | .obj s _ _ _ _ _ _ => NoBig.val I s
  | .objKey s _ _ _ _ _ _ _ => NoBig.val I s
  | .objVal s _ _ _ _ _ _ _ _ => NoBig.val I s
  | .collect acc it nx => NoBig.vals I acc ∧ NoBig.val I it ∧ NoBig.val I nx
  | .collectIt acc => NoBig.vals I acc

def NoBig.fnF : FnF → Prop
  | .fn b => NoBig.bnd I b
  | .params _ _ as _ => NoBig.vals I as
  | .paramDflt _ _ _ as _ => NoBig.vals I as
  | .classHeritage _ _ => True
  | .classMembers _ _ _ is _ => NoBig.insts I is
  | .classKey _ _ _ _ is _ => NoBig.insts I is
  | .classStatic _ _ _ _ is _ => NoBig.insts I is
  | .fields _ ms _ => NoBig.insts I ms
  | .fieldVal _ _ ms _ => NoBig.insts I ms
  | .privVal _ _ _ ms _ => NoBig.insts I ms
  | .ctorBody o _ _ as => NoBig.val I o ∧ NoBig.vals I as
  | .superRet _ _ _ => True
  | .paramProps o _ _ => NoBig.val I o
  | .native _ d => NoBig.vals I d
  | .promiseThen _ => True
  | .yield _ => True
  | .ystarIt => True
  | .ystarNext it nx => NoBig.val I it ∧ NoBig.val I nx
  | .ystarResume it nx => NoBig.val I it ∧ NoBig.val I nx
  | .ystarAIt => True
  | .ystarAResult it nx => NoBig.val I it ∧ NoBig.val I nx
  | .ystarAResume it nx => NoBig.val I it ∧ NoBig.val I nx
  | .ystarAReturned it nx => NoBig.val I it ∧ NoBig.val I nx
  | .ystarAReturn => True
  | .await => True
  | .modules _ => True

def NoBig.frame : Frame → Prop
  | .e f => NoBig.exprF I f
  | .c f => NoBig.callF I f
  | .l f => NoBig.litF I f
  | .a f => NoBig.asgF I f
  | .s f => NoBig.stmtF I f
  | .lp f => NoBig.loopF I f
  | .b f => NoBig.bindF I f
  | .k f => NoBig.fnF I f

def NoBig.ctl : Ctl → Prop
  | .ev _ _ => True
  | .ex _ _ => True
  | .ret v => NoBig.val I v
  | .abr a => NoBig.abr I a
  | .call f t as => NoBig.val I f ∧ NoBig.val I t ∧ NoBig.vals I as
  | .construct f as nt => NoBig.val I f ∧ NoBig.vals I as ∧ NoBig.val I nt
  | .bind _ v _ _ _ => NoBig.val I v
  | .short => True
  | .halt c => NoBig.comp I c

def NoBig.stores (ss : List (Nat × Val)) : Prop := ∀ x ∈ ss, NoBig.val I x.2

def NoBig.susp (u : Susp) : Prop := (∀ f ∈ u.frames, NoBig.frame I f) ∧ NoBig.stores I u.stores

def NoBig.gen : GenState → Prop
  | .start _ _ => True
  | .suspended u => NoBig.susp I u
  | .running => True
  | .done => True

def NoBig.reaction : Reaction → Prop
  | .resume u => NoBig.susp I u
  | .then_ f r _ ss => NoBig.val I f ∧ NoBig.val I r ∧ NoBig.stores I ss
  | .adopt _ => True
  | .forward _ => True

def NoBig.pstate : PState → Prop
  | .pending rs => ∀ r ∈ rs, NoBig.reaction I r
  | .fulfilled v => NoBig.val I v
  | .rejected v => NoBig.val I v

def NoBig.code : Code → Prop
  | .closure _ _ _ h => NoBig.val I h
  | .klass _ _ p is => NoBig.val I p ∧ NoBig.insts I is
  | .native _ d => NoBig.vals I d
  | .bound t th as => NoBig.val I t ∧ NoBig.val I th ∧ NoBig.vals I as

def NoBig.kind : Kind → Prop
  | .ordinary => True
  | .array es => NoBig.vals I es
  | .fn c => NoBig.code I c
  | .buf bs => NoBig.bytes I bs
  | .extBuf _ _ _ => True
  | .typed _ _ _ _ => True
  | .view _ _ _ => True
  | .map m => NoBig.pairs I m
  | .set m => NoBig.vals I m
  | .promise p => NoBig.pstate I p
  | .gen g _ q => NoBig.gen I g ∧ ∀ x ∈ q, NoBig.comp I x.2
  | .ns _ => True
  | .box v => NoBig.val I v
  | .iter s _ _ => NoBig.val I s

def NoBig.obj (o : Obj) : Prop :=
  NoBig.kind I o.kind ∧ NoBig.val I o.proto ∧ NoBig.props I o.props ∧ ∀ x ∈ o.priv, NoBig.prop I x.2

def NoBig.hobj : HObj → Prop
  | .cell none => True
  | .cell (some v) => NoBig.val I v
  | .obj o => NoBig.obj I o

def NoBig.arg : Arg → Prop
  | .big i => ¬ I i
  | .jsPtr _ _ bs => NoBig.bytes I bs
  | .other v => NoBig.val I v
  | _ => True

def NoBig.args (as : List Arg) : Prop := ∀ a ∈ as, NoBig.arg I a

def NoBig.ret : Ret → Prop
  | .big i => ¬ I i
  | .callback _ as => NoBig.args I as
  | _ => True

def NoBig.event (e : Event) : Prop := NoBig.args I e.args ∧ NoBig.ret I e.ret

def NoBig.job (j : Job) : Prop := NoBig.reaction I j.r ∧ NoBig.val I j.v

def NoBig.write : Nat × Nat × List Byte → Prop
  | (_, _, bs) => NoBig.bytes I bs

end

/-! ## Agreement -/

private theorem map_rebig {α β : Type} {P : α → Prop} {f g : α → β} {l : List α}
    (hl : ∀ x ∈ l, P x) (h : ∀ x, P x → f x = g x) : l.map f = l.map g :=
  List.map_congr_left fun x hx => h x (hl x hx)

section
variable {I : Int → Prop} {M : Map} {b : Int → Int}
variable (hb : ∀ i, ¬ I i → b i = M.big i)
include hb

attribute [local simp] Map.withBig_a Map.withBig_num Map.withBig_big Map.withBig_region
  Map.nv_withBig Map.mem_withBig Map.sym_withBig Map.key_withBig Map.env_withBig
  Map.keys_withBig Map.okey_withBig

theorem Map.handle_rebig {x : Nat} (hx : ¬ I (Int.ofNat x)) : (M.withBig b).handle x = M.handle x := by
  show (b (Int.ofNat x)).toNat = (M.big (Int.ofNat x)).toNat
  rw [hb _ hx]

theorem Map.val_rebig {x : Val} (hx : NoBig.val I x) : (M.withBig b).val x = M.val x := by
  cases x with
  | big i => exact congrArg Val.big (hb i hx)
  | _ => rfl

theorem Map.prop_rebig {p : PropV} (hx : NoBig.prop I p) : (M.withBig b).prop p = M.prop p := by
  cases p <;> simp_all [Map.prop, NoBig.prop, Map.val_rebig hb]

theorem Map.props_rebig {ps : Props} (hx : NoBig.props I ps) : (M.withBig b).props ps = M.props ps :=
  map_rebig hx fun ⟨_, _⟩ hp => by simp [Map.prop_rebig hb hp]

theorem Map.vals_rebig {vs : List Val} (hx : NoBig.vals I vs) : (M.withBig b).vals vs = M.vals vs :=
  map_rebig hx fun _ hv => Map.val_rebig hb hv

theorem Map.cell_rebig {c : Cell} (hx : NoBig.cell I c) : (M.withBig b).cell c = M.cell c := by
  cases c with
  | num x => rfl
  | big i => exact congrArg Cell.big (hb i hx)

theorem Map.byte_rebig {x : Byte} (hx : NoBig.byte I x) : (M.withBig b).byte x = M.byte x := by
  cases x with
  | lit _ => rfl
  | part k c i => exact congrArg (fun c => Byte.part k c i) (Map.cell_rebig hb hx)

theorem Map.bytes_rebig {bs : List Byte} (hx : NoBig.bytes I bs) :
    bs.map (M.withBig b).byte = bs.map M.byte :=
  map_rebig hx fun _ h => Map.byte_rebig hb h

theorem Map.abr_rebig {a : Abrupt} (hx : NoBig.abr I a) : (M.withBig b).abr a = M.abr a := by
  cases a <;> simp_all [Map.abr, NoBig.abr, Map.val_rebig hb]

theorem Map.comp_rebig {c : Comp} (hx : NoBig.comp I c) : (M.withBig b).comp c = M.comp c := by
  cases c <;> simp_all [Map.comp, NoBig.comp, Map.val_rebig hb, Map.abr_rebig hb]

theorem Map.inst_rebig {i : InstMember} (hx : NoBig.inst I i) : (M.withBig b).inst i = M.inst i := by
  cases i <;> simp_all [Map.inst, NoBig.inst, Map.prop_rebig hb]

theorem Map.insts_rebig {is : List InstMember} (hx : NoBig.insts I is) :
    is.map (M.withBig b).inst = is.map M.inst :=
  map_rebig hx fun _ h => Map.inst_rebig hb h

theorem Map.bnd_rebig {x : Boundary} (hx : NoBig.bnd I x) : (M.withBig b).bnd x = M.bnd x := by
  cases x <;> simp_all [Map.bnd, NoBig.bnd, Map.val_rebig hb]

theorem Map.src_rebig {s : IterSrc} (hx : NoBig.src I s) : (M.withBig b).src s = M.src s := by
  cases s <;> simp_all [Map.src, NoBig.src, Map.val_rebig hb]

theorem Map.pairs_rebig {ps : List (Val × Val)} (hx : NoBig.pairs I ps) :
    (M.withBig b).pairs ps = M.pairs ps :=
  map_rebig hx fun ⟨_, _⟩ ⟨h1, h2⟩ => by simp [Map.val_rebig hb h1, Map.val_rebig hb h2]

theorem Map.callF_rebig {f : CallF} (hx : NoBig.callF I f) : (M.withBig b).callF f = M.callF f := by
  cases f <;> simp_all [Map.callF, NoBig.callF, Map.val_rebig hb, Map.vals_rebig hb]

theorem Map.exprF_rebig {f : ExprF} (hx : NoBig.exprF I f) : (M.withBig b).exprF f = M.exprF f := by
  cases f <;> simp_all [Map.exprF, NoBig.exprF, Map.val_rebig hb]

theorem Map.litF_rebig {f : LitF} (hx : NoBig.litF I f) : (M.withBig b).litF f = M.litF f := by
  cases f <;> simp_all [Map.litF, NoBig.litF, Map.val_rebig hb, Map.vals_rebig hb]

theorem Map.target_rebig {t : Target} (hx : NoBig.target I t) : (M.withBig b).target t = M.target t := by
  cases t <;> simp_all [Map.target, NoBig.target, Map.val_rebig hb]

theorem Map.asgF_rebig {f : AsgF} (hx : NoBig.asgF I f) : (M.withBig b).asgF f = M.asgF f := by
  cases f <;> simp_all [Map.asgF, NoBig.asgF, Map.target_rebig hb, Map.val_rebig hb]

theorem Map.stmtF_rebig {f : StmtF} (hx : NoBig.stmtF I f) : (M.withBig b).stmtF f = M.stmtF f := by
  cases f <;> simp_all [Map.stmtF, NoBig.stmtF, Map.pairs_rebig hb, Map.comp_rebig hb, Map.val_rebig hb]

theorem Map.loopF_rebig {f : LoopF} (hx : NoBig.loopF I f) : (M.withBig b).loopF f = M.loopF f := by
  cases f <;> simp_all [Map.loopF, NoBig.loopF, Map.src_rebig hb, Map.comp_rebig hb, Map.val_rebig hb]

theorem Map.bindF_rebig {f : BindF} (hx : NoBig.bindF I f) : (M.withBig b).bindF f = M.bindF f := by
  cases f <;> simp_all [Map.bindF, NoBig.bindF, Map.val_rebig hb, Map.vals_rebig hb]

theorem Map.fnF_rebig {f : FnF} (hx : NoBig.fnF I f) : (M.withBig b).fnF f = M.fnF f := by
  cases f
  case modules r => rfl
  all_goals simp_all [Map.fnF, NoBig.fnF, Map.insts_rebig hb, Map.bnd_rebig hb, Map.val_rebig hb,
    Map.vals_rebig hb]

theorem Map.frame_rebig {f : Frame} (hx : NoBig.frame I f) : (M.withBig b).frame f = M.frame f := by
  cases f <;> simp_all [Map.frame, NoBig.frame, Map.exprF_rebig hb, Map.callF_rebig hb,
    Map.litF_rebig hb, Map.asgF_rebig hb, Map.stmtF_rebig hb, Map.loopF_rebig hb, Map.bindF_rebig hb,
    Map.fnF_rebig hb]

theorem Map.ctl_rebig {c : Ctl} (hx : NoBig.ctl I c) : (M.withBig b).ctl c = M.ctl c := by
  cases c <;> simp_all [Map.ctl, NoBig.ctl, Map.abr_rebig hb, Map.comp_rebig hb, Map.val_rebig hb,
    Map.vals_rebig hb]

theorem Map.stores_rebig {ss : List (Nat × Val)} (hx : NoBig.stores I ss) :
    (M.withBig b).stores ss = M.stores ss :=
  map_rebig hx fun ⟨_, _⟩ hv => by simp [Map.val_rebig hb hv]

theorem Map.susp_rebig {u : Susp} (hx : NoBig.susp I u) : (M.withBig b).susp u = M.susp u := by
  obtain ⟨fs, ss⟩ := u
  obtain ⟨hf, hs⟩ := hx
  simp only [Map.susp, Map.stores_rebig hb hs, map_rebig hf fun _ => Map.frame_rebig hb]

theorem Map.gen_rebig {g : GenState} (hx : NoBig.gen I g) : (M.withBig b).gen g = M.gen g := by
  cases g <;> simp_all [Map.gen, NoBig.gen, Map.susp_rebig hb]

theorem Map.reaction_rebig {r : Reaction} (hx : NoBig.reaction I r) :
    (M.withBig b).reaction r = M.reaction r := by
  cases r <;> simp_all [Map.reaction, NoBig.reaction, Map.susp_rebig hb, Map.stores_rebig hb,
    Map.val_rebig hb]

theorem Map.pstate_rebig {p : PState} (hx : NoBig.pstate I p) : (M.withBig b).pstate p = M.pstate p := by
  cases p
  case pending rs => exact congrArg PState.pending (map_rebig hx fun _ => Map.reaction_rebig hb)
  all_goals simp_all [Map.pstate, NoBig.pstate, Map.val_rebig hb]

theorem Map.code_rebig {c : Code} (hx : NoBig.code I c) : (M.withBig b).code c = M.code c := by
  cases c <;> simp_all [Map.code, NoBig.code, Map.insts_rebig hb, Map.val_rebig hb, Map.vals_rebig hb]

theorem Map.kind_rebig {k : Kind} (hx : NoBig.kind I k) : (M.withBig b).kind k = M.kind k := by
  cases k
  case gen g a q =>
    obtain ⟨hg, hq⟩ := hx
    simp only [Map.kind, Map.gen_rebig hb hg]
    exact congrArg _ (map_rebig hq fun ⟨p, _⟩ hc => by simp [Map.comp_rebig hb hc])
  case ns ex => rfl
  all_goals simp_all [Map.kind, NoBig.kind, Map.bytes_rebig hb, Map.code_rebig hb, Map.pairs_rebig hb,
    Map.pstate_rebig hb, Map.val_rebig hb, Map.vals_rebig hb]

theorem Map.obj_rebig {o : Obj} (hx : NoBig.obj I o) : (M.withBig b).obj o = M.obj o := by
  obtain ⟨k, pr, ps, pv, ex⟩ := o
  obtain ⟨hk, hpr, hps, hpv⟩ := hx
  simp only [Map.obj, Map.kind_rebig hb hk, Map.val_rebig hb hpr, Map.props_rebig hb hps]
  congr 1
  exact map_rebig hpv fun ⟨⟨_, _⟩, _⟩ hp => by simp [Map.prop_rebig hb hp]

theorem Map.hobj_rebig {o : HObj} (hx : NoBig.hobj I o) : (M.withBig b).hobj o = M.hobj o := by
  cases o with
  | cell v => cases v <;> simp_all [Map.hobj, NoBig.hobj, Map.val_rebig hb]
  | obj o => simp_all [Map.hobj, NoBig.hobj, Map.obj_rebig hb]

theorem Map.arg_rebig {a : Arg} (hx : NoBig.arg I a) : (M.withBig b).arg a = M.arg a := by
  cases a with
  | big i => exact congrArg Arg.big (hb i hx)
  | jsPtr x o bs => exact congrArg (Arg.jsPtr (M.a x) o) (Map.bytes_rebig hb hx)
  | other v => exact congrArg Arg.other (Map.val_rebig hb hx)
  | num x => rfl
  | null => rfl
  | bool _ => rfl
  | extPtr _ _ => rfl

theorem Map.args_rebig {as : List Arg} (hx : NoBig.args I as) :
    as.map (M.withBig b).arg = as.map M.arg :=
  map_rebig hx fun _ h => Map.arg_rebig hb h

theorem Map.ret_rebig {r : Ret} (hx : NoBig.ret I r) : (M.withBig b).ret r = M.ret r := by
  cases r with
  | big i => exact congrArg Ret.big (hb i hx)
  | callback f as => exact congrArg (Ret.callback (M.region f)) (Map.args_rebig hb hx)
  | _ => rfl

theorem Map.event_rebig {e : Event} (hx : NoBig.event I e) : (M.withBig b).event e = M.event e := by
  obtain ⟨s, as, r⟩ := e
  obtain ⟨ha, hr⟩ := hx
  simp only [Map.event, Map.args_rebig hb ha, Map.ret_rebig hb hr]

theorem Map.job_rebig {j : Job} (hx : NoBig.job I j) : (M.withBig b).job j = M.job j := by
  obtain ⟨r, t, v⟩ := j
  obtain ⟨hr, hv⟩ := hx
  simp only [Map.job, Map.reaction_rebig hb hr, Map.val_rebig hb hv]

theorem Map.write_rebig {w : Nat × Nat × List Byte} (hx : NoBig.write I w) :
    (M.withBig b).write w = M.write w := by
  obtain ⟨x, off, bs⟩ := w
  simp only [Map.write, Map.withBig_a, Map.bytes_rebig hb hx]

end

end Host.Ts.Sim
