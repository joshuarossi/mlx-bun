import kernels.trellis.PackedArraySemantics
namespace Inference.Kernels.Trellis.PackedArrayPrograms
open PackedArraySyntax PackedArraySemantics
set_option maxRecDepth 10000
private def v := Expr.variable
private def s (n : Nat) := Expr.literal .signed n
private def u (n : Nat) := Expr.literal .unsigned n

def gateDeclare (primary virtual width : String) : Stmt :=
  .declare [(primary,[.add (v width) (s 1)]),(virtual,[.add (v width) (s 1)])]
def gateLoadAST (primary width global base first : String) : Stmt :=
  .forLoop "i" (s 0) false (.castUInt (v width))
    [.assign primary [v "i"] (.index global [.add (.add (v base) (v first)) (v "i")])]
def gateWrapAST (primary width global base first : String) : Stmt :=
  .assign primary [v width] (.index global [.add (v base)
    (.conditional (.equal (v "t0") (u 0)) (u 0) (.add (v first) (.castUInt (v width))))])
def virtualZeroAST (primary virtual : String) : Stmt :=
  .assign virtual [s 0] (.shiftLeft (.index primary [s 0]) (s 16))
def virtualLoopAST (primary virtual : String) (inclusive : Bool) (bound : Expr) : Stmt :=
  .forLoop "i" (s 1) inclusive bound [.assign virtual [v "i"]
    (.bitOr (.shiftRight (.index primary [.subtract (v "i") (s 1)]) (s 16))
      (.shiftLeft (.index primary [v "i"]) (s 16)))]

def gateSources : List String := [gateDeclaration,upDeclaration,gateLoad,gateWrap,upLoad,upWrap,
  gateVirtualZero,upVirtualZero,gateVirtual,upVirtual]
def gateProgram : List Stmt := [gateDeclare "g" "gv" "KG",gateDeclare "u" "uv" "KU",
  gateLoadAST "g" "KG" "gcodes" "gw" "gW0",gateWrapAST "g" "KG" "gcodes" "gw" "gW0",
  gateLoadAST "u" "KU" "ucodes" "uw" "uW0",gateWrapAST "u" "KU" "ucodes" "uw" "uW0",
  virtualZeroAST "g" "gv",virtualZeroAST "u" "uv",
  virtualLoopAST "g" "gv" true (.castUInt (v "KG")),virtualLoopAST "u" "uv" true (.castUInt (v "KU"))]

def downIndexAST : Stmt := .forLoop "i" (s 0) false (v "NL")
  [.assign "idx" [v "i"] (.modulo (.add (v "first") (v "i")) (v "WPB"))]
def downLoadAST (paired : Bool) : Stmt := .forLoop "i" (s 0) false (v "NL")
  [.assign "ld" (if paired then [v "u",v "i"] else [v "i"])
    (.index "rowWords" [.index "idx" [v "i"]])]
def downAlignAST (paired : Bool) : Stmt :=
  let element := fun index => Expr.index "ld" (if paired then [v "u",index] else [index])
  .forLoop "i" (s 0) false (v "NA") [.assign "w" [v "i"]
    (.conditional (v "shifted") (.bitOr (.shiftRight (element (v "i")) (v "SHIFT"))
      (.shiftLeft (element (.add (v "i") (s 1))) (.subtract (u 32) (v "SHIFT")))) (element (v "i")))]
def downIndexProgram : List Stmt := [.declare [("idx",[v "NL"])],downIndexAST]
def downPairLoadProgram : List Stmt := [.declare [("ld",[v "U",v "NL"])],downLoadAST true]
def downTailLoadProgram : List Stmt := [.declare [("ld",[v "NL"])],downLoadAST false]
def downAlignProgram (paired : Bool) : List Stmt := [.declare [("w",[v "NA"]),("v",[v "NA"])],
  downAlignAST paired,virtualZeroAST "w" "v",virtualLoopAST "w" "v" false (v "NA")]

def parsedFragments (sources : List String) : Option (List Stmt) := sources.mapM PackedArraySyntax.parse

theorem parsed_gate : parsedFragments gateSources=some gateProgram := by rfl
theorem parsed_down_index : parsedFragments [downIndexDeclaration,downIndex]=some downIndexProgram := by rfl
theorem parsed_down_pair_load : parsedFragments [downPairDeclaration,downPairLoad]=some downPairLoadProgram := by rfl
theorem parsed_down_tail_load : parsedFragments [downTailDeclaration,downTailLoad]=some downTailLoadProgram := by rfl
theorem parsed_down_pair_align : parsedFragments [downWordsDeclaration,downPairAlign,downVirtualZero,downVirtual]=some (downAlignProgram true) := by rfl
theorem parsed_down_tail_align : parsedFragments [downWordsDeclaration,downTailAlign,downVirtualZero,downVirtual]=some (downAlignProgram false) := by rfl

def sourceExecute (sources : List String) (before : State) : Option State := do
  execute 16 (←parsedFragments sources) before
theorem sourceExecute_parsed (sources : List String) (code : List Stmt)
    (parsed : parsedFragments sources=some code) (before : State) :
    sourceExecute sources before=execute 16 code before :=
  congrArg (fun actual : Option (List Stmt) => actual.bind (fun program => execute 16 program before)) parsed
end Inference.Kernels.Trellis.PackedArrayPrograms
