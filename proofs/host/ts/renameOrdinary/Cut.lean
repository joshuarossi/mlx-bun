import host.ts.renameOrdinary.ReadEntry
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts

def offsetPlaces : List LoopPlace := [.data 2672298 (.str chars!"offset"),
  .data 2672303 (.str chars!"offset"),
  .data 2672308 (.str chars!"offset"),
  .data 2672320 (.str chars!"offset"),
  .data 2672329 (.str chars!"offset"),
  .data 2672334 (.str chars!"offset"),
  .data 2672339 (.str chars!"offset"),
  .data 2672351 (.str chars!"offset"),
  .data 2672360 (.str chars!"offset"),
  .data 2672365 (.str chars!"offset"),
  .data 2672370 (.str chars!"offset"),
  .data 2672382 (.str chars!"offset"),
  .data 2672391 (.str chars!"offset"),
  .data 2672396 (.str chars!"offset"),
  .data 2672401 (.str chars!"offset"),
  .data 2672413 (.str chars!"offset"),
  .data 2672422 (.str chars!"offset"),
  .data 2672427 (.str chars!"offset"),
  .data 2672432 (.str chars!"offset"),
  .data 2672444 (.str chars!"offset"),
  .data 2672453 (.str chars!"offset"),
  .data 2672458 (.str chars!"offset"),
  .data 2672463 (.str chars!"offset"),
  .data 2672475 (.str chars!"offset"),
  .data 2672484 (.str chars!"offset"),
  .data 2672489 (.str chars!"offset"),
  .data 2672494 (.str chars!"offset"),
  .data 2672506 (.str chars!"offset"),
  .data 2672515 (.str chars!"offset"),
  .data 2672520 (.str chars!"offset"),
  .data 2672525 (.str chars!"offset"),
  .data 2672537 (.str chars!"offset"),
  .data 2672546 (.str chars!"offset"),
  .data 2672551 (.str chars!"offset"),
  .data 2672556 (.str chars!"offset"),
  .data 2672568 (.str chars!"offset"),
  .data 2672577 (.str chars!"offset"),
  .data 2672582 (.str chars!"offset"),
  .data 2672587 (.str chars!"offset"),
  .data 2672599 (.str chars!"offset"),
  .data 2672608 (.str chars!"offset"),
  .data 2672613 (.str chars!"offset"),
  .data 2672618 (.str chars!"offset"),
  .data 2672630 (.str chars!"offset"),
  .data 2672639 (.str chars!"offset"),
  .data 2672644 (.str chars!"offset"),
  .data 2672649 (.str chars!"offset"),
  .data 2672661 (.str chars!"offset"),
  .data 2672670 (.str chars!"offset"),
  .data 2672675 (.str chars!"offset"),
  .data 2672680 (.str chars!"offset"),
  .data 2672692 (.str chars!"offset"),
  .data 2672701 (.str chars!"offset"),
  .data 2672706 (.str chars!"offset"),
  .data 2672711 (.str chars!"offset"),
  .data 2672723 (.str chars!"offset"),
  .data 2672732 (.str chars!"offset"),
  .data 2672737 (.str chars!"offset"),
  .data 2672742 (.str chars!"offset"),
  .data 2672754 (.str chars!"offset"),
  .data 2672763 (.str chars!"offset"),
  .data 2672768 (.str chars!"offset"),
  .data 2672773 (.str chars!"offset"),
  .data 2672785 (.str chars!"offset")]
def kvPlaces : List LoopPlace := [.privField 2983599 4852 chars!"handle",
  .privField 2983651 4852 chars!"handle",
  .privField 2992573 4852 chars!"handle",
  .privField 2992625 4852 chars!"handle",
  .privField 3001947 4852 chars!"handle",
  .privField 3001999 4852 chars!"handle",
  .privField 3011329 4852 chars!"handle",
  .privField 3011381 4852 chars!"handle",
  .privField 3020719 4852 chars!"handle",
  .privField 3020771 4852 chars!"handle",
  .privField 3030093 4852 chars!"handle",
  .privField 3030145 4852 chars!"handle",
  .privField 3039367 4852 chars!"handle",
  .privField 3039419 4852 chars!"handle",
  .privField 3048745 4852 chars!"handle",
  .privField 3048797 4852 chars!"handle",
  .privField 3058131 4852 chars!"handle",
  .privField 3058183 4852 chars!"handle",
  .privField 3067505 4852 chars!"handle",
  .privField 3067557 4852 chars!"handle",
  .privField 3076879 4852 chars!"handle",
  .privField 3076931 4852 chars!"handle",
  .privField 3086261 4852 chars!"handle",
  .privField 3086313 4852 chars!"handle",
  .privField 3095647 4852 chars!"handle",
  .privField 3095699 4852 chars!"handle",
  .privField 3104625 4852 chars!"handle",
  .privField 3104677 4852 chars!"handle",
  .privField 3113315 4852 chars!"handle",
  .privField 3113367 4852 chars!"handle",
  .privField 3122001 4852 chars!"handle",
  .privField 3122053 4852 chars!"handle"]
noncomputable def nativeNodeAt (h : Nat) : Host.Mlx.Ffi.Node :=
  (P.s3272.ffi.mlx.node? h).getD ⟨.zeros,[],[],0⟩

theorem actual_all_offsets : ∀ p ∈ offsetPlaces, p.read P.s3272 = some (natV 3) := by
  intro p hp
  simp only [offsetPlaces,List.mem_cons,List.not_mem_nil,or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals rfl

theorem actual_all_kv : ∀ p ∈ kvPlaces, ∃ h node,
    p.read P.s3272 = some (.big (Int.ofNat h)) ∧ P.s3272.ffi.mlx.node? h = some node ∧
      node.shape = Host.Mlx.Ffi.lits [1,4,256,256] ∧ node.dtype = 12 := by
  intro p hp
  simp only [kvPlaces,List.mem_cons,List.not_mem_nil,or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact ⟨25850,nativeNodeAt 25850,rfl,rfl,rfl,rfl⟩
  · exact ⟨25851,nativeNodeAt 25851,rfl,rfl,rfl,rfl⟩
  · exact ⟨26070,nativeNodeAt 26070,rfl,rfl,rfl,rfl⟩
  · exact ⟨26071,nativeNodeAt 26071,rfl,rfl,rfl,rfl⟩
  · exact ⟨26302,nativeNodeAt 26302,rfl,rfl,rfl,rfl⟩
  · exact ⟨26303,nativeNodeAt 26303,rfl,rfl,rfl,rfl⟩
  · exact ⟨26534,nativeNodeAt 26534,rfl,rfl,rfl,rfl⟩
  · exact ⟨26535,nativeNodeAt 26535,rfl,rfl,rfl,rfl⟩
  · exact ⟨26766,nativeNodeAt 26766,rfl,rfl,rfl,rfl⟩
  · exact ⟨26767,nativeNodeAt 26767,rfl,rfl,rfl,rfl⟩
  · exact ⟨26998,nativeNodeAt 26998,rfl,rfl,rfl,rfl⟩
  · exact ⟨26999,nativeNodeAt 26999,rfl,rfl,rfl,rfl⟩
  · exact ⟨27227,nativeNodeAt 27227,rfl,rfl,rfl,rfl⟩
  · exact ⟨27228,nativeNodeAt 27228,rfl,rfl,rfl,rfl⟩
  · exact ⟨27459,nativeNodeAt 27459,rfl,rfl,rfl,rfl⟩
  · exact ⟨27460,nativeNodeAt 27460,rfl,rfl,rfl,rfl⟩
  · exact ⟨27691,nativeNodeAt 27691,rfl,rfl,rfl,rfl⟩
  · exact ⟨27692,nativeNodeAt 27692,rfl,rfl,rfl,rfl⟩
  · exact ⟨27923,nativeNodeAt 27923,rfl,rfl,rfl,rfl⟩
  · exact ⟨27924,nativeNodeAt 27924,rfl,rfl,rfl,rfl⟩
  · exact ⟨28155,nativeNodeAt 28155,rfl,rfl,rfl,rfl⟩
  · exact ⟨28156,nativeNodeAt 28156,rfl,rfl,rfl,rfl⟩
  · exact ⟨28387,nativeNodeAt 28387,rfl,rfl,rfl,rfl⟩
  · exact ⟨28388,nativeNodeAt 28388,rfl,rfl,rfl,rfl⟩
  · exact ⟨28619,nativeNodeAt 28619,rfl,rfl,rfl,rfl⟩
  · exact ⟨28620,nativeNodeAt 28620,rfl,rfl,rfl,rfl⟩
  · exact ⟨28839,nativeNodeAt 28839,rfl,rfl,rfl,rfl⟩
  · exact ⟨28840,nativeNodeAt 28840,rfl,rfl,rfl,rfl⟩
  · exact ⟨29050,nativeNodeAt 29050,rfl,rfl,rfl,rfl⟩
  · exact ⟨29051,nativeNodeAt 29051,rfl,rfl,rfl,rfl⟩
  · exact ⟨29261,nativeNodeAt 29261,rfl,rfl,rfl,rfl⟩
  · exact ⟨29262,nativeNodeAt 29262,rfl,rfl,rfl,rfl⟩

def places : LoopRolePlaces := {
  generated := .cell 2673316
  stepIndex := .cell 2975684
  maxTokens := .cell 2673291
  pending := .cell 2673319
  nextPending := .cell 2673320
  forwarded := 2673447
  emitted := 12502
  cacheOffsets := offsetPlaces
  kvHandles := kvPlaces
  cur := .cell 2975683
  yieldedEarly := .cell 2975686
  currentHandle := .privField 2975628 4852 chars!"handle"
}

def budgetValuation (limit : Nat) : CSrv := ⟨[F64.ofNat limit]⟩

/-- All observations of the generalized cut hold at the actual ordinary source
state. Varying its budget valuation is an observation statement; reachability
under a different budget additionally needs the checked prefix's oracle facts. -/
theorem actual_supported_cut (limit : Nat) (hlo : 3 ≤ limit) (hhi : limit ≤ 262143) :
    SupportedOrdinaryCut Host.Load.ffi (fun s => s.mlx) places (budgetValuation limit) P.s3272
      1 1 limit 256 [.num (.ref 1)] (.ref 2) remainingReads := by
  refine {
    ordinary := by decide
    lookahead := by omega
    promptPositive := by decide
    bounded := by omega
    capacityPositive := by decide
    capacityAligned := by decide
    fits := by decide
    capacityBounded := by decide
    generated := rfl
    stepIndex := rfl
    maximum := rfl
    forwardedArray := rfl
    emittedArray := rfl
    recordedPrefix := rfl
    forwardedLength := rfl
    emittedLength := rfl
    layerCount := rfl
    offsets := ?_
    kvCount := rfl
    kvCarriers := actual_all_kv
    currentPending := ⟨2975628,rfl⟩
    nextPending := ⟨3123531,rfl⟩
    unread := rfl
    supported := by omega
    capacitySupported := by decide
    generatedLiteral := actual_generated
    stepIndexLiteral := actual_stepIndex
    offsetLiterals := actual_all_offsets
    early := rfl
    pendingObject := ⟨2975628,rfl,rfl⟩
    readEntry := ?_
  }
  · intro p hp
    change p.number (budgetValuation limit) P.s3272 = _
    rw [LoopPlace.number,actual_all_offsets p hp]
    rfl
  · exact ⟨4711,4415,3123575,0,25658,objectAt 4711,objectAt 4415,readBytes,.obj 4817,
      actual_read_control,rfl,rfl,rfl,rfl,rfl,rfl⟩

end Host.Load.Run.Full.Ordinary
