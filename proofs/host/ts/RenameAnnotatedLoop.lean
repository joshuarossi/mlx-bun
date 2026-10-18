import host.ts.RenameAnnotationResources
import host.ts.RenameLoopInvariant
import host.ts.RenameIntegerPacking
namespace Host.Ts.Owned.Annotated

/-- Fixed names for source loop roles, independent of numeric-server indexes. -/
def loopValuation (prompt index limit capacity : Nat) : Nat → F64
  | 0 => F64.ofNat prompt | 1 => F64.ofNat index
  | 2 => F64.ofNat limit | 3 => F64.ofNat capacity | _ => F64.ofNat 0

def cacheTime : SymE := .bin .add (.bin .add (.var 0) (.var 1)) (.lit (F64.ofNat 1))

def advanceRoles (growth : Bool) : Nat → SymE
  | 0 => .var 0 | 1 => .bin .add (.var 1) (.lit (F64.ofNat 1))
  | 2 => .var 2 | 3 => if growth then .bin .add (.var 3) (.lit (F64.ofNat 256)) else .var 3
  | k => .var k

theorem cacheTime_eval (prompt index limit capacity : Nat) (h : prompt + index + 1 < 2^53) :
    cacheTime.eval (loopValuation prompt index limit capacity) = F64.ofNat (prompt+index+1) := by
  simp only [cacheTime,SymE.eval,loopValuation,F64.bin]
  rw [F64.add_ofNat53 prompt index (by omega),F64.add_ofNat53 (prompt+index) 1 h]

theorem advanceRoles_eval (prompt index limit capacity : Nat) (growth : Bool)
    (hi : index+1 < 2^53) (hc : capacity+256 < 2^53) :
    nextValuation (advanceRoles growth) (loopValuation prompt index limit capacity) =
      loopValuation prompt (index+1) limit (if growth then capacity+256 else capacity) := by
  funext k
  cases k with
  | zero => rfl
  | succ k => cases k with
    | zero => exact F64.add_ofNat53 index 1 hi
    | succ k => cases k with
      | zero => rfl
      | succ k => cases k with
        | zero => cases growth <;> simp only [nextValuation,advanceRoles,SymE.eval,loopValuation,Bool.false_eq_true,↓reduceIte]
                  exact F64.add_ofNat53 capacity 256 hc
        | succ k => rfl

/-- A literal-sensitive occurrence annotation at an actual runtime location. -/
def At {S : Type} (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) (p : LoopPlace) (role : Value) : Prop :=
  ∃ v, p.read s = some v ∧ role.Holds ν C R v

/-- The numeric part of the ordinary source cut. The selected meaning is fixed
by data. In particular, literals used by BigInt and native integer decoders
cannot be replaced by unresolved references. -/
structure LoopNumbers {S : Type} (ν : Nat → F64) (C : CSrv) (R : Ren)
    (places : LoopRolePlaces) (s : St S) : Prop where
  generated : At ν C R s places.generated (.literal (.var 1))
  stepIndex : At ν C R s places.stepIndex (.literal (.var 1))
  maximum : At ν C R s places.maxTokens (.num (.var 2))
  offsets : ∀ p ∈ places.cacheOffsets, At ν C R s p (.literal cacheTime)

/-- Every supported ordinary cut instantiates this concrete annotation. This
uses all64 source cache offsets and preserves their literal representation. -/
theorem SupportedOrdinaryCut.loopNumbers {F : Ffi} {native : F.S → Host.Mlx.Ffi.St}
    {places : LoopRolePlaces} {C : CSrv} {s : St F.S} {prompt index limit capacity : Nat}
    {recorded : List Val} {token : NumV} {future : List NumV}
    (cut : Host.Ts.SupportedOrdinaryCut F native places C s prompt index limit capacity recorded token future)
    (R : Ren) : LoopNumbers (loopValuation prompt index limit capacity) C R places s := by
  refine ⟨⟨natV index,cut.generatedLiteral,.literal (.var 1) _ rfl⟩,
    ⟨natV index,cut.stepIndexLiteral,.literal (.var 1) _ rfl⟩,?_,?_⟩
  · have h := cut.maximum
    unfold LoopPlace.number at h
    cases hv : places.maxTokens.read s with
    | none => simp [hv] at h
    | some v => cases v <;> simp only [hv] at h
                all_goals try cases h
                case num n => exact ⟨.num n,hv,.num (.var 2) n h⟩
  · intro p hp
    refine ⟨natV (prompt+index+1),cut.offsetLiterals p hp,.literal cacheTime _ ?_⟩
    change some (F64.ofNat (prompt+index+1)) = some _
    rw [cacheTime_eval prompt index limit capacity]
    have h := cut.supported
    have hi := cut.lookahead
    omega

/-- A post-body annotation with the explicit I+1/capacity expression is exactly
the next cut's fixed role under the advanced valuation. No new existential
numeric meaning is selected while resetting the loop template. -/
theorem Tree.loop_rebase {C : CSrv} (R K : Ren) (role : Tree) (value : Owned.Tree)
    (prompt index limit capacity : Nat) (growth : Bool)
    (hi : index+1 < 2^53) (hc : capacity+256 < 2^53) :
    ((role.rename K).subst (advanceRoles growth)).Holds
      (loopValuation prompt index limit capacity) C R value ↔
    role.Holds (loopValuation prompt (index+1) limit (if growth then capacity+256 else capacity))
      C (composeResources R K) value := by
  rw [Tree.rebase,advanceRoles_eval prompt index limit capacity growth hi hc]

end Host.Ts.Owned.Annotated
