import host.sim.BigFree

/-! # Deciding bigint freedom for a predicate

`host.sim.BigFreeCheck`'s deciders and `host.sim.BigFree`'s state checks with the band `[lo, hi)`
replaced by a Boolean predicate `pB` on bigints (`noBig*P pB`, `stateNoBigP pB`): a state passes when
no bigint it mentions satisfies `pB`. Soundness is stated for every `I` that `pB` covers
(`∀ i, I i → pB i = true`), so a check also gives the freedom of any smaller set. -/

namespace Host.Ts.Sim
open Host.Ts.Sim.Template (PTrie.keys PTrie.mem_keys)


section
variable (pB : Int → Bool)

def noBigValP : Val → Bool
  | .big i => !pB i
  | _ => true

def noBigPropP : PropV → Bool
  | .data v _ _ => noBigValP pB v
  | .acc g s _ => noBigValP pB g && noBigValP pB s

def noBigPropsP (ps : Props) : Bool := ps.all fun x => noBigPropP pB x.2

def noBigValsP (vs : List Val) : Bool := vs.all (noBigValP pB)

def noBigCellP : Cell → Bool
  | .num _ => true
  | .big i => !pB i

def noBigByteP : Byte → Bool
  | .lit _ => true
  | .part _ c _ => noBigCellP pB c

def noBigBytesP (bs : List Byte) : Bool := bs.all (noBigByteP pB)

def noBigAbrP : Abrupt → Bool
  | .throw v => noBigValP pB v
  | .ret v => noBigValP pB v
  | _ => true

def noBigCompP : Comp → Bool
  | .normal v => noBigValP pB v
  | .abrupt a => noBigAbrP pB a

def noBigInstP : InstMember → Bool
  | .field _ _ => true
  | .privField _ _ _ => true
  | .privMethod _ _ p => noBigPropP pB p

def noBigInstsP (is : List InstMember) : Bool := is.all (noBigInstP pB)

def noBigBndP : Boundary → Bool
  | .call => true
  | .ctor t => noBigValP pB t
  | .derived _ => true
  | .async _ => true
  | .gen _ => true

def noBigSrcP : IterSrc → Bool
  | .index v _ => noBigValP pB v
  | .proto it nx => noBigValP pB it && noBigValP pB nx

def noBigPairsP (ps : List (Val × Val)) : Bool :=
  ps.all fun x => noBigValP pB x.1 && noBigValP pB x.2

def noBigCallFP : CallF → Bool
  | .callee _ _ _ => true
  | .member _ _ _ _ _ => true
  | .index _ _ _ _ _ => true
  | .indexK o _ _ _ => noBigValP pB o
  | .priv _ _ _ _ _ _ => true
  | .method t _ _ _ => noBigValP pB t
  | .args _ f t acc _ _ => noBigValP pB f && noBigValP pB t && noBigValsP pB acc
  | .spread _ f t acc _ _ => noBigValP pB f && noBigValP pB t && noBigValsP pB acc
  | .newCallee _ _ => true

def noBigExprFP : ExprF → Bool
  | .unary _ => true
  | .binL _ _ _ => true
  | .binR _ a => noBigValP pB a
  | .logL _ _ _ => true
  | .cond _ _ _ => true
  | .seq _ _ => true
  | .member _ _ => true
  | .indexL _ _ _ => true
  | .indexR o => noBigValP pB o
  | .priv _ _ _ => true
  | .chain => true
  | .const v => noBigValP pB v
  | .typeof => true

def noBigLitFP : LitF → Bool
  | .array acc _ _ => noBigValsP pB acc
  | .spread acc _ _ => noBigValsP pB acc
  | .object _ _ _ => true
  | .objKey _ _ _ _ => true
  | .objVal _ _ _ _ => true
  | .objSpread _ _ _ => true
  | .tmpl _ _ _ _ => true
  | .tagged t _ acc _ _ => noBigValP pB t && noBigValsP pB acc

def noBigTargetP : Target → Bool
  | .var _ _ => true
  | .prop o _ => noBigValP pB o
  | .priv o _ _ => noBigValP pB o

def noBigAsgFP : AsgF → Bool
  | .pat _ _ => true
  | .obj _ _ _ _ _ => true
  | .key _ o _ _ => noBigValP pB o
  | .privObj _ _ _ _ _ => true
  | .old _ t _ _ => noBigTargetP pB t
  | .put _ t o => noBigTargetP pB t && noBigValP pB o
  | .updObj _ _ _ _ _ => true
  | .updKey _ _ o => noBigValP pB o
  | .updPrivObj _ _ _ _ => true
  | .updOld _ _ t => noBigTargetP pB t

def noBigStmtFP : StmtF → Bool
  | .block _ _ => true
  | .scope res => noBigPairsP pB res
  | .dispose r c => noBigPairsP pB r && noBigCompP pB c
  | .if_ _ _ _ => true
  | .decl _ _ _ _ => true
  | .declNext _ _ _ => true
  | .ret => true
  | .throw => true
  | .try_ _ _ _ => true
  | .catch_ _ _ => true
  | .finally_ c => noBigCompP pB c
  | .label _ => true
  | .switchD _ _ => true
  | .switchCase d _ _ _ => noBigValP pB d
  | .switchBody => true

def noBigLoopFP : LoopF → Bool
  | .forTest _ _ _ _ _ _ _ => true
  | .forBody _ _ _ _ _ _ => true
  | .forUpd _ _ _ _ _ _ => true
  | .whileTest _ _ _ _ => true
  | .whileBody _ _ _ _ => true
  | .doBody _ _ _ _ => true
  | .forOfSrc _ _ _ _ _ _ => true
  | .forOfIt _ _ _ _ _ _ => true
  | .forOfNext it nx _ _ _ _ _ _ => noBigValP pB it && noBigValP pB nx
  | .forOfBody s _ _ _ _ _ _ => noBigSrcP pB s
  | .close c => noBigCompP pB c

def noBigBindFP : BindF → Bool
  | .dflt _ _ _ _ => true
  | .arr _ _ vs _ _ _ => noBigValsP pB vs
  | .arrSrc _ _ _ _ _ => true
  | .obj s _ _ _ _ _ _ => noBigValP pB s
  | .objKey s _ _ _ _ _ _ _ => noBigValP pB s
  | .objVal s _ _ _ _ _ _ _ _ => noBigValP pB s
  | .collect acc it nx => noBigValsP pB acc && noBigValP pB it && noBigValP pB nx
  | .collectIt acc => noBigValsP pB acc

def noBigFnFP : FnF → Bool
  | .fn b => noBigBndP pB b
  | .params _ _ as _ => noBigValsP pB as
  | .paramDflt _ _ _ as _ => noBigValsP pB as
  | .classHeritage _ _ => true
  | .classMembers _ _ _ is _ => noBigInstsP pB is
  | .classKey _ _ _ _ is _ => noBigInstsP pB is
  | .classStatic _ _ _ _ is _ => noBigInstsP pB is
  | .fields _ ms _ => noBigInstsP pB ms
  | .fieldVal _ _ ms _ => noBigInstsP pB ms
  | .privVal _ _ _ ms _ => noBigInstsP pB ms
  | .ctorBody o _ _ as => noBigValP pB o && noBigValsP pB as
  | .superRet _ _ _ => true
  | .paramProps o _ _ => noBigValP pB o
  | .native _ d => noBigValsP pB d
  | .promiseThen _ => true
  | .yield _ => true
  | .ystarIt => true
  | .ystarNext it nx => noBigValP pB it && noBigValP pB nx
  | .ystarResume it nx => noBigValP pB it && noBigValP pB nx
  | .ystarAIt => true
  | .ystarAResult it nx => noBigValP pB it && noBigValP pB nx
  | .ystarAResume it nx => noBigValP pB it && noBigValP pB nx
  | .ystarAReturned it nx => noBigValP pB it && noBigValP pB nx
  | .ystarAReturn => true
  | .await => true
  | .modules _ => true

def noBigFrameP : Frame → Bool
  | .e f => noBigExprFP pB f
  | .c f => noBigCallFP pB f
  | .l f => noBigLitFP pB f
  | .a f => noBigAsgFP pB f
  | .s f => noBigStmtFP pB f
  | .lp f => noBigLoopFP pB f
  | .b f => noBigBindFP pB f
  | .k f => noBigFnFP pB f

def noBigCtlP : Ctl → Bool
  | .ev _ _ => true
  | .ex _ _ => true
  | .ret v => noBigValP pB v
  | .abr a => noBigAbrP pB a
  | .call f t as => noBigValP pB f && noBigValP pB t && noBigValsP pB as
  | .construct f as nt => noBigValP pB f && noBigValsP pB as && noBigValP pB nt
  | .bind _ v _ _ _ => noBigValP pB v
  | .short => true
  | .halt c => noBigCompP pB c

def noBigStoresP (ss : List (Nat × Val)) : Bool := ss.all fun x => noBigValP pB x.2

def noBigSuspP (u : Susp) : Bool := u.frames.all (noBigFrameP pB) && noBigStoresP pB u.stores

def noBigGenP : GenState → Bool
  | .start _ _ => true
  | .suspended u => noBigSuspP pB u
  | .running => true
  | .done => true

def noBigReactionP : Reaction → Bool
  | .resume u => noBigSuspP pB u
  | .then_ f r _ ss => noBigValP pB f && noBigValP pB r && noBigStoresP pB ss
  | .adopt _ => true
  | .forward _ => true

def noBigPstateP : PState → Bool
  | .pending rs => rs.all (noBigReactionP pB)
  | .fulfilled v => noBigValP pB v
  | .rejected v => noBigValP pB v

def noBigCodeP : Code → Bool
  | .closure _ _ _ h => noBigValP pB h
  | .klass _ _ p is => noBigValP pB p && noBigInstsP pB is
  | .native _ d => noBigValsP pB d
  | .bound t th as => noBigValP pB t && noBigValP pB th && noBigValsP pB as

def noBigKindP : Kind → Bool
  | .ordinary => true
  | .array es => noBigValsP pB es
  | .fn c => noBigCodeP pB c
  | .buf bs => noBigBytesP pB bs
  | .extBuf _ _ _ => true
  | .typed _ _ _ _ => true
  | .view _ _ _ => true
  | .map m => noBigPairsP pB m
  | .set m => noBigValsP pB m
  | .promise p => noBigPstateP pB p
  | .gen g _ q => noBigGenP pB g && q.all fun x => noBigCompP pB x.2
  | .ns _ => true
  | .box v => noBigValP pB v
  | .iter s _ _ => noBigValP pB s

def noBigObjP (o : Obj) : Bool :=
  noBigKindP pB o.kind && noBigValP pB o.proto && noBigPropsP pB o.props &&
    o.priv.all fun x => noBigPropP pB x.2

def noBigHobjP : HObj → Bool
  | .cell none => true
  | .cell (some v) => noBigValP pB v
  | .obj o => noBigObjP pB o

def noBigArgP : Arg → Bool
  | .big i => !pB i
  | .jsPtr _ _ bs => noBigBytesP pB bs
  | .other v => noBigValP pB v
  | _ => true

def noBigArgsP (as : List Arg) : Bool := as.all (noBigArgP pB)

def noBigRetP : Ret → Bool
  | .big i => !pB i
  | .callback _ as => noBigArgsP pB as
  | _ => true

def noBigEventP (e : Event) : Bool := noBigArgsP pB e.args && noBigRetP pB e.ret

def noBigJobP (j : Job) : Bool := noBigReactionP pB j.r && noBigValP pB j.v

end

/-! ## Soundness -/

section
variable {pB : Int → Bool} {I : Int → Prop} (hpI : ∀ i, I i → pB i = true)
include hpI

attribute [local simp] Bool.and_eq_true List.all_eq_true

theorem predP_sound {i : Int} (h : (!pB i) = true) : ¬ I i := fun hi => by
  rw [hpI i hi] at h; cases h

theorem noBigValP_sound {v : Val} (h : noBigValP pB v = true) : NoBig.val I v := by
  cases v with
  | big i => exact predP_sound hpI h
  | _ => trivial

theorem noBigCellP_sound {c : Cell} (h : noBigCellP pB c = true) : NoBig.cell I c := by
  cases c with
  | num _ => trivial
  | big i => exact predP_sound hpI h

theorem noBigByteP_sound {x : Byte} (h : noBigByteP pB x = true) : NoBig.byte I x := by
  cases x with
  | lit _ => trivial
  | part _ c _ => exact noBigCellP_sound hpI h

theorem noBigBytesP_sound {bs : List Byte} (h : noBigBytesP pB bs = true) : NoBig.bytes I bs := by
  simp only [noBigBytesP, List.all_eq_true] at h
  exact fun x hx => noBigByteP_sound hpI (h x hx)

theorem noBigPropP_sound {p : PropV} (h : noBigPropP pB p = true) : NoBig.prop I p := by
  cases p <;> simp only [noBigPropP, NoBig.prop, Bool.and_eq_true] at h ⊢
  · exact noBigValP_sound hpI h
  · exact ⟨noBigValP_sound hpI h.1, noBigValP_sound hpI h.2⟩

theorem noBigPropsP_sound {ps : Props} (h : noBigPropsP pB ps = true) : NoBig.props I ps := by
  simp only [noBigPropsP, List.all_eq_true] at h
  exact fun x hx => noBigPropP_sound hpI (h x hx)

theorem noBigValsP_sound {vs : List Val} (h : noBigValsP pB vs = true) : NoBig.vals I vs := by
  simp only [noBigValsP, List.all_eq_true] at h
  exact fun v hv => noBigValP_sound hpI (h v hv)

theorem noBigAbrP_sound {a : Abrupt} (h : noBigAbrP pB a = true) : NoBig.abr I a := by
  cases a <;> simp only [noBigAbrP, NoBig.abr] at h ⊢ <;> first | trivial | exact noBigValP_sound hpI h

theorem noBigCompP_sound {c : Comp} (h : noBigCompP pB c = true) : NoBig.comp I c := by
  cases c <;> simp only [noBigCompP, NoBig.comp] at h ⊢
  · exact noBigValP_sound hpI h
  · exact noBigAbrP_sound hpI h

theorem noBigInstP_sound {i : InstMember} (h : noBigInstP pB i = true) : NoBig.inst I i := by
  cases i <;> simp only [noBigInstP, NoBig.inst] at h ⊢ <;> first | trivial | exact noBigPropP_sound hpI h

theorem noBigInstsP_sound {is : List InstMember} (h : noBigInstsP pB is = true) : NoBig.insts I is := by
  simp only [noBigInstsP, List.all_eq_true] at h
  exact fun i hi => noBigInstP_sound hpI (h i hi)

theorem noBigBndP_sound {x : Boundary} (h : noBigBndP pB x = true) : NoBig.bnd I x := by
  cases x <;> simp only [noBigBndP, NoBig.bnd] at h ⊢ <;> first | trivial | exact noBigValP_sound hpI h

theorem noBigSrcP_sound {s : IterSrc} (h : noBigSrcP pB s = true) : NoBig.src I s := by
  cases s <;> simp only [noBigSrcP, NoBig.src, Bool.and_eq_true] at h ⊢
  · exact noBigValP_sound hpI h
  · exact ⟨noBigValP_sound hpI h.1, noBigValP_sound hpI h.2⟩

theorem noBigPairsP_sound {ps : List (Val × Val)} (h : noBigPairsP pB ps = true) : NoBig.pairs I ps := by
  simp only [noBigPairsP, List.all_eq_true, Bool.and_eq_true] at h
  exact fun x hx => ⟨noBigValP_sound hpI (h x hx).1, noBigValP_sound hpI (h x hx).2⟩

-- Destructure a conjunction of checks (`h`) into the matching conjunction of freedoms.
set_option hygiene false in
macro "nobig_partsP" : tactic => `(tactic| ((try simp only [Bool.and_eq_true] at h); (try revert h); (try simp only [and_imp]); intros; ((try and_intros) <;>
  first
    | assumption
    | (apply noBigValP_sound hpI; assumption) | (apply noBigValsP_sound hpI; assumption)
    | (apply noBigInstsP_sound hpI; assumption) | (apply noBigPairsP_sound hpI; assumption)
    | (apply noBigCompP_sound hpI; assumption) | (apply noBigSrcP_sound hpI; assumption)
    | (apply noBigBndP_sound hpI; assumption) | (apply noBigPropP_sound hpI; assumption)
    | (apply noBigTargetP_sound hpI; assumption) | (apply noBigAbrP_sound hpI; assumption) | trivial)))

theorem noBigCallFP_sound {f : CallF} (h : noBigCallFP pB f = true) : NoBig.callF I f := by
  cases f <;> simp only [noBigCallFP, NoBig.callF] at h ⊢ <;> nobig_partsP

theorem noBigExprFP_sound {f : ExprF} (h : noBigExprFP pB f = true) : NoBig.exprF I f := by
  cases f <;> simp only [noBigExprFP, NoBig.exprF] at h ⊢ <;> nobig_partsP

theorem noBigLitFP_sound {f : LitF} (h : noBigLitFP pB f = true) : NoBig.litF I f := by
  cases f <;> simp only [noBigLitFP, NoBig.litF] at h ⊢ <;> nobig_partsP

theorem noBigTargetP_sound {t : Target} (h : noBigTargetP pB t = true) : NoBig.target I t := by
  cases t <;> simp only [noBigTargetP, NoBig.target] at h ⊢ <;> nobig_partsP

theorem noBigAsgFP_sound {f : AsgF} (h : noBigAsgFP pB f = true) : NoBig.asgF I f := by
  cases f <;> simp only [noBigAsgFP, NoBig.asgF] at h ⊢ <;> nobig_partsP

theorem noBigStmtFP_sound {f : StmtF} (h : noBigStmtFP pB f = true) : NoBig.stmtF I f := by
  cases f <;> simp only [noBigStmtFP, NoBig.stmtF] at h ⊢ <;> nobig_partsP

theorem noBigLoopFP_sound {f : LoopF} (h : noBigLoopFP pB f = true) : NoBig.loopF I f := by
  cases f <;> simp only [noBigLoopFP, NoBig.loopF] at h ⊢ <;> nobig_partsP

theorem noBigBindFP_sound {f : BindF} (h : noBigBindFP pB f = true) : NoBig.bindF I f := by
  cases f <;> simp only [noBigBindFP, NoBig.bindF] at h ⊢ <;> nobig_partsP

theorem noBigFnFP_sound {f : FnF} (h : noBigFnFP pB f = true) : NoBig.fnF I f := by
  cases f <;> simp only [noBigFnFP, NoBig.fnF] at h ⊢ <;> nobig_partsP

theorem noBigFrameP_sound {f : Frame} (h : noBigFrameP pB f = true) : NoBig.frame I f := by
  cases f <;> simp only [noBigFrameP, NoBig.frame] at h ⊢
  · exact noBigExprFP_sound hpI h
  · exact noBigCallFP_sound hpI h
  · exact noBigLitFP_sound hpI h
  · exact noBigAsgFP_sound hpI h
  · exact noBigStmtFP_sound hpI h
  · exact noBigLoopFP_sound hpI h
  · exact noBigBindFP_sound hpI h
  · exact noBigFnFP_sound hpI h

theorem noBigCtlP_sound {c : Ctl} (h : noBigCtlP pB c = true) : NoBig.ctl I c := by
  cases c <;> simp only [noBigCtlP, NoBig.ctl] at h ⊢ <;> nobig_partsP

theorem noBigStoresP_sound {ss : List (Nat × Val)} (h : noBigStoresP pB ss = true) :
    NoBig.stores I ss := by
  simp only [noBigStoresP, List.all_eq_true] at h
  exact fun x hx => noBigValP_sound hpI (h x hx)

theorem noBigSuspP_sound {u : Susp} (h : noBigSuspP pB u = true) : NoBig.susp I u := by
  simp only [noBigSuspP, Bool.and_eq_true, List.all_eq_true] at h
  exact ⟨fun f hf => noBigFrameP_sound hpI (h.1 f hf), noBigStoresP_sound hpI h.2⟩

theorem noBigGenP_sound {g : GenState} (h : noBigGenP pB g = true) : NoBig.gen I g := by
  cases g <;> simp only [noBigGenP, NoBig.gen] at h ⊢ <;> first | trivial | exact noBigSuspP_sound hpI h

theorem noBigReactionP_sound {r : Reaction} (h : noBigReactionP pB r = true) : NoBig.reaction I r := by
  cases r <;> simp only [noBigReactionP, NoBig.reaction, Bool.and_eq_true] at h ⊢
  · exact noBigSuspP_sound hpI h
  · exact ⟨noBigValP_sound hpI h.1.1, noBigValP_sound hpI h.1.2, noBigStoresP_sound hpI h.2⟩

theorem noBigPstateP_sound {p : PState} (h : noBigPstateP pB p = true) : NoBig.pstate I p := by
  cases p <;> simp only [noBigPstateP, NoBig.pstate, List.all_eq_true] at h ⊢
  · exact fun r hr => noBigReactionP_sound hpI (h r hr)
  · exact noBigValP_sound hpI h
  · exact noBigValP_sound hpI h

theorem noBigCodeP_sound {c : Code} (h : noBigCodeP pB c = true) : NoBig.code I c := by
  cases c <;> simp only [noBigCodeP, NoBig.code] at h ⊢ <;> nobig_partsP

theorem noBigKindP_sound {k : Kind} (h : noBigKindP pB k = true) : NoBig.kind I k := by
  cases k <;> simp only [noBigKindP, NoBig.kind] at h ⊢
  all_goals first
    | trivial | exact noBigValsP_sound hpI h | exact noBigCodeP_sound hpI h | exact noBigBytesP_sound hpI h
    | exact noBigPairsP_sound hpI h | exact noBigPstateP_sound hpI h | exact noBigValP_sound hpI h
    | skip
  case gen g a q =>
    simp only [Bool.and_eq_true, List.all_eq_true] at h
    exact ⟨noBigGenP_sound hpI h.1, fun x hx => noBigCompP_sound hpI (h.2 x hx)⟩

theorem noBigObjP_sound {o : Obj} (h : noBigObjP pB o = true) : NoBig.obj I o := by
  simp only [noBigObjP, Bool.and_eq_true, List.all_eq_true] at h
  exact ⟨noBigKindP_sound hpI h.1.1.1, noBigValP_sound hpI h.1.1.2, noBigPropsP_sound hpI h.1.2,
    fun x hx => noBigPropP_sound hpI (h.2 x hx)⟩

theorem noBigHobjP_sound {o : HObj} (h : noBigHobjP pB o = true) : NoBig.hobj I o := by
  match o, h with
  | .cell none, _ => trivial
  | .cell (some v), h => exact noBigValP_sound hpI h
  | .obj o, h => exact noBigObjP_sound hpI h

theorem noBigArgP_sound {a : Arg} (h : noBigArgP pB a = true) : NoBig.arg I a := by
  cases a with
  | big i => exact predP_sound hpI h
  | jsPtr _ _ bs => exact noBigBytesP_sound hpI h
  | other v => exact noBigValP_sound hpI h
  | _ => trivial

theorem noBigArgsP_sound {as : List Arg} (h : noBigArgsP pB as = true) : NoBig.args I as := by
  simp only [noBigArgsP, List.all_eq_true] at h
  exact fun a ha => noBigArgP_sound hpI (h a ha)

theorem noBigRetP_sound {r : Ret} (h : noBigRetP pB r = true) : NoBig.ret I r := by
  cases r with
  | big i => exact predP_sound hpI h
  | callback _ as => exact noBigArgsP_sound hpI h
  | _ => trivial

theorem noBigEventP_sound {e : Event} (h : noBigEventP pB e = true) : NoBig.event I e := by
  simp only [noBigEventP, Bool.and_eq_true] at h
  exact ⟨noBigArgsP_sound hpI h.1, noBigRetP_sound hpI h.2⟩

theorem noBigJobP_sound {j : Job} (h : noBigJobP pB j = true) : NoBig.job I j := by
  simp only [noBigJobP, Bool.and_eq_true] at h
  exact ⟨noBigReactionP_sound hpI h.1, noBigValP_sound hpI h.2⟩

end


/-! ## Deciding freedom of a state -/

section
variable {S : Type} (pB : Int → Bool)

/-- The heap entry at `a` is free of `pB`. -/
def noBigAtP (s : St S) (a : Nat) : Bool :=
  match s.heap.get a with
  | some h => noBigHobjP pB h
  | none => true

/-- Every heap entry is free of `pB` (checked over the explicit address list). -/
def noBigHeapP (s : St S) : Bool := (PTrie.keys s.heap).all (noBigAtP pB s)

def noBigRootsP (base : List Event) (s : St S) : Bool :=
  noBigCtlP pB s.ctl && s.stack.all (noBigFrameP pB) && s.jobs.all (noBigJobP pB) &&
    noBigStoresP pB s.stores && (freshOf base s).all (noBigEventP pB)

def stateNoBigP (base : List Event) (s : St S) : Bool := noBigHeapP pB s && noBigRootsP pB base s

end

section
variable {S : Type} {pB : Int → Bool} {I : Int → Prop} {base : List Event} {s : St S}

theorem noBigHeapP_sound (h : noBigHeapP pB s = true) : ∀ a, Present s a → noBigAtP pB s a = true := by
  intro a ha
  obtain ⟨o, hg⟩ := Option.isSome_iff_exists.mp ha
  simp only [noBigHeapP, List.all_eq_true] at h
  exact h a (PTrie.mem_keys s.heap a o hg)

theorem NoBigSt.of_checksP (hpI : ∀ i, I i → pB i = true) (hheap : ∀ a, Present s a → noBigAtP pB s a = true)
    (hroots : noBigRootsP pB base s = true) : NoBigSt I base s := by
  simp only [noBigRootsP, Bool.and_eq_true, List.all_eq_true] at hroots
  refine ⟨fun a o ha => ?_, noBigCtlP_sound hpI hroots.1.1.1.1, fun f hf => noBigFrameP_sound hpI (hroots.1.1.1.2 f hf),
    fun j hj => noBigJobP_sound hpI (hroots.1.1.2 j hj), noBigStoresP_sound hpI hroots.1.2,
    fun e he => noBigEventP_sound hpI (hroots.2 e he)⟩
  have hp : Present s a := by unfold Present; rw [ha]; rfl
  have := hheap a hp
  unfold noBigAtP at this
  rw [ha] at this
  exact noBigHobjP_sound hpI this

theorem stateNoBigP_sound (hpI : ∀ i, I i → pB i = true) (h : stateNoBigP pB base s = true) : NoBigSt I base s := by
  simp only [stateNoBigP, Bool.and_eq_true] at h
  exact NoBigSt.of_checksP hpI (noBigHeapP_sound h.1) h.2

end


end Host.Ts.Sim
