import host.simgraph.prompt.ChooseFamily
import host.simgraph.ref.Steps
namespace Host.Mlx.SimGraph.ChooseFamilyTest
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.Ffi (Dim Prim Node)

/-! A forward piece checked with the family chooser: the SSM convolution of a V23 delta layer (the
reference's rows representation `refRows`: rows at position 1), nodes 35–42 of the family's expected graph —
the conv state (the cache stage's input), the concat with the qkv projection (a boundary carrier, node 15),
the new conv tail, the conv1d and the compiled `nn.silu` (a closure). The piece's synthetic end state holds
the old nodes below 4 (the qkv output, the conv state, the conv weight) and the piece's from 4, its row
dimensions symbolic numbers `n` (entry 0) and `n + 3` (entry 1) of the run's table, classified by `clsOfP`
over the box `2 ≤ n ≤ 223`; the closure's replay is closure object 9. -/

def lin (bits rows cols : Nat) : LinLayout := ⟨.plain, bits, rows, cols⟩

/-- A delta layer's layout with both SSM caches present. -/
def dl : DeltaLayout :=
  ⟨lin 4 10240 5120, lin 4 6144 5120, lin 4 48 5120, lin 4 48 5120, lin 4 5120 6144, ⟨4, 4, 4⟩, true, true⟩

/-- The V23 family's expected graph of one delta layer (symbolic dimensions). -/
def E : List (RNode PDim PKey) := (familyGraph (v23 Ref.refRows).ops id 0 2 [.delta dl]).1

def table : SSrv := ⟨[.var 1, .bin .add (.var 1) (.lit (F64.ofNat 3))], []⟩

/-- `2 ≤ n ≤ 223`. -/
def box : Box := [(1, 2, 223)]

def n : Dim := .sym (.ref 0)
def n3 : Dim := .sym (.ref 1)

def state : Ffi.St :=
  let s := Ffi.init [] [] [] []
  let s := (s.addNode ⟨.load ['f'] ['q'], [], [.lit 1, n, .lit 10240], 12⟩).2
  let s := (s.addNode ⟨.load ['f'] ['c'], [], [.lit 1, .lit 3, .lit 10240], 12⟩).2
  let s := (s.addNode ⟨.load ['f'] ['w'], [], [.lit 10240, .lit 4, .lit 1], 12⟩).2
  let s := (s.addNode ⟨.concat 1, [2, 1], [.lit 1, n3, .lit 10240], 12⟩).2
  let s := (s.addNode ⟨.slice [.lit 0, n, .lit 0] [.lit 1, n3, .lit 10240] [.lit 1, .lit 1, .lit 1], [4],
    [.lit 1, .lit 3, .lit 10240], 12⟩).2
  let s := (s.addNode ⟨.data [.lit 0, .lit 0, .lit 0, .lit 0], [], [], 7⟩).2
  let s := (s.addNode ⟨.sliceDynamic [0] [.lit 1, .lit 3, .lit 10240], [5, 6], [.lit 1, .lit 3, .lit 10240], 12⟩).2
  let s := (s.addNode ⟨.conv1d 1 0 1 10240, [4, 3], [.lit 1, n, .lit 10240], 12⟩).2
  let s := (s.addNode ⟨.replayed 9 (.unary chars!"sigmoid"), [8], [.lit 1, n, .lit 10240], 12⟩).2
  let s := (s.addNode ⟨.replayed 9 (.binary chars!"multiply"), [8, 9], [.lit 1, n, .lit 10240], 12⟩).2
  let s := (s.addNode ⟨.slice [.lit 0, .lit 0, .lit 0] [.lit 1, n, .lit 2048] [.lit 1, .lit 1, .lit 1], [10], [], 12⟩).2
  let s := (s.addNode ⟨.slice [.lit 0, .lit 0, .lit 2048] [.lit 1, n, .lit 4096] [.lit 1, .lit 1, .lit 1], [10], [], 12⟩).2
  let s := (s.addNode ⟨.slice [.lit 0, .lit 0, .lit 4096] [.lit 1, n, .lit 10240] [.lit 1, .lit 1, .lit 1], [10], [], 12⟩).2
  let s := (s.addNode ⟨.reshape [.lit 1, n, .lit 16, .lit 128], [11], [], 12⟩).2
  let s := (s.addNode ⟨.reshape [.lit 1, n, .lit 16, .lit 128], [12], [], 12⟩).2
  (s.addNode ⟨.reshape [.lit 1, n, .lit 48, .lit 128], [13], [], 12⟩).2

def sources : KernelSources := ⟨fun _ => [], fun _ => []⟩

/-- The piece's domain: old nodes below 4, its own from 4. -/
def NL : Nat := 4
def N0 : Nat := 4

/-- The input carriers: the conv state and the conv weight of stage 0. -/
def ins : PKey → Option Nat
  | .base (.stage 0 (.cache 0)) => some 2
  | .base (.stage 0 .conv) => some 3
  | _ => none

/-- The boundary carrier: the qkv projection's output (expected node 15). -/
def bnd (j : Nat) : Option Nat := if j = 15 then some 1 else none

simgraph_choose_family_at piece : state, table, box, NL, N0, [], E, ins, 35, 43, bnd

def Gs : Nat → Option (RNode PDim PKey) :=
  restrictTo (tplDom NL N0 [] state) (symGraphD (clsOfP table box) PDim.lit sources state)

simgraph_check_segment check : Gs, kindFn piece.kind, E, .promptIds, 35, 43, piece.cert, ins choosing E

/-- **The piece's certificate**: nodes 35–42 of the family's graph are carried at the chosen carriers, the
closure by its replayed body (closure object 9 compiles `nn.silu`). -/
theorem piece_matches : MatchesSeg .promptIds (kindFn piece.kind) Gs E piece.cert 35 43 = true := check.matches

theorem piece_kind : kindFn piece.kind 9 = some .silu := by decide

/-- One check covers every row count: the piece's graph at `ν` carries the family's segment at `ν`. -/
theorem piece_every (ν : Nat → Int) :
    MatchesSeg .promptIds (kindFn piece.kind) (mapG (PDim.eval ν) Gs) (E.map (mapN (PDim.eval ν))) piece.cert 35 43 = true :=
  matchesSeg_map (PDim.eval ν) _ _ Gs E piece.cert 35 43 check.matches

/-- A wrong boundary carrier is rejected (the concat reads node 1 there, not 2). -/
theorem rejects_wrong_boundary :
    MatchesSeg .promptIds (kindFn piece.kind) Gs E (piece.cert.set 15 2) 35 43 = false := by decide +kernel

/-! The next piece, nodes 43–48 (the q, k, v slices of the convolution and their head reshapes), chosen and checked
on its own with the first piece's carrier of node 42 as its boundary; the two compose. -/

def bnd2 (j : Nat) : Option Nat := if j = 42 then some 10 else none

simgraph_choose_family_at piece2 : state, table, box, NL, N0, [], E, ins, 43, 49, bnd2

simgraph_check_segment check2 : Gs, kindFn piece.kind, E, .promptIds, 43, 49, piece2.cert, ins choosing E

/-- The second piece reads the first's carriers at its boundary. -/
theorem boundary : ∀ k (hk : k < E.length), 43 ≤ k → k < 49 → ∀ j ∈ E[k].ins, j < 43 →
    certAt piece2.cert j = certAt piece.cert j :=
  boundary_of_ok E piece.cert piece2.cert 43 49 (by decide +kernel)

/-- **The two pieces compose**: the merged certificate carries nodes 35–48. -/
theorem pieces_compose :
    MatchesSeg .promptIds (kindFn piece.kind) Gs E (mergeCert piece.cert piece2.cert 43 E.length) 35 49 = true := by
  have h1 := check.matches
  have h2 := check2.matches
  exact matchesSeg_split _ _ _ _ _ _ 35 43 49 h1 h2 boundary

end Host.Mlx.SimGraph.ChooseFamilyTest
