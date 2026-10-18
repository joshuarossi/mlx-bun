import host.ts.RenameStateValuationRebase
import host.ts.RenameAnnotatedLoop

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.LoopVariables
open Host.Ts

def oracleVariables (i : Nat) : SymE := .var (2*i)
def loopVariables (i : Nat) : SymE := .var (2*i+1)
def valuation (oracle loop : Nat → F64) (i : Nat) : F64 :=
  if i % 2 = 0 then oracle (i/2) else loop (i/2)

theorem oracle_projection (oracle loop : Nat → F64) :
    nextValuation oracleVariables (valuation oracle loop) = oracle := by
  funext i
  change valuation oracle loop (2*i) = oracle i
  have even : (2*i)%2 = 0 := by omega
  have half : (2*i)/2 = i := by omega
  simp only [valuation,even,ite_true,half]

theorem loop_projection (oracle loop : Nat → F64) :
    nextValuation loopVariables (valuation oracle loop) = loop := by
  funext i
  change valuation oracle loop (2*i+1) = loop i
  have odd : ¬ (2*i+1)%2 = 0 := by omega
  have half : (2*i+1)/2 = i := by omega
  simp only [valuation,ite_eq_right odd,half]

theorem namespaces_disjoint (i j : Nat) : 2*i ≠ 2*j+1 := by omega

theorem oracle_expression (oracle loop : Nat → F64) (expression : SymE) :
    (expression.subst oracleVariables).eval (valuation oracle loop) = expression.eval oracle := by
  rw [SymE.eval_subst]
  change expression.eval (nextValuation oracleVariables (valuation oracle loop)) = _
  rw [oracle_projection]

theorem loop_expression (oracle loop : Nat → F64) (expression : SymE) :
    (expression.subst loopVariables).eval (valuation oracle loop) = expression.eval loop := by
  rw [SymE.eval_subst]
  change expression.eval (nextValuation loopVariables (valuation oracle loop)) = _
  rw [loop_projection]

def cacheIndex : SymE := cacheTime.subst loopVariables
def capacity : SymE := (SymE.var 3).subst loopVariables

theorem cache_index_eval (oracle : Nat → F64) (prompt index limit size : Nat)
    (bound : prompt+index+1 < 2^53) :
    cacheIndex.eval (valuation oracle (loopValuation prompt index limit size)) =
      F64.ofNat (prompt+index+1) := by
  rw [cacheIndex,loop_expression]
  exact cacheTime_eval prompt index limit size bound

theorem capacity_eval (oracle : Nat → F64) (prompt index limit size : Nat) :
    capacity.eval (valuation oracle (loopValuation prompt index limit size)) = F64.ofNat size := by
  rw [capacity,loop_expression]
  rfl

theorem instantiate {oracle : Nat → F64} {server : SSrv} {concrete : CSrv}
    (loop : Nat → F64) (current : Inst oracle server concrete) :
    Inst (valuation oracle loop) (server.substitute oracleVariables) concrete := by
  apply Inst.substitute_valuation oracleVariables
  simpa only [oracle_projection] using current

theorem answers (oracle loop : Nat → F64) (pending : List Ans) :
    Good (valuation oracle loop) (pending.map (Ans.subst oracleVariables)) ↔ Good oracle pending := by
  rw [good_subst]
  change Good (nextValuation oracleVariables (valuation oracle loop)) pending ↔ _
  rw [oracle_projection]

/-- A newly discovered comparison records the same answer after embedding,
for arbitrary future expressions, not only the current finite table. -/
theorem future_answer (oracle loop : Nat → F64) (op : NTest) (a b : SymE) :
    F64.test op ((a.subst oracleVariables).eval (valuation oracle loop))
      ((b.subst oracleVariables).eval (valuation oracle loop)) =
      F64.test op (a.eval oracle) (b.eval oracle) := by
  rw [oracle_expression,oracle_expression]

end Host.Ts.Owned.Annotated.LoopVariables

namespace Host.Ts
open Owned.Annotated

theorem SSrv.val_substitute (θ : Nat → SymE) (server : SSrv) (value : NumV) :
    (server.substitute θ).val value = (server.val value).map (SymE.subst θ) := by
  cases value with
  | lit number => rfl
  | ref index => exact nth?_map (SymE.subst θ) server.tab index

theorem SSrv.push_substitute (θ : Nat → SymE) (server : SSrv) (expression : SymE) :
    ({server with tab := server.tab ++ [expression]}).substitute θ =
      {server.substitute θ with tab := (server.substitute θ).tab ++ [expression.subst θ]} := by
  simp only [SSrv.substitute,List.map_append,List.map_cons,List.map_nil]

/-- Future matching queries consume exactly the substituted pending answer.
New arithmetic references still use the same table length and indexes. -/
theorem SSrv.answer_substitute (θ : Nat → SymE) (server next : SSrv) (op : NTest) (a b : SymE) (answer : Bool)
    (accepted : server.answer op a b = some (answer,next)) :
    (server.substitute θ).answer op (a.subst θ) (b.subst θ) = some (answer,next.substitute θ) := by
  cases pending : server.oracle with
  | nil => simp only [SSrv.answer,pending] at accepted; cases accepted
  | cons query rest =>
    by_cases matching : query.op = op ∧ query.a = a ∧ query.b = b
    · simp only [SSrv.answer,pending,matching] at accepted
      obtain ⟨rfl,rfl⟩ := accepted
      simp only [SSrv.answer,SSrv.substitute,pending,List.map_cons,Ans.subst,
        matching.1,matching.2.1,matching.2.2,and_self,decide_true,Bool.cond_true]
    · simp only [SSrv.answer,pending,matching,decide_false,Bool.cond_false] at accepted
      cases accepted

/-- The protocol commutes with substitution for an arbitrary future request
tree. Arithmetic allocates the same reference indexes; comparisons consume
the substituted query and answer; concretization keeps the original literal. -/
theorem interpS_substitute {α : Type} (θ : Nat → SymE) (computation : Free α) :
    ∀ (server : SSrv) (result : α) (next : SSrv),
      interpS computation server = some (result,next) →
      interpS computation (server.substitute θ) = some (result,next.substitute θ) := by
  induction computation with
  | pure value =>
    intro server result next accepted
    obtain ⟨rfl,rfl⟩ := Option.some.inj accepted
    rfl
  | fail reason =>
    intro server result next accepted
    cases accepted
  | bin op a b k ih =>
    intro server result next accepted
    cases left : server.val a with
    | none => simp only [interpS_bin,left] at accepted; cases accepted
    | some x =>
      cases right : server.val b with
      | none => simp only [interpS_bin,left,right] at accepted; cases accepted
      | some y =>
        simp only [interpS_bin,left,right] at accepted
        rw [interpS_bin,SSrv.val_substitute,SSrv.val_substitute,left,right]
        simp only [Option.map_some,SSrv.substitute_length]
        simpa only [SSrv.push_substitute,SymE.subst] using ih server.tab.length _ result next accepted
  | un op a k ih =>
    intro server result next accepted
    cases value : server.val a with
    | none => simp only [interpS_un,value] at accepted; cases accepted
    | some x =>
      simp only [interpS_un,value] at accepted
      rw [interpS_un,SSrv.val_substitute,value]
      simp only [Option.map_some,SSrv.substitute_length]
      simpa only [SSrv.push_substitute,SymE.subst] using ih server.tab.length _ result next accepted
  | test op a b k ih =>
    intro server result next accepted
    cases left : server.val a with
    | none => simp only [interpS_test,left] at accepted; cases accepted
    | some x =>
      cases right : server.val b with
      | none => simp only [interpS_test,left,right] at accepted; cases accepted
      | some y =>
        cases answer : server.answer op x y with
        | none => simp only [interpS_test,left,right,answer] at accepted; cases accepted
        | some pair =>
          obtain ⟨boolean,current⟩ := pair
          simp only [interpS_test,left,right,answer] at accepted
          rw [interpS_test,SSrv.val_substitute,SSrv.val_substitute,left,right]
          simp only [Option.map_some,SSrv.answer_substitute θ server current op x y boolean answer]
          exact ih boolean current result next accepted
  | conc a k ih =>
    intro server result next accepted
    cases value : server.val a with
    | none => simp only [interpS_conc,value] at accepted; cases accepted
    | some expression =>
      cases expression with
      | lit number =>
        simp only [interpS_conc,value] at accepted
        rw [interpS_conc,SSrv.val_substitute,value]
        simp only [Option.map_some,SymE.subst]
        exact ih number server result next accepted
      | var index => simp only [interpS_conc,value] at accepted; cases accepted
      | bin op x y => simp only [interpS_conc,value] at accepted; cases accepted
      | un op x => simp only [interpS_conc,value] at accepted; cases accepted

theorem runS_substitute (F : Ffi) (θ : Nat → SymE) (steps : Nat) :
    ∀ (source target : St F.S) (server next : SSrv),
      runS F steps source server = some (target,next) →
      runS F steps source (server.substitute θ) = some (target,next.substitute θ) := by
  induction steps with
  | zero =>
    intro source target server next accepted
    obtain ⟨rfl,rfl⟩ := Option.some.inj accepted
    rfl
  | succ count ih =>
    intro source target server next accepted
    cases halted : isHalt source.ctl with
    | true =>
      simp only [runS,runWith_succ,halted,Bool.cond_true,Option.some.injEq,Prod.mk.injEq] at accepted
      obtain ⟨rfl,rfl⟩ := accepted
      simp only [runS,runWith_succ,halted,Bool.cond_true]
    | false =>
      cases first : interpS (step F source).run server with
      | none => simp only [runS,runWith_succ,halted,Bool.cond_false,first] at accepted; cases accepted
      | some pair =>
        obtain ⟨middle,current⟩ := pair
        simp only [runS,runWith_succ,halted,Bool.cond_false,first,St.rebuild_eq] at accepted
        have embedded := interpS_substitute θ (step F source).run server middle current first
        simp only [runS,runWith_succ,halted,Bool.cond_false,embedded,St.rebuild_eq]
        exact ih middle target current next accepted

end Host.Ts
