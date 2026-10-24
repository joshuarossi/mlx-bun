import host.sim.dispatch.Ret1
import host.sim.dispatch.PutAdapt
import host.sim.dispatch.DecideStmt
import host.sim.dispatch.DecideLoop
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.StmtSim

/-! # Dispatch of `.ret v` under assignment, statement, loop and pattern frames

Every frame has a step lemma except the object-pattern key frame `BindF.objKey`
(computed keys of object patterns). -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

def okRetA (P : JSP F) (s : St F.S) (n : Nat) (v : Val) : AsgF → Bool
  | .pat _ _ => true
  | .obj op k _ _ _ => presB s aTypeErrorProto && presB s aReferenceErrorProto && presB s aGlobal &&
      (match k with
        | some key => asgReadB P s n op (.prop v key)
        | none => true)
  | .key op o _ _ => presB s aTypeErrorProto && presB s aReferenceErrorProto && presB s aGlobal &&
      litVB v && bfVB P v && (match asgKey v with
        | some key => asgReadB P s n op (.prop o key)
        | none => true)
  | .privObj _ _ nm _ _ => presB s aTypeErrorProto && presB s aReferenceErrorProto && presB s aGlobal &&
      privB P s v nm
  | .old _ _ _ _ => bfVB P v
  | .put op x old => presB s aTypeErrorProto && presB s aRangeErrorProto && presB s aReferenceErrorProto &&
      (match op with
        | none => storeTargetXB P s n x v
        | some bo => binB P s n bo old v && binMapB P s bo old v)
  | .updObj _ _ k _ _ => presB s aTypeErrorProto && (match k with
    | some key => lookupB P s n v key
    | none => true)
  | .updKey _ _ o => presB s aTypeErrorProto && litVB v && bfVB P v && (match asgKey v with
    | some key => lookupB P s n o key
    | none => true)
  | .updPrivObj _ _ _ nm => presB s aTypeErrorProto && privB P s v nm
  | .updOld inc _ x => presB s aTypeErrorProto && presB s aRangeErrorProto && presB s aReferenceErrorProto &&
      updOldB P s n inc x v

def okRetS (P : JSP F) (s : St F.S) (v : Val) : StmtF → Bool
  | .block _ _ => true
  | .scope _ => true
  | .dispose _ _ => true
  | .if_ _ _ _ => bfVB P v
  | .decl kind _ _ _ => match kind with
    | .using => isNullish v || presB s aTypeErrorProto && lookupNoWB P s v
    | _ => true
  | .declNext _ _ _ => true
  | .ret => true
  | .throw => true
  | .try_ _ fin _ => finB s fin
  | .catch_ fin _ => finB s fin
  | .finally_ _ => true
  | .label _ => true
  | .switchD _ _ => true
  | .switchCase d _ _ _ => strictB P d v
  | .switchBody => true

def okRetLp (P : JSP F) (s : St F.S) (n : Nat) (v : Val) : LoopF → Bool
  | .forTest _ _ _ _ env names _ => Nat.ble names.length two20 && namesNoWB P env names
  | .forBody _ _ _ _ _ _ => bfVB P v
  | .forUpd _ _ _ env names _ => Nat.ble names.length two20 && namesNoWB P env names
  | .whileTest _ _ _ _ => bfVB P v
  | .whileBody _ _ _ _ => true
  | .doBody _ _ _ _ => true
  | .forOfSrc _ _ p _ _ _ => Nat.ble (patNames p).length two20 && presB s aTypeErrorProto &&
      (!(isIndexable F s v) || idxB P s n v 0) && lookupNoWB P s v
  | .forOfIt _ _ p _ _ _ => Nat.ble (patNames p).length two20 && lookupNoWB P s v
  | .forOfNext _ _ _ _ p _ _ _ => Nat.ble (patNames p).length two20 && lookupNoWB P s v
  | .forOfBody src _ _ p _ _ _ => Nat.ble (patNames p).length two20 && srcIdxB P s n src
  | .close _ => true

def okRetB (P : JSP F) (s : St F.S) (n : Nat) (v : Val) : BindF → Bool
  | .dflt _ _ _ _ => true
  | .arr _ rest _ _ _ _ => rest.isNone || presB s aArrayProto
  | .arrSrc _ rest _ _ _ => elemsB P s n v && (rest.isNone || presB s aArrayProto)
  | .obj src ps rest _ _ _ _ => presB s aTypeErrorProto && objPatB P s n src ps && objRestPatB P s n src ps rest
  | .objKey _ _ _ _ _ _ _ _ => false
  | .objVal _ _ _ _ _ _ _ _ _ => true
  | .collect _ _ _ => presB s aArrayProto && lookupNoWB P s v
  | .collectIt _ => lookupNoWB P s v

theorem arrB_sound {S' : Type} {s : St S'} {rest : Option Pat} (h : (rest.isNone || presB s aArrayProto) = true) :
    rest ≠ none → Present s aArrayProto := by
  intro hr
  cases rest with
  | none => exact absurd rfl hr
  | some _ => exact (by simpa using h : presB s aArrayProto = true)

variable {okBack : F.S → Arg → Bool}

theorem simRetA {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hFR : FRLaws FR) (hK : Kp P K) (hW : Wp P W)
    (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : AsgF} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .a f :: fs) (hn : s.next + margin < Sim.bound) (hok : okRetA P s S.tab.length v f = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  have hn' := lt_bound_of_margin hn
  cases f with
  | pat p env => exact MSim.toX (step_retA_pat h hc hs)
  | obj op k kexpr val env =>
    simp only [okRetA, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
    refine MSim.toX (step_retA_obj h hF hn' hc hs h1 h2 h3 ?_)
    rintro key rfl
    exact hK.asgRead hW h4
  | key op o val env =>
    simp only [okRetA, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := hok
    refine MSim.toX (step_retA_key h hF hn' hc hs h1 h2 h3 (litVB_sound h4) (hK.bfV h5) ?_)
    intro key hk
    simp only [hk] at h6
    exact hK.asgRead hW h6
  | privObj op b nm val env =>
    simp only [okRetA, Bool.and_eq_true] at hok
    exact MSim.toX (step_retA_privObj h hF hn' hc hs hok.1.1.1 hok.1.1.2 hok.1.2 (hK.priv hW hok.2))
  | old op x val env => exact MSim.toX (step_retA_old h hFR hc hs (hK.bfV hok))
  | put op x old =>
    simp only [okRetA, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
    cases op with
    | none => exact MSim.toX (step_retA_putX h hF hFR hn' hc hs h1 h2 h3 (hK.storeTargetX hW h4)
        (storeTargetXB_range hK hN h h4))
    | some bo =>
      simp only [Bool.and_eq_true] at h4
      exact MSim.toX (step_retA_put h hF hFR hn' hc hs h1 h2 h3 (hK.bin hW h4.1) (binMapB_sound hK hN h h4.2))
  | updObj inc pre k kexpr env =>
    simp only [okRetA, Bool.and_eq_true] at hok
    refine MSim.toX (step_retA_updObj h hF hn' hc hs hok.1 ?_)
    rintro key rfl
    exact hK.lookup hW hok.2
  | updKey inc pre o =>
    simp only [okRetA, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
    refine MSim.toX (step_retA_updKey h hF hn' hc hs h1 (litVB_sound h2) (hK.bfV h3) ?_)
    intro key hk
    simp only [hk] at h4
    exact hK.lookup hW h4
  | updPrivObj inc pre b nm =>
    simp only [okRetA, Bool.and_eq_true] at hok
    exact MSim.toX (step_retA_updPrivObj h hn' hc hs hok.1 (hK.priv hW hok.2))
  | updOld inc pre x =>
    simp only [okRetA, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
    exact MSim.toX (step_retA_updOld h hF hFR hn' hc hs h1 h2 h3 (hK.updOld hW h4))

theorem simRetS {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hFR : FRLaws FR) (hK : Kp P K)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : StmtF} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .s f :: fs) (hn : s.next + margin < Sim.bound) (hok : okRetS P s v f = true)
    (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases f with
  | block rest env => exact MSim.toX (step_ret_block h hc hs)
  | scope res => exact MSim.toX (step_ret_scope h hc hs)
  | dispose rest c => exact MSim.toX (step_ret_dispose h hc hs)
  | if_ st e env => exact MSim.toX (step_ret_if h hFR hc hs (hK.bfBig hok))
  | decl kind p rest env =>
    cases hu : isUsing kind with
    | false => exact MSim.toX (step_ret_decl h hc hs hu)
    | true =>
      cases kind <;> simp [isUsing] at hu
      simp only [okRetS, Bool.or_eq_true] at hok
      cases hv : isNullish v with
      | true => exact MSim.toX (step_ret_decl_using_nullish h hc hs hv)
      | false =>
        simp only [hv, Bool.false_eq_true, false_or, Bool.and_eq_true] at hok
        exact MSim.toX (step_ret_decl_using h hF hc hs hv hn hok.1 (hK.lookupNoW hW hok.2)
          (hloc.imp id fun hl => localB_using hl hs rfl))
  | declNext kind rest env => exact MSim.toX (step_ret_declNext h hc hs)
  | ret => exact MSim.toX (step_ret_ret h hc hs)
  | throw => exact MSim.toX (step_ret_throw h hc hs)
  | try_ hd fin env =>
    have hb := finB_sound hok
    exact MSim.toX (step_ret_try h hc hs hn hb.1 hb.2)
  | catch_ fin env =>
    have hb := finB_sound hok
    exact MSim.toX (step_ret_catch h hc hs hn hb.1 hb.2)
  | finally_ c => exact MSim.toX (step_ret_finally h hc hs)
  | label l => exact MSim.toX (step_ret_label h hc hs)
  | switchD cs env => exact MSim.toX (step_ret_switchD h hc hs)
  | switchCase d cs all env => exact MSim.toX (step_ret_switchCase h hFR hc hs (hK.strict hok))
  | switchBody => exact MSim.toX (step_ret_switchBody h hc hs)

theorem simRetLp {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hFR : FRLaws FR) (hK : Kp P K)
    (hW : Wp P W) (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : LoopF} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp f :: fs) (hn : s.next + margin < Sim.bound) (hok : okRetLp P s S.tab.length v f = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases f with
  | forTest copy test update body env names labels =>
    simp only [okRetLp, Bool.and_eq_true] at hok
    exact MSim.toX (step_ret_forTest h hc hs hn (le20 hok.1) (hK.namesNoW hW hok.2))
  | forBody test update body env names labels => exact MSim.toX (step_ret_forBody h hFR hc hs (hK.bfBig hok))
  | forUpd test update body env names labels =>
    simp only [okRetLp, Bool.and_eq_true] at hok
    exact MSim.toX (step_ret_forUpd h hc hs hn (le20 hok.1) (hK.namesNoW hW hok.2))
  | whileTest c body env labels => exact MSim.toX (step_ret_whileTest h hFR hc hs (hK.bfBig hok))
  | whileBody c body env labels => exact MSim.toX (step_ret_whileBody h hc hs)
  | doBody body c env labels => exact MSim.toX (step_ret_doBody h hc hs)
  | forOfSrc aw kind p body env labels =>
    simp only [okRetLp, Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at hok
    obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
    refine MSim.toX (step_ret_forOfSrc h hF hc hs hn (le20 h1) h2 ?_ (hK.lookupNoW hW h4))
    intro hi
    rcases h3 with h3 | h3
    · rw [hi] at h3; cases h3
    · exact hK.idx h3
  | forOfIt aw kind p body env labels =>
    simp only [okRetLp, Bool.and_eq_true] at hok
    exact MSim.toX (step_ret_forOfIt h hF hc hs hn (le20 hok.1) (hK.lookupNoW hW hok.2))
  | forOfNext it nx aw kind p body env labels =>
    simp only [okRetLp, Bool.and_eq_true] at hok
    exact MSim.toX (step_ret_forOfNext h hF hFR hc hs hn (le20 hok.1) (hN.zero M _ _ _ h.ffi) (hK.lookupNoW hW hok.2))
  | forOfBody src aw kind p body env labels =>
    simp only [okRetLp, Bool.and_eq_true] at hok
    exact MSim.toX (step_ret_forOfBody h hF hc hs hn (le20 hok.1) (hK.srcIdx hok.2))
  | close c => exact MSim.toX (step_ret_close h hc hs)

theorem simRetB {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hFR : FRLaws FR) (hK : Kp P K)
    (hW : Wp P W) (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : BindF} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .b f :: fs) (hn : s.next + margin < Sim.bound) (hok : okRetB P s S.tab.length v f = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases f with
  | dflt p env mode kind => exact MSim.toX (step_ret_bdflt h hc hs)
  | arr ps rest vs env mode kind => exact MSim.toX (step_ret_arr h hc hs hn (arrB_sound hok))
  | arrSrc ps rest env mode kind =>
    simp only [okRetB, Bool.and_eq_true] at hok
    exact MSim.toX (step_ret_arrSrc h hF hc hs hn (hK.elems hok.1) (arrB_sound hok.2))
  | obj src ps rest used env mode kind =>
    simp only [okRetB, Bool.and_eq_true] at hok
    obtain ⟨⟨h1, h2⟩, h3⟩ := hok
    exact MSim.toX (step_ret_obj h hF hc hs hn h1 (hK.objPat hW h2) (hK.objRestPat hW h3))
  | objKey src p ps rest used env mode kind => simp [okRetB] at hok
  | objVal src k p ps rest used env mode kind => exact MSim.toX (step_ret_objVal h hc hs)
  | collect acc it nx =>
    simp only [okRetB, Bool.and_eq_true] at hok
    exact MSim.toX (step_ret_collect h hF hFR hc hs hn hok.1 (hN.zero M _ _ _ h.ffi) (hK.lookupNoW hW hok.2))
  | collectIt acc => exact MSim.toX (step_ret_collectIt h hF hc hs (hK.lookupNoW hW hok))

end
end Host.Ts.Sim.Disp
