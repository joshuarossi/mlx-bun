import host.sim.compose.a4b.GraphColdCandidateBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open Lean Meta Elab Term in
run_elab do
  let e ← instantiateMVars (← Term.elabTermAndSynthesize (← `(((List.range 1024).map (fun k => candidateAt (16384 + k))).toArray)) none)
  let ty ← inferType e
  let value ← Meta.reduce e (skipTypes := true)
  let decl := Declaration.defnDecl { name := (← getCurrNamespace) ++ `candidateChunk16, levelParams := [], type := ty, value := value, hints := .regular 0, safety := .safe }
  addDecl decl
  compileDecl decl
end Host.Ts.Sim.Compose.ColdGraph
