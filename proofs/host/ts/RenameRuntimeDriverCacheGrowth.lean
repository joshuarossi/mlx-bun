import host.ts.RenameRuntimeDriverGuardedComparison
import host.ts.RenameCacheComparisonGuards

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- A cache growth comparison consumes the retained capacity and index
occurrences. Its target branch follows from exact bounded integer ranges. -/
elab "host_retained_cache_growth " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let original := pre ++ `Comparison
  let originalName := mkIdent (name.getId ++ `Comparison)
  elabCommand (← `(host_retained_guarded_comparison $f, $s using $initial to $t using $next as $originalName))
  let full ← liftTermElabM do
    let kind ← whnf (mkConst (original ++ `kind))
    unless kind.isConstOf ``Parametric.ComparisonKind.lt do
      throwError "host_retained_cache_growth: expected source less-than comparison"
    let answer ← whnf (← mkAppM ``F64.test #[← mkAppM ``Parametric.ComparisonKind.numOp #[kind],
      mkConst (original ++ `sourceLeft),mkConst (original ++ `sourceRight)])
    if answer.isConstOf ``Bool.true then pure true
    else if answer.isConstOf ``Bool.false then pure false
    else throwError "host_retained_cache_growth: source comparison was not decided"
  liftTermElabM do
    for tag in [`F,`input,`output,`initialServer,`nextServer] do
      addData (pre ++ tag) (mkConst (original ++ tag))
  let n := "_root_." ++ pre.toString
  let c := "_root_." ++ original.toString
  let answer := if full then "true" else "false"
  let domain := if full then
      "(c : Nat) (indexValue : indexMeaning.eval ν = F64.ofNat c)\n" ++
      "(capacityValue : capacityMeaning.eval ν = F64.ofNat c) (nextBound : c+1 < 2^31)"
    else "(i c : Nat) (indexValue : indexMeaning.eval ν = F64.ofNat i)\n" ++
      "(capacityValue : capacityMeaning.eval ν = F64.ofNat c) (capacityBound : c < 2^31) (fits : i+1 ≤ c)"
  let guardProof := if full then
      "CacheGuards.full_growth ν indexMeaning capacityMeaning c indexValue capacityValue nextBound"
    else "CacheGuards.no_growth ν indexMeaning capacityMeaning i c indexValue capacityValue capacityBound fits"
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_answer : F64.test {c}.kind.numOp {c}.sourceLeft {c}.sourceRight = {answer} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (indexMeaning capacityMeaning : SymE) (tail : List Annotated.Tree)
      (controlNote : notes.runtime.control = returnNote (.literal (.bin .add indexMeaning (.lit (F64.ofNat 1)))))
      (stackNotes : notes.runtime.stack = binaryRightNote .lt (.literal capacityMeaning)::tail)
      {domain} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool {answer}) tail))
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      have guard : F64.test {c}.kind.numOp (capacityMeaning.eval ν)
          ((SymE.bin .add indexMeaning (.lit (F64.ofNat 1))).eval ν) =
          F64.test {c}.kind.numOp {c}.sourceLeft {c}.sourceRight := by
        rw [{n}.source_answer]
        exact {guardProof}
      exact {c}.retained_transport notes ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory
        capacityMeaning (.bin .add indexMeaning (.lit (F64.ofNat 1)))
        (.literal capacityMeaning) (.literal (.bin .add indexMeaning (.lit (F64.ofNat 1))))
        tail controlNote stackNotes (.literal _) (.literal _) guard")
end Host.Ts.Owned.Annotated.Driver
