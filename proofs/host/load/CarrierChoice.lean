import host.mlx.GraphBuildCommand
import host.mlx.GraphCertificate
import host.load.Inputs
import host.mlx.KernelSources
import Lean

namespace Host.Load.CarrierChoice
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts

private def handle : Ffi.Prim → Option Nat
  | .kernel k _ _ => some k
  | .replayed _ p => handle p
  | _ => none

/-- Search only: resolve each native kernel binding once and bucket nodes by
their input carriers. The resulting data is still checked against the
original source graph by `ffi_check_family`. -/
def choose (native : Ffi.St) (sources : KernelSources)
    (expected : List (RNode Int InKey)) (inputs : InKey → Option Nat) (lower : Nat := 0) (upper : Nat := native.nnext) : Except String (List Nat) := do
  let mut kernels : Std.HashMap Nat (Option (List Char)) := {}
  for i in [:native.nnext] do
    if let some n := native.nodes.get i then
      if let some k := handle n.prim then
        if !kernels.contains k then kernels := kernels.insert k (kernelName? sources native k)
  let name := fun k => (kernels[k]?).join
  let mut actual : Array (Option (RNode Int InKey)) := Array.replicate native.nnext none
  let mut buckets : Std.HashMap (List Nat) (Array Nat) := {}
  let mut exponentials : Array Nat := #[]
  for i in [:native.nnext] do
    if let some n := (native.nodes.get i).bind (resolveNode (concrete (CSrv.val ⟨[]⟩)) name) then
      actual := actual.set! i (some n)
      if i < upper then
        buckets := buckets.insert n.ins ((buckets[n.ins]?).getD #[] |>.push i)
        if isExp n.prim then exponentials := exponentials.push i
  let graph := fun i => actual[i]?.join
  let mut cert : Array Nat := #[]
  let mut used : Std.HashSet Nat := {}
  for e in expected do
    let k := cert.size
    let carrier ← match e.prim with
      | .input key => match inputs key with
        | some i => pure i
        | none => throw s!"missing input at expected node {k}"
      | _ => do
        let ins := e.ins.map (cert[·]?.getD 0)
        let candidates := if e.prim = .computeG then exponentials else (buckets[ins]?).getD #[]
        let accepts := fun i => ins.all (· < i) &&
          if e.prim = .computeG then decide (cgLeaves graph i = some ins)
          else !isExp e.prim && match graph i with
            | none => false
            | some r => decide (strip r.prim = e.prim ∧
                (r.prim = e.prim ∨ elementwise e.prim = false) ∧ r.ins = ins)
        let found := (candidates.find? fun i => lower ≤ i && !used.contains i && accepts i).orElse fun _ =>
          (candidates.find? fun i => !used.contains i && accepts i).orElse fun _ =>
          candidates.find? accepts
        match found with
        | some i => pure i
        | none => throw s!"no carrier at expected node {k}; candidates={candidates.size}; ins={ins}; prefix={cert.toList}; primitive={Lean.toExpr e.prim}"
    cert := cert.push carrier
    used := used.insert carrier
  return cert.toList

end Host.Load.CarrierChoice
