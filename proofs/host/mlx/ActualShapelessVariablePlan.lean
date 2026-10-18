import host.mlx.ActualShapelessCall
import host.mlx.NativeVariableInference
import host.mlx.NativeReplayPolicy
import host.mlx.NativeShapelessSignature

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Shapeless.Variable
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def width : Shape := closedShape [48]
def tensor (leading : Shape) : Shape := leading ++ width

/-- Reuse the actual trace and every source replay state. Only the fixed
annotation of its batch-shaped tensors is generalized to a leading schema. -/
def roles (base : Nat → GraphNode) (leading : Shape) (i : Nat) : GraphNode :=
  match i with
  | 15245 | 15263 | 15268 | 15270 | 15271 | 15272 | 17780 | 17781 | 17782 | 17783 =>
    { Shapeless.roles base i with shape := tensor leading }
  | _ => Shapeless.roles base i

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
  have live : N7 15272 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15272 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N7 d8.ins := by change listSupport N7 [15271]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N7 (d8.ins.map (substOf m7)) := by change listSupport N7 [17782]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s7.nnext) m7 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d8 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([1,1,48],10)]) (([1,1,48] : List Int).map Dim.lit) 10 (by rfl) (by change infer (.unary chars!"exp") (literalMetadata [([1,1,48],10)]) = _; exact infer_exp148)
  · intro H tail target h nd' metadata' hr _ read
    apply variable_node_transport h 15272 18194 d8 nd' m7
      (literalMetadata [([1,1,48],10)]) metadata' (([1,1,48] : List Int).map Dim.lit) 10 hr full
      (.unary chars!"exp") [15271] [(tensor leading,10)] (tensor leading) (by rfl) (expLaw (tensor leading)) sub
      (by change listSupport (· < s7.nnext) [15271]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.unary chars!"exp") (literalMetadata [([1,1,48],10)]) = _; exact infer_exp148) (by rfl) read
  · exact .done _ _ _

theorem plan6 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
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
    apply variable_node_transport h 15271 18194 d7 nd' m6
      (literalMetadata [([48],10),([1,1,48],12)]) metadata' (([1,1,48] : List Int).map Dim.lit) 10 hr full
      (.binary chars!"multiply") [15267,15270] [(width,10),(tensor leading,12)] (tensor leading) (by rfl) (multiplyLaw leading) sub
      (by change listSupport (· < s6.nnext) [15267,15270]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.binary chars!"multiply") (literalMetadata [([48],10),([1,1,48],12)]) = _; exact infer_multiply) (by rfl) read
  · exact plan7 base leading

theorem plan5 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
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
    apply variable_node_transport h 15270 18194 d6 nd' m5
      (literalMetadata [([1,1,48],12),([],12)]) metadata' (([1,1,48] : List Int).map Dim.lit) 12 hr full
      (.binary chars!"logaddexp") [15268,15269] [(tensor leading,12),([],12)] (tensor leading) (by rfl) (scalarLaw leading) sub
      (by change listSupport (· < s5.nnext) [15268,15269]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.binary chars!"logaddexp") (literalMetadata [([1,1,48],12),([],12)]) = _; exact infer_logaddexp) (by rfl) read
  · exact plan6 base leading

theorem plan4 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      N4 s4 m4 [15269,15270,15271,15272] N8 s8 m8 := by
  have hn : s4.nodes.get 15269 = some d5 := by rfl
  have live : N4 15269 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15269 := by dsimp [boundary,trace]; decide +kernel
  apply ReplayPlan.leaf d5 live full hn (by rfl)
  exact plan5 base leading

theorem plan3 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
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
    apply variable_node_transport h 15268 18194 d4 nd' m3
      (literalMetadata [([1,1,48],12),([48],12)]) metadata' (([1,1,48] : List Int).map Dim.lit) 12 hr full
      (.binary chars!"add") [15263,15264] [(tensor leading,12),(width,12)] (tensor leading) (by rfl) (addLaw leading) sub
      (by change listSupport (· < s3.nnext) [15263,15264]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.binary chars!"add") (literalMetadata [([1,1,48],12),([48],12)]) = _; exact infer_add) (by rfl) read
  · exact plan4 base leading

theorem plan2 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
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
    apply variable_node_transport h 15267 18194 d3 nd' m2
      (literalMetadata [([48],10)]) metadata' (([48] : List Int).map Dim.lit) 10 hr full
      (.unary chars!"negative") [15266] [(width,10)] (width) (by rfl) (negativeLaw) sub
      (by change listSupport (· < s2.nnext) [15266]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.unary chars!"negative") (literalMetadata [([48],10)]) = _; exact infer_negative) (by rfl) read
  · exact plan3 base leading

theorem plan1 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
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
    apply variable_node_transport h 15266 18194 d2 nd' m1
      (literalMetadata [([48],10)]) metadata' (([48] : List Int).map Dim.lit) 10 hr full
      (.unary chars!"exp") [15265] [(width,10)] (width) (by rfl) (expLaw width) sub
      (by change listSupport (· < s1.nnext) [15265]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.unary chars!"exp") (literalMetadata [([48],10)]) = _; exact infer_exp48) (by rfl) read
  · exact plan2 base leading

theorem plan0 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode) (leading : Shape) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 18194
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
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
    apply variable_node_transport h 15265 18194 d1 nd' m0
      (literalMetadata [([48],12)]) metadata' (([48] : List Int).map Dim.lit) 10 hr full
      (.astype 10) [15262] [(width,12)] (width) (by rfl) (castLaw) sub
      (by change listSupport (· < s0.nnext) [15262]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,N6,N7,N8,s0,s1,s2,s3,s4,s5,s6,s7,s8,m0,m1,m2,m3,m4,m5,m6,m7,m8,inputs,trace,source,St.addNode]; decide +kernel)
      keys (by rfl) (by rfl)
      (by change infer (.astype 10) (literalMetadata [([48],12)]) = _; exact infer_astype) (by rfl) read
  · exact plan1 base leading

/-- Replay the existing real shapeless graph with variable leading dimensions.
The reached closure/vector annotations determine both trace selection and all
seven fresh producer annotations. Source plans and target geometry are not
incoming premises. Native object/configuration/callback fields are framed. -/
theorem replay_from_current {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (base : Nat → GraphNode) (leading : Shape) (objects : Nat → Object)
    {roots H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N0 tail source target)
    (policy : ProducerAnnotations roots H N0 (roles base leading) objects)
    (closureLive : H 18194) (vectorLive : H 18195)
    (targetNodes : target.nnext + trace.order.length < 2^64) :
    ∃ payload' trace' final',
      target.obj? (R.handle 18194) = some (.clo (.compiled (R.region 281474976715599) payload' true [trace'])) ∧
      findTrace target true (inputs.map R.node) [trace'] = M.pure (some trace') ∧
      replay source 18194 trace inputs = M.pure (some (s8,[17783])) ∧
      replay target (R.handle 18194) trace' (inputs.map R.node) = M.pure (some (final',[17783].map R.node)) ∧
      Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
        (ObjectRel objects ν₀ ν C₀ C R) H N8 tail s8 final' ∧
      ProducerAnnotations roots H N8 (roles base leading) objects ∧
      ProducerSupport roots H N8 s8 ∧
      ProducerSupport (resourceImage R.node (fun i => N8 i ∧ roots i))
        (resourceImage R.handle H) (resourceImage R.node N8) final' := by
  have initial := policy.source h
  have traceSupport := initial.single_trace 18194 281474976715599 payload true trace closureLive source_closure
  have inputSupport := initial.vector 18195 inputs vectorLive source_vector
  have signature := policy.shapeless_signature h 18194 281474976715599 18195 payload trace inputs
    closureLive vectorLive source_closure source_vector metadata metadata source_trace_inputs source_real_inputs rfl
  have weak := h.mono (fun _ _ held => held) (fun _ _ _ held => held) (fun _ _ _ held => held.base)
  obtain ⟨payload',trace',closureRead,traceRelated⟩ := target_closure weak closureLive
  have selection := (h.findTrace_signature true trace trace' inputs traceRelated.ins traceSupport.inputs inputSupport
    signature metadata metadata source_trace_inputs source_real_inputs).2
  have keys : listSupport (fun p : Nat × Nat => p.1 < s8.nnext) m8 := by
    change listSupport (fun p : Nat × Nat => p.1 < 17784)
      [(15272,17783),(15271,17782),(15270,17781),(15268,17780),(15267,17779),(15266,17778),(15265,17777),(15262,1318),(15263,15245),(15264,1319)]
    dsimp [listSupport]; decide +kernel
  have outputs : listSupport (· < s8.nnext) trace.outs := by change 15272 < 17784 ∧ True; decide +kernel
  have sourceNodes : source.nnext + trace.order.length < 2^64 := by change 17777+8 < 2^64; decide +kernel
  obtain ⟨final',left,right,post,_,_⟩ := (plan0 base leading).replay_objects
    (fun _ _ _ held => held.base) (fun _ _ _ held => held.base) h traceRelated keys outputs sourceNodes targetNodes
  have sourceRoles : ∀ i node, N8 i → s8.nodes.get i = some node →
      ((roles base leading) i).Holds ν₀ C₀ Owned.Annotated.identity node := by
    intro i node selected read
    obtain ⟨_,_,related⟩ := post.node_view selected read
    exact related.source
  have updated := policy.replay (plan0 (ν₀ := ν₀) (ν := ν) (C₀ := C₀) (C := C) (R := R) base leading) (zip_support_right trace.ins inputs inputSupport) sourceNodes sourceRoles
  have outputNodes : trace.outs.map (substOf m8) = [17783] := by rfl
  rw [outputNodes] at left right
  exact ⟨payload',trace',final',closureRead,selection,left,right,post,updated,updated.source post,updated.target post⟩

end Host.Load.Run.Full.Shapeless.Variable
