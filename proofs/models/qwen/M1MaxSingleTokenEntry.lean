import Mathlib.Data.Nat.Basic

namespace Inference.Models.Qwen.M1MaxSingleTokenEntry

-- Manual translation of the repository host route, guarded by the companion
-- SHA256/source-fragment checker. It is not a verified TypeScript interpreter,
-- checkpoint loader, native compiler, allocator or hardware-execution proof.
-- Domain: fresh serial text request, one prompt token, no prefix restoration,
-- paging, adapters, media, speculative execution or non-BF16 KV scheme.
def fingerprint : String := "cfa205c8f5af046a"
def chip : String := "applegpu_g13s"
def graph : String := "qwen3.8-27b-trellis-3.2bpw-m1max"

inductive KvOverride where
  | absent | off | affine | config
  deriving DecidableEq, Repr
inductive KvScheme where
  | bf16 | affine | turbo | other
  deriving DecidableEq, Repr
inductive CacheKind where
  | recurrent | kvCache | other
  deriving DecidableEq, Repr
inductive Phase where
  | decode | chunk | tail
  deriving DecidableEq, Repr
inductive Program where
  | one | rows | mma | wider
  deriving DecidableEq, Repr

-- factory.ts: GraphTable selection is constrained by fingerprint/device;
-- no explicit graph override is admitted by this entry contract.
def selectedGraph (artifact device : String) : Option String :=
  if artifact=fingerprint ∧ device=chip then some graph else none

-- kv-scheme.ts: turbo takes priority; absent/off resolve to BF16.
-- Config-driven schemes are outside this domain and abstracted as other.
def resolveKv (override : KvOverride) (turbo : Bool) : KvScheme :=
  if turbo then .turbo else match override with
  | .absent | .off => .bf16
  | .affine => .affine
  | .config => .other

-- cache-composition.ts: selected full layers with BF16 construct KVCache.
def cacheFor (scheme : KvScheme) (recurrent : Bool) : CacheKind :=
  if recurrent then .recurrent else if scheme=.bf16 then .kvCache else .other

structure EmptyKv where
  keysPresent : Bool
  valuesPresent : Bool
  offset : Nat
  deriving DecidableEq, Repr

def newKv : EmptyKv := ⟨false,false,0⟩

-- request-policy.ts: no paging leaves this freshly constructed cache intact.
def requestCache (paged : Bool) : Option EmptyKv := if paged then none else some newKv

-- portable/prefill.ts: no snapshot boundary; initial position is zero.
def firstEnd (length chunkSize : Nat) (tailSplit : Bool) : Nat :=
  if length > (if tailSplit then 1 else chunkSize) then
    if !tailSplit || decide (chunkSize≤length-1) then chunkSize else length-1
  else length

def prefillPhase (start finish : Nat) (whole : Bool) : Phase :=
  if finish-start=1 then .decode else if whole then .chunk else .tail

def firstPhase (length chunkSize : Nat) (tailSplit : Bool) : Phase :=
  prefillPhase 0 (firstEnd length chunkSize tailSplit) (decide (length=chunkSize))

-- MlxPhaseDispatch.prompt delegates decode phase to decode(sequences).
-- Static graph decode[1] is D1; D1 submits #one with phase="decode".
def decodeProgram (rows : Nat) : Program :=
  if rows=1 then .one else if rows≤3 then .rows else if rows=4 then .mma else .wider

def promptProgram (phase : Phase) (sequences tokens : Nat) : Program :=
  if phase=.decode then decodeProgram sequences else decodeProgram (sequences*tokens)

-- blocks.ts cacheRead→appendFor.decode→KVCache.appendDecode→updateAndFetch.
def directInitial (cache : EmptyKv) : Bool := !cache.keysPresent || !cache.valuesPresent

def compiledDecode : Bool := false

theorem selected : selectedGraph fingerprint chip=some graph := by simp [selectedGraph]

theorem default_bf16 : resolveKv .absent false=.bf16 := rfl

theorem explicit_bf16 : resolveKv .off false=.bf16 := rfl

theorem full_cache (override : KvOverride) (allowed : override=.absent ∨ override=.off) :
    cacheFor (resolveKv override false) false=.kvCache := by
  rcases allowed with rfl | rfl <;> rfl

theorem initial_cache : requestCache false=some ⟨false,false,0⟩ := rfl

theorem first_end (chunkSize : Nat) (positive : 0<chunkSize) (tailSplit : Bool) :
    firstEnd 1 chunkSize tailSplit=1 := by
  cases tailSplit <;> simp [firstEnd]
  omega

theorem first_decode (chunkSize : Nat) (positive : 0<chunkSize) (tailSplit : Bool) :
    firstPhase 1 chunkSize tailSplit=.decode := by
  unfold firstPhase
  rw [first_end chunkSize positive tailSplit]
  rfl

theorem first_one (chunkSize : Nat) (positive : 0<chunkSize) (tailSplit : Bool) :
    promptProgram (firstPhase 1 chunkSize tailSplit) 1 1=.one := by
  rw [first_decode chunkSize positive tailSplit]
  rfl

theorem first_direct : directInitial newKv=true := rfl

theorem no_compiled_entry : compiledDecode=false := rfl

-- Configuration-only conclusion: no execution/readback/correctness premise.
theorem route (override : KvOverride) (allowed : override=.absent ∨ override=.off)
    (chunkSize : Nat) (positive : 0<chunkSize) (tailSplit : Bool) :
    selectedGraph fingerprint chip=some graph ∧
    cacheFor (resolveKv override false) false=.kvCache ∧
    requestCache false=some ⟨false,false,0⟩ ∧
    firstPhase 1 chunkSize tailSplit=.decode ∧
    promptProgram (firstPhase 1 chunkSize tailSplit) 1 1=.one ∧
    directInitial newKv=true ∧ compiledDecode=false :=
  ⟨selected,full_cache override allowed,initial_cache,first_decode chunkSize positive tailSplit,
    first_one chunkSize positive tailSplit,first_direct,no_compiled_entry⟩

inductive AppendBranch where
  | initial | growth | reuse
  deriving DecidableEq, Repr

-- Exact control tests of KVCache.updateAndFetch; capacity is irrelevant
-- when both storage handles are initially null.
def appendBranch (cache : EmptyKv) (capacity length : Nat) : AppendBranch :=
  if !cache.keysPresent || decide (cache.offset+length>capacity) then
    if cache.keysPresent && cache.valuesPresent then .growth else .initial
  else .reuse

def zeroTokens (length : Nat) : Nat := ((256+length-1)/256)*256

def initialZeroShape : List Nat := [1,4,zeroTokens 1,256]

theorem initial_branch (capacity : Nat) : appendBranch newKv capacity 1=.initial := rfl

theorem initial_shape : initialZeroShape=[1,4,256,256] := rfl

theorem initial_words : initialZeroShape.prod=262144 := rfl

theorem initial_bytes : 2*initialZeroShape.prod=524288 := rfl

structure Request where
  artifact : String
  device : String
  override : KvOverride
  turbo : Bool
  paged : Bool
  suppliedCache : Bool
  explicitGraph : Bool
  customImplementation : Bool
  resumed : Bool
  media : Bool
  adapters : Bool
  speculative : Bool
  snapshot : Bool
  serial : Bool
  sequences : Nat
  promptTokens : Nat
  chunkSize : Nat
  tailSplit : Bool

-- These are input/configuration facts, not execution-result hypotheses.
structure Domain (request : Request) : Prop where
  artifact : request.artifact=fingerprint
  device : request.device=chip
  kv : request.override=.absent ∨ request.override=.off
  turbo : request.turbo=false
  paged : request.paged=false
  suppliedCache : request.suppliedCache=false
  explicitGraph : request.explicitGraph=false
  customImplementation : request.customImplementation=false
  resumed : request.resumed=false
  media : request.media=false
  adapters : request.adapters=false
  speculative : request.speculative=false
  snapshot : request.snapshot=false
  serial : request.serial=true
  sequences : request.sequences=1
  promptTokens : request.promptTokens=1
  chunkSize : 0<request.chunkSize

def usesMakeCache (request : Request) : Bool := !request.suppliedCache

def freshCache (request : Request) : Option EmptyKv :=
  if request.suppliedCache then none else requestCache request.paged

theorem request_route (request : Request) (domain : Domain request) :
    selectedGraph request.artifact request.device=some graph ∧
    cacheFor (resolveKv request.override request.turbo) false=.kvCache ∧
    usesMakeCache request=true ∧
    freshCache request=some ⟨false,false,0⟩ ∧
    firstPhase request.promptTokens request.chunkSize request.tailSplit=.decode ∧
    promptProgram (firstPhase request.promptTokens request.chunkSize request.tailSplit) request.sequences request.promptTokens=.one ∧
    directInitial newKv=true ∧ compiledDecode=false := by
  rw [domain.artifact,domain.device,domain.turbo,domain.promptTokens,domain.sequences]
  refine ⟨selected,full_cache request.override domain.kv,?_,?_,first_decode _ domain.chunkSize _,first_one _ domain.chunkSize _,first_direct,no_compiled_entry⟩
  · simp [usesMakeCache,domain.suppliedCache]
  · simp [freshCache,domain.suppliedCache,domain.paged,requestCache,newKv]

def selectionSource : String := r#"    loadedEntry({ id: QWEN38_TRELLIS_M1MAX_GRAPH, serves: {
      fingerprint:"cfa205c8f5af046a",device:"applegpu_g13s",
    }, create: (weights, config) => new Qwen38TrellisM1Max(weights, config),
      anePrograms: () => qwen38TrellisM1MaxAnePrograms() })"#

def kvDefaultSource : String := r#"  if (input.override === "off" || input.override === undefined)
    return new KvScheme("bf16", {});"#

def bf16CacheSource : String := r#"    case "bf16": return new KVCache(masks, turboQuantKernels, windowRead);"#

def bindCachesSource : String := r#"  return Object.assign(graph, { makeCache: () => composeGraphCaches(graph, composition),"#

def bindMakeCacheSource : String := r#"    makeCache: model.makeCache.bind(model),"#

def newKvSource : String := r#"  keys: MlxArray | null = null;
  values: MlxArray | null = null;
  offset = 0;"#

def phaseSource : String := r#"export function prefillPhase(start: number, end: number, whole: boolean): PrefillPhase {
  return end - start === 1 ? "decode" : whole ? "chunk" : "tail";
}"#

def promptDecodeSource : String := r#"    if (phase === "decode") return this.decode(sequences);"#

def d1Source : String := r#"    const D1:RowsForward=(ids,cache,capture)=>this.#submitted(one,ids,cache,"decode",capture);"#

def oneSource : String := r#"    const one=this.#one,rows=this.#rows;"#

def tableSource : String := r#"      1:D1,2:D23,3:D23,4:D4,5:D58,6:D58,7:D58,8:D58,9:DW,10:DW,11:DW,12:DW,13:DW,14:DW,15:DW,16:DW,"#

def readSource : String := r#"  decode: (cache, k, v) => (cache as CommittedAttentionCache).appendDecode(k, v),"#

def directSource : String := r#"      } else {
        this.keys = newK;
        this.values = newV;
      }"#

def uncompiledSource : String := r#"  readonly graphCapabilities:GraphDeclaration=declareGraph({media:{input:"embeddings+positions",video:true},hiddenLayerTaps:true,prefill:{boundedWorkspace:true}});"#

end Inference.Models.Qwen.M1MaxSingleTokenEntry
