import kernels.quantization.AffineInput4Source

namespace Inference.Kernels.Quantization.MlxQmvInput4Source
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Copy.ScalarCopySyntax (Parser accept)
open Trellis.GateTailSyntax (tokenize)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
open AffineInput4Syntax
set_option maxRecDepth 10000

-- Template substitution resolves the identifier token before the existing
-- expression/assignment parser; it does not rewrite source substrings.
def substitute (tokens : List String) : List String :=
  tokens.map (fun token => if token="values_per_thread" then "16" else token)
def parseLoop (source : String) : Option Program := do
  parseTokens (substitute (←tokenize source))
def parseInitial (source : String) : Option Nat := do
  let rest ←tokenize source
  let rest ←acceptMany ["U","sum","="] rest
  let (value,rest) ←number rest
  let rest ←accept ";" rest
  if rest=[] then some value else none

def sourceInitial : String := "U sum = 0;"
def sourceLoop : String := r#"for (int i = 0; i < values_per_thread; i += 4) {
      sum += x[i] + x[i + 1] + x[i + 2] + x[i + 3];
      x_thread[i] = x[i];
      x_thread[i + 1] = x[i + 1] / 16.0f;
      x_thread[i + 2] = x[i + 2] / 256.0f;
      x_thread[i + 3] = x[i + 3] / 4096.0f;
    }"#
def sourceReturn : String := "return sum;"
theorem parsed_initial : parseInitial sourceInitial=some 0 := by decide +kernel
theorem parsed_loop : parseLoop sourceLoop=some body := by decide +kernel
theorem parsed_return : parseReturn sourceReturn=some () := by decide +kernel
attribute [local irreducible] parseLoop parseInitial parseReturn

def execute (divide : Float32→Float32→Float32) (bytes : HalfMemory.Bytes) (base : Nat)
    (privateCells : Nat→Float32) : Option (Float32×(Nat→Float32)) := do
  let initial ←parseInitial sourceInitial
  let program ←parseLoop sourceLoop
  let indices ←AffineInput4Source.visits 4 program.start program.bound program.stride
  let _ ←parseReturn sourceReturn
  pure (AffineInput4Source.sum bytes base program indices (Float32.ofInt initial),
    MemoryCells.execute (AffineInput4Source.stores divide bytes base program indices) privateCells)

theorem execute_eq (divide : Float32→Float32→Float32) (bytes : HalfMemory.Bytes) (base : Nat)
    (before : Nat→Float32) :
    execute divide bytes base before=AffineInput4Source.execute divide bytes base before := by
  simp only [execute,AffineInput4Source.execute,parsed_initial,parsed_loop,parsed_return,
    AffineInput4Syntax.parsed_initializer,AffineInput4Syntax.parsed_loop,AffineInput4Syntax.parsed_return]

theorem execution (p : AffineTile.Platform) {x : Fin 16→AffineInput.BF}
    (buffer : ArrayStorage.BFBuffer x) (before : Nat→Float32) :
    ∃ cells,execute p.divide buffer.bytes buffer.base before=some (AffineInput.summed x AffineInput.groups4,cells) ∧
      ∀ i j,cells (4*i.val+j.val)=AffineTile.prepared4 p x i j := by
  rw [execute_eq]
  exact AffineInput4Source.execution p buffer before

end Inference.Kernels.Quantization.MlxQmvInput4Source
