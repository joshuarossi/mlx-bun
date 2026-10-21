import host.sim.dispatch.DecideExpr
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Dispatch of `.ev e env`

Every expression form has a step lemma except a class expression without a
heritage clause (`defineClass` is not simulated). -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

def okEv (P : JSP F) (s : St F.S) (e : Expr) (env : Env) : Bool :=
  match e with
  | .lit l => litB P l
  | .id n => presB s aReferenceErrorProto && varB s env n
  | .this => presB s aReferenceErrorProto && varB s env nThis
  | .super => true
  | .template _ _ _ => true
  | .array _ => presB s aArrayProto
  | .object props => presB s aObjectProto && presB s aFunctionProto && presB s aReferenceErrorProto &&
      Nat.ble props.length two20 && allB (shortB s env) props
  | .func _ => presB s aFunctionProto
  | .arrow _ => presB s aFunctionProto
  | .cls (.mk _ sup _) => sup.isSome
  | .member _ _ _ => true
  | .priv _ _ _ => true
  | .index _ _ _ => true
  | .call _ _ _ => true
  | .new _ _ => true
  | .chain _ => true
  | .unary op x => match op, x with
    | .typeof, .id n => varB s env n
    | _, _ => true
  | .update _ _ x => presB s aReferenceErrorProto && (match x with
    | .id n => varB s env n
    | _ => true)
  | .bin _ _ _ => true
  | .log _ _ _ => true
  | .cond _ _ _ => true
  | .assign op target _ => presB s aReferenceErrorProto && (match target with
    | .id n => (match op with
      | .assign => true
      | _ => varB s env n)
    | _ => true)
  | .seq _ _ => true
  | .yield _ _ => true
  | .await _ => true

theorem simEv {okBack : F.S → Arg → Bool} {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hK : Kp P K)
    (h : Rel F FR M ν K s S t C) {e : Expr} {env : Env} (hc : s.ctl = .ev e env)
    (hn : s.next + margin < Sim.bound) (hok : okEv P s e env = true) :
    MSim (PX F FR M ν K S C) S C (step F s) (step F t) := by
  cases e with
  | lit l => exact MSim.toX (step_lit h hF hc hn (hK.lit hok))
  | id n =>
    simp only [okEv, Bool.and_eq_true] at hok
    exact MSim.toX (step_id h hF hc hn hok.1 (varB_sound hok.2))
  | this =>
    simp only [okEv, Bool.and_eq_true] at hok
    exact MSim.toX (step_this h hF hc hn hok.1 (varB_sound hok.2))
  | super => exact MSim.toX (step_super h hc)
  | template tag quasis subs =>
    cases tag with
    | none => exact MSim.toX (step_template h hc)
    | some tag => exact MSim.toX (step_tagged h hc)
  | array elems => exact MSim.toX (step_array h hc hn hok)
  | object props =>
    simp only [okEv, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := hok
    exact MSim.toX (step_object h hF hc hn h1 h2 h3 (le20 h4) (shortB_sound h5))
  | func f => exact MSim.toX (step_func h hc hn hok)
  | arrow f => exact MSim.toX (step_arrow h hc hn hok)
  | cls c =>
    obtain ⟨name, sup, ms⟩ := c
    cases sup with
    | none => simp [okEv] at hok
    | some sup => exact MSim.toX (step_cls_extends h hc)
  | member o p opt => exact MSim.toX (step_member h hc)
  | priv o n opt => exact MSim.toX (step_priv h hc)
  | index o k opt => exact MSim.toX (step_index h hc)
  | call callee args opt => exact MSim.toX (step_call h hc)
  | new callee args => exact MSim.toX (step_new h hc)
  | chain e => exact MSim.toX (step_chain h hc)
  | unary op x =>
    refine MSim.toX (step_unary h hF hc ?_)
    rintro n rfl rfl
    simp only [okEv] at hok
    exact varB_sound hok
  | update inc pre x =>
    simp only [okEv, Bool.and_eq_true] at hok
    refine MSim.toX (step_update h hF hc hn hok.1 ?_)
    rintro n rfl
    have h2 := hok.2
    simp only at h2
    exact varB_sound h2
  | bin op a b => exact MSim.toX (step_bin h hc)
  | log op a b => exact MSim.toX (step_log h hc)
  | cond c a b => exact MSim.toX (step_cond h hc)
  | assign op target v =>
    simp only [okEv, Bool.and_eq_true] at hok
    refine MSim.toX (step_assign h hF hc hn hok.1 ?_)
    rintro n rfl hop
    have h2 := hok.2
    cases op with
    | assign => exact absurd rfl hop
    | bin _ => exact varB_sound h2
    | log _ => exact varB_sound h2
  | seq a b => exact MSim.toX (step_seq h hc)
  | yield arg d => exact MSim.toX (step_yield h hc)
  | await e => exact MSim.toX (step_await h hc)

end
end Host.Ts.Sim.Disp
