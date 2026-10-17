import kernels.normalization.MlxRmsLoopSyntax
namespace Inference.Kernels.Quantization.AffineDequantizeSyntax
open Kernels.Copy.ScalarCopySyntax (Tokens accept)
open Kernels.Normalization.MlxRmsLoopSyntax (acceptAll)
set_option maxRecDepth 10000

-- The trusted host guard extracts and binds every token of each complete
-- native body, including unselected branches. Lean checks the restricted
-- token grammar; this is not a verified C++ lexer, frontend or compiler.
def parseExact (expected tokens : Tokens) : Option Unit := do
  let rest ←acceptAll expected tokens
  if rest=[] then some () else none

private theorem accepts_self (tokens : Tokens) : acceptAll tokens tokens=some [] := by
  induction tokens with
  | nil => rfl
  | cons token rest ih =>
    simp only [acceptAll,accept,ite_true]
    exact ih

theorem exact_self (tokens : Tokens) : parseExact tokens tokens=some () := by
  rw [parseExact,accepts_self]
  rfl

def bodySource : String := r#"constexpr int pack_factor = get_pack_factor<bits, 8>();
  constexpr int bytes_per_pack = get_bytes_per_pack<bits>();

  size_t offset = index.x + grid_dim.x * size_t(index.y);
  size_t oindex = offset * pack_factor;
  size_t gindex = oindex / group_size;
  T scale = scales[gindex];
  T bias = biases[gindex];

  out += oindex;

  if (bits == 3) {
    w += offset * bytes_per_pack;
    out[0] = (w[0] & 0x7) * scale + bias;
    out[1] = ((w[0] & 0x38) >> 3) * scale + bias;
    out[2] = (((w[0] & 0xc0) >> 6) + ((w[1] & 0x1) << 2)) * scale + bias;
    out[3] = ((w[1] & 0xe) >> 1) * scale + bias;
    out[4] = ((w[1] & 0x70) >> 4) * scale + bias;
    out[5] = (((w[1] & 0x80) >> 7) + ((w[2] & 0x3) << 1)) * scale + bias;
    out[6] = ((w[2] & 0x1c) >> 2) * scale + bias;
    out[7] = ((w[2] & 0xe0) >> 5) * scale + bias;
  } else if (bits == 5) {
    w += offset * bytes_per_pack;
    out[0] = (w[0] & 0x1f) * scale + bias;
    out[1] = (((w[0] & 0xe0) >> 5) + ((w[1] & 0x3) << 3)) * scale + bias;
    out[2] = ((w[1] & 0x7c) >> 2) * scale + bias;
    out[3] = (((w[1] & 0x80) >> 7) + ((w[2] & 0xf) << 1)) * scale + bias;
    out[4] = (((w[2] & 0xf0) >> 4) + ((w[3] & 0x1) << 4)) * scale + bias;
    out[5] = ((w[3] & 0x3e) >> 1) * scale + bias;
    out[6] = (((w[3] & 0xc0) >> 6) + ((w[4] & 0x7) << 2)) * scale + bias;
    out[7] = ((w[4] & 0xf8) >> 3) * scale + bias;
  } else if (bits == 6) {
    w += offset * bytes_per_pack;
    out[0] = (w[0] & 0x3f) * scale + bias;
    out[1] = (((w[0] >> 6) & 0x03) + ((w[1] & 0x0f) << 2)) * scale + bias;
    out[2] = (((w[1] >> 4) & 0x0f) + ((w[2] & 0x03) << 4)) * scale + bias;
    out[3] = ((w[2] >> 2) & 0x3f) * scale + bias;
  } else {
    uint val = w[offset];
#pragma clang loop unroll(full)
    for (int i = 0; i < pack_factor; i++) {
      uint8_t d;
      if (bits == 2) {
        d = (val >> (bits * i)) & 0x03;
      } else if (bits == 4) {
        d = (val >> (bits * i)) & 0x0f;
      } else if (bits == 8) {
        d = val;
      }
      out[i] = scale * d + bias;
    }
  }"#

def bodyTokens : Tokens := ["constexpr","int","pack_factor","=","get_pack_factor","<","bits",",","8",">","(",")",";","constexpr","int","bytes_per_pack","=","get_bytes_per_pack","<","bits",">","(",")",";","size_t","offset","=","index.x","+","grid_dim.x","*","size_t","(","index.y",")",";","size_t","oindex","=","offset","*","pack_factor",";","size_t","gindex","=","oindex","/","group_size",";","T","scale","=","scales","[","gindex","]",";","T","bias","=","biases","[","gindex","]",";","out","+","=","oindex",";","if","(","bits","=","=","3",")","{","w","+","=","offset","*","bytes_per_pack",";","out","[","0","]","=","(","w","[","0","]","&","0x7",")","*","scale","+","bias",";","out","[","1","]","=","(","(","w","[","0","]","&","0x38",")",">",">","3",")","*","scale","+","bias",";","out","[","2","]","=","(","(","(","w","[","0","]","&","0xc0",")",">",">","6",")","+","(","(","w","[","1","]","&","0x1",")","<","<","2",")",")","*","scale","+","bias",";","out","[","3","]","=","(","(","w","[","1","]","&","0xe",")",">",">","1",")","*","scale","+","bias",";","out","[","4","]","=","(","(","w","[","1","]","&","0x70",")",">",">","4",")","*","scale","+","bias",";","out","[","5","]","=","(","(","(","w","[","1","]","&","0x80",")",">",">","7",")","+","(","(","w","[","2","]","&","0x3",")","<","<","1",")",")","*","scale","+","bias",";","out","[","6","]","=","(","(","w","[","2","]","&","0x1c",")",">",">","2",")","*","scale","+","bias",";","out","[","7","]","=","(","(","w","[","2","]","&","0xe0",")",">",">","5",")","*","scale","+","bias",";","}","else","if","(","bits","=","=","5",")","{","w","+","=","offset","*","bytes_per_pack",";","out","[","0","]","=","(","w","[","0","]","&","0x1f",")","*","scale","+","bias",";","out","[","1","]","=","(","(","(","w","[","0","]","&","0xe0",")",">",">","5",")","+","(","(","w","[","1","]","&","0x3",")","<","<","3",")",")","*","scale","+","bias",";","out","[","2","]","=","(","(","w","[","1","]","&","0x7c",")",">",">","2",")","*","scale","+","bias",";","out","[","3","]","=","(","(","(","w","[","1","]","&","0x80",")",">",">","7",")","+","(","(","w","[","2","]","&","0xf",")","<","<","1",")",")","*","scale","+","bias",";","out","[","4","]","=","(","(","(","w","[","2","]","&","0xf0",")",">",">","4",")","+","(","(","w","[","3","]","&","0x1",")","<","<","4",")",")","*","scale","+","bias",";","out","[","5","]","=","(","(","w","[","3","]","&","0x3e",")",">",">","1",")","*","scale","+","bias",";","out","[","6","]","=","(","(","(","w","[","3","]","&","0xc0",")",">",">","6",")","+","(","(","w","[","4","]","&","0x7",")","<","<","2",")",")","*","scale","+","bias",";","out","[","7","]","=","(","(","w","[","4","]","&","0xf8",")",">",">","3",")","*","scale","+","bias",";","}","else","if","(","bits","=","=","6",")","{","w","+","=","offset","*","bytes_per_pack",";","out","[","0","]","=","(","w","[","0","]","&","0x3f",")","*","scale","+","bias",";","out","[","1","]","=","(","(","(","w","[","0","]",">",">","6",")","&","0x03",")","+","(","(","w","[","1","]","&","0x0f",")","<","<","2",")",")","*","scale","+","bias",";","out","[","2","]","=","(","(","(","w","[","1","]",">",">","4",")","&","0x0f",")","+","(","(","w","[","2","]","&","0x03",")","<","<","4",")",")","*","scale","+","bias",";","out","[","3","]","=","(","(","w","[","2","]",">",">","2",")","&","0x3f",")","*","scale","+","bias",";","}","else","{","uint","val","=","w","[","offset","]",";","#","pragma","clang","loop","unroll","(","full",")","for","(","int","i","=","0",";","i","<","pack_factor",";","i","+","+",")","{","uint8_t","d",";","if","(","bits","=","=","2",")","{","d","=","(","val",">",">","(","bits","*","i",")",")","&","0x03",";","}","else","if","(","bits","=","=","4",")","{","d","=","(","val",">",">","(","bits","*","i",")",")","&","0x0f",";","}","else","if","(","bits","=","=","8",")","{","d","=","val",";","}","out","[","i","]","=","scale","*","d","+","bias",";","}","}"]

def parseBody : Tokens → Option Unit := parseExact bodyTokens
theorem parsed_body : parseBody bodyTokens=some () := exact_self _

def packSource : String := r#"return (bits == 3 || bits == 5) ? 8 : (bits == 6 ? 4 : wsize / bits);"#

def packTokens : Tokens := ["return","(","bits","=","=","3","|","|","bits","=","=","5",")","?","8",":","(","bits","=","=","6","?","4",":","wsize","/","bits",")",";"]

def parsePack : Tokens → Option Unit := parseExact packTokens
theorem parsed_pack : parsePack packTokens=some () := exact_self _

def bytesSource : String := r#"constexpr int power_of_2_bits = (bits & (bits - 1)) == 0;
  return power_of_2_bits ? (wsize / 8) : (bits == 5 ? 5 : 3);"#

def bytesTokens : Tokens := ["constexpr","int","power_of_2_bits","=","(","bits","&","(","bits","-","1",")",")","=","=","0",";","return","power_of_2_bits","?","(","wsize","/","8",")",":","(","bits","=","=","5","?","5",":","3",")",";"]

def parseBytes : Tokens → Option Unit := parseExact bytesTokens
theorem parsed_bytes : parseBytes bytesTokens=some () := exact_self _

end Inference.Kernels.Quantization.AffineDequantizeSyntax
