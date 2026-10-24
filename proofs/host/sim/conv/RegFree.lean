import host.sim.BigFreeImage
import host.sim.Support
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim

/-! # Images under a change of the region map, and maps fixing a band

`M.withRegion g` replaces the region map of `M` by `g`. JavaScript data sends regions through
`M.region` only at native pointers (`Mem.ext`), external buffers (`Kind.extBuf`), and the native
pointer arguments and returns of events. `NoReg.foo R x`: no such region of `x` lies in `R`; if
`g` agrees with `M.region` outside `R`, `x` has the same image under `M.withRegion g` and `M`
(`_reregion`, the region counterpart of `host.sim.BigFreeImage`'s `_rebig`).

`Map.hobj_fix`: **a map fixes the entries of a band** when it fixes the band's addresses and its
first `n` references, and agrees with the identity on every bigint outside `I` and every region
outside `R`, for entries supported in the band, free of `I` and of `R`. This is what makes a
stage conversion's static band free: the band's entries are checked once per stage template
(support, `NoBig`, `NoReg`), and the conversion's map is checked only on its exceptions
(`Iso.heap_of_band`, `host.sim.conv.Band`). -/

def _root_.Host.Ts.Sim.Map.withRegion (M : Map) (g : Nat → Nat) : Map := { M with region := g }

section
variable (R : Nat → Prop)

def NoReg.mem : Mem → Prop
  | .js _ => True
  | .ext r => ¬ R r

def NoReg.val : Val → Prop
  | .ptr m _ => NoReg.mem R m
  | _ => True

def NoReg.prop : PropV → Prop
  | .data v _ _ => NoReg.val R v
  | .acc g s _ => NoReg.val R g ∧ NoReg.val R s

def NoReg.props (ps : Props) : Prop := ∀ x ∈ ps, NoReg.prop R x.2

def NoReg.vals (vs : List Val) : Prop := ∀ v ∈ vs, NoReg.val R v

def NoReg.abr : Abrupt → Prop
  | .throw v => NoReg.val R v
  | .ret v => NoReg.val R v
  | _ => True

def NoReg.comp : Comp → Prop
  | .normal v => NoReg.val R v
  | .abrupt a => NoReg.abr R a

def NoReg.inst : InstMember → Prop
  | .field _ _ => True
  | .privField _ _ _ => True
  | .privMethod _ _ p => NoReg.prop R p

def NoReg.insts (is : List InstMember) : Prop := ∀ i ∈ is, NoReg.inst R i

def NoReg.bnd : Boundary → Prop
  | .ctor t => NoReg.val R t
  | _ => True

def NoReg.src : IterSrc → Prop
  | .index v _ => NoReg.val R v
  | .proto it nx => NoReg.val R it ∧ NoReg.val R nx

def NoReg.pairs (ps : List (Val × Val)) : Prop := ∀ x ∈ ps, NoReg.val R x.1 ∧ NoReg.val R x.2

def NoReg.callF : CallF → Prop
  | .indexK o _ _ _ => NoReg.val R o
  | .method t _ _ _ => NoReg.val R t
  | .args _ f t acc _ _ => NoReg.val R f ∧ NoReg.val R t ∧ NoReg.vals R acc
  | .spread _ f t acc _ _ => NoReg.val R f ∧ NoReg.val R t ∧ NoReg.vals R acc
  | _ => True

def NoReg.exprF : ExprF → Prop
  | .binR _ a => NoReg.val R a
  | .indexR o => NoReg.val R o
  | .const v => NoReg.val R v
  | _ => True

def NoReg.litF : LitF → Prop
  | .array acc _ _ => NoReg.vals R acc
  | .spread acc _ _ => NoReg.vals R acc
  | .tagged t _ acc _ _ => NoReg.val R t ∧ NoReg.vals R acc
  | _ => True

def NoReg.target : Target → Prop
  | .prop o _ => NoReg.val R o
  | .priv o _ _ => NoReg.val R o
  | _ => True

def NoReg.asgF : AsgF → Prop
  | .key _ o _ _ => NoReg.val R o
  | .old _ t _ _ => NoReg.target R t
  | .put _ t o => NoReg.target R t ∧ NoReg.val R o
  | .updKey _ _ o => NoReg.val R o
  | .updOld _ _ t => NoReg.target R t
  | _ => True

def NoReg.stmtF : StmtF → Prop
  | .scope res => NoReg.pairs R res
  | .dispose r c => NoReg.pairs R r ∧ NoReg.comp R c
  | .finally_ c => NoReg.comp R c
  | .switchCase d _ _ _ => NoReg.val R d
  | _ => True

def NoReg.loopF : LoopF → Prop
  | .forOfNext it nx _ _ _ _ _ _ => NoReg.val R it ∧ NoReg.val R nx
  | .forOfBody s _ _ _ _ _ _ => NoReg.src R s
  | .close c => NoReg.comp R c
  | _ => True

def NoReg.bindF : BindF → Prop
  | .arr _ _ vs _ _ _ => NoReg.vals R vs
  | .obj s _ _ _ _ _ _ => NoReg.val R s
  | .objKey s _ _ _ _ _ _ _ => NoReg.val R s
  | .objVal s _ _ _ _ _ _ _ _ => NoReg.val R s
  | .collect acc it nx => NoReg.vals R acc ∧ NoReg.val R it ∧ NoReg.val R nx
  | .collectIt acc => NoReg.vals R acc
  | _ => True

def NoReg.fnF : FnF → Prop
  | .fn b => NoReg.bnd R b
  | .params _ _ as _ => NoReg.vals R as
  | .paramDflt _ _ _ as _ => NoReg.vals R as
  | .classMembers _ _ _ is _ => NoReg.insts R is
  | .classKey _ _ _ _ is _ => NoReg.insts R is
  | .classStatic _ _ _ _ is _ => NoReg.insts R is
  | .fields _ ms _ => NoReg.insts R ms
  | .fieldVal _ _ ms _ => NoReg.insts R ms
  | .privVal _ _ _ ms _ => NoReg.insts R ms
  | .ctorBody o _ _ as => NoReg.val R o ∧ NoReg.vals R as
  | .paramProps o _ _ => NoReg.val R o
  | .native _ d => NoReg.vals R d
  | .ystarNext it nx => NoReg.val R it ∧ NoReg.val R nx
  | .ystarResume it nx => NoReg.val R it ∧ NoReg.val R nx
  | .ystarAResult it nx => NoReg.val R it ∧ NoReg.val R nx
  | .ystarAResume it nx => NoReg.val R it ∧ NoReg.val R nx
  | .ystarAReturned it nx => NoReg.val R it ∧ NoReg.val R nx
  | _ => True

def NoReg.frame : Frame → Prop
  | .e f => NoReg.exprF R f
  | .c f => NoReg.callF R f
  | .l f => NoReg.litF R f
  | .a f => NoReg.asgF R f
  | .s f => NoReg.stmtF R f
  | .lp f => NoReg.loopF R f
  | .b f => NoReg.bindF R f
  | .k f => NoReg.fnF R f

def NoReg.ctl : Ctl → Prop
  | .ret v => NoReg.val R v
  | .abr a => NoReg.abr R a
  | .call f t as => NoReg.val R f ∧ NoReg.val R t ∧ NoReg.vals R as
  | .construct f as nt => NoReg.val R f ∧ NoReg.vals R as ∧ NoReg.val R nt
  | .bind _ v _ _ _ => NoReg.val R v
  | .halt c => NoReg.comp R c
  | _ => True

def NoReg.stores (ss : List (Nat × Val)) : Prop := ∀ x ∈ ss, NoReg.val R x.2

def NoReg.susp (u : Susp) : Prop := (∀ f ∈ u.frames, NoReg.frame R f) ∧ NoReg.stores R u.stores

def NoReg.gen : GenState → Prop
  | .suspended u => NoReg.susp R u
  | _ => True

def NoReg.reaction : Reaction → Prop
  | .resume u => NoReg.susp R u
  | .then_ f r _ ss => NoReg.val R f ∧ NoReg.val R r ∧ NoReg.stores R ss
  | _ => True

def NoReg.pstate : PState → Prop
  | .pending rs => ∀ r ∈ rs, NoReg.reaction R r
  | .fulfilled v => NoReg.val R v
  | .rejected v => NoReg.val R v

def NoReg.code : Code → Prop
  | .closure _ _ _ h => NoReg.val R h
  | .klass _ _ p is => NoReg.val R p ∧ NoReg.insts R is
  | .native _ d => NoReg.vals R d
  | .bound t th as => NoReg.val R t ∧ NoReg.val R th ∧ NoReg.vals R as

def NoReg.kind : Kind → Prop
  | .array es => NoReg.vals R es
  | .fn c => NoReg.code R c
  | .extBuf r _ _ => ¬ R r
  | .map m => NoReg.pairs R m
  | .set m => NoReg.vals R m
  | .promise p => NoReg.pstate R p
  | .gen g _ q => NoReg.gen R g ∧ ∀ x ∈ q, NoReg.comp R x.2
  | .box v => NoReg.val R v
  | .iter s _ _ => NoReg.val R s
  | _ => True

def NoReg.obj (o : Obj) : Prop :=
  NoReg.kind R o.kind ∧ NoReg.val R o.proto ∧ NoReg.props R o.props ∧ ∀ x ∈ o.priv, NoReg.prop R x.2

def NoReg.hobj : HObj → Prop
  | .cell none => True
  | .cell (some v) => NoReg.val R v
  | .obj o => NoReg.obj R o

def NoReg.arg : Arg → Prop
  | .extPtr r _ => ¬ R r
  | .other v => NoReg.val R v
  | _ => True

def NoReg.args (as : List Arg) : Prop := ∀ a ∈ as, NoReg.arg R a

def NoReg.ret : Ret → Prop
  | .ptr r _ => ¬ R r
  | .callback f as => ¬ R f ∧ NoReg.args R as
  | _ => True

def NoReg.event (e : Event) : Prop := NoReg.args R e.args ∧ NoReg.ret R e.ret

def NoReg.job (j : Job) : Prop := NoReg.reaction R j.r ∧ NoReg.val R j.v

end

/-! ## Agreement -/

private theorem map_rereg {α β : Type} {P : α → Prop} {f g : α → β} {l : List α}
    (hl : ∀ x ∈ l, P x) (h : ∀ x, P x → f x = g x) : l.map f = l.map g :=
  List.map_congr_left fun x hx => h x (hl x hx)

section
variable {R : Nat → Prop} {M : Map} {g : Nat → Nat}

theorem Map.withRegion_a (x : Nat) : (M.withRegion g).a x = M.a x := rfl
theorem Map.withRegion_num (i : Nat) : (M.withRegion g).num i = M.num i := rfl
theorem Map.withRegion_big (i : Int) : (M.withRegion g).big i = M.big i := rfl
theorem Map.withRegion_node (x : Nat) : (M.withRegion g).node x = M.node x := rfl
theorem Map.nv_withRegion (x : NumV) : (M.withRegion g).nv x = M.nv x := by cases x <;> rfl
theorem Map.sym_withRegion (i : Nat) : (M.withRegion g).sym i = M.sym i := rfl
theorem Map.key_withRegion (k : PKey) : (M.withRegion g).key k = M.key k := by cases k <;> rfl
theorem Map.env_withRegion (e : Env) : (M.withRegion g).env e = M.env e := rfl
theorem Map.keys_withRegion (ks : List PKey) : ks.map (M.withRegion g).key = ks.map M.key :=
  List.map_congr_left fun k _ => Map.key_withRegion k
theorem Map.okey_withRegion (k : Option PKey) : k.map (M.withRegion g).key = k.map M.key := by
  cases k <;> simp [Map.key_withRegion]
theorem Map.cell_withRegion (c : Cell) : (M.withRegion g).cell c = M.cell c := by cases c <;> rfl
theorem Map.byte_withRegion (b : Byte) : (M.withRegion g).byte b = M.byte b := by
  cases b with
  | lit _ => rfl
  | part k c i => exact congrArg (fun c => Byte.part k c i) (Map.cell_withRegion c)
theorem Map.bytes_withRegion (bs : List Byte) : bs.map (M.withRegion g).byte = bs.map M.byte :=
  List.map_congr_left fun b _ => Map.byte_withRegion b

variable (hg : ∀ r, ¬ R r → g r = M.region r)
include hg

attribute [local simp] Map.withRegion_a Map.withRegion_num Map.withRegion_big Map.nv_withRegion Map.sym_withRegion Map.key_withRegion Map.env_withRegion
  Map.keys_withRegion Map.okey_withRegion Map.bytes_withRegion

theorem Map.mem_reregion {m : Mem} (hx : NoReg.mem R m) : (M.withRegion g).mem m = M.mem m := by
  cases m with
  | js _ => rfl
  | ext r => exact congrArg Mem.ext (hg r hx)

theorem Map.val_reregion {x : Val} (hx : NoReg.val R x) : (M.withRegion g).val x = M.val x := by
  cases x with
  | ptr m off => exact congrArg (fun m => Val.ptr m off) (Map.mem_reregion hg hx)
  | num x => exact congrArg Val.num (Map.nv_withRegion x)
  | _ => rfl

theorem Map.prop_reregion {p : PropV} (hx : NoReg.prop R p) : (M.withRegion g).prop p = M.prop p := by
  cases p <;> simp_all [Map.prop, NoReg.prop, Map.val_reregion hg]

theorem Map.props_reregion {ps : Props} (hx : NoReg.props R ps) : (M.withRegion g).props ps = M.props ps :=
  map_rereg hx fun ⟨_, _⟩ hp => by simp [Map.prop_reregion hg hp]

theorem Map.vals_reregion {vs : List Val} (hx : NoReg.vals R vs) : (M.withRegion g).vals vs = M.vals vs :=
  map_rereg hx fun _ hv => Map.val_reregion hg hv

theorem Map.abr_reregion {a : Abrupt} (hx : NoReg.abr R a) : (M.withRegion g).abr a = M.abr a := by
  cases a <;> simp_all [Map.abr, NoReg.abr, Map.val_reregion hg]

theorem Map.comp_reregion {c : Comp} (hx : NoReg.comp R c) : (M.withRegion g).comp c = M.comp c := by
  cases c <;> simp_all [Map.comp, NoReg.comp, Map.val_reregion hg, Map.abr_reregion hg]

theorem Map.inst_reregion {i : InstMember} (hx : NoReg.inst R i) : (M.withRegion g).inst i = M.inst i := by
  cases i <;> simp_all [Map.inst, NoReg.inst, Map.prop_reregion hg]

theorem Map.insts_reregion {is : List InstMember} (hx : NoReg.insts R is) :
    is.map (M.withRegion g).inst = is.map M.inst :=
  map_rereg hx fun _ h => Map.inst_reregion hg h

theorem Map.bnd_reregion {x : Boundary} (hx : NoReg.bnd R x) : (M.withRegion g).bnd x = M.bnd x := by
  cases x <;> simp_all [Map.bnd, NoReg.bnd, Map.val_reregion hg]

theorem Map.src_reregion {s : IterSrc} (hx : NoReg.src R s) : (M.withRegion g).src s = M.src s := by
  cases s <;> simp_all [Map.src, NoReg.src, Map.val_reregion hg]

theorem Map.pairs_reregion {ps : List (Val × Val)} (hx : NoReg.pairs R ps) :
    (M.withRegion g).pairs ps = M.pairs ps :=
  map_rereg hx fun ⟨_, _⟩ ⟨h1, h2⟩ => by simp [Map.val_reregion hg h1, Map.val_reregion hg h2]

theorem Map.callF_reregion {f : CallF} (hx : NoReg.callF R f) : (M.withRegion g).callF f = M.callF f := by
  cases f <;> simp_all [Map.callF, NoReg.callF, Map.val_reregion hg, Map.vals_reregion hg]

theorem Map.exprF_reregion {f : ExprF} (hx : NoReg.exprF R f) : (M.withRegion g).exprF f = M.exprF f := by
  cases f <;> simp_all [Map.exprF, NoReg.exprF, Map.val_reregion hg]

theorem Map.litF_reregion {f : LitF} (hx : NoReg.litF R f) : (M.withRegion g).litF f = M.litF f := by
  cases f <;> simp_all [Map.litF, NoReg.litF, Map.val_reregion hg, Map.vals_reregion hg]

theorem Map.target_reregion {t : Target} (hx : NoReg.target R t) : (M.withRegion g).target t = M.target t := by
  cases t <;> simp_all [Map.target, NoReg.target, Map.val_reregion hg]

theorem Map.asgF_reregion {f : AsgF} (hx : NoReg.asgF R f) : (M.withRegion g).asgF f = M.asgF f := by
  cases f <;> simp_all [Map.asgF, NoReg.asgF, Map.target_reregion hg, Map.val_reregion hg]

theorem Map.stmtF_reregion {f : StmtF} (hx : NoReg.stmtF R f) : (M.withRegion g).stmtF f = M.stmtF f := by
  cases f <;> simp_all [Map.stmtF, NoReg.stmtF, Map.pairs_reregion hg, Map.comp_reregion hg,
    Map.val_reregion hg]

theorem Map.loopF_reregion {f : LoopF} (hx : NoReg.loopF R f) : (M.withRegion g).loopF f = M.loopF f := by
  cases f <;> simp_all [Map.loopF, NoReg.loopF, Map.src_reregion hg, Map.comp_reregion hg,
    Map.val_reregion hg]

theorem Map.bindF_reregion {f : BindF} (hx : NoReg.bindF R f) : (M.withRegion g).bindF f = M.bindF f := by
  cases f <;> simp_all [Map.bindF, NoReg.bindF, Map.val_reregion hg, Map.vals_reregion hg]

theorem Map.fnF_reregion {f : FnF} (hx : NoReg.fnF R f) : (M.withRegion g).fnF f = M.fnF f := by
  cases f
  case modules r => rfl
  all_goals simp_all [Map.fnF, NoReg.fnF, Map.insts_reregion hg, Map.bnd_reregion hg, Map.val_reregion hg,
    Map.vals_reregion hg]

theorem Map.frame_reregion {f : Frame} (hx : NoReg.frame R f) : (M.withRegion g).frame f = M.frame f := by
  cases f <;> simp_all [Map.frame, NoReg.frame, Map.exprF_reregion hg, Map.callF_reregion hg,
    Map.litF_reregion hg, Map.asgF_reregion hg, Map.stmtF_reregion hg, Map.loopF_reregion hg,
    Map.bindF_reregion hg, Map.fnF_reregion hg]

theorem Map.ctl_reregion {c : Ctl} (hx : NoReg.ctl R c) : (M.withRegion g).ctl c = M.ctl c := by
  cases c <;> simp_all [Map.ctl, NoReg.ctl, Map.abr_reregion hg, Map.comp_reregion hg, Map.val_reregion hg,
    Map.vals_reregion hg]

theorem Map.stores_reregion {ss : List (Nat × Val)} (hx : NoReg.stores R ss) :
    (M.withRegion g).stores ss = M.stores ss :=
  map_rereg hx fun ⟨_, _⟩ hv => by simp [Map.val_reregion hg hv]

theorem Map.susp_reregion {u : Susp} (hx : NoReg.susp R u) : (M.withRegion g).susp u = M.susp u := by
  obtain ⟨fs, ss⟩ := u
  obtain ⟨hf, hs⟩ := hx
  simp only [Map.susp, Map.stores_reregion hg hs, map_rereg hf fun _ => Map.frame_reregion hg]

theorem Map.gen_reregion {x : GenState} (hx : NoReg.gen R x) : (M.withRegion g).gen x = M.gen x := by
  cases x <;> simp_all [Map.gen, NoReg.gen, Map.susp_reregion hg]

theorem Map.reaction_reregion {r : Reaction} (hx : NoReg.reaction R r) :
    (M.withRegion g).reaction r = M.reaction r := by
  cases r <;> simp_all [Map.reaction, NoReg.reaction, Map.susp_reregion hg, Map.stores_reregion hg,
    Map.val_reregion hg]

theorem Map.pstate_reregion {p : PState} (hx : NoReg.pstate R p) : (M.withRegion g).pstate p = M.pstate p := by
  cases p
  case pending rs => exact congrArg PState.pending (map_rereg hx fun _ => Map.reaction_reregion hg)
  all_goals simp_all [Map.pstate, NoReg.pstate, Map.val_reregion hg]

theorem Map.code_reregion {c : Code} (hx : NoReg.code R c) : (M.withRegion g).code c = M.code c := by
  cases c <;> simp_all [Map.code, NoReg.code, Map.insts_reregion hg, Map.val_reregion hg, Map.vals_reregion hg]
   

theorem Map.kind_reregion {k : Kind} (hx : NoReg.kind R k) : (M.withRegion g).kind k = M.kind k := by
  cases k
  case gen x a q =>
    obtain ⟨hx', hq⟩ := hx
    simp only [Map.kind, Map.gen_reregion hg hx']
    exact congrArg _ (map_rereg hq fun ⟨p, _⟩ hc => by simp [Map.comp_reregion hg hc])
  case extBuf r o l => exact congrArg (fun r => Kind.extBuf r o l) (hg r hx)
  case ns ex => rfl
  all_goals simp_all [Map.kind, NoReg.kind, Map.code_reregion hg, Map.pairs_reregion hg,
    Map.pstate_reregion hg, Map.val_reregion hg, Map.vals_reregion hg]

theorem Map.obj_reregion {o : Obj} (hx : NoReg.obj R o) : (M.withRegion g).obj o = M.obj o := by
  obtain ⟨k, pr, ps, pv, ex⟩ := o
  obtain ⟨hk, hpr, hps, hpv⟩ := hx
  simp only [Map.obj, Map.kind_reregion hg hk, Map.val_reregion hg hpr, Map.props_reregion hg hps]
  congr 1
  exact map_rereg hpv fun ⟨⟨_, _⟩, _⟩ hp => by simp [Map.prop_reregion hg hp]

theorem Map.hobj_reregion {o : HObj} (hx : NoReg.hobj R o) : (M.withRegion g).hobj o = M.hobj o := by
  cases o with
  | cell v => cases v <;> simp_all [Map.hobj, NoReg.hobj, Map.val_reregion hg]
  | obj o => simp_all [Map.hobj, NoReg.hobj, Map.obj_reregion hg]

theorem Map.arg_reregion {a : Arg} (hx : NoReg.arg R a) : (M.withRegion g).arg a = M.arg a := by
  cases a with
  | extPtr r o => exact congrArg (fun r => Arg.extPtr r o) (hg r hx)
  | jsPtr x o bs => exact congrArg (Arg.jsPtr (M.a x) o) (Map.bytes_withRegion bs)
  | other v => exact congrArg Arg.other (Map.val_reregion hg hx)
  | num x => exact congrArg Arg.num (Map.nv_withRegion x)
  | big _ => rfl
  | null => rfl
  | bool _ => rfl

theorem Map.args_reregion {as : List Arg} (hx : NoReg.args R as) :
    as.map (M.withRegion g).arg = as.map M.arg :=
  map_rereg hx fun _ h => Map.arg_reregion hg h

theorem Map.ret_reregion {r : Ret} (hx : NoReg.ret R r) : (M.withRegion g).ret r = M.ret r := by
  cases r with
  | ptr r o => exact congrArg (fun r => Ret.ptr r o) (hg r hx)
  | callback f as =>
    show Ret.callback (g f) (as.map (M.withRegion g).arg) = Ret.callback (M.region f) (as.map M.arg)
    rw [hg f hx.1, Map.args_reregion hg hx.2]
  | num x => exact congrArg Ret.num (Map.nv_withRegion x)
  | _ => rfl

theorem Map.event_reregion {e : Event} (hx : NoReg.event R e) : (M.withRegion g).event e = M.event e := by
  obtain ⟨s, as, r⟩ := e
  obtain ⟨ha, hr⟩ := hx
  simp only [Map.event, Map.args_reregion hg ha, Map.ret_reregion hg hr]

theorem Map.job_reregion {j : Job} (hx : NoReg.job R j) : (M.withRegion g).job j = M.job j := by
  obtain ⟨r, t, v⟩ := j
  obtain ⟨hr, hv⟩ := hx
  simp only [Map.job, Map.reaction_reregion hg hr, Map.val_reregion hg hv]

end

/-! ## Maps fixing a band -/

set_option linter.unusedSectionVars false

section
variable {σ : Map} {A : Nat → Prop} {n : Nat} {I : Int → Prop} {R : Nat → Prop}
variable (ha : ∀ x, A x → σ.a x = x) (hn : ∀ i, i < n → σ.num i = .ref i)
  (hb : ∀ i, ¬ I i → σ.big i = i) (hr : ∀ r, ¬ R r → σ.region r = r)
include ha hn hb hr

/-- The identity's names with `σ`'s node map (JavaScript data never reads the node map). -/
private def idWith (σ : Map) : Map := ⟨id, .ref, id, id, σ.node⟩

private theorem fixAgree : Agree A n ((σ.withBig id).withRegion id) (idWith σ) :=
  ⟨fun x hx => ha x hx, fun i hi => hn i hi, rfl, rfl, rfl⟩

private theorem idWith_hobj (h : HObj) : (idWith σ).hobj h = h := by
  have e : (idWith σ).hobj h = Map.id.hobj h := rfl
  rw [e, Map.hobj_id]

/-- **A map fixing a band fixes its entries.** -/
theorem Map.hobj_fix {h : HObj} (hs : Supp.hobj A n h) (hnb : NoBig.hobj I h) (hnr : NoReg.hobj R h) :
    σ.hobj h = h := by
  have e1 : (σ.withBig id).hobj h = σ.hobj h := Map.hobj_rebig (fun i hi => (hb i hi).symm) hnb
  have e2 : ((σ.withBig id).withRegion id).hobj h = (σ.withBig id).hobj h :=
    Map.hobj_reregion (M := σ.withBig id) (fun r hr' => (hr r hr').symm) hnr
  rw [← e1, ← e2, Map.hobj_agree (fixAgree ha hn hb hr) hs, idWith_hobj ha hn hb hr]

theorem Map.frame_fix {f : Frame} (hs : Supp.frame A n f) (hnb : NoBig.frame I f) (hnr : NoReg.frame R f) :
    σ.frame f = f := by
  have e1 : (σ.withBig id).frame f = σ.frame f := Map.frame_rebig (fun i hi => (hb i hi).symm) hnb
  have e2 : ((σ.withBig id).withRegion id).frame f = (σ.withBig id).frame f :=
    Map.frame_reregion (M := σ.withBig id) (fun r hr' => (hr r hr').symm) hnr
  have e3 : (idWith σ).frame f = Map.id.frame f := rfl
  rw [← e1, ← e2, Map.frame_agree (fixAgree ha hn hb hr) hs, e3, Map.frame_id]

theorem Map.ctl_fix {c : Ctl} (hs : Supp.ctl A n c) (hnb : NoBig.ctl I c) (hnr : NoReg.ctl R c) :
    σ.ctl c = c := by
  have e1 : (σ.withBig id).ctl c = σ.ctl c := Map.ctl_rebig (fun i hi => (hb i hi).symm) hnb
  have e2 : ((σ.withBig id).withRegion id).ctl c = (σ.withBig id).ctl c :=
    Map.ctl_reregion (M := σ.withBig id) (fun r hr' => (hr r hr').symm) hnr
  have e3 : (idWith σ).ctl c = Map.id.ctl c := rfl
  rw [← e1, ← e2, Map.ctl_agree (fixAgree ha hn hb hr) hs, e3, Map.ctl_id]

theorem Map.job_fix {j : Job} (hs : Supp.job A n j) (hnb : NoBig.job I j) (hnr : NoReg.job R j) :
    σ.job j = j := by
  have e1 : (σ.withBig id).job j = σ.job j := Map.job_rebig (fun i hi => (hb i hi).symm) hnb
  have e2 : ((σ.withBig id).withRegion id).job j = (σ.withBig id).job j :=
    Map.job_reregion (M := σ.withBig id) (fun r hr' => (hr r hr').symm) hnr
  have e3 : (idWith σ).job j = Map.id.job j := rfl
  rw [← e1, ← e2, Map.job_agree (fixAgree ha hn hb hr) hs, e3, Map.job_id]

theorem Map.stores_fix {ss : List (Nat × Val)} (hs : Supp.stores A n ss) (hnb : NoBig.stores I ss)
    (hnr : NoReg.stores R ss) : σ.stores ss = ss := by
  have e1 : (σ.withBig id).stores ss = σ.stores ss := Map.stores_rebig (fun i hi => (hb i hi).symm) hnb
  have e2 : ((σ.withBig id).withRegion id).stores ss = (σ.withBig id).stores ss :=
    Map.stores_reregion (M := σ.withBig id) (fun r hr' => (hr r hr').symm) hnr
  have e3 : (idWith σ).stores ss = Map.id.stores ss := rfl
  rw [← e1, ← e2, Map.stores_agree (fixAgree ha hn hb hr) hs, e3, Map.stores_id]

end

end Host.Ts.Sim.Conv
