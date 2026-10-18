import host.load.run.full.InitializedCaptures
import host.ts.renameOrdinary.RankOriginOwnership
import host.ts.Chunk

set_option Elab.async false
namespace Host.Load.Run.Full
host_stream_state P.micro3275 0
set_option maxRecDepth 1000000 in
host_chunk P.micro3275 0
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Load Host.Ts.Owned Host.Ts.Owned.Annotated

/-- Compose the already checked full-source prefix with the missing final
9942-step segment to the saved rank-entry boundary. -/
theorem source_rank_prefix : runS P.F 32741797 P.s0 P.S0 = some (input,P.micro3275.S1) := by
  have last : runS P.F 9942 P.s3275 P.S3275 = some (input,P.micro3275.S1) := P.micro3275.c0
  exact runS_trans P.F (m := 32731855) (n := 9942) P.prefixRun3275 last

noncomputable def rankAnswers : List Ans := P.O.take 7

theorem rank_answers : P.S0.oracle = rankAnswers ++ P.micro3275.S1.oracle := by rfl

theorem rank_answers_iff (ρ : Nat → F64) : Good ρ rankAnswers ↔
    F64.test .lt (.fin false 1 0) (ρ 0) = true ∧
    F64.test .lt (.fin false 2 0) (ρ 0) = true ∧
    F64.test .lt (.fin false 3 0) (ρ 0) = true ∧
    F64.test .eq (.fin false 248044 0) (ρ 1) = false ∧
    F64.test .eq (.fin false 248044 0) (ρ 2) = false := by
  simp only [Good,rankAnswers,P.O,List.take,List.forall_mem_cons,SymE.eval]
  constructor
  · rintro ⟨h1,t1,_,_,h2,t2,h3,_⟩
    exact ⟨h1,h2,h3,t1,t2⟩
  · rintro ⟨h1,h2,h3,t1,t2⟩
    exact ⟨h1,t1,h1,t1,h2,t2,h3,by intro q hq; cases hq⟩

/-- The base rank entry is reached from boot using only its consumed branch
answers. Its native literal metadata is then derived from that reached heap. -/
theorem source_rank_initialization (ρ : Nat → F64) (C : CSrv) (live : Nat → Prop)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ C', ((bootL Route.cx Decode.world 2000).bind fun start => runC Host.Load.ffi 32741797 start C) =
      some (input,C') ∧ C'.tab = P.micro3275.S1.tab.map (SymE.eval ρ) ∧
      NativeCaptureInventory (literalCaptures live input) ρ ρ C' C' identity live input input := by
  obtain ⟨C',run,tab⟩ := source_prefix_boot ρ C source_rank_prefix rank_answers table answers
  exact ⟨C',run,tab,NativeCaptureInventory.literal_seed_same input ρ ρ C' C' identity live (fun _ _ _ => rfl)⟩

theorem source_rank_initialization_guarded (ρ : Nat → F64) (C : CSrv) (live : Nat → Prop)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget1 : F64.test .lt (.fin false 1 0) (ρ 0) = true)
    (budget2 : F64.test .lt (.fin false 2 0) (ρ 0) = true)
    (budget3 : F64.test .lt (.fin false 3 0) (ρ 0) = true)
    (token1 : F64.test .eq (.fin false 248044 0) (ρ 1) = false)
    (token2 : F64.test .eq (.fin false 248044 0) (ρ 2) = false) :
    ∃ C', ((bootL Route.cx Decode.world 2000).bind fun start => runC Host.Load.ffi 32741797 start C) =
      some (input,C') ∧ C'.tab = P.micro3275.S1.tab.map (SymE.eval ρ) ∧
      NativeCaptureInventory (literalCaptures live input) ρ ρ C' C' identity live input input :=
  source_rank_initialization ρ C live table ((rank_answers_iff ρ).2 ⟨budget1,budget2,budget3,token1,token2⟩)

end Host.Load.Run.Full.Ordinary.RankOrigin
