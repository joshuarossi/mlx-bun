import host.mlx.OrdinaryShapelessStates
import host.mlx.NativeVariableInference
import host.mlx.ActualShapelessPlan
import host.mlx.NativeShapelessSignature

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

noncomputable section

namespace Host.Load.Run.Full.Ordinary.ShapelessCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated
open Host.Load.Run.Full.Shapeless

noncomputable def source : Host.Mlx.Ffi.St := P.RestStream.micro0.micro36.s86.ffi.mlx
abbrev trace := Shapeless.trace
def inputs : List Nat := [1330,22586,1331]
def m0 : List (Nat × Nat) := trace.ins.zip inputs
noncomputable def s0 : Host.Mlx.Ffi.St := source
def N0 (i : Nat) : Prop := i ∈ [1330,22586,1331,15262,15263,15264,15265,15266,15267,15268,15269,15270,15271,15272]
def boundary (i : Nat) : Prop := i ∉ trace.order

noncomputable def d1 : Node := (s0.nodes.get 15265).getD ⟨.zeros,[],[],0⟩
noncomputable def s1 : Host.Mlx.Ffi.St := (s0.addNode ⟨.replayed 18194 d1.prim,d1.ins.map (substOf m0),(([48] : List Int).map Dim.lit),10⟩).2
def m1 : List (Nat × Nat) := (15265,s0.nnext)::m0
def N1 (i : Nat) : Prop := i = s0.nnext ∨ N0 i

noncomputable def d2 : Node := (s1.nodes.get 15266).getD ⟨.zeros,[],[],0⟩
noncomputable def s2 : Host.Mlx.Ffi.St := (s1.addNode ⟨.replayed 18194 d2.prim,d2.ins.map (substOf m1),(([48] : List Int).map Dim.lit),10⟩).2
def m2 : List (Nat × Nat) := (15266,s1.nnext)::m1
def N2 (i : Nat) : Prop := i = s1.nnext ∨ N1 i

noncomputable def d3 : Node := (s2.nodes.get 15267).getD ⟨.zeros,[],[],0⟩
noncomputable def s3 : Host.Mlx.Ffi.St := (s2.addNode ⟨.replayed 18194 d3.prim,d3.ins.map (substOf m2),(([48] : List Int).map Dim.lit),10⟩).2
def m3 : List (Nat × Nat) := (15267,s2.nnext)::m2
def N3 (i : Nat) : Prop := i = s2.nnext ∨ N2 i

noncomputable def d4 : Node := (s3.nodes.get 15268).getD ⟨.zeros,[],[],0⟩
noncomputable def s4 : Host.Mlx.Ffi.St := (s3.addNode ⟨.replayed 18194 d4.prim,d4.ins.map (substOf m3),(([1,1,48] : List Int).map Dim.lit),12⟩).2
def m4 : List (Nat × Nat) := (15268,s3.nnext)::m3
def N4 (i : Nat) : Prop := i = s3.nnext ∨ N3 i

noncomputable def d5 : Node := (s4.nodes.get 15269).getD ⟨.zeros,[],[],0⟩
noncomputable def s5 : Host.Mlx.Ffi.St := s4
def m5 : List (Nat × Nat) := m4
def N5 : Nat → Prop := N4

noncomputable def d6 : Node := (s5.nodes.get 15270).getD ⟨.zeros,[],[],0⟩
noncomputable def s6 : Host.Mlx.Ffi.St := (s5.addNode ⟨.replayed 18194 d6.prim,d6.ins.map (substOf m5),(([1,1,48] : List Int).map Dim.lit),12⟩).2
def m6 : List (Nat × Nat) := (15270,s5.nnext)::m5
def N6 (i : Nat) : Prop := i = s5.nnext ∨ N5 i

noncomputable def d7 : Node := (s6.nodes.get 15271).getD ⟨.zeros,[],[],0⟩
noncomputable def s7 : Host.Mlx.Ffi.St := (s6.addNode ⟨.replayed 18194 d7.prim,d7.ins.map (substOf m6),(([1,1,48] : List Int).map Dim.lit),10⟩).2
def m7 : List (Nat × Nat) := (15271,s6.nnext)::m6
def N7 (i : Nat) : Prop := i = s6.nnext ∨ N6 i

noncomputable def d8 : Node := (s7.nodes.get 15272).getD ⟨.zeros,[],[],0⟩
noncomputable def s8 : Host.Mlx.Ffi.St := (s7.addNode ⟨.replayed 18194 d8.prim,d8.ins.map (substOf m7),(([1,1,48] : List Int).map Dim.lit),10⟩).2
def m8 : List (Nat × Nat) := (15272,s7.nnext)::m7
def N8 (i : Nat) : Prop := i = s7.nnext ∨ N7 i

def fixedRoles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  match i with
  | 1330 => ⟨closedShape [48],12,none⟩
  | 1331 => ⟨closedShape [48],12,none⟩
  | 15262 => ⟨closedShape [48],12,none⟩
  | 15264 => ⟨closedShape [48],12,none⟩
  | 22586 => ⟨closedShape [1,1,48],12,none⟩
  | 15263 => ⟨closedShape [1,1,48],12,none⟩
  | 15265 => ⟨closedShape [48],10,some (.astype 10,[15262])⟩
  | 22595 => ⟨closedShape [48],10,some (.replayed 18194 (.astype 10),[1330])⟩
  | 15266 => ⟨closedShape [48],10,some (.unary chars!"exp",[15265])⟩
  | 22596 => ⟨closedShape [48],10,some (.replayed 18194 (.unary chars!"exp"),[22595])⟩
  | 15267 => ⟨closedShape [48],10,some (.unary chars!"negative",[15266])⟩
  | 22597 => ⟨closedShape [48],10,some (.replayed 18194 (.unary chars!"negative"),[22596])⟩
  | 15268 => ⟨closedShape [1,1,48],12,some (.binary chars!"add",[15263,15264])⟩
  | 22598 => ⟨closedShape [1,1,48],12,some (.replayed 18194 (.binary chars!"add"),[22586,1331])⟩
  | 15269 => { base 15269 with shape := [], dtype := 12 }
  | 15270 => ⟨closedShape [1,1,48],12,some (.binary chars!"logaddexp",[15268,15269])⟩
  | 22599 => ⟨closedShape [1,1,48],12,some (.replayed 18194 (.binary chars!"logaddexp"),[22598,15269])⟩
  | 15271 => ⟨closedShape [1,1,48],10,some (.binary chars!"multiply",[15267,15270])⟩
  | 22600 => ⟨closedShape [1,1,48],10,some (.replayed 18194 (.binary chars!"multiply"),[22597,22599])⟩
  | 15272 => ⟨closedShape [1,1,48],10,some (.unary chars!"exp",[15271])⟩
  | 22601 => ⟨closedShape [1,1,48],10,some (.replayed 18194 (.unary chars!"exp"),[22600])⟩
  | _ => base i

def width : Shape := closedShape [48]
def tensor (leading : Shape) : Shape := leading ++ width

/-- Reuse the actual trace and every source replay state. Only the fixed
annotation of its batch-shaped tensors is generalized to a leading schema. -/
def roles (base : Nat → GraphNode) (leading : Shape) (i : Nat) : GraphNode :=
  match i with
  | 22586 | 15263 | 15268 | 15270 | 15271 | 15272 | 22598 | 22599 | 22600 | 22601 =>
    { fixedRoles base i with shape := tensor leading }
  | _ => fixedRoles base i

private theorem width_literal : width.Literal := ⟨⟨_,rfl⟩,True.intro⟩

private theorem castLaw : InferenceSchema (.astype 10) [(width,12)] (width,10) := by
  intro ν C R p metadata primitive inputs
  exact astype 10 primitive inputs

private theorem expLaw (shape : Shape) : InferenceSchema (.unary chars!"exp") [(shape,10)] (shape,10) := by
  intro ν C R p metadata primitive inputs
  simpa only [dtype_exp] using unary chars!"exp" primitive inputs

private theorem negativeLaw : InferenceSchema (.unary chars!"negative") [(width,10)] (width,10) := by
  intro ν C R p metadata primitive inputs
  simpa only [dtype_negative] using unary chars!"negative" primitive inputs

private theorem addLaw (leading : Shape) :
    InferenceSchema (.binary chars!"add") [(tensor leading,12),(width,12)] (tensor leading,12) := by
  intro ν C R p metadata primitive inputs
  simpa only [tensor,dtype_add] using binary_leading chars!"add" width_literal primitive inputs

private theorem scalarLaw (leading : Shape) :
    InferenceSchema (.binary chars!"logaddexp") [(tensor leading,12),([],12)] (tensor leading,12) := by
  intro ν C R p metadata primitive inputs
  simpa only [dtype_logaddexp] using binary_scalar chars!"logaddexp" primitive inputs

private theorem multiplyLaw (leading : Shape) :
    InferenceSchema (.binary chars!"multiply") [(width,10),(tensor leading,12)] (tensor leading,10) := by
  intro ν C R p metadata primitive inputs
  simpa only [tensor,dtype_multiply] using binary_suffix chars!"multiply" width_literal primitive inputs

theorem plan7 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      N7 s7 m7 [15272] N8 s8 m8 := by
  have hn : s7.nodes.get 15272 = some d8 := by rfl
  have live : N7 15272 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15272 := by dsimp [boundary,trace,Shapeless.trace]; decide +kernel
  have ins : listSupport N7 d8.ins := by change listSupport N7 [15271]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have sub : listSupport N7 (d8.ins.map (substOf m7)) := by change listSupport N7 [22600]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s7.nnext) m7 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d8 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([1,1,48],10)]) (([1,1,48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.unary chars!"exp") (literalMetadata [([1,1,48],10)]) = _; exact infer_exp148)
  · intro H tail target h nd' metadata' hr _ read
    apply variable_node_transport h 15272 18194 d8 nd' m7
      (literalMetadata [([1,1,48],10)]) metadata' (([1,1,48] : List Int).map Dim.lit) 10 hr full
      (.unary chars!"exp") [15271] [(tensor leading,10)] (tensor leading) (by rfl) (expLaw (tensor leading)) sub
      (by change listSupport (· < s7.nnext) [15271]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.unary chars!"exp") (literalMetadata [([1,1,48],10)]) = _; exact infer_exp148) (by rfl) read
  · exact .done _ _ _

theorem plan6 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      N6 s6 m6 [15271,15272] N8 s8 m8 := by
  have hn : s6.nodes.get 15271 = some d7 := by rfl
  have live : N6 15271 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15271 := by dsimp [boundary,trace,Shapeless.trace]; decide +kernel
  have ins : listSupport N6 d7.ins := by change listSupport N6 [15267,15270]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have sub : listSupport N6 (d7.ins.map (substOf m6)) := by change listSupport N6 [22597,22599]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s6.nnext) m6 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d7 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([48],10),([1,1,48],12)]) (([1,1,48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.binary chars!"multiply") (literalMetadata [([48],10),([1,1,48],12)]) = _; exact infer_multiply)
  · intro H tail target h nd' metadata' hr _ read
    apply variable_node_transport h 15271 18194 d7 nd' m6
      (literalMetadata [([48],10),([1,1,48],12)]) metadata' (([1,1,48] : List Int).map Dim.lit) 10 hr full
      (.binary chars!"multiply") [15267,15270] [(width,10),(tensor leading,12)] (tensor leading) (by rfl) (multiplyLaw leading) sub
      (by change listSupport (· < s6.nnext) [15267,15270]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.binary chars!"multiply") (literalMetadata [([48],10),([1,1,48],12)]) = _; exact infer_multiply) (by rfl) read
  · exact plan7 base leading

theorem plan5 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      N5 s5 m5 [15270,15271,15272] N8 s8 m8 := by
  have hn : s5.nodes.get 15270 = some d6 := by rfl
  have live : N5 15270 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15270 := by dsimp [boundary,trace,Shapeless.trace]; decide +kernel
  have ins : listSupport N5 d6.ins := by change listSupport N5 [15268,15269]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have sub : listSupport N5 (d6.ins.map (substOf m5)) := by change listSupport N5 [22598,15269]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s5.nnext) m5 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d6 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([1,1,48],12),([],12)]) (([1,1,48] : List Int).map Dim.lit) 12 (by rfl) (by change infer (.binary chars!"logaddexp") (literalMetadata [([1,1,48],12),([],12)]) = _; exact infer_logaddexp)
  · intro H tail target h nd' metadata' hr _ read
    apply variable_node_transport h 15270 18194 d6 nd' m5
      (literalMetadata [([1,1,48],12),([],12)]) metadata' (([1,1,48] : List Int).map Dim.lit) 12 hr full
      (.binary chars!"logaddexp") [15268,15269] [(tensor leading,12),([],12)] (tensor leading) (by rfl) (scalarLaw leading) sub
      (by change listSupport (· < s5.nnext) [15268,15269]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.binary chars!"logaddexp") (literalMetadata [([1,1,48],12),([],12)]) = _; exact infer_logaddexp) (by rfl) read
  · exact plan6 base leading

theorem plan4 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      N4 s4 m4 [15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s4.nodes.get 15269 = some d5 := by rfl
  have live : N4 15269 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15269 := by dsimp [boundary,trace,Shapeless.trace]; decide +kernel
  apply ReplayPlan.leaf d5 live full hn (by rfl)
  exact plan5 base leading

theorem plan3 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      N3 s3 m3 [15268,15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s3.nodes.get 15268 = some d4 := by rfl
  have live : N3 15268 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15268 := by dsimp [boundary,trace,Shapeless.trace]; decide +kernel
  have ins : listSupport N3 d4.ins := by change listSupport N3 [15263,15264]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have sub : listSupport N3 (d4.ins.map (substOf m3)) := by change listSupport N3 [22586,1331]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s3.nnext) m3 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d4 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([1,1,48],12),([48],12)]) (([1,1,48] : List Int).map Dim.lit) 12 (by rfl) (by change infer (.binary chars!"add") (literalMetadata [([1,1,48],12),([48],12)]) = _; exact infer_add)
  · intro H tail target h nd' metadata' hr _ read
    apply variable_node_transport h 15268 18194 d4 nd' m3
      (literalMetadata [([1,1,48],12),([48],12)]) metadata' (([1,1,48] : List Int).map Dim.lit) 12 hr full
      (.binary chars!"add") [15263,15264] [(tensor leading,12),(width,12)] (tensor leading) (by rfl) (addLaw leading) sub
      (by change listSupport (· < s3.nnext) [15263,15264]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.binary chars!"add") (literalMetadata [([1,1,48],12),([48],12)]) = _; exact infer_add) (by rfl) read
  · exact plan4 base leading

theorem plan2 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      N2 s2 m2 [15267,15268,15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s2.nodes.get 15267 = some d3 := by rfl
  have live : N2 15267 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15267 := by dsimp [boundary,trace,Shapeless.trace]; decide +kernel
  have ins : listSupport N2 d3.ins := by change listSupport N2 [15266]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have sub : listSupport N2 (d3.ins.map (substOf m2)) := by change listSupport N2 [22596]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s2.nnext) m2 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d3 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([48],10)]) (([48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.unary chars!"negative") (literalMetadata [([48],10)]) = _; exact infer_negative)
  · intro H tail target h nd' metadata' hr _ read
    apply variable_node_transport h 15267 18194 d3 nd' m2
      (literalMetadata [([48],10)]) metadata' (([48] : List Int).map Dim.lit) 10 hr full
      (.unary chars!"negative") [15266] [(width,10)] (width) (by rfl) (negativeLaw) sub
      (by change listSupport (· < s2.nnext) [15266]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.unary chars!"negative") (literalMetadata [([48],10)]) = _; exact infer_negative) (by rfl) read
  · exact plan3 base leading

theorem plan1 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      N1 s1 m1 [15266,15267,15268,15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s1.nodes.get 15266 = some d2 := by rfl
  have live : N1 15266 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15266 := by dsimp [boundary,trace,Shapeless.trace]; decide +kernel
  have ins : listSupport N1 d2.ins := by change listSupport N1 [15265]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have sub : listSupport N1 (d2.ins.map (substOf m1)) := by change listSupport N1 [22595]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s1.nnext) m1 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d2 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([48],10)]) (([48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.unary chars!"exp") (literalMetadata [([48],10)]) = _; exact infer_exp48)
  · intro H tail target h nd' metadata' hr _ read
    apply variable_node_transport h 15266 18194 d2 nd' m1
      (literalMetadata [([48],10)]) metadata' (([48] : List Int).map Dim.lit) 10 hr full
      (.unary chars!"exp") [15265] [(width,10)] (width) (by rfl) (expLaw width) sub
      (by change listSupport (· < s1.nnext) [15265]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.unary chars!"exp") (literalMetadata [([48],10)]) = _; exact infer_exp48) (by rfl) read
  · exact plan2 base leading

theorem plan0 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      N0 s0 m0 [15265,15266,15267,15268,15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s0.nodes.get 15265 = some d1 := by rfl
  have live : N0 15265 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15265 := by dsimp [boundary,trace,Shapeless.trace]; decide +kernel
  have ins : listSupport N0 d1.ins := by change listSupport N0 [15262]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have sub : listSupport N0 (d1.ins.map (substOf m0)) := by change listSupport N0 [1330]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s0.nnext) m0 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d1 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([48],12)]) (([48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.astype 10) (literalMetadata [([48],12)]) = _; exact infer_astype)
  · intro H tail target h nd' metadata' hr _ read
    apply variable_node_transport h 15265 18194 d1 nd' m0
      (literalMetadata [([48],12)]) metadata' (([48] : List Int).map Dim.lit) 10 hr full
      (.astype 10) [15262] [(width,12)] (width) (by rfl) (castLaw) sub
      (by change listSupport (· < s0.nnext) [15262]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,Shapeless.trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.astype 10) (literalMetadata [([48],12)]) = _; exact infer_astype) (by rfl) read
  · exact plan1 base leading


end Host.Load.Run.Full.Ordinary.ShapelessCall
