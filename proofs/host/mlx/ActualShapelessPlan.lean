import host.mlx.ActualCachedKernel
import host.mlx.LiteralReplay
import host.mlx.ActualShapelessFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Shapeless
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def source : Host.Mlx.Ffi.St := firstChoice.graph
def trace : Trace := ⟨[15262,15263,15264],[15272],[15265,15266,15267,15268,15269,15270,15271,15272]⟩
def inputs : List Nat := [1318,15245,1319]
def m0 : List (Nat × Nat) := trace.ins.zip inputs
def s0 : Host.Mlx.Ffi.St := source
def N0 (i : Nat) : Prop := i ∈ [1318,15245,1319,15262,15263,15264,15265,15266,15267,15268,15269,15270,15271,15272]
def boundary (i : Nat) : Prop := i ∉ trace.order

def d1 : Node := (s0.nodes.get 15265).getD ⟨.zeros,[],[],0⟩
def s1 : Host.Mlx.Ffi.St := (s0.addNode ⟨.replayed 18194 d1.prim,d1.ins.map (substOf m0),(([48] : List Int).map Dim.lit),10⟩).2
def m1 : List (Nat × Nat) := (15265,s0.nnext)::m0
def N1 (i : Nat) : Prop := i = s0.nnext ∨ N0 i

def d2 : Node := (s1.nodes.get 15266).getD ⟨.zeros,[],[],0⟩
def s2 : Host.Mlx.Ffi.St := (s1.addNode ⟨.replayed 18194 d2.prim,d2.ins.map (substOf m1),(([48] : List Int).map Dim.lit),10⟩).2
def m2 : List (Nat × Nat) := (15266,s1.nnext)::m1
def N2 (i : Nat) : Prop := i = s1.nnext ∨ N1 i

def d3 : Node := (s2.nodes.get 15267).getD ⟨.zeros,[],[],0⟩
def s3 : Host.Mlx.Ffi.St := (s2.addNode ⟨.replayed 18194 d3.prim,d3.ins.map (substOf m2),(([48] : List Int).map Dim.lit),10⟩).2
def m3 : List (Nat × Nat) := (15267,s2.nnext)::m2
def N3 (i : Nat) : Prop := i = s2.nnext ∨ N2 i

def d4 : Node := (s3.nodes.get 15268).getD ⟨.zeros,[],[],0⟩
def s4 : Host.Mlx.Ffi.St := (s3.addNode ⟨.replayed 18194 d4.prim,d4.ins.map (substOf m3),(([1,1,48] : List Int).map Dim.lit),12⟩).2
def m4 : List (Nat × Nat) := (15268,s3.nnext)::m3
def N4 (i : Nat) : Prop := i = s3.nnext ∨ N3 i

def d5 : Node := (s4.nodes.get 15269).getD ⟨.zeros,[],[],0⟩
def s5 : Host.Mlx.Ffi.St := s4
def m5 : List (Nat × Nat) := m4
def N5 : Nat → Prop := N4

def d6 : Node := (s5.nodes.get 15270).getD ⟨.zeros,[],[],0⟩
def s6 : Host.Mlx.Ffi.St := (s5.addNode ⟨.replayed 18194 d6.prim,d6.ins.map (substOf m5),(([1,1,48] : List Int).map Dim.lit),12⟩).2
def m6 : List (Nat × Nat) := (15270,s5.nnext)::m5
def N6 (i : Nat) : Prop := i = s5.nnext ∨ N5 i

def d7 : Node := (s6.nodes.get 15271).getD ⟨.zeros,[],[],0⟩
def s7 : Host.Mlx.Ffi.St := (s6.addNode ⟨.replayed 18194 d7.prim,d7.ins.map (substOf m6),(([1,1,48] : List Int).map Dim.lit),10⟩).2
def m7 : List (Nat × Nat) := (15271,s6.nnext)::m6
def N7 (i : Nat) : Prop := i = s6.nnext ∨ N6 i

def d8 : Node := (s7.nodes.get 15272).getD ⟨.zeros,[],[],0⟩
def s8 : Host.Mlx.Ffi.St := (s7.addNode ⟨.replayed 18194 d8.prim,d8.ins.map (substOf m7),(([1,1,48] : List Int).map Dim.lit),10⟩).2
def m8 : List (Nat × Nat) := (15272,s7.nnext)::m7
def N8 (i : Nat) : Prop := i = s7.nnext ∨ N7 i

def roles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  match i with
  | 1318 => ⟨closedShape [48],12,none⟩
  | 1319 => ⟨closedShape [48],12,none⟩
  | 15262 => ⟨closedShape [48],12,none⟩
  | 15264 => ⟨closedShape [48],12,none⟩
  | 15245 => ⟨closedShape [1,1,48],12,none⟩
  | 15263 => ⟨closedShape [1,1,48],12,none⟩
  | 15265 => ⟨closedShape [48],10,some (.astype 10,[15262])⟩
  | 17777 => ⟨closedShape [48],10,some (.replayed 18194 (.astype 10),[1318])⟩
  | 15266 => ⟨closedShape [48],10,some (.unary chars!"exp",[15265])⟩
  | 17778 => ⟨closedShape [48],10,some (.replayed 18194 (.unary chars!"exp"),[17777])⟩
  | 15267 => ⟨closedShape [48],10,some (.unary chars!"negative",[15266])⟩
  | 17779 => ⟨closedShape [48],10,some (.replayed 18194 (.unary chars!"negative"),[17778])⟩
  | 15268 => ⟨closedShape [1,1,48],12,some (.binary chars!"add",[15263,15264])⟩
  | 17780 => ⟨closedShape [1,1,48],12,some (.replayed 18194 (.binary chars!"add"),[15245,1319])⟩
  | 15269 => { base 15269 with shape := [], dtype := 12 }
  | 15270 => ⟨closedShape [1,1,48],12,some (.binary chars!"logaddexp",[15268,15269])⟩
  | 17781 => ⟨closedShape [1,1,48],12,some (.replayed 18194 (.binary chars!"logaddexp"),[17780,15269])⟩
  | 15271 => ⟨closedShape [1,1,48],10,some (.binary chars!"multiply",[15267,15270])⟩
  | 17782 => ⟨closedShape [1,1,48],10,some (.replayed 18194 (.binary chars!"multiply"),[17779,17781])⟩
  | 15272 => ⟨closedShape [1,1,48],10,some (.unary chars!"exp",[15271])⟩
  | 17783 => ⟨closedShape [1,1,48],10,some (.replayed 18194 (.unary chars!"exp"),[17782])⟩
  | _ => base i

theorem plan7 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N7 s7 m7 [15272] N8 s8 m8 := by
  have hn : s7.nodes.get 15272 = some d8 := by rfl
  have live : N7 15272 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15272 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N7 d8.ins := by change listSupport N7 [15271]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N7 (d8.ins.map (substOf m7)) := by change listSupport N7 [17782]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s7.nnext) m7 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d8 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([1,1,48],10)]) (([1,1,48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.unary chars!"exp") (literalMetadata [([1,1,48],10)]) = _; exact infer_exp148)
  · intro H tail target h nd' metadata' hr _ read
    apply literal_node_transport h 15272 18194 d8 nd' m7 metadata' hr full
      (.unary chars!"exp") [15271] (by rfl) (by intro p hp; cases hp; rfl) sub
      (by change listSupport (· < s7.nnext) [15271]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys [([1,1,48],10)] [1,1,48] 10
      (by dsimp [listSupport]; decide +kernel) (by dsimp [listSupport]; decide +kernel)
      (by rfl) (by rfl) (by change infer (.unary chars!"exp") (literalMetadata [([1,1,48],10)]) = _; exact infer_exp148) (by rfl) read
  · exact .done _ _ _

theorem plan6 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N6 s6 m6 [15271,15272] N8 s8 m8 := by
  have hn : s6.nodes.get 15271 = some d7 := by rfl
  have live : N6 15271 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15271 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N6 d7.ins := by change listSupport N6 [15267,15270]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N6 (d7.ins.map (substOf m6)) := by change listSupport N6 [17779,17781]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s6.nnext) m6 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d7 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([48],10),([1,1,48],12)]) (([1,1,48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.binary chars!"multiply") (literalMetadata [([48],10),([1,1,48],12)]) = _; exact infer_multiply)
  · intro H tail target h nd' metadata' hr _ read
    apply literal_node_transport h 15271 18194 d7 nd' m6 metadata' hr full
      (.binary chars!"multiply") [15267,15270] (by rfl) (by intro p hp; cases hp; rfl) sub
      (by change listSupport (· < s6.nnext) [15267,15270]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys [([48],10),([1,1,48],12)] [1,1,48] 10
      (by dsimp [listSupport]; decide +kernel) (by dsimp [listSupport]; decide +kernel)
      (by rfl) (by rfl) (by change infer (.binary chars!"multiply") (literalMetadata [([48],10),([1,1,48],12)]) = _; exact infer_multiply) (by rfl) read
  · exact plan7 base

theorem plan5 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N5 s5 m5 [15270,15271,15272] N8 s8 m8 := by
  have hn : s5.nodes.get 15270 = some d6 := by rfl
  have live : N5 15270 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15270 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N5 d6.ins := by change listSupport N5 [15268,15269]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N5 (d6.ins.map (substOf m5)) := by change listSupport N5 [17780,15269]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s5.nnext) m5 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d6 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([1,1,48],12),([],12)]) (([1,1,48] : List Int).map Dim.lit) 12 (by rfl) (by change infer (.binary chars!"logaddexp") (literalMetadata [([1,1,48],12),([],12)]) = _; exact infer_logaddexp)
  · intro H tail target h nd' metadata' hr _ read
    apply literal_node_transport h 15270 18194 d6 nd' m5 metadata' hr full
      (.binary chars!"logaddexp") [15268,15269] (by rfl) (by intro p hp; cases hp; rfl) sub
      (by change listSupport (· < s5.nnext) [15268,15269]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys [([1,1,48],12),([],12)] [1,1,48] 12
      (by dsimp [listSupport]; decide +kernel) (by dsimp [listSupport]; decide +kernel)
      (by rfl) (by rfl) (by change infer (.binary chars!"logaddexp") (literalMetadata [([1,1,48],12),([],12)]) = _; exact infer_logaddexp) (by rfl) read
  · exact plan6 base

theorem plan4 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N4 s4 m4 [15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s4.nodes.get 15269 = some d5 := by rfl
  have live : N4 15269 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15269 := by dsimp [boundary,trace]; decide +kernel
  apply ReplayPlan.leaf d5 live full hn (by rfl)
  exact plan5 base

theorem plan3 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N3 s3 m3 [15268,15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s3.nodes.get 15268 = some d4 := by rfl
  have live : N3 15268 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15268 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N3 d4.ins := by change listSupport N3 [15263,15264]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N3 (d4.ins.map (substOf m3)) := by change listSupport N3 [15245,1319]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s3.nnext) m3 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d4 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([1,1,48],12),([48],12)]) (([1,1,48] : List Int).map Dim.lit) 12 (by rfl) (by change infer (.binary chars!"add") (literalMetadata [([1,1,48],12),([48],12)]) = _; exact infer_add)
  · intro H tail target h nd' metadata' hr _ read
    apply literal_node_transport h 15268 18194 d4 nd' m3 metadata' hr full
      (.binary chars!"add") [15263,15264] (by rfl) (by intro p hp; cases hp; rfl) sub
      (by change listSupport (· < s3.nnext) [15263,15264]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys [([1,1,48],12),([48],12)] [1,1,48] 12
      (by dsimp [listSupport]; decide +kernel) (by dsimp [listSupport]; decide +kernel)
      (by rfl) (by rfl) (by change infer (.binary chars!"add") (literalMetadata [([1,1,48],12),([48],12)]) = _; exact infer_add) (by rfl) read
  · exact plan4 base

theorem plan2 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N2 s2 m2 [15267,15268,15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s2.nodes.get 15267 = some d3 := by rfl
  have live : N2 15267 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15267 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N2 d3.ins := by change listSupport N2 [15266]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N2 (d3.ins.map (substOf m2)) := by change listSupport N2 [17778]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s2.nnext) m2 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d3 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([48],10)]) (([48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.unary chars!"negative") (literalMetadata [([48],10)]) = _; exact infer_negative)
  · intro H tail target h nd' metadata' hr _ read
    apply literal_node_transport h 15267 18194 d3 nd' m2 metadata' hr full
      (.unary chars!"negative") [15266] (by rfl) (by intro p hp; cases hp; rfl) sub
      (by change listSupport (· < s2.nnext) [15266]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys [([48],10)] [48] 10
      (by dsimp [listSupport]; decide +kernel) (by dsimp [listSupport]; decide +kernel)
      (by rfl) (by rfl) (by change infer (.unary chars!"negative") (literalMetadata [([48],10)]) = _; exact infer_negative) (by rfl) read
  · exact plan3 base

theorem plan1 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N1 s1 m1 [15266,15267,15268,15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s1.nodes.get 15266 = some d2 := by rfl
  have live : N1 15266 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15266 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N1 d2.ins := by change listSupport N1 [15265]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N1 (d2.ins.map (substOf m1)) := by change listSupport N1 [17777]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s1.nnext) m1 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d2 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([48],10)]) (([48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.unary chars!"exp") (literalMetadata [([48],10)]) = _; exact infer_exp48)
  · intro H tail target h nd' metadata' hr _ read
    apply literal_node_transport h 15266 18194 d2 nd' m1 metadata' hr full
      (.unary chars!"exp") [15265] (by rfl) (by intro p hp; cases hp; rfl) sub
      (by change listSupport (· < s1.nnext) [15265]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys [([48],10)] [48] 10
      (by dsimp [listSupport]; decide +kernel) (by dsimp [listSupport]; decide +kernel)
      (by rfl) (by rfl) (by change infer (.unary chars!"exp") (literalMetadata [([48],10)]) = _; exact infer_exp48) (by rfl) read
  · exact plan2 base

theorem plan0 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N0 s0 m0 [15265,15266,15267,15268,15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s0.nodes.get 15265 = some d1 := by rfl
  have live : N0 15265 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15265 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N0 d1.ins := by change listSupport N0 [15262]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N0 (d1.ins.map (substOf m0)) := by change listSupport N0 [1318]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s0.nnext) m0 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d1 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([48],12)]) (([48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.astype 10) (literalMetadata [([48],12)]) = _; exact infer_astype)
  · intro H tail target h nd' metadata' hr _ read
    apply literal_node_transport h 15265 18194 d1 nd' m0 metadata' hr full
      (.astype 10) [15262] (by rfl) (by intro p hp; cases hp; rfl) sub
      (by change listSupport (· < s0.nnext) [15262]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys [([48],12)] [48] 10
      (by dsimp [listSupport]; decide +kernel) (by dsimp [listSupport]; decide +kernel)
      (by rfl) (by rfl) (by change infer (.astype 10) (literalMetadata [([48],12)]) = _; exact infer_astype) (by rfl) read
  · exact plan1 base

end Host.Load.Run.Full.Shapeless
