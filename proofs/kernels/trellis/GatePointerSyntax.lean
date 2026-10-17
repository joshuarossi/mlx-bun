import kernels.trellis.PackedArraySyntax
namespace Inference.Kernels.Trellis.GatePointerSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
set_option maxRecDepth 10000

-- Each declaration retains every target and expression, including casts,
-- mixed signed/unsigned operands and left-associative subtraction/division.
abbrev Declaration := List (String × PackedArraySyntax.Expr)

def bindings : Nat → Parser Declaration
  | 0,_ => none
  | fuel+1,ts => do
    let (name,ts) ←nameToken ts
    let ts ←accept "=" ts
    let (value,ts) ←PackedArraySyntax.expression 32 0 ts
    match ts with
    | ","::ts => do
      let (rest,ts) ←bindings fuel ts
      pure ((name,value)::rest,ts)
    | ";"::ts => pure ([(name,value)],ts)
    | _ => none

def declaration : Parser Declaration := fun ts => do
  let ts ←accept "const" ts
  let ts ←accept "uint" ts
  bindings 4 ts

def parse (source : String) : Option Declaration := do
  let (actual,rest) ←declaration (←PackedArraySyntax.tokenize source)
  if rest=[] then some actual else none

def gateBlockSource : String := "const uint gWpb = (uint)(BT * KG / 32);"
def upBlockSource : String := "const uint uWpb = (uint)(BT * KU / 32);"
def runsSource : String := "const uint runsPerBlock = (uint)BT / 32u;"
def gateRowSource : String := "const uint gRow = row * (uint)((C / BT) * gWpb);"
def upRowSource : String := "const uint uRow = row * (uint)((C / BT) * uWpb);"
def blockSource : String := "const uint blk = run / runsPerBlock;"
def offsetSource : String := "const uint t0 = (run - blk * runsPerBlock) * 32u;"
def basesSource : String := "const uint gw = gRow + blk * gWpb, uw = uRow + blk * uWpb;"
def gateFirstSource : String := "const uint gW0 = ((uint)BT - 32u - t0) * (uint)KG / 32u;"
def upFirstSource : String := "const uint uW0 = ((uint)BT - 32u - t0) * (uint)KU / 32u;"
def sources : List String := [gateBlockSource,upBlockSource,runsSource,gateRowSource,upRowSource,blockSource,offsetSource,basesSource,gateFirstSource,upFirstSource]
private def v := PackedArraySyntax.Expr.variable
private def s (n : Nat) := PackedArraySyntax.Expr.literal .signed n
private def u (n : Nat) := PackedArraySyntax.Expr.literal .unsigned n
open PackedArraySyntax.Expr in
def code : List Declaration := [
  [("gWpb",castUInt (divide (multiply (v "BT") (v "KG")) (s 32)))],
  [("uWpb",castUInt (divide (multiply (v "BT") (v "KU")) (s 32)))],
  [("runsPerBlock",divide (castUInt (v "BT")) (u 32))],
  [("gRow",multiply (v "row") (castUInt (multiply (divide (v "C") (v "BT")) (v "gWpb"))))],
  [("uRow",multiply (v "row") (castUInt (multiply (divide (v "C") (v "BT")) (v "uWpb"))))],
  [("blk",divide (v "run") (v "runsPerBlock"))],
  [("t0",multiply (subtract (v "run") (multiply (v "blk") (v "runsPerBlock"))) (u 32))],
  [("gw",add (v "gRow") (multiply (v "blk") (v "gWpb"))),("uw",add (v "uRow") (multiply (v "blk") (v "uWpb")))],
  [("gW0",divide (multiply (subtract (subtract (castUInt (v "BT")) (u 32)) (v "t0")) (castUInt (v "KG"))) (u 32))],
  [("uW0",divide (multiply (subtract (subtract (castUInt (v "BT")) (u 32)) (v "t0")) (castUInt (v "KU"))) (u 32))]]

def parseSources (sources : List String) : Option (List Declaration) := sources.mapM parse

theorem parsed : parseSources sources=some code := rfl
end Inference.Kernels.Trellis.GatePointerSyntax
