import host.sim.dispatch.Ret2
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.StmtSim

/-! # Dispatch of `.bind p v env mode kind`

Every pattern form has a step lemma. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

/-- The initialized binding's address holds a cell. -/
def bindCellB {S' : Type} (s : St S') (n : Name) (env : Env) : Bool :=
  match lookupEnv n env with
  | some c => (s.cell? c).isSome
  | none => true

theorem bindCellB_sound {S' : Type} {s : St S'} {n : Name} {env : Env} (h : bindCellB s n env = true) :
    ∀ c, lookupEnv n env = some c → (s.cell? c).isSome = true := by
  intro c hc
  simp only [bindCellB, hc] at h
  exact h

def okBind (P : JSP F) (s : St F.S) (n : Nat) (p : Pat) (v : Val) (env : Env) (mode : BindMode) : Bool :=
  match p with
  | .id nm => cellNoWB P env nm && match mode with
    | .init => bindCellB s nm env
    | .assign => presB s aReferenceErrorProto
  | .expr _ => true
  | .array _ rest => elemsB P s n v && (rest.isNone || presB s aArrayProto) && presB s aTypeErrorProto &&
      lookupNoWB P s v
  | .object ps rest => presB s aTypeErrorProto && objPatB P s n v ps && objRestPatB P s n v ps rest
  | .dflt _ _ => true

theorem simBind {okBack : F.S → Arg → Bool} {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hK : Kp P K)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) {p : Pat} {v : Val} {env : Env} {mode : BindMode} {kind : DeclKind}
    (hc : s.ctl = .bind p v env mode kind) (hn : s.next + margin < Sim.bound)
    (hok : okBind P s S.tab.length p v env mode = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases p with
  | id nm =>
    simp only [okBind, Bool.and_eq_true] at hok
    cases mode with
    | init => exact MSim.toX (step_bind_id_init h hc hn (bindCellB_sound hok.2) (hK.cellNoW hW hok.1))
    | assign => exact MSim.toX (step_bind_id_assign h hc hn hok.2 (hK.cellNoW hW hok.1))
  | expr e => exact MSim.toX (step_bind_expr h hc)
  | array ps rest =>
    simp only [okBind, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
    exact MSim.toX (step_bind_array h hF hc hn (hK.elems h1) (arrB_sound h2) h3 (hK.lookupNoW hW h4))
  | object ps rest =>
    simp only [okBind, Bool.and_eq_true] at hok
    obtain ⟨⟨h1, h2⟩, h3⟩ := hok
    exact MSim.toX (step_bind_object h hF hc hn h1 (hK.objPat hW h2) (hK.objRestPat hW h3))
  | dflt q d => exact MSim.toX (step_bind_dflt h hc)

end
end Host.Ts.Sim.Disp
