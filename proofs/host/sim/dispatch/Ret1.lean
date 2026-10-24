import host.sim.dispatch.DecideRetC
import host.sim.dispatch.RetAdapt
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Dispatch of `.ret v` under expression, call and literal frames

Every frame of `ExprF` and `CallF` has a step lemma; of `LitF`, template frames
(`tmpl`, `tagged`) do not. -/

theorem lt_bound_of_margin {n : Nat} (h : n + margin < Sim.bound) : n < Sim.bound :=
  Nat.lt_of_le_of_lt (Nat.le_add_right _ _) h

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

def okRetE (P : JSP F) (s : St F.S) (n : Nat) (v : Val) : ExprF → Bool
  | .unary op => presB s aTypeErrorProto && unB P op v && tyB P s op v
  | .binL _ _ _ => true
  | .binR op a => presB s aTypeErrorProto && presB s aRangeErrorProto && binB P s n op a v && binMapB P s op a v
  | .logL _ _ _ => true
  | .cond _ _ _ => true
  | .seq _ _ => true
  | .member k _ => presB s aTypeErrorProto && lookupB P s n v k
  | .indexL _ _ _ => true
  | .indexR o => presB s aTypeErrorProto && getIndexB P s n o v
  | .priv _ nm _ => presB s aTypeErrorProto && privB P s v nm
  | .chain => true
  | .const _ => true
  | .typeof => tyB P s .typeof v

def okRetC (P : JSP F) (s : St F.S) (n : Nat) (v : Val) : CallF → Bool
  | .callee _ _ _ => true
  | .member k _ _ _ _ => presB s aTypeErrorProto && lookupB P s n v k
  | .index _ _ _ _ _ => true
  | .indexK o _ _ _ => presB s aTypeErrorProto && getIndexB P s n o v
  | .priv _ nm _ _ _ _ => presB s aTypeErrorProto && privB P s v nm
  | .method _ _ _ _ => true
  | .args kind _ _ _ _ env => Nat.blt kind 2 || cellNoWB P env nCls && cellNoWB P env nNt
  | .spread kind _ _ _ _ env => presB s aTypeErrorProto && spreadB P s n v &&
      (Nat.blt kind 2 || cellNoWB P env nCls && cellNoWB P env nNt)
  | .newCallee _ _ => true

def okRetL (P : JSP F) (s : St F.S) (n : Nat) (v : Val) : LitF → Bool
  | .array _ _ _ => presB s aArrayProto
  | .spread _ _ _ => presB s aArrayProto && presB s aTypeErrorProto && spreadB P s n v
  | .object o rest env => frB P o && presB s aFunctionProto && presB s aReferenceErrorProto && objRestB rest env &&
      allB (shortCellB P env) rest
  | .objKey o _ rest env => frB P o && presB s aFunctionProto && presB s aReferenceErrorProto &&
      objRestB rest env && litVB v && bfVB P v && allB (shortCellB P env) rest
  | .objVal o _ rest env => frB P o && presB s aFunctionProto && presB s aReferenceErrorProto && objRestB rest env &&
      allB (shortCellB P env) rest
  | .objSpread o rest env => frB P o && presB s aFunctionProto && presB s aReferenceErrorProto &&
      objRestB rest env && objSpreadB P s n v && allB (shortCellB P env) rest
  | .tmpl _ _ _ _ => false
  | .tagged _ _ _ _ _ => false

variable {okBack : F.S → Arg → Bool}

theorem simRetE {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hFR : FRLaws FR) (hK : Kp P K) (hW : Wp P W)
    (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : ExprF} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .e f :: fs) (hn : s.next + margin < Sim.bound) (hok : okRetE P s S.tab.length v f = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  have hn' := lt_bound_of_margin hn
  cases f with
  | unary op =>
    simp only [okRetE, Bool.and_eq_true] at hok
    exact MSim.toX (step_retE_unary h hFR hn' hc hs hok.1.1 (hK.un hok.1.2) (hK.ty hW hok.2))
  | binL op b env => exact MSim.toX (step_retE_binL h hc hs)
  | binR op a =>
    simp only [okRetE, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
    exact MSim.toX (step_retE_binR h hF hFR hn' hc hs h1 h2 (hK.bin hW h3) (binMapB_sound hK hN h h4))
  | logL op b env => exact MSim.toX (step_retE_logLZ h hFR hc hs (hN.zero M _ _ _ h.ffi))
  | cond a b env => exact MSim.toX (step_retE_condZ h hFR hc hs (hN.zero M _ _ _ h.ffi))
  | seq b env => exact MSim.toX (step_retE_seq h hc hs)
  | member k opt =>
    simp only [okRetE, Bool.and_eq_true] at hok
    exact MSim.toX (step_retE_member h hF hn' hc hs hok.1 (hK.lookup hW hok.2))
  | indexL k env opt => exact MSim.toX (step_retE_indexL h hc hs)
  | indexR o =>
    simp only [okRetE, Bool.and_eq_true] at hok
    exact MSim.toX (step_retE_indexR h hF hn' hc hs hok.1 (hK.getIndex hW hok.2))
  | priv b nm opt =>
    simp only [okRetE, Bool.and_eq_true] at hok
    exact MSim.toX (step_retE_priv h hn' hc hs hok.1 (hK.priv hW hok.2))
  | chain => exact MSim.toX (step_retE_chain h hc hs)
  | const c => exact MSim.toX (step_retE_const h hc hs)
  | typeof => exact MSim.toX (step_retE_typeof h hc hs (hK.ty hW hok rfl))

theorem simRetC {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hK : Kp P K)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : CallF} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .c f :: fs) (hn : s.next + margin < Sim.bound) (hok : okRetC P s S.tab.length v f = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  have hn' := lt_bound_of_margin hn
  cases f with
  | callee args env opt => exact MSim.toX (step_retC_callee h hc hs)
  | member k args env optObj optCall =>
    simp only [okRetC, Bool.and_eq_true] at hok
    exact MSim.toX (step_retC_member h hF hn' hc hs hok.1 (hK.lookup hW hok.2))
  | index ke args env optObj optCall => exact MSim.toX (step_retC_index h hc hs)
  | indexK o args env optCall =>
    simp only [okRetC, Bool.and_eq_true] at hok
    exact MSim.toX (step_retC_indexK h hF hn' hc hs hok.1 (hK.getIndex hW hok.2))
  | priv b nm args env optObj optCall =>
    simp only [okRetC, Bool.and_eq_true] at hok
    exact MSim.toX (step_retC_priv h hn' hc hs hok.1 (hK.priv hW hok.2))
  | method this args env optCall => exact MSim.toX (step_retC_method h hc hs)
  | args kind fn this acc rest env =>
    refine MSim.toX (step_retC_args h hc hs fun hk2 => ?_)
    simp only [okRetC, Bool.or_eq_true, Bool.and_eq_true, Nat.blt_eq] at hok
    rcases hok with hlt | ⟨h1, h2⟩
    · omega
    · exact ⟨hK.cellNoW hW h1, hK.cellNoW hW h2⟩
  | spread kind fn this acc rest env =>
    simp only [okRetC, Bool.and_eq_true] at hok
    refine MSim.toX (step_retC_spread h hF hn' hc hs hok.1.1 (hK.spread hW hok.1.2) fun hk2 => ?_)
    have h3 := hok.2
    simp only [Bool.or_eq_true, Bool.and_eq_true, Nat.blt_eq] at h3
    rcases h3 with hlt | ⟨h1, h2⟩
    · omega
    · exact ⟨hK.cellNoW hW h1, hK.cellNoW hW h2⟩
  | newCallee args env => exact MSim.toX (step_retC_newCallee h hc hs)

theorem simRetL {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hK : Kp P K)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : LitF} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .l f :: fs) (hn : s.next + margin < Sim.bound) (hok : okRetL P s S.tab.length v f = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  have hn' := lt_bound_of_margin hn
  cases f with
  | array acc rest env => exact MSim.toX (step_retL_array h hn' hc hs hok)
  | spread acc rest env =>
    simp only [okRetL, Bool.and_eq_true] at hok
    exact MSim.toX (step_retL_spread h hF hn' hc hs hok.1.1 hok.1.2 (hK.spread hW hok.2))
  | object o rest env =>
    simp only [okRetL, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := hok
    exact MSim.toX (step_retL_object h hn hc hs (hK.fr_none h1) h2 h3 (objRestB_sound h4) (hK.shortCells hW h5))
  | objKey o p rest env =>
    simp only [okRetL, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩ := hok
    exact MSim.toX (step_retL_objKey h hn hc hs (hK.fr_none h1) h2 h3 (objRestB_sound h4) (litVB_sound h5)
      (hK.bfV h6) (hK.shortCells hW h7))
  | objVal o k rest env =>
    simp only [okRetL, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := hok
    exact MSim.toX (step_retL_objVal h hn hc hs (hK.fr_none h1) h2 h3 (objRestB_sound h4) (hK.shortCells hW h5))
  | objSpread o rest env =>
    simp only [okRetL, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := hok
    exact MSim.toX (step_retL_objSpread h hF hn hc hs (hK.fr_none h1) h2 h3 (objRestB_sound h4) (hK.objSpread hW h5)
      (hK.shortCells hW h6))
  | tmpl acc quasis subs env => simp [okRetL] at hok
  | tagged tag quasis acc subs env => simp [okRetL] at hok

end
end Host.Ts.Sim.Disp
