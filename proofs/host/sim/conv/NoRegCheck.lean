import host.sim.conv.RegFree
import host.sim.BigFreeCheck
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim

/-! # Deciding region freedom

Boolean versions `noReg*B rB` of `NoReg.* R` (`host.sim.conv.RegFree`) for a decidable region set
`R r := rB r = true`, with soundness lemmas, in the style of `host.sim.BigFreeCheck`: non-recursive
matches and `List.all`, so the kernel decides them by evaluation.

`cleanAtB lo hi rB s a`: the heap entry at `a` holds no bigint in `[lo, hi)` and no region of `rB`
(the cut bookkeeping of the compaction, `host.sim.conv.Compact`: a piece checks it on the entries
it creates or changes, against the native counter at its end); `cleanListB` over a list,
`cleanListB_sound`. -/

section
variable (rB : Nat → Bool)

def noRegMemB : Mem → Bool
  | .js _ => true
  | .ext r => !rB r

def noRegValB : Val → Bool
  | .ptr m _ => noRegMemB rB m
  | _ => true

def noRegPropB : PropV → Bool
  | .data v _ _ => noRegValB rB v
  | .acc g s _ => noRegValB rB g && noRegValB rB s

def noRegPropsB (ps : Props) : Bool := ps.all fun x => noRegPropB rB x.2

def noRegValsB (vs : List Val) : Bool := vs.all (noRegValB rB)

def noRegAbrB : Abrupt → Bool
  | .throw v => noRegValB rB v
  | .ret v => noRegValB rB v
  | _ => true

def noRegCompB : Comp → Bool
  | .normal v => noRegValB rB v
  | .abrupt a => noRegAbrB rB a

def noRegInstB : InstMember → Bool
  | .privMethod _ _ p => noRegPropB rB p
  | _ => true

def noRegInstsB (is : List InstMember) : Bool := is.all (noRegInstB rB)

def noRegBndB : Boundary → Bool
  | .ctor t => noRegValB rB t
  | _ => true

def noRegSrcB : IterSrc → Bool
  | .index v _ => noRegValB rB v
  | .proto it nx => noRegValB rB it && noRegValB rB nx

def noRegPairsB (ps : List (Val × Val)) : Bool := ps.all fun x => noRegValB rB x.1 && noRegValB rB x.2

def noRegCallFB : CallF → Bool
  | .indexK o _ _ _ => noRegValB rB o
  | .method t _ _ _ => noRegValB rB t
  | .args _ f t acc _ _ => noRegValB rB f && noRegValB rB t && noRegValsB rB acc
  | .spread _ f t acc _ _ => noRegValB rB f && noRegValB rB t && noRegValsB rB acc
  | _ => true

def noRegExprFB : ExprF → Bool
  | .binR _ a => noRegValB rB a
  | .indexR o => noRegValB rB o
  | .const v => noRegValB rB v
  | _ => true

def noRegLitFB : LitF → Bool
  | .array acc _ _ => noRegValsB rB acc
  | .spread acc _ _ => noRegValsB rB acc
  | .tagged t _ acc _ _ => noRegValB rB t && noRegValsB rB acc
  | _ => true

def noRegTargetB : Target → Bool
  | .prop o _ => noRegValB rB o
  | .priv o _ _ => noRegValB rB o
  | _ => true

def noRegAsgFB : AsgF → Bool
  | .key _ o _ _ => noRegValB rB o
  | .old _ t _ _ => noRegTargetB rB t
  | .put _ t o => noRegTargetB rB t && noRegValB rB o
  | .updKey _ _ o => noRegValB rB o
  | .updOld _ _ t => noRegTargetB rB t
  | _ => true

def noRegStmtFB : StmtF → Bool
  | .scope res => noRegPairsB rB res
  | .dispose r c => noRegPairsB rB r && noRegCompB rB c
  | .finally_ c => noRegCompB rB c
  | .switchCase d _ _ _ => noRegValB rB d
  | _ => true

def noRegLoopFB : LoopF → Bool
  | .forOfNext it nx _ _ _ _ _ _ => noRegValB rB it && noRegValB rB nx
  | .forOfBody s _ _ _ _ _ _ => noRegSrcB rB s
  | .close c => noRegCompB rB c
  | _ => true

def noRegBindFB : BindF → Bool
  | .arr _ _ vs _ _ _ => noRegValsB rB vs
  | .obj s _ _ _ _ _ _ => noRegValB rB s
  | .objKey s _ _ _ _ _ _ _ => noRegValB rB s
  | .objVal s _ _ _ _ _ _ _ _ => noRegValB rB s
  | .collect acc it nx => noRegValsB rB acc && noRegValB rB it && noRegValB rB nx
  | .collectIt acc => noRegValsB rB acc
  | _ => true

def noRegFnFB : FnF → Bool
  | .fn b => noRegBndB rB b
  | .params _ _ as _ => noRegValsB rB as
  | .paramDflt _ _ _ as _ => noRegValsB rB as
  | .classMembers _ _ _ is _ => noRegInstsB rB is
  | .classKey _ _ _ _ is _ => noRegInstsB rB is
  | .classStatic _ _ _ _ is _ => noRegInstsB rB is
  | .fields _ ms _ => noRegInstsB rB ms
  | .fieldVal _ _ ms _ => noRegInstsB rB ms
  | .privVal _ _ _ ms _ => noRegInstsB rB ms
  | .ctorBody o _ _ as => noRegValB rB o && noRegValsB rB as
  | .paramProps o _ _ => noRegValB rB o
  | .native _ d => noRegValsB rB d
  | .ystarNext it nx => noRegValB rB it && noRegValB rB nx
  | .ystarResume it nx => noRegValB rB it && noRegValB rB nx
  | .ystarAResult it nx => noRegValB rB it && noRegValB rB nx
  | .ystarAResume it nx => noRegValB rB it && noRegValB rB nx
  | .ystarAReturned it nx => noRegValB rB it && noRegValB rB nx
  | _ => true

def noRegFrameB : Frame → Bool
  | .e f => noRegExprFB rB f
  | .c f => noRegCallFB rB f
  | .l f => noRegLitFB rB f
  | .a f => noRegAsgFB rB f
  | .s f => noRegStmtFB rB f
  | .lp f => noRegLoopFB rB f
  | .b f => noRegBindFB rB f
  | .k f => noRegFnFB rB f

def noRegCtlB : Ctl → Bool
  | .ret v => noRegValB rB v
  | .abr a => noRegAbrB rB a
  | .call f t as => noRegValB rB f && noRegValB rB t && noRegValsB rB as
  | .construct f as nt => noRegValB rB f && noRegValsB rB as && noRegValB rB nt
  | .bind _ v _ _ _ => noRegValB rB v
  | .halt c => noRegCompB rB c
  | _ => true

def noRegStoresB (ss : List (Nat × Val)) : Bool := ss.all fun x => noRegValB rB x.2

def noRegSuspB (u : Susp) : Bool := u.frames.all (noRegFrameB rB) && noRegStoresB rB u.stores

def noRegGenB : GenState → Bool
  | .suspended u => noRegSuspB rB u
  | _ => true

def noRegReactionB : Reaction → Bool
  | .resume u => noRegSuspB rB u
  | .then_ f r _ ss => noRegValB rB f && noRegValB rB r && noRegStoresB rB ss
  | _ => true

def noRegPstateB : PState → Bool
  | .pending rs => rs.all (noRegReactionB rB)
  | .fulfilled v => noRegValB rB v
  | .rejected v => noRegValB rB v

def noRegCodeB : Code → Bool
  | .closure _ _ _ h => noRegValB rB h
  | .klass _ _ p is => noRegValB rB p && noRegInstsB rB is
  | .native _ d => noRegValsB rB d
  | .bound t th as => noRegValB rB t && noRegValB rB th && noRegValsB rB as

def noRegKindB : Kind → Bool
  | .array es => noRegValsB rB es
  | .fn c => noRegCodeB rB c
  | .extBuf r _ _ => !rB r
  | .map m => noRegPairsB rB m
  | .set m => noRegValsB rB m
  | .promise p => noRegPstateB rB p
  | .gen g _ q => noRegGenB rB g && q.all fun x => noRegCompB rB x.2
  | .box v => noRegValB rB v
  | .iter s _ _ => noRegValB rB s
  | _ => true

def noRegObjB (o : Obj) : Bool :=
  noRegKindB rB o.kind && noRegValB rB o.proto && noRegPropsB rB o.props && o.priv.all fun x => noRegPropB rB x.2

def noRegHobjB : HObj → Bool
  | .cell none => true
  | .cell (some v) => noRegValB rB v
  | .obj o => noRegObjB rB o

end

/-! ## Soundness -/

section
variable {rB : Nat → Bool}
local notation "Rb" => fun r : Nat => rB r = true

theorem noRegMemB_sound {m : Mem} (h : noRegMemB rB m = true) : NoReg.mem Rb m := by
  cases m with
  | js _ => trivial
  | ext r => simpa [noRegMemB, NoReg.mem] using h

theorem noRegValB_sound {v : Val} (h : noRegValB rB v = true) : NoReg.val Rb v := by
  cases v with
  | ptr m _ => exact noRegMemB_sound h
  | _ => trivial

theorem noRegPropB_sound {p : PropV} (h : noRegPropB rB p = true) : NoReg.prop Rb p := by
  cases p <;> simp only [noRegPropB, NoReg.prop, Bool.and_eq_true] at h ⊢
  · exact noRegValB_sound h
  · exact ⟨noRegValB_sound h.1, noRegValB_sound h.2⟩

theorem noRegPropsB_sound {ps : Props} (h : noRegPropsB rB ps = true) : NoReg.props Rb ps := by
  simp only [noRegPropsB, List.all_eq_true] at h
  exact fun x hx => noRegPropB_sound (h x hx)

theorem noRegValsB_sound {vs : List Val} (h : noRegValsB rB vs = true) : NoReg.vals Rb vs := by
  simp only [noRegValsB, List.all_eq_true] at h
  exact fun v hv => noRegValB_sound (h v hv)

theorem noRegAbrB_sound {a : Abrupt} (h : noRegAbrB rB a = true) : NoReg.abr Rb a := by
  cases a <;> simp only [noRegAbrB, NoReg.abr] at h ⊢ <;> first | trivial | exact noRegValB_sound h

theorem noRegCompB_sound {c : Comp} (h : noRegCompB rB c = true) : NoReg.comp Rb c := by
  cases c <;> simp only [noRegCompB, NoReg.comp] at h ⊢
  · exact noRegValB_sound h
  · exact noRegAbrB_sound h

theorem noRegInstB_sound {i : InstMember} (h : noRegInstB rB i = true) : NoReg.inst Rb i := by
  cases i <;> simp only [noRegInstB, NoReg.inst] at h ⊢ <;> first | trivial | exact noRegPropB_sound h

theorem noRegInstsB_sound {is : List InstMember} (h : noRegInstsB rB is = true) : NoReg.insts Rb is := by
  simp only [noRegInstsB, List.all_eq_true] at h
  exact fun i hi => noRegInstB_sound (h i hi)

theorem noRegBndB_sound {x : Boundary} (h : noRegBndB rB x = true) : NoReg.bnd Rb x := by
  cases x <;> simp only [noRegBndB, NoReg.bnd] at h ⊢ <;> first | trivial | exact noRegValB_sound h

theorem noRegSrcB_sound {s : IterSrc} (h : noRegSrcB rB s = true) : NoReg.src Rb s := by
  cases s <;> simp only [noRegSrcB, NoReg.src, Bool.and_eq_true] at h ⊢
  · exact noRegValB_sound h
  · exact ⟨noRegValB_sound h.1, noRegValB_sound h.2⟩

theorem noRegPairsB_sound {ps : List (Val × Val)} (h : noRegPairsB rB ps = true) : NoReg.pairs Rb ps := by
  simp only [noRegPairsB, List.all_eq_true, Bool.and_eq_true] at h
  exact fun x hx => ⟨noRegValB_sound (h x hx).1, noRegValB_sound (h x hx).2⟩

theorem noRegTargetB_sound {t : Target} (h : noRegTargetB rB t = true) : NoReg.target Rb t := by
  cases t <;> simp only [noRegTargetB, NoReg.target] at h ⊢ <;> first | trivial | exact noRegValB_sound h

set_option hygiene false in
macro "noreg_parts" : tactic => `(tactic| ((try simp only [Bool.and_eq_true] at h); (try revert h); (try simp only [and_imp]); intros; ((try and_intros) <;>
  first
    | assumption
    | (apply noRegValB_sound; assumption) | (apply noRegValsB_sound; assumption)
    | (apply noRegInstsB_sound; assumption) | (apply noRegPairsB_sound; assumption)
    | (apply noRegCompB_sound; assumption) | (apply noRegSrcB_sound; assumption)
    | (apply noRegBndB_sound; assumption) | (apply noRegPropB_sound; assumption)
    | (apply noRegTargetB_sound; assumption) | (apply noRegAbrB_sound; assumption) | trivial)))

theorem noRegCallFB_sound {f : CallF} (h : noRegCallFB rB f = true) : NoReg.callF Rb f := by
  cases f <;> simp only [noRegCallFB, NoReg.callF] at h ⊢ <;> noreg_parts

theorem noRegExprFB_sound {f : ExprF} (h : noRegExprFB rB f = true) : NoReg.exprF Rb f := by
  cases f <;> simp only [noRegExprFB, NoReg.exprF] at h ⊢ <;> noreg_parts

theorem noRegLitFB_sound {f : LitF} (h : noRegLitFB rB f = true) : NoReg.litF Rb f := by
  cases f <;> simp only [noRegLitFB, NoReg.litF] at h ⊢ <;> noreg_parts

theorem noRegAsgFB_sound {f : AsgF} (h : noRegAsgFB rB f = true) : NoReg.asgF Rb f := by
  cases f <;> simp only [noRegAsgFB, NoReg.asgF] at h ⊢ <;> noreg_parts

theorem noRegStmtFB_sound {f : StmtF} (h : noRegStmtFB rB f = true) : NoReg.stmtF Rb f := by
  cases f <;> simp only [noRegStmtFB, NoReg.stmtF] at h ⊢ <;> noreg_parts

theorem noRegLoopFB_sound {f : LoopF} (h : noRegLoopFB rB f = true) : NoReg.loopF Rb f := by
  cases f <;> simp only [noRegLoopFB, NoReg.loopF] at h ⊢ <;> noreg_parts

theorem noRegBindFB_sound {f : BindF} (h : noRegBindFB rB f = true) : NoReg.bindF Rb f := by
  cases f <;> simp only [noRegBindFB, NoReg.bindF] at h ⊢ <;> noreg_parts

theorem noRegFnFB_sound {f : FnF} (h : noRegFnFB rB f = true) : NoReg.fnF Rb f := by
  cases f <;> simp only [noRegFnFB, NoReg.fnF] at h ⊢ <;> noreg_parts

theorem noRegFrameB_sound {f : Frame} (h : noRegFrameB rB f = true) : NoReg.frame Rb f := by
  cases f <;> simp only [noRegFrameB, NoReg.frame] at h ⊢
  · exact noRegExprFB_sound h
  · exact noRegCallFB_sound h
  · exact noRegLitFB_sound h
  · exact noRegAsgFB_sound h
  · exact noRegStmtFB_sound h
  · exact noRegLoopFB_sound h
  · exact noRegBindFB_sound h
  · exact noRegFnFB_sound h

theorem noRegCtlB_sound {c : Ctl} (h : noRegCtlB rB c = true) : NoReg.ctl Rb c := by
  cases c <;> simp only [noRegCtlB, NoReg.ctl] at h ⊢ <;> noreg_parts

theorem noRegStoresB_sound {ss : List (Nat × Val)} (h : noRegStoresB rB ss = true) : NoReg.stores Rb ss := by
  simp only [noRegStoresB, List.all_eq_true] at h
  exact fun x hx => noRegValB_sound (h x hx)

theorem noRegSuspB_sound {u : Susp} (h : noRegSuspB rB u = true) : NoReg.susp Rb u := by
  simp only [noRegSuspB, Bool.and_eq_true, List.all_eq_true] at h
  exact ⟨fun f hf => noRegFrameB_sound (h.1 f hf), noRegStoresB_sound h.2⟩

theorem noRegGenB_sound {g : GenState} (h : noRegGenB rB g = true) : NoReg.gen Rb g := by
  cases g <;> simp only [noRegGenB, NoReg.gen] at h ⊢ <;> first | trivial | exact noRegSuspB_sound h

theorem noRegReactionB_sound {r : Reaction} (h : noRegReactionB rB r = true) : NoReg.reaction Rb r := by
  cases r <;> simp only [noRegReactionB, NoReg.reaction, Bool.and_eq_true] at h ⊢ <;>
    first
    | exact noRegSuspB_sound h
    | exact ⟨noRegValB_sound h.1.1, noRegValB_sound h.1.2, noRegStoresB_sound h.2⟩
    | trivial

theorem noRegPstateB_sound {p : PState} (h : noRegPstateB rB p = true) : NoReg.pstate Rb p := by
  cases p <;> simp only [noRegPstateB, NoReg.pstate, List.all_eq_true] at h ⊢
  · exact fun r hr => noRegReactionB_sound (h r hr)
  · exact noRegValB_sound h
  · exact noRegValB_sound h

theorem noRegCodeB_sound {c : Code} (h : noRegCodeB rB c = true) : NoReg.code Rb c := by
  cases c <;> simp only [noRegCodeB, NoReg.code] at h ⊢ <;> noreg_parts

theorem noRegKindB_sound {k : Kind} (h : noRegKindB rB k = true) : NoReg.kind Rb k := by
  cases k <;> simp only [noRegKindB, NoReg.kind] at h ⊢
  all_goals first
    | trivial | exact noRegValsB_sound h | exact noRegCodeB_sound h
    | exact noRegPairsB_sound h | exact noRegPstateB_sound h | exact noRegValB_sound h
    | (simpa using h) | skip
  case gen g a q =>
    simp only [Bool.and_eq_true, List.all_eq_true] at h
    exact ⟨noRegGenB_sound h.1, fun x hx => noRegCompB_sound (h.2 x hx)⟩

theorem noRegObjB_sound {o : Obj} (h : noRegObjB rB o = true) : NoReg.obj Rb o := by
  simp only [noRegObjB, Bool.and_eq_true, List.all_eq_true] at h
  exact ⟨noRegKindB_sound h.1.1.1, noRegValB_sound h.1.1.2, noRegPropsB_sound h.1.2,
    fun x hx => noRegPropB_sound (h.2 x hx)⟩

theorem noRegHobjB_sound {o : HObj} (h : noRegHobjB rB o = true) : NoReg.hobj Rb o := by
  match o, h with
  | .cell none, _ => trivial
  | .cell (some v), h => exact noRegValB_sound h
  | .obj o, h => exact noRegObjB_sound h

end

/-! ## Entries free of a bigint band and a region set -/

section
variable {S : Type}

/-- The entry at `a`: no bigint in `[lo, hi)`, no region of `rB`. -/
def cleanAtB (lo hi : Int) (rB : Nat → Bool) (s : St S) (a : Nat) : Bool :=
  match s.heap.get a with
  | some h => noBigHobjB lo hi h && noRegHobjB rB h
  | none => true

/-- The entries at `l`. -/
def cleanListB (lo hi : Int) (rB : Nat → Bool) (s : St S) (l : List Nat) : Bool := l.all (cleanAtB lo hi rB s)

theorem cleanListB_sound {lo hi : Int} {rB : Nat → Bool} {s : St S} {l : List Nat}
    (h : cleanListB lo hi rB s l = true) :
    ∀ a ∈ l, ∀ o, s.heap.get a = some o → NoBig.hobj (fun i => lo ≤ i ∧ i < hi) o ∧ NoReg.hobj (fun r => rB r = true) o := by
  intro a ha o ho
  simp only [cleanListB, List.all_eq_true] at h
  have := h a ha
  unfold cleanAtB at this
  rw [ho] at this
  simp only [Bool.and_eq_true] at this
  exact ⟨noBigHobjB_sound this.1, noRegHobjB_sound this.2⟩

end

end Host.Ts.Sim.Conv
