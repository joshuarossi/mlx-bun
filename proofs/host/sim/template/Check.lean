import host.sim.Support
import host.sim.Rel
import host.sim.template.Keys

/-! # Deciding support

Boolean versions `b*` of the support predicates `Supp.*` (`host.sim.Support`),
with soundness lemmas (`b*_sound`). A state's closedness (`Supp.*` of its heap
entries, control, stack, jobs and stores over its present addresses and its
table length) follows from `checkSupp s n = true`, which the kernel decides by
evaluation. -/

namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

section
variable (A : Nat → Bool) (n : Nat)

def bNv : NumV → Bool
  | .lit _ => true
  | .ref i => decide (i < n)

def bMem : Mem → Bool
  | .js b => A b
  | .ext _ => true

def bSym (i : Nat) : Bool := !decide (16 ≤ i) || A (i - 16)

def bVal : Val → Bool
  | .num x => bNv n x
  | .sym i => bSym A i
  | .obj a => A a
  | .ptr m _ => bMem A m
  | _ => true

def bKey : PKey → Bool
  | .str _ => true
  | .sym i => bSym A i

def bOkey : Option PKey → Bool
  | none => true
  | some k => bKey A k

def bKeys (ks : List PKey) : Bool := ks.all (bKey A)

def bProp : PropV → Bool
  | .data v _ _ => bVal A n v
  | .acc g s _ => bVal A n g && bVal A n s

def bProps (ps : Props) : Bool := ps.all fun x => bKey A x.1 && bProp A n x.2

def bVals (vs : List Val) : Bool := vs.all (bVal A n)

def bCell : Cell → Bool
  | .num x => bNv n x
  | .big _ => true

def bByte : Byte → Bool
  | .lit _ => true
  | .part _ c _ => bCell n c

def bBytes (bs : List Byte) : Bool := bs.all (bByte n)

def bAbr : Abrupt → Bool
  | .throw v => bVal A n v
  | .ret v => bVal A n v
  | _ => true

def bComp : Comp → Bool
  | .normal v => bVal A n v
  | .abrupt a => bAbr A n a

def bEnv (e : Env) : Bool := e.all fun x => A x.2

def bInst : InstMember → Bool
  | .field k _ => bKey A k
  | .privField b _ _ => A b
  | .privMethod b _ p => A b && bProp A n p

def bInsts (is : List InstMember) : Bool := is.all (bInst A n)

def bBnd : Boundary → Bool
  | .call => true
  | .ctor t => bVal A n t
  | .derived c => A c
  | .async p => A p
  | .gen g => A g

def bSrc : IterSrc → Bool
  | .index v _ => bVal A n v
  | .proto it nx => bVal A n it && bVal A n nx

def bPairs (ps : List (Val × Val)) : Bool := ps.all fun x => bVal A n x.1 && bVal A n x.2

def bCallF : CallF → Bool
  | .callee _ e _ => bEnv A e
  | .member k _ e _ _ => bKey A k && bEnv A e
  | .index _ _ e _ _ => bEnv A e
  | .indexK o _ e _ => bVal A n o && bEnv A e
  | .priv b _ _ e _ _ => A b && bEnv A e
  | .method t _ e _ => bVal A n t && bEnv A e
  | .args _ f t acc _ e => bVal A n f && bVal A n t && bVals A n acc && bEnv A e
  | .spread _ f t acc _ e => bVal A n f && bVal A n t && bVals A n acc && bEnv A e
  | .newCallee _ e => bEnv A e

def bExprF : ExprF → Bool
  | .unary _ => true
  | .binL _ _ e => bEnv A e
  | .binR _ a => bVal A n a
  | .logL _ _ e => bEnv A e
  | .cond _ _ e => bEnv A e
  | .seq _ e => bEnv A e
  | .member k _ => bKey A k
  | .indexL _ e _ => bEnv A e
  | .indexR o => bVal A n o
  | .priv b _ _ => A b
  | .chain => true
  | .const v => bVal A n v
  | .typeof => true

def bLitF : LitF → Bool
  | .array acc _ e => bVals A n acc && bEnv A e
  | .spread acc _ e => bVals A n acc && bEnv A e
  | .object o _ e => A o && bEnv A e
  | .objKey o _ _ e => A o && bEnv A e
  | .objVal o k _ e => A o && bKey A k && bEnv A e
  | .objSpread o _ e => A o && bEnv A e
  | .tmpl _ _ _ e => bEnv A e
  | .tagged t _ acc _ e => bVal A n t && bVals A n acc && bEnv A e

def bTarget : Target → Bool
  | .var _ e => bEnv A e
  | .prop o k => bVal A n o && bKey A k
  | .priv o b _ => bVal A n o && A b

def bAsgF : AsgF → Bool
  | .pat _ e => bEnv A e
  | .obj _ k _ _ e => bOkey A k && bEnv A e
  | .key _ o _ e => bVal A n o && bEnv A e
  | .privObj _ b _ _ e => A b && bEnv A e
  | .old _ t _ e => bTarget A n t && bEnv A e
  | .put _ t o => bTarget A n t && bVal A n o
  | .updObj _ _ k _ e => bOkey A k && bEnv A e
  | .updKey _ _ o => bVal A n o
  | .updPrivObj _ _ b _ => A b
  | .updOld _ _ t => bTarget A n t

def bStmtF : StmtF → Bool
  | .block _ e => bEnv A e
  | .scope res => bPairs A n res
  | .dispose r c => bPairs A n r && bComp A n c
  | .if_ _ _ e => bEnv A e
  | .decl _ _ _ e => bEnv A e
  | .declNext _ _ e => bEnv A e
  | .ret => true
  | .throw => true
  | .try_ _ _ e => bEnv A e
  | .catch_ _ e => bEnv A e
  | .finally_ c => bComp A n c
  | .label _ => true
  | .switchD _ e => bEnv A e
  | .switchCase d _ _ e => bVal A n d && bEnv A e
  | .switchBody => true

def bLoopF : LoopF → Bool
  | .forTest _ _ _ _ e _ _ => bEnv A e
  | .forBody _ _ _ e _ _ => bEnv A e
  | .forUpd _ _ _ e _ _ => bEnv A e
  | .whileTest _ _ e _ => bEnv A e
  | .whileBody _ _ e _ => bEnv A e
  | .doBody _ _ e _ => bEnv A e
  | .forOfSrc _ _ _ _ e _ => bEnv A e
  | .forOfIt _ _ _ _ e _ => bEnv A e
  | .forOfNext it nx _ _ _ _ e _ => bVal A n it && bVal A n nx && bEnv A e
  | .forOfBody s _ _ _ _ e _ => bSrc A n s && bEnv A e
  | .close c => bComp A n c

def bBindF : BindF → Bool
  | .dflt _ e _ _ => bEnv A e
  | .arr _ _ vs e _ _ => bVals A n vs && bEnv A e
  | .arrSrc _ _ e _ _ => bEnv A e
  | .obj s _ _ u e _ _ => bVal A n s && bKeys A u && bEnv A e
  | .objKey s _ _ _ u e _ _ => bVal A n s && bKeys A u && bEnv A e
  | .objVal s k _ _ _ u e _ _ => bVal A n s && bKey A k && bKeys A u && bEnv A e
  | .collect acc it nx => bVals A n acc && bVal A n it && bVal A n nx
  | .collectIt acc => bVals A n acc

def bFnF : FnF → Bool
  | .fn b => bBnd A n b
  | .params _ _ as e => bVals A n as && bEnv A e
  | .paramDflt _ _ _ as e => bVals A n as && bEnv A e
  | .classHeritage _ e => bEnv A e
  | .classMembers f p _ is e => A f && A p && bInsts A n is && bEnv A e
  | .classKey f p _ _ is e => A f && A p && bInsts A n is && bEnv A e
  | .classStatic f p k _ is e => A f && A p && bKey A k && bInsts A n is && bEnv A e
  | .fields o ms e => A o && bInsts A n ms && bEnv A e
  | .fieldVal o k ms e => A o && bKey A k && bInsts A n ms && bEnv A e
  | .privVal o b _ ms e => A o && A b && bInsts A n ms && bEnv A e
  | .ctorBody o _ e as => bVal A n o && bEnv A e && bVals A n as
  | .superRet c k e => A c && A k && bEnv A e
  | .paramProps o _ e => bVal A n o && bEnv A e
  | .native _ d => bVals A n d
  | .promiseThen p => A p
  | .yield _ => true
  | .ystarIt => true
  | .ystarNext it nx => bVal A n it && bVal A n nx
  | .ystarResume it nx => bVal A n it && bVal A n nx
  | .ystarAIt => true
  | .ystarAResult it nx => bVal A n it && bVal A n nx
  | .ystarAResume it nx => bVal A n it && bVal A n nx
  | .ystarAReturned it nx => bVal A n it && bVal A n nx
  | .ystarAReturn => true
  | .await => true
  | .modules r => r.all fun x => bEnv A x.2

def bFrame : Frame → Bool
  | .e f => bExprF A n f
  | .c f => bCallF A n f
  | .l f => bLitF A n f
  | .a f => bAsgF A n f
  | .s f => bStmtF A n f
  | .lp f => bLoopF A n f
  | .b f => bBindF A n f
  | .k f => bFnF A n f

def bCtl : Ctl → Bool
  | .ev _ en => bEnv A en
  | .ex _ en => bEnv A en
  | .ret v => bVal A n v
  | .abr a => bAbr A n a
  | .call f t as => bVal A n f && bVal A n t && bVals A n as
  | .construct f as nt => bVal A n f && bVals A n as && bVal A n nt
  | .bind _ v e _ _ => bVal A n v && bEnv A e
  | .short => true
  | .halt c => bComp A n c

def bStores (ss : List (Nat × Val)) : Bool := ss.all fun x => A x.1 && bVal A n x.2

def bSusp (u : Susp) : Bool := u.frames.all (bFrame A n) && bStores A n u.stores

def bGen : GenState → Bool
  | .start _ e => bEnv A e
  | .suspended u => bSusp A n u
  | .running => true
  | .done => true

def bReaction : Reaction → Bool
  | .resume u => bSusp A n u
  | .then_ f r d ss => bVal A n f && bVal A n r && A d && bStores A n ss
  | .adopt p => A p
  | .forward p => A p

def bPstate : PState → Bool
  | .pending rs => rs.all (bReaction A n)
  | .fulfilled v => bVal A n v
  | .rejected v => bVal A n v

def bCode : Code → Bool
  | .closure _ e _ h => bEnv A e && bVal A n h
  | .klass _ e p is => bEnv A e && bVal A n p && bInsts A n is
  | .native _ d => bVals A n d
  | .bound t th as => bVal A n t && bVal A n th && bVals A n as

def bKind : Kind → Bool
  | .ordinary => true
  | .array es => bVals A n es
  | .fn c => bCode A n c
  | .buf bs => bBytes n bs
  | .extBuf _ _ _ => true
  | .typed _ b _ _ => A b
  | .view b _ _ => A b
  | .map m => bPairs A n m
  | .set m => bVals A n m
  | .promise p => bPstate A n p
  | .gen g _ q => bGen A n g && q.all fun x => A x.1 && bComp A n x.2
  | .ns ex => bEnv A ex
  | .box v => bVal A n v
  | .iter s _ _ => bVal A n s

def bObj (o : Obj) : Bool :=
  bKind A n o.kind && bVal A n o.proto && bProps A n o.props && o.priv.all fun x => A x.1.1 && bProp A n x.2

def bHobj : HObj → Bool
  | .cell none => true
  | .cell (some v) => bVal A n v
  | .obj o => bObj A n o

def bJob (j : Job) : Bool := bReaction A n j.r && bVal A n j.v

end

/-! ## Soundness -/

section
variable {A : Nat → Bool} {n : Nat}
local notation "P" => fun a => A a = true

attribute [local simp] Bool.and_eq_true List.all_eq_true decide_eq_true_eq Bool.or_eq_true Bool.not_eq_true'

theorem bNv_sound {x : NumV} (h : bNv n x = true) : Supp.nv P n x := by
  cases x <;> simp_all [bNv, Supp.nv]

theorem bMem_sound {m : Mem} (h : bMem A m = true) : Supp.mem P n m := by
  cases m <;> simp_all [bMem, Supp.mem]

theorem bSym_sound {i : Nat} (h : bSym A i = true) : Supp.sym P n i := by
  intro hi
  simp only [bSym, Bool.or_eq_true, Bool.not_eq_true', decide_eq_false_iff_not] at h
  rcases h with h | h
  · exact absurd hi h
  · exact h

theorem bVal_sound {v : Val} (h : bVal A n v = true) : Supp.val P n v := by
  cases v <;> simp only [bVal, Supp.val] at h ⊢ <;> first | trivial | exact h | exact bNv_sound h | exact bSym_sound h | exact bMem_sound h

theorem bKey_sound {k : PKey} (h : bKey A k = true) : Supp.key P n k := by
  cases k <;> simp only [bKey, Supp.key] at h ⊢ <;> first | trivial | exact bSym_sound h

theorem bOkey_sound {k : Option PKey} (h : bOkey A k = true) : Supp.okey P n k := by
  cases k <;> simp only [bOkey, Supp.okey] at h ⊢ <;> first | trivial | exact bKey_sound h

theorem bKeys_sound {ks : List PKey} (h : bKeys A ks = true) : Supp.keys P n ks := by
  simp only [bKeys, List.all_eq_true] at h
  exact fun k hk => bKey_sound (h k hk)

theorem bProp_sound {p : PropV} (h : bProp A n p = true) : Supp.prop P n p := by
  cases p <;> simp only [bProp, Supp.prop, Bool.and_eq_true] at h ⊢
  · exact bVal_sound h
  · exact ⟨bVal_sound h.1, bVal_sound h.2⟩

theorem bProps_sound {ps : Props} (h : bProps A n ps = true) : Supp.props P n ps := by
  simp only [bProps, List.all_eq_true, Bool.and_eq_true] at h
  exact fun x hx => ⟨bKey_sound (h x hx).1, bProp_sound (h x hx).2⟩

theorem bVals_sound {vs : List Val} (h : bVals A n vs = true) : Supp.vals P n vs := by
  simp only [bVals, List.all_eq_true] at h
  exact fun v hv => bVal_sound (h v hv)

theorem bCell_sound {c : Cell} (h : bCell n c = true) : Supp.cell P n c := by
  cases c <;> simp only [bCell, Supp.cell] at h ⊢ <;> first | trivial | exact bNv_sound h

theorem bByte_sound {b : Byte} (h : bByte n b = true) : Supp.byte P n b := by
  cases b <;> simp only [bByte, Supp.byte] at h ⊢ <;> first | trivial | exact bCell_sound h

theorem bBytes_sound {bs : List Byte} (h : bBytes n bs = true) : Supp.bytes P n bs := by
  simp only [bBytes, List.all_eq_true] at h
  exact fun b hb => bByte_sound (h b hb)

theorem bAbr_sound {a : Abrupt} (h : bAbr A n a = true) : Supp.abr P n a := by
  cases a <;> simp only [bAbr, Supp.abr] at h ⊢ <;> first | trivial | exact bVal_sound h

theorem bComp_sound {c : Comp} (h : bComp A n c = true) : Supp.comp P n c := by
  cases c <;> simp only [bComp, Supp.comp] at h ⊢
  · exact bVal_sound h
  · exact bAbr_sound h

theorem bEnv_sound {e : Env} (h : bEnv A e = true) : Supp.env P n e := by
  simp only [bEnv, List.all_eq_true] at h
  exact fun x hx => h x hx

theorem bInst_sound {i : InstMember} (h : bInst A n i = true) : Supp.inst P n i := by
  cases i <;> simp only [bInst, Supp.inst, Bool.and_eq_true] at h ⊢
  · exact bKey_sound h
  · exact h
  · exact ⟨h.1, bProp_sound h.2⟩

theorem bInsts_sound {is : List InstMember} (h : bInsts A n is = true) : Supp.insts P n is := by
  simp only [bInsts, List.all_eq_true] at h
  exact fun i hi => bInst_sound (h i hi)

theorem bBnd_sound {b : Boundary} (h : bBnd A n b = true) : Supp.bnd P n b := by
  cases b <;> simp only [bBnd, Supp.bnd] at h ⊢ <;> first | trivial | exact h | exact bVal_sound h

theorem bSrc_sound {s : IterSrc} (h : bSrc A n s = true) : Supp.src P n s := by
  cases s <;> simp only [bSrc, Supp.src, Bool.and_eq_true] at h ⊢
  · exact bVal_sound h
  · exact ⟨bVal_sound h.1, bVal_sound h.2⟩

theorem bPairs_sound {ps : List (Val × Val)} (h : bPairs A n ps = true) : Supp.pairs P n ps := by
  simp only [bPairs, List.all_eq_true, Bool.and_eq_true] at h
  exact fun x hx => ⟨bVal_sound (h x hx).1, bVal_sound (h x hx).2⟩

-- Destructure a conjunction of checks (`h`) into the matching conjunction of supports.
set_option hygiene false in
macro "supp_parts" : tactic => `(tactic| ((try simp only [Bool.and_eq_true] at h); (try revert h); (try simp only [and_imp]); intros; ((try and_intros) <;>
  first
    | assumption
    | (apply bVal_sound; assumption) | (apply bVals_sound; assumption) | (apply bEnv_sound; assumption)
    | (apply bKey_sound; assumption) | (apply bOkey_sound; assumption) | (apply bKeys_sound; assumption)
    | (apply bInsts_sound; assumption) | (apply bPairs_sound; assumption) | (apply bComp_sound; assumption)
    | (apply bSrc_sound; assumption) | (apply bBnd_sound; assumption) | (apply bProp_sound; assumption)
    | (apply bTarget_sound; assumption) | (apply bAbr_sound; assumption) | trivial)))

theorem bCallF_sound {f : CallF} (h : bCallF A n f = true) : Supp.callF P n f := by
  cases f <;> simp only [bCallF, Supp.callF] at h ⊢ <;> supp_parts

theorem bExprF_sound {f : ExprF} (h : bExprF A n f = true) : Supp.exprF P n f := by
  cases f <;> simp only [bExprF, Supp.exprF] at h ⊢ <;> supp_parts

theorem bLitF_sound {f : LitF} (h : bLitF A n f = true) : Supp.litF P n f := by
  cases f <;> simp only [bLitF, Supp.litF] at h ⊢ <;> supp_parts

theorem bTarget_sound {t : Target} (h : bTarget A n t = true) : Supp.target P n t := by
  cases t <;> simp only [bTarget, Supp.target] at h ⊢ <;> supp_parts

theorem bAsgF_sound {f : AsgF} (h : bAsgF A n f = true) : Supp.asgF P n f := by
  cases f <;> simp only [bAsgF, Supp.asgF] at h ⊢ <;> supp_parts

theorem bStmtF_sound {f : StmtF} (h : bStmtF A n f = true) : Supp.stmtF P n f := by
  cases f <;> simp only [bStmtF, Supp.stmtF] at h ⊢ <;> supp_parts

theorem bLoopF_sound {f : LoopF} (h : bLoopF A n f = true) : Supp.loopF P n f := by
  cases f <;> simp only [bLoopF, Supp.loopF] at h ⊢ <;> supp_parts

theorem bBindF_sound {f : BindF} (h : bBindF A n f = true) : Supp.bindF P n f := by
  cases f <;> simp only [bBindF, Supp.bindF] at h ⊢ <;> supp_parts

theorem bFnF_sound {f : FnF} (h : bFnF A n f = true) : Supp.fnF P n f := by
  cases f
  case modules r =>
    simp only [bFnF, Supp.fnF, List.all_eq_true] at h ⊢
    exact fun x hx => bEnv_sound (h x hx)
  all_goals simp only [bFnF, Supp.fnF] at h ⊢ <;> supp_parts

theorem bFrame_sound {f : Frame} (h : bFrame A n f = true) : Supp.frame P n f := by
  cases f <;> simp only [bFrame, Supp.frame] at h ⊢
  · exact bExprF_sound h
  · exact bCallF_sound h
  · exact bLitF_sound h
  · exact bAsgF_sound h
  · exact bStmtF_sound h
  · exact bLoopF_sound h
  · exact bBindF_sound h
  · exact bFnF_sound h

theorem bCtl_sound {c : Ctl} (h : bCtl A n c = true) : Supp.ctl P n c := by
  cases c <;> simp only [bCtl, Supp.ctl] at h ⊢ <;>
    first | exact bAbr_sound h | (supp_parts)

theorem bStores_sound {ss : List (Nat × Val)} (h : bStores A n ss = true) : Supp.stores P n ss := by
  simp only [bStores, List.all_eq_true, Bool.and_eq_true] at h
  exact fun x hx => ⟨(h x hx).1, bVal_sound (h x hx).2⟩

theorem bSusp_sound {u : Susp} (h : bSusp A n u = true) : Supp.susp P n u := by
  simp only [bSusp, Bool.and_eq_true, List.all_eq_true] at h
  exact ⟨fun f hf => bFrame_sound (h.1 f hf), bStores_sound h.2⟩

theorem bGen_sound {g : GenState} (h : bGen A n g = true) : Supp.gen P n g := by
  cases g <;> simp only [bGen, Supp.gen] at h ⊢
  · exact bEnv_sound h
  · exact bSusp_sound h

theorem bReaction_sound {r : Reaction} (h : bReaction A n r = true) : Supp.reaction P n r := by
  cases r <;> simp only [bReaction, Supp.reaction, Bool.and_eq_true] at h ⊢
  · exact bSusp_sound h
  · exact ⟨bVal_sound h.1.1.1, bVal_sound h.1.1.2, h.1.2, bStores_sound h.2⟩
  · exact h
  · exact h

theorem bPstate_sound {p : PState} (h : bPstate A n p = true) : Supp.pstate P n p := by
  cases p <;> simp only [bPstate, Supp.pstate, List.all_eq_true] at h ⊢
  · exact fun r hr => bReaction_sound (h r hr)
  · exact bVal_sound h
  · exact bVal_sound h

theorem bCode_sound {c : Code} (h : bCode A n c = true) : Supp.code P n c := by
  cases c <;> simp only [bCode, Supp.code] at h ⊢ <;> supp_parts

theorem bKind_sound {k : Kind} (h : bKind A n k = true) : Supp.kind P n k := by
  cases k <;> simp only [bKind, Supp.kind] at h ⊢
  all_goals first
    | trivial | exact h | exact bVals_sound h | exact bCode_sound h | exact bBytes_sound h
    | exact bPairs_sound h | exact bPstate_sound h | exact bEnv_sound h | exact bVal_sound h
    | skip
  case gen g a q =>
    simp only [Bool.and_eq_true, List.all_eq_true] at h
    exact ⟨bGen_sound h.1, fun x hx => ⟨(h.2 x hx).1, bComp_sound (h.2 x hx).2⟩⟩

theorem bObj_sound {o : Obj} (h : bObj A n o = true) : Supp.obj P n o := by
  simp only [bObj, Bool.and_eq_true, List.all_eq_true] at h
  exact ⟨bKind_sound h.1.1.1, bVal_sound h.1.1.2, bProps_sound h.1.2,
    fun x hx => ⟨(h.2 x hx).1, bProp_sound (h.2 x hx).2⟩⟩

theorem bHobj_sound {o : HObj} (h : bHobj A n o = true) : Supp.hobj P n o := by
  match o, h with
  | .cell none, _ => trivial
  | .cell (some v), h => exact bVal_sound h
  | .obj o, h => exact bObj_sound h

theorem bJob_sound {j : Job} (h : bJob A n j = true) : Supp.job P n j := by
  simp only [bJob, Bool.and_eq_true] at h
  exact ⟨bReaction_sound h.1, bVal_sound h.2⟩

end

/-! ## Closedness of a state -/

/-- The present addresses of a state, as a Boolean. -/
def presentB {S : Type} (s : St S) (a : Nat) : Bool := (s.heap.get a).isSome

/-- Every heap entry is supported (checked over the explicit address list). -/
def checkHeapSupp {S : Type} (s : St S) (n : Nat) : Bool :=
  (PTrie.keys s.heap).all fun a => match s.heap.get a with
    | some h => bHobj (presentB s) n h
    | none => true

def checkRootsSupp {S : Type} (s : St S) (n : Nat) : Bool :=
  bCtl (presentB s) n s.ctl && s.stack.all (bFrame (presentB s) n) && s.jobs.all (bJob (presentB s) n) &&
    bStores (presentB s) n s.stores

theorem checkHeapSupp_sound {S : Type} {s : St S} {n : Nat} (h : checkHeapSupp s n = true) :
    ∀ a o, s.heap.get a = some o → Supp.hobj (Present s) n o := by
  intro a o ha
  simp only [checkHeapSupp, List.all_eq_true] at h
  have := h a (PTrie.mem_keys s.heap a o ha)
  rw [ha] at this
  exact bHobj_sound this

theorem checkRootsSupp_sound {S : Type} {s : St S} {n : Nat} (h : checkRootsSupp s n = true) :
    Supp.ctl (Present s) n s.ctl ∧ (∀ f ∈ s.stack, Supp.frame (Present s) n f) ∧
      (∀ j ∈ s.jobs, Supp.job (Present s) n j) ∧ Supp.stores (Present s) n s.stores := by
  simp only [checkRootsSupp, Bool.and_eq_true, List.all_eq_true] at h
  exact ⟨bCtl_sound h.1.1.1, fun f hf => bFrame_sound (h.1.1.2 f hf), fun j hj => bJob_sound (h.1.2 j hj),
    bStores_sound h.2⟩

end Host.Ts.Sim.Template
