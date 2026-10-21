import host.sim.BigFreeImage

/-! # Deciding bigint freedom

Boolean versions `noBig*B lo hi` of the predicates `NoBig.* I` for the band
`I = [lo, hi)`, with soundness lemmas (`_sound`), in the style of
`host.sim.template.Check`: non-recursive matches and `List.all`, so the
kernel decides them by evaluation. -/

namespace Host.Ts.Sim

section
variable (lo hi : Int)

/-- `i` lies in the band `[lo, hi)`. -/
def inBandB (i : Int) : Bool := decide (lo ≤ i) && decide (i < hi)

def noBigValB : Val → Bool
  | .big i => !inBandB lo hi i
  | _ => true

def noBigPropB : PropV → Bool
  | .data v _ _ => noBigValB lo hi v
  | .acc g s _ => noBigValB lo hi g && noBigValB lo hi s

def noBigPropsB (ps : Props) : Bool := ps.all fun x => noBigPropB lo hi x.2

def noBigValsB (vs : List Val) : Bool := vs.all (noBigValB lo hi)

def noBigCellB : Cell → Bool
  | .num _ => true
  | .big i => !inBandB lo hi i

def noBigByteB : Byte → Bool
  | .lit _ => true
  | .part _ c _ => noBigCellB lo hi c

def noBigBytesB (bs : List Byte) : Bool := bs.all (noBigByteB lo hi)

def noBigAbrB : Abrupt → Bool
  | .throw v => noBigValB lo hi v
  | .ret v => noBigValB lo hi v
  | _ => true

def noBigCompB : Comp → Bool
  | .normal v => noBigValB lo hi v
  | .abrupt a => noBigAbrB lo hi a

def noBigInstB : InstMember → Bool
  | .field _ _ => true
  | .privField _ _ _ => true
  | .privMethod _ _ p => noBigPropB lo hi p

def noBigInstsB (is : List InstMember) : Bool := is.all (noBigInstB lo hi)

def noBigBndB : Boundary → Bool
  | .call => true
  | .ctor t => noBigValB lo hi t
  | .derived _ => true
  | .async _ => true
  | .gen _ => true

def noBigSrcB : IterSrc → Bool
  | .index v _ => noBigValB lo hi v
  | .proto it nx => noBigValB lo hi it && noBigValB lo hi nx

def noBigPairsB (ps : List (Val × Val)) : Bool :=
  ps.all fun x => noBigValB lo hi x.1 && noBigValB lo hi x.2

def noBigCallFB : CallF → Bool
  | .callee _ _ _ => true
  | .member _ _ _ _ _ => true
  | .index _ _ _ _ _ => true
  | .indexK o _ _ _ => noBigValB lo hi o
  | .priv _ _ _ _ _ _ => true
  | .method t _ _ _ => noBigValB lo hi t
  | .args _ f t acc _ _ => noBigValB lo hi f && noBigValB lo hi t && noBigValsB lo hi acc
  | .spread _ f t acc _ _ => noBigValB lo hi f && noBigValB lo hi t && noBigValsB lo hi acc
  | .newCallee _ _ => true

def noBigExprFB : ExprF → Bool
  | .unary _ => true
  | .binL _ _ _ => true
  | .binR _ a => noBigValB lo hi a
  | .logL _ _ _ => true
  | .cond _ _ _ => true
  | .seq _ _ => true
  | .member _ _ => true
  | .indexL _ _ _ => true
  | .indexR o => noBigValB lo hi o
  | .priv _ _ _ => true
  | .chain => true
  | .const v => noBigValB lo hi v
  | .typeof => true

def noBigLitFB : LitF → Bool
  | .array acc _ _ => noBigValsB lo hi acc
  | .spread acc _ _ => noBigValsB lo hi acc
  | .object _ _ _ => true
  | .objKey _ _ _ _ => true
  | .objVal _ _ _ _ => true
  | .objSpread _ _ _ => true
  | .tmpl _ _ _ _ => true
  | .tagged t _ acc _ _ => noBigValB lo hi t && noBigValsB lo hi acc

def noBigTargetB : Target → Bool
  | .var _ _ => true
  | .prop o _ => noBigValB lo hi o
  | .priv o _ _ => noBigValB lo hi o

def noBigAsgFB : AsgF → Bool
  | .pat _ _ => true
  | .obj _ _ _ _ _ => true
  | .key _ o _ _ => noBigValB lo hi o
  | .privObj _ _ _ _ _ => true
  | .old _ t _ _ => noBigTargetB lo hi t
  | .put _ t o => noBigTargetB lo hi t && noBigValB lo hi o
  | .updObj _ _ _ _ _ => true
  | .updKey _ _ o => noBigValB lo hi o
  | .updPrivObj _ _ _ _ => true
  | .updOld _ _ t => noBigTargetB lo hi t

def noBigStmtFB : StmtF → Bool
  | .block _ _ => true
  | .scope res => noBigPairsB lo hi res
  | .dispose r c => noBigPairsB lo hi r && noBigCompB lo hi c
  | .if_ _ _ _ => true
  | .decl _ _ _ _ => true
  | .declNext _ _ _ => true
  | .ret => true
  | .throw => true
  | .try_ _ _ _ => true
  | .catch_ _ _ => true
  | .finally_ c => noBigCompB lo hi c
  | .label _ => true
  | .switchD _ _ => true
  | .switchCase d _ _ _ => noBigValB lo hi d
  | .switchBody => true

def noBigLoopFB : LoopF → Bool
  | .forTest _ _ _ _ _ _ _ => true
  | .forBody _ _ _ _ _ _ => true
  | .forUpd _ _ _ _ _ _ => true
  | .whileTest _ _ _ _ => true
  | .whileBody _ _ _ _ => true
  | .doBody _ _ _ _ => true
  | .forOfSrc _ _ _ _ _ _ => true
  | .forOfIt _ _ _ _ _ _ => true
  | .forOfNext it nx _ _ _ _ _ _ => noBigValB lo hi it && noBigValB lo hi nx
  | .forOfBody s _ _ _ _ _ _ => noBigSrcB lo hi s
  | .close c => noBigCompB lo hi c

def noBigBindFB : BindF → Bool
  | .dflt _ _ _ _ => true
  | .arr _ _ vs _ _ _ => noBigValsB lo hi vs
  | .arrSrc _ _ _ _ _ => true
  | .obj s _ _ _ _ _ _ => noBigValB lo hi s
  | .objKey s _ _ _ _ _ _ _ => noBigValB lo hi s
  | .objVal s _ _ _ _ _ _ _ _ => noBigValB lo hi s
  | .collect acc it nx => noBigValsB lo hi acc && noBigValB lo hi it && noBigValB lo hi nx
  | .collectIt acc => noBigValsB lo hi acc

def noBigFnFB : FnF → Bool
  | .fn b => noBigBndB lo hi b
  | .params _ _ as _ => noBigValsB lo hi as
  | .paramDflt _ _ _ as _ => noBigValsB lo hi as
  | .classHeritage _ _ => true
  | .classMembers _ _ _ is _ => noBigInstsB lo hi is
  | .classKey _ _ _ _ is _ => noBigInstsB lo hi is
  | .classStatic _ _ _ _ is _ => noBigInstsB lo hi is
  | .fields _ ms _ => noBigInstsB lo hi ms
  | .fieldVal _ _ ms _ => noBigInstsB lo hi ms
  | .privVal _ _ _ ms _ => noBigInstsB lo hi ms
  | .ctorBody o _ _ as => noBigValB lo hi o && noBigValsB lo hi as
  | .superRet _ _ _ => true
  | .paramProps o _ _ => noBigValB lo hi o
  | .native _ d => noBigValsB lo hi d
  | .promiseThen _ => true
  | .yield _ => true
  | .ystarIt => true
  | .ystarNext it nx => noBigValB lo hi it && noBigValB lo hi nx
  | .ystarResume it nx => noBigValB lo hi it && noBigValB lo hi nx
  | .ystarAIt => true
  | .ystarAResult it nx => noBigValB lo hi it && noBigValB lo hi nx
  | .ystarAResume it nx => noBigValB lo hi it && noBigValB lo hi nx
  | .ystarAReturned it nx => noBigValB lo hi it && noBigValB lo hi nx
  | .ystarAReturn => true
  | .await => true
  | .modules _ => true

def noBigFrameB : Frame → Bool
  | .e f => noBigExprFB lo hi f
  | .c f => noBigCallFB lo hi f
  | .l f => noBigLitFB lo hi f
  | .a f => noBigAsgFB lo hi f
  | .s f => noBigStmtFB lo hi f
  | .lp f => noBigLoopFB lo hi f
  | .b f => noBigBindFB lo hi f
  | .k f => noBigFnFB lo hi f

def noBigCtlB : Ctl → Bool
  | .ev _ _ => true
  | .ex _ _ => true
  | .ret v => noBigValB lo hi v
  | .abr a => noBigAbrB lo hi a
  | .call f t as => noBigValB lo hi f && noBigValB lo hi t && noBigValsB lo hi as
  | .construct f as nt => noBigValB lo hi f && noBigValsB lo hi as && noBigValB lo hi nt
  | .bind _ v _ _ _ => noBigValB lo hi v
  | .short => true
  | .halt c => noBigCompB lo hi c

def noBigStoresB (ss : List (Nat × Val)) : Bool := ss.all fun x => noBigValB lo hi x.2

def noBigSuspB (u : Susp) : Bool := u.frames.all (noBigFrameB lo hi) && noBigStoresB lo hi u.stores

def noBigGenB : GenState → Bool
  | .start _ _ => true
  | .suspended u => noBigSuspB lo hi u
  | .running => true
  | .done => true

def noBigReactionB : Reaction → Bool
  | .resume u => noBigSuspB lo hi u
  | .then_ f r _ ss => noBigValB lo hi f && noBigValB lo hi r && noBigStoresB lo hi ss
  | .adopt _ => true
  | .forward _ => true

def noBigPstateB : PState → Bool
  | .pending rs => rs.all (noBigReactionB lo hi)
  | .fulfilled v => noBigValB lo hi v
  | .rejected v => noBigValB lo hi v

def noBigCodeB : Code → Bool
  | .closure _ _ _ h => noBigValB lo hi h
  | .klass _ _ p is => noBigValB lo hi p && noBigInstsB lo hi is
  | .native _ d => noBigValsB lo hi d
  | .bound t th as => noBigValB lo hi t && noBigValB lo hi th && noBigValsB lo hi as

def noBigKindB : Kind → Bool
  | .ordinary => true
  | .array es => noBigValsB lo hi es
  | .fn c => noBigCodeB lo hi c
  | .buf bs => noBigBytesB lo hi bs
  | .extBuf _ _ _ => true
  | .typed _ _ _ _ => true
  | .view _ _ _ => true
  | .map m => noBigPairsB lo hi m
  | .set m => noBigValsB lo hi m
  | .promise p => noBigPstateB lo hi p
  | .gen g _ q => noBigGenB lo hi g && q.all fun x => noBigCompB lo hi x.2
  | .ns _ => true
  | .box v => noBigValB lo hi v
  | .iter s _ _ => noBigValB lo hi s

def noBigObjB (o : Obj) : Bool :=
  noBigKindB lo hi o.kind && noBigValB lo hi o.proto && noBigPropsB lo hi o.props &&
    o.priv.all fun x => noBigPropB lo hi x.2

def noBigHobjB : HObj → Bool
  | .cell none => true
  | .cell (some v) => noBigValB lo hi v
  | .obj o => noBigObjB lo hi o

def noBigArgB : Arg → Bool
  | .big i => !inBandB lo hi i
  | .jsPtr _ _ bs => noBigBytesB lo hi bs
  | .other v => noBigValB lo hi v
  | _ => true

def noBigArgsB (as : List Arg) : Bool := as.all (noBigArgB lo hi)

def noBigRetB : Ret → Bool
  | .big i => !inBandB lo hi i
  | .callback _ as => noBigArgsB lo hi as
  | _ => true

def noBigEventB (e : Event) : Bool := noBigArgsB lo hi e.args && noBigRetB lo hi e.ret

def noBigJobB (j : Job) : Bool := noBigReactionB lo hi j.r && noBigValB lo hi j.v

end

/-! ## Soundness -/

section
variable {lo hi : Int}
local notation "J" => fun i : Int => lo ≤ i ∧ i < hi

attribute [local simp] Bool.and_eq_true List.all_eq_true

theorem inBandB_sound {i : Int} (h : (!inBandB lo hi i) = true) : ¬ (lo ≤ i ∧ i < hi) := by
  simp only [inBandB, Bool.not_eq_true', Bool.and_eq_false_iff, decide_eq_false_iff_not] at h
  rintro ⟨h1, h2⟩
  rcases h with h | h
  · exact h h1
  · exact h h2

theorem noBigValB_sound {v : Val} (h : noBigValB lo hi v = true) : NoBig.val J v := by
  cases v with
  | big i => exact inBandB_sound h
  | _ => trivial

theorem noBigCellB_sound {c : Cell} (h : noBigCellB lo hi c = true) : NoBig.cell J c := by
  cases c with
  | num _ => trivial
  | big i => exact inBandB_sound h

theorem noBigByteB_sound {x : Byte} (h : noBigByteB lo hi x = true) : NoBig.byte J x := by
  cases x with
  | lit _ => trivial
  | part _ c _ => exact noBigCellB_sound h

theorem noBigBytesB_sound {bs : List Byte} (h : noBigBytesB lo hi bs = true) : NoBig.bytes J bs := by
  simp only [noBigBytesB, List.all_eq_true] at h
  exact fun x hx => noBigByteB_sound (h x hx)

theorem noBigPropB_sound {p : PropV} (h : noBigPropB lo hi p = true) : NoBig.prop J p := by
  cases p <;> simp only [noBigPropB, NoBig.prop, Bool.and_eq_true] at h ⊢
  · exact noBigValB_sound h
  · exact ⟨noBigValB_sound h.1, noBigValB_sound h.2⟩

theorem noBigPropsB_sound {ps : Props} (h : noBigPropsB lo hi ps = true) : NoBig.props J ps := by
  simp only [noBigPropsB, List.all_eq_true] at h
  exact fun x hx => noBigPropB_sound (h x hx)

theorem noBigValsB_sound {vs : List Val} (h : noBigValsB lo hi vs = true) : NoBig.vals J vs := by
  simp only [noBigValsB, List.all_eq_true] at h
  exact fun v hv => noBigValB_sound (h v hv)

theorem noBigAbrB_sound {a : Abrupt} (h : noBigAbrB lo hi a = true) : NoBig.abr J a := by
  cases a <;> simp only [noBigAbrB, NoBig.abr] at h ⊢ <;> first | trivial | exact noBigValB_sound h

theorem noBigCompB_sound {c : Comp} (h : noBigCompB lo hi c = true) : NoBig.comp J c := by
  cases c <;> simp only [noBigCompB, NoBig.comp] at h ⊢
  · exact noBigValB_sound h
  · exact noBigAbrB_sound h

theorem noBigInstB_sound {i : InstMember} (h : noBigInstB lo hi i = true) : NoBig.inst J i := by
  cases i <;> simp only [noBigInstB, NoBig.inst] at h ⊢ <;> first | trivial | exact noBigPropB_sound h

theorem noBigInstsB_sound {is : List InstMember} (h : noBigInstsB lo hi is = true) : NoBig.insts J is := by
  simp only [noBigInstsB, List.all_eq_true] at h
  exact fun i hi => noBigInstB_sound (h i hi)

theorem noBigBndB_sound {x : Boundary} (h : noBigBndB lo hi x = true) : NoBig.bnd J x := by
  cases x <;> simp only [noBigBndB, NoBig.bnd] at h ⊢ <;> first | trivial | exact noBigValB_sound h

theorem noBigSrcB_sound {s : IterSrc} (h : noBigSrcB lo hi s = true) : NoBig.src J s := by
  cases s <;> simp only [noBigSrcB, NoBig.src, Bool.and_eq_true] at h ⊢
  · exact noBigValB_sound h
  · exact ⟨noBigValB_sound h.1, noBigValB_sound h.2⟩

theorem noBigPairsB_sound {ps : List (Val × Val)} (h : noBigPairsB lo hi ps = true) : NoBig.pairs J ps := by
  simp only [noBigPairsB, List.all_eq_true, Bool.and_eq_true] at h
  exact fun x hx => ⟨noBigValB_sound (h x hx).1, noBigValB_sound (h x hx).2⟩

-- Destructure a conjunction of checks (`h`) into the matching conjunction of freedoms.
set_option hygiene false in
macro "nobig_parts" : tactic => `(tactic| ((try simp only [Bool.and_eq_true] at h); (try revert h); (try simp only [and_imp]); intros; ((try and_intros) <;>
  first
    | assumption
    | (apply noBigValB_sound; assumption) | (apply noBigValsB_sound; assumption)
    | (apply noBigInstsB_sound; assumption) | (apply noBigPairsB_sound; assumption)
    | (apply noBigCompB_sound; assumption) | (apply noBigSrcB_sound; assumption)
    | (apply noBigBndB_sound; assumption) | (apply noBigPropB_sound; assumption)
    | (apply noBigTargetB_sound; assumption) | (apply noBigAbrB_sound; assumption) | trivial)))

theorem noBigCallFB_sound {f : CallF} (h : noBigCallFB lo hi f = true) : NoBig.callF J f := by
  cases f <;> simp only [noBigCallFB, NoBig.callF] at h ⊢ <;> nobig_parts

theorem noBigExprFB_sound {f : ExprF} (h : noBigExprFB lo hi f = true) : NoBig.exprF J f := by
  cases f <;> simp only [noBigExprFB, NoBig.exprF] at h ⊢ <;> nobig_parts

theorem noBigLitFB_sound {f : LitF} (h : noBigLitFB lo hi f = true) : NoBig.litF J f := by
  cases f <;> simp only [noBigLitFB, NoBig.litF] at h ⊢ <;> nobig_parts

theorem noBigTargetB_sound {t : Target} (h : noBigTargetB lo hi t = true) : NoBig.target J t := by
  cases t <;> simp only [noBigTargetB, NoBig.target] at h ⊢ <;> nobig_parts

theorem noBigAsgFB_sound {f : AsgF} (h : noBigAsgFB lo hi f = true) : NoBig.asgF J f := by
  cases f <;> simp only [noBigAsgFB, NoBig.asgF] at h ⊢ <;> nobig_parts

theorem noBigStmtFB_sound {f : StmtF} (h : noBigStmtFB lo hi f = true) : NoBig.stmtF J f := by
  cases f <;> simp only [noBigStmtFB, NoBig.stmtF] at h ⊢ <;> nobig_parts

theorem noBigLoopFB_sound {f : LoopF} (h : noBigLoopFB lo hi f = true) : NoBig.loopF J f := by
  cases f <;> simp only [noBigLoopFB, NoBig.loopF] at h ⊢ <;> nobig_parts

theorem noBigBindFB_sound {f : BindF} (h : noBigBindFB lo hi f = true) : NoBig.bindF J f := by
  cases f <;> simp only [noBigBindFB, NoBig.bindF] at h ⊢ <;> nobig_parts

theorem noBigFnFB_sound {f : FnF} (h : noBigFnFB lo hi f = true) : NoBig.fnF J f := by
  cases f <;> simp only [noBigFnFB, NoBig.fnF] at h ⊢ <;> nobig_parts

theorem noBigFrameB_sound {f : Frame} (h : noBigFrameB lo hi f = true) : NoBig.frame J f := by
  cases f <;> simp only [noBigFrameB, NoBig.frame] at h ⊢
  · exact noBigExprFB_sound h
  · exact noBigCallFB_sound h
  · exact noBigLitFB_sound h
  · exact noBigAsgFB_sound h
  · exact noBigStmtFB_sound h
  · exact noBigLoopFB_sound h
  · exact noBigBindFB_sound h
  · exact noBigFnFB_sound h

theorem noBigCtlB_sound {c : Ctl} (h : noBigCtlB lo hi c = true) : NoBig.ctl J c := by
  cases c <;> simp only [noBigCtlB, NoBig.ctl] at h ⊢ <;> nobig_parts

theorem noBigStoresB_sound {ss : List (Nat × Val)} (h : noBigStoresB lo hi ss = true) :
    NoBig.stores J ss := by
  simp only [noBigStoresB, List.all_eq_true] at h
  exact fun x hx => noBigValB_sound (h x hx)

theorem noBigSuspB_sound {u : Susp} (h : noBigSuspB lo hi u = true) : NoBig.susp J u := by
  simp only [noBigSuspB, Bool.and_eq_true, List.all_eq_true] at h
  exact ⟨fun f hf => noBigFrameB_sound (h.1 f hf), noBigStoresB_sound h.2⟩

theorem noBigGenB_sound {g : GenState} (h : noBigGenB lo hi g = true) : NoBig.gen J g := by
  cases g <;> simp only [noBigGenB, NoBig.gen] at h ⊢ <;> first | trivial | exact noBigSuspB_sound h

theorem noBigReactionB_sound {r : Reaction} (h : noBigReactionB lo hi r = true) : NoBig.reaction J r := by
  cases r <;> simp only [noBigReactionB, NoBig.reaction, Bool.and_eq_true] at h ⊢
  · exact noBigSuspB_sound h
  · exact ⟨noBigValB_sound h.1.1, noBigValB_sound h.1.2, noBigStoresB_sound h.2⟩

theorem noBigPstateB_sound {p : PState} (h : noBigPstateB lo hi p = true) : NoBig.pstate J p := by
  cases p <;> simp only [noBigPstateB, NoBig.pstate, List.all_eq_true] at h ⊢
  · exact fun r hr => noBigReactionB_sound (h r hr)
  · exact noBigValB_sound h
  · exact noBigValB_sound h

theorem noBigCodeB_sound {c : Code} (h : noBigCodeB lo hi c = true) : NoBig.code J c := by
  cases c <;> simp only [noBigCodeB, NoBig.code] at h ⊢ <;> nobig_parts

theorem noBigKindB_sound {k : Kind} (h : noBigKindB lo hi k = true) : NoBig.kind J k := by
  cases k <;> simp only [noBigKindB, NoBig.kind] at h ⊢
  all_goals first
    | trivial | exact noBigValsB_sound h | exact noBigCodeB_sound h | exact noBigBytesB_sound h
    | exact noBigPairsB_sound h | exact noBigPstateB_sound h | exact noBigValB_sound h
    | skip
  case gen g a q =>
    simp only [Bool.and_eq_true, List.all_eq_true] at h
    exact ⟨noBigGenB_sound h.1, fun x hx => noBigCompB_sound (h.2 x hx)⟩

theorem noBigObjB_sound {o : Obj} (h : noBigObjB lo hi o = true) : NoBig.obj J o := by
  simp only [noBigObjB, Bool.and_eq_true, List.all_eq_true] at h
  exact ⟨noBigKindB_sound h.1.1.1, noBigValB_sound h.1.1.2, noBigPropsB_sound h.1.2,
    fun x hx => noBigPropB_sound (h.2 x hx)⟩

theorem noBigHobjB_sound {o : HObj} (h : noBigHobjB lo hi o = true) : NoBig.hobj J o := by
  match o, h with
  | .cell none, _ => trivial
  | .cell (some v), h => exact noBigValB_sound h
  | .obj o, h => exact noBigObjB_sound h

theorem noBigArgB_sound {a : Arg} (h : noBigArgB lo hi a = true) : NoBig.arg J a := by
  cases a with
  | big i => exact inBandB_sound h
  | jsPtr _ _ bs => exact noBigBytesB_sound h
  | other v => exact noBigValB_sound h
  | _ => trivial

theorem noBigArgsB_sound {as : List Arg} (h : noBigArgsB lo hi as = true) : NoBig.args J as := by
  simp only [noBigArgsB, List.all_eq_true] at h
  exact fun a ha => noBigArgB_sound (h a ha)

theorem noBigRetB_sound {r : Ret} (h : noBigRetB lo hi r = true) : NoBig.ret J r := by
  cases r with
  | big i => exact inBandB_sound h
  | callback _ as => exact noBigArgsB_sound h
  | _ => trivial

theorem noBigEventB_sound {e : Event} (h : noBigEventB lo hi e = true) : NoBig.event J e := by
  simp only [noBigEventB, Bool.and_eq_true] at h
  exact ⟨noBigArgsB_sound h.1, noBigRetB_sound h.2⟩

theorem noBigJobB_sound {j : Job} (h : noBigJobB lo hi j = true) : NoBig.job J j := by
  simp only [noBigJobB, Bool.and_eq_true] at h
  exact ⟨noBigReactionB_sound h.1, noBigValB_sound h.2⟩

end

end Host.Ts.Sim
