import host.sim.compose.a4b.GraphColdCandidate0
import host.sim.compose.a4b.GraphColdCandidate1
import host.sim.compose.a4b.GraphColdCandidate2
import host.sim.compose.a4b.GraphColdCandidate3
import host.sim.compose.a4b.GraphColdCandidate4
import host.sim.compose.a4b.GraphColdCandidate5
import host.sim.compose.a4b.GraphColdCandidate6
import host.sim.compose.a4b.GraphColdCandidate7
import host.sim.compose.a4b.GraphColdCandidate8
import host.sim.compose.a4b.GraphColdCandidate9
import host.sim.compose.a4b.GraphColdCandidate10
import host.sim.compose.a4b.GraphColdCandidate11
import host.sim.compose.a4b.GraphColdCandidate12
import host.sim.compose.a4b.GraphColdCandidate13
import host.sim.compose.a4b.GraphColdCandidate14
import host.sim.compose.a4b.GraphColdCandidate15
import host.sim.compose.a4b.GraphColdCandidate16
import host.sim.compose.a4b.GraphColdCandidate17
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

def candidateNodes : Array (Option (RNode PDim InKey)) := candidateChunk0 ++ candidateChunk1 ++ candidateChunk2 ++ candidateChunk3 ++ candidateChunk4 ++ candidateChunk5 ++ candidateChunk6 ++ candidateChunk7 ++ candidateChunk8 ++ candidateChunk9 ++ candidateChunk10 ++ candidateChunk11 ++ candidateChunk12 ++ candidateChunk13 ++ candidateChunk14 ++ candidateChunk15 ++ candidateChunk16 ++ candidateChunk17

/-! Untrusted metadata choice; actual_cache_output checks every pair later. -/
open Lean Meta Elab Term in
run_elab do
  let e ← instantiateMVars (← Term.elabTermAndSynthesize (← `(((loadedT endLoad (entryEnv Host.Load.Run.Prompt.P.s0)).map (fun l => l.cache.map cacheNodePair)).getD [])) none)
  let ty ← inferType e
  let value ← Meta.reduce e (skipTypes := true)
  let decl := Declaration.defnDecl { name := (← getCurrNamespace) ++ `candidateOutputs, levelParams := [], type := ty, value := value, hints := .regular 0, safety := .safe }
  addDecl decl
  compileDecl decl
end Host.Ts.Sim.Compose.ColdGraph
