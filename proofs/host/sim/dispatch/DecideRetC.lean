import host.sim.dispatch.DecideRetE
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Deciders for the side conditions of steps/RetC.lean and steps/RetL.lean

`SpreadOK` (spread arguments and array elements), `ObjRestOK` and `ObjSpreadOK`
(object literals). -/

section
variable {F : Ffi} (P : JSP F)

/-- `SpreadOK`. -/
def spreadB (s : St F.S) (n : Nat) (v : Val) : Bool :=
  elemsB P s n v && lookupB P s n v (.sym symIterator)

/-- `ObjRestOK`. -/
def objRestB (rest : List Property) (env : Env) : Bool :=
  Nat.ble rest.length two20 && rest.all (shortLocal env)

/-- `ObjSpreadOK`: own keys of a typed array are element reads. -/
def objSpreadB (s : St F.S) (n : Nat) (v : Val) : Bool :=
  match v with
  | .obj a => frB P a && (match s.obj? a with
    | some src => nsAllB P src && (match src.kind with
      | .typed _ _ _ _ => allB (typedB P s n src) (ownKeys F s src)
      | _ => true)
    | none => true)
  | _ => true

/-- Shorthand properties' cells (`CellNoW`). -/
def shortCellB (env : Env) : Property → Bool
  | .short n => cellNoWB P env n
  | _ => true

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx} {W : Nat → Option WFrame}

theorem Kp.shortCells (hK : Kp P K) (hW : Wp P W) {env : Env} {rest : List Property}
    (h : allB (shortCellB P env) rest = true) : ∀ n, Property.short n ∈ rest → CellNoW K W env n :=
  fun n hn => hK.cellNoW hW (allB_sound h _ hn)

theorem Kp.spread (hK : Kp P K) (hW : Wp P W) {s : St F.S} {S : SSrv} {v : Val} (h : spreadB P s S.tab.length v = true) :
    SpreadOK F K W s S v := by
  simp only [spreadB, Bool.and_eq_true] at h
  exact ⟨hK.elems h.1, hK.lookup hW h.2⟩

theorem objRestB_sound {rest : List Property} {env : Env} (h : objRestB rest env = true) : ObjRestOK rest env := by
  simp only [objRestB, Bool.and_eq_true] at h
  exact ⟨le20 h.1, h.2⟩

theorem typedOK_plainKind {s : St F.S} {S : SSrv} {o : Obj} {k : PKey}
    (hk : ∀ kk b off n, o.kind ≠ .typed kk b off n) : TypedOK F K s S o k :=
  fun kk b off n _ hko => absurd hko (hk kk b off n)

theorem Kp.objSpread (hK : Kp P K) (hW : Wp P W) {s : St F.S} {S : SSrv} {v : Val}
    (h : objSpreadB P s S.tab.length v = true) : ObjSpreadOK F K W s S v := by
  rintro a rfl
  simp only [objSpreadB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun src hs k hk0 => ?_⟩
  have h2 := h.2
  simp only [hs, Bool.and_eq_true] at h2
  refine ⟨?_, hK.nsOK (s := s) hW h2.1 k⟩
  have h3 := h2.2
  cases hk : src.kind with
  | typed kk b off n =>
    simp only [hk] at h3
    exact hK.typed (allB_sound h3 k hk0)
  | _ => exact typedOK_plainKind (fun _ _ _ _ he => by rw [hk] at he; cases he)

end
end Host.Ts.Sim.Disp
