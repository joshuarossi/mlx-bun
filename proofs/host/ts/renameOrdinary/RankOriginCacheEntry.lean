import host.ts.renameOrdinary.RankOriginNativeSeed
import host.load.Extract
import host.ts.RenameAnnotatedLoop
import host.ts.RenamePublicInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi

structure Occurrence where
  stage : Nat
  cache : Nat
  field : Name
  wrapper : Nat
  handle : Nat
  producer : Nat
deriving DecidableEq

def cacheOwners : List Nat := [2672298,2672303,2672308,2672320,2672329,2672334,2672339,2672351,2672360,2672365,2672370,2672382,2672391,2672396,2672401,2672413,2672422,2672427,2672432,2672444,2672453,2672458,2672463,2672475,2672484,2672489,2672494,2672506,2672515,2672520,2672525,2672537,2672546,2672551,2672556,2672568,2672577,2672582,2672587,2672599,2672608,2672613,2672618,2672630,2672639,2672644,2672649,2672661,2672670,2672675,2672680,2672692,2672701,2672706,2672711,2672723,2672732,2672737,2672742,2672754,2672763,2672768,2672773,2672785]

def occurrences : List Occurrence := [
  ⟨3,2672320,chars!"keys",2983599,25850,20291⟩,
  ⟨3,2672320,chars!"values",2983651,25851,20292⟩,
  ⟨7,2672351,chars!"keys",2992573,26070,20439⟩,
  ⟨7,2672351,chars!"values",2992625,26071,20440⟩,
  ⟨11,2672382,chars!"keys",3001947,26302,20587⟩,
  ⟨11,2672382,chars!"values",3001999,26303,20588⟩,
  ⟨15,2672413,chars!"keys",3011329,26534,20735⟩,
  ⟨15,2672413,chars!"values",3011381,26535,20736⟩,
  ⟨19,2672444,chars!"keys",3020719,26766,20883⟩,
  ⟨19,2672444,chars!"values",3020771,26767,20884⟩,
  ⟨23,2672475,chars!"keys",3030093,26998,21031⟩,
  ⟨23,2672475,chars!"values",3030145,26999,21032⟩,
  ⟨27,2672506,chars!"keys",3039367,27227,21179⟩,
  ⟨27,2672506,chars!"values",3039419,27228,21180⟩,
  ⟨31,2672537,chars!"keys",3048745,27459,21327⟩,
  ⟨31,2672537,chars!"values",3048797,27460,21328⟩,
  ⟨35,2672568,chars!"keys",3058131,27691,21475⟩,
  ⟨35,2672568,chars!"values",3058183,27692,21476⟩,
  ⟨39,2672599,chars!"keys",3067505,27923,21623⟩,
  ⟨39,2672599,chars!"values",3067557,27924,21624⟩,
  ⟨43,2672630,chars!"keys",3076879,28155,21771⟩,
  ⟨43,2672630,chars!"values",3076931,28156,21772⟩,
  ⟨47,2672661,chars!"keys",3086261,28387,21919⟩,
  ⟨47,2672661,chars!"values",3086313,28388,21920⟩,
  ⟨51,2672692,chars!"keys",3095647,28619,22067⟩,
  ⟨51,2672692,chars!"values",3095699,28620,22068⟩,
  ⟨55,2672723,chars!"keys",3104625,28839,22215⟩,
  ⟨55,2672723,chars!"values",3104677,28840,22216⟩,
  ⟨59,2672754,chars!"keys",3113315,29050,22363⟩,
  ⟨59,2672754,chars!"values",3113367,29051,22364⟩,
  ⟨63,2672785,chars!"keys",3122001,29261,22511⟩,
  ⟨63,2672785,chars!"values",3122053,29262,22512⟩]

def producers : List Nat := occurrences.map Occurrence.producer
def offsetValue (owner : Nat) : Nat := if owner = 2672298 then 4 else 3
def offsetMeaning (timeMeaning : SymE) (owner : Nat) : SymE :=
  if owner = 2672298 then .bin .add timeMeaning (.lit (F64.ofNat 1)) else timeMeaning
noncomputable def nodeAt (producer : Nat) : Node :=
  (NativeSeed.native.nodes.get producer).getD ⟨.zeros,[],[],0⟩

structure Facts (entry : Occurrence) : Prop where
  cacheIndex : cacheOwners[entry.stage]? = some entry.cache
  field : Extract.own input (.obj entry.cache) entry.field = some (.obj entry.wrapper)
  handle : (LoopPlace.privField entry.wrapper 4852 chars!"handle").read input = some (.big (Int.ofNat entry.handle))
  producer : NativeSeed.native.arrs.get entry.handle = some entry.producer
  node : NativeSeed.native.nodes.get entry.producer = some (nodeAt entry.producer)
  shape : (nodeAt entry.producer).shape = [.lit 1,.lit 4,.lit 256,.lit 256]
  dtype : (nodeAt entry.producer).dtype = 12

theorem actual_cache_binding :
    ((bindingOf input (entryEnv P.s0) chars!"cache").bind (Extract.elements input)) =
      some (cacheOwners.map Val.obj) := by host_kernel_rfl

theorem cache_count : cacheOwners.length = 64 := by decide +kernel
theorem occurrence_count : occurrences.length = 32 := by decide +kernel
theorem producers_distinct : producers.Nodup := by decide +kernel
theorem producers_bounded : ∀ producer ∈ producers, producer < NativeSeed.native.nnext := by
  rw [NativeSeed.source_nnext]
  decide +kernel
theorem producers_not_hidden : 22582 ∉ producers := by decide +kernel

theorem actual_offsets : ∀ owner ∈ cacheOwners,
    (LoopPlace.data owner (.str chars!"offset")).read input = some (natV (offsetValue owner)) := by
  intro owner selected
  simp only [cacheOwners,List.mem_cons,List.not_mem_nil,or_false] at selected
  rcases selected with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals host_kernel_rfl

theorem first_offset_advanced :
    (LoopPlace.data 2672298 (.str chars!"offset")).read input = some (natV 4) := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Host.Ts.Owned.Parametric.Driver.emit "open Host.Ts in theorem wrong_uniform_offset : (LoopPlace.data 2672298 (.str chars!\"offset\")).read input = some (natV 3) := by host_kernel_rfl"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "the active SSM offset was incorrectly treated as an unadvanced cache"

theorem actual_facts : ∀ entry ∈ occurrences, Facts entry := by
  intro entry selected
  simp only [occurrences,List.mem_cons,List.not_mem_nil,or_false] at selected
  rcases selected with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals constructor
  all_goals host_kernel_rfl

theorem offsets_live : ∀ owner ∈ cacheOwners, owner < input.next := by
  rw [InitialClosure.source_address_limit]
  decide +kernel

theorem actual_all_producers : ∀ producer ∈ producers,
    ∃ node, NativeSeed.native.nodes.get producer = some node ∧
      node.shape = [.lit 1,.lit 4,.lit 256,.lit 256] ∧ node.dtype = 12 := by
  intro producer selected
  obtain ⟨entry,member,equal⟩ := List.mem_map.mp selected
  subst producer
  have facts := actual_facts entry member
  exact ⟨nodeAt entry.producer,facts.node,facts.shape,facts.dtype⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
