import host.sim.Map
namespace Host.Ts.Sim

/-! # Identity, support and composition of maps

* Identity: `Map.id` fixes every name, so every image under it is the
  identity (`_id`).
* Support: `Supp.foo A n x` holds when every JS address in `x` satisfies `A`
  and every number reference in `x` is below `n`. Maps that `Agree` there
  give `x` the same image (`_agree`); support is monotone (`_mono`).
* Composition: `M.after σ` applies `σ`, then `M`; images compose (`_after`).
  `Map.handle` is excluded: `toNat` clamps negative bigints. -/

private theorem map_agree {α β : Type} {P : α → Prop} {f g : α → β} {l : List α}
    (hl : ∀ x ∈ l, P x) (h : ∀ x, P x → f x = g x) : l.map f = l.map g :=
  List.map_congr_left fun x hx => h x (hl x hx)

private theorem map_comp {α β γ : Type} {f : β → γ} {g : α → β} {k : α → γ}
    (h : ∀ x, f (g x) = k x) (l : List α) : (l.map g).map f = l.map k := by
  rw [List.map_map]; exact List.map_congr_left fun x _ => h x

private theorem opt_comp {α β γ : Type} {f : β → γ} {g : α → β} {k : α → γ}
    (h : ∀ x, f (g x) = k x) (o : Option α) : (o.map g).map f = o.map k := by
  cases o <;> simp [h]

private theorem sym_eq (R : Map) (i : Nat) : R.sym i = if i < 16 then i else R.a (i - 16) + 16 := by
  unfold Map.sym
  cases hb : Nat.blt i 16
  · have : ¬ i < 16 := by rw [← @Nat.blt_eq i 16, hb]; simp
    simp [this]
  · have : i < 16 := by rw [← @Nat.blt_eq i 16, hb]
    simp [this]

/-! ## Identity -/

def Map.id : Map := ⟨_root_.id, .ref, _root_.id, _root_.id, _root_.id⟩

theorem Map.id_a (x : Nat) : Map.id.a x = x := rfl
theorem Map.id_big (i : Int) : Map.id.big i = i := rfl
theorem Map.id_region (r : Nat) : Map.id.region r = r := rfl

theorem Map.handle_id (h : Nat) : Map.id.handle h = h := by simp [Map.handle, Map.id_big]

theorem Map.sym_id (i : Nat) : Map.id.sym i = i := by
  rw [sym_eq]; by_cases hi : i < 16 <;> simp [hi, Map.id_a] <;> omega

theorem Map.nv_id (x : NumV) : Map.id.nv x = x := by cases x <;> rfl

theorem Map.mem_id (m : Mem) : Map.id.mem m = m := by cases m <;> rfl

theorem Map.val_id (x : Val) : Map.id.val x = x := by
  cases x <;> simp [Map.val, Map.nv_id, Map.sym_id, Map.mem_id, Map.id_a, Map.id_big]

theorem Map.key_id (k : PKey) : Map.id.key k = k := by cases k <;> simp [Map.key, Map.sym_id]

theorem Map.prop_id (p : PropV) : Map.id.prop p = p := by cases p <;> simp [Map.prop, Map.val_id]

theorem Map.props_id (ps : Props) : Map.id.props ps = ps :=
  List.map_id'' (fun ⟨_, _⟩ => by simp [Map.key_id, Map.prop_id]) ps

theorem Map.vals_id (vs : List Val) : Map.id.vals vs = vs := List.map_id'' Map.val_id vs

theorem Map.cell_id (c : Cell) : Map.id.cell c = c := by
  cases c <;> simp [Map.cell, Map.nv_id, Map.id_big]

theorem Map.byte_id (b : Byte) : Map.id.byte b = b := by cases b <;> simp [Map.byte, Map.cell_id]

theorem Map.abr_id (a : Abrupt) : Map.id.abr a = a := by cases a <;> simp [Map.abr, Map.val_id]

theorem Map.comp_id (c : Comp) : Map.id.comp c = c := by
  cases c <;> simp [Map.comp, Map.val_id, Map.abr_id]

theorem Map.env_id (e : Env) : Map.id.env e = e := List.map_id'' (fun ⟨_, _⟩ => rfl) e

theorem Map.inst_id (i : InstMember) : Map.id.inst i = i := by
  cases i <;> simp [Map.inst, Map.key_id, Map.prop_id, Map.id_a]

theorem Map.bnd_id (b : Boundary) : Map.id.bnd b = b := by
  cases b <;> simp [Map.bnd, Map.val_id, Map.id_a]

theorem Map.src_id (s : IterSrc) : Map.id.src s = s := by cases s <;> simp [Map.src, Map.val_id]

theorem Map.pairs_id (ps : List (Val × Val)) : Map.id.pairs ps = ps :=
  List.map_id'' (fun ⟨_, _⟩ => by simp [Map.val_id]) ps

theorem Map.callF_id (f : CallF) : Map.id.callF f = f := by
  cases f <;> simp [Map.callF, Map.key_id, Map.val_id, Map.vals_id, Map.env_id, Map.id_a]

theorem Map.exprF_id (f : ExprF) : Map.id.exprF f = f := by
  cases f <;> simp [Map.exprF, Map.key_id, Map.val_id, Map.env_id, Map.id_a]

theorem Map.litF_id (f : LitF) : Map.id.litF f = f := by
  cases f <;> simp [Map.litF, Map.key_id, Map.val_id, Map.vals_id, Map.env_id, Map.id_a]

theorem Map.target_id (t : Target) : Map.id.target t = t := by
  cases t <;> simp [Map.target, Map.key_id, Map.val_id, Map.env_id, Map.id_a]

theorem Map.asgF_id (f : AsgF) : Map.id.asgF f = f := by
  have hk : Map.id.key = _root_.id := funext Map.key_id
  cases f <;> simp [Map.asgF, hk, Map.target_id, Map.val_id, Map.env_id, Map.id_a]

theorem Map.stmtF_id (f : StmtF) : Map.id.stmtF f = f := by
  cases f <;> simp [Map.stmtF, Map.pairs_id, Map.comp_id, Map.val_id, Map.env_id]

theorem Map.loopF_id (f : LoopF) : Map.id.loopF f = f := by
  cases f <;> simp [Map.loopF, Map.src_id, Map.comp_id, Map.val_id, Map.env_id]

theorem Map.bindF_id (f : BindF) : Map.id.bindF f = f := by
  cases f <;> simp [Map.bindF, List.map_id'' Map.key_id, Map.key_id, Map.val_id, Map.vals_id,
    Map.env_id]

theorem Map.fnF_id (f : FnF) : Map.id.fnF f = f := by
  cases f
  case modules r =>
    exact congrArg FnF.modules (List.map_id'' (fun ⟨_, _⟩ => by simp [Map.env_id]) r)
  all_goals simp [Map.fnF, List.map_id'' Map.inst_id, Map.bnd_id, Map.key_id, Map.val_id,
    Map.vals_id, Map.env_id, Map.id_a]

theorem Map.frame_id (f : Frame) : Map.id.frame f = f := by
  cases f <;> simp [Map.frame, Map.exprF_id, Map.callF_id, Map.litF_id, Map.asgF_id, Map.stmtF_id,
    Map.loopF_id, Map.bindF_id, Map.fnF_id]

theorem Map.ctl_id (c : Ctl) : Map.id.ctl c = c := by
  cases c <;> simp [Map.ctl, Map.abr_id, Map.comp_id, Map.val_id, Map.vals_id, Map.env_id]

theorem Map.stores_id (ss : List (Nat × Val)) : Map.id.stores ss = ss :=
  List.map_id'' (fun ⟨_, _⟩ => by simp [Map.val_id, Map.id_a]) ss

theorem Map.susp_id (u : Susp) : Map.id.susp u = u := by
  cases u; simp [Map.susp, List.map_id'' Map.frame_id, Map.stores_id]

theorem Map.gen_id (g : GenState) : Map.id.gen g = g := by
  cases g <;> simp [Map.gen, Map.susp_id, Map.env_id]

theorem Map.reaction_id (r : Reaction) : Map.id.reaction r = r := by
  cases r <;> simp [Map.reaction, Map.susp_id, Map.stores_id, Map.val_id, Map.id_a]

theorem Map.pstate_id (p : PState) : Map.id.pstate p = p := by
  cases p <;> simp [Map.pstate, List.map_id'' Map.reaction_id, Map.val_id]

theorem Map.code_id (c : Code) : Map.id.code c = c := by
  cases c <;> simp [Map.code, List.map_id'' Map.inst_id, Map.val_id, Map.vals_id, Map.env_id]

theorem Map.kind_id (k : Kind) : Map.id.kind k = k := by
  cases k
  case gen g a q =>
    simp only [Map.kind, Map.gen_id]
    exact congrArg _ (List.map_id'' (fun ⟨_, _⟩ => by simp [Map.comp_id, Map.id_a]) q)
  case ns ex => exact congrArg Kind.ns (List.map_id'' (fun ⟨_, _⟩ => rfl) ex)
  all_goals simp [Map.kind, List.map_id'' Map.byte_id, Map.code_id, Map.pairs_id, Map.pstate_id,
    Map.val_id, Map.vals_id, Map.id_a, Map.id_region]

theorem Map.obj_id (o : Obj) : Map.id.obj o = o := by
  obtain ⟨k, pr, ps, pv, ex⟩ := o
  simp only [Map.obj, Map.kind_id, Map.val_id, Map.props_id]
  congr 1
  exact List.map_id'' (fun ⟨⟨_, _⟩, _⟩ => by simp [Map.prop_id, Map.id_a]) pv

theorem Map.hobj_id (o : HObj) : Map.id.hobj o = o := by
  cases o with
  | cell v => cases v <;> simp [Map.hobj, Map.val_id]
  | obj o => simp [Map.hobj, Map.obj_id]

theorem Map.arg_id (a : Arg) : Map.id.arg a = a := by
  cases a <;> simp [Map.arg, List.map_id'' Map.byte_id, Map.nv_id, Map.val_id, Map.id_a,
    Map.id_big, Map.id_region]

theorem Map.ret_id (r : Ret) : Map.id.ret r = r := by
  cases r <;> simp [Map.ret, List.map_id'' Map.arg_id, Map.nv_id, Map.id_big, Map.id_region]

theorem Map.event_id (e : Event) : Map.id.event e = e := by
  cases e; simp [Map.event, List.map_id'' Map.arg_id, Map.ret_id]

theorem Map.job_id (j : Job) : Map.id.job j = j := by
  cases j; simp [Map.job, Map.reaction_id, Map.val_id]

theorem Map.write_id (w : Nat × Nat × List Byte) : Map.id.write w = w := by
  obtain ⟨b, off, bs⟩ := w; simp [Map.write, List.map_id'' Map.byte_id, Map.id_a]

/-! ## Support -/

/-- `M` and `M'` agree on the addresses in `A` and the first `n` number
references, and share their bigint, region and node maps. -/
structure Agree (A : Nat → Prop) (n : Nat) (M M' : Map) : Prop where
  a : ∀ x, A x → M.a x = M'.a x
  num : ∀ i, i < n → M.num i = M'.num i
  big : M.big = M'.big
  region : M.region = M'.region
  node : M.node = M'.node

def Supp.nv (_A : Nat → Prop) (n : Nat) : NumV → Prop
  | .lit _ => True
  | .ref i => i < n

def Supp.mem (A : Nat → Prop) (_n : Nat) : Mem → Prop
  | .js b => A b
  | .ext _ => True

def Supp.sym (A : Nat → Prop) (_n : Nat) (i : Nat) : Prop := 16 ≤ i → A (i - 16)

def Supp.val (A : Nat → Prop) (n : Nat) : Val → Prop
  | .num x => Supp.nv A n x
  | .sym i => Supp.sym A n i
  | .obj a => A a
  | .ptr m _ => Supp.mem A n m
  | _ => True

def Supp.key (A : Nat → Prop) (n : Nat) : PKey → Prop
  | .str _ => True
  | .sym i => Supp.sym A n i

def Supp.okey (A : Nat → Prop) (n : Nat) : Option PKey → Prop
  | none => True
  | some k => Supp.key A n k

def Supp.keys (A : Nat → Prop) (n : Nat) (ks : List PKey) : Prop := ∀ k ∈ ks, Supp.key A n k

def Supp.prop (A : Nat → Prop) (n : Nat) : PropV → Prop
  | .data v _ _ => Supp.val A n v
  | .acc g s _ => Supp.val A n g ∧ Supp.val A n s

def Supp.props (A : Nat → Prop) (n : Nat) (ps : Props) : Prop :=
  ∀ x ∈ ps, Supp.key A n x.1 ∧ Supp.prop A n x.2

def Supp.vals (A : Nat → Prop) (n : Nat) (vs : List Val) : Prop := ∀ v ∈ vs, Supp.val A n v

def Supp.cell (A : Nat → Prop) (n : Nat) : Cell → Prop
  | .num x => Supp.nv A n x
  | .big _ => True

def Supp.byte (A : Nat → Prop) (n : Nat) : Byte → Prop
  | .lit _ => True
  | .part _ c _ => Supp.cell A n c

def Supp.bytes (A : Nat → Prop) (n : Nat) (bs : List Byte) : Prop := ∀ b ∈ bs, Supp.byte A n b

def Supp.abr (A : Nat → Prop) (n : Nat) : Abrupt → Prop
  | .throw v => Supp.val A n v
  | .ret v => Supp.val A n v
  | _ => True

def Supp.comp (A : Nat → Prop) (n : Nat) : Comp → Prop
  | .normal v => Supp.val A n v
  | .abrupt a => Supp.abr A n a

def Supp.env (A : Nat → Prop) (_n : Nat) (e : Env) : Prop := ∀ x ∈ e, A x.2

def Supp.inst (A : Nat → Prop) (n : Nat) : InstMember → Prop
  | .field k _ => Supp.key A n k
  | .privField b _ _ => A b
  | .privMethod b _ p => A b ∧ Supp.prop A n p

def Supp.insts (A : Nat → Prop) (n : Nat) (is : List InstMember) : Prop :=
  ∀ i ∈ is, Supp.inst A n i

def Supp.bnd (A : Nat → Prop) (n : Nat) : Boundary → Prop
  | .call => True
  | .ctor t => Supp.val A n t
  | .derived c => A c
  | .async p => A p
  | .gen g => A g

def Supp.src (A : Nat → Prop) (n : Nat) : IterSrc → Prop
  | .index v _ => Supp.val A n v
  | .proto it nx => Supp.val A n it ∧ Supp.val A n nx

def Supp.pairs (A : Nat → Prop) (n : Nat) (ps : List (Val × Val)) : Prop :=
  ∀ x ∈ ps, Supp.val A n x.1 ∧ Supp.val A n x.2

def Supp.callF (A : Nat → Prop) (n : Nat) : CallF → Prop
  | .callee _ e _ => Supp.env A n e
  | .member k _ e _ _ => Supp.key A n k ∧ Supp.env A n e
  | .index _ _ e _ _ => Supp.env A n e
  | .indexK o _ e _ => Supp.val A n o ∧ Supp.env A n e
  | .priv b _ _ e _ _ => A b ∧ Supp.env A n e
  | .method t _ e _ => Supp.val A n t ∧ Supp.env A n e
  | .args _ f t acc _ e =>
    Supp.val A n f ∧ Supp.val A n t ∧ Supp.vals A n acc ∧ Supp.env A n e
  | .spread _ f t acc _ e =>
    Supp.val A n f ∧ Supp.val A n t ∧ Supp.vals A n acc ∧ Supp.env A n e
  | .newCallee _ e => Supp.env A n e

def Supp.exprF (A : Nat → Prop) (n : Nat) : ExprF → Prop
  | .unary _ => True
  | .binL _ _ e => Supp.env A n e
  | .binR _ a => Supp.val A n a
  | .logL _ _ e => Supp.env A n e
  | .cond _ _ e => Supp.env A n e
  | .seq _ e => Supp.env A n e
  | .member k _ => Supp.key A n k
  | .indexL _ e _ => Supp.env A n e
  | .indexR o => Supp.val A n o
  | .priv b _ _ => A b
  | .chain => True
  | .const v => Supp.val A n v
  | .typeof => True

def Supp.litF (A : Nat → Prop) (n : Nat) : LitF → Prop
  | .array acc _ e => Supp.vals A n acc ∧ Supp.env A n e
  | .spread acc _ e => Supp.vals A n acc ∧ Supp.env A n e
  | .object o _ e => A o ∧ Supp.env A n e
  | .objKey o _ _ e => A o ∧ Supp.env A n e
  | .objVal o k _ e => A o ∧ Supp.key A n k ∧ Supp.env A n e
  | .objSpread o _ e => A o ∧ Supp.env A n e
  | .tmpl _ _ _ e => Supp.env A n e
  | .tagged t _ acc _ e => Supp.val A n t ∧ Supp.vals A n acc ∧ Supp.env A n e

def Supp.target (A : Nat → Prop) (n : Nat) : Target → Prop
  | .var _ e => Supp.env A n e
  | .prop o k => Supp.val A n o ∧ Supp.key A n k
  | .priv o b _ => Supp.val A n o ∧ A b

def Supp.asgF (A : Nat → Prop) (n : Nat) : AsgF → Prop
  | .pat _ e => Supp.env A n e
  | .obj _ k _ _ e => Supp.okey A n k ∧ Supp.env A n e
  | .key _ o _ e => Supp.val A n o ∧ Supp.env A n e
  | .privObj _ b _ _ e => A b ∧ Supp.env A n e
  | .old _ t _ e => Supp.target A n t ∧ Supp.env A n e
  | .put _ t o => Supp.target A n t ∧ Supp.val A n o
  | .updObj _ _ k _ e => Supp.okey A n k ∧ Supp.env A n e
  | .updKey _ _ o => Supp.val A n o
  | .updPrivObj _ _ b _ => A b
  | .updOld _ _ t => Supp.target A n t

def Supp.stmtF (A : Nat → Prop) (n : Nat) : StmtF → Prop
  | .block _ e => Supp.env A n e
  | .scope res => Supp.pairs A n res
  | .dispose r c => Supp.pairs A n r ∧ Supp.comp A n c
  | .if_ _ _ e => Supp.env A n e
  | .decl _ _ _ e => Supp.env A n e
  | .declNext _ _ e => Supp.env A n e
  | .ret => True
  | .throw => True
  | .try_ _ _ e => Supp.env A n e
  | .catch_ _ e => Supp.env A n e
  | .finally_ c => Supp.comp A n c
  | .label _ => True
  | .switchD _ e => Supp.env A n e
  | .switchCase d _ _ e => Supp.val A n d ∧ Supp.env A n e
  | .switchBody => True

def Supp.loopF (A : Nat → Prop) (n : Nat) : LoopF → Prop
  | .forTest _ _ _ _ e _ _ => Supp.env A n e
  | .forBody _ _ _ e _ _ => Supp.env A n e
  | .forUpd _ _ _ e _ _ => Supp.env A n e
  | .whileTest _ _ e _ => Supp.env A n e
  | .whileBody _ _ e _ => Supp.env A n e
  | .doBody _ _ e _ => Supp.env A n e
  | .forOfSrc _ _ _ _ e _ => Supp.env A n e
  | .forOfIt _ _ _ _ e _ => Supp.env A n e
  | .forOfNext it nx _ _ _ _ e _ => Supp.val A n it ∧ Supp.val A n nx ∧ Supp.env A n e
  | .forOfBody s _ _ _ _ e _ => Supp.src A n s ∧ Supp.env A n e
  | .close c => Supp.comp A n c

def Supp.bindF (A : Nat → Prop) (n : Nat) : BindF → Prop
  | .dflt _ e _ _ => Supp.env A n e
  | .arr _ _ vs e _ _ => Supp.vals A n vs ∧ Supp.env A n e
  | .arrSrc _ _ e _ _ => Supp.env A n e
  | .obj s _ _ u e _ _ => Supp.val A n s ∧ Supp.keys A n u ∧ Supp.env A n e
  | .objKey s _ _ _ u e _ _ => Supp.val A n s ∧ Supp.keys A n u ∧ Supp.env A n e
  | .objVal s k _ _ _ u e _ _ =>
    Supp.val A n s ∧ Supp.key A n k ∧ Supp.keys A n u ∧ Supp.env A n e
  | .collect acc it nx => Supp.vals A n acc ∧ Supp.val A n it ∧ Supp.val A n nx
  | .collectIt acc => Supp.vals A n acc

def Supp.fnF (A : Nat → Prop) (n : Nat) : FnF → Prop
  | .fn b => Supp.bnd A n b
  | .params _ _ as e => Supp.vals A n as ∧ Supp.env A n e
  | .paramDflt _ _ _ as e => Supp.vals A n as ∧ Supp.env A n e
  | .classHeritage _ e => Supp.env A n e
  | .classMembers f p _ is e => A f ∧ A p ∧ Supp.insts A n is ∧ Supp.env A n e
  | .classKey f p _ _ is e => A f ∧ A p ∧ Supp.insts A n is ∧ Supp.env A n e
  | .classStatic f p k _ is e =>
    A f ∧ A p ∧ Supp.key A n k ∧ Supp.insts A n is ∧ Supp.env A n e
  | .fields o ms e => A o ∧ Supp.insts A n ms ∧ Supp.env A n e
  | .fieldVal o k ms e => A o ∧ Supp.key A n k ∧ Supp.insts A n ms ∧ Supp.env A n e
  | .privVal o b _ ms e => A o ∧ A b ∧ Supp.insts A n ms ∧ Supp.env A n e
  | .ctorBody o _ e as => Supp.val A n o ∧ Supp.env A n e ∧ Supp.vals A n as
  | .superRet c k e => A c ∧ A k ∧ Supp.env A n e
  | .paramProps o _ e => Supp.val A n o ∧ Supp.env A n e
  | .native _ d => Supp.vals A n d
  | .promiseThen p => A p
  | .yield _ => True
  | .ystarIt => True
  | .ystarNext it nx => Supp.val A n it ∧ Supp.val A n nx
  | .ystarResume it nx => Supp.val A n it ∧ Supp.val A n nx
  | .ystarAIt => True
  | .ystarAResult it nx => Supp.val A n it ∧ Supp.val A n nx
  | .ystarAResume it nx => Supp.val A n it ∧ Supp.val A n nx
  | .ystarAReturned it nx => Supp.val A n it ∧ Supp.val A n nx
  | .ystarAReturn => True
  | .await => True
  | .modules r => ∀ x ∈ r, Supp.env A n x.2

def Supp.frame (A : Nat → Prop) (n : Nat) : Frame → Prop
  | .e f => Supp.exprF A n f
  | .c f => Supp.callF A n f
  | .l f => Supp.litF A n f
  | .a f => Supp.asgF A n f
  | .s f => Supp.stmtF A n f
  | .lp f => Supp.loopF A n f
  | .b f => Supp.bindF A n f
  | .k f => Supp.fnF A n f

def Supp.ctl (A : Nat → Prop) (n : Nat) : Ctl → Prop
  | .ev _ en => Supp.env A n en
  | .ex _ en => Supp.env A n en
  | .ret v => Supp.val A n v
  | .abr a => Supp.abr A n a
  | .call f t as => Supp.val A n f ∧ Supp.val A n t ∧ Supp.vals A n as
  | .construct f as nt => Supp.val A n f ∧ Supp.vals A n as ∧ Supp.val A n nt
  | .bind _ v e _ _ => Supp.val A n v ∧ Supp.env A n e
  | .short => True
  | .halt c => Supp.comp A n c

def Supp.stores (A : Nat → Prop) (n : Nat) (ss : List (Nat × Val)) : Prop :=
  ∀ x ∈ ss, A x.1 ∧ Supp.val A n x.2

def Supp.susp (A : Nat → Prop) (n : Nat) (u : Susp) : Prop :=
  (∀ f ∈ u.frames, Supp.frame A n f) ∧ Supp.stores A n u.stores

def Supp.gen (A : Nat → Prop) (n : Nat) : GenState → Prop
  | .start _ e => Supp.env A n e
  | .suspended u => Supp.susp A n u
  | .running => True
  | .done => True

def Supp.reaction (A : Nat → Prop) (n : Nat) : Reaction → Prop
  | .resume u => Supp.susp A n u
  | .then_ f r d ss => Supp.val A n f ∧ Supp.val A n r ∧ A d ∧ Supp.stores A n ss
  | .adopt p => A p
  | .forward p => A p

def Supp.pstate (A : Nat → Prop) (n : Nat) : PState → Prop
  | .pending rs => ∀ r ∈ rs, Supp.reaction A n r
  | .fulfilled v => Supp.val A n v
  | .rejected v => Supp.val A n v

def Supp.code (A : Nat → Prop) (n : Nat) : Code → Prop
  | .closure _ e _ h => Supp.env A n e ∧ Supp.val A n h
  | .klass _ e p is => Supp.env A n e ∧ Supp.val A n p ∧ Supp.insts A n is
  | .native _ d => Supp.vals A n d
  | .bound t th as => Supp.val A n t ∧ Supp.val A n th ∧ Supp.vals A n as

def Supp.kind (A : Nat → Prop) (n : Nat) : Kind → Prop
  | .ordinary => True
  | .array es => Supp.vals A n es
  | .fn c => Supp.code A n c
  | .buf bs => Supp.bytes A n bs
  | .extBuf _ _ _ => True
  | .typed _ b _ _ => A b
  | .view b _ _ => A b
  | .map m => Supp.pairs A n m
  | .set m => Supp.vals A n m
  | .promise p => Supp.pstate A n p
  | .gen g _ q => Supp.gen A n g ∧ ∀ x ∈ q, A x.1 ∧ Supp.comp A n x.2
  | .ns ex => Supp.env A n ex
  | .box v => Supp.val A n v
  | .iter s _ _ => Supp.val A n s

def Supp.obj (A : Nat → Prop) (n : Nat) (o : Obj) : Prop :=
  Supp.kind A n o.kind ∧ Supp.val A n o.proto ∧ Supp.props A n o.props ∧
    ∀ x ∈ o.priv, A x.1.1 ∧ Supp.prop A n x.2

def Supp.hobj (A : Nat → Prop) (n : Nat) : HObj → Prop
  | .cell none => True
  | .cell (some v) => Supp.val A n v
  | .obj o => Supp.obj A n o

def Supp.arg (A : Nat → Prop) (n : Nat) : Arg → Prop
  | .num x => Supp.nv A n x
  | .jsPtr b _ bs => A b ∧ Supp.bytes A n bs
  | .other v => Supp.val A n v
  | _ => True

def Supp.args (A : Nat → Prop) (n : Nat) (as : List Arg) : Prop := ∀ a ∈ as, Supp.arg A n a

def Supp.ret (A : Nat → Prop) (n : Nat) : Ret → Prop
  | .num x => Supp.nv A n x
  | .callback _ as => Supp.args A n as
  | _ => True

def Supp.event (A : Nat → Prop) (n : Nat) (e : Event) : Prop :=
  Supp.args A n e.args ∧ Supp.ret A n e.ret

def Supp.job (A : Nat → Prop) (n : Nat) (j : Job) : Prop :=
  Supp.reaction A n j.r ∧ Supp.val A n j.v

def Supp.write (A : Nat → Prop) (n : Nat) : Nat × Nat × List Byte → Prop
  | (b, _, bs) => A b ∧ Supp.bytes A n bs

section
variable {A A' : Nat → Prop} {n n' : Nat} {M M' : Map}

section
variable (h : Agree A n M M')
include h

theorem Map.handle_agree (x : Nat) : M.handle x = M'.handle x := by
  simp [Map.handle, h.big]

theorem Map.nv_agree {x : NumV} (hx : Supp.nv A n x) : M.nv x = M'.nv x := by
  cases x
  · rfl
  · exact h.num _ hx

theorem Map.mem_agree {m : Mem} (hx : Supp.mem A n m) : M.mem m = M'.mem m := by
  cases m <;> simp_all [Map.mem, Supp.mem, h.a, h.region]

theorem Map.sym_agree {i : Nat} (hx : Supp.sym A n i) : M.sym i = M'.sym i := by
  rw [sym_eq, sym_eq]
  by_cases hi : i < 16
  · simp [hi]
  · simp [hi, h.a _ (hx (by omega))]

theorem Map.val_agree {x : Val} (hx : Supp.val A n x) : M.val x = M'.val x := by
  cases x <;> simp_all [Map.val, Supp.val, Map.nv_agree h, Map.sym_agree h, Map.mem_agree h, h.a,
    h.big]

theorem Map.key_agree {k : PKey} (hx : Supp.key A n k) : M.key k = M'.key k := by
  cases k <;> simp_all [Map.key, Supp.key, Map.sym_agree h]

private theorem okey_agree {k : Option PKey} (hx : Supp.okey A n k) :
    k.map M.key = k.map M'.key := by
  cases k <;> simp_all [Supp.okey, Map.key_agree h]

private theorem keys_agree {ks : List PKey} (hx : Supp.keys A n ks) :
    ks.map M.key = ks.map M'.key :=
  map_agree hx fun _ hk => Map.key_agree h hk

theorem Map.prop_agree {p : PropV} (hx : Supp.prop A n p) : M.prop p = M'.prop p := by
  cases p <;> simp_all [Map.prop, Supp.prop, Map.val_agree h]

theorem Map.props_agree {ps : Props} (hx : Supp.props A n ps) : M.props ps = M'.props ps :=
  map_agree hx fun ⟨_, _⟩ ⟨hk, hp⟩ => by simp [Map.key_agree h hk, Map.prop_agree h hp]

theorem Map.vals_agree {vs : List Val} (hx : Supp.vals A n vs) : M.vals vs = M'.vals vs :=
  map_agree hx fun _ hv => Map.val_agree h hv

theorem Map.cell_agree {c : Cell} (hx : Supp.cell A n c) : M.cell c = M'.cell c := by
  cases c <;> simp_all [Map.cell, Supp.cell, Map.nv_agree h, h.big]

theorem Map.byte_agree {b : Byte} (hx : Supp.byte A n b) : M.byte b = M'.byte b := by
  cases b <;> simp_all [Map.byte, Supp.byte, Map.cell_agree h]

private theorem bytes_agree {bs : List Byte} (hx : Supp.bytes A n bs) :
    bs.map M.byte = bs.map M'.byte :=
  map_agree hx fun _ hb => Map.byte_agree h hb

theorem Map.abr_agree {a : Abrupt} (hx : Supp.abr A n a) : M.abr a = M'.abr a := by
  cases a <;> simp_all [Map.abr, Supp.abr, Map.val_agree h]

theorem Map.comp_agree {c : Comp} (hx : Supp.comp A n c) : M.comp c = M'.comp c := by
  cases c <;> simp_all [Map.comp, Supp.comp, Map.val_agree h, Map.abr_agree h]

theorem Map.env_agree {e : Env} (hx : Supp.env A n e) : M.env e = M'.env e :=
  map_agree hx fun ⟨_, c⟩ hc => by simp [h.a c hc]

theorem Map.inst_agree {i : InstMember} (hx : Supp.inst A n i) : M.inst i = M'.inst i := by
  cases i <;> simp_all [Map.inst, Supp.inst, Map.key_agree h, Map.prop_agree h, h.a]

private theorem insts_agree {is : List InstMember} (hx : Supp.insts A n is) :
    is.map M.inst = is.map M'.inst :=
  map_agree hx fun _ hi => Map.inst_agree h hi

theorem Map.bnd_agree {b : Boundary} (hx : Supp.bnd A n b) : M.bnd b = M'.bnd b := by
  cases b <;> simp_all [Map.bnd, Supp.bnd, Map.val_agree h, h.a]

theorem Map.src_agree {s : IterSrc} (hx : Supp.src A n s) : M.src s = M'.src s := by
  cases s <;> simp_all [Map.src, Supp.src, Map.val_agree h]

theorem Map.pairs_agree {ps : List (Val × Val)} (hx : Supp.pairs A n ps) :
    M.pairs ps = M'.pairs ps :=
  map_agree hx fun ⟨_, _⟩ ⟨h1, h2⟩ => by simp [Map.val_agree h h1, Map.val_agree h h2]

theorem Map.callF_agree {f : CallF} (hx : Supp.callF A n f) : M.callF f = M'.callF f := by
  cases f <;> simp_all [Map.callF, Supp.callF, Map.key_agree h, Map.val_agree h, Map.vals_agree h,
    Map.env_agree h, h.a]

theorem Map.exprF_agree {f : ExprF} (hx : Supp.exprF A n f) : M.exprF f = M'.exprF f := by
  cases f <;> simp_all [Map.exprF, Supp.exprF, Map.key_agree h, Map.val_agree h, Map.env_agree h,
    h.a]

theorem Map.litF_agree {f : LitF} (hx : Supp.litF A n f) : M.litF f = M'.litF f := by
  cases f <;> simp_all [Map.litF, Supp.litF, Map.key_agree h, Map.val_agree h, Map.vals_agree h,
    Map.env_agree h, h.a]

theorem Map.target_agree {t : Target} (hx : Supp.target A n t) : M.target t = M'.target t := by
  cases t <;> simp_all [Map.target, Supp.target, Map.key_agree h, Map.val_agree h, Map.env_agree h,
    h.a]

theorem Map.asgF_agree {f : AsgF} (hx : Supp.asgF A n f) : M.asgF f = M'.asgF f := by
  cases f <;> simp_all [Map.asgF, Supp.asgF, okey_agree h, Map.target_agree h, Map.val_agree h,
    Map.env_agree h, h.a]

theorem Map.stmtF_agree {f : StmtF} (hx : Supp.stmtF A n f) : M.stmtF f = M'.stmtF f := by
  cases f <;> simp_all [Map.stmtF, Supp.stmtF, Map.pairs_agree h, Map.comp_agree h, Map.val_agree h,
    Map.env_agree h]

theorem Map.loopF_agree {f : LoopF} (hx : Supp.loopF A n f) : M.loopF f = M'.loopF f := by
  cases f <;> simp_all [Map.loopF, Supp.loopF, Map.src_agree h, Map.comp_agree h, Map.val_agree h,
    Map.env_agree h]

theorem Map.bindF_agree {f : BindF} (hx : Supp.bindF A n f) : M.bindF f = M'.bindF f := by
  cases f <;> simp_all [Map.bindF, Supp.bindF, keys_agree h, Map.key_agree h, Map.val_agree h,
    Map.vals_agree h, Map.env_agree h]

theorem Map.fnF_agree {f : FnF} (hx : Supp.fnF A n f) : M.fnF f = M'.fnF f := by
  cases f
  case modules r =>
    exact congrArg FnF.modules (map_agree hx fun ⟨_, _⟩ he => by simp [Map.env_agree h he])
  all_goals simp_all [Map.fnF, Supp.fnF, insts_agree h, Map.bnd_agree h, Map.key_agree h,
    Map.val_agree h, Map.vals_agree h, Map.env_agree h, h.a]

theorem Map.frame_agree {f : Frame} (hx : Supp.frame A n f) : M.frame f = M'.frame f := by
  cases f <;> simp_all [Map.frame, Supp.frame, Map.exprF_agree h, Map.callF_agree h,
    Map.litF_agree h, Map.asgF_agree h, Map.stmtF_agree h, Map.loopF_agree h, Map.bindF_agree h,
    Map.fnF_agree h]

theorem Map.ctl_agree {c : Ctl} (hx : Supp.ctl A n c) : M.ctl c = M'.ctl c := by
  cases c <;> simp_all [Map.ctl, Supp.ctl, Map.abr_agree h, Map.comp_agree h, Map.val_agree h,
    Map.vals_agree h, Map.env_agree h]

theorem Map.stores_agree {ss : List (Nat × Val)} (hx : Supp.stores A n ss) :
    M.stores ss = M'.stores ss :=
  map_agree hx fun ⟨i, _⟩ ⟨hi, hv⟩ => by simp [h.a i hi, Map.val_agree h hv]

theorem Map.susp_agree {u : Susp} (hx : Supp.susp A n u) : M.susp u = M'.susp u := by
  obtain ⟨fs, ss⟩ := u
  obtain ⟨hf, hs⟩ := hx
  simp only [Map.susp, Map.stores_agree h hs, map_agree hf fun _ => Map.frame_agree h]

theorem Map.gen_agree {g : GenState} (hx : Supp.gen A n g) : M.gen g = M'.gen g := by
  cases g <;> simp_all [Map.gen, Supp.gen, Map.susp_agree h, Map.env_agree h]

theorem Map.reaction_agree {r : Reaction} (hx : Supp.reaction A n r) :
    M.reaction r = M'.reaction r := by
  cases r <;> simp_all [Map.reaction, Supp.reaction, Map.susp_agree h, Map.stores_agree h,
    Map.val_agree h, h.a]

theorem Map.pstate_agree {p : PState} (hx : Supp.pstate A n p) : M.pstate p = M'.pstate p := by
  cases p
  case pending rs => exact congrArg PState.pending (map_agree hx fun _ => Map.reaction_agree h)
  all_goals simp_all [Map.pstate, Supp.pstate, Map.val_agree h]

theorem Map.code_agree {c : Code} (hx : Supp.code A n c) : M.code c = M'.code c := by
  cases c <;> simp_all [Map.code, Supp.code, insts_agree h, Map.val_agree h, Map.vals_agree h,
    Map.env_agree h]

theorem Map.kind_agree {k : Kind} (hx : Supp.kind A n k) : M.kind k = M'.kind k := by
  cases k
  case gen g a q =>
    obtain ⟨hg, hq⟩ := hx
    simp only [Map.kind, Map.gen_agree h hg]
    exact congrArg _ (map_agree hq fun ⟨p, _⟩ ⟨hp, hc⟩ =>
      by simp [h.a p hp, Map.comp_agree h hc])
  case ns ex => exact congrArg Kind.ns (map_agree hx fun ⟨_, c⟩ hc => by simp [h.a c hc])
  all_goals simp_all [Map.kind, Supp.kind, bytes_agree h, Map.code_agree h, Map.pairs_agree h,
    Map.pstate_agree h, Map.val_agree h, Map.vals_agree h, h.a, h.region]

theorem Map.obj_agree {o : Obj} (hx : Supp.obj A n o) : M.obj o = M'.obj o := by
  obtain ⟨k, pr, ps, pv, ex⟩ := o
  obtain ⟨hk, hpr, hps, hpv⟩ := hx
  simp only [Map.obj, Map.kind_agree h hk, Map.val_agree h hpr, Map.props_agree h hps]
  congr 1
  exact map_agree hpv fun ⟨⟨b, _⟩, _⟩ ⟨hb, hp⟩ =>
    by simp [h.a b hb, Map.prop_agree h hp]

theorem Map.hobj_agree {o : HObj} (hx : Supp.hobj A n o) : M.hobj o = M'.hobj o := by
  cases o with
  | cell v => cases v <;> simp_all [Map.hobj, Supp.hobj, Map.val_agree h]
  | obj o => simp_all [Map.hobj, Supp.hobj, Map.obj_agree h]

theorem Map.arg_agree {a : Arg} (hx : Supp.arg A n a) : M.arg a = M'.arg a := by
  cases a <;> simp_all [Map.arg, Supp.arg, bytes_agree h, Map.nv_agree h, Map.val_agree h,
    h.a, h.big, h.region]

private theorem args_agree {as : List Arg} (hx : Supp.args A n as) : as.map M.arg = as.map M'.arg :=
  map_agree hx fun _ ha => Map.arg_agree h ha

theorem Map.ret_agree {r : Ret} (hx : Supp.ret A n r) : M.ret r = M'.ret r := by
  cases r <;> simp_all [Map.ret, Supp.ret, args_agree h, Map.nv_agree h, h.big, h.region]

theorem Map.event_agree {e : Event} (hx : Supp.event A n e) : M.event e = M'.event e := by
  obtain ⟨s, as, r⟩ := e
  obtain ⟨ha, hr⟩ := hx
  simp only [Map.event, args_agree h ha, Map.ret_agree h hr]

theorem Map.job_agree {j : Job} (hx : Supp.job A n j) : M.job j = M'.job j := by
  obtain ⟨r, t, v⟩ := j
  obtain ⟨hr, hv⟩ := hx
  simp only [Map.job, Map.reaction_agree h hr, Map.val_agree h hv]

theorem Map.write_agree {w : Nat × Nat × List Byte} (hx : Supp.write A n w) :
    M.write w = M'.write w := by
  obtain ⟨b, off, bs⟩ := w
  obtain ⟨hb, hbs⟩ := hx
  simp only [Map.write, h.a b hb, bytes_agree h hbs]

end

/-! ### Monotonicity -/

theorem Supp.nv_mono (_hA : ∀ a, A a → A' a) (hn : n ≤ n') {x : NumV} (hx : Supp.nv A n x) :
    Supp.nv A' n' x := by
  cases x
  · trivial
  · exact Nat.lt_of_lt_of_le hx hn

theorem Supp.mem_mono (hA : ∀ a, A a → A' a) (_hn : n ≤ n') {m : Mem} (hx : Supp.mem A n m) :
    Supp.mem A' n' m := by
  cases m
  · exact hA _ hx
  · trivial

theorem Supp.sym_mono (hA : ∀ a, A a → A' a) (_hn : n ≤ n') {i : Nat} (hx : Supp.sym A n i) :
    Supp.sym A' n' i :=
  fun hi => hA _ (hx hi)

theorem Supp.env_mono (hA : ∀ a, A a → A' a) (_hn : n ≤ n') {e : Env} (hx : Supp.env A n e) :
    Supp.env A' n' e :=
  fun x hm => hA _ (hx x hm)

section
variable (hA : ∀ a, A a → A' a) (hn : n ≤ n')
include hA hn

theorem Supp.val_mono {x : Val} (hx : Supp.val A n x) : Supp.val A' n' x := by
  cases x <;> simp_all [Supp.val, Supp.nv_mono hA hn, Supp.sym_mono hA hn, Supp.mem_mono hA hn]

theorem Supp.key_mono {k : PKey} (hx : Supp.key A n k) : Supp.key A' n' k := by
  cases k <;> simp_all [Supp.key, Supp.sym_mono hA hn]

theorem Supp.okey_mono {k : Option PKey} (hx : Supp.okey A n k) : Supp.okey A' n' k := by
  cases k <;> simp_all [Supp.okey, Supp.key_mono hA hn]

theorem Supp.keys_mono {ks : List PKey} (hx : Supp.keys A n ks) : Supp.keys A' n' ks :=
  fun k hk => Supp.key_mono hA hn (hx k hk)

theorem Supp.prop_mono {p : PropV} (hx : Supp.prop A n p) : Supp.prop A' n' p := by
  cases p <;> simp_all [Supp.prop, Supp.val_mono hA hn]

theorem Supp.props_mono {ps : Props} (hx : Supp.props A n ps) : Supp.props A' n' ps :=
  fun x hm => ⟨Supp.key_mono hA hn (hx x hm).1, Supp.prop_mono hA hn (hx x hm).2⟩

theorem Supp.vals_mono {vs : List Val} (hx : Supp.vals A n vs) : Supp.vals A' n' vs :=
  fun v hv => Supp.val_mono hA hn (hx v hv)

theorem Supp.cell_mono {c : Cell} (hx : Supp.cell A n c) : Supp.cell A' n' c := by
  cases c <;> simp_all [Supp.cell, Supp.nv_mono hA hn]

theorem Supp.byte_mono {b : Byte} (hx : Supp.byte A n b) : Supp.byte A' n' b := by
  cases b <;> simp_all [Supp.byte, Supp.cell_mono hA hn]

theorem Supp.bytes_mono {bs : List Byte} (hx : Supp.bytes A n bs) : Supp.bytes A' n' bs :=
  fun b hb => Supp.byte_mono hA hn (hx b hb)

theorem Supp.abr_mono {a : Abrupt} (hx : Supp.abr A n a) : Supp.abr A' n' a := by
  cases a <;> simp_all [Supp.abr, Supp.val_mono hA hn]

theorem Supp.comp_mono {c : Comp} (hx : Supp.comp A n c) : Supp.comp A' n' c := by
  cases c <;> simp_all [Supp.comp, Supp.val_mono hA hn, Supp.abr_mono hA hn]

theorem Supp.inst_mono {i : InstMember} (hx : Supp.inst A n i) : Supp.inst A' n' i := by
  cases i <;> simp_all [Supp.inst, Supp.key_mono hA hn, Supp.prop_mono hA hn]

theorem Supp.insts_mono {is : List InstMember} (hx : Supp.insts A n is) : Supp.insts A' n' is :=
  fun i hi => Supp.inst_mono hA hn (hx i hi)

theorem Supp.bnd_mono {b : Boundary} (hx : Supp.bnd A n b) : Supp.bnd A' n' b := by
  cases b <;> simp_all [Supp.bnd, Supp.val_mono hA hn]

theorem Supp.src_mono {s : IterSrc} (hx : Supp.src A n s) : Supp.src A' n' s := by
  cases s <;> simp_all [Supp.src, Supp.val_mono hA hn]

theorem Supp.pairs_mono {ps : List (Val × Val)} (hx : Supp.pairs A n ps) : Supp.pairs A' n' ps :=
  fun x hm => ⟨Supp.val_mono hA hn (hx x hm).1, Supp.val_mono hA hn (hx x hm).2⟩

theorem Supp.callF_mono {f : CallF} (hx : Supp.callF A n f) : Supp.callF A' n' f := by
  cases f <;> simp_all [Supp.callF, Supp.key_mono hA hn, Supp.val_mono hA hn, Supp.vals_mono hA hn,
    Supp.env_mono hA hn]

theorem Supp.exprF_mono {f : ExprF} (hx : Supp.exprF A n f) : Supp.exprF A' n' f := by
  cases f <;> simp_all [Supp.exprF, Supp.key_mono hA hn, Supp.val_mono hA hn, Supp.env_mono hA hn]

theorem Supp.litF_mono {f : LitF} (hx : Supp.litF A n f) : Supp.litF A' n' f := by
  cases f <;> simp_all [Supp.litF, Supp.key_mono hA hn, Supp.val_mono hA hn, Supp.vals_mono hA hn,
    Supp.env_mono hA hn]

theorem Supp.target_mono {t : Target} (hx : Supp.target A n t) : Supp.target A' n' t := by
  cases t <;> simp_all [Supp.target, Supp.key_mono hA hn, Supp.val_mono hA hn, Supp.env_mono hA hn]

theorem Supp.asgF_mono {f : AsgF} (hx : Supp.asgF A n f) : Supp.asgF A' n' f := by
  cases f <;> simp_all [Supp.asgF, Supp.okey_mono hA hn, Supp.target_mono hA hn,
    Supp.val_mono hA hn, Supp.env_mono hA hn]

theorem Supp.stmtF_mono {f : StmtF} (hx : Supp.stmtF A n f) : Supp.stmtF A' n' f := by
  cases f <;> simp_all [Supp.stmtF, Supp.pairs_mono hA hn, Supp.comp_mono hA hn,
    Supp.val_mono hA hn, Supp.env_mono hA hn]

theorem Supp.loopF_mono {f : LoopF} (hx : Supp.loopF A n f) : Supp.loopF A' n' f := by
  cases f <;> simp_all [Supp.loopF, Supp.src_mono hA hn, Supp.comp_mono hA hn,
    Supp.val_mono hA hn, Supp.env_mono hA hn]

theorem Supp.bindF_mono {f : BindF} (hx : Supp.bindF A n f) : Supp.bindF A' n' f := by
  cases f <;> simp_all [Supp.bindF, Supp.keys_mono hA hn, Supp.key_mono hA hn,
    Supp.val_mono hA hn, Supp.vals_mono hA hn, Supp.env_mono hA hn]

theorem Supp.fnF_mono {f : FnF} (hx : Supp.fnF A n f) : Supp.fnF A' n' f := by
  cases f
  case modules r => exact fun x hm => Supp.env_mono hA hn (hx x hm)
  all_goals simp_all [Supp.fnF, Supp.insts_mono hA hn, Supp.bnd_mono hA hn, Supp.key_mono hA hn,
    Supp.val_mono hA hn, Supp.vals_mono hA hn, Supp.env_mono hA hn]

theorem Supp.frame_mono {f : Frame} (hx : Supp.frame A n f) : Supp.frame A' n' f := by
  cases f <;> simp_all [Supp.frame, Supp.exprF_mono hA hn, Supp.callF_mono hA hn,
    Supp.litF_mono hA hn, Supp.asgF_mono hA hn, Supp.stmtF_mono hA hn, Supp.loopF_mono hA hn,
    Supp.bindF_mono hA hn, Supp.fnF_mono hA hn]

theorem Supp.ctl_mono {c : Ctl} (hx : Supp.ctl A n c) : Supp.ctl A' n' c := by
  cases c <;> simp_all [Supp.ctl, Supp.abr_mono hA hn, Supp.comp_mono hA hn, Supp.val_mono hA hn,
    Supp.vals_mono hA hn, Supp.env_mono hA hn]

theorem Supp.stores_mono {ss : List (Nat × Val)} (hx : Supp.stores A n ss) :
    Supp.stores A' n' ss :=
  fun x hm => ⟨hA _ (hx x hm).1, Supp.val_mono hA hn (hx x hm).2⟩

theorem Supp.susp_mono {u : Susp} (hx : Supp.susp A n u) : Supp.susp A' n' u := by
  obtain ⟨hf, hs⟩ := hx
  exact ⟨fun f hm => Supp.frame_mono hA hn (hf f hm), Supp.stores_mono hA hn hs⟩

theorem Supp.gen_mono {g : GenState} (hx : Supp.gen A n g) : Supp.gen A' n' g := by
  cases g <;> simp_all [Supp.gen, Supp.susp_mono hA hn, Supp.env_mono hA hn]

theorem Supp.reaction_mono {r : Reaction} (hx : Supp.reaction A n r) : Supp.reaction A' n' r := by
  cases r <;> simp_all [Supp.reaction, Supp.susp_mono hA hn, Supp.stores_mono hA hn,
    Supp.val_mono hA hn]

theorem Supp.pstate_mono {p : PState} (hx : Supp.pstate A n p) : Supp.pstate A' n' p := by
  cases p
  case pending rs => exact fun r hm => Supp.reaction_mono hA hn (hx r hm)
  all_goals simp_all [Supp.pstate, Supp.val_mono hA hn]

theorem Supp.code_mono {c : Code} (hx : Supp.code A n c) : Supp.code A' n' c := by
  cases c <;> simp_all [Supp.code, Supp.insts_mono hA hn, Supp.val_mono hA hn, Supp.vals_mono hA hn,
    Supp.env_mono hA hn]

theorem Supp.kind_mono {k : Kind} (hx : Supp.kind A n k) : Supp.kind A' n' k := by
  cases k
  case gen g a q =>
    obtain ⟨hg, hq⟩ := hx
    exact ⟨Supp.gen_mono hA hn hg,
      fun x hm => ⟨hA _ (hq x hm).1, Supp.comp_mono hA hn (hq x hm).2⟩⟩
  all_goals simp_all [Supp.kind, Supp.bytes_mono hA hn, Supp.code_mono hA hn,
    Supp.pairs_mono hA hn, Supp.pstate_mono hA hn, Supp.val_mono hA hn, Supp.vals_mono hA hn,
    Supp.env_mono hA hn]

theorem Supp.obj_mono {o : Obj} (hx : Supp.obj A n o) : Supp.obj A' n' o := by
  obtain ⟨hk, hpr, hps, hpv⟩ := hx
  exact ⟨Supp.kind_mono hA hn hk, Supp.val_mono hA hn hpr, Supp.props_mono hA hn hps,
    fun x hm => ⟨hA _ (hpv x hm).1, Supp.prop_mono hA hn (hpv x hm).2⟩⟩

theorem Supp.hobj_mono {o : HObj} (hx : Supp.hobj A n o) : Supp.hobj A' n' o := by
  cases o with
  | cell v => cases v <;> simp_all [Supp.hobj, Supp.val_mono hA hn]
  | obj o => exact Supp.obj_mono hA hn hx

theorem Supp.arg_mono {a : Arg} (hx : Supp.arg A n a) : Supp.arg A' n' a := by
  cases a <;> simp_all [Supp.arg, Supp.bytes_mono hA hn, Supp.nv_mono hA hn, Supp.val_mono hA hn]

theorem Supp.args_mono {as : List Arg} (hx : Supp.args A n as) : Supp.args A' n' as :=
  fun a ha => Supp.arg_mono hA hn (hx a ha)

theorem Supp.ret_mono {r : Ret} (hx : Supp.ret A n r) : Supp.ret A' n' r := by
  cases r <;> simp_all [Supp.ret, Supp.args_mono hA hn, Supp.nv_mono hA hn]

theorem Supp.event_mono {e : Event} (hx : Supp.event A n e) : Supp.event A' n' e := by
  obtain ⟨ha, hr⟩ := hx
  exact ⟨Supp.args_mono hA hn ha, Supp.ret_mono hA hn hr⟩

theorem Supp.job_mono {j : Job} (hx : Supp.job A n j) : Supp.job A' n' j := by
  obtain ⟨hr, hv⟩ := hx
  exact ⟨Supp.reaction_mono hA hn hr, Supp.val_mono hA hn hv⟩

theorem Supp.write_mono {w : Nat × Nat × List Byte} (hx : Supp.write A n w) :
    Supp.write A' n' w := by
  obtain ⟨b, off, bs⟩ := w
  obtain ⟨hb, hbs⟩ := hx
  exact ⟨hA _ hb, Supp.bytes_mono hA hn hbs⟩

end

end

/-! ## Composition -/

/-- `σ`, then `M`. -/
def Map.after (M σ : Map) : Map :=
  ⟨fun x => M.a (σ.a x), fun i => M.nv (σ.num i), fun i => M.big (σ.big i),
    fun r => M.region (σ.region r), fun x => M.node (σ.node x)⟩

section
variable (M σ : Map)

theorem Map.after_a (x : Nat) : (M.after σ).a x = M.a (σ.a x) := rfl
theorem Map.after_big (i : Int) : (M.after σ).big i = M.big (σ.big i) := rfl
theorem Map.after_region (r : Nat) : (M.after σ).region r = M.region (σ.region r) := rfl

theorem Map.nv_after (x : NumV) : M.nv (σ.nv x) = (M.after σ).nv x := by cases x <;> rfl

theorem Map.mem_after (m : Mem) : M.mem (σ.mem m) = (M.after σ).mem m := by cases m <;> rfl

theorem Map.sym_after (i : Nat) : M.sym (σ.sym i) = (M.after σ).sym i := by
  simp only [sym_eq]
  by_cases hi : i < 16
  · simp [hi]
  · have : ¬ σ.a (i - 16) + 16 < 16 := by omega
    simp [hi, this, Map.after_a]

theorem Map.val_after (x : Val) : M.val (σ.val x) = (M.after σ).val x := by
  cases x <;> simp [Map.val, Map.nv_after, Map.sym_after, Map.mem_after, Map.after_a, Map.after_big]

theorem Map.key_after (k : PKey) : M.key (σ.key k) = (M.after σ).key k := by
  cases k <;> simp [Map.key, Map.sym_after]

theorem Map.prop_after (p : PropV) : M.prop (σ.prop p) = (M.after σ).prop p := by
  cases p <;> simp [Map.prop, Map.val_after]

theorem Map.props_after (ps : Props) : M.props (σ.props ps) = (M.after σ).props ps :=
  map_comp (fun ⟨_, _⟩ => by simp [Map.key_after, Map.prop_after]) ps

theorem Map.vals_after (vs : List Val) : M.vals (σ.vals vs) = (M.after σ).vals vs :=
  map_comp (Map.val_after M σ) vs

theorem Map.cell_after (c : Cell) : M.cell (σ.cell c) = (M.after σ).cell c := by
  cases c <;> simp [Map.cell, Map.nv_after, Map.after_big]

theorem Map.byte_after (b : Byte) : M.byte (σ.byte b) = (M.after σ).byte b := by
  cases b <;> simp [Map.byte, Map.cell_after]

theorem Map.abr_after (a : Abrupt) : M.abr (σ.abr a) = (M.after σ).abr a := by
  cases a <;> simp [Map.abr, Map.val_after]

theorem Map.comp_after (c : Comp) : M.comp (σ.comp c) = (M.after σ).comp c := by
  cases c <;> simp [Map.comp, Map.val_after, Map.abr_after]

theorem Map.env_after (e : Env) : M.env (σ.env e) = (M.after σ).env e :=
  map_comp (fun ⟨_, _⟩ => rfl) e

theorem Map.inst_after (i : InstMember) : M.inst (σ.inst i) = (M.after σ).inst i := by
  cases i <;> simp [Map.inst, Map.key_after, Map.prop_after, Map.after_a]

theorem Map.bnd_after (b : Boundary) : M.bnd (σ.bnd b) = (M.after σ).bnd b := by
  cases b <;> simp [Map.bnd, Map.val_after, Map.after_a]

theorem Map.src_after (s : IterSrc) : M.src (σ.src s) = (M.after σ).src s := by
  cases s <;> simp [Map.src, Map.val_after]

theorem Map.pairs_after (ps : List (Val × Val)) : M.pairs (σ.pairs ps) = (M.after σ).pairs ps :=
  map_comp (fun ⟨_, _⟩ => by simp [Map.val_after]) ps

theorem Map.callF_after (f : CallF) : M.callF (σ.callF f) = (M.after σ).callF f := by
  cases f <;> simp [Map.callF, Map.key_after, Map.val_after, Map.vals_after, Map.env_after,
    Map.after_a]

theorem Map.exprF_after (f : ExprF) : M.exprF (σ.exprF f) = (M.after σ).exprF f := by
  cases f <;> simp [Map.exprF, Map.key_after, Map.val_after, Map.env_after, Map.after_a]

theorem Map.litF_after (f : LitF) : M.litF (σ.litF f) = (M.after σ).litF f := by
  cases f <;> simp [Map.litF, Map.key_after, Map.val_after, Map.vals_after, Map.env_after,
    Map.after_a]

theorem Map.target_after (t : Target) : M.target (σ.target t) = (M.after σ).target t := by
  cases t <;> simp [Map.target, Map.key_after, Map.val_after, Map.env_after, Map.after_a]

theorem Map.asgF_after (f : AsgF) : M.asgF (σ.asgF f) = (M.after σ).asgF f := by
  cases f <;> simp [Map.asgF, opt_comp (Map.key_after M σ), Map.target_after, Map.val_after,
    Map.env_after, Map.after_a]

theorem Map.stmtF_after (f : StmtF) : M.stmtF (σ.stmtF f) = (M.after σ).stmtF f := by
  cases f <;> simp [Map.stmtF, Map.pairs_after, Map.comp_after, Map.val_after, Map.env_after]

theorem Map.loopF_after (f : LoopF) : M.loopF (σ.loopF f) = (M.after σ).loopF f := by
  cases f <;> simp [Map.loopF, Map.src_after, Map.comp_after, Map.val_after, Map.env_after]

theorem Map.bindF_after (f : BindF) : M.bindF (σ.bindF f) = (M.after σ).bindF f := by
  cases f <;> simp [Map.bindF, map_comp (Map.key_after M σ), Map.key_after, Map.val_after,
    Map.vals_after, Map.env_after]

theorem Map.fnF_after (f : FnF) : M.fnF (σ.fnF f) = (M.after σ).fnF f := by
  cases f
  case modules r =>
    exact congrArg FnF.modules (map_comp (fun ⟨_, _⟩ => by simp [Map.env_after]) r)
  all_goals simp [Map.fnF, map_comp (Map.inst_after M σ), Map.bnd_after, Map.key_after,
    Map.val_after, Map.vals_after, Map.env_after, Map.after_a]

theorem Map.frame_after (f : Frame) : M.frame (σ.frame f) = (M.after σ).frame f := by
  cases f <;> simp [Map.frame, Map.exprF_after, Map.callF_after, Map.litF_after, Map.asgF_after,
    Map.stmtF_after, Map.loopF_after, Map.bindF_after, Map.fnF_after]

theorem Map.ctl_after (c : Ctl) : M.ctl (σ.ctl c) = (M.after σ).ctl c := by
  cases c <;> simp [Map.ctl, Map.abr_after, Map.comp_after, Map.val_after, Map.vals_after,
    Map.env_after]

theorem Map.stores_after (ss : List (Nat × Val)) :
    M.stores (σ.stores ss) = (M.after σ).stores ss :=
  map_comp (fun ⟨_, _⟩ => by simp [Map.val_after, Map.after_a]) ss

theorem Map.susp_after (u : Susp) : M.susp (σ.susp u) = (M.after σ).susp u := by
  cases u; simp [Map.susp, map_comp (Map.frame_after M σ), Map.stores_after]

theorem Map.gen_after (g : GenState) : M.gen (σ.gen g) = (M.after σ).gen g := by
  cases g <;> simp [Map.gen, Map.susp_after, Map.env_after]

theorem Map.reaction_after (r : Reaction) :
    M.reaction (σ.reaction r) = (M.after σ).reaction r := by
  cases r <;> simp [Map.reaction, Map.susp_after, Map.stores_after, Map.val_after, Map.after_a]

theorem Map.pstate_after (p : PState) : M.pstate (σ.pstate p) = (M.after σ).pstate p := by
  cases p <;> simp [Map.pstate, map_comp (Map.reaction_after M σ), Map.val_after]

theorem Map.code_after (c : Code) : M.code (σ.code c) = (M.after σ).code c := by
  cases c <;> simp [Map.code, map_comp (Map.inst_after M σ), Map.val_after, Map.vals_after,
    Map.env_after]

theorem Map.kind_after (k : Kind) : M.kind (σ.kind k) = (M.after σ).kind k := by
  cases k
  case gen g a q =>
    simp only [Map.kind, Map.gen_after]
    exact congrArg _ (map_comp (fun ⟨_, _⟩ => by simp [Map.comp_after, Map.after_a]) q)
  case ns ex => exact congrArg Kind.ns (map_comp (fun ⟨_, _⟩ => rfl) ex)
  all_goals simp [Map.kind, map_comp (Map.byte_after M σ), Map.code_after, Map.pairs_after,
    Map.pstate_after, Map.val_after, Map.vals_after, Map.after_a, Map.after_region]

theorem Map.obj_after (o : Obj) : M.obj (σ.obj o) = (M.after σ).obj o := by
  obtain ⟨k, pr, ps, pv, ex⟩ := o
  simp only [Map.obj, Map.kind_after, Map.val_after, Map.props_after]
  congr 1
  exact map_comp (fun ⟨⟨_, _⟩, _⟩ => by simp [Map.prop_after, Map.after_a]) pv

theorem Map.hobj_after (o : HObj) : M.hobj (σ.hobj o) = (M.after σ).hobj o := by
  cases o with
  | cell v => cases v <;> simp [Map.hobj, Map.val_after]
  | obj o => simp [Map.hobj, Map.obj_after]

theorem Map.arg_after (a : Arg) : M.arg (σ.arg a) = (M.after σ).arg a := by
  cases a <;> simp [Map.arg, map_comp (Map.byte_after M σ), Map.nv_after, Map.val_after,
    Map.after_a, Map.after_big, Map.after_region]

theorem Map.ret_after (r : Ret) : M.ret (σ.ret r) = (M.after σ).ret r := by
  cases r <;> simp [Map.ret, map_comp (Map.arg_after M σ), Map.nv_after, Map.after_big,
    Map.after_region]

theorem Map.event_after (e : Event) : M.event (σ.event e) = (M.after σ).event e := by
  cases e; simp [Map.event, map_comp (Map.arg_after M σ), Map.ret_after]

theorem Map.job_after (j : Job) : M.job (σ.job j) = (M.after σ).job j := by
  cases j; simp [Map.job, Map.reaction_after, Map.val_after]

theorem Map.write_after (w : Nat × Nat × List Byte) :
    M.write (σ.write w) = (M.after σ).write w := by
  obtain ⟨b, off, bs⟩ := w; simp [Map.write, map_comp (Map.byte_after M σ), Map.after_a]

end

end Host.Ts.Sim
