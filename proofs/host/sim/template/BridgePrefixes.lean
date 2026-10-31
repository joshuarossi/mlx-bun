import host.sim.template.FullWorld
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Host.Ts Host.Mlx

/-- Candidate prefix data from a complete bridge snapshot. No prefix law is
assumed: each use is checked against the original replay log by the kernel. -/
def bridgePrefixCandidate (full : FfiAne.St) (count : Nat) : FfiAne.St := Id.run do
  let mut b := FfiAne.St.empty
  for n in [0:count] do
    if let some q := full.handles.get n then
      if let some p := nth? full.programs q then
        if q < b.programs.length then
          if let some old := nth? b.programs q then
            b := { FfiAne.setProgram b q { old with holders := old.holders + 1 } with
              handles := b.handles.set n q }
        else if q == b.programs.length then
          let last := p.ins.foldl Nat.max p.out + 1
          b := { b with surfaces := full.surfaces.take (max b.surfaces.length last) }
          b := FfiAne.addProgram b n (FfiAne.fresh p.prog p.ins p.out)
  return b

/-- Extra candidate definitions only; the serialized machine state's complete
native value is still the actual value supplied to `serFull`. -/
def serBridgePrefixes (p : FS) : Stream.GenM Lean.Expr := do
  for count in [548, 1096, 1644] do
    let b := bridgePrefixCandidate p.1.1.bridge count
    let _ ← Stream.named (mkConst ``FfiAne.St) ("bridge" ++ toString count) b (fun x => pure (toExpr x))
  serFull p

def bridgePrefixesWorld : TWorld Host.Load.Layers.full :=
  { fullWorld with ser := serBridgePrefixes }

end Host.Ts.Sim.Template
