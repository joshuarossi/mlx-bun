import host.sim.dispatch.DecideRetE
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Deciders for the side conditions of steps/RetA.lean

`ReadTargetOK`, `StoreTargetOK`, `AsgReadOK` and `UpdOldOK` (the `put` frame of a
compound assignment uses `BinOK`/`BinMapOK`, a plain one `StoreTargetOKX` of PutAdapt.lean). -/

section
variable {F : Ffi} (P : JSP F)

/-- `ReadTargetOK`. -/
def readTargetB (s : St F.S) (n : Nat) : Target → Bool
  | .var nm env => match lookupEnv nm env with
    | none => plainKeyB (.str nm) || chainB P s n (.str nm) 16 aGlobal
    | some _ => true
  | .prop o k => lookupB P s n o k
  | .priv _ _ _ => true

/-- `StoreTargetOK`. -/
def storeTargetB (s : St F.S) (n : Nat) (x : Target) (v : Val) : Bool :=
  match x with
  | .var _ _ => true
  | .prop o k => putB P s n o k v
  | .priv o _ _ => match o with
    | .obj a => frB P a
    | _ => true

/-- `AsgReadOK`. -/
def asgReadB (s : St F.S) (n : Nat) (op : AsgOp) (x : Target) : Bool :=
  match op with
  | .assign => true
  | _ => readTargetB P s n x

/-- `UpdOldOK`. -/
def updOldB (s : St F.S) (n : Nat) (inc : Bool) (x : Target) (v : Val) : Bool :=
  match v with
  | .big i => bfB P i && bfB P (bif inc then i + 1 else i - 1) &&
      storeTargetB P s n x (.big (bif inc then i + 1 else i - 1))
  | _ => storeTargetB P s n x (.num zeroN)

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx}

theorem Kp.readTarget (hK : Kp P K) {s : St F.S} {S : SSrv} {x : Target}
    (h : readTargetB P s S.tab.length x = true) : ReadTargetOK F K s S x := by
  cases x with
  | var nm env =>
    intro hl
    simp only [readTargetB, hl, Bool.or_eq_true] at h
    rcases h with h | h
    · have := plainKeyB_sound h
      exact ChainOK.of_plain this.1 this.2 16 aGlobal
    · exact hK.chain h
  | prop o k => exact hK.lookup h
  | priv _ _ _ => trivial

theorem Kp.storeTarget (hK : Kp P K) {s : St F.S} {S : SSrv} {x : Target} {v : Val}
    (h : storeTargetB P s S.tab.length x v = true) : StoreTargetOK F K s S x v := by
  cases x with
  | var _ _ => trivial
  | prop o k => exact hK.put h
  | priv o _ _ =>
    rintro a rfl
    exact hK.fr_none h

theorem Kp.asgRead (hK : Kp P K) {s : St F.S} {S : SSrv} {op : AsgOp} {x : Target}
    (h : asgReadB P s S.tab.length op x = true) : AsgReadOK F K s S op x := by
  cases op with
  | assign => trivial
  | bin _ => exact hK.readTarget h
  | log _ => exact hK.readTarget h

theorem Kp.updOld (hK : Kp P K) {s : St F.S} {S : SSrv} {inc : Bool} {x : Target} {v : Val}
    (h : updOldB P s S.tab.length inc x v = true) : UpdOldOK F K s S inc x v := by
  cases v <;> simp only [updOldB, Bool.and_eq_true] at h <;> simp only [UpdOldOK] <;>
    first
    | exact ⟨hK.bf h.1.1, hK.bf h.1.2, hK.storeTarget h.2⟩
    | exact hK.storeTarget h

end
end Host.Ts.Sim.Disp
